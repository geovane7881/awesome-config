-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
--------------------------------------------------------------------------------
local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }
-- for debugging
-- local inspect = require('inspect')

local apprunner = redflat.float.apprunner
local switcher = require("awesome-switcher")
local beautiful = require("beautiful")

local current = redflat.widget.tasklist.filter.currenttags
local allscr = redflat.widget.tasklist.filter.allscreen
local laybox = redflat.widget.layoutbox
local redtip = redflat.float.hotkeys
local redtitle = redflat.titlebar
local laycom = redflat.layout.common

--------------------------------------------------------------------------------
-- Key support functions
--------------------------------------------------------------------------------

-- move client to screen
local function move_to_screen(dir)
	return function()
		if client.focus then
			client.focus:move_to_screen(dir == "right" and client.focus.screen.index + 1 or client.focus.screen.index - 1)
			client.focus:raise()
		end
	end
end

local focus_switch_byd = function(dir)
	return function()
		awful.client.focus.bydirection(dir)
		if client.focus then client.focus:raise() end
	end
end

local function minimize_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) then c.minimized = true end
	end
end

local function minimize_all_except_focused()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
	end
end

local function restore_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c.minimized then c.minimized = false end
	end
end

local function kill_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and not c.sticky then c:kill() end
	end
end

local function focus_to_previous()
    switcher.switch( 1, "Mod1", "Alt_L", "Shift", "Tab")
end

local function focus_to_next()
    switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
end

local function restore_client()
	local c = awful.client.restore()
	if c then client.focus = c; c:raise() end
end

local function toggle_placement(env)
	env.set_slave = not env.set_slave
	redflat.float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
end

local function tag_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then action(tag) end
		end
	)
end

local function client_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then action(tag) end
			end
		end
	)
end

-- run application once
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        findme = cmd
        if cmd == 'google-chrome' or cmd == '/usr/bin/google-chrome' then
          findme = 'chrome'
        end

        firstspace = cmd:find(" ")
        if firstspace then
            findme = cmd:sub(0, firstspace-1)
        end
        awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, 
cmd))
    end
end

-- brightness functions
local brightness = function(args)
	redflat.float.brightness:change_with_xbacklight(args) -- use xbacklight
end

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- Init vars
	------------------------------------------------------------
	args = args or {}
	local env = args.env
	local mainmenu = args.menu
	local volume = args.volume

	self.mouse.root = (awful.util.table.join(
		awful.button({ }, 3, function () mainmenu:toggle() end)
    --scroll do desktop
		--,awful.button({ }, 4, awful.tag.viewnext),
		--awful.button({ }, 5, awful.tag.viewprev)
	))

	-- volume functions
	local volume_raise = function() volume:change_volume({ show_notify = true })              end
	local volume_lower = function() volume:change_volume({ show_notify = true, down = true }) end
	local volume_mute  = function() volume:mute() end


	-- Layouts
	--------------------------------------------------------------------------------

	-- shared layout keys
	local layout_tile = {
		{
			{ env.mod, "Shift" }, "l", function () awful.tag.incmwfact( 0.05) end,
			{ description = "Increase master width factor", group = "Layout" }
		},
		{
			{ env.mod, "Shift" }, "h", function () awful.tag.incmwfact(-0.05) end,
			{ description = "Decrease master width factor", group = "Layout" }
		},
		{
			{ env.mod, "Shift" }, "k", function () awful.client.incwfact( 0.05) end,
			{ description = "Increase window factor of a client", group = "Layout" }
		},
		{
			{ env.mod, "Shift" }, "j", function () awful.client.incwfact(-0.05) end,
			{ description = "Decrease window factor of a client", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "k", function () awful.tag.incnmaster( 1, nil, true) end,
			{ description = "Increase the number of master clients", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "j", function () awful.tag.incnmaster(-1, nil, true) end,
			{ description = "Decrease the number of master clients", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "l", function () awful.tag.incncol( 1, nil, true) end,
			{ description = "Increase the number of columns", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "h", function () awful.tag.incncol(-1, nil, true) end,
			{ description = "Decrease the number of columns", group = "Layout" }
		},
	}

	laycom:set_keys(layout_tile, "tile")

	-- grid layout keys
	local layout_grid_move = {
		{
			{ env.mod }, "KP_Up", function() grid.move_to("up") end,
			{ description = "Move window up", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Down", function() grid.move_to("down") end,
			{ description = "Move window down", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Left", function() grid.move_to("left") end,
			{ description = "Move window left", group = "Movement" }
		},
		{
			{ env.mod }, "KP_right", function() grid.move_to("right") end,
			{ description = "Move window right", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Up", function() grid.move_to("up", true) end,
			{ description = "Move window up by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Down", function() grid.move_to("down", true) end,
			{ description = "Move window down by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Left", function() grid.move_to("left", true) end,
			{ description = "Move window left by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Right", function() grid.move_to("right", true) end,
			{ description = "Move window right by bound", group = "Movement" }
		},
	}

	local layout_grid_resize = {
		{
			{ env.mod }, "j", function() grid.resize_to("up") end,
			{ description = "Inrease window size to the up", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() grid.resize_to("down") end,
			{ description = "Inrease window size to the down", group = "Resize" }
		},
		{
			{ env.mod }, "h", function() grid.resize_to("left") end,
			{ description = "Inrease window size to the left", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() grid.resize_to("right") end,
			{ description = "Inrease window size to the right", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "j", function() grid.resize_to("up", nil, true) end,
			{ description = "Decrease window size from the up", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "k", function() grid.resize_to("down", nil, true) end,
			{ description = "Decrease window size from the down", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "h", function() grid.resize_to("left", nil, true) end,
			{ description = "Decrease window size from the left", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "l", function() grid.resize_to("right", nil, true) end,
			{ description = "Decrease window size from the right", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "j", function() grid.resize_to("up", true) end,
			{ description = "Increase window size to the up by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "k", function() grid.resize_to("down", true) end,
			{ description = "Increase window size to the down by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "h", function() grid.resize_to("left", true) end,
			{ description = "Increase window size to the left by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "l", function() grid.resize_to("right", true) end,
			{ description = "Increase window size to the right by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "j", function() grid.resize_to("up", true, true) end,
			{ description = "Decrease window size from the up by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "k", function() grid.resize_to("down", true, true) end,
			{ description = "Decrease window size from the down by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "i", function() grid.resize_to("left", true, true) end,
			{ description = "Decrease window size from the left by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "l", function() grid.resize_to("right", true, true) end,
			{ description = "Decrease window size from the right by bound ", group = "Resize" }
		},
	}

	redflat.layout.grid:set_keys(layout_grid_move, "move")
	redflat.layout.grid:set_keys(layout_grid_resize, "resize")

	-- user map layout keys
	local layout_map_layout = {
		{
			{ env.mod }, "s", function() map.swap_group() end,
			{ description = "Change placement direction for group", group = "Layout" }
		},
		{
			{ env.mod }, "v", function() map.new_group(true) end,
			{ description = "Create new vertical group", group = "Layout" }
		},
		{
			{ env.mod }, "h", function() map.new_group(false) end,
			{ description = "Create new horizontal group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "v", function() map.insert_group(true) end,
			{ description = "Insert new vertical group before active", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "h", function() map.insert_group(false) end,
			{ description = "Insert new horizontal group before active", group = "Layout" }
		},
		{
			{ env.mod }, "d", function() map.delete_group() end,
			{ description = "Destroy group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "d", function() map.clean_groups() end,
			{ description = "Destroy all empty groups", group = "Layout" }
		},
		{
			{ env.mod }, "f", function() map.set_active() end,
			{ description = "Set active group", group = "Layout" }
		},
		{
			{ env.mod }, "g", function() map.move_to_active() end,
			{ description = "Move focused client to active group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "f", function() map.hilight_active() end,
			{ description = "Hilight active group", group = "Layout" }
		},
		{
			{ env.mod }, "a", function() map.switch_active(1) end,
			{ description = "Activate next group", group = "Layout" }
		},
		{
			{ env.mod }, "q", function() map.switch_active(-1) end,
			{ description = "Activate previous group", group = "Layout" }
		},
		{
			{ env.mod }, "]", function() map.move_group(1) end,
			{ description = "Move active group to the top", group = "Layout" }
		},
		{
			{ env.mod }, "[", function() map.move_group(-1) end,
			{ description = "Move active group to the bottom", group = "Layout" }
		},
		{
			{ env.mod }, "r", function() map.reset_tree() end,
			{ description = "Reset layout structure", group = "Layout" }
		},
	}

	local layout_map_resize = {
		{
			{ env.mod }, "j", function() map.incfactor(nil, 0.1, false) end,
			{ description = "Increase window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() map.incfactor(nil, -0.1, false) end,
			{ description = "Decrease window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "i", function() map.incfactor(nil, 0.1, true) end,
			{ description = "Increase window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() map.incfactor(nil, -0.1, true) end,
			{ description = "Decrease window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "j", function() map.incfactor(nil, 0.1, false, true) end,
			{ description = "Increase group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "l", function() map.incfactor(nil, -0.1, false, true) end,
			{ description = "Decrease group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "i", function() map.incfactor(nil, 0.1, true, true) end,
			{ description = "Increase group vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "k", function() map.incfactor(nil, -0.1, true, true) end,
			{ description = "Decrease group vertical size factor", group = "Resize" }
		},
	}

	redflat.layout.map:set_keys(layout_map_layout, "layout")
	redflat.layout.map:set_keys(layout_map_resize, "resize")

	-- Keys for widgets
	--------------------------------------------------------------------------------

	-- Apprunner widget
	------------------------------------------------------------
	local apprunner_keys_move = {
		{
			{ env.mod }, "j", function() apprunner:down() end,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "i", function() apprunner:up() end,
			{ description = "Select previous item", group = "Navigation" }
		},
	}

	apprunner:set_keys(awful.util.table.join(apprunner.keys.move, apprunner_keys_move), "move")

	--------------------------------------------------------------------------------
	-- Menu widget
	--------------------------------------------------------------------------------
	local menu_keys_move = {
		{
			{ env.mod }, "k", redflat.menu.action.down,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "i", redflat.menu.action.up,
			{ description = "Select previous item", group = "Navigation" }
		},
		{
			{ env.mod }, "k", redflat.menu.action.back,
			{ description = "Go back", group = "Navigation" }
		},
		{
			{ env.mod }, "l", redflat.menu.action.enter,
			{ description = "Open submenu", group = "Navigation" }
		},
	}

	redflat.menu:set_keys(awful.util.table.join(redflat.menu.keys.move, menu_keys_move), "move")

	--------------------------------------------------------------------------------
	-- Global keys
	--------------------------------------------------------------------------------
	self.raw.root = {
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "Show hotkeys helper", group = "Main" }
		},
		{
			{ env.mod, "Control" }, "r", awesome.restart,
			{ description = "Reload awesome", group = "Main" }
		},
		{
			{ env.mod }, "s", function() mainmenu:show() end,
			{ description = "Main menu", group = "Launchers" }
		},
		-------------------------------------------------------------------------------------
    -- Launchers/Switcher to opened Aplications
		-------------------------------------------------------------------------------------
		{
			{ env.mod }, "Return", function() awful.spawn(env.terminal_cmd) end,
			{ description = "Open a terminal", group = "Launchers" }
		},
		{
			{ env.mod }, "r", function() awful.spawn(env.terminal_fm) end,
			{ description = "Terminal file browser", group = "Launchers" }
		},
		{
			{ env.mod, "Shift" }, "r", function()
          awful.spawn(env.fm)
          -- local screen = awful.screen.focused()
          -- local tag = screen.tags[3]
          -- if tag then
          --   tag:view_only()
          -- end
        end,
			{ description = "GUI file browser", group = "Launchers" }
		},
		{
			{ env.mod }, "n",  function()
        awful.spawn.single_instance(env.editor)
        local screen = awful.screen.focused()
        local tag = screen.tags[2]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            if c.name == "nvim" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "Neovim", group = "Launchers" }
		},
		{
			{ env.mod }, "v",  function()
        run_once({env.vscode})
        local screen = awful.screen.focused()
        local tag = screen.tags[2]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            if c.class == "Code" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "VSCode", group = "Launchers" }
		},
		{
			{ env.mod }, "w", function()
        run_once({env.browser})
        local screen = awful.screen.focused()
        local tag = screen.tags[2]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            -- if c.class == "Google-chrome" then
            if c.class == "Google-chrome-unstable" then
            -- if c.class == "firefox" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "Google Chrome", group = "Launchers" }
		},
		{
			{ env.mod, "Shift" }, "d", function()
          awful.spawn(env.discord)
          local screen = awful.screen.focused()
          local tag = screen.tags[4]
          if tag then
            tag:view_only()
          end
        end,
			{ description = "Discord", group = "Launchers" }
		},
		{
			{ env.mod }, "p",  function()
        run_once({env.postman})
        local screen = awful.screen.focused()
        local tag = screen.tags[3]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            if c.class == "Postman" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "Postman", group = "Launchers" }
		},
		{
			{ env.mod }, "b",  function()
        run_once({env.dbeaver})
        local screen = awful.screen.focused()
        local tag = screen.tags[3]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            if c.class == "DBeaver" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "DBEaver", group = "Launchers" }
		},
		{
			{ env.mod, "Control" }, "n",  function()
        run_once({env.notion})
        local screen = awful.screen.focused()
        local tag = screen.tags[1]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            if c.class == "notion-desktop" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "Notion", group = "Launchers" }
		},
		{
			{ env.mod  }, "i",  function()
        run_once({env.intellij})
        local screen = awful.screen.focused()
        local tag = screen.tags[3]
        if tag then
          tag:view_only()
          for _, c in ipairs(client.get()) do
            if c.class == "jetbrains-idea-ce" then
              client.focus = c
              c:raise()
            end
          end
        end
      end,
			{ description = "Intellij", group = "Launchers" }
		},
		{
			{ env.mod }, "y", function() awful.spawn(env.player_cmd) end,
			{ description = "Music player", group = "Launchers" }
		},
		-------------------------------------------------------------------------------------
		-- Scripts, Rofi
		-------------------------------------------------------------------------------------
		{
			{ env.mod }, "d", function() awful.spawn("sh " .. env.home .. "/.scripts/rofi/appsmenu.sh") end,
			{ description = "Application launcher", group = "Rofi" }
		},
		{
			{ env.mod }, "0", function() redflat.service.logout:show() end,
			{ description = "Log out screen", group = "Widgets" }
		},
		{
			{ env.mod, "Shift" }, "n", function() awful.spawn("sh " .. env.home .. "/.scripts/rofi/notes.sh") end,
			{ description = "Notes", group = "Rofi" }
		},
		{
			{ env.mod, "Shift"}, "f", function() awful.spawn("sh " .. env.home .. "/.scripts/rofi/websearch.sh") end,
			{ description = "Websearch", group = "Rofi" }
		},
		{
			{ env.mod, "Shift" }, "i", function() awful.spawn("sh " .. env.home .. "/.scripts/rofi/locate.sh") end,
			{ description = "Locate files", group = "Rofi" }
		},
		{
			{ env.mod, "Shift" }, "b", function() awful.spawn("sh " .. env.home .. "/.scripts/rofi/bookmark.sh") end,
			{ description = "Bookmarks", group = "Rofi" }
		},
		-------------------------------------------------------------------------------------
		-- Window control
		-------------------------------------------------------------------------------------
		{
			{ env.mod }, "m", function () redflat.service.navigator:run() end,
			{ description = "[Hold] Tiling window control mode", group = "Window control" }
		},
		{
			{ env.mod, "Control" }, "b", function() redflat.float.bartip:show() end,
			{ description = "[Hold] Titlebar control", group = "Window control" }
		},
		{
			{ env.mod, "Control" }, "f", function() redflat.float.control:show() end,
			{ description = "[Hold] Floating window control mode", group = "Window control" }
		},
		{
			{ env.mod}, "t", function() redtitle.global_switch() end,
			{ description = "Switch titlebar style", group = "Window control" }
		},
		-------------------------------------------------------------------------------------
		-- Client Focus and Navigation, Layouts
		-------------------------------------------------------------------------------------
    {
			{ env.mod, "Control"}, "h",
			function()
				awful.screen.focus_bydirection("left")
				if client.focus then client.focus:raise() end
			end,
			{ description = "Go to previous monitor", group = "Client focus"}
		},
		{
			{ env.mod, "Control"}, "l",
			function()
				awful.screen.focus_bydirection("right")
				if client.focus then client.focus:raise() end
			end,
			{ description = "Go to next monitor", group = "Client focus"}
		},
		{
			{ env.mod, "Shift" }, "l",
			function ()
				awful.client.swap.byidx(1)
			end,
			{ description = "swap with next client by index", group = "Client swap"}
		},
		{
			{ env.mod, "Shift" }, "h", function ()
				awful.client.swap.byidx(-1)
			end,
			{ description = "swap with previous client by index", group = "Client swap"}
		},
		{
			{ env.mod, "Control", "Shift" }, "h", move_to_screen("left"),
			{ description = "Move client to the next screen", group = "Client swap"}
		},
		{
			{ env.mod, "Control", "Shift" }, "l", move_to_screen("right"),
			{ description = "Move client to the next screen", group = "Client swap"}
		},
		{
			{ env.mod }, "l", focus_switch_byd("right"),
			{ description = "Go to right client", group = "Client focus" }
		},
		{
			{ env.mod }, "h", focus_switch_byd("left"),
			{ description = "Go to left client", group = "Client focus" }
		},
		{
			{ env.mod }, "k", focus_switch_byd("up"),
			{ description = "Go to upper client", group = "Client focus" }
		},
		{
			{ env.mod }, "j", focus_switch_byd("down"),
			{ description = "Go to lower client", group = "Client focus" }
		},
    -- fast app switch with alt tab (with visualizer)
		{
			{ "Mod1" }, "Tab", focus_to_previous,
			{ description = "Go to previous client", group = "Client focus" }
		},
		{
			{ "Mod1", "Shift" }, "Tab", focus_to_next,
			{ description = "Go to next client", group = "Client focus" }
		},
    -- fast screen switch with alt esc (basic)
		{
			{ "Mod1" }, "Escape", awful.tag.history.restore,
			{ description = "Swith to previos tag by history", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Escape", awful.tag.history.restore,
			{ description = "Go previos tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Right", awful.tag.viewnext,
			{ description = "View next tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Left", awful.tag.viewprev,
			{ description = "View previous tag", group = "Tag navigation" }
		},
		{
			{ env.mod, "Control"}, "y", function() laybox:toggle_menu(mouse.screen.selected_tag) end,
			{ description = "Show layout menu", group = "Layouts" }
		},
		{
			{ env.mod, "Shift" }, "Up", function() awful.layout.inc(1) end,
			{ description = "Select next layout", group = "Layouts" }
		},
		{
			{ env.mod, "Shift" }, "Down", function() awful.layout.inc(-1) end,
			{ description = "Select previous layout", group = "Layouts" }
		},
		-------------------------------------------------------------------------------------
		-- Multimedia keys
		-------------------------------------------------------------------------------------
		{
			{}, "XF86AudioRaiseVolume", volume_raise,
			{ description = "Increase volume", group = "Volume control" }
		},
		{
			{}, "XF86AudioLowerVolume", volume_lower,
			{ description = "Reduce volume", group = "Volume control" }
		},
		{
			{}, "XF86AudioMute", volume_mute,
			{ description = "Mute audio", group = "Volume control" }
		},
		{
			{}, "XF86MonBrightnessUp", function() brightness({ step = 2 }) end,
			{ description = "Increase brightness", group = "Brightness control" }
		},
		{
			{}, "XF86MonBrightnessDown", function() brightness({ step = 2, down = true }) end,
			{ description = "Reduce brightness", group = "Brightness control" }
		},
		{
			{}, "XF86AudioPlay", function() redflat.float.player:action("PlayPause") end,
			{ description = "Play/Pause track", group = "Audio player" }
		},
		{
			{}, "XF86AudioNext", function() redflat.float.player:action("Next") end,
			{ description = "Next track", group = "Audio player" }
		},
		{
			{}, "XF86AudioPrev", function() redflat.float.player:action("Previous") end,
			{ description = "Previous track", group = "Audio player" }
		},
		{
			{ env.mod }, ".", function() redflat.float.player:action("Next") end,
			{ description = "Next track", group = "Audio player" }
		},
		{
			{ env.mod }, ",", function() redflat.float.player:action("Previous") end,
			{ description = "Previous track", group = "Audio player" }
		},
		{
			{}, "Print", function() awful.spawn(env.screenshot_o) end,
			{ description = "Screenshot", group = "Launchers" }
		},
	}

	--------------------------------------------------------------------------------
	-- Client keys
	--------------------------------------------------------------------------------
	self.raw.client = {
		{
			{ env.mod }, "F11", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
			{ description = "Toggle fullscreen", group = "Client keys" }
		},
		{
			{ "Mod1" }, "q", function(c) c:kill() end,
			{ description = "Close", group = "Client keys" }
		},
		{
			{ env.mod }, "f", function(c) c.floating = not c.floating  end,
			{ description = "Toggle floating", group = "Client keys" }
		},
		{
			{ env.mod, "Control" }, "f", awful.client.floating.toggle,
			{ description = "Toggle floating menu", group = "Client keys" }
		},
		{
			{ env.mod, "Control" }, "o", function(c) c.ontop = not c.ontop end,
			{ description = "Toggle keep on top", group = "Client keys" }
		},
		{
			{ env.mod }, "Down", function(c) c.minimized = true end,
			{ description = "Minimize", group = "Client keys" }
		},
		{
			{ env.mod }, "Up", function(c) c.maximized = not c.maximized; c:raise() end,
			{ description = "Maximize", group = "Client keys" }
		},
    {
        { env.mod, "Shift" }, "m", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "Client keys"}
    },
	}

	self.keys.root = redflat.util.key.build(self.raw.root)
	self.keys.client = redflat.util.key.build(self.raw.client)

	--------------------------------------------------------------------------------
	-- Numkeys
	--------------------------------------------------------------------------------

	-- add real keys without description here
	for i = 1, 9 do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			tag_numkey(i,    { env.mod },                     function(t) t:view_only()               end),
			tag_numkey(i,    { env.mod, "Control" },          function(t) awful.tag.viewtoggle(t)     end),
			client_numkey(i, { env.mod, "Shift" },            function(t) client.focus:move_to_tag(t) end),
			client_numkey(i, { env.mod, "Control", "Shift" }, function(t) client.focus:toggle_tag(t)  end)
		)
	end

	-- make fake keys with description special for key helper widget
	local numkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

	self.fake.numkeys = {
		{
			{ env.mod }, "1..9", nil,
			{ description = "Switch to tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, "Control" }, "1..9", nil,
			{ description = "Toggle tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, "Shift" }, "1..9", nil,
			{ description = "Move focused client to tag", group = "Numeric keys", keyset = numkeys }
		},
		{
			{ env.mod, "Control", "Shift" }, "1..9", nil,
			{ description = "Toggle focused client on tag", group = "Numeric keys", keyset = numkeys }
		},
	}

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.numkeys), 2)

	-- Mouse buttons
	--------------------------------------------------------------------------------
	self.mouse.client = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ env.mod }, 1, awful.mouse.client.move),
		awful.button({ env.mod }, 3, awful.mouse.client.resize),
    awful.button({ env.mod, "Shift" }, 1,
				move_to_screen("left")
      ),
    awful.button({ env.mod, "Shift" }, 3,
				move_to_screen("right")
      )
	)

	-- Set root hotkeys
	--------------------------------------------------------------------------------
	root.keys(self.keys.root)
	root.buttons(self.mouse.root)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
