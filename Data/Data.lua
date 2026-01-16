local _, Ether = ...

---@alias Menu number
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
---| Aura Enabled on player, target, raid
---| Buffs 1101
---| Debuffs 1202
---| Layout 2001
---| UIParent 5133
---| Position 5111

local Default = {
    ["VERSION"] = 0,
    ["LAST_VERSION"] = 0,
    ["SHOW"] = true,
    ["LAST_TAB"] = nil,
    ["SELECTED"] = 341,
    [101] = { 1, 1, 1, 1, 1, 1, 1, 1 },
    [201] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    [301] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    [401] = { 1, 1 },
    [501] = { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    [601] = { 1, 1, 1, 0, 1, 1, 1 },
    [701] = { 0, 0, 0, 0, 0, 0 },
    [801] = { 0 },
    [901] = { "player", "target", "targettarget", "pet", "pettarget", "focus", "party", "raid", "raidpet", "maintank" },
    [1001] = {
        [1002] = { 0, 0, 0 },
        ["SIZE"] = 6,
        [1101] = { 10938, 21564, 27841, 27681, 10958, 27683, 25315, 10901, 6346, 10157, 23028, 9885, 21850 },
        [1202] = { 6788 },
        ["CUSTOM"] = {}
    },
    [2001] = {
        ["CLASS"] = nil,
        ["ROLE"] = nil,
        ["SMOOTH_HEALTH_SINGLE"] = false,
        ["SMOOTH_HEALTH_RAID"] = false,
        ["SMOOTH_POWER_SINGLE"] = false,
        ["HIGHLIGHT"] = false,
        ["LAYOUT_SOLO"] = false,
        ["LAYOUT_BG"] = true,
        ["PLAYER_BAR"] = false,
        ["TARGET_BAR"] = false,
    },
    [5111] = {
        [301] = { "TOPLEFT", 5133, "TOPLEFT", 300, -300, 1, 1, 1.0, 1.0 },
        [331] = { "CENTER", 5133, "CENTER", -250, -250, 120, 50, 1.0, 1.0 },
        [332] = { "CENTER", 5133, "CENTER", 250, -250, 120, 50, 1.0, 1.0 },
        [333] = { "CENTER", 5133, "CENTER", 0, -300, 120, 50, 1.0, 1.0 },
        [334] = { "CENTER", 5133, "CENTER", -350, 80, 120, 50, 1.0, 1.0 },
        [335] = { "CENTER", 5133, "CENTER", -370, 0, 120, 50, 1.0, 1.0 },
        [336] = { "CENTER", 5133, "CENTER", 0, 100, 120, 50, 1.0, 1.0 },
        [337] = { "TOPLEFT", 5133, "TOPLEFT", 20, -130, 1, 1, 1.0, 1.0 },
        [338] = { "LEFT", 5133, "LEFT", 10, 0, 1, 1, 1.0, 1.0 },
        [339] = { "LEFT", 5133, "LEFT", 10, 70, 1, 1, 1.0, 1.0 },
        [340] = { "TOPLEFT", 5133, "TOPLEFT", 20, -20, 1, 1, 1.0, 1.0 },
        [341] = { "TOP", 5133, "TOP", 80, -80, 320, 200, 1.0, 1.0 },
        [342] = { "TOPLEFT", 5133, "TOPLEFT", 50, -100, 640, 480, 1.0, 1.0 }
    }
}
Ether.DataDefault = Default

---@alias Token number
---| Player 331
---| Target 332
---| TargetTarget 333
---| Pet 334
---| PetTarget 335
---| Focus 336
---| Party 337
---| Raid 338
---| RaidPet 339
---| MainTank 340
---| Debug 341
---| Settings 342

---@alias I_Register number
---| READY_CHECK READY_CHECK_CONFIRM READY_FINISHED 1
---| UNIT_CONNECTION 2
---| RAID_TARGET_UPDATE 3
---| INCOMING_RESURRECT_CHANGED 4
---| PARTY_LEADER_CHANGED 5
---| PARTY_LOOT_METHOD_CHANGED 6
---| UNIT_FLAGS 7
---| PLAYER_ROLES_ASSIGNED 8
---| PLAYER_FLAGS_CHANGED 9

---@alias I_Enable number
---| Unit Is Charmed 1
---| Unit Is Dead 2
---| Unit Is Ghost 3
---| Group Role 4
---| Main Tank and Main Assist 5
---| AFK String 6
---| DND String 7

---@alias Module number
---| Icon 1
---| Grid 2

---@alias Tooltip number
---| Enabled 1
---| AFK 2
---| DND 3
---| PVP 4
---| Resting 5
---| Realm 6
---| Different Realm 7
---| Level 8
---| Class 9
---| Guild 10
---| Role 11
---| Creature 12
---| Race 13
---| Raid Target 14
---| Reaction 15

---@alias Create number
---| Player 1
---| Target 2
---| Target Target 3
---| Pet 4
---| Pet Target 5
---| Focus 6
---| Party 7
---| Raid 8
---| Raid pet 9
---| Main Tank 10
---| Player Cast Bar 11
---| Target Cast Bar 12

---@alias Hide number
---| Player 1
---| Pet 2
---| Target 3
---| Cast Bar 4
---| Party 5
---| Raid 6
---| Manager 7

---@alias Range number
---| Enable 1

---@alias UpdateText number
---| Single-Health 1
---| Single-Power 2
---| Party-Health 3
---| Party-Power 4
---| Raid-Health 5
---| Raid-Power 6

---@alias AuraON number
---| Player 1
---| Target 2
---| Raid 3

function Ether.MigrateDatabase(oldDB, newVersion)
    local newDB = Ether.DeepCopy(Ether.DataDefault)
    newDB.VERSION = newVersion

    if not oldDB or type(oldDB) ~= "table" then
        return newDB
    end

    for key, defaultValue in pairs(Ether.DataDefault) do
        if type(defaultValue) ~= "table" and oldDB[key] ~= nil then
            newDB[key] = oldDB[key]
        end
    end

    local arrayConfigs = {
        [101] = { size = 7, default = 1 },
        [201] = { size = 12, default = 0 },
        [301] = { size = 15, default = 1 },
        MODULES = { size = 2, default = 1 },
        [501] = { size = 9, default = 1 },
        [601] = { size = 7, default = 1 },
        POWER = { size = 3, default = 0 },
        RANGE = { size = 1, default = 0 },
        AURA = {
            ON = { size = 3, default = 0 },
            BUFF = { keepAll = true },
            DEBUFF = { keepAll = true },
            CUSTOM = { keepAll = true }
        }
    }

    for category, config in pairs(arrayConfigs) do
        if category == "AURA" then
            if oldDB.AURA and type(oldDB.AURA) == "table" then
                if oldDB.AURA.ON then
                    newDB.AURA.ON = Ether.DataMigrate(oldDB.AURA.ON, 3, 0)
                end
                if config.BUFF.keepAll and oldDB.AURA.BUFF then
                    newDB.AURA.BUFF = Ether.DeepCopy(oldDB.AURA.BUFF)
                end
                if config.DEBUFF.keepAll and oldDB.AURA.DEBUFF then
                    newDB.AURA.DEBUFF = Ether.DeepCopy(oldDB.AURA.DEBUFF)
                end
                if config.CUSTOM.keepAll and oldDB.AURA.CUSTOM then
                    newDB.AURA.CUSTOM = Ether.DeepCopy(oldDB.AURA.CUSTOM)
                end

                if oldDB.AURA.SIZE then
                    newDB.AURA.SIZE = oldDB.AURA.SIZE
                end
            end
        else
            if oldDB[category] then
                newDB[category] = Ether.DataMigrate(
                        oldDB[category],
                        config.size,
                        config.default
                )
            end
        end
    end

    if oldDB.UPDATE and type(oldDB.UPDATE) == "table" then
        for unit, value in pairs(oldDB.UPDATE) do
            if newDB.UPDATE[unit] ~= nil then
                newDB.UPDATE[unit] = value
            end
        end
    end

    if oldDB.LAYOUT and type(oldDB.LAYOUT) == "table" then
        for key, defaultValue in pairs(newDB.LAYOUT) do
            if oldDB.LAYOUT[key] ~= nil then
                newDB.LAYOUT[key] = oldDB.LAYOUT[key]
            end
        end
    end

    if oldDB[5111] and type(oldDB[5111]) == "table" then
        for frame, posData in pairs(oldDB[5111]) do
            if newDB[5111][frame] and type(posData) == "table" then
                for i = 1, math.min(#posData, 9) do
                    newDB[5111][frame][i] = posData[i]
                end
            end
        end
    end

    local preserveFields = { "LAST_VERSION", "LAST_TAB", "SELECTED" }
    for _, field in ipairs(preserveFields) do
        if oldDB[field] ~= nil then
            newDB[field] = oldDB[field]
        end
    end

    return newDB
end

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