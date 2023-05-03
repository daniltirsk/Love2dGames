require 'vector'
Ball = {}
Ball.__index = Ball

function Ball:create(pos, radius)
    local ball = {}
    setmetatable(ball, Ball)
    ball.start_pos = pos
    ball.pos = pos
    ball.radius = radius
    ball.velocity = Vector:create(0, 0)
    ball.acceleration = Vector:create(0, 0)
    ball.maxSpeed = 30
    return ball
end

function Ball:draw()
    love.graphics.circle("fill", self.pos.x - self.radius/2, self.pos.y - self.radius/2, self.radius)
end

function Ball:update(dt)
    self.velocity = self.velocity + self.acceleration*dt

    self.velocity:limit(self.maxSpeed)
    self.pos = self.pos + self.velocity
    self.acceleration:mul(0)
    self:boundaries(0,height)
end

function Ball:applyForce(force)
    self.acceleration:add(force)
end

function Ball:paddle_hit(paddle)

    if self.pos.x - self.radius > paddle.pos.x + paddle.width or paddle.pos.x > self.pos.x + self.radius/2 then
        return false
    end

    if self.pos.y - self.radius > paddle.pos.y + paddle.height or paddle.pos.y > self.pos.y + self.radius then
        return false
    end 

    return true

end

function Ball:reset()
    ball.pos = ball.start_pos
    ball.velocity = Vector:create(0,0)
end

function Ball:boundaries(y_min,y_max)
   if self.pos.y > y_max - self.radius then
    self.pos.y = y_max - self.radius
    self.velocity.y = -self.velocity.y
   end 
   if self.pos.y < y_min + self.radius then
    self.pos.y = y_min + self.radius
    self.velocity.y = -self.velocity.y
   end 
end