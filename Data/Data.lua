local _, Ether = ...

local Default = {
    [001] = {
        VERSION = 0,
        LAST_VERSION = 0,
        SHOW = true,
        LAST_TAB = "Module",
        SELECTED = 341
    },
    [101] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [201] = {1, 1, 1, 1, 1, 1, 1, 1, 0},
    [301] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [401] = {1, 0, 1},
    [501] = {1, 1, 1, 1, 1, 1, 1, 1, 1},
    [601] = {1, 1, 1, 0, 1, 1, 1},
    [701] = {0, 0, 0, 0, 0, 0},
    [801] = {0},
    [901] = {
        player = true,
        target = true,
        targettarget = true,
        pet = true,
        pettarget = true,
        focus = true,
        party = true,
        raid = true,
    },
    [1001] = {},
    [1002] = {1, 1, 1},
    [1003] = {},
    [2001] = {1, 1, 0, 0, 0},
    [5111] = {
        [331] = {"BOTTOMLEFT", 5133, "BOTTOMLEFT", 350, 250, 180, 100, 1.0, 1.0},
        [332] = {"CENTER", 5133, "CENTER", -250, -250, 120, 50, 1.0, 1.0},
        [333] = {"CENTER", 5133, "CENTER", 250, -250, 120, 50, 1.0, 1.0},
        [334] = {"CENTER", 5133, "CENTER", 0, -300, 120, 50, 1.0, 1.0},
        [335] = {"CENTER", 5133, "CENTER", -400, -100, 120, 50, 1.0, 1.0},
        [336] = {"CENTER", 5133, "CENTER", -300, 100, 120, 50, 1.0, 1.0},
        [337] = {"CENTER", 5133, "CENTER", 0, 100, 120, 50, 1.0, 1.0},
        [338] = {"CENTER", 5133, "CENTER", -100, -80, 1, 1, 1.0, 1.0},
        [339] = {"LEFT", 5133, "LEFT", 10, 0, 1, 1, 1.0, 1.0},
        [340] = {"TOP", 5133, "TOP", 80, -80, 320, 200, 1.0, 1.0},
        [341] = {"TOPLEFT", 5133, "TOPLEFT", 50, -100, 640, 480, 1.0, 1.0}
    }
}
Ether.DataDefault = Default



---@alias Menu number
---| DataInfo 001
---| HIDE 101
---| CREATE 201
---| TOOLTIP 301
---| MODULES 401
---| Indicators Register 501
---| Indicators Status 601
---| Update Text 701
---| Range 801
---| Updated Units 901
---| Aura 1001
---| Aura Enabled on player, target, raid 1002
---| Aura Size 1003
---| Buffs 1004
---| Debuffs 1005
---| Custom 1006
---| Layout 2001
---| UIParent 5133
---| Position 5111

---@alias Anchor number
---| 331 tooltip
---| 332 player
---| 333 target
---| 334 targettarget
---| 335 pet
---| 336 pettarget
---| 337 focus
---| 338 party
---| 339 raid
---| 340 Debug
---| 341 Settings

--- 5133 UIParent


---@alias Layout_2001 number
---| smooth health solo 1
---| smooth health raid  2
---| smooth health solo power solo 3
---| player bar 4
---| target bar 5

---@alias Data_001 number
---| Version 1
---| LastVersion 2
---| ShowSettings 3
---| LastTab 4
---| SelectedFrame 5

---@alias HideBlizzard_101 number
---| Player 1
---| Pet 2
---| Target 3
---| Focus 4
---| Cast Bar 5
---| Party 6
---| Raid 7
---| Manager 8
---| MicroMenu 9
---| MainStatusBarContainer 10
---| MainMenuBar 11
---| BagsBar 12

---@alias Create_201 number
---| Player 1
---| Target 2
---| Target Target 3
---| Pet 4
---| Pet Target 5
---| Focus 6
---| Party 7
---| Raid 8

---@alias Tooltip_301 number
---| AFK 1
---| DND 2
---| PVP 3
---| Resting 4
---| Realm 5
---| Different Realm 6
---| Level 7
---| Class 8
---| Guild 9
---| Role 10
---| Creature 11
---| Race 12
---| Raid Target 13
---| Reaction 14

---@alias Module_401 number
---| Icon 1
---| whisper 2
---| tooltip 3

---@alias I_Register_501 number
---| READY_CHECK READY_CHECK_CONFIRM READY_FINISHED 1
---| UNIT_CONNECTION 2
---| RAID_TARGET_UPDATE 3
---| INCOMING_RESURRECT_CHANGED 4
---| PARTY_LEADER_CHANGED 5
---| PARTY_LOOT_METHOD_CHANGED 6
---| UNIT_FLAGS 7
---| PLAYER_ROLES_ASSIGNED 8
---| PLAYER_FLAGS_CHANGED 9

---@alias I_Enable_601 number
---| Unit Is Charmed 1
---| Unit Is Dead 2
---| Unit Is Ghost 3
---| Group Role 4
---| Main Tank and Main Assist 5
---| AFK String 6
---| DND String 7

---@alias UpdateText_701 number
---| Single-Health 1
---| Single-Power 2
---| Party-Health 3
---| Party-Power 4
---| Raid-Health 5
---| Raid-Power 6

---@alias Range_801 number
---| Enable 1

---@alias Update_901 number
---| Player 331
---| Target 332
---| TargetTarget 333
---| Pet 334
---| PetTarget 335
---| Focus 336
---| Party 337
---| Raid 338
---| MainTank 339

---@alias AuraON number
---| Player 1
---| Target 2
---| Raid 3
---| RaidAuraIcon 4

function Ether.DataEnableAll(t)
    for i = 1, #t do
        t[i] = 1
    end
end

function Ether.DataDisableAll(t)
    for i = 1, #t do
        t[i] = 0
    end
end

function Ether.DataSnapShot(t)
    local copy = {}
    for i = 1, #t do
        copy[i] = t[i]
    end
    return copy
end

function Ether.DataRestore(t, snapshot)
    for i = 1, #snapshot do
        t[i] = snapshot[i]
    end
end

function Ether.DataMigrate(old, newSize, default)
    local t = {}
    for i = 1, newSize do
        t[i] = old[i] ~= nil and old[i] or default
    end
    return t
end

function Ether.MergeToLeft(origTbl, newTbl)
    for k, v in pairs(newTbl) do
        if type(v) == "table" and type(origTbl[k]) == "table" then
            Ether.MergeToLeft(origTbl[k], v)
        else
            origTbl[k] = v
        end
    end
    return origTbl
end

function Ether.DeepCopy(orig, seen)
    seen = seen or {}
    if seen[orig] then
        return seen[orig]
    end

    local copy
    if type(orig) == "table" then
        copy = {}
        seen[orig] = copy
        for k, v in pairs(orig) do
            copy[Ether.DeepCopy(k, seen)] = Ether.DeepCopy(v, seen)
        end
        setmetatable(copy, Ether.DeepCopy(getmetatable(orig), seen))
    else
        copy = orig
    end
    return copy
end

function Ether.tContains(tbl, value)
    if not tbl or type(tbl) ~= "table" then
        return false
    end

    for i = 1, #tbl do
        if tbl[i] == value then
            return true
        end
    end
    return false
end

function Ether.CopyTable(src)
    local copy = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            copy[k] = Ether.CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

Ether.AuraTemplates = {
    ["Priest - Buffs"] = {
        [17] = {
            name = "Power Word: Shield",
            color = {0.93, 0.91, 0.67, 1},
            size = 8,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [139] = {
            name = "Renew",
            color = {0.2, 1, 0.2, 1},
            size = 8,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [10060] = {
            name = "Power Infusion",
            color = {0.5, 0.5, 1, 1},
            size = 8,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [33076] = {
            name = "Prayer of Mending",
            color = {1, 0.8, 0.2, 1},
            size = 8,
            position = "LEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    },
    ["Priest - Debuffs"] = {
        [6788] = {
            name = "Weakened Soul",
            color = {1, 0, 0, 1},
            size = 8,
            position = "BOTTOM",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    },

    ["Paladin - Buffs"] = {
        [1022] = {
            name = "BoP",
            color = {1, 0.8, 0.2, 1},
            size = 8,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [6940] = {
            name = "BoS",
            color = {1, 0.4, 0.4, 1},
            size = 8,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [1044] = {
            name = "BoF",
            color = {0.4, 0.8, 1, 1},
            size = 8,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [53563] = {
            name = "Beacon",
            color = {1, 1, 0.2, 1},
            size = 8,
            position = "LEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    },

    ["Druid - HoTs"] = {
        [774] = {
            name = "Rejuv",
            color = {1, 0.4, 1, 1},
            size = 8,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [8936] = {
            name = "Regrowth",
            color = {0.2, 1, 0.2, 1},
            size = 8,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [48438] = {
            name = "Wild Growth",
            color = {0.4, 1, 0.4, 1},
            size = 8,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [33763] = {
            name = "Lifebloom",
            color = {1, 0.8, 0, 1},
            size = 8,
            position = "LEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    },

    ["Shaman - Buffs"] = {
        [974] = {
            name = "Earth Shield",
            color = {0.6, 0.4, 0.2, 1},
            size = 8,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [61295] = {
            name = "Riptide",
            color = {0.2, 0.8, 1, 1},
            size = 8,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    },

    ["Tank - Cooldowns"] = {
        [871] = {
            name = "Shield Wall",
            color = {0.8, 0.2, 0.2, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [48792] = {
            name = "IBF",
            color = {0.4, 0.8, 1, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [22812] = {
            name = "Barkskin",
            color = {0.6, 0.4, 0.2, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [498] = {
            name = "Divine Prot",
            color = {1, 0.8, 0.2, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    },

    ["Raid - Cooldowns"] = {
        [64843] = {
            name = "Divine Hymn",
            color = {1, 1, 0.4, 1},
            size = 12,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [15286] = {
            name = "VE",
            color = {0.6, 0.2, 0.6, 1},
            size = 10,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        },
        [31821] = {
            name = "Aura Mastery",
            color = {1, 0.8, 0, 1},
            size = 10,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true
        }
    }
}
