local D,_,_,C=unpack(select(2,...))
local sformat,date,select,type,tconcat,C_After,twipe,parts=string.format,date,select,type,table.concat,C_Timer.After,table.wipe,{}
C.InfoTimer=false
local concat=""
local function callback(msg)
    concat=concat.."\n"..msg
    C.InfoText:SetText(concat)
    if not C.InfoTimer then
        C.InfoTimer=true
        C.InfoFrame:Show()
        C.InfoRight:SetText(sformat([[|cffffd700%s|r]],date([[%d.%m.%Y %A %H:%M:%S]])))
        C_After(5,function()
            concat=""
            C.InfoFrame:Hide()
            C.InfoTimer=false
        end)
    end
end
function C:EtherInfo(msg)
    if not C.InfoFrame then return end
    if not msg then return end
    if D.DB[1][8]~=1 then return end
    if type(msg)~="string" then return end
    twipe(parts)
    for i=1,select('#',msg) do
        local arg=select(i,msg)
        parts[#parts+1]=arg
    end
    callback(tconcat(parts,'\n'))
end