Repeller = {}
Repeller.__index = Repeller

function Repeller:create(position)
    local repeller = {}
    setmetatable(repeller, Repeller)
    repeller.position = position
    repeller.r = 40
    repeller.strength = 0.05
    return repeller
end

function Repeller:draw()
    love.graphics.circle("line", self.position.x, self.position.y, self.r)
end

function Repeller:repel(particle)
    local dir = self.position - particle.position
    local d = dir:mag()

    if d <= self.r then
        d = 1
    end
    dir = dir:norm()
    local f = -1 * self.strength / (d * d)
    dir:mul(f)
    return dir
end