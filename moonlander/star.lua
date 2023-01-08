require "vector"
Star = {}
Star.__index = Star

function Star:create(pos, scale)
    local star = {}
    setmetatable(star, Star)
    star.scale = scale or 0.25
    star.maxScale = 0.3
    star.minScale = 0
    star.scaleStep = 0.05
    star.pos = pos
    return star
end

function Star:draw()

    if self.scale > self.maxScale or self.scale < self.minScale then
        self.scaleStep = -self.scaleStep
        self.scale = self.scale + self.scaleStep
    end

    if math.random() < 0.1 then
        self.scale = self.scale + self.scaleStep
    end
    
    local curScale = self.scale

    love.graphics.translate(self.pos.x,self.pos.y)
    love.graphics.scale(curScale,curScale)
    love.graphics.setColor(1,1,0,1)
    love.graphics.line(-8,0,8,0)
    love.graphics.line(-5,10,0,-5)
    love.graphics.line(5,10,0,-5)

    love.graphics.line(5,10,-8,0)
    love.graphics.line(-5,10,8,0)
    love.graphics.setColor(1,1,1,1)

    love.graphics.origin()
end

function Star:update()
    
end

