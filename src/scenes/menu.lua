
local menu = {}

local MAX_STARS = 50

function menu:load()
	-- Load fonts
	titleFont = love.graphics.newFont("assets/4114blasterv2.ttf", 72)
	normalFont = love.graphics.newFont("assets/4114blasterv2.ttf", 48)
	subtitleFont = love.graphics.newFont("assets/4114blasterv2.ttf", 16)

	titleY = screenHeight * 0.2
	subtitleY = titleY + titleFont:getHeight()
	footerY = screenHeight - subtitleFont:getHeight() * 2

	selectedOption = 1
	blinkTimer = 0

	-- Generate random star locations
	bgStars = { }
	for i = 0, MAX_STARS, 1 do
		table.insert(bgStars, { love.math.random(screenWidth), love.math.random(screenHeight) })
	end
end

function menu:update(dt)
	-- Move stars
	for i, star in ipairs(bgStars) do
		star[1] = (star[1] - 20 * dt) % screenWidth
	end

	-- Update blinking
	blinkTimer = (blinkTimer + dt) % 1
end

function menu:draw()
	-- Draw stars
	love.graphics.points(bgStars)

	-- Draw title
	love.graphics.printf("Spacewar!", titleFont, 0, titleY, screenWidth, "center")
	love.graphics.printf("by: Lucy van Sandwijk", subtitleFont, 0, subtitleY, screenWidth, "center")

	-- Draw buttons
	local opt1 = ((selectedOption == 1 and blinkTimer < 0.5) and "- Play -" or "Play")
	local opt2 = ((selectedOption == 2 and blinkTimer < 0.5) and "- How to play -" or "How to play")
	
	love.graphics.printf(opt1, normalFont, 0, screenHeight / 2 - normalFont:getHeight() / 2, screenWidth, "center")
	love.graphics.printf(opt2, normalFont, 0, screenHeight / 2 + normalFont:getHeight(), screenWidth, "center")

	-- Footer buttons
	love.graphics.printf("Website", subtitleFont, 0, footerY, screenWidth / 2 - 20, "right")
	love.graphics.printf("GitHub", subtitleFont, screenWidth / 2 + 20, footerY, screenWidth / 2, "left")

	-- Check if y is in the footer
	local x, y = love.mouse.getPosition()
	if y >= footerY and y <= footerY + subtitleFont:getHeight() then
		-- If x matches one of the buttons
		if x >= (screenWidth / 2) + 20 and x <= (screenWidth / 2) + 20 + subtitleFont:getWidth("GitHub") then
			love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
			love.graphics.line((screenWidth / 2) + 20, footerY + subtitleFont:getHeight(), (screenWidth / 2) + 20 + subtitleFont:getWidth("GitHub"), footerY + subtitleFont:getHeight())
		elseif x >= (screenWidth / 2) - 20 - subtitleFont:getWidth("Website") and x <= (screenWidth / 2) - 20 then
			love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
			love.graphics.line((screenWidth / 2) - 20 - subtitleFont:getWidth("Website"), footerY + subtitleFont:getHeight(), (screenWidth / 2) - 20, footerY + subtitleFont:getHeight())
		else
			love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
		end
	else
		love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
	end
end

function menu:keypressed(key, unicode)
	if key == "up" or key == "down" then
		selectedOption = selectedOption == 1 and 2 or 1
	elseif key == "return" then
		Soupy.enterState(({ "game", "help" })[selectedOption])
	end
end

function menu:mousereleased(x, y, button)
	-- Make sure the left mouse button is pressed
	if button == 1 then
		-- Check if y is in the footer
		if y >= footerY and y <= footerY + subtitleFont:getHeight() then
			-- If x matches GitHub button
			if x >= (screenWidth / 2) + 20 and x <= (screenWidth / 2) + 20 + subtitleFont:getWidth("GitHub") then
				love.system.openURL("https://github.com/Loucee/Love2D-Spacewar")
			end

			-- If x matches website button
			if x >= (screenWidth / 2) - 20 - subtitleFont:getWidth("Website") and x <= (screenWidth / 2) - 20 then
				love.system.openURL("https://loucee.dev")
			end
		end
	end
end

return menu
