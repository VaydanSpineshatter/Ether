local D,F,_,C=unpack(select(2,...))
local GameTooltip,mfloor=GameTooltip,math.floor
local tostring,tonumber,UIParent=tostring,tonumber,UIParent
local _,screenHeight=GetPhysicalScreenSize()
local pixelScale=1/(768/screenHeight)
local function SnapToGrid(x,y,g)
    local gx=mfloor(x/g+0.5)*g
    local gy=mfloor(y/g+0.5)*g
    local snappedX=mfloor((gx/pixelScale)+0.5)*pixelScale
    local snappedY=mfloor((gy/pixelScale)+0.5)*pixelScale
    return snappedX,snappedY
end
local function DragStart(self)
    if not C.IsMovable then
        return
    end
    if not self:IsMovable() then return end
    self:StartMoving()
    if self.index==19 then
        self.moving=true
        GameTooltip:Hide()
    end
end
local function DragStop(self)
    if not C.IsMovable then return end
    self:StopMovingOrSizing()
    if self.index==19 then
        self.moving=false
        GameTooltip:Show()
    end
    local point,relTo,relPoint,x,y=self:GetPoint(1)
    local relToName="UIParent"
    if relTo and relTo.GetName and relTo:GetName() then
        relToName=relTo:GetName()
    end
    local gridSize=5
    local snappedX,snappedY=SnapToGrid(x,y,gridSize)
    D.DB[21][self.index][1]=point
    D.DB[21][self.index][2]=relToName
    D.DB[21][self.index][3]=relPoint
    D.DB[21][self.index][4]=snappedX
    D.DB[21][self.index][5]=snappedY
    D:ApplyFramePosition(self)
end
function F:SetupDrag(frame)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:SetScript("OnDragStart",DragStart)
    frame:SetScript("OnDragStop",DragStop)
end

function F:RemoveDrag(frame)
    frame:RegisterForDrag()
    frame:SetMovable(false)
    frame:SetScript("OnDragStart",nil)
    frame:SetScript("OnDragStop",nil)
    frame:EnableMouse(false)
end
function F:SetupPowerText(button)
    if not button or not button.healthBar then
        return
    end
    local text=button.healthBar:CreateFontString(nil,"OVERLAY")
    button.power=text
    text:SetFontObject(C.EtherFont)
    text:SetPoint("BOTTOMRIGHT",button.healthBar,"BOTTOMRIGHT",1,0)
    text:SetTextColor(1,1,1)
    return button
end
function F:SetupHealthText(button)
    if not button or not button.healthBar then
        return
    end
    local text=button.healthBar:CreateFontString(nil,"OVERLAY")
    button.health=text
    text:SetFontObject(C.EtherFont)
    text:SetPoint("BOTTOMLEFT",button.healthBar,"BOTTOMLEFT")
    text:SetTextColor(1,1,1)
    return button
end
function C:ToggleUser()
    if InCombatLockdown() then return end
    if not C.created then
        C:Main()
    end
    if not C.MainFrame then return end
    D.DB["CONFIG"][3]=F:ToggleBinary(D.DB["CONFIG"][3])
    if C.DropdownMenu then
        C.DropdownMenu:Hide()
    end
    if C.DropdownText then
        C.DropdownText:SetAlpha(1)
    end
    C.MainFrame:SetShown(F:BinaryCondition(D.DB["CONFIG"][3]))
end
function F:SetupName(button,number)
    if not button then return end
    local name=button.healthBar:CreateFontString(nil,"OVERLAY")
    button.name=name
    name:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",11,"OUTLINE")
    name:SetPoint("CENTER",button.healthBar,"CENTER",0,number)
    return button
end
function F:SetupButtonBackground(button)
    if not button then return end
    local bg=button:CreateTexture(nil,"BACKGROUND")
    button.bg=bg
    bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    bg:SetColorTexture(0,0,0,.8)
    bg:SetAllPoints(button)
    return button
end
function F:SetupHeaderBackground(frame)
    if not frame then return end
    local tex=frame:CreateTexture(nil,"BACKGROUND")
    frame.tex=tex
    tex:SetSize(32,32)
    tex:SetAllPoints()
    tex:SetColorTexture(0,1,0,.7)
    tex:Hide()
    D:ApplyFramePosition(frame)
    F:SetupDrag(frame)
end
function F:SetupButtonBorder(button)
    local r,g,b,a=0,0,0,1
    local p=pixelScale
    local top=button:CreateTexture(nil,"BORDER")
    button.top=top
    top:SetPoint("TOPLEFT",button,"TOPLEFT",-p,p)
    top:SetPoint("TOPRIGHT",button,"TOPRIGHT",p,p)
    top:SetHeight(p)
    top:SetColorTexture(r,g,b,a)
    local bottom=button:CreateTexture(nil,"BORDER")
    button.bottom=bottom
    bottom:SetPoint("BOTTOMLEFT",button,"BOTTOMLEFT",-p,-p)
    bottom:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",p,-p)
    bottom:SetHeight(p)
    bottom:SetColorTexture(r,g,b,a)
    local left=button:CreateTexture(nil,"BORDER")
    button.left=left
    left:SetPoint("TOPLEFT",button,"TOPLEFT",-p,p)
    left:SetPoint("BOTTOMLEFT",button,"BOTTOMLEFT",-p,-p)
    left:SetWidth(p)
    left:SetColorTexture(r,g,b,a)
    local right=button:CreateTexture(nil,"BORDER")
    button.right=right
    right:SetPoint("TOPRIGHT",button,"TOPRIGHT",p,p)
    right:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",p,-p)
    right:SetWidth(p)
    right:SetColorTexture(r,g,b,a)
    button.topDispel=false
    return button
end
function F:SetupHealthBar(button,orient)
    if not button then return end
    local name=button:GetName()
    local healthBar=CreateFrame("StatusBar",name.."_HealthBar",button)
    healthBar:SetParent(button)
    button.healthBar=healthBar
    healthBar:SetOrientation(orient)
    healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(button:GetFrameLevel()+3)
    healthBar:SetPoint("TOPLEFT",button,"TOPLEFT")
    healthBar:SetHeight(27)
    healthBar:SetWidth(110)
    local healthDrop=button:CreateTexture(name.."_HealthDrop","OVERLAY")
    button.healthDrop=healthDrop
    healthDrop:SetAllPoints()
    healthDrop:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    return button
end
function F:SetupPowerBar(button)
    if not button then return end
    local name=button:GetName()
    local powerBar=CreateFrame("StatusBar",name.."_PowerBar",button)
    button.powerBar=powerBar
    powerBar:SetHeight(5)
    powerBar:SetWidth(110)
    powerBar:SetPoint("BOTTOMLEFT")
    powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    powerBar:SetFrameLevel(button:GetFrameLevel()+3)
    powerBar:SetMinMaxValues(0,100)
    local powerDrop=button:CreateTexture(name.."_PowerDrop","OVERLAY")
    button.powerDrop=powerDrop
    powerDrop:SetAllPoints(powerBar)
    return button
end
function F:SetupSlash()
    SLASH_ETHER1="/ether"
    SlashCmdList["ETHER"]=function(msg)
        local input,rest=msg:match("^(%S*)%s*(.-)$")
        input=string.lower(input or "")
        rest=string.lower(rest or "")
        if input=="user" then
            C:ToggleUser()
        elseif input=="rl" then
            if not InCombatLockdown() then
                ReloadUI()
            end
        elseif input=="help" then
            F:AddonUsage()
        else
            C:ToggleUser()
        end
    end
end
function F:SetupPrediction(button)
    if not button then
        return
    end
    local player=CreateFrame("StatusBar",nil,button)
    button.myPrediction=player
    player:SetAllPoints(button.healthBar)
    player:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    player:SetStatusBarColor(0,1,0)
    player:SetMinMaxValues(0,1)
    player:SetValue(1)
    player:Hide()
    player:SetFrameLevel(button:GetFrameLevel()+1)
    local from=CreateFrame("StatusBar",nil,button)
    button.prediction=from
    from:SetAllPoints(button.healthBar)
    from:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    from:SetStatusBarColor(0.5,0,0.5)
    from:SetMinMaxValues(0,1)
    from:SetValue(1)
    from:Hide()
    from:SetFrameLevel(button:GetFrameLevel()+1)
    return button
end
function F:SetupCastBar()
    local frame=CreateFrame("StatusBar",nil,UIParent)
    frame:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    local drop=frame:CreateTexture(nil,"OVERLAY")
    drop:SetAllPoints()
    local r,g,b=F:GetClassColor("player")
    frame:SetStatusBarColor(r,g,b,1)
    drop:SetColorTexture(0.2,0.2,0.4,.5)
    local text=frame:CreateFontString(nil,"OVERLAY")
    text:SetFontObject(C.EtherFont)
    text:SetPoint("LEFT",31,0)
    local time=frame:CreateFontString(nil,"OVERLAY")
    time:SetFontObject(C.EtherFont)
    time:SetPoint("RIGHT",frame,"RIGHT",-12,0)
    local icon=frame:CreateTexture(nil,"OVERLAY")
    icon:SetSize(16,16)
    icon:SetPoint("RIGHT",frame,"LEFT",0,0)
    local safeZone=frame:CreateTexture(nil,"OVERLAY")
    safeZone:SetColorTexture(1,0,0,1)
    local shield=frame:CreateTexture(nil,"OVERLAY")
    shield:SetSize(20,20)
    shield:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-LockIcon")
    shield:SetPoint("CENTER",frame.icon,"CENTER",0,0)
    shield:Hide()
    frame.shield=shield
    frame.safeZone=safeZone
    frame.time=time
    frame.drop=drop
    frame.icon=icon
    frame.text=text
    frame.casting=nil
    frame.channeling=nil
    frame.duration=0
    frame.delay=0
    frame.timeToHold=0.05
    frame:Hide()
    return frame
end
function F:SetupTooltip(button,unit)
    button:SetScript("OnEnter",function()
        GameTooltip:SetOwner(button,"ANCHOR_RIGHT")
        GameTooltip:SetUnit(unit)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)
end
function F:SetupAttribute(button,unit)
    button:RegisterForClicks("AnyUp")
    button:SetAttribute("unit",unit)
    button:SetAttribute("*type1","target")
    button:SetAttribute("*type2","togglemenu")
end
local linePool={}
function F:SetupGridFrame()
    if C.GridFrame then return end
    local frame=CreateFrame("Frame",nil,UIParent)
    C.GridFrame=frame
    frame:SetAllPoints(UIParent)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(1)
    frame:SetAlpha(0.4)
    frame:Hide()
    local screenWidth,screenH=GetScreenWidth(),GetScreenHeight()
    local centerX,centerY=screenWidth/2,screenH/2
    local centerH=frame:CreateLine()
    centerH:SetColorTexture(0,1,0,0.8)
    centerH:SetThickness(4)
    centerH:SetStartPoint("TOPLEFT",UIParent,0,-centerY)
    centerH:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-centerY)
    local centerV=frame:CreateLine()
    centerV:SetColorTexture(0,1,0,0.8)
    centerV:SetThickness(4)
    centerV:SetStartPoint("TOPLEFT",UIParent,centerX,0)
    centerV:SetEndPoint("BOTTOMLEFT",UIParent,centerX,-screenH)
    for offset=100,math.max(centerX,centerY),100 do
        local yTop=centerY+offset
        local yBottom=centerY-offset
        if yTop<=screenH then
            local line=frame:CreateLine()
            line:SetColorTexture(1,0.5,0.5,0.5)
            line:SetThickness(2)
            line:SetStartPoint("TOPLEFT",UIParent,0,-yTop)
            line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yTop)
            linePool[#linePool+1]=line
        end
        if yBottom>=0 then
            local line=frame:CreateLine()
            line:SetColorTexture(1,0.5,0.5,0.5)
            line:SetThickness(2)
            line:SetStartPoint("TOPLEFT",UIParent,0,-yBottom)
            line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yBottom)
            linePool[#linePool+1]=line
        end
        local xRight=centerX+offset
        local xLeft=centerX-offset
        if xRight<=screenWidth then
            local line=frame:CreateLine()
            line:SetColorTexture(1,0.5,0.5,0.5)
            line:SetThickness(2)
            line:SetStartPoint("TOPLEFT",UIParent,xRight,0)
            line:SetEndPoint("BOTTOMLEFT",UIParent,xRight,-screenH)
            linePool[#linePool+1]=line
        end
        if xLeft>=0 then
            local line=frame:CreateLine()
            line:SetColorTexture(1,0.5,0.5,0.5)
            line:SetThickness(2)
            line:SetStartPoint("TOPLEFT",UIParent,xLeft,0)
            line:SetEndPoint("BOTTOMLEFT",UIParent,xLeft,-screenH)
            linePool[#linePool+1]=line
        end
    end
    for offset=20,math.max(centerX,centerY),20 do
        if offset%100~=0 then
            local yTop=centerY+offset
            local yBottom=centerY-offset
            if yTop<=screenH then
                local line=frame:CreateLine()
                line:SetColorTexture(0.8,0.8,0.8,0.2)
                line:SetThickness(1)
                line:SetStartPoint("TOPLEFT",UIParent,0,-yTop)
                line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yTop)
                linePool[#linePool+1]=line
            end
            if yBottom>=0 then
                local line=frame:CreateLine()
                line:SetColorTexture(0.8,0.8,0.8,0.2)
                line:SetThickness(1)
                line:SetStartPoint("TOPLEFT",UIParent,0,-yBottom)
                line:SetEndPoint("TOPRIGHT",UIParent,screenWidth,-yBottom)
                linePool[#linePool+1]=line
            end
            local xRight=centerX+offset
            local xLeft=centerX-offset
            if xRight<=screenWidth then
                local line=frame:CreateLine()
                line:SetColorTexture(0.8,0.8,0.8,0.2)
                line:SetThickness(1)
                line:SetStartPoint("TOPLEFT",UIParent,xRight,0)
                line:SetEndPoint("BOTTOMLEFT",UIParent,xRight,-screenH)
                linePool[#linePool+1]=line
            end
            if xLeft>=0 then
                local line=frame:CreateLine()
                line:SetColorTexture(0.8,0.8,0.8,0.2)
                line:SetThickness(1)
                line:SetStartPoint("TOPLEFT",UIParent,xLeft,0)
                line:SetEndPoint("BOTTOMLEFT",UIParent,xLeft,-screenH)
                linePool[#linePool+1]=line
            end
        end
    end
end
function F:SetupSliderText(slider,lowText,highText)
    slider.Low:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    slider.Low:SetText(lowText)
    slider.High:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    slider.High:SetText(highText)
    slider.Low:ClearAllPoints()
    slider.Low:SetPoint("TOPLEFT",slider,"BOTTOMLEFT",0,-2)
    slider.High:ClearAllPoints()
    slider.High:SetPoint("TOPRIGHT",slider,"BOTTOMRIGHT",0,-2)
end
function F:SetupSliderThump(slider,size,r,g,b)
    local thumb=slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(size,size)
        thumb:SetColorTexture(r,g,b)
    end
end
function F:CreateSlider(parent,label,_,l,h,s,point,rel,x,y,callback)
    local slider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    slider.l=slider:CreateFontString(nil,"OVERLAY")
    slider.l:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    slider.l:SetPoint(point,parent,rel,x,y)
    slider.l:SetText(label)
    slider:SetPoint("TOPLEFT",slider.l,"BOTTOMLEFT")
    slider:SetWidth(100)
    slider:SetMinMaxValues(tonumber(l),tonumber(h))
    slider:SetValueStep(s)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText(tostring(l))
    slider.High:SetText(tostring(h))
    slider:SetScript("OnValueChanged",function(self,value)
        if callback then callback(self,value) end
    end)
    slider.bg=slider:CreateTexture(nil,"BACKGROUND")
    slider.bg:SetPoint("CENTER")
    slider.bg:SetSize(100,10)
    slider.bg:SetColorTexture(0.2,0.2,0.2,0.8)
    slider.bg:SetDrawLayer("BACKGROUND",-1)
    slider.v=slider:CreateFontString(nil,"OVERLAY")
    slider.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    slider.v:SetPoint("TOP",slider,"BOTTOM",0,-4)
    F:SetupSliderThump(slider,10,0.8,0.6,0)
    F:SetupSliderText(slider,tostring(l),tostring(h))
    return slider
end
local position={{"TOPLEFT","TOP","TOPRIGHT"},{"LEFT","CENTER","RIGHT"},{"BOTTOMLEFT","BOTTOM","BOTTOMRIGHT"}}
local function GetShortName(pos)
    if pos=="CENTER" then return "C" end
    local first=pos:match("TOP") or pos:match("BOTTOM") or ""
    local second=pos:match("LEFT") or pos:match("RIGHT") or ""
    if first~="" and second~="" then
        return first:sub(1,1)..second:sub(1,1)
    else
        return pos:sub(1,1)
    end
end
function F:SetupClassDispel(b)
    if not b then return end
    if not b.dispel then
        local frame=CreateFrame("Frame",nil,UIParent)
        frame:SetFrameStrata("HIGH")
        frame:SetPoint("CENTER",b,"CENTER",0,10)
        frame:SetSize(10,10)
        local dispel=frame:CreateTexture(nil,"OVERLAY",nil,7)
        dispel:Hide()
        dispel:SetSize(14,14)
        dispel:SetPoint("TOPRIGHT",b.healthBar,"TOPRIGHT",-2,-2)
        local border=frame:CreateTexture(nil,"BORDER")
        border:Hide()
        border:SetColorTexture(1,0,0,1)
        border:SetPoint("TOPLEFT",dispel,"TOPLEFT",-1,1)
        border:SetPoint("BOTTOMRIGHT",dispel,"BOTTOMRIGHT",1,-1)
        b.dispel=dispel
        b.dispelBorder=border
        b.classDispel=false
        return b
    end
end
function F:SetupBlinkIcon(b)
    if not b then return end
    if not b.blink then
        local frame=CreateFrame("Frame",nil,UIParent)
        frame:SetFrameStrata("HIGH")
        frame:SetPoint("CENTER",b,"CENTER",0,10)
        frame:SetSize(10,10)
        local icon=frame:CreateTexture(nil,"OVERLAY",nil,7)
        icon:SetAllPoints()
        icon:SetTexCoord(0.07,0.93,0.07,0.93)
        b.blink=frame
        b.blinkIcon=icon
        return b
    end
end
function F:GetTexture(button,data)
    local frame=CreateFrame("Frame",nil,button)
    frame:SetFrameStrata("HIGH")
    local tex=frame:CreateTexture(nil,"OVERLAY",nil,7)
    tex:SetColorTexture(data[2],data[3],data[4],data[5])
    tex:SetSize(data[9],data[9])
    tex:SetPoint(data[6],button.healthBar,data[6],data[7],data[8])
    local cooldown=CreateFrame("Cooldown",nil,frame,"CooldownFrameTemplate")
    cooldown:SetBlingTexture("Interface\\Cooldown\\star4_edge",1,1,1,1)
    cooldown:SetAllPoints(tex)
    cooldown:SetReverse(true)
    cooldown:SetHideCountdownNumbers(true)
    local count=frame:CreateFontString(nil,"OVERLAY")
    count:SetFontObject(C.EtherFont)
    count:SetPoint("LEFT",tex)
    count:Hide()
    local stacks=frame:CreateFontString(nil,"OVERLAY")
    stacks:SetFontObject(C.EtherFont)
    stacks:SetPoint("LEFT",tex)
    stacks:Hide()
    local durationText=frame:CreateFontString(nil,"OVERLAY")
    durationText:SetFontObject(C.EtherFont)
    durationText:SetPoint("CENTER",frame)
    durationText:Hide()
    frame.icon=tex
    frame.cooldown=cooldown
    frame.count=count
    frame.stacks=stacks
    frame.durationText=durationText
    return frame
end
function F:CreatePreview(parent,point)
    local preview=CreateFrame("StatusBar",nil,parent)
    preview:SetSize(55,55)
    preview:SetPoint(point)
    preview:SetOrientation("HORIZONTAL")
    preview:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    local name=preview:CreateFontString(nil,"OVERLAY",nil,7)
    name:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",11,"OUTLINE")
    name:SetPoint("CENTER",preview,"CENTER",0,-5)
    name:SetText([[|cffffd700ME|r]])
    local icon=preview:CreateTexture(nil,"OVERLAY",nil,7)
    preview.icon=icon
    icon:SetPoint("TOP",preview,"TOP")
    local data={}
    for i=1,3 do
        for j=1,3 do
            local pos=position[i][j]
            local text=GetShortName(pos)
            local btn=CreateFrame("Button",nil,preview)
            data[pos]=btn
            btn:SetSize(18.3,18.3)
            btn:SetPoint("TOPRIGHT",preview,"TOPLEFT",(j-1)*18.3-39,-(i-1)*18.3+1)
            btn.bg=btn:CreateTexture(nil,"BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.8)
            btn.text=btn:CreateFontString(nil,"OVERLAY")
            btn.text:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(text)
            btn.position=pos
        end
    end
    return data,preview
end
local function CreatePopupBox()
    if C.PopupBox then return end
    local f=CreateFrame("Frame",nil,UIParent)
    C.PopupBox=f
    f:Hide()
    f:SetSize(320,200)
    f:SetFrameLevel(600)
    f:SetPoint("CENTER")
    local bg=f:CreateTexture(nil,"BACKGROUND")
    f.bg=bg
    bg:SetAllPoints()
    bg:SetTexture("Interface\\AddOns\\Ether\\Media\\emblem.png")
    bg:SetAlpha(0.7)
    local font=f:CreateFontString(nil,"OVERLAY")
    f.font=font
    font:SetFontObject(C.EtherFont)
    font:SetPoint("TOP",0,-20)
    font:SetIndentedWordWrap(true)
    local left=CreateFrame("Button",nil,f)
    left:SetPoint("BOTTOMLEFT",0,5)
    left:SetSize(50,20)
    left.font=left:CreateFontString(nil,"OVERLAY")
    left.font:SetFontObject(C.EtherFont)
    left.font:SetPoint("CENTER")
    left.font:SetText("Yes")
    left:SetScript("OnEnter",function()
        left.font:SetTextColor(0.00,0.80,1.00,1)
    end)
    left:SetScript("OnLeave",function()
        left.font:SetTextColor(1,1,1,1)
    end)
    local right=CreateFrame("Button",nil,f)
    right:SetPoint("BOTTOMRIGHT",0,5)
    right:SetSize(50,20)
    right.font=right:CreateFontString(nil,"OVERLAY")
    right.font:SetFontObject(C.EtherFont)
    right.font:SetText("No")
    right.font:SetPoint("CENTER")
    right:SetScript("OnEnter",function()
        right.font:SetTextColor(0.00,0.80,1.00,1)
    end)
    right:SetScript("OnLeave",function()
        right.font:SetTextColor(1,1,1,1)
    end)
    right:SetScript("OnClick",function()
        C.PopupBox:SetShown(false)
    end)
    C.PopupCallback=left
end
function F:PopupBoxSetup()
    if not C.PopupCallback or not C.PopupBox then
        CreatePopupBox()
    end
    if C.PopupCallback:GetScript("OnClick") then
        C.PopupCallback:SetScript("OnClick",nil)
    end
    C.PopupBox:SetShown(true)
end
function F:LineInput(parent,width,height)
    local input=CreateFrame("EditBox",nil,parent)
    C.InputText=input
    input:SetSize(width,height)
    input:SetAutoFocus(false)
    local bg=input:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1,1,1,0.1)
    local line=input:CreateTexture(nil,"BORDER")
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(1)
    line:SetColorTexture(0.67,0.67,0.67)
    input:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    input:SetTextInsets(4,4,2,2)
    input:SetScript("OnEditFocusGained",function()
        line:SetColorTexture(1,0.84,0)
        line:SetHeight(1)
        bg:SetColorTexture(1,1,1,0.1)
        C:ToggleBorder(1,0.84,0)
    end)
    input:SetScript("OnEditFocusLost",function()
        line:SetColorTexture(0.67,0.67,0.67)
        line:SetHeight(1)
        bg:SetColorTexture(1,1,1,0.1)
        C:ToggleBorder(0.67,0.67,0.67)
        input:ClearFocus()
    end)
    input:SetScript("OnEscapePressed",function()
        input:ClearFocus()
        input:SetText("")
    end)
    if input.Left then input.Left:Hide() end
    if input.Middle then input.Middle:Hide() end
    if input.Right then input.Right:Hide() end
    return input
end