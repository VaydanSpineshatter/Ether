local D,F,_,C=unpack(select(2,...))
local ipairs=ipairs
function F:CleanUpButtons(status)
    local index=F:BinaryCondition(status)
    --[[
    if C.ChildFrames[6] and C.ChildFrames[6].consuma and C.ChildFrames[6].consuma.v then
        C.ChildFrames[6].consuma:SetShown(index)
        C.ChildFrames[6].consuma.v:SetShown(index)
        C.ChildFrames[6].wl:SetShown(index)
        C.ChildFrames[6].hl:SetShown(index)
        C.ChildFrames[6].wl.v:SetShown(index)
        C.ChildFrames[6].hl.v:SetShown(index)
        C.ChildFrames[6].w:SetShown(index)
        C.ChildFrames[6].h:SetShown(index)
    end
    ]]
    if C.EditorFrame.spell and C.EditorFrame.spell.v then
        --  C.AuraFrame:SetShown(index)
    end
end
function C:ToggleBorder(r,g,b)
    if not C.BorderFrames then return end
    for _,v in ipairs(C.BorderFrames) do
        v:SetColorTexture(r,g,b)
    end
end
function F:MainBorder(parent,_1,_2,_3,_4)
    for index=_1,_4 do
        local tex=parent:CreateTexture(nil,"BORDER")
        C.BorderFrames[index]=tex
        tex:SetColorTexture(0.67,0.67,0.67)
        if index>=31 then
            C.BorderFrames[index]:SetColorTexture(0,1,0)
        end
        if index>=35 then
            C.BorderFrames[index]:SetColorTexture(0,1,0)
        end
        if index<=_2 then
            tex:SetHeight(1)
        else
            tex:SetWidth(1)
        end
    end
    for i,v in ipairs({1,3,7,9,1,7,3,9}) do
        local j=_1+math.floor((i-1)/2)
        C.BorderFrames[j]:SetPoint(D:GetRelativePoint(D:PosNumber(v)))
    end
end
--  local r, g, b = GetThreatStatusColor(thread)
function F:UpdateThreatColor(numb,numb2,unit)
    local thread=UnitThreatSituation(unit)
    local r,g,b
    if thread then
        r,g,b=1,0,0
    else
        r,g,b=0,1,0
    end
    for index=numb,numb2 do
        if C.BorderFrames[index] then
            C.BorderFrames[index]:SetColorTexture(r,g,b)
        end
    end
end
-- F:UpdateCube(C.EditorFrame.cube, status)
--  F:UpdateCube(C.IndicatorFrame.cube, status)
function F:UpdateCube(data,status)
    if not data then return end
    local index=F:BinaryCondition(status)
    for _,btn in pairs(data) do
        btn:SetShown(index)
    end
end
function F:RefreshUserButtons()
    for _,v in ipairs(C.ChildFrames) do
        v:Hide()
    end
    if C.DropdownMenu then
        C.DropdownMenu:Hide()
    end
    if C.InputText then
        C.InputText:SetText("")
    end
    if C.DropdownText then
        C.DropdownText:SetAlpha(1)
    end
    if C.ImportBox then
        C.ImportBox:ClearFocus()
        C.ImportBox:SetText("Paste import data here...")
    end
    if C.InputLine then
        C.InputLine:Hide()
    end
end
function F:MenuStringsAlpha(number)
    if D.menuStrings[1]:GetAlpha()==number then return end
    for index=1,5 do
        D.menuStrings[index]:SetAlpha(number)
    end
end

local dropdownBtn={}
function F:CreateEtherDropdown(parent,width,txt,options,callback,status)
    table.wipe(dropdownBtn)
    local frame=CreateFrame("Button",nil,parent)
    frame:SetSize(width,20)
    local bg=frame:CreateTexture(nil,"BACKGROUND")
    frame.bg=bg
    bg:SetAllPoints()
    bg:SetColorTexture(1,1,1,0.1)
    local text=frame:CreateFontString(nil,"OVERLAY")
    frame.text=text
    text:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
    text:SetPoint("CENTER")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetText(txt)
    frame:SetScript("OnEnter",function()
        text:SetTextColor(0,0.8,1)
        C:ToggleBorder(0,0.8,1)
    end)
    frame:SetScript("OnLeave",function()
        text:SetTextColor(1,1,1)
        C:ToggleBorder(0.67,0.67,0.67)
    end)
    local menu=CreateFrame("Button",nil,frame)
    frame.menu=menu
    C.DropdownMenu=menu
    C.DropdownText=text
    menu:SetPoint("TOPLEFT",frame,"BOTTOMLEFT",0,-2)
    menu:SetWidth(width)
    menu:SetFrameLevel(parent:GetFrameLevel()+10)
    menu:Hide()
    menu.bg=menu:CreateTexture(nil,"BACKGROUND")
    menu.bg:SetAllPoints()
    menu.bg:SetColorTexture(0.2,0.2,0.2,1)
    function frame:SetOptions(newList)
        if newList then
            options=newList
        end
        local totalHeight=4
        for _,btn in ipairs(dropdownBtn) do
            btn:Hide()
        end
        for index,data in ipairs(options) do
            local btn=dropdownBtn[index]
            if not btn then
                btn=CreateFrame("Button",nil,menu)
                btn:SetSize(width-8,20)
                btn.text=btn:CreateFontString(nil,"OVERLAY")
                btn.text:SetFont("Interface\\AddOns\\Ether\\Media\\venite.ttf",7,"OUTLINE")
                btn.text:SetJustifyH("CENTER")
                btn.text:SetJustifyV("MIDDLE")
                btn.text:SetPoint("CENTER")
                btn:SetScript("OnEnter",function(self)
                    self.text:SetTextColor(1,0.84,0)
                end)
                btn:SetScript("OnLeave",function(self)
                    self.text:SetTextColor(1,1,1)
                end)
                dropdownBtn[#dropdownBtn+1]=btn
            end
            btn:SetPoint("TOPLEFT",4,-totalHeight)
            btn.text:SetText(data)
            btn:SetScript("OnClick",function()
                if callback then
                    callback(frame,index,data)
                end
                if not status then
                    text:SetText(data)
                end
                text:SetAlpha(1)
                menu:Hide()
            end)
            btn:Show()
            totalHeight=totalHeight+20
        end
        menu:SetHeight(totalHeight+4)
    end
    frame:SetScript("OnClick",function()
        menu:SetShown(not menu:IsShown())
        if text:GetAlpha()==1 then
            text:SetAlpha(0)
        else
            text:SetAlpha(1)
        end
        C:ToggleBorder(0.67,0.67,0.67)
    end)
    if options then frame:SetOptions(options) end
    function frame:HideDropdown()
        frame.menu:Hide()
        frame.text:SetAlpha(1)
    end
    return frame
end
function F:RefreshChildText(dropdown,number,text)
    if not text then return end
    if C.ChildFrames[number] and C.ChildFrames[number][dropdown] then
        C.ChildFrames[number][dropdown]:SetText(text)
    end
end
function F:EtherPanelButton(parent,width,height,text,point,relTo,rel,offX,offY,r,g,b)
    local btn=CreateFrame("Button",nil,parent)
    btn:SetSize(width,height)
    btn:SetPoint(point,relTo,rel,offX,offY)
    btn.v=btn:CreateFontString(nil,"OVERLAY")
    btn.v:SetFontObject(C.EtherFont)
    btn.v:SetPoint("LEFT")
    btn.v:SetText(text)
    btn.bg=btn:CreateTexture(nil,"BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0,0,0,0)
    btn:SetScript("OnEnter",function(self)
        self.v:SetTextColor(r or 1,g or 0.84,b or 0)
        C:ToggleBorder(r or 1,g or 0.84,b or 0)
    end)
    btn:SetScript("OnLeave",function(self)
        self.v:SetTextColor(1,1,1)
        C:ToggleBorder(0.67,0.67,0.67)
    end)
    return btn
end
function F:MenuButton(index,func)
    C.MenuButtons[index]=CreateFrame("Button",nil,C.BaseFrame)
    C.MenuButtons[index]:SetSize(90,20)
    local frame=C.ChildFrames
    frame[index]=CreateFrame("Frame",nil,C.ContentFrame)
    frame[index]:SetAllPoints(C.ContentFrame)
    C.MenuButtons[index]:SetScript("OnClick",function()
        F:MenuStringsAlpha(0)
        F:RefreshUserButtons()
        if index==4 then
            C.ChildFrames[10]:Show()
            C.ChildFrames[11]:Show()
        end
        D.DB["CONFIG"][1]=index
        func(index)
        frame[index]:Show()
    end)
    if index==1 then
        C.MenuButtons[index]:SetPoint("TOP",0,-5)
    else
        C.MenuButtons[index]:SetPoint("TOP",C.MenuButtons[index-1],"BOTTOM")
    end
    C.MenuButtons[index].text=C.MenuButtons[index]:CreateFontString(nil,"OVERLAY")
    C.MenuButtons[index].text:SetFontObject(C.EtherFont)
    C.MenuButtons[index].text:SetPoint("CENTER")
    C.MenuButtons[index].text:SetText(D.MenuKey[index])
    C.MenuButtons[index]:SetScript("OnEnter",function(self)
        self.text:SetTextColor(1,0.84,0)
        C:ToggleBorder(1,0.84,0)
    end)
    C.MenuButtons[index]:SetScript("OnLeave",function(self)
        self.text:SetTextColor(1,1,1)
        C:ToggleBorder(0.67,0.67,0.67)
    end)
end