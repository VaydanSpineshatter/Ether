local _,_,_,_,L=unpack(select(2,...))
if L.Locale~="esES" and L.Locale~="esMX" then
    return
end
L.MINIMAP_TOOLTIP_LOCALE="[esES/esMX]"
L.MINIMAP_TOOLTIP_RIGHT="Clic derecho: Configuración"
--Tooltip
L.TT_UNKNOWN="DESCONOCIDO"
L.TT_AIMING_YOU="|cffff0000te está apuntando|r"
L.TT_AIMING="apunta a"
--Status
L.HEALTH_PCT="Salud %"
L.POWER_PCT="Potencia %"
--Header
L.SORT_BY_H="Ordenado por: "
L.DIRECTION_BY_H="Orientación según: "