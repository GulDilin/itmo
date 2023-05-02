local function init_spaces()
    local customer = box.schema.space.create(
        -- name of the space for storing customers
        'customer',
        -- extra parameters
        {
            -- format for stored tuples
            format = {
                {'customer_id', 'unsigned'},
                {'bucket_id', 'unsigned'},
                {'name', 'string'},
            },
            -- creating the space only if it doesn't exist
            if_not_exists = true,
        }
    )

    -- creating an index by customer's id
    customer:create_index('customer_id', {
        parts = {'customer_id'},
        if_not_exists = true,
    })

    customer:create_index('bucket_id', {
        parts = {'bucket_id'},
        unique = false,
        if_not_exists = true,
    })

    -- similarly, creating a space for accounts
    local account = box.schema.space.create('account', {
        format = {
            {'account_id', 'unsigned'},
            {'customer_id', 'unsigned'},
            {'bucket_id', 'unsigned'},
            {'balance', 'string'},
            {'name', 'string'},
        },
        if_not_exists = true,
    })

    -- similar indexes
    account:create_index('account_id', {
        parts = {'account_id'},
        if_not_exists = true,
    })
    account:create_index('customer_id', {
        parts = {'customer_id'},
        unique = false,
        if_not_exists = true,
    })

    account:create_index('bucket_id', {
        parts = {'bucket_id'},
        unique = false,
        if_not_exists = true,
    })
end

local function customer_add(customer)
    customer.accounts = customer.accounts or {}

    -- opening a transaction
    box.begin()

    -- inserting a tuple into the customer space
    box.space.customer:upsert({
        customer.customer_id,
        customer.bucket_id,
        customer.name
    }, {{'=', 2, customer.name }})
    for _, account in ipairs(customer.accounts) do
        -- inserting a tuple into the account space
        box.space.account:insert({
            account.account_id,
            customer.customer_id,
            customer.bucket_id,
            '0.00',
            account.name
        })
    end

    -- committing the transaction
    box.commit()
    return true
end

local function customer_lookup(customer_id)
    checks('number')

    local customer = box.space.customer:get(customer_id)
    if customer == nil then
        return nil
    end
    customer = {
        customer_id = customer.customer_id;
        name = customer.name;
    }
    local accounts = {}
    for _, account in box.space.account.index.customer_id:pairs(customer_id) do
        table.insert(accounts, {
            account_id = account.account_id;
            name = account.name;
            balance = account.balance;
        })
    end
    customer.accounts = accounts;

    return customer
end


local exported_functions = {
    customer_add = customer_add,
    customer_lookup = customer_lookup,
}

local checks = require('checks')


local function init(opts)
    if not box.cfg.read_only then
        -- calling the space initialization function
        init_spaces()

        for name in pairs(exported_functions) do
            box.schema.func.create(name, {if_not_exists = true})
            box.schema.role.grant('public', 'execute', 'function', name, {if_not_exists = true})
        end
    end

    for name, func in pairs(exported_functions) do
        rawset(_G, name, func)
    end

    return true
end

local function stop()
    return true
end

local function validate_config(conf_new, conf_old) -- luacheck: no unused args
    return true
end

local function apply_config(conf, opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end

    return true
end

return {
    role_name = 'app.roles.storage',
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
    dependencies = {
        'cartridge.roles.vshard-storage',
    },
}
