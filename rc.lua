-- standard awesome library
gears = require('gears')
awful = require('awful')
math = require('math')

local FLOAT_TERMINAL_TITLE = 'FLOAT TERMINAL'
local MD_NOTE_TITLE = 'MD NOTE'
local MD_NOTE_INSTANCE = 'MdNote'

local PIP_OPACITY = 0.8
local PIP_DEFAULT_WIDTH = 260
local PIP_DEFAULT_HEIGHT = 148
local PIP_OPACITY_TIMEOUT = 3
local PIP_OPACITY_TIMER = nil
local PIP_WINDOW_PROPERTIES = {
    width=PIP_DEFAULT_WIDTH, height=PIP_DEFAULT_HEIGHT, x=1400, y=800, border_width=0, opacity=PIP_OPACITY, ontop=true, above=true,
    requests_no_titlebar=true, floating=true, dockable=false, fullscreen=false, sticky=true,
    focusable=false, skip_taskbar=true, size_hints_honor = true
}

local ABTT_OPACITY = 0.5
local ABTT_OPACITY_TIMEOUT = 0.2
local ABTT_OPACITY_TIMER = nil
local ABTT_MAIN_WINDOW_Y_POSITION = 0
local ABTT_MAIN_WINDOW_X_POSITION = 100
local abtt_main_window_client = nil
local abtt_list_window_client = nil

-- hidden clients that's added to this table
hidden_clients = {}

-- FOCUS MODE
focus_mode_on = false
focus_mode_icons = {}

require('my_vars')
require('my_functions')
require('my_hotkey_functions')

eDP1 = os.capture("cat ~/git/linux-settings/generic/.display-output-edp-1")
HDMI1 = os.capture("cat ~/git/linux-settings/generic/.display-output-hdmi-1")
DP1 = os.capture("cat ~/git/linux-settings/generic/.display-output-dp-1")
DP2 = os.capture("cat ~/git/linux-settings/generic/.display-output-dp-2")

require('performer.utils')
require('my_menus')
pprint = require('pprint')

awful.rules = require('awful.rules')
awful.spawn = require('awful.spawn')

require('awful.autofocus')
-- Widget and layout library
wibox = require('wibox')
-- Theme handling library
beautiful = require('beautiful')
dpi = beautiful.xresources.apply_dpi
-- Notification library
naughty = require('naughty')
menubar = require('menubar')

current_screen_outputs = {}

function get_current_outputs()
    local outputs = {}

    for scr_idx = 1, screen.count() do
        outputs[scr_idx] = next(screen[scr_idx].outputs)
    end

    return outputs
end

current_screen_outputs = get_current_outputs()


-- slow first time run fix
menubar.menu_gen.lookup_category_icons = function() end

-- Load Debian menu entries
require('debian.menu')
archsome = require('archsome')
archsome.icons = require('archsome.icons')
gestures = require('archsome.gestures')
multiclicks = require('archsome.multiclicks')
local PIP_WINDOW_TITLE_CHROME = 'Picture in picture'
local PIP_WINDOW_TITLE_FIREFOX = 'Picture-in-Picture'
local ABTT_MAIN_WINDOW_TITLE = 'ABTT - Main'
local ABTT_LIST_WINDOW_TITLE = 'ABTT - List'

gestures.gestures = {
    l = function()
        nt('Left')
    end,
    r = function()
        nt('Right')
    end,
    d_r = function()
        nt('Down Right')
    end,
}

multiclicks.multiclicks = {
    _1 = function()
        nt('1 click')
    end,
    _2 = function()
        nt('2 clicks')
    end,
    _3 = function()
        nt('3 clicks')
    end,
    _4 = function()
        nt('4 clicks')
    end,
}

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

-- {{{ Changing default style of notifications
--naughty.config.notification_margin = 15
--naughty.config.padding = 50
naughty.config.defaults['border_width'] = 0
naughty.config.defaults['margin'] = 10
naughty.config.presets.normal = {
    position = 'bottom_right',
    font = "ubuntu mono 16",
    bg = '#6b8e65',
    fg = '#ffffff',
    opacity = 0.8,
    timeout = 10,
}
naughty.config.presets.critical = {
    position = 'bottom_right',
    font = "ubuntu mono 16",
    bg = '#aa3322',
    fg = '#ffffff',
    opacity = 0.9,
    timeout = 0,
}
naughty.connect_signal(
    'added',
    function(notification)
        if notification.app_name == "GmailNeomuttPersonal" then
            notification:connect_signal("destroyed", on_custom_notification_destroyed)
            notification.fg = "#ffffff"
            notification.bg = "#335544"
            notification.opacity = 0.95
            notification.timeout = 10
        elseif notification.app_name == "GmailNeomuttWork1" then
            notification:connect_signal("destroyed", on_custom_notification_destroyed)
            notification.fg = "#ffffff"
            notification.bg = "#224455"
            notification.opacity = 0.95
            notification.timeout = 20
        elseif notification.app_name == "Slack" then
            notification.shape = function(cs, width, height)
                return gears.shape.rounded_rect(cs, width, height, 20)
            end

            notification.fg = "#ffffff"
            notification.bg = "#cc5800"
            notification.opacity = 0.8
            notification.timeout = 10
            notification.is_expired = true

            for i, pattern in ipairs(my_review_mr_work_1_gitlab_patterns) do
                if notification.title:match(pattern)
                    and notification.text:match('opened.*in.*<[^>]+>')
                    and my_notification_actions['review_mr_work_1_gitlab'] ~= nil then
                    notification.position = 'middle'
                    notification.timeout = 30
                    notification.icon = my_home_path .. '/gdrive/awesome-performer/icons/gitlab-orange-on-dark.png'
                    notification:append_actions({my_notification_actions['review_mr_work_1_gitlab']})
                    play_notification('mr')
                    return
                end
            end

            for i, person in pairs(my_slack_people_avatars) do
                if notification.title:match(' from ' .. person[1] .. '.*')
                    or (notification.title:match(' in #') and notification.text:match('^' .. person[1] .. '.*: ')) then
                    notification.text = notification.text:gsub('^' .. person[1] .. '.*: ', '')
                    notification.text = "\n" .. notification.text
                    notification.icon = person[2]
                    notification.icon_size = 96

                    if value_exists_in_table(my_slack_urgent_people, person[1]) then
                        notification.font = 'Ubuntu mono 20'
                        notification.position = 'middle'
                    end

                    return
                end
            end
        elseif notification.app_name == "Google Chrome" then
            notification.fg = "#ffffff"
            notification.bg = "#225544"
            notification.opacity = 0.5
            notification.timeout = 5
            notification:connect_signal("destroyed", on_custom_notification_destroyed)
        elseif notification.app_name == "Thunderbird" then
            notification.fg = "#ffffff"
            notification.position = 'middle'
            notification.opacity = 0.6

            if notification.title:match(personal_email_app_pattern) then
                notification.timeout = 5
                notification.icon = archsome.icons['mail_personal']
                notification.bg = "#223322cc"
            elseif notification.title:match(work_1_email_app_pattern) then
                notification.timeout = 15
                notification.icon = archsome.icons['mail_work_1']
                notification.bg = "#222233cc"
            elseif notification.title:match(work_2_email_app_pattern) then
                notification.timeout = 15
                notification.icon = archsome.icons['mail_work_2']
                notification.bg = "#332233cc"
            end
        end
    end
)

function on_custom_notification_destroyed(notification)
    if notification.is_expired then
        return
    end

    if notification.app_name == "GmailNeomuttPersonal" then
        activate_tag(my_tags['personal_mail'])
    elseif notification.app_name == "GmailNeomuttWork1" then
        activate_tag(my_tags['work_1_mail'])
    elseif notification.app_name == "Slack" then
        local client = notification.clients[1]
        activate_tag(my_tags['slack'], client)
    elseif notification.app_name == "Google Chrome" then
        local client = notification.clients[1]

        if client ~= nil and client.first_tag ~= nil then
            activate_tag(client.first_tag, client)
        end
    end
end

-- }}}

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

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags_per_virtual_screen_count = 12

function initialize_tags()
    local result_tags = {}
    local tags_count = 36 / screen.count()
    local screen_count = screen.count()

    if screen_count == 2 then
        local tags_template_1 = {}
        local tags_template_2 = {}

        for i = 1, 12 do
            table.insert(tags_template_2, i)
        end

        for i = 13, 24 do
            table.insert(tags_template_1, i)
        end

        for i = 25, 36 do
            table.insert(tags_template_2, i)
        end

        result_tags[1] = awful.tag(tags_template_1, 1, layouts[2])
        result_tags[2] = awful.tag(tags_template_2, 2, layouts[2])
    else
        local tags_template = {}

        for i = 1, tags_count do
            table.insert(tags_template, i)
        end

        for s = 1, screen_count do
            -- Each screen has its own tag table.
            result_tags[s] = awful.tag(tags_template, s, layouts[2])
        end
    end

    local i = 1

    for s = 1, screen_count do
        -- Each screen has its own tag table.
        for _, tag in pairs(result_tags[s]) do
            if i > 12 and i < 25 then
                tag.archsome_preferred_output = eDP1
            else
                tag.archsome_preferred_output = HDMI1
            end

            tag.archsome_preferred_index = i
            i = i + 1
        end

    end

    return result_tags
end

tags = initialize_tags()

-- }}}

-- {{{ Menu

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

require('my_tags')


-- {{{ Wibox

-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mylogo = {}
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
        function (c)
            local formatted_name

            if #c.name > 15 then
                formatted_name = c.name:sub(1, 12) .. "..."
            else
                formatted_name = c.name
            end

            if c.ontop == true then
                c.ontop = false

                nt{
                    text=string.format("On Top is DEACTIVATED for: %q", formatted_name),
                    preset="interface",
                }
            else
                c.ontop = true
                nt{
                    text=string.format("On Top is ACTIVATED for: %q", formatted_name),
                    preset="interface",
                }
            end
        end
    ),
    awful.button(
        { },
        4,
        function (client)
            local current_client

            for _, cl in pairs(client.first_tag:clients()) do
                if awful.widget.tasklist.filter.focused(cl, cl.screen) then
                    current_client = cl
                    break
                end
            end

            if current_client then
                next_tag_client(current_client, 1)
            end
        end
    ),
    awful.button(
        { },
        5,
        function (client)
            local current_client

            for _, cl in pairs(client.first_tag:clients()) do
                if awful.widget.tasklist.filter.focused(cl, cl.screen) then
                    current_client = cl
                    break
                end
            end

            if current_client then
                next_tag_client(current_client, -1)
            end
        end
    )
)

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = 'setxkbmap -option "ctrl:nocaps"'
kbdcfg.layout = { { 'us', 'ru' }, { 'ru', 'us' } }
kbdcfg.current = 1 -- us is our default layout

kbdcfg.set_text = function(lang)
    local fg_color

    if lang == 'us' then -- if english
        fg_color = "#77AAFF"
    else -- if russian
        fg_color = "#FF9999"
    end

    kbdcfg.widget:set_markup_silently('<span fgcolor = "' .. fg_color..'"><tt> ' .. lang .. ' </tt></span>')
end

kbdcfg.widget = wibox.widget.textbox()
kbdcfg.set_text(kbdcfg.layout[kbdcfg.current][1])

kbdcfg.switch = function (do_switch, specific_layout)
    local layout_pair
    local bg_color
    naughty.destroy_all_notifications(nil, -1)
    os.execute("(xset q | grep 'Caps Lock:   on' && xdotool key Caps_Lock) > /dev/null &2>1")

    if do_switch == true then
        if specific_layout then
            if kbdcfg.layout[1][1] == specific_layout then -- if english
                kbdcfg.current = 1
            else -- if russian
                kbdcfg.current = 2
            end
        else
            kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
        end


        layout_pair = kbdcfg.layout[kbdcfg.current]
        kbdcfg.set_text(layout_pair[1])
        os.execute(kbdcfg.cmd .. ' ' .. layout_pair[1] .. ',' .. layout_pair[2])
    else
        layout_pair = kbdcfg.layout[kbdcfg.current]
    end

    if kbdcfg.current == 1 then -- if english
        bg_color = "#3355cc"
    else -- if russian
        bg_color = "#cc4444"
    end

    kbdcfg.notify(layout_pair[1], bg_color)
end

kbdcfg.notify = function(current_language, bg_color)
    --local locations = {'top_left', 'top_right', 'bottom_left', 'bottom_right'}
    local locations = {
        {
            position='middle',
            text="<span font_desc='Ubuntu bold 24'>" .. current_language .. "</span>",
            border_width=0,
            shape=gears.shape.circle,
        }
    }

    for s in screen do
        for _, location_settings in pairs(locations) do
            naughty.notify({
                timeout = 1,
                text = location_settings.text,
                position = location_settings.position,
                bg = bg_color,
                border_color = "transparent",
                border_width = location_settings.border_width,
                replaces_id = 0,
                shape=location_settings.shape,
                screen=s,
            })
        end
    end
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

volume_slider = wibox.widget {
    forced_width        = 50,
    bar_shape           = gears.shape.rounded_rect,
    bar_height          = 1,
    bar_color           = beautiful.border_color,
    --handle_color        = beautiful.bg_normal,
    handle_color        = "#FFFFFF",
    handle_shape        = gears.shape.circle,
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    minimum             = 0,
    maximum             = 100,
    value               = 100,
    widget              = wibox.widget.slider,
}

volume_slider:connect_signal(
    "property::value",
    function()
        volume_slider.opacity = math.sqrt(volume_slider.value / 100 + 0.2)
        awful.spawn('dvol -s ' .. volume_slider.value)
    end
)

systray = nil

function init_screen(s)
    screen[s].archsome_is_inited = true
    gears.wallpaper.maximized(my_home_path .. "/gdrive/awesome-performer/wallpapers/grass-and-tree.jpg", s)
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
    mytaglist[s] = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = mytaglist.buttons,
        style = {
            shape = gears.shape.rectangle,
            squares_resize = false,
        },
        update_function = awful.widget.common.list_update,
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'index_role',
                            font = 'ubuntu mono 6',
                            widget = wibox.widget.textbox,
                        },
                        id = 'second_margin',
                        widget  = wibox.container.place,
                        valign = "centered",
                        halign = "centered",
                    },
                    id = 'first_margin',
                    margins = 1,
                    top = 5,
                    forced_width = 16,
                    widget  = wibox.container.margin,
                },
                bg     = '#00000000',
                fg = '#ffffffff',
                shape  = gears.shape.rectangle,
                widget = wibox.container.background,
            },
            id     = 'background_role',
            shape  = gears.shape.rectangle,
            widget = wibox.container.background,
            create_callback = function(self, c3, index, objects)
                local index_element = self:get_children_by_id('index_role')[1]
                index_element.markup = '<b> '..c3.name..' </b>'

                self:connect_signal('mouse::enter', function()
                    if not self.backup_bg then
                        self.backup_bg = self.bg
                        self.bg = '#66ff66bb'
                        self.has_backup = true
                    end
                end)

                self:connect_signal('mouse::leave', function()
                    if self.has_backup == true then
                        self.bg = self.backup_bg
                        self.has_backup = false
                    end
                end)
            end,
            update_callback = function(self, c3, index, objects)
            end,
        },
    }

    mytaglist[s] = wibox.container.margin(
        mytaglist[s],
        1,
        10,
        1,
        1
    )

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(
        s,
        awful.widget.tasklist.filter.currenttags,
        mytasklist.buttons,
        {
            shape = gears.shape.rounded_rect,
        }
    )

    if focus_mode_on then
        focus_mode_icon_file = archsome.icons.focus_mode_on_icon
    else
        focus_mode_icon_file = archsome.icons.focus_mode_off_icon
    end

    focus_mode_icons[s] = wibox.widget {
        image = focus_mode_icon_file,
        resize = true,
        widget = wibox.widget.imagebox,
        opacity = 1
    }

    focus_mode_icons[s].buttons = {
        awful.button(
            {},
            1,
            function (icon)
                if focus_mode_on then
                    focus_mode_on = false
                else
                    focus_mode_on = true
                end

                for s = 1, screen.count() do
                    if focus_mode_on then
                        focus_mode_icons[s].image = archsome.icons.focus_mode_on_icon
                    else
                        focus_mode_icons[s].image = archsome.icons.focus_mode_off_icon
                    end
                end
            end
        ),
    }

    mylogo[s] = wibox.container.margin(
        focus_mode_icons[s],
        1,
        10,
        1,
        1
    )
    local systray_delimeter_left_image = wibox.widget {
        image  = archsome.icons.systray_delimeter_left,
        resize = false,
        widget = wibox.widget.imagebox,
        opacity = 1
    }
    local systray_delimeter_right_image = wibox.widget {
        image  = archsome.icons.systray_delimeter_right,
        resize = false,
        widget = wibox.widget.imagebox,
        opacity = 1
    }
    local systray_delimeter_left = wibox.container.margin(
        systray_delimeter_left_image,
        0,
        0,
        0,
        0
    )
    local systray_delimeter_right = wibox.container.margin(
        systray_delimeter_right_image,
        0,
        0,
        0,
        0
    )
    --

    -- Create the wibox
    mywibox[s] = awful.wibar({ position = 'bottom', screen = s, height = 24, ontop = true })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylogo[s])
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the bottom
    local right_layout = wibox.layout.fixed.horizontal()

    systray = wibox.widget.systray()
    systray.screen = screen[1]
    systray.bg = "#00000000"

    volume_slider_container = wibox.container.margin(
        volume_slider,
        10,
        0,
        1,
        1
    )
    right_layout:add(volume_slider_container)
    right_layout:add(mytextclock)
    right_layout:add(kbdcfg.widget)
    right_layout:add(systray_delimeter_left)
    right_layout:add(systray)
    right_layout:add(systray_delimeter_right)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
    mywibox[s]:buttons(awful.util.table.join(
        awful.button({modkey}, 1, function(e) multiclicks.trigger(e, 1) end)
    ))
    mywibox[s].cursor = 'hand1'
    mywibox[s].bg = '#00000000'
end

for s = 1, screen.count() do
    init_screen(s)
end

-- }}}

-- {{{ Mouse bindings

require('my_mouse_bindings')

-- }}}
--

--- {{{ Calendar widget
cal = require("cal")
cal.register(mytextclock, "<span background='#0a0' foreground='#fff'><b>%s</b></span>") -- now the current day is bold instead of underline
-- }}}


function toggle_center_screen_menu(menu)
    menu:toggle({
        coords = {
            x=get_center_screen_menu_pos_x(mouse.screen, menu),
            y=get_center_screen_menu_pos_y(mouse.screen, menu),
        }
    })
end


function get_center_screen_menu_pos_x(scr, menu)
    return scr.geometry.x + scr.geometry.width/2 - menu.width/2
end


function get_center_screen_menu_pos_y(scr, menu)
    return scr.geometry.y + scr.geometry.height/2 - menu.height/2
end


function get_next_visible(clients_sorted, current_client_idx, step, end_reached, include_minimized)
    local next_client_idx = current_client_idx + step

    if current_client_idx > #clients_sorted then
        if end_reached == true then
            return nil
        end

        next_client_idx = 1
    elseif current_client_idx < 1 then
        if end_reached == true then
            return nil
        end

        next_client_idx = #clients_sorted
    end

    next_client = clients_sorted[next_client_idx]
    next_client_is_3d = is_3d_client(next_client)
    is_minimized_flag = (
        next_client ~= nil
        and (next_client.minimized == false or (next_client.minimized == true and next_client_is_3d == true))
    )

    if is_minimized_flag == true
            and next_client.skip_taskbar == false then
        return next_client_idx
    else
        return get_next_visible(clients_sorted, next_client_idx, step, end_reached, include_minimized)
    end
end


function next_tag_client(client, step, include_minimized)
    if include_minimized ~= nil then
        include_minimized = true
    end

    local clients_sorted = client.first_tag:clients()
    local current_client_idx = 0
    local next_client, next_client_idx

    table.sort(
        clients_sorted,
        function(c1, c2)
            if c1 and c2 then
                return c1.name < c2.name
            else
                return true
            end
        end
    )

    for sorted_idx, cl in pairs(clients_sorted) do
        if cl == client then
            current_client_idx = sorted_idx
            break
        end
    end

    next_client_idx = get_next_visible(clients_sorted, current_client_idx, step, false, include_minimized)

    if next_client_idx then
        if clients_sorted[next_client_idx].minimized then
            clients_sorted[next_client_idx].minimized = false
        end

        awful.client.focus.byidx(0, clients_sorted[next_client_idx])
    end
end


clientkeys = awful.util.table.join(
    awful.key(
        { altkey },
        'Tab',
        function (client)
            next_tag_client(client, 1)
        end
    ),
    awful.key(
        { altkey, 'Shift' },
        'Tab',
        function (client)
            next_tag_client(client, -1)
        end
    ),
    awful.key(
        { modkey },
        'Tab',
        function (client)
            next_tag_client(client, 1)
        end
    ),
    awful.key(
        { modkey, 'Shift' },
        'Tab',
        function (client)
            next_tag_client(client, -1)
        end
    ),
    awful.key(
        { modkey },
        '#30',
        restore_clients_size_callback
    ),
    -- #41 - f
    awful.key(
        { 'Control', modkey },
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
    -- #70 - F4
    awful.key(
        { altkey },
        '#70',
        function (c)
            c:kill()
        end
    ),
    -- #61 - /
    awful.key(
        { modkey },
        '#61',
        function (c)
            if c.pinned_to_tag == nil then
                c.pinned_to_tag = {
                    x = c.x,
                    y = c.y,
                    width = c.width,
                    height = c.height,
                    maximized = c.maximized,
                    floating = c.floating,
                    tag = c.first_tag,
                    original_sticky = c.sticky,
                    original_border_color = c.border_color,
                    original_border_width = c.border_width,
                }
                c.maximized = false
                c.floating = true
                c.sticky = true
                c.border_color = '#aa33aa'
                c.border_focus_color = '#aa33aa'
                c.border_normal_color = '#661166'
                c.border_width = 2

                client_pseudo_maximize(c)
                c:connect_signal(
                    'property::position',
                    moved_pinned_to_tag_client
                )
                c:connect_signal(
                    'property::size',
                    moved_pinned_to_tag_client
                )
            else
                c.sticky = c.pinned_to_tag.original_sticky
                c.border_color = c.pinned_to_tag.original_border_color
                c.border_width = c.pinned_to_tag.original_border_width
                c.floating = c.pinned_to_tag.floating
                c.width = c.pinned_to_tag.width
                c.height = c.pinned_to_tag.height
                c.maximized = c.pinned_to_tag.maximized
                c.border_focus_color = nil
                c.border_normal_color = nil
                c:disconnect_signal(
                    'property::position',
                    moved_pinned_to_tag_client
                )
                c:disconnect_signal(
                    'property::size',
                    moved_pinned_to_tag_client
                )
                c.pinned_to_tag = nil

                if c._destination_tag then
                    c.tags = {c._destination_tag}
                    c.first_tag = c._destination_tag
                    awful.client.movetotag(c._destination_tag)
                else
                    local client_rules = awful.rules.matching_rules(c, awful.rules.rules)

                    if client_rules ~= nil then
                        for _, rule in pairs(client_rules) do
                            if rule['properties']['tag'] and rule['properties']['tag'] ~= c.first_tag then
                                c.tags = {rule['properties']['tag']}
                                c.first_tag = rule['properties']['tag']
                                awful.client.movetotag(rule['properties']['tag'])
                            end
                        end
                    end
                end
            end
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
    -- #46 - l
    awful.key(
        { modkey },
        '#46',
        hotkey_client_align_left
    ),
    -- #43 - h
    awful.key(
        { modkey },
        '#43',
        hotkey_client_align_right
    ),
    -- #45 - k
    awful.key(
        { modkey },
        '#45',
        hotkey_cllent_align_max
    ),
    -- #45 - k
    awful.key(
        { modkey, 'Shift' },
        '#45',
        function(c)
            c:move_to_screen(c.screen.index - 1)
        end
    ),
    -- #44 - j
    awful.key(
        { modkey },
        '#44',
        hotkey_cllent_restore_pre_align
    ),
    -- #44 - j
    awful.key(
        { modkey, 'Shift' },
        '#44',
        function(c)
            c:move_to_screen(c.screen.index + 1)
        end
    ),
    -- #58 - m
    awful.key(
        { modkey },
        '#58',
        function (c)
            awful.spawn('dvol -t')
        end
    ),
    -- #59 - <
    awful.key(
        { modkey },
        '#59',
        function (c)
            volume_slider.value = volume_slider.value - 5
        end
    ),
    -- #60 - >
    awful.key(
        { modkey },
        '#60',
        function (c)
            volume_slider.value = volume_slider.value + 5
        end
    )
)


function eval_prompt(input)
    awful.util.eval(input)
end


function restore_tag_clients_size()
    if mouse.screen == nil then
        return
    end

    if mouse.screen.selected_tag == nil then
        return
    end

    mouse.screen.selected_tag.layout = layouts[4]
    awful.spawn.with_shell(
        'echo -e "mouse.screen.selected_tag.layout = layouts[2]" | awesome-client'
    )
end


function restore_clients_size_callback()
    local start_x = 0
    local screen_width
    local screen_height

    for s = 1, screen.count() do
        start_x = screen[s].workarea['x']
        local screen_width = screen[s].workarea['width']
        local screen_height = screen[s].workarea['height']

        for id, c in pairs(screen[s].all_clients) do
            c.x = start_x
            c:move_to_screen(c.screen.index + 1)
            c:move_to_screen(c.screen.index - 1)

            if c.width > screen_width then
                c.width = screen_width
            end

            if c.height > screen_height then
                c.height = screen_height
            end
        end
    end
end


function restore_clients_size()
    awful.spawn.with_shell('echo -e "restore_clients_size_callback()" | awesome-client')
end


-- {{{ Key bindings
-- You can use keycode ('#keycode') instead of key name ('key_name') as the second parameter to the function awful.key.
-- Keycode is the numeric code, that can be understood by "xmodmap" utility. It can be obtained from the "xev" utility
-- output.
--
function make_default_keys()
    local globalkeys = awful.util.table.join(
        -- #27 - r
        awful.key(
            { modkey, 'Control' },
            '#27',
            function ()
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
                awful.spawn('dm-tool switch-to-greeter')
            end
        ),
        -- #43 - h
        awful.key({ modkey, 'Shift'   }, '#43',     function () awful.tag.incnmaster( 1)      end),
        -- #46 - l
        awful.key({ modkey, 'Shift'   }, '#46',     function () awful.tag.incnmaster(-1)      end),
        -- #46 - l
        --awful.key({ modkey, }, '#46',     function () awful.spawn('dbus-send --print-reply --dest=org.mpris.MediaPlayer2.streamkeys /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause') end),
        -- #43 - h
        awful.key({ modkey, 'Control' }, '#43',     function () awful.tag.incncol( 1)         end),
        -- #46 - l
        awful.key({ modkey, 'Control' }, '#46',     function () awful.tag.incncol(-1)         end),
        awful.key({ modkey,           }, 'space', function () kbdcfg.switch(true, false) end),
        awful.key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts, -1) end),
        awful.key({ modkey, 'Control' }, 'n', awful.client.restore),
        awful.key({ }, 'Pause', function () kbdcfg.switch(true, false) end),
        --awful.key({ 'Control' }, 'Shift_L', function() nt(1) end, function () kbdcfg.switch(true, false) end),
        awful.key({ 'Control' }, 'Pause', function () kbdcfg.switch(false, false) end),

        -- Prompt
        -- #27 - r
        --awful.key(
            --{ modkey },
            --'#27',
            --function (evt)
                --kbdcfg.switch(true, 'us')
                --mypromptbox[1]:run()
            --end
        --),
        -- #28 - t
        awful.key(
            { 'Control', modkey },
            '#28',
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
        --awful.key(
            --{ modkey },
            --'#43',
            --function()
                --nt('asdf')
            --end
        --),

        -- Volume buttons
        -- #121 - mute/unmute
        awful.key(
            {},
            '#121',
            function ()
                awful.spawn('dvol -t')
            end
        ),
        awful.key(
            {},
            '#122',
            function ()
                volume_slider.value = volume_slider.value - 5
            end
        ),
        awful.key(
            {},
            '#123',
            function ()
                volume_slider.value = volume_slider.value + 5
            end
        ),
        -- #28 - t
        awful.key(
            { modkey },
            '#28',
            function ()
                toggle_center_screen_menu(my_translators_menu)
            end
        ),
        -- Put PC into the sleep mode
        -- #29 - y
        --awful.key(
            --{ modkey },
            --'#29',
            --function ()
                --nt('SYSTEM IS GOING TO SLEEP')
                --awful.spawn.with_shell('sudo rm /var/run/pm-utils/locks/pm-suspend.lock')
                --awful.spawn.with_shell('sleep 1; slock.sh suspend')
                ----awful.spawn.with_shell('sudo ' .. my_home_path .. '/bin/acpi_event_button_sleep.sh')
            --end
        --),
        -- #30 - u
        --awful.key(
            --{ modkey },
            --'#30',
            --function ()
                --nt('SYSTEM IS GOING TO HIBERNATE')
                --awful.spawn.with_shell('sudo pm-suspend-hybrid')
            --end
        --),

        -- Skype shortcuts
        awful.key(
            {altkey},
            'End',
            function ()
                my_tags['skype']:view_only()
                awful.spawn('skypedbusctl recent')
            end
        ),
        awful.key(
            {altkey},
            'Home',
            function ()
                my_tags['skype']:view_only()
                awful.spawn('skypedbusctl missed')
            end
        ),
        awful.key(
            {altkey},
            'Next',
            function ()
                awful.spawn('skypedbusctl hang-up')
            end
        ),
        awful.key(
            {altkey},
            'Prior',
            function ()
                awful.spawn('skypedbusctl pick-up')
            end
        ),
        awful.key(
            {altkey},
            'Insert',
            function ()
                my_tags['skype']:view_only()
                awful.spawn('skypedbusctl contacts ' .. my_skype_login)
            end
        ),
        -- #56 - b
        awful.key(
            {  modkey },
            '#56',
            function ()
                awful.spawn('btc')
                naughty.notify({ title = 'BTC', text = 'Trying to connect/disconnect...' })
            end
        ),
        -- #39 - s
        awful.key(
            { 'Control', modkey },
            '#39',
            function ()
                awful.spawn('pavucontrol')
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
            { modkey, 'Control' },
            '#45',
            function ()
                for _, client in pairs(my_tags['skype']:clients()) do
                    if client.class == 'Slack' then
                        my_tags['skype']:view_only()
                        awful.client.focus.byidx(0, client)
                        awful.spawn.with_shell('sleep 0.3 && xdotool key ctrl+k')
                    end
                end
            end
        ),
        -- #58 - m
        awful.key(
            { 'Control', modkey },
            '#58',
            function ()
                toggle_center_screen_menu(my_gmail_menu)
            end
        ),
        -- #25 - w
        awful.key(
            { 'Control', modkey },
            '#25',
            function ()
                dropdown_app_toggle("ChromeStuff")
                start_applications_section('current_work_links')
            end
        ),
        -- #32 - o
        awful.key(
            { modkey },
            '#32',
            function (c)
                toggle_center_screen_menu(my_monitors_menu)
            end
        ),
        -- #41 - f
        awful.key(
            { modkey },
            '#41',
            function ()
                toggle_center_screen_menu(my_cheat_sheets_menu)
            end
        ),
        -- #31 - i
        awful.key(
            { 'Control', modkey },
            '#31',
            function ()
                start_applications_section('jira')
            end
        ),
        -- #30 - u
        awful.key(
            { 'Control', modkey },
            '#30',
            function ()
                start_applications_section('wiki')
            end
        ),
        -- #57 - n
        awful.key(
            { 'Control', modkey },
            '#57',
            function ()
                toggle_center_screen_menu(my_browsers_menu)
            end
        ),
        -- #47 - ;
        --awful.key(
            --{ modkey },
            --'#47',
            --function ()
                --awful.spawn('dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.streamkeys /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous')
            --end
        -- #48 - '
        --awful.key(
            --{ modkey },
            --'#48',
            --function ()
                --awful.spawn('dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.streamkeys /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next')
            --end
        --),

        -- Get full screen screenshot
        -- #107 - PrintScreen
        awful.key(
            { },
            '#107',
            function ()
                awful.spawn('flameshot gui')
            end
        ),

        -- Get screenshot with selection
        -- #107 - PrintScreen
        awful.key(
            { 'Control' },
            '#107',
            function ()
                awful.spawn('flameshot full')
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
                    activate_tag(surfing_screen_tags[i + surfing_screen_offset], nil, i + surfing_screen_tag_number_offset)
                end
            ),

            -- Screen 2 tags
            awful.key(
                { 'Control' },
                '#' .. i + 9,
                function ()
                    activate_tag(work_screen_tags[i + work_screen_offset], nil, i + work_screen_tag_number_offset)
                end
            ),

            -- Screen 3 tags
            awful.key(
                { altkey },
                '#' .. i + 9,
                function ()
                    activate_tag(planning_screen_tags[i + planning_screen_offset], nil, i + planning_screen_tag_number_offset)
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
    awful.spawn('slock')
    awful.spawn('sh -c "sleep 1 && xset dpms force off"')
end

function make_compatible_keys()
    local globalkeys = awful.util.table.join(
        -- Toggle compatibility keys mode
        -- #58 - m
        awful.key(
            { modkey, 'Control', 'Shift' },
            '#58',
            function ()
                root.keys(make_default_keys())
                naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 20'>COMPATIBILITY MODE IS OFF</span>", border_width=300, border_color="transparent", position = "top_middle", bg="#227722", replaces_id = 0 })
                naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 20'>COMPATIBILITY MODE IS OFF</span>", border_width=300, border_color="transparent", position = "bottom_middle", bg="#227722", replaces_id = 1 })
            end
        ),
        awful.key({ }, 'Pause', function () kbdcfg.switch(true, false) end)
    )

    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 20'>COMPATIBILITY MODE IS ON</span>", border_width=300, border_color="transparent", position = "top_middle", bg="#cc0000", replaces_id = 0 })
    naughty.notify({ timeout = 1, text = "<span font_desc='Ubuntu bold 20'>COMPATIBILITY MODE IS ON</span>", border_width=300, border_color="transparent", position = "bottom_middle", bg="#cc0000", replaces_id = 1 })
    return globalkeys
end

globalkeys = make_default_keys()
-- Set keys
root.keys(globalkeys)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button(
        { modkey },
        1,
        function(c)
            if c.archsome_no_manual_move then
                return
            end

            c.maximized = false
            awful.mouse.client.move(c)
        end
    ),
    awful.button(
        { modkey },
        3,
        function(c)
            if c.archsome_no_manual_resize then
                return
            end

            c.maximized = false
            awful.mouse.client.resize(c)
        end
    )
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
    { rule = { class = 'streaming_client' }, properties = { tag = my_tags['games'] } },
    {
        rule = { class = 'csgo_linux64' },
        properties = {
            tag = my_tags['games'],
            callback = function(c)
                c.screen = c.first_tag.screen
                c.width = c.screen.workarea['width']
                c.height = c.screen.workarea['height']
            end,
        }
    },
    { rule = { instance = 'skype', class = 'Skype' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'Microsoft Teams - Preview' }, properties = { tag = my_tags['skype'] } },
    { rule = { instance = 'skypeforlinux', class = 'skypeforlinux' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'TeamSpeak 3' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'zoom' }, properties = { tag = my_tags['tag_6'] } },
    { rule = { class = 'TelegramDesktop' }, properties = { tag = my_tags['skype'] } },
    {
        rule = { instance = 'viber' },
        properties = {
            tag = my_tags['viber'],
            maximized=true,
            callback = function(c)
                c.width = c.screen.workarea['width']
                c.height = c.screen.workarea['height']
            end,
            floating=true,
            placement=awful.placement.no_offscreen,
            honor_workarea=false,
        }
    },
    {
        rule = { class = 'ThunderbirdPersonal', instance = 'Mail' },
        properties = { tag = my_tags['personal_mail'], maximized = true },
    },
    {
        rule = { class = 'ThunderbirdPersonal', instance='Calendar' },
        properties = {
            width=800, height=520,
            maximized=false, sticky=true, ontop=true, above=true,
            floating=true, dockable=false, fullscreen=false,
            requests_no_titlebar=true, border_width=2, skip_taskbar=true,
            border_width = 5,
            shape=function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 20)
            end,
            callback = function(c)
                c.border_normal_color = '#448844'
                c.border_focus_color = '#88cc88'
                c.border_color = '#88cc88'
            end,
        },
    },
    {
        rule = { class = 'ThunderbirdWork1', instance = 'Mail' },
        properties = { tag = my_tags['work_1_mail'], maximized = true },
    },
    {
        rule = { class = 'ThunderbirdWork1', instance = 'Calendar' },
        properties = {
            width=800, height=520,
            maximized=false, sticky=true, ontop=true, above=true,
            floating=true, dockable=false, fullscreen=false,
            requests_no_titlebar=true, border_width=2, skip_taskbar=true,
            border_width = 5,
            shape=function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 20)
            end,
            callback = function(c)
                c.border_normal_color = '#444488'
                c.border_focus_color = '#8888cc'
                c.border_color = '#8888cc'
            end,
        },
    },
    {
        rule = { class = 'ThunderbirdWork2', instance = 'Mail' },
        properties = { tag = my_tags['work_2_mail'], maximized = true },
    },
    {
        rule = { class = 'ThunderbirdWork2', instance = 'Calendar' },
        properties = {
            width=800, height=520,
            maximized=false, sticky=true, ontop=true, above=true,
            floating=true, dockable=false, fullscreen=false,
            requests_no_titlebar=true, border_width=2, skip_taskbar=true,
            border_width = 5,
            shape=function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 20)
            end,
            callback = function(c)
                c.border_normal_color = '#884488'
                c.border_focus_color = '#cc88cc'
                c.border_color = '#cc88cc'
            end,
        },
    },
    { rule = { class = 'Slack' }, properties = { tag = my_tags['skype'], maximized = true } },
    { rule = { class = 'discord' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'ViberPC' }, properties = { tag = my_tags['skype'] } },
    { rule = { class = 'jetbrains-pychar' }, properties = { tag = my_tags['pycharm'], fullscreen = false } },
    { rule = { class = 'jetbrains-pycharm' }, properties = { tag = my_tags['pycharm'], fullscreen = false } },
    { rule = { instance = 'gnome-terminal' }, properties = { size_hints_honor = false } },
    { rule = { name = '[-]vim[-]python' }, properties = { tag = my_tags['vim_coding_python'], fullscreen = false } },
    { rule = { name = '[-]vim[-]golang' }, properties = { tag = my_tags['vim_coding_golang'], fullscreen = false } },
    {rule = {name = '[-]gmail[-]personal'}, properties = {tag = my_tags['personal_mail'], maximized = true}},
    {rule = {name = '[-]gmail[-]work[-]1'}, properties = {tag = my_tags['work_1_mail'], maximized = true}},
    { rule = { instance = 'sun-awt-X11-XFramePeer', class = 'NetBeans IDE' }, properties = { tag = my_tags['netbeans'], fullscreen = false } },
    { rule = { instance = 'sun-awt-X11-XFramePeer', class = 'freemind-main-FreeMindStarte' }, properties = { tag = my_tags['freemind'] } },
    { rule = { instance = 'mysql-workbench-bin' }, properties = { tag = my_tags['mysql'] } },
    { rule = { instance = 'clementine' }, properties = { tag = my_tags['music'] } },
    { rule = { class = 'Spotify' }, properties = { tag = my_tags['music'] } },
    { rule = { instance = 'tilda' }, properties = { fullscreen = true } },
    { rule = { class = 'Gimp'}, properties = { tag = my_tags['gimp'] } },
    { rule = { class = 'Blender'}, properties = { tag = my_tags['blender'] } },
    { rule = { class = 'Inkscape'}, properties = { tag = my_tags['inkscape'] } },
    {
        rule = { class = 'Surf'},
        properties = {
            width=1100, height=600,
            maximized=false, sticky=true, ontop=true, above=true,
            floating=true, dockable=false, fullscreen=false,
            requests_no_titlebar=true, border_width=2, skip_taskbar=true,
            shape=function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 20)
            end,
        }
    },
    {
        rule = {class = 'Gnome-calculator'},
        properties = {
            maximized=false, sticky=true, ontop=true, above=true,
            floating=true, dockable=false, fullscreen=false,
            callback = function(c)
                c.screen = mouse.screen
            end,
        }
    },
    {
        rule = { instance='DropdownAppAndroidKeyboard' },
        properties = {
            maximized = false, sticky = true, size_hints_honor = false, requests_no_titlebar=true, border_width=0, skip_taskbar=true
        }
    },
    { rule = { class='steam_app_' }, properties = { fullscreen = true, tag = my_tags['games'], ontop = true } },
    {
        rule = {class='Rofi'},
        properties = {
            fullscreen=false, maximized=false, sticky=true, size_hints_honor=true,
            requests_no_titlebar=true, border_width=0, floating=true, opacity=1,
            above=true, ontop=true,
            callback = function(c)
                c.screen = mouse.screen
                c.archsome_no_manual_resize = true
                c.archsome_no_manual_move = true
                --center_client(c)
                c:connect_signal(
                    'unfocus',
                    function(c)
                        local found_other_rofi = false

                        for i, tag_client in pairs(c.first_tag:clients()) do
                            if tag_client.class == 'Rofi' and tag_client ~= c then
                                tag_client.focus = true
                                found_other_rofi = true
                            end
                        end

                        if found_other_rofi then
                            c:kill()
                        else
                            gears.timer.start_new(
                                0.1,
                                function()
                                    client.focus = c
                                    c:raise()
                                    awful.client.focus.byidx(0, c)
                                end
                            )
                        end
                    end
                )
                c:connect_signal(
                    'property::position',
                    function(c)
                        center_client(c)
                    end
                )
                c:connect_signal(
                    'property::size',
                    function(c)
                        center_client(c)
                    end
                )
            end,
        },
    },
    {
        rule = {name=FLOAT_TERMINAL_TITLE},
        properties = {
            width=1400, height=800,
            fullscreen=false, maximized=false, sticky=true, size_hints_honor=true,
            requests_no_titlebar=true, border_width=2, floating=true, opacity=0.9,
            callback = function(c)
                c.screen = mouse.screen
                center_client(c)
            end,
        },
    },
    {
        rule = {name=MD_NOTE_TITLE},
        properties = {
            width=1200, height=600,
            fullscreen=false, maximized=false, sticky=true, size_hints_honor=true,
            requests_no_titlebar=true, border_width=5, floating=true, opacity=1,
            above=true, ontop=true,
            callback = function(c)
                c.border_normal_color = '#444422'
                c.border_focus_color = '#aa9955'
                c.border_color = '#aa9955'
                c.screen = mouse.screen
                c.shape = function(cr, width, height)
                    gears.shape.rounded_rect(cr, width, height, 20)
                end
                c:connect_signal(
                    'property::position',
                    center_client
                )
                c:connect_signal(
                    'property::size',
                    center_client
                )
            end,
        },
    },
    {
        rule = { instance='DropdownAppTerminal' },
        properties = {
            fullscreen=false, maximized=true, sticky=true, size_hints_honor=true, skip_taskbar=true,
            requests_no_titlebar=true, border_width=0, skip_taskbar=true,
            callback = function(c)
                c.screen = mouse.screen
            end,
        },
    },
    {
        rule = { instance='DropdownAppmarks_work' },
        properties = {
            maximized=true, sticky=true, size_hints_honor=false,
            requests_no_titlebar=true, border_width=0, skip_taskbar=true,
        },
    },
    {
        rule = { instance='DropdownAppmarks_alightbit' },
        properties = {
            maximized=true, sticky=true, size_hints_honor=false,
            requests_no_titlebar=true, border_width=0, skip_taskbar=true,
        },
    },
    {
        rule = { instance='DropdownAppmarks_private' },
        properties = {
            maximized=true, sticky=true, size_hints_honor=false,
            requests_no_titlebar=true, border_width=0, skip_taskbar=true,
        },
    },
    {
        rule = { instance='DropdownAppChromeMindmeister' },
        properties = {
            maximized = true, sticky = true, requests_no_titlebar=true, border_width=0, skip_taskbar=true,
        },
    },
    {
        rule = { instance='DropdownAppChromeStuff' },
        properties = {
            maximized = true, sticky = true, requests_no_titlebar=true, border_width=0, skip_taskbar=true,
        },
    },
    { rule = { instance='.*google[-]chrome[-]rg_youtrack.*' }, properties = { maximized = true, tag = my_tags['yt'] } },
    {
        rule = { name=PIP_WINDOW_TITLE_CHROME },
        properties = PIP_WINDOW_PROPERTIES,
    },
    {
        rule = { name=PIP_WINDOW_TITLE_FIREFOX },
        properties = PIP_WINDOW_PROPERTIES,
    },
    {
        rule = { class='firefox_github_class' },
        properties = {
            tag = my_tags['github'],
        },
    },
    {
        rule = { class='firefox_youtube_class' },
        properties = {
            tag = my_tags['youtube'],
        },
    },
    {
        rule = { class='firefox_rg_youtrack_class' },
        properties = {
            tag = my_tags['rg_youtrack'],
        },
    },
    {
        rule = { class='firefox_work_class' },
        properties = {
            tag = my_tags['surfing_work'],
        },
    },
    {
        rule = { name=ABTT_MAIN_WINDOW_TITLE },
        properties = {
            height=30, border_width=0, opacity=ABTT_OPACITY, ontop=true, above=true, requests_no_titlebar=true,
            floating=true, dockable=false, fullscreen=false, sticky=true, focusable=false, skip_taskbar=true,
            size_hints_honor = true,
        },
    },
    {
        rule = { name=ABTT_LIST_WINDOW_TITLE },
        properties = {
            border_width=0, opacity=1, ontop=true, above=true, requests_no_titlebar=true, floating=true,
            dockable=false, fullscreen=false, sticky=true, focusable=true, skip_taskbar=true,
            size_hints_honor = true,
        },
    },
}
-- }}}
--


-- {{{ Signals

client.connect_signal(
    'untagged',
    client_untagged
)

-- Signal function to execute when a new client appears.
client.connect_signal(
    'manage',
    function (c, startup)
        if c.class then
            for _, my_3d_app_class in pairs(my_3d_app_classes) do
                if string.match(c.class, my_3d_app_class) then
                    awful.spawn.with_shell('killall compton')
                    awful.spawn.with_shell('xinput-switch-disabling-touchpad-when-typing.sh 0')
                    return
                end
            end
        end

        if c.class == my_browser_window_class_1 or c.class == my_browser_window_class_2 then
            local focused_screen = awful.screen.focused()
            local focused_tag = focused_screen.selected_tag
            local was_focused_before = value_exists_in_table(c.tags(c), focused_tag)
            c:connect_signal(
                'property::name',
                function(c)
                    if focus_mode_on and client.focus == c then
                        for i, pattern in pairs(unfocused_patterns) do
                            if c.name:match(pattern) then
                                nt{text="ARE YOU SURE THAT YOU NEED TO DO IT RIGHT NOW?", preset='urgent'}
                                nt{text="PUT IT DOWN TO YOUR NOTES AND COME BACK LATER", preset='warning'}
                            end
                        end
                    end
                end
            )

            send_browser_instance_to_its_tag(c, was_focused_before, false)
        elseif c.class == 'Surf' then
            c.screen = mouse.screen
            c:connect_signal(
                'property::size',
                function(c)
                    center_client(c)
                end
            )
            c:connect_signal(
                'property::position',
                function(c)
                    center_client(c)
                end
            )
            center_client(c)
        end

        if c.name == FLOAT_TERMINAL_TITLE then
            c:connect_signal(
                'property::size',
                function(c)
                    center_client(c)
                end
            )
            c:connect_signal(
                'property::position',
                function(c)
                    center_client(c)
                end
            )
            center_client(c)
        elseif c.name == MD_NOTE_TITLE then
            awful.spawn('xdotool set_window --classname ' .. MD_NOTE_INSTANCE .. ' ' .. c.window)
            center_client(c)
        elseif c.name == PIP_WINDOW_TITLE_CHROME or c.name == PIP_WINDOW_TITLE_FIREFOX then
            local scr_geometry = c.screen.workarea
            c.y = scr_geometry.y + 100
            c.opacity = PIP_OPACITY
            c.original_width = c.width
            c.original_height = c.height
            c.shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 10)
            end
            c:connect_signal(
                'request::geometry',
                function(c, context, hints)
                    if context == 'mouse.resize' then
                        local aspect_ratio = c.original_width / c.original_height
                        hints.width = math.min(hints.width, gears.math.round(aspect_ratio * hints.height))
                        hints.height = math.min(hints.height, gears.math.round(hints.width / aspect_ratio))
                    end
                end
            )
            c:connect_signal(
                'property::size',
                function(c, context, hints)
                    local scr_geometry = c.screen.workarea
                    c.x = scr_geometry.x + scr_geometry.width - (c.width + 100)
                end
            )
            c:connect_signal(
                'property::position',
                function(c)
                    local scr_geometry = c.screen.workarea
                    c.x = scr_geometry.x + scr_geometry.width - (c.width + 100)
                end
            )
            c:connect_signal(
                'mouse::enter',
                function(c)
                    clear_pip_opacity_timer()
                    c.opacity = 1
                end
            )
            c:connect_signal(
                'mouse::move',
                function(c)
                    clear_pip_opacity_timer()
                    c.opacity = 1
                end
            )
            c:connect_signal(
                'mouse::leave',
                function(c)
                    clear_pip_opacity_timer()
                    PIP_OPACITY_TIMER = gears.timer.start_new(
                        PIP_OPACITY_TIMEOUT,
                        function()
                            c.opacity = PIP_OPACITY
                        end
                    )
                end
            )
        elseif c.name == ABTT_MAIN_WINDOW_TITLE then
            c.opacity = ABTT_OPACITY
            c.shape = gears.shape.rounded_rect
            c.above = true
            c.ontop = true

            -- Fix for something to reset the client's x-location to 0 on awesome restart
            gears.timer.start_new(
                2,
                function()
                    position_abtt_window(c, 200, ABTT_MAIN_WINDOW_Y_POSITION)
                end
            )
            c:connect_signal(
                'request::geometry',
                function(c, context, hints)
                    if context == 'mouse.move' then
                        local scr_geometry = c.screen.workarea
                        hints.y = scr_geometry.y + scr_geometry.height - ABTT_MAIN_WINDOW_Y_POSITION
                    end
                end
            )
            c:connect_signal(
                'property::position',
                function(c)
                    position_abtt_window(c, nil, ABTT_MAIN_WINDOW_Y_POSITION)

                    if abtt_list_window_client ~= nil then
                        position_abtt_window(
                            abtt_list_window_client,
                            get_x_offset(c),
                            32
                        )
                    end
                end
            )
            c:connect_signal(
                'mouse::enter',
                function(c)
                    clear_abtt_opacity_timer()
                    c.opacity = 1
                end
            )
            c:connect_signal(
                'mouse::move',
                function(c)
                    clear_abtt_opacity_timer()
                    c.opacity = 1
                end
            )
            c:connect_signal(
                'mouse::leave',
                function(c)
                    clear_abtt_opacity_timer()
                    ABTT_OPACITY_TIMER = gears.timer.start_new(
                        ABTT_OPACITY_TIMEOUT,
                        function()
                            c.opacity = ABTT_OPACITY
                        end
                    )
                end
            )
            abtt_main_window_client = c
        elseif c.name == PIP_WINDOW_TITLE_CHROME or c.name == PIP_WINDOW_TITLE_FIREFOX then
            c.above = true
            c.ontop = true
        elseif c.name == ABTT_LIST_WINDOW_TITLE then
            abtt_list_window_client = c
            c.opacity = 1
            c.shape = gears.shape.rounded_rect
            c.above = true
            c.ontop = true
            position_abtt_window(
                c,
                ternary(abtt_main_window_client ~= nil, get_x_offset(abtt_main_window_client), ABTT_MAIN_WINDOW_X_POSITION),
                32
            )
            c:connect_signal(
                'property::position',
                function(c)
                    position_abtt_window(
                        c,
                        ternary(abtt_main_window_client ~= nil, get_x_offset(abtt_main_window_client), ABTT_MAIN_WINDOW_X_POSITION),
                        32
                    )
                end
            )
        end

        if c.instance == 'sun-awt-X11-XFramePeer' then
            naughty.notify({ title = c.class })
        elseif c.instance == 'terminator' or c.instance == 'x-terminal-emulator' then
            for tag_name, title in pairs(my_terminal_titles_to_intercept) do
                if string.match(c.name, title) and value_exists_in_table(c.tags(c), my_tags[tag_name]) == false then
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
            if not c.size_hints.user_position and not c.size_hints.program_position and #c:tags() > 0 then
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
    end
)

client.connect_signal(
    'unmanage',
    function (c)
        for _, my_3d_app_class in pairs(my_3d_app_classes) do
            if c.class and string.match(c.class, my_3d_app_class) then
                start_applications_section('compton')
                awful.spawn.with_shell('xinput-switch-disabling-touchpad-when-typing.sh 1')
                return
            end
        end
    end
)

client.connect_signal(
    'property::fullscreen',
    function (c)
        if c.instance and string.match(c.instance, 'DropdownApp') == true then
            return true
        end

        local show_above_clients = not c.fullscreen or c ~= client.focus
        if show_above_clients == true then
            mywibox[c.screen.index].visible = true

            for _, cli in pairs(hidden_clients) do
                cli.hidden = false
            end

            hidden_clients = {}
        else
            mywibox[c.screen.index].visible = false

            for _, cli in pairs(c.screen.clients) do
                if cli.ontop == true then
                    cli.hidden = true
                    table.insert(hidden_clients, cli)
                end
            end
        end
    end
)

client.connect_signal(
    'focus',
    function(c)
        --if c.instance and string.match(c.instance, 'DropdownApp') then
            --return true
        --end

        if c.fullscreen == true then
            mywibox[c.screen.index].visible = false

            for _, cli in pairs(c.screen.clients) do
                if cli.ontop == true then
                    cli.hidden = true
                    table.insert(hidden_clients, cli)
                end
            end
        else
            for _, mwb in pairs(mywibox) do
                mwb.visible = true
            end

            for _, cli in pairs(hidden_clients) do
                cli.hidden = false
            end

            hidden_clients = {}
        end

        c.border_color = c.border_focus_color or beautiful.border_focus
    end
)

client.connect_signal(
    'unfocus',
    function(c)
        --if c.instance and string.match(c.instance, 'DropdownApp') then
            --return true
        --end

        if c.fullscreen == true then
            for _, mwb in pairs(mywibox) do
                mwb.visible = true
            end

            for _, cli in pairs(hidden_clients) do
                cli.hidden = false
            end

            hidden_clients = {}
        end

        if c.name == PIP_WINDOW_TITLE_CHROME or c.name == PIP_WINDOW_TITLE_FIREFOX then
            c.opacity = PIP_OPACITY
        elseif c.name == ABTT_MAIN_WINDOW_TITLE then
            c.opacity = ABTT_OPACITY
        end

        c.border_color = c.border_normal_color or beautiful.border_normal
    end
)
-- }}}


function client_to_tag_by_name_signal(c)
    if not c.name or c.pinned_to_tag then
        return
    end

    if c.class == 'Firefox' and c.name:find('JIRA') ~= nil and c.tag ~= my_tags['jira'] then
        awful.client.movetotag(my_tags['jira'], c)
        c._destination_tag = my_tags['jira']
    elseif c.class == my_browser_window_class_1 or c.class == my_browser_window_class_2
        and c.name ~= nil then
        local focused_screen = awful.screen.focused()
        local focused_tag = focused_screen.selected_tag
        local was_focused_before = value_exists_in_table(c.tags(c), focused_tag)

        if send_browser_instance_to_its_tag(c, was_focused_before, false) then
            return
        end

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
    elseif c.name == 'New Tab - Google Chrome' then
        c._destination_tag = my_tags['surfing_localhost']
        c:move_to_tag(my_tags['surfing_localhost'])
        my_tags['surfing_localhost']:view_only()
    end
end

client.connect_signal(
    'property::name',
    client_to_tag_by_name_signal
)

awesome.connect_signal(
    'startup',
    function(args)
        awful.spawn.with_shell('ws-screens-layout.sh')
        awful.spawn.with_shell('rm ' .. my_home_path .. '/.awesome-restart > /dev/null 2>&1 || add-edp-custom-resolutions.sh || rm ~/.DropdownApp*')
        initial_tags_assignation()
        restore_clients_size()
    end
)

awesome.connect_signal(
    'exit',
    function(args)
        awful.spawn.with_shell('touch ' .. my_home_path .. '/.awesome-restart')
    end
)

screen.connect_signal(
    'list',
    function()
        screens_by_outputs = {}
        screens_by_outputs[eDP1] = screen[awful.screen.getbycoord(0, 1081)]
        screens_by_outputs[HDMI1] = screen[awful.screen.getbycoord(0, 0)]

        init_screen_tags_offsets()

        if screen.count() == 2 then
            for s = 1, 2 do
                gears.wallpaper.maximized(my_home_path .. "/gdrive/awesome-performer/wallpapers/grass-and-tree.jpg", s)

                if screen[s].archsome_is_inited == nil then
                    init_screen(screen[s].index)
                end

                local first_tag = nil

                for _, tag in pairs(screen[s].tags) do
                    if screens_by_outputs[tag.archsome_preferred_output] then
                        tag.screen = screens_by_outputs[tag.archsome_preferred_output]
                    end

                    if first_tag == nil then
                        first_tag = tag
                    end
                end

                if screen[s].selected_tag == nil then
                    screen[s].selected_tag = first_tag
                end
            end

            systray:set_screen(screens_by_outputs[eDP1])
            restore_clients_size()
        elseif screen.count() == 1 then
            for i, j in pairs(mywibox) do
                mywibox[i]:remove()
            end

            mywibox = {}
            init_screen(1)

            if screen[1].archsome_is_inited == nil then
                init_screen(screen[1].index)
            end

            for _, tag in pairs(screen[1].tags) do
                if screens_by_outputs[tag.archsome_preferred_output] then
                    tag.screen = screens_by_outputs[tag.archsome_preferred_output]
                end
            end

            systray:set_screen(screens_by_outputs[HDMI1])
            restore_clients_size()
        end
    end
)

screen.connect_signal(
    'added',
    function(scr)
        awesome.restart()
        --local output_added = next(scr.outputs)
        --systray:set_screen(scr)
        --nt{text=output_added, title="SCREEN ADDED: ", icon=archsome.icons.monitor_connected, preset='devices'}
    end
)

screen.connect_signal(
    'removed',
    function(scr)
        local output_removed = next(scr.outputs)
        nt{text=output_removed, title="SCREEN REMOVED: ", icon=archsome.icons.monitor_disconnected, preset='devices'}
        local primary_out = next(screen[1].outputs)

        if screen.count() == 1 then
            local tag

            for idx = 1, 36 do
                tag = screen[1].tags[idx]
                tag:swap(screen[1].tags[tag.archsome_preferred_index])
            end
        end

        systray:set_screen(screen[1])
        restore_clients_size()
    end
)

tag.connect_signal(
    'request::screen',
    function (t)
        if screen.count() == 1 then
            t.screen = screen[1]
        end
    end
)

do
    for _, apps_section_name in pairs(my_startup_sections) do
        if apps_section_name == "current_work_links" then
            dropdown_app_toggle("ChromeStuff")
        end

        start_applications_section(apps_section_name)
    end
end

function initial_tags_assignation()
    for _, c in ipairs(client.get()) do
        client_to_tag_by_name_signal(c)
    end
end
