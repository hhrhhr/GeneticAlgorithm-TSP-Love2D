local _lmr = love.math.random
local _mf = math.floor
local _mc = math.ceil

local POPULATION_SIZE = 0
local ELITE_RATE
local CROSSOVER_PROBABILITY
local MUTATION_PROBABILITY
--local OX_CROSSOVER_RATE

local dis
local currentBest
local population
local values
local fitnessValues
local roulette

local function countDistances()
    local pc = points_count
    local p = points

    dis = {[pc] = 0}
    for i = 1, pc do
        dis[i] = {[pc] = 0}
        for j = 1, pc do
            if i ~= j then
                local p1, p2 = i*2, j*2
                local d = calc_distance(p[p1-1], p[p1], p[p2-1], p[p2])
                dis[i][j] = _mc(d)
            else
                dis[i][j] = 0
            end
        end
    end
end

local function getCurrentBest()
    local bestP = 1
    local currentBestValue = values[1]

    for i = 2, POPULATION_SIZE do
        if values[i] < currentBestValue then
            currentBestValue = values[i]
            bestP = i
        end
    end
    return { bestPosition = bestP, bestValue = currentBestValue }
end

local function setBestValue()
    for i = 1, POPULATION_SIZE do
        local pop = population[i]
        local p_sz = points_count

        local x = pop[1]
        local y = pop[p_sz]
        local sum = dis[x][y]
        for j = 2, p_sz do
            local x = pop[j]
            local y = pop[j-1]
            sum = sum + dis[x][y]
        end
        values[i] = sum
    end

    currentBest = getCurrentBest()
    if bestValue < 0 or bestValue > currentBest.bestValue then
        best = table_clone(population[currentBest.bestPosition])
        bestValue = currentBest.bestValue
        UNCHANGED_GENS = 0
        bestUpdated = true
    else
        UNCHANGED_GENS = UNCHANGED_GENS + 1
    end
end

local function randomIndivial(n)
    local t = {}
    for i = 1, n do t[i] = i end
    return table_shuffle(t)
end

local function doMutate(seq)
    mutationTimes = mutationTimes + 1

    -- 1 <= m <= max-1, m+1 <= n <= max
    local seq_sz, m, n = #seq
    m = _lmr(seq_sz-1)
    n = _lmr(m+1, seq_sz)

    local j = _mf((n - m + 1) / 2)
    for i = 0, j do
        local k1, k2 = m+i, n-i
        seq[k1], seq[k2] = seq[k2], seq[k1]
    end
    return seq
end

local function pushMutate(seq)
    mutationTimes = mutationTimes + 1

    -- 1 <= m <= max/2, m+1 <=n <= max
    local seq_sz, m, n = #seq
    m = _lmr(_mf(seq_sz / 2))
    n = _lmr(m+1, seq_sz)

    local s = {}
    for i = m, n do table.insert(s, seq[i]) end
    for i = 1, m-1 do table.insert(s, seq[i]) end
    for i = n+1, seq_sz do table.insert(s, seq[i]) end
    return s
end

local function setRoulette()
    for i = 1, POPULATION_SIZE do
        fitnessValues[i] = 1.0 / values[i]
    end
    local sum = 0
    for i = 1, POPULATION_SIZE do
        sum = sum + fitnessValues[i]
    end
    for i = 1, POPULATION_SIZE do
        roulette[i] = fitnessValues[i] / sum
    end
    for i = 2, POPULATION_SIZE do 
        roulette[i] = roulette[i] + roulette[i-1]
    end
end

local function wheelOut(rand)
    for i = 1, POPULATION_SIZE do
        if rand <= roulette[i] then
            return i
        end
    end
end

local function selection()
    local parent = {}
    parent[1] = population[currentBest.bestPosition]
    parent[2] = doMutate(table_clone(best))
    parent[3] = pushMutate(table_clone(best))
    parent[4] = table_clone(best)

    setRoulette()

    for i = 5, POPULATION_SIZE do
        parent[i] = population[wheelOut(_lmr())]
    end
    population = parent
end


local function indexOf(t, v, sz)
    for i = 1, sz do
        if t[i] == v then
            return i
        end
    end
end

local function get_index(t, i, fun, sz)
    if fun > 0 then
        return (i == sz) and t[1] or t[i+1]
    else
        return (i == 1) and t[sz] or t[i-1]
    end
end

local function getChild(fun, x, y)
    local solution = {}
    local px = table_clone(population[x])
    local py = table_clone(population[y])

    local c = px[_lmr(points_count)]
    table.insert(solution, c)

    for sz = points_count, 2, -1 do
        local i = indexOf(px, c, sz)
        local dx = get_index(px, i, fun, sz)
        table.remove(px, i)

        i = indexOf(py, c, sz)
        local dy = get_index(py, i, fun, sz)
        table.remove(py, i)

        local d1 = dis[c][dx]
        local d2 = dis[c][dy]
        c = (d1 < d2) and dx or dy

        table.insert(solution, c)
    end

    return solution
end

local function doCrossover(x, y)
    local child1 = getChild(1, x, y)
    local child2 = getChild(-1, x, y)

    population[x] = child1
    population[y] = child2
end

local function crossover()
    local quene = {}

    for i = 1, POPULATION_SIZE do
        if _lmr() < CROSSOVER_PROBABILITY then
            table.insert(quene, i)
        end
    end

    quene = table_shuffle(quene)
    for i = 1, #quene-1, 2 do
        doCrossover(quene[i], quene[i+1])
    end
end

local function mutation()
    local i = 1
    while i <= POPULATION_SIZE do
        if MUTATION_PROBABILITY > _lmr() then
            if 0.5 < _lmr() then
                population[i] = pushMutate(population[i])
            else
                population[i] = doMutate(population[i])
            end
            i = i - 1
        end
        i = i + 1
    end
end


--[[ public ]]--

function initData()
    running = false
    POPULATION_SIZE = 30
    ELITE_RATE = 0.3
    CROSSOVER_PROBABILITY = 0.9
    MUTATION_PROBABILITY  = 0.01
    UNCHANGED_GENS = 0
    mutationTimes = 0

    bestValue = -1
    best = {}
    currentGeneration = 0
    currentBest = nil

    population = table_empty(POPULATION_SIZE)
    values = table_empty(POPULATION_SIZE)
    fitnessValues = table_empty(POPULATION_SIZE)
    roulette = table_empty(POPULATION_SIZE)
end

function GANextGeneration()
    currentGeneration = currentGeneration + 1
    selection()
    crossover()
    mutation()

    setBestValue()
end

function GAInitialize()
    countDistances()
    for i = 1, POPULATION_SIZE do
        population[i] = randomIndivial(points_count)
    end
    setBestValue()
end