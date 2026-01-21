local _, Ether = ...

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
---| 340 maintank
---| 341 Debug
---| 342 Settings

--- 5133 UIParent


local Default = {
    [001] = {
        VERSION = 0,
        LAST_VERSION = 0,
        SHOW = true,
        LAST_TAB = "Module",
        SELECTED = 341
    },
    [101] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    [201] = { 1, 1, 1, 1, 1, 1, 1, 1, 0 },
    [301] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    [401] = { 1, 1 },
    [501] = { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    [601] = { 1, 1, 1, 0, 1, 1, 1 },
    [701] = { 0, 0, 0, 0, 0, 0 },
    [801] = { 0 },
    [901] = {
        player = true,
        target = true,
        targettarget = true,
        pet = true,
        pettarget = true,
        focus = true,
        party = true,
        raid = true,
        maintank = false,
    },
    [1001] = {
        [1002] = { 1, 1, 1, 1 },
        [1003] = {
            [6788] = {
                enabled = true,
                name = "Weakened Soul",
                position = "TOP",
                color = {
                    [1] = 1,
                    [2] = 0,
                    [3] = 0,
                    [4] = 1
                },
                offsetX = 0,
                offsetY = -6,
                size = 6
            },
            [10901] = {
                enabled = true,
                name = "Power Word Shield: Rank 3",
                position = "TOP",
                color = {
                    [1] = 1,
                    [2] = 1,
                    [3] = 1,
                    [4] = 1
                },
                offsetX = 0,
                offsetY = 0,
                size = 6
            },
        }
    },
    [2001] = {
        ["SMOOTH_HEALTH_SINGLE"] = false,
        ["SMOOTH_HEALTH_RAID"] = false,
        ["SMOOTH_POWER_SINGLE"] = false,
        ["PLAYER_BAR"] = true,
        ["TARGET_BAR"] = true,
    },
    [5111] = {
        [331] = { "TOPLEFT", 5133, "TOPLEFT", 300, -300, 1, 1, 1.0, 1.0 },
        [332] = { "CENTER", 5133, "CENTER", -250, -250, 120, 50, 1.0, 1.0 },
        [333] = { "CENTER", 5133, "CENTER", 250, -250, 120, 50, 1.0, 1.0 },
        [334] = { "CENTER", 5133, "CENTER", 0, -300, 120, 50, 1.0, 1.0 },
        [335] = { "CENTER", 5133, "CENTER", -400, -100, 120, 50, 1.0, 1.0 },
        [336] = { "CENTER", 5133, "CENTER", -300, 100, 120, 50, 1.0, 1.0 },
        [337] = { "CENTER", 5133, "CENTER", 0, 100, 120, 50, 1.0, 1.0 },
        [338] = { "CENTER", 5133, "CENTER", -100, -80, 1, 1, 1.0, 1.0 },
        [339] = { "LEFT", 5133, "LEFT", 10, 0, 1, 1, 1.0, 1.0 },
        [340] = { "TOPLEFT", 5133, "TOPLEFT", 20, -20, 1, 1, 1.0, 1.0 },
        [341] = { "TOP", 5133, "TOP", 80, -80, 320, 200, 1.0, 1.0 },
        [342] = { "TOPLEFT", 5133, "TOPLEFT", 50, -100, 640, 480, 1.0, 1.0 }
    }
}
Ether.DataDefault = Default

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
---| Main Tank 9

---@alias Tooltip_301 number
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

---@alias Module_401 number
---| Icon 1

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