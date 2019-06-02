local awful = require('awful')
local naughty = require('naughty')
local my_home_path = os.getenv('HOME')


function nt(text)
    for s in screen do
        naughty.notify({
            screen = s,
            preset = naughty.config.presets.normal,
            title = text,
        })
    end
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

function start_applications_section(applications_section)
    for _, app in pairs(applications_section) do
        local check_result
        app_name = app[1]
        app_start_cmd = app[2]
        app_check_cmd = app[3]
        do_xdo_check = app[4]

        if app_check_cmd == true then
            app_check_cmd = app_start_cmd
        end

        if app_check_cmd ~= false then
            check_result = get_pids_by_cmd(app_check_cmd, do_xdo_check)

            if check_result == "" then
                naughty.notify({
                    preset = naughty.config.presets.normal,
                    title = 'Starting up the:',
                    text = app_name
                })
            end
        end


        if app_check_cmd == false or check_result == '' then
            awful.util.spawn(app_start_cmd)
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
        awful.util.spawn('dropdown-window ChromeMindmeister ' .. set_action .. ' "google-chrome --app=https://mindmeister.com --user-data-dir=' .. my_home_path .. '/.config/chrome-mindmeister" ')
    elseif app_name == "ChromeStuff" then
        awful.util.spawn('dropdown-window ChromeStuff ' .. set_action .. ' "google-chrome --user-data-dir=' .. my_home_path .. '/.config/chrome-stuff" ')
    elseif app_name == "Terminal" then
        awful.util.spawn('dropdown-window Terminal ' .. set_action .. ' dr-terminal.sh shell')
    elseif app_name == "marks_work" then
        awful.util.spawn(
            'dropdown-window marks_work ' .. set_action .. ' "dr-vim-marks.sh work blue" shell'
        )
    elseif app_name == "marks_alightbit" then
        awful.util.spawn(
            'dropdown-window marks_alightbit ' .. set_action .. ' "dr-vim-marks.sh alightbit gold" shell'
        )
    elseif app_name == "marks_private" then
        awful.util.spawn(
            'dropdown-window marks_private ' .. set_action .. ' "dr-vim-marks.sh private green" shell'
        )
    elseif app_name == "AndroidKeyboard" then
        awful.util.spawn('dropdown-window AndroidKeyboard ' .. set_action .. ' "terminator --title=android-keyboard --profile=android-keyboard"')
    else
        awful.util.spawn('dropdown-window ChromeMindmeister hide')
        awful.util.spawn('dropdown-window ChromeStuff hide')
        awful.util.spawn('dropdown-window Terminal hide')
        awful.util.spawn('dropdown-window Marks hide')
        awful.util.spawn('dropdown-window AndroidKeyboard hide')
    end
end
