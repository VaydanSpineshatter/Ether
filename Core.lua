---@class Ether
local _, Ether = ...
local L = Ether.L
local pairs, ipairs = pairs, ipairs
Ether.version = ""
Ether.charKey = "Unknown-Unknown"
Ether.statusMigration = ""
Ether.updatedChannel = false
Ether.debug = false
local panelIsCreated = false
Ether.Header = {}
Ether.Anchor = {}

Ether.mediaPath = {
    Icon = {"Interface\\AddOns\\Ether\\Media\\Texture\\Icon.blp"},
    Font = {"Interface\\AddOns\\Ether\\Media\\Font\\expressway.ttf"},
    statusBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\UfBar.blp"},
    soloBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\striped.tga"},
    powerBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\otravi.tga"},
    headerBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\header.tga"},
    predictionBar = {"Interface\\AddOns\\Ether\\Media\\StatusBar\\BlankBar.tga"},
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
            Hide = {A = {}},
            Create = {A = {}},
            Auras = {A = {}, B = {}},
            Indicators = {A = {}, B = {}},
            Update = {A = {}, B = {}},
            Tooltip = {A = {}},
            Layout = {A = {}}
        }
    },
    Menu = {
        ["TOP"] = {
            [1] = {"Module", "Slash"},
            [2] = {"Hide", "Create", "Updates"},
            [3] = {"Aura Settings", "Aura Custom"},
            [4] = {"Register"},
            [5] = {"Comm", "Setup"},
            [6] = {"Layout", "Tooltip", "Config", "Profile"}
        },
        ["LEFT"] = {
            [1] = {"Info"},
            [2] = {"Units"},
            [3] = {"Auras"},
            [4] = {"Indicators"},
            [5] = {"Arena"},
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

function Ether.CreateMainSettings(self)
    if not self.IsCreated then
        self.Frames["Main"] = CreateFrame("Frame", "EtherUnitFrameAddon", UIParent, "BackdropTemplate")
        self.Frames["Main"]:SetFrameLevel(400)
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
            Ether.DB[001].SHOW = false
        end)
        tinsert(UISpecialFrames, self.Frames["Main"]:GetName())
        RegisterAttributeDriver(self.Frames["Main"], "state-visibility", "[combat]hide")
        local btnX = CreateFrame("Button", nil, self.Frames["Main"], "GameMenuButtonTemplate")
        btnX:SetPoint("TOPRIGHT", -10, -10)
        btnX:SetSize(28, 28)
        btnX:SetScript("OnClick", function()
            self.Frames["Main"]:Hide()
        end)
        self.Frames["Top"] = CreateFrame("Frame", nil, self.Frames["Main"])
        self.Frames["Top"]:SetPoint("TOPLEFT", 10, -10)
        self.Frames["Top"]:SetPoint("TOPRIGHT", -10, 0)
        self.Frames["Top"]:SetSize(0, 40)
        self.Frames["Bottom"] = CreateFrame('Frame', nil, self.Frames["Main"])
        self.Frames["Bottom"]:SetPoint("BOTTOMLEFT", 10, 10)
        self.Frames["Bottom"]:SetPoint("BOTTOMRIGHT", -10, 0)
        self.Frames["Bottom"]:SetSize(0, 30)
        self.Frames["Left"] = CreateFrame('Frame', nil, self.Frames["Main"])
        self.Frames["Left"]:SetPoint("TOPLEFT", self.Frames["Top"], 'BOTTOMLEFT')
        self.Frames["Left"]:SetPoint("BOTTOMLEFT", self.Frames["Bottom"], "TOPLEFT")
        self.Frames["Left"]:SetSize(110, 0)
        self.Frames["Right"] = CreateFrame("Frame", nil, self.Frames["Top"])
        self.Frames["Right"]:SetPoint("TOPRIGHT", self.Frames["Bottom"], "TOPRIGHT")
        self.Frames["Right"]:SetPoint("BOTTOMRIGHT", self.Frames["Bottom"], "TOPRIGHT")
        self.Frames["Right"]:SetSize(10, 0)
        self.Frames["Content"] = CreateFrame("Frame", nil, self.Frames["Top"])
        self.Frames["Content"]:SetPoint("TOP", self.Frames["Top"], 'BOTTOM')
        self.Frames["Content"]:SetPoint("BOTTOM", self.Frames["Bottom"], "TOP")
        self.Frames["Content"]:SetPoint("LEFT", self.Frames["Left"], "RIGHT")
        self.Frames["Content"]:SetPoint("RIGHT", self.Frames["Right"], "LEFT")
        local top = self.Frames["Content"]:CreateTexture(nil, 'BORDER')
        top:SetColorTexture(1, 1, 1, 1)
        top:SetPoint("TOPLEFT", -2, 2)
        top:SetPoint("TOPRIGHT", 2, 2)
        top:SetHeight(1)
        local bottom = self.Frames["Content"]:CreateTexture(nil, 'BORDER')
        bottom:SetColorTexture(1, 1, 1, 1)
        bottom:SetPoint("BOTTOMLEFT", -2, -2)
        bottom:SetPoint("BOTTOMRIGHT", 2, -2)
        bottom:SetHeight(1)
        local left = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        left:SetColorTexture(1, 1, 1, 1)
        left:SetPoint("TOPLEFT", -2, 2)
        left:SetPoint("BOTTOMLEFT", -2, -2)
        left:SetWidth(1)
        local right = self.Frames["Content"]:CreateTexture(nil, "BORDER")
        right:SetColorTexture(1, 1, 1, 1)
        right:SetPoint("TOPRIGHT", 2, 2)
        right:SetPoint("BOTTOMRIGHT", 2, -2)
        right:SetWidth(1)
        local version = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
        version:SetFont(unpack(Ether.mediaPath.Font), 15, "OUTLINE")
        version:SetPoint("BOTTOMRIGHT", -10, 3)
        version:SetText("Beta Build |cE600CCFF" .. Ether.version .. "|r")
        local menuIcon = self.Frames["Bottom"]:CreateTexture(nil, "ARTWORK")
        menuIcon:SetSize(32, 32)
        menuIcon:SetTexture(unpack(Ether.mediaPath.Icon))
        menuIcon:SetPoint("BOTTOMLEFT", 0, 5)
        local name = self.Frames["Bottom"]:CreateFontString(nil, "OVERLAY")
        name:SetFont(unpack(Ether.mediaPath.Font), 20, "OUTLINE")
        name:SetPoint("BOTTOMLEFT", menuIcon, "BOTTOMRIGHT", 7, 0)
        name:SetText("|cffcc66ffEther|r")
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
    local lastCheck = Ether.DB[001].LAST_UPDATE_CHECK or 0
    if (time() - lastCheck >= 9200) and theirVersion and myVersion and myVersion < theirVersion then
        Ether.DB[001].LAST_UPDATE_CHECK = time()
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
            if not panelIsCreated then return end
            if Ether.DB[001].SHOW then
                Ether.DB[001].SHOW = false
            else
                Ether.DB[001].SHOW = true
            end
            ToggleSettings(Construct)
        elseif button == "LeftButton" then
            if not Ether.gridFrame then
                Ether:SetupGridFrame()
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

function Ether.RefreshAllSettings()

    if not Construct or not Construct.Content then
        return
    end

    if Construct.Content.Buttons.Module and Construct.Content.Buttons.Module.A then
        for i = 1, #Ether.DB[401] do
            local checkbox = Construct.Content.Buttons.Module.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[401][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Hide and Construct.Content.Buttons.Hide.A then
        for i = 1, #Ether.DB[101] do
            local checkbox = Construct.Content.Buttons.Hide.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[101][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Create and Construct.Content.Buttons.Create.A then
        for i = 1, #Ether.DB[201] do
            local checkbox = Construct.Content.Buttons.Create.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[201][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Tooltip and Construct.Content.Buttons.Tooltip.A then
        for i = 1, #Ether.DB[301] do
            local checkbox = Construct.Content.Buttons.Tooltip.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[301][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Indicators and Construct.Content.Buttons.Indicators.A then
        for i = 1, #Ether.DB[501] do
            local checkbox = Construct.Content.Buttons.Indicators.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[501][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Indicators and Construct.Content.Buttons.Indicators.B then
        for i = 1, #Ether.DB[601] do
            local checkbox = Construct.Content.Buttons.Indicators.B[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[601][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Update and Construct.Content.Buttons.Update.A then
        for i = 1, #Ether.DB[701] do
            local checkbox = Construct.Content.Buttons.Update.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[701][i] == 1)
            end
        end
    end

    if Construct.Content.Buttons.Update and Construct.Content.Buttons.Update.B then
        local units = {
            "player", "target", "targettarget", "pet", "pettarget",
            "focus", "raid"
        }

        for i, unitKey in ipairs(units) do
            local checkbox = Construct.Content.Buttons.Update.B[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[901][unitKey] == true)
            end
        end
    end

    if Construct.Content.Buttons.Layout and Construct.Content.Buttons.Layout.A then
        for i = 1, #Ether.DB[801] do
            local checkbox = Construct.Content.Buttons.Layout.A[i]
            if checkbox then
                checkbox:SetChecked(Ether.DB[801][i] == 1)
            end
        end
    end
end

function Ether.RefreshFramePositions()

    local frames = {
        [331] = Ether.Anchor.tooltip,
        [332] = Ether.Anchor.player,
        [333] = Ether.Anchor.target,
        [334] = Ether.Anchor.targettarget,
        [335] = Ether.Anchor.pet,
        [336] = Ether.Anchor.pettarget,
        [337] = Ether.Anchor.focus,
        [338] = Ether.Anchor.raid,
        [339] = Ether.DebugFrame,
        [340] = Construct.Frames["Main"]
    }

    for frameID, frame in pairs(frames) do
        if frame and Ether.DB[5111][frameID] then
            local pos = Ether.DB[5111][frameID]

            for i, default in ipairs({"CENTER", 5133, "CENTER", 0, 0, 100, 100, 1, 1}) do
                pos[i] = pos[i] or default
            end

            local relTo = (pos[2] == 5133) and UIParent or frames[pos[2]] or UIParent

            if frame.SetPoint then
                frame:ClearAllPoints()
                frame:SetPoint(pos[1], relTo, pos[3], pos[4], pos[5])
                frame:SetSize(pos[6], pos[7])
                frame:SetScale(pos[8])
                frame:SetAlpha(pos[9])

                Ether.Fire("FRAME_UPDATED", frameID)
            end
        end
    end
end

local function OnInitialize(self, event, ...)
    if (event == "ADDON_LOADED") then
        local loadedAddon = ...

        assert(loadedAddon == "Ether", "Unexpected addon string: " .. tostring(loadedAddon))
        assert(type(Ether.DataDefault) == "table", "Ether default database missing")
        assert(type(Ether.MergeToLeft) == "function" and type(Ether.CopyTable) == "function", "Ether table func missing")

        self:RegisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")

        if type(_G.ETHER_DATABASE_DX_AA) ~= "table" then
            _G.ETHER_DATABASE_DX_AA = {}
        end

        self:RegisterEvent("PLAYER_LOGOUT")
    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        local charKey = Ether.GetCharacterKey()
        if not charKey then
            charKey = Ether.charKey
        end

        if not ETHER_DATABASE_DX_AA.profiles then
            local profileData = Ether.MergeToLeft(
                    Ether.CopyTable(Ether.DataDefault),
                    ETHER_DATABASE_DX_AA
            )
            ETHER_DATABASE_DX_AA = {
                profiles = {
                    [charKey] = profileData
                },
                currentProfile = charKey
            }

        elseif not ETHER_DATABASE_DX_AA.profiles[charKey] then
            ETHER_DATABASE_DX_AA.profiles[charKey] = Ether.CopyTable(Ether.DataDefault)
        end

        ETHER_DATABASE_DX_AA.currentProfile = charKey

        Ether:MigrateArraysOnLogin()

        Ether.DB = Ether.CopyTable(Ether.GetCurrentProfile())

        local version = C_AddOns.GetAddOnMetadata("Ether", "Version")

        Ether.version = version
        HideBlizzard()

        SLASH_ETHER1 = "/ether"
        SlashCmdList["ETHER"] = function(msg)
            local input, rest = msg:match("^(%S*)%s*(.-)$")
            input = string.lower(input or "")
            rest = string.lower(rest or "")
            if input == "settings" then
                if not panelIsCreated then
                    return
                end
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
                if Construct.Content.Buttons.Module.A[2] then
                    local checkbox = Construct.Content.Buttons.Module.A[2]
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

        if (LibStub and LibStub("LibDBIcon-1.0")) then
            if type(_G.ETHER_ICON) ~= "table" then
                ETHER_ICON = {}
            end
            local LDI = LibStub("LibDBIcon-1.0", true)
            LDI:Register("EtherIcon", Ether.dataBroker, ETHER_ICON)
        end
        if not Ether.DebugFrame then
            Ether:SetupDebugFrame()
        end

        Ether:RosterEnable()
        if Ether.DB[401][2] == 1 then
            Ether.EnableMsgEvents()
        end

        local r = Ether.RegisterPosition(Ether.Anchor.raid)
        r:InitialPosition(338)
        local tooltip = CreateFrame("Frame", nil, UIParent)
        tooltip:SetFrameLevel(400)
        Ether.Anchor.tooltip = tooltip
        local tooltip_P = Ether.RegisterPosition(Ether.Anchor.tooltip)
        tooltip_P:InitialPosition(331)
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
                pos_Frames["pos_" .. key] = Ether.RegisterPosition(Ether.Anchor[key])
                pos_Frames["pos_" .. key]:InitialPosition(token[i])
            end
        end

        Ether.CreateMainSettings(Construct)
        if Ether.DB[201][1] == 1 then
            Ether:CreateUnitButtons("player")
        end
        if Ether.DB[201][2] == 1 then
            Ether:CreateUnitButtons("target")
        end
        if Ether.DB[201][3] == 1 then
            Ether:CreateUnitButtons("targettarget")
        end
        if Ether.DB[201][4] == 1 then
            Ether:CreateUnitButtons("pet")
        end
        if Ether.unitButtons.solo["pet"] then
            Ether:PetCondition(Ether.unitButtons.solo["pet"])
        end
        if Ether.DB[201][5] == 1 then
            Ether:CreateUnitButtons("pettarget")
        end
        if Ether.DB[201][6] == 1 then
            Ether:CreateUnitButtons("focus")
        end
        if Ether.DB[1001][1] == 1 then
            Ether:SingleAuraFullInitial(Ether.unitButtons.solo["player"])
        end
        if Ether.DB[1001][2] == 1 then
            Ether:SingleAuraFullInitial(Ether.unitButtons.solo["target"])
        end
        Ether.registerToTEvents()
        if Ether.DB[801][1] == 1 then
            Ether.CastBar.Enable("player")
        end
        if Ether.DB[801][2] == 1 then
            Ether.CastBar.Enable("target")
        end
        local settings = Ether.RegisterPosition(Construct.Frames["Main"])
        settings:InitialPosition(340)
        settings:InitialDrag(340)

        Ether.Tooltip:Initialize()

        ToggleSettings(Construct)

        panelIsCreated = true


    elseif (event == "GROUP_ROSTER_UPDATE") then
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        if IsInGroup() and Ether.updatedChannel ~= true then
            Ether.updatedChannel = true
            UpdateSendChannel()
            Comm:SendCommMessage("ETHER_VERSION", Ether.version, sendChannel, nil, "NORMAL")
        end
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
