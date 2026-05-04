local D,F,_,C=unpack(select(2,...))
local ipairs,pairs,sformat,twipe=ipairs,pairs,string.format,table.wipe
local function SelectAura(editor,spellId)
    if not spellId then return end
    C.Spell=spellId
    F:UpdateAuraList()
    F:UpdateEditor(editor)
end
local function AddAura(editor)
    local newId=1
    while D.DB["CUSTOM"][newId] do
        newId=newId+1
    end
    D.DB["CUSTOM"][newId]=F:AuraTemplate(newId)
    SelectAura(editor,newId)
end
local function OnAuraSelect(self,_,data)
    local editor=C.ChildFrames[7]
    if not editor:IsShown() then
        editor:Show()
    end
    F:AddTemplateAuras(data)
    self.text:SetText(data)
end
local function UpdateAuraStatus(self,spellId)
    if not spellId then return end
    local c=D.DB["CUSTOM"][spellId][10]
    local r,g,b=0,1,0
    self.isDebuff.bg:SetColorTexture(c and r or 1,c and g or 0,c and b or 0,0.4)
end
local function UpdateStatus(self,index)
    if not index then return end
    local c=F:BinaryCondition(D.DB["CONFIG"][index])
    local r,g,b=0,1,0
    self.bg:SetColorTexture(c and r or 1,c and g or 0,c and b or 0,0.4)
    if not c and index==14 then
        F:StopAllBlinks()
    end
    if not c and index==15 then
        F:HideClassDispel()
    end
    if not c and index==16 then
        F:HideBorderDispel()
    end
end
function F:Aura(self,status)
    if self.created or type(status)~="boolean" then return end
    self.created=status
    local auraList={}
    for v in pairs(D.PredefinedAuras) do
        auraList[#auraList+1]=v
    end
    local dropdown=F:CreateEtherDropdown(self,140,"Predefined Auras",auraList,OnAuraSelect)
    dropdown:SetPoint("TOPLEFT",5,-5)
    local scrollFrame=CreateFrame("ScrollFrame",nil,self,"ScrollFrameTemplate")
    self.scrollFrame=scrollFrame
    scrollFrame:SetPoint("TOPLEFT",0,-10)
    scrollFrame:SetPoint("BOTTOMRIGHT",-25,35)
    local scrollChild=CreateFrame("Frame",nil,scrollFrame)
    scrollChild:SetSize(190,1)
    scrollFrame:SetScrollChild(scrollChild)
    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:Hide()
    end
    local new=F:EtherPanelButton(self,50,25,"New","TOP",self,"TOP",0,-5,0,1,0)
    new:SetScript("OnClick",function()
        if not self:IsShown() then
            self:Show()
        end
        AddAura(self)
    end)
    local isBlink=F:EtherPanelButton(self,50,25,"Blink","LEFT",new,"RIGHT",20,0)
    self.isBlink=isBlink
    isBlink:SetScript("OnClick",function()
        D.DB["CONFIG"][14]=F:ToggleBinary(D.DB["CONFIG"][14])
        UpdateStatus(isBlink,14)
    end)
    local isClass=F:EtherPanelButton(self,50,25,"Dispel","LEFT",isBlink,"RIGHT",5,0)
    self.isClass=isClass
    isClass:SetScript("OnClick",function()
        D.DB["CONFIG"][15]=F:ToggleBinary(D.DB["CONFIG"][15])
        UpdateStatus(isClass,15)
    end)
    local isBorder=F:EtherPanelButton(self,50,25,"Border","LEFT",isClass,"RIGHT",5,0)
    self.isBorder=isBorder
    isBorder:SetScript("OnClick",function()
        D.DB["CONFIG"][16]=F:ToggleBinary(D.DB["CONFIG"][16])
        UpdateStatus(isBorder,16)
    end)
    local clear=F:EtherPanelButton(self,50,25,"Wipe","TOPRIGHT",self,"TOPRIGHT",0,-5,1,0,0)
    clear:SetScript("OnClick",function()
        F:PopupBoxSetup()
        F:UpdateAuraList()
        F:UpdateEditor(self)
        if D:TableSize(D.DB["CUSTOM"])==0 then
            F:EtherInfo("No auras available to delete")
            return
        end
        C.PopupBox.font:SetText("Clear all auras?")
        C.PopupCallback:SetScript("OnClick",function()
            twipe(D.DB["CUSTOM"])
            C.Spell=nil
            F:UpdateAuraList()
            F:UpdateEditor(self)
            C:EtherInfo("|cff00ccffAuras|r: Custom auras cleared")
            dropdown.menu:Hide()
            C.PopupBox:SetShown(false)
            C.MainFrame:SetShown(true)
        end)
    end)
    self.scrollChild=scrollChild
    local name=F:LineInput(self,100,-20)
    self.name=name
    name:SetPoint("TOP",40,-70)
    name:SetScript("OnEnterPressed",function()
        if type(C.Spell)~=nil then
            D.DB["CUSTOM"][C.Spell].name=name:GetText()
            F:UpdateAuraList()
        end
        name:ClearFocus()
    end)
    name.v=self:CreateFontString(nil,"OVERLAY")
    name.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    name.v:SetPoint("BOTTOMLEFT",name,"TOPLEFT",0,2)
    name.v:SetText("Name")
    local spell=F:LineInput(self,100,20)
    self.spell=spell
    spell:SetPoint("LEFT",name,"RIGHT",15,0)
    spell:SetNumeric(true)
    spell:SetScript("OnEnterPressed",function()
        local newId=tonumber(spell:GetText())
        if F.SpellId and newId and newId>0 and newId~=C.Spell then
            local data=D.DB["CUSTOM"][C.Spell]
            D.DB["CUSTOM"][C.Spell]=nil
            D.DB["CUSTOM"][newId]=data
            C.Spell=newId
            F:UpdateAuraList()
            F:UpdateEditor(self)
        end
        spell:ClearFocus()
    end)
    spell.v=self:CreateFontString(nil,"OVERLAY")
    spell.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    spell.v:SetPoint("BOTTOMLEFT",spell,"TOPLEFT",0,2)
    spell.v:SetText("Spell ID")
    local x=F:CreateSlider(name,"X-Off","0 px","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(_,value)
                if not C.Spell then return end
                if type(C.Spell)~=nil then
                    self.x:SetValue(D.DB["CUSTOM"][C.Spell][7])
                    D.DB["CUSTOM"][C.Spell][7]=value
                    self.x.v:SetText(sformat("%.0f",value))
                    F:UpdatePreview(D.DB["CUSTOM"],self,C.Spell)
                end
            end)
    self.x=x
    local y=F:CreateSlider(spell,"Y-Off","0 px","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(_,value)
                if not C.Spell then return end
                if type(C.Spell)~=nil then
                    self.y:SetValue(D.DB["CUSTOM"][C.Spell][8])
                    D.DB["CUSTOM"][C.Spell][8]=value
                    self.y.v:SetText(sformat("%.0f",value))
                    F:UpdatePreview(D.DB["CUSTOM"],self,C.Spell)
                end
            end)
    self.y=y
    local s=F:CreateSlider(x,"Scale","6 px","4","20",1,"TOPLEFT","BOTTOMLEFT",0,-25,
            function(_,value)
                if not C.Spell then return end
                if type(C.Spell)~=nil then
                    D.DB["CUSTOM"][C.Spell][9]=value
                    self.s:SetValue(D.DB["CUSTOM"][C.Spell][9])
                    self.s.v:SetText(sformat("%.1f px",value))
                    F:UpdatePreview(D.DB["CUSTOM"],self,C.Spell)
                end
            end)
    self.s=s
    local cube,preview=F:CreatePreview(self,"BOTTOMRIGHT")
    self.cube=cube
    self.preview=preview
    for _,btn in pairs(cube) do
        btn:SetScript("OnClick",function()
            if C.Spell then
                D.DB["CUSTOM"][C.Spell][6]=btn.position
                F:UpdateEditor(self)
                for _,otherBtn in pairs(cube) do
                    otherBtn:GetScript("OnLeave")(otherBtn)
                end
            end
        end)
        btn:SetScript("OnEnter",function()
            btn.bg:SetColorTexture(0.3,0.3,0.3,0.9)
        end)
        btn:SetScript("OnLeave",function()
            local data=C.Spell and D.DB["CUSTOM"][C.Spell]
            if data and data[6]==btn.position then
                btn.bg:SetColorTexture(0.8,0.6,0,0.4)
            else
                btn.bg:SetColorTexture(0.2,0.2,0.2,0.8)
            end
        end)
        btn:GetScript("OnLeave")(btn)
    end
    local color=CreateFrame("Button",nil,self)
    self.color=color
    color:SetSize(60,15)
    color:SetPoint("TOPLEFT",s,"BOTTOMLEFT",0,-20)
    color.bg=color:CreateTexture(nil,"BACKGROUND")
    color.bg:SetAllPoints()
    color.bg:SetColorTexture(1,1,0,1)
    color:SetScript("OnClick",function()
        F:ColorSelect(self)
    end)
    local isDebuff=F:EtherPanelButton(self,50,25,"Debuff","LEFT",color,"RIGHT",5,0)
    self.isDebuff=isDebuff
    isDebuff:SetScript("OnClick",function()
        if type(C.Spell)==nil then return end
        if D.DB["CUSTOM"] and D.DB["CUSTOM"][C.Spell] then
            D.DB["CUSTOM"][C.Spell][10]=not D.DB["CUSTOM"][C.Spell][10]
            UpdateAuraStatus(self,C.Spell)
        end
    end)
    F:UpdateAuraList()
    F:UpdateEditor(self)
    UpdateStatus(isBlink,14)
    UpdateStatus(isClass,15)
    UpdateStatus(isBorder,16)
end
function F:UpdateAuraList()
    if not C.ChildFrames[7].created then
        F:Aura(C.ChildFrames[7],true)
    end
    local editor=C.ChildFrames[7]
    for _,btn in ipairs(C.AuraList) do
        btn:Hide()
        btn:SetParent(nil)
    end
    local yOffset=-20
    local index=1
    for spellId,data in pairs(D.DB["CUSTOM"]) do
        local btn=CreateFrame("Button",nil,editor.scrollChild)
        btn:SetSize(190,18)
        if index == 1 then
            btn:SetPoint("TOPLEFT",5,-20)
        else
             yOffset=yOffset-20
             btn:SetPoint("TOPLEFT",5, yOffset)
        end
        btn.bg=btn:CreateTexture(nil,"BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.3,0.3,0.3,0)
        btn:SetScript("OnEnter",function(self)
            self.bg:SetColorTexture(0.3,0.3,0.3,0.8)
        end)
        btn:SetScript("OnLeave",function(self)
            if C.Spell==spellId then
                self.bg:SetColorTexture(0.3,0.3,0.3,0.8)
            else
                self.bg:SetColorTexture(0.3,0.3,0.3,0)
            end
        end)
        btn:SetScript("OnClick",function()
            if not editor:IsShown() then
                editor:Show()
            end
            SelectAura(editor,spellId)
            UpdateAuraStatus(editor,spellId)
        end)
        btn.name=btn:CreateFontString(nil,"OVERLAY")
        btn.name:SetFontObject(C.EtherFont)
        btn.name:SetPoint("TOPLEFT",2,-5)
        btn.name:SetText(data[1] or "Unknown")
        btn.spell=btn:CreateFontString(nil,"OVERLAY")
        btn.spell:SetFontObject(C.EtherFont)
        btn.spell:SetPoint("LEFT",btn.name,"RIGHT")
        btn.spell:SetText(spellId)
        if data[2] then
            btn.name:SetTextColor(data[2],data[3],data[4],data[5])
            btn.spell:SetTextColor(data[2],data[3],data[4],data[5])
        end
        btn.delete=CreateFrame("Button",nil,btn)
        btn.delete:SetSize(18,18)
        btn.delete:SetPoint("RIGHT")
        btn.delete:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        btn.delete:SetScript("OnClick",function(self)
            F:PopupBoxSetup()
            C.PopupBox.font:SetText("Delete Aura |cffcc66ff"..tostring(spellId).."|r ?")
            C.PopupCallback:SetScript("OnClick",function()
                C.MainFrame:SetShown(true)
                C.PopupBox:SetShown(false)
                D.DB["CUSTOM"][spellId]=nil
                if C.Spell==spellId then
                    C.Spell=nil
                end
                F:UpdateAuraList()
                F:UpdateEditor(editor)
            end)
            self:GetParent():GetScript("OnLeave")(self:GetParent())
        end)
        btn.spell=spellId
        C.AuraList[#C.AuraList+1]=btn
        index=index+1
    end
    UpdateStatus(editor.isBlink,14)
    UpdateStatus(editor.isClass,15)
    UpdateStatus(editor.isBorder,16)
end
function F:UpdateEditor(editor)
    if not editor then return end
    if not D.DB["CUSTOM"][C.Spell] then
        editor.name:SetText("")
        editor.name:Disable()
        editor.spell:SetText("")
        editor.spell:Disable()
        editor.color:Disable()
        editor.s:Disable()
        editor.x:Disable()
        editor.y:Disable()
        for _,btn in pairs(editor.cube) do
            btn:Disable()
        end
        return
    end
    local data=D.DB["CUSTOM"][C.Spell]
    editor.name:SetText(data[1] or "")
    editor.name:Enable()
    editor.spell:SetText(tostring(C.Spell))
    editor.spell:Enable()
    editor.color.bg:SetColorTexture(data[2],data[3],data[4],data[5])
    editor.color:Enable()
    editor.x:Enable()
    editor.x:Show()
    editor.y:Enable()
    editor.y:Show()
    editor.s:SetValue(data[9])
    editor.s:Enable()
    editor.s:Show()
    editor.s.v:SetText(sformat("%.1f px",data[9]))
    F:UpdateCube(editor.cube,data,6)
    editor.x:SetValue(data[7])
    editor.x.v:SetText(sformat("%.0f px",data[7]))
    editor.y:SetValue(data[8])
    editor.y.v:SetText(sformat("%.0f px",data[8]))
    F:UpdatePreview(D.DB["CUSTOM"],editor,C.Spell)
end
function F:AddTemplateAuras(templateName)
    if not D.PredefinedAuras or not D.PredefinedAuras[templateName] then return end
    local a,s=0,0
    local DB=D.DB["CUSTOM"]
    for i,v in pairs(D.PredefinedAuras[templateName]) do
        if not DB[i] then
            DB[i]=D:CopyTable(v)
            a=a+1
        else
            s=s+1
        end
    end
    F:UpdateAuraList()
    local msg=sformat("|cff00ccffAuras|r: Template '%s' loaded. ",templateName)
    if a>0 then
        msg=msg..sformat("|cff00ff00+%d new auras|r",a)
    end
    if s>0 then
        msg=msg..sformat(" (%d already existed)",s)
    end
    C:EtherInfo(msg)
    C.Spell=nil
    F:UpdateEditor(C.ChildFrames[7])
end