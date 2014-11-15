-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")


-- {{{ Changing default style of notifications
naughty.config.defaults['border_width'] = "0"
naughty.config.presets['normal'] = {
    bg = '#3b8e15',
    fg = '#ffffff'
}
-- }}}

-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors 
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal(
	"debug::error",
	function (err)
	    -- Make sure we don't go into an endless error loop
	    if in_error then
		return
	    end
	    
	    in_error = true
	    naughty.notify({ 
		preset = naughty.config.presets.critical,
		title = "Oops, an error happened!",
		text = err 
            })
	    in_error = false
	end
    )
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"

-- my editor --
editor = "vim"

editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
altkey = "Mod1"
modkey = "Mod4"

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

tags_template = {}
tags_count = 36 / screen.count()
tags_per_virtual_screen_count = 12

for i = 1, tags_count do
    table.insert(tags_template, i)
end

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags_template, s, layouts[4])
end

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

mymainmenu = awful.menu({
    items = { 
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "Debian", debian.menu.Debian_menu.Debian },
        { "open terminal", terminal }
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

require('my_tags')
require('my_functions')
require('my_vars')

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
		    awful.tag.viewonly(c:tags()[1])
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
                          end),
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
            awful.button({ }, 5, function ()
            awful.client.focus.byidx(1)

            if client.focus then
                client.focus:raise()
            end
        end
    )
)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

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

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),
    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(-1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(1)    end),
    awful.key({ modkey }, "j", function () awful.screen.focus(1) end),
    awful.key({ modkey }, "k", function () awful.screen.focus(2) end),
    awful.key({ modkey }, "l", function () awful.screen.focus(3) end),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    
    -- Standard program
    awful.key({ modkey }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, altkey, "Shift" }, "q", awesome.quit),

    --awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    --awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Lock screen (need to be installed through "apt-get install suckless-tools")
    awful.key({ modkey }, "h", function ()
        awful.util.spawn('xscreensaver-command -lock')
    end),

    -- Skype shortcuts
    awful.key(
        {altkey},
        "End",
        function ()
            awful.tag.viewonly(my_tags['skype'])
            awful.util.spawn("skypedbusctl recent")
        end
    ),
    awful.key(
        {altkey},
        "Home",
        function ()
            awful.tag.viewonly(my_tags['skype'])
            awful.util.spawn("skypedbusctl missed")
        end
    ),
    awful.key(
        {altkey},
        "Next",
        function ()
            awful.tag.viewonly(my_tags['skype'])
            awful.util.spawn("skypedbusctl hang-up")
        end
    ),
    awful.key(
        {altkey},
        "Prior",
        function ()
            awful.tag.viewonly(my_tags['skype'])
            awful.util.spawn("skypedbusctl pick-up")
        end
    ),
    awful.key(
        {altkey},
        "Insert",
        function ()
            awful.tag.viewonly(my_tags['skype'])
            awful.util.spawn("skypedbusctl contacts " .. my_skype_login)
        end
    ),
    awful.key(
	{ 'Control', modkey },
	'b',
	function ()
	    awful.util.spawn('unity-control-center bluetooth')
	end
    ),
    awful.key(
	{ 'Control', modkey },
	's',
	function ()
	    awful.util.spawn('unity-control-center sound')
	end
    ),
    awful.key(
	{ 'Control', modkey },
	'w',
	function ()
	    start_applications_section(my_startup_applications['work_terminals'])
	end
    )
)

clientkeys = awful.util.table.join(
    awful.key({ modkey }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_verticalical
        end
    )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, tags_per_virtual_screen_count do
    globalkeys = awful.util.table.join(globalkeys,
        -- Screen 1 tags
        awful.key(
            { modkey, "Control" },
	    "#" .. i + 9,
	    function ()
	        awful.screen.focus(surfing_screen)
	        awful.tag.viewonly(surfing_screen_tags[i + screen_1_offset])
	    end
        ),

        -- Screen 2 tags 
        awful.key(
            { "Control" },
            "#" .. i + 9,
            function ()
                awful.screen.focus(work_screen)
                awful.tag.viewonly(work_screen_tags[i + screen_2_offset])
            end
        ),

        -- Screen 3 tags 
        awful.key(
            { "Control", altkey },
            "#" .. i + 9,
            function ()
                awful.screen.focus(planning_screen)
                awful.tag.viewonly(planning_screen_tags[i + screen_3_offset])
            end
        ),

        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" }, properties = { floating = true } },
    { rule = { class = "pinentry" }, properties = { floating = true } }, 
    { rule = { class = "gimp" }, properties = { floating = true } },
    { rule = { instance = "skype", class = "Skype" }, properties = { tag = my_tags['skype'] } },
    { rule = { class = "jetbrains-pychar" }, properties = { tag = my_tags['pycharm'], fullscreen = true } },
    { rule = { class = "jetbrains-pycharm" }, properties = { tag = my_tags['pycharm'], fullscreen = true } },
    { rule = { name = "VimCoding" }, properties = { tag = my_tags['pycharm'], fullscreen = true } },
    { rule = { instance = "sun-awt-X11-XFramePeer", class = "NetBeans IDE" }, properties = { tag = my_tags['netbeans'] } },
    { rule = { instance = "sun-awt-X11-XFramePeer", class = "freemind-main-FreeMindStarte" }, properties = { tag = my_tags['freemind'] } },
    { rule = { instance = 'mysql-workbench-bin' }, properties = { tag = my_tags['mysql'] } },
    { rule = { instance = 'clementine' }, properties = { tag = my_tags['music'] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    if c.instance == 'sun-awt-X11-XFramePeer' then
	naughty.notify({ title = c.class })
    elseif c.instance == 'gnome-terminal' then
	for tag_name, title in pairs(my_terminal_titles_to_intercept) do
	    if c.name == title and value_exists_in_table(c.tags(c), my_tags[tag_name]) == false then
		naughty.notify({ title = 'Moved to the "' .. tag_name .. '" tag' })
		awful.client.movetotag(my_tags[tag_name], c)
		awful.tag.viewonly(my_tags[tag_name])
	    end
	end
    end

    -- Enable sloppy focus
    --c:connect_signal("mouse::enter", function(c)
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
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
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
        title:set_align("center")
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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


client.connect_signal(
    'property::name',
    function(c)
        if c.class == 'Firefox' and c.name:find('JIRA') ~= nil and c.tag ~= my_tags['jira'] then
            awful.client.movetotag(my_tags['jira'], c)
        elseif c.class == my_browser_window_class_1 or c.class == my_browser_window_class_2 then
	    for tag_name, title_pattern in pairs(my_browser_titles_to_intercept) do
		if c.name:find(title_pattern) ~= nil and value_exists_in_table(c.tags(c), my_tags[tag_name]) == false then
		    naughty.notify({ title = 'Moved to the "' .. tag_name .. '" tag' })
		    awful.client.movetotag(my_tags[tag_name], c)
		    awful.tag.viewonly(my_tags[tag_name])
		end
	    end
	end
    end
)


do
    for apps_section_name, applications in pairs(my_startup_applications) do
	start_applications_section(applications)
    end
end

