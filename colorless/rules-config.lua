-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful =require("awful")
local beautiful = require("beautiful")
local redflat = require("redflat")
local inspect = require('inspect')

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
      rule = { class = "discord" },
      properties = {
        switch_to_tags = true
      }, callback = function (c)
          if not skipMovingDC then
            print('-------tags----')
            print(inspect(tags, {depth = 4}))
            -- awful.client.movetotag(tags[4], c)
            local tag = tags[4]
            c:move_to_tag(tag)
            -- skipMovingDC = true
          end
        end },
      {
        rule = { class = "Google-chrome" },
        properties = {
          switch_to_tags = true,
        }, callback = function (c)
          if not skipMovingGC then
            local tag = tags[2]
            c:move_to_tag(tag)
            -- c:move_to_screen()
            --skipMovingGC = true
          end
        end },
      {
        rule = { name = "nvim" },
        properties = {
          switch_to_tags = true
        }, callback = function (c)
          if not skipMovingVI then
            local tag = tags[2]
            c:move_to_tag(tag)
            --skipMovingVI = true
          end
        end },
      {
        rule = { class = "Org.gnome.Nautilus" },
        properties = {
          switch_to_tags = true
        }, callback = function (c)
          if not skipMovingNA then
            local tag = tags[3]
            c:move_to_tag(tag)
            --skipMovingNA = true
          end
        end },

	}


	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules
