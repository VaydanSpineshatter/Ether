local D,F,S,C=unpack(select(2,...))
local pairs,ipairs,UnitExists,C_After=pairs,ipairs,UnitExists,C_Timer.After
local event,raidBtn,soloBtn,modelBtn=S.EventFrame,D.raidBtn,D.soloBtn,D.modelBtn
local refresh,channel=false,false
local function GetModelBtn(unit)
    return modelBtn[D:PosUnit(unit)]
end
local function refreshButtons()
    C_After(2,function()
        for _,b in pairs(raidBtn) do
            if UnitExists(b.unit) then
                F:RaidAurasFullUpdate(b.unit)
            end
            F.UpdateClassColor(b)
            F.InitialHealth(b)
            F:UpdateIndicatorsString(b)
        end
        refresh=false
    end)
end
function event:GROUP_ROSTER_UPDATE()
    if not UnitInAnyGroup("player") then
        print("refresh none")
        F:AuraDisable()
        C_After(1,function()
            F:IndicatorsFullUpdateBtn()
            F:AuraEnable()
        end)
    else
        if refresh then return end
        refresh=true
        refreshButtons()
        if channel then return end
        channel=true
        C_ChatInfo.SendAddonMessage(C.EtherPrefix,C.EtherVersion,IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")         --D:ExportAddonMsg()
    end
end
function event:GROUP_JOINED()
    if UnitAffectingCombat("player") then return end
    UnitSetRole("player",D.DB["CONFIG"][13] or "NONE")
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
    local b=GetModelBtn(unit)
    if b then
        b:SetUnit(unit)
        b:SetPortraitZoom(1)
    end
end
function event:UNIT_MODEL_CHANGED(unit)
    local b=GetModelBtn(unit)
    if b then
        b:SetUnit(unit)
        b:SetPortraitZoom(1)
    end
end
function event:PLAYER_TARGET_CHANGED()
    if D.DB[1][6]==1 then
        F:UpdateSoloIndicator(2)
        if UnitExists("targettarget") then
            F:UpdateSoloIndicator(3)
        end
        if UnitExists("focus") then
            F:UpdateSoloIndicator(6)
        end
    end
    if D.DB[6][2]==1 then
        F:SoloAuraFullUpdate(soloBtn[2],"target")
    end
    F:UpdateThreatColor(35,38,"target")
    modelBtn[2]:SetUnit("target")
    modelBtn[2]:SetPortraitZoom(1)
    F:UpdateTargetCastBar("target")
    F:UpdateTargetAlpha()
    F:HidePrediction(soloBtn[2])
    F:HidePrediction(soloBtn[3])
    F:ScanTargetGUID()
end
function F:RosterDisable()
    F:AuraDisable()
    F:IndicatorsDisable()
    F:HealthDisable()
    F:PowerDisable()
    F:RangeDisable()
    F:NameDisable()
    F:MsgDisable()
    if D.DB[1][1]==1 then
        F:IconDisable()
    end
    if D.DB[1][2]==1 then
        F:MsgDisable()
    end
    if D.DB[1][3]==1 then
        F:MsgCLEUDisable()
    end
end
function F:RosterEnable()
    if D.DB[1][7]==1 then
        F:AuraEnable()
    end
    if D.DB[1][6]==1 then
        F:IndicatorsEnable()
    end
    if D.DB[1][1]==1 then
        F:IconEnable()
    end
    F:HealthEnable()
    F:PowerEnable()
    F:MsgEnable()
    F:NameEnable()
    if D.DB[1][5]==1 then
        F:RangeEnable()
    end
    for _,v in ipairs(D.rosterEvent) do
        if not event:IsEventRegistered(v) then
            event:RegisterEvent(v)
        end
    end
    for _,v in ipairs(D.threadEvent) do
        if not event:IsEventRegistered(v) then
            event:RegisterUnitEvent(v,"player","target")
        end
    end
    if D.DB[1][2]==1 then
        F:MsgEnable()
    end
    if D.DB[1][3]==1 then
        F:MsgCLEUEnable()
    end
end
