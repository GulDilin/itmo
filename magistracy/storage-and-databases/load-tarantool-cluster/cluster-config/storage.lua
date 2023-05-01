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

local function init(opts)
    if not box.cfg.read_only then
        -- calling the space initialization function
        init_spaces()
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
}
