local Ether = select(2, ...)
local Grid = Ether.Grid

function Grid:Initialize()
    if self.frame then return end
    local frame = CreateFrame('Frame', nil, UIParent)
    self.frame = frame
    frame:SetAllPoints(UIParent)
    frame:SetFrameStrata('TOOLTIP')
    frame:SetFrameLevel(1)
    frame:SetAlpha(0.4)

    local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
    local centerX, centerY = screenWidth / 2, screenHeight / 2
    local linePool = {}

    local centerH = frame:CreateLine()
    centerH:SetColorTexture(0, 1, 0, 0.8)
    centerH:SetThickness(4)
    centerH:SetStartPoint('TOPLEFT', UIParent, 0, -centerY)
    centerH:SetEndPoint('TOPRIGHT', UIParent, screenWidth, -centerY)

    local centerV = frame:CreateLine()
    centerV:SetColorTexture(0, 1, 0, 0.8)
    centerV:SetThickness(4)
    centerV:SetStartPoint('TOPLEFT', UIParent, centerX, 0)
    centerV:SetEndPoint('BOTTOMLEFT', UIParent, centerX, -screenHeight)

    for offset = 100, math.max(centerX, centerY), 100 do
        local yTop = centerY + offset
        local yBottom = centerY - offset
        if yTop <= screenHeight then
            local line = frame:CreateLine()
            line:SetColorTexture(1, 0.5, 0.5, 0.5)
            line:SetThickness(2)
            line:SetStartPoint('TOPLEFT', UIParent, 0, -yTop)
            line:SetEndPoint('TOPRIGHT', UIParent, screenWidth, -yTop)
            table.insert(linePool, line)
        end
        if yBottom >= 0 then
            local line = frame:CreateLine()
            line:SetColorTexture(1, 0.5, 0.5, 0.5)
            line:SetThickness(2)
            line:SetStartPoint('TOPLEFT', UIParent, 0, -yBottom)
            line:SetEndPoint('TOPRIGHT', UIParent, screenWidth, -yBottom)
            table.insert(linePool, line)
        end

        local xRight = centerX + offset
        local xLeft = centerX - offset
        if xRight <= screenWidth then
            local line = frame:CreateLine()
            line:SetColorTexture(1, 0.5, 0.5, 0.5)
            line:SetThickness(2)
            line:SetStartPoint('TOPLEFT', UIParent, xRight, 0)
            line:SetEndPoint('BOTTOMLEFT', UIParent, xRight, -screenHeight)
            table.insert(linePool, line)
        end
        if xLeft >= 0 then
            local line = frame:CreateLine()
            line:SetColorTexture(1, 0.5, 0.5, 0.5)
            line:SetThickness(2)
            line:SetStartPoint('TOPLEFT', UIParent, xLeft, 0)
            line:SetEndPoint('BOTTOMLEFT', UIParent, xLeft, -screenHeight)
            table.insert(linePool, line)
        end
    end

    for offset = 20, math.max(centerX, centerY), 20 do
        if offset % 100 ~= 0 then
            local yTop = centerY + offset
            local yBottom = centerY - offset
            if yTop <= screenHeight then
                local line = frame:CreateLine()
                line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                line:SetThickness(1)
                line:SetStartPoint('TOPLEFT', UIParent, 0, -yTop)
                line:SetEndPoint('TOPRIGHT', UIParent, screenWidth, -yTop)
                table.insert(linePool, line)
            end
            if yBottom >= 0 then
                local line = frame:CreateLine()
                line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                line:SetThickness(1)
                line:SetStartPoint('TOPLEFT', UIParent, 0, -yBottom)
                line:SetEndPoint('TOPRIGHT', UIParent, screenWidth, -yBottom)
                table.insert(linePool, line)
            end

            local xRight = centerX + offset
            local xLeft = centerX - offset
            if xRight <= screenWidth then
                local line = frame:CreateLine()
                line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                line:SetThickness(1)
                line:SetStartPoint('TOPLEFT', UIParent, xRight, 0)
                line:SetEndPoint('BOTTOMLEFT', UIParent, xRight, -screenHeight)
                table.insert(linePool, line)
            end
            if xLeft >= 0 then
                local line = frame:CreateLine()
                line:SetColorTexture(0.8, 0.8, 0.8, 0.2)
                line:SetThickness(1)
                line:SetStartPoint('TOPLEFT', UIParent, xLeft, 0)
                line:SetEndPoint('BOTTOMLEFT', UIParent, xLeft, -screenHeight)
                table.insert(linePool, line)
            end
        end
    end
    frame:Hide()
end
