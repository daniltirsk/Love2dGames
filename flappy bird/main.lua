require 'vector'
require 'bird'
require 'pipe'
require 'counter'

function love.load()
    gameState = 'start'

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    sounds = {
        ['die'] = love.audio.newSource('assets/audio/die.wav', 'static'),
        ['hit'] = love.audio.newSource('assets/audio/hit.wav', 'static'),
        ['point'] = love.audio.newSource('assets/audio/point.wav', 'static'),
        ['swoosh'] = love.audio.newSource('assets/audio/swoosh.wav', 'static'),
        ['wing'] = love.audio.newSource('assets/audio/wing.wav', 'static')
    }
    
    background = love.graphics.newImage('assets/sprites/background-day.png')
    ground = love.graphics.newImage('assets/sprites/base.png')
    startScreen = love.graphics.newImage('assets/sprites/message.png')
    gameOverScreen = love.graphics.newImage('assets/sprites/gameover.png')

    groundScroll = 0
    groundScrollSpeed = 100

    bird = Bird:create(Vector:create(width/4,height /2),Vector:create(0,0))
    gravity = Vector:create(0,10)

    pipes = {}
    pipeSpawnTimer = 0
    pipeUpperBound = height/3
    pipeLowerBound = height*2/3

    counter = Counter:create(Vector:create(width/2,height/6))

    counter.count = 0
end

function love.update(dt)
    if gameState ~= "done" then 
        if gameState ~= 'start' then
            bird:applyForce(gravity)
        end

        if gameState ~= 'hit' then 
            groundScroll = (groundScroll + groundScrollSpeed*dt)%(ground:getWidth() - background:getWidth())
        end
        bird:update(dt)
    end

    if gameState == 'play' then 
        pipeSpawnTimer = pipeSpawnTimer + dt

        for i,pipe in pairs(pipes) do
            pipe:update(dt)
            if pipe.pos.x < -pipe.width then
                table.remove(pipes,i)
            end

            if bird:collides(pipe) then
                gameState = 'hit'
                bird.velocity = Vector:create(0,0)
                sounds['hit']:play()
            end
        end

        if #pipes > 0 then 
            if bird.pos.x - bird.width > pipes[1].pos.x and not pipes[1].scored then
                counter:increase()
                sounds['point']:play()
                pipes[1].scored = true
            end

        end
    end

    if bird.pos.y - bird.height/2 > height - ground:getHeight()/2 - bird.height and gameState ~= 'done' then
        sounds['swoosh']:play()
        sounds['die']:play()
        gameState = 'done'
    end

    if pipeSpawnTimer > 1.5 then

        chance = math.min(counter.count / 100, 1)

        isMoving = math.random(1,100)/100 <= chance


        table.insert(pipes, Pipe:create(Vector:create(width*1.5,math.random(pipeUpperBound, pipeLowerBound)),isMoving))
        pipeSpawnTimer = 0
    end
end

function love.draw()
    love.graphics.draw(background, 0, -background:getHeight()/8)

    for i,pipe in pairs(pipes) do
        pipe:draw()
    end

    bird:draw()

    counter:draw()

    love.graphics.draw(ground,-groundScroll,height - ground:getHeight()/2)

    if gameState == 'start' then
        love.graphics.draw(startScreen, width/2 - startScreen:getWidth()/2, 10)
    end

    if gameState == 'done' then
        love.graphics.draw(gameOverScreen, width/2 - gameOverScreen:getWidth()/2, height/2 - gameOverScreen:getHeight())
    end

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
            bird.velocity = Vector:create(0,0)
            bird:applyForce(Vector:create(0,-250))
            sounds["wing"]:play()
        elseif gameState == 'play' then
            bird.velocity = Vector:create(0,0)
            bird:applyForce(Vector:create(0,-250))
            sounds["wing"]:play()
        elseif gameState == 'done' then
            bird:reset()
            pipes = {}
            counter:reset()
            gameState = 'start'
        end
    end
end


function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        love.keypressed('return')
    end
 end
