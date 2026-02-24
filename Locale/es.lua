local Ether=select(2,...)
if Ether.Locale~="esES" and Ether.Locale~="esMX" then
    return
end
local L=Ether.L
L.MINIMAP_TOOLTIP_LOCALE="[esES/esMX]"
L.MINIMAP_TOOLTIP_RIGHT="Clic derecho: Configuración"
--Tooltip
L.TT_UNKNOWN="DESCONOCIDO"
L.TT_AIMING_YOU="|cffff0000te está apuntando|r"
L.TT_AIMING="apunta a"