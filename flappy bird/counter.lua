require 'vector'
Counter = {}
Counter.__index = Counter

function Counter:create(pos)
    local counter = {}
    setmetatable(counter, Counter)
    counter.pos = pos

    counter.counter_imgs = {}

    for i = 0, 9 do
        counter.counter_imgs[i] = love.graphics.newImage('assets/sprites/'..tostring(i)..'.png')
    end
    
    counter.count = 0

    return counter
end

function Counter:increase()
    self.count = self.count+1
end

function Counter:reset()
    self.count = 0
end

function Counter:draw()
    local digits = tostring(self.count)

    local width = 0

    for i = 1, string.len(digits) do
        local digit = string.sub(digits,i,i)
        width = width + self.counter_imgs[tonumber(digit)]:getWidth()
    end

    local cur_width = 0
    for i = 1, string.len(digits) do
        local digit = string.sub(digits,i,i)
        love.graphics.draw(self.counter_imgs[tonumber(digit)], self.pos.x + cur_width,self.pos.y, 0, 1, 1, width/2)

        cur_width = cur_width + self.counter_imgs[tonumber(digit)]:getWidth()
    end
end

