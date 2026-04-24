local D,F,_,C,_=unpack(select(2,...))
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
    for index=1,4 do
        D.menuStrings[index]:SetAlpha(number)
    end
end
