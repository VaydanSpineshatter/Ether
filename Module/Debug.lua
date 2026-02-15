local _, Ether = ...
local tinsert = table.insert
local tconcat = table.concat
local select, wipe = select, wipe
local C_After = C_Timer.After
local debugText = ""
local function SendOutput(input)
    if not Ether.debugFrame then
       Ether:SetupDebugFrame()
    end
    Ether.debugFrame:Show()
    debugText = debugText .. '\n' .. input
    Ether.DebugText:SetText(debugText)
end
local timer = false
local function hide()
    if not timer then
        timer = true
        C_After(7, function()
            debugText = ""
            Ether.debugFrame:Hide()
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
        if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
            local text, _, _, _, playerName2 = ...
            Ether.DebugOutput(string.format("|cffcc66ffFrom %s:|r %s", playerName2, text))
        end
    end
    function enableWhisper()
        if not msgEvent:GetScript("OnEvent") then
            msgEvent:SetScript("OnEvent", Whisper)
            msgEvent:RegisterEvent("CHAT_MSG_WHISPER")
            msgEvent:RegisterEvent("CHAT_MSG_BN_WHISPER")
            Ether.DB[401][2] = 1
        end
    end
    function disableWhisper()
        if msgEvent:GetScript("OnEvent") then
            msgEvent:SetScript("OnEvent", nil)
            msgEvent:UnregisterAllEvents()
            Ether.DB[401][2] = 0
        end
    end
end
local function EnableMsgEvents()
    if msgEvent:GetScript("OnEvent") and msgEvent:IsEventRegistered("CHAT_MSG_WHISPER") then
        disableWhisper()
    else
        enableWhisper()
    end
end
Ether.EnableMsgEvents = EnableMsgEvents
