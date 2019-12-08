local awful = require('awful')
require('performer.utils')

callback_shell = {callbacks = {}}


local function get_next_id()
    next_id = 1

    while callback_shell.callbacks[next_id] do
        next_id = next_id + 1 
    end

    return next_id
end


function callback_shell.destroy_callback(id)
    if callback_shell.callbacks[id] then
        if callback_shell.callbacks[id].timer then
            callback_shell.callbacks[id].timer:stop()
            callback_shell.callbacks[id].timer = nil
        end

        callback_shell.callbacks[id] = nil
    end
end


function callback_shell.spawn(command, callback, timeout)
    local id = get_next_id()
    local formatted_command = string.gsub(command, '"','\"')
    callback_shell.callbacks[id] = {callback = callback}
    local script = string.format(
        "echo \"callback_shell.catch_callback(%s, [[$(%s)#####$?]])\" | awesome-client &",
        id, formatted_command
    )

    awful.spawn.with_shell(script)

    if timeout and timeout > 0 then
        callback_shell.callbacks[id].timer = timer({timeout = timeout})
        callback_shell.callbacks[id].timer:connect_signal(
            "timeout",
            function() callback_shell.destroy_callback(id) end
        )
        callback_shell.callbacks[id].timer:start()
    end
end


function callback_shell.catch_callback(id, output)
    local split_result = split_string(output, '#####')
    local script_output = split_result[1]
    local exit_code = tonumber(split_result[2])

    if callback_shell.callbacks[id] then
        callback_shell.callbacks[id].callback(script_output, exit_code)
        callback_shell.destroy_callback(id)
    end
end

return callback_shell
