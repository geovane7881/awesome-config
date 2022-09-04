-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful =require("awful")
local beautiful = require("beautiful")
local redflat = require("redflat")
-- local inspect = require('inspect')

-----------------------------------------------------------------------------------------------------------------------
local rules = {}
local tags = root.tags()

rules.base_properties = {
	border_width = beautiful.border_width,
	border_color = beautiful.border_normal,
	focus        = awful.client.focus.filter,
	raise        = true,
	size_hints_honor = false,
	screen       = awful.screen.preferred,
	placement    = awful.placement.no_overlap + awful.placement.no_offscreen
}

rules.floating_any = {
	instance = { "DTA", "copyq", },
	class = {
		"Arandr", "Gpick", "Kruler", "MessageWin", "Sxiv", "Wpa_gui", "pinentry", "veromix",
		"xtightvncviewer", "Gnome-calculator",
	},
	name = { "Event Tester", },
	role = { "AlarmWindow", "pop-up", }
}

-- Build rule table
-----------------------------------------------------------------------------------------------------------------------
function rules:init(args)

	args = args or {}
	self.base_properties.keys = args.hotkeys.keys.client
	self.base_properties.buttons = args.hotkeys.mouse.client


	-- Build rules
	--------------------------------------------------------------------------------
	self.rules = {
		{
			rule       = {},
			properties = args.base_properties or self.base_properties
		},
		{
			rule_any   = args.floating_any or self.floating_any,
			properties = { floating = true }
		},
		{
			rule_any   = { type = { "normal", "dialog" }},
			properties = { titlebars_enabled = true }
		},
    {
      rule = { name = "nvim" },
      properties = {
        switch_to_tags = true
      }, callback = function (c)
        local tag = tags[2]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "discord" },
      properties = {
        switch_to_tags = true
      }, callback = function (c)
        local tag = tags[4]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "Google-chrome" },
      properties = {
        switch_to_tags = true,
      }, callback = function (c)
        local tag = tags[2]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "firefox" },
      properties = {
        switch_to_tags = true,
      }, callback = function (c)
        local tag = tags[2]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "Code" },
      properties = {
        switch_to_tags = true,
      }, callback = function (c)
        local tag = tags[2]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "jetbrains-idea-ce" },
      properties = {
        switch_to_tags = true,
      }, callback = function (c)
        local tag = tags[3]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "DBeaver" },
      properties = {
        switch_to_tags = true,
      }, callback = function (c)
        local tag = tags[3]
        c:move_to_tag(tag)
      end
    },
    {
      rule = { class = "notion-desktop" },
      properties = {
        switch_to_tags = true,
      }, callback = function (c)
        local tag = tags[1]
        c:move_to_tag(tag)
      end
    },
    -- {
    --   rule = { class = "Org.gnome.Nautilus" },
    --   properties = {
    --     switch_to_tags = true
    --   }, callback = function (c)
    --     local tag = tags[1]
    --     c:move_to_tag(tag)
    --   end
    -- },
		{
      rule = { class = "Org.gnome.Nautilus" },
			properties = { floating = true }
		}
  }

	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules
