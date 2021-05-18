
local help = {}

local MAX_STARS = 50

function help:load()
	-- Load fonts
	titleFont = love.graphics.newFont("assets/4114blasterv2.ttf", 72)
	headerFont = love.graphics.newFont("assets/4114blasterv2.ttf", 32)
	font = love.graphics.newFont("assets/4114blasterv2.ttf", 24)

	titleY = screenHeight * 0.2
	subtitleY = titleY + titleFont:getHeight()
	
	-- Generate random star locations
	bgStars = { }
	for i = 0, MAX_STARS, 1 do
		table.insert(bgStars, { love.math.random(screenWidth), love.math.random(screenHeight) })
	end
end

function help:update(dt)
	for i, star in ipairs(bgStars) do
		star[1] = (star[1] - 20 * dt) % screenWidth
	end
end

function help:draw()
	-- Draw stars
	love.graphics.points(bgStars)

	-- Draw title
	love.graphics.printf("Spacewar!", titleFont, 0, titleY, screenWidth, "center")

	love.graphics.printf("Controls:", headerFont, screenWidth * 0.125, titleY + (titleFont:getHeight() * 2), screenWidth * 0.75, "left")
	love.graphics.printf("Player 1:\nThrust forward\nTurn ship:\nWarp:\nShoot:\n\nPlayer 2:\nThrust forward\nTurn ship:\nWarp:\nShoot:", font, screenWidth * 0.125, titleY + (titleFont:getHeight() * 2.5), screenWidth * 0.375, "left")
	love.graphics.printf("\nUp\nLeft / Right\nSpace\nDown\n\n\nW\nA / D\nQ\nS", font, screenWidth / 2, titleY + (titleFont:getHeight() * 2.5), screenWidth * 0.375, "right")
end

function help:keypressed(key, unicode)
	if key == "escape" then
		Soupy.enterState("menu")
	end
end

return help