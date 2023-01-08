require "vector"
ShipPart = {}
ShipPart.__index = ShipPart

function ShipPart:create(drawFunc,params,pos)
    local shipPart = {}
    setmetatable(shipPart, ShipPart)
    shipPart.drawFunc = drawFunc
    shipPart.params = params
    shipPart.pos = pos
    shipPart.velocity = Vector:create(0,0)
    return shipPart
end

function ShipPart:draw()
    love.graphics.translate(self.pos.x,self.pos.y)
    self.drawFunc(unpack(self.params))
    love.graphics.translate(-self.pos.x,-self.pos.y)
end

function ShipPart:update()
    self.pos = self.pos + self.velocity
end

