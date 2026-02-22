local _, Ether = ...
local tinsert, tsort, tconcat = table.insert, table.sort, table.concat
local pairs, ipairs = pairs, ipairs
local tostring = tostring
local string_format = string.format
local type = type
local math_floor = math.floor
local string_char = string.char
local string_rep = string.rep
local Default = {
    ["VERSION"] = 0,
    [111] = {
        LAST_CHECK = 0,
        SHOW = false,
        LAST_TAB = "Module",
        SELECTED = 331,
    },
    [101] = {1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0},
    [201] = {1, 1, 1, 1, 1, 1},
    [301] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    [401] = {1, 1, 1, 1, 0, 1},
    [501] = {1, 1, 1, 1, 1, 1, 1, 1, 1},
    [701] = {0, 0, 0, 0},
    [801] = {0, 0, 0},
    [811] = {
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["background"] = "",
        ["border"] = "Interface\\DialogFrame\\UI-DialogBox-Border",
        ["bar"] = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
    },
    [1001] = {1, 1, 1},
    [1002] = {
        [1] = {12, "TOP", 0, 0},
        [2] = {24, "TOPLEFT", 0, 0},
        [3] = {12, "BOTTOM", 0, 0},
        [4] = {17, "CENTER", 0, 6},
        [5] = {12, "RIGHT", 0, 0},
        [6] = {12, "BOTTOMRIGHT", 0, 12},
        [7] = {12, "TOP", 0, 0},
        [8] = {12, "LEFT", 0, 0},
        [9] = {34, "TOPLEFT", 0, 0},
    },
    [1003] = {},
    [1101] = {1, 1, 1},
    [1201] = {1, 1},
    [1301] = {
        [341] = {16, 12, 12},
        [342] = {16, 12, 12}
    },
    [1401] = {
        [1] = {"CENTER", "UIParent", "CENTER", 0, 90},
        [2] = {"CENTER", "UIParent", "CENTER", 0, 0},
        [3] = {"CENTER", "UIParent", "CENTER", 0, -90},
    },
    [1501] = {1, 1, 1, 1, 1},
    [5111] = {
        [331] = {"RIGHT", "UIParent", "RIGHT", -340, -340, 180, 200, 1.0, 1.0},
        [332] = {"CENTER", "UIParent", "CENTER", -250, -200, 120, 50, 1.0, 1.0},
        [333] = {"CENTER", "UIParent", "CENTER", 250, -200, 120, 50, 1.0, 1.0},
        [334] = {"CENTER", "UIParent", "CENTER", 0, -220, 120, 50, 1.0, 1.0},
        [335] = {"CENTER", "UIParent", "CENTER", -350, -100, 120, 50, 1.0, 1.0},
        [336] = {"CENTER", "UIParent", "CENTER", -270, -20, 120, 50, 1.0, 1.0},
        [337] = {"LEFT", "UIParent", "LEFT", 500, 100, 120, 50, 1.0, 1.0},
        [338] = {"LEFT", "UIParent", "LEFT", 100, -200, 1, 1, 1.0, 1.0},
        [339] = {"TOP", "UIParent", "TOP", 80, -80, 320, 200, 1.0, 1.0},
        [340] = {"TOPLEFT", "UIParent", "TOPLEFT", 50, -100, 640, 480, 1.0, 1.0},
        [341] = {"CENTER", "UIParent", "CENTER", 0, -180, 340, 15, 1.0, 1.0},
        [342] = {"CENTER", "UIParent", "CENTER", 360, -270, 240, 15, 1.0, 1.0, }
    }
}

Ether.DataDefault = Default

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
---| 341 PlayerCastBar
---| 342 TargetCastBar

---@alias Data_111 table
---| LastVersion 1
---| ShowSettings 2
---| LastTab 3
---| SelectedFrame 4

---@alias Blizzard_101 number
---| Player 1
---| Pet 2
---| Target 3
---| Focus 4
---| Cast Bar 5
---| Party 6
---| Raid 7
---| Manager 8
---| MicroMenu 9
---| XP Bar 10
---| BagsBar 11

---@alias Create_201 number
---| Player 1
---| Target 2
---| Target Target 3
---| Pet 4
---| Pet Target 5
---| Focus 6

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
---| Idle mode 4
---| Range check 5
---| Indicators 6

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

---@alias UpdateText_701 number
---| Solo Health 1
---| Solo Power 2
---| Header Health 5
---| Header Power 6

---@alias Layout_801 number
---| smooth health Solo 1
---| smooth Power Solo 2
---| smooth health Header 3

---@alias Update_901 boolean
---| Player
---| Target
---| TargetTarget
---| Pet
---| PetTarget
---| Focus
---| Header

---@alias Aura_1001 number
---| Enable 1
---| Solo 2
---| Header 3

---@alias IndicatorsPosition_1002 number
---| READY_CHECK READY_CHECK_CONFIRM READY_FINISHED 1
---| UNIT_CONNECTION 2
---| RAID_TARGET_UPDATE 3
---| INCOMING_RESURRECT_CHANGED 4
---| PARTY_LEADER_CHANGED 5
---| PARTY_LOOT_METHOD_CHANGED 6
---| UNIT_FLAGS 7
---| PLAYER_ROLES_ASSIGNED 8
---| PLAYER_FLAGS_CHANGED 9

---@alias Layout_1201 number
---| playerCastBar 1
---| targetCastBar 2

---@alias CastBarConfig_1301 number
---| Player CastBar Config 1
---| Target CastBar Config 2

---@alias CastBarConfig_1401 number
---| customButton 1
---| customButton 2
---| customButton 3

---@alias CastBarConfig_1501 number
---| header 1
---| header 2
---| header 3
---| header 4
---| header 5

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

function Ether:NilCheckData(data, number)
    if data[number] then
        for subkey in pairs(Ether.DataDefault[number]) do
            if data[number][subkey] == nil then
                data[number] = Ether.CopyTable(Ether.DataDefault[number])
                break
            end
        end
    end
end

function Ether:ArrayMigrateData(data)
    local arraysLength = {
        [101] = 11, [201] = 6, [301] = 13, [401] = 6,
        [501] = 9, [701] = 4, [801] = 3,
        [1001] = 3, [1101] = 3, [1201] = 2, [1501] = 5
    }
    for arrayID, expectedLength in pairs(arraysLength) do
        if data[arrayID] and type(data[arrayID]) == "table" then
            if #data[arrayID] ~= expectedLength then
                data[arrayID] = Ether.DataMigrate(data[arrayID], expectedLength, 1)
            end
        end
    end
end

function Ether:FrameChecked(number, data)
    if Ether.UIPanel.Buttons[number] then
        for i = 1, #Ether.DB[data] do
            local checkbox = Ether.UIPanel.Buttons[number][i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[data][i] == 1)
            end
        end
    end
end
function Ether:RefreshAllSettings()


end

function Ether:RefreshAllSettings()
    Ether:FrameChecked(1, 401)
    Ether:FrameChecked(2, 101)
    Ether:FrameChecked(3, 201)
    Ether:FrameChecked(4, 701)
    Ether:FrameChecked(5, 1001)
    Ether:FrameChecked(6, 501)
    Ether:FrameChecked(7, 301)
    Ether:FrameChecked(8, 801)
    Ether:FrameChecked(9, 1201)
    Ether:FrameChecked(11, 1501)
end

function Ether:EtherFrameSetClick(number, number2, number3)
    local check = Ether.UIPanel.Buttons[number][number2][number3] or Ether.UIPanel.Buttons[number][number2]
    check:SetChecked(not check:GetChecked())
    check:GetScript("OnClick")(check)
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
            tinsert(result, "\n" .. string_rep(" ", indent) .. keyStr .. " = " .. valueStr .. comma)
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
