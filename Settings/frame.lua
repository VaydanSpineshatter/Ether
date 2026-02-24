local _,Ether=...
local string_format=string.format
local pairs,ipairs=pairs,ipairs

local function GetFont(_,target,tex,numb)
    target.label=target:CreateFontString(nil,"OVERLAY")
    target.label:SetFont(unpack(Ether.media.expressway),numb,"OUTLINE")
    target.label:SetText(tex)
    return target.label
end
local function CreateHeaderPreview(parent,name,numb,size)
    local preview=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    preview:SetSize(size,size)
    preview:SetBackdrop({
        bgFile=Ether.DB[811][2],
        insets={left=-2,right=-2,top=-2,bottom=-2}
    })
    Ether:SetupHealthBar(preview,"HORIZONTAL",size,size,"player")
    Ether:SetupName(preview,0)
    preview.name:SetText(Ether:ShortenName(name,numb))
    return preview
end

local colorPickerCallbacks={
    currentSpellId=nil,
    editorFrame=nil
}

local function GenericColorChanged()
    local state=colorPickerCallbacks
    if state.currentSpellId and Ether.DB[1003][state.currentSpellId] then
        local r,g,b=ColorPickerFrame:GetColorRGB()
        local a=ColorPickerFrame:GetColorAlpha()
        local auraData=Ether.DB[1003][state.currentSpellId]

        auraData.color[1],auraData.color[2],auraData.color[3],auraData.color[4]=r,g,b,a

        if state.editorFrame then
            state.editorFrame.colorBtn.bg:SetColorTexture(r,g,b,a)
            Ether:UpdatePreview(Ether.UIPanel.Frames["EDITOR"])
            Ether:UpdateAuraList()
        end
    end
end

local function GenericCancel(prevValues)
    local state=colorPickerCallbacks
    if state.currentSpellId and Ether.DB[1003][state.currentSpellId] then
        local auraData=Ether.DB[1003][state.currentSpellId]

        if prevValues then
            auraData.color[1]=prevValues.r
            auraData.color[2]=prevValues.g
            auraData.color[3]=prevValues.b
            auraData.color[4]=prevValues.a
        end

        if state.editorFrame then
            local r,g,b,a=auraData.color[1],auraData.color[2],auraData.color[3],auraData.color[4]
            state.editorFrame.colorBtn.bg:SetColorTexture(r,g,b,a)
            Ether:UpdatePreview(Ether.UIPanel.Frames["EDITOR"])
            Ether:UpdateAuraList()
        end
    end
    colorPickerCallbacks.currentSpellId=nil
    colorPickerCallbacks.editorFrame=nil
end

local originalColor
local currentEditor
local function OnCancel(prevValues)
    if type(Ether.UIPanel. SpellId)=="nil" then return end
    if Ether.DB[1003][Ether.UIPanel.SpellId] then
        local auraData=Ether.DB[1003][Ether.UIPanel.SpellId]

        if prevValues then
            auraData.color[1]=prevValues.r
            auraData.color[2]=prevValues.g
            auraData.color[3]=prevValues.b
            auraData.color[4]=prevValues.a
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

function Ether:UpdateEditor(editor)
    if not Ether.DB[1003][Ether.UIPanel.SpellId] then
        editor.nameInput:SetText("")
        editor.nameInput:Disable()
        editor.spellIdInput:SetText("")
        editor.spellIdInput:Disable()
        editor.colorBtn:Disable()
        editor.sizeSlider:Disable()
        editor.offsetXSlider:Disable()
        editor.YSlider:Disable()
        editor.icon:Hide()
        for _,btn in pairs(editor.posButtons) do
            btn:Disable()
        end
        return
    end

    local data=Ether.DB[1003][Ether.UIPanel.SpellId]
    editor.nameInput:SetText(data.name or "")
    editor.nameInput:Enable()
    editor.icon:Show()
    editor.spellIdInput:SetText(tostring(Ether.UIPanel.SpellId))
    editor.spellIdInput:Enable()
    editor.colorBtn.bg:SetColorTexture(data.color[1],data.color[2],data.color[3],data.color[4])
    editor.colorBtn:Enable()
    editor.offsetXSlider:Enable()
    editor.offsetXSlider:Show()
    editor.YSlider:Enable()
    editor.YSlider:Show()
    editor.sizeSlider:SetValue(data.size)
    editor.sizeSlider:Enable()
    editor.sizeSlider:Show()
    editor.sizeValue:SetText(string_format("%.0f px",data.size))
    for pos,btn in pairs(editor.posButtons) do
        if pos==data.position then
            btn.bg:SetColorTexture(0.8,0.6,0,0.5)
            btn:Enable()
        else
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.5)
            btn:Enable()
        end
    end
    editor.offsetXSlider:SetValue(data.offsetX)
    editor.offsetXValue:SetText(string_format("%.0f",data.offsetX))
    editor.YSlider:SetValue(data.offsetY)
    editor.offsetYValue:SetText(string_format("%.0f",data.offsetY))
    Ether:UpdatePreview(editor)
end

function Ether:UpdatePreview(editor)
    if type(Ether.UIPanel.SpellId)=="nil" then return end
    local data=Ether.DB[1003][Ether.UIPanel.SpellId]
    local indicator=editor.icon
    indicator:SetSize(data.size,data.size)
    indicator:SetColorTexture(data.color[1],data.color[2],data.color[3],data.color[4])
    indicator:ClearAllPoints()
    local posMap={
        TOPLEFT={"TOPLEFT",data.offsetX,data.offsetY},
        TOP={"TOP",data.offsetX,data.offsetY},
        TOPRIGHT={"TOPRIGHT",data.offsetX,data.offsetY},
        LEFT={"LEFT",data.offsetX,-data.offsetY},
        CENTER={"CENTER",data.offsetX,-data.offsetY},
        RIGHT={"RIGHT",data.offsetX,-data.offsetY},
        BOTTOMLEFT={"BOTTOMLEFT",data.offsetX,data.offsetY},
        BOTTOM={"BOTTOM",data.offsetX,data.offsetY},
        BOTTOMRIGHT={"BOTTOMRIGHT",data.offsetX,data.offsetY}
    }
    local pos=posMap[data.position]
    if pos then
        indicator:SetPoint(pos[1],editor.preview.healthBar,pos[1],pos[2],pos[3])
    end
end

local function SelectAura(editor,spellId)
    Ether.UIPanel.SpellId=spellId
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
end

local function AddCustomAura(editor)
    local newId=1
    while Ether.DB[1003][newId] do
        newId=newId+1
    end
    Ether.DB[1003][newId]=Ether.AuraTemplate(newId)
    SelectAura(editor,newId)
end

local function UpdateAuraStatus(spellId)
    if Ether.DB[1001][3]~=1 then return end
    if not spellId then return end
    local debuff=Ether.DB[1003][spellId].isDebuff
    local active=Ether.DB[1003][spellId].isActive
    local editor=Ether.UIPanel.Frames["EDITOR"]
    if debuff then
        editor.isDebuff.bg:SetColorTexture(0.80,0.40,1.00,0.4)
    else
        editor.isDebuff.bg:SetColorTexture(0,0,0,0)
    end
    if not active then
        editor.isActive.bg:SetColorTexture(0.80,0.40,1.00,0.4)
        Ether:ForceHelpfulNotActive()
    else
        editor.isActive.bg:SetColorTexture(0,0,0,0)
        Ether:ForceHelpfulNotActive()
    end
end

local function EtherSpellInfo(spellName,resultText,spellIcon)
    if not resultText or not spellIcon then return end
    spellName=spellName:trim()
    if spellName=="" then
        resultText:SetText("Enter spell name")
        resultText:SetTextColor(1,1,1)
        spellIcon:Hide()
        return
    end
    local spellID=C_Spell.GetSpellIDForSpellIdentifier(spellName)
    if not spellID then
        local baseName=spellName:gsub("%s*%(%s*[Rr]ank%s+%d+%s*%)",""):trim()
        if baseName~=spellName then
            spellID=C_Spell.GetSpellIDForSpellIdentifier(baseName)
        end
    end
    if not spellID then
        resultText:SetText("Not found: "..spellName)
        resultText:SetTextColor(1,0,0)
        spellIcon:Hide()
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
        spellIcon:SetTexture(iconID)
        spellIcon:Show()
    else
        spellIcon:Hide()
    end
    local resultStr=string_format("Spell Name: %s\nSpellID: %d",name,spellID)
    if subtext~="" then
        resultStr=resultStr..string_format("\n%s",subtext)
    end
    if levelLearned>0 then
        resultStr=resultStr..string_format("\nLearned at: Level %d",levelLearned)
    end

    resultText:SetText(resultStr)
    resultText:SetTextColor(1,1,1)
    Ether:EtherInfo(resultStr)
    spellIcon:SetScript("OnEnter",function()
        GameTooltip:SetOwner(spellIcon,"ANCHOR_RIGHT")
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

    spellIcon:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)
end

local function CreateEtherDropdown(parent,width,text,options,position)
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
    if position then
        dropdown.left=dropdown:CreateTexture(nil,"BORDER")
        dropdown.left:SetPoint("TOPLEFT")
        dropdown.left:SetPoint("BOTTOMLEFT")
        dropdown.left:SetWidth(-1)
        dropdown.left:SetColorTexture(0.80,0.40,1.00,1)
    else
        dropdown.right=dropdown:CreateTexture(nil,"BORDER")
        dropdown.right:SetPoint("TOPRIGHT")
        dropdown.right:SetPoint("BOTTOMRIGHT")
        dropdown.right:SetWidth(1)
        dropdown.right:SetColorTexture(0.80,0.40,1.00,1)
    end
    dropdown.text=dropdown:CreateFontString(nil,"OVERLAY")
    dropdown.text:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    dropdown.text:SetPoint("CENTER")
    dropdown.text:SetJustifyH("CENTER")
    dropdown.text:SetJustifyV("MIDDLE")
    dropdown.text:SetText(text)
    local menu=CreateFrame("Button",nil,dropdown)
    dropdown.menu=menu
    menu:SetPoint("TOPLEFT")
    menu:SetWidth(width)
    menu.bg=menu:CreateTexture(nil,"BACKGROUND")
    menu.bg:SetAllPoints()
    menu.bg:SetColorTexture(0.2,0.2,0.2,1)
    menu:SetFrameLevel(parent:GetFrameLevel()+10)
    menu:Hide()
    menu.bottom=menu:CreateTexture(nil,"BORDER")
    menu.bottom:SetPoint("BOTTOMLEFT")
    menu.bottom:SetPoint("BOTTOMRIGHT")
    menu.bottom:SetHeight(1)
    menu.bottom:SetColorTexture(0.00,0.80,1.00,1)
    if position then
        menu.left=menu:CreateTexture(nil,"BORDER")
        menu.left:SetPoint("TOPLEFT")
        menu.left:SetPoint("BOTTOMLEFT")
        menu.left:SetWidth(-1)
        menu.left:SetColorTexture(0.00,0.80,1.00,1)
    else
        menu.right=menu:CreateTexture(nil,"BORDER")
        menu.right:SetPoint("TOPRIGHT")
        menu.right:SetPoint("BOTTOMRIGHT")
        menu.right:SetWidth(1)
        menu.right:SetColorTexture(0.00,0.80,1.00,1)
    end
    local totalHeight=4
    for _,data in ipairs(options) do
        local btn=CreateFrame("Button",nil,menu)
        btn:SetSize(width-8,20)
        btn:SetPoint("TOPLEFT",4,-totalHeight)
        btn.text=btn:CreateFontString(nil,"OVERLAY")
        btn.text:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
        btn.text:SetJustifyH("CENTER")
        btn.text:SetJustifyV("MIDDLE")
        btn.text:SetPoint("CENTER")
        btn.text:SetText(data.text)
        btn:SetScript("OnEnter",function()
            btn.text:SetTextColor(0.00,0.80,1.00,1)
        end)
        btn:SetScript("OnLeave",function()
            btn.text:SetTextColor(1,1,1,1)
        end)
        btn:SetScript("OnClick",function()
            if data.func then
                data.func()
                menu:SetShown(false)
            end
        end)
        totalHeight=totalHeight+20
    end
    menu:SetHeight(totalHeight+4)
    dropdown:SetScript("OnClick",function()
        menu:SetShown(true)
    end)
    menu:SetScript("OnLeave",function()
        menu:SetShown(false)
    end)
    menu:SetScript("OnShow",function()
        Ether.WrapSettingsColor({0.00,0.80,1.00,1})
    end)
    menu:SetScript("OnHide",function()
        Ether.WrapSettingsColor({0.80,0.40,1.00,1})
        menu:SetShown(false)
    end)
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
    input:SetScript("OnEditFocusGained",function(self)
        line:SetColorTexture(0,0.8,1,1)
        line:SetHeight(1)
        bg:SetColorTexture(1,1,1,0.1)
    end)
    input:SetScript("OnEditFocusLost",function(self)
        line:SetColorTexture(0.80,0.40,1.00,1)
        line:SetHeight(1)
        bg:SetColorTexture(1,1,1,0.1)
    end)
    input:SetScript("OnEscapePressed",function(self)
        self:ClearFocus()
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

local function EtherPanelButton(parent,width,height,text,point,relto,rel,offX,offY)
    local btn=CreateFrame("Button",nil,parent)
    btn:SetSize(width,height)
    btn:SetPoint(point,relto,rel,offX,offY)
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

local number=nil
local iconTexture=""
local coordinates=""
local indicatorType=""
local currentIndicator=nil

local function UpdateIndicators(self)
    if not number then return end
    local data=Ether.DB[1002][number]
    if not data then return end

    if indicatorType=="texture" then
        self.icon:SetSize(data[1],data[1])
        self.icon:ClearAllPoints()
        self.icon:SetPoint(data[2],self.preview.healthBar,data[2],data[3],data[4])
    elseif indicatorType=="string" then
        self.text:SetSize(data[1],data[1])
        self.text:ClearAllPoints()
        self.text:SetPoint(data[2],self.preview.healthBar,data[2],data[3],data[4])
    end
end

local function UpdateIndicatorsValue(self)
    if not number then return end
    local data=Ether.DB[1002][number]
    if not data then return end

    self.icon:Hide()
    self.text:Hide()
    if indicatorType=="texture" then
        self.icon:SetTexture(iconTexture)
        self.icon:SetTexCoord(0,1,0,1)
        self.icon:Show()
        if coordinates then
            self.icon:SetTexCoord(unpack(coordinates))
        end
    elseif indicatorType=="string" then
        self.text:Show()
        self.text:SetText([[|cE600CCFFAFK|r]])
    end

    self.sizeSlider:SetValue(data[1])

    if self.sizeValue then
        self.sizeValue:SetText(string_format("%.0f px",data[1]))
    end

    for pos,btn in pairs(self.posButtons) do
        if pos==data[2] then
            btn.bg:SetColorTexture(0.8,0.6,0,0.5)
        else
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.5)
        end
    end

    self.offsetXSlider:SetValue(data[3])
    if self.offsetXValue then
        self.offsetXValue:SetText(string_format("%.0f",data[3]))
    end

    self.YSlider:SetValue(data[4])
    if self.offsetYValue then
        self.offsetYValue:SetText(string_format("%.0f",data[4]))
    end

    UpdateIndicators(self)
end

function Ether:CreateModuleSection(self)
    local parent=self["CONTENT"]["CHILDREN"]["Module"]
    if parent.Created then return end
    parent.Created=true
    local modulesValue={
        [1]={name="Icon"},
        [2]={name="Chat Bn & Msg Whisper"},
        [3]={name="Tooltip"},
        [4]={name="Idle mode"},
        [5]={name="Range check"},
        [6]={name="Indicators"},
        [7]={name="Info Frame"}
    }

    local mod=CreateFrame("Frame",nil,parent)
    mod:SetSize(200,(#modulesValue*30)+60)
    for i,opt in ipairs(modulesValue) do
        local btn=CreateFrame("CheckButton",nil,mod,"OptionsBaseCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",parent,5,-5)
        else
            btn:SetPoint("TOPLEFT",self.Buttons[1][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        GetFont(self,btn,opt.name,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[401][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[401][i]=checked and 1 or 0
            if i==1 then
                local LDI=LibStub("LibDBIcon-1.0")
                if Ether.DB[401][1]==1 then
                    LDI:Show("EtherIcon")
                    ETHER_ICON.hide=false
                else
                    LDI:Hide("EtherIcon")
                    ETHER_ICON.hide=true
                end
            elseif i==2 then
                Ether.EnableMsgEvents()
            elseif i==5 then
                if Ether.DB[401][5]==1 then
                    Ether:RangeEnable()
                else
                    Ether:RangeDisable()
                end
            elseif i==6 then
                if Ether.DB[401][6]==1 then
                    Ether:IndicatorsEnable()
                else
                    Ether:IndicatorsDisable()
                end
            end
        end)
        self.Buttons[1][i]=btn
    end
end

function Ether:CreateBlizzardSection(self)
    local parent=self["CONTENT"]["CHILDREN"]["Blizzard"]
    if parent.Created then return end
    parent.Created=true
    local HideValue={
        [1]={name="Player frame"},
        [2]={name="Pet frame"},
        [3]={name="Target frame"},
        [4]={name="Focus frame"},
        [5]={name="CastBar"},
        [6]={name="Party"},
        [7]={name="Raid"},
        [8]={name="Raid Manager"},
        [9]={name="MicroMenu"},
        [10]={name="XP Bar"},
        [11]={name="BagsBar"}
    }
    local bF=CreateFrame("Frame",nil,parent)
    bF:SetSize(200,(#HideValue*30)+60)
    for i,opt in ipairs(HideValue) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",self.Buttons[2][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(self,btn,opt.name,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(Ether.DB[101][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[101][i]=checked and 1 or 0

        end)
        self.Buttons[2][i]=btn
    end
end

function Ether:CreateAboutSection(self)
    local parent=self["CONTENT"]["CHILDREN"]["About"]
    if parent.Created then return end
    parent.Created=true
    local slash=GetFont(self,parent,"Slash Commands",15)
    slash:SetPoint("TOP",0,-20)
    local lastY=-20
    for _,entry in ipairs(Ether.SlashInfo) do
        local fs=GetFont(self,parent,string_format("%s  –  %s",entry.cmd,entry.desc),12)
        fs:SetPoint("TOP",slash,"BOTTOM",0,lastY)
        lastY=lastY-18
    end
    local idle=GetFont(self,parent,"What happens in idle mode?",15)
    idle:SetPoint("TOP",0,-180)
    local idleInfo=GetFont(self,parent,"When the user is not at the keyboard,\nEther deregisters all events and OnUpdate functions.",12)
    idleInfo:SetPoint("TOP",0,-220)

    local auras=GetFont(self,parent,"How do I create my own auras?",15)
    auras:SetPoint("TOP",idleInfo,"BOTTOM",0,-30)
    local aurasInfo=GetFont(self,parent,"Only via SpellId. Use Aura Helper or other methods.",12)
    aurasInfo:SetPoint("TOP",auras,"BOTTOM",0,-10)
end

function Ether:CreateCreationSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Create"]
    if parent.Created then return end
    parent.Created=true
    local CreateUnits={
        [1]={name="|cffCC66FFPlayer|r"},
        [2]={name="|cE600CCFFTarget|r"},
        [3]={name="Target of Target"},
        [4]={name="|cffCC66FFPet|r"},
        [5]={name="|cffCC66FFPetTarget|r"},
        [6]={name="|cff3399FFFocus|r"},
    }

    local uF=CreateFrame('Frame',nil,parent)
    uF:SetSize(200,(#CreateUnits*30)+60)
    for i,opt in ipairs(CreateUnits) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOP",EtherFrame.Buttons[3][i-1],"BOTTOM",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(EtherFrame,btn,opt.name,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(Ether.DB[201][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[201][i]=checked and 1 or 0
            if Ether.DB[201][i]==1 then
                Ether:CreateUnitButtons(i)
                if Ether.DB[1001][2]==1 then
                    Ether:EnableSoloUnitAura(i)
                end
            else
                if Ether.DB[1001][2]==1 then
                    Ether:DisableSoloUnitAura(i)
                end
                Ether:DestroyUnitButtons(i)
            end
        end)
        EtherFrame.Buttons[3][i]=btn
    end

end

local updateTicker=nil
local customButtons={}
local C_Ticker=C_Timer.NewTicker
local function updateHealth(button)
    if not button then return end
    local health,healthMax=UnitHealth(button.unit),UnitHealthMax(button.unit)
    if button.healthBar and healthMax>0 then
        button.healthBar:SetMinMaxValues(0,healthMax)
        button.healthBar:SetValue(health)
    end
end
local function updatePower(button)
    if not button then return end
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
    if not customButtons[numb] then return end
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
    if not customButtons[numb] then return end
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
    if customButtons[numb] then return end
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

function Ether:CreateFakeSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Fake"]
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
        if dataNumber==0 then return end
        CreateCustomUnit(dataNumber)
    end)
    destroy:SetScript("OnClick",function()
        if dataNumber==0 then return end
        CleanUpCustom(dataNumber)
    end)
end

function Ether:CreateUpdateSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Update"]
    if parent.Created then return end
    parent.Created=true
    local UpdateValue={
        [1]={text="Health Solo"},
        [2]={text="Power Solo"},
        [3]={text="Health Header"},
        [4]={text="Power Header"},
    }

    local UpdateToggle=CreateFrame("Frame",nil,parent)
    UpdateToggle:SetSize(200,(#UpdateValue*30)+60)
    for i,opt in ipairs(UpdateValue) do
        local btn=CreateFrame("CheckButton",nil,parent,"OptionsBaseCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",EtherFrame.Buttons[4][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(EtherFrame,btn,opt.text,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[701][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[701][i]=checked and 1 or 0
            resetHealthPowerText(i)
        end)
        EtherFrame.Buttons[4][i]=btn
    end
end

function Ether:CreateSettingsSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Settings"]
    if parent.Created then return end
    parent.Created=true
    local CreateAura={
        [1]={text="Enable/Disable Auras"},
        [2]={text="Solo Auras"},
        [3]={text="Header Auras"}
    }
    local CreateAurasToggle=CreateFrame("Frame",nil,parent)
    CreateAurasToggle:SetSize(200,(#CreateAura*30)+60)
    for i,opt in ipairs(CreateAura) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",EtherFrame.Buttons[5][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(EtherFrame,btn,opt.text,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[1001][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[1001][i]=checked and 1 or 0
            if i==1 then
                if Ether.DB[1001][1]==1 then
                    Ether:AuraEnable()
                else
                    Ether:AuraDisable()
                end
            elseif i==2 then
                if Ether.DB[1001][2]==1 then
                    Ether:EnableSoloAuras()
                else
                    Ether:DisableSoloAuras()
                end
            elseif i==3 then
                if Ether.DB[1001][3]==1 then
                    Ether:EnableHeaderAuras()
                else
                    Ether:DisableHeaderAuras()
                end
            end
        end)
        EtherFrame.Buttons[5][i]=btn
    end
end

function Ether:AddTemplateAuras(templateName)
    local template=Ether.PredefinedAuras[templateName]
    if not template then
        return
    end

    local added=0
    local skipped=0

    for spellID,auraData in pairs(template) do
        if not Ether.DB[1003][spellID] then
            Ether.DB[1003][spellID]=Ether:CopyTable(auraData)
            added=added+1
        else
            skipped=skipped+1
        end
    end

    Ether:UpdateAuraList()

    local msg=string_format("|cff00ccffAuras|r: Template '%s' loaded. ",templateName)
    if added>0 then
        msg=msg..string_format("|cff00ff00+%d new auras|r",added)
    end
    if skipped>0 then
        msg=msg..string_format(" (%d already existed)",skipped)
    end
    Ether:EtherInfo(msg)
    Ether.UIPanel.SpellId=nil
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
end

function Ether:CreateCustomSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Custom"]
    if parent.Created then return end
    parent.Created=true
    EtherFrame.Frames["AURAS"].Created=true
    EtherFrame.Frames["EDITOR"].Created=true
    EtherFrame.Frames["AURAS"]:SetParent(parent)
    EtherFrame.Frames["EDITOR"]:SetParent(parent)

    local auraWipe={}
    for templateName,_ in pairs(Ether.PredefinedAuras) do
        table.insert(auraWipe,{
            text=templateName,
            func=function()
                if not EtherFrame.Frames["EDITOR"]:IsShown() then
                    EtherFrame.Frames["EDITOR"]:Show()
                end
                Ether:AddTemplateAuras(templateName,true)
            end
        })
    end
    local auraDropdown=CreateEtherDropdown(parent,160,"Predefined Auras",auraWipe)
    auraDropdown:SetPoint("TOPLEFT")
    local editor=EtherFrame.Frames["EDITOR"]
    local auras=EtherFrame.Frames["AURAS"]
    auras:SetPoint("TOPLEFT",auraDropdown,"BOTTOMLEFT",0,0)
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
        AddCustomAura(editor,auras)
    end)
    addBtn.text:SetPoint("LEFT")

    local confirm=EtherPanelButton(auras,50,25,"Confirm","LEFT",addBtn,"RIGHT",10,0)
    confirm:SetScript("OnClick",function()
        if type(Ether.UIPanel.SpellId)~="nil" then
            Ether:SaveAuraPosition(Ether.UIPanel.SpellId)
        end
    end)
    local clear=EtherPanelButton(auras,50,25,"Wipe","TOPRIGHT",parent,"TOPRIGHT",0,-5)
    clear:SetScript("OnClick",function()
        if Ether:TableSize(Ether.DB[1003])==0 then
            Ether:EtherInfo("No auras available to delete")
            return
        end
        if not Ether.popupBox then return end
        if Ether.popupCallback:GetScript("OnClick") then
            Ether.popupCallback:SetScript("OnClick",nil)
        end
        if not Ether.popupBox:IsShown() then
            Ether.popupBox:SetShown(true)
            Ether.UIPanel.Frames["MAIN"]:SetShown(false)
        end
        Ether.popupBox.font:SetText("Clear all auras?")
        Ether.popupCallback:SetScript("OnClick",function()
            wipe(Ether.DB[1003])
            Ether.UIPanel.SpellId=nil
            Ether:UpdateAuraList()
            Ether:UpdateEditor(editor)
            Ether:EtherInfo("|cff00ccffAuras|r: Custom auras cleared")
            auraDropdown.menu:Hide()
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
    nameInput:SetScript("OnEnterPressed",function(self)
        if Ether.UIPanel.SpellId then
            Ether.DB[1003][Ether.UIPanel.SpellId].name=self:GetText()
            Ether:UpdateAuraList()
        end
        self:ClearFocus()
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
            local data=Ether.DB[1003][Ether.UIPanel.SpellId]
            Ether.DB[1003][Ether.UIPanel.SpellId]=nil
            Ether.DB[1003][newId]=data
            Ether.UIPanel.SpellId=newId
            Ether:UpdateAuraList()
            Ether:UpdateEditor(editor)
        end
        self:ClearFocus()
    end)

    local isDebuff=EtherPanelButton(editor,50,25,"Debuff","LEFT",spellIdInput,"RIGHT",10,0)
    editor.isDebuff=isDebuff
    isDebuff:SetScript("OnClick",function(self)
        if Ether.UIPanel.SpellId then
            Ether.DB[1003][Ether.UIPanel.SpellId].isDebuff=not Ether.DB[1003][Ether.UIPanel.SpellId].isDebuff
            UpdateAuraStatus(Ether.UIPanel.SpellId)
        end
    end)
    local isActive=EtherPanelButton(editor,50,25,"Active","BOTTOMLEFT",isDebuff,"TOPLEFT",0,10)
    editor.isActive=isActive
    isActive:SetScript("OnClick",function()
        if Ether.UIPanel.SpellId then
            Ether.DB[1003][Ether.UIPanel.SpellId].isActive=not Ether.DB[1003][Ether.UIPanel.SpellId].isActive
            UpdateAuraStatus(Ether.UIPanel.SpellId)
        end
    end)
    local sizeLabel=editor:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
    editor.sizeLabel=sizeLabel
    sizeLabel:SetPoint("TOPLEFT",spellIdInput,"BOTTOMLEFT",0,-120)
    sizeLabel:SetText("Size")

    local sizeSlider=CreateFrame("Slider",nil,editor,"OptionsSliderTemplate")
    editor.sizeSlider=sizeSlider
    sizeSlider:SetPoint("TOPLEFT",sizeLabel,"BOTTOMLEFT")
    sizeSlider:SetWidth(100)
    sizeSlider:SetMinMaxValues(4,20)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("4")
    sizeSlider.High:SetText("20")
    sizeSlider:SetScript("OnValueChanged",function(self,value)
        if Ether.UIPanel.SpellId then
            Ether.DB[1003][Ether.UIPanel.SpellId].size=value
            editor.sizeValue:SetText(string_format("%.0f px",value))
            Ether:UpdatePreview(editor)
        end
    end)
    local sizeSliderBG=sizeSlider:CreateTexture(nil,"BACKGROUND")
    editor.sizeSliderBG=sizeSliderBG
    sizeSliderBG:SetPoint("CENTER")
    sizeSliderBG:SetSize(100,10)
    sizeSliderBG:SetColorTexture(0.2,0.2,0.2,0.8)
    sizeSliderBG:SetDrawLayer("BACKGROUND",-1)

    local sizeValue=editor:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
    editor.sizeValue=sizeValue
    sizeValue:SetPoint("TOP",sizeSlider,"BOTTOM",0,-5)
    sizeValue:SetText("6 px")

    local colorBtn=CreateFrame("Button",nil,editor)
    editor.colorBtn=colorBtn
    colorBtn:SetSize(15,15)
    colorBtn:SetPoint("LEFT",sizeSlider,"RIGHT",20,0)
    editor.colorBtn.bg=colorBtn:CreateTexture(nil,"BACKGROUND")
    editor.colorBtn.bg:SetAllPoints()
    editor.colorBtn.bg:SetColorTexture(1,1,0,1)
    editor.colorBtn:SetScript("OnClick",function()
        if not Ether.UIPanel.SpellId then
            return
        end
        local data=Ether.DB[1003][Ether.UIPanel.SpellId]
        originalColor=data.color
        currentEditor=editor
        local function OnColorChanged()
            local r,g,b=ColorPickerFrame:GetColorRGB()
            local a=ColorPickerFrame:GetColorAlpha()
            if Ether.UIPanel.SpellId and Ether.DB[1003][Ether.UIPanel.SpellId] then
                local auraData=Ether.DB[1003][Ether.UIPanel.SpellId]
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
    rgbText:SetPoint("LEFT",sizeSlider,"RIGHT",40,0)
    rgbText:SetText("Pick Color")

    local preview=CreateHeaderPreview(editor,Ether.playerName,3,55)
    editor.preview=preview
    preview:SetPoint("TOPLEFT",15,-120)
    preview.name:SetPoint("CENTER",0,-5)
    local icon=preview.healthBar:CreateTexture(nil,"OVERLAY")
    editor.icon=icon
    icon:SetSize(6,6)
    icon:SetPoint("TOP",preview.healthBar,"TOP",0,0)
    icon:SetColorTexture(1,1,0,1)

    local positions={
        {"TOPLEFT","TOP","TOPRIGHT"},
        {"LEFT","CENTER","RIGHT"},
        {"BOTTOMLEFT","BOTTOM","BOTTOMRIGHT"}
    }

    editor.posButtons={}
    local startX,startY=120,-120
    local btnSize=25

    for row=1,3 do
        for col=1,3 do
            local pos=positions[row][col]
            local btn=CreateFrame("Button",nil,editor)
            btn:SetSize(btnSize,btnSize)
            btn:SetPoint("TOPLEFT",startX+(col-1)*(btnSize+1),startY-(row-1)*(btnSize+1))

            btn.bg=btn:CreateTexture(nil,"BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.8)

            btn.text=btn:CreateFontString(nil,"OVERLAY")
            btn.text:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(pos:sub(1,1))

            btn.position=pos
            btn:SetScript("OnClick",function(self)
                if Ether.UIPanel.SpellId then
                    Ether.DB[1003][Ether.UIPanel.SpellId].position=self.position
                    Ether:UpdateEditor(editor)
                    Ether:UpdatePreview(editor)
                end
            end)

            btn:SetScript("OnEnter",function(self)
                self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
            end)
            btn:SetScript("OnLeave",function(self)
                local data=Ether.UIPanel.SpellId and Ether.DB[1003][Ether.UIPanel.SpellId]
                if data and data.position==self.position then
                    self.bg:SetColorTexture(0.8,0.6,0,0.4)
                else
                    self.bg:SetColorTexture(0.2,0.2,0.2,0.8)
                end
            end)
            editor.posButtons[pos]=btn
        end
    end

    local offsetXLabel=editor:CreateFontString(nil,"OVERLAY")
    editor.offsetXLabel=offsetXLabel
    offsetXLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetXLabel:SetPoint("TOPLEFT",sizeLabel,"BOTTOMLEFT",0,-50)
    offsetXLabel:SetText("X Offset")

    local offsetXSlider=CreateFrame("Slider",nil,editor,"OptionsSliderTemplate")
    editor.offsetXSlider=offsetXSlider
    offsetXSlider:SetPoint("TOPLEFT",offsetXLabel,"BOTTOMLEFT")
    offsetXSlider:SetWidth(100)
    offsetXSlider:SetMinMaxValues(-20,20)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    offsetXSlider.Low:SetText("-20")
    offsetXSlider.High:SetText("20")
    offsetXSlider:SetScript("OnValueChanged",function(self,value)
        if Ether.UIPanel.SpellId then
            Ether.DB[1003][Ether.UIPanel.SpellId].offsetX=value
            editor.offsetXValue:SetText(string_format("%.0f",value))
            Ether:UpdatePreview(editor,Ether.UIPanel.SpellId)
        end
    end)
    local offsetXBG=offsetXSlider:CreateTexture(nil,"BACKGROUND")
    offsetXBG:SetPoint("CENTER")
    offsetXBG:SetSize(100,10)
    offsetXBG:SetColorTexture(0.2,0.2,0.2,0.8)
    offsetXBG:SetDrawLayer("BACKGROUND",-1)

    local offsetYLabel=editor:CreateFontString(nil,"OVERLAY")
    editor.offsetYLabel=offsetYLabel
    offsetYLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetYLabel:SetPoint("LEFT",offsetXLabel,"RIGHT",80,0)
    offsetYLabel:SetText("Y Offset")

    local YSlider=CreateFrame("Slider",nil,editor,"OptionsSliderTemplate")
    editor.YSlider=YSlider
    YSlider:SetPoint("TOPLEFT",offsetYLabel,"BOTTOMLEFT")
    YSlider:SetWidth(100)
    YSlider:SetMinMaxValues(-20,20)
    YSlider:SetValueStep(1)
    YSlider.Low:SetText("-20")
    YSlider.High:SetText("20")
    YSlider:SetObeyStepOnDrag(true)
    YSlider:SetScript("OnValueChanged",function(self,value)
        if Ether.UIPanel.SpellId then
            Ether.DB[1003][Ether.UIPanel.SpellId].offsetY=value
            editor.offsetYValue:SetText(string_format("%.0f",value))
            Ether:UpdatePreview(editor)
        end
    end)
    local offsetYBG=YSlider:CreateTexture(nil,"BACKGROUND")
    offsetYBG:SetPoint("CENTER")
    offsetYBG:SetSize(100,10)
    offsetYBG:SetColorTexture(0.2,0.2,0.2,0.6)
    offsetYBG:SetDrawLayer("BACKGROUND",-1)

    local offsetXValue=editor:CreateFontString(nil,"OVERLAY")
    editor.offsetXValue=offsetXValue
    offsetXValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetXValue:SetPoint("TOP",offsetXSlider,"BOTTOM")
    offsetXValue:SetText("0")

    local offsetYValue=editor:CreateFontString(nil,"OVERLAY")
    editor.offsetYValue=offsetYValue
    offsetYValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetYValue:SetPoint("TOP",YSlider,"BOTTOM")
    offsetYValue:SetText("0")

    SetupSliderText(sizeSlider,"4","20")
    SetupSliderText(YSlider,"-20","20")
    SetupSliderText(offsetXSlider,"-20","20")
    SetupSliderThump(sizeSlider,10,{0.8,0.6,0,1})
    SetupSliderThump(YSlider,10,{0.8,0.6,0,1})
    SetupSliderThump(offsetXSlider,10,{0.8,0.6,0,1})

    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
end

function Ether:UpdateAuraList()
    local editor=Ether.UIPanel.Frames["EDITOR"]
    local auras=Ether.UIPanel.Frames["AURAS"]
    for _,btn in ipairs(Ether.UIPanel.Buttons[12]) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(Ether.UIPanel.Buttons[12])
    local yOffset=0
    local index=1
    for spellId,data in pairs(Ether.DB[1003]) do
        local btn=CreateFrame("Button",nil,auras.scrollChild)
        btn:SetSize(200,40)
        btn:SetPoint("TOP",2,yOffset)

        btn.bg=btn:CreateTexture(nil,"BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.1,0.1,0.1,0.6)

        btn:SetScript("OnEnter",function(self)
            self.bg:SetColorTexture(0.2,0.2,0.2,0.7)
        end)
        btn:SetScript("OnLeave",function(self)
            if Ether.UIPanel.SpellId==spellId then
                self.bg:SetColorTexture(0.80,0.40,1.00,0.2)
            else
                self.bg:SetColorTexture(0.1,0.1,0.1,0.8)
            end
        end)

        btn:SetScript("OnClick",function()
            if not editor:IsShown() then
                editor:Show()
            end
            SelectAura(editor,spellId)
            UpdateAuraStatus(spellId)
        end)

        btn.name=btn:CreateFontString(nil,"OVERLAY")
        btn.name:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
        btn.name:SetPoint("TOPLEFT",10,-8)
        btn.name:SetText(data.name or "Unknown")

        btn.spellId=btn:CreateFontString(nil,"OVERLAY")
        btn.spellId:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
        btn.spellId:SetPoint("TOPLEFT",10,-23)
        btn.spellId:SetText("Spell ID: "..spellId)
        btn.spellId:SetTextColor(0,0.8,1)

        btn.colorBox=btn:CreateTexture(nil,"OVERLAY")
        btn.colorBox:SetSize(15,15)
        btn.colorBox:SetPoint("RIGHT",-10,0)
        if data.color then
            btn.colorBox:SetColorTexture(data.color[1],data.color[2],data.color[3],data.color[4])
        end

        btn.deleteBtn=CreateFrame("Button",nil,btn)
        btn.deleteBtn:SetSize(15,15)
        btn.deleteBtn:SetPoint("RIGHT",btn.colorBox,"LEFT",0,0)
        btn.deleteBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        btn.deleteBtn:SetScript("OnClick",function(self)
            if not Ether.popupBox then return end
            if Ether.popupCallback:GetScript("OnClick") then
                Ether.popupCallback:SetScript("OnClick",nil)
            end
            if not Ether.popupBox:IsShown() then
                Ether.popupBox:SetShown(true)
                Ether.UIPanel.Frames["MAIN"]:SetShown(false)
            end
            Ether.popupBox.font:SetText("Delete Aura |cffcc66ff"..tostring(spellId).."|r ?")
            Ether.popupCallback:SetScript("OnClick",function()
                Ether.UIPanel.Frames["MAIN"]:SetShown(true)
                Ether.popupBox:SetShown(false)
                Ether.DB[1003][spellId]=nil
                if Ether.UIPanel.SpellId==spellId then
                    Ether.UIPanel.SpellId=nil
                end
                Ether:UpdateAuraList()
                Ether:UpdateEditor(editor)
            end)
            self:GetParent():GetScript("OnLeave")(self:GetParent())
        end)
        btn.spellId=spellId
        table.insert(Ether.UIPanel.Buttons[12],btn)

        if Ether.UIPanel.SpellId==spellId then
            btn.bg:SetColorTexture(0,0.8,1,0.8,.3)
        end
        yOffset=yOffset-45
        index=index+1
    end
end

function Ether:CreateEffectsSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Effects"]
    if parent.Created then return end
    parent.Created=true
end

function Ether:CreateHelperSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Helper"]
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
        EtherSpellInfo(spellNameBox:GetText(),resultText,spellIcon)
    end)

    local spellInfo=EtherPanelButton(spellIDPanel,50,25,"Search","LEFT",spellNameBox,"RIGHT",10,0)
    local resultFrame=CreateFrame("Frame",nil,spellIDPanel)
    resultFrame:SetPoint("TOPLEFT",spellNameBox,"BOTTOMLEFT",0,-15)
    resultFrame:SetSize(230,40)

    resultText=resultFrame:CreateFontString(nil,"OVERLAY")
    resultText:SetFont(unpack(Ether.media.expressway),11,"OUTLINE")
    resultText:SetPoint("TOPLEFT",resultFrame,"BOTTOMLEFT",0,0)
    resultText:SetWidth(230)
    resultText:SetJustifyH("LEFT")

    spellIcon=resultFrame:CreateTexture(nil,"OVERLAY")
    spellIcon:SetPoint("TOP",resultText,"BOTTOM",0,-40)
    spellIcon:SetSize(64,64)
    spellIcon:Hide()
    spellInfo:SetScript("OnClick",function()
        EtherSpellInfo(spellNameBox:GetText(),resultText,spellIcon)
    end)

    local examples={"Greater Heal(Rank 4)","Greater Heal","25233"}
    local exampleText="Example\n\n"
    for i=1,3 do
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
end

function Ether:CreatePositionSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Position"]
    if parent.Created then return end
    parent.Created=true
    -- local tbl = {"ReadCheck","Connection","RaidTarget","Resurrection","GroupLeader","LootMethod", "UnitFlags", "PlayerRoles","PlayerFlags"}
    -- local icon = {}
    local I_Register = {
        [1] = {text = "Ready check", texture = "Interface\\RaidFrame\\ReadyCheck-Ready", texture2 = "Interface\\RaidFrame\\ReadyCheck-NotReady", texture3 = "Interface\\RaidFrame\\ReadyCheck-Waiting"},
        [2] = {text = "Connection", texture = "Interface\\CharacterFrame\\Disconnect-Icon", size = 30},
        [3] = {text = "Raid target update", texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", size = 14, coo = {0.75, 1, 0.25, 0.5}},
        [4] = {text = "Resurrection", texture = "Interface\\RaidFrame\\Raid-Icon-Rez", size = 20},
        [5] = {text = "Leader", texture = "Interface\\GroupFrame\\UI-Group-LeaderIcon"},
        [6] = {text = "Loot method", texture = "Interface\\GroupFrame\\UI-Group-MasterLooter", size = 16},
        [7] = {text = "Unit Flags |cffff0000 Red Name|r  &", texture = "Interface\\Icons\\Spell_Shadow_Charm", texture2 = "Interface\\Icons\\Spell_Holy_GuardianSpirit"},
        [8] = {text = "Maintank and Mainassist", texture = "Interface\\GroupFrame\\UI-Group-MainTankIcon", texture2 = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"},
        [9] = {text = "Player flags  |cE600CCFFAFK|r & |cffCC66FFDND|r"}
    }

    local DB = Ether.DB
    local iRegister = CreateFrame("Frame", nil, parent)
    iRegister:SetSize(200, (#I_Register * 30) + 60)

    for i, opt in ipairs(I_Register) do
        local btn = CreateFrame("CheckButton", nil, iRegister, "InterfaceOptionsCheckButtonTemplate")
        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -100)
        else
            btn:SetPoint("TOPLEFT", Ether.UIPanel.Buttons[6][i - 1], "BOTTOMLEFT", 0, 0)
        end
        btn:SetSize(24, 24)
        btn.label = GetFont(EtherFrame, btn, opt.text, 12)
        btn.label:SetPoint("LEFT", btn, "RIGHT", 10, 0)
        btn.texture = btn:CreateTexture(nil, "OVERLAY")
        btn.texture:SetSize(18, 18)
        btn.texture:SetPoint("LEFT", btn.label, "RIGHT", 8, 0)
        btn.texture:SetTexture(opt.texture)
        btn.texture2 = btn:CreateTexture(nil, "OVERLAY")
        btn.texture2:SetSize(18, 18)
        btn.texture2:SetPoint("LEFT", btn.label, "RIGHT", 35, 0)
        btn.texture2:SetTexture(opt.texture2)
        btn.texture3 = btn:CreateTexture(nil, "OVERLAY")
        btn.texture3:SetSize(18, 18)
        btn.texture3:SetPoint("LEFT", btn.label, "RIGHT", 60, 0)
        btn.texture3:SetTexture(opt.texture3)
        if opt.size then
            btn.texture:SetSize(opt.size, opt.size)
        end
        if opt.coo then
            btn.texture:SetTexCoord(unpack(opt.coo))
        end
        if opt.coo2 then
            btn.texture2:SetTexCoord(unpack(opt.coo2))
        end
        if opt.coo3 then
            btn.texture3:SetTexCoord(unpack(opt.coo3))
        end
        btn:SetChecked(DB[501][i]==1)

        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[501][i]=checked and 1 or 0
            Ether:IndicatorsRegisterByIndex(i)
        end)
        EtherFrame.Buttons[6][i]=btn
    end

    local Indicator=EtherFrame.Frames["INDICATORS"]
    Indicator.sizeValue=nil
    Indicator.offsetXValue=nil
    Indicator.offsetYValue=nil
    local indicators={
        ["ReadyCheck"]={icon="Interface\\RaidFrame\\ReadyCheck-Ready",id=1,type="texture"},
        ["Connection"]={icon="Interface\\CharacterFrame\\Disconnect-Icon",id=2,type="texture"},
        ["RaidTarget"]={icon="Interface\\TargetingFrame\\UI-RaidTargetingIcons",id=3,coordinates={0.75,1,0.25,0.5},type="texture"},
        ["Resurrection"]={icon="Interface\\RaidFrame\\Raid-Icon-Rez",id=4,type="texture"},
        ["GroupLeader"]={icon="Interface\\GroupFrame\\UI-Group-LeaderIcon",id=5,type="texture"},
        ["MasterLoot"]={icon="Interface\\GroupFrame\\UI-Group-MasterLooter",id=6,type="texture"},
        ["UnitFlags"]={icon="Interface\\Icons\\Spell_Holy_GuardianSpirit",id=7,type="texture"},
        ["PlayerRoles"]={icon="Interface\\GroupFrame\\UI-Group-MainTankIcon",id=8,type="texture"},
        ["PlayerFlags"]={type="string",id=9},
    }
    local templateDropdown
    local indicatorFunc={}
    for name in pairs(indicators) do
        table.insert(indicatorFunc,{
            text=name,
            func=function()
                Indicator.sizeSlider:Show()
                Indicator.sizeSlider:Enable()
                Indicator.YSlider:Show()
                Indicator.YSlider:Enable()
                Indicator.offsetXSlider:Show()
                Indicator.offsetXSlider:Enable()
                Indicator.offsetXLabel:Show()
                Indicator.sizeLabel:Show()
                Indicator.offsetYLabel:Show()
                Indicator.offsetXValue:Show()
                Indicator.offsetYValue:Show()
                Indicator.sizeValue:Show()
                Indicator.preview:Show()
                for _,btn in pairs(Indicator.posButtons) do
                    btn:Enable()
                end
                number=indicators[name].id
                if indicators[name].type=="texture" then
                    indicatorType=indicators[name].type
                    iconTexture=indicators[name].icon
                    coordinates=indicators[name].coordinates
                end
                if indicators[name].type=="string" then
                    indicatorType=indicators[name].type
                    coordinates=indicators[name].coordinates
                end
                currentIndicator=name
                templateDropdown.text:SetText(currentIndicator)
                UpdateIndicatorsValue(Indicator)
            end
        })
    end

    templateDropdown=CreateEtherDropdown(parent,160,"Select Indicator",indicatorFunc)
    Indicator.templateDropdown=templateDropdown
    templateDropdown:SetPoint("TOPLEFT")

    local preview=CreateHeaderPreview(parent,Ether.playerName,3,55)
    Indicator.preview=preview
    preview:SetPoint("TOP",80,-90)
    local icon=preview.healthBar:CreateTexture(nil,"OVERLAY")
    Indicator.icon=icon
    icon:SetSize(12,12)
    icon:SetPoint("TOP",preview.healthBar,"TOP",0,0)
    icon:SetTexture(iconTexture)
    preview.name:SetPoint("CENTER",0,-5)
    local textIndicator=preview.healthBar:CreateFontString(nil,"OVERLAY")
    textIndicator:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    Indicator.text=textIndicator
    textIndicator:SetPoint("TOP",preview.healthBar,"TOP",0,0)
    textIndicator:Hide()

    local positions={
        {"TOPLEFT","TOP","TOPRIGHT"},
        {"LEFT","CENTER","RIGHT"},
        {"BOTTOMLEFT","BOTTOM","BOTTOMRIGHT"}
    }

    Indicator.posButtons={}
    local startX,startY=90,0
    local btnSize=25

    for row=1,3 do
        for col=1,3 do
            local pos=positions[row][col]
            local btn=CreateFrame("Button",nil,preview)
            btn:SetSize(btnSize,btnSize)
            btn:SetPoint("TOPLEFT",startX+(col-1)*(btnSize+1),startY-(row-1)*(btnSize+1))
            btn.bg=btn:CreateTexture(nil,"BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.8)
            btn.text=btn:CreateFontString(nil,"OVERLAY")
            btn.text:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
            btn.text:SetPoint("CENTER")
            btn.text:SetText(pos:sub(1,1))
            btn.position=pos
            btn:SetScript("OnClick",function(self)
                if number then
                    Ether.DB[1002][number][2]=self.position
                    UpdateIndicatorsValue(Indicator)
                end
            end)
            btn:SetScript("OnEnter",function(self)
                self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
            end)
            btn:SetScript("OnLeave",function(self)
                local data=number and Ether.DB[1002][number]
                if data and data[2]==self.position then
                    self.bg:SetColorTexture(0.8,0.6,0,0.4)
                else
                    self.bg:SetColorTexture(0.2,0.2,0.2,0.8)
                end
            end)

            Indicator.posButtons[pos]=btn
        end
    end

    local sizeLabel=parent:CreateFontString(nil,"OVERLAY")
    Indicator.sizeLabel=sizeLabel
    sizeLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    sizeLabel:SetPoint("TOPLEFT",preview,"BOTTOMLEFT",0,-50)
    sizeLabel:SetText("Size")

    local confirm=EtherPanelButton(preview,60,25,"Confirm","BOTTOMLEFT",preview,"TOPRIGHT",0,40)
    confirm:SetScript("OnClick",function()
        if currentIndicator and number then
            Ether:SaveIndicatorsPosition(currentIndicator,number)
        end
    end)

    local sizeSlider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    Indicator.sizeSlider=sizeSlider
    sizeSlider:SetPoint("TOPLEFT",sizeLabel,"BOTTOMLEFT")
    sizeSlider:SetWidth(100)
    sizeSlider:SetMinMaxValues(4,34)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("4")
    sizeSlider.High:SetText("34")
    sizeSlider:SetScript("OnValueChanged",function(self,value)
        if number then
            Ether.DB[1002][number][1]=value
            if Indicator.sizeValue then
                Indicator.sizeValue:SetText(string_format("%.0f px",value))
            end
            UpdateIndicatorsValue(Indicator)
        end
    end)
    local sizeSliderBG=sizeSlider:CreateTexture(nil,"BACKGROUND")
    sizeSliderBG:SetPoint("CENTER")
    sizeSliderBG:SetSize(100,10)
    sizeSliderBG:SetColorTexture(0.2,0.2,0.2,0.8)
    sizeSliderBG:SetDrawLayer("BACKGROUND",-1)

    local sizeValue=parent:CreateFontString(nil,"OVERLAY")
    Indicator.sizeValue=sizeValue
    sizeValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    sizeValue:SetPoint("TOP",sizeSlider,"BOTTOM",0,-5)
    sizeValue:SetText("6 px")

    local offsetXLabel=parent:CreateFontString(nil,"OVERLAY")
    Indicator.offsetXLabel=offsetXLabel
    offsetXLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetXLabel:SetPoint("TOPLEFT",sizeLabel,"BOTTOMLEFT",0,-50)
    offsetXLabel:SetText("X Offset")

    local offsetXSlider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    Indicator.offsetXSlider=offsetXSlider
    offsetXSlider:SetPoint("TOPLEFT",offsetXLabel,"BOTTOMLEFT")
    offsetXSlider:SetWidth(100)
    offsetXSlider:SetMinMaxValues(-20,20)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    offsetXSlider.Low:SetText("-20")
    offsetXSlider.High:SetText("20")
    offsetXSlider:SetScript("OnValueChanged",function(self,value)
        if number then
            Ether.DB[1002][number][3]=value
            if Indicator.offsetXValue then
                Indicator.offsetXValue:SetText(string_format("%.0f",value))
            end
            UpdateIndicatorsValue(Indicator)
        end
    end)
    local offsetXBG=offsetXSlider:CreateTexture(nil,"BACKGROUND")
    offsetXBG:SetPoint("CENTER")
    offsetXBG:SetSize(100,10)
    offsetXBG:SetColorTexture(0.2,0.2,0.2,0.8)
    offsetXBG:SetDrawLayer("BACKGROUND",-1)

    local offsetXValue=parent:CreateFontString(nil,"OVERLAY")
    Indicator.offsetXValue=offsetXValue
    offsetXValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetXValue:SetPoint("TOP",offsetXSlider,"BOTTOM")
    offsetXValue:SetText("0")

    local offsetYLabel=parent:CreateFontString(nil,"OVERLAY")
    Indicator.offsetYLabel=offsetYLabel
    offsetYLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetYLabel:SetPoint("TOPLEFT",offsetXLabel,"BOTTOMLEFT",0,-50)
    offsetYLabel:SetText("Y Offset")

    local YSlider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    Indicator.YSlider=YSlider
    YSlider:SetPoint("TOPLEFT",offsetYLabel,"BOTTOMLEFT")
    YSlider:SetWidth(100)
    YSlider:SetMinMaxValues(-20,20)
    YSlider:SetValueStep(1)
    YSlider:SetObeyStepOnDrag(true)
    YSlider.Low:SetText("-20")
    YSlider.High:SetText("20")
    YSlider:SetScript("OnValueChanged",function(self,value)
        if number then
            Ether.DB[1002][number][4]=value
            if Indicator.offsetYValue then
                Indicator.offsetYValue:SetText(string_format("%.0f",value))
            end
            UpdateIndicatorsValue(Indicator)
        end
    end)

    local offsetYBG=YSlider:CreateTexture(nil,"BACKGROUND")
    offsetYBG:SetPoint("CENTER")
    offsetYBG:SetSize(100,10)
    offsetYBG:SetColorTexture(0.2,0.2,0.2,0.6)
    offsetYBG:SetDrawLayer("BACKGROUND",-1)

    local offsetYValue=parent:CreateFontString(nil,"OVERLAY")
    Indicator.offsetYValue=offsetYValue
    offsetYValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    offsetYValue:SetPoint("TOP",YSlider,"BOTTOM")
    offsetYValue:SetText("0")

    SetupSliderText(sizeSlider,"4","34")
    SetupSliderText(YSlider,"-20","20")
    SetupSliderText(offsetXSlider,"-20","20")
    SetupSliderThump(sizeSlider,10,{0.8,0.6,0,1})
    SetupSliderThump(YSlider,10,{0.8,0.6,0,1})
    SetupSliderThump(offsetXSlider,10,{0.8,0.6,0,1})
end

function Ether:CreateTooltipSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Tooltip"]
    if parent.Created then return end
    parent.Created=true
    local tbl={"AFK","DND","PVP","Resting","Realm","Level","Class","Guild","Role","Creature","Race","RaidTarget","Reaction"}

    local mF=CreateFrame("Frame",nil,parent)
    mF:SetSize(200,(#tbl*30)+60)

    for i,opt in ipairs(tbl) do
        local btn=CreateFrame("CheckButton",nil,mF,"InterfaceOptionsCheckButtonTemplate")

        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",EtherFrame.Buttons[7][i-1],"BOTTOMLEFT",0,0)
        end

        btn:SetSize(24,24)

        btn.label=GetFont(EtherFrame,btn,opt,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",8,1)
        btn:SetChecked(Ether.DB[301][i]==1)

        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[301][i]=checked and 1 or 0
        end)
        EtherFrame.Buttons[7][i]=btn
    end
end

function Ether:CreateLayoutSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Layout"]
    if parent.Created then return end
    parent.Created=true
    local tbl={"Smooth Health Solo","Smooth Power Solo","Smooth Header"}
    local layout=CreateFrame("Frame",nil,parent)
    layout:SetSize(200,(#tbl*30)+60)

    for i,opt in ipairs(tbl) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")

        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",EtherFrame.Buttons[8][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(EtherFrame,btn,opt,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[801][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[801][i]=checked and 1 or 0
        end)
        EtherFrame.Buttons[8][i]=btn
    end
end

function Ether:CreateHeaderSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Header"]
    if parent.Created then return end
    parent.Created=true
    local layoutValue={
        [1]={text="Sort order"}
    }
    -- Ether:InitializePreview()
    local header=CreateFrame("Frame",nil,parent)
    header:SetSize(200,(#layoutValue*30)+60)
    for i,opt in ipairs(layoutValue) do
        local btn=CreateFrame("CheckButton",nil,parent,"InterfaceOptionsCheckButtonTemplate")
        if i==1 then
            btn:SetPoint("TOPLEFT",5,-5)
        else
            btn:SetPoint("TOPLEFT",EtherFrame.Buttons[11][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(EtherFrame,btn,opt.text,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[1501][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[1501][i]=checked and 1 or 0
            if i==1 then
                if Ether.DB[1501][1]==1 then
                    Ether:ChangeDirectionHeader(true)
                else
                    Ether:ChangeDirectionHeader(false)
                end
                --   Ether:InitializePreview()
            end
        end)
        EtherFrame.Buttons[11][i]=btn
    end

end

function Ether:CreateCastBarSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["CastBar"]
    if parent.Created then return end
    parent.Created=true

    local castBarId={
        [11]="Player CastBar",token="player",
        [12]="Target CastBar",token="target"
    }
    local castBarConfig={
        [1]="Height",
        [2]="Width",
        [3]="Icon",
    }

    local barIdTbl={}
    local barConfigTbl={}
    local barDropdown
    local configDropdown
    for _,configName in pairs(castBarId) do
        table.insert(barIdTbl,{
            text=configName,
            func=function()
                barDropdown.text:SetText(configName)

            end
        })
    end

    for _,configName in ipairs(castBarConfig) do
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
        local size=tonumber(self:GetText())

        self:ClearFocus()
    end)
    iconLabel:Hide()
    iconInput:Hide()
    local layoutValue={
        [1]={text="Player CastBar"},
        [2]={text="Target CastBar"}
    }

    local layout=CreateFrame("Frame",nil,parent)
    layout:SetSize(200,(#layoutValue*30)+60)

    for i,opt in ipairs(layoutValue) do
        local btn=CreateFrame("CheckButton",nil,layout,"InterfaceOptionsCheckButtonTemplate")

        if i==1 then
            btn:SetPoint("TOPLEFT",parent,"TOPLEFT",10,-300)
        else
            btn:SetPoint("TOPLEFT",EtherFrame.Buttons[9][i-1],"BOTTOMLEFT",0,0)
        end
        btn:SetSize(24,24)
        btn.label=GetFont(EtherFrame,btn,opt.text,12)
        btn.label:SetPoint("LEFT",btn,"RIGHT",10,0)
        btn:SetChecked(Ether.DB[1201][i]==1)
        btn:SetScript("OnClick",function(self)
            local checked=self:GetChecked()
            Ether.DB[1201][i]=checked and 1 or 0
            if i==1 then
                if Ether.DB[1201][1]==1 then
                    Ether:CastBarEnable("player")
                else
                    Ether:CastBarDisable("player")
                end
            elseif i==2 then
                if Ether.DB[1201][2]==1 then
                    Ether:CastBarEnable("target")
                else
                    Ether:CastBarDisable("target")
                end
            end
        end)
        EtherFrame.Buttons[9][i]=btn
    end
end

function Ether:CreateConfigSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Config"]
    if parent.Created then return end
    parent.Created=true
    local editor=EtherFrame.Frames["EDITOR"]
    local auras=EtherFrame.Frames["AURAS"]

    if not editor.Created or not auras.Created then
        Ether:CreateCustomSection(EtherFrame)
        editor.Created,auras.Created=true,true
    end
    if not EtherFrame["CONTENT"]["CHILDREN"]["Position"].Created then
        Ether:CreatePositionSection(EtherFrame)
        EtherFrame["CONTENT"]["CHILDREN"]["Position"].Created=true
    end

    local DB=Ether.DB
    local K={"Tooltip","player","target","targettarget","pet","pettarget","focus","Raid","InfoFrame"}

    local F={
        [1]=Ether.Anchor.tooltip,
        [2]=Ether.unitButtons.solo[K[2]],
        [3]=Ether.unitButtons.solo[K[3]],
        [4]=Ether.unitButtons.solo[K[4]],
        [5]=Ether.unitButtons.solo[K[5]],
        [6]=Ether.unitButtons.solo[K[6]],
        [7]=Ether.unitButtons.solo[K[7]],
        [8]=Ether.Anchor.raid,
        [9]=Ether.infoFrame
    }
    local sizeLabel=parent:CreateFontString(nil,"OVERLAY")
    sizeLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    sizeLabel:SetPoint("TOPLEFT",5,-50)
    sizeLabel:SetText("Size")

    local sizeSlider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT",sizeLabel,"BOTTOMLEFT",0,-10)
    sizeSlider:SetWidth(100)
    sizeSlider:SetMinMaxValues(0.5,2)
    sizeSlider:SetValueStep(0.1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.Low:SetText("0.5")
    sizeSlider.High:SetText("2")

    local sizeSliderBG=sizeSlider:CreateTexture(nil,"BACKGROUND")
    sizeSliderBG:SetPoint("CENTER")
    sizeSliderBG:SetSize(100,10)
    sizeSliderBG:SetColorTexture(0.2,0.2,0.2,0.8)
    sizeSliderBG:SetDrawLayer("BACKGROUND",-1)

    local sizeValue=parent:CreateFontString(nil,"OVERLAY")
    sizeValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    sizeValue:SetPoint("TOP",sizeSlider,"BOTTOM",0,-5)

    local alphaLabel=parent:CreateFontString(nil,"OVERLAY")
    alphaLabel:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    alphaLabel:SetPoint("LEFT",sizeLabel,"RIGHT",100,0)
    alphaLabel:SetText("Alpha")

    local alphaSlider=CreateFrame("Slider",nil,parent,"OptionsSliderTemplate")
    alphaSlider:SetPoint("TOPLEFT",alphaLabel,"BOTTOMLEFT",0,-10)
    alphaSlider:SetWidth(100)
    alphaSlider:SetMinMaxValues(0.1,1)
    alphaSlider:SetValueStep(0.1)
    alphaSlider:SetObeyStepOnDrag(true)
    alphaSlider.Low:SetText("0")
    alphaSlider.High:SetText("1")

    local alphaSliderBG=alphaSlider:CreateTexture(nil,"BACKGROUND")
    alphaSliderBG:SetPoint("CENTER")
    alphaSliderBG:SetSize(100,10)
    alphaSliderBG:SetColorTexture(0.2,0.2,0.2,0.8)
    alphaSliderBG:SetDrawLayer("BACKGROUND",-1)

    local alphaValue=parent:CreateFontString(nil,"OVERLAY")
    alphaValue:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
    alphaValue:SetPoint("TOP",alphaSlider,"BOTTOM",0,-5)

    SetupSliderText(sizeSlider,"0.5","2.0")
    SetupSliderText(alphaSlider,"0","1")
    SetupSliderThump(sizeSlider,10,{0.8,0.6,0,1})
    SetupSliderThump(alphaSlider,10,{0.8,0.6,0,1})

    local unlock=EtherPanelButton(parent,60,25,"Unlock","TOPLEFT",sizeSlider,"BOTTOMLEFT",0,-50)
    unlock:SetScript("OnClick",function()
        if not Ether.Anchor.raid.tex:IsShown() then
            Ether.ShowHideSettings(true)
        else
            Ether.ShowHideSettings(false)
        end
    end)

    local dropdowns,frameOptions={},{}
    local fontOptions,barOptions,bgOptions={},{},{}
    local function UpdateValueLabels()
        local SELECTED=DB[111][4]
        if not SELECTED or not DB[21] or not DB[21][SELECTED] then
            sizeValue:SetText("")
            alphaValue:SetText("")
            return
        end
        local pos=DB[21][SELECTED]
        sizeValue:SetText(string_format("%.1f",pos[8] or 1))
        alphaValue:SetText(string_format("%.1f",pos[9] or 1))
    end

    local function UpdateSliders()
        local SELECTED=DB[111][4]
        if not SELECTED or not DB[21][SELECTED] then
            sizeSlider:Disable()
            alphaSlider:Disable()
            UpdateValueLabels()
            return
        end

        sizeSlider:Enable()
        alphaSlider:Enable()
        local pos=DB[21][SELECTED]
        if math.abs((sizeSlider:GetValue() or 1)-(pos[8] or 1))>0.001 then
            sizeSlider:SetValue(pos[8] or 1)
        end
        if math.abs((alphaSlider:GetValue() or 1)-(pos[9] or 1))>0.001 then
            alphaSlider:SetValue(pos[9] or 1)
        end
        UpdateValueLabels()
    end
    local preview=CreateHeaderPreview(parent,Ether.playerName,3,55)
    preview:SetPoint("TOP",20,-200)
    preview:SetFrameLevel(preview.healthBar:GetFrameLevel()+1)
    Ether:SetupPowerBar(preview,"player")
    preview:Hide()
    preview.healthBar:Hide()
    preview.powerBar:Hide()
    for frameID,frameData in pairs(K) do
        table.insert(frameOptions,{
            text=frameData,
            func=function()
                DB[111][4]=frameID
                UpdateSliders()
                dropdowns.frame.text:SetText(K[frameID])
                if DB[111][4]~=338 then
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER",preview.healthBar,"CENTER",0,3)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName,10))
                    preview.name:Show()
                    preview.healthBar:SetSize(120,50)
                    preview:SetBackdrop({
                        bgFile=Ether.DB[811][2],
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                    preview:SetSize(120,50)
                    preview.powerBar:SetSize(120,10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Show()
                else
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER",preview.healthBar,"CENTER",0,-5)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName,3))
                    preview.name:Show()
                    preview.healthBar:SetSize(55,55)
                    preview:SetBackdrop({
                        bgFile=Ether.DB[811][2],
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                    preview:SetSize(55,55)
                    preview.powerBar:SetSize(55,10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Hide()
                end
            end
        })
    end

    dropdowns.frame=CreateEtherDropdown(parent,160,"Select Frame",frameOptions)
    dropdowns.frame:SetPoint("TOPLEFT")

    sizeSlider:SetScript("OnValueChanged",function(self,value)
        local frame=DB[111][4]
        if DB[21][frame] then
            DB[21][frame][8]=self:GetValue()
            Ether:ApplyFramePosition(F[frame],frame)
            UpdateValueLabels()
        end
    end)

    alphaSlider:SetScript("OnValueChanged",function(self,value)
        local frame=DB[111][4]
        if DB[21][frame] then
            DB[21][frame][9]=self:GetValue()
            Ether:ApplyFramePosition(F[frame],frame)
            UpdateValueLabels()
        end
    end)

    UpdateSliders()

    if not LibStub or not LibStub("LibSharedMedia-3.0",true) then return end
    local LSM=LibStub("LibSharedMedia-3.0")
    for frameID,frameData in pairs(K) do
        table.insert(frameOptions,{
            text=frameData,
            func=function()
                DB[111][4]=frameID
                UpdateSliders()
                dropdowns.frame.text:SetText(K[frameID])
                if DB[111][4]~=338 then
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER",preview.healthBar,"CENTER",0,3)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName,10))
                    preview.name:Show()
                    preview.healthBar:SetSize(120,50)
                    preview:SetBackdrop({
                        bgFile=Ether.DB[811][2],
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                    preview:SetSize(120,50)
                    preview.powerBar:SetSize(120,10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Show()
                else
                    preview.name:Hide()
                    preview.name:ClearAllPoints()
                    preview.name:SetPoint("CENTER",preview.healthBar,"CENTER",0,-5)
                    preview.name:SetText(Ether:ShortenName(Ether.playerName,3))
                    preview.name:Show()
                    preview.healthBar:SetSize(55,55)
                    preview:SetBackdrop({
                        bgFile=Ether.DB[811][2],
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                    preview:SetSize(55,55)
                    preview.powerBar:SetSize(55,10)
                    preview:Show()
                    preview.healthBar:Show()
                    preview.powerBar:Hide()
                end
            end
        })
    end

    local mediaFonts=LSM:HashTable("font")
    for fontName,fontPath in pairs(mediaFonts) do
        table.insert(fontOptions,{
            text=fontName,
            func=function()
                dropdowns.font.text:SetText(fontName)
                DB[811][1]=fontPath
                if preview.name then
                    preview.name:SetFont(fontPath,13,"OUTLINE")
                end
                for _,button in pairs(Ether.unitButtons.raid) do
                    if button and button.name then
                        button.name:SetFont(fontPath,13,"OUTLINE")
                    end
                end
                for _,button in pairs(Ether.unitButtons.solo) do
                    if button and button.name then
                        button.name:SetFont(fontPath,13,"OUTLINE")
                    end
                end
            end})
    end
    local Indicator=EtherFrame.Frames["INDICATORS"]
    dropdowns.font=CreateEtherDropdown(parent,200,"Select Font",fontOptions,true)
    dropdowns.font:SetPoint("TOPRIGHT",0,0)
    local mediaBars=LSM:HashTable("statusbar")
    for barName,barPath in pairs(mediaBars) do
        table.insert(barOptions,{
            text=barName,
            func=function(self)
                dropdowns.bar.text:SetText(barName)
                DB[811][3]=barPath
                if preview.healthBar then
                    preview.healthBar:SetStatusBarTexture(barPath)
                end
                if Ether.UIPanel.Frames["EDITOR"].preview.healthBar then
                    Ether.UIPanel.Frames["EDITOR"].preview.healthBar:SetStatusBarTexture(barPath)
                end
                if Indicator.preview.healthBar then
                    Indicator.preview.healthBar:SetStatusBarTexture(barPath)
                end
                for _,button in pairs(Ether.unitButtons.raid) do
                    if button and button.healthBar then
                        button.healthBar:SetStatusBarTexture(barPath)
                    end
                end
                for _,button in pairs(Ether.unitButtons.solo) do
                    if button and button.healthBar then
                        button.healthBar:SetStatusBarTexture(barPath)
                    end
                end
            end})
    end

    dropdowns.bar=CreateEtherDropdown(parent,200,"Select Statusbar",barOptions,true)
    dropdowns.bar:SetPoint("TOP",dropdowns.font,"BOTTOM")
    local bgMedia=LSM:HashTable("background")
    for bgName,bgPath in pairs(bgMedia) do
        table.insert(bgOptions,{
            text=bgName,
            func=function(self)
                dropdowns.bg.text:SetText(bgName)
                DB[811][2]=bgPath
                if preview then
                    preview:SetBackdrop({
                        bgFile=bgPath,
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                end
                if Ether.UIPanel.Frames["EDITOR"].preview then
                    Ether.UIPanel.Frames["EDITOR"].preview:SetBackdrop({
                        bgFile=bgPath,
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                end
                if Indicator.preview then
                    Indicator.preview:SetBackdrop({
                        bgFile=bgPath,
                        insets={left=-2,right=-2,top=-2,bottom=-2}
                    })
                end
                for _,button in pairs(Ether.unitButtons.solo) do
                    if button then
                        button:SetBackdrop({
                            bgFile=bgPath,
                            insets={left=-2,right=-2,top=-2,bottom=-2}
                        })
                    end
                end
                for _,button in pairs(Ether.unitButtons.raid) do
                    if button then
                        if button then
                            button:SetBackdrop({
                                bgFile=bgPath,
                                insets={left=-2,right=-2,top=-2,bottom=-2}
                            })
                        end
                    end
                end
            end})
    end
    dropdowns.bg=CreateEtherDropdown(parent,200,"Select Background",bgOptions,true)
    dropdowns.bg:SetPoint("TOP",dropdowns.bar,"BOTTOM")
end

function Ether:CreateEditSection(EtherFrame)
    local parent=EtherFrame["CONTENT"]["CHILDREN"]["Edit"]
    if parent.Created then return end
    parent.Created=true

    local dropdown=CreateFrame("Frame",nil,parent,"UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT",parent,"TOPLEFT",0,-5)
    UIDropDownMenu_SetWidth(dropdown,130)

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
    local function RefreshDropdown()
        UIDropDownMenu_Initialize(dropdown,function(self,level)
            local info=UIDropDownMenu_CreateInfo()
            for _,profileName in ipairs(Ether:GetProfileList()) do
                info.text=profileName
                info.value=profileName
                info.func=function(self)
                    local success,msg=Ether:SwitchProfile(self.value)
                    if success then
                        UIDropDownMenu_SetSelectedValue(dropdown,self.value)
                        UIDropDownMenu_SetText(dropdown,self.value)
                        Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                    else
                        Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                    end
                end
                info.checked=(profileName==Ether:GetCurrentProfileString())
                UIDropDownMenu_AddButton(info,level)
            end
        end)
        UIDropDownMenu_SetSelectedValue(dropdown,Ether:GetCurrentProfileString())
        UIDropDownMenu_SetText(dropdown,Ether:GetCurrentProfileString())
    end
    RefreshDropdown()

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
                    RefreshDropdown()
                    Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                else
                    Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                end
            else
                Ether:EtherInfo("|cffcc66ffEther|r Enter name")
            end
            inputDialog:Hide()
        end)
    end)
    local copyButton=EtherPanelButton(parent,60,25,"Copy","LEFT",createButton,"RIGHT",5,0)
    copyButton:SetScript("OnClick",function()
        inputTitle:SetText("Copy profile")
        inputBox:SetText(Ether:GetCurrentProfileString().." - Copy")
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick",function()
            local name=inputBox:GetText()
            if name and name~="" then
                local success,msg=Ether:CopyProfile(Ether:GetCurrentProfileString(),name)
                if success then
                    RefreshDropdown()
                    Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                else
                    Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                end
            end
            inputDialog:Hide()
        end)
    end)
    local renameButton=EtherPanelButton(parent,60,25,"Rename","TOPLEFT",createButton,"BOTTOMLEFT",0,-20)
    renameButton:SetScript("OnClick",function()
        inputTitle:SetText("Rename profile")
        inputBox:SetText(Ether:GetCurrentProfileString())
        inputDialog:Show()
        inputBox:SetFocus()
        okButton:SetScript("OnClick",function()
            local newName=inputBox:GetText()
            if newName and newName~="" then
                local success,msg=Ether:RenameProfile(Ether:GetCurrentProfileString(),newName)
                if success then
                    RefreshDropdown()
                    Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                else
                    Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                end
            end
            inputDialog:Hide()
        end)
    end)

    local deleteButton=EtherPanelButton(parent,60,25,"Delete","LEFT",renameButton,"RIGHT",5,0)
    deleteButton:SetScript("OnClick",function()
        local profileToDelete=Ether:GetCurrentProfileString()
        local profiles=Ether:GetProfileList()
        if #profiles<=1 then
            Ether:EtherInfo("|cffcc66ffEther|r Cannot delete the only profile")
            return
        end
        if not Ether.popupBox then return end
        if Ether.popupCallback:GetScript("OnClick") then
            Ether.popupCallback:SetScript("OnClick",nil)
        end
        if not Ether.popupBox:IsShown() then
            Ether.popupBox:SetShown(true)
            Ether.UIPanel.Frames["MAIN"]:SetShown(false)
        end
        Ether.popupBox.font:SetText("Delete profile |cffcc66ff"..profileToDelete.."|r ?")
        Ether.popupCallback:SetScript("OnClick",function()
            local success,msg=Ether:DeleteProfile(profileToDelete)
            if success then
                RefreshDropdown()
                Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                if parent.RefreshConfig then
                    parent.RefreshConfig()
                end
                Ether.popupBox:SetShown(false)
                Ether.UIPanel.Frames["MAIN"]:SetShown(true)
            else
                Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                Ether.popupBox:SetShown(false)
                Ether.UIPanel.Frames["MAIN"]:SetShown(true)
            end
        end)
    end)
    local resetButton=EtherPanelButton(parent,60,25,"Reset","TOPLEFT",renameButton,"BOTTOMLEFT",0,-80)
    resetButton:SetScript("OnClick",function()
        if not Ether.popupBox then return end
        local profileToRest=Ether:GetCurrentProfileString()
        if Ether.popupCallback:GetScript("OnClick") then
            Ether.popupCallback:SetScript("OnClick",nil)
        end
        if not Ether.popupBox:IsShown() then
            Ether.popupBox:SetShown(true)
            Ether.UIPanel.Frames["MAIN"]:SetShown(false)
        end
        Ether.popupBox.font:SetText("Reset profile |cffcc66ff"..profileToRest.."|r ?")
        Ether.popupCallback:SetScript("OnClick",function()
            local success,msg=Ether:ResetProfile()
            if success then
                Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                RefreshDropdown()
                if parent.RefreshConfig then
                    parent.RefreshConfig()
                end
                Ether.popupBox:SetShown(false)
                Ether.UIPanel.Frames["MAIN"]:SetShown(true)
            else
                Ether:EtherInfo("|cffcc66ffEther|r "..msg)
                Ether.popupBox:SetShown(false)
                Ether.UIPanel.Frames["MAIN"]:SetShown(true)
            end
        end)
    end)
    local transfer=CreateFrame("Frame",nil,parent)
    transfer:SetPoint("TOP",parent,"TOP",50,-5)
    transfer:SetSize(250,200)
    local importBox

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
    importBox=CreateFrame("EditBox",nil,importBackdrop)
    importBox:SetPoint("TOPLEFT",importBackdrop,"TOPLEFT",8,-8)
    importBox:SetPoint("BOTTOMRIGHT",importBackdrop,"BOTTOMRIGHT",-8,8)
    importBox:SetMultiLine(true)
    importBox:SetAutoFocus(false)
    importBox:SetClipsChildren(true)
    importBox:SetFont(unpack(Ether.media.expressway),9,"OUTLINE")
    importBox:SetText("Paste export data here...")
    importBox:SetTextColor(0.7,0.7,0.7)
    importBox:SetScript("OnMouseWheel",function(self,delta)
        local current=self:GetText()
        if delta>0 then
            self:SetCursorPosition(0)
        else
            self:SetCursorPosition(#current)
        end
    end)

    importBox:SetScript("OnEditFocusGained",function(self)
        if self:GetText()=="Paste export data here..." then
            self:SetText("")
            self:SetTextColor(1,1,1)
        end
        self:HighlightText()
    end)

    importBox:SetScript("OnEditFocusLost",function(self)
        if self:GetText()=="" then
            self:SetText("Paste export data here...")
            self:SetTextColor(0.7,0.7,0.7)
        end
    end)

    importBox:SetScript("OnEscapePressed",function(self)
        self:ClearFocus()
    end)
    local importBtn=EtherPanelButton(transfer,60,25,"Import","BOTTOMLEFT",importBox,"TOPLEFT",0,20)
    importBtn.text:SetPoint("LEFT")
    local exportBtn=EtherPanelButton(transfer,60,25,"Export","LEFT",importBtn,"RIGHT",20,0)
    exportBtn:SetScript("OnClick",function()
        local encoded=Ether:ExportProfileToClipboard()
        if encoded then
            Ether:ShowExportPopup(encoded)
        end
    end)
    importBtn:SetScript("OnClick",function()
        local data=importBox:GetText()
        if data and data~="" and data~="Paste export data here..." then
            local success,msg=Ether:ImportProfile(data)
            if success then
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
    parent.Refresh=RefreshDropdown
    parent.RefreshConfig=function()
    end
end

function Ether.CleanUpButtons()
    Ether:CreateCustomSection(Ether.UIPanel)
    Ether:CreatePositionSection(Ether.UIPanel)
    local editor=Ether.UIPanel.Frames["EDITOR"]
    local Indicator=Ether.UIPanel.Frames["INDICATORS"]
    Ether.WrapSettingsColor({0.80,0.40,1.00,1})
    Indicator.icon:Hide()
    Indicator.text:Hide()
    Indicator.sizeSlider:Hide()
    Indicator.sizeSlider:Disable()
    Indicator.YSlider:Hide()
    Indicator.YSlider:Disable()
    Indicator.offsetXSlider:Hide()
    Indicator.offsetXSlider:Disable()
    Indicator.offsetXLabel:Hide()
    Indicator.sizeLabel:Hide()
    Indicator.offsetYLabel:Hide()
    Indicator.offsetXValue:Hide()
    Indicator.offsetYValue:Hide()
    Indicator.sizeValue:Hide()
    Indicator.preview:Hide()
    editor:Hide()
    Indicator.templateDropdown.text:SetText("Select Indicator")
    for _,btn in pairs(editor.posButtons) do
        btn:Disable()
    end
    for _,btn in pairs(Indicator.posButtons) do
        btn:Disable()
    end
end