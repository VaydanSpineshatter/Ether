local D,F,_,C=unpack(select(2,...))
local tconcat,C_After=table.concat,C_Timer.After
local sformat,date,select,type=string.format,date,select,type
C.InfoTimer=false
local function callback()
    if not C.InfoFrame then return end
    C.InfoFrame:Show()
    C.InfoRight:SetText(sformat([[|cffffd700%s|r]],date("%d.%m.%Y %A %H:%M:%S")))
    C_After(5,function()
        C.InfoFrame:Hide()
        C.InfoTimer=false
    end)
end
function C:EtherInfo(msg)
    if C.InfoTimer then return end
    if not msg then return end
    if D.DB[1][8]~=1 then return end
    if type(msg)~="string" then return end
    local parts=F.GetTbl()
    for i=1,select('#',msg) do
        local arg=select(i,msg)
        parts[#parts+1]=arg
    end
    C.InfoText:SetText(tconcat(parts,'\n'))
    F.RelTbl(parts)
    C.InfoTimer=true
    callback()
end


