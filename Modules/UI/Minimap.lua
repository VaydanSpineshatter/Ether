local _, addonTable = ...
local L = LOCALIZATION_L

addonTable.Modules.Minimap = addonTable.Modules.Minimap or {
    initialized = false,
    dataBroker = nil
}

local Minimap = addonTable.Modules.Minimap

local function InitMinimapDB()
    ETHERWATCH_ICON_DB = ETHERWATCH_ICON_DB or {
        version = 1,
        minimap = {
            hide = false,
            radius = 80,
            lock = false
        }
    };
    ETHERWATCH_ICON_DB.minimap = ETHERWATCH_ICON_DB.minimap or {}
end

function Minimap:Initialize()
    if self.initialized then return true end

    if db.profile.Minimap.Enabled == false then return false end

    InitMinimapDB()

    local LDB = LibStub("LibDataBroker-1.1", true)
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)

    if not LDB or not LibDBIcon then
        return false
    end

    self.dataBroker = LDB:NewDataObject("EtherWatch", {
        type = "data source",
        text = "EtherWatch",
        icon = "Interface\\AddOns\\EtherWatch\\Textures\\Icons\\Icon.png",
        OnClick = function(_, _)
            local Dialog = LibStub("AceConfigDialog-3.0", true)
            if Dialog then
                if Dialog.OpenFrames["EtherWatch"] then
                    Dialog:Close("EtherWatch")
                else
                    Dialog:Open("EtherWatch")
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip.SetText or not tooltip.AddLine then return end
            if not addonTable.Store or not addonTable.Store.HexToRGB1 then return end

            if L.MINIMAP_TOOLTIP_HEADER then
                local r, g, b = addonTable.Store.HexToRGB1("00ccff")
                tooltip:SetText(L.MINIMAP_TOOLTIP_HEADER, r, g, b)
            end
            if L.MINIMAP_TOOLTIP_NAME then
                local r, g, b = addonTable.Store.HexToRGB1("cffcc66ff")
                tooltip:AddLine(L.MINIMAP_TOOLTIP_NAME, r, g, b)
            end
            if L.MINIMAP_TOOLTIP_FOOTER then
                local r, g, b = addonTable.Store.HexToRGB1("00ccff")
                tooltip:AddLine(L.MINIMAP_TOOLTIP_FOOTER, r, g, b)
            end
        end
    });

    LibDBIcon:Register("EtherWatch", self.dataBroker, ETHERWATCH_ICON_DB.minimap)

    self.initialized = true
    return true
end

function Minimap:Show()
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    if LibDBIcon then
        LibDBIcon:Show("EtherWatch")
        ETHERWATCH_ICON_DB.minimap.hide = false
    end
end

function Minimap:Hide()
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    if LibDBIcon then
        LibDBIcon:Hide("EtherWatch")
        ETHERWATCH_ICON_DB.minimap.hide = true
    end
end

function Minimap:Toggle()
    if ETHERWATCH_ICON_DB.minimap.hide then
        self:Show()
    else
        self:Hide()
    end
end

function Minimap:IsShown()
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    if LibDBIcon and LibDBIcon:IsRegistered("EtherWatch") then
        local button = LibDBIcon:GetMinimapButton("EtherWatch")
        return button and button:IsShown()
    end
    return false
end

function Minimap:ResetToDefaults()
    ETHERWATCH_ICON_DB.minimap = {
        hide = false,
        radius = 80,
        lock = false
    };
    if not self:IsShown() then
        self:Show()
    end
end
