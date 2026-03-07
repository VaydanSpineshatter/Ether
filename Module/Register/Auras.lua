local _,Ether=...

local function SelectAura(editor,spellId)
    Ether.UIPanel.SpellId=spellId
    Ether.DB[1003][spellId][9]=true
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
end

function Ether:UpdateAuraStatus(spellId)
    if Ether.DB[1001][3]~=1 then return end
    if not spellId then return end
    local debuff=Ether.DB[1003][spellId][8]
    local editor=Ether.UIPanel.Frames["EDITOR"]
    if debuff then
        editor.isDebuff.bg:SetColorTexture(0.80,0.40,1.00,0.4)
    else
        editor.isDebuff.bg:SetColorTexture(0,0,0,0)
    end
end

function Ether:AddCustomAura(editor)
    local newId=1
    while Ether.DB[1003][newId] do
        newId=newId+1
    end
    Ether.DB[1003][newId]=Ether:AuraTemplate(newId)
    SelectAura(editor,newId)
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
            Ether:UpdateAuraStatus(spellId)
        end)

        btn.name=btn:CreateFontString(nil,"OVERLAY")
        btn.name:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
        btn.name:SetPoint("TOPLEFT",10,-8)
        btn.name:SetText(data[1] or "Unknown")

        btn.spellId=btn:CreateFontString(nil,"OVERLAY")
        btn.spellId:SetFont(unpack(Ether.media.expressway),10,"OUTLINE")
        btn.spellId:SetPoint("TOPLEFT",10,-23)
        btn.spellId:SetText("Spell ID: "..spellId)
        btn.spellId:SetTextColor(0,0.8,1)

        btn.colorBox=btn:CreateTexture(nil,"OVERLAY")
        btn.colorBox:SetSize(15,15)
        btn.colorBox:SetPoint("RIGHT",-10,0)
        if data[2] then
            btn.colorBox:SetColorTexture(data[2][1],data[2][2],data[2][3],data[2][4])
        end

        btn.deleteBtn=CreateFrame("Button",nil,btn)
        btn.deleteBtn:SetSize(15,15)
        btn.deleteBtn:SetPoint("RIGHT",btn.colorBox,"LEFT",0,0)
        btn.deleteBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        btn.deleteBtn:SetScript("OnClick",function(self)
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
