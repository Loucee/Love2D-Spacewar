
CONTROL_SCHEME_ARROWS = 1
CONTROL_SCHEME_WASD = 2
CONTROL_SCHEME_REMOTE = 3

PLAYER_STYLE_WEDGE = 1
PLAYER_STYLE_NEEDLE = 2

Player = { }

function Player:new(controlScheme, playerNr, style)
	controlScheme = controlScheme and controlScheme or 1
	playerNr = playerNr and playerNr or 1
	style = style and style or 1

	local s = {}

	s.bullets = { }

	s.isDead = false
	s.explosion = nil

	s.rotate_speed = 20
	s.speed = 50
	s.shootCooldown = GameSettings.shootCooldown

	s.warpingTimeLeft = 0
	s.timesWarped = 0

	s.controlScheme = controlScheme
	s.playerNr = playerNr
	s.style = style
	s.image = style == PLAYER_STYLE_WEDGE and wedge or needle
	s.timeSinceLastShot = GameSettings.shootCooldown

	s.posX = playerNr == 1 and screenWidth * 0.1 or screenWidth * 0.9
	s.posY = playerNr == 1 and screenHeight * 0.9 or screenHeight * 0.1
	s.velocityX = 0
	s.velocityY = 0
	s.rotation = playerNr == 1 and -45 or 135

	function s:draw()
		if self.warpingTimeLeft <= 0 and not self.isDead then
			-- Draw player
			love.graphics.draw(self.image, math.floor(self.posX), math.floor(self.posY), math.rad(self.rotation), 1, 1, math.floor(self.image:getWidth() / 2), math.floor(self.image:getHeight() / 2))

			-- Draw blasting effect
			if love.keyboard.isDown("up") and self.controlScheme == CONTROL_SCHEME_ARROWS or
			   love.keyboard.isDown("w") and self.controlScheme == CONTROL_SCHEME_WASD then

				local length = love.math.random(5, 15)
				love.graphics.translate(self.posX, self.posY)
				love.graphics.rotate(math.rad(self.rotation + love.math.random(-3, 3)))
				love.graphics.translate(-(self.image:getWidth() / 2), 0)
				love.graphics.line(0, 0, -length, 0)
				love.graphics.origin()
			end

		elseif self.isDead and self.explosion ~= nil then
			self.explosion:draw()
		end

		-- Draw bullets
		for bulletIndex, bullet in ipairs(self.bullets) do
			love.graphics.circle('fill', bullet.x, bullet.y, 1)
		end
	end

	function s:update(dt)
		-- Update shot cooldown
		self.timeSinceLastShot = self.timeSinceLastShot + dt

		if self.warpingTimeLeft <= 0 and not self.isDead then
			-- On rotate left
			if love.keyboard.isDown("left") and self.controlScheme == CONTROL_SCHEME_ARROWS or
			   love.keyboard.isDown("a") and self.controlScheme == CONTROL_SCHEME_WASD then
				self.rotation = self.rotation - self.rotate_speed * dt
			end

			-- On rotate right
			if love.keyboard.isDown("right") and self.controlScheme == CONTROL_SCHEME_ARROWS or
			   love.keyboard.isDown("d") and self.controlScheme == CONTROL_SCHEME_WASD then
				self.rotation = self.rotation + self.rotate_speed * dt
			end

			-- On thrust
			if love.keyboard.isDown("up") and self.controlScheme == CONTROL_SCHEME_ARROWS or
			   love.keyboard.isDown("w") and self.controlScheme == CONTROL_SCHEME_WASD then
				angle_radians = math.rad(self.rotation)
				fx = math.cos(angle_radians) * self.speed * dt
				fy = math.sin(angle_radians) * self.speed * dt
				self.velocityX = self.velocityX + (fx < 1 and fx or 1)
				self.velocityY = self.velocityY + (fy < 1 and fy or 1)
			end

			-- On shoot
			if love.keyboard.isDown("down") and self.controlScheme == CONTROL_SCHEME_ARROWS or
			   love.keyboard.isDown("s") and self.controlScheme == CONTROL_SCHEME_WASD then
				
				-- Check shot cooldown
				if self.timeSinceLastShot >= self.shootCooldown then
					self.timeSinceLastShot = 0
					
					-- Create new bullet
					table.insert(self.bullets, {
						x = self.posX + math.cos(math.rad(self.rotation)) * (self.image:getWidth() / 2),
						y = self.posY + math.sin(math.rad(self.rotation)) * (self.image:getWidth() / 2),
						angle = math.rad(self.rotation),
						timeLeft = 1.25
					})
				end
			end

			-- On warp
			if love.keyboard.isDown("space") and self.controlScheme == CONTROL_SCHEME_ARROWS or
			   love.keyboard.isDown("q") and self.controlScheme == CONTROL_SCHEME_WASD then
				
				-- Random chance of exploding on warp, starts at 1 in 20 and then goes down by 1 for every warp done
				local shouldExplode = (GameSettings.warpFailure and love.math.random(20 - self.timesWarped) == 1 or false)
				if shouldExplode then
					self:explode()
				else
					-- Warping takes anywhere from 1 to 3 seconds
					self.warpingTimeLeft = GameSettings.instantWarp and 0.1 or love.math.random(10, 30) / 10
					self.timesWarped = self.timesWarped + 1

					-- Reset velocity
					self.velocityX = 0
					self.velocityY = 0

					-- Move player to random location and orientation
					self.posX = love.math.random(20, screenWidth - 20)
					self.posY = love.math.random(20, screenHeight - 20)
					self.rotation = love.math.random(360)
				end
			end

			-- Gravitate toward black hole
			local fx, fy = Soupy.physics.gravitateToward(self.posX, self.posY, screenWidth / 2, screenHeight / 2, GameSettings.centerGravity)
			self.velocityX = self.velocityX + (fx < 1 and fx or 1)
			self.velocityY = self.velocityY + (fy < 1 and fy or 1)
			
			-- Limit speed
			local currentSpeed = Soupy.math.hypot(self.velocityX, self.velocityY)
			if (currentSpeed > GameSettings.maxPlayerSpeed) then
				self.velocityX = self.velocityX * (GameSettings.maxPlayerSpeed / currentSpeed)
				self.velocityY = self.velocityY * (GameSettings.maxPlayerSpeed / currentSpeed)
			end

			-- Update player location
			self.posX = (self.posX + self.velocityX * dt) % screenWidth
			self.posY = (self.posY + self.velocityY * dt) % screenHeight

			-- Check for collision with black hole
			local radius = ((self.image:getWidth() + self.image:getHeight()) / 2) / 2
			if Soupy.physics.circlesIntersect(self.posX, self.posY, radius, screenWidth / 2, screenHeight / 2, 1) then
				self:explode()
			end

		elseif self.isDead and self.explosion ~= nil then
			self.explosion:update(dt)
		else
			self.warpingTimeLeft = self.warpingTimeLeft - dt
		end

		-- Update bullets
		for bulletIndex = #self.bullets, 1, -1 do
			local bullet = self.bullets[bulletIndex]

			bullet.timeLeft = bullet.timeLeft - dt

			if bullet.timeLeft <= 0 then
				table.remove(self.bullets, bulletIndex)
			else
				local bulletSpeed = 200
				bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt) % screenWidth
				bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt) % screenHeight
			end
		end
	end

	function s:explode()
		self.isDead = true
		self.explosion = Explosion:new(self.posX, self.posY)
	end

	return s
end
