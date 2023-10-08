-----------------------------------------------------------------------------------------------------------------------
--                                              Autostart app list                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local env = require("colorless.env-config") -- load file with environment

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local autostart = {}
env:init()

-- Application list function
--------------------------------------------------------------------------------
function autostart.run()
	-- environment
	--awful.spawn.with_shell("python ~/scripts/env/pa-setup.py")
  --

	---- utils
  --desativado até por um atalho de desativar
  --awful.spawn.with_shell("compton --config ~/.config/compton/compton.conf")
  awful.spawn.with_shell("picom -b --experimental-backends --config ~/.config/picom.conf")
	awful.spawn.with_shell("nm-applet")
	-- awful.spawn.with_shell("mopidy")
  --desnecessário
	--awful.spawn.with_shell("mpDris2")
  --conky
  -- awful.spawn.with_shell("conky -d -c ~/.config/conky/conky.config")
	---- apps
  --ex:
	--awful.spawn.with_shell("clipflap")
	--awful.spawn.with_shell("transmission-gtk -m")
	--awful.spawn.with_shell("pragha --toggle_view")
  --redshift
	awful.spawn.with_shell("redshift -O 3700k")
  -- teclado
	awful.spawn.with_shell("~/.scripts/teclado.sh")
  -- telas
	awful.spawn.with_shell("~/.screenlayout/telas.sh")


  -- programas dia a dia
  -- por mais: notion, youtubemusic, etc
 
  -- chrome
  awful.spawn(env.browser, {
      -- floating  = false,
      -- tag       = mouse.screen.selected_tag
      -- screen = awful.screen[0]
  })

  -- nvim
  -- awful.spawn(env.editor .. ' ~/dev/front', {
  --     -- floating  = false,
  --     -- tag       = mouse.screen.selected_tag
  -- })

  -- discord
  -- awful.spawn('discord')--, {
    -- floating = false
    -- screen = awful.screen[0],
    -- switch_to_tags = true,
  --})

end

-- Read and commads from file and spawn them
--------------------------------------------------------------------------------
function autostart.run_from_file(file_)
	local f = io.open(file_)
	for line in f:lines() do
		if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
	end
	f:close()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
