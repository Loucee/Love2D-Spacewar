
local function _explosionColor()
	if GameSettings.rainbowExplosions then
		local colors = {
			{ 255, 0, 0 },
			{ 255, 165, 0 },
			{ 255, 255, 0 },
			{ 0, 128, 0 },
			{ 0, 0, 255 },
			{ 75, 0, 130 },
			{ 238, 130, 238 }
		}
		return colors[love.math.random(#colors)]
	else
		return { 255, 255, 255 }
	end
end

Explosion = { }

function Explosion:new(x, y)
	local s = {}

	s.posX = x
	s.posY = y

	particles = { }
	for i = 0, 200, 1 do
		table.insert(particles, {
			posX = x,
			posY = y,
			angle = math.rad(love.math.random(360)),
			timeLeft = love.math.random(1, 15) / 10,
			speed = love.math.random(30),
			color = _explosionColor()
		})
	end

	s.particles = particles

	function s:update(dt)
		for i = #self.particles, 1, -1 do
			local particle = self.particles[i]

			particle.timeLeft = particle.timeLeft - dt

			if particle.timeLeft <= 0 then
				table.remove(self.particles, i)
			else
				particle.posX = (particle.posX + math.cos(particle.angle) * particle.speed * dt) % screenWidth
				particle.posY = (particle.posY + math.sin(particle.angle) * particle.speed * dt) % screenHeight
			end
		end
	end

	function s:draw()
		local p = { }
		table.foreach(self.particles, function(k, v) 
			table.insert(p, { self.particles[k].posX, self.particles[k].posY, unpack(self.particles[k].color) })
		end)

		love.graphics.points(p)
	end

	return s
end
