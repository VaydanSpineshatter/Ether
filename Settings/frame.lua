local _,Ether=...
local string_format=string.format
local pairs,ipairs=pairs,ipairs
local tinsert,tremove=table.insert,table.remove
local eColor="|cffcc66ffEther|r "
local function CreateHeaderPreview(parent,name,numb,size)
    local preview=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    preview:SetSize(size,size)
    preview:SetBackdrop({
        bgFile=Ether.DB[8][2],
        insets={left=-1,right=-1,top=-1,bottom=-1}
    })
    Ether:SetupHealthBar(preview,"HORIZONTAL",size,size,"player")
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
local originalColor,currentEditor
local GenericColor,GenericCancel,OnCancel
do
    local editor=Ether.UIPanel.Frames["EDITOR"]
    local callbacks={
        currentSpellId=nil,
        editorFrame=nil
    }
    function GenericColor()
        local state=callbacks
        if state.currentSpellId and Ether.DB[1003][state.currentSpellId] then
            local r,g,b=ColorPickerFrame:GetColorRGB()
            local a=ColorPickerFrame:GetColorAlpha()
            local data=Ether.DB[1003][state.currentSpellId]
            data.color[1],data.color[2],data.color[3],data.color[4]=r,g,b,a
            if state.editorFrame then
                state.editorFrame.colorBtn.bg:SetColorTexture(r,g,b,a)
                Ether:UpdatePreview(editor)
                Ether:UpdateAuraList()
            end
        end
    end
    function GenericCancel(prevValues)
        local state=callbacks
        if state.currentSpellId and Ether.DB[1003][state.currentSpellId] then
            local data=Ether.DB[1003][state.currentSpellId]
            if prevValues then
                data.color[1]=prevValues.r
                data.color[2]=prevValues.g
                data.color[3]=prevValues.b
                data.color[4]=prevValues.a
            end
            if state.editorFrame then
                local r,g,b,a=data.color[1],data.color[2],data.color[3],data.color[4]
                state.editorFrame.colorBtn.bg:SetColorTexture(r,g,b,a)
                Ether:UpdatePreview(editor)
                Ether:UpdateAuraList()
            end
        end
        function OnCancel(prev)
            if type(Ether.UIPanel.SpellId)=="nil" then
                return
            end
            if Ether.DB[1003][Ether.UIPanel.SpellId] then
                local auraData=Ether.DB[1003][Ether.UIPanel.SpellId]
                if prev then
                    auraData.color[1]=prev.r
                    auraData.color[2]=prev.g
                    auraData.color[3]=prev.b
                    auraData.color[4]=prev.a
                else
                    auraData.color={unpack(originalColor)}
                end

                local color=prevValues or {
                    r=originalColor[1],
                    g=originalColor[2],
                    b=originalColor[3],
                    a=originalColor[4]
                }
                currentEditor.colorBtn.bg:SetColorTexture(color.r,color.g,color.b,color.a)
                Ether:UpdateAuraList()
            end
        end
        callbacks.currentSpellId=nil
        callbacks.editorFrame=nil
    end
end

local function CreateEtherDropdown(parent,width,text,options,position,callback)
    local dropdown=CreateFrame("Button",nil,parent)
    dropdown:SetSize(width,25)
    dropdown.bg=dropdown:CreateTexture(nil,"BACKGROUND")
    dropdown.bg:SetAllPoints()
    dropdown.bg:SetColorTexture(1,1,1,0.1)
    dropdown.bottom=dropdown:CreateTexture(nil,"BORDER")
    dropdown.bottom:SetPoint("BOTTOMLEFT")
    dropdown.bottom:SetPoint("BOTTOMRIGHT")
    dropdown.bottom:SetHeight(1)
    dropdown.bottom:SetColorTexture(0.80,0.40,1.00,1)
    if position=="NONE" then
        dropdown.bottom:Hide()
    elseif position then
        dropdown.left=dropdown:CreateTexture(nil,"BORDER")
        dropdown.left:SetPoint("TOPLEFT")
        dropdown.left:SetPoint("BOTTOMLEFT")
        dropdown.left:SetWidth(-1)
        dropdown.left:SetColorTexture(0.80,0.40,1.00,1)
        dropdown.bottom:Show()
    else
        dropdown.right=dropdown:CreateTexture(nil,"BORDER")
        dropdown.right:SetPoint("TOPRIGHT")
        dropdown.right:SetPoint("BOTTOMRIGHT")
        dropdown.right:SetWidth(1)
        dropdown.right:SetColorTexture(0.80,0.40,1.00,1)
        dropdown.bottom:Show()
    end
    dropdown.text=dropdown:CreateFontString(nil,"OVERLAY")
    dropdown.text:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    dropdown.text:SetPoint("CENTER")
    dropdown.text:SetJustifyH("CENTER")
    dropdown.text:SetJustifyV("MIDDLE")
    dropdown.text:SetText(text)
    local menu=CreateFrame("Button",nil,dropdown)
    dropdown.menu=menu
    menu:SetPoint("TOPLEFT",dropdown,"BOTTOMLEFT",0,-2)
    menu:SetWidth(width)
    menu:SetFrameLevel(parent:GetFrameLevel()+10)
    menu:Hide()
    menu.bg=menu:CreateTexture(nil,"BACKGROUND")
    menu.bg:SetAllPoints()
    menu.bg:SetColorTexture(0.2,0.2,0.2,1)
    menu.bottom=menu:CreateTexture(nil,"BORDER")
    menu.bottom:SetPoint("BOTTOMLEFT")
    menu.bottom:SetPoint("BOTTOMRIGHT")
    menu.bottom:SetHeight(1)
    menu.bottom:SetColorTexture(0.80,0.40,1.00,1)
    if position=="NONE" then
        menu.bottom:Hide()
    elseif position then
        menu.left=menu:CreateTexture(nil,"BORDER")
        menu.left:SetPoint("TOPLEFT")
        menu.left:SetPoint("BOTTOMLEFT")
        menu.left:SetWidth(-1)
        menu.left:SetColorTexture(0.80,0.40,1.00,1)
        menu.bottom:Show()
    else
        menu.right=menu:CreateTexture(nil,"BORDER")
        menu.right:SetPoint("TOPRIGHT")
        menu.right:SetPoint("BOTTOMRIGHT")
        menu.right:SetWidth(1)
        menu.right:SetColorTexture(0.80,0.40,1.00,1)
        menu.bottom:Show()
    end
    menu.buttons={}
    function dropdown:SetOptions(newList)
        if newList then
            options=newList
        end
        local totalHeight=4
        for _,btn in ipairs(menu.buttons) do
            btn:Hide()
        end

        for i,data in ipairs(options) do
            local btn=menu.buttons[i]
            if not btn then
                btn=CreateFrame("Button",nil,menu)
                btn:SetSize(width-8,20)
                btn.text=btn:CreateFontString(nil,"OVERLAY")
                btn.text:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
                btn.text:SetJustifyH("CENTER")
                btn.text:SetJustifyV("MIDDLE")
                btn.text:SetPoint("CENTER")

                btn:SetScript("OnEnter",function(self)
                    self.text:SetTextColor(0.00,0.80,1.00,1)
                end)
                btn:SetScript("OnLeave",function(self)
                    self.text:SetTextColor(1,1,1,1)
                end)

                tinsert(menu.buttons,btn)
            end

            btn:SetPoint("TOPLEFT",4,-totalHeight)
            btn.text:SetText(data.text)
            btn:SetScript("OnClick",function()
                if callback then
                    callback(dropdown,data)
                end
                dropdown.text:SetText(data.text)
                menu:Hide()
            end)
            btn:Show()
            totalHeight=totalHeight+20
        end
        menu:SetHeight(totalHeight+4)
    end

    dropdown:SetScript("OnClick",function()
        menu:SetShown(not menu:IsShown())
    end)
    if options then dropdown:SetOptions(options) end
    return dropdown
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

local function ResetTblText(buttons,tbl)
    for _,btn in pairs(buttons) do
        if btn[tbl] then
            btn[tbl]:SetText("")
        end
    end
end

local function resetHealthPowerText(value)
    if value==1 then
        ResetTblText(Ether.unitButtons["solo"],"health")
    elseif value==2 then
        ResetTblText(Ether.unitButtons["solo"],"power")
    elseif value==3 then
        ResetTblText(Ether.unitButtons["raid"],"health")
    elseif value==4 then
        ResetTblText(Ether.unitButtons["raid"],"power")
    end
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
    local modules={"Icon","Chat Bn & Msg Whisper","Tooltip","Idle mode","Range check","Indicators","Info","Debug"}
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
            end
        end)
        panel.Buttons[1][i]=btn
    end
end

function Ether:CreateBlizzardSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Blizzard"]
    if parent.Created then return end
    parent.Created=true
    local blizzard={"Player frame","Pet frame","Target frame","Focus frame","CastBar","Party","Raid","Raid Manager","MicroMenu","XP Bar","BagsBar"}
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

function Ether:CreateCreationSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Create"]
    if parent.Created then return end
    parent.Created=true
    local units={"|cffCC66FFPlayer|r","|cE600CCFFTarget|r","Target of Target","|cffCC66FFPet|r","|cffCC66FFPetTarget|r","|cff3399FFFocus|r"}
    local uF=CreateFrame('Frame',nil,parent)
    uF:SetSize(200,(#units*30)+60)
    for i,opt in ipairs(units) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOP",panel.Buttons[3][i-1],"BOTTOM",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(Ether.DB[3][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[3][i]=checked and 1 or 0
            if Ether.DB[3][i]==1 then
                Ether:CreateUnitButtons(i)
                if Ether.DB[6][2]==1 then
                    Ether:EnableSoloUnitAura(i)
                end
            else
                if Ether.DB[6][2]==1 then
                    Ether:DisableSoloUnitAura(i)
                end
                Ether:DestroyUnitButtons(i)
            end
        end)
        panel.Buttons[3][i]=btn
    end
end

function Ether:CreateUpdateSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Update"]
    if parent.Created then return end
    parent.Created=true
    local Update={"Health Solo","Power Solo","Health Header","Power Header"}
    local UpdateToggle=CreateFrame("Frame",nil,parent)
    UpdateToggle:SetSize(200,(#Update*30)+60)
    for i,opt in ipairs(Update) do
        local btn=CreateFrame("CheckButton",nil,parent,"OptionsBaseCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[4][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[4][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[4][i]=checked and 1 or 0
            resetHealthPowerText(i)
        end)
        panel.Buttons[4][i]=btn
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

local updateTicker
updateTicker=nil
local customButtons={}
local C_Ticker=C_Timer.NewTicker
local function updateHealth(button)
    if not button then
        return
    end
    local health,healthMax=UnitHealth(button.unit),UnitHealthMax(button.unit)
    if button.healthBar and healthMax>0 then
        button.healthBar:SetMinMaxValues(0,healthMax)
        button.healthBar:SetValue(health)
    end
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

local function updateCustom()
    for i=1,3 do
        updateHealth(customButtons[i])
        updatePower(customButtons[i])
    end
end

local function updateFunc()
    if not updateTicker then
        updateTicker=C_Ticker(0.12,updateCustom)
    end
end

local function DestroyCustom(numb)
    if not customButtons[numb] then
        return
    end
    local button=customButtons[numb]
    button:Hide()
    button:ClearAllPoints()
    button:RegisterForClicks()
    button:RegisterForDrag()
    button:SetAttribute("unit",nil)
    button:SetScript("OnDragStart",nil)
    button:SetScript("OnDragStop",nil)
    button:SetScript("OnEnter",nil)
    button:SetScript("OnLeave",nil)
    button=nil
    customButtons[numb]=nil
end

local function CleanUpCustom(numb)
    if not customButtons[numb] then
        return
    end
    DestroyCustom(numb)
    if not next(customButtons) and updateTicker then
        updateTicker:Cancel()
        if updateTicker:IsCancelled() then
            updateTicker=nil
        else
            Ether:EtherInfo("Custom Updater is not cancelled. Reload UI")
        end
    end
end

local function ParseGUID(unit)
    local guid=UnitGUID(unit)
    local name=UnitName(unit)
    local tokenGuid=UnitTokenFromGUID(guid)
    if guid and tokenGuid then
        return name,tokenGuid
    end
end

local function CreateCustomUnit(numb)
    if InCombatLockdown() then
        return
    end
    if not UnitGUID("target") or not UnitInAnyGroup("player") then
        Ether:EtherInfo("Target a group or raid member")
        return
    end
    if customButtons[numb] then
        return
    end
    local custom=CreateFrame("Button","EtherCustomUnitButton",UIParent,"EtherUnitTemplate")
    local pos=Ether.DB[1401][numb]
    custom:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
    custom:SetSize(120,50)
    local name,unit=ParseGUID("target")
    if not name or not unit then
        return nil
    end
    custom.unit=unit
    Ether:SetupAttribute(custom,custom.unit)
    Ether:SetupTooltip(custom,custom.unit)
    Ether:SetupHealthBar(custom,"HORIZONTAL",120,40)
    local background=custom:CreateTexture(nil,"BACKGROUND")
    background:SetColorTexture(0,0,0,.6)
    background:SetPoint("TOPLEFT",custom,"TOPLEFT",-2,2)
    background:SetPoint("BOTTOMRIGHT",custom,"BOTTOMRIGHT",2,-2)
    local r,g,b=Ether:GetClassColors(custom.unit)
    custom.healthBar:SetStatusBarColor(r,g,b,.8)
    custom.healthDrop:SetColorTexture(r*0.3,g*0.3,b*0.4)
    Ether:SetupPowerBar(custom)
    Ether:SetupName(custom,0)
    custom.name:SetText(name)
    local re,ge,be=Ether:GetPowerColor(custom.unit)
    custom.powerBar:SetStatusBarColor(re,ge,be,.6)
    customButtons[numb]=custom
    updateFunc()
end

local function Drag(self)
    if self:IsMovable() then
        self:StartMoving()
    end
end

local function StopDrag(self,dataNumber)
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
    local pos=Ether.DB[1401][dataNumber]
    pos[1]=point
    pos[2]=relToName
    pos[3]=relPoint
    pos[4]=x
    pos[5]=y
    local anchorRelTo=relToName
    self:ClearAllPoints()
    self:SetPoint(pos[1],anchorRelTo,pos[3],x,y)
    if customButtons[dataNumber] and customButtons[dataNumber]:IsVisible() then
        customButtons[dataNumber]:ClearAllPoints()
        customButtons[dataNumber]:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
    end
end

function Ether:CreateFakeSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Fake"]
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
                local pos=Ether.DB[1401][dataNumber]
                indicator:ClearAllPoints()
                indicator:SetPoint(pos[1],UIParent,pos[3],pos[4],pos[5])
                indicator.tex:SetColorTexture(unpack(color[dataNumber]))
                destroy.text:SetText("Destroy "..configName)
                customDropDown.text:SetText("Selected "..configName)
            end
        })
    end

    customDropDown=CreateEtherDropdown(parent,140,"Select Custom",customConfig,true)
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
    indicator:SetSize(120,50)
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
        CreateCustomUnit(dataNumber)
    end)
    destroy:SetScript("OnClick",function()
        if dataNumber==0 then
            return
        end
        CleanUpCustom(dataNumber)
    end)
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
        [10]="Interface\\RaidFrame\\ReadyCheck-Ready"
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
    local parent=panel["CONTENT"]["CHILDREN"]["Position"]
    if parent.Created then return end
    parent.Created=true
    local iTbl={"Connection","Resurrection","PlayerFlags","UnitFlags","RaidTarget","GroupLeader","MasterLoot","MainTank","GroupRole","ReadyCheck"}
    local DB=Ether.DB
    local register=CreateFrame("Frame",nil,parent)
    register:SetSize(200,(#iTbl*30)+60)
    for i,opt in ipairs(iTbl) do
        local btn=CreateFrame("CheckButton",nil,register,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-100)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[5][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=parent:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[5][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[5][i]=checked and 1 or 0
            Ether.IndicatorToggle(i)
        end)
        panel.Buttons[5][i]=btn
    end

    local Indicator=panel.Frames["INDICATORS"]

    local indicatorList={}
    for index,name in ipairs(iTbl) do
        tinsert(indicatorList,{text=name,value=name,index=index})
    end
    local dropdown=CreateEtherDropdown(parent,160,"Select Indicator",indicatorList,false,OnIndicatorSelect)
    Indicator.dropdown=dropdown
    dropdown:SetPoint("TOPLEFT")

    local preview=CreateHeaderPreview(parent,Ether.metaData[2],3,55)
    Indicator.preview=preview
    preview:SetPoint("TOP",80,-90)
    preview.tex:SetTexture(iIcon)
    preview.name:SetPoint("CENTER",0,-5)

    local cube=Ether:CreateCube(preview,24,90,0,function(self)
        if iNumber then
            Ether.DB[1002][iNumber][1]=self.position
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end,function(self)
        self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
    end,function(self)
        local data=iNumber and Ether.DB[1002][iNumber]
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
            Ether:UpdateIndicatorsPosition(iNumber)
        end
    end)

    local s=Ether:CreateSlider(preview,"Size","6 px","4","34",1,"TOP","BOTTOM",0,-60,function(self,value)
        if iNumber then
            DB[1002][iNumber][4]=value
            self.v:SetText(string.format("%.0f px",value))
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end)
    Indicator.s=s

    local x=Ether:CreateSlider(s,"X-Off","0","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,function(self,value)
        if iNumber then
            Ether.DB[1002][iNumber][2]=value
            self.v:SetText(string.format("%.0f",value))
            Ether:UpdateIndicatorsPos(iNumber,iIcon)
        end
    end)
    Indicator.x=x

    local y=Ether:CreateSlider(x,"Y-Off","0","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,function(self,value)
        if iNumber then
            DB[1002][iNumber][3]=value
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

function Ether:CreateAuraSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Settings"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local Aura={"Enable Auras","Solo Auras","Header Auras"}
    local CreateAurasToggle=CreateFrame("Frame",nil,parent)
    CreateAurasToggle:SetSize(200,(#Aura*30)+60)
    for i,opt in ipairs(Aura) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[6][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[6][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[6][i]=checked and 1 or 0
            if i==1 then
                if Ether.DB[6][1]==1 then
                    Ether:AuraEnable()
                else
                    Ether:AuraDisable()
                end
            elseif i==2 then
                if Ether.DB[6][2]==1 then
                    Ether:EnableSoloAuras()
                else
                    Ether:DisableSoloAuras()
                end
            elseif i==3 then
                Ether:ToggleHeaderAuras()
            end
        end)
        panel.Buttons[6][i]=btn
    end
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
            btn:SetPoint("TOPLEFT",panel.Buttons[7][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(DB[7][i]==1)

        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[7][i]=checked and 1 or 0
        end)
        panel.Buttons[7][i]=btn
    end
end

function Ether:CreateHeaderSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Header"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local data={"Sort order"}
    -- Ether:InitializePreview()
    local header=CreateFrame("Frame",nil,parent)
    header:SetSize(200,(#data*30)+60)
    for i,opt in ipairs(data) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[8][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[8][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[8][i]=checked and 1 or 0
            if i==1 then
                if Ether.DB[8][1]==1 then
                    Ether:ChangeDirectionHeader(true)
                else
                    Ether:ChangeDirectionHeader(false)
                end
            end
        end)
        panel.Buttons[8][i]=btn
    end
end

function Ether:CreateLayoutSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Layout"]
    if parent.Created then return end
    parent.Created=true
    --[[
    local DB=Ether.DB
    local data={"Smooth Health Solo","Smooth Power Solo","Smooth Header"}
    local frame=CreateFrame("Frame",nil,parent)
    frame:SetSize(200,(#data*30)+60)
    for i,opt in ipairs(data) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[9][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[9][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[9][i]=checked and 1 or 0
        end)
        panel.Buttons[9][i]=btn
    end
    ]]
end

function Ether:CreateCastBarSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["CastBar"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local id={"Player CastBar","Target CastBar"}
    local c={"Height","Width","Icon"}
    --local u={"player","target"}
    local barIdTbl={}
    local barConfigTbl={}
    local barDropdown
    local configDropdown
    for _,configName in ipairs(id) do
        table.insert(barIdTbl,{
            text=configName,
            func=function()
                barDropdown.text:SetText(configName)
            end
        })
    end

    for _,configName in ipairs(c) do
        table.insert(barConfigTbl,{
            text=configName,
            func=function()
                configDropdown.text:SetText(configName)
            end
        })
    end
    barDropdown=CreateEtherDropdown(parent,120,"Select CastBar",barIdTbl)
    barDropdown:SetPoint("TOPLEFT")
    configDropdown=CreateEtherDropdown(parent,120,"Config",barConfigTbl,true)
    configDropdown:SetPoint("TOPRIGHT")

    local iconLabel=parent:CreateFontString(nil,"OVERLAY")
    iconLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    iconLabel:SetPoint("BOTTOM",0,120)
    iconLabel:SetText("Size")
    local iconInput=CreateLineInput(parent,70,25)
    iconInput:SetPoint("TOPLEFT",iconLabel,"BOTTOMLEFT",0,-10)
    iconInput:SetNumeric(true)
    iconInput:SetScript("OnEnterPressed",function(self)
        --  local size=tonumber(self:GetText())
        self:ClearFocus()
    end)
    iconLabel:Hide()
    iconInput:Hide()
    local layout=CreateFrame("Frame",nil,parent)
    layout:SetSize(200,(#id*30)+60)
    for i,opt in ipairs(id) do
        local btn=CreateFrame("CheckButton",nil,layout,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-300)
        else
            btn:SetPoint("TOPLEFT",panel.Buttons[10][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=btn:CreateFontString(nil,"OVERLAY")
        btn.label:SetFont(unpack(Ether.media.expressway),12,"OUTLINE")
        btn.label:SetText(opt)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(DB[10][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            DB[10][i]=checked and 1 or 0
            if i==1 then
                if DB[10][1]==1 then
                    Ether:CastBarEnable("player")
                else
                    Ether:CastBarDisable("player")
                end
            elseif i==2 then
                if DB[10][2]==1 then
                    Ether:CastBarEnable("target")
                else
                    Ether:CastBarDisable("target")
                end
            end
        end)
        panel.Buttons[10][i]=btn
    end
end
local function OnAuraSelect(self,data)
    local editor=Ether.UIPanel["CONTENT"]["CHILDREN"]["Custom"]
    if not editor:IsShown() then
        editor:Show()
    end
    Ether:AddTemplateAuras(data.value)
    self.text:SetText(data.value)
end
function Ether:CreateCustomSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Custom"]
    if parent.Created then return end
    parent.Created=true
    local DB=Ether.DB
    local editor=panel.Frames["EDITOR"]
    local auras=panel.Frames["AURAS"]
    local auraList={}

    for name in pairs(Ether.PredefinedAuras) do
        tinsert(auraList,{text=name,value=name})
    end

    local dropdown=CreateEtherDropdown(parent,160,"Predefined Auras",auraList,false,OnAuraSelect)
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
        if type(panel.SpellId)~=nil then return end
        local data=Ether.DB[1003][panel.SpellId]
        originalColor=data.color
        currentEditor=editor
        local function OnColorChanged()
            local r,g,b=ColorPickerFrame:GetColorRGB()
            local a=ColorPickerFrame:GetColorAlpha()
            if Ether.DB[1003][panel.SpellId] then
                local auraData=Ether.DB[1003][panel.SpellId]
                auraData.color[1],auraData.color[2],auraData.color[3],auraData.color[4]=r,g,b,a
                currentEditor.colorBtn.bg:SetColorTexture(r,g,b,a)
                Ether:UpdateAuraList()
                Ether:UpdatePreview(editor)
            end
        end
        local swatchTexture=editor.colorBtn.bg
        ColorPickerFrame:SetupColorPickerAndShow({
            swatchFunc=OnColorChanged,
            opacityFunc=OnColorChanged,
            cancelFunc=OnCancel,
            hasOpacity=true,
            opacity=data.color[4],
            r=data.color[1],
            g=data.color[2],
            b=data.color[3],
            swatch=swatchTexture
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
    spellIcon:SetPoint("TOP",resultText,"BOTTOM",0,-40)
    spellIcon:SetSize(64,64)
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

    local pvp=EtherPanelButton(parent,50,25,"Check PVP Status","BOTTOMLEFT",parent,"BOTTOMLEFT",60,40)
    pvp:SetScript("OnClick",function()
        Ether:CheckPvpStatus()
    end)

    local ignore=CreateLineInput(parent,180,20)
    ignore:SetPoint("LEFT",parent,"LEFT",10,-10)
    ignore:SetAutoFocus(false)
    ignore:SetScript("OnEnterPressed",function(self)
        local name=self:GetText()
        if name then
            Ether:IgnoringHandler(resultText,name)
        end
        self:ClearFocus()
    end)
    local send=EtherPanelButton(parent,50,25,"Enter","LEFT",ignore,"RIGHT",10,0)
    send:SetScript("OnClick",function()
        local name=ignore:GetText()
        if name then
            Ether:IgnoringHandler(resultText,name)
        end
        ignore:ClearFocus()
    end)
    local search=EtherPanelButton(parent,50,25,"Search","LEFT",send,"RIGHT",10,0)
    search:SetScript("OnClick",function()
        for entry in pairs(Ether.DB["USER"]) do
            Ether:EtherInfo(string.format("%s",entry))
        end
    end)
    local clear=EtherPanelButton(parent,50,25,"Delete ignore list","LEFT",search,"RIGHT",50,0)
    clear:SetScript("OnClick",function()
        if Ether:TableSize(Ether.DB["USER"])==0 then
            Ether:EtherInfo("|cffcc66ffEther|r The ignore list is empty")
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

local function UpdateFrames(id)
    local F={
        [1]=Ether.infoFrame,
        [2]=Ether.toolFrame,
        [3]=Ether.soloButtons["player"],
        [4]=Ether.soloButtons["target"],
        [5]=Ether.soloButtons["targettarget"],
        [6]=Ether.soloButtons["pet"],
        [7]=Ether.soloButtons["pettarget"],
        [8]=Ether.soloButtons["focus"],
        [9]=Ether.Anchor.raid,
        [10]=Ether.Anchor.pet,
        [11]=Ether.soloButtons["player"].castBar,
        [12]=Ether.soloButtons["target"].castBar,
        [13]=Ether.EtherIcon
    }
    Ether:ApplyFramePosition(F[id],id)
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
            UpdateFrames(currentID)
            self:SetValue(value)
            self.v:SetText(string_format("%.1f",value))
        end
    end)
    parent.s=s

    local a=Ether:CreateSlider(parent,"Alpha","0","0","1",0.1,"TOPLEFT","TOPLEFT",100,-200,function(self,value)
        local currentID=Ether.DB[100][2]
        if DB[21][currentID] then
            DB[21][currentID][9]=value
            UpdateFrames(currentID)
            self:SetValue(value)
            self.v:SetText(string_format("%.1f",value))
        end
    end)
    parent.a=a

    local f=Ether:CreateSlider(parent,"Font","8 px","8","24",1,"TOPLEFT","TOPLEFT",100,-250,function(self,value)
        if value then
            DB[100][7]=value
            UpdateFontSize()
            self.v:SetText(string_format("%.0f px",value))
            self:SetValue(value)
        end
    end)
    parent.f=f

    SetupSliderText(f,"8","24")
    SetupSliderThump(f,10,{0.8,0.6,0,1})
    SetupSliderText(s,"0.5","2.0")
    SetupSliderText(a,"0","1")
    SetupSliderThump(s,10,{0.8,0.6,0,1})
    SetupSliderThump(a,10,{0.8,0.6,0,1})

    local frames={"InfoFrame","Tooltip","player","target","targettarget","pet","pettarget","focus","RaidButtons","RaidPetButtons","PlayerCastBar","TargetCastBar","EtherIcon"}
    local frameList={}
    for index,name in ipairs(frames) do
        tinsert(frameList,{text=name,value=name,index=index})
    end
    local frameDropDown=CreateEtherDropdown(parent,200,"Select Frame",frameList,false,OnFrameSelect)
    frameDropDown:SetPoint("TOPLEFT")

    local show=false
    local unlock=EtherPanelButton(parent,60,25,"Unlock","LEFT",frameDropDown,"RIGHT",10,0)
    unlock:SetScript("OnClick",function()
        if not show then
            show=true
            Ether.ShowHideSettings(true)
        else
            show=false
            Ether.ShowHideSettings(false)
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

    local fontDropDown=CreateEtherDropdown(parent,200,"Select Font",fontList,true,OnMediaSelect)
    fontDropDown.type="font"
    local barDropDown=CreateEtherDropdown(parent,200,"Select Bar",barList,true,OnMediaSelect)
    barDropDown.type="statusbar"
    local bgDropDown=CreateEtherDropdown(parent,200,"Select Background",bgList,true,OnMediaSelect)
    bgDropDown.type="background"
    local flagDropDown=CreateEtherDropdown(parent,120,"Select Font Flags",flagList,"NONE",OnFlagsSelect)
    fontDropDown:SetPoint("TOPRIGHT")
    barDropDown:SetPoint("TOP",fontDropDown,"BOTTOM")
    bgDropDown:SetPoint("TOP",barDropDown,"BOTTOM")
    flagDropDown:SetPoint("LEFT",f,"RIGHT",60,0)
end

function Ether:CreateEditSection(panel)
    local parent=panel["CONTENT"]["CHILDREN"]["Edit"]
    if parent.Created then return end
    parent.Created=true

    local profileData={}
    for _,name in ipairs(Ether:GetProfileList()) do
        tinsert(profileData,{text=name,value=name})
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
    local main=panel.Frames["MAIN"]

    local dropdown=CreateEtherDropdown(parent,130,"Select Profile",profileData,false,OnProfileChange)
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
            Ether:EtherInfo("|cffcc66ffEther|r Cannot delete the only profile")
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

    local frame=CreateFrame("Frame",nil,UIParent,"BackdropTemplate")
    frame:SetSize(400,300)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    frame:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true,tileSize=32,edgeSize=32,
        insets={left=11,right=12,top=12,bottom=11}
    })
    local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
    title:SetPoint("TOP",frame,"TOP",0,-15)
    title:SetText("Export Data (copied to clipboard)")
    local scrollFrame=CreateFrame("ScrollFrame",nil,frame,"UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-40)
    scrollFrame:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-30,40)
    frame.EditBox=CreateFrame("EditBox",nil,scrollFrame)
    frame.EditBox:SetSize(350,200)
    frame.EditBox:SetMultiLine(true)
    frame.EditBox:SetFont(unpack(Ether.media.expressway),9,"OUTLINE")
    frame.EditBox:SetAutoFocus(false)
    frame.EditBox:SetTextInsets(5,5,5,5)
    scrollFrame:SetScrollChild(frame.EditBox)
    local closeBtn=CreateFrame("Button",nil,frame,"GameMenuButtonTemplate")
    closeBtn:SetSize(100,25)
    closeBtn:SetPoint("BOTTOM",frame,"BOTTOM",0,15)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick",function()
        frame:Hide()
    end)
    Ether.ExportPopup=frame
    parent.Refresh=GetUpdatedProfileList
    parent.RefreshConfig=function()
    end
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