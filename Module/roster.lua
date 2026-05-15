local D,F,S,C=unpack(select(2,...))
local pairs,ipairs,UnitExists,C_After=pairs,ipairs,UnitExists,C_Timer.After
local event,raidBtn,soloBtn,modelBtn=S.EventFrame,D.raidBtn,D.soloBtn,D.modelBtn
local refresh,send=false,false
local function UpdateModelBtn(unit)
    return modelBtn[D:PosUnit(unit)]:SetUnit(unit)
end
local function refreshButtons()
    if refresh then return end
    refresh=true
    C_After(1.6,function()
        for _,b in pairs(raidBtn) do
            if UnitExists(b.unit) then
                F:UpdateRaidAuras(b)
                F.UpdateClassColor(b)
                F.InitialHealth(b)
                F:UpdateIndicatorsUnit(b)
            end
        end
        refresh=false
    end)
end
function event:GROUP_ROSTER_UPDATE()
    if not UnitInAnyGroup("player") then
        F:AuraDisable()
        for i=1,11 do
            F:IndicatorsToggleIcon(i)
        end
        for _,b in pairs(D.raidBtn) do
            if UnitExists(b.unit) then
                F:UpdateIndicatorsUnit(b)
            end
        end
        C_After(1,function()
            F:AuraEnable()
        end)
    end
    if not UnitInAnyGroup("player") then return end
    refreshButtons()
    if send then return end
    send=true
    C_ChatInfo.SendAddonMessage(C.EtherPrefix,D:ExportAddonMsg(),IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
end
function event:GROUP_JOINED()
    F:UpdateRole(D.DB["CONFIG"][13])
end
function event:UNIT_THREAT_SITUATION_UPDATE(unit)
    if unit=="player" then
        F:UpdateThreatColor(31,34,unit)
    end
    if unit=="target" then
        F:UpdateThreatColor(35,38,unit)
    end
end
function event:UNIT_PORTRAIT_UPDATE(unit)
    UpdateModelBtn(unit)
end
function event:UNIT_MODEL_CHANGED(unit)
    UpdateModelBtn(unit)
end
function event:PLAYER_TARGET_CHANGED()
    if D.DB[1][6]==1 then
        if UnitExists("targettarget") then
            F:UpdateSoloIndicator(3)
        end
        if UnitExists("focus") then
            F:UpdateSoloIndicator(6)
        end
        if UnitExists("pet") then
            F:UpdateSoloIndicator(4)
        end
    end
    if UnitExists("target") then
        F:UpdateSoloIndicator(2)
        if D.DB[6][2]==1 then
            F:SoloAuraFullUpdate(soloBtn[2],"target")
        end
        F:UpdateThreatColor(35,38,"target")
        UpdateModelBtn("target")
        F:UpdateTargetCastBar("target")
        F:UpdateTargetAlpha()
        F:HidePrediction(soloBtn[2])
        F:ScanTargetGUID()
    end
end
function F:RosterDisable()
    F:Fire(7+30)
    for _,v in ipairs(D.threadEvent) do
        F:FuncDisable(v)
    end
    for _,v in ipairs(D.rosterEvent) do
        F:FuncDisable(v)
    end
    for index=12,13 do
        if D.DB[6][index]==1 then
            F:CastDisable(index-11)
        end
    end
    for index=1,6 do
        if D.DB[6][index]==1 then
            F:DeactivateUnitButton(index)
        end
    end
    for index=1,2 do
        F:DeactivateModelButton(index)
    end
    for index=1,12 do
        if D.DB[1][index]==1 then
            if index==1 then
                if index>=10 and index<=12 then
                    F:Fire(index+30)
                elseif index>=5 and index<=6 then
                    F:Fire(index+30)
                elseif index<=3 then
                    F:Fire(index+30)
                end
            end
        end
    end
    if D.DB[6][17]==1 then
        F:FuncDisable("MERCHANT_SHOW")
    end
end
function F:RosterEnable()
    for index=1,6 do
        if D.DB[6][index]==1 then
            F:ActivateUnitButton(index)
        end
    end
    for index=1,2 do
        F:ActivateModelButton(index)
    end
    for _,v in ipairs(D.rosterEvent) do
        F:FuncEnable(v)
    end
    for _,v in ipairs(D.threadEvent) do
        if not event:IsEventRegistered(v) then
            event:RegisterUnitEvent(v,"player","target")
        end
    end
    for index=12,13 do
        if D.DB[6][index]==1 then
            F:CastEnable(index-11)
        end
    end
    for index=1,12 do
        if D.DB[1][index]==1 then
            if index>=10 and index<=12 then
                F:Fire(index)
            elseif index>=5 and index<=6 then
                F:Fire(index)
            elseif index<=3 then
                F:Fire(index)
            end
        end
    end
    if D.DB[6][17]==1 then
        F:FuncEnable("MERCHANT_SHOW")
    end
    if D.DB[1][7]==1 then
        C_Timer.After(0.3,function()
            F:Fire(7)
        end)
    end
end