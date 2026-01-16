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
