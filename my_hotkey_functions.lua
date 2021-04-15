local ALIGNED_BORDER_COLOR = '#aaaa88'

function hotkey_cllent_align_max(c)
    if c.pinned_to_tag then
        return
    end

    client_save_original_geometry(c)
    c.maximized = false
    c.floating = true
    c.border_color = ALIGNED_BORDER_COLOR
    c.border_width = 0
    client_pseudo_maximize(c)
end


function hotkey_cllent_restore_pre_align(c)
    if c.pinned_to_tag then
        return
    end

    client_restore_original_geometry(c)
end


function hotkey_client_align_right(c)
    if c.pinned_to_tag then
        return
    end

    client_save_original_geometry(c)
    c.maximized = false
    c.floating = true
    c.border_normal_color = ALIGNED_BORDER_COLOR
    c.border_width = 1
    local scr_geometry = c.screen.workarea
    local border_space = c.border_width * 2
    c.width = math.floor(scr_geometry.width/2) - border_space
    c.height = scr_geometry.height - border_space
    c.x = scr_geometry.x
    c.y = scr_geometry.y
end


function hotkey_client_align_left(c)
    if c.pinned_to_tag and c.pinned_to_tag.sticky then
        return
    end

    client_save_original_geometry(c)
    c.maximized = false
    c.floating = true
    c.border_normal_color = ALIGNED_BORDER_COLOR
    c.border_width = 1
    local scr_geometry = c.screen.workarea
    local border_space = c.border_width * 2
    c.width = math.floor(scr_geometry.width/2) - border_space
    c.height = scr_geometry.height - border_space
    c.x = scr_geometry.x + scr_geometry.width - (c.width + border_space)
    c.y = scr_geometry.y
end
