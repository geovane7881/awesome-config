-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless config                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")
local switcher = require("awesome-switcher")

redflat.startup:activate()

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("colorless.env-config") -- load file with environment
env:init()


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("colorless.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("colorless.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { widget = redflat.gauge.tag.orange.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })

-- Software update indcator
--------------------------------------------------------------------------------
redflat.widget.updates:init({ command = env.updates })

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.blue.new })

-- activate player widget
redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
	awful.button({}, 4, function() volume.widget:change_volume()                end),
	awful.button({}, 5, function() volume.widget:change_volume({ down = true }) end),
	awful.button({}, 2, function() volume.widget:mute()                         end),
	awful.button({}, 3, function() redflat.float.player:show()                  end),
	awful.button({}, 1, function() redflat.float.player:action("PlayPause")     end),
	awful.button({}, 8, function() redflat.float.player:action("Previous")      end),
	awful.button({}, 9, function() redflat.float.player:action("Next")          end)
)

---- Mail widget
----------------------------------------------------------------------------------
---- mail settings template
----local my_mails = require("color.blue.mail-example")
--local my_mails = require("colorless.mail-example")
--
---- safe load private mail settings
----pcall(function() my_mails = require("private.mail-config") end)
--
---- widget setup
--local mail = {}
--redflat.widget.mail:init({ maillist = my_mails })
--mail.widget = redflat.widget.mail()
--
---- buttons
--mail.buttons = awful.util.table.join(
--	awful.button({ }, 1, function () awful.spawn.with_shell(env.mail) end),
--	awful.button({ }, 2, function () redflat.widget.mail:update(true) end)
--)
--
-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {}, icon = {} }

-- icons
sysmon.icon.battery = redflat.util.table.check(beautiful, "wicon.battery")
sysmon.icon.network = redflat.util.table.check(beautiful, "wicon.wireless")
sysmon.icon.cpuram = redflat.util.table.check(beautiful, "wicon.monitor")

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
	{ timeout = 60, widget = redflat.gauge.icon.single, monitor = { is_vertical = true, icon = sysmon.icon.battery } }
)

-- network speed
sysmon.widget.network = redflat.widget.net(
	{
		--interface = "wlp60s0",
    interface = "enp3s0",
		alert = { up = 5 * 1024^2, down = 5 * 1024^2 },
		speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
		autoscale = false
	},
	{ timeout = 2, widget = redflat.gauge.monitor.double, monitor = { icon = sysmon.icon.network } }
)

-- CPU and RAM usage
local cpu_storage = { cpu_total = {}, cpu_active = {} }

local cpuram_func = function()
	local cpu_usage = redflat.system.cpu_usage(cpu_storage).total
	local mem_usage = redflat.system.memory_info().usep

	return {
		text = "CPU: " .. cpu_usage .. "%  " .. "RAM: " .. mem_usage .. "%",
		value = { cpu_usage / 100,  mem_usage / 100},
		alert = cpu_usage > 80 or mem_usage > 70
	}
end

sysmon.widget.cpuram = redflat.widget.sysmon(
	{ func = cpuram_func },
	{ timeout = 2,  widget = redflat.gauge.monitor.double, monitor = { icon = sysmon.icon.cpuram } }
)

sysmon.buttons.cpuram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)

-- Screen setup
-----------------------------------------------------------------------------------------------------------------------
-- aliases for setup
local al = awful.layout.layouts

awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag({ "Tag1", "Tag2", "Tag3", "Tag4", "Tag5" }, s, awful.layout.layouts[1])

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons })

		-- panel wibox
		s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,
				env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				separator,
				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				s.mypromptbox,
				separator,
			},
			{ -- middle widget
				layout = wibox.layout.align.horizontal,
				expand = "outside",

				nil,
				env.wrapper(tasklist[s], "tasklist"),
			},
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,
				--separator,
				--env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
				--env.wrapper(mail.widget, "mail", mail.buttons),
				--separator,
				env.wrapper(sysmon.widget.network, "network"),
				separator,
				env.wrapper(sysmon.widget.cpuram, "cpuram", sysmon.buttons.cpuram),
				separator,
				env.wrapper(volume.widget, "volume", volume.buttons),
				-- separator,
				env.wrapper(textclock.widget, "textclock"),
				-- separator,
				-- env.wrapper(sysmon.widget.battery, "battery"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
			},
		}
	end
)


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("colorless.keys-config") -- load file with hotkeys configuration
--hotkeys:init({ env = env, menu = mymenu.mainmenu })
hotkeys:init({ env = env, menu = mymenu.mainmenu, volume = volume.widget })


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()

-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("colorless.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})



-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({ env = env })

-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
if redflat.startup.is_startup then
	local autostart = require("colorless.autostart-config") -- load file with autostart application list
	autostart.run()
end
