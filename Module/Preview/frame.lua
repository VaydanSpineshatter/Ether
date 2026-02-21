local _, Ether = ...
local C_After = C_Timer.After

local function CreatePreviewFrame()
    if Ether.previewFrame then return end
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Ether.previewFrame = frame
    frame:SetPoint("TOP", -100, 0)
    frame:SetFrameLevel(500)
    frame:SetSize(480, 320)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, .8)
    frame:SetBackdropBorderColor(0, 0.8, 1, 1)
    frame:Hide()
end

local headerButtons = {}

local function HeaderPreview(status)
    if not Ether.previewFrame then return end
    local spacing = 4
    local step = 30 + spacing
    local cols, rows
    if status then
        cols = 5
        rows = 8
    else
        cols = 8
        rows = 5
    end
    local gridWidth = (cols - 1) * step
    local gridHeight = (rows - 1) * step
    local startX = -(gridWidth / 2)
    local startY = (gridHeight / 2)
    for i = 1, 40 do
        local col, row
        if status then
            col = (i - 1) % cols
            row = math.floor((i - 1) / cols)
        else
            row = (i - 1) % rows
            col = math.floor((i - 1) / rows)
        end
        local xOffset = startX + (col * step)
        local yOffset = startY - (row * step)
        headerButtons[i]:ClearAllPoints()
        headerButtons[i]:SetPoint("CENTER", Ether.previewFrame, "CENTER", xOffset, yOffset)
    end
end

local function CreatePreviewButtons(parent, name, numb, size)
    local preview = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    preview:SetSize(size, size)
    preview:SetBackdrop({
        bgFile = Ether.DB[811]["background"],
        insets = {left = -2, right = -2, top = -2, bottom = -2}
    })
    Ether:SetupHealthBar(preview, "HORIZONTAL", size, size, "player")
    Ether:SetupName(preview, 0)
    preview.name:SetText(Ether:ShortenName(name, numb))
    return preview
end

local function CreateHeaderPreview()
    if not headerButtons[1] then
        for i = 1, 40 do
            headerButtons[i] = CreatePreviewButtons(Ether.previewFrame, tostring(i), 2, 30)
        end
    end
end

local function CreateSoloPreview()
    if not Ether.previewFrame then return end
end

local function CreateCastBarPreview()
    if not Ether.previewFrame then return end

end

local timer = false
local function hide()
    if not Ether.previewFrame then return end
    if not timer then
        timer = true
        Ether.previewFrame:SetShown(true)
        C_After(7, function()
            Ether.previewFrame:SetShown(false)
            timer = false
        end)
    end
end

function Ether:InitializePreview()
    if not Ether.previewFrame then
        CreatePreviewFrame()
        CreateHeaderPreview()
    end
    if Ether.DB[1501][1] == 1 then
        HeaderPreview(true)
    else
        HeaderPreview(false)
    end
    hide()
end