require 'vector'
Button = {}
Button.__index = Button

function Button:create(pos, width, height, text)
    local button = {}
    setmetatable(button, Button)
    
    button.pos = pos
    button.width = width
    button.height = height
    button.text = text
    button.is_pressed = 0

    return button
end

function Button:draw()
    if self.is_pressed == 0 then
        love.graphics.setColor( 1, 1, 1, 0.5)
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line",self.pos.x - self.width/2,self.pos.y - self.height/2,self.width,self.height,15,15, 3)
    love.graphics.setLineWidth(1)

    love.graphics.setFont(largeFont)
    love.graphics.printf(self.text, self.pos.x-self.width/2, self.pos.y-16, self.width, 'center')

    love.graphics.setColor(1, 1, 1, 1)
end

function Button:touch(x, y)
    if x > self.pos.x - self.width/2 and x < self.pos.x + self.width/2 then
        if y > self.pos.y - self.height/2 and y < self.pos.y + self.height/2 then
            return true
        end
    end

    return false
end