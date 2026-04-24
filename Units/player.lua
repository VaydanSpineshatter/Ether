local D,F,_,_,_=unpack(select(2,...))
local UnitGUID=UnitGUID
local customBtn,soloBtn=D.customBtn,D.soloBtn
local function OnAttributeChanged(self)
    self.unit=self:GetAttribute("unit")
    local guid=self.unit and UnitGUID(self.unit)
    if (guid~=self.unitGUID) then
        self.unitGUID=guid
        if (guid) then
            F:FullHealthUpdate(self)
            F:FullPowerUpdate(self)
            F:UpdateName(self,6)
        end
    end
end
function F:CreateUnitButtons(index)
    local unit=D:PosUnit(index)
    local button=CreateFrame("Button","Ether_"..unit.."_UnitButton",UIParent,"EtherUnitTemplate")
    button.unit=unit
    button.index=index
    local name=button:GetName()
    local healthBar=CreateFrame("StatusBar",name.."_HealthBar",button)
    button.healthBar=healthBar
    healthBar:SetOrientation("HORIZONTAL")
    healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(button:GetFrameLevel()+3)
    local powerBar=CreateFrame("StatusBar",name.."_PowerBar",button)
    button.powerBar=powerBar
    powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    powerBar:SetFrameLevel(button:GetFrameLevel()+3)
    powerBar:SetMinMaxValues(0,100)
    local healthDrop=button:CreateTexture(name.."_HealthDrop","ARTWORK",nil,-7)
    button.healthDrop=healthDrop
    healthDrop:SetAllPoints()
    local powerDrop=button:CreateTexture(name.."_PowerDrop","ARTWORK",nil,-7)
    button.powerDrop=powerDrop
    powerDrop:SetAllPoints(powerBar)
    powerBar:SetPoint("BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT")
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetPoint("TOPRIGHT")
    healthBar:SetPoint("BOTTOM",powerBar,"TOP",0,1)
    button:SetScript("OnSizeChanged",function(_,_,height)
        local pH=height*0.15
        powerBar:SetHeight(pH)
    end)
    Mixin(healthBar,SmoothStatusBarMixin)
    Mixin(powerBar,SmoothStatusBarMixin)
    button.smooth=true
    F:SetupTooltip(button,button.unit)
    F:SetupPrediction(button)
    F:SetupButtonBackground(button)
    F:SetupButtonBorder(button)
    F:SetupName(button,0)
    button.RaidTarget=button.healthBar:CreateTexture(nil,"OVERLAY")
    button.RaidTarget:SetSize(18,18)
    button.RaidTarget:SetPoint("LEFT",button.healthBar,"LEFT",5,0)
    F.UpdateClassColor(button)
    F.DisplayPower(button)
    if not InCombatLockdown() then
        button:SetAttribute("unit",button.unit)
        button:SetAttribute("*type1","target")
        button:SetAttribute("*type2","togglemenu")
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
    end
    if button.unit~="player" then
        RegisterUnitWatch(button)
    end
    button:HookScript("OnAttributeChanged",OnAttributeChanged)
    OnAttributeChanged(button)
    soloBtn[button.index]=button
    D:ApplyFramePosition(button)
    F:SetupDrag(button)
end

function F:ActivateUnitButton(index)
    local button=soloBtn[index]
    if not button then return end
    local unit=D:PosUnit(index)
    button.unit=unit
    if not InCombatLockdown() then
        button:SetAttribute("unit",button.unit)
        button:SetAttribute("*type1","target")
        button:SetAttribute("*type2","togglemenu")
        button:RegisterForClicks("AnyUp")
        button:RegisterForDrag("LeftButton")
        button.unit=nil
        button.unitGUID=nil
    end
    if unit~="player" then
        RegisterUnitWatch(button)
    end
    button:EnableMouse(true)
    button:SetMovable(true)
    D:ApplyFramePosition(button)
    F:SetupDrag(button)
    button:SetScript("OnEvent",Event)
    OnAttributeChanged(button)
    button:Show()
end

function F:DeactivateUnitButton(index)
    if soloBtn[index] then
        local button=soloBtn[index]
        button:Hide()
        button:ClearAllPoints()
        if not InCombatLockdown() then
            button:SetAttribute("unit",nil)
            button:SetAttribute("*type1",nil)
            button:SetAttribute("*type2",nil)
            button:RegisterForClicks()
            button:RegisterForDrag()
        end
        button:EnableMouse(false)
        button:SetMovable(false)
        if button.unit~="player" then
            UnregisterUnitWatch(button)
        end
        button:SetScript("OnDragStart",nil)
        button:SetScript("OnDragStop",nil)
    end
end

local currentTotal=0
local expectedMax=100
function F:updateHealth(amount)
    if amount<=0 then return end
    currentTotal=currentTotal+amount
    if expectedMax<=0 then
        expectedMax=amount*10
    end
    if currentTotal>=expectedMax then
        expectedMax=currentTotal+(amount*2)
    end
    local barValue=((expectedMax-currentTotal)/expectedMax)*100
    customBtn[1].healthBar:SetMinMaxValues(0,expectedMax or 100)
    customBtn[1].healthBar:SetValue(barValue)
end
local function updatePower(button)
    if not button then
        return
    end
    local power,powerMax=UnitPower(button.unit),UnitPowerMax(button.unit)
    if button.powerBar and powerMax>0 then
        button.powerBar:SetMinMaxValues(0,powerMax)
        button.powerBar:SetValue(power)
    end
end
function F:DestroyCustom(number)
    if not customBtn[number] or not customBtn[number].destGUID then
        return
    end
    local button=customBtn[number]
    button:Hide()
    button.destGUID=nil
end
function F:CreateCustomUnit(destGUID,index)
    local button=CreateFrame("Button",nil,UIParent)
    local pos=D.DB[21][7]
    button:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
    button:SetSize(pos[6] or 110,pos[7] or 40)
    button.destGUID=destGUID
    button.index=index
    local healthBar=CreateFrame("StatusBar",nil,button)
    button.healthBar=healthBar
    healthBar:SetOrientation("HORIZONTAL")
    healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK",-7)
    healthBar:SetFrameLevel(button:GetFrameLevel()+3)
    local healthDrop=button:CreateTexture(nil,"ARTWORK",nil,-7)
    button.healthDrop=healthDrop
    healthDrop:SetAllPoints()
    healthBar:SetAllPoints()
    F:SetupButtonBackground(button)
    F:SetupButtonBorder(button)
    F:SetupName(button,6)
    customBtn[1]=button
    -- updateFunc()
end

--[[
local updateTicker = nil
local C_Ticker = C_Timer.NewTicker

local function updateCustom()
    -- for i = 1, 3 do
    F:updateHealth(C.customBtn[1])
    --  updatePower(C.customButtons[i])
    -- end
end

local function updateFunc()
    if not updateTicker then
        updateTicker = C_Ticker(0.1, updateCustom)
    end
end
function F:CleanUpCustom(numb)
    if not customBtn[numb] then
        return
    end
    F:DestroyCustom(numb)
    if not next(customBtn) and updateTicker then
        updateTicker:Cancel()
        if updateTicker:IsCancelled() then
            updateTicker = nil
        else
            C:EtherInfo("Custom Updater is not cancelled. Reload UI")
        end
    end
end
    button:ClearAllPoints()
    button:RegisterForClicks()
    button:RegisterForDrag()
    button:SetAttribute("unit", nil)
    button:SetScript("OnDragStart", nil)
    button:SetScript("OnDragStop", nil)
    button:SetScript("OnEnter", nil)
    button:SetScript("OnLeave", nil)
local function GUIDToUnit(unit)
    local guid = UnitGUID(unit)
    local name = UnitName(unit)
    local token = UnitTokenFromGUID(guid)
    if guid and name and token then
        return guid, name, token
    end
end

     local parent=panel["CONTENT"]["CHILDREN"]["Custom"]
    if parent.Created then return end
    parent.Created=true

    local color={
        [1]={0.2,0.6,1.0,1},
        [2]={0.6,0.4,0.0,1},
        [3]={0.6,0.2,1.0,1}
    }
    local create=EtherPanelButton(parent,120,25,"Select Custom","TOPLEFT",parent,"TOPLEFT",5,-5)
    local destroy=EtherPanelButton(parent,120,25,"Select Custom","TOPLEFT",create,"BOTTOMLEFT",0,-5)
    local customConfig={}
    local customDropDown
    local dataNumber=0
    local indicator
    for index,configName in ipairs({"Custom 1","Custom 2","Custom 3"}) do
        table.insert(customConfig,{
            text=configName,
            func=function()
                indicator:Show()
                dataNumber=index
                create.text:SetText("Create "..configName)
                local pos=Ether.DB[23][dataNumber]
                indicator:ClearAllPoints()
                indicator:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
                indicator.tex:SetColorTexture(unpack(color[dataNumber]))
                destroy.text:SetText("Destroy "..configName)
                customDropDown.text:SetText("Selected "..configName)
            end
        })
    end

    customDropDown=Ether:CreateEtherDropdown(parent,140,"Select Custom",customConfig,true)
    customDropDown:SetPoint("TOPRIGHT")
    local box=CreateFrame("Frame",nil,parent)
    box:SetSize(240,240)
    box:SetPoint("CENTER",parent,"CENTER",60,0)
    box.l=box:CreateTexture(nil,"BORDER")
    box.l:SetPoint("TOPLEFT")
    box.l:SetPoint("BOTTOMLEFT")
    box.l:SetWidth(2)
    box.l:SetColorTexture(0.80,0.40,1.00,1)
    box.r=box:CreateTexture(nil,"BORDER")
    box.r:SetPoint("TOPRIGHT")
    box.r:SetPoint("BOTTOMRIGHT")
    box.r:SetWidth(2)
    box.r:SetColorTexture(0.80,0.40,1.00,1)
    box.t=box:CreateTexture(nil,"BORDER")
    box.t:SetPoint("TOPLEFT")
    box.t:SetPoint("TOPRIGHT")
    box.t:SetHeight(2)
    box.t:SetColorTexture(0.80,0.40,1.00,1)
    box.b=box:CreateTexture(nil,"BORDER")
    box.b:SetPoint("BOTTOMLEFT")
    box.b:SetPoint("BOTTOMRIGHT")
    box.b:SetHeight(2)
    box.b:SetColorTexture(0.80,0.40,1.00,1)

    indicator=CreateFrame("Frame",nil,box)
    indicator:SetParent(box)
    indicator:SetSize(110,40)
    indicator:SetClampedToScreen(true)
    indicator:SetFrameLevel(box:GetFrameLevel()+3)
    indicator:SetPoint("CENTER")
    indicator:SetMovable(true)
    indicator:EnableMouse(true)
    indicator:RegisterForDrag("LeftButton")
    indicator.tex=indicator:CreateTexture(nil,"OVERLAY")
    indicator.tex:SetAllPoints()
    indicator.tex:SetBlendMode("BLEND")
    indicator:Hide()
    indicator:SetScript("OnDragStart",Drag)
    indicator:SetScript("OnDragStop",function(self)
        StopDrag(self,dataNumber)
    end)

    local show=EtherPanelButton(parent,100,25,"Show Indicators","TOP",parent,"TOP",0,-5)
    show:SetScript("OnClick",function()
        if not indicator:IsShown() then
            indicator:Show()
        else
            indicator:Hide()
        end
    end)
    create:SetScript("OnClick",function()
        if dataNumber==0 then
            return
        end
        Ether:CreateCustomUnit(dataNumber)
    end)
    destroy:SetScript("OnClick",function()
        if dataNumber==0 then
            return
        end
        Ether:CleanUpCustom(dataNumber)
    end)

local function Drag(self)
    if self:IsMovable() then
        self:StartMoving()
    end
end

local function StopDrag(self, dataNumber)
    if self:IsMovable() then
        self:StopMovingOrSizing()
    end
    local point, relTo, relPoint, x, y = self:GetPoint(1)
    local relToName = "UIParent"
    if relTo then
        if relTo.GetName and relTo:GetName() then
            relToName = relTo:GetName()
        elseif relTo == UIParent then
            relToName = "UIParent"
        else
            relToName = "UIParent"
        end
    end
    local DB = D.DB
    local pos = DB[1401][dataNumber]
    pos[1] = point
    pos[2] = relToName
    pos[3] = relPoint
    pos[4] = x
    pos[5] = y
    local anchorRelTo = relToName
    self:ClearAllPoints()
    self:SetPoint(pos[1], anchorRelTo, pos[3], x, y)
    if customButtons[dataNumber] and customButtons[dataNumber]:IsVisible() then
        customButtons[dataNumber]:ClearAllPoints()
        customButtons[dataNumber]:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
    end
end

    if subevent=="SWING_DAMAGE" then
        if destGUID~=snapshot then return end
        local amount=arg12 --  12. Parameter
    elseif subevent=="SPELL_DAMAGE" or subevent=="RANGE_DAMAGE" then
        if destGUID~=snapshot then return end
        local amount=arg15 --  15. Parameter
        if not amount then return end
        print(amount)
        F:updateHealth(amount)
        if sourceName==D.customBtn[1].lastname then return end
        D.customBtn[1].lastname=sourceName
        D.customBtn[1].name:SetText(sourceName)
    elseif subevent=="UNIT_DIED" then
        if destGUID~=snapshot then return end
        snapshot=nil
        F:DestroyCustom(1)
    end
local function OnEvent(self, event)
    local _, subevent, _, _, _, _, _, destGUID, _, _, _ = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_DAMAGE" or subevent == "SWING_DAMAGE" then
        if destGUID == meineGespeicherteBossGUID then
            local amount
            if subevent == "SWING_DAMAGE" then
                amount = select(12, CombatLogGetCurrentEventInfo())
            else
                amount = select(15, CombatLogGetCurrentEventInfo())
            end

            print("Boss: " .. amount)
        end
    end
end
local myBossGUID = nil

local tracker = CreateFrame("Frame")
tracker:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT") -- Boss erscheint
tracker:RegisterEvent("PLAYER_TARGET_CHANGED")        -- Ziel wechselt

tracker:SetScript("OnEvent", function(self, event)
    if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        -- Wir prüfen boss1 bis boss5
        for i = 1, 5 do
            local unit = "boss" .. i
            if UnitExists(unit) then
                myBossGUID = UnitGUID(unit)
                print("Boss Name:", UnitName(unit), "GUID:", myBossGUID)
                break
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") then
            myBossGUID = UnitGUID("target")
        end
    end
end)
local combatLogFrame = CreateFrame("Frame")
combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

combatLogFrame:SetScript("OnEvent", function(self)
    -- Lade alle Daten des Events
    local timestamp, subevent, _, _, _, _, _, destGUID, _, _, _, arg12, arg13, arg14, arg15 = CombatLogGetCurrentEventInfo()

    -- SCHRITT 1: Ist es überhaupt unser Boss? (Performance-Check Nr. 1)
    if destGUID ~= myBossGUID then return end

    -- SCHRITT 2: Welches Event ist passiert?
    if subevent == "SWING_DAMAGE" then
        local amount = arg12 -- Bei Swing ist Schaden der 12. Parameter
        print("Boss kassiert Melee-Hit:", amount)

    elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        local amount = arg15 -- Bei Spells ist Schaden der 15. Parameter
        print("Boss kassiert Zauber-Schaden:", amount)

    elseif subevent == "UNIT_DIED" then
        print("Boss besiegt!")
        myBossGUID = nil -- Zurücksetzen für den nächsten Boss
    end
end)
local function CreateDamageText(parent, amount, color)
    local text = parent:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
    text:SetPoint("CENTER", parent, "CENTER", math.random(-20, 20), math.random(-10, 10))
    text:SetText("-" .. amount)
    text:SetTextColor(unpack(color))
    local alpha = 1
    local yOffset = 0
    text:SetScript("OnUpdate", function(self, elapsed)
        alpha = alpha - elapsed
        yOffset = yOffset + (elapsed * 50)
        self:SetAlpha(alpha)
        self:SetPoint("CENTER", parent, "CENTER", 0, yOffset)

        if alpha <= 0 then
            self:SetScript("OnUpdate", nil)
            self:Hide()
        end
    end)
end
combatLogFrame:SetScript("OnEvent", function(self)
    local _, subevent, _, _, _, _, _, destGUID, _, _, _, arg12, arg13, arg14, arg15, arg16, arg17, arg18 = CombatLogGetCurrentEventInfo()

    if destGUID ~= myBossGUID then return end

    local amount, critical

    if subevent == "SWING_DAMAGE" then
        amount = arg12
        critical = arg18 -- 18. Parameter bei Swing ist Crit (boolean/1)
    elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        amount = arg15
        critical = arg21
    end

    if amount and myCustomBossFrame then
        local color = critical and {1, 1, 0} or {1, 1, 1} -- Gelb für Crit, Weiß für Normal
        CreateDamageText(myCustomBossFrame, amount, color)
    end
end)
local ag = text:CreateAnimationGroup()
local move = ag:CreateAnimation("Translation")
move:SetOffset(0, 50)
move:SetDuration(0.8)

local fade = ag:CreateAnimation("Alpha")
fade:SetFromAlpha(1)
fade:SetToAlpha(0)
fade:SetDuration(0.8)

ag:SetScript("OnFinished", function() text:Hide() end)
ag:Play()

]]
