local _, Ether = ...
local tinsert = table.insert
local tconcat = table.concat
local select, wipe = select, wipe
local C_After = C_Timer.After
local debugText = ""
local function SendOutput(input)
    if not Ether.DebugFrame then
        return
    end
    Ether.DebugFrame:Show()
    debugText = debugText .. '\n' .. input
    Ether.DebugText:SetText(debugText)
end
local timer = false
local function hide()
    if not timer then
        timer = true
        C_After(7, function()
            debugText = ""
            Ether.DebugFrame:Hide()
            timer = false
        end)
    end
end
local TEMP_CAT = {}
function Ether.DebugOutput(...)
    local data = ...
    if type(data) ~= "string" then
        return
    end
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        tinsert(TEMP_CAT, tostring(arg))
    end
    local concat = tconcat(TEMP_CAT, "")
    SendOutput(concat)
    wipe(TEMP_CAT)
    hide()
end
local msgEvent, enableWhisper, disableWhisper
do
    if not msgEvent then
        msgEvent = CreateFrame("Frame")
    end
    local function Whisper(_, event, ...)
        if event ~= "CHAT_MSG_WHISPER" then
            return
        end
        local msg, sender = ...
        Ether.DebugOutput(string.format("|cffcc66ff%s|r  %s", sender, msg))
    end
    function enableWhisper()
        if not msgEvent:GetScript("OnEvent") then
            msgEvent:SetScript("OnEvent", Whisper)
            msgEvent:RegisterEvent("CHAT_MSG_WHISPER")
        end
    end
    function disableWhisper()
        if msgEvent:GetScript("OnEvent") then
            msgEvent:SetScript("OnEvent", nil)
            msgEvent:UnregisterEvent("CHAT_MSG_WHISPER")
        end
    end
end
local function EnableMsgEvents()
    if msgEvent:GetScript("OnEvent") and msgEvent:IsEventRegistered("CHAT_MSG_WHISPER") then
        Ether.DebugOutput("|cffcc66ffEther|r - Whisper Off")
        disableWhisper()
    else
        Ether.DebugOutput("|cffcc66ffEther|r - Whisper On")
        enableWhisper()
    end
end
Ether.EnableMsgEvents = EnableMsgEvents
