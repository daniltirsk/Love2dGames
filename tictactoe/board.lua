require 'vector'
require 'cell'

Board = {}
Board.__index = Board

function Board:create(width)
    --[[
        Game board class
    ]]
    local board = {}
    setmetatable(board, Board)
    board.pos = board
    board.width = width
    board.step = math.floor(screen_width / board.width)
    board.turns = board.width * board.width

    board.table = {}
    for i = 1, board.width do
        board.table[i] = {}
        for j = 1, board.width do
            board.table[i][j] = Cell:create(Vector:create((j-0.5)*board.step,(i-0.5)*board.step), board.step)
        end
    end

    return board
end

function Board:reset()
    self.table = {}
    for i = 1, self.width do
        self.table[i] = {}
        for j = 1, self.width do
            self.table[i][j] = Cell:create(Vector:create((j-0.5)*self.step,(i-0.5)*self.step), self.step)
        end
    end
    self.turns = self.width * self.width
end

function Board:draw()
    for i = 1, self.width - 1 do
        love.graphics.line(i*self.step,0,i*self.step,screen_height)
        love.graphics.line(0,i*self.step,screen_width,i*self.step)
    end

    for i = 1, self.width do
        for j = 1, self.width do
            self.table[i][j]:draw()
        end
    end
end

function Board:checkWin()

    -- if self.turns > self.width*(self.width - 2) + 1 then
    --     return 0 
    -- end 

    -- check horizontal wins
    for i = 1, self.width do
        for j = 2, self.width do
            if self.table[i][j-1].player ~= self.table[i][j].player or self.table[i][j].player == nil then
                break
            elseif j == self.width and self.table[i][j].player ~= nil then
                return self.table[i][j].player
            end
        end
    end

    -- check vertical wins
    for j = 1, self.width do
        for i = 2, self.width do
            if self.table[i-1][j].player ~= self.table[i][j].player or self.table[i][j].player == nil then
                break
            elseif i == self.width and self.table[i][j].player ~= nil then
                return self.table[i][j].player
            end
        end
    end

    -- check first diagonal
    for i = 2, self.width do
        if self.table[i-1][i-1].player ~= self.table[i][i].player or self.table[i][i].player == nil then
            break
        elseif i == self.width and self.table[i][i].player ~= nil then
            return self.table[i][i].player
        end 
    end

    -- check second diagonal
    for i = 2, self.width do
        if self.table[i-1][self.width - i + 2].player ~= self.table[i][self.width - i + 1].player or self.table[i][self.width - i + 1].player == nil then
            break
        elseif i == self.width and self.table[i][self.width - i + 1] ~= nil then
            return self.table[i][self.width - i + 1].player
        end 
    end

    return 0

end

function Board:takeTurn(cellX, cellY, playerTurn)
    if not self.table[cellY][cellX].player then
        self.table[cellY][cellX].player = playerTurn
        self.turns = self.turns - 1

        return true
    end

    return false
end

function Board:touch(x, y, playerTurn)
    local cellX = math.floor(x / self.step) + 1 
    local cellY = math.floor(y / self.step) + 1

    return self:takeTurn(cellX,cellY, playerTurn)
end