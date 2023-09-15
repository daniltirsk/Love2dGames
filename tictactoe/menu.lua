require 'vector'
require 'button'
Menu = {}
Menu.__index = Menu

function Menu:create()
    local menu = {}
    setmetatable(menu, Menu)
    
    menu.gameModeButtons = {}
    menu.gameModeLabels = {"PvP","PvE","DEMO"}

    for i, label in pairs(menu.gameModeLabels) do
        menu.gameModeButtons[i] = Button:create(Vector:create(screen_width/2, screen_height*0.4 + screen_height/6*i),
            screen_width * 0.8, screen_height / 8, label)
    end

    menu.gridSizeButtons = {}
    menu.gridSizes = {3, 5}
    menu.gridSizeLabels = {"3x3","5x5"}

    for i, label in pairs(menu.gridSizeLabels) do
        menu.gridSizeButtons[i] = Button:create(Vector:create(screen_width/3*i, screen_height/3),
            screen_width * 0.2, screen_height / 6, label)
    end

    menu.gridSizeButtons[1].is_pressed = 1

    return menu
end

function Menu:draw()
    love.graphics.setFont(titleFont)
    love.graphics.printf("TICTACTOE", 0, screen_height/10 - 26, screen_width, 'center')

    for i, button in pairs(self.gameModeButtons) do
        button:draw()
    end

    for i, button in pairs(self.gridSizeButtons) do
        button:draw()
    end
end

function Menu:touch(x, y)
    for i, button in pairs(self.gridSizeButtons) do
        if button:touch(x, y) then
            for j, button in pairs(self.gridSizeButtons) do
                button.is_pressed = 0
            end

            gridSize = self.gridSizes[i]
            button.is_pressed = 1
        end
    end

    for i, button in pairs(self.gameModeButtons) do
        if button:touch(x, y) then
            if button:touch(x, y) then
                for j, button in pairs(self.gameModeButtons) do
                    button.is_pressed = 0
                end

                gameMode = i
                gameState = "play"
            end
        end
    end
end