local D,F,S=unpack(select(2,...))
local UnitIsAFK,UnitIsDND,UnitIsConnected,UnitIsDeadOrGhost=UnitIsAFK,UnitIsDND,UnitIsConnected,UnitIsDeadOrGhost
local UnitHasIncomingResurrection,Enum,UnitExists=UnitHasIncomingResurrection,Enum,UnitExists
local GetReadyCheckStatus,GetPartyAssignment,GetRaidTargetIndex,updater=GetReadyCheckStatus,GetPartyAssignment,GetRaidTargetIndex,nil
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
local function IndictorsTexture(b,data)
    if not b or not b.Indicators then return end
    local Config=D.DB[20][D:PosIndicator(data)]
    if not b.Indicators[data] then
        b.Indicators[data]=frame:CreateTexture(nil,"OVERLAY",nil,7)
        b.Indicators[data]:SetPoint(Config[1],b.healthBar,Config[1],Config[2],Config[3])
        b.Indicators[data]:SetSize(Config[4],Config[4])
        b.Indicators[data]:Hide()
        return b
    end
end
function F:SavePosition(index)
    local Config=D.DB[20][index]
    local icon=D:PosIndicator(index)
    for _,b in pairs(raidBtn) do
        if b.Indicators and b.Indicators[icon] then
            b.Indicators[icon].Shown=b.Indicators[icon]:IsShown()
            b.Indicators[icon]:Hide()
            b.Indicators[icon]:ClearAllPoints()
            b.Indicators[icon]:SetPoint(Config[1],b.healthBar,Config[1],Config[2],Config[3])
            b.Indicators[icon]:SetSize(Config[4],Config[4])
            if b.Indicators[icon].Shown then
                b.Indicators[icon]:Show()
                b.Indicators[icon].Shown=nil
            end
        end
    end
end
function F:SaveBtnPosition(b)
    if not b or not b.Indicators or not b.healthBar then return end
    for i,v in ipairs(D.iIconTable) do
        local c=D.DB[20][i]
        if not b.Indicators[v] then
            b.Indicators[v]=frame:CreateTexture(nil,"OVERLAY",nil,7)
            b.Indicators[v]:SetPoint(c[1],b.healthBar,c[1],c[2],c[3])
            b.Indicators[v]:SetSize(c[4],c[4])
        else
            b.Indicators[v]:SetPoint(c[1],b.healthBar,c[1],c[2],c[3])
            b.Indicators[v]:SetSize(c[4],c[4])
        end
        if not UnitInAnyGroup("player") then
            b.Indicators[v]:Hide()
        end
    end
end
local function UpdateGroupRole(b,unit)
    if D.DB[3][10]~=1 then return end
    IndictorsTexture(b,"GroupRole")
    if not IsInGroup() then
        b.Indicators.GroupRole:Hide()
        return
    end
    local role=UnitGroupRolesAssigned(unit)
    if (role) then
        b.Indicators.GroupRole:SetTexture(D.iIconPath[12])
        if (role=="TANK") then
            b.Indicators.GroupRole:SetTexCoord(0,19/64,22/64,41/64)
            b.Indicators.GroupRole:Show()
        elseif (role=="HEALER") then
            b.Indicators.GroupRole:SetTexCoord(20/64,39/64,1/64,20/64)
            b.Indicators.GroupRole:Show()
        elseif (role=="DAMAGER") then
            b.Indicators.GroupRole:SetTexCoord(20/64,39/64,22/64,41/64)
            b.Indicators.GroupRole:Show()
        else
            b.Indicators.GroupRole:Hide()
        end
    end
end
local function UpdateMainTank(b,unit)
    if D.DB[3][9]~=1 then return end
    IndictorsTexture(b,"MainTank")
    if not IsInGroup() and b.Indicators.MainTank then
        b.Indicators.MainTank:Hide()
        return
    end
    if GetPartyAssignment("MAINTANK",unit) then
        b.Indicators.MainTank:SetTexture(D.iIconPath[10])
        b.Indicators.MainTank:Show()
    else
        b.Indicators.MainTank:Hide()
    end
end
local function UpdateMainAssist(b,unit)
    if D.DB[3][9]~=1 then return end
    IndictorsTexture(b,"MainTank")
    if not IsInGroup() and b.Indicators.MainTank then
        b.Indicators.MainTank:Hide()
        return
    end
    if GetPartyAssignment("MAINASSIST",unit) then
        b.Indicators.MainTank:SetTexture(D.iIconPath[11])
        b.Indicators.MainTank:Show()
    else
        b.Indicators.MainTank:Hide()
    end
end
function event:PLAYER_ROLES_ASSIGNED()
    if D.DB[3][9]==0 and D.DB[3][10]==0 then return end
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            local unit=b.unit
            local role=UnitGroupRolesAssigned(unit)
            if role then
                UpdateGroupRole(b,unit)
            end
            local tank=GetPartyAssignment("MAINTANK",unit)
            if tank then
                UpdateMainTank(b,unit)
            end
            local assist=GetPartyAssignment("MAINASSIST",unit)
            if assist then
                UpdateMainAssist(b,unit)
            end
        end
    end
end
function event:PARTY_LOOT_METHOD_CHANGED()
    if D.DB[3][8]~=1 then return end
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            local unit=b.unit
            IndictorsTexture(b,"MasterLoot")
            if not UnitInAnyGroup("player") and b.Indicators.MasterLoot then
                b.Indicators.MasterLoot:Hide()
                return
            end
            local lootType,partyID,raidID=GetLootMethod()
            if lootType==Enum.LootMethod.Masterlooter then
                local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or
                        partyID and ((partyID==0) and "player" or "party"..partyID)
                if masterLooterUnit and UnitIsUnit(unit,masterLooterUnit) then
                    b.Indicators.MasterLoot:SetTexture(D.iIconPath[9])
                    b.Indicators.MasterLoot:Show()
                else
                    b.Indicators.MasterLoot:Hide()
                end
            end
        end
    end
end
function event:PARTY_LEADER_CHANGED()
    if D.DB[3][7]~=1 then return end
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            local unit=b.unit
            IndictorsTexture(b,"GroupLeader")
            if not UnitInAnyGroup("player") and b.Indicators.GroupLeader then
                b.Indicators.GroupLeader:Hide()
                return
            end
            local IsLeader=UnitIsGroupLeader(unit)
            if (IsLeader) then
                b.Indicators.GroupLeader:SetTexture(D.iIconPath[8])
                b.Indicators.GroupLeader:Show()
            else
                b.Indicators.GroupLeader:Hide()
            end
        end
    end
end
local function raidPlayerRoles(self)
    if D.DB[3][9]==0 and D.DB[3][10]==0 then return end
    local role=UnitGroupRolesAssigned(self.unit)
    local assignment=GetPartyAssignment("MAINTANK",self.unit) or GetPartyAssignment("MAINASSIST",self.unit)
    if role then
        UpdateGroupRole(self,self.unit)
    end
    if assignment then
        UpdateMainTank(self,self.unit)
    end
end
local function raidMasterLoot(self)
    if D.DB[3][8]~=1 then return end
    IndictorsTexture(self,"MasterLoot")
    if not UnitInAnyGroup("player") then
        self.Indicators.MasterLoot:Hide()
    end
    local lootType,partyID,raidID=GetLootMethod()
    if lootType==Enum.LootMethod.Masterlooter then
        local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or
                partyID and ((partyID==0) and "player" or "party"..partyID)
        if masterLooterUnit and UnitIsUnit(self.unit,masterLooterUnit) then
            self.Indicators.MasterLoot:SetTexture(D.iIconPath[9])
            self.Indicators.MasterLoot:Show()
        else
            self.Indicators.MasterLoot:Hide()
        end
    end
end
local function raidGroupLeader(self)
    if D.DB[3][7]~=1 then return end
    IndictorsTexture(self,"GroupLeader")
    if not UnitInAnyGroup("player") then
        self.Indicators.GroupLeader:Hide()
    end
    local IsLeader=UnitIsGroupLeader(self.unit)
    if (IsLeader) then
        self.Indicators.GroupLeader:SetTexture(D.iIconPath[8])
        self.Indicators.GroupLeader:Show()
    else
        self.Indicators.GroupLeader:Hide()
    end
end
local function raidTarget(self)
    if D.DB[3][6]~=1 then return end
    IndictorsTexture(self,"RaidTarget")
    local index=GetRaidTargetIndex(self.unit)
    if index then
        self.Indicators.RaidTarget:SetTexture(D.iIconPath[7])
        SetRaidTargetIconTexture(self.Indicators.RaidTarget,index)
        self.Indicators.RaidTarget:Show()
    else
        self.Indicators.RaidTarget:Hide()
    end
end
function F:IndicatorsFullUpdateBtn()
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            F:UpdateIndicatorsString(b)
        end
    end
end
function F:UpdateIndicatorsString(self)
    event:UNIT_CONNECTION(self.unit)
    event:PLAYER_FLAGS_CHANGED(self.unit)
    event:UNIT_FLAGS(self.unit)
    event:UNIT_FACTION(self.unit)
    raidTarget(self)
    raidGroupLeader(self)
    raidMasterLoot(self)
    raidPlayerRoles(self)
    for index=1,3 do
        if UnitExists(D:PosUnit(index)) then
            F:UpdateSoloIndicator(index)
        end
    end
    if UnitExists(D:PosUnit(6)) then
        F:UpdateSoloIndicator(6)
    end
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

function event:RAID_TARGET_UPDATE()
    if D.DB[3][6]~=1 then return end
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            local unit=b.unit
            IndictorsTexture(b,"RaidTarget")
            local index=GetRaidTargetIndex(unit)
            if index then
                b.Indicators.RaidTarget:SetTexture(D.iIconPath[7])
                SetRaidTargetIconTexture(b.Indicators.RaidTarget,index)
                b.Indicators.RaidTarget:Show()
            else
                b.Indicators.RaidTarget:Hide()
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
    local b=GetRaidBtn(unit)
    if not b then return end
    IndictorsTexture(b,"UnitFaction")
    local charmed=UnitIsCharmed(unit)
    if charmed then
        b.name:SetTextColor(1,0,0)
        b.Indicators.UnitFaction:SetTexture(D.iIconPath[6])
        b.Indicators.UnitFaction:Show()
    else
        b.name:SetTextColor(1,1,1)
        b.Indicators.UnitFaction:Hide()
    end
end
function event:UNIT_FLAGS(unit)
    if D.DB[3][4]~=1 then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    IndictorsTexture(b,"UnitFlags")
    local dead=UnitIsDeadOrGhost(unit)
    if dead then
        b.Indicators.UnitFlags:SetTexture(D.iIconPath[5])
        b.Indicators.UnitFlags:Show()
    else
        b.Indicators.UnitFlags:Hide()
        F.InitialHealth(b)
    end
end
function event:PLAYER_FLAGS_CHANGED(unit)
    if unit=="player" then
        F:UserIdle(unit)
    end
    if D.DB[3][3]~=1 then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    IndictorsTexture(b,"PlayerFlags")
    local away=UnitIsAFK(unit)
    local dnd=UnitIsDND(unit)
    if away then
        b.Indicators.PlayerFlags:SetTexture(D.iIconPath[3])
        b.Indicators.PlayerFlags:Show()
    elseif dnd then
        b.Indicators.PlayerFlags:SetTexture(D.iIconPath[4])
        b.Indicators.PlayerFlags:Show()
    else
        b.Indicators.PlayerFlags:Hide()
    end
end
function event:INCOMING_RESURRECT_CHANGED(unit)
    if D.DB[3][2]~=1 then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    IndictorsTexture(b,"Resurrection")
    local Resurrect=UnitHasIncomingResurrection(unit)
    if (Resurrect) then
        b.Indicators.Resurrection:SetTexture(D.iIconPath[2])
        b.Indicators.Resurrection:Show()
    else
        b.Indicators.Resurrection:Hide()
    end
end
function event:UNIT_CONNECTION(unit)
    if D.DB[3][1]~=1 then return end
    local b=GetRaidBtn(unit)
    if not b then return end
    IndictorsTexture(b,"Connection")
    local isConnected=UnitIsConnected(unit)
    if not isConnected then
        F.UpdateClassColor(b)
        b.Indicators.Connection:SetTexture(D.iIconPath[1])
        b.Indicators.Connection:Show()
    else
        F.UpdateClassColor(b)
        b.Indicators.Connection:Hide()
    end
    for index=1,3 do
        F:UpdateSoloIndicator(index)
    end
    F:UpdateSoloIndicator(6)
end
function F:UpdateSoloIndicator(number)
    local b=soloBtn[number]
    if not b then return end
    local unit=b.unit
    local index=GetRaidTargetIndex(unit)
    if index and b.RaidTarget then
        b.RaidTarget:SetTexture(D.iIconPath[7])
        SetRaidTargetIconTexture(b.RaidTarget,index)
        b.RaidTarget:Show()
    else
        b.RaidTarget:Hide()
    end
    if not b.UnitConnection then return end
    local isConnected=UnitIsConnected(unit)
    if not isConnected then
        b.UnitConnection:SetTexture(D.iIconPath[1])
        F.UpdateClassColor(b)
        b.UnitConnection:Show()
    else
        F.UpdateClassColor(b)
        b.UnitConnection:Hide()
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
    for _,b in pairs(raidBtn) do
        if b and b.Indicators and b.Indicators[data] then
            if b.Indicators[data]:IsShown() then
                b.Indicators[data]:Hide()
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
    C_Timer.After(1,function()
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