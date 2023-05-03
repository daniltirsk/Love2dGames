require 'vector'
Paddle = {}
Paddle.__index = Paddle

function Paddle:create(pos, height, width, speed)
    local paddle = {}
    setmetatable(paddle, Paddle)
    paddle.height = height
    paddle.width = width
    paddle.speed = speed
    paddle.pos = pos
    return paddle
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.width, self.height)
end

function Paddle:move(dir, dt)
    if dir == "up" then
        self.pos.y = self.pos.y - self.speed*dt
    elseif dir == "down" then
        self.pos.y = self.pos.y + self.speed*dt
    end
    self:boundaries(0,height)
end

function Paddle:boundaries(y_min,y_max)
   if self.pos.y > y_max - self.height then
    self.pos.y = y_max - self.height
   end 
   if self.pos.y < y_min then
    self.pos.y = y_min
   end 
end