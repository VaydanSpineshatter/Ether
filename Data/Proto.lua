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

Ether.PredefinedAuras = {
    ["Priest - Group Buffs"] = {
        [21564] = {
            name = "Prayer Fortitude Rank 2",
            color = {0.93, 0.91, 0.67, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
        [27681] = {
            name = "Prayer Spirit Rank 1",
            color = {0.93, 0.91, 0.67, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 6,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
        [27683] = {
            name = "Prayer Shadow",
            color = {0, 0, 0, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 12,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
    },
    ["Priest - Helpful"] = {
        [25217] = {
            name = "Shield 11",
            color = {0.93, 0.91, 0.67, 1},
            size = 6,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
        [25221] = {
            name = "Renew 11",
            color = {0.2, 1, 0.2, 1},
            size = 6,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
        [6346] = {
            name = "Fear Ward",
            color = {1, 0.2, 0.5, 1},
            size = 6,
            position = "BOTTOM",
            offsetX = 0,
            offsetY = 6,
            enabled = true,
            isDebuff = false
        },
    },
    ["Priest - Harmful"] = {
        [6788] = {
            name = "Weakened Soul",
            color = {0.00, 0.80, 1.00, 1},
            size = 6,
            position = "TOP",
            offsetX = 0,
            offsetY = -6,
            enabled = true,
            isDebuff = true
        }
    },
    ["Druid - Group Buffs"] = {
        [9885] = {
            name = "MotW Rank 7",
            color = {1, 0.4, 1, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [21850] = {
            name = "GotW Rank 2",
            color = {0.2, 1, 0.2, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 8,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
    },
    ["Mage - Group Buffs"] = {
        [10157] = {
            name = "Int Rank 5",
            color = {1, 1, 0.4, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
        [23028] = {
            name = "Int Group Rank 1",
            color = {0.6, 0.2, 0.6, 1},
            size = 6,
            position = "BOTTOMRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            isDebuff = false
        },
    }
}

