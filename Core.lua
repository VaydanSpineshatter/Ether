---@class Ether
local _, Ether = ...
local L = Ether.L
local pairs, ipairs = pairs, ipairs
Ether.version = ""
Ether.IsMovable = false
Ether.IsShown = false
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
    solo = {}
}

local function CreateSettingsButtons(name, parent, layer, onClick, isTopButton)
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

local EtherToggle
do
    ---@class EtherSettings
    local EtherFrame = {
        Created = false,
        SpellId = nil,
        Frames = {},
        Borders = {},
        Snap = {},
        Buttons = {
            Menu = {},
            [1] = {},
            [2] = {},
            [3] = {},
            [4] = {},
            [5] = {},
            [6] = {},
            [7] = {},
            [8] = {},
            [9] = {},
            [10] = {},
            [11] = {},
            [12] = {}
        },
        ["CONTENT"] = {["CHILDREN"] = {}, },
        Menu = {
            ["TOP"] = {
                [1] = {"Module", "Blizzard", "About"},
                [2] = {"Create", "Fake", "Update"},
                [3] = {"Settings", "Custom", "Effects", "Helper"},
                [4] = {"Position"},
                [5] = {"Tooltip"},
                [6] = {"Layout", "Header", "CastBar", "Config"},
                [7] = {"Edit"}
            },
            ["LEFT"] = {
                [1] = {"Info"},
                [2] = {"Units"},
                [3] = {"Aura"},
                [4] = {"Indicators"},
                [5] = {"Tooltip"},
                [6] = {"Interface"},
                [7] = {"Profile"}
            }
        }
    }

    local function ShowCategory(self, category)
        if self.Created ~= true then return end
        local tabLayer
        for layer = 1, 7 do
            if self.Menu["TOP"][layer] then
                for _, tabName in ipairs(self.Menu["TOP"][layer]) do
                    if tabName == category then
                        tabLayer = layer
                        break
                    end
                end
            end
            if tabLayer then
                break
            end
        end
        for _, layers in pairs(self.Buttons[10]) do
            for _, topBtn in pairs(layers) do
                topBtn:Hide()
            end
        end
        if tabLayer and self.Buttons[10][tabLayer] then
            for _, topBtn in pairs(self.Buttons[10][tabLayer]) do
                topBtn:Show()
            end
        end
        for _, child in pairs(self["CONTENT"]["CHILDREN"]) do
            child:Hide()
        end

        if category == "Module" then
            Ether:CreateModuleSection(EtherFrame)
        elseif category == "Blizzard" then
            Ether:CreateBlizzardSection(EtherFrame)
        elseif category == "About" then
            Ether:CreateAboutSection(EtherFrame)
        elseif category == "Create" then
            Ether:CreateCreationSection(EtherFrame)
        elseif category == "Fake" then
            Ether:CreateFakeSection(EtherFrame)
        elseif category == "Update" then
            Ether:CreateUpdateSection(EtherFrame)
        elseif category == "Settings" then
            Ether:CreateSettingsSection(EtherFrame)
        elseif category == "Custom" then
            Ether:CreateCustomSection(EtherFrame)
        elseif category == "Effects" then
            Ether:CreateEffectsSection(EtherFrame)
        elseif category == "Helper" then
            Ether:CreateHelperSection(EtherFrame)
        elseif category == "Position" then
            Ether:CreatePositionSection(EtherFrame)
        elseif category == "Tooltip" then
            Ether:CreateTooltipSection(EtherFrame)
        elseif category == "Header" then
            Ether:CreateHeaderSection(EtherFrame)
        elseif category == "Layout" then
            Ether:CreateLayoutSection(EtherFrame)
        elseif category == "CastBar" then
            Ether:CreateCastBarSection(EtherFrame)
        elseif category == "Config" then
            Ether:CreateConfigSection(EtherFrame)
        elseif category == "Edit" then
            Ether:CreateEditSection(EtherFrame)
        end

        local target = self["CONTENT"]["CHILDREN"][category]
        if target then
            target:Show()
        end
    end

    local function InitializeLayer(self)
        if not self.Created then
            for layer = 1, 7 do
                if self.Menu["TOP"][layer] then
                    for _, name in ipairs(self.Menu["TOP"][layer]) do
                        self["CONTENT"]["CHILDREN"][name] = CreateFrame("Frame", nil, self.Frames["CONTENT"])
                        self["CONTENT"]["CHILDREN"][name]:SetAllPoints(self.Frames["CONTENT"])
                        self["CONTENT"]["CHILDREN"][name]:Hide()
                    end
                end
            end
            for layer = 1, 7 do
                if self.Menu["TOP"][layer] then
                    self.Buttons[10][layer] = {}
                    local BtnConfig = {}
                    for idx, itemName in ipairs(self.Menu["TOP"][layer]) do
                        local btn = CreateSettingsButtons(itemName, self.Frames["TOP"], layer, function(btnName)
                            ShowCategory(self, btnName)
                        end, true)
                        btn:Hide()
                        BtnConfig[idx] = {
                            btn = btn,
                            name = itemName,
                            width = btn:GetWidth()
                        }
                        self.Buttons[10][layer][itemName] = btn
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
                            data.btn:SetPoint("CENTER", self.Frames["TOP"], "CENTER", currentX + data.width / 2, 5)
                            currentX = currentX + data.width + spacing
                        end
                    end
                end
            end
            local last = nil
            for layer = 1, 7 do
                if self.Menu["LEFT"][layer] then
                    for _, itemName in ipairs(self.Menu["LEFT"][layer]) do
                        local btn = CreateSettingsButtons(itemName, self.Frames["LEFT"], layer, function(_, btnLayer)
                            local firstTabName = self.Menu["TOP"][btnLayer][1]
                            Ether.DB[111].LAST_TAB = firstTabName
                            for _, layers in pairs(self.Buttons[10]) do
                                for _, topBtn in pairs(layers) do
                                    topBtn:Hide()
                                end
                            end
                            if self.Buttons[10][btnLayer] then
                                for _, topBtn in pairs(self.Buttons[10][btnLayer]) do
                                    topBtn:Show()
                                end
                            end
                            if self.Menu["TOP"][btnLayer] and self.Menu["TOP"][btnLayer][1] then
                                ShowCategory(self, firstTabName)
                            end
                        end, false)

                        if last then
                            btn:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 0)
                            btn:SetPoint("TOPRIGHT", last, "BOTTOMRIGHT", 0, -2)
                        else
                            btn:SetPoint("TOPLEFT", self.Frames["LEFT"], "TOPLEFT", 5, 0)
                            btn:SetPoint("TOPRIGHT", self.Frames["LEFT"], "TOPRIGHT", -10, 0)
                        end
                        last = btn
                    end
                end
            end
            self.Created = true
        end
    end
    local function ShowHideSettings(state)
        if InCombatLockdown() then return end
        if state then
            wipe(EtherFrame.Snap)
            EtherFrame.Snap = Ether.DataSnapShot(Ether.DB[401])
        end
        if not Ether.gridFrame then
            Ether:SetupGridFrame()
        end
        if not Ether.debugFrame then
            Ether:SetupDebugFrame()
        end
        Ether.IsMovable = state
        Ether.gridFrame:SetShown(state)
        if Ether.tooltipFrame and Ether.DB[401][3] == 1 then
            Ether.tooltipFrame:SetShown(state)
            Ether.DB[401][3] = 0
        end
        Ether.debugFrame:SetShown(state)
        if Ether.Anchor.raid.tex then
            Ether.Anchor.raid.tex:SetShown(state)
        end
        Ether:HideCastBar("player", state)
        Ether:HideCastBar("target", state)
        if not state then
            Ether.DataRestore(Ether.DB[401], EtherFrame.Snap)
            Ether.CleanUpButtons()
            Ether.WrapSettingsColor({0.80, 0.40, 1.00, 1})
        end
    end
    local function CreateMainFrame(self)
        if not self.Created then
            self.Frames["MAIN"] = CreateFrame("Frame", "EtherUnitFrameAddon", UIParent, "BackdropTemplate")
            self.Frames["MAIN"]:SetFrameLevel(500)
            self.Frames["MAIN"]:SetSize(640, 480)
            self.Frames["MAIN"]:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            self.Frames["MAIN"]:SetBackdropColor(0.1, 0.1, 0.1, 1)
            self.Frames["MAIN"]:SetBackdropBorderColor(0, 0.8, 1, .7)
            self.Frames["MAIN"]:Hide()
            tinsert(UISpecialFrames, self.Frames["MAIN"]:GetName())
            for _, value in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
                self.Frames[value] = CreateFrame("Frame", nil, self.Frames["MAIN"])
            end
            self.Frames["MAIN"]:SetScript("OnShow", function()
                Ether.DB[111].SHOW = true
            end)
            self.Frames["MAIN"]:SetScript("OnHide", function()
                Ether.DB[111].SHOW = false
            end)
            self.Frames["TOP"]:SetPoint("TOPLEFT", 10, -15)
            self.Frames["TOP"]:SetPoint("TOPRIGHT", -10, 0)
            self.Frames["TOP"]:SetSize(0, 30)
            self.Frames["BOTTOM"]:SetPoint("BOTTOMLEFT", 10, 10)
            self.Frames["BOTTOM"]:SetPoint("BOTTOMRIGHT", -10, 0)
            self.Frames["BOTTOM"]:SetSize(0, 30)
            self.Frames["LEFT"]:SetPoint("TOPLEFT", self.Frames["TOP"], "BOTTOMLEFT")
            self.Frames["LEFT"]:SetPoint("BOTTOMLEFT", self.Frames["BOTTOM"], "TOPLEFT")
            self.Frames["LEFT"]:SetSize(100, 0)
            self.Frames["RIGHT"]:SetPoint("TOPRIGHT", self.Frames["BOTTOM"], "TOPRIGHT")
            self.Frames["RIGHT"]:SetPoint("BOTTOMRIGHT", self.Frames["BOTTOM"], "TOPRIGHT")
            self.Frames["RIGHT"]:SetSize(10, 0)
            self.Frames["CONTENT"] = CreateFrame("Frame", nil, self.Frames["TOP"])
            self.Frames["CONTENT"]:SetPoint("TOP", self.Frames["TOP"], "BOTTOM")
            self.Frames["CONTENT"]:SetPoint("BOTTOM", self.Frames["BOTTOM"], "TOP")
            self.Frames["CONTENT"]:SetPoint("LEFT", self.Frames["LEFT"], "RIGHT")
            self.Frames["CONTENT"]:SetPoint("RIGHT", self.Frames["RIGHT"], "LEFT")
            for index, value in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
                self.Borders[value] = self.Frames["CONTENT"]:CreateTexture(nil, "BORDER")
                self.Borders[value]:SetColorTexture(0.80, 0.40, 1.00, 1)
                if index == 1 or index == 2 then
                    self.Borders[value]:SetHeight(1)
                else
                    self.Borders[value]:SetWidth(1)
                end
            end
            self.Borders["TOP"]:SetPoint("TOPLEFT", -1, 1)
            self.Borders["TOP"]:SetPoint("TOPRIGHT", 1, 1)
            self.Borders["BOTTOM"]:SetPoint("BOTTOMLEFT", -1, -1)
            self.Borders["BOTTOM"]:SetPoint("BOTTOMRIGHT", 1, -1)
            self.Borders["LEFT"]:SetPoint("TOPLEFT", -1, 1)
            self.Borders["LEFT"]:SetPoint("BOTTOMLEFT", -1, -1)
            self.Borders["RIGHT"]:SetPoint("TOPRIGHT", 1, 1)
            self.Borders["RIGHT"]:SetPoint("BOTTOMRIGHT", 1, -1)
            self.Frames["INDICATORS"] = CreateFrame("Frame", nil, self.Frames["MAIN"])
            self.Frames["AURAS"] = CreateFrame("Frame", nil, self.Frames["MAIN"])
            self.Frames["EDITOR"] = CreateFrame("Frame", nil, self.Frames["MAIN"])
            self.Frames["EDITOR"].Created = false
            self.Frames["AURAS"].Created = false
            local version = self.Frames["BOTTOM"]:CreateFontString(nil, "OVERLAY")
            version:SetFont(unpack(Ether.mediaPath.expressway), 15, "OUTLINE")
            version:SetPoint("BOTTOMRIGHT", -10, 3)
            version:SetText("Beta Build |cE600CCFF" .. Ether.version .. "|r")
            local menuIcon = self.Frames["BOTTOM"]:CreateTexture(nil, "ARTWORK")
            menuIcon:SetSize(32, 32)
            menuIcon:SetTexture(unpack(Ether.mediaPath.etherIcon))
            menuIcon:SetPoint("BOTTOMLEFT", 0, 5)
            local name = self.Frames["BOTTOM"]:CreateFontString(nil, "OVERLAY")
            name:SetFont(unpack(Ether.mediaPath.expressway), 20, "OUTLINE")
            name:SetPoint("BOTTOMLEFT", menuIcon, "BOTTOMRIGHT", 7, 0)
            name:SetText("|cffcc66ffEther|r")
            Ether:ApplyFramePosition(self.Frames["MAIN"], 340)
            Ether:SetupDrag(self.Frames["MAIN"], 340, 40)
            local close = CreateFrame("Button", nil, self.Frames["BOTTOM"])
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
                self.Frames["MAIN"]:Hide()
                ShowHideSettings(false)
                if Ether.TableSize(EtherFrame.Snap) > 0 then
                    Ether.DataRestore(Ether.DB[401], EtherFrame.Snap)
                end
            end)
            InitializeLayer(self)
        end
    end
    function EtherToggle()
        CreateMainFrame(EtherFrame)
        if InCombatLockdown() then return end
        if EtherFrame.Frames["MAIN"]:IsShown() then
            EtherFrame.Frames["MAIN"]:Hide()
        else
            EtherFrame.Frames["MAIN"]:Show()
        end
        local category = Ether.DB[111].LAST_TAB
        if EtherFrame["CONTENT"]["CHILDREN"][category] then
            ShowCategory(EtherFrame, category)
        end
    end

    local function WrapSettingsColor(color)
        if type(color) ~= "table" then return end
        for _, borders in pairs(EtherFrame.Borders) do
            borders:SetColorTexture(unpack(color))
        end
    end
    Ether.UIPanel = EtherFrame
    Ether.WrapSettingsColor = WrapSettingsColor
    Ether.ShowHideSettings = ShowHideSettings
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
    if InCombatLockdown() then return end
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

local string_format = string.format
local Comm = LibStub("AceComm-3.0")
Comm:RegisterComm("ETHER_VERSION", function(prefix, message, channel, sender)
    if sender == Ether.playerName then
        return
    end
    local theirVersion = tonumber(message)
    local myVersion = tonumber(Ether.version)
    local lastCheck = Ether.DB[111].LAST_CHECK or 0
    if (time() - lastCheck >= 9200) and theirVersion and myVersion and myVersion < theirVersion then
        Ether.DB[111].LAST_CHECK = time()
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
    if not LibStub or not LibStub("LibDataBroker-1.1", true) then return end
    local LDB = LibStub("LibDataBroker-1.1")

    dataBroker = LDB:NewDataObject("EtherIcon", {
        type = "launcher",
        icon = unpack(Ether.mediaPath.etherIcon)
    })

    local function OnClick(_, button)
        if button == "RightButton" then
            EtherToggle()
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
        [340] = Ether.UIPanel.Frames["MAIN"],
        [341] = Ether.unitButtons.solo["player"].castBar,
        [342] = Ether.unitButtons.solo["target"].castBar
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

        if type(_G.ETHER_DATABASE_DX_AA["VERSION"]) ~= "number" then
            _G.ETHER_DATABASE_DX_AA["VERSION"] = 0
        end

        if type(_G.ETHER_ICON) ~= "table" then
            _G.ETHER_ICON = {}
        end

        self:RegisterEvent("PLAYER_LOGOUT")
    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        Ether:CreatePopupBox()

        local charKey = Ether:GetCharacterKey() or "Unknown-Unknown"
        local version = C_AddOns.GetAddOnMetadata("Ether", "Version")
        Ether.version = version

        local REQUIREMENT_VERSION = 26766
        local CURRENT_VERSION = ETHER_DATABASE_DX_AA["VERSION"]

        if CURRENT_VERSION < REQUIREMENT_VERSION then
            ETHER_DATABASE_DX_AA = {
                profiles = {
                    [charKey] = Ether.CopyTable(Ether.DataDefault)
                },
                currentProfile = charKey
            }
            ETHER_DATABASE_DX_AA["VERSION"] = REQUIREMENT_VERSION
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
            for info in pairs(Ether.DataDefault) do
                if profile[info] == nil then
                    profile[info] = Ether.CopyTable(Ether.DataDefault)
                end
            end
            for _, info in ipairs({111, 701, 811, 1002, 1201, 1301, 1401, 1501, 5111}) do
                Ether:NilCheckData(profile, info)
            end
            Ether:ArrayMigrateData(profile)
        end

        ETHER_DATABASE_DX_AA.currentProfile = charKey
        Ether.DB = Ether.CopyTable(Ether:GetCurrentProfile())
        Ether.REQUIREMENT_VERSION = REQUIREMENT_VERSION
        Ether:CreateGroupHeader()
        Ether:CreatePetHeader()
        if Ether.DB[1501][1] == 1 then
            Ether:ChangeDirectionHeader(true)
        end
        HideBlizzard()
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        SLASH_ETHER1 = "/ether"
        SlashCmdList["ETHER"] = function(msg)
            local input, rest = msg:match("^(%S*)%s*(.-)$")
            input = string.lower(input or "")
            rest = string.lower(rest or "")
            if input == "settings" then
                EtherToggle()
            elseif input == "debug" then
                Ether.debug = not Ether.debug
                Ether.DebugOutput(Ether.debug and "Debug On" or "Debug Off")
            elseif input == "rl" then
                if not InCombatLockdown() then
                    ReloadUI()
                end
            elseif input == "msg" then
                Ether:EtherFrameSetClick(1, 2)
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

        if Ether.DB[401][2] == 1 then
            Ether.EnableMsgEvents()
        end

        EtherToggle()

        Ether.Anchor.raid:SetSize(32, 32)
        Ether:ApplyFramePosition(Ether.Anchor.raid, 338)
        Ether.Anchor.raid.tex = Ether.Anchor.raid:CreateTexture(nil, "BACKGROUND")
        Ether.Anchor.raid.tex:SetAllPoints()
        Ether.Anchor.raid.tex:SetColorTexture(0, 1, 0, .7)
        Ether.Anchor.raid.tex:Hide()
        Ether:SetupDrag(Ether.Anchor.raid, 338, 40)
        Ether.Anchor.tooltip = CreateFrame("Frame", nil, UIParent)
        Ether.Anchor.tooltip:SetSize(280, 120)
        Ether:ApplyFramePosition(Ether.Anchor.tooltip, 331)
        Ether.Tooltip:Initialize()

        for _, unit in ipairs({"player", "target", "targettarget", "pet", "pettarget", "focus"}) do
            Ether:CreateUnitButtons(unit)
        end

        self:RegisterEvent("PLAYER_REGEN_DISABLED")
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
    elseif (event == "PLAYER_LOGOUT") then
        local charKey = Ether:GetCharacterKey()
        if charKey then
            ETHER_DATABASE_DX_AA.profiles[charKey] = Ether.CopyTable(Ether.DB)
        end
        if charKey and ETHER_DATABASE_DX_AA.profiles[charKey] then
            ETHER_DATABASE_DX_AA.currentProfile = charKey
        end
    elseif (event == "PLAYER_REGEN_DISABLED") then
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        if Ether.UIPanel.Frames["MAIN"]:IsShown() then
            Ether.UIPanel.Frames["MAIN"]:Hide()
            Ether.ShowHideSettings(false)
            Ether.IsShown = true
        end
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        if Ether.IsShown then
            Ether.UIPanel.Frames["MAIN"]:Show()
            Ether.IsShown = false
            --   ShowHideSettings(true)

        end
    end
end
local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("ADDON_LOADED")
Initialize:SetScript("OnEvent", OnInitialize)