require "vector"
require "shipPart"
Ship = {}
Ship.__index = Ship

function Ship:create(pos, velocity)
    local ship = {}
    setmetatable(ship, Ship)
    ship.pos = pos
    ship.velocity = velocity
    ship.acceleration = Vector:create(0,0)
    ship.maxSpeed = 10
    ship.angle = 0
    ship.engineTime = 0
    ship.scale = 0.5
    ship.fuel = 1000

    ship.collisionSegmentPoints = {{{-5,8},{-5,-4}},{{5,8},{5,-4}},{{-5,-4},{5,-4}},{{-5,8},{-10,16}},
    {{5,8},{10,16}},{{6,12},{-6,12}},{{12,16},{7,16}},{{-12,16},{-7,16}}}

    -- function to draw and its params, plus cur 
    ship.shipParts = {
        ShipPart:create(love.graphics.ellipse,{'line', 0, 0, 5,5},pos),
        ShipPart:create(love.graphics.rectangle,{'line', -6, 5, 12,3},pos),
        ShipPart:create(love.graphics.line,{-5,8,-10,16},pos),
        ShipPart:create(love.graphics.line,{5,8,10,16},pos),
        ShipPart:create(love.graphics.line,{3,8,5,14},pos),
        ShipPart:create(love.graphics.line,{-3,8,-5,14},pos),
        ShipPart:create(love.graphics.line,{5,12,-5,12},pos),
        ShipPart:create(love.graphics.line,{12,16,7,16},pos),
        ShipPart:create(love.graphics.line,{-12,16,-7,16},pos)
    }

    ship.isDestroyed = false

    ship.segments = {}

    return ship
end

function Ship:draw()
    love.graphics.translate(self.pos.x, self.pos.y)
    love.graphics.scale(self.scale,self.scale)

    if self.isDestroyed == false then
        love.graphics.rotate(self.angle)
    end
    love.graphics.translate(-self.pos.x,-self.pos.y)

    for i =1,#self.shipParts do
        self.shipParts[i]:draw()
    end

    love.graphics.translate(self.pos.x, self.pos.y)
    
    -- fire trail
    local jet_len = math.min(self.engineTime*50,20 + math.random(-3,3))
    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(1,0.3,0,1)
    love.graphics.polygon('line' ,-4 , 12 ,0 ,12 + jet_len, 4, 12)

    -- love.graphics.setColor(1,0,1,1)


    love.graphics.scale(2,2)
    love.graphics.translate(-self.pos.x,-self.pos.y)

    -- for i =1,#self.segments do
    --     self.segments[i]:draw()
    -- end

    love.graphics.setColor(r,g,b,a)
end

function Ship:fireEngines(speedCoeff,dt)
    speedCoeff = speedCoeff or 0.5
    if self.fuel > 0 then
        ship:applyForce(Vector:create(-math.cos(self.angle + math.pi/2)*speedCoeff,-math.sin(self.angle + math.pi/2)*speedCoeff))
        self.engineTime = self.engineTime + dt
        self.fuel = self.fuel - dt*10
        self.fuel = math.max(self.fuel,0)
        sounds['engineSound']:play()
    else
        self:stopEngines()
    end
end

function Ship:stopEngines()
    self.engineTime = 0
    sounds['engineSound']:stop()
end

function Ship:applyForce(force)
    self.acceleration:add(force)
end

function Ship:update(dt)
    if self.isDestroyed then
        for i =1,#self.shipParts do
            self.shipParts[i]:update()
        end
    else 
        self.velocity = self.velocity + self.acceleration*dt
        self.velocity:limit(self.maxSpeed)
        self.pos = self.pos + self.velocity

        for i =1,#self.shipParts do
            self.shipParts[i].pos = self.pos
        end

        self.acceleration:mul(0)

        self.segments = {}
        for i=1,#self.collisionSegmentPoints do
            local startPoint = {self.collisionSegmentPoints[i][1][1]*self.scale+self.pos.x, self.collisionSegmentPoints[i][1][2]*self.scale+self.pos.y}
            local endPoint = {self.collisionSegmentPoints[i][2][1]*self.scale+self.pos.x, self.collisionSegmentPoints[i][2][2]*self.scale+self.pos.y}
            table.insert(self.segments, Segment:create(startPoint,endPoint))
        end
    end
end