require 'vector'
require 'ball'
require 'paddle'

function love.load()
    gameState = 'start'

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    
    ball = Ball:create(Vector:create(width/2,height/2),10)

    player1 = Paddle:create(Vector:create(50,height/2 - 45),90,20,500)
    player2 = Paddle:create(Vector:create(width - 50 - 10,height/2 - 45),90,20,500)

    smallFont = love.graphics.newFont('resources/AtariClassic-Regular.ttf', 16)
    largeFont = love.graphics.newFont('resources/AtariClassic-Regular.ttf', 32)
    scoreFont = love.graphics.newFont('resources/AtariClassic-Regular.ttf', 64)

    sounds = {
        ['hit'] = love.audio.newSource('resources/pong.wav', 'static'),
        ['victory'] = love.audio.newSource('resources/victory.wav', 'static'),
        ['gameover'] = love.audio.newSource('resources/gameover.wav', 'static')
    }
    

    player1Score = 0
    player2Score = 0

    servingPlayer = 1
    winningPlayer = 0

    speedIncrease = 0.05

    maxBounceAngle = 60 * math.pi / 180
    ballSpeed = 500
    curSpeed = ballSpeed + 0.1 * ballSpeed * (player1Score + player2Score)

end

function love.update(dt)
    if ball:paddle_hit(player1) or ball:paddle_hit(player2) then
        if ball:paddle_hit(player1) then
            ball.pos.x = player1.pos.x + player1.width + ball.radius
            relIntersectY = player1.pos.y + player1.height / 2 - ball.pos.y
            relIntersectY = relIntersectY / (player1.height/2)
            bounceAngle = relIntersectY * maxBounceAngle

            ballVX = curSpeed * math.cos(bounceAngle)
            ballVY = curSpeed * -math.sin(bounceAngle)
            
            ball.velocity = Vector:create(0,0)
            ball:applyForce(Vector:create(ballVX,ballVY))
        end

        if ball:paddle_hit(player2) then
            relIntersectY = player2.pos.y + player2.height / 2 - ball.pos.y
            relIntersectY = relIntersectY / (player2.height/2)
            bounceAngle = relIntersectY * maxBounceAngle

            ballVX = curSpeed * math.cos(bounceAngle)
            ballVY = curSpeed * -math.sin(bounceAngle)
            
            ball.velocity = Vector:create(0,0)
            ball:applyForce(Vector:create(-ballVX,ballVY))
        end

        sounds['hit']:play()
    end

    if ball.pos.x < 0 then
        curSpeed = ballSpeed + speedIncrease * ballSpeed * (player1Score + player2Score)
        ball:reset()
        gameState = 'serve'
        servingPlayer = 1
        player2Score = player2Score + 1

        if player2Score>8 then
            gameState = 'done'
            winningPlayer = 2
            sounds['gameover']:play()
        end
    end

    if ball.pos.x > width then
        curSpeed = ballSpeed + speedIncrease * ballSpeed * (player1Score + player2Score)
        ball:reset()
        gameState = 'serve'
        servingPlayer = 2
        player1Score = player1Score + 1

        if player1Score>8 then
            gameState = 'done'
            winningPlayer = 1
            sounds['victory']:play()
        end
    end

    if love.keyboard.isDown('w') then
        player1:move('up',dt)
    elseif love.keyboard.isDown('s') then
        player1:move('down',dt)
    end

    if ball.velocity.x > 0 and ball.pos.x > width / 3 then
        diff = math.abs((player2.pos.y + player2.height / 2) - ball.pos.y) / (player2.height)
        diff = math.min(diff, 1)
        if ball.pos.y > player2.pos.y + player2.height / 2 then
            player2:move('down',dt*diff)
        elseif ball.pos.y < player2.pos.y + player2.height / 2 then
            player2:move("up",dt*diff)
        end
    end
    
    -- if love.keyboard.isDown('up') then
    --     player2:move('up',dt)
    -- elseif love.keyboard.isDown('down') then
    --     player2:move('down',dt)
    -- end

    ball:update(dt)
end

function love.draw()
    ball:draw()
    player1:draw()
    player2:draw()



    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, width, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 30, width, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, width, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 30, width, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, width, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 50, width, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), width / 2 - 100, height / 5)
    love.graphics.print(tostring(player2Score), width / 2 + 30, height / 5)

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            bounceAngle = math.random(-100,100)/100 * maxBounceAngle

            ballVX = curSpeed * math.cos(bounceAngle)
            ballVY = curSpeed * -math.sin(bounceAngle)

            if servingPlayer == 1 then
                ball:applyForce(Vector:create(ballVX,ballVY))
            else
                ball:applyForce(Vector:create(-ballVX,ballVY))
            end
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'start'
            ball:reset()
            servingPlayer = 1
            player1Score = 0
            player2Score = 0
            curSpeed = ballSpeed
        end
    end
end
