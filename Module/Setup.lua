local _,Ether=...
local tinsert,tremove=table.insert,table.remove
local pairs,ipairs=pairs,ipairs
local GameTooltip=GameTooltip
local unpack,CreateFrame=unpack,CreateFrame
local tostring,tonumber=tostring,tonumber
local UIParent=UIParent

function Ether:CreateToolFrame()
    if Ether.toolFrame then return end
    local frame=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
    Ether.toolFrame=frame
    local DB=Ether.DB[21][2]
    frame:SetFrameStrata("TOOLTIP")
    frame:SetSize(DB[6] or 280,DB[7] or 120)
    frame:SetScale(DB[8] or 1)
    frame:SetScale(DB[9] or 1)
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
    Ether:ApplyFramePosition(15)
    Ether:SetupDrag(15)
end

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
    if not button then return end
    local name=button.healthBar:CreateFontString(nil,"OVERLAY")
    button.name=name
    local size=Ether.DB[100][7] or 12
    local font=Ether.DB[100][4] or unpack(Ether.media.venite)
    local flag=Ether.DB[100][8] or "OUTLINE"
    name:SetFont(font,size,flag)
    name:SetPoint("CENTER",button.healthBar,"CENTER",0,number)
    return button
end

function Ether:SetupButtonLayout(button)
    if not button then
        return
    end
    button.background=button:CreateTexture(nil,"BACKGROUND")
    button.background:SetTexture(Ether.DB[100][6])
    button.background:SetAllPoints(button)
    return button
end

function Ether:SetupBorderLayout(target,Offset)
    local r,g,b,a=0,0,0,1
    target.t=target:CreateTexture(nil,"BORDER")
    target.t:SetPoint("TOPLEFT",target,"TOPLEFT",-Offset,Offset)
    target.t:SetPoint("TOPRIGHT",target,"TOPRIGHT",Offset,Offset)
    target.t:SetHeight(Offset)
    target.t:SetColorTexture(r,g,b,a)
    target.b=target:CreateTexture(nil,"BORDER")
    target.b:SetPoint("BOTTOMLEFT",target.powerBar or target,"BOTTOMLEFT",-Offset,-Offset)
    target.b:SetPoint("BOTTOMRIGHT",target.powerBar or target,"BOTTOMRIGHT",Offset,-Offset)
    target.b:SetHeight(Offset)
    target.b:SetColorTexture(r,g,b,a)
    target.l=target:CreateTexture(nil,"BORDER")
    target.l:SetPoint("TOPLEFT",target,"TOPLEFT",-Offset,Offset)
    target.l:SetPoint("BOTTOMLEFT",target.powerBar or target,"BOTTOMLEFT",-Offset,-Offset)
    target.l:SetWidth(Offset)
    target.l:SetColorTexture(r,g,b,a)
    target.r=target:CreateTexture(nil,"BORDER")
    target.r:SetPoint("TOPRIGHT",target,"TOPRIGHT",Offset,Offset)
    target.r:SetPoint("BOTTOMRIGHT",target.powerBar or target,"BOTTOMRIGHT",Offset,-Offset)
    target.r:SetWidth(Offset)
    target.r:SetColorTexture(r,g,b,a)
end

function Ether:CreateMainFrame(self)
    if not self.Created then
        self.Frames["MAIN"]=CreateFrame("Frame","EtherUnitFrameAddon",UIParent,"BackdropTemplate")
        self.Frames["MAIN"]:SetFrameLevel(500)
        self.Frames["MAIN"]:SetSize(640,480)
        self.Frames["MAIN"]:SetBackdrop({
            bgFile="Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
            tile=true,
            tileSize=16,
            edgeSize=16,
            insets={left=4,right=4,top=4,bottom=4}
        })
        self.Frames["MAIN"]:SetBackdropColor(0.1,0.1,0.1,1)
        self.Frames["MAIN"]:SetBackdropBorderColor(0,0.8,1,.7)
        self.Frames["MAIN"]:Hide()
        tinsert(UISpecialFrames,self.Frames["MAIN"]:GetName())
        for _,value in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
            self.Frames[value]=CreateFrame("Frame",nil,self.Frames["MAIN"])
        end
        self.Frames["MAIN"]:SetScript("OnHide",function()
            if Ether.DB[100][3] then Ether.DB[100][3]=false end
            Ether.ToggleUnlock(false)
        end)
        self.Frames["TOP"]:SetPoint("TOPLEFT",10,-15)
        self.Frames["TOP"]:SetPoint("TOPRIGHT",-10,0)
        self.Frames["TOP"]:SetSize(0,30)
        self.Frames["BOTTOM"]:SetPoint("BOTTOMLEFT",10,10)
        self.Frames["BOTTOM"]:SetPoint("BOTTOMRIGHT",-10,0)
        self.Frames["BOTTOM"]:SetSize(0,30)
        self.Frames["LEFT"]:SetPoint("TOPLEFT",self.Frames["TOP"],"BOTTOMLEFT")
        self.Frames["LEFT"]:SetPoint("BOTTOMLEFT",self.Frames["BOTTOM"],"TOPLEFT")
        self.Frames["LEFT"]:SetSize(100,0)
        self.Frames["RIGHT"]:SetPoint("TOPRIGHT",self.Frames["BOTTOM"],"TOPRIGHT")
        self.Frames["RIGHT"]:SetPoint("BOTTOMRIGHT",self.Frames["BOTTOM"],"TOPRIGHT")
        self.Frames["RIGHT"]:SetSize(10,0)
        self.Frames["CONTENT"]=CreateFrame("Frame",nil,self.Frames["TOP"])
        self.Frames["CONTENT"]:SetPoint("TOP",self.Frames["TOP"],"BOTTOM")
        self.Frames["CONTENT"]:SetPoint("BOTTOM",self.Frames["BOTTOM"],"TOP")
        self.Frames["CONTENT"]:SetPoint("LEFT",self.Frames["LEFT"],"RIGHT")
        self.Frames["CONTENT"]:SetPoint("RIGHT",self.Frames["RIGHT"],"LEFT")
        for index,value in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
            self.Borders[value]=self.Frames["CONTENT"]:CreateTexture(nil,"BORDER")
            self.Borders[value]:SetColorTexture(0.80,0.40,1.00,1)
            if index==1 or index==2 then
                self.Borders[value]:SetHeight(1)
            else
                self.Borders[value]:SetWidth(1)
            end
        end
        self.Borders["TOP"]:SetPoint("TOPLEFT",-1,1)
        self.Borders["TOP"]:SetPoint("TOPRIGHT",1,1)
        self.Borders["BOTTOM"]:SetPoint("BOTTOMLEFT",-1,-1)
        self.Borders["BOTTOM"]:SetPoint("BOTTOMRIGHT",1,-1)
        self.Borders["LEFT"]:SetPoint("TOPLEFT",-1,1)
        self.Borders["LEFT"]:SetPoint("BOTTOMLEFT",-1,-1)
        self.Borders["RIGHT"]:SetPoint("TOPRIGHT",1,1)
        self.Borders["RIGHT"]:SetPoint("BOTTOMRIGHT",1,-1)
        for _,info in ipairs({"INDICATORS","AURAS","EDITOR"}) do
            self.Frames[info]=CreateFrame("Frame",nil,self.Frames["MAIN"])
        end
        local version=self.Frames["BOTTOM"]:CreateFontString(nil,"OVERLAY")
        version:SetFont(unpack(Ether.media.expressway),15,"OUTLINE")
        version:SetPoint("BOTTOMRIGHT",-10,3)
        version:SetText("Beta |cE600CCFF"..tostring(Ether.metaData[3]).."|r")
        local menuIcon=self.Frames["BOTTOM"]:CreateTexture(nil,"ARTWORK")
        menuIcon:SetSize(32,32)
        menuIcon:SetTexture(unpack(Ether.media.icon))
        menuIcon:SetPoint("BOTTOMLEFT",0,5)
        local name=self.Frames["BOTTOM"]:CreateFontString(nil,"OVERLAY")
        name:SetFont(unpack(Ether.media.expressway),20,"OUTLINE")
        name:SetPoint("BOTTOMLEFT",menuIcon,"BOTTOMRIGHT",7,0)
        name:SetText("|cffcc66ffEther|r")
        local close=CreateFrame("Button",nil,self.Frames["BOTTOM"])
        close:SetSize(100,15)
        close:SetPoint("BOTTOM",0,3)
        close.text=close:CreateFontString(nil,"OVERLAY")
        close.text:SetFont(unpack(Ether.media.expressway),15,"OUTLINE")
        close.text:SetAllPoints()
        close.text:SetText("Close")
        close:SetScript("OnEnter",function()
            close.text:SetTextColor(0.00,0.80,1.00,1)
        end)
        close:SetScript("OnLeave",function()
            close.text:SetTextColor(1,1,1,1)
        end)
        close:SetScript("OnClick",function()
            self.Frames["MAIN"]:Hide()
            Ether.DB[100][3]=false
            Ether.ShowHideSettings(false)
            ETHER_DATABASE_DX_AA["PROFILES"][Ether:GetProfileName()]=Ether:CopyTable(Ether.DB)
        end)
        Ether.InitializeLayerLevel(self)
        Ether:CreateIndicatorsSection(self)
        Ether:CreateAuraSection(self)
        Ether:CreateConfigSection(self)
        Ether:ApplyFramePosition(17)
        Ether:SetupDrag(17)
    end
end

function Ether:CreateSettingsButtons(name,parent,layer,onClick,isTopButton)
    local btn=CreateFrame("Button",nil,parent)
    if isTopButton then
        btn:SetHeight(20)
        btn:SetWidth(100)
    else
        btn:SetHeight(25)
        btn:SetWidth(100)
    end
    btn.font=btn:CreateFontString(nil,"OVERLAY")
    btn.font:SetFont(unpack(Ether.media.expressway),15,"OUTLINE")
    btn.font:SetText(name)
    btn.font:SetAllPoints()
    btn:SetScript("OnEnter",function(self)
        self.font:SetTextColor(0.00,0.80,1.00,1)
    end)
    btn:SetScript("OnLeave",function(self)
        self.font:SetTextColor(1,1,1,1)
    end)
    btn:SetScript("OnClick",function()
        return onClick(name,layer)
    end)
    return btn
end

function Ether:SetupHealthBar(button,orient)
    if not button then return end
    local healthBar=CreateFrame("StatusBar",nil,button)
    button.healthBar=healthBar
    healthBar:SetAllPoints(button)
    healthBar:SetOrientation(orient)
    local bar=Ether.DB[100][5] or unpack(Ether.media.elvUIBar)
    healthBar:SetStatusBarTexture(bar)
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(button:GetFrameLevel()+3)
    local healthDrop=button:CreateTexture(nil,"OVERLAY")
    button.healthDrop=healthDrop
    healthDrop:SetAllPoints(healthBar)
    healthDrop:SetTexture(bar)
    return button
end

function Ether:CleanUpButtons(editor,indicator)
    indicator:Hide()
    editor:Hide()
    indicator.dropdown.text:SetText("Select Indicator")
    for _,btn in pairs(editor.cube) do
        btn:Disable()
    end
    for _,btn in pairs(indicator.cube) do
        btn:Disable()
    end
end

function Ether:SetupPowerBar(button)
    if not button or not button.healthBar then return end
    local powerBar=CreateFrame("StatusBar",nil,button)
    button.powerBar=powerBar
    powerBar:SetPoint("TOPLEFT",button,"BOTTOMLEFT")
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

function Ether:SetupSlash()
    SLASH_ETHER1="/ether"
    SlashCmdList["ETHER"]=function(msg)
        local input,rest=msg:match("^(%S*)%s*(.-)$")
        input=string.lower(input or "")
        rest=string.lower(rest or "")
        if input=="settings" then
            Ether:SettingsToggleSlash()
        elseif input=="rl" then
            if not InCombatLockdown() then
                ReloadUI()
            end
        elseif input=="msg" then
            if Ether.EtherFrameSetClick then
                Ether:EtherFrameSetClick(1,2)
            end
        else
            for _,entry in ipairs(Ether.media.slash) do
                Ether:EtherInfo(string.format("%s  –  %s",entry.cmd,entry.desc))
            end
            Ether:SoloAuraReset()
        end
    end
end
function Ether:SettingsToggleSlash()
    if InCombatLockdown() then return end
    if Ether.EtherToggle then
        Ether.DB[100][3]=not Ether.DB[100][3]
        Ether.EtherToggle(Ether.DB[100][3])
    end
end

function Ether:SetupPrediction(button)
    if not button or not button.healthBar then
        return
    end
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
    button.prediction=from
    from:SetAllPoints(button.healthBar)
    from:SetStatusBarTexture(unpack(Ether.media.blankBar))
    from:SetStatusBarColor(1.00,0.65,0.00,.5)
    from:SetMinMaxValues(0,1)
    from:SetValue(1)
    from:Hide()
    from:SetFrameLevel(button:GetFrameLevel()+1)
    return button
end

function Ether:SetupCastBar(button,number)
    if not button or not number then return end
    local pos=Ether.DB[21][number]
    local frame=CreateFrame("StatusBar",nil,UIParent)
    frame:SetWidth(pos[6] or 300)
    frame:SetHeight(pos[7] or 15)
    frame:SetScale(pos[8] or 1)
    frame:SetAlpha(pos[9] or 1)
    button.castBar=frame
    frame:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    local drop=frame:CreateTexture(nil,"OVERLAY")
    frame.drop=drop
    drop:SetAllPoints()
    local r,g,b=Ether:GetClassColor("player")
    frame:SetStatusBarColor(r,g,b,1)
    drop:SetColorTexture(0.2,0.2,0.4,.5)
    local text=frame:CreateFontString(nil,"OVERLAY")
    frame.text=text
    text:SetFont(Ether.DB[100][4] or unpack(Ether.media.expressway),12,"OUTLINE")
    text:SetPoint("LEFT",31,0)
    local time=frame:CreateFontString(nil,"OVERLAY")
    frame.time=time
    time:SetFont(Ether.DB[100][4] or unpack(Ether.media.expressway),12,"OUTLINE")
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
    frame:SetPoint(pos[1] or "CENTER",UIParent,pos[3] or "CENTER",pos[4] or 0,pos[5] or 0)
    Ether:SetupDrag(number)
    frame:Hide()
end

function Ether:CreateSlider(parent,label,text,l,h,s,point,rel,x,y,callback)
    local slider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    slider.l=slider:CreateFontString(nil,"OVERLAY")
    slider.l:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
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
    slider.v:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    slider.v:SetPoint("TOP",slider,"BOTTOM",0,-5)
    slider.v:SetText(text)
    return slider
end

local position={
    {"TOPLEFT","TOP","TOPRIGHT"},
    {"LEFT","CENTER","RIGHT"},
    {"BOTTOMLEFT","BOTTOM","BOTTOMRIGHT"}
}

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

function Ether:CreateCube(parent,s,x,y,click,enter,leave)
    local data={}
    for row=1,3 do
        for col=1,3 do
            local pos=position[row][col]
            local text=GetShortName(pos)
            local btn=CreateFrame("Button",nil,parent)
            data[pos]=btn
            btn:SetSize(s,s)
            btn:SetPoint("TOPLEFT",x+(col-1)*(s+1),y-(row-1)*(s+1))
            btn.bg=btn:CreateTexture(nil,"BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.8)
            btn.text=btn:CreateFontString(nil,"OVERLAY")
            btn.text:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(text)
            btn.position=pos
            btn:SetScript("OnClick",click)
            btn:SetScript("OnEnter",enter)
            btn:SetScript("OnLeave",leave)
        end
    end
    return data
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
    if not Ether.DB or not Ether.DB[21] or not Ether.DB[21][index] then
        return
    end
    local DB=Ether.DB[21][index]
    DB[1]=point
    DB[2]=relToName
    DB[3]=relPoint
    DB[4]=math.floor(snapX)
    DB[5]=math.floor(snapY)
    local anchorRelTo=_G[relToName] or UIParent
    self:ClearAllPoints()
    self:SetPoint(point,anchorRelTo,relPoint,DB[4],DB[5])
end

function Ether:SetupDrag(index)
    if not index or type(index)~="number" then return end
    local frame=Ether.ReturnFrame(index)
    if frame then
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        frame:SetScript("OnDragStart",onStart)
        frame:SetScript("OnDragStop",function(self)
            onStop(self,index,10)
        end)
    end
end

function Ether:SetupInfoFrame()
    if Ether.infoFrame then return end
    local frame=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
    Ether.infoFrame=frame
    local DB=Ether.DB[21][1]
    frame:SetPoint("CENTER")
    frame:SetSize(DB[6] or 320,DB[7] or 200)
    frame:SetScale(DB[8] or 1)
    frame:SetScale(DB[9] or 1)
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
    Ether:ApplyFramePosition(14)
    Ether:SetupDrag(14)
    return frame
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

local function SetupAuraStacks(button)
    local stack=button:CreateFontString(nil,"OVERLAY")
    stack:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    stack:SetPoint("LEFT")
    stack:Hide()
    return stack
end
local function SetupAuraBorder(button)
    local border=button:CreateTexture(nil,"BORDER")
    border:SetColorTexture(1,0,0,1)
    border:SetPoint("TOPLEFT",-1,1)
    border:SetPoint("BOTTOMRIGHT",1,-1)
    border:Hide()
    return border
end

local function Aura_OnEnter(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetUnitAura(self.unit,self.id,self.filter)
    GameTooltip:Show()
end
local function Aura_OnLeave()
    GameTooltip:Hide()
end

function Ether:SoloAuraSetup(button)
    if not button then return end
    if not button.Aura then
        button.Aura={
            Buffs={},
            Debuffs={},
            LastBuffs={},
            LastDebuffs={}
        }
    end
    local unit=button.unit
    for id=1,16 do
        if not button.Aura.Buffs[id] then
            local aura=CreateFrame("Frame",nil,button)
            aura.unit=unit
            aura.filter="HELPFUL"
            aura:SetSize(13,13)
            aura.icon=SetupAuraIcon(aura)
            aura.count=SetupAuraCount(aura)
            aura.timer=SetupAuraTimer(aura,aura.icon)
            aura.stacks=SetupAuraStacks(aura)
            aura.id=id
            aura:SetScript("OnEnter",Aura_OnEnter)
            aura:SetScript("OnLeave",Aura_OnLeave)
            button.Aura.Buffs[id]=aura
        end
    end
    for id=1,16 do
        if not button.Aura.Debuffs[id] then
            local aura=CreateFrame("Frame",nil,button)
            aura.unit=unit
            aura.filter="HARMFUL"
            aura:SetSize(13,13)
            aura.icon=SetupAuraIcon(aura)
            aura.count=SetupAuraCount(aura)
            aura.timer=SetupAuraTimer(aura,aura.icon)
            aura.stacks=SetupAuraStacks(aura)
            aura.border=SetupAuraBorder(aura)
            aura.id=id
            aura:SetScript("OnEnter",Aura_OnEnter)
            aura:SetScript("OnLeave",Aura_OnLeave)
            button.Aura.Debuffs[id]=aura
        end
    end
end

function Ether:DispelIconSetup(button)
    if not button then return end
    if not button.dispelFrame then
        local frame=CreateFrame("Frame",nil,UIParent)
        frame:SetFrameLevel(button:GetFrameLevel()+6)
        frame:SetPoint("CENTER",button,"CENTER",0,8)
        frame:SetSize(12,12)
        local icon=frame:CreateTexture(nil,"OVERLAY")
        icon:SetAllPoints()
        icon:SetTexCoord(0.07,0.93,0.07,0.93)
        local border=frame:CreateTexture(nil,"BORDER")
        border:SetColorTexture(1,1,1,0)
        border:SetPoint("TOPLEFT",frame,"TOPLEFT",-1,1)
        border:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",1,-1)
        button.dispelFrame=frame
        button.dispelIcon=icon
        button.dispelBorder=border
        return button
    end
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
    frame.bg:SetTexture(unpack(Ether.media.emblem))
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

local TextureMethod,SetupDispelAuraButton
do
    local frame=CreateFrame("Frame",nil,UIParent)
    frame:SetFrameStrata("HIGH")
    TextureMethod=function()
        local method=frame:CreateTexture(nil,"OVERLAY",nil,7)
        method.Setup=function(self,CFG,button)
            self:SetColorTexture(unpack(CFG[2]))
            self:SetSize(CFG[3],CFG[3])
            self:SetPoint(CFG[4],button.healthBar,CFG[4],CFG[5],CFG[6])
            self:Show()
        end
        method.Reset=function(self)
            self:Hide()
            self:ClearAllPoints()
        end
        return method
    end
    function SetupDispelAuraButton(button)
        if not button or not button.Dispel then return end
        if not button.Dispel.indicator then
            local indicator=frame:CreateTexture(nil,"OVERLAY",nil,7)
            indicator:Hide()
            indicator:SetSize(14,14)
            indicator:SetPoint("TOPRIGHT",button.healthBar,"TOPRIGHT",-2,-2)
            local border=frame:CreateTexture(nil,"BORDER")
            border:Hide()
            border:SetColorTexture(1,0,0,1)
            border:SetPoint("TOPLEFT",indicator,"TOPLEFT",-1,1)
            border:SetPoint("BOTTOMRIGHT",indicator,"BOTTOMRIGHT",1,-1)
            button.Dispel.indicator=indicator
            button.Dispel.border=border
        end
    end
    Ether.SetupDispelAuraButton=SetupDispelAuraButton
    Ether.TextureMethod=TextureMethod
end
---@class ObjPool
---@field active table
---@field inactive table
---@field activeCount number
local ObjPool={}

---@return ObjPool
function Ether:CreateObjPool(creatorFunc)
    local obj={
        create=creatorFunc,
        active={},
        inactive={},
        temp={},
        activeCount=0,
    }
    setmetatable(obj,{__index=ObjPool})
    return obj
end

---@return any
function ObjPool:Acquire(...)
    if self.activeCount>=310 then
        Ether.TexPool:ReleaseAll()
        return
    end
    local obj=tremove(self.inactive)
    if not obj then
        obj=self.create()
    end
    self.activeCount=self.activeCount+1
    self.active[obj]=true
    if obj.Setup then
        obj:Setup(...)
    end
    return obj
end

function ObjPool:Release(obj)
    if not obj or not self.active[obj] then
        return
    end
    self.active[obj]=nil
    self.activeCount=self.activeCount-1
    if obj.Reset then
        obj:Reset()
    end
    if #self.inactive<150 then
        self.inactive[#self.inactive+1]=obj
    end
end

function ObjPool:ReleaseAll()
    for obj in pairs(self.active) do
        self.temp[#self.temp+1]=obj
    end
    for i=1,#self.temp do
        self:Release(self.temp[i])
    end
    for i=1,#self.temp do
        self.temp[i]=nil
    end
end

function Ether:SpellInfo(info,result,icon)
    if not info or not result or not icon then return end
    info=info:trim()
    if info=="" then
        result:SetText("Enter spell name")
        result:SetTextColor(1,1,1)
        icon:Hide()
        return
    end
    local spellID=C_Spell.GetSpellIDForSpellIdentifier(info)
    if not spellID then
        local baseName=info:gsub("%s*%(%s*[Rr]ank%s+%d+%s*%)",""):trim()
        if baseName~=info then
            spellID=C_Spell.GetSpellIDForSpellIdentifier(baseName)
        end
    end
    if not spellID then
        result:SetText("Not found: "..info)
        result:SetTextColor(1,0,0)
        icon:Hide()
        return
    end
    local name=C_Spell.GetSpellName(spellID)
    local subtext=C_Spell.GetSpellSubtext(spellID) or ""
    local iconID=C_Spell.GetSpellTexture(spellID)
    local levelLearned=C_Spell.GetSpellLevelLearned(spellID)
    local spellRank=0
    if subtext:match("Rank") then
        spellRank=tonumber(subtext:match("Rank%s+(%d+)")) or 0
    end
    if iconID then
        icon:SetTexture(iconID)
        icon:Show()
    else
        icon:Hide()
    end
    local resultStr=string.format("Spell Name: %s\nSpellID: %d",name,spellID)
    if subtext~="" then
        resultStr=resultStr..string.format("\n%s",subtext)
    end
    if levelLearned>0 then
        resultStr=resultStr..string.format("\nLearned at: Level %d",levelLearned)
    end
    result:SetText(resultStr)
    result:SetTextColor(1,1,1)
    Ether:EtherInfo(resultStr)
    icon:SetScript("OnEnter",function()
        GameTooltip:SetOwner(icon,"ANCHOR_RIGHT")
        GameTooltip:AddLine(name,1,1,1)
        GameTooltip:AddLine("Spell ID: "..spellID,0.5,1,0.5)
        if subtext~="" then
            GameTooltip:AddLine(subtext,1,0.82,0)
        end
        local level=C_Spell.GetSpellLevelLearned(spellID)
        if level>0 then
            GameTooltip:AddLine("Learned at level "..level,0.7,0.7,1)
        end
        local desc=C_Spell.GetSpellDescription(spellID)
        if desc and desc~="" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(desc:sub(1,200),0.8,0.8,0.8,true)
        end
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)
end

function Ether:IgnoringHandler(result,name)
    if not name or type(name)~="string" then return end
    name=name:trim()
    if name=="" then
        return
    elseif Ether.DB["USER"][name] then
        result:SetText("Name already ignored")
        result:SetTextColor(1,0,0)
        return
    else
        Ether.DB["USER"][name]=true
    end
end
function Ether.ValidMessage(sender)
    local DB=Ether.DB["USER"]
    if DB[sender] then
        return true
    end
    return false
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



local HealthColors = {
    {0.0, 'ff0000'},
    {0.3, 'ff4500'},
    {0.5, 'ffa500'},
    {0.7, 'ffd700'},
    {0.9, 'adff2f'},
    {1.0, '00ff00'},
}
local HealthGradient = Ether:BuildGradientTable(HealthColors)
local lastHealth = {}

function Ether:UpdateHealthTextRounded(button)
    if not button or not button.unit or not button.health then return end

    local unit = button.unit
    local h, maxH = UnitHealth(unit), UnitHealthMax(unit)
    local pct = maxH > 0 and h / maxH or 0
    local roundedPct = math_floor(pct * 100 + 0.5)

    if lastHealth[unit] == roundedPct then
        return
    end
    lastHealth[unit] = roundedPct

    local colorCode = HealthGradient[roundedPct]
    button.health:SetText(string_format(f2m, colorCode, roundedPct))
end
]]