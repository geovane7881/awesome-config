-----------------------------------------------------------------------------------------------------------------------
--                                                  Environment config                                               --
-----------------------------------------------------------------------------------------------------------------------

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local redflat = require("redflat")

local unpack = unpack or table.unpack

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local env = {}

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function env:init(args)

	-- init vars
	args = args or {}
	local theme = args.theme or "colorless"

	-- environment vars
	self.updates = args.updates or "bash -c 'pacman -Qu | grep -v ignored | wc -l'"
	self.themedir = awful.util.get_configuration_dir() .. "themes/" .. theme
	self.home = os.getenv("HOME")
  self.terminal = os.getenv("TERMCMD") or 'kitty'
	self.mod = args.mod or "Mod4"
	self.fm = args.fm or "nautilus"
	self.document_viewer = "evince"
	self.vscode = "code"
	self.postman = "postman"
	self.dbeaver = "dbeaver"
	self.intellij = "intellij"
	self.notion = "notion-desktop"
  self.browser = os.getenv("BROWSER") or "google-chrome"
  self.discord = "discord"
  self.player = args.player or "mpd"
  -- vivaldi, no localhost, meu segundo navegador
  -- self.browser2 = "vivaldi-stable http://localhost"
  -- self.player = args.player or "spotify"
  -- self.player = args.player or "mopidy"
  -- qute com o popup do rofi, meu navegador padrão
  -- self.browser = "sh "..self.home.."/.scripts/qute.sh"
	self.mpsyt = "sh "..self.home.."/.scripts/setup_player.sh"
  self.screenshot_d = "bash -c 'gnome-screenshot -w'"
  self.screenshot_a = "bash -c 'gnome-screenshot -a'"
  self.screenshot_o = "bash -c 'gnome-screenshot --interactive'"

  --terminal apps
  self.terminal_cmd = "bash -c '"..self.terminal.."'"
	self.editor = "bash -c '"..self.terminal.." -e nvim'"
  --self.terminal_fm = "bash -c '"..self.terminal.." -e ranger'"
  self.terminal_fm = "bash -c '"..self.terminal.." -e lf'"
  self.email = "bash -c '"..self.terminal.." -e neomutt'"
  self.newsboat = "bash -c '"..self.terminal.." -e newsboat'";

  -- music
	self.player_cmd = "bash -c '"..self.terminal.." -e ncmpcpp'"
  self.player_play_pause = "playerctl play-pause"
  self.player_previous = "playerctl previous"
  self.player_next = "playerctl next"

	-- boolean defaults is pain
	self.sloppy_focus = args.sloppy_focus or false
  self.color_border_focus = args.color_border_focus or false
	-- self.color_border_focus = true
	self.set_slave = args.set_slave == nil and true or false
	self.desktop_autohide = args.desktop_autohide or false
	self.set_center = args.set_center or false

	-- theme setup
	beautiful.init(env.themedir .. "/theme.lua")

	-- naughty config
	naughty.config.padding = beautiful.useless_gap and 2 * beautiful.useless_gap or 0

	if beautiful.naughty then
		naughty.config.presets.normal   = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.normal)
		naughty.config.presets.critical = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.critical)
		naughty.config.presets.low      = redflat.util.table.merge(beautiful.naughty.base, beautiful.naughty.low)
	end
end

-- Common functions
-----------------------------------------------------------------------------------------------------------------------

-- Wallpaper setup
--------------------------------------------------------------------------------
env.wallpaper = function(s)
	if beautiful.wallpaper then
		if not env.desktop_autohide and awful.util.file_readable(beautiful.wallpaper) then
			gears.wallpaper.maximized(beautiful.wallpaper, s, true)
		else
			gears.wallpaper.set(beautiful.color.bg)
		end
	end
end

-- Tag tooltip text generation
--------------------------------------------------------------------------------
env.tagtip = function(t)
	local layname = awful.layout.getname(awful.tag.getproperty(t, "layout"))
	if redflat.util.table.check(beautiful, "widget.layoutbox.name_alias") then
		layname = beautiful.widget.layoutbox.name_alias[layname] or layname
	end
	return string.format("%s (%d apps) [%s]", t.name, #(t:clients()), layname)
end

-- Panel widgets wrapper
--------------------------------------------------------------------------------
env.wrapper = function(widget, name, buttons)
	local margin = redflat.util.table.check(beautiful, "widget.wrapper")
	               and beautiful.widget.wrapper[name] or { 0, 0, 0, 0 }
	if buttons then
		widget:buttons(buttons)
	end

	return wibox.container.margin(widget, unpack(margin))
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return env
