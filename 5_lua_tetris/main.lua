local json = require("json")

local rectangle_size = 40
local grid_width = 400
local grid_height = 800
local splitter = 1
local fallTimer = 0
local isRemoveLines = false

shapes = {
    {{1, 1, 1, 1}},
    {{1, 1}, {1, 1}},
    {{1, 1, 0}, {0, 1, 1}},
    {{0, 1, 1}, {1, 1, 0}},
    {{1, 1, 1}},
    {{1, 1}, {0, 1}, {0, 1}},
    {{1, 1}, {1, 0}, {1, 0}},
}

function createBlock()
    shape = shapes[math.random(#shapes)]
    return {shape=shapes[math.random(#shapes)], x=5, y=1}
end

function initGrid()
    grid = {}
    for y = 1, 20 do
        grid[y] = {}
        for x = 1, 10 do
            grid[y][x] = 0
        end
    end
end

function love.load()
    love.window.setMode(grid_width, grid_height)
    initGrid()
    currentBlock = createBlock()
    fallTimer = 0
end

function love.update(dt)
    fallTimer = fallTimer + dt

    if isRemoveLines then
        removeLines()
        isRemoveLines = false
        return
    end

    if fallTimer >= 0.5 then
        currentBlock.y = currentBlock.y + 1
        fallTimer = 0
    end

    if checkCollision() then
        if currentBlock.y == 1 then
            love.load()
        else
            lockPiece()
            removeFilledLines()
            currentBlock = createBlock()
        end
    end
end

function removeLines()
    for _, y in ipairs(linesToRemove) do
        for i = y, 2, -1 do
            for x = 1, 10 do
                grid[i][x] = grid[i - 1][x]
            end
        end
        for x = 1, 10 do
            grid[1][x] = 0
        end
    end
end

function lockPiece()
    for i, row in ipairs(currentBlock.shape) do
        for j, cell in ipairs(row) do
            if cell == 1 then
                grid[currentBlock.y + i - 1][currentBlock.x + j - 1] = 1
            end
        end
    end
end

function rotateBlock()
    local newShape = {}
    for i = 1, #currentBlock.shape[1] do
        newShape[i] = {}
        for j = 1, #currentBlock.shape do
            newShape[i][j] = currentBlock.shape[#currentBlock.shape - j + 1][i]
        end
    end

    if canRotate(newShape) then
        currentBlock.shape = newShape
    end
end

function canRotate(newShape) 
    for i, row in ipairs(newShape) do
        for j, cell in ipairs(row) do
            if cell == 1 then
                if currentBlock.x + j - 1 < 1 or currentBlock.x + j - 1 > 10 or currentBlock.y + i - 1 > 20 or grid[currentBlock.y + i - 1][currentBlock.x + j - 1] == 1 then
                    return false
                end
            end
        end
    end
    return true
end

function removeFilledLines()
    linesToRemove = {}
    for y = 1, 20 do
        local filled = true
        for x = 1, 10 do
            if grid[y][x] == 0 then
                filled = false
            end
        end
        if filled then
            table.insert(linesToRemove, y)
        end
    end

    if #linesToRemove > 0 then
        isRemoveLines = true
    end
end

function checkCollision()
    for i, row in ipairs(currentBlock.shape) do
        for j, cell in ipairs(row) do
            if cell == 1 then
                if currentBlock.y + i - 1 == 20 or grid[currentBlock.y + i][currentBlock.x + j - 1] == 1 then
                    return true
                end
            end
        end
    end
    return false
end

function love.draw()
    for y = 1, #grid do
        for x = 1, #grid[y] do
            if grid[y][x] == 1 then
                local alpha = 1.0

                love.graphics.setColor(1, 1, 1, alpha)
                drawBlock(x, y)
            end
        end
    end

    for i, row in ipairs(currentBlock.shape) do
        for j, cell in ipairs(row) do
            if cell == 1 then
                drawBlock(currentBlock.x + j - 1, currentBlock.y + i - 1)
            end
        end
    end
end

function drawBlock(x, y)
    love.graphics.setColor(0.8, 0.3, 0.7)
    love.graphics.rectangle("fill", (x - 1) * rectangle_size, (y - 1) * rectangle_size, rectangle_size-splitter, rectangle_size - splitter)
end

function love.keypressed(key)
    if key == "c" and love.keyboard.isDown("lctrl") then
        love.event.quit()
    elseif key == "left" then
        if isLeftValid() then
            currentBlock.x = currentBlock.x - 1
        end
    elseif key == "right" then
        if isRightValid() then
            currentBlock.x = currentBlock.x + 1
        end
    elseif key == "down" then
        currentBlock.y = currentBlock.y + 1
    elseif key == "up" then
        rotateBlock()
    end
end

function isLeftValid()
    for i, row in ipairs(currentBlock.shape) do
        for j, cell in ipairs(row) do
            if cell == 1 then
                if currentBlock.x + j - 2 < 1 or grid[currentBlock.y + i - 1][currentBlock.x + j - 2] == 1 then
                    return false
                end
            end
        end
    end
    return true
end

function isRightValid()
    for i, row in ipairs(currentBlock.shape) do
        for j, cell in ipairs(row) do
            if cell == 1 then
                if currentBlock.x + j > 10 or grid[currentBlock.y + i - 1][currentBlock.x + j] == 1 then
                    return false
                end
            end
        end
    end
    return true
end
