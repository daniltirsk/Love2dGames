require("vector")
require("mover")

require "particle"
require "particleSystem"


function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    num = 10000

    snowPile = {}

    particleSystem = ParticleSystem:create(Vector:create(width/2,height/2),num,Particle)

    time = 0

    texture = love.graphics.newImage("assets/snowflake.png")
    
end

function love.update(dt)
    time = time + dt
    wind = love.math.noise(1,1,time) / 10000

    particleSystem:update(dt)
    particleSystem:applyForce(Vector:create(wind,0))
end

function love.draw()
    particleSystem:draw()

    for k, v in pairs(snowPile) do
        -- if snowPile[k] > 1 then
        --     print(snowPile[k])
        -- end

        for i=1,snowPile[k] do
            love.graphics.draw(texture, 
            k - 0.1 * texture:getWidth()/2, 
            height - 10 - i*0.5 * 0.1 * texture:getHeight()/2,
            0.1,
            0.1)
        end
    end
end
