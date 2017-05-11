local awful = require('awful')
local naughty = require('naughty')
local my_home_path = os.getenv('HOME')

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
    result_string = string.gsub(s, '%s+$', '')
    result_string = string.gsub(s, '[\n\r]+', ' ')

    return result_string
end


function get_pids_by_cmd(cmd)
    local pids = os.capture(
        'ps ax | grep -E "' .. cmd .. '" | sed "s/^[ \t]//g" | grep -v grep | grep -E "^[0-9]+" -o'
    )

    --if pids ~= '' then
    --    naughty.notify({
    --        preset = naughty.config.presets.critical,
    --        title = 'Program is already launched!',
    --        text = pids .. " for app - " .. cmd
    --    })
    --end

    return pids
end


function kill_processes_by_cmd(cmd)
    local pids = get_pids_by_cmd(cmd)

    if pids ~= '' then
	os.execute('kill ' .. pids)
    end
end


function strip_new_lines(text)
    return text:gsub('\n', ' ')
end

function start_applications_section(applications_section)
    for _, app in pairs(applications_section) do
        app_start_cmd = app[1]
        app_check_cmd = app[2]

        if app_check_cmd == true then
            app_check_cmd = app_start_cmd
        end

        if app_check_cmd == false or get_pids_by_cmd(app_check_cmd) == '' then
            awful.util.spawn(app_start_cmd)
        end
    end
end

-- dropdown applications 
function dropdown_app_toggle (app_name, action)
    local set_action = "toggle"

    if state ~= nil then
        set_action = action
    end

    if app_name == "mindmeister" then
        dropdown_android_keyboard("hide")
        dropdown_mindmeister(set_action)
        dropdown_stuff("hide")
        dropdown_terminal("hide")
    elseif app_name == "stuff" then
        dropdown_android_keyboard("hide")
        dropdown_mindmeister("hide")
        dropdown_stuff(set_action)
        dropdown_terminal("hide")
    elseif app_name == "terminal" then
        dropdown_android_keyboard("hide")
        dropdown_mindmeister("hide")
        dropdown_stuff("hide")
        dropdown_terminal(set_action)
    elseif app_name == "android-keyboard" then
        dropdown_android_keyboard(set_action)
        dropdown_mindmeister("hide")
        dropdown_stuff("hide")
        dropdown_terminal("hide")
    end
end

function dropdown_hide_all ()
    dropdown_android_keyboard("hide")
    dropdown_mindmeister("hide")
    dropdown_stuff("hide")
    dropdown_terminal("hide")
end

function dropdown_mindmeister (action)
    awful.util.spawn('dropdown-window ChromeMindmeister ' .. action .. ' "google-chrome --app=https://mindmeister.com --user-data-dir=' .. my_home_path .. '/.config/chrome-mindmeister" ')
end

function dropdown_stuff (action)
    awful.util.spawn('dropdown-window ChromeStuff ' .. action .. ' "google-chrome --user-data-dir=' .. my_home_path .. '/.config/chrome-stuff" ')
end

function dropdown_terminal (action)
    awful.util.spawn('dropdown-window Terminal ' .. action .. ' "urxvt -pixmap /opt/user-settings/Dropbox/Pictures/Wallpapers/vintage_ornament-wallpaper-1920x1080-dark.png"')
end

function dropdown_android_keyboard (action)
    awful.util.spawn('dropdown-window AndroidKeyboard ' .. action .. ' "terminator --title=android-keyboard --profile=android-keyboard"')
end
