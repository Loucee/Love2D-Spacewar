
GameSettings = require("gamesettings")
Soupy = require("lib.soupy")

function love.load()
	-- Get screen dimensions
	screenWidth, screenHeight = love.graphics.getDimensions()

	-- Load scenes
	Soupy.addState("scenes.menu", "menu")
	Soupy.addState("scenes.help", "help")
	Soupy.addState("scenes.game", "game")
	
	-- Show menu
	Soupy.enterState("menu")
end

function love.update(dt)
	Soupy.event.update(dt)
end

function love.draw()
	Soupy.event.draw()
end

function love.keypressed(key, unicode)
	Soupy.event.keypressed(key, unicode)
end

function love.mousereleased(x, y, button)
	Soupy.event.mousereleased(x, y, button)
end
