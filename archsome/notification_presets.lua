naughty = require('naughty')

return {
    devices = {
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#888866",
        border_width = 0,
        opacity=0.8,
        category='device.added',
        timeout=3,
    },
    user_session_commands = {
        shape = function(cs, width, height)
            return gears.shape.rounded_bar(cs, width, height, 40)
        end,
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#ffffff22",
        border_color = '#666666',
        border_width = 1,
        opacity=1,
        category='device.added',
        timeout=2,
        singleton_type = 'user_session_commands',
    },
    system = {
        shape = function(cs, width, height)
            return gears.shape.rounded_bar(cs, width, height, 40)
        end,
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#66776699",
        border_color = '#666666',
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=2,
    },
    system_keyboard_connected = {
        shape = function(cs, width, height)
            return gears.shape.rounded_bar(cs, width, height, 40)
        end,
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#66776699",
        border_color = '#666666',
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=2,
        singleton_type = 'system_keyboard_connected', -- distinct/unique notification id
    },
    system_mouse_connected = {
        shape = function(cs, width, height)
            return gears.shape.rounded_bar(cs, width, height, 40)
        end,
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#66776699",
        border_color = '#666666',
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=2,
        singleton_type = 'system_mouse_connected', -- distinct/unique notification id
    },
    interface = {
        shape = function(cs, width, height)
            return gears.shape.rounded_bar(cs, width, height, 40)
        end,
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#66776699",
        border_color = '#666666',
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=2,
    },
    audio = {
        shape = function(cs, width, height)
            return gears.shape.rounded_bar(cs, width, height, 40)
        end,
        preset=naughty.config.presets.normal,
        margin=10,
        position='middle',
        bg="#66776699",
        border_color = '#666666',
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=2,
        singleton_type = 'audio', -- distinct/unique notification id
    },
    urgent = {
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#cc4444",
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=30,
    },
    warning = {
        preset=naughty.config.presets.normal,
        position='middle',
        bg="#ccaa44",
        border_width = 0,
        opacity=1,
        category='device.added',
        timeout=30,
    },
}
