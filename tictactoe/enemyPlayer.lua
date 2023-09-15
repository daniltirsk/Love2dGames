require 'vector'
EnemyPlayer = {}
EnemyPlayer.__index = EnemyPlayer

function EnemyPlayer:create(turn)
    --[[
        Enemy AI player class
        Implemented through minimax algorithm with alpha-beta pruning.
        For the 5x5 board the first steps are taken at random and the depth of minimax search is limited, 
        though ideally Monte-Carlo search tree should be used for the 5x5 board.
    ]]

    local enemyPlayer = {}
    setmetatable(enemyPlayer, EnemyPlayer)
    enemyPlayer.turn = turn

    return enemyPlayer
end


function EnemyPlayer:minmax(board, depth, isMax, alpha, beta, max_depth)
    local winner = board:checkWin()

    --[[
        calculating every possible state for a 5x5 board is a computationally expensive task as there are 3^25 possible states
        at the beggining of the game, so we cut off the search tree at max_depth
    ]] 

    if board.width > 3 and depth == max_depth then
        return 0 
    end

    if board.turns == 0 then
        return 0
    end


    if winner ~= 0 then
        if winner == self.turn then
            return 10 - depth
        else
            return -10 + depth
        end
    end

    if isMax then
        local best = -1000
        for i = 1, board.width do
            for j = 1, board.width do
                if board:takeTurn(j, i, self.turn) then
                    best = math.max(best, self:minmax(board, depth+1, not isMax, alpha, beta, max_depth))

                    alpha = math.max(alpha, best)

                    board.table[i][j].player = nil
                    board.turns = board.turns + 1

                    if beta <= alpha then
                        return best
                    end
                end
            end
        end
        return best
    else
        local best = 1000
        for i = 1, board.width do
            for j = 1, board.width do
                if board:takeTurn(j, i, self.turn % 2 + 1) then
                    best = math.min(best, self:minmax(board, depth+1, not isMax, alpha, beta, max_depth))

                    beta = math.min(beta, best)

                    board.table[i][j].player = nil
                    board.turns = board.turns + 1

                    if beta <= alpha then
                        return best
                    end
                end
            end
        end
        return best
    end
end

  

function EnemyPlayer:getBestTurn(board)
    local bestVal = -1000 
    local bestMove = {-1, -1}

    local moveVal = 0
  
    for i = 1, board.width do     
        for j = 1, board.width do
            if board:takeTurn(j, i, self.turn) then
                -- if our board is 5x5 then the first 3 turns are taken at random
                if board.width > 3 then
                    if board.turns > 19 then
                        moveVal = 0
                    elseif board.turns > 13 then
                        moveVal = self:minmax(board, 0, false, -1000, 1000, 6)
                    else
                        moveVal = self:minmax(board, 0, false, -1000, 1000, 8)
                    end
                else
                    moveVal = self:minmax(board, 0, false, -1000, 1000, 10)
                end

                board.table[i][j].player = nil
                board.turns = board.turns + 1

                if moveVal > bestVal then
                    bestVal = moveVal
                    bestMove = {j, i}
                elseif moveVal == bestVal then
                    if math.random()>0.5 then
                        bestMove = {j, i}
                    end
                end
            end
        end
    end
  
    return bestMove
end