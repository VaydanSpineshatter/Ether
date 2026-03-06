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
local tinsert,tremove=table.insert,table.remove
local GetLootMethod=C_PartyInfo.GetLootMethod
local pairs,ipairs=pairs,ipairs
local UnitIsGroupLeader=UnitIsGroupLeader
local UnitIsCharmed=UnitIsCharmed
local UnitIsUnit=UnitIsUnit
local deadIcon="Interface\\Icons\\Spell_Holy_GuardianSpirit"
local connectionIcon="Interface\\CharacterFrame\\Disconnect-Icon"
local ReadyCheck_Ready="Interface\\RaidFrame\\ReadyCheck-Ready"
local ReadyCheck_NotReady="Interface\\RaidFrame\\ReadyCheck-NotReady"
local ReadyCheck_Waiting="Interface\\RaidFrame\\ReadyCheck-Waiting"
local leaderIcon="Interface\\GroupFrame\\UI-Group-LeaderIcon"
local targetIcon="Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local mainTankIcon="Interface\\GroupFrame\\UI-Group-MainTankIcon"
local mainAssistIcon="Interface\\GroupFrame\\UI-Group-MainAssistIcon"
local rezIcon="Interface\\RaidFrame\\Raid-Icon-Rez"
local masterlootIcon="Interface\\GroupFrame\\UI-Group-MasterLooter"
local charmedIcon="Interface\\Icons\\Spell_Shadow_Charm"
local AFK=[[|cE600CCFFAFK|r]]
local DND=[[|cffCC66FFDND|r]]

local raidButtons=Ether.raidButtons
local soloButtons=Ether.soloButtons

Ether.Handler={}
local Updates={}
function Ether.Handler:FullUpdate()
    for i=1,#(Updates) do
        Updates[i]()
    end
end

function Ether.Handler:RegisterUpdater(func)
    for i=1,#(Updates) do
        if (Updates[i] and Updates[i+1]==func) then
            return
        end
    end
    tinsert(Updates,func)
end

function Ether.Handler:UnregisterUpdater(func)
    for i=#(Updates),1,-1 do
        if (Updates[i] and Updates[i+1]==func) then
            tremove(Updates,i+1)
        end
    end
end

function Ether:HideIndicators(indicator)
    for _,button in pairs(raidButtons) do
        if button and button.Indicators and button.Indicators[indicator] then
            button.Indicators[indicator]:Hide()
        end
    end
end

function Ether:IndictorsTexture(b,tbl)
    if not b then
        return
    end
    if not b.Indicators then
        b.Indicators={}
    end
    local frame=CreateFrame("Frame",nil,UIParent)
    frame:SetFrameLevel(b:GetFrameLevel()+7)
    if not b.Indicators[tbl] then
        if tbl=="PlayerFlags" then
            b.Indicators[tbl]=frame:CreateFontString(nil,"OVERLAY")
            b.Indicators[tbl]:SetFont(unpack(Ether.media.expressway),14,"OUTLINE")
            b.Indicators[tbl]:Hide()
        else
            b.Indicators[tbl]=frame:CreateTexture(nil,"OVERLAY")
            b.Indicators[tbl]:Hide()
        end
    end
end

function Ether:SaveIndicatorsPosition(indicator,number)
    for _,button in pairs(raidButtons) do
        if not button or not button.Indicators then
            return
        end
        Ether:IndictorsTexture(button,indicator)
        if button.Indicators[indicator] then
            button.Indicators[indicator]:Hide()
            button.Indicators[indicator]:ClearAllPoints()
            button.Indicators[indicator]:SetPoint(Ether.DB[1002][number][2],button.healthBar,Ether.DB[1002][number][2],Ether.DB[1002][number][3],Ether.DB[1002][number][4])
            button.Indicators[indicator]:SetSize(Ether.DB[1002][number][1],Ether.DB[1002][number][1])
        end
    end
    Ether:IndicatorsNormalFullUpdate()
end
local iTbl={"Connection","Resurrection","PlayerFlags","UnitFlags","ReadyCheck","RaidTarget","GroupLeader","MasterLoot","PlayerRoles"}
function Ether:CheckIndicatorsPosition(button)
    for index,value in ipairs(iTbl) do
        Ether:IndictorsTexture(button,value)
        if button.Indicators[value] then
            button.Indicators[value]:Hide()
            button.Indicators[value]:ClearAllPoints()
            button.Indicators[value]:SetPoint(Ether.DB[1002][index][2],button.healthBar,Ether.DB[1002][index][2],Ether.DB[1002][index][3],Ether.DB[1002][index][4])
            button.Indicators[value]:SetSize(Ether.DB[1002][index][1],Ether.DB[1002][index][1])
        end
    end
end

function Ether:InitialIndicatorsPosition()
    for index,value in ipairs(iTbl) do
        Ether:SaveIndicatorsPosition(value,index)
    end
end

local updater=nil
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
            Ether:IndictorsTexture(self,"ReadyCheck")
            if UnitExists(button.unit) then
                local status=GetReadyCheckStatus(button.unit)
                if (status) then
                    if (status=="ready") then
                        button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Ready)
                        button.Indicators.ReadyCheck:Show()
                    elseif (status=="notready") then
                        button.Indicators.ReadyCheck:SetTexture(ReadyCheck_NotReady)
                        button.Indicators.ReadyCheck:Show()
                    elseif (status=="waiting") then
                        button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Waiting)
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
            Ether:IndictorsTexture(self,"ReadyCheck")
            local status=GetReadyCheckStatus(button.unit)
            if (status=="ready") then
                button.Indicators.ReadyCheck:SetTexture(ReadyCheck_Ready)
                button.Indicators.ReadyCheck:Show()
            elseif (status=="notready") then
                button.Indicators.ReadyCheck:SetTexture(ReadyCheck_NotReady)
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
            Ether:IndictorsTexture(button,"GroupLeader")
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

local function PlayerRoles()
    for _,button in pairs(raidButtons) do
        if button then
            Ether:IndictorsTexture(button,"PlayerRoles")
            if not IsInRaid() then
                button.Indicators.PlayerRoles:Hide()
            else
                if (GetPartyAssignment("MAINTANK",button.unit)) then
                    button.Indicators.PlayerRoles:SetTexture(mainTankIcon)
                    button.Indicators.PlayerRoles:Show()
                elseif (GetPartyAssignment("MAINASSIST",button.unit)) then
                    button.Indicators.PlayerRoles:SetTexture(mainAssistIcon)
                    button.Indicators.PlayerRoles:Show()
                else
                    button.Indicators.PlayerRoles:Hide()
                end
            end
        end
    end
end

local function MasterLoot()
    for _,button in pairs(raidButtons) do
        if button then
            Ether:IndictorsTexture(button,"MasterLoot")
            if not UnitInAnyGroup("player") then
                button .Indicators.MasterLoot:Hide()
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
            Ether:IndictorsTexture(button,"RaidTarget")
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

local state=false
local function isAway(DB)
    if DB[1201][1]==1 then
        Ether:CastBarDisable("player")
    end
    if DB[1201][2]==1 then
        Ether:CastBarDisable("target")
    end
    if DB[401][5]==1 then
        Ether:RangeDisable()
    end
     Ether:IndicatorsNormalFullUpdate()
    for i=1,#iTbl do
        Ether:HideIndicators(iTbl[i])
    end
end

local function isNotAway(DB)
    if DB[1201][1]==1 then
        Ether:CastBarEnable("player")
    end
    if DB[1201][2]==1 then
        Ether:CastBarEnable("target")
    end
    if DB[401][5]==1 then
        Ether:RangeEnable()
    end
    Ether.Handler:FullUpdate()
end

local function isUserIdle()
    if Ether.DB[401][4]~=1 then return end
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
    Ether:IndictorsTexture(self,"Connection")
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
    Ether:IndictorsTexture(self,"UnitFlags")
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
    Ether:IndictorsTexture(self,"Resurrection")
    local Resurrect=UnitHasIncomingResurrection(self.unit)
    if (Resurrect) then
        self.Indicators.Resurrection:SetTexture(rezIcon)
        self.Indicators.Resurrection:Show()
    else
        self.Indicators.Resurrection:Hide()
    end
end

local function PlayerFlags(self)
    Ether:IndictorsTexture(self,"PlayerFlags")
    local away=UnitIsAFK(self.unit)
    local dnd=UnitIsDND(self.unit)
    if away then
        self.Indicators.PlayerFlags:SetText(AFK)
        self.Indicators.PlayerFlags:Show()
    elseif dnd then
        self.Indicators.PlayerFlags:SetText(DND)
        self.Indicators.PlayerFlags:Show()
    else
        self.Indicators.PlayerFlags:Hide()
    end
    isUserIdle()
end

function Ether:IndicatorsNormalFullUpdate()
    for _,button in pairs(raidButtons) do
        if button then
            for _,value in ipairs(iTbl) do
                Ether:IndictorsTexture(button,value)
            end
            Connection(button)
            PlayerFlags(button)
            UnitFlags(button)
            Resurrection(button)
            RaidTarget(button)
            PlayerRoles(button)
            GroupLeader(button)
            MasterLoot(button)
        end
    end
end

function Ether:IndicatorsFullUpdate(self)
    Connection(self)
    PlayerFlags(self)
    UnitFlags(self)
    Resurrection(self)
    RaidTarget(self)
    PlayerRoles(self)
    GroupLeader(self)
    MasterLoot(self)
end

local Toggle,Register,Unregister
do
    local str={"UNIT_CONNECTION","INCOMING_RESURRECT_CHANGED","PLAYER_FLAGS_CHANGED","UNIT_FLAGS"}
    local nStr={"RAID_TARGET_UPDATE","PARTY_LEADER_CHANGED","PARTY_LOOT_METHOD_CHANGED","PLAYER_ROLES_ASSIGNED","READY_CHECK","READY_CHECK_CONFIRM","READY_CHECK_FINISHED"}
    local StrEvent,Events={},{}
    local h={Connection,Resurrection,PlayerFlags,UnitFlags}
    local n={RaidTarget,GroupLeader,MasterLoot,PlayerRoles,UpdateReady,UpdateConfirm,UpdateFinished}
    local token,frame=CreateFrame("Frame"),CreateFrame("Frame")
    if not token:GetScript("OnEvent") then
        token:SetScript("OnEvent",function(_,event,unit)
            local btn=raidButtons[unit]
            if not btn then return end
            if unit and btn.unit~=unit then return end
            StrEvent[event](btn,event,unit)
        end)
    end
    if not frame:GetScript("OnEvent") then
        frame:SetScript("OnEvent",function(self,event)
            Events[event](self,event)
        end)
    end
    function Register()
        for index,info in ipairs(str) do
            if not StrEvent[info] and not token:IsEventRegistered(info) then
                token:RegisterEvent(info)
                StrEvent[info]=h[index]
            end
        end
        for index,info in ipairs(nStr) do
            if not Events[info] and not frame:IsEventRegistered(info) then
                frame:RegisterEvent(info)
                Events[info]=n[index]
            end
        end
    end
    function Unregister()
        token:UnregisterAllEvent()
        frame:UnregisterAllEvent()
        wipe(StrEvent)
        wipe(Events)
    end
    function Toggle(number)
        if not number or type(number)~="number" then return end
        if number<5 then
            for index,info in ipairs(str) do
                if number==index then
                    if StrEvent[info] and token:IsEventRegistered(info) then
                        token:UnregisterEvent(info)
                        StrEvent[info]=nil
                    else
                        token:RegisterEvent(info)
                        StrEvent[info]=h[index]
                    end
                end
            end
        else
            for index,info in ipairs(nStr) do
                if number==index+4 then
                    if Events[info] and frame:IsEventRegistered(info) then
                        frame:UnregisterEvent(info)
                        Events[info]=nil
                    else
                        frame:RegisterEvent(info)
                        Events[info]=n[index]
                    end
                end
            end
        end
    end
    Ether.IndicatorToggle=Toggle
end

function Ether:IndicatorsEnable()
    Register()
    Ether:UpdateSoloIndicator("player")
end

function Ether:IndicatorsDisable()
    Unregister()
end
