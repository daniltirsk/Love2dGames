require "board"
require "menu"
require "enemyPlayer"

function love.load()
    math.randomseed(os.time())

    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()

    smallFont = love.graphics.newFont('resources/AtariClassic-Regular.ttf', 16)
    largeFont = love.graphics.newFont('resources/AtariClassic-Regular.ttf', 32)
    titleFont = love.graphics.newFont('resources/AtariClassic-Regular.ttf', 52)

    menu = Menu:create()

    gameMode = 1
    gridSize = 3

    enemyPlayer = EnemyPlayer:create(2)

    gameState = "menu"
    winner = 0

    last_turn = 0
end

function love.update(dt)
    last_turn = last_turn + dt
    if gameState == "play" then
        if last_turn < 0.3 then
            return
        else
            last_turn = 0
        end

        if gameMode == 2 then
            if playerTurn == enemyPlayer.turn then
                enemyTurn = enemyPlayer:getBestTurn(board)
                board:takeTurn(enemyTurn[1],enemyTurn[2], playerTurn)

                winner = board:checkWin()

                playerTurn = playerTurn % 2 + 1

                if winner ~= 0 or board.turns == 0 then
                    gameState = "end"
                    return
                end
            end
        elseif gameMode == 3 then
            enemyPlayer.turn = playerTurn

            enemyTurn = enemyPlayer:getBestTurn(board)
            board:takeTurn(enemyTurn[1],enemyTurn[2], playerTurn)

            winner = board:checkWin()

            playerTurn = playerTurn % 2 + 1

            if winner ~= 0 or board.turns == 0 then
                gameState = "end"
                return
            end
        end
    end
end

function love.draw()
    if gameState == "play" then
        love.window.setTitle("Player " .. playerTurn)

        board:draw()
    elseif gameState == "menu" then
        menu:draw()
    elseif gameState == "end" then
        love.graphics.setColor(1, 1, 1, 0.4)
        board:draw()
        love.graphics.setColor( 1, 1, 1, 1)

        love.graphics.setFont(largeFont)

        if winner ~= 0 then
            love.graphics.printf('Player ' .. tostring(winner) .. ' wins!', 0, 10, screen_width, 'center')
        else
            love.graphics.printf('It\'s a draw', 0, 10, screen_width, 'center')
        end

        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 50, screen_width, 'center')
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'end' then
            board:reset()
            playerTurn = defaultPlayerTurn
            gameState = 'menu'
            love.window.setTitle("TICTACTOE")
        end
    end
end


function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        if gameState == "play" then
            if gameMode == 1 or (gameMode == 2 and playerTurn ~= enemyPlayer.turn) then
                if board:touch(x, y, playerTurn) then
                    winner = board:checkWin()
    
                    if winner ~= 0 or board.turns == 0 then
                        gameState = "end"
                        return
                    end
    
                    playerTurn = playerTurn % 2 + 1
                end
            end
        elseif gameState == "menu" then
            menu:touch(x, y)
            if gameState == "play" then
                board = Board:create(gridSize)
                playerTurn = math.random(1,2)
            end
        end
    end
 end
