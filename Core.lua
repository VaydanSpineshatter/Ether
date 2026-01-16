---@class Ether
local _, Ether = ...
local L = Ether.L
Ether.Header = {}
Ether.Anchor = {}

local mediaPath = {
    Icon = { "Interface\\AddOns\\Ether\\Media\\Graphic\\Icon.blp" },
    Font = { "Interface\\AddOns\\Ether\\Media\\Font\\expressway.ttf" },
    StatusBar = { "Interface\\AddOns\\Ether\\Media\\StatusBar\\UfBar.blp" },
    BlankBar = { "Interface\\AddOns\\Ether\\Media\\StatusBar\\BlankBar.tga" },
    NewBar = { "Interface\\AddOns\\Ether\\Media\\StatusBar\\striped.tga" },
    OldBar = { "Interface\\AddOns\\Ether\\Media\\StatusBar\\otravi.tga" },
}
Ether.mediaPath = mediaPath

Ether.SlashInfo = {
    [1] = { cmd = "/ether", desc = "Toggle Commands" },
    [2] = { cmd = "/ether settings", desc = "Toggle settings" },
    [3] = { cmd = "/ether debug", desc = "Toggle debug" },
    [4] = { cmd = "/ether rl", desc = "Reload Interface" }
}

local pos_Frames = {}
Ether.pos_Frames = pos_Frames
Ether.unitButtons = {}
Ether.HeaderStr = {}
Ether.Buttons = {
    SplitHeader = {},
    party = {},
    raid = {},
    maintank = {},
    raidpet = {},
    single = {},
    Update = {},
    raidByGUID = {}
}

local function BuildContent(self)
    local success, msg = pcall(function()
        Ether.InfoSection(self)
        Ether.SlashSection(self)
        Ether.HideSection(self)
        Ether.FactorySection(self)
        Ether.UpdateSection(self)
        Ether.AuraSettingsSection(self)
        Ether.AuraCustomSection(self)
        Ether.AuraInfoSection(self)
        Ether.RegisterSection(self)
        Ether.LayoutSection(self)
        Ether.RangeSection(self)
        Ether.TooltipSection(self)
        Ether.ConfigSection(self)
        Ether.ProfileSection(self)
    end)
    if not success then
        if Ether.DebugOutput then
            Ether.DebugOutput("Content creation failed - ", msg)
        else
            print("Content creation failed - ", msg)
        end
    end
end

local pairs, ipairs = pairs, ipairs
local GetMetadata = C_AddOns.GetAddOnMetadata
Ether.version = GetMetadata("Ether", "Version")
Ether.updatedChannel = false
Ether.debug = false

local Construct = {
    IsSuccess = false,
    IsLoaded = false,
    IsCreated = false,
    Steps = { 0, 0, 0 },
    Frames = {},
    MenuButtons = {},
    ScrollFrames = {},
    DropDownTemplates = {},
    Content = {
        Children = {},
        Buttons = {
            General = { A = {} },
            Config = {},
            Hide = {},
            Create = { A = {} },
            Auras = { A = {}, B = {}, C = {} },
            Indicators = { A = {}, B = {} },
            Update = { A = {}, B = {}, C = {} },
            Layout = { A = {}, B = {}, C = {}, D = {}, E = {} }
        }
    },
    Auras = { Spells = {}, Colors = {} },
    ContentKeys = {
        [1] = { "Info", "Slash" },
        [2] = { "Hide", "Factory", "Updates" },
        [3] = { "Aura Settings", "Aura Custom", "Aura Info" },
        [4] = { "Register" },
        [5] = { "Layout", "Range", "Tooltip", "Config", "Profile" }
    },
    Menu = {
        ["LEFT"] = {
            [1] = { "General" },
            [2] = { "Units" },
            [3] = { "Auras" },
            [4] = { "Indicators" },
            [5] = { "Interface" }
        },
        ["TOP"] = {
            [1] = { "Info", "Slash" },
            [2] = { "Hide", "Factory", "Updates" },
            [3] = { "Aura Settings", "Aura Custom", "Aura Info" },
            [4] = { "Register" },
            [5] = { "Layout", "Range", "Tooltip", "Config", "Profile" }
        }
    },
}
Ether.Construct = Construct

local function IsSuccess(self)
    local success, msg = pcall(function()
        assert(self.Steps[1] == 1 and self.Steps[2] == 1 and self.Steps[3] == 1, "Steps incomplete")
    end)
    if not success then
        Ether.DebugOutput("Assertion failed - ", msg)
        return false
    else
        return true
    end
end

local function ShowCategory(self, IdStr)
    if not self.IsLoaded then
        return
    end

    for _, child in pairs(self.Content.Children) do
        if child._ScrollFrame then
            child._ScrollFrame:Hide()
        else
            child:Hide()
        end
    end

    local target = self.Content.Children[IdStr]
    if target then
        if target._ScrollFrame then
            local scrollFrame = target._ScrollFrame

            scrollFrame:Show()

            target:Show()
            local width = scrollFrame:GetWidth()
            if width > 30 then
                target:SetWidth(width - 30)
            else
                target:SetWidth(self.Frames["Content"]:GetWidth() - 30)
            end

            scrollFrame:UpdateScrollChildRect()
        else
            target:Show()
        end

        Ether.DB["LAST_TAB"] = IdStr
    end
end

local function InitializeSettings(self)
    if self.IsLoaded then
        return
    end

    for layer = 1, 5 do
        if self.ContentKeys[layer] then
            for _, name in ipairs(self.ContentKeys[layer]) do
                self.Content.Children[name] = Ether.CreateSettingsScrollTab(self.Frames["Content"], name)
                self.Content.Children[name].tex = self.Content.Children[name]:CreateTexture(nil, "BACKGROUND")
                self.Content.Children[name].tex:SetAllPoints()
                self.Content.Children[name].tex:SetColorTexture(0, 0, 0, 0.5)
                self.Content.Children[name]._ScrollFrame:Hide()
            end
        end
    end

    BuildContent(self)

    if self.Content.Children["Layout"] then
        self.Steps[1] = 1
    end

    for layer = 1, 5 do
        if self.Menu["TOP"][layer] then
            self.MenuButtons[layer] = {}
            local BtnConfig = {}
            for idx, itemName in ipairs(self.Menu["TOP"][layer]) do
                local btn = Ether.CreateSettingsButtons(self, itemName, self.Frames["Top"], layer, function(btnName)
                    ShowCategory(self, btnName)
                end, true)

                btn:SetWidth(self.Frames["Top"]:GetWidth() / 6)

                btn:Hide()
                BtnConfig[idx] = {
                    btn = btn,
                    name = itemName,
                    width = btn:GetWidth()
                }
                self.MenuButtons[layer][itemName] = btn
            end

            if #BtnConfig > 0 then
                local spacing = 10
                local totalWidth = 0

                for _, data in ipairs(BtnConfig) do
                    totalWidth = totalWidth + data.width
                end
                totalWidth = totalWidth + (#BtnConfig - 1) * spacing

                local startX = -totalWidth / 2
                local currentX = startX

                for _, data in ipairs(BtnConfig) do
                    data.btn:SetPoint("CENTER", self.Frames["Top"], "CENTER", currentX + data.width / 2, 5)
                    currentX = currentX + data.width + spacing
                end
            end
        end
    end

    if self.Menu["TOP"] then
        self.Steps[2] = 1
    end

    local last = nil
    for layer = 1, 5 do
        if self.Menu["LEFT"][layer] then
            for _, itemName in ipairs(self.Menu["LEFT"][layer]) do
                local btn = Ether.CreateSettingsButtons(self, itemName, self.Frames["Left"], layer, function(_, btnLayer)
                    for _, layers in pairs(self.MenuButtons) do
                        for _, topBtn in pairs(layers) do
                            topBtn:Hide()
                        end
                    end

                    if self.MenuButtons[btnLayer] then
                        for _, topBtn in pairs(self.MenuButtons[btnLayer]) do
                            topBtn:Show()
                        end
                    end
                end, false)

                if last then
                    btn:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 0)
                    btn:SetPoint("TOPRIGHT", last, "BOTTOMRIGHT", 0, -2)
                else
                    btn:SetPoint("TOPLEFT", self.Frames["Left"], "TOPLEFT", 5, 0)
                    btn:SetPoint("TOPRIGHT", self.Frames["Left"], "TOPRIGHT", -10, 0)
                end

                last = btn
            end
        end
    end

    if self.Menu["LEFT"] then
        self.Steps[3] = 1
    end

    self.IsLoaded = true

    if IsSuccess(self) then
        self.IsSuccess = true
    end
end

local function FindLayer(self, category)
    for layer = 1, 5 do
        if self.ContentKeys[layer] then
            for _, name in ipairs(self.ContentKeys[layer]) do
                if name == category then
                    return layer
                end
            end
        end
    end
    return nil
end

local function ToggleSettings(self)
    if not self.IsLoaded then
        InitializeSettings(self)
    end
    if not self.IsSuccess then
        return
    end

    self.Frames["Main"]:SetShown(Ether.DB["SHOW"])

    local category = Ether.DB["LAST_TAB"] or "Info"
    if self.Content.Children[category] then
        ShowCategory(self, category)
        local layer = FindLayer(self, category)
        if layer and self.MenuButtons[layer] then
            for _, topBtn in pairs(self.MenuButtons[layer]) do
                topBtn:Show()
            end
        end
    end
end

local hiddenParent = CreateFrame("Frame", nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()
local function HiddenFrame(frame)
    if not frame then
        return
    end
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(hiddenParent)
end

local function BlizzardHidePlayer()
    if Ether.DB[101][1] == 1 and PlayerFrame then
        HiddenFrame(PlayerFrame)
    end
end

local function BlizzardHidePlayersPet()
    if Ether.DB[101][2] == 1 and PetFrame then
        HiddenFrame(PetFrame)
    end
end

local function BlizzardHideTarget()
    if Ether.DB[101][3] == 1 and TargetFrame then
        HiddenFrame(TargetFrame)
    end
end

local function BlizzardHideFocus()
    if Ether.DB[101][4] == 1 and FocusFrame then
        HiddenFrame(FocusFrame)
    end
end

local function BlizzardHideCastBar()
    if Ether.DB[101][5] == 1 and PlayerCastingBarFrame then
        HiddenFrame(PlayerCastingBarFrame)
    end
end

local function HideBlizzardPartyFrames()
    if Ether.DB[101][6] == 1 then
        UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
        if CompactPartyFrame then
            CompactPartyFrame:UnregisterAllEvents()
        end

        if PartyFrame then
            PartyFrame:SetScript('OnShow', nil)
            for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
                HiddenFrame(frame)
            end
            HiddenFrame(PartyFrame)
        else
            for i = 1, 4 do
                HiddenFrame(_G['PartyMemberFrame' .. i])
                HiddenFrame(_G['CompactPartyMemberFrame' .. i])
            end
            HiddenFrame(PartyMemberBackground)
        end
    end
end

local function HideBlizzardRaidFrames()
    if Ether.DB[101][7] == 1 then
        if CompactRaidFrameContainer then
            CompactRaidFrameContainer:UnregisterAllEvents()
            hooksecurefunc(CompactRaidFrameContainer, 'Show', CompactRaidFrameContainer.Hide)
            hooksecurefunc(CompactRaidFrameContainer, 'SetShown', function(frame, shown)
                if shown then
                    frame:Hide()
                end
            end)
        end
    end
end

local function HideBlizzardRaidFrameManger()
    if Ether.DB[101][8] == 1 then
        if CompactRaidFrameManager_SetSetting then
            CompactRaidFrameManager_SetSetting('IsShown', '0')
        end
        if CompactRaidFrameManager then
            HiddenFrame(CompactRaidFrameManager)
        end
    end
end

local sendChannel
local function UpdateSendChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendChannel = "INSTANCE_CHAT"
    elseif IsInRaid() then
        sendChannel = "RAID"
    else
        sendChannel = "PARTY"
    end
end

local string_format = string.format
local time = time
local Comm = LibStub("AceComm-3.0")
Comm:RegisterComm("ETHER_VERSION", function(prefix, message, channel, sender)
    if sender == UnitName("player") then
        return
    end

    local theirVersion = tonumber(message)
    local myVersion = tonumber(Ether.version)

    local lastCheck = Ether.DB["LAST_VERSION"] or 0
    if (time() - lastCheck >= 9200) and theirVersion and myVersion and myVersion < theirVersion then
        Ether.DB["LAST_VERSION"] = time()

        local msg = string_format("New version found (%d). Please visit %s to get the latest version.", theirVersion, "|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r")

        if Ether.DebugOutput then
            Ether.DebugOutput(msg)
        end
    end
end)

local dataBroker
do
    if (not LibStub or not LibStub("LibDataBroker-1.1")) then
        return
    end
    local LDB = LibStub("LibDataBroker-1.1", true)

    dataBroker = LDB:NewDataObject("EtherIcon", {
        type = "launcher",
        icon = unpack(mediaPath.Icon)
    })

    local function OnClick(_, button)
        if button == "RightButton" then
            Ether.NotShow("SHOW")
            ToggleSettings(Construct)
        elseif button == "LeftButton" then
            if not Ether.gridFrame then
                Ether.Setup:CreateGrid()
            end
            local isShown = Ether.gridFrame:IsShown()
            Ether.gridFrame:SetShown(not isShown)
            Construct.GridCheckbox:SetChecked(not isShown)
        end
    end

    local function ShowTooltip(GameTooltip)
        GameTooltip:SetText("Ether", 0, 0.8, 1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LEFT, 1, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT, 1, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LOCALE, 1, 1, 1, 1)
    end

    dataBroker.OnTooltipShow = ShowTooltip
    dataBroker.OnClick = OnClick
    Ether.dataBroker = dataBroker
end

local tremove = table.remove
local C_After = C_Timer.After
local isCreating = false
local creationDelay = 0.08
local creationQueue = {}
local totEvents = { "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_HEAL_PREDICTION" }

local function processFunc()
    if #creationQueue == 0 then
        isCreating = false
        return
    end
    tremove(creationQueue, 1)()
    C_After(creationDelay, processFunc)
end

local function targetOfTargetEvents()
    if Ether.unitButtons["targettarget"] then
        for e = 1, 6 do
            Ether.unitButtons["targettarget"]:RegisterUnitEvent(totEvents[e], "targettarget")
        end
    end
end
Ether.targetOfTargetEvents = targetOfTargetEvents
local function startC_Process()
    local C = Ether.DB[201]

    if C[7] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreatePartyHeader()
        end
    end

    if C[8] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateRaidHeader()
        end
    end

    if C[9] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateRaidPetHeader()
        end
    end

    if C[1] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("player")
        end
    end

    if Ether.DB[1001][1002][1] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.Aura.SingleAuraFullInitial(Ether.unitButtons["player"])
        end
    end

    if C[2] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("target")
        end
    end

    if Ether.DB[1001][1002][2] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.Aura.SingleAuraFullInitial(Ether.unitButtons["target"])
        end
    end

    if C[3] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("targettarget")
        end
    end

    if C[4] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("pet")

        end
    end

    if C[5] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("pettarget")
        end
    end

    if C[10] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateMainTankHeader()
        end
    end

    if C[6] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("focus")
        end
    end

    creationQueue[#creationQueue + 1] = function()
        if Ether.unitButtons["pet"] then
            Ether:PetCondition(Ether.unitButtons["pet"])
        end
    end

    creationQueue[#creationQueue + 1] = function()
        targetOfTargetEvents()
    end

    if Ether.DB[2001]["PLAYER_BAR"] then
        creationQueue[#creationQueue + 1] = function()
            Ether.CastBar.Enable("player")
        end
    end

    if Ether.DB[2001]["TARGET_BAR"] then
        creationQueue[#creationQueue + 1] = function()
            Ether.CastBar.Enable("target")
        end
    end

    creationQueue[#creationQueue + 1] = function()
        if not Construct.IsCreated then
            Ether.CreateMainSettings(Construct)
        end
    end

    creationQueue[#creationQueue + 1] = function()
        local settings = Ether.RegisterPosition(Construct.Frames["Main"], 342)
        settings:InitialPosition()
        settings:InitialDrag()
    end

    creationQueue[#creationQueue + 1] = function()
        local debug = Ether.RegisterPosition(Ether.DebugFrame, 341)
        debug:InitialPosition()
        debug:InitialDrag()
    end

    if Ether.DB[301][1] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.Tooltip:Initialize()
        end
    end

    creationQueue[#creationQueue + 1] = function()
        ToggleSettings(Construct)
    end

    if not isCreating then
        isCreating = true
        processFunc()
    end
end

local function OnInitialize(self, event, ...)
    if (event == "ADDON_LOADED") then
        local loadedAddon = ...

        assert(loadedAddon == "Ether", "Unexpected addon string: " .. tostring(loadedAddon))
        assert(type(Ether.DataDefault) == "table", "Ether default database missing")
        assert(type(Ether.MergeToLeft) == "function" and type(Ether.DeepCopy) == "function", "Ether table func missing")

        self:RegisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")

        if not Ether.DebugFrame then
            Ether.Setup.CreateDebugFrame()
        end

        if type(_G.ETHER_DATABASE_DX_AA) ~= "table" then
            ETHER_DATABASE_DX_AA = {}
        end

        if type(ETHER_DATABASE_DX_AA.VERSION) ~= "number" then
            ETHER_DATABASE_DX_AA.VERSION = 0
        end

        local version = tonumber(Ether.version)
        if version == ETHER_DATABASE_DX_AA.VERSION then
            Ether.MergeToLeft(Ether.DataDefault, ETHER_DATABASE_DX_AA)
        else
            ETHER_DATABASE_DX_AA = Ether.DataDefault
            ETHER_DATABASE_DX_AA.VERSION = version
        end

        Ether.DB = Ether.DataDefault

        assert(type(Ether.DB) == "table", "Ether Database failed to initialize")
        assert(type(Ether.DB[5111]) == "table", "Ether Position table missing")
        self:RegisterEvent("PLAYER_LOGOUT")

        BlizzardHidePlayer()
        BlizzardHideTarget()
        BlizzardHidePlayersPet()
        BlizzardHideFocus()
        BlizzardHideCastBar()
        HideBlizzardPartyFrames()
        HideBlizzardRaidFrames()
        HideBlizzardRaidFrameManger()

    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        SLASH_ETHER1 = "/ether"
        SlashCmdList["ETHER"] = function(msg)
            local input, rest = msg:match("^(%S*)%s*(.-)$")
            input = string.lower(input or "")
            rest = string.lower(rest or "")
            if input == "settings" then
                Ether.NotShow("SHOW")
                ToggleSettings(Construct)
            elseif input == "debug" then
                Ether.debug = not Ether.debug
                Ether.DebugOutput(Ether.debug and "Debug On" or "Debug Off")
            elseif input == "rl" then
                if not InCombatLockdown() then
                    ReloadUI()
                end
            else
                for _, entry in ipairs(Ether.SlashInfo) do
                    Ether.DebugOutput(string_format("%s  –  %s", entry.cmd, entry.desc))
                end
            end
        end

        if IsInGuild() then
            Comm:SendCommMessage("ETHER_VERSION", Ether.version, "GUILD", nil, "NORMAL")
        end

        if (LibStub and LibStub("LibDBIcon-1.0")) then
            if type(_G.ETHER_ICON) ~= "table" then
                ETHER_ICON = {}
            end
            local LDI = LibStub("LibDBIcon-1.0", true)
            LDI:Register("EtherIcon", Ether.dataBroker, ETHER_ICON)
        end

        Ether.Aura:Enable()
        Ether.Roster:Enable()
        Ether.hStatus:Enable()
        Ether.nStatus:Enable()
        Ether.pStatus:Enable()

        local p = Ether.RegisterPosition(Ether.Anchor.party, 337)
        p:InitialPosition()
        local r = Ether.RegisterPosition(Ether.Anchor.raid, 338)
        r:InitialPosition()
        local rp = Ether.RegisterPosition(Ether.Anchor.raidpet, 339)
        rp:InitialPosition()
        local mt = Ether.RegisterPosition(Ether.Anchor.maintank, 340)
        mt:InitialPosition()
        local tooltip = CreateFrame("Frame", nil, UIParent)
        tooltip:SetFrameLevel(100)
        Ether.Anchor.tooltip = tooltip
        local tooltip_P = Ether.RegisterPosition(Ether.Anchor.tooltip, 301)
        tooltip_P:InitialPosition()
        local token = {
            [1] = 331,
            [2] = 332,
            [3] = 333,
            [4] = 334,
            [5] = 335,
            [6] = 336
        }
        for i, key in ipairs({ "player", "target", "targettarget", "pet", "pettarget", "focus" }) do
            if not Ether.Anchor[key] then
                Ether.Anchor[key] = CreateFrame("Frame", "Ether_" .. key .. "_Anchor", UIParent, "SecureFrameTemplate")
                pos_Frames["pos_" .. key] = Ether.RegisterPosition(Ether.Anchor[key], token[i])
                pos_Frames["pos_" .. key]:InitialPosition()
            end
        end
        startC_Process()

    elseif (event == "GROUP_ROSTER_UPDATE") then
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        if IsInGroup() and Ether.updatedChannel ~= true then
            Ether.updatedChannel = true
            UpdateSendChannel()
            Comm:SendCommMessage("ETHER_VERSION", Ether.version, sendChannel, nil, "NORMAL")
        end
    elseif (event == "PLAYER_LOGOUT") then
        _G.ETHER_DATABASE_DX_AA = Ether.DeepCopy(Ether.DB)
    end
end
local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("ADDON_LOADED")
Initialize:SetScript("OnEvent", OnInitialize)


