local D,F,S=unpack(select(2,...))
local UnitIsAFK,UnitIsDND,UnitIsConnected,UnitIsDeadOrGhost=UnitIsAFK,UnitIsDND,UnitIsConnected,UnitIsDeadOrGhost
local UnitHasIncomingResurrection,Enum,UnitExists=UnitHasIncomingResurrection,Enum,UnitExists
local GetReadyCheckStatus,GetPartyAssignment,GetRaidTargetIndex,updater=GetReadyCheckStatus,GetPartyAssignment,GetRaidTargetIndex,nil
local GetLootMethod,pairs,ipairs,petBtn=C_PartyInfo.GetLootMethod,pairs,ipairs,D.petBtn
local UnitIsGroupLeader,UnitInAnyGroup=UnitIsGroupLeader,UnitInAnyGroup
local UnitIsUnit,UnitIsCharmed=UnitIsUnit,UnitIsCharmed
local UnitGroupRolesAssigned,SetRaidTargetIconTexture=UnitGroupRolesAssigned,SetRaidTargetIconTexture
local event,raidBtn,soloBtn=S.EventFrame,D.raidBtn,D.soloBtn
local function GetRaidBtn(arg1)
    if not raidBtn[arg1] then return end
    local b=raidBtn[arg1]
    if arg1==b.unit and b:IsVisible() then
        return b
    end
end
local function GetPetBtn(arg1)
    if not petBtn[arg1] then return end
    local b=petBtn[arg1]
    if b and UnitExists(b.unit) then
        if b:IsVisible() then
            return b
        end
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
function F:SaveRaidBtnPosition(b)
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
        if not b.Indicators[v]:IsShown() then
            b.Indicators[v]:Hide()
        end
    end
end
function F:SavePetBtnPosition(b)
    if not b or not b.Indicators or not b.healthBar then return end
    for i,v in ipairs(D.iIconTable) do
        if i==2 or i==6 then
            local c=D.DB[20][i]
            if not b.Indicators[v] then
                b.Indicators[v]=frame:CreateTexture(nil,"OVERLAY",nil,7)
                b.Indicators[v]:SetPoint(c[1],b.healthBar,c[1],c[2],c[3])
                b.Indicators[v]:SetSize(c[4],c[4])
            else
                b.Indicators[v]:SetPoint(c[1],b.healthBar,c[1],c[2],c[3])
                b.Indicators[v]:SetSize(c[4],c[4])
            end
            if not b.Indicators[v]:IsShown() then
                b.Indicators[v]:Hide()
            end
        end
    end
end
local function groupAssignments(self)
    local assignment=GetPartyAssignment("MAINTANK",self.unit) or GetPartyAssignment("MAINASSIST",self.unit)
    IndictorsTexture(self,"MainTank")
    if assignment then
        if GetPartyAssignment("MAINTANK",self.unit) then
            self.Indicators.MainTank:SetTexture(D.iIconPath[10])
            self.Indicators.MainTank:Show()
        elseif GetPartyAssignment("MAINASSIST",self.unit) then
            self.Indicators.MainTank:SetTexture(D.iIconPath[11])
            self.Indicators.MainTank:Show()
        else
            self.Indicators.MainTank:Hide()
        end
    end
end
local function groupRole(self)
    local role=UnitGroupRolesAssigned(self.unit)
    if role then
        IndictorsTexture(self,"GroupRole")
        self.Indicators.GroupRole:SetTexture(D.iIconPath[12])
        if (role=="TANK") then
            self.Indicators.GroupRole:SetTexCoord(0,19/64,22/64,41/64)
            self.Indicators.GroupRole:Show()
        elseif (role=="HEALER") then
            self.Indicators.GroupRole:SetTexCoord(20/64,39/64,1/64,20/64)
            self.Indicators.GroupRole:Show()
        elseif (role=="DAMAGER") then
            self.Indicators.GroupRole:SetTexCoord(20/64,39/64,22/64,41/64)
            self.Indicators.GroupRole:Show()
        else
            self.Indicators.GroupRole:Hide()
        end
    end
end
function event:PLAYER_ROLES_ASSIGNED()
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            groupRole(b)
            groupAssignments(b)
        end
    end
end
function event:PARTY_LOOT_METHOD_CHANGED()
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
local function raidMasterLoot(self)
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
    IndictorsTexture(self,"GroupLeader")
    if not UnitInAnyGroup("player") then
        self.Indicators.GroupLeader:Hide()
    end
    local IsLeader=UnitIsGroupLeader(self.unit)
    if IsLeader then
        self.Indicators.GroupLeader:SetTexture(D.iIconPath[8])
        self.Indicators.GroupLeader:Show()
    else
        self.Indicators.GroupLeader:Hide()
    end
end
local function raidTarget(self)
    IndictorsTexture(self,"RaidTarget")
    if UnitExists(self.unit) then
        local index=GetRaidTargetIndex(self.unit)
        if index then
            self.Indicators.RaidTarget:SetTexture(D.iIconPath[7])
            SetRaidTargetIconTexture(self.Indicators.RaidTarget,index)
            self.Indicators.RaidTarget:Show()
        else
            self.Indicators.RaidTarget:Hide()
        end
    end
end
local function unitConnection(self)
    IndictorsTexture(self,"Connection")
    local isConnected=UnitIsConnected(self.unit)
    if not isConnected then
        F.UpdateClassColor(self)
        self.Indicators.Connection:SetTexture(D.iIconPath[1])
        self.Indicators.Connection:Show()
    else
        F.UpdateClassColor(self)
        self.Indicators.Connection:Hide()
    end
end
local function unitFaction(self)
    IndictorsTexture(self,"UnitFaction")
    local charmed=UnitIsCharmed(self.unit)
    if charmed then
        self.name:SetTextColor(1,0,0)
        self.Indicators.UnitFaction:SetTexture(D.iIconPath[6])
        self.Indicators.UnitFaction:Show()
    else
        self.name:SetTextColor(1,1,1)
        self.Indicators.UnitFaction:Hide()
    end
end
local function unitFlags(self)
    IndictorsTexture(self,"UnitFlags")
    local dead=UnitIsDeadOrGhost(self.unit)
    local status=D.DB["CONFIG"]
    if dead then
        F.UpdateStatusIcons(status,self)
        self.Indicators.UnitFlags:SetTexture(D.iIconPath[5])
        self.Indicators.UnitFlags:Show()
    else
        self.Indicators.UnitFlags:Hide()
        F.InitialHealth(self)
    end
end
local function flagsChanged(self)
    IndictorsTexture(self,"PlayerFlags")
    local away=UnitIsAFK(self.unit)
    local dnd=UnitIsDND(self.unit)
    if away then
        self.Indicators.PlayerFlags:SetTexture(D.iIconPath[3])
        self.Indicators.PlayerFlags:Show()
    elseif dnd then
        self.Indicators.PlayerFlags:SetTexture(D.iIconPath[4])
        self.Indicators.PlayerFlags:Show()
    else
        self.Indicators.PlayerFlags:Hide()
    end
end
local function unitResurrection(self)
    if UnitExists(self.unit) then
        IndictorsTexture(self,"Resurrection")
        local Resurrect=UnitHasIncomingResurrection(self.unit)
        if (Resurrect) then
            self.Indicators.Resurrection:SetTexture(D.iIconPath[2])
            self.Indicators.Resurrection:Show()
        else
            self.Indicators.Resurrection:Hide()
        end
    end
end
function F:UpdateIndicatorsUnit(self)
    unitConnection(self)
    flagsChanged(self)
    unitFlags(self)
    unitFaction(self)
    raidTarget(self)
    raidGroupLeader(self)
    raidMasterLoot(self)
    groupRole(self)
    groupAssignments(self)
    unitResurrection(self)
end
function F:UpdateIndicatorsPetUnit(self)
    raidTarget(self)
    unitResurrection(self)
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
    if D.DB[4][6]~=1 then return end
    for _,b in pairs(raidBtn) do
        if b and UnitExists(b.unit) then
            raidTarget(b)
        end
    end
    for _,b in pairs(petBtn) do
        if b and UnitExists(b.unit) then
            raidTarget(b)
        end
    end
    for index=1,6 do
        if UnitExists(D:PosUnit(index)) then
            F:UpdateSoloIndicator(index)
        end
    end
end
function event:UNIT_FACTION(unit)
    local b=GetRaidBtn(unit)
    if not b then return end
    unitFaction(b)
end
function event:UNIT_FLAGS(unit)
    local b=GetRaidBtn(unit)
    if not b then return end
    unitFlags(b)
end
function event:PLAYER_FLAGS_CHANGED(unit)
    if unit=="player" then
        F:UserIdle(unit)
    end
    local b=GetRaidBtn(unit)
    if not b then return end
    flagsChanged(b)
end
function event:INCOMING_RESURRECT_CHANGED(unit)
    local p=GetPetBtn(unit)
    if p then
        unitResurrection(p)
    end
    local b=GetRaidBtn(unit)
    if b then
        unitResurrection(b)
    end
end
function event:UNIT_CONNECTION(unit)
    local b=GetRaidBtn(unit)
    if not b then return end
    unitConnection(b)
end
function F:UpdateSoloIndicator(number)
    local b=soloBtn[number]
    if not b or not UnitExists(b.unit) then return end
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
    if D.DB[4][number]==1 then
        if not event:IsEventRegistered(D.iEvent[number]) then
            event:RegisterEvent(D.iEvent[number])
        end
    elseif D.DB[4][number]==0 then
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
        for index=1,6 do
            if UnitExists(D:PosUnit(index)) then
                F:UpdateSoloIndicator(index)
            end
        end
    end)
end
function F:IndicatorsDisable()
    for _,v in ipairs(D.iEvent) do
        if event:IsEventRegistered(v) then
            event:UnregisterEvent(v)
        end
    end
end
F:RegisterCallbackByIndex(F.IndicatorsEnable,6)
F:RegisterCallbackByIndex(F.IndicatorsDisable,6+30)