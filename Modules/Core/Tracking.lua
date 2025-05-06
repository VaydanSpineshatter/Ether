local _, addonTable = ...
local L = LOCALIZATION_L or {}

addonTable.Modules.Tracking = addonTable.Modules.Tracking or {
    initialized = false
};

local Tracking = addonTable.Modules.Tracking




local function CheckCooldownExpirations()
    local currentTime = GetTime()
    local anyExpired = false

    for spellId, cdData in pairs(addonTable.Store.Cooldowns.active) do
        if cdData.endTime <= currentTime then
            local spellData = addonTable.Store.SPELLS[spellId]
            if spellData then
                print(string.format("|cFF%02X%02X%02X%s|r (used by %s) is now ready!",
                    spellData.color.r * 255,
                    spellData.color.g * 255,
                    spellData.color.b * 255,
                    spellData.name,
                    cdData.triggeredBy))
            end
            addonTable.Store.Cooldowns.active[spellId] = nil
            anyExpired = true
        end
    end

    return anyExpired
end


local function OnCombatLogEvent(...)
    local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, _, _, amount =
        CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_ENERGIZE" then
        local spellData = addonTable.Store.SPELLS[spellId]
        if not spellData or not spellData.isManaSource then return end

        local unit
        if destGUID == UnitGUID("player") then
            unit = "player"
        else
            for i = 1, GetNumGroupMembers() do
                if UnitGUID("raid" .. i) == destGUID then
                    unit = "raid" .. i
                    break
                end
            end
        end

        if unit then
            if addonTable.Store.IsOnCooldown(spellId) then
                local remaining = addonTable.Store.GetCooldownRemaining(spellId)
                local cdData = addonTable.Store.Cooldowns.active[spellId]
                local user = cdData and cdData.triggeredBy or "unknown"

                print(string.format("|cFF%02X%02X%02X%s|r (used by %s) on cooldown (%.1fs remaining)",
                    spellData.color.r * 255,
                    spellData.color.g * 255,
                    spellData.color.b * 255,
                    spellData.name,
                    user,
                    remaining))
            else
                local sourcePlayer = sourceName or UnitName("player")
                addonTable.Store.StartCooldown(spellId, sourcePlayer)

                print(string.format("|cFF%02X%02X%02X%s|r - %d Mana restored to %s (used by %s, CD: %ds started)",
                    spellData.color.r * 255,
                    spellData.color.g * 255,
                    spellData.color.b * 255,
                    spellData.name,
                    amount,
                    destName or UnitName(unit),
                    sourcePlayer,
                    spellData.cooldown or 0))
            end
        end
    end
end





function Tracking:Initialize()
    if self.initialized then return end
    if not db.profile.Tracking.Enabled then return false end

    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self.eventFrame:SetScript("OnEvent", OnCombatLogEvent)
    end

    C_Timer.NewTicker(1, function()
        if CheckCooldownExpirations() then

        end
    end)

    do
        local potion = addonTable.Store.Items[13444]
        local manaText = addonTable.Store.FormatManaText("player")
        print(string.format("Function check: %s found - Mana: %s",
            potion.name, manaText))
    end

    self.initialized = true
    return true
end

function Tracking:RegisterEvents()
    local f = self.DrinkOverlayFrame
    local events = {
        "COMBAT_LOG_EVENT_UNFILTERED",
        "SPELL_ENERGIZE"
    };

    for _, event in ipairs(events) do
        f:RegisterEvent(event)
    end
end

function Tracking:UnregisterEvents()
    local f = self.DrinkOverlayFrame
    f:UnregisterAllEvents()
end

function Tracking:IsEnabled()
    return self.initialized
end

function Tracking:Enable()
    if not self.initialized then self:Initialize() end
end

function Tracking:Disable()
    print("Tracking disabled")
    self:UnregisterEvents()
    self.initialized = false
end
