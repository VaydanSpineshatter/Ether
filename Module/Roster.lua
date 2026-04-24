local D,F,S,C,_=unpack(select(2,...))
local C_After=C_Timer.After
local UnitExists=UnitExists
local pairs,ipairs=pairs,ipairs
local UnitCastingInfo,UnitChannelInfo=UnitCastingInfo,UnitChannelInfo
local castBar=D.castBar
local event,raidBtn,soloBtn,modelBtn=S.EventFrame,D.raidBtn,D.soloBtn,D.modelBtn
local refresh,after=false,false
local updatedChannel=false
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
                if b then
                    F.InitialHealth(b)
                    F:HideButtonDispellable(b)
                    F:UpdateDeadIcon(b)
                end
            end
            for _,b in ipairs(soloBtn) do
                if b and UnitExists(b.unit) then
                    F.InitialHealth(b)
                end
            end
            after=false
        end)
    end
end
local function refreshButtons()
    if not refresh then
        refresh=true
        if not UnitInAnyGroup("player") then
            local button=raidBtn["player"]
            if button then
                F:HidePrediction(button)
                F:IndicatorsFullUpdateBtn()
            end
            F:AuraDisable()
            C_After(1.5,function()
                F:AuraEnable()
                refresh=false
            end)
        else
            C_After(3,function()
                for _,button in pairs(raidBtn) do
                    if button and UnitExists(button.unit) then
                        F:RaidAurasFullUpdate(button.unit)
                        F.InitialHealth(button)
                        F.UpdateClassColor(button)
                        F:IndicatorsFullUpdate(button.unit)
                    end
                end
                refresh=false
            end)
        end
    end
end
function event:GROUP_ROSTER_UPDATE()
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
    C:EtherInfo("joined a")
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
--[[

 "UPDATE_STEALTH"

function EventFrame:UPDATE_STEALTH()
    if IsStealthed() then

    end
end


if true then return end

local select, twipe, next, unpack = select, table.wipe, next, unpack

local Callbacks = {}


function F:RegisterForEvents(module, events)
    for event, units in pairs(events) do
        if not Callbacks[event] then
            Callbacks[event] = {}
            if event:match("^UNIT_") then
             --   frame:RegisterUnitEvent(event, unpack(units))
            else
            --    frame:RegisterEvent(event)
            end
        end
        Callbacks[event][module] = true
    end
end




local POOL = {}
local TEMP    = {}
C.EventPool   = C.EventPool or {}
local TRACKED = {}
local WAIT    = 0
local DELAY   = 0.2
local POOLFRAME = CreateFrame("Frame")
local function ReleaseTemp(t)
    twipe(t)
    tinsert(TEMP, t)
end
local function tableContains(tbl, element)
    for _, value in ipairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end
local function ProcessEvent(e, d)
    local pool = POOL.events[e]
    if not pool then
        return
    end
    for i, v in pairs(pool) do
        if i:IsVisible() then
            for _, func in ipairs(v.functions) do
                for _, data in ipairs(d) do
                    local unit = data[1]
                    if #v.units == 0 or tableContains(v.units, unit) then
                        func(i,v, unpack(data))
                    end
                end
            end
        end
    end

    for _, entry in ipairs(d) do
        ReleaseTemp(entry)
    end
end



local function AcquireTemp(...)
    local t = tremove(TEMP) or {}
    wipe(t)
    for i = 1, select("#", ...) do
        t[i] = select(i, ...)
    end
    return t
end


local function OnEvent(self, event, unit, ...)
    local pool = C.EventPool[event]
    if not pool then
        return
    end

    local data = AcquireTemp(unit, ...)
    ProcessEvent(event, { data })
    ReleaseTemp(data)
end
POOLFRAME:SetScript("OnEvent", function(_, event, unit, ...)
    for cb in pairs(Callbacks[event] or {}) do
        if cb.OnEvent then
            cb:OnEvent(event, unit, ...)
        end
    end
end)


local function OnUpdate(self, elapsed)
    WAIT = WAIT + elapsed
    if WAIT >= DELAY then
        for e, d in pairs(TRACKED) do
            ProcessEvent(e, d)
            TRACKED[e] = nil
        end
       WAIT = 0
        if next(POOL.events) == nil then
            self:Hide()
        end
    end
end


POOL:SetScript("OnEvent", OnEvent)
POOL:SetScript("OnUpdate", OnUpdate)

function F:UnregisterUnitEvent(frame, event, func, ...)
    local eventPool = self.events[event]
    if not eventPool then
        return
    end

    local framePool = eventPool[frame]
    if not framePool then
        return
    end

    for i = #framePool.functions, 1, -1 do
        if framePool.functions[i] == func then
            tremove(framePool.functions, i)
        end
    end

    if #framePool.functions == 0 then
        eventPool[frame] = nil
    end

    if next(eventPool) == nil then
        self.events[event] = nil
        self:UnregisterEvent(event)
    end

    if next(self.events) == nil then
        frame:Hide()
    end
end

function POOL:RegisterUnitEvent(frame, event, func, ...)
    local units = { ... }
    if not self.events[event] then
        self.events[event] = {}
        setmetatable(self.events[event], { __mode = "k" })
        frame:RegisterEvent(event)
        frame:Show()
    end

    local framePool = self.events[event][frame]
    if not framePool then
        framePool = { functions = {}, units = {} }
        self.events[event][frame] = framePool
    end

    tinsert(framePool.functions, func)

    for _, unit in ipairs(units) do
        if not tableContains(framePool.units, unit) then
            tinsert(framePool.units, unit)
        end
    end

    if not frame:IsShown() then
        frame:Show()
    end
end

function POOL:Register(frame, event, func, ...)
    local units = { ... }

    if not self.events[event] then
        self.events[event] = {}
        setmetatable(self.events[event], { __mode = "k" })
        frame:RegisterUnitEvent(event, unpack(units))
    end


    local framePool = self.events[event][frame]
    if not framePool then
        framePool = { functions = {}, units = {} }
        self.events[event][frame] = framePool
    end

    tinsert(framePool.functions, func)

    for _, unit in ipairs(units) do
        if not tableContains(framePool.units, unit) then
            tinsert(framePool.units, unit)
        end
    end

    if not frame:IsShown() then
        frame:Show()
    end
end
]]
