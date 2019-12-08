local awful = require('awful')
awful.spawn = require('awful.spawn')
local gears = require('gears')
local gestures = {gestures = {}}


local function center_mouse()
    local scr = mouse.screen
    local center_x = scr.geometry.x + scr.geometry.width/2
    local center_y = scr.geometry.y + scr.geometry.height/2
    mouse.coords({
        x=center_x,
        y=center_y,
    })
end


function gestures.trigger(trigger_mouse_button)
    center_mouse()
    local gesture_timeout = 1 --in seconds
    local start_coords = mouse.coords()
    local prev_movement = {
        x = nil,
        y = nil
    }
    local cur_movement = {
        x = nil,
        y = nil
    }
    local movements = {}

    local gesture_timer

    function read_movement()
        if prev_movement.x == nil or cur_movement.x == nil then
            return
        end

        local delta_x = cur_movement.x - prev_movement.x
        local delta_y = cur_movement.y - prev_movement.y
        local x_move_length = math.abs(delta_x)
        local y_move_length = math.abs(delta_y)
        local is_x_movement = false

        if x_move_length < 10 and y_move_length < 10 then
            return
        end

        if x_move_length > y_move_length then
            is_x_movement = true
        end

        if is_x_movement then
            if delta_x >= 0 then
                movement = 'r'
            else
                movement = 'l'
            end
        else
            if delta_y >= 0 then
                movement = 'd'
            else
                movement = 'u'
            end
        end

        if movements[#movements] ~= movement then
            movements[#movements + 1] = movement
        end

        prev_movement.x = cur_movement.x
        prev_movement.y = cur_movement.y
    end

    local function create_movement_timer()
        return gears.timer.start_new(
            0.05,
            function()
                if mousegrabber.isrunning() == false then
                    return
                end

                read_movement()
                create_movement_timer()
            end
        )
    end

    create_movement_timer()

    mousegrabber.run(
        function(args)
            if args.buttons[trigger_mouse_button] == false then
                if gestures.gestures[table.concat(movements, '_')] then
                    gestures.gestures[table.concat(movements, '_')]()
                end

                mousegrabber.stop()
                return true
            end

            cur_movement.x = args.x
            cur_movement.y = args.y

            if prev_movement.x == nil then
                prev_movement.x = args.x
                prev_movement.y = args.y
            end

            return true
        end,
        'diamond_cross'
    )

    return false
end


return gestures
