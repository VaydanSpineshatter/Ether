local _, addonTable = ...

local Prototype = {}
local Mt = { __index = Prototype }

function Prototype:New(name)
    local obj = {
        name = name or "Unnamed Module",
        initialized = false,
        enabled = false
    }
    return setmetatable(obj, Mt)
end

function Prototype:Initialize()
    if self.initialized then return end
    self.initialized = true
    print("Initialized:", self.name)
    return true
end

function Prototype:Enable()
    if not self.initialized then
        self:Initialize()
    end
    self.enabled = true
    print("Enabled:", self.name)
end

function Prototype:Disable()
    self.enabled = false
    print("Disabled:", self.name)
end

function Prototype:Print()
    print("Module:", self.name, "| Initialized:", self.initialized, "| Enabled:", self.enabled)
end

addonTable.Prototype = Prototype
