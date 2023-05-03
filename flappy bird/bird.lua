require 'vector'
Bird = {}
Bird.__index = Bird

function Bird:create(pos, speed, color)
    local bird = {}
    setmetatable(bird, Bird)
    bird.start_pos = pos
    bird.pos = pos
    bird.velocity = speed
    bird.color = color or 'y'
    bird.acceleration = Vector:create(0,0)

    if bird.color == 'y' then
        bird.flapImgs = {}
        bird.flapImgs[0] = love.graphics.newImage('assets/sprites/yellowbird-upflap.png')
        bird.flapImgs[1] = love.graphics.newImage('assets/sprites/yellowbird-midflap.png')
        bird.flapImgs[2] = love.graphics.newImage('assets/sprites/yellowbird-downflap.png')
        bird.flapImgs[3] = love.graphics.newImage('assets/sprites/yellowbird-midflap.png')
        bird.upImg = love.graphics.newImage('assets/sprites/yellowbird-upflap.png')
        bird.downImg = love.graphics.newImage('assets/sprites/yellowbird-downflap.png')
        bird.midImg = love.graphics.newImage('assets/sprites/yellowbird-midflap.png')
    end

    bird.height = bird.upImg:getHeight()
    bird.width = bird.upImg:getWidth()
    bird.maxSpeed = 10

    bird.flapTimer = 0
    bird.flapPosition = 0

    return bird
end

function Bird:draw()
    love.graphics.draw(self.flapImgs[math.floor(self.flapTimer/0.1)], self.pos.x, self.pos.y, self.velocity.y*math.pi/180 * 10,1,1,self.width/2,self.height/2)
end

function Bird:update(dt)
    self.flapTimer = (self.flapTimer + dt) % 0.4
    
    self.velocity = self.velocity + self.acceleration*dt
    self.velocity:limit(self.maxSpeed)
    self.pos = self.pos + self.velocity
    self.acceleration:mul(0)
end

function Bird:applyForce(force)
    self.acceleration:add(force)
end

function Bird:reset()
    self.pos = self.start_pos
    self.velocity = Vector:create(0,0)
end

function Bird:collides(pipe) 
    if self.pos.x + self.width/2 - 5 >= pipe.pos.x and self.pos.x - self.width/2 + 5 <= pipe.pos.x + pipe.width then
        if self.pos.y + self.height/2 - 5 > pipe.pos.y or self.pos.y - self.height/2 + 5 < pipe.pos.y - pipe.gap then
            return true
        end
    end

    return false
end