local awful = require('awful')
local naughty = require('naughty')

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
    return os.capture(
	'ps ax | grep -E "' .. cmd .. '" | sed "s/^[ \t]//g" | grep -v grep | grep -E "^[0-9]+" -o'
    )
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
