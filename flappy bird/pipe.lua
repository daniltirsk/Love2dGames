require 'vector'
Pipe = {}
Pipe.__index = Pipe

function Pipe:create(pos, isMoving, color)
    local pipe = {}
    setmetatable(pipe, Pipe)
    pipe.pos = pos

    pipe.color = color or 'g'

    if pipe.color == 'g' then
        pipe.image = love.graphics.newImage('assets/sprites/pipe-green.png')
    end

    pipe.height = pipe.image:getHeight()
    pipe.width = pipe.image:getWidth()
    pipe.scored = false
    pipe.gap = 100
    pipe.isMoving = isMoving or false
    pipe.movingSpeed = 10

    return pipe
end

function Pipe:draw()
    love.graphics.draw(self.image, self.pos.x, self.pos.y)
    love.graphics.draw(self.image, self.pos.x, self.pos.y - self.gap, 0, 1, -1)
end

function Pipe:update(dt)
    self.pos.x = self.pos.x - groundScrollSpeed*dt
    if self.isMoving then
        if self.pos.y < pipeUpperBound or self.pos.y > pipeLowerBound  then
            self.movingSpeed = -self.movingSpeed
        end
        self.pos.y = self.pos.y + self.movingSpeed*dt
    end
end
