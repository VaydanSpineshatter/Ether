local _, addonTable = ...

local spellCacheMT = {
    __index = function(t, spellID)
        local storeData = rawget(addonTable.Store.SPELLS, spellID)


        local name, _, icon = GetSpellInfo(spellID)

        if not name then return nil end

        local data = {
            name = name,
            icon = icon,

            isDrink = storeData and storeData.isDrink or false,
            isManaSource = storeData and storeData.isManaSource or false,
            color = storeData and storeData.color or nil,
            cooldown = storeData and storeData.cooldown or nil,
            sharedCooldownGroup = storeData and storeData.sharedCooldownGroup or nil
        }

        rawset(t, spellID, data)
        return data
    end
}

local storeMT = {
    __index = function(t, k)
        rawset(t, k, {})
        return rawget(t, k)
    end
}


local function tContains(table, item)
    for _, value in pairs(table) do
        if value == item then return true end
    end
    return false
end

local classColorCache = {}

addonTable.Store = setmetatable({
    Items    = {
        [13444] = { name = "Major Mana Potion" },
        [13446] = { name = "Major Healing Potion" }
    },

    SPELLS   = setmetatable({
        [430] = { isDrink = true },
        [1137] = { isDrink = true },
        [22734] = { isDrink = true },
        [34291] = { isDrink = true },
        [17531] = {
            name = "Major Mana Potion",
            color = { r = 0.2, g = 0.5, b = 1 },
            cooldown = 120,
            isManaSource = true,
        },
        [16666] = {
            name = "Demonic Rune",
            color = { r = 1, g = 0.2, b = 0.2 },
            cooldown = 120,
            sharedCooldownGroup = "RUNE_SHARED_CD",
            isManaSource = true,
        },
        [15701] = {
            name = "Night Dragon's Breath",
            color = { r = 0.5, g = 0, b = 1 },
            cooldown = 120,
            sharedCooldownGroup = "RUNE_SHARED_CD",
            isManaSource = true,
        },
        [27869] = {
            name = "Dark Rune",
            color = { r = 1, g = 0.2, b = 0.2 },
            cooldown = 120,
            sharedCooldownGroup = "RUNE_SHARED_CD",
            isManaSource = true,
        }
    }, spellCacheMT),

    STATUSES = {
        DEAD      = 1,
        OOR       = 2,
        DRINK     = 4,
        INNERVATE = 8
    },


    UnitData             = {},

    Cooldowns            = {
        SHARED_GROUPS = {
            RUNE_SHARED_CD = {
                duration = 120,
                spells = { 16666, 15701, 27869 }
            }
        },
        active = {}
    },

    StartCooldown        = function(spellId, triggeredBy)
        local spellData = addonTable.Store.SPELLS[spellId]
        if not spellData then return end

        local currentTime = GetTime()
        local playerName = triggeredBy or UnitName("player")


        addonTable.Store.Cooldowns.active[spellId] = {
            endTime = currentTime + (spellData.cooldown or 0),
            triggeredBy = playerName
        }


        for groupName, groupData in pairs(addonTable.Store.Cooldowns.SHARED_GROUPS) do
            if tContains(groupData.spells, spellId) then
                for _, sharedSpellId in ipairs(groupData.spells) do
                    addonTable.Store.Cooldowns.active[sharedSpellId] = {
                        endTime = currentTime + groupData.duration,
                        triggeredBy = playerName
                    }
                end
                break
            end
        end
    end,

    IsOnCooldown         = function(spellId)
        local cdData = addonTable.Store.Cooldowns.active[spellId]
        return cdData and cdData.endTime > GetTime()
    end,

    GetCooldownRemaining = function(spellId)
        local cdData = addonTable.Store.Cooldowns.active[spellId]
        if not cdData then return 0 end
        return math.max(0, cdData.endTime - GetTime())
    end,

    SetStatus            = function(unit, status)
        addonTable.Store.UnitData[unit] = addonTable.Store.UnitData[unit] or { statuses = 0 }
        addonTable.Store.UnitData[unit].statuses = bit.bor(addonTable.Store.UnitData[unit].statuses, status)
    end,

    HasStatus            = function(unit, status)
        local unitData = addonTable.Store.UnitData[unit]
        return unitData and bit.band(unitData.statuses, status) ~= 0
    end,

    ClearStatus          = function(unit, status)
        if addonTable.Store.UnitData[unit] then
            addonTable.Store.UnitData[unit].statuses = bit.band(
                addonTable.Store.UnitData[unit].statuses,
                bit.bnot(status)
            )
        end
    end,

    ClearAllStatuses     = function(unit)
        if addonTable.Store.UnitData[unit] then
            addonTable.Store.UnitData[unit].statuses = 0
        end
    end,

    GetManaPercent       = function(unit)
        if not UnitExists(unit) then return 0 end
        local power = UnitPower(unit, 0)
        local maxPower = UnitPowerMax(unit, Enum.PowerType.Mana)
        return maxPower > 0 and (power / maxPower * 100) or 0
    end,

    FormatManaText       = function(unit)
        if not UnitExists(unit) then return "|cffff0000N/A|r" end
        local pct = addonTable.Store.GetManaPercent(unit)
        return string.format("%s%.0f%%|r", addonTable.Store.GetManaColor(pct / 100), pct)
    end,

    GetManaColor         = function(pct)
        pct = pct or 0
        return pct > 0.7 and "|cff00ff00"
            or pct > 0.4 and "|cffffff00"
            or "|cffff0000"
    end,

    HexToRGB1            = function(hex)
        hex = hex:gsub("^|?c?f?f?", "")
        if #hex ~= 6 then return 1, 1, 1 end
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        return r, g, b
    end,

    IsManaClass          = function(class)
        local MANA_CLASSES = {
            DRUID = true,
            PRIEST = true,
            SHAMAN = true,
            PALADIN = false,
            HUNTER = false,
            MAGE = true,
            WARLOCK = false,
            WARRIOR = false,
            ROGUE = false
        }
        return MANA_CLASSES[class] or false
    end,

    ClassTools           = {
        GetColor = function(unit)
            local _, class = UnitClass(unit or "player")
            return RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }
        end,

        GetClassColorTable = function(class)
            class = class or select(2, UnitClass("player"))
            return RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }
        end,

        GetColorString = function(unitOrClass)
            local color
            if type(unitOrClass) == "string" and UnitExists(unitOrClass) then
                color = addonTable.Store.ClassTools.GetColor(unitOrClass)
            else
                color = addonTable.Store.ClassTools.GetClassColorTable(unitOrClass)
            end
            return string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        end,

        IsManaUser = function(unit)
            local _, class = UnitClass(unit)
            return addonTable.Store.IsManaClass(class)
        end,


        ClearCache = function()
            if classColorCache then wipe(classColorCache) end
        end
    },

}, storeMT)

--/run print(GetBuildInfo())
--/run print(IsAddOnLoaded("RaidManaEV"))
--local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
--/run local _, _, icon = GetSpellInfo(430); print("Icon ID:", string.match(icon, "%d+"))
--/run for i=1,40 do local name,_,_,_,_,_,_,_,_,id = UnitBuff("player", i); if name then print(name, id) end end
