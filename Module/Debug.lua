local _,Ether=...
local tinsert=table.insert
local tconcat=table.concat
local select,wipe=select,wipe
local C_After=C_Timer.After
local debugText=""
local function SendOutput(input)
    Ether.infoFrame:Show()
    debugText=debugText..'\n'..input
    Ether.infoText:SetText(debugText)
end
local timer=false
local function hide()
    if not timer then
        timer=true
        C_After(7,function()
            debugText=""
            Ether.infoFrame:Hide()
            timer=false
        end)
    end
end
local TEMP_CAT={}
local function Output(...)
    if not Ether.infoFrame then
        print(...)
    else
        for i=1,select('#',...) do
            local arg=select(i,...)
            tinsert(TEMP_CAT,tostring(arg))
        end
        local concat=tconcat(TEMP_CAT,"")
        SendOutput(concat)
        wipe(TEMP_CAT)
        hide()
    end
end
function Ether:EtherInfo(...)
    if Ether.DB[1][8]~=1 then return end
    Output(...)
end
function Ether:EtherDebug(...)
    if Ether.DB[1][9]~=1 then return end
    Output(...)
end

