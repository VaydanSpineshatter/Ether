local _, Ether = ...


Ether.AuraTemplate = function(newId)
    local obj = {
        name = "New Aura " .. newId,
        color = {1, 1, 0, 1},
        size = 6,
        position = "TOP",
        offsetX = 0,
        offsetY = 0,
        enabled = true,
        isDebuff = false
    }
    return obj
end


