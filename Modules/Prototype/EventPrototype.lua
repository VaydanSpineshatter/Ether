local _, addonTable = ...

local EventProto = {
    events = {}
}

function EventProto:New(name)
    local obj = {
        name = name,
        frame = CreateFrame("Frame", name .. "EventFrame")
    }
    obj.frame:SetScript("OnEvent", function(_, ...) obj:OnEvent(...) end)
    return setmetatable(obj, { __index = EventProto })
end

function EventProto:RegisterEvent(event, handler)
    self.events[event] = handler
    self.frame:RegisterEvent(event)
end

function EventProto:OnEvent(event, ...)
    if self.events[event] then
        self.events[event](self, event, ...)
    end
end

addonTable.EventProto = EventProto
