local Ether = select(2, ...)
local C     = Ether
local Setup = C.Setup

function Setup:CreateName(frame, numb, numb2)

    if not frame.Name then
        frame.Name =frame.healthBar:CreateFontString(nil, 'OVERLAY')
        frame.Name:SetFont(unpack(C.Data.Forming.Font), numb, 'OUTLINE')
        frame.Name:SetPoint('RIGHT', frame.healthBar, 'RIGHT', 0, numb2)
        frame.Name:SetPoint('LEFT', frame.healthBar, 'LEFT', 0, numb2)
        frame.Name:SetTextColor(1, 1, 1)
        end
    end


function Setup:HealthText(frame)
    if (not frame.healthBar) then return end
    local Health = frame.healthBar:CreateFontString(nil, 'OVERLAY')
    Health:SetFont(unpack(C.Data.Forming.Font), 10, 'OUTLINE')
    Health:SetPoint('BOTTOM', frame.healthBar, 'BOTTOM', 0, 2)
    frame.Health = Health
end

function Setup:PowerText(frame, bool)
    if bool then
        if (frame.healthBar) then
            frame.Power = frame.healthBar:CreateFontString(nil, 'OVERLAY')
            frame.Power:SetFont(unpack(C.Data.Forming.Font), 10, 'OUTLINE')
            frame.Power:SetPoint('BOTTOMRIGHT')
        end
    else
        if (not frame.powerBar) then return end
        frame.Power = frame.powerBar:CreateFontString(nil, 'OVERLAY')
        frame.Power:SetFont(unpack(C.Data.Forming.Font), 10, 'OUTLINE')
        frame.Power:SetPoint('RIGHT')
    end
end

function Setup:CreateHealthBar(frame, height, orient)
    if (not frame.healthBar) then
        frame.healthBar = CreateFrame('StatusBar', nil, frame)
        frame.healthBar:SetPoint('TOPLEFT')
        frame.healthBar:SetPoint('TOPRIGHT')
        frame.healthBar:SetHeight(height)
        frame.healthBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 10)
        frame.healthBar:SetStatusBarTexture(unpack(Ether.Data.Forming.StatusBar))
        frame.healthBar:SetMinMaxValues(0, 100)
        frame.healthBar:SetOrientation(orient)
        frame.healthBar.bg = frame.healthBar:CreateTexture(nil, 'BACKGROUND')
        frame.healthBar.bg:SetAllPoints()
        frame.healthBar.bg:SetTexture(unpack(Ether.Data.Forming.StatusBar))
        frame.healthBar:GetStatusBarTexture():SetHorizTile(true)
    end
end

function Setup:CreatePowerBar(frame)
    if ( not frame.powerBar ) then
        frame.powerBar = CreateFrame('StatusBar', nil, frame)
        frame.powerBar:SetPoint('TOPLEFT', frame.healthBar, 'BOTTOMLEFT', 0, 0)
        frame.powerBar:SetHeight(10)
        frame.powerBar:SetWidth(120)
        frame.powerBar:SetStatusBarTexture(unpack(Ether.Data.Forming.StatusBar))
        frame.powerBar:SetMinMaxValues(0, 100)
        frame.powerBar.bg = frame.powerBar:CreateTexture(nil, 'BACKGROUND')
        frame.powerBar.bg:SetAllPoints()
        frame.powerBar.bg:SetTexture(unpack(Ether.Data.Forming.StatusBar))

    end
end


function Setup:HealPrediction(frame)
    if (not frame.healthBar) then return end

    local playerBar = CreateFrame('StatusBar', nil, frame.healthBar:GetParent())
    playerBar:SetAllPoints(frame.healthBar)
    playerBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 0)
    playerBar:SetStatusBarTexture(unpack(Ether.Data.Forming.StatusBar))
    playerBar:SetStatusBarColor(1.00, 0.65, 0.00, .7)
    playerBar:SetMinMaxValues(0, 1)
    playerBar:SetValue(1)
    playerBar:Hide()

    local enemyBar = CreateFrame('StatusBar', nil, frame.healthBar:GetParent())
    enemyBar:SetAllPoints(frame.healthBar)
    enemyBar:SetFrameLevel(frame.healthBar:GetFrameLevel() - 0)
    enemyBar:SetStatusBarTexture(unpack(Ether.Data.Forming.StatusBar))
    enemyBar:SetStatusBarColor(0, 0.5, 1, .7)
    enemyBar:SetMinMaxValues(0, 1)
    enemyBar:SetValue(1)
    enemyBar:Hide()

    frame.playerBar = playerBar
    frame.enemyBar = enemyBar
end



function Setup:CreateBorder(frame)

    if not frame.Border then
        frame.Border = {}
        frame.Border.Top = frame:CreateTexture(nil, 'BORDER')
        frame.Border.Top:SetColorTexture(0, 0, 0, 1)
        frame.Border.Top:SetPoint('TOPLEFT', -1, 1)
        frame.Border.Top:SetPoint('TOPRIGHT', 1, 1)
        frame.Border.Top:SetHeight(1)

        frame.Border.Bottom = frame:CreateTexture(nil, 'BORDER')
        frame.Border.Bottom:SetColorTexture(0, 0, 0, 1)
        frame.Border.Bottom:SetPoint('BOTTOMLEFT', -1, -1)
        frame.Border.Bottom:SetPoint('BOTTOMRIGHT', 1, -1)
        frame.Border.Bottom:SetHeight(1)

        frame.Border.Left = frame:CreateTexture(nil, 'BORDER')
        frame.Border.Left:SetColorTexture(0, 0, 0, 1)
        frame.Border.Left:SetPoint('TOPLEFT', -1, 1)
        frame.Border.Left:SetPoint('BOTTOMLEFT', -1, -1)
        frame.Border.Left:SetWidth(1)

        frame.Border.Right = frame:CreateTexture(nil, 'BORDER')
        frame.Border.Right:SetColorTexture(0, 0, 0, 1)
        frame.Border.Right:SetPoint('TOPRIGHT', 1, 1)
        frame.Border.Right:SetPoint('BOTTOMRIGHT', 1, -1)
        frame.Border.Right:SetWidth(1)

    end


    if Ether.DB.HEADER.RAID.HIGHLIGHT ~= true then return end
    if not   frame.Border.Highlight then
        frame.Border.Highlight = frame:CreateTexture(nil, "HIGHLIGHT")
        frame.Border.Highlight:SetPoint('TOPLEFT', frame, 'TOPLEFT', -1, 1)
        frame.Border.Highlight:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 1, -1)
        frame.Border.Highlight:SetColorTexture(0.80, 0.40, 1.00, .6)
        end

end

function Setup:CreateToggle(parent, name, dbTable, dbKey, func)
    local toggle = CreateFrame('CheckButton', nil, parent, 'InterfaceOptionsCheckButtonTemplate')

    toggle:SetSize(24, 24)

    if dbTable and dbKey then
        toggle:SetChecked(dbTable[dbKey] or false)
    else
        toggle:SetChecked(false)
    end

    toggle:SetScript('OnClick', function(self)
        local checked = self:GetChecked()

        if dbTable and dbKey then
            dbTable[dbKey] = checked
        end

        if func then
            func(checked)
        end
    end)

    toggle.label = toggle:CreateFontString(nil, 'OVERLAY')
    toggle.label:SetFont(unpack(Ether.Data.Forming.Font), 12, 'OUTLINE')
    toggle.label:SetText(name)
    toggle.label:SetPoint('LEFT', toggle, 'RIGHT', 8, 1)

    return toggle
end

function Setup:PetCondition(frame)
    if (not frame.healthBar) then return end
    local condition = CreateFrame('Frame', 'nil', frame)
    self.condition = condition

    condition:SetSize(16, 16)
    condition:SetPoint('BOTTOMRIGHT', frame.healthBar, 'BOTTOMRIGHT', 0, 0)

    condition:Show()

    condition.happy = condition:CreateTexture(nil, 'OVERLAY')
    condition.happy:SetTexture('Interface\\PetPaperDollFrame\\UI-PetHappiness')
    condition.happy:SetAllPoints(condition)

    condition.happy:SetScript('OnEnter', function()
        if not UnitExists('pet') then return end
        local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
        local petType = UnitCreatureFamily('pet')
        GameTooltip:SetOwner(condition, 'ANCHOR_RIGHT')
        GameTooltip:SetText('Condition:')
        GameTooltip:AddLine('Family: ' .. petType)
        GameTooltip:AddLine('Happiness: ' .. ({ 'Unhappy', 'Content', 'Happy' })[happiness])
        GameTooltip:AddLine('Loyalty: ' .. (loyaltyRate or 'N/A'))
        GameTooltip:AddLine('Pet is doing ' .. damagePercentage .. '% damage')
        GameTooltip:Show()
    end)
    condition.happy:SetScript('OnLeave', GameTooltip_Hide)

    local GetPetHappiness = GetPetHappiness

    local PETCOORDS = {
        [1] = { 0.375, 0.5625, 0, 0.359375 },
        [2] = { 0.1875, 0.375, 0, 0.359375 },
        [3] = { 0, 0.1875, 0, 0.359375 },
    }

    local function PetStatus()
        local happiness = GetPetHappiness()
        if (happiness) then
            Ether.Setup.condition.happy:SetTexCoord(unpack(PETCOORDS[happiness]))
        end
    end

    local function OnPetEvent(self, event)
        if event == 'UNIT_HAPPINESS' then
            PetStatus(self)
        elseif event == 'PET_UI_UPDATE' then
            PetStatus(self)
        elseif (event == 'UNIT_PET') then
            Ether.Update:Name('pet')
        end
    end
    local petEvent = CreateFrame('Frame')


    petEvent:RegisterUnitEvent('UNIT_HAPPINESS', 'pet')
    petEvent:RegisterEvent('PET_UI_UPDATE')
    petEvent:RegisterUnitEvent('UNIT_PET', 'player')
    petEvent:SetScript('OnEvent', OnPetEvent)
end

function Setup:CreateReloadBox()
    if self.ReloadBox then return end

    local frame = CreateFrame('EditBox', nil, UIParent, 'InputBoxTemplate')
    frame:SetAutoFocus(false)
    self.ReloadBox = frame
    frame:SetSize(120, 20)
    frame:SetFrameLevel(120)
    frame:SetPoint('CENTER', 0, 200)
    frame:SetJustifyH('CENTER')
    frame:Hide()

    local BtnY = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    BtnY:SetPoint('LEFT', frame, 'RIGHT', 0, 0)

    BtnY.text = BtnY:CreateFontString(nil, 'OVERLAY', 'GameFontWhite')
    BtnY.text:SetPoint('CENTER')
    BtnY.text:SetText('Yes')

    BtnY:SetScript('OnClick', function()
        if not InCombatLockdown() then
            if frame:GetText() == '|cffff0000Reset|r' then
                C.DB['VERSION'] = 123456
                ReloadUI()
            else
                ReloadUI()
            end
        end
    end)

    local BtnN = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    BtnN:SetPoint('LEFT', BtnY, 'RIGHT', 0, 0)

    BtnN.text = BtnN:CreateFontString(nil, 'OVERLAY', 'GameFontWhite')
    BtnN.text:SetPoint('CENTER')
    BtnN.text:SetText('No')

    BtnN:SetScript('OnClick', function()
        frame:Hide()
    end)

    return frame
end
