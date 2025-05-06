local _, addonTable = ...
local L, C = LOCALIZATION_L, addonTable.C

addonTable.Modules = addonTable.Modules or {
    Minimap = {},
    Tracking = {},
    UnitFrames = {},
    Events = {}
};

addonTable.Config = addonTable.Config or {
    GeneralOPT = {},
    MinimapOpt = {},
    UnitFramesOpt = {},
    TrackingOpt = {},
    EventsOpt = {}
};

local defaults = {
    profile = {
        Minimap = { Enabled = true },
        UnitFrames = {
            Enabled = false,
            BackdropColor = {
                r = 0.1,
                g = 0.1,
                b = 0.1,
                a = 1
            },
            Color = {
                r = 0.9,
                g = 0,
                b = 0
            },
            Position = {
                point = "CENTER",
                relativeTo = "UIParent",
                relativePoint = "CENTER",
                x = 0,
                y = 0
            },
            Show = true,
            Lock = false,
            Scale = 1.0,
            Opacity = 1
        },
        Tracking = { Enabled = false },
        Events = { Enabled = false },
    }
};

local function SafeInitialize(module)
    if module and type(module.Initialize) == "function" then
        local success, err = pcall(module.Initialize, module)
        if not success then
            print(L.ERROR_INSTALIZING_MODULE, err)
            return false
        end
        return true
    end
    return false
end

StaticPopupDialogs["ETHERWATCH_CONFIRM_DELETE"] = {
    text = L.PROFILE_REALLY_DELETE,
    button1 = L.DELETE,
    button2 = L.CANCEL,
    OnAccept = function(self)
        local profileName = self.data
        if profileName then
            db:DeleteProfile(profileName)
            RefreshConfig(L.DELETED, profileName)
        else
            print(L.ERROR_PROFILE_NAME)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
};

local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("PLAYER_LOGIN")
Initialize:SetScript("OnEvent", function(self, event)
    db = LibStub("AceDB-3.0"):New("ETHEREWATCH_MAIN_DB", defaults, true)
    assert(db, L.ASSERT_DATABASE)

    db.RegisterCallback(addonTable, "OnProfileChanged", function(_, newdb)
        RefreshConfig("changed", newdb:GetCurrentProfile())
    end)

    db.RegisterCallback(addonTable, "OnProfileCopied", function(_, _, name)
        RefreshConfig("copied", name)
    end)

    db.RegisterCallback(addonTable, "OnProfileReset", function(_, db)
        RefreshConfig("reset", db:GetCurrentProfile())
    end)

    local options = BuildOptions()

    local Config = LibStub("AceConfig-3.0")
    local Dialog = LibStub("AceConfigDialog-3.0")
    local Notify = LibStub("AceConfigRegistry-3.0")

    Config:RegisterOptionsTable("EtherWatch", options)
    Dialog:AddToBlizOptions("EtherWatch", "EtherWatch")
    Dialog:SetDefaultSize("EtherWatch", 800, 600)
    Notify:NotifyChange("EtherWatch")

    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
    options.args.profiles.name = "|cff00ccffProfiles|r"
    options.args.profiles.args.delete = {
        name = "Delete",
        desc = "Permanently delete your profile",
        type = "execute",
        func = function()
            local currentProfile = db:GetCurrentProfile()
            StaticPopup_Show("ETHERWATCH_CONFIRM_DELETE", currentProfile, nil, currentProfile)
        end,
        confirm = false
    };

    local tabOrder = { "General", "Minimap", "UnitFrames", "Tracking", "Events" }
    for _, tabName in ipairs(tabOrder) do
        options.args[tabName] = addonTable.Config[tabName .. "Opt"]:GetOptions(db)
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("EtherWatch")

    for name, module in pairs(addonTable.Modules) do
        if type(db.profile[name]) == "table" and db.profile[name].Enabled then
            SafeInitialize(module)
        end
    end

    SLASH_ETHERWATCH1 = "/etherwatch"
    SlashCmdList.EtherWatch = function()
        if Dialog.OpenFrames["EtherWatch"] then
            Dialog:Close("EtherWatch")
        else
            Dialog:Open("EtherWatch")
        end
    end
end);

function RefreshConfig(action, profileName)
    local messages = {
        changed = L.PROFILE_CHANGED,
        copied = L.PROFILE_COPIED,
        reset = L.PROFILE_RESET,
        deleted = L.PROFILE_DELETED
    };

    profileName = profileName or db:GetCurrentProfile() or L.PROFILE_UNKNOWN

    local message = messages[action] and format(messages[action], profileName)
        or L.SETTINGS_UPDATED

    print("|cff00ccffEtherWatch:|r " .. message)

    if action == "deleted" then
        if db:GetCurrentProfile() == profileName then
            db:SetProfile("Default")
        end
    end

    Refresh()
end

local function SafeGet(val, fallback)
    return val ~= nil and val or fallback
end

function Refresh()
    local frames = addonTable.Modules.UnitFrames
    if not frames or type(frames) ~= "table" or not frames.DrinkOverlayFrame or not frames.DrinkOverlayFrame.SetShown then return end

    frames.DrinkOverlayFrame:SetShown(db.profile.UnitFrames.Enabled)

    local pos = db.profile.UnitFrames.Position
    if type(pos) == "table" then
        frames.DrinkOverlayFrame:ClearAllPoints()
        frames.DrinkOverlayFrame:SetPoint(
            pos.point or "CENTER",
            pos.relativeTo or "UIParent",
            pos.relativePoint or "CENTER",
            pos.x or 0,
            pos.y or 0
        );
    end

    frames.DrinkOverlayFrame:SetScale(SafeGet(db.profile.UnitFrames.Scale, 1.0))
    frames.DrinkOverlayFrame:SetAlpha(SafeGet(db.profile.UnitFrames.Opacity, 1.0))

    local lock, back = db.profile.UnitFrames.Lock, db.profile.UnitFrames.BackdropColor
    local alpha = (lock and 0) or 1
    frames.DrinkOverlayFrame:SetBackdropColor(back.r, back.g, back.b, alpha)
end

local options
function BuildOptions()
    options = options or { name = "EtherWatch", type = "group", childGroups = "tab", args = {} }
    return options
end
