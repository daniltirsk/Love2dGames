require "vector"
Segment = {}
Segment.__index = Segment

function Segment:create(startPoint,endPoint,isPlatform)
    local segment = {}
    setmetatable(segment, Segment)
    segment.startPoint = startPoint
    segment.endPoint = endPoint
    segment.isPlatform = isPlatform or false
    segment.isIntersected = false
    return segment
end

function Segment:update(dt)

end

function Segment:distToPoint(point)
    local x = point.x
    local y = point.y

    local A = x - self.startPoint[1]
    local B = y - self.startPoint[2]
    local C = self.endPoint[1] - self.startPoint[1]
    local D = self.endPoint[2] - self.startPoint[2]
    
    local dot = A * C + B * D
    local len_sq = C * C + D * D
    local param = -1
    if (len_sq ~= 0) then
        param = dot / len_sq
    end
    
    local xx, yy
    
    if (param < 0) then
        xx = self.startPoint[1]
        yy = self.startPoint[2]
    elseif (param > 1) then
        xx = self.endPoint[1]
        yy = self.endPoint[2]
    else 
        xx = self.startPoint[1] + param * C
        yy = self.startPoint[2] + param * D
    end
    
    local dx = x - xx
    local dy = y - yy

    return math.sqrt(dx * dx + dy * dy)
end

function Segment:intersects(other)

    local x1 = self.startPoint[1]
    local y1 = self.startPoint[2]
    local x2 = self.endPoint[1]
    local y2 = self.endPoint[2]

    local x3 = other.startPoint[1]
    local y3 = other.startPoint[2]
    local x4 = other.endPoint[1]
    local y4 = other.endPoint[2]


    local uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
    local uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))

    if (uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1) then
        local intersectionX = x1 + (uA * (x2-x1))
        local intersectionY = y1 + (uA * (y2-y1))

        
        self.isIntersected = true

        return true
    end

    return false
end

function Segment:draw()
    if self.isPlatform then 
        local r,g,b,a = love.graphics.getColor()
        love.graphics.setColor(0,0.7,0,1)
        love.graphics.setLineWidth(2)
        love.graphics.line(self.startPoint[1],self.startPoint[2],self.endPoint[1],self.endPoint[2])
        love.graphics.setLineWidth(1)
        love.graphics.setColor(r,g,b,a)
    else
        love.graphics.line(self.startPoint[1],self.startPoint[2],self.endPoint[1],self.endPoint[2])
    end
end