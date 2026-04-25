local D,F,S,C=unpack(select(2,...))
local pairs,ipairs,UnitExists,C_After=pairs,ipairs,UnitExists,C_Timer.After
local UnitCastingInfo,UnitChannelInfo=UnitCastingInfo,UnitChannelInfo
local event,raidBtn,soloBtn,modelBtn=S.EventFrame,D.raidBtn,D.soloBtn,D.modelBtn
local castBar,refresh,after,updatedChannel=D.castBar,false,false,false
local function GetModelBtn(unit)
    return modelBtn[D:PosUnit(unit)]
end
local function UpdateSendChannel()
    local channel
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        channel="INSTANCE_CHAT"
    elseif IsInRaid() then
        channel="RAID"
    else
        channel="PARTY"
    end
    return channel
end
local function refreshAfter()
    if not after then
        after=true
        C_After(1,function()
            for _,b in pairs(raidBtn) do
                if b and UnitExists(b.unit) then
                    F:HideButtonDispellable(b)
                    F:UpdateDeadIcon(b)
                    F:HidePrediction(b)
                    F.InitialHealth(b)
                end
            end
            for _,b in ipairs(soloBtn) do
                if b and UnitExists(b.unit) then
                    F.InitialHealth(b)
                    F.InitialPower(b)
                end
            end
            after=false
        end)
    end
end
local function refreshButtons()
    if not refresh then
        refresh=true
        C_After(2,function()
            F:ClearRaidIcons()
            for _,b in pairs(raidBtn) do
                if not UnitExists(b.unit) then return end
                F:UpdateIndicatorsString(b)
                F:RaidAurasFullUpdate(b.unit)
                F.InitialHealth(b.unit)
                F.UpdateClassColor(b)
            end
            refresh=false
        end)
    end
end
function event:GROUP_ROSTER_UPDATE()
    if not UnitInAnyGroup("player") then
        F:AuraDisable()
        C_After(1,function()
            F:AuraEnable()
            F:IndicatorsFullUpdateBtn()
        end)
    end
    refreshButtons()
    if IsInGroup() then
        if not updatedChannel then
            updatedChannel=true
            local channel=UpdateSendChannel()
            C_ChatInfo.SendAddonMessage(C.EtherPrefix,tostring(C.EtherVersion),channel)
        end
    else
        updatedChannel=false
    end
end
function event:GROUP_JOINED()
    refreshButtons()
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
function event:PLAYER_UNGHOST()
    refreshAfter()
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
        F:TargetAuraFullUpdate()
    end
    F:UpdateThreatColor(35,38,"target")
    modelBtn[2]:SetUnit("target")
    modelBtn[2]:SetPortraitZoom(1)
    local bar=castBar[2]
    if bar then
        if not UnitExists("target") or (not UnitCastingInfo("target") and not UnitChannelInfo("target")) then
            bar.casting=nil
            bar.channeling=nil
            bar.holdTime=nil
            bar:Hide()
        else
            self:UNIT_SPELLCAST_START("target")
        end
    end
    F:UpdateTargetAlpha()
    F:ScanTargetGUID()
    for _,b in ipairs(soloBtn) do
        if b.unit then
            F:FullHealthUpdate(b)
            F:FullPowerUpdate(b)
            F:UpdateName(b,6)
        end
    end
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
