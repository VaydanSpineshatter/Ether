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
L.FRAMES_TOPRIGHT        = "Top Right"
L.FRAMES_BOTTOMLEFT      = "Bottom Left"
L.FRAMES_BOTTOMRIGHT     = "Bottom Right"
L.FRAMES_BOTTOM          = "Bottom"
L.FRAMES_TOP             = "Top"
L.FRAMES_LEFT            = "Left"
L.FRAMES_TOPLEFT         = "Top Left"
L.FRAMES_CENTER          = "Center"
L.FRAMES_XOFFSET         = "X Offset"
L.FRAMES_YOFFSET         = "Y Offset"
L.FRAMES_POINT           = "Location"
L.FRAMES_RELATIVE        = "Align Point"
L.FRAMES_SCALE           = "Scale"
L.FRAMES_OPACITY         = "Opacity"
L.FRAMES_SELECT          = "Select Frame"
L.FRAMES_WIDTH           = "Width"
L.FRAMES_HEIGHT          = "Height"
