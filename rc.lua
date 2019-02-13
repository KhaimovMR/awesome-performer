-- standard awesome library
local gears = require('gears')
local awful = require('awful')

require('my_functions')
require('my_vars')

--os.execute('ws-screens-layout.sh; sleep 5')

awful.rules = require('awful.rules')
awful.util.spawn_with_shell("killall unagi; sleep 5; unagi &")

require('awful.autofocus')
-- Widget and layout library
local wibox = require('wibox')
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')
local menubar = require('menubar')
local my_home_path = os.getenv('HOME')

-- {{{ Changing default style of notifications
naughty.config.defaults['border_width'] = '0'
naughty.config.presets['normal'] = {
    bg = '#3b8e15',
    fg = '#ffffff'
}
-- }}}

-- Load Debian menu entries
require('debian.menu')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal(
        'debug::error',
        function (err)
            -- Make sure we don't go into an endless error loop
            if in_error then
                return
            end

            in_error = true
            naughty.notify({
                preset = naughty.config.presets.critical,
                title = 'Oops, an error happened!',
                text = tostring(err) .. '\n\n' .. debug.traceback()
            })
            in_error = false
        end
    )
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init('~/.config/awesome/themes/theme.lua')

-- This is used later as the default terminal and editor to run.
terminal = 'x-terminal-emulator'
editor = os.getenv('EDITOR') or 'editor'

-- my editor --
editor = 'vim'

editor_cmd = terminal .. ' -e ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
altkey = 'Mod1'
modkey = 'Mod4'

-- Output names table filled to use later in tags management
output_names = {}

function get_output_names()
    local names = {
        --['eDP-1'] = nil,
        --['DP-1'] = nil,
        --['DP-2'] = nil,
        --['HDMI-1'] = nil,
        --['HDMI-2'] = nil,
    }

    for scr_idx = 1, screen.count() do
        name = get_keys(screen[scr_idx].outputs)[1]
        names[name] = scr_idx
        naughty.notify({text="Monitor connected: " .. name})
    end

    return names
end

output_names = get_output_names()

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags_per_virtual_screen_count = 12

function initialize_tags()
    local result_tags = {}
    local tags_count = 36 / screen.count()
    local screen_count = screen.count()
    local j = 1

    if screen_count == 2 then
        local tags_template_1 = {}
        local tags_template_2 = {}

        for i = 1, 24 do
            if j > 12 then
                j = 1
            end

            table.insert(tags_template_1, j)
            j = j + 1
        end

        j = 1

        for i = 1, 12 do
            table.insert(tags_template_2, j)
            j = j + 1
        end

        result_tags[1] = awful.tag(tags_template_1, 1, layouts[4])
        result_tags[2] = awful.tag(tags_template_2, 2, layouts[4])
    else
        local tags_template = {}

        for i = 1, tags_count do
            if j > 12 then
                j = 1
            end

            table.insert(tags_template, j)
            j = j + 1
        end

        for s = 1, screen_count do
            -- Each screen has its own tag table.
            result_tags[s] = awful.tag(tags_template, s, layouts[4])
        end
    end

    return result_tags
end

tags = initialize_tags()

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { 'manual', terminal .. ' -e man awesome' },
    { 'edit config', editor_cmd .. ' ' .. awesome.conffile },
    { 'restart', awesome.restart },
    { 'quit', awesome.quit }
}

mymainmenu = awful.menu({
    items = {
        { 'awesome', myawesomemenu, beautiful.awesome_icon },
        { 'Debian', debian.menu.Debian_menu.Debian },
        { 'open terminal', terminal }
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

require('my_tags')

-- Cheatsheets
local cheatsheets_directory = my_home_path .. '/Dropbox/Pictures/CheatSheets'


-- {{{ Wibox

-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button(
        { },
        1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else

            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false

            if not c:isvisible() then
                c:tags()[1]:view_only()
            end

            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
            end
        end
    ),
    awful.button(
        { },
        3,
        function ()
            if instance then
            instance:hide()
            instance = nil
            else
            instance = awful.menu.clients(
                { theme = { width = 250 } }
            )
            end
        end
    ),
    awful.button(
        { },
        4,
        function ()
            awful.client.focus.byidx(-1)

            if client.focus then
                client.focus:raise()
            end
        end
    ),
    awful.button(
        { },
        5,
        function ()
            awful.client.focus.byidx(1)

            if client.focus then
                client.focus:raise()
            end
        end
    )
)

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = 'setxkbmap -option "ctrl:nocaps"'
kbdcfg.layout = { { 'us', 'ru' }, { 'ru', 'us' } }
kbdcfg.current = 1 -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(' ' .. kbdcfg.layout[kbdcfg.current][1] .. ' ')
kbdcfg.switch = function (do_switch, specific_layout)
    local layout_pair
    local bg_color
    naughty.destroy_all_notifications(nil, -1)

    if do_switch == true then
        if specific_layout then
            if kbdcfg.layout[1][1] == specific_layout then
                kbdcfg.current = 1
            else
                kbdcfg.current = 2
            end
        else
            kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
        end

        layout_pair = kbdcfg.layout[kbdcfg.current]
        kbdcfg.widget:set_text(' ' .. layout_pair[1] .. ' ')
        os.execute(kbdcfg.cmd .. ' ' .. layout_pair[1] .. ',' .. layout_pair[2])
    else
        layout_pair = kbdcfg.layout[kbdcfg.current]
    end

    if layout_pair[1] == "ru" then
        bg_color = "#cc0000"
    else
        bg_color = "#0000cc"
    end

    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>" .. layout_pair[1] .. "</span>", border_width=300, border_color="transparent", position = "top_right", bg=bg_color, replaces_id = 0 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>" .. layout_pair[1] .. "</span>", border_width=300, border_color="transparent", position = "top_left", bg=bg_color, replaces_id = 1 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>" .. layout_pair[1] .. "</span>", border_width=300, border_color="transparent", position = "bottom_right", bg=bg_color, replaces_id = 2 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>" .. layout_pair[1] .. "</span>", border_width=300, border_color="transparent", position = "bottom_left", bg=bg_color, replaces_id = 3 })
end

-- Mouse bindings
kbdcfg.widget:buttons(
    awful.util.table.join(
        awful.button(
            { },
            1,
            function ()
                kbdcfg.switch(true, false)
            end
        )
    )
)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(
        awful.util.table.join(
            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
        )
    )
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = 'top', screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the bottom
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then 
        right_layout:add(wibox.widget.systray())
    end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])
    right_layout:add(kbdcfg.widget)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

-- }}}

-- {{{ Mouse bindings

require('my_mouse_bindings')
my_mouse_bindings(awful, mymainmenu)

-- }}}
--

--- {{{ Calendar widget
cal = require("cal")
cal.register(mytextclock, "<span background='#ff9999'><b>%s</b></span>") -- now the current day is bold instead of underline
-- }}}

clientkeys = awful.util.table.join(
    -- #41 - f
    awful.key(
        { modkey },
        '#41',
        function (c)
            c.fullscreen = not c.fullscreen
        end
    ),
    -- #54 - c
    awful.key(
        { modkey, 'Shift'   },
        '#54',
        function (c)
            c:kill()
        end
    ),
    awful.key(
        { modkey, 'Control' },
        'space',
        awful.client.floating.toggle
    ),
    awful.key(
        { modkey, 'Control' },
        'Return',
        function (c)
            c:swap(awful.client.getmaster())
        end
    ),
    -- #32 - o
    awful.key(
        { modkey },
        '#32',
        awful.client.movetoscreen
    ),
    -- #28 - t
    --awful.key(
        --{ modkey },
        --'#28',
        --function (c)
            --c.ontop = not c.ontop
        --end
    --),
    -- #57 - n
    awful.key(
        { modkey },
        '#57',
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            if c.minimized == true then
                c.minimized = false
            else
                c.minimized = true
            end
        end
    ),
    -- #58 - m
    awful.key({ modkey,           }, '#58',
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_verticalical
        end
    )
)

function eval_prompt(input)
    --local require("gears")\nrequire("awful")\nrequire("my_functions")\nrequire("my_vars")\nrequire("awful.rules")\nrequire("awful.autofocus")\nrequire("wibox")\nrequire("beautiful")\nrequire("naughty")\nrequire("menubar")\n'..input
    awful.util.eval(input)
end

-- {{{ Key bindings
-- You can use keycode ('#keycode') instead of key name ('key_name') as the second parameter to the function awful.key.
-- Keycode is the numeric code, that can be understood by "xmodmap" utility. It can be obtained from the "xev" utility
-- output.
--
function make_default_keys()
    local globalkeys = awful.util.table.join(
        awful.key({ modkey }, 'Left',   awful.tag.viewprev       ),
        awful.key({ modkey }, 'Right',  awful.tag.viewnext       ),
        awful.key({ modkey }, 'Escape', awful.tag.history.restore),
        awful.key({ modkey }, 'Tab',
            function ()
                awful.client.focus.byidx( 1)
                if client.focus then client.focus:raise() end
            end),
        awful.key({ modkey, 'Shift'   }, 'Tab',
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end),
        -- #25 - w
        -- awful.key({ modkey }, '#25', function () mymainmenu:show() end),

        -- Layout manipulation
        -- #44 - j
        awful.key({ modkey, 'Shift'   }, '#44', function () awful.client.swap.byidx(-1)    end),
        -- #45 - k
        awful.key({ modkey, 'Shift'   }, '#45', function () awful.client.swap.byidx(1)    end),
        -- #44 - j
        awful.key({ modkey, 'Control' }, '#44', function () awful.screen.focus(1) end),
        -- #45 - k
        awful.key({ modkey, 'Control' }, '#45', function () awful.screen.focus(2) end),
        -- #46 - l
        awful.key({ modkey, 'Control' }, '#46', function () awful.screen.focus(3) end),
        -- #30 - u
        awful.key({ modkey }, '#30', awful.client.urgent.jumpto),
        
        -- Standard program
        awful.key({ modkey }, 'Return', function () awful.util.spawn(terminal) end),
        -- #27 - r
        awful.key(
            { altkey, 'Control' },
            '#27',
            function ()
                --os.execute("ws-screens-layout.sh")
                my_tags['surfing_localhost'].screen = nil
                my_tags['surfing_localhost'].screen = screen[1]
            end
        ),
        -- #27 - r
        awful.key(
            { modkey, 'Control' },
            '#27',
            function ()
                --os.execute("ws-screens-layout.sh; sleep 5")
                awesome.restart()
            end
        ),
        -- #24 - q
        awful.key({ modkey, altkey, 'Shift' }, '#24', awesome.quit),
        -- #39 - s
        awful.key(
            { modkey, altkey, 'Shift' },
            '#39',
            function ()
                awful.util.spawn('dm-tool switch-to-greeter')
            end
        ),

        -- #43 - h
        awful.key({ modkey, 'Shift'   }, '#43',     function () awful.tag.incnmaster( 1)      end),
        -- #46 - l
        awful.key({ modkey, 'Shift'   }, '#46',     function () awful.tag.incnmaster(-1)      end),
        -- #43 - h
        awful.key({ modkey, 'Control' }, '#43',     function () awful.tag.incncol( 1)         end),
        -- #46 - l
        awful.key({ modkey, 'Control' }, '#46',     function () awful.tag.incncol(-1)         end),
        awful.key({ modkey,           }, 'space', function () awful.layout.inc(layouts,  1) end),
        awful.key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts, -1) end),
        awful.key({ modkey, 'Control' }, 'n', awful.client.restore),
        awful.key({ }, 'Pause', function () kbdcfg.switch(true, false) end),
        awful.key({ 'Control' }, 'space', function () kbdcfg.switch(true, false) end),
        awful.key({ 'Control' }, 'Pause', function () kbdcfg.switch(false, false) end),

        -- Prompt
        -- #27 - r
        awful.key(
            { modkey },
            '#27',
            function (evt)
                mypromptbox[1]:run()
            end
        ),
        -- # - x
        awful.key(
            { modkey },
            'x',
            function ()
                awful.prompt.run(
                    { prompt = 'Run Lua code: ' },
                    mypromptbox[1].widget,
                    eval_prompt,
                    nil,
                    awful.util.getdir('cache') .. '/history_eval'
                )
            end
        ),

        -- Menubar
        -- #33 - p
        awful.key(
            { modkey },
            '#33',
            function()
                kbdcfg.switch(true, 'us')
                menubar.show()
            end
        ),

        -- Lock screen (need to be installed through "apt-get install suckless-tools")
        -- #43 - h
        awful.key(
            { modkey },
            '#43',
            lock_screen
        ),

        -- Put PC into the sleep mode
        -- #44 - j
        awful.key(
            { modkey },
            '#44',
            function ()
                lock_screen()
                awful.util.spawn('systemctl suspend')
            end
        ),

        -- California (calendar)
        -- #38 - a
        awful.key(
            { modkey, 'Control' },
            '#38',
            function ()
                awful.util.spawn('california')
            end
        ),

        -- Kill dev django server
        -- #38 - a
        awful.key(
            { modkey },
            '#38',
            function ()
                my_tags['pyr']:view_only()
                awful.util.spawn('sudo pkill -fe runserver')
            end
        ),

        -- Anamnesis
        -- #55 - v
        awful.key(
            { 'Control', altkey },
            '#55',
            function ()
                awful.util.spawn('anamnesis --browse')
            end
        ),

        -- Skype shortcuts
        awful.key(
            {altkey},
            'End',
            function ()
                my_tags['skype']:view_only()
                awful.util.spawn('skypedbusctl recent')
            end
        ),
        awful.key(
            {altkey},
            'Home',
            function ()
                my_tags['skype']:view_only()
                awful.util.spawn('skypedbusctl missed')
            end
        ),
        awful.key(
            {altkey},
            'Next',
            function ()
                awful.util.spawn('skypedbusctl hang-up')
            end
        ),
        awful.key(
            {altkey},
            'Prior',
            function ()
                awful.util.spawn('skypedbusctl pick-up')
            end
        ),
        awful.key(
            {altkey},
            'Insert',
            function ()
                my_tags['skype']:view_only()
                awful.util.spawn('skypedbusctl contacts ' .. my_skype_login)
            end
        ),
        -- #56 - b
        awful.key(
            {  modkey },
            '#56',
            function ()
                awful.util.spawn('btc')
                naughty.notify({ text = 'Trying to connect/disconnect bluetooth A2DB device...' })
            end
        ),
        -- #39 - s
        awful.key(
            { 'Control', modkey },
            '#39',
            function ()
                awful.util.spawn('unity-control-center sound')
            end
        ),
        -- #25 - w
        awful.key(
            { 'Control', altkey },
            '#25',
            function ()
                start_applications_section(my_applications['work_terminals'])
            end
        ),
        -- #26 - e
        awful.key(
            { modkey },
            '#26',
            function ()
                dropdown_app_toggle("ChromeMindmeister")
            end
        ),
        -- #25 - w
        awful.key(
            { modkey },
            '#25',
            function ()
                dropdown_app_toggle("ChromeStuff")
            end
        ),
        -- #24 - q
        awful.key(
            { modkey },
            '#24',
            function ()
                dropdown_app_toggle("Terminal")
            end
        ),
        -- #45 - k
        awful.key(
            { modkey },
            '#45',
            function ()
                dropdown_app_toggle("AndroidKeyboard")
            end
        ),
        -- #58 - m
        awful.key(
            { 'Control', modkey },
            '#58',
            function ()
                start_applications_section(my_applications['mail'])
            end
        ),
        -- #25 - w
        awful.key(
            { 'Control', modkey },
            '#25',
            function ()
                dropdown_app_toggle("ChromeStuff")
                start_applications_section(my_applications['current_work_links'])
            end
        ),
        -- #41 - f
        awful.key(
            { 'Control', modkey },
            '#41',
            function ()
                awful.util.spawn('feh -FZNq ' .. cheatsheets_directory)
            end
        ),
        -- #31 - i
        awful.key(
            { 'Control', modkey },
            '#31',
            function ()
                start_applications_section(my_applications['jira'])
            end
        ),
        -- #30 - u
        awful.key(
            { 'Control', modkey },
            '#30',
            function ()
                start_applications_section(my_applications['wiki'])
            end
        ),
        -- #57 - n
        awful.key(
            { 'Control', modkey },
            '#57',
            function ()
                awful.screen.focus(surfing_screen)
                surfing_screen_tags[1 + screen_1_offset]:view_only()
                awful.util.spawn('google-chrome')
            end
        ),

        -- Get full screen screenshot
        -- #107 - PrintScreen
        awful.key(
            { },
            '#107',
            function ()
                awful.util.spawn('shutter -f')
            end
        ),

        -- Get screenshot with selection
        -- #107 - PrintScreen
        awful.key(
            { 'Control' },
            '#107',
            function ()
                awful.util.spawn('shutter -s')
            end
        )
    )

    -- Bind all key numbers to tags.
    -- Be careful: we use keycodes to make it works on any keyboard layout.
    -- This should map on the top row of your keyboard, usually 1 to 9.
    for i = 1, tags_per_virtual_screen_count do
        globalkeys = awful.util.table.join(
            globalkeys,
            -- Screen 1 tags
            awful.key(
                { modkey },
                '#' .. i + 9,
                function ()
                    dropdown_app_toggle('all', 'hide')
                    awful.screen.focus(surfing_screen)
                    surfing_screen_tags[i + screen_1_offset]:view_only()
                end
            ),

            -- Screen 2 tags
            awful.key(
                { 'Control' },
                '#' .. i + 9,
                function ()
                    dropdown_app_toggle('all', 'hide')
                    awful.screen.focus(work_screen)
                    work_screen_tags[i + screen_2_offset]:view_only()
                end
            ),

            -- Screen 3 tags
            awful.key(
                { altkey },
                '#' .. i + 9,
                function ()
                    dropdown_app_toggle('all', 'hide')
                    awful.screen.focus(planning_screen)
                    planning_screen_tags[i + screen_3_offset]:view_only()
                end
            ),

            -- Move client to tag.
            awful.key(
                { modkey, 'Shift' },
                '#' .. i + 9,
                function ()
                    if client.focus then
                        local tag = awful.tag.gettags(client.focus.screen)[i]

                        if tag then
                            awful.client.movetotag(tag)
                        end
                    end
                end
            ),

            -- Toggle compatibility keys mode
            -- #58 - m
            awful.key(
                { modkey, 'Control', 'Shift' },
                '#58',
                function ()
                    root.keys(make_compatible_keys())
                end
            )
        )
    end

    return globalkeys
end

function lock_screen()
    kbdcfg.switch(true, 'us')
    awful.util.spawn('slock')
    awful.util.spawn('sh -c "sleep 1 && xset dpms force off"')
end

function make_compatible_keys()
    local globalkeys = awful.util.table.join(
        awful.key({ modkey }, 'Left',   awful.tag.viewprev       ),
        awful.key({ modkey }, 'Right',  awful.tag.viewnext       ),
        awful.key({ modkey }, 'Escape', awful.tag.history.restore),
        awful.key({ modkey }, 'Tab',
            function ()
                awful.client.focus.byidx( 1)
                if client.focus then client.focus:raise() end
            end
        ),
        awful.key({ modkey, 'Shift'   }, 'Tab',
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end
        ),
        awful.key({ modkey, 'Control', 'Shift' }, 'Tab',
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end
        ),
        -- Toggle compatibility keys mode
        -- #58 - m
        awful.key(
            { modkey, 'Control', 'Shift' },
            '#58',
            function ()
                root.keys(make_default_keys())
                naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS OFF</span>", border_width=300, border_color="transparent", position = "top_right", bg="#227722", replaces_id = 0 })
                naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS OFF</span>", border_width=300, border_color="transparent", position = "top_left", bg="#227722", replaces_id = 1 })
                naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS OFF</span>", border_width=300, border_color="transparent", position = "bottom_right", bg="#227722", replaces_id = 2 })
                naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS OFF</span>", border_width=300, border_color="transparent", position = "bottom_left", bg="#227722", replaces_id = 3 })
            end
        ),
        awful.key({ }, 'Pause', function () kbdcfg.switch(true, false) end)
    )

    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS ON</span>", border_width=300, border_color="transparent", position = "top_right", bg="#cc0000", replaces_id = 0 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS ON</span>", border_width=300, border_color="transparent", position = "top_left", bg="#cc0000", replaces_id = 1 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS ON</span>", border_width=300, border_color="transparent", position = "bottom_right", bg="#cc0000", replaces_id = 2 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 24'>COMPATIBILITY MODE IS ON</span>", border_width=300, border_color="transparent", position = "bottom_left", bg="#cc0000", replaces_id = 3 })
    return globalkeys
end

globalkeys = make_default_keys()
-- Set keys
root.keys(globalkeys)


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    -- windows classes are acquired by the 'xprop | grep "WM_CLASS"' command
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = 'TeamViewer' }, properties = { tag = my_tags['teamviewer'], fullscreen = false, maximized = false, floating = true } },
    { rule = { class = 'Steam' }, properties = { tag = my_tags['games'] } },
    { rule = { class = 'csgo_linux64' }, properties = { tag = my_tags['games'] } },
    { rule = { instance = 'skype', class = 'Skype' }, properties = { tag = my_tags['skype'] } },
    { rule = { instance = 'skypeforlinux', class = 'skypeforlinux' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'TeamSpeak 3' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'TelegramDesktop' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'Viber' }, properties = { tag = my_tags['viber'] } },
    { rule = { class = 'Slack' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'discord' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'ViberPC' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'jetbrains-pychar' }, properties = { tag = my_tags['pycharm'], fullscreen = false } },
    { rule = { class = 'jetbrains-pycharm' }, properties = { tag = my_tags['pycharm'], fullscreen = false } },
    { rule = { instance = 'gnome-terminal' }, properties = { size_hints_honor = false } },
    { rule = { name = 'VimCoding-Python' }, properties = { tag = my_tags['vim_coding_python'], fullscreen = false } },
    { rule = { name = 'VimCoding-PHP' }, properties = { tag = my_tags['vim_coding_php'], fullscreen = false } },
    { rule = { instance = 'sun-awt-X11-XFramePeer', class = 'NetBeans IDE' }, properties = { tag = my_tags['netbeans'], fullscreen = false } },
    { rule = { instance = 'sun-awt-X11-XFramePeer', class = 'freemind-main-FreeMindStarte' }, properties = { tag = my_tags['freemind'] } },
    { rule = { instance = 'mysql-workbench-bin' }, properties = { tag = my_tags['mysql'] } },
    { rule = { instance = 'clementine' }, properties = { tag = my_tags['music'] } },
    { rule = { instance = 'tilda' }, properties = { fullscreen = true } },
    { rule = { class = 'Gimp'}, properties = { tag = my_tags['gimp'] } },
    { rule = { class = 'Inkscape'}, properties = { tag = my_tags['inkscape'] } },
    { rule = { instance='DropdownAppAndroidKeyboard' }, properties = { fullscreen = false, sticky = true, size_hints_honor = false } },
    { rule = { instance='DropdownAppTerminal' }, properties = { fullscreen=true, sticky=true, size_hints_honor = false } },
    { rule = { instance='DropdownAppChromeMindmeister' }, properties = { fullscreen = true, sticky = true } },
    { rule = { instance='DropdownAppChromeStuff' }, properties = { fullscreen = true, sticky = true } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c, startup)
    if c.instance == 'sun-awt-X11-XFramePeer' then
        naughty.notify({ title = c.class })
    elseif c.instance == 'terminator' or c.instance == 'x-terminal-emulator' then
        for tag_name, title in pairs(my_terminal_titles_to_intercept) do
            if c.name == title and value_exists_in_table(c.tags(c), my_tags[tag_name]) == false then
                naughty.notify({ title = 'Moved to the "' .. tag_name .. '" tag' })
                awful.client.movetotag(my_tags[tag_name], c)
                my_tags[tag_name]:view_only()
            end
        end
    end

    -- Enable sloppy focus
    --c:connect_signal('mouse::enter', function(c)
    --    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    --        and awful.client.focus.filter(c) then
    --        client.focus = c
    --    end
    --end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == 'normal' or c.type == 'dialog') then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align('center')
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal(
    'focus',
    function(c)
        c.border_color = beautiful.border_focus
    end
)

client.connect_signal(
    'unfocus',
    function(c)
        -- if c.instance:find('DropdownApp') ~= nil  then
            -- local app_name = string.sub(c.instance, 12, string.len(c.instance))
            -- dropdown_app_toggle(app_name, 'hide')
        -- end

        c.border_color = beautiful.border_normal
    end
)
-- }}}


function client_signals(c)
    if not c.name then
        return
    end

    if c.name:find('DropdownApp') ~= nil  then
        c.border_width = 0
        c.fullscreen = true
    elseif c.class == 'Firefox' and c.name:find('JIRA') ~= nil and c.tag ~= my_tags['jira'] then
        awful.client.movetotag(my_tags['jira'], c)
    elseif c.class == my_browser_window_class_1 or c.class == my_browser_window_class_2
        and c.name ~= nil then
        local focused_screen = awful.screen.focused()
        local focused_tag = focused_screen.selected_tag
        local was_focused_before = value_exists_in_table(c.tags(c), focused_tag)
        local new_client_tags = {}

        for tag_name, title_pattern in pairs(my_browser_titles_to_intercept) do
            if c.name:find(title_pattern) ~= nil then
                c:move_to_tag(my_tags[tag_name])

                if was_focused_before then
                    my_tags[tag_name]:view_only()
                    client.focus = c
                    return
                end

                return
            end
        end

        c:move_to_tag(my_tags['surfing_localhost'])

        if was_focused_before then
            my_tags['surfing_localhost']:view_only()
        end
    end
end

client.connect_signal(
    'property::name',
    client_signals
)

tag.connect_signal(
    'request::screen',
    function (t)
        naughty.notify({title = tostring(t)})

        if screen.count() == 2 then
            t.screen = screen[1]
        elseif screen.count() == 1 then
            t.screen = screen[1]
        end
    end
)

--client.connect_signal(
 --   'request::activate',
  --  client_signals
--)

do
    for _, apps_section_name in pairs(my_startup_sections) do
        applications = my_applications[apps_section_name]

        if apps_section_name == "current_work_links" then
            dropdown_app_toggle("ChromeStuff")
        end

        start_applications_section(applications)
    end
end
