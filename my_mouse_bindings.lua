function my_mouse_bindings(awful, mymainmenu)
    root.buttons(
	awful.util.table.join(
	    awful.button({ }, 3, function () mymainmenu:toggle() end),
	    awful.button({ }, 4, awful.tag.viewprev),
	    awful.button({ }, 5, awful.tag.viewnext)
	)
    )
end
