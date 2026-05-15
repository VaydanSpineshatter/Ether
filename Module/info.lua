local D,_,_,C=unpack(select(2,...))
local sformat,date,select,type,tconcat,C_After,twipe,parts=string.format,date,select,type,table.concat,C_Timer.After,table.wipe,{}
local timer,concat=false,""
local frame=CreateFrame("Frame",nil,UIParent)
C.InfoFrame=frame
frame:Hide()
frame.index=16
local bg=frame:CreateTexture(nil,"BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0.1,0.1,0.1)
local topR=frame:CreateFontString(nil,"OVERLAY")
C.InfoTopRight=topR
topR:SetFontObject(C.EtherFont)
topR:SetPoint("TOPRIGHT",-10,-10)
local scroll=CreateFrame("ScrollFrame",nil,frame,"ScrollFrameTemplate")
scroll:SetPoint("TOPLEFT",10,-30)
scroll:SetPoint("BOTTOMRIGHT",-30,10)
local cF=CreateFrame("Frame",nil,scroll)
cF:SetSize(390,111)
scroll:SetScrollChild(cF)
local v=cF:CreateFontString(nil,"OVERLAY")
v:SetFontObject(C.EtherFont)
v:SetPoint("TOPLEFT")
v:SetWidth(290)
v:SetJustifyH("LEFT")
scroll:EnableMouseWheel(true)
scroll:SetScript("OnMouseWheel",function(self,delta)
    if delta>0 then
        self:SetVerticalScroll(-50)
    else
        self:SetVerticalScroll(50)
    end
end)
if scroll.ScrollBar then
    scroll.ScrollBar:Hide()
end
local left=frame:CreateTexture(nil,"BACKGROUND")
C.FlashLeft=left
left:SetColorTexture(1,0,0,.4)
left:SetPoint("TOPLEFT",UIParent,"TOPLEFT")
left:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT")
left:SetWidth(40)
left:Hide()
local right=frame:CreateTexture(nil,"BACKGROUND")
C.FlashRight=right
right:SetPoint("TOPRIGHT",UIParent,"TOPRIGHT")
right:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT")
right:SetColorTexture(1,0,0,.4)
right:SetWidth(40)
right:Hide()
local function callback(msg)
    concat=concat.."\n"..msg
    v:SetText(concat)
    if timer then return end
    timer=true
    frame:Show()
    topR:SetText(sformat([[|cffffd700%s|r]],date([[%d.%m.%Y %A %H:%M:%S]])))
    C_After(5,function()
        concat=""
        frame:Hide()
        timer=false
    end)
end
function C:EtherInfo(msg)
    if D.DB[1][8]~=1 then return end
    if type(msg)~="string" or C.IdleMode then return end
    twipe(parts)
    for i=1,select('#',msg) do
        local arg=select(i,msg)
        parts[#parts+1]=arg
    end
    callback(tconcat(parts,'\n'))
end