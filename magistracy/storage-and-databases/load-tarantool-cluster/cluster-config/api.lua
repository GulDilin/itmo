local vshard = require('vshard')
local cartridge = require('cartridge')
local errors = require('errors')

local err_vshard_router = errors.new_class("Vshard routing error")
local err_httpd = errors.new_class("httpd error")


local function customer_add(customer)
    local bucket_id = vshard.router.bucket_id(customer.customer_id)
    customer.bucket_id = bucket_id
    local _, error = err_vshard_router:pcall(
        vshard.router.call,
        bucket_id,
        'write',
        'customer_add',
        {customer}
    )
    return _, error
end


local function customer_lookup(customer_id)
    local bucket_id = vshard.router.bucket_id(customer_id)
    local customer, error = err_vshard_router:pcall(
        vshard.router.call,
        bucket_id,
        'read',
        'customer_lookup',
        {customer_id}
    )
    return customer, error
end


local function http_customer_add(req)
    local customer = req:json()
    local _, error = customer_add(customer)

    if error then
        local resp = req:render({json = {
            info = "Internal error",
            error = error
        }})
        resp.status = 500
        return resp
    end

    local resp = req:render({json = { info = "Successfully created" }})
    resp.status = 201
    return resp
end



local function http_customer_get(req)
    local customer_id = tonumber(req:stash('customer_id'))
    local customer, error = customer_lookup(customer_id)

    if error then
        local resp = req:render({json = {
            info = "Internal error",
            error = error
        }})
        resp.status = 500
        return resp
    end

    if customer == nil then
        local resp = req:render({json = { info = "Customer not found" }})
        resp.status = 404
        return resp
    end

    customer.bucket_id = nil
    local resp = req:render({json = customer})
    resp.status = 200
    return resp
end


local exported_functions = {
    customer_add = customer_add,
    customer_lookup = customer_lookup,
}


local function init(opts)
    rawset(_G, 'vshard', vshard)

    if opts.is_master then
        box.schema.user.grant('guest',
            'read,write,execute',
            'universe',
            nil, { if_not_exists = true }
        )
    end

    local httpd = cartridge.service_get('httpd')

    if not httpd then
        return nil, err_httpd:new("not found")
    end

    for name in pairs(exported_functions) do
        box.schema.func.create(name, {if_not_exists = true})
        box.schema.role.grant('public', 'execute', 'function', name, {if_not_exists = true})
    end

    for name, func in pairs(exported_functions) do
        rawset(_G, name, func)
    end

    -- assigning handler functions
    httpd:route(
        { path = '/storage/customers/create', method = 'POST', public = true },
        http_customer_add
    )
    httpd:route(
        { path = '/storage/customers/:customer_id', method = 'GET', public = true },
        http_customer_get
    )

    return true
end


return {
    role_name = 'api',
    init = init,
    dependencies = {'cartridge.roles.vshard-router'},
}
