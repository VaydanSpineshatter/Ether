local _,Ether=...
local L=Ether.L
local isDragging=false
local cos, sin, abs,  pi, atan2 = math.cos, math.sin, math.abs, math.pi, math.atan2

local button=CreateFrame("Button","EtherMinimapButton",Minimap)
Ether.EtherIcon = button
button:SetSize(31,31)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")

local function OnUpdate(self, elapsed)
    self.last = (self.last or 0) + elapsed
    if self.last > 0.01 then
        self.last = 0
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        if not scale then return end
        cx, cy = cx / scale, cy / scale
        local angleRad = atan2(cy - my, cx - mx)
        local dynRadius = (Minimap:GetWidth() / 2) + 30
        local x, y = cos(angleRad), sin(angleRad)
        local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
        local q = (angleRad >= 0 and (angleRad < pi/2 and 1 or 2) or (angleRad < -pi/2 and 3 or 4))
        if (shape == "SQUARE") or (shape:find("SIDE")) or (shape:find("CORNER")) then
            local absX, absY = abs(x), abs(y)
            if absX > absY then
                x = (x > 0 and 1 or -1)
                y = y / absX
            else
                y = (y > 0 and 1 or -1)
                x = x / absY
            end
        end
        self.posX = x * dynRadius
        self.posY = y * dynRadius
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", self.posX, self.posY)
    end
end

local function DragStart(self)
    isDragging = true
    self:SetScript("OnUpdate", OnUpdate)
end

local function DragStop(self)
    isDragging = false
    self:SetScript("OnUpdate", nil)
    if self.posX and self.posY then
        Ether.DB[21][13][4] = self.posX
        Ether.DB[21][13][5] = self.posY
    end
end

local function Enter(self)
    if not isDragging  then
        GameTooltip:SetOwner(self,"ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText("Ether",0,0.8,1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_RIGHT,1,1,1,1)
        GameTooltip:AddLine(L.MINIMAP_TOOLTIP_LOCALE,1,1,1,1)
        GameTooltip:Show()
    end
end

local function Leave()
    GameTooltip:Hide()
end

local function Click(_,btn)
    if btn=="RightButton" then
        Ether.EtherToggle()
    end
end

local icon=button:CreateTexture(nil,"BACKGROUND")
icon:SetSize(20,20)
icon:SetPoint("CENTER", button, "CENTER", 0, 1)
icon:SetTexture(unpack(Ether.media.etherIcon))

local border=button:CreateTexture(nil,"OVERLAY")
border:SetSize(53,53)
border:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT",button,"TOPLEFT")

button:SetScript("OnDragStart",DragStart)
button:SetScript("OnDragStop",DragStop)
button:SetScript("OnEnter",Enter)
button:SetScript("OnLeave",Leave)
button:SetScript("OnClick",Click)
button:EnableMouse(true)
button:SetMovable(true)
button:RegisterForClicks("AnyUp")
button:RegisterForDrag("LeftButton")

