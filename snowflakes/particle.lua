require "vector"

Particle = {}
Particle.__index = Particle

function Particle:create(position)
    local particle = {}
    setmetatable(particle, Particle)
    particle.position = Vector:create(math.random(-width,width*2),-10)
    -- particle.position = Vector:create(love.math.noise(1,1,1,1)*width,-10)
    particle.acceleration = Vector:create(0, 0.01)

    particle.velocity = Vector:create(math.random(-5, 5)/10, math.random(-1, 1)/10)
    
    -- particle.velocity = Vector:create(love.math.noise( x, y, z, w ), love.math.noise( x, y, z, w ))
    particle.lifespan = 5000
    -- particle.scale = math.random(5,10)/10
    particle.scale = 1
    particle.texture = love.graphics.newImage("assets/snowflake.png")
    particle.width = particle.texture:getWidth()
    particle.height = particle.texture:getHeight()
    particle.isDown = false

    return particle
end

function Particle:update()
    if self.position.y < height - 10 then
        self.velocity:add(self.acceleration)
        self.position:add(self.velocity)
    else
        self.velocity = Vector:create(0,0)
        self.acceleration = Vector:create(0,0)

        if self.isDown == false then
            local increment = 1
            local x = math.floor(self.position.x)

            if snowPile[x] ~= nil then
                snowPile[x] = snowPile[x]+increment
            else
                snowPile[x] = increment
            end
        end

        self.isDown = true
    end

    self.lifespan = self.lifespan - 1
end

function Particle:isDead()
    if self.lifespan < 0 then
        snowPile[math.floor(self.position.x)] = snowPile[math.floor(self.position.x)] - 1
        return true
    end
    return false
end

function Particle:applyForce(force)
    self.acceleration:add(force)
end

function Particle:draw()
    if self.isDown == false then
        r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255,255,255,self.lifespan/100)
        love.graphics.draw(self.texture, 
        self.position.x - 0.1 * self.texture:getWidth()/2, 
        self.position.y - 0.1 * self.texture:getHeight()/2,
        0.1,
        0.1)

        love.graphics.origin()
    end
end