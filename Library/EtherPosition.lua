local _, Ether = ...

local ObjPos = {}

function Ether.RegisterPosition(parent)
    if type(parent) == "nil" then
        print("ObjPos – " .. parent .. " element is nil")
        return
    end
    local obj = {
        _parent = parent,
        _pos = Ether.DB[5111],
    }
    setmetatable(obj, {__index = ObjPos})
    return obj
end

function ObjPos:InitialPosition(number)
    if type(number) ~= "number" then
        print("ObjPos – element is not number")
        return
    end
    local success, msg = pcall(function()
        self._parent:SetClampedToScreen(true)
        local relTo = self._pos[number][2]
        if type(relTo) == "number" then
            if relTo == 5133 then
                relTo = UIParent
            else
                relTo = _G[relTo] or 5133
            end
            self._parent:SetPoint(self._pos[number][1], relTo, self._pos[number][3], self._pos[number][4], self._pos[number][5]);
        end
    end)
    if not success then
        if Ether.DebugOutput then
            Ether.DebugOutput("ObjPos - InitialPosition failed - ", msg)
        else
            print("ObjPos - InitialPosition failed - ", msg)
        end
    end
end

function ObjPos:InitialDrag(number)
    if type(number) ~= "number" then
        print("ObjPos – element is not number")
        return
    end
    self._parent:EnableMouse(true)
    self._parent:SetMovable(true)
    self._parent:RegisterForDrag("LeftButton")
    self._parent:SetScript("OnDragStart", function()
        if self._parent:IsMovable() then
            self._parent:StartMoving()
        end
    end)
    self._parent:SetScript("OnDragStop", function()
        if self._parent:IsMovable() then
            self._parent:StopMovingOrSizing()
        end
        local point, relTo, relPoint, x, y = self._parent:GetPoint(1)
        local relToName

        x = math.floor(x + 0.5)
        y = math.floor(y + 0.5)

        if relTo and relTo.GetName then
            relToName = relTo:GetName() or 5133
        else
            relToName = 5133
        end
        self._pos[number][1] = point
        self._pos[number][2] = relToName
        self._pos[number][3] = relPoint
        self._pos[number][4] = x
        self._pos[number][5] = y
        local anchorRelTo = _G[relToName] or UIParent
        self._parent:SetPoint(self._pos[number][1], anchorRelTo, self._pos[number][3], self._pos[number][4], self._pos[number][5])
    end)
end
