local Ether   = select(2, ...)
local Effects = Ether.Effects

local Blinks  = {}

local BlinkController
if not BlinkController then
    BlinkController = CreateFrame("Frame")
end

local function ControllerOnUpdate(self, elapsed)
    self.time = (self.time or 0) + elapsed
    if self.time > 0.3 then
        self.time = 0
        for tex in pairs(Blinks) do
            if tex:IsShown() then
                tex:Hide()
            else
                tex:Show()
            end
        end
    end
end

local function StartTextureBlink(tex)
    Blinks[tex] = true
    if not BlinkController:GetScript("OnUpdate") then
        BlinkController:SetScript("OnUpdate", ControllerOnUpdate)
    end
end

local function StopTextureBlink(tex)
    Blinks[tex] = nil
    tex:Hide()
    if not next(Blinks) then
        BlinkController:SetScript("OnUpdate", nil)
    end
end

Effects.StartBlink = StartTextureBlink
Effects.StopBlink  = StopTextureBlink
