require 'vector'
Cell = {}
Cell.__index = Cell

function Cell:create(pos, width)
    local cell = {}
    setmetatable(cell, Cell)
    cell.pos = pos
    cell.player = nil
    cell.width = width

    cell.shift = math.floor(cell.width/2) - 10

    return cell
end

function Cell:draw()
    if self.player == 1 then
        love.graphics.setLineWidth(4)
        love.graphics.circle('line', self.pos.x, self.pos.y, self.shift)
        love.graphics.setLineWidth(1)
    elseif self.player == 2 then
        love.graphics.setLineWidth(4)
        love.graphics.line(self.pos.x-self.shift,self.pos.y-self.shift,self.pos.x+self.shift,self.pos.y + self.shift)
        love.graphics.line(self.pos.x-self.shift,self.pos.y+self.shift,self.pos.x+self.shift,self.pos.y - self.shift)
        love.graphics.setLineWidth(1)
    end
end