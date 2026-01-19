local Ether = select(2, ...)

if Ether.Locale ~= "enUS" and Ether.Locale ~= "enGB" then
	return
end

local L                  = Ether.L

L.MINIMAP_TOOLTIP_LOCALE = "[enUS/enGB]"
L.MINIMAP_TOOLTIP_LEFT   = "Left Click: Grid"
L.MINIMAP_TOOLTIP_RIGHT  = "Right Click: Settings"

L.ETHER_UI               = "ReloadUI"
L.ETHER_RESET            = "ResetData"
L.ETHER_GRID             = 'Grid'

L.FRAMES_RIGHT           = "Right"
L.FRAMES_TOPRIGHT        = "TopRight"
L.FRAMES_BOTTOMLEFT      = "BottomLeft"
L.FRAMES_BOTTOMRIGHT     = "BottomRight"
L.FRAMES_BOTTOM          = "Bottom"
L.FRAMES_TOP             = "Top"
L.FRAMES_LEFT            = "Left"
L.FRAMES_TOPLEFT         = "TopLeft"
L.FRAMES_CENTER          = "Center"
L.FRAMES_XOFFSET         = "XOffset"
L.FRAMES_YOFFSET         = "YOffset"
L.FRAMES_POINT           = "Location"
L.FRAMES_RELATIVE        = "Align Point"
L.FRAMES_SCALE           = "Scale"
L.FRAMES_OPACITY         = "Opacity"
L.FRAMES_SELECT          = "Select Frame"
L.FRAMES_WIDTH           = "Width"
L.FRAMES_HEIGHT          = "Height"


--Tooltip
L.TT_UNKNOWN                = "UNKNOWN"
L.TT_AIMING_YOU             = "|cffff0000is aiming at you|r"
L.TT_AIMING                 = "aims at"

