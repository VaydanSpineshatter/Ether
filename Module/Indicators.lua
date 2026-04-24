local D,F,S=unpack(select(2,...))
local UnitIsAFK,UnitIsDND=UnitIsAFK,UnitIsDND
local UnitIsConnected,UnitIsDeadOrGhost=UnitIsConnected,UnitIsDeadOrGhost
local UnitHasIncomingResurrection=UnitHasIncomingResurrection
local GetReadyCheckStatus=GetReadyCheckStatus
local GetPartyAssignment=GetPartyAssignment
local GetRaidTargetIndex=GetRaidTargetIndex
local Enum,IsInRaid,UnitExists=Enum,IsInRaid,UnitExists
local GetLootMethod,pairs,ipairs=C_PartyInfo.GetLootMethod,pairs,ipairs
local UnitIsGroupLeader,UnitInAnyGroup=UnitIsGroupLeader,UnitInAnyGroup
local UnitIsUnit,UnitIsCharmed,IsInGroup=UnitIsUnit,UnitIsCharmed,IsInGroup
local UnitGroupRolesAssigned,SetRaidTargetIconTexture=UnitGroupRolesAssigned,SetRaidTargetIconTexture
local event,raidBtn,soloBtn=S.EventFrame,D.raidBtn,D.soloBtn
local function GetRaidBtn(unit)
    local b=raidBtn[unit]
    if b and b.unit==unit then
        return b
    end
end
local frame=CreateFrame("Frame")
frame:SetFrameStrata("HIGH")
local function IndictorsTexture(button,data)
    if not button or not button.Indicators then return end
    local Config=D.DB[20][D:PosIndicator(data)]
    if not button.Indicators[data] then
        button.Indicators[data]=frame:CreateTexture(nil,"OVERLAY",nil,7)
        button.Indicators[data]:Hide()
        button.Indicators[data]:SetPoint(Config[1],button.healthBar,Config[1],Config[2],Config[3])
        button.Indicators[data]:SetSize(Config[4],Config[4])
    end
end
function F:SavePosition(index)
    local Config=D.DB[20][index]
    local icon=D:PosIndicator(index)
    for _,button in pairs(raidBtn) do
        if button and button.Indicators[icon] then
            button.Indicators[icon].Shown=button.Indicators[icon]:IsShown()
            button.Indicators[icon]:Hide()
            button.Indicators[icon]:ClearAllPoints()
            button.Indicators[icon]:SetPoint(Config[1],button.healthBar,Config[1],Config[2],Config[3])
            button.Indicators[icon]:SetSize(Config[4],Config[4])
            if button.Indicators[icon].Shown then
                button.Indicators[icon]:Show()
                button.Indicators[icon].Shown=nil
            end
        end
    end
end
local function UpdateHealthBar(button)
    if not button or not button.healthBar then return end
    button.healthBar:SetValue(0)
    button.healthBar:SetMinMaxValues(0,0)
end
function F:UpdateDeadIcon(button)
    if not button or not button.Indicators or not button.Indicators.UnitFlags then return end
    button.Indicators.UnitFlags:Hide()
end
function F:IndicatorsFullUpdateBtn()
    for _,b in pairs(raidBtn) do
        local unit=b.unit
        if unit and UnitExists(unit) then
            F:UpdateIndicatorsString(unit)
        end
    end
    F:UpdateIndicators()
end
function F:UpdateIndicatorsString(unit)
    event:UNIT_CONNECTION(unit)
    event:INCOMING_RESURRECT_CHANGED(unit)
    event:PLAYER_FLAGS_CHANGED(unit)
    event:UNIT_FLAGS(unit)
    event:UNIT_FACTION(unit)
end
function F:UpdateIndicators()
    event:RAID_TARGET_UPDATE()
    event:PARTY_LEADER_CHANGED()
    event:PARTY_LOOT_METHOD_CHANGED()
    event:PLAYER_ROLES_ASSIGNED()
    event:READY_CHECK()
end
function F:IndicatorsFullUpdate(unit)
    if not unit or not UnitExists(unit) then return end
    F:UpdateIndicatorsString(unit)
    F:UpdateIndicators()
end
function event:READY_CHECK()
    for _,b in pairs(raidBtn) do
        local unit=b.unit
        IndictorsTexture(b,"ReadyCheck")
        if UnitExists(unit) then
            local status=GetReadyCheckStatus(unit)
            if (status) then
                if (status=="ready") then
                    b.Indicators.ReadyCheck:SetTexture(D.iIconPath[13])
                    b.Indicators.ReadyCheck:Show()
                elseif (status=="notready") then
                    b.Indicators.ReadyCheck:SetTexture(D.iIconPath[14])
                    b.Indicators.ReadyCheck:Show()
                elseif (status=="waiting") then
                    b.Indicators.ReadyCheck:SetTexture(D.iIconPath[15])
                    b.Indicators.ReadyCheck:Show()
                end
            else
                b.Indicators.ReadyCheck:Hide()
            end
        end
    end
end
function event:READY_CHECK_CONFIRM()
    for _,b in pairs(raidBtn) do
        local unit=b.unit
        IndictorsTexture(b,"ReadyCheck")
        local status=GetReadyCheckStatus(unit)
        if (status=="ready") then
            b.Indicators.ReadyCheck:SetTexture(D.iIconPath[13])
            b.Indicators.ReadyCheck:Show()
        elseif (status=="notready") then
            b.Indicators.ReadyCheck:SetTexture(D.iIconPath[14])
            b.Indicators.ReadyCheck:Show()
        end
    end
end
local updater
updater=nil
local function HideReadyCheckIcons()
    for _,button in pairs(raidBtn) do
        if button and button.Indicators and button.Indicators.ReadyCheck then
            button.Indicators.ReadyCheck:Hide()
        end
    end
    if updater then
        updater:Cancel()
        updater=nil
    end
end
function event:READY_CHECK_FINISHED()
    if not updater then
        updater=C_Timer.After(5,HideReadyCheckIcons)
    end
end
local function UpdateGroupRole(button,unit)
    if D.DB[3][10]~=1 then return end
    IndictorsTexture(button,"GroupRole")
    if not IsInGroup() then
        button.Indicators.GroupRole:Hide()
        return
    end
    local role=UnitGroupRolesAssigned(unit)
    if (role) then
        button.Indicators.GroupRole:SetTexture(D.iIconPath[12])
        if (role=="TANK") then
            button.Indicators.GroupRole:SetTexCoord(0,19/64,22/64,41/64)
            button.Indicators.GroupRole:Show()
        elseif (role=="HEALER") then
            button.Indicators.GroupRole:SetTexCoord(20/64,39/64,1/64,20/64)
            button.Indicators.GroupRole:Show()
        elseif (role=="DAMAGER") then
            button.Indicators.GroupRole:SetTexCoord(20/64,39/64,22/64,41/64)
            button.Indicators.GroupRole:Show()
        else
            button.Indicators.GroupRole:Hide()
        end
    end
end
local function UpdateMainTank(button,unit)
    if D.DB[3][9]~=1 then return end
    IndictorsTexture(button,"MainTank")
    if not IsInRaid() then
        button.Indicators.MainTank:Hide()
        return
    end
    if GetPartyAssignment("MAINTANK",unit) then
        button.Indicators.MainTank:SetTexture(D.iIconPath[10])
        button.Indicators.MainTank:Show()
    elseif GetPartyAssignment("MAINASSIST",unit) then
        button.Indicators.MainTank:SetTexture(D.iIconPath[11])
        button.Indicators.MainTank:Show()
    else
        button.Indicators.MainTank:Hide()
    end
end
function event:PLAYER_ROLES_ASSIGNED()
    if D.DB[3][9]==0 and D.DB[3][10]==0 then return end
    for _,button in pairs(raidBtn) do
        if not button then return end
        local unit=button.unit
        local role=UnitGroupRolesAssigned(unit)
        local assignment=GetPartyAssignment("MAINTANK",unit) or GetPartyAssignment("MAINASSIST",unit)
        if role then
            UpdateGroupRole(button,unit)
        end
        if assignment then
            UpdateMainTank(button,unit)
        end
    end
end
function event:PARTY_LOOT_METHOD_CHANGED()
    if D.DB[3][8]~=1 then return end
    for _,button in pairs(raidBtn) do
        if button then
            local unit=button.unit
            IndictorsTexture(button,"MasterLoot")
            if not UnitInAnyGroup("player") then
                button.Indicators.MasterLoot:Hide()
            end
            local lootType,partyID,raidID=GetLootMethod()
            if lootType==Enum.LootMethod.Masterlooter then
                local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or
                        partyID and ((partyID==0) and "player" or "party"..partyID)
                if masterLooterUnit and UnitIsUnit(unit,masterLooterUnit) then
                    button.Indicators.MasterLoot:SetTexture(D.iIconPath[9])
                    button.Indicators.MasterLoot:Show()
                else
                    button.Indicators.MasterLoot:Hide()
                end
            end
        end
    end
end
function event:PARTY_LEADER_CHANGED()
    if D.DB[3][7]~=1 then return end
    for _,button in pairs(raidBtn) do
        if button then
            local unit=button.unit
            IndictorsTexture(button,"GroupLeader")
            if not UnitInAnyGroup("player") then
                button.Indicators.GroupLeader:Hide()
            end
            local IsLeader=UnitIsGroupLeader(unit)
            if (IsLeader) then
                button.Indicators.GroupLeader:SetTexture(D.iIconPath[8])
                button.Indicators.GroupLeader:Show()
            else
                button.Indicators.GroupLeader:Hide()
            end
        end
    end
end
function event:RAID_TARGET_UPDATE()
    if D.DB[3][6]~=1 then return end
    for _,button in pairs(raidBtn) do
        if button then
            local unit=button.unit
            IndictorsTexture(button,"RaidTarget")
            if UnitExists(unit) then
                local index=GetRaidTargetIndex(unit)
                if index then
                    button.Indicators.RaidTarget:SetTexture(D.iIconPath[7])
                    SetRaidTargetIconTexture(button.Indicators.RaidTarget,index)
                    button.Indicators.RaidTarget:Show()
                else
                    button.Indicators.RaidTarget:Hide()
                end
            end
        end
    end
    for index=1,3 do
        if UnitExists(D:PosUnit(index)) then
            F:UpdateSoloIndicator(index)
        end
    end
    if UnitExists(D:PosUnit(6)) then
        F:UpdateSoloIndicator(6)
    end
end
function event:UNIT_FACTION(unit)
    if D.DB[3][5]~=1 then return end
    local button=GetRaidBtn(unit)
    if not button then return end
    IndictorsTexture(button,"UnitFaction")
    local charmed=UnitIsCharmed(unit)
    if charmed then
        button.name:SetTextColor(1,0,0)
        button.Indicators.UnitFaction:SetTexture(D.iIconPath[6])
        button.Indicators.UnitFaction:Show()
    else
        button.name:SetTextColor(1,1,1)
        button.Indicators.UnitFaction:Hide()
    end
end
function event:UNIT_FLAGS(unit)
    if D.DB[3][4]~=1 then return end
    local button=GetRaidBtn(unit)
    if not button then return end
    IndictorsTexture(button,"UnitFlags")
    local dead=UnitIsDeadOrGhost(unit)
    if dead then
        UpdateHealthBar(button)
        F:HideButtonDispellable(button)
        F:HidePrediction(button)
        button.Indicators.UnitFlags:SetTexture(D.iIconPath[5])
        button.Indicators.UnitFlags:Show()
    else
        button.Indicators.UnitFlags:Hide()
        F:InitialHealth(button)
    end
end
function event:PLAYER_FLAGS_CHANGED(unit)
    F:UserIdle(unit)
    if D.DB[3][3]~=1 then return end
    local button=GetRaidBtn(unit)
    if not button then return end
    IndictorsTexture(button,"PlayerFlags")
    local away=UnitIsAFK(unit)
    local dnd=UnitIsDND(unit)
    if away then
        button.Indicators.PlayerFlags:SetTexture(D.iIconPath[3])
        button.Indicators.PlayerFlags:Show()
    elseif dnd then
        button.Indicators.PlayerFlags:SetTexture(D.iIconPath[4])
        button.Indicators.PlayerFlags:Show()
    else
        button.Indicators.PlayerFlags:Hide()
    end
end
function event:INCOMING_RESURRECT_CHANGED(unit)
    if D.DB[3][2]~=1 then return end
    local button=GetRaidBtn(unit)
    if not button then return end
    IndictorsTexture(button,"Resurrection")
    local Resurrect=UnitHasIncomingResurrection(unit)
    if (Resurrect) then
        button.Indicators.Resurrection:SetTexture(D.iIconPath[2])
        button.Indicators.Resurrection:Show()
    else
        button.Indicators.Resurrection:Hide()
    end
end
function event:UNIT_CONNECTION(unit)
    if D.DB[3][1]~=1 then return end
    local button=GetRaidBtn(unit)
    if not button then return end
    IndictorsTexture(button,"Connection")
    local isConnected=UnitIsConnected(unit)
    if not isConnected then
        button.healthBar:SetStatusBarColor(0.5,0.5,0.5)
        button.Indicators.Connection:SetTexture(D.iIconPath[1])
        button.Indicators.Connection:Show()
    else
        button.Indicators.Connection:Hide()
    end
end
function F:UpdateSoloIndicator(number)
    local button=soloBtn[number]
    if not button or not button.RaidTarget then return end
    if UnitExists(button.unit) then
        local index=GetRaidTargetIndex(button.unit)
        if index then
            button.RaidTarget:SetTexture(D.iIconPath[7])
            SetRaidTargetIconTexture(button.RaidTarget,index)
            button.RaidTarget:Show()
        else
            button.RaidTarget:Hide()
        end
    end
end
function F:IndicatorToggleEvent(number)
    if not number or type(number)~="number" then return end
    if D.DB[3][number]==1 then
        if not event:IsEventRegistered(D.iEvent[number]) then
            event:RegisterEvent(D.iEvent[number])
        end
    elseif D.DB[3][number]==0 then
        if event:IsEventRegistered(D.iEvent[number]) then
            event:UnregisterEvent(D.iEvent[number])
        end
    end
end
function F:IndicatorsToggleIcon(number)
    local data=D:PosIndicator(number)
    for _,button in pairs(raidBtn) do
        if not button or not button.Indicators or not button.Indicators[data] then return end
        if button.Indicators[data]:IsShown() then
            button.Indicators[data]:Hide()
        else
            button.Indicators[data]:Show()
        end
    end
    for index=1,6 do
        local button=soloBtn[index]
        if button and button.RaidTarget then
            if button.RaidTarget:IsShown() then
                button.RaidTarget:Hide()
            else
                button.RaidTarget:Show()
            end
        end
    end
end
function F:IndicatorsEnable()
    for _,v in ipairs(D.iEvent) do
        if not event:IsEventRegistered(v) then
            event:RegisterEvent(v)
        end
    end
    C_Timer.After(2,function()
        F:UpdateSoloIndicator(1)
    end)
end
function F:IndicatorsDisable()
    for _,v in ipairs(D.iEvent) do
        if event:IsEventRegistered(v) then
            event:UnregisterEvent(v)
        end
    end
end