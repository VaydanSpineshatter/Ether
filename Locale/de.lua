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
L.FRAMES_TOPRIGHT        = "Oben Rechts"
L.FRAMES_BOTTOMLEFT      = "Unten Links"
L.FRAMES_BOTTOMRIGHT     = "Unten Rechts"
L.FRAMES_BOTTOM          = "Unten"
L.FRAMES_TOP             = "Oben"
L.FRAMES_LEFT            = "Links"
L.FRAMES_TOPLEFT         = "Oben Links"
L.FRAMES_CENTER          = "Mitte"
L.FRAMES_XOFFSET         = "X Versatz"
L.FRAMES_YOFFSET         = "Y Versatz"
L.FRAMES_POINT           = "Ausrichten"
L.FRAMES_RELATIVE        = "Relativer Punkt"
L.FRAMES_SCALE           = "Skalierung"
L.FRAMES_OPACITY         = "Transparenz"
L.FRAMES_SELECT          = "Frame Auswählen"
L.FRAMES_WIDTH           = "Breite"
L.FRAMES_HEIGHT          = "Höhe"
