require "vector"
require "segment"
Terrain = {}
Terrain.__index = Terrain

function Terrain:create(maxHeight)
    local terrain = {}
    setmetatable(terrain, Terrain)
    terrain.maxHeight = maxHeight or height/2
    terrain.points = {}
    terrain.segments = {}
    return terrain
end

function Terrain:update(dt)

end

function Terrain:draw()
    r,g,b,a = love.graphics.getColor()

    love.graphics.setColor(0.4,0.4,0.4,1)

    local triangles = love.math.triangulate(unpack(self.points))
    for i = 1, #triangles do
        love.graphics.polygon('fill',unpack(triangles[i]))
    end

    love.graphics.setColor(r,g,b,a)


    for i = 1, #self.segments do
        self.segments[i]:draw()
    end

end

function Terrain:generate(minNumOfPlatforms,maxNumOfPlatforms,minPlatfromLength,maxPlatformLength)
    local numOfIters = 8
    local minY = 50
    local R = 1

    self.points = {{0,math.random(height - self.maxHeight,height - minY)},{width,math.random(height - self.maxHeight,height - minY)}}

    local verticalDisplacement = (self.points[1][2] + self.points[2][2]) / 2

    for i = 1, numOfIters do
        local midPoints = {}
        -- local verticalDisplacementOptions = {-verticalDisplacement,verticalDisplacement}

        for j = 1, #self.points - 1 do
            local midPoint = {(self.points[j][1] + self.points[j+1][1])/2}
            -- local midPointY = (self.points[j][2] + self.points[j+1][2])/2 + verticalDisplacementOptions[math.random(1,2)]
            local curVerticalDisplacement = math.random(-verticalDisplacement,verticalDisplacement)
            local midPointY = (self.points[j][2] + self.points[j+1][2])/2 + curVerticalDisplacement
            
            -- midPointY = math.min(height - minY,midPointY)
            -- midPointY = math.max(height - self.maxHeight,midPointY)
            if midPointY < height - self.maxHeight or midPointY > height - minY then
                midPointY = (self.points[j][2] + self.points[j+1][2])/2
            end

            midPoint[2] = midPointY

            table.insert(midPoints,midPoint)
        end

        local newPoints = {}

        for j = 1, #self.points + #midPoints do
            if (j % 2) == 1 then
                table.insert(newPoints,self.points[j - (j-1)/2])
            else
                table.insert(newPoints,midPoints[j/2])
            end
        end

        self.points = newPoints

        verticalDisplacement = verticalDisplacement / math.pow(2,R)

    end

    local numOfPlatforms = math.random(minNumOfPlatforms,maxNumOfPlatforms)
    local platformPoints = {}
    local platformStarts = {}

    for i=1, numOfPlatforms do
        local platformLength = math.random(minPlatfromLength,maxPlatformLength)
        local platformStart = math.random(1,#self.points-platformLength-1)
        
        while (platformStarts[self.points[platformStart][1]] or platformPoints[self.points[platformStart][1]] or 
        platformStarts[self.points[platformStart + platformLength][1]] or platformPoints[self.points[platformStart + platformLength][1]]) do
            platformStart = math.random(1,#self.points-platformLength-1)
        end

        platformStarts[self.points[platformStart][1]] = true

        for i = platformStart+1, platformStart + platformLength-1 do
            platformPoints[self.points[i][1]] = true
        end

        self.points[platformStart + platformLength][2] = self.points[platformStart][2]
    end


    newPoints = {}

    local background = {}

    table.insert(background,0)
    table.insert(background,height)

    for i = 1,#self.points do
        if platformPoints[self.points[i][1]] == nil then
            table.insert(newPoints,self.points[i])
            table.insert(background,self.points[i][1])
            table.insert(background,self.points[i][2])
        end
    end

    table.insert(background,width)
    table.insert(background,height)
    

    self.points = newPoints

    for i = 1, #self.points-1 do
        isPlatform = platformStarts[self.points[i][1]]
        table.insert(self.segments, Segment:create(self.points[i],self.points[i+1],isPlatform))
    end

    self.points = background
end