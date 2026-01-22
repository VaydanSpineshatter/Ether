---@class Ether
local _, Ether = ...
local L = Ether.L
local pairs, ipairs = pairs, ipairs
Ether.version = C_AddOns.GetAddOnMetadata("Ether", "Version")
Ether.updatedChannel = false
Ether.debug = false

Ether.Header = {}
Ether.Anchor = {}

Ether.mediaPath = {
    Icon = {"Interface\\AddOns\\Ether\\Media\\Texture\\Icon.blp"},
    Font = {"Interface\\AddOns\\Ether\\Media\\Font\\expressway.ttf"},
    StatusBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\UfBar.blp"},
    BlankBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\BlankBar.tga"},
    NewBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\striped.tga"},
    OldBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\otravi.tga"}
}

Ether.SlashInfo = {
    [1] = {cmd = "/ether", desc = "Toggle Commands"},
    [2] = {cmd = "/ether settings", desc = "Toggle settings"},
    [3] = {cmd = "/ether debug", desc = "Toggle debug"},
    [4] = {cmd = "/ether rl", desc = "Reload Interface"},
    [5] = {cmd = "/ether Msg", desc = "Ether whisper enable"},

}

Ether.unitButtons = {
    raid = {},
    party = {},
    solo = {}
}

local function BuildContent(self)
    local success, msg = pcall(function()
        Ether.CreateModuleSection(self)
        Ether.CreateSlashSection(self)
        Ether.CreateHideSection(self)
        Ether.CreateSection(self)
        Ether.CreateUpdateSection(self)
        Ether.CreateAuraSettingsSection(self)
        Ether.CreateAuraCustomSection(self)
        Ether.CreateRegisterSection(self)
        Ether.CreateLayoutSection(self)
        Ether.CreateRangeSection(self)
        Ether.CreateTooltipSection(self)
        Ether.CreateConfigSection(self)
        Ether.CreateProfileSection(self)
    end)
    if not success then
        if Ether.DebugOutput then
            Ether.DebugOutput("Content creation failed - ", msg)
        else
            print("Content creation failed - ", msg)
        end
    end
end

---@class Ether_Construct
local Construct = {
    IsLoaded = false,
    IsCreated = false,
    IsSuccess = false,
    Frames = {},
    MenuButtons = {},
    ScrollFrames = {},
    DropDownTemplates = {},
    Content = {
        Children = {},
        Buttons = {
            Module = {A = {}},
            Config = {},
            Hide = {},
            Create = {A = {}},
            Auras = {A = {}, B = {}},
            Indicators = {A = {}, B = {}},
            Update = {A = {}, B = {}},
            Layout = {A = {}, B = {}, C = {}, D = {}, E = {}}
        }
    },
    Menu = {
        ["TOP"] = {
            [1] = {"Module", "Slash"},
            [2] = {"Hide", "Create", "Updates"},
            [3] = {"Aura Settings", "Aura Custom"},
            [4] = {"Register"},
            [5] = { "Comm", "Setup" },
            [6] = {"Layout", "Range", "Tooltip", "Config", "Profile"}
        },
        ["LEFT"] = {
            [1] = {"Info"},
            [2] = {"Units"},
            [3] = {"Auras"},
            [4] = {"Indicators"},
            [5] = { "Arena" },
            [6] = {"Interface"}
        },
    },
}

function Ether.ShowCategory(self, tab)
    if not self.IsLoaded then
        return
    end

    local tabLayer
    for layer = 1, 6 do
        if self.Menu["TOP"][layer] then
            for _, tabName in ipairs(self.Menu["TOP"][layer]) do
                if tabName == tab then
                    tabLayer = layer
                    break
                end
            end
        end
        if tabLayer then
            break
        end
    end

    for _, layers in pairs(self.MenuButtons) do
        for _, topBtn in pairs(layers) do
            topBtn:Hide()
        end
    end

    if tabLayer and self.MenuButtons[tabLayer] then
        for _, topBtn in pairs(self.MenuButtons[tabLayer]) do
            topBtn:Show()
        end
    end

    for _, child in pairs(self.Content.Children) do
        if child._ScrollFrame then
            child._ScrollFrame:Hide()
        else
            child:Hide()
        end
    end

    local target = self.Content.Children[tab]
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
    end
end

local function CreateSettingsScrollTab(parent, name)
    local scrollFrame = CreateFrame("ScrollFrame", name .. "Scroll", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints(parent)
    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:ClearAllPoints()
        scrollFrame.ScrollBar:SetPoint("TOPRIGHT", -5, -20)
        scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", -5, 20)
    end
    local content = CreateFrame('Frame', name, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 30, 1)
    scrollFrame:SetScrollChild(content)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur, max = self:GetVerticalScroll(), self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(max, cur - (delta * 20))))
    end)
    content._ScrollFrame = scrollFrame
    return content
end
local function CreateSettingsButtons(self, name, parent, layer, onClick, isTopButton)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(25)
    if isTopButton then
    else
        btn:SetWidth(parent:GetWidth() - 10)
    end
    btn.font = Ether.GetFont(self, btn, name, 15)
    btn.font:SetText(name)
    btn.font:SetAllPoints()
    btn.Highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.Highlight:SetAllPoints()
    btn.Highlight:SetColorTexture(1, 1, 1, .4)
    btn:SetScript("OnClick", function()
        return onClick(name, layer)
    end)
    return btn
end

local function InitializeSettings(self)
    if self.IsLoaded then
        return
    end
    local success, msg = pcall(function()
        for layer = 1, 6 do
            if self.Menu["TOP"][layer] then
                for _, name in ipairs(self.Menu["TOP"][layer]) do
                    self.Content.Children[name] = CreateSettingsScrollTab(self.Frames["Content"], name)
                    self.Content.Children[name].tex = self.Content.Children[name]:CreateTexture(nil, "BACKGROUND")
                    self.Content.Children[name].tex:SetAllPoints()
                    self.Content.Children[name].tex:SetColorTexture(0, 0, 0, 0.5)
                    self.Content.Children[name]._ScrollFrame:Hide()
                end
            end
        end
        BuildContent(self)

        for layer = 1, 6 do
            if self.Menu["TOP"][layer] then
                self.MenuButtons[layer] = {}
                local BtnConfig = {}
                for idx, itemName in ipairs(self.Menu["TOP"][layer]) do
                    local btn = CreateSettingsButtons(self, itemName, self.Frames["Top"], layer, function(btnName)
                        Ether.ShowCategory(self, btnName)
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

        local last = nil
        for layer = 1, 6 do
            if self.Menu["LEFT"][layer] then
                for _, itemName in ipairs(self.Menu["LEFT"][layer]) do
                    local btn = CreateSettingsButtons(self, itemName, self.Frames["Left"], layer, function(_, btnLayer)
                        local firstTabName = self.Menu["TOP"][btnLayer][1]
                        Ether.DB[001].LAST_TAB = firstTabName
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
                        if self.Menu["TOP"][btnLayer] and self.Menu["TOP"][btnLayer][1] then
                            Ether.ShowCategory(self, firstTabName)
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

        self.IsLoaded = true
    end)
    if not success then
        self.IsSuccess = false
        Ether.DebugOutput("Error in construct creation - ", msg)
    else
        self.IsSuccess = true
    end
end

local function ToggleSettings(self)
    if not self.IsLoaded then
        InitializeSettings(self)
    end
    if not self.IsSuccess then
        return
    end
    self.Frames["Main"]:SetShown(Ether.DB[001].SHOW)
    local category = Ether.DB[001].LAST_TAB

    if self.Content.Children[category] then
        Ether.ShowCategory(self, category)
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

local function HideBlizzard()
    if Ether.DB[101][1] == 1 then
        HiddenFrame(PlayerFrame)
    end
    if Ether.DB[101][2] == 1 then
        HiddenFrame(PetFrame)
    end
    if Ether.DB[101][3] == 1 then
        HiddenFrame(TargetFrame)
    end
    if Ether.DB[101][4] == 1 then
        HiddenFrame(FocusFrame)
    end
    if Ether.DB[101][5] == 1 then
        HiddenFrame(PlayerCastingBarFrame)
    end
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
    if Ether.DB[101][8] == 1 then
        if CompactRaidFrameManager_SetSetting then
            CompactRaidFrameManager_SetSetting('IsShown', '0')
        end
        if CompactRaidFrameManager then
            HiddenFrame(CompactRaidFrameManager)
        end
    end
    if Ether.DB[101][9] == 1 then
        HiddenFrame(MicroMenu)
    end
    if Ether.DB[101][10] == 1 then
        HiddenFrame(MainStatusTrackingBarContainer)
    end
    if Ether.DB[101][11] == 1 then
        HiddenFrame(MainMenuBar)
    end
    if Ether.DB[101][12] == 1 then
        HiddenFrame(BagsBar)
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

local playerName = UnitName("player")
local string_format = string.format
local time = time
local Comm = LibStub("AceComm-3.0")
Comm:RegisterComm("ETHER_VERSION", function(prefix, message, channel, sender)
    if sender == playerName then
        return
    end
    local theirVersion = tonumber(message)
    local myVersion = tonumber(Ether.version)
    local lastCheck = Ether.DB[001].LAST_VERSION or 0
    if (time() - lastCheck >= 9200) and theirVersion and myVersion and myVersion < theirVersion then
        Ether.DB[001].LAST_VERSION = time()
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
        icon = unpack(Ether.mediaPath.Icon)
    })

    local function OnClick(_, button)
        if button == "RightButton" then
            if Ether.DB[001].SHOW then
                Ether.DB[001].SHOW = false
            else
                Ether.DB[001].SHOW = true
            end
            ToggleSettings(Construct)
        elseif button == "LeftButton" then
            if not Ether.gridFrame then
                Ether.Setup:CreateGrid()
            end
            local isShown = Ether.gridFrame:IsShown()
            Ether.gridFrame:SetShown(not isShown)
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
local isCreating = false
local creationDelay = 0.08
local creationQueue = {}
local totEvents = {"UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_HEAL_PREDICTION"}

local function processFunc()
    if #creationQueue == 0 then
        isCreating = false
        return
    end
    tremove(creationQueue, 1)()
    C_Timer.After(creationDelay, processFunc)
end

local function targetOfTargetEvents()
    if Ether.unitButtons.solo["targettarget"] then
        for e = 1, 6 do
            Ether.unitButtons.solo["targettarget"]:RegisterUnitEvent(totEvents[e], "targettarget")
        end
    end
end
Ether.targetOfTargetEvents = targetOfTargetEvents
local function startC_Process()
    local C = Ether.DB[201]

    creationQueue[#creationQueue + 1] = function()
        Ether.Aura:Enable()
    end

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
    creationQueue[#creationQueue + 1] = function()
        Ether:UpdateIndicators()
        Ether:IndicatorsToggle()
    end

    creationQueue[#creationQueue + 1] = function()
        if not Construct.IsCreated then
            Ether.CreateMainSettings(Construct)
        end
    end

    if C[1] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("player")
        end
    end

    if C[2] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("target")
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

    creationQueue[#creationQueue + 1] = function()
        if Ether.unitButtons.solo["pet"] then
            Ether:PetCondition(Ether.unitButtons.solo["pet"])
        end
    end

    if C[5] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("pettarget")
        end
    end

    if C[6] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether:CreateUnitButtons("focus")
        end
    end

    if Ether.DB[1002][1] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.Aura.SingleAuraFullInitial(Ether.unitButtons.solo["player"])
        end
    end

    if Ether.DB[1002][2] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.Aura.SingleAuraFullInitial(Ether.unitButtons.solo["target"])
        end
    end

    creationQueue[#creationQueue + 1] = function()
        targetOfTargetEvents()
    end

    if Ether.DB[2001][1] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.CastBar.Enable("player")
        end
    end

    if Ether.DB[2001][2] == 1 then
        creationQueue[#creationQueue + 1] = function()
            Ether.CastBar.Enable("target")
        end
    end

    creationQueue[#creationQueue + 1] = function()
        local settings = Ether.RegisterPosition(Construct.Frames["Main"], 341)
        settings:InitialPosition()
        settings:InitialDrag()
    end

    creationQueue[#creationQueue + 1] = function()
        local debug = Ether.RegisterPosition(Ether.DebugFrame, 340)
        debug:InitialPosition()
        debug:InitialDrag()
    end

    if Ether.DB[401][3] == 1 then
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

        if type(_G.ETHER_DATABASE_DX_AA) ~= "table" then
            ETHER_DATABASE_DX_AA = {}
        end

        if type(ETHER_DATABASE_DX_AA[001]) ~= "table" then
            ETHER_DATABASE_DX_AA[001] = {}
        end

        if Ether.version ~= ETHER_DATABASE_DX_AA[001].VERSION then
            ETHER_DATABASE_DX_AA = Ether.DataDefault
            ETHER_DATABASE_DX_AA[001].VERSION = Ether.version
        end

        if not ETHER_DATABASE_DX_AA.profiles then
            local charKey = Ether.GetCharacterKey()
            local oldData = Ether.DeepCopy(ETHER_DATABASE_DX_AA)
            local profileData = Ether.MergeToLeft(
                    Ether.DeepCopy(Ether.DataDefault),
                    oldData
            )
            ETHER_DATABASE_DX_AA.profiles = {
                [charKey] = profileData
            }
            ETHER_DATABASE_DX_AA.currentProfile = charKey
        end

        local DB = Ether.DeepCopy(Ether.GetCurrentProfile())
        Ether.DB = DB

        self:RegisterEvent("PLAYER_LOGOUT")

        if not Ether.DebugFrame then
            Ether.Setup.CreateDebugFrame()
        end
        HideBlizzard()

    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        SLASH_ETHER1 = "/ether"
        SlashCmdList["ETHER"] = function(msg)
            local input, rest = msg:match("^(%S*)%s*(.-)$")
            input = string.lower(input or "")
            rest = string.lower(rest or "")
            if input == "settings" then
                if Ether.DB[001].SHOW then
                    Ether.DB[001].SHOW = false
                else
                    Ether.DB[001].SHOW = true
                end
                ToggleSettings(Construct)
            elseif input == "debug" then
                Ether.debug = not Ether.debug
                Ether.DebugOutput(Ether.debug and "Debug On" or "Debug Off")
            elseif input == "rl" then
                if not InCombatLockdown() then
                    ReloadUI()
                end
            elseif input == "msg" then
                Ether.EnableMsgEvents()
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
        Ether:IndicatorsToggle()
        Ether.Roster:Enable()
        Ether.hStatus:Enable()
        Ether.nStatus:Enable()
        Ether.pStatus:Enable()

        local p = Ether.RegisterPosition(Ether.Anchor.party, 338)
        p:InitialPosition()
        local r = Ether.RegisterPosition(Ether.Anchor.raid, 339)
        r:InitialPosition()
        local tooltip = CreateFrame("Frame", nil, UIParent)
        tooltip:SetFrameLevel(90)
        Ether.Anchor.tooltip = tooltip
        local tooltip_P = Ether.RegisterPosition(Ether.Anchor.tooltip, 331)
        tooltip_P:InitialPosition()
        local token = {
            [1] = 332,
            [2] = 333,
            [3] = 334,
            [4] = 335,
            [5] = 336,
            [6] = 337
        }
        local pos_Frames = {}
        for i, key in ipairs({"player", "target", "targettarget", "pet", "pettarget", "focus"}) do
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
        if Ether.DB then
            ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.DeepCopy(Ether.DB)
        end
    end
end

local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("ADDON_LOADED")
Initialize:SetScript("OnEvent", OnInitialize)


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
]]