local Ether = select(2, ...)

if Ether.Locale ~= "deDE" then
	return
end

local L                  = Ether.L

L.MINIMAP_TOOLTIP_LOCALE = "[deDE]"
L.MINIMAP_TOOLTIP_LEFT   = "Left Click: Grid"
L.MINIMAP_TOOLTIP_RIGHT  = "Right Click: Settings"

L.ETHER_UI               = "Reload"
L.ETHER_RESET            = "Data Reset"
L.ETHER_GRID             = 'Grid'

L.FRAMES_RIGHT           = "Rechts"
L.FRAMES_TOPRIGHT        = "ObenRechts"
L.FRAMES_BOTTOMLEFT      = "UntenLinks"
L.FRAMES_BOTTOMRIGHT     = "UntenRechts"
L.FRAMES_BOTTOM          = "Unten"
L.FRAMES_TOP             = "Oben"
L.FRAMES_LEFT            = "Links"
L.FRAMES_TOPLEFT         = "ObenLinks"
L.FRAMES_CENTER          = "Mitte"
L.FRAMES_XOFFSET         = "XVersatz"
L.FRAMES_YOFFSET         = "YVersatz"
L.FRAMES_POINT           = "Ausrichten"
L.FRAMES_RELATIVE        = "RelativerPunkt"
L.FRAMES_SCALE           = "Skalierung"
L.FRAMES_OPACITY         = "Transparenz"
L.FRAMES_SELECT          = "Frame Auswählen"
L.FRAMES_WIDTH           = "Breite"
L.FRAMES_HEIGHT          = "Höhe"


--Tooltip
L.TT_UNKNOWN                = "UNBEKANNT"
L.TT_AIMING_YOU             = "|cffff0000zielt auf dich|r"
L.TT_AIMING                 = "visiert"