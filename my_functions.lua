local awful = require('awful')
local gears = require('gears')
local pprint = require('pprint')
local pl = require('pl')
local pretty = require('pl.pretty')
awful.spawn = require('awful.spawn')
local naughty = require('naughty')
local my_home_path = os.getenv('HOME')
local archsome = require('archsome')
archsome.notification_presets = require('archsome.notification_presets')
local singleton_notifications = {}


function set_client_proper_size_for_screen(client, only_if_bigger)
    local scr_geometry = client.screen.workarea
    local border_space = client.border_width * 2

    if  only_if_bigger then
        if client.width <= scr_geometry.width - border_space
            and client.height <= scr_geometry.height - border_space then
            return
        end
    end

    client.width = scr_geometry.width - border_space
    client.height = scr_geometry.height - border_space
end


function client_pseudo_maximize(client)
    local scr_geometry = client.screen.workarea
    client.x = scr_geometry.x
    client.y = scr_geometry.y
    set_client_proper_size_for_screen(client, false)
end


function client_untagged(client, tag)
    if client.pinned_to_tag then
        if client.pinned_to_tag.tag == tag then
            client.screen = client.pinned_to_tag.tag.screen or screen[1]
            client.first_tag = client.pinned_to_tag.tag
            center_client(client)
        end
    else
        set_client_proper_size_for_screen(client, true)
    end
end


function moved_pinned_to_tag_client(client)
    if client.pinned_to_tag then
        client.screen = client.pinned_to_tag.tag.screen or screen[1]
        client:tags({client.pinned_to_tag.tag})
        center_client(client)
    end
end


function center_client(c)
    local scr_geometry = c.screen.workarea
    c.x = scr_geometry.x + math.floor((scr_geometry.width - c.width)/2)
    c.y = scr_geometry.y + math.floor((scr_geometry.height - c.height)/2)
end


function client_save_original_geometry(c)
    if c.original_geometry == nil then
        c.original_geometry = {
            x = c.x,
            y = c.y,
            width = c.width,
            height = c.height,
            maximized = c.maximized,
            floating = c.floating,
            border_width = c.border_width,
            border_color = c.border_color,
        }
    end
end


function client_restore_original_geometry(c)
    if c.original_geometry ~= nil then
        c.border_width = c.original_geometry.border_width
        c.border_color = c.original_geometry.border_color
        c.x = c.original_geometry.x
        c.y = c.original_geometry.y
        c.width = c.original_geometry.width
        c.height = c.original_geometry.height
        c.maximized = c.original_geometry.maximized
        c.floating = c.original_geometry.floating
        c.original_geometry = nil
    end
end


function play_notification(name)
    awful.spawn('notification-' .. name .. '.sh')
end


function web_query_execute(query_type, activate_correspondent_tag)
    if activate_correspondent_tag == true then
        callback_shell.spawn(
            'web-query-dialog ' .. query_type,
            function (output, exit_code)
                if exit_code == 0 then activate_tag_by_name(query_type) end
            end
        )
    else
        callback_shell.spawn('web-query-dialog ' .. query_type)
    end

end


function browser_router(browser_profile, url)
    local script

    if url then
        script = 'firefox-router.sh ' .. browser_profile .. ' "' .. url .. '" > /dev/null &2>1'
    else
        script = 'firefox-router.sh ' .. browser_profile .. ' > /dev/null &2>1'
    end

    callback_shell.spawn(
        script,
        function (output, exit_code)
            if exit_code == 0 then activate_tag_by_name(browser_profile) end
        end
    )
end


function activate_tag_by_name(tag_name)
    local tag

    if my_tags[tag_name] ~= nil then
        tag = my_tags[tag_name]
    else
        tag = my_tags['surfing_localhost']
    end

    awful.screen.focus(tag.screen)
    tag:view_only()
end


function nt(...)
    if type(...) == 'table' then
        local args = ...
        text = args.text or args[1]
        title = args.title or args[2]
        position = args.position or args[3]
        timeout = args.timeout or args[4]
        icon = args.icon or args[5]
        preset = args.preset or args[6]
    else
        text, title, position, timeout, icon, preset = ...
    end

    local notify_params_table = {
        preset=naughty.config.presets.normal,
        position=position,
        bg="#4488aa",
        border_width = 0,
        opacity=0.8,
        category='device.added',
    }

    if type(text) ~= 'string' then
        if type(text) == 'table' then
            local keys_table = {}
            local counter = 0

            for i,_ in pairs(text) do
                if counter > 30 then
                    break
                end
                counter = counter + 1
                keys_table[#keys_table+1] = i
                timeout = 0
            end

            text = pretty.write(keys_table)
        else
            text = tostring(text)
        end
    end

    notify_params_table['text'] = "<span font_desc='Ubuntu bold 16'>" .. text .. "</span>"

    if title ~= nil then
        notify_params_table['title'] = title
    end

    if position == nil then
        position = "middle"
    end

    notify_params_table['position'] = position

    if timeout == nil then
        timeout = 15
    end

    if icon ~= nil then
        notify_params_table['icon'] = icon
    end

    notify_params_table['timeout'] = timeout

    if preset ~= nil then
        for key, value in pairs(archsome.notification_presets[preset]) do
            notify_params_table[key] = value
        end
    end

    if notify_params_table['singleton_type'] ~= nil then
        if singleton_notifications[notify_params_table['singleton_type']] then
            for i, notification in ipairs(singleton_notifications[notify_params_table['singleton_type']]) do
                if notification ~= nil and notification.screen ~= nil then
                    notification:destroy(1)
                end
            end
        else
            singleton_notifications[notify_params_table['singleton_type']] = {}
        end
    end

    for s in screen do
        notify_params_table['screen'] = s
        local notification = naughty.notify(notify_params_table)

        if notify_params_table['singleton_type'] ~= nil then
            print(singleton_notifications[notify_params_table['singleton_type']])
            table.insert(singleton_notifications[notify_params_table['singleton_type']], notification)
        end
    end

    awful.spawn.with_shell('echo "' .. tostring(notify_params_table['title']) .. ': ' .. text .. '" >> ~/nt.log')
end


function get_keys(tbl)
    local keyset={}
    local n=0

    for k,v in pairs(tbl) do
      n=n+1
      keyset[n]=k
    end

    return keyset
end


function value_exists_in_table(tbl, search_value)
    for _, value in pairs(tbl) do
        if value == search_value then
            return true
        end
    end

    return false
end


function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()

    if raw then
        return s
    end

    result_string = string.gsub(s, '^%s+', '')
    result_string = string.gsub(result_string, '%s+$', '')
    result_string = string.gsub(result_string, '[\n\r]+', ' ')

    return result_string
end


function get_pids_by_cmd(cmd, xdotool_search)
    local pids

    if xdotool_search then
        pids = os.capture(
            'xdotool search --name "' .. cmd .. '"'
        )
    else
        pids = os.capture(
            'ps ax | grep -E "' .. cmd .. '" | sed "s/^[ \t]//g" | grep -v grep | grep -E "^[0-9]+" -o'
        )
    end

    return pids
end


function kill_processes_by_cmd(cmd)
    local pids = get_pids_by_cmd(cmd, false)

    if pids ~= '' then
        os.execute('kill ' .. pids)
    end
end


function strip_new_lines(text)
    return text:gsub('\n', ' ')
end


function start_application_with_check(app)
    local check_result = ""
    local app_name = app[1]
    local app_start_cmd = app[2]
    local app_check_cmd = app[3]
    local do_xdo_check = app[4]

    if app_check_cmd == true then
        app_check_cmd = app_start_cmd
    end

    if app_check_cmd ~= false then
        check_result = get_pids_by_cmd(app_check_cmd, do_xdo_check)
    end

    awful.spawn.with_shell('echo "'..app_start_cmd..'" >> ' .. my_home_path .. '/ts-log.log 2>&1')

    if check_result == "" then
        --naughty.notify({
            --preset = naughty.config.presets.normal,
            --title = 'Starting up the:',
            --text = app_name
        --})
    end

    if app_check_cmd == false or check_result == '' then
        awful.spawn.with_shell(app_start_cmd .. ' > /dev/null 2>&1')
    end
end


function start_applications_section(application_section_name, app_section)
    if app_section == nil then
        app_section = my_applications
    end

    for _, app in pairs(app_section[application_section_name]) do
        if type(app[2]) == 'function' then
            app[2]()
        else
            start_application_with_check(app)
        end
    end
end


-- dropdown applications 
function dropdown_app_toggle(app_name, action)
    local set_action = "toggle"

    if action ~= nil then
        set_action = action
    end

    if app_name == "ChromeMindmeister" then
        awful.spawn('dropdown-window ChromeMindmeister ' .. set_action .. ' "google-chrome --app=https://mindmeister.com --user-data-dir=' .. my_home_path .. '/.config/chrome-mindmeister" ')
    elseif app_name == "ChromeStuff" then
        awful.spawn(
            'dropdown-window ChromeStuff ' .. set_action ..
                ' "/opt/qutebrowser/.venv/bin/python /opt/qutebrowser/.venv/bin/qutebrowser --basedir ' .. my_home_path ..
                '/.config/qutebrowser-stuff --target window"'
        )
    elseif app_name == "Terminal" then
        awful.spawn('dropdown-window Terminal ' .. set_action .. ' dr-terminal.sh shell')
    elseif app_name == "marks_work" then
        awful.spawn(
            'dropdown-window marks_work ' .. set_action .. ' "dr-vim-marks.sh work blue" shell'
        )
    elseif app_name == "marks_alightbit" then
        awful.spawn(
            'dropdown-window marks_alightbit ' .. set_action .. ' "dr-vim-marks.sh alightbit gold" shell'
        )
    elseif app_name == "marks_private" then
        awful.spawn(
            'dropdown-window marks_private ' .. set_action .. ' "dr-vim-marks.sh private green" shell'
        )
    elseif app_name == "AndroidKeyboard" then
        awful.spawn('dropdown-window AndroidKeyboard ' .. set_action .. ' "terminator --title=android-keyboard --profile=android-keyboard"')
    else
        awful.spawn('dropdown-window ChromeMindmeister hide')
        awful.spawn('dropdown-window ChromeStuff hide')
        awful.spawn('dropdown-window Terminal hide')
        awful.spawn('dropdown-window marks_work hide')
        awful.spawn('dropdown-window marks_alightbit hide')
        awful.spawn('dropdown-window marks_private hide')
        awful.spawn('dropdown-window AndroidKeyboard hide')
    end
end


function send_browser_instance_to_its_tag(browser_client, was_focused_before, check_only)
    if browser_client.pinned_to_tag then
        return false
    end

    if my_browser_instance_tags[browser_client.instance] then
        browser_client._destination_tag = my_tags[my_browser_instance_tags[browser_client.instance]]

        if check_only then
            return true
        end

        browser_client:move_to_tag(browser_client._destination_tag)

        if was_focused_before then
            browser_client._destination_tag:view_only()
        end

        return true
    end

    return false
end


function focus_last_focused_client_of_tag(screen_to_focus)
    local client = awful.client.focus.history.get(screen_to_focus, 0)

    if client ~= nil then
        client.focus = true
    end
end


function activate_tag(tag, client, tag_number)
    if type(tag) == 'number' then
        tag = my_tags['tag_' .. tostring(tag)]
    end

    dropdown_app_toggle('all', 'hide')
    awful.screen.focus(tag.screen)
    tag:view_only()

    if client ~= nil then
        next_tag_client(client, 0)
    else
        focus_last_focused_client_of_tag(tag.screen)
    end

    if tag_number and #tag:clients() == 0 and my_tags_default_applications['tag_' .. tostring(tag_number)] then
        start_applications_section('tag_' .. tostring(tag_number), my_tags_default_applications)
    end
end


function tables_diff(a, b)
    local a_inverted = {}
    local a_cloned = {}
    local result = {}

    for ak,av in pairs(a) do
        a_cloned[ak] = av
        a_inverted[av] = ak
    end

    for bk,bv in pairs(b) do 
        if a_inverted[bv] ~= nil then
            a_cloned[a_inverted[bv]] = nil
        end
    end

    for _,v in pairs(a_cloned) do 
        table.insert(result, v)
    end

    if #result then
        return result
    else
        return {}
    end
end


function ternary(cond, if_true, if_false)
    if cond then return if_true else return if_false end
end


function is_3d_client(c)
    if c == nil then
        return false
    end

    for _, my_3d_app_class in pairs(my_3d_app_classes) do
        if string.match(c.class, my_3d_app_class) then
            return true
        end
    end

    return false
end


function clear_pip_opacity_timer()
    if PIP_OPACITY_TIMER then
        PIP_OPACITY_TIMER:stop()
        PIP_OPACITY_TIMER = nil
    end
end


function clear_abtt_opacity_timer()
    if ABTT_OPACITY_TIMER then
        ABTT_OPACITY_TIMER:stop()
        ABTT_OPACITY_TIMER = nil
    end
end


function position_abtt_window(c, x_offset, y_offset)
    local scr_geometry = c.screen.workarea

    if x_offset ~= nil then
        c.x = scr_geometry.x + scr_geometry.width - (x_offset + c.width)
    end

    if y_offset ~= nil then
        c.y = scr_geometry.y + scr_geometry.height - (y_offset + c.height)
    end
end


function get_x_offset(c)
    local scr_geometry = c.screen.workarea
    return scr_geometry.x + scr_geometry.width - c.width - c.x
end


function init_center_client(c)
    c:move_to_screen(mouse.screen)
    c:move_to_tag(mouse.screen.selected_tag)
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
