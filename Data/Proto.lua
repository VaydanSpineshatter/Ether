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
        [41635] = {
            name = "POM1",
            color = {0, 0.5, 0.9, 1},
            size = 10,
            position = "RIGHT",
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




--[[
    local AuraInfo = {
        [1] = { Id = 10938, name = "Power Word: Fortitude: Rank 6", color = "|cffCC66FFEther Pink|r" },
        [2] = { Id = 21564, name = "Prayer of Fortitude: Rank 2", color = "|cffCC66FFEther Pink|r" },
        [3] = { Id = 27841, name = "Divine Spirit: Rank 4", color = "|cff00ffffCyan|r" },
        [4] = { Id = 27681, name = "Prayer of Spirit: Rank 1", color = "|cff00ffffCyan|r" },
        [5] = { Id = 10958, name = "Shadow Protection: Rank 3", color = "Black" },
        [6] = { Id = 27683, name = "Prayer of Shadow Protection: Rank 1", color = "Black" },
        [7] = { Id = 10157, name = "Arcane Intellect: Rank 5", color = "|cE600CCFFEther Blue|r" },
        [8] = { Id = 23028, name = "Arcane Brilliance: Rank 1", color = "|cE600CCFFEther Blue|r" },
        [9] = { Id = 9885, name = "Mark of the Wild: Rank 7", color = "|cffffa500Orange|r" },
        [10] = { Id = 21850, name = "Gift of the Wild: Rank 2", color = "|cffffa500Orange|r" },
        [11] = { Id = 25315, name = "Renew: Rank 10", color = "|cff00ff00Green|r" },
        [12] = { Id = 10901, name = "Power Word Shield: Rank 3", color = "White" },
        [13] = { Id = 6788, name = "Weakened Soul", color = "|cffff0000Red|r" },
        [14] = { Id = 6346, name = "Fear Ward", color = "|cff8b4513Saddle Brown|r" },
        [15] = { Id = 0, name = "Dynamic depending on class and skills" },
        [16] = { Id = 0, name = "Magic: Border color: |cff3399FFAzure blue|r" },
        [17] = { Id = 0, name = "Disease: Border color |cff996600Rust brown|r" },
        [18] = { Id = 0, name = "Curse: Border color |cff9900FFViolet|r" },
        [19] = { Id = 0, name = "Poison: Border color |cff009900Grass green|r" }
    }
local GetColor              = {
	["Azure blue"]  = { str = "cff3399FF" },
	["Rust brown"]  = { str = "cff996600" },
	["Violet"]      = { str = "cff9900FF" },
	["Grass green"] = { str = "cff009900" },
	["red"]         = { r = 1.00, g = 0.00, b = 0.00, str = "cffff0000" },
	["green"]       = { r = 0.00, g = 1.00, b = 0.00, str = "cff00ff00" },
	["blue"]        = { r = 0.00, g = 0.00, b = 1.00, str = "cff0000ff" },
	["white"]       = { r = 1.00, g = 1.00, b = 1.00, str = "cffffffff" },
	["black"]       = { r = 0.00, g = 0.00, b = 0.00, str = "cff000000" },
	["lightGray"]   = { r = 0.67, g = 0.67, b = 0.67, str = "cffaaaaaa" },
	["darkGray"]    = { r = 0.40, g = 0.40, b = 0.40, str = "cff666666" },
	["orange"]      = { r = 1.00, g = 0.65, b = 0.00, str = "cffffa500" },
	["magenta"]     = { r = 1.00, g = 0.00, b = 1.00, str = "cffff00ff" },
	["cyan"]        = { r = 0.00, g = 1.00, b = 1.00, str = "cff00ffff" },
	["yellow"]      = { r = 1.00, g = 1.00, b = 0.00, str = "cffffff00" },
	["purple"]      = { r = 0.50, g = 0.00, b = 0.50, str = "cff800080" },
	["saddleBrown"] = { r = 0.55, g = 0.27, b = 0.07, str = "cff8b4513" },
	["darkTur"]     = { r = 0.00, g = 0.81, b = 0.82, str = "cff00ced1" },
	["pink"]        = { r = 1.00, g = 0.41, b = 0.71, str = "cffff69b4" },
	["seaGreen"]    = { r = 0.18, g = 0.54, b = 0.34, str = "cff2e8b57" },
	["gold"]        = { r = 1.00, g = 0.84, b = 0.00, str = "cffffd700" },
	["fireRed"]     = { r = 0.70, g = 0.13, b = 0.13, str = "cffb22222" },
	["EtherPink"]   = { r = 0.80, g = 0.40, b = 1.00, str = "cffCC66FF" },
	["EtherBlue"]   = { r = 0.00, g = 0.80, b = 1.00, str = "cE600CCFF" }
}
]]


