
local show_help = true

local WIDTH = 100
local HEIGHT = 100
local running = false

local lines = {}
local lines_sz = 0

points = {}
points_count = 0

currentGeneration = 0
mutationTimes = 0
bestValue = -1
best = {}
bestUpdated = false
UNCHANGED_GENS = 0

require("utils")
require("algo")


--[[ UI ]]--

local function update_lines()
    local num = #best
    for i = 1, num do
        local p = best[i] * 2
        local l = i * 2
        lines[l] = points[p]
        lines[l-1] = points[p-1]
    end
    lines_sz = num * 2
end

local function add_points(num)
    running = false

    if points_count + num < 3 then num = 3 end

    for _ = 1, num do
        local x = love.math.random(0, WIDTH)
        local y = love.math.random(0, HEIGHT)
        table.insert(points, x)
        table.insert(points, y)
        table.insert(lines, x)
        table.insert(lines, y)
    end
    points_count = #points / 2
end

local function clear_points()
    running = false
    initData()
    points = {}
    points_count = 0
    lines = {}
    lines_sz = 0
end

local function TSP_start()
    if points_count >= 3 then
        initData()
        GAInitialize()
        running = true
    else
        print("add points!")
    end
end

local function TSP_draw()
    if running then
        GANextGeneration()
    end

    if points_count >= 3 then
        if bestUpdated then
            update_lines()
            bestUpdated = false
        end

        love.graphics.setColor(127,127,127)
        love.graphics.line(lines)
        love.graphics.line(lines[lines_sz-1], lines[lines_sz], lines[1], lines[2])

        love.graphics.setColor(255,255,255)
        love.graphics.points(points)
    end
end


local function TSP_stop()
    if running == false and currentGeneration ~= 0 then
        if points_count ~= #best then
            initData()
            GAInitialize()
        end
        running = true
    else
        running = false
    end
end


--[[ love ]]--

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    love.graphics.setNewFont(12)
    love.graphics.setBackgroundColor(44, 62, 80)
    love.graphics.setPointSize(4)
    love.graphics.setLineWidth(1)
--    love.graphics.setLineStyle("smooth")
    love.graphics.setLineStyle("rough")
    love.graphics.setLineJoin("none")

    WIDTH, HEIGHT = love.graphics.getDimensions()
    WIDTH = WIDTH - 40
    HEIGHT = HEIGHT - 40

    initData()

    points = dofile("data.lua")
    points_count = #points / 2
    lines = table_clone(points)
end

--function love.update(dt)
--end

function love.draw()
    love.graphics.translate(20, 20)
    TSP_draw()
    love.graphics.origin()

    if show_help then
        love.graphics.setColor(64,255,64)
        love.graphics.print("F1 - show/hide help")
        love.graphics.print("1 - clear", 0, 14)
        love.graphics.print("2 - add 1 point", 0, 28)
        love.graphics.print("3 - add 10 points", 0, 42)
        love.graphics.print("4 - start/restart", 0, 56)
        love.graphics.print("5 - pause/continue ", 0, 70)
        love.graphics.print(love.timer.getFPS(), 0, 84)

        local status = string.format(
            "points: %d, generation: %d, mutations: %d, best: %d, idle: %d",
            points_count, currentGeneration, mutationTimes, bestValue, UNCHANGED_GENS
        )
        love.graphics.print(status, 0, HEIGHT+26)
    end
end

function love.keypressed(k)
    if k == 'escape' then love.event.quit()
    elseif k == 'f1' then show_help = not show_help
    elseif k =='1'   then clear_points()
    elseif k =='2'   then add_points(1)
    elseif k =='3'   then add_points(10)
    elseif k =='4'   then TSP_start()
    elseif k =='5'   then TSP_stop()
    end
end
