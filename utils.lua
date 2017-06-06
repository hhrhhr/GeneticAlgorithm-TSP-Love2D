
function calc_distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx*dx + dy*dy)
end

function table_clone(src)
    local tgt = {}
    for i = 1, #src do
        tgt[i] = src[i]
    end
    return tgt
end

function table_shuffle(t)
    local n = #t
    while n > 2 do
        local i = love.math.random(n)
        t[n], t[i] = t[i], t[n]
        n = n - 1
    end
    return t
end

function table_empty(size)
    local t = {}
    for i = 1, size do t[i] = 0 end
    return t
end
