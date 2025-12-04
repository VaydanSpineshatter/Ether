local _, C             = ...
local Console          = C.Console
local Broker           = C.Broker
local L                = C.L
local _, classFilename = UnitClass("player")


if (not LibStub or not LibStub('LibDataBroker-1.1') or not LibStub('LibDBIcon-1.0')) then return end

local LDB = LibStub('LibDataBroker-1.1', true)
local LDI = LibStub('LibDBIcon-1.0', true)

Broker.Icon = LDB:NewDataObject('EtherIcon', {
	type = 'launcher',
	text = 'Ether',
	icon = unpack(C.Data.Forming.Icon)
})

local function ShowTooltip(GameTooltip)
	local classColor = C.Data.RAID_COLORS[classFilename]
	GameTooltip:SetText(Broker.Icon.text, 0, 0.8, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LEFT, 1, 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT, 1, 1, 1, 1)
	GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LOCALE, classColor.r, classColor.g, classColor.b, 1)
end

local function OnClick(_, button)
	if button == 'RightButton' then
		C.Callback.Fire('TOGGLE_SETTINGS')
	elseif button == 'LeftButton' then
		C.Callback.Fire('TOGGLE_GRID')
	end
end

local function MoveIcon()
	if C.DB['MODULES'][1] == 1 then
		LDI:Show('EtherIcon')
		Console:Output('Show Minimap Icon')
	else
		LDI:Hide('EtherIcon')
		Console:Output('Hide Minimap Icon')
	end
end

local function Compartment()
	if C.DB['MODULES'][2] == 1 then
		LDI:AddButtonToCompartment('EtherIcon')
		Console:Output('Compartment On')
	else
		LDI:RemoveButtonFromCompartment('EtherIcon')
		Console:Output('Compartment Off')
	end
end

Broker.Icon.OnTooltipShow = ShowTooltip
Broker.Icon.OnClick       = OnClick
Broker.MoveIcon           = MoveIcon
Broker.Compartment        = Compartment
