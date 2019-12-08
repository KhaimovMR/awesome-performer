local gears = require('gears')
local recurrent_clicks_timeout = 1
local recurrent_clicks_timer
local multiclicks = {
    multiclicks = {
        _1 = function()end,
        _2 = function()end,
        _3 = function()end,
        _4 = function()end,
    },
    clicks_count = 0
}


function multiclicks.trigger(e, trigger_mouse_button)
    if recurrent_clicks_timer == nil then
        recurrent_clicks_timer = gears.timer.start_new(
            recurrent_clicks_timeout,
            function()
                local key = '_' .. tostring(multiclicks.clicks_count)

                if multiclicks.multiclicks[key] then
                    multiclicks.multiclicks[key]()
                else
                    nt('No function')
                end

                multiclicks.clicks_count = 0
                recurrent_clicks_timer = nil
            end
        )
    end

    multiclicks.clicks_count = multiclicks.clicks_count + 1
end


return multiclicks
