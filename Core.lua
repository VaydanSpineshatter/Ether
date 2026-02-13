---@class Ether
local _, Ether = ...
local L = Ether.L
local pairs, ipairs = pairs, ipairs
Ether.version = ""
Ether.charKey = "Unknown-Unknown"
Ether.IsMovable = false
local updatedChannel = false
Ether.debug = false
Ether.Header = {}
Ether.Anchor = {}
Ether.playerName = UnitName("player")
local soundsRegistered = false

Ether.mediaPath = {
    etherIcon = {"Interface\\AddOns\\Ether\\Media\\Texture\\icon.blp"},
    etherEmblem = {"Interface\\AddOns\\Ether\\Media\\Texture\\emblem.png"},
    expressway = {"Interface\\AddOns\\Ether\\Media\\Font\\expressway.ttf"},
    blankBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\BlankBar.tga"},
    powerBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\otravi.tga"}
}

Ether.SlashInfo = {
    [1] = {cmd = "/ether", desc = "Toggle Commands"},
    [2] = {cmd = "/ether settings", desc = "Toggle settings"},
    [3] = {cmd = "/ether debug", desc = "Toggle debug"},
    [4] = {cmd = "/ether rl", desc = "Reload Interface"},
    [5] = {cmd = "/ether Msg", desc = "Ether whisper enable"}
}

Ether.unitButtons = {
    raid = {},
    party = {},
    solo = {}
}

local function BuildContent(self)
    local success, msg = pcall(function()
        Ether.CreateModuleSection(self)
        Ether.CreateInformationSection(self)
        Ether.CreateBlizzardSection(self)
        Ether.CreateSection(self)
        Ether.CreateUpdateSection(self)
        Ether.CreateAuraSettingsSection(self)
        Ether.CreateAuraCustomSection(self)
        Ether.CreateAuraConfigSection(self)
        Ether.CreateIndicatorsSection(self)
        Ether.CreateTooltipSection(self)
        Ether.CreateLayoutSection(self)
        Ether.CreateCastBarSection(self)
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

---@class EtherSettings
local EtherFrame = {
    IsLoaded = false,
    IsCreated = false,
    IsSuccess = false,
    Frames = {},
    Borders = {},
    Buttons = {
        Menu = {},
        Module = {A = {}},
        Config = {},
        Hide = {A = {}},
        Create = {A = {}},
        Auras = {A = {}, B = {}},
        Indicators = {A = {}},
        Update = {A = {}, B = {}},
        Tooltip = {A = {}},
        Layout = {A = {}},
        CastBar = {A = {}}
    },
    Content = {
        Children = {},
    },
    Menu = {
        ["TOP"] = {
            [1] = {"Module", "Blizzard", "About"},
            [2] = {"Create", "Updates"},
            [3] = {"Settings", "Custom", "Effects", "Helper"},
            [4] = {"Position"},
            [5] = {"Tooltip"},
            [6] = {"Layout", "CastBar", "Config"},
            [7] = {"Edit"}
        },
        ["LEFT"] = {
            [1] = {"Info"},
            [2] = {"Units"},
            [3] = {"Auras"},
            [4] = {"Indicators"},
            [5] = {"Tooltip"},
            [6] = {"Interface"},
            [7] = {"Profile"}
        }
    }
}

function Ether.ShowCategory(self, tab)
    if not self.IsLoaded then
        return
    end
    local tabLayer
    for layer = 1, 7 do
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
    for _, layers in pairs(self.Buttons.Menu) do
        for _, topBtn in pairs(layers) do
            topBtn:Hide()
        end
    end
    if tabLayer and self.Buttons.Menu[tabLayer] then
        for _, topBtn in pairs(self.Buttons.Menu[tabLayer]) do
            topBtn:Show()
        end
    end
    for _, child in pairs(self.Content.Children) do
        child:Hide()
    end
    local target = self.Content.Children[tab]
    if target then
        target:Show()
    end
end

local function CreateSettingsButtons(self, name, parent, layer, onClick, isTopButton)
    local btn = CreateFrame("Button", nil, parent)
    if isTopButton then
        btn:SetHeight(20)
        btn:SetWidth(100)
    else
        btn:SetHeight(25)
        btn:SetWidth(100)
    end
    btn.font = btn:CreateFontString(nil, "OVERLAY")
    btn.font:SetFont(unpack(Ether.mediaPath.expressway), 15, "OUTLINE")
    btn.font:SetText(name)
    btn.font:SetAllPoints()
    btn:SetScript("OnEnter", function(self)
        self.font:SetTextColor(0.00, 0.80, 1.00, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self.font:SetTextColor(1, 1, 1, 1)
    end)
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
        for layer = 1, 7 do
            if self.Menu["TOP"][layer] then
                for _, name in ipairs(self.Menu["TOP"][layer]) do
                    self.Content.Children[name] = CreateFrame("Frame", nil, self.Frames["Content"])
                    self.Content.Children[name]:SetAllPoints(self.Frames["Content"])
                    self.Content.Children[name]:Hide()
                end
            end
        end
        BuildContent(self)
        for layer = 1, 7 do
            if self.Menu["TOP"][layer] then
                self.Buttons.Menu[layer] = {}
                local BtnConfig = {}
                for idx, itemName in ipairs(self.Menu["TOP"][layer]) do
                    local btn = CreateSettingsButtons(self, itemName, self.Frames["Top"], layer, function(btnName)
                        Ether.ShowCategory(self, btnName)
                    end, true)
                    btn:Hide()
                    BtnConfig[idx] = {
                        btn = btn,
                        name = itemName,
                        width = btn:GetWidth()
                    }
                    self.Buttons.Menu[layer][itemName] = btn
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
        for layer = 1, 7 do
            if self.Menu["LEFT"][layer] then
                for _, itemName in ipairs(self.Menu["LEFT"][layer]) do
                    local btn = CreateSettingsButtons(self, itemName, self.Frames["Left"], layer, function(_, btnLayer)
                        local firstTabName = self.Menu["TOP"][btnLayer][1]
                        Ether.DB[111].LAST_TAB = firstTabName
                        for _, layers in pairs(self.Buttons.Menu) do
                            for _, topBtn in pairs(layers) do
                                topBtn:Hide()
                            end
                        end
                        if self.Buttons.Menu[btnLayer] then
                            for _, topBtn in pairs(self.Buttons.Menu[btnLayer]) do
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
        if Ether.DebugOutput then
            Ether.DebugOutput("Error in EtherFrame creation - ", msg)
        else
            Ether.DebugOutput("Error in EtherFrame creation - ", msg)
        end
    else
        self.IsSuccess = true
    end
end

function Ether:WrapMainSettingsColor(color)
    if type(color) ~= "table" then return end
    for _, borders in pairs(EtherFrame.Borders) do
        borders:SetColorTexture(unpack(color))
    end
end

function Ether.CreateMainSettings(self)
    if not self.IsCreated then
        self.Frames["Main"] = CreateFrame("Frame", "EtherUnitFrameAddon", UIParent, "BackdropTemplate")
        self.Frames["Main"]:SetFrameLevel(500)
        self.Frames["Main"]:SetSize(640, 480)
        self.Frames["Main"]:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        self.Frames["Main"]:SetBackdropColor(0.1, 0.1, 0.1, 1)
        self.Frames["Main"]:SetBackdropBorderColor(0, 0.8, 1, .7)
        self.Frames["Main"]:Hide()
        self.Frames["Main"]:SetScript("OnHide", function()
            Ether.DB[111].SHOW = false
            Ether.IsMovable = false
            if Ether.gridFrame then
                Ether.gridFrame:SetShown(false)
            end
            if Ether.debugFrame then
                Ether.debugFrame:SetShown(false)
            end
            if Ether.tooltipFrame then
                Ether.tooltipFrame:SetShown(false)
            end
            if Ether.Anchor.raid.tex then
                Ether.Anchor.raid.tex:SetShown(false)
            end
            Ether.CleanUpButtons()
            Ether:WrapMainSettingsColor({0.80, 0.40, 1.00, 1})
        end)
        tinsert(UISpecialFrames, self.Frames["Main"]:GetName())
        RegisterAttributeDriver(self.Frames["Main"], "state-visibility", "[combat]hide")
        self.Frames["Top"] = CreateFrame("Frame", nil, self.Frames["Main"])
        self.Frames["Top"]:SetPoint("TOPLEFT", 10, -15)
        self.Frames["Top"]:SetPoint("TOPRIGHT", -10, 0)
        self.Frames["Top"]:SetSize(0, 30)
        self.Frames["Bottom"] = CreateFrame('Frame', nil, self.Frames["Main"])
        self.Frames["Bottom"]:SetPoint("BOTTOMLEFT", 10, 10)
        self.Frames["Bottom"]:SetPoint("BOTTOMRIGHT", -10, 0)
        self.Frames["Bottom"]:SetSize(0, 30)
        self.Frames["Left"] = CreateFrame('Frame', nil, self.Frames["Main"])
        self.Frames["Left"]:SetPoint("TOPLEFT", self.Frames["Top"], 'BOTTOMLEFT')
        self.Frames["Left"]:SetPoint("BOTTOMLEFT", self.Frames["Bottom"], "TOPLEFT")
        self.Frames["Left"]:SetSize(100, 0)
        self.Frames["Right"] = CreateFrame("Frame", nil, self.Frames["Top"])
        self.Frames["Right"]:SetPoint("TOPRIGHT", self.Frames["Bottom"], "TOPRIGHT")
        self.Frames["Right"]:SetPoint("BOTTOMRIGHT", self.Frames["Bottom"], "TOPRIGHT")
        self.Frames["Right"]:SetSize(10, 0)
        self.Frames["Content"] = CreateFrame("Frame", nil, self.Frames["Top"])
        self.Frames["Content"]:SetPoint("TOP", self.Frames["Top"], 'BOTTOM')
        self.Frames["Content"]:SetPoint("BOTTOM", self.Frames["Bottom"], "TOP")
        self.Frames["Content"]:SetPoint("LEFT", self.Frames["Left"], "RIGHT")
        self.Frames["Content"]:SetPoint("RIGHT", self.Frames["Right"], "LEFT")
        self.Borders["TOP"] = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        self.Borders["TOP"]:SetColorTexture(0.80, 0.40, 1.00, 1)
        self.Borders["TOP"]:SetPoint("TOPLEFT", -1, 1)
        self.Borders["TOP"]:SetPoint("TOPRIGHT", 1, 1)
        self.Borders["TOP"]:SetHeight(1)
        self.Borders["BOTTOM"] = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        self.Borders["BOTTOM"]:SetColorTexture(0.80, 0.40, 1.00, 1)
        self.Borders["BOTTOM"]:SetPoint("BOTTOMLEFT", -1, -1)
        self.Borders["BOTTOM"]:SetPoint("BOTTOMRIGHT", 1, -1)
        self.Borders["BOTTOM"]:SetHeight(1)
        self.Borders["LEFT"] = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        self.Borders["LEFT"]:SetColorTexture(0.80, 0.40, 1.00, 1)
        self.Borders["LEFT"]:SetPoint("TOPLEFT", -1, 1)
        self.Borders["LEFT"]:SetPoint("BOTTOMLEFT", -1, -1)
        self.Borders["LEFT"]:SetWidth(1)
        self.Borders["RIGHT"] = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        self.Borders["RIGHT"]:SetColorTexture(0.80, 0.40, 1.00, 1)
        self.Borders["RIGHT"]:SetPoint("TOPRIGHT", 1, 1)
        self.Borders["RIGHT"]:SetPoint("BOTTOMRIGHT", 1, -1)
        self.Borders["RIGHT"]:SetWidth(1)
        local version = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
        version:SetFont(unpack(Ether.mediaPath.expressway), 15, "OUTLINE")
        version:SetPoint("BOTTOMRIGHT", -10, 3)
        version:SetText("Beta Build |cE600CCFF" .. Ether.version .. "|r")
        local menuIcon = self.Frames["Bottom"]:CreateTexture(nil, "ARTWORK")
        menuIcon:SetSize(32, 32)
        menuIcon:SetTexture(unpack(Ether.mediaPath.etherIcon))
        menuIcon:SetPoint("BOTTOMLEFT", 0, 5)
        local name = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
        name:SetFont(unpack(Ether.mediaPath.expressway), 20, "OUTLINE")
        name:SetPoint("BOTTOMLEFT", menuIcon, "BOTTOMRIGHT", 7, 0)
        name:SetText("|cffcc66ffEther|r")
        Ether:ApplyFramePosition(self.Frames["Main"], 340)
        Ether:SetupDrag(self.Frames["Main"], 340, 40)
        local close = CreateFrame("Button", nil, self.Frames["Bottom"])
        close:SetSize(100, 15)
        close:SetPoint("BOTTOM", 0, 3)
        close.text = close:CreateFontString(nil, "OVERLAY")
        close.text:SetFont(unpack(Ether.mediaPath.expressway), 15, "OUTLINE")
        close.text:SetAllPoints()
        close.text:SetText("Close")
        close:SetScript("OnEnter", function(self)
            self.text:SetTextColor(0.00, 0.80, 1.00, 1)
        end)
        close:SetScript("OnLeave", function(self)
            self.text:SetTextColor(1, 1, 1, 1)
        end)
        close:SetScript("OnClick", function()
            self.Frames["Main"]:Hide()
        end)

        self.IsCreated = true
    end
end

local function ToggleSettings(self)
    if not self.IsLoaded then
        InitializeSettings(self)
    end
    if not self.IsSuccess then
        return
    end
    self.Frames["Main"]:SetShown(Ether.DB[111].SHOW)
    local category = Ether.DB[111].LAST_TAB

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
    if InCombatLockdown() then
        if Ether.DebugOutput then
            Ether.DebugOutput("Users in combat lockdown – Reload interface outside of combat")
        else
            print("Users in combat lockdown – Reload interface outside of combat")
        end
        return
    end
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
local Comm = LibStub("AceComm-3.0")
Comm:RegisterComm("ETHER_VERSION", function(prefix, message, channel, sender)
    if sender == playerName then
        return
    end
    local theirVersion = tonumber(message)
    local myVersion = tonumber(Ether.version)
    local lastCheck = Ether.DB[111].LAST_UPDATE_CHECK or 0
    if (time() - lastCheck >= 9200) and theirVersion and myVersion and myVersion < theirVersion then
        Ether.DB[111].LAST_UPDATE_CHECK = time()
        local msg = string_format("New version found (%d). Please visit %s to get the latest version.", theirVersion, "|cFF00CCFFhttps://www.curseforge.com/wow/addons/ether|r")
        if Ether.DebugOutput then
            Ether.DebugOutput(msg)
        else
            print(msg)
        end
    end
end)

local dataBroker
do
    if not LibStub or not LibStub("LibDataBroker-1.1") then return end
    local LDB = LibStub("LibDataBroker-1.1", true)

    dataBroker = LDB:NewDataObject("EtherIcon", {
        type = "launcher",
        icon = unpack(Ether.mediaPath.etherIcon)
    })

    local function OnClick(_, button)
        if button == "RightButton" then
            if Ether.DB[111].SHOW then
                Ether.DB[111].SHOW = false
            else
                Ether.DB[111].SHOW = true
            end
            ToggleSettings(EtherFrame)
        end
    end

    local function ShowTooltip(GameTooltip)
        GameTooltip:SetText("Ether", 0, 0.8, 1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT, 1, 1, 1, 1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LOCALE, 1, 1, 1, 1)
    end

    dataBroker.OnTooltipShow = ShowTooltip
    dataBroker.OnClick = OnClick
    Ether.dataBroker = dataBroker
end

function Ether:RefreshAllSettings()

    if not EtherFrame or not EtherFrame.Content then
        return
    end
    EtherFrame.Frames["Main"]:Hide()
    if EtherFrame.Buttons.Module and EtherFrame.Buttons.Module.A then
        for i = 1, #Ether.DB[401] do
            local checkbox = EtherFrame.Buttons.Module.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[401][i] == 1)
            end
        end
    end

    if EtherFrame.Buttons.Hide and EtherFrame.Buttons.Hide.A then
        for i = 1, #Ether.DB[101] do
            local checkbox = EtherFrame.Buttons.Hide.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[101][i] == 1)
            end
        end
    end

    if EtherFrame.Buttons.Create and EtherFrame.Buttons.Create.A then
        for i = 1, #Ether.DB[201] do
            local checkbox = EtherFrame.Buttons.Create.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[201][i] == 1)
            end
        end
    end

    if EtherFrame.Buttons.Tooltip and EtherFrame.Buttons.Tooltip.A then
        for i = 1, #Ether.DB[301] do
            local checkbox = EtherFrame.Buttons.Tooltip.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[301][i] == 1)
            end
        end
    end

    if EtherFrame.Buttons.Indicators and EtherFrame.Buttons.Indicators.A then
        for i = 1, #Ether.DB[501] do
            local checkbox = EtherFrame.Buttons.Indicators.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[501][i] == 1)
            end
        end
    end

    if EtherFrame.Buttons.Update and EtherFrame.Buttons.Update.A then
        for i = 1, #Ether.DB[701] do
            local checkbox = EtherFrame.Buttons.Update.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[701][i] == 1)
            end
        end
    end

    if EtherFrame.Buttons.Update and EtherFrame.Buttons.Update.B then
        local units = {
            "player", "target", "targettarget", "pet", "pettarget",
            "focus", "raid"
        }

        for i, unitKey in ipairs(units) do
            local checkbox = EtherFrame.Buttons.Update.B[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[901][unitKey] == true)
            end
        end
    end

    if EtherFrame.Buttons.Layout and EtherFrame.Buttons.Layout.A then
        for i = 1, #Ether.DB[801] do
            local checkbox = EtherFrame.Buttons.Layout.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[801][i] == 1)
            end
        end
    end
    if EtherFrame.Buttons.CastBar and EtherFrame.Buttons.CastBar.A then
        for i = 1, #Ether.DB[1201] do
            local checkbox = EtherFrame.Buttons.CastBar.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[1201][i] == 1)
            end
        end
    end
    EtherFrame.Frames["Main"]:Show()
end

function Ether:RefreshFramePositions()
    local frame = {
        [331] = Ether.Anchor.tooltip,
        [332] = Ether.unitButtons.solo["player"],
        [333] = Ether.unitButtons.solo["target"],
        [334] = Ether.unitButtons.solo["targettarget"],
        [335] = Ether.unitButtons.solo["pet"],
        [336] = Ether.unitButtons.solo["pettarget"],
        [337] = Ether.unitButtons.solo["focus"],
        [338] = Ether.Anchor.raid,
        [339] = Ether.DebugFrame,
        [340] = EtherFrame.Frames["Main"]
    }

    for frameID in pairs(Ether.DB[5111]) do
        if frameID then
            Ether:ApplyFramePosition(frame[frameID], frameID)
        end
    end
end

function Ether:ApplyFramePosition(frame, index)
    if type(index) ~= "number" then return end
    local pos = Ether.DB[5111][index]
    for i, default in ipairs({"CENTER", "UIParent", "CENTER", 0, 0, 100, 100, 1, 1}) do
        pos[i] = pos[i] or default
    end
    if frame and pos then
        local relTo = (pos[2] == "UIParent") and UIParent or frame[pos[2]]
        frame:ClearAllPoints()
        frame:SetPoint(pos[1], relTo, pos[3], pos[4], pos[5])
        frame:SetScale(pos[8])
        frame:SetAlpha(pos[9])
    end
end

local arraysLength = {
    [101] = 11, [201] = 6, [301] = 13, [401] = 6,
    [501] = 9, [701] = 4, [801] = 3,
    [1001] = 3, [1101] = 3, [1201] = 2
}

local currentVersion = nil
local function OnInitialize(self, event, ...)
    if (event == "ADDON_LOADED") then
        local loadedAddon = ...

        assert(loadedAddon == "Ether", "Unexpected addon string: " .. tostring(loadedAddon))
        assert(type(Ether.DataDefault) == "table", "Ether default database missing")
        assert(type(Ether.CopyTable) == "function", "Ether table func missing")

        self:RegisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")

        if type(_G.ETHER_DATABASE_DX_AA) ~= "table" then
            _G.ETHER_DATABASE_DX_AA = {}
        end

        if type(_G.ETHER_DATABASE_DX_AA[101]) ~= "number" then
            _G.ETHER_DATABASE_DX_AA[101] = 0
        end

        if type(_G.ETHER_ICON) ~= "table" then
            _G.ETHER_ICON = {}
        end

        self:RegisterEvent("PLAYER_LOGOUT")
    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        local charKey = Ether.GetCharacterKey()
        if not charKey then
            charKey = Ether.charKey
        end

        local version = C_AddOns.GetAddOnMetadata("Ether", "Version")
        Ether.version = version

        local REQUIREMENT_VERSION = 26766
        Ether.REQUIREMENT_VERSION = 26766
        local CURRENT_VERSION = ETHER_DATABASE_DX_AA[101]

        if CURRENT_VERSION < REQUIREMENT_VERSION then
            ETHER_DATABASE_DX_AA = {
                profiles = {
                    [charKey] = Ether.CopyTable(Ether.DataDefault)
                },
                currentProfile = charKey
            }
            ETHER_DATABASE_DX_AA[101] = REQUIREMENT_VERSION
            currentVersion = "The database is too old and will be reset.\nReload Interface."
        elseif not ETHER_DATABASE_DX_AA.profiles then
            ETHER_DATABASE_DX_AA = {
                profiles = {
                    [charKey] = Ether.CopyTable(Ether.DataDefault)
                },
                currentProfile = charKey
            }
        elseif not ETHER_DATABASE_DX_AA.profiles[charKey] then
            ETHER_DATABASE_DX_AA.profiles[charKey] = Ether.CopyTable(Ether.DataDefault)
        else
            local profile = ETHER_DATABASE_DX_AA.profiles[charKey]
            for key, value in pairs(Ether.DataDefault) do
                if profile[key] == nil then
                    profile[key] = Ether.CopyTable(value)
                end
            end
            if profile[111] then
                for subkey in pairs(Ether.DataDefault[111]) do
                    if profile[111][subkey] == nil then
                        profile[111] = Ether.CopyTable(Ether.DataDefault[111])
                        break
                    end
                end
            end
            if profile[901] then
                for subkey in pairs(Ether.DataDefault[901]) do
                    if profile[901][subkey] == nil then
                        profile[901] = Ether.CopyTable(Ether.DataDefault[901])
                        break
                    end
                end
            end
            if profile[1002] then
                for subkey in pairs(Ether.DataDefault[1002]) do
                    if profile[1002][subkey] == nil then
                        profile[1002] = Ether.CopyTable(Ether.DataDefault[1002])
                        break
                    end
                end
            end
            if profile[811] then
                for subkey in pairs(Ether.DataDefault[811]) do
                    if profile[811][subkey] == nil then
                        profile[811] = Ether.CopyTable(Ether.DataDefault[811])
                        break
                    end
                end
            end
            if profile[1201] then
                for subkey in pairs(Ether.DataDefault[1201]) do
                    if profile[1201][subkey] == nil then
                        profile[1201] = Ether.CopyTable(Ether.DataDefault[1201])
                        break
                    end
                end
            end
            if profile[1301] then
                for subkey in pairs(Ether.DataDefault[1301]) do
                    if profile[1301][subkey] == nil then
                        profile[1301] = Ether.CopyTable(Ether.DataDefault[1301])
                        break
                    end
                end
            end
            if profile[5111] then
                for subkey in pairs(Ether.DataDefault[5111]) do
                    if profile[5111][subkey] == nil then
                        profile[5111] = Ether.CopyTable(Ether.DataDefault[5111])
                        break
                    end
                end
            end
            for arrayID, expectedLength in pairs(arraysLength) do
                if profile[arrayID] and type(profile[arrayID]) == "table" then
                    if #profile[arrayID] ~= expectedLength then
                        profile[arrayID] = Ether.DataMigrate(profile[arrayID], expectedLength, 1)
                    end
                end
            end
        end

        ETHER_DATABASE_DX_AA.currentProfile = charKey
        Ether.DB = Ether.CopyTable(Ether.GetCurrentProfile())
        Ether:CreateSplitGroupHeader()
        HideBlizzard()
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        SLASH_ETHER1 = "/ether"
        SlashCmdList["ETHER"] = function(msg)
            local input, rest = msg:match("^(%S*)%s*(.-)$")
            input = string.lower(input or "")
            rest = string.lower(rest or "")
            if input == "settings" then
                if Ether.DB[111].SHOW then
                    Ether.DB[111].SHOW = false
                else
                    Ether.DB[111].SHOW = true
                end
                ToggleSettings(EtherFrame)
            elseif input == "debug" then
                Ether.debug = not Ether.debug
                Ether.DebugOutput(Ether.debug and "Debug On" or "Debug Off")
            elseif input == "rl" then
                if not InCombatLockdown() then
                    ReloadUI()
                end
            elseif input == "msg" then
                if EtherFrame.Buttons.Module.A[2] then
                    local checkbox = EtherFrame.Buttons.Module.A[2]
                    checkbox:SetChecked(not checkbox:GetChecked())
                    checkbox:GetScript("OnClick")(checkbox)
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
        if LibStub and LibStub("LibDBIcon-1.0", true) and LibStub("LibSharedMedia-3.0", true) then
            if not soundsRegistered then
                local LDI = LibStub("LibDBIcon-1.0")
                LDI:Register("EtherIcon", Ether.dataBroker, _G.ETHER_ICON)
                local LSM = LibStub("LibSharedMedia-3.0")
                LSM:Register("font", "Expressway", [[Interface\AddOns\Ether\Media\Font\expressway.ttf]])
                LSM:Register("statusbar", "BlankBar", [[Interface\AddOns\Ether\Media\StatusBar\BlankBar.tga]])
                soundsRegistered = true
            end
        end

        if not Ether.debugFrame then
            Ether:SetupDebugFrame()
        end

        if Ether.DB[401][2] == 1 then
            Ether.EnableMsgEvents()
        end
        if type(currentVersion) ~= "nil" then
            StaticPopupDialogs["ETHER_RELOAD_UI"] = {
                text = currentVersion,
                button1 = "Yes",
                button2 = "No",
                OnAccept = function(self)
                    if not InCombatLockdown() then
                        ReloadUI()
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("ETHER_RELOAD_UI")
        end
        Ether.Anchor.raid:SetSize(66, 66)
        Ether:ApplyFramePosition(Ether.Anchor.raid, 338)
        Ether.Anchor.raid.tex = Ether.Anchor.raid:CreateTexture(nil, "BACKGROUND")
        Ether.Anchor.raid.tex:SetAllPoints()
        Ether.Anchor.raid.tex:SetColorTexture(0, 1, 0, .7)
        Ether.Anchor.raid.tex:Hide()
        Ether:SetupDrag(Ether.Anchor.raid, 338, 40)

        Ether.Anchor.tooltip = CreateFrame("Frame", nil, UIParent)
        Ether.Anchor.tooltip:SetSize(280, 120)
        Ether:ApplyFramePosition(Ether.Anchor.tooltip, 331)
        Ether.CreateMainSettings(EtherFrame)

        for index = 1, 7 do
            if Ether.DB[201][index] == 1 then
                Ether:CreateUnitButtons(index)
            end
        end

        Ether.Tooltip:Initialize()

        ToggleSettings(EtherFrame)

    elseif (event == "GROUP_ROSTER_UPDATE") then
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        if IsInGroup() and updatedChannel ~= true then
            updatedChannel = true
            UpdateSendChannel()
            Comm:SendCommMessage("ETHER_VERSION", Ether.version, sendChannel, nil, "NORMAL")
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Ether:RosterEnable()
        C_Timer.After(0.8, function()
            Ether:InitializePetHeader()
            for _, button in pairs(Ether.unitButtons.raid) do
                if Ether.DB[701][3] == 1 then
                    Ether:UpdateHealthText(button)
                end
                if Ether.DB[701][4] == 1 then
                    Ether:UpdatePowerText(button)
                end
            end
        end)
    elseif (event == "PLAYER_LOGOUT") then
        local charKey = Ether.GetCharacterKey()
        if charKey then
            ETHER_DATABASE_DX_AA.profiles[charKey] = Ether.CopyTable(Ether.DB)
        end
        if charKey and ETHER_DATABASE_DX_AA.profiles[charKey] then
            ETHER_DATABASE_DX_AA.currentProfile = charKey
        end
    end
end
local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("ADDON_LOADED")
Initialize:SetScript("OnEvent", OnInitialize)



