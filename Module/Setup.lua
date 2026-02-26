local _,Ether=...
local math_floor=math.floor
local tinsert=table.insert

function Ether:SetupUpdateText(button,tbl,p)
    if not button or not button.healthBar then
        return
    end
    local text=button.healthBar:CreateFontString(nil,"OVERLAY")
    button[tbl]=text
    text:SetFont(unpack(Ether.media.expressway),9,"OUTLINE")
    text:SetPoint("BOTTOMRIGHT",button.healthBar,"BOTTOMRIGHT",0,p and 1 or 10)
    text:SetTextColor(1,1,1)
    return button
end

function Ether:SetupName(button,number)
    if not button or not button.healthBar then
        return
    end
    local name=button.healthBar:CreateFontString(nil,"OVERLAY")
    button.name=name
    name:SetFont(Ether.DB[811][1] or unpack(Ether.media.expressway),12,"OUTLINE")
    name:SetPoint("CENTER",button.healthBar,"CENTER",0,number)
    name:SetTextColor(1,1,1)
    return button
end

function Ether:SetupButtonLayout(button)
    if not button then return end
    button.background=button:CreateTexture(nil,"BACKGROUND")
    button.background:SetTexture(Ether.DB[811][3])
    button.background:SetAllPoints(button)
    return button
end

function Ether:SetupBorderLayout(target)
    local Offset=2
    local top=target:CreateTexture(nil,"BORDER")
    top:SetPoint("TOPLEFT",target,"TOPLEFT",-Offset,Offset)
    top:SetPoint("TOPRIGHT",target,"TOPRIGHT",Offset,Offset)
    top:SetHeight(Offset)
    local bottom=target:CreateTexture(nil,"BORDER")
    bottom:SetPoint("BOTTOMLEFT",target.powerBar or target,"BOTTOMLEFT",-Offset,-Offset)
    bottom:SetPoint("BOTTOMRIGHT",target.powerBar or target,"BOTTOMRIGHT",Offset,-Offset)
    bottom:SetHeight(Offset)
    local left=target:CreateTexture(nil,"BORDER")
    left:SetPoint("TOPLEFT",target,"TOPLEFT",-Offset,Offset)
    left:SetPoint("BOTTOMLEFT",target.powerBar or target,"BOTTOMLEFT",-Offset,-Offset)
    left:SetWidth(Offset)
    local right=target:CreateTexture(nil,"BORDER")
    right:SetPoint("TOPRIGHT",target,"TOPRIGHT",Offset,Offset)
    right:SetPoint("BOTTOMRIGHT",target.powerBar or target,"BOTTOMRIGHT",Offset,-Offset)
    right:SetWidth(Offset)
    top:SetColorTexture(0,0,0,.8)
    bottom:SetColorTexture(0,0,0,.8)
    right:SetColorTexture(0,0,0,.8)
    left:SetColorTexture(0,0,0,.8)
end
--[[
function Ether:SetupButtonLayout(button)
    if not button then return end
    local bg=button:CreateTexture(nil,"BACKGROUND")
    button.background=bg
    bg:SetTexture(Ether.DB[811][3])
    bg:SetAllPoints()
    button.border =button:CreateTexture(nil,"BORDER")
    button.border:SetTexture(Ether.DB[811][3])
    local top=button:CreateTexture(nil,"BORDER")
    button.top=top
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(2)
    local bottom=button:CreateTexture(nil,"BORDER")
    button.bottom=bottom
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(2)
    local left=button:CreateTexture(nil,"BORDER")
    button.left=left
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    left:SetWidth(2)
    local right=button:CreateTexture(nil,"BORDER")
    button.right=right
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    right:SetWidth(2)


    local left, top, right, bottom=button.border:GetTextureSliceMargins()
    button.border:SetTextureSliceMargins(left, top, right, bottom)
    return button
end
]]
function Ether:SetupHealthBar(button,orient)
    if not button then return end
    local healthBar=CreateFrame("StatusBar",nil,button)
    button.healthBar=healthBar
    healthBar:SetAllPoints(button)
    healthBar:SetOrientation(orient)
    local bar=Ether.DB[811][2] or unpack(Ether.media.blankBar)
    healthBar:SetStatusBarTexture(bar)
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(button:GetFrameLevel()+3)
    local healthDrop=button:CreateTexture(nil,"OVERLAY")
    button.healthDrop=healthDrop
    healthDrop:SetAllPoints(healthBar)
    local r,g,b=Ether:GetClassColors("player")
    healthBar:SetStatusBarColor(r,g,b)
    healthDrop:SetTexture(unpack(Ether.media.blankBar))
    return button
end

function Ether:SetupPowerBar(button)
    if not button or not button.healthBar then return end
    local powerBar=CreateFrame("StatusBar",nil,button)
    button.powerBar=powerBar
    powerBar:SetPoint("TOPLEFT",button,"BOTTOMLEFT")
    local h=button:GetHeight()
    local w=button:GetWidth()
    powerBar:SetSize(w,8)
    powerBar:SetStatusBarTexture(unpack(Ether.media.blankBar))
    powerBar:SetFrameLevel(button:GetFrameLevel()+3)
    powerBar:SetMinMaxValues(0,100)
    local powerDrop=button:CreateTexture(nil,"OVERLAY")
    button.powerDrop=powerDrop
    powerDrop:SetAllPoints(powerBar)
    return button
end

function Ether:SetupPrediction(button)
    if not button or not button.healthBar then return end
    local player=CreateFrame("StatusBar",nil,button)
    button.myPrediction=player
    player:SetAllPoints(button.healthBar)
    player:SetStatusBarTexture(unpack(Ether.media.blankBar))
    player:SetStatusBarColor(0.00,0.80,1.00,.6)
    player:SetMinMaxValues(0,1)
    player:SetValue(1)
    player:Hide()
    player:SetFrameLevel(button:GetFrameLevel()+1)
    local from=CreateFrame("StatusBar",nil,button)
    button.otherPrediction=from
    from:SetAllPoints(button.healthBar)
    from:SetStatusBarTexture(unpack(Ether.media.blankBar))
    from:SetStatusBarColor(1.00,0.65,0.00,.5)
    from:SetMinMaxValues(0,1)
    from:SetValue(1)
    from:Hide()
    from:SetFrameLevel(button:GetFrameLevel()+1)
    return button
end

function Ether:SetupGreetings()
    local anime=CreateFrame('Frame',nil,UIParent)
    anime:SetSize(256,256)
    anime:SetPoint("TOPRIGHT")
    anime:SetFrameStrata("DIALOG")
    local ether=anime:CreateTexture(nil,"ARTWORK")
    ether:SetAllPoints(anime)
    ether:SetTexture("Interface\\AddOns\\Ether\\Media\\Graphic\\Ether.png")
    ether:SetVertexColor(1,1,1,1)
    local group=anime:CreateAnimationGroup()
    local fadeIn=group:CreateAnimation("Alpha")
    fadeIn:SetDuration(1.5)
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetOrder(0)
    local slide=group:CreateAnimation("Translation")
    slide:SetStartDelay(0.5)
    slide:SetDuration(1.5)
    slide:SetOffset(0,550)
    slide:SetSmoothing("IN_OUT")
    slide:SetOrder(1)
    group:SetScript("OnFinished",function(self)
        anime:Hide()
        anime:ClearAllPoints()
        anime:SetParent(nil)
        self:SetScript(nil)
    end)
    group:Play()
end

function Ether:SetupCastBar(button,number)
    if not button then
        return
    end
    local frame=CreateFrame("StatusBar",nil,UIParent)
    frame:SetParent(button)
    button.castBar=frame
    frame:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    local drop=frame:CreateTexture(nil,"OVERLAY")
    frame.drop=drop
    drop:SetAllPoints()
    local r,g,b=Ether:GetClassColors("player")
    frame:SetStatusBarColor(r,g,b,1)
    drop:SetColorTexture(0.2,0.2,0.4,.5)
    local text=frame:CreateFontString(nil,"OVERLAY")
    frame.text=text
    text:SetFont(Ether.DB[811][1] or unpack(Ether.media.expressway),12,"OUTLINE")
    text:SetPoint("LEFT",31,0)
    local time=frame:CreateFontString(nil,"OVERLAY")
    frame.time=time
    time:SetFont(Ether.DB[811][1] or unpack(Ether.media.expressway),12,"OUTLINE")
    time:SetPoint("RIGHT",frame,"RIGHT",-12,0)
    local icon=frame:CreateTexture(nil,"OVERLAY")
    icon:SetSize(16,16)
    frame.icon=icon
    icon:SetPoint("RIGHT",frame,"LEFT",0,0)
    local safeZone=frame:CreateTexture(nil,"OVERLAY")
    frame.safeZone=safeZone
    safeZone:SetColorTexture(1,0,0,1)
    frame.casting=nil
    frame.channeling=nil
    frame.duration=0
    frame.delay=0
    frame.timeToHold=0.1
    if number then
        local pos=Ether.DB[21][number]
        local config=Ether.DB[1301][number]
        frame:SetSize(pos[6],pos[7])
        frame:SetScale(pos[8])
        frame:SetAlpha(pos[9])
        frame:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
        text:SetFont(Ether.DB[811][1] or unpack(Ether.media.expressway),config[2],"OUTLINE")
        time:SetFont(Ether.DB[811][1] or unpack(Ether.media.expressway),config[3],"OUTLINE")
        icon:SetSize(config[1],config[1])
        Ether:SetupDrag(frame,number,10)
    end
    frame:Hide()
end

function Ether:SetupTooltip(button,unit)
    button:SetScript("OnEnter",function()
        GameTooltip:SetOwner(button,"ANCHOR_RIGHT")
        GameTooltip:SetUnit(unit)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)
end

function Ether:SetupAttribute(button,unit)
    button:RegisterForClicks("AnyUp")
    button:SetAttribute("unit",unit)
    button:SetAttribute("*type1","target")
    button:SetAttribute("*type2","togglemenu")
end

local initialGrid=false
function Ether:SetupGridFrame()
    if not initialGrid then
        initialGrid=true
        local frame=CreateFrame("Frame",nil,UIParent)
        Ether.gridFrame=frame
        frame:SetAllPoints(UIParent)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetFrameLevel(1)
        frame:SetAlpha(0.4)
        frame:Hide()
        local screenWidth,screenHeight=GetScreenWidth(),GetScreenHeight()
        local centerX,centerY=screenWidth/2,screenHeight/2
        local linePool={}
        local centerH=frame:CreateLine()
        centerH:SetColorTexture(0,1,0,0.8)
        centerH:SetThickness(4)
        centerH:SetStartPoint("TOPLEFT",UIParent,0,-centerY)
        centerH:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-centerY)
        local centerV=frame:CreateLine()
        centerV:SetColorTexture(0,1,0,0.8)
        centerV:SetThickness(4)
        centerV:SetStartPoint("TOPLEFT",UIParent,centerX,0)
        centerV:SetEndPoint("BOTTOMLEFT",UIParent,centerX,-screenHeight)
        for offset=100,math.max(centerX,centerY),100 do
            local yTop=centerY+offset
            local yBottom=centerY-offset
            if yTop<=screenHeight then
                local line=frame:CreateLine()
                line:SetColorTexture(1,0.5,0.5,0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT",UIParent,0,-yTop)
                line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yTop)
                tinsert(linePool,line)
            end
            if yBottom>=0 then
                local line=frame:CreateLine()
                line:SetColorTexture(1,0.5,0.5,0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT",UIParent,0,-yBottom)
                line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yBottom)
                tinsert(linePool,line)
            end
            local xRight=centerX+offset
            local xLeft=centerX-offset
            if xRight<=screenWidth then
                local line=frame:CreateLine()
                line:SetColorTexture(1,0.5,0.5,0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT",UIParent,xRight,0)
                line:SetEndPoint("BOTTOMLEFT",UIParent,xRight,-screenHeight)
                tinsert(linePool,line)
            end
            if xLeft>=0 then
                local line=frame:CreateLine()
                line:SetColorTexture(1,0.5,0.5,0.5)
                line:SetThickness(2)
                line:SetStartPoint("TOPLEFT",UIParent,xLeft,0)
                line:SetEndPoint("BOTTOMLEFT",UIParent,xLeft,-screenHeight)
                tinsert(linePool,line)
            end
        end
        for offset=20,math.max(centerX,centerY),20 do
            if offset%100~=0 then
                local yTop=centerY+offset
                local yBottom=centerY-offset
                if yTop<=screenHeight then
                    local line=frame:CreateLine()
                    line:SetColorTexture(0.8,0.8,0.8,0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT",UIParent,0,-yTop)
                    line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yTop)
                    tinsert(linePool,line)
                end
                if yBottom>=0 then
                    local line=frame:CreateLine()
                    line:SetColorTexture(0.8,0.8,0.8,0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT",UIParent,0,-yBottom)
                    line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yBottom)
                    tinsert(linePool,line)
                end
                local xRight=centerX+offset
                local xLeft=centerX-offset
                if xRight<=screenWidth then
                    local line=frame:CreateLine()
                    line:SetColorTexture(0.8,0.8,0.8,0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT",UIParent,xRight,0)
                    line:SetEndPoint("BOTTOMLEFT",UIParent,xRight,-screenHeight)
                    tinsert(linePool,line)
                end
                if xLeft>=0 then
                    local line=frame:CreateLine()
                    line:SetColorTexture(0.8,0.8,0.8,0.2)
                    line:SetThickness(1)
                    line:SetStartPoint("TOPLEFT",UIParent,xLeft,0)
                    line:SetEndPoint("BOTTOMLEFT",UIParent,xLeft,-screenHeight)
                    tinsert(linePool,line)
                end
            end
        end
    end
end

local function SnapToGrid(x,y,gridSize)
    local snappedX=x+gridSize/2/gridSize*gridSize
    local snappedY=y+gridSize/2/gridSize*gridSize
    return snappedX,snappedY
end

local function onStart(self)
    if not Ether.IsMovable then
        return
    end
    if self:IsMovable() then
        self:StartMoving()
    end
end

local function onStop(self,index,grid)
    if not Ether.IsMovable then
        return
    end
    if self:IsMovable() then
        self:StopMovingOrSizing()
    end
    local point,relTo,relPoint,x,y=self:GetPoint(1)
    local relToName="UIParent"
    if relTo then
        if relTo.GetName and relTo:GetName() then
            relToName=relTo:GetName()
        elseif relTo==UIParent then
            relToName="UIParent"
        else
            relToName="UIParent"
        end
    end

    local snapX,snapY=SnapToGrid(x,y,grid)
    if not Ether.DB or not Ether.DB[21] or not Ether.DB[21][index] then return end
    local DB=Ether.DB[21][index]
    DB[1]=point
    DB[2]=relToName
    DB[3]=relPoint
    DB[4]=math.floor(snapX)
    DB[5]=math.floor(snapY)
    local anchorRelTo=_G[relToName] or UIParent
    self:ClearAllPoints()
    self:SetPoint(DB[1],anchorRelTo,DB[3],snapX,snapY)
end

function Ether:SetupDrag(button,index,grid)
    if not button then
        return
    end
    if type(index)~="number" or type(grid)~="number" then
        return
    end
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetScript("OnDragStart",onStart)
    button:SetScript("OnDragStop",function(self)
        onStop(self,index,grid)
    end)
end

function Ether:SetupInfoFrame()
    if Ether.infoFrame then
        return
    end
    local frame=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
    Ether.infoFrame=frame
    frame:SetPoint("CENTER")
    frame:SetSize(320,200)
    frame:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true,
        tileSize=16,
        edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}
    })
    frame:SetBackdropColor(0.1,0.1,0.1,.9)
    frame:SetBackdropBorderColor(0.4,0.4,0.4)
    frame:SetSize(320,200)
    frame:SetFrameStrata("DIALOG")
    local sF=CreateFrame("ScrollFrame",nil,frame,"UIPanelScrollFrameTemplate")
    sF:SetPoint("TOPLEFT",10,-30)
    sF:SetPoint("BOTTOMRIGHT",-30,10)
    local cF=CreateFrame("Frame",nil,sF)
    cF:SetSize(390,111)
    sF:SetScrollChild(cF)
    local txt=cF:CreateFontString(nil,"OVERLAY")
    Ether.infoText=txt
    txt:SetFont(unpack(Ether.media.expressway),12,'OUTLINE')
    txt:SetPoint("TOPLEFT")
    txt:SetWidth(290)
    txt:SetJustifyH("LEFT")
    local top=frame:CreateFontString(nil,"OVERLAY")
    top:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    top:SetPoint("TOP",0,-10)
    top:SetText("|cE600CCFFEther|r")
    frame:Hide()
    Ether:ApplyFramePosition(frame,9)
    Ether:SetupDrag(frame,9,10)
    return frame
end

local function AuraPosition(i)
    local row=math_floor((i-1)/8)
    local col=(i-1)%8
    local xOffset=col*(14+1)
    local yOffset=1+row*(14+1)

    return xOffset,yOffset
end

local function SetupAuraIcon(button)
    local icon=button:CreateTexture(nil,"OVERLAY")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07,0.93,0.07,0.93)
    return icon
end

local function SetupAuraTimer(button,icon)
    local timer=CreateFrame("Cooldown",nil,button,"CooldownFrameTemplate")
    timer:SetAllPoints(icon)
    timer:SetHideCountdownNumbers(true)
    timer:SetReverse(true)
    timer:SetBlingTexture("Interface\\Cooldown\\star4_edge",1,1,1,1)
    return timer
end

local function SetupAuraCount(button)
    local count=button:CreateFontString(nil,"OVERLAY")
    count:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    count:SetPoint("LEFT")
    count:Hide()
    return count
end

function Ether:SoloAuraSetup(button)
    if not button then
        return
    end
    if not button.Aura then
        button.Aura={
            Buffs={},
            Debuffs={},
            LastBuffs={},
            LastDebuffs={}
        }
    end
    local unit=button.unit
    for i=1,16 do
        local aura=CreateFrame("Frame",nil,button)
        aura:SetSize(14,14)
        local xOffset,yOffset=AuraPosition(i)
        aura:SetPoint("BOTTOMLEFT",button,"TOPLEFT",xOffset-1,yOffset+2)
        aura:SetShown(false)
        aura.icon=SetupAuraIcon(aura)
        aura.count=SetupAuraCount(aura)
        aura.timer=SetupAuraTimer(aura,aura.icon)
        aura:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(unit,i,"HELPFUL")
            GameTooltip:Show()
        end)
        aura:SetScript("OnLeave",function()
            GameTooltip:Hide()
        end)
        button.Aura.Buffs[i]=aura
    end
    for i=1,16 do
        local aura=CreateFrame("Frame",nil,button)
        aura:SetSize(14,14)
        aura:SetShown(false)
        aura.icon=SetupAuraIcon(aura)
        aura.count=SetupAuraCount(aura)
        aura.timer=SetupAuraTimer(aura,aura.icon)
        local border=aura:CreateTexture(nil,"BORDER")
        border:SetColorTexture(1,0,0,1)
        border:SetPoint("TOPLEFT",-1,1)
        border:SetPoint("BOTTOMRIGHT",1,-1)
        border:Hide()
        aura:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetUnitAura(unit,i,"HARMFUL")
            GameTooltip:Show()
        end)
        aura:SetScript("OnLeave",function()
            GameTooltip:Hide()
        end)
        aura.border=border
        button.Aura.Debuffs[i]=aura
    end
end

function Ether:DispelIconSetup(button)
    local aura=CreateFrame("Frame",nil,UIParent)
    aura:SetFrameLevel(button:GetFrameLevel()+6)
    aura:SetPoint("CENTER",button,"CENTER",0,8)
    aura:SetSize(12,12)
    local icon=aura:CreateTexture(nil,"OVERLAY")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07,0.93,0.07,0.93)
    local border=aura:CreateTexture(nil,"BORDER")
    border:SetColorTexture(1,1,1,0)
    border:SetPoint("TOPLEFT",aura,"TOPLEFT",-1,1)
    border:SetPoint("BOTTOMRIGHT",aura,"BOTTOMRIGHT",1,-1)
    button.iconFrame=aura
    button.dispelIcon=icon
    button.dispelBorder=border
    return button
end

function Ether:CreatePopupBox()
    if Ether.popupBox then return end
    local frame=CreateFrame("Frame",nil,UIParent)
    Ether.popupBox=frame
    frame:Hide()
    frame:SetSize(320,200)
    frame:SetPoint("CENTER")
    frame.bg=frame:CreateTexture(nil,"BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture(unpack(Ether.media.etherEmblem))
    frame.font=frame:CreateFontString(nil,"OVERLAY")
    frame.font:SetFont(unpack(Ether.media.expressway),14,"OUTLINE")
    frame.font:SetPoint("TOP",0,-20)
    frame.font:SetIndentedWordWrap(true)
    local left=CreateFrame("Button",nil,frame)
    left:SetPoint("BOTTOMLEFT",0,5)
    left:SetSize(50,20)
    left.font=left:CreateFontString(nil,"OVERLAY")
    left.font:SetFont(unpack(Ether.media.expressway),16,"OUTLINE")
    left.font:SetPoint("CENTER")
    left.font:SetText("Yes")
    left:SetScript("OnEnter",function()
        left.font:SetTextColor(0.00,0.80,1.00,1)
    end)
    left:SetScript("OnLeave",function()
        left.font:SetTextColor(1,1,1,1)
    end)
    local right=CreateFrame("Button",nil,frame)
    right:SetPoint("BOTTOMRIGHT",0,5)
    right:SetSize(50,20)
    right.font=right:CreateFontString(nil,"OVERLAY")
    right.font:SetFont(unpack(Ether.media.expressway),16,"OUTLINE")
    right.font:SetText("No")
    right.font:SetPoint("CENTER")
    right:SetScript("OnEnter",function()
        right.font:SetTextColor(0.00,0.80,1.00,1)
    end)
    right:SetScript("OnLeave",function()
        right.font:SetTextColor(1,1,1,1)
    end)
    right:SetScript("OnClick",function()
        if Ether.popupBox:IsShown() then
            Ether.popupBox:SetShown(false)
            if Ether.UIPanel and Ether.UIPanel.Frames and Ether.UIPanel.Frames["MAIN"] then
                Ether.UIPanel.Frames["MAIN"]:SetShown(true)
            end
        end
    end)
    Ether.popupCallback=left
end

function Ether:CreateToolFrame()
    if Ether.toolFrame then return end
    local frame=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
    Ether.toolFrame=frame
    frame:SetFrameStrata("TOOLTIP")
    frame:SetSize(280,120)
    frame:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true,tileSize=16,edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}
    })
    frame:SetBackdropColor(0.08,0.08,0.08,0.8)
    frame:SetBackdropBorderColor(0.3,0.3,0.3,0.7)
    local name=frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    frame.name=name
    name:SetFont(unpack(Ether.media.expressway),14,"OUTLINE")
    name:SetPoint("TOPLEFT",12,-12)
    name:SetJustifyH("LEFT")
    name:SetTextColor(1,0.9,0.5,1)
    local nameLine=frame:CreateTexture(nil,"ARTWORK")
    nameLine:SetPoint("TOPLEFT",name,"BOTTOMLEFT",0,-4)
    nameLine:SetPoint("RIGHT",frame,-12,0)
    nameLine:SetHeight(1)
    nameLine:SetColorTexture(0.4,0.4,0.4,0.6)
    local guildIcon=frame:CreateTexture(nil,"OVERLAY")
    guildIcon:SetSize(12,12)
    guildIcon:SetTexture(135026)
    guildIcon:SetPoint("TOPLEFT",nameLine,"BOTTOMLEFT",0,-8)
    local guild=frame:CreateFontString(nil,"OVERLAY")
    frame.guild=guild
    guild:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    guild:SetPoint("LEFT",guildIcon,"RIGHT",4,0)
    guild:SetTextColor(0.7,0.7,1,1)
    local info=frame:CreateFontString(nil,"OVERLAY")
    frame.info=info
    info:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    info:SetPoint("TOPLEFT",guildIcon,"BOTTOMLEFT",0,-8)
    info:SetTextColor(0.8,0.8,0.8,1)
    local targetIcon=frame:CreateTexture(nil,"OVERLAY")
    targetIcon:SetSize(14,14)
    targetIcon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    targetIcon:SetPoint("TOPLEFT",info,"BOTTOMLEFT",0,-8)
    local target=frame:CreateFontString(nil,"OVERLAY")
    frame.target=target
    target:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    target:SetPoint("LEFT",targetIcon,"RIGHT",4,0)
    target:SetJustifyH("LEFT")
    target:SetTextColor(1,0.5,0.5,1)
    local flags=frame:CreateFontString(nil,"OVERLAY")
    frame.flags=flags
    flags:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    flags:SetPoint("BOTTOMRIGHT",frame,-10,10)
    flags:SetJustifyH("RIGHT")
    flags:SetTextColor(0.6,0.6,0.6,1)
    local pvpBg=CreateFrame("Frame",nil,frame,"BackdropTemplate")
    pvpBg:SetSize(22,22)
    pvpBg:SetPoint("TOPRIGHT",frame,-8,-8)
    pvpBg:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize=8,
        insets={left=2,right=2,top=2,bottom=2}
    })
    pvpBg:SetBackdropColor(0,0,0,0.5)
    pvpBg:SetBackdropBorderColor(0.5,0.5,0.5,1)
    local pvp=frame:CreateTexture(nil,"OVERLAY")
    frame.pvp=pvp
    pvp:SetAllPoints(pvpBg)
    local restBg=CreateFrame("Frame",nil,frame,"BackdropTemplate")
    restBg:SetSize(22,22)
    restBg:SetPoint("RIGHT",pvpBg,"LEFT",-6,0)
    restBg:SetBackdrop(pvpBg:GetBackdrop())
    restBg:SetBackdropColor(0,0,0,0.5)
    restBg:SetBackdropBorderColor(0.5,0.5,0.5,1)
    local resting=frame:CreateTexture(nil,"OVERLAY")
    frame.resting=resting
    resting:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    resting:SetTexCoord(0.0625,0.45,0.0625,0.45)
    resting:SetPoint("CENTER",restBg)
    resting:SetAllPoints(restBg)
    frame:Hide()
    Ether:ApplyFramePosition(frame,1)
    Ether:SetupDrag(frame,1,10)
end
--[[
local function HexToRGB(hex)
    hex = hex:gsub('#', '')
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return r, g, b
end

local function LeapColor(r1, g1, b1, r2, g2, b2, t)
    return r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t
end

local cFF = "|cff%02x%02x%02x"
function Ether:BuildGradientTable(colorDef)
    local steps = {}
    for i = 0, 100 do
        local pct = i / 100
        local prev, nextC
        for idx = 1, #colorDef - 1 do
            if pct >= colorDef[idx][1] and pct <= colorDef[idx + 1][1] then
                prev = colorDef[idx]
                nextC = colorDef[idx + 1]
                break
            end
        end
        if not prev then
            prev, nextC = colorDef[#colorDef - 1], colorDef[#colorDef]
        end
        local pr, pg, pb = HexToRGB(prev[2])
        local nr, ng, nb = HexToRGB(nextC[2])
        local range = (nextC[1] - prev[1])
        local t = range > 0 and (pct - prev[1]) / range or 0

        local r, g, b = LeapColor(pr, pg, pb, nr, ng, nb, t)
        steps[i] = string_format(cFF, r * 255, g * 255, b * 255)
    end
    return steps
end

]]