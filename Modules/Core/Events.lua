local _, addonTable = ...
local L = LOCALIZATION_L or {}

addonTable.Modules.Events = addonTable.Modules.Events or {
    initialized = false
};

local Events = addonTable.Modules.Events

function Events:Initialize()
    if self.initialized then return end

    if db.profile.Events.Enabled == false then return false end


    self.initialized = true
end

function Events:Disable()
    if not self.initialized then return end

    self.initialized = false
end

function Events:IsEnabled()
    return self.initialized
end
