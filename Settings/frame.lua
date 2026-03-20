local _,Ether=...
local string_format=string.format
local pairs,ipairs=pairs,ipairs
local tinsert=table.insert
local eColor="|cffcc66ffEther|r "
local function CreateHeaderPreview(parent,name,numb,size)
    local preview=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    preview:SetSize(size,size)
    preview:SetBackdrop({
        bgFile=Ether.DB[100][5] or unpack(Ether.media.elvUIBar),
        insets={left=-1,right=-1,top=-1,bottom=-1}
    })
    local healthBar=CreateFrame("StatusBar",nil,preview)
    preview.healthBar=healthBar
    healthBar:SetAllPoints()
    healthBar:SetOrientation("HORIZONTAL")
    local bar=Ether.DB[100][5] or unpack(Ether.media.elvUIBar)
    healthBar:SetStatusBarTexture(bar)
    healthBar:SetMinMaxValues(0,100)
    healthBar:SetFrameLevel(preview:GetFrameLevel()+3)
    local healthDrop=preview:CreateTexture(nil,"OVERLAY")
    preview.healthDrop=healthDrop
    healthDrop:SetAllPoints(healthBar)
    healthDrop:SetTexture(unpack(Ether.media.elvUIBar))
    Ether:SetupName(preview,0)
    preview.name:SetText(Ether:ShortenName(name,numb))
    preview.tex=preview.healthBar:CreateTexture(nil,"OVERLAY")
    preview.tex:SetSize(12,12)
    preview.tex:SetPoint("TOP",preview.healthBar,"TOP",0,0)
    return preview
end
local function popupBox()
    local box=Ether.popupBox
    local callback=Ether.popupCallback
    if not box then return end
    if callback:GetScript("OnClick") then
        callback:SetScript("OnClick",nil)
    end
    if not box:IsShown() then
        box:SetShown(true)
        Ether.UIPanel.Frames["MAIN"]:SetShown(false)
    end
end
local function SetupSliderText(slider,lowText,highText)
    slider.Low:SetFont(unpack(Ether.media.expressway),9,"OUTLINE")
    slider.Low:SetText(lowText)
    slider.High:SetFont(unpack(Ether.media.expressway),9,"OUTLINE")
    slider.High:SetText(highText)
    slider.Low:ClearAllPoints()
    slider.Low:SetPoint("TOPLEFT",slider,"BOTTOMLEFT",0,-2)
    slider.High:ClearAllPoints()
    slider.High:SetPoint("TOPRIGHT",slider,"BOTTOMRIGHT",0,-2)
end

local function SetupSliderThump(slider,size,color)
    local thumb=slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(size,size)
        thumb:SetColorTexture(unpack(color))
    end
end

local function CreateLineInput(parent,width,height)
    local input=CreateFrame("EditBox",nil,parent)
    input:SetSize(width,height)
    input:SetAutoFocus(false)

    local bg=input:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1,1,1,0.1)

    local line=input:CreateTexture(nil,"BORDER")
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(1)
    line:SetColorTexture(0.80,0.40,1.00,1)
    input:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    input:SetTextInsets(4,4,2,2)
    input:SetScript("OnEditFocusGained",function()
        line:SetColorTexture(0,0.8,1,1)
        line:SetHeight(1)
        bg:SetColorTexture(1,1,1,0.1)
    end)
    input:SetScript("OnEditFocusLost",function()
        line:SetColorTexture(0.80,0.40,1.00,1)
        line:SetHeight(1)
        bg:SetColorTexture(1,1,1,0.1)
    end)
    input:SetScript("OnEscapePressed",function()
        input:ClearFocus()
    end)
    return input
end

local function EtherPanelButton(parent,width,height,text,point,relTo,rel,offX,offY)
    local btn=CreateFrame("Button",nil,parent)
    btn:SetSize(width,height)
    btn:SetPoint(point,relTo,rel,offX,offY)
    btn.text=btn:CreateFontString(nil,"OVERLAY")
    btn.text:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)
    btn.bg=btn:CreateTexture(nil,"BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0,0,0,0)
    btn:SetScript("OnEnter",function(self)
        if self.text:GetText()=="Reset" or self.text:GetText()=="Wipe" then
            self.text:SetTextColor(1.00,0.00,0.00,1)
        else
            self.text:SetTextColor(0.00,0.80,1.00,1)
        end
    end)
    btn:SetScript("OnLeave",function(self)
        self.text:SetTextColor(1,1,1,1)
    end)
    return btn
end

function Ether:CreateModuleSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Module"]
    if parent.Created then
        return
    end
    parent.Created=true
    local modules={"Icon","Whisper","Tooltip","Idle","Range","Indicators","Aura","Info","Debug"}
    local mod=CreateFrame("Frame",nil,parent)
    mod:SetSize(200,(#modules*30)+60)
    for i,opt in ipairs(modules) do
        local btn=CreateFrame("CheckButton",nil,mod,"OptionsBaseCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[1][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[1][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[1][i]=checked and 1 or 0
            if i==1 then
                if Ether.DB[1][1]==1 then
                    Ether:ToggleIcon(true)
                else
                    Ether:ToggleIcon(false)
                end
            elseif i==2 then
                Ether:EnableMsgEvents()
            elseif i==5 then
                if Ether.DB[1][5]==1 then
                    Ether:RangeEnable()
                else
                    Ether:RangeDisable()
                end
            elseif i==6 then
                if Ether.DB[1][6]==1 then
                    Ether:IndicatorsEnable()
                else
                    Ether:IndicatorsDisable()
                end
            elseif i==7 then
                if Ether.DB[1][7]==1 then
                    Ether:AuraEnable()
                else
                    Ether:AuraDisable()
                end
            end
        end)
        panel.Buttons[1][i]=btn
    end
end

function Ether:CreateBlizzardSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Blizzard"]
    if parent.Created then return end
    parent.Created=true
    local blizzard={"Hide Player frame","Hide Pet frame","Hide Target frame","Hide Focus frame","Hide CastBar","Hide Party","Hide Raid","Hide Raid Manager","Hide MicroMenu","Hide XP Bar","Hide BagsBar"}
    local bF=CreateFrame("Frame",nil,parent)
    bF:SetSize(200,(#blizzard*30)+60)
    for i,opt in ipairs(blizzard) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[2][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(Ether.DB[2][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[2][i]=checked and 1 or 0
        end)
        panel.Buttons[2][i]=btn
    end
end

function Ether:CreateAboutSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["About"]
    if parent.Created then return end
    parent.Created=true
    local slash=parent:CreateFontString(nil,"OVERLAY")
    slash:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    slash:SetText("Slash Commands")
    slash:SetPoint("TOP",0,-20)
    local lastY=-20
    for _,entry in ipairs(Ether.media.slash) do
        local fs=parent:CreateFontString(nil,"OVERLAY")
        fs:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        fs:SetText(string_format("%s  –  %s",entry.cmd,entry.desc))
        fs:SetPoint("TOP",slash,"BOTTOM",0,lastY)
        lastY=lastY-18
    end
    local idle=parent:CreateFontString(nil,"OVERLAY")
    idle:SetFont(unpack(Ether.media.expressway),15,"OUTLINE")
    idle:SetText("What happens in idle mode?")
    idle:SetPoint("TOP",0,-180)
    local idleInfo=parent:CreateFontString(nil,"OVERLAY")
    idleInfo:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    idleInfo:SetText("When the user is not at the keyboard,\nEther deregisters all events and OnUpdate functions.")
    idleInfo:SetPoint("TOP",0,-220)
    local auras=parent:CreateFontString(nil,"OVERLAY")
    auras:SetFont(unpack(Ether.media.expressway),15,"OUTLINE")
    auras:SetText("How do I create my own auras?")
    auras:SetPoint("TOP",idleInfo,"BOTTOM",0,-30)
    local aurasInfo=parent:CreateFontString(nil,"OVERLAY")
    aurasInfo:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    aurasInfo:SetText("Only via SpellId. Use Aura Helper or other methods.")
    aurasInfo:SetPoint("TOP",auras,"BOTTOM",0,-10)
end

function Ether:CreateCustomSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Custom"]
    if parent.Created then return end
    parent.Created=true
    --[[
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
    ]]
end

local iNumber
iNumber=nil
local iIcon=""
local function OnIndicatorSelect(self,data)
    local iK={
        [1]="Interface\\CharacterFrame\\Disconnect-Icon",
        [2]="Interface\\RaidFrame\\Raid-Icon-Rez",
        [3]="Interface\\FriendsFrame\\StatusIcon-Away",
        [4]="Interface\\Icons\\Spell_Holy_GuardianSpirit",
        [5]="Interface\\TargetingFrame\\UI-RaidTargetingIcons",
        [6]="Interface\\GroupFrame\\UI-Group-LeaderIcon",
        [7]="Interface\\GroupFrame\\UI-Group-MasterLooter",
        [8]="Interface\\GroupFrame\\UI-Group-MainTankIcon",
        [9]="Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
        [10]="Interface\\RaidFrame\\ReadyCheck-Ready",
        [11]="Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
    }
    local Indicator=Ether.UIPanel.Frames["INDICATORS"]
    if data.index and data.value then
        for _,btn in pairs(Indicator.cube) do
            btn:Enable()
        end
        iNumber=data.index
        iIcon=iK[data.index]
        self.text:SetText(data.value)
        Ether:UpdateIndicatorsPos(iNumber,iIcon)
    end
end

function Ether:CreateIndicatorsSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Indicators"]
    if parent.Created then return end
    parent.Created=true
    local iTbl={"Connection","Resurrection","PlayerFlags","UnitFlags","RaidTarget","GroupLeader","MasterLoot","MainTank","GroupRole","ReadyCheck","ClassIcon"}
    local DB=Ether.DB
    local register=CreateFrame("Frame",nil,parent)
    register:SetSize(200,(#iTbl*30)+60)
    for i,opt in ipairs(iTbl) do
        local btn=CreateFrame("CheckButton",nil,register,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-100)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[3][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=parent:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[3][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[3][i]=checked and 1 or 0
            Ether.IndicatorToggle(i)
            Ether:ToggleIndicatorIcon(i)
        end)
        panel.Buttons[3][i]=btn
    end

    local Indicator=panel.Frames["INDICATORS"]

    local indicatorList={}
    for index,name in ipairs(iTbl) do
        tinsert(indicatorList,{text=name,value=name,index=index})
    end
    local dropdown=Ether:CreateEtherDropdown(parent,160,"Select Indicator",indicatorList,false,OnIndicatorSelect)
    Indicator.dropdown=dropdown
    dropdown:SetPoint("TOPLEFT")

    local preview=CreateHeaderPreview(parent,Ether.metaData[2],3,55)
    Indicator.preview=preview
    preview:SetPoint("TOP",80,-90)
    preview.tex:SetTexture(iIcon)
    preview.name:SetPoint("CENTER",0,-5)

    local cube=Ether:CreateCube(preview,24,90,0,function(self)
        if iNumber then
            Ether.DB[20][iNumber][1]=self.position
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end,function(self)
        self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
    end,function(self)
        local data=iNumber and Ether.DB[20][iNumber]
        if data and data[1]==self.position then
            self.bg:SetColorTexture(0.8,0.6,0,0.4)
        else
            self.bg:SetColorTexture(0.2,0.2,0.2,0.8)
        end
    end)

    Indicator.cube=cube
    local confirm=EtherPanelButton(preview,60,25,"Confirm","BOTTOMLEFT",preview,"TOPRIGHT",0,40)
    confirm:SetScript("OnClick",function()
        if iNumber then
            Ether:SavePosition(iNumber)
        end
    end)

    local s=Ether:CreateSlider(preview,"Size","6 px","4","34",1,"TOP","BOTTOM",0,-60,function(self,value)
        if iNumber then
            DB[20][iNumber][4]=value
            self.v:SetText(string.format("%.0f px",value))
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end)
    Indicator.s=s

    local x=Ether:CreateSlider(s,"X-Off","0","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,function(self,value)
        if iNumber then
            Ether.DB[20][iNumber][2]=value
            self.v:SetText(string.format("%.0f",value))
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end)
    Indicator.x=x

    local y=Ether:CreateSlider(x,"Y-Off","0","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,function(self,value)
        if iNumber then
            DB[20][iNumber][3]=value
            self.v:SetText(string.format("%.0f",value))
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end)
    Indicator.y=y

    SetupSliderText(s,"4","34")
    SetupSliderText(y,"-20","20")
    SetupSliderText(x,"-20","20")
    SetupSliderThump(s,10,{0.8,0.6,0,1})
    SetupSliderThump(y,10,{0.8,0.6,0,1})
    SetupSliderThump(x,10,{0.8,0.6,0,1})
end

function Ether:CreateTooltipSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Tooltip"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local tbl={"AFK","DND","PVP","Resting","Realm","Level","Class","Guild","Role","Creature","Race","RaidTarget","Reaction"}
    local mF=CreateFrame("Frame",nil,parent)
    mF:SetSize(200,(#tbl*30)+60)
    for i,opt in ipairs(tbl) do
        local btn=CreateFrame("CheckButton",nil,mF,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[4][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(DB[4][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[4][i]=checked and 1 or 0
        end)
        panel.Buttons[4][i]=btn
    end
end
local Sort={"GROUP","CLASS","ASSIGNEDROLE","LEFT->TOP","TOP->LEFT"}
local function OnHeaderSort(_,data)
    local parent=Ether.UIPanel["CONTENT"]["CHILDREN"]["Header"]
    local DB=Ether.DB
    if data.index<3 then
        DB[100][9]=data.index
        parent.label:SetText("Direction: "..Sort[DB[100][9]])
    elseif data.index>=3 then
        DB[100][10]=data.index
        parent.direction:SetText("Direction: "..Sort[DB[100][10]])
    elseif data.index>=5 then
    end
    Ether.Fire("UPDATE_HEADER",data.index)
end

function Ether:CreateHeaderSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Header"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local headerData={"RaidHeader","PetHeader"}
    local header=CreateFrame("Frame",nil,parent)
    header:SetSize(200,(#headerData*30)+60)
    for i,opt in ipairs(headerData) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[5][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[5][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[5][i]=checked and 1 or 0
        end)
        panel.Buttons[5][i]=btn
    end
    local Config={}
    for index,name in ipairs(Sort) do
        tinsert(Config,{text=name,value=name,index=index})
    end
    local dropdown=Ether:CreateEtherDropdown(parent,130,"Select Method",Config,"NONE",OnHeaderSort)
    dropdown:SetPoint("CENTER")
    local label=parent:CreateFontString(nil,"OVERLAY")
    parent.label=label
    label:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    label:SetText("Sort By: "..Sort[DB[100][9]])
    label:SetPoint("BOTTOMLEFT",dropdown,"TOPLEFT",0,10)
    local direction=parent:CreateFontString(nil,"OVERLAY")
    parent.direction=direction
    direction:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    direction:SetText("Direction: "..Sort[DB[100][10]])
    direction:SetPoint("BOTTOMLEFT",label,"TOPLEFT",0,10)
end

local INDEX
local function OnBarSelect(self,data)
    local buttons=Ether.UIPanel.Buttons
    for _,v in ipairs(buttons[6]) do
        if v then v:Hide() end
    end
    local panel=Ether.UIPanel["CONTENT"]["CHILDREN"]["Layout"]
    local DB=Ether.DB[21]
    self.text:SetText(data.value)
    if self.type=="object" then
        INDEX=data.index
        buttons[6][data.index].label:SetText(data.value)
        buttons[6][data.index]:Show()
        panel.width:SetText(tonumber(DB[data.index][6]))
        panel.height:SetText(tonumber(DB[data.index][7]))
    elseif self.type=="data" then

    end
end

local function unitButtons(data,number,number2)
    if not data or not number or not number2 then return end
    for _,button in pairs(data) do
        if button then
            button:SetSize(number,number2)
        end
    end
end

function Ether:ProcessUserData(index)
    if not index or type(index)~="number" or index>15 then return end
    local DB=Ether.DB[21][index]
    local raidButtons=Ether.raidButtons
    local soloButton=Ether.soloButtons[index]
    --  local customButtons=Ether.customButtons
    if index==15 then
        Ether:ApplyFramePosition(15)
    elseif index==14 then
        Ether:ApplyFramePosition(14)
    elseif index==13 then
        Ether:CastBarReset(2)
    elseif index==12 then
        Ether:CastBarReset(1)
    elseif index==10 then
        unitButtons(raidButtons,DB[6],DB[7])
        Ether.Fire("UPDATE_HEADER",5)
    elseif index==11 then
        unitButtons(raidButtons,DB[6],DB[7])
        Ether.Fire("UPDATE_HEADER",6)
    elseif index>=7 then

    else
        if soloButton then
            soloButton:SetSize(DB[6],DB[7])
        end
    end
end
local layout={"playerButton","targetButton","targettargetButton","petButton","pettargetButton","focusButton","custom1","custom2","custom3","raidButtons","petButtons","PlayerCastBar","TargetCastBar","InfoFrame","Tooltip"}
function Ether:CreateLayoutSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Layout"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB[21]
    local Config={"Size","Scale","Alpha","StatusBar","Background","Font"}
    local object,data={},{}
    for index,name in ipairs(layout) do
        tinsert(object,{text=name,value=name,index=index})
    end
    for index,name in ipairs(Config) do
        tinsert(data,{text=name,value=name,index=index})
    end
    local objectDropdown=Ether:CreateEtherDropdown(parent,200,"Select Frame",object,false,OnBarSelect)
    objectDropdown.type="object"
    local dataDropdown=Ether:CreateEtherDropdown(parent,200,"Select Config",data,true,OnBarSelect)
    dataDropdown.type="data"
    objectDropdown:SetPoint("TOPLEFT")
    dataDropdown:SetPoint("TOPRIGHT")
    local w,h=CreateLineInput(parent,100,25),CreateLineInput(parent,100,25)
    parent.width,parent.height=w,h
    w:SetPoint("TOPLEFT",parent,"TOPLEFT",200,-300)
    w:SetNumeric(true)
    w:SetScript("OnEnterPressed",function(self)
        local width=tonumber(self:GetText())
        DB[INDEX][6]=width
        if INDEX then
            Ether:ProcessUserData(INDEX)
        end
        self:ClearFocus()
    end)
    h:SetPoint("LEFT",w,"RIGHT",20,0)
    h:SetNumeric(true)
    h:SetScript("OnEnterPressed",function(self)
        local height=tonumber(self:GetText())
        DB[INDEX][7]=height
        if INDEX then
            Ether:ProcessUserData(INDEX)
        end
        self:ClearFocus()
    end)
    w.label=parent:CreateFontString(nil,"OVERLAY")
    w.label:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    w.label:SetText("Width:")
    w.label:SetPoint("BOTTOMLEFT",w,"TOPLEFT",0,2)
    h.label=parent:CreateFontString(nil,"OVERLAY")
    h.label:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    h.label:SetText("Height:")
    h.label:SetPoint("BOTTOMLEFT",h,"TOPLEFT",0,2)
    local checkButtons=CreateFrame("Frame",nil,parent)
    checkButtons:SetSize(200,(#layout*30)+60)
    for i,opt in ipairs(layout) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        btn:Hide()
        btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-300)
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(Ether.DB[6][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[6][i]=checked and 1 or 0
            if i==12 then
                if Ether.DB[6][12]==1 then
                    Ether:CastBarEnable(i-11)
                else
                    Ether:CastBarDisable(i-11)
                end
            end
            if i==13 then
                if Ether.DB[6][13]==1 then
                    Ether:CastBarEnable(i-11)
                else
                    Ether:CastBarDisable(i-11)
                end
            end
            if i<7 then
                if Ether.DB[6][i]==1 then
                    Ether:ActivateUnitButton(i)
                else
                    Ether:DeactivateUnitButton(i)
                end
            end
        end)
        panel.Buttons[6][i]=btn
    end
end

local ColorState={
    spellId=nil,
    frame=nil,
    oldColor={r=0,g=0,b=0,a=1}
}
local lastR,lastG,lastB,lastA
local function UpdateAuraColor(r,g,b,a)
    if r==lastR and g==lastG and b==lastB and a==lastA then return end
    lastR,lastG,lastB,lastA=r,g,b,a
    if not ColorState.spellId then return end
    local data=Ether.DB[1003][ColorState.spellId]
    data[2][1],data[2][2],data[2][3],data[2][4]=r,g,b,a
    if ColorState.frame then
        ColorState.frame.colorBtn.bg:SetColorTexture(r,g,b,a)
    end
    Ether:UpdateAuraList()
    Ether:UpdatePreview(ColorState.frame)
end

local function OnColorChanged()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=ColorPickerFrame:GetColorAlpha()
    UpdateAuraColor(r,g,b,a)
end

local function OnCancel(prev)
    if not prev then return end
    UpdateAuraColor(prev.r,prev.g,prev.b,prev.a)
end

local function OnAuraSelect(self,data)
    local editor=Ether.UIPanel["CONTENT"]["CHILDREN"]["Aura"]
    if not editor:IsShown() then
        editor:Show()
    end
    Ether:AddTemplateAuras(data.value)
    self.text:SetText(data.value)
end

function Ether:CreateAuraSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Aura"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local editor=panel.Frames["EDITOR"]
    local auras=panel.Frames["AURAS"]
    local auraList={}

    for name in pairs(Ether.PredefinedAuras) do
        tinsert(auraList,{text=name,value=name})
    end

    local dropdown=Ether:CreateEtherDropdown(parent,160,"Predefined Auras",auraList,false,OnAuraSelect)
    dropdown:SetPoint("TOPLEFT")
    auras:SetPoint("TOPLEFT",dropdown,"BOTTOMLEFT",0,0)
    auras:SetSize(230,400)
    editor:SetPoint("TOPRIGHT",parent,"TOPRIGHT",70,-50)
    editor:SetSize(320,300)
    local scrollFrame=CreateFrame("ScrollFrame",nil,auras,"ScrollFrameTemplate")
    editor.scrollFrame=scrollFrame
    scrollFrame:SetPoint("TOPLEFT",0,-10)
    scrollFrame:SetPoint("BOTTOMRIGHT",-25,35)
    local scrollChild=CreateFrame("Frame",nil,scrollFrame)
    scrollChild:SetSize(190,1)
    scrollFrame:SetScrollChild(scrollChild)
    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:Hide()
    end
    local addBtn=EtherPanelButton(auras,50,25,"New","TOP",parent,"TOP",0,-5)
    addBtn:SetScript("OnClick",function()
        if not editor:IsShown() then
            editor:Show()
        end
        Ether:AddCustomAura(editor,auras)
    end)
    addBtn.text:SetPoint("LEFT")

    local confirm=EtherPanelButton(auras,50,25,"Confirm","LEFT",addBtn,"RIGHT",10,0)
    confirm:SetScript("OnClick",function()
        if type(panel.SpellId)~="nil" then
            Ether:SaveAuraPosition(panel.SpellId)
        end
    end)
    local clear=EtherPanelButton(auras,50,25,"Wipe","TOPRIGHT",parent,"TOPRIGHT",0,-5)
    clear:SetScript("OnClick",function()
        Ether:UpdateAuraList()
        Ether:UpdateEditor(editor)
        if Ether:TableSize(DB[1003])==0 then
            Ether:EtherInfo("No auras available to delete")
            return
        end
        if not Ether.popupBox then
            return
        end
        if Ether.popupCallback:GetScript("OnClick") then
            Ether.popupCallback:SetScript("OnClick",nil)
        end
        if not Ether.popupBox:IsShown() then
            Ether.popupBox:SetShown(true)
            Ether.UIPanel.Frames["MAIN"]:SetShown(false)
        end
        Ether.popupBox.font:SetText("Clear all auras?")
        Ether.popupCallback:SetScript("OnClick",function()
            wipe(DB[1003])
            panel.SpellId=nil
            Ether:UpdateAuraList()
            Ether:UpdateEditor(editor)
            Ether:EtherInfo("|cff00ccffAuras|r: Custom auras cleared")
            dropdown.menu:Hide()
            Ether.popupBox:SetShown(false)
            Ether.UIPanel.Frames["MAIN"]:SetShown(true)
        end)
    end)
    auras.scrollChild=scrollChild
    local name=editor:CreateFontString(nil,"OVERLAY")
    editor.nameLabel=name
    name:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    name:SetPoint("TOP",parent,"TOP",-10,-40)
    name:SetText("Name")

    local nameInput=CreateLineInput(editor,140,24)
    editor.nameInput=nameInput
    nameInput:SetPoint("TOPLEFT",name,"BOTTOMLEFT",0,-10)
    nameInput:SetScript("OnEnterPressed",function(_)
        if type(panel.SpellId)~=nil then
            DB[1003][panel.SpellId].name=nameInput:GetText()
            Ether:UpdateAuraList()
        end
        nameInput:ClearFocus()
    end)

    local spellID=editor:CreateFontString(nil,"OVERLAY")
    editor.spellID=spellID
    spellID:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    spellID:SetPoint("TOPLEFT",nameInput,"BOTTOMLEFT",0,-10)
    spellID:SetText("Spell ID")

    local spellIdInput=CreateLineInput(editor,140,24)
    editor.spellIdInput=spellIdInput
    spellIdInput:SetPoint("TOPLEFT",spellID,"BOTTOMLEFT",0,-10)
    spellIdInput:SetNumeric(true)
    spellIdInput:SetScript("OnEnterPressed",function(self)
        local newId=tonumber(self:GetText())
        if Ether.UIPanel.SpellId and newId and newId>0 and newId~=Ether.UIPanel.SpellId then
            local data=DB[1003][Ether.UIPanel.SpellId]
            DB[1003][Ether.UIPanel.SpellId]=nil
            DB[1003][newId]=data
            Ether.UIPanel.SpellId=newId
            Ether:UpdateAuraList()
            Ether:UpdateEditor(editor)
        end
        self:ClearFocus()
    end)

    local isDebuff=EtherPanelButton(editor,50,25,"Debuff","LEFT",spellIdInput,"RIGHT",10,0)
    editor.isDebuff=isDebuff
    isDebuff:SetScript("OnClick",function()
        if type(panel.SpellId)~=nil then
            DB[1003][panel.SpellId][8]=not DB[1003][panel.SpellId][8]
            Ether:UpdateAuraStatus(panel.SpellId)
        end
    end)

    local cube=Ether:CreateCube(editor,24,120,-120,function(self)
        if type(Ether.UIPanel.SpellId)~=nil then
            Ether.DB[1003][Ether.UIPanel.SpellId][4]=self.position
            Ether:UpdateEditor(editor)
            Ether:UpdatePreview(editor)
        end
    end,function(self)
        self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
    end,function(self)
        local data=Ether.UIPanel.SpellId and Ether.DB[1003][Ether.UIPanel.SpellId]
        if data and data[1]==self.position then
            self.bg:SetColorTexture(0.8,0.6,0,0.4)
        else
            self.bg:SetColorTexture(0.2,0.2,0.2,0.8)
        end
    end)
    editor.cube=cube

    local s=Ether:CreateSlider(spellIdInput,"Size","6 px","4","20",1,"TOPLEFT","BOTTOMLEFT",0,-110,function(_,value)
        if not panel.SpellId then return end
        if type(panel.SpellId)~=nil then
            DB[1003][panel.SpellId][3]=value
            editor.s.v:SetText(string_format("%.0f px",value))
            Ether:UpdatePreview(editor)
        end
    end)
    editor.s=s

    local x=Ether:CreateSlider(s,"X-Off","0","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,function(_,value)
        if not panel.SpellId then return end
        if type(panel.SpellId)~=nil then
            DB[1003][panel.SpellId][5]=value
            editor.x.v:SetText(string_format("%.0f",value))
            Ether:UpdatePreview(editor)
        end
    end)
    editor.x=x

    local y=Ether:CreateSlider(x,"Y-Off","0","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,function(_,value)
        if not panel.SpellId then return end
        if type(panel.SpellId)~=nil then
            DB[1003][panel.SpellId][6]=value
            editor.y.v:SetText(string_format("%.0f",value))
            Ether:UpdatePreview(editor)
        end
    end)
    editor.y=y

    local colorBtn=CreateFrame("Button",nil,editor)
    editor.colorBtn=colorBtn
    colorBtn:SetSize(15,15)
    colorBtn:SetPoint("LEFT",s,"RIGHT",20,0)
    editor.colorBtn.bg=colorBtn:CreateTexture(nil,"BACKGROUND")
    editor.colorBtn.bg:SetAllPoints()
    editor.colorBtn.bg:SetColorTexture(1,1,0,1)
    editor.colorBtn:SetScript("OnClick",function()
        local data=Ether.DB[1003][panel.SpellId]
        if not data then return end
        ColorState.spellId=panel.SpellId
        ColorState.frame=editor
        ColorState.oldColor.r=data[2][1]
        ColorState.oldColor.g=data[2][2]
        ColorState.oldColor.b=data[2][3]
        ColorState.oldColor.a=data[2][4]
        ColorPickerFrame:SetupColorPickerAndShow({
            swatchFunc=OnColorChanged,
            opacityFunc=OnColorChanged,
            cancelFunc=OnCancel,
            hasOpacity=true,
            opacity=ColorState.oldColor.a,
            r=ColorState.oldColor.r,
            g=ColorState.oldColor.g,
            b=ColorState.oldColor.b,
            previousValues=ColorState.oldColor
        })
    end)
    local rgbText=editor:CreateFontString(nil,"OVERLAY")
    rgbText:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    rgbText:SetPoint("LEFT",s,"RIGHT",40,0)
    rgbText:SetText("Pick Color")
    local preview=CreateHeaderPreview(editor,Ether.metaData[2],3,55)
    editor.preview=preview
    preview:SetPoint("TOPLEFT",15,-120)
    preview.name:SetPoint("CENTER",0,-5)
    local icon=preview.healthBar:CreateTexture(nil,"OVERLAY")
    editor.icon=icon
    icon:SetSize(6,6)
    icon:SetPoint("TOP",preview.healthBar,"TOP",0,0)
    icon:SetColorTexture(1,1,0,1)
    SetupSliderText(s,"4","20")
    SetupSliderText(y,"-20","20")
    SetupSliderText(x,"-20","20")
    SetupSliderThump(s,10,{0.8,0.6,0,1})
    SetupSliderThump(y,10,{0.8,0.6,0,1})
    SetupSliderThump(x,10,{0.8,0.6,0,1})
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
end

function Ether:CreateEffectsSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Effects"]
    if parent.Created then return end
    parent.Created=true
end

function Ether:CreateHelperSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Helper"]
    if parent.Created then return end
    parent.Created=true
    local spellIDPanel=CreateFrame("Frame",nil,parent)
    spellIDPanel:SetPoint("TOPLEFT",5,-5)
    spellIDPanel:SetSize(250,80)

    local title=parent:CreateFontString(nil,"OVERLAY")
    title:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    title:SetPoint("TOPLEFT",5,-5)
    title:SetText("Spell Information")

    local resultText,spellIcon

    local spellNameBox=CreateLineInput(spellIDPanel,180,20)
    spellNameBox:SetPoint("TOPLEFT",spellIDPanel,"TOPLEFT",10,-30)
    spellNameBox:SetAutoFocus(false)
    spellNameBox:SetScript("OnEnterPressed",function()
        Ether:SpellInfo(spellNameBox:GetText(),resultText,spellIcon)
    end)

    local spellInfo=EtherPanelButton(spellIDPanel,50,25,"Search","LEFT",spellNameBox,"RIGHT",10,0)
    local resultFrame=CreateFrame("Frame",nil,spellIDPanel)
    resultFrame:SetPoint("TOPLEFT",spellNameBox,"BOTTOMLEFT",0,-15)
    resultFrame:SetSize(230,40)

    resultText=resultFrame:CreateFontString(nil,"OVERLAY")
    parent.resultText=resultText
    resultText:SetFont(unpack(Ether.media.expressway),14,"OUTLINE")
    resultText:SetPoint("TOPLEFT",resultFrame,"BOTTOMLEFT",0,0)
    resultText:SetWidth(230)
    resultText:SetJustifyH("LEFT")
    spellIcon=resultFrame:CreateTexture(nil,"OVERLAY")
    spellIcon:SetPoint("LEFT",resultText,"RIGHT")
    spellIcon:SetPoint("LEFT",resultText,"RIGHT")
    spellIcon:SetSize(32,32)
    spellIcon:Hide()
    spellInfo:SetScript("OnClick",function()
        Ether:SpellInfo(spellNameBox:GetText(),resultText,spellIcon)
    end)
    local examples={"Greater Heal(Rank 4)","Greater Heal","25233","Name-Name"}
    local exampleText="Example\n\n"
    for i=1,4 do
        exampleText=exampleText..string_format("• %s\n",examples[i])
    end
    local example=parent:CreateFontString(nil,"OVERLAY")
    example:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    example:SetJustifyH("LEFT")
    example:SetPoint("TOPRIGHT",0,-5)
    example:SetText(exampleText)

    local pvp=EtherPanelButton(parent,50,25,"Check PVP Status","BOTTOMLEFT",parent,"BOTTOMLEFT",40,20)
    pvp:SetScript("OnClick",function()
        Ether:CheckPvpStatus()
    end)
     local ignore=CreateLineInput(parent,180,20)
    ignore:SetPoint("LEFT",parent,"LEFT",10,-80)
    ignore:SetAutoFocus(false)
    ignore:SetScript("OnEnterPressed",function(self)
        local name=self:GetText()
        if name then
           Ether:IgnoreScanData(name,resultText)
        end
        self:ClearFocus()
    end)
    local insert=EtherPanelButton(parent,50,25,"Insert","LEFT",ignore,"RIGHT")
    insert:SetScript("OnClick",function()
        local name=ignore:GetText()
        if name then
          Ether:IgnoreScanData(name,resultText)
        end
    end)
    local find=EtherPanelButton(parent,50,25,"Find","LEFT",insert,"RIGHT")
    find:SetScript("OnClick",function()
        Ether:IgnoreScanInput(resultText)
    end)
    local target=EtherPanelButton(parent,50,25,"Target","LEFT",find,"RIGHT",5,0)
    target:SetScript("OnClick",function()
        Ether:IgnoreScanByTarget(resultText)
    end)
    local remove=EtherPanelButton(parent,50,25,"Remove","LEFT",target,"RIGHT",5,0)
    remove:SetScript("OnClick",function()
        local index=tonumber(ignore:GetText())
        if type(index)~="number" then
            Ether:EtherInfo("|cffcc66ffEtherIgnore:|r Enter Name Id")
            return
        else
            Ether:IgnoreRemoveByIndex(index,resultText)
        end
        ignore:ClearFocus()
    end)
    local clear=EtherPanelButton(parent,50,25,"Clear","LEFT",remove,"RIGHT",5,0)
    clear:SetScript("OnClick",function()
        if Ether:TableSize(Ether.DB["USER"])==0 then
            Ether:EtherInfo("|cffcc66ffEther Ignore|r The ignore list is empty")
            return
        end
        popupBox()
        Ether.popupBox.font:SetText("|cffcc66ffDelete ignore list|r ?")
        Ether.popupCallback:SetScript("OnClick",function()
            wipe(Ether.DB["USER"])
            Ether.popupBox:SetShown(false)
            panel.Frames["MAIN"]:SetShown(true)
        end)
    end)
    local label=parent:CreateFontString(nil,"OVERLAY")
    label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
    label:SetPoint("BOTTOMLEFT",ignore,"TOPLEFT",0,10)
    label:SetText("Enter name to ignore")
    local scan={"Target","Group"}
    local sF=CreateFrame("Frame",nil,parent)
    sF:SetSize(200,(#scan*30)+60)
    for i,opt in ipairs(scan) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",insert,"BOTTOMLEFT",0,-20)
        else
            btn:SetPoint("LEFT",panel.Buttons[7][i-1],"RIGHT",50,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT")
        btn:SetChecked(Ether.DB[7][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[7][i]=checked and 1 or 0
        end)
        panel.Buttons[7][i]=btn
    end
end

local function OnMediaSelect(self,data)
    local LSM=LibStub("LibSharedMedia-3.0")
    local DB=Ether.DB
    self.text:SetText(data.value)
    if self.type=="font" then
        local path=LSM:Fetch("font",data.value)
        DB[100][4]=path
    elseif self.type=="statusbar" then
        local path=LSM:Fetch("statusbar",data.value)
        DB[100][5]=path
    elseif self.type=="background" then
        local path=LSM:Fetch("background",data.value)
        DB[100][6]=path
    end
    Ether:RefreshLayout(Ether.soloButtons)
    Ether:RefreshLayout(Ether.raidButtons)
end

local function OnFlagsSelect(self,data)
    self.text:SetText(data.value)
    Ether:SetupFontFlags(data.value)
end

local function UpdateSliders()
    local parent=Ether.UIPanel["CONTENT"]["CHILDREN"]["Config"]
    local DB=Ether.DB
    local ID=DB[100][2]
    local pos=DB[21][ID]
    parent.s:SetValue(pos[8] or 1)
    parent.a:SetValue(pos[9] or 1)
    parent.f:SetValue(DB[100][7] or 12)
    parent.s.v:SetText(string_format("%.1f",pos[8] or 1))
    parent.a.v:SetText(string_format("%.1f",pos[9] or 1))
    parent.f.v:SetText(string_format("%.0f px",DB[100][7] or 12))
end

local function OnFrameSelect(self,data)
    Ether.DB[100][2]=data.index
    UpdateSliders()
    self.text:SetText(data.value)
end

local function UpdateFontSize()
    Ether:UpdateButtonFont(Ether.raidButtons)
    Ether:UpdateButtonFont(Ether.soloButtons)
end

function Ether:CreateConfigSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Config"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local s=Ether:CreateSlider(parent,"Size","6 px","0.5","2",0.1,"TOPLEFT","TOPLEFT",100,-150,function(self,value)
        local currentID=Ether.DB[100][2]
        if DB[21][currentID] then
            DB[21][currentID][8]=value
            Ether:ApplyFramePosition(currentID)
            self:SetValue(value)
            self.v:SetText(string_format("%.1f",value))
        end
    end)
    local a=Ether:CreateSlider(parent,"Alpha","0","0","1",0.1,"TOPLEFT","TOPLEFT",100,-200,function(self,value)
        local currentID=Ether.DB[100][2]
        if DB[21][currentID] then
            DB[21][currentID][9]=value
            Ether:ApplyFramePosition(currentID)
            self:SetValue(value)
            self.v:SetText(string_format("%.1f",value))
        end
    end)
    local f=Ether:CreateSlider(parent,"Font","8 px","8","24",1,"TOPLEFT","TOPLEFT",100,-250,function(self,value)
        if value then
            DB[100][7]=value
            UpdateFontSize()
            self.v:SetText(string_format("%.0f px",value))
            self:SetValue(value)
        end
    end)
    parent.s=s
    parent.f=f
    parent.a=a
    SetupSliderText(f,"8","24")
    SetupSliderThump(f,10,{0.8,0.6,0,1})
    SetupSliderText(s,"0.5","2.0")
    SetupSliderText(a,"0","1")
    SetupSliderThump(s,10,{0.8,0.6,0,1})
    SetupSliderThump(a,10,{0.8,0.6,0,1})
    local frameList={}
    for index,name in ipairs(layout) do
        tinsert(frameList,{text=name,value=name,index=index})
    end
    local frameDropDown=Ether:CreateEtherDropdown(parent,200,"Select Frame",frameList,false,OnFrameSelect)
    frameDropDown:SetPoint("TOPLEFT")
    local show=false
    local unlock=EtherPanelButton(parent,60,25,"Unlock","LEFT",frameDropDown,"RIGHT",10,0)
    unlock:SetScript("OnClick",function()
        if not show then
            show=true
            Ether.ToggleUnlock(true)
        else
            show=false
            Ether.ToggleUnlock(false)
        end
    end)
    if not LibStub or not LibStub("LibSharedMedia-3.0",true) then return end
    local LSM=LibStub("LibSharedMedia-3.0")
    local fontList,barList,bgList,flagList={},{},{},{}
    for name in pairs(LSM:HashTable("font")) do
        tinsert(fontList,{text=name,value=name})
    end
    for name in pairs(LSM:HashTable("statusbar")) do
        tinsert(barList,{text=name,value=name})
    end
    for name in pairs(LSM:HashTable("background")) do
        tinsert(bgList,{text=name,value=name})
    end
    for _,name in pairs({"OUTLINE","THICKOUTLINE","MONOCHROME","NONE"}) do
        tinsert(flagList,{text=name,value=name})
    end
    local fontDropDown=Ether:CreateEtherDropdown(parent,200,"Select Font",fontList,true,OnMediaSelect)
    fontDropDown.type="font"
    local barDropDown=Ether:CreateEtherDropdown(parent,200,"Select Bar",barList,true,OnMediaSelect)
    barDropDown.type="statusbar"
    local bgDropDown=Ether:CreateEtherDropdown(parent,200,"Select Background",bgList,true,OnMediaSelect)
    bgDropDown.type="background"
    local flagDropDown=Ether:CreateEtherDropdown(parent,120,"Select Font Flags",flagList,"NONE",OnFlagsSelect)
    fontDropDown:SetPoint("TOPRIGHT")
    barDropDown:SetPoint("TOP",fontDropDown,"BOTTOM")
    bgDropDown:SetPoint("TOP",barDropDown,"BOTTOM")
    flagDropDown:SetPoint("LEFT",f,"RIGHT",60,0)
end

local function OnProfileChange(self,data)
    if data.value==Ether:GetProfileName() then return end
    Ether:SwitchProfile(data.value)
    self.text:SetText(data.value)
end

local function GetUpdatedProfileList()
    local newList={}
    for _,name in pairs(Ether:GetProfileList()) do
        tinsert(newList,{text=name,value=name})
    end
    return newList
end

function Ether:CreateProfileSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Profile"]
    if parent.Created then return end
    parent.Created=true

    local profileData={}
    for _,name in ipairs(Ether:GetProfileList()) do
        tinsert(profileData,{text=name,value=name})
    end

    local main=panel.Frames["MAIN"]

    local dropdown=Ether:CreateEtherDropdown(parent,130,"Select Profile",profileData,false,OnProfileChange)
    dropdown:SetPoint("TOPLEFT")
    dropdown.text:SetText(Ether:GetProfileName())
    local inputDialog=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
    inputDialog:SetSize(300,120)
    inputDialog:SetPoint("CENTER")
    inputDialog:SetFrameStrata("DIALOG")
    inputDialog:Hide()
    inputDialog:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true,tileSize=32,edgeSize=32,
        insets={left=11,right=12,top=12,bottom=11}
    })
    local inputTitle=inputDialog:CreateFontString(nil,"OVERLAY","GameFontNormal")
    inputTitle:SetPoint("TOP",inputDialog,"TOP",0,-15)
    local inputBox=CreateFrame("EditBox",nil,inputDialog,"InputBoxTemplate")
    inputBox:SetSize(250,30)
    inputBox:SetPoint("TOP",inputTitle,"BOTTOM",0,-10)
    inputBox:SetAutoFocus(false)
    local okButton=CreateFrame("Button",nil,inputDialog,"GameMenuButtonTemplate")
    okButton:SetSize(100,25)
    okButton:SetPoint("BOTTOMLEFT",inputDialog,"BOTTOM",0,15)
    okButton:SetText("OK")
    local cancelButton=CreateFrame("Button",nil,inputDialog,"GameMenuButtonTemplate")
    cancelButton:SetSize(100,25)
    cancelButton:SetPoint("BOTTOMRIGHT",inputDialog,"BOTTOM",-5,15)
    cancelButton:SetText("Cancel")
    cancelButton:SetScript("OnClick",function()
        inputDialog:Hide()
    end)

    local createButton=EtherPanelButton(parent,60,25,"New","TOPLEFT",dropdown,"BOTTOMLEFT",5,-30)
    createButton:SetScript("OnClick",function()
        inputTitle:SetText("Create new profile")
        inputBox:SetText("")
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick",function()
            local name=inputBox:GetText()
            if name and name~="" then
                local success,msg=Ether:CreateProfile(name)
                if success then
                    local freshData=GetUpdatedProfileList()
                    dropdown:SetOptions(freshData)
                    dropdown.text:SetText(name)
                    Ether:EtherInfo(eColor,msg)
                else
                    Ether:EtherInfo(eColor,msg)
                end
            else
                Ether:EtherInfo(eColor,name)
            end
            inputDialog:Hide()
        end)
    end)
    local copyButton=EtherPanelButton(parent,60,25,"Copy","LEFT",createButton,"RIGHT",5,0)
    copyButton:SetScript("OnClick",function()
        inputTitle:SetText("Copy profile")
        inputBox:SetText(Ether:GetProfileName().." - Copy")
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick",function()
            local name=inputBox:GetText()
            if name and name~="" then
                local success,msg=Ether:CopyProfile(Ether:GetProfileName(),name)
                if success then
                    local freshData=GetUpdatedProfileList()
                    dropdown:SetOptions(freshData)
                    dropdown.text:SetText(name)
                    Ether:EtherInfo(eColor,msg)
                else
                    Ether:EtherInfo(eColor,msg)
                end
            end
            inputDialog:Hide()
        end)
    end)
    local renameButton=EtherPanelButton(parent,60,25,"Rename","TOPLEFT",createButton,"BOTTOMLEFT",0,-20)
    renameButton:SetScript("OnClick",function()
        inputTitle:SetText("Rename profile")
        local name=Ether:GetProfileName()
        inputBox:SetText(name)
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick",function()
            local newName=inputBox:GetText()
            if newName and newName~="" then
                local success,msg=Ether:RenameProfile(name,newName)
                if success then
                    local freshData=GetUpdatedProfileList()
                    dropdown:SetOptions(freshData)
                    dropdown.text:SetText(name)
                    Ether:EtherInfo(eColor,msg)
                else
                    Ether:EtherInfo(eColor,msg)
                end
            end
            inputDialog:Hide()
        end)
    end)

    local deleteButton=EtherPanelButton(parent,60,25,"Delete","LEFT",renameButton,"RIGHT",5,0)
    deleteButton:SetScript("OnClick",function()
        local profileToDelete=Ether:GetProfileName()
        local profiles=Ether:GetProfileList()
        if #profiles<=1 then
            Ether:EtherInfo("|cffcc66ffEther|r Cannot delete the last profile")
            return
        end
        if Ether:GetProfileName()=="DEFAULT" then
            Ether:EtherInfo("|cffcc66ffEther|r Cannot delete Default profile")
            return
        end
        popupBox()
        Ether.popupBox.font:SetText("Delete profile |cffcc66ff"..profileToDelete.."|r ?")
        Ether.popupCallback:SetScript("OnClick",function()
            local success,msg=Ether:DeleteProfile(profileToDelete)
            if success then
                local freshData=GetUpdatedProfileList()
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(Ether:GetProfileName())
                Ether:EtherInfo(eColor..msg)
                if parent.RefreshConfig then
                    parent.RefreshConfig()
                end
                Ether.popupBox:SetShown(false)
                main:SetShown(true)
            else
                Ether:EtherInfo(eColor..msg)
                Ether.popupBox:SetShown(false)
                main:SetShown(true)
            end
        end)
    end)
    local resetButton=EtherPanelButton(parent,60,25,"Reset","TOPLEFT",renameButton,"BOTTOMLEFT",0,-80)
    resetButton:SetScript("OnClick",function()
        popupBox()
        local profileToRest=Ether:GetProfileName()
        Ether.popupBox.font:SetText("Reset profile |cffcc66ff"..profileToRest.."|r ?")
        Ether.popupCallback:SetScript("OnClick",function()
            local success,msg=Ether:ResetProfile()
            if success then
                Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                local freshData=GetUpdatedProfileList()
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(Ether:GetProfileName())
                if parent.RefreshConfig then
                    parent.RefreshConfig()
                end
                Ether.popupBox:SetShown(false)
                main:SetShown(true)
            else
                Ether:EtherInfo(eColor..msg)
                Ether.popupBox:SetShown(false)
                main:SetShown(true)
            end
        end)
    end)

    local transfer=CreateFrame("Frame",nil,parent)
    transfer:SetPoint("TOP",parent,"TOP",50,-5)
    transfer:SetSize(250,200)
    local importBackdrop=CreateFrame("Frame",nil,transfer,"BackdropTemplate")
    importBackdrop:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",-5,5)
    importBackdrop:SetSize(285,280)
    importBackdrop:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true,tileSize=16,edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}
    })
    importBackdrop:SetBackdropColor(0.1,0.1,0.1,0.8)
    importBackdrop:SetBackdropBorderColor(0.4,0.4,0.4)
    local importBox=Ether:CreateImportBox(importBackdrop)

    local import=EtherPanelButton(transfer,60,25,"Import","BOTTOMLEFT",importBox,"TOPLEFT",0,20)
    import.text:SetPoint("LEFT")
    local export=EtherPanelButton(transfer,60,25,"Export","LEFT",import,"RIGHT",20,0)
    export:SetScript("OnClick",function()
        local encoded=Ether:ExportProfileToClipboard()
        if encoded then
            Ether:ShowExportPopup(encoded)
        end
    end)
    import:SetScript("OnClick",function()
        local data=importBox:GetText()
        if data and data~="" and data~="Paste export data here..." then
            local success,msg=Ether:ImportProfile(data)
            if success then
                local freshData=GetUpdatedProfileList()
                dropdown:SetOptions(freshData)
                dropdown.text:SetText(Ether:GetProfileName())
                Ether:EtherInfo("|cff00ff00"..msg.."|r")
                importBox:SetText("")
                parent.Refresh()
            else
                Ether:EtherInfo("|cffff0000"..msg.."|r")
            end
        else
            Ether:EtherInfo("|cffff0000No data to import|r")
        end
    end)

    parent.Refresh=GetUpdatedProfileList
    parent.RefreshConfig=function() end
end
