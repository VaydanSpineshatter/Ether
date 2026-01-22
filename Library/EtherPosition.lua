local _, Ether = ...

local ObjPos = {}

function Ether.RegisterPosition(parent, name)
    if type(parent) == "nil" or type(name) == "nil" then
        error("ObjPos – " .. (parent or name) .. " element is nil")
        return
    end
    local obj = {
        _parent = parent,
        _pos = Ether.DB[5111][name],
    }
    setmetatable(obj, {__index = ObjPos})
    return obj
end

function ObjPos:InitialPosition()
         ColorPickerFrame:Show()
    self._parent:SetClampedToScreen(true)
    self._parent:SetMovable(true)
    local relTo = self._pos[2]
    if type(relTo) == "number" then
        if relTo == 5133 then
            relTo = UIParent
        else
            relTo = _G[relTo] or 5133
        end
        self._parent:ClearAllPoints()
        self._parent:SetPoint(self._pos[1], relTo, self._pos[3], self._pos[4], self._pos[5]);
        self._parent:SetWidth(self._pos[6])
        self._parent:SetHeight(self._pos[7])
        self._parent:SetScale(self._pos[8])
        self._parent:SetAlpha(self._pos[9])
    end
end

function ObjPos:InitialDrag()
    self._parent:EnableMouse(true)
    self._parent:RegisterForDrag("LeftButton")
    self._parent:SetScript("OnDragStart", function()
        if InCombatLockdown() or self._parent.isMoving then
            return
        end
        if self._parent:IsMovable() then
            self._parent:StartMoving()
            self._parent.isMoving = true
        end
    end)
    self._parent:SetScript("OnDragStop", function()
        if InCombatLockdown() or not self._parent.isMoving then
            return
        end
        if self._parent:IsMovable() then
            self._parent:StopMovingOrSizing()
            self._parent.isMoving = false
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
        self._pos[1] = point
        self._pos[2] = relToName
        self._pos[3] = relPoint
        self._pos[4] = x
        self._pos[5] = y
        local anchorRelTo = _G[relToName] or UIParent
        self._parent:SetPoint(self._pos[1], anchorRelTo, self._pos[3], self._pos[4], self._pos[5])
    end)
end
