local Ether      = select(2, ...)
local Table      = Ether.Table

local MERGECACHE = {}

function Table:MergeToLeft(ORIG, NEW)
    MERGECACHE[ORIG] = NEW
    local LEFT = ORIG
    while LEFT ~= nil do
        local RIGHT = MERGECACHE[LEFT]
        for NEW_KEY, NEW_VAL in pairs(RIGHT) do
            local OLD_VAL = LEFT[NEW_KEY]
            if OLD_VAL == nil then
                LEFT[NEW_KEY] = NEW_VAL
            else
                local OLD_TYPE = type(OLD_VAL)
                local NEW_TYPE = type(NEW_VAL)
                if OLD_TYPE == "table" and NEW_TYPE == "table" then
                    MERGECACHE[OLD_VAL] = NEW_VAL
                else
                    LEFT[NEW_KEY] = NEW_VAL
                end
            end
        end
        MERGECACHE[LEFT] = nil
        LEFT = next(MERGECACHE)
    end
end

function Table:DeepCopy(orig, seen)
    seen = seen or {}
    if seen[orig] then
        return seen[orig]
    end

    local copy
    if type(orig) == "table" then
        copy = {}
        seen[orig] = copy
        for k, v in pairs(orig) do
            copy[self:DeepCopy(k, seen)] = self:DeepCopy(v, seen)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig), seen))
    else
        copy = orig
    end
    return copy
end

function Table:tContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function Table:SortedPairsByOrder(tbl)
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    table.sort(keys, function(a, b) return (tbl[a].order or 1000) < (tbl[b].order or 1000) end)
    local i = 0
    return function()
        i = i + 1
        local key = keys[i]
        if key then
            return key, tbl[key]
        end
    end
end
