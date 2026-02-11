local _, Ether = ...
local Blinks = {}
local BlinkState = true
local BlinkTimer
local pairs, wipe, next = pairs, wipe, next
local C_After = C_Timer.After
local C_Ticker = C_Timer.NewTicker

local function ToggleAllBlinks()
    BlinkState = not BlinkState
    for tex in pairs(Blinks) do
        if BlinkState then
            tex:Show()
        else
            tex:Hide()
        end
    end
end

Ether.StartBlink = function(tex, duration, interval)
    if type(tex) == "nil" then
        error("The element " .. tex .. " does not exist")
        return
    end
    if type(duration) ~= "number" or type(interval) ~= "number" then
        error("The element " .. (duration or interval) .. " must be a number")
        return
    end
    interval = interval or 0.5
    Ether.StopBlink(tex)
    Blinks[tex] = true
    if BlinkState then
        tex:Show()
    else
        tex:Hide()
    end
    if not BlinkTimer then
        BlinkTimer = C_Ticker(interval, ToggleAllBlinks)
    end
    if duration then
        C_After(duration, function()
            Ether.StopBlink(tex)
        end)
    end
end

Ether.StopBlink = function(tex)
    if Blinks[tex] then
        Blinks[tex] = nil
        tex:Hide()
        if not next(Blinks) and BlinkTimer then
            BlinkTimer:Cancel()
            BlinkTimer = nil
        end
    end
end

Ether.StopAllBlinks = function()
    for tex in pairs(Blinks) do
        tex:Hide()
    end
    wipe(Blinks)
    if BlinkTimer then
        BlinkTimer:Cancel()
        BlinkTimer = nil
    end
end
