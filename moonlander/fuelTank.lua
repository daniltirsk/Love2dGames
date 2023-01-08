require "vector"
require "segment"

FuelTank = {}
FuelTank.__index = FuelTank

function FuelTank:create(pos, fuel)
    local fuelTank = {}
    setmetatable(fuelTank, FuelTank)
    fuelTank.pos = pos
    fuelTank.fuel = fuel or 100

    fuelTank.segments = {
        Segment:create({pos.x-5,pos.y+0},{pos.x+5,pos.y+0}),
        Segment:create({pos.x+0,pos.y-10},{pos.x+0,pos.y+10}),
        Segment:create({pos.x-5,pos.y+0},{pos.x+0,pos.y+10}),
        Segment:create({pos.x+5,pos.y+0},{pos.x+0,pos.y+10}),
        Segment:create({pos.x-5,pos.y+0},{pos.x+0,pos.y-10}),
        Segment:create({pos.x+5,pos.y+0},{pos.x+0,pos.y-10})
    }

    return fuelTank
end

function FuelTank:draw()
    r,g,b,a = love.graphics.getColor()

    love.graphics.setColor(0,0.5,1,1)

    for i =1, #self.segments do
        self.segments[i]:draw()
    end

    love.graphics.setColor(r,g,b,a)
end

function FuelTank:update()
    
end

