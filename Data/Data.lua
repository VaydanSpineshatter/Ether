local _, Ether = ...
local tinsert = table.insert
local tconcat = table.concat
local tsort = table.sort
local pairs, ipairs = pairs, ipairs
local tostring = tostring
local string_format = string.format
local type = type
local math_floor = math.floor
local string_char = string.char

---@alias Menu number
---| Data 001
---| Hide 101
---| Create 201
---| Tooltip 301
---| MODULES 401
---| Indicators Register 501
---| Indicators Status 601
---| Update Text 701
---| Layout 801
---| Updated Units 901
---| Aura 1001
---| Aura Custom 1003

---@alias Anchor number
---| 331 tooltip
---| 332 player
---| 333 target
---| 334 targettarget
---| 335 pet
---| 336 pettarget
---| 337 focus
---| 338 raid
---| 339 Debug
---| 340 Settings

---@alias Data_001 table
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
---| Raid 7

---@alias Tooltip_301 number
---| AFK 1
---| DND 2
---| PVP 3
---| Resting 4
---| Realm 5
---| Level 6
---| Class 7
---| Guild 8
---| Role 9
---| Creature 10
---| Race 11
---| Raid Target 12
---| Reaction 13

---@alias Module_401 number
---| Icon 1
---| Whisper 2
---| Tooltip 3

---@alias IndicatorRegister_501 number
---| READY_CHECK READY_CHECK_CONFIRM READY_FINISHED 1
---| UNIT_CONNECTION 2
---| RAID_TARGET_UPDATE 3
---| INCOMING_RESURRECT_CHANGED 4
---| PARTY_LEADER_CHANGED 5
---| PARTY_LOOT_METHOD_CHANGED 6
---| UNIT_FLAGS 7
---| PLAYER_ROLES_ASSIGNED 8
---| PLAYER_FLAGS_CHANGED 9

---@alias IndicatorStatus_601 number
---| Unit Is Charmed 1
---| Unit Is Dead 2
---| Unit Is Ghost 3
---| Group Role 4
---| Main Tank and Main Assist 5
---| AFK String 6
---| DND String 7

---@alias UpdateText_701 number
---| Solo Health 1
---| Solo Power 2
---| Header Health 5
---| Header Power 6

---@alias Layout_801 number
---| playerCastBar 1
---| targetCastBar 2
---| smooth health Solo 3
---| smooth Power Solo 4
---| smooth health Header 5
---| range checker  6


---@alias Update_901 boolean
---| Player
---| Target
---| TargetTarget
---| Pet
---| PetTarget
---| Focus
---| Header

---@alias AuraEnable_1001 number
---| Player 1
---| Target 2
---| Header 3

---@alias AuraEnable_1101 number
---| arena 1
---| arena 2
---| arena 3

local Default = {
    [001] = {
        VERSION = 0,
        LAST_UPDATE_CHECK = 0,
        SHOW = true,
        LAST_TAB = "Module",
        SELECTED = 331,
    },
    [101] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [201] = {1, 1, 1, 1, 1, 1},
    [301] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [401] = {1, 0, 1},
    [501] = {1, 1, 1, 1, 1, 1, 1, 1, 1},
    [601] = {1, 1, 1, 0, 1, 1, 1},
    [701] = {0, 0, 0, 0},
    [801] = {1, 1, 0, 0, 0, 0},
    [901] = {
        player = true,
        target = true,
        targettarget = true,
        pet = true,
        pettarget = true,
        focus = true,
        raid = true,
    },
    [1001] = {1, 1, 1},
    [1003] = {},
    [1101] = {1, 1, 1},
    [5111] = {
        [331] = {"BOTTOMRIGHT", 5133, "BOTTOMRIGHT", -220, 220, 180, 100, 1.0, 1.0},
        [332] = {"CENTER", 5133, "CENTER", -250, -250, 120, 50, 1.0, 1.0},
        [333] = {"CENTER", 5133, "CENTER", 250, -250, 120, 50, 1.0, 1.0},
        [334] = {"CENTER", 5133, "CENTER", 0, -300, 120, 50, 1.0, 1.0},
        [335] = {"CENTER", 5133, "CENTER", -400, -100, 120, 50, 1.0, 1.0},
        [336] = {"CENTER", 5133, "CENTER", -300, 100, 120, 50, 1.0, 1.0},
        [337] = {"LEFT", 5133, "LEFT", 500, 100, 120, 50, 1.0, 1.0},
        [338] = {"LEFT", 5133, "LEFT", 50, 0, 1, 1, 1.0, 1.0},
        [339] = {"TOP", 5133, "TOP", 80, -80, 320, 200, 1.0, 1.0},
        [340] = {"TOPLEFT", 5133, "TOPLEFT", 50, -100, 640, 480, 1.0, 1.0},
        [341] = {"TOPLEFT", 5133, "TOPLEFT", 50, -100, 640, 480, 1.0, 1.0},
    }
}
Ether.DataDefault = Default

local arrayLengths = {
    [101] = 12, [201] = 6, [301] = 13, [401] = 3,
    [501] = 9, [601] = 7, [701] = 4, [801] = 6,
    [1001] = 3, [1101] = 3
}

local arrayDefaults = {
    [101] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [201] = {1, 1, 1, 1, 1, 1},
    [301] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [401] = {1, 0, 1},
    [501] = {1, 1, 1, 1, 1, 1, 1, 1, 1},
    [601] = {1, 1, 1, 0, 1, 1, 1},
    [701] = {0, 0, 0, 0},
    [801] = {1, 1, 0, 0, 0, 0},
    [1001] = {1, 1, 1},
    [1101] = {1, 1, 1}
}

local units_901 = {
    "player", "target", "targettarget", "pet", "pettarget",
    "focus", "raid"
}

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

function Ether.TableSize(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function Ether:MigrateArraysOnLogin()
    local profile = Ether.GetCurrentProfile()
    local migratedArrays = {}
    local totalAdded = 0

    for arrayID, expectedLength in pairs(arrayLengths) do
        if profile[arrayID] then
            local currentLength = #profile[arrayID]

            if currentLength < expectedLength then
                local added = expectedLength - currentLength
                totalAdded = totalAdded + added

                for i = currentLength + 1, expectedLength do
                    if arrayDefaults[arrayID] and arrayDefaults[arrayID][i] then
                        profile[arrayID][i] = arrayDefaults[arrayID][i]
                    elseif Ether.DataDefault[arrayID] and Ether.DataDefault[arrayID][i] then
                        profile[arrayID][i] = Ether.DataDefault[arrayID][i]
                    else
                        profile[arrayID][i] = 1
                    end
                end

                tinsert(migratedArrays, string_format("|cff00ff00%d|r (+%d)",
                        arrayID, added))

            elseif currentLength > expectedLength then

                Ether.DebugOutput(string_format("Array %d trimmed: %d → %d",
                        arrayID, currentLength, expectedLength))
                for i = expectedLength + 1, currentLength do
                    profile[arrayID][i] = nil
                end
            end
        else

            profile[arrayID] = Ether.CopyTable(arrayDefaults[arrayID] or Ether.DataDefault[arrayID])
            totalAdded = totalAdded + expectedLength
            tinsert(migratedArrays, string_format("|cff00ff00%d|r (new)", arrayID))
        end
    end

    if #migratedArrays > 0 then
        Ether.DebugOutput(string_format("|cff00ccffEther|r: Database migration complete"))
        Ether.DebugOutput(string_format("|cff00ccffEther|r: Added %d entries across %d arrays",
                totalAdded, #migratedArrays))
        Ether.DebugOutput(string_format("|cff00ccffEther|r: Updated arrays: %s",
                tconcat(migratedArrays, ", ")))
    end
end

function Ether.StringToTbl(str)
    if not str or str == "" then
        return false, "Empty string"
    end
    if not str:match("^%s*return") then
        str = "return " .. str
    end
    local env = {
        string = {
            sub = string.sub,
            find = string.find,
            match = string.match,
            gsub = string.gsub,
            byte = string.byte,
            char = string.char,
            len = string.len,
            lower = string.lower,
            upper = string.upper,
            rep = string.rep,
            format = string.format,
        },
        table = {
            insert = table.insert,
            remove = table.remove,
            concat = table.concat,
            sort = table.sort,
        },
        math = {
            floor = math.floor,
            ceil = math.ceil,
            abs = math.abs,
            max = math.max,
            min = math.min,
            random = math.random,
            sqrt = math.sqrt,
        },
        tonumber = tonumber,
        tostring = tostring,
        type = type,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        select = select,
        unpack = unpack,
        error = error,
        pcall = pcall,
        assert = assert,
        _VERSION = _VERSION,
    }
    setmetatable(env, {
        __index = function(t, k)
            error("Access to forbidden global: " .. tostring(k), 2)
        end,
        __newindex = function(t, k, v)
            error("Modification of environment forbidden", 2)
        end
    })
    local func, err = loadstring(str)
    if not func then
        return false, "Compile error: " .. err
    end

    setfenv(func, env)

    local success, result = pcall(func)
    if not success then
        return false, "Execution error: " .. result
    end

    return true, result
end

local function isArray(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local count = 0
    local maxIndex = 0

    for k, v in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k ~= math_floor(k) then
            return false
        end
        count = count + 1
        if k > maxIndex then
            maxIndex = k
        end
    end

    if count == 0 or count ~= maxIndex then
        return false
    end

    return true
end

local function serializeValue(value, indent)
    if type(value) == "table" then
        if isArray(value) then
            return Ether.SerializeArray(value)
        else
            return Ether.SerializeTbl(value, indent)
        end
    elseif type(value) == "string" then
        return string_format("%q", value)
    elseif type(value) == "number" then
        return tostring(value)
    elseif type(value) == "boolean" then
        return value and "true" or "false"
    elseif value == nil then
        return "nil"
    else
        return string_format("%q", tostring(value))
    end
end

function Ether.SerializeArray(tbl)
    local items = {}
    for i = 1, #tbl do
        local value = tbl[i]
        if type(value) == "table" then
            if isArray(value) then
                tinsert(items, Ether.SerializeArray(value))
            else
                tinsert(items, Ether.SerializeTbl(value, 0))
            end
        elseif type(value) == "string" then
            tinsert(items, string_format("%q", value))
        elseif type(value) == "number" then
            tinsert(items, tostring(value))
        elseif type(value) == "boolean" then
            tinsert(items, value and "true" or "false")
        elseif value == nil then
            tinsert(items, "nil")
        else
            tinsert(items, string_format("%q", tostring(value)))
        end
    end
    return "{" .. tconcat(items, ", ") .. "}"
end

function Ether.SerializeTbl(tbl, indent)
    indent = indent or 0

    local isEmpty = true
    for _ in pairs(tbl) do
        isEmpty = false
        break
    end
    if isEmpty then
        return "{}"
    end

    if isArray(tbl) then
        return Ether.SerializeArray(tbl)
    end

    local result = {}
    tinsert(result, "{")

    local keys = {}
    for k in pairs(tbl) do
        tinsert(keys, k)
    end
    tsort(keys, function(a, b)

        if type(a) == type(b) then
            return a < b
        else
            return type(a) == "number"
        end
    end)

    for i, key in ipairs(keys) do
        local value = tbl[key]
        local comma = i < #keys and "," or ""

        local keyStr
        if type(key) == "number" then
            keyStr = "[" .. key .. "]"
        elseif type(key) == "string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
            keyStr = key
        else
            keyStr = "[" .. string_format("%q", tostring(key)) .. "]"
        end

        local valueStr = serializeValue(value, indent + 2)

        if indent > 0 and type(value) == "table" and not isArray(value) and Ether.TableSize(value) > 2 then
            tinsert(result, "\n" .. string.rep(" ", indent) .. keyStr .. " = " .. valueStr .. comma)
        else
            tinsert(result, keyStr .. " = " .. valueStr .. comma .. " ")
        end
    end

    tinsert(result, "}")
    return tconcat(result)
end

function Ether.TblToString(tbl)
    return "return " .. Ether.SerializeTbl(tbl)
end

local PADDING_CHAR = '='
local BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function Ether.Base64Encode(data)
    local result = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i + 2)

        local index1 = math_floor(a / 4) + 1
        tinsert(result, BASE64_CHARS:sub(index1, index1))

        if b then
            local index2 = ((a % 4) * 16) + math_floor(b / 16) + 1
            tinsert(result, BASE64_CHARS:sub(index2, index2))

            if c then
                local index3 = ((b % 16) * 4) + math_floor(c / 64) + 1
                tinsert(result, BASE64_CHARS:sub(index3, index3))

                local index4 = (c % 64) + 1
                tinsert(result, BASE64_CHARS:sub(index4, index4))
            else
                local index3 = ((b % 16) * 4) + 1
                tinsert(result, BASE64_CHARS:sub(index3, index3))
                tinsert(result, '=')
            end
        else
            local index2 = ((a % 4) * 16) + 1
            tinsert(result, BASE64_CHARS:sub(index2, index2))
            tinsert(result, '==')
        end
    end

    return tconcat(result)
end

function Ether.Base64Decode(data)
    data = data:gsub('[^' .. BASE64_CHARS .. PADDING_CHAR .. ']', '')
    local result = {}
    for i = 1, #data, 4 do
        local chunk = data:sub(i, i + 3)
        if #chunk < 4 then
            break
        end
        local values = {}
        for j = 1, 4 do
            local char = chunk:sub(j, j)
            if char == '=' then
                values[j] = 0
            else
                values[j] = BASE64_CHARS:find(char, 1, true) - 1
            end
        end
        local byte1 = (values[1] * 4) + math_floor(values[2] / 16)
        tinsert(result, string_char(byte1))

        if values[3] ~= 0 or chunk:sub(3, 3) ~= '=' then
            local byte2 = ((values[2] % 16) * 16) + math_floor(values[3] / 4)
            tinsert(result, string_char(byte2))
        end
        if values[4] ~= 0 or chunk:sub(4, 4) ~= '=' then
            local byte3 = ((values[3] % 4) * 64) + values[4]
            tinsert(result, string_char(byte3))
        end
    end
    return tconcat(result)
end



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
    ["EtherPink"]   = { r = 0.80, g = 0.40, b = 1.00, str = "cffCC66FF" },
	["EtherBlue"]   = { r = 0.00, g = 0.80, b = 1.00, str = "cE600CCFF" }
]]

Ether.AuraTemplates = {
    ["Priest - Buffs"] = {
        [21564] = {
            name = "Prayer of Fortitude: Rank 2",
            color = {0.93, 0.91, 0.67, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [27681] = {
            name = "Prayer of Spirit: Rank 1",
            color = {0.93, 0.91, 0.67, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 6,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [27683] = {
            name = "Prayer of Shadow Protection",
            color = {0, 0, 0, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 12,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [10901] = {
            name = "Power Word: Shield",
            color = {0.93, 0.91, 0.67, 1},
            size = 6,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [25315] = {
            name = "Renew",
            color = {0.2, 1, 0.2, 1},
            size = 6,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [6346] = {
            name = "Fear Ward",
            color = {1, 0.2, 0.5, 1},
            size = 6,
            position = "TOP",
            offsetX = 0,
            offsetY = -6,
            enabled = true,
            debuff = false
        }
    },
    ["Paladin - Buffs"] = {
        [1022] = {
            name = "BoP",
            color = {1, 0.8, 0.2, 1},
            size = 6,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [6940] = {
            name = "BoS",
            color = {1, 0.4, 0.4, 1},
            size = 6,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [1044] = {
            name = "BoF",
            color = {0.4, 0.8, 1, 1},
            size = 6,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [53563] = {
            name = "Beacon",
            color = {1, 1, 0.2, 1},
            size = 6,
            position = "LEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        }
    },
    ["Druid - Buffs"] = {
        [9885] = {
            name = "Mark of the Wild: Rank 7",
            color = {1, 0.4, 1, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [21850] = {
            name = "Gift of the Wild: Rank 2",
            color = {0.2, 1, 0.2, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 8,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
    },
    ["Druid - HoTs"] = {
        [25299] = {
            name = "Rejuvenation",
            color = {1, 0.4, 1, 1},
            size = 6,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [9858] = {
            name = "Regrowth",
            color = {0.2, 1, 0.2, 1},
            size = 6,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [34161] = {
            name = "Wild Growth",
            color = {0.4, 1, 0.4, 1},
            size = 6,
            position = "TOPRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [33763] = {
            name = "Lifebloom",
            color = {1, 0.8, 0, 1},
            size = 6,
            position = "LEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        }
    },
    ["Shaman - Buffs"] = {
        [32593] = {
            name = "Earth Shield",
            color = {0.6, 0.4, 0.2, 1},
            size = 8,
            position = "TOPLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [61295] = {
            name = "Riptide",
            color = {0.2, 0.8, 1, 1},
            size = 8,
            position = "TOP",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
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
            enabled = true,
            debuff = false
        },
        [48792] = {
            name = "IBF",
            color = {0.4, 0.8, 1, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [22812] = {
            name = "Barkskin",
            color = {0.6, 0.4, 0.2, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [13007] = {
            name = "Divine Prot",
            color = {1, 0.8, 0.2, 1},
            size = 10,
            position = "CENTER",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        }
    },
    ["Mage - Cooldowns"] = {
        [10157] = {
            name = "Arcane Intellect: Rank 5",
            color = {1, 1, 0.4, 1},
            size = 6,
            position = "BOTTOMLEFT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
        [23028] = {
            name = "Arcane Brilliance: Rank 1",
            color = {0.6, 0.2, 0.6, 1},
            size = 6,
            position = "BOTTOMRIGHT",
            offsetX = 0,
            offsetY = 0,
            enabled = true,
            debuff = false
        },
    }
}
