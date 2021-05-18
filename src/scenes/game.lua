
require("explosion")
require("player")

local game = {}

local MAX_STARS = 50

function game:load()
	-- Load graphics
	wedge = love.graphics.newImage("assets/wedge.png")
	needle = love.graphics.newImage("assets/needle.png")
	font = love.graphics.newFont("assets/4114blasterv2.ttf", 24)

	self:reset()
end

function game:update(dt)
	Player1:update(dt)
	Player2:update(dt)

	-- Check collision between players and bullets
	self:checkCollisions(Player1, Player2)
end

function game:draw()
	-- Draw stars
	love.graphics.points(bgStars)

	if winner ~= nil then
		local outcome = (Player1.isDead and Player2.isDead) and "It's a tie!" or "Player "..winner.." wins!"
		love.graphics.printf(outcome.."\nPress enter to play again", font, 0, screenHeight / 2 - font:getHeight(), screenWidth, "center")
	else
		-- Draw black hole
		local length = love.math.random(5, 20)
		love.graphics.translate(screenWidth / 2, screenHeight / 2)
		love.graphics.rotate(love.math.random(0, 359))
		love.graphics.translate(-(length / 2), 0)
		love.graphics.line(0, 0, length, 0)
		love.graphics.origin()

		-- Draw players
		Player1:draw()
		Player2:draw()
	end
end

function game:keypressed(key, unicode)
	if winner ~= nil and key == "return" then
		self:reset()
	end
end

function game:reset()
	winner = nil

	-- Create player objects
	Player1 = Player:new(CONTROL_SCHEME_ARROWS, 1, PLAYER_STYLE_WEDGE)
	Player2 = Player:new(CONTROL_SCHEME_WASD, 2, PLAYER_STYLE_NEEDLE)

	-- Generate random star locations
	bgStars = { }
	for i = 0, MAX_STARS, 1 do
		table.insert(bgStars, { love.math.random(screenWidth), love.math.random(screenHeight) })
	end
end

function game:checkCollisions(p1, p2)
	-- Check if either player died and the explosion ended
	if p1.isDead and #p1.explosion.particles == 0 then
		winner = 2
		return
	elseif p2.isDead and #p2.explosion.particles == 0 then
		winner = 1
		return
	end

	p1r = ((p1.image:getWidth() + p1.image:getHeight()) / 2) / 2
	p2r = ((p2.image:getWidth() + p2.image:getHeight()) / 2) / 2

	-- Check if players hit eachother
	if not p1.isDead and not p2.isDead then
		if Soupy.physics.circlesIntersect(p1.posX, p1.posY, p1r, p2.posX, p2.posY, p2r) then
			p1:explode()
			p2:explode()
		end
	end

	-- Check for bullet collisions (player 1)
	if not p1.isDead then
		for bulletIndex = #p2.bullets, 1, -1 do
			local bullet = p2.bullets[bulletIndex]
			if Soupy.physics.circlesIntersect(p1.posX, p1.posY, p1r, bullet.x, bullet.y, 1) then
				table.remove(p2.bullets, bulletIndex)
				p1:explode()
			end
		end
	end

	-- Check for bullet collisions (player 2)
	if not p2.isDead then
		for bulletIndex = #p1.bullets, 1, -1 do
			local bullet = p1.bullets[bulletIndex]
			if Soupy.physics.circlesIntersect(p2.posX, p2.posY, p2r, bullet.x, bullet.y, 1) then
				table.remove(p1.bullets, bulletIndex)
				p2:explode()
			end
		end
	end
end

return game