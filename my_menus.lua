local awful = require('awful')
local gears = require('gears')
local my_home_path = os.getenv('HOME')
local callback_shell = require('performer.callback_shell')
require('performer.utils')
require('my_functions')

terminals_tmuxinator_menu_items = {}

-- PATCHED VERSION OF THE MENU KEYS HANDLER RECEIVES THE LOWERCASED
-- STRING OF THE KEYS COMBINATION WITH MODIFIERS SET IN THE PRIORITY
-- (ONE BY ONE) shift-control-mod1-mod4-<symbol>
awful.menu.menu_keys.up = {'k', 'p', 'л', 'з'}
awful.menu.menu_keys.down = {'j', 'n', 'о', 'т'}
awful.menu.menu_keys.close = {
    '9', 'control-c', 'control-с', 'escape', 'q', 'mod4-o', 'mod4-f', 'mod4-k', 'mod4-j', 'mod4-t',
    'control-mod4-n', 'й', 'mod4-щ', 'mod4-а', 'mod4-л', 'mod4-о', 'control-mod4-т', 'mod4-е'
}
awful.menu.menu_keys.exec = {'return', 'l', 'д'}
local normal_icon = my_home_path .. "/gdrive/awesome-performer/icons/bullet-normal.png"
local focus_icon = my_home_path .. "/gdrive/awesome-performer/icons/bullet-focus.png"

local my_menus_theme = {
    font = 'ubuntu mono 13',
    border_color = "#559966",
    border_width = 0,
    height = 48,
    width = 260,
    bg_normal = "#559966",
    bg_focus = "#ccffdd",
    fg_normal = "#ffffff",
    fg_focus = "#111111",
    radius = 20,
}


local function get_cheat_sheets_menu_items()
    local cheat_sheets_dir = my_home_path .. '/gdrive/awesome-performer/cheatsheets'
    local ls_output = os.capture("ls -1 " .. cheat_sheets_dir .. "/*.png | awk -F '/' '{print $NF}'", true)
    local files = split_string(ls_output, '\r\n')
    local menu_items = {}
    local counter = 0

    for _, file in pairs(files) do
        counter = counter + 1
        table.insert(
            menu_items,
            {
                '[CH] &' .. tostring(counter) .. '. ' ..
                    file:gsub('.png', '')
                    :gsub('[-_]', ' ')
                    :gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end),
                'sxiv -f ' .. cheat_sheets_dir .. '/' .. file,
            }
        )
    end

    return menu_items
end


local function get_terminals_tmuxinator_menu_items(args)
    local prefix = args.prefix
    local short_name = args.short_name
    local terminal_title_suffix = args.terminal_title_suffix
    local terminal_profile = args.terminal_profile
    local menu_item_function_key = string.format(
        '%s-%s-%s-%s',
        prefix, short_name, terminal_title_suffix, terminal_profile
    )
    local tmuxinator_config_path = my_home_path .. '/.config/tmuxinator'
    local ls_output = os.capture(
        "ls -1 " .. tmuxinator_config_path .. "/" .. prefix .. "*.yml | awk -F '/' '{print $NF}'", true
    )
    local files = split_string(ls_output, '\r\n')
    local menu_items = {}
    local counter = 0
    local terminal_title = ''
    local file_stripped = ''
    local file_short_name = ''
    local short_name_suffix = ''
    local representation_name = ''
    local cmd_to_run = ''

    for _, file in pairs(files) do
        file_stripped = file:gsub('[.]yml', '')
        file_short_name = file_stripped:
            gsub(prefix:gsub('[-]', '[-]'), '')
        representation_name = file_short_name:
            gsub('[-_]', ' '):
            gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
        short_name_suffix = file_short_name:
            gsub("(%l)(%w*)", function(a,b) return string.upper(a) end):
            gsub('[-_]', '')
        terminal_title = file_stripped .. terminal_title_suffix
        counter = counter + 1
        cmd_to_run = string.format(
            'terminator --title="%s" --profile="%s" -e "ts-router %s %s"',
            terminal_title,
            terminal_profile,
            short_name .. '-' .. short_name_suffix,
            file_stripped
        )
        table.insert(
            menu_items,
            {
                '&' .. tostring(counter) .. '. ' .. representation_name,
                return_termial_applicationrunner(representation_name, cmd_to_run, terminal_title)
            }
        )
    end

    return menu_items
end


function return_termial_applicationrunner(representation_name, cmd_to_run, terminal_title)
    return function()
        start_application_with_check({
            representation_name,
            cmd_to_run,
            terminal_title,
            true
        })
    end
end

my_cheat_sheets_menu = awful.menu({
    items = get_cheat_sheets_menu_items(),
    theme = my_menus_theme,
})

my_monitors_menu = awful.menu({
    items = {
        {
            '[MON] &1. eDP1',
            {
                {'&1. ENABLE/DISABLE', 'ws-screens-layout.sh edp-toggle'},
            }
        },
        {
            '[MON] &2. HDMI1',
            {
                {'&1. ENABLE/DISABLE', 'ws-screens-layout.sh hdmi-toggle'},
                {'&2. LOW RES MODE', 'ws-screens-layout.sh toggle-low-res'},
                {'&3. ROTATION', 'ws-screens-layout.sh rotate ' .. HDMI1},
            }
        },
        {
            '[MON] &3. DP1',
            {
                {'&1. ENABLE/DISABLE', 'ws-screens-layout.sh toggle'},
                {'&2. LOW RES MODE', 'ws-screens-layout.sh toggle-low-res-dp1'},
                {'&3. ROTATION', 'ws-screens-layout.sh rotate ' .. DP1},
            }
        },
        { '[MON] &4. RESET', 'ws-screens-layout.sh' },
    },
    theme = my_menus_theme,
})

my_browsers_menu = awful.menu({
    items = {
        {'[BROWSER] &1. Default', function() browser_router('default') end},
        {'[BROWSER] &2. Work 1',  function() browser_router('work') end},
        {'[BROWSER] &3. Work 2', function() browser_router('work_2') end},
        {'[BROWSER] &4. YouTube', function() browser_router('youtube', 'https://youtube.com') end},
        {
            '[BROWSER] &5. Google Music',
            function()
                browser_router('youtube', 'https://play.google.com/music/listen#/wmp')
            end
        },
        {'[BROWSER] &6. Repositories', function() browser_router('github', 'https://github.com') end},
    },
    theme = my_menus_theme,
})

my_translators_menu = awful.menu({
    items = {
        {'[TR] &1. English', function() kbdcfg.switch(true, 'us'); web_query_execute('t') end},
        {'[TR] &2. Russian', function() kbdcfg.switch(true, 'ru'); web_query_execute('tr') end},
        {'[TR] &3. Ukrainian', function() kbdcfg.switch(true, 'ru'); web_query_execute('tu') end},
        {'[TR] &4. Hebrew', function() kbdcfg.switch(true, 'us'); web_query_execute('th') end},
    },
    theme = my_menus_theme,
})

my_gmail_menu = awful.menu({
    items = {
        {
            '[GMAIL] &1. Personal',
            function() start_applications_section('personal', gmail_menu_apps) end
        },
        {
            '[GMAIL] &2. Work 1',
            function() start_applications_section('work1', gmail_menu_apps) end
        },
        {
            '[GMAIL] &3. Work 2',
            function() start_applications_section('work2', gmail_menu_apps) end
        },
    },
    theme = my_menus_theme,
})
