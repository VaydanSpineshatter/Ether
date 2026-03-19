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
local UnitIsVisible = UnitIsVisible
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
local classIcon='Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES'
local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons
local ClassCoords={
    ['WARRIOR']={0,0.25,0,0.25},
    ['MAGE']={0.25,0.49609375,0,0.25},
    ['ROGUE']={0.49609375,0.7421875,0,0.25},
    ['DRUID']={0.7421875,0.98828125,0,0.25},
    ['HUNTER']={0,0.25,0.25,0.5},
    ['SHAMAN']={0.25,0.49609375,0.25,0.5},
    ['PRIEST']={0.49609375,0.7421875,0.25,0.5},
    ['WARLOCK']={0.7421875,0.98828125,0.25,0.5},
    ['PALADIN']={0,0.25,0.5,0.75},
}

local RoleCoords={
    ["tank"]='|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:0:19:22:41|t',
    ["heal"]='|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:1:20|t',
    ["damager"]='|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:13:13:0:0:64:64:20:39:22:41|t'
}

local function GetClassCoords(info)
    local coords=CLASS_ICON_TCOORDS[info] or ClassCoords[info]
    if not coords then
        return 0,1,0,1
    end
    local crop=0.015
    return coords[1]+crop,coords[2]-crop,coords[3]+crop,coords[4]-crop
end
Ether.GetClassCoords=GetClassCoords

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
            local unit=button.unit
            IndictorsTexture(button,"ReadyCheck")
            if UnitExists(unit) then
                local status=GetReadyCheckStatus(unit)
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
            local unit=button.unit
            IndictorsTexture(button,"ReadyCheck")
            local status=GetReadyCheckStatus(unit)
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
            local unit=button.unit
            IndictorsTexture(button,"GroupLeader")
            if not UnitInAnyGroup("player") then
                button.Indicators.GroupLeader:Hide()
            end
            local IsLeader=UnitIsGroupLeader(unit)
            if (IsLeader) then
                button.Indicators.GroupLeader:SetTexture(leaderIcon)
                button.Indicators.GroupLeader:Show()
            else
                button.Indicators.GroupLeader:Hide()
            end
        end
    end
end

local function UpdateClassIcon(self)
    if self.Indicators.ClassIcon then
        self.Indicators.ClassIcon:Hide()
    end
    if Ether.DB[3][11]==0 then return end
    IndictorsTexture(self,"ClassIcon")
    local unit=self.unit
    local className=select(2,UnitClass(unit))
    if className then
        self.Indicators.ClassIcon:SetTexture(classIcon)
        self.Indicators.ClassIcon:SetTexCoord(GetClassCoords(className))
        self.Indicators.ClassIcon:Show()
    end
end

local function UpdateGroupRole(self)
    if Ether.DB[3][9]==0 then return end
    local unit=self.unit
    IndictorsTexture(self,"GroupRole")
    if not IsInGroup() then
        self.Indicators.GroupRole:Hide()
    end
    local role=UnitGroupRolesAssigned(unit)
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

local function MainTank()
    for _,button in pairs(raidButtons) do
        if button then
            local unit=button.unit
            UpdateGroupRole(button)
            UpdateClassIcon(button)
            IndictorsTexture(button,"MainTank")
            if not IsInRaid() then
                button.Indicators.MainTank:Hide()
            else
                if (GetPartyAssignment("MAINTANK",unit)) then
                    button.Indicators.MainTank:SetTexture(mainTankIcon)
                    button.Indicators.MainTank:Show()
                elseif (GetPartyAssignment("MAINASSIST",unit)) then
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
            local unit=button.unit
            IndictorsTexture(button,"MasterLoot")
            if not UnitInAnyGroup("player") then
                button.Indicators.MasterLoot:Hide()
            end
            local lootType,partyID,raidID=GetLootMethod()
            if lootType==Enum.LootMethod.Masterlooter then
                local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or partyID and ((partyID==0) and "player" or "party"..partyID)
                if masterLooterUnit and UnitIsUnit(unit,masterLooterUnit) then
                    button.Indicators.MasterLoot:SetTexture(masterlootIcon)
                    button.Indicators.MasterLoot:Show()
                else
                    button.Indicators.MasterLoot:Hide()
                end
            end
        end
    end
end

function Ether:UpdateSoloIndicator(number)
    local button=soloButtons[number]
    if not button or not button.RaidTarget then return end
    if UnitExists(button.unit) then
        local index=GetRaidTargetIndex(button.unit)
        if index then
            button.RaidTarget:SetTexture(targetIcon)
            SetRaidTargetIconTexture(button.RaidTarget,index)
            button.RaidTarget:Show()
        else
            button.RaidTarget:Hide()
        end
    end
end

local function RaidTarget()
    for _,button in pairs(raidButtons) do
        if button then
            local unit=button.unit
            IndictorsTexture(button,"RaidTarget")
            if UnitExists(unit) then
                local index=GetRaidTargetIndex(unit)
                if index then
                    button.Indicators.RaidTarget:SetTexture(targetIcon)
                    SetRaidTargetIconTexture(button.Indicators.RaidTarget,index)
                    button.Indicators.RaidTarget:Show()
                else
                    button.Indicators.RaidTarget:Hide()
                end
            end
        end
    end

   if UnitIsVisible(soloButtons[1].unit) then
        Ether:UpdateSoloIndicator(1)
   end
    if UnitIsVisible(soloButtons[2].unit) then
        Ether:UpdateSoloIndicator(2)
    end
    if UnitIsVisible(soloButtons[3].unit) then
        Ether:UpdateSoloIndicator(3)
    end
end

local function UpdateHealthBar(button)
    if not button or not button.healthBar then return end
    button.healthBar:SetValue(0)
    button.healthBar:SetMinMaxValues(0,0)
end

local iTbl={"Connection","Resurrection","PlayerFlags","UnitFlags","RaidTarget","GroupLeader","MasterLoot","MainTank","GroupRole","ReadyCheck","ClassIcon"}
local IndiMap={}
for i,v in ipairs(iTbl) do
    IndiMap[v]=i -- "ICON" -> 1
    IndiMap[i]=v -- 1 -> "ICON"
end
function Ether:ToggleIndicatorIcon(index)
    local number=IndiMap[index]
    for _,button in pairs(raidButtons) do
        if button and button.Indicators and button.Indicators[number] then
            if not button.Indicators[number]:IsShown() then
                button.Indicators[number]:Show()
            else
                button.Indicators[number]:Hide()
            end
        end
    end
end

local function Connection(self)
    local unit=self.unit
    IndictorsTexture(self,"Connection")
    local isConnected=UnitIsConnected(unit)
    if not isConnected then
        self.healthBar:SetStatusBarColor(0.5,0.5,0.5)
        self.Indicators.Connection:SetTexture(connectionIcon)
        self.Indicators.Connection:Show()
    else
        self.Indicators.Connection:Hide()
    end
end

local function UnitFlags(self)
    local unit=self.unit
    IndictorsTexture(self,"UnitFlags")
    local charmed=UnitIsCharmed(unit)
    local dead=UnitIsDeadOrGhost(unit)
    if charmed then
        self.name:SetTextColor(1.00,0.00,0.00)
        self.Indicators.UnitFlags:SetTexture(charmedIcon)
        self.Indicators.UnitFlags:Show()
    elseif dead then
        UpdateHealthBar(self)
        Ether:HideButtonDispel(self)
        Ether:UpdatePrediction(self)
        self.Indicators.UnitFlags:SetTexture(deadIcon)
        self.Indicators.UnitFlags:Show()
    else
        self.Indicators.UnitFlags:Hide()
        self.name:SetTextColor(1,1,1)
    end
end

local function Resurrection(self)
    local unit=self.unit
    IndictorsTexture(self,"Resurrection")
    local Resurrect=UnitHasIncomingResurrection(unit)
    if (Resurrect) then
        self.Indicators.Resurrection:SetTexture(rezIcon)
        self.Indicators.Resurrection:Show()
    else
        self.Indicators.Resurrection:Hide()
    end
end

local function PlayerFlags(self)
    local unit=self.unit
    IndictorsTexture(self,"PlayerFlags")
    local away=UnitIsAFK(unit)
    local dnd=UnitIsDND(unit)
    if away then
        self.Indicators.PlayerFlags:SetTexture(AFK)
        self.Indicators.PlayerFlags:Show()
    elseif dnd then
        self.Indicators.PlayerFlags:SetTexture(DND)
        self.Indicators.PlayerFlags:Show()
    else
        self.Indicators.PlayerFlags:Hide()
    end
    Ether:isUserIdle()
end

local function RaidTargetToken(self)
    local unit=self.unit
    IndictorsTexture(self,"RaidTarget")
    if UnitExists(unit) then
        local index=GetRaidTargetIndex(unit)
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
    local unit=self.unit
    IndictorsTexture(self,"GroupLeader")
    if not UnitInAnyGroup("player") then
        self.Indicators.GroupLeader:Hide()
    end
    local IsLeader=UnitIsGroupLeader(unit)
    if (IsLeader) then
        self.Indicators.GroupLeader:SetTexture(leaderIcon)
        self.Indicators.GroupLeader:Show()
    else
        self.Indicators.GroupLeader:Hide()
    end
end

local function MainTankToken(self)
    local unit=self.unit
    IndictorsTexture(self,"MainTank")
    if not IsInRaid() then
        self.Indicators.MainTank:Hide()
    else
        if (GetPartyAssignment("MAINTANK",unit)) then
            self.Indicators.MainTank:SetTexture(mainTankIcon)
            self.Indicators.MainTank:Show()
        elseif (GetPartyAssignment("MAINASSIST",unit)) then
            self.Indicators.MainTank:SetTexture(mainAssistIcon)
            self.Indicators.MainTank:Show()
        else
            self.Indicators.MainTank:Hide()
        end
    end
    UpdateGroupRole(self)
end

local function MasterLootToken(self)
    local unit=self.unit
    IndictorsTexture(self,"MasterLoot")
    if not UnitInAnyGroup("player") then
        self.Indicators.MasterLoot:Hide()
    end
    local lootType,partyID,raidID=GetLootMethod()
    if lootType==Enum.LootMethod.Masterlooter then
        local masterLooterUnit=raidID and ((raidID==0) and "player" or "raid"..raidID) or partyID and ((partyID==0) and "player" or "party"..partyID)
        if masterLooterUnit and UnitIsUnit(unit,masterLooterUnit) then
            self.Indicators.MasterLoot:SetTexture(masterlootIcon)
            self.Indicators.MasterLoot:Show()
        else
            self.Indicators.MasterLoot:Hide()
        end
    end
end

local function UpdateReadyToken(self)
    local unit=self.unit
    IndictorsTexture(self,"ReadyCheck")
    if UnitExists(unit) then
        local status=GetReadyCheckStatus(unit)
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

local function IndicatorsFullUpdateByUnit(self)
    Connection(self)
    Resurrection(self)
    PlayerFlags(self)
    UnitFlags(self)
    RaidTargetToken(self)
    GroupLeaderToken(self)
    MainTankToken(self)
    MasterLootToken(self)
    UpdateGroupRole(self)
    UpdateClassIcon(self)
    UpdateReadyToken(self)
end

function Ether:IndicatorsFullUpdate()
    for _,button in pairs(raidButtons) do
        if button then
            Ether:UpdateIndicatorsPosition(button)
        end
    end
end

function Ether:UpdateIndicatorsPosition(button)
    if not button then return end
    for i,v in ipairs(iTbl) do
        if button.Indicators[v] then
            local C=Ether.DB[20][i]
            button.Indicators[v]:Hide()
            button.Indicators[v]:ClearAllPoints()
            button.Indicators[v]:SetPoint(C[1],button.healthBar,C[1],C[2],C[3])
            button.Indicators[v]:SetSize(C[4],C[4])
        end
    end
    IndicatorsFullUpdateByUnit(button)
end

function Ether:SavePosition(index)
    local C=Ether.DB[20][index]
    local data=iTbl[index]
    for _,button in pairs(raidButtons) do
        if button and button.Indicators[data] then
            button.Indicators[data].Shown=button.Indicators[data]:IsShown()
            button.Indicators[data]:Hide()
            button.Indicators[data]:ClearAllPoints()
            button.Indicators[data]:SetPoint(C[1],button.healthBar,C[1],C[2],C[3])
            button.Indicators[data]:SetSize(C[4],C[4])
            if button.Indicators[data].Shown then
                button.Indicators[data]:Show()
                button.Indicators[data].Shown=nil
            end
        end
    end
end

function Ether:HideIndicators()
    for _,button in pairs(raidButtons) do
        if button and button.Indicators then
            for _,info in pairs(button.Indicators) do
                if info then
                    info:Hide()
                end
            end
        end
    end
end

local Toggle,Register,Unregister
do
    local uSTR={"UNIT_CONNECTION","INCOMING_RESURRECT_CHANGED","PLAYER_FLAGS_CHANGED","UNIT_FLAGS"}
    local nSTR={"RAID_TARGET_UPDATE","PARTY_LEADER_CHANGED","PARTY_LOOT_METHOD_CHANGED","PLAYER_ROLES_ASSIGNED","READY_CHECK","READY_CHECK_CONFIRM","READY_CHECK_FINISHED"}
    local U,N={},{}
    local UH={Connection,Resurrection,PlayerFlags,UnitFlags}
    local NH={RaidTarget,GroupLeader,MasterLoot,MainTank,UpdateReady,UpdateConfirm,UpdateFinished}
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
        wipe(N)
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
            N[info]=nil
        else
            frame:RegisterEvent(info)
            N[info]=handler
        end
    end
    Ether.IndicatorToggle=Toggle
end

function Ether:IndicatorsEnable()
    Register()
    Ether:UpdateSoloIndicator("player")
    HideReadyCheckIcons()
    C_Timer.After(2,function()
        Ether:IndicatorsFullUpdate()
        if UnitExists(soloButtons[1].unit) then
            Ether:UpdateSoloIndicator(1)
        end
    end)
end

function Ether:IndicatorsDisable()
    Unregister()
end
