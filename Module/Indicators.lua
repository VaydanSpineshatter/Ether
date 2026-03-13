local _,Ether=...
local UnitIsAFK=UnitIsAFK
local UnitIsDND=UnitIsDND
local UnitIsConnected=UnitIsConnected
local UnitIsDeadOrGhost=UnitIsDeadOrGhost
local UnitHasIncomingResurrection=UnitHasIncomingResurrection
local GetReadyCheckStatus=GetReadyCheckStatus
local GetPartyAssignment=GetPartyAssignment
local GetRaidTargetIndex=GetRaidTargetIndex
local UnitExists=UnitExists
local Enum=Enum
local GetLootMethod=C_PartyInfo.GetLootMethod
local pairs,ipairs=pairs,ipairs
local UnitIsGroupLeader=UnitIsGroupLeader
local UnitIsCharmed=UnitIsCharmed
local UnitIsUnit=UnitIsUnit
local UnitGroupRolesAssigned=UnitGroupRolesAssigned
local deadIcon="Interface\\Icons\\Spell_Holy_GuardianSpirit"
local connectionIcon="Interface\\CharacterFrame\\Disconnect-Icon"
local Rdy="Interface\\RaidFrame\\ReadyCheck-Ready"
local NotRdy="Interface\\RaidFrame\\ReadyCheck-NotReady"
local Waiting="Interface\\RaidFrame\\ReadyCheck-Waiting"
local leaderIcon="Interface\\GroupFrame\\UI-Group-LeaderIcon"
local targetIcon="Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local mainTankIcon="Interface\\GroupFrame\\UI-Group-MainTankIcon"
local mainAssistIcon="Interface\\GroupFrame\\UI-Group-MainAssistIcon"
local rezIcon="Interface\\RaidFrame\\Raid-Icon-Rez"
local masterlootIcon="Interface\\GroupFrame\\UI-Group-MasterLooter"
local charmedIcon="Interface\\Icons\\Spell_Shadow_Charm"
local AFK="Interface\\FriendsFrame\\StatusIcon-Away"
local DND="Interface\\FriendsFrame\\StatusIcon-DnD"
local Roles="Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons

local function IndictorsTexture(button,data)
    if not button then return end
    if not button.Indicators[data] then
        button.Indicators[data]=button.healthBar:CreateTexture(nil,"OVERLAY")
        button.Indicators[data]:Hide()
    end
end

local updater
updater=nil
local function HideReadyCheckIcons()
    for _,button in pairs(raidButtons) do
        if button and button.Indicators and button.Indicators.ReadyCheck then
            button.Indicators.ReadyCheck:Hide()
        end
    end
    if updater then
        updater:Cancel()
        updater=nil
    end
end

local function UpdateReady()
    for _,button in pairs(raidButtons) do
        if button then
            IndictorsTexture(button,"ReadyCheck")
            if UnitExists(button.unit) then
                local status=GetReadyCheckStatus(button.unit)
                if (status) then
                    if (status=="ready") then
                        button.Indicators.ReadyCheck:SetTexture(Rdy)
                        button.Indicators.ReadyCheck:Show()
                    elseif (status=="notready") then
                        button.Indicators.ReadyCheck:SetTexture(NotRdy)
                        button.Indicators.ReadyCheck:Show()
                    elseif (status=="waiting") then
                        button.Indicators.ReadyCheck:SetTexture(Waiting)
                        button.Indicators.ReadyCheck:Show()
                    end
                else
                    button.Indicators.ReadyCheck:Hide()
                end
            end
        end
    end
end

local function UpdateConfirm()
    for _,button in pairs(raidButtons) do
        if button then
            IndictorsTexture(button,"ReadyCheck")
            local status=GetReadyCheckStatus(button.unit)
            if (status=="ready") then
                button.Indicators.ReadyCheck:SetTexture(Rdy)
                button.Indicators.ReadyCheck:Show()
            elseif (status=="notready") then
                button.Indicators.ReadyCheck:SetTexture(NotRdy)
                button.Indicators.ReadyCheck:Show()
            end
        end
    end
end

local function UpdateFinished()
    if not updater then
        updater=C_Timer.After(5,HideReadyCheckIcons)
    end
end

local function GroupLeader()
    for _,button in pairs(raidButtons) do
        if button then
            IndictorsTexture(button,"GroupLeader")
            if not UnitInAnyGroup("player") then
                button.Indicators.GroupLeader:Hide()
            end
            local IsLeader=UnitIsGroupLeader(button.unit)
            if (IsLeader) then
                button.Indicators.GroupLeader:SetTexture(leaderIcon)
                button.Indicators.GroupLeader:Show()
            else
                button.Indicators.GroupLeader:Hide()
            end
        end
    end
end

local function MainTank()
    for _,button in pairs(raidButtons) do
        if button then
            IndictorsTexture(button,"MainTank")
            if not IsInRaid() then
                button.Indicators.MainTank:Hide()
            else
                if (GetPartyAssignment("MAINTANK",button.unit)) then
                    button.Indicators.MainTank:SetTexture(mainTankIcon)
                    button.Indicators.MainTank:Show()
                elseif (GetPartyAssignment("MAINASSIST",button.unit)) then
                    button.Indicators.MainTank:SetTexture(mainAssistIcon)
                    button.Indicators.MainTank:Show()
                else
                    button.Indicators.MainTank:Hide()
                end
            end
        end
    end
end

local function MasterLoot()
    for _,button in pairs(raidButtons) do
        if button then
            IndictorsTexture(button,"MasterLoot")
            if not UnitInAnyGroup("player") then
                button.Indicators.MasterLoot:Hide()
            end
            local lootType,partyID,raidID=GetLootMethod()
            if lootType==Enum.LootMethod.Masterlooter then
                local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or partyID and ((partyID==0) and "player" or "party"..partyID)
                if masterLooterUnit and UnitIsUnit(button.unit,masterLooterUnit) then
                    button.Indicators.MasterLoot:SetTexture(masterlootIcon)
                    button.Indicators.MasterLoot:Show()
                else
                    button.Indicators.MasterLoot:Hide()
                end
            end
        end
    end
end

function Ether:UpdateSoloIndicator(unit)
    local button=soloButtons[unit]
    if not button or not button.RaidTarget then
        return
    end
    if UnitExists(unit) then
        local index=GetRaidTargetIndex(unit)
        if index then
            button.RaidTarget:SetTexture(targetIcon)
            SetRaidTargetIconTexture(button.RaidTarget,index)
            button.RaidTarget:Show()
        else
            button.RaidTarget:Hide()
        end
    end
end

local function IndicatorsSoloUpdate()
    for _,info in ipairs({"player","target","targettarget"}) do
        if UnitExists(info) then
            Ether:UpdateSoloIndicator(info)
        end
    end
end

local function RaidTarget()
    for _,button in pairs(raidButtons) do
        if button then
            IndictorsTexture(button,"RaidTarget")
            local index=GetRaidTargetIndex(button.unit)
            if index then
                button.Indicators.RaidTarget:SetTexture(targetIcon)
                SetRaidTargetIconTexture(button.Indicators.RaidTarget,index)
                button.Indicators.RaidTarget:Show()
            else
                button.Indicators.RaidTarget:Hide()
            end
        end
    end
    IndicatorsSoloUpdate()
end

local function UpdateHealthBar(button)
    if not button or not button.healthBar then return end
    button.healthBar:SetValue(0)
    button.healthBar:SetMinMaxValues(0,0)
end

local function UpdateDispelFrame(button)
    if not button or not button.dispelLeft then return end
    button.dispelLeft:SetColorTexture(0,0,0,0)
    button.dispelRight:SetColorTexture(0,0,0,0)
end

local iTbl={"Connection","Resurrection","PlayerFlags","UnitFlags","RaidTarget","GroupLeader","MasterLoot","MainTank","GroupRole","ReadyCheck"}
local state=false
local function isAway(DB)
    if DB[10][1]==1 then
        Ether:CastBarDisable("player")
    end
    if DB[10][2]==1 then
        Ether:CastBarDisable("target")
    end
    if DB[1][5]==1 then
        Ether:RangeDisable()
    end
    Ether:IndicatorsFullUpdate()
end

local function isNotAway(DB)
    if DB[10][1]==1 then
        Ether:CastBarEnable("player")
    end
    if DB[10][2]==1 then
        Ether:CastBarEnable("target")
    end
    if DB[1][5]==1 then
        Ether:RangeEnable()
    end
end

local function isUserIdle()
    if Ether.DB[1][4]~=1 then return end
    local DB=Ether.DB
    local afk=UnitIsAFK("player")
    if afk and not state then
        state=true
        isAway(DB)
    end
    if not afk and state then
        state=false
        isNotAway(DB)
    end
end

local function Connection(self)
    IndictorsTexture(self,"Connection")
    local isConnected=UnitIsConnected(self.unit)
    if not isConnected then
        self.healthBar:SetStatusBarColor(0.5,0.5,0.5)
        self.Indicators.Connection:SetTexture(connectionIcon)
        self.Indicators.Connection:Show()
    else
        self.Indicators.Connection:Hide()
    end
end

local function UnitFlags(self)
    IndictorsTexture(self,"UnitFlags")
    local charmed=UnitIsCharmed(self.unit)
    local dead=UnitIsDeadOrGhost(self.unit)
    if charmed then
        self.name:SetTextColor(1.00,0.00,0.00)
        self.Indicators.UnitFlags:SetTexture(charmedIcon)
        self.Indicators.UnitFlags:Show()
    elseif dead then
        UpdateHealthBar(self)
        UpdateDispelFrame(self)
        self.Indicators.UnitFlags:SetTexture(deadIcon)
        self.Indicators.UnitFlags:Show()
    else
        self.Indicators.UnitFlags:Hide()
        self.name:SetTextColor(1,1,1)
    end
end

local function Resurrection(self)
    IndictorsTexture(self,"Resurrection")
    local Resurrect=UnitHasIncomingResurrection(self.unit)
    if (Resurrect) then
        self.Indicators.Resurrection:SetTexture(rezIcon)
        self.Indicators.Resurrection:Show()
    else
        self.Indicators.Resurrection:Hide()
    end
end

local function PlayerFlags(self)
    IndictorsTexture(self,"PlayerFlags")
    local away=UnitIsAFK(self.unit)
    local dnd=UnitIsDND(self.unit)
    if away then
        self.Indicators.PlayerFlags:SetTexture(AFK)
        self.Indicators.PlayerFlags:Show()
    elseif dnd then
        self.Indicators.PlayerFlags:SetTexture(DND)
        self.Indicators.PlayerFlags:Show()
    else
        self.Indicators.PlayerFlags:Hide()
    end
    isUserIdle()
end

local function ReadyCheckToken(self)
    IndictorsTexture(self,"ReadyCheck")
    if UnitExists(self.unit) then
        local status=GetReadyCheckStatus(self.unit)
        if (status) then
            if (status=="ready") then
                self.Indicators.ReadyCheck:SetTexture(Rdy)
                self.Indicators.ReadyCheck:Show()
            elseif (status=="notready") then
                self.Indicators.ReadyCheck:SetTexture(NotRdy)
                self.Indicators.ReadyCheck:Show()
            elseif (status=="waiting") then
                self.Indicators.ReadyCheck:SetTexture(Waiting)
                self.Indicators.ReadyCheck:Show()
            end
        else
            self.Indicators.ReadyCheck:Hide()
        end
    end
end

local function RaidTargetToken(self)
    IndictorsTexture(self,"RaidTarget")
    if UnitExists(self.unit) then
        local index=GetRaidTargetIndex(self.unit)
        if index then
            self.Indicators.RaidTarget:SetTexture(targetIcon)
            SetRaidTargetIconTexture(self.Indicators.RaidTarget,index)
            self.Indicators.RaidTarget:Show()
        else
            self.Indicators.RaidTarget:Hide()
        end
    end
end

local function GroupLeaderToken(self)
    IndictorsTexture(self,"GroupLeader")
    if not UnitInAnyGroup("player") then
        self.Indicators.GroupLeader:Hide()
    end
    local IsLeader=UnitIsGroupLeader(self.unit)
    if (IsLeader) then
        self.Indicators.GroupLeader:SetTexture(leaderIcon)
        self.Indicators.GroupLeader:Show()
    else
        self.Indicators.GroupLeader:Hide()
    end
end

local function MainTankToken(self)
    IndictorsTexture(self,"MainTank")
    if not IsInRaid() then
        self.Indicators.MainTank:Hide()
    else
        if (GetPartyAssignment("MAINTANK",self.unit)) then
            self.Indicators.MainTank:SetTexture(mainTankIcon)
            self.Indicators.MainTank:Show()
        elseif (GetPartyAssignment("MAINASSIST",self.unit)) then
            self.Indicators.MainTank:SetTexture(mainAssistIcon)
            self.Indicators.MainTank:Show()
        else
            self.Indicators.MainTank:Hide()
        end
    end
end

local function MasterLootToken(self)
    IndictorsTexture(self,"MasterLoot")
    if not UnitInAnyGroup("player") then
        self.Indicators.MasterLoot:Hide()
    end
    local lootType,partyID,raidID=GetLootMethod()
    if lootType==Enum.LootMethod.Masterlooter then
        local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or partyID and ((partyID==0) and "player" or "party"..partyID)
        if masterLooterUnit and UnitIsUnit(self.unit,masterLooterUnit) then
            self.Indicators.MasterLoot:SetTexture(masterlootIcon)
            self.Indicators.MasterLoot:Show()
        else
            self.Indicators.MasterLoot:Hide()
        end
    end
end

local function UpdateGroupRole(self)
    if Ether.DB[5][9]==0 then return end
    IndictorsTexture(self,"GroupRole")
    local role=UnitGroupRolesAssigned(self.unit)
    if (role) then
        self.Indicators.GroupRole:SetTexture(Roles)
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

function Ether:IndicatorsFullUpdate()
    for _,button in pairs(raidButtons) do
        if button then
            Connection(button)
            Resurrection(button)
            PlayerFlags(button)
            UnitFlags(button)
            RaidTargetToken(button)
            GroupLeaderToken(button)
            MainTankToken(button)
            MasterLootToken(button)
            UpdateGroupRole(button)
            ReadyCheckToken(button)
        end
    end
end

function Ether:IndicatorsFullUpdateByUnit(self)
    Connection(self)
    Resurrection(self)
    PlayerFlags(self)
    UnitFlags(self)
    RaidTargetToken(self)
    GroupLeaderToken(self)
    MainTankToken(self)
    MasterLootToken(self)
    UpdateGroupRole(self)
    ReadyCheckToken(self)
end

function Ether:UpdateIndicatorsPosition(number)
    local C=Ether.DB[1002][number]
    local data=iTbl[number]
    for _,button in pairs(raidButtons) do
        if button.Indicators[data] then
            button.Indicators[data]:Hide()
            button.Indicators[data]:ClearAllPoints()
            button.Indicators[data]:SetPoint(C[1],button.healthBar,C[1],C[2],C[3])
            button.Indicators[data]:SetSize(C[4],C[4])
        end
    end
    Ether:IndicatorsFullUpdate()
end

function Ether:SavePosition(button)
    local C=Ether.DB[1002]
    for index,data in ipairs(iTbl) do
        if button.Indicators[data] then
            button.Indicators[data]:Hide()
            button.Indicators[data]:ClearAllPoints()
            button.Indicators[data]:SetPoint(C[index][1],button.healthBar,C[index][1],C[index][2],C[index][3])
            button.Indicators[data]:SetSize(C[index][4],C[index][4])
        end
    end
end

function Ether:InitialIndicatorsPosition()
    for _,button in pairs(raidButtons) do
        Ether:SavePosition(button)
    end
end

local function HideIconsByIndex(index)
    for _,button in pairs(raidButtons) do
        if button and button.Indicators and button.Indicators[iTbl[index]] then
            button.Indicators[iTbl[index]]:Hide()
        end
    end
end

local function ShowIconsByIndex(index)
    for _,button in pairs(raidButtons) do
        if button and button.Indicators and button.Indicators[iTbl[index]] then
            button.Indicators[iTbl[index]]:Show()
        end
    end
end

local Toggle,Register,Unregister
do
    local uSTR={"UNIT_CONNECTION","INCOMING_RESURRECT_CHANGED","PLAYER_FLAGS_CHANGED","UNIT_FLAGS"}
    local nSTR={"RAID_TARGET_UPDATE","PARTY_LEADER_CHANGED","PARTY_LOOT_METHOD_CHANGED","PLAYER_ROLES_ASSIGNED","READY_CHECK","READY_CHECK_CONFIRM","READY_CHECK_FINISHED"}
    local U,N={},{}
    local UH={Connection,Resurrection,PlayerFlags,UnitFlags}
    local NH={RaidTarget,GroupLeader,MasterLoot,MainTank,UpdateReady,UpdateConfirm,UpdateFinished,UpdateGroupRole}
    local token,frame=CreateFrame("Frame"),CreateFrame("Frame")
    if not token:GetScript("OnEvent") then
        token:SetScript("OnEvent",function(_,event,unit)
            local btn=raidButtons[unit]
            if not btn then return end
            if unit and btn.unit~=unit then return end
            U[event](btn,event,unit)
        end)
    end
    if not frame:GetScript("OnEvent") then
        frame:SetScript("OnEvent",function(self,event)
            N[event](self,event)
        end)
    end
    function Register()
        for index,info in ipairs(uSTR) do
            if not U[info] and not token:IsEventRegistered(info) then
                token:RegisterEvent(info)
                U[info]=UH[index]
            end
        end
        for index,info in ipairs(nSTR) do
            if not N[info] and not frame:IsEventRegistered(info) then
                frame:RegisterEvent(info)
                N[info]=NH[index]
            end
        end
    end
    function Unregister()
        token:UnregisterAllEvent()
        frame:UnregisterAllEvent()
        wipe(N);
        wipe(U)
    end
    function Toggle(number)
        if not number or type(number)~="number" then return end
        local idx=number-4
        local info=nSTR[idx]
        local handler=NH[idx]
        if not info then return end
        if N[info] and frame:IsEventRegistered(info) then
            frame:UnregisterEvent(info)
            HideIconsByIndex(number)
            N[info]=nil
        else
            frame:RegisterEvent(info)
            ShowIconsByIndex(number)
            N[info]=handler
        end
    end
    Ether.IndicatorToggle=Toggle
end

function Ether:IndicatorsEnable()
    Ether:InitialIndicatorsPosition()
    Register()
    Ether:UpdateSoloIndicator("player")
    Ether:IndicatorsFullUpdate()
    HideReadyCheckIcons()
end

function Ether:IndicatorsDisable()
    Unregister()
end
