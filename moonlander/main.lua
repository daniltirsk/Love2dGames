require "vector" 
require "ship"
require "terrain"
require "star"
require "fuelTank"


function generateStars()
    numOfStars = math.random(30,50)
    stars = {}

    for i = 1, numOfStars do
        table.insert(stars,Star:create(Vector:create(math.random(0,width),math.random(0,height))))
    end
end

function generateFuelTank()
    fuelTank = nil
    if math.random() < 1/maxPlatformLength then
        fuelTank = FuelTank:create(Vector:create(math.random(100,width-100),math.random(100,height/3)))
    end
end

function initilizeGame()
    initilizeSpeed = Vector:create(1,0)
    initialPos = Vector:create(width/10,height/4)

    ship = Ship:create(initialPos,initilizeSpeed)
    ship.angle = -1.5

    generateStars()
    
    maxNumOfPlatforms = 6
    minNumOfPlatforms = 4
    
    maxPlatformLength = 9
    minPlatfromLength = 3

    levelCounter = 1

    terrain = Terrain:create()
    terrain:generate(minNumOfPlatforms,maxNumOfPlatforms,minPlatfromLength,maxPlatformLength)

    startingFuel = ship.fuel
    overallScore = 0
    levelScore = 0
    time = 0

    generateFuelTank()
end

function nextLevel()
    ship.pos = initialPos

    initilizeSpeed = initilizeSpeed*1.2

    ship.velocity = initilizeSpeed
    ship.angle = -1.5
    terrain = Terrain:create()

    generateStars()

    maxNumOfPlatforms = math.max(maxNumOfPlatforms - 1,minNumOfPlatforms)
    minNumOfPlatforms = math.max(minNumOfPlatforms - 1,1)
    maxPlatformLength = math.max(maxPlatformLength - 1,3)

    terrain:generate(minNumOfPlatforms,maxNumOfPlatforms,minPlatfromLength,maxPlatformLength)

    levelScore = 0
    startingFuel = ship.fuel

    generateFuelTank()
end

function love.load()
    math.randomseed(os.time())

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    gravity = Vector:create(0,10)

    isCloseUp = false

    -- game states: start, play, win, lose
    smallFont = love.graphics.newFont('assets/AtariClassic-Regular.ttf', 16)
    largeFont = love.graphics.newFont('assets/AtariClassic-Regular.ttf', 32)
    giantFont = love.graphics.newFont('assets/AtariClassic-Regular.ttf', 64)

    gameState = 'start'

    sounds = {
        ['background'] = love.audio.newSource('assets/bgMusic.ogg', 'static'),
        ['engineSound'] = love.audio.newSource('assets/engineSound2.ogg', 'static'),
        ['lowFuel'] = love.audio.newSource('assets/lowFuel.ogg', 'static'),
        ['victory'] = love.audio.newSource('assets/victory.ogg', 'static'),
        ['gameover'] = love.audio.newSource('assets/gameOver.ogg', 'static'),
        ['fuelPickUp'] = love.audio.newSource('assets/fuelPickUp.ogg', 'static')
    }

    sounds['background']:setLooping(true)
    sounds['engineSound']:setLooping(true)
    sounds['lowFuel']:setLooping(true)

    sounds['engineSound']:setVolume(0.4)
    sounds['lowFuel']:setVolume(0.7)

    sounds['background']:play()

    lowFuelLevel = 100
    fuelTank = nil

    initilizeGame()
end

function love.update(dt)
    time = time+dt
    if ship.pos.x < 0 then
        ship.pos.x = width
    elseif ship.pos.x > width then
        ship.pos.x = 0
    end

    if fuelTank ~= nil then
        for i=1,#ship.segments do
            if fuelTank == nil then
                break
            end

            for j=1,#fuelTank.segments do
                if ship.segments[i]:intersects(fuelTank.segments[j]) then
                    sounds['fuelPickUp']:play()
                    ship.fuel = ship.fuel + fuelTank.fuel
                    startingFuel = startingFuel + fuelTank.fuel
                    fuelTank = nil
                    break
                end
            end
        end
    end

    isCloseUp = false
    for i = 1, #terrain.segments do
        local distToSeg = terrain.segments[i]:distToPoint(ship.pos)
        if distToSeg < 80 then
            isCloseUp = true
            if gameState == 'play' then
                for j=1,#ship.segments do
                    if terrain.segments[i]:intersects(ship.segments[j]) then
                        gameState = 'gameover'
                        ship.isDestroyed = true
                        ship:stopEngines()
                        sounds['lowFuel']:stop()

                        if terrain.segments[i].isPlatform then
                            if ship.angle < 10/180*math.pi and ship.angle>-10/180*math.pi  then
                                if math.abs(ship.velocity.x) < 0.2 and math.abs(ship.velocity.y) < 0.2 then
                                    gameState = 'win'
                                    sounds['victory']:play()
                                    ship.angle = 0
                                    ship.pos.y = terrain.segments[i].startPoint[2] - 8
                                    ship.isDestroyed = false
                                    
                                    levelScore = math.floor(1 / (startingFuel - ship.fuel + 1) * 10000 + 1 / (terrain.segments[i].endPoint[1]-terrain.segments[i].startPoint[1]) * 1000)
                                    overallScore = overallScore + levelScore
                                end
                            end
                        end

                        if ship.isDestroyed then
                            sounds['gameover']:play()

                            local oppositeAngle = Vector:create(terrain.segments[i].startPoint[1] -  terrain.segments[i].endPoint[1], terrain.segments[i].startPoint[2] -  terrain.segments[i].endPoint[2])
                            oppositeAngle:norm()
                            oppositeAngle = math.atan2(oppositeAngle.y,oppositeAngle.x) + 0.5*math.pi
        
                            for p = 1, #ship.shipParts do
                                local shipPartAngle = oppositeAngle + math.random(-50,50)/100
                                ship.shipParts[p].velocity = Vector:create(math.cos(shipPartAngle)*2,math.sin(shipPartAngle)*2)
                            end
                        end

                        if gameState ~= 'play' then
                            break
                        end
                    end
                end
            end
        end
    end

    if gameState == 'start' then
        
    elseif gameState == 'play' then
        if ship.fuel < lowFuelLevel then
            sounds['lowFuel']:play()
        end

        if love.keyboard.isDown('right','d') then
            ship.angle = ship.angle + 2*dt
            ship.angle = math.min(ship.angle, 2)
        elseif love.keyboard.isDown('left','a') then
            ship.angle = ship.angle - 2*dt
            ship.angle = math.max(ship.angle, -2)
        end
        if love.keyboard.isDown('up','w') then
            ship:fireEngines(0.5,dt)
        end
    
        ship:applyForce(gravity*dt)
        ship:update(dt)
    elseif gameState == 'win' then
        
    elseif gameState == 'gameover' then
        ship:update(dt)
    end
end

function love.draw()

    for i = 1, #stars do
        stars[i]:draw()
    end

    if isCloseUp then
        love.graphics.translate(ship.pos.x,ship.pos.y)
        love.graphics.scale(4,4)
        love.graphics.translate(-ship.pos.x,-ship.pos.y)
    end

    if fuelTank ~= nil then
        fuelTank:draw()
    end

    terrain:draw()


    if gameState == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Welcome to Lunar Lander!', 0, 30, width, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to begin!', 0, 90, width, 'center')
        love.graphics.printf('To restart the game press R at any time', 0, 110, width, 'center')
    elseif gameState == 'play' then

        ship:draw()

        love.graphics.origin()
        love.graphics.setFont(smallFont)

        love.graphics.printf('SCORE', 30, 60, width)
        love.graphics.printf(string.format("%04d",overallScore), 130, 60, width)
        love.graphics.printf('TIME', 30, 90, width)
        love.graphics.printf(string.format("%d:%02d",time/60,time%60), 130, 90, width)
        love.graphics.printf('FUEL', 30, 120, width)
        love.graphics.printf(string.format("%04d",ship.fuel), 130, 120, width)

        love.graphics.printf('ALTITUDE', width - 400, 60, width)
        love.graphics.printf(string.format("%04d",height - ship.pos.y), width - 100, 60, width)
        love.graphics.printf('HORIZONTAL SPEED', width - 400, 90, width)
        love.graphics.printf(string.format("%.2f",ship.velocity.x), width - 100, 90, width)
        love.graphics.printf('VIRTICAL SPEED', width - 400, 120, width)
        love.graphics.printf(string.format("%.2f",ship.velocity.y), width - 100, 120, width)
    elseif gameState == 'win' then
        ship:draw()
        love.graphics.origin()
        love.graphics.setFont(largeFont)
        love.graphics.printf('CONGRATULATIONS!!!', 0, 100, width, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Your landing was successfull', 0, 150, width, 'center')
        love.graphics.printf('Press Enter to continue', 0, 170, width, 'center')
        love.graphics.setFont(largeFont)
        love.graphics.printf('SCORE +'..tostring(levelScore), 0, 240, width, 'center')
        love.graphics.printf('Your current SCORE = '..tostring(overallScore), 0, 280, width, 'center')
    elseif gameState == 'gameover' then
        ship:draw()
        love.graphics.origin()
        love.graphics.setFont(giantFont)
        love.graphics.printf('GAMEOVER', 0, 100, width, 'center')
        love.graphics.setFont(largeFont)
        love.graphics.printf('Your current SCORE = '..tostring(overallScore), 0, 280, width, 'center')
    end

end

function love.mousepressed(x,y,button, istouch, presses)
    -- if button == 1 then

    -- end
end

function love.keyreleased(key)
    if (key == 'up') or (key=='w') then
        ship:stopEngines()
    end
end


function love.keypressed(key)
    if (key == "return" and gameState == 'start') then
        gameState = "play"

    end

    if (key == "return" and gameState == 'win') then
        gameState = "play"
        nextLevel()
    end

    if (key == "r") then
        gameState = 'start'
        initilizeGame()
    end
end

