local D,F,_,C,_=unpack(select(2,...))
local tinsert=table.insert
local ipairs,pairs=ipairs,pairs
local twipe=table.wipe
local sformat=string.format

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

local function OnAuraSelect(self,data)
    local editor=C.EditorFrame
    if not editor:IsShown() then
        editor:Show()
    end
    F:AddTemplateAuras(data.value)
    self.text:SetText(data.value)
end

function F:Aura(index)
    local parent=C.ChildFrames[index]
    if parent.Created then return end
    parent.Created=true
    local editor=C.EditorFrame
    local auras=C.AuraFrame
    local auraList={}
    for name in pairs(D.PredefinedAuras) do
        tinsert(auraList,{text=name,value=name})
    end
    local dropdown=F:CreateEtherDropdown(parent,160,"Predefined Auras",auraList,OnAuraSelect)
    dropdown:SetPoint("TOPLEFT",5,-5)
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
    local addBtn=F:EtherPanelButton(auras,50,25,"New","TOP",parent,"TOP")
    addBtn:SetScript("OnClick",function()
        if not editor:IsShown() then
            editor:Show()
        end
        AddAura(editor)
    end)
    addBtn.v:SetPoint("LEFT")

    local confirm=F:EtherPanelButton(auras,50,25,"Confirm","LEFT",addBtn,"RIGHT",10,0)
    confirm:SetScript("OnClick",function()
        if type(C.Spell)==nil then return end
        if D.DB["CUSTOM"] and D.DB["CUSTOM"][C.Spell] then
            F:UpdateAuraPos()
        end
    end)
    local isDebuff=F:EtherPanelButton(editor,50,25,"Debuff","LEFT",confirm,"RIGHT",30,0)
    editor.isDebuff=isDebuff
    isDebuff:SetScript("OnClick",function()
        if type(C.Spell)==nil then return end
        if D.DB["CUSTOM"] and D.DB["CUSTOM"][C.Spell] then
            D.DB["CUSTOM"][C.Spell][10]=not D.DB["CUSTOM"][C.Spell][10]
            F:UpdateAuraStatus(C.Spell)
        end
    end)
    local clear=F:EtherPanelButton(auras,50,25,"Wipe","TOPRIGHT",parent,"TOPRIGHT")
    clear:SetScript("OnClick",function()
        F:PopupBoxSetup()
        F:UpdateAuraList()
        F:UpdateEditor(editor)
        if D:TableSize(D.DB["CUSTOM"])==0 then
            F:EtherInfo("No auras available to delete")
            return
        end
        C.PopupBox.font:SetText("Clear all auras?")
        C.PopupCallback:SetScript("OnClick",function()
            twipe(D.DB["CUSTOM"])
            C.Spell=nil
            F:UpdateAuraList()
            F:UpdateEditor(editor)
            C:EtherInfo("|cff00ccffAuras|r: Custom auras cleared")
            dropdown.menu:Hide()
            C.PopupBox:SetShown(false)
            C.MainFrame:SetShown(true)
        end)
    end)
    auras.scrollChild=scrollChild

    local name=F:LineInput(parent,100,-20)
    editor.name=name
    name:SetPoint("TOP",40,-70)
    name:SetScript("OnEnterPressed",function()
        if type(C.Spell)~=nil then
            D.DB["CUSTOM"][C.Spell].name=name:GetText()
            F:UpdateAuraList()
        end
        name:ClearFocus()
    end)
    name.v=parent:CreateFontString(nil,"OVERLAY")
    name.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    name.v:SetPoint("BOTTOMLEFT",name,"TOPLEFT",0,2)
    name.v:SetText("Name")

    local spell=F:LineInput(parent,100,20)
    editor.spell=spell
    spell:SetPoint("LEFT",name,"RIGHT",15,0)
    spell:SetNumeric(true)
    spell:SetScript("OnEnterPressed",function(self)
        local newId=tonumber(self:GetText())
        if F.SpellId and newId and newId>0 and newId~=C.Spell then
            local data=D.DB["CUSTOM"][C.Spell]
            D.DB["CUSTOM"][C.Spell]=nil
            D.DB["CUSTOM"][newId]=data
            C.Spell=newId
            F:UpdateAuraList()
            F:UpdateEditor(editor)
        end
        self:ClearFocus()
    end)
    spell.v=editor:CreateFontString(nil,"OVERLAY")
    spell.v:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    spell.v:SetPoint("BOTTOMLEFT",spell,"TOPLEFT",0,2)
    spell.v:SetText("Spell ID")
    local x=F:CreateSlider(name,"X-Off","0 px","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(self,value)
                if not C.Spell then return end
                if type(C.Spell)~=nil then
                    self:SetValue(D.DB["CUSTOM"][C.Spell][7])
                    D.DB["CUSTOM"][C.Spell][7]=value
                    editor.x.v:SetText(sformat("%.0f",value))
                    F:UpdatePreview(editor)
                end
            end)
    editor.x=x
    local y=F:CreateSlider(spell,"Y-Off","0 px","-20","20",1,"TOPLEFT","BOTTOMLEFT",0,-20,
            function(self,value)
                if not C.Spell then return end
                if type(C.Spell)~=nil then
                    self:SetValue(D.DB["CUSTOM"][C.Spell][8])
                    D.DB["CUSTOM"][C.Spell][8]=value
                    editor.y.v:SetText(sformat("%.0f",value))
                    F:UpdatePreview(editor)
                end
            end)
    editor.y=y
    local s=F:CreateSlider(x,"Scale","6 px","4","20",1,"TOPLEFT","BOTTOMLEFT",0,-25,
            function(self,value)
                if not C.Spell then return end
                if type(C.Spell)~=nil then
                    D.DB["CUSTOM"][C.Spell][9]=value
                    self:SetValue(D.DB["CUSTOM"][C.Spell][9])
                    editor.s.v:SetText(sformat("%.1f px",value))
                    F:UpdatePreview(editor)
                end
            end)
    editor.s=s
    local cube,preview=F:CreatePreview(parent,"BOTTOMRIGHT")
    editor.cube=cube
    editor.preview=preview
    for _,btn in pairs(cube) do
        btn:SetScript("OnClick",function(self)
            if C.Spell then
                D.DB["CUSTOM"][C.Spell][6]=self.position
                F:UpdateEditor(editor)
                F:UpdatePreview(editor)
                for _,otherBtn in pairs(cube) do
                    otherBtn:GetScript("OnLeave")(otherBtn)
                end
            end
        end)
        btn:SetScript("OnEnter",function(self)
            self.bg:SetColorTexture(0.3,0.3,0.3,0.9)
        end)
        btn:SetScript("OnLeave",function(self)
            local data=C.Spell and D.DB["CUSTOM"][C.Spell]
            if data and data[6]==self.position then
                self.bg:SetColorTexture(0.8,0.6,0,0.4)
            else
                self.bg:SetColorTexture(0.2,0.2,0.2,0.8)
            end
        end)
        btn:GetScript("OnLeave")(btn)
    end
    editor.color=F:ColorSelect(editor,s)
    F:UpdateAuraList()
    F:UpdateEditor(editor)
end
function F:UpdateAuraStatus(spellId)
    if not spellId then return end
    local debuff=D.DB["CUSTOM"][spellId][10]
    local editor=C.EditorFrame
    if debuff then
        editor.isDebuff.bg:SetColorTexture(0.80,0.40,1.00,0.4)
    else
        editor.isDebuff.bg:SetColorTexture(0,0,0,0)
    end
end
function F:UpdateAuraList()
    local editor=C.EditorFrame
    local auras=C.AuraFrame
    if not C.ChildFrames[4].Created then
        F:Aura(4)
    end
    local DB=D.DB
    for _,btn in ipairs(C.AuraList) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(C.AuraList)
    local yOffset=0
    local index=1
    for spellId,data in pairs(DB["CUSTOM"]) do
        local btn=CreateFrame("Button",nil,auras.scrollChild)
        btn:SetSize(180,25)
        btn:SetPoint("TOPLEFT",1,yOffset)
        btn.bg=btn:CreateTexture(nil,"BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.1,0.1,0.1,0.6)
        btn:SetScript("OnEnter",function(self)
            self.bg:SetColorTexture(0.2,0.2,0.2,0.7)
        end)
        btn:SetScript("OnLeave",function(self)
            if C.Spell==spellId then
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
            F:UpdateAuraStatus(spellId)
        end)
        btn.name=btn:CreateFontString(nil,"OVERLAY")
        btn.name:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
        btn.name:SetPoint("TOPLEFT",2,-5)
        btn.name:SetText(data[1] or "Unknown")
        btn.spell=btn:CreateFontString(nil,"OVERLAY")
        btn.spell:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
        btn.spell:SetPoint("TOPLEFT",btn.name,"BOTTOMLEFT",0,-2)
        btn.spell:SetText("Spell ID: "..spellId)
        btn.spell:SetTextColor(0,0.8,1)

        btn.colorBox=btn:CreateTexture(nil,"OVERLAY")
        btn.colorBox:SetSize(10,10)
        btn.colorBox:SetPoint("RIGHT",-10,0)
        if data[2] then
            btn.colorBox:SetColorTexture(data[2],data[3],data[4],data[5])
        end
        btn.delete=CreateFrame("Button",nil,btn)
        btn.delete:SetSize(15,15)
        btn.delete:SetPoint("RIGHT",btn.colorBox,"LEFT",0,0)
        btn.delete:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        btn.delete:SetScript("OnClick",function(self)
            F:PopupBoxSetup()
            C.PopupBox.font:SetText("Delete Aura |cffcc66ff"..tostring(spellId).."|r ?")
            C.PopupCallback:SetScript("OnClick",function()
                C.MainFrame:SetShown(true)
                C.PopupBox:SetShown(false)
                DB["CUSTOM"][spellId]=nil
                if C.Spell==spellId then
                    C.Spell=nil
                end
                F:UpdateAuraList()
                F:UpdateEditor(editor)
            end)
            self:GetParent():GetScript("OnLeave")(self:GetParent())
        end)
        btn.spell=spellId
        tinsert(C.AuraList,btn)
        if C.Spell==spellId then
            btn.bg:SetColorTexture(0,0.8,1,0.8)
        end
        yOffset=yOffset-30
        index=index+1
    end
end
function F:UpdateEditor(editor)
    local DB=D.DB
    if not editor.nameInput then
        F:Aura(4)
    end
    if not DB["CUSTOM"][C.Spell] then
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
    local data=DB["CUSTOM"][C.Spell]
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
    for pos,btn in pairs(editor.cube) do
        if pos==data[6] then
            btn.bg:SetColorTexture(0.8,0.6,0,0.5)
            btn:Enable()
        else
            btn.bg:SetColorTexture(0.2,0.2,0.2,0.5)
            btn:Enable()
        end
    end
    editor.x:SetValue(data[7])
    editor.x.v:SetText(sformat("%.0f px",data[7]))
    editor.y:SetValue(data[8])
    editor.y.v:SetText(sformat("%.0f px",data[8]))
    F:UpdatePreview(editor)
end
function F:UpdatePreview(editor)
    if type(C.Spell)=="nil" then
        return
    end
    local data=D.DB["CUSTOM"][C.Spell]
    editor.preview.icon:SetSize(data[9],data[9])
    editor.preview.icon:SetColorTexture(data[2],data[3],data[4],data[5])
    editor.preview.icon:ClearAllPoints()
    local posMap={
        TOPLEFT={"TOPLEFT",data[7],data[8]},
        TOP={"TOP",data[7],data[8]},
        TOPRIGHT={"TOPRIGHT",data[7],data[8]},
        LEFT={"LEFT",data[7],-data[8]},
        CENTER={"CENTER",data[7],-data[8]},
        RIGHT={"RIGHT",data[7],-data[8]},
        BOTTOMLEFT={"BOTTOMLEFT",data[7],data[8]},
        BOTTOM={"BOTTOM",data[7],data[8]},
        BOTTOMRIGHT={"BOTTOMRIGHT",data[7],data[8]},
    }
    local pos=posMap[data[6]]
    if pos then
        editor.preview.icon:SetPoint(pos[1],editor.preview,pos[1],pos[2],pos[3])
    end
end
function F:AddTemplateAuras(templateName)
    local template=D.PredefinedAuras[templateName]
    if not template then
        return
    end

    local added=0
    local skipped=0
    local DB=D.DB["CUSTOM"]
    for spellID,auraData in pairs(template) do
        if not DB[spellID] then
            DB[spellID]=D:CopyTable(auraData)
            added=added+1
        else
            skipped=skipped+1
        end
    end
    F:UpdateAuraList()
    local msg=sformat("|cff00ccffAuras|r: Template '%s' loaded. ",templateName)
    if added>0 then
        msg=msg..sformat("|cff00ff00+%d new auras|r",added)
    end
    if skipped>0 then
        msg=msg..sformat(" (%d already existed)",skipped)
    end
    C:EtherInfo(msg)
    C.Spell=nil
    F:UpdateEditor(C.EditorFrame)
end