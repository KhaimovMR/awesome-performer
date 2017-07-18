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

    if action ~= nil then
        set_action = action
    end

    if app_name == "ChromeMindmeister" then
        awful.util.spawn('dropdown-window ChromeMindmeister ' .. set_action .. ' "google-chrome --app=https://mindmeister.com --user-data-dir=' .. my_home_path .. '/.config/chrome-mindmeister" ')
    elseif app_name == "ChromeStuff" then
        awful.util.spawn('dropdown-window ChromeStuff ' .. set_action .. ' "google-chrome --user-data-dir=' .. my_home_path .. '/.config/chrome-stuff" ')
    elseif app_name == "Terminal" then
        awful.util.spawn('dropdown-window Terminal ' .. set_action .. ' "urxvt -pixmap /opt/user-settings/Dropbox/Pictures/Wallpapers/vintage_ornament-wallpaper-1920x1080-dark.png -e tmux new-session -A -s urxvt"')
    elseif app_name == "AndroidKeyboard" then
        awful.util.spawn('dropdown-window AndroidKeyboard ' .. set_action .. ' "terminator --title=android-keyboard --profile=android-keyboard"')
    else
        awful.util.spawn('dropdown-window ChromeMindmeister hide')
        awful.util.spawn('dropdown-window ChromeStuff hide')
        awful.util.spawn('dropdown-window Terminal hide')
        awful.util.spawn('dropdown-window AndroidKeyboard hide')
    end
end
