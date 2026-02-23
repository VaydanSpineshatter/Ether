local _, Ether = ...
local realmName = GetRealmName()

function Ether:ExportCurrentProfile()
    Ether:CreateCustomSection(Ether.UIPanel)
    Ether:CreatePositionSection(Ether.UIPanel)
    Ether:UpdateAuraList()
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
    local profileName = Ether:GetCurrentProfileString()
    local profile = Ether:GetCurrentProfile()
    if not profile then
        return nil, "Current profile not found"
    end
    local exportData = {
        profileName = profileName,
        data = profile,
    }
    local serialized = Ether.TblToString(exportData)
    local encoded = Ether.Base64Encode(serialized)
    Ether:UpdateAuraList()
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
    Ether:EtherInfo("|cff00ff00Export ready:|r " .. profileName)
    Ether:EtherInfo("|cff888888Size:|r " .. #encoded .. " characters")
    return encoded
end

function Ether:ExportProfileToClipboard()
    local encoded, err = Ether:ExportCurrentProfile()
    if not encoded then
        Ether:EtherInfo("|cffff0000Export failed:|r " .. err)
        return
    end
    local editBox = CreateFrame("EditBox", nil, UIParent)
    editBox:SetText(encoded)
    editBox:SetFocus()
    editBox:HighlightText()
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:Hide()
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        self:Hide()
    end)
    Ether:EtherInfo("|cff00ff00Profile copied to clipboard!|r")
    Ether:EtherInfo("|cff888888You can now paste it anywhere|r")

    return encoded
end

function Ether:CopyProfile(sourceName, targetName)
    if not ETHER_DATABASE_DX_AA.profiles[sourceName] then
        return false, "Source profile not found"
    end
    if ETHER_DATABASE_DX_AA.profiles[targetName] then
        return false, "Target profile already exists"
    end
    ETHER_DATABASE_DX_AA.profiles[targetName] = Ether.CopyTable(ETHER_DATABASE_DX_AA.profiles[sourceName])
    return true, "Profile copied"
end

local function RefreshLayout(data)
    if type(data) ~= "table" then return end
    for _, button in pairs(data) do
        if not button then return end
        button:SetBackdrop({
            bgFile = Ether.DB[811]["background"],
            insets = {left = -2, right = -2, top = -2, bottom = -2}
        })
        if button.name then
            button.name:SetFont(Ether.DB[811].font or unpack(Ether.mediaPath.expressway), 12, "OUTLINE")

        end
        if button.healthBar then
            button.healthBar:SetStatusBarTexture((Ether.DB[811].bar or unpack(Ether.mediaPath.blankBar)))
        end
    end
end

function Ether:ProfileRefreshLayout()
    if not Ether.unitButtons then return end
    local raid = Ether.unitButtons.raid
    local solo = Ether.unitButtons.solo
    if solo then
        RefreshLayout(solo)
    end
    if raid then
        RefreshLayout(raid)
    end
end

function Ether:ImportProfile(encodedString)
    if not encodedString or encodedString == "" then
        return false, "Empty import string"
    end

    Ether:CreatePositionSection(Ether.UIPanel)
    Ether:CreateCustomSection(Ether.UIPanel)

    local decoded = Ether.Base64Decode(encodedString)
    if not decoded then
        return false, "Invalid Base64 encoding"
    end

    local success, importedData = Ether.StringToTbl(decoded)
    if not success then
        return false, "Invalid data format"
    end

    if type(importedData) ~= "table" then
        return false, "Invalid data: expected table"
    end

    if not importedData.data then
        return false, "No profile data found"
    end

    local importedName = importedData.profileName or "Imported"
    local baseName = importedName
    local counter = 1

    while ETHER_DATABASE_DX_AA.profiles[importedName] do
        counter = counter + 1
        importedName = baseName .. "_" .. counter
    end

    ETHER_DATABASE_DX_AA.profiles[importedName] = Ether.CopyTable(importedData.data)

    ETHER_DATABASE_DX_AA.currentProfile = importedName

    Ether.DB = Ether.CopyTable(ETHER_DATABASE_DX_AA.profiles[importedName])

    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
    Ether:ProfileRefreshLayout()
    return true, "Successfully imported as: " .. importedName
end

function Ether:SwitchProfile(name)

    if not ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile not found"
    end
    Ether:CreatePositionSection(Ether.UIPanel)
    Ether:CreateCustomSection(Ether.UIPanel)
    local editor = Ether.UIPanel.Frames["EDITOR"]

    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.CopyTable(Ether.DB)

    ETHER_DATABASE_DX_AA.currentProfile = name
    Ether.DB = Ether.CopyTable(ETHER_DATABASE_DX_AA.profiles[name])

    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)

    Ether:ProfileRefreshLayout()
    return true, "Switched to " .. name
end
function Ether:DeleteProfile(name)

    Ether:CreatePositionSection(Ether.UIPanel)
    Ether:CreateCustomSection(Ether.UIPanel)
    local editor = Ether.UIPanel.Frames["EDITOR"]
    if not ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile not found"
    end
    local profileCount = 0
    for _ in pairs(ETHER_DATABASE_DX_AA.profiles) do
        profileCount = profileCount + 1
    end
    if profileCount <= 1 then
        return false, "Cannot delete the only profile"
    end
    if name == ETHER_DATABASE_DX_AA.currentProfile then
        local otherProfile
        for profileName in pairs(ETHER_DATABASE_DX_AA.profiles) do
            if profileName ~= name then
                otherProfile = profileName
                break
            end
        end
        if not otherProfile then
            return false, "No other profile available"
        end
        local success, msg = Ether:SwitchProfile(otherProfile)
        if not success then
            return false, "Failed to switch profile: " .. msg
        end
    end
    ETHER_DATABASE_DX_AA.profiles[name] = nil
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
    return true, "Profile deleted"
end

function Ether:ShowExportPopup(encoded)
    if not Ether.ExportPopup then
        Ether:CreateExportPopup()
    end
    Ether.ExportPopup.EditBox:SetText(encoded)
    Ether.ExportPopup:Show()
end

function Ether:GetCharacterKey()
    return Ether.playerName .. "-" .. realmName
end

function Ether:GetCurrentProfile()
    return ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile]
end

function Ether:GetCurrentProfileString()
    return ETHER_DATABASE_DX_AA.currentProfile
end

function Ether:GetProfileList()
    local list = {}
    for name in pairs(ETHER_DATABASE_DX_AA.profiles) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function Ether:CreateProfile(name)
    if ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile already exists"
    end

    ETHER_DATABASE_DX_AA.profiles[name] = Ether.CopyTable(Ether.DataDefault)
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
    Ether:ProfileRefreshLayout()
    return true, "Profile created"
end

function Ether:RenameProfile(oldName, newName)
    if not ETHER_DATABASE_DX_AA.profiles[oldName] then
        return false, "Profile not found"
    end
    if ETHER_DATABASE_DX_AA.profiles[newName] then
        return false, "Name already taken"
    end
    ETHER_DATABASE_DX_AA.profiles[newName] = ETHER_DATABASE_DX_AA.profiles[oldName]
    ETHER_DATABASE_DX_AA.profiles[oldName] = nil
    if ETHER_DATABASE_DX_AA.currentProfile == oldName then
        ETHER_DATABASE_DX_AA.currentProfile = newName
    end
    return true, "Profile renamed"
end

function Ether:ResetProfile()

    Ether.DB = Ether.CopyTable(Ether.DataDefault)

    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.CopyTable(Ether.DataDefault)

    wipe(Ether.DB[1003])
    Ether.UIPanel.SpellId = nil
    Ether:CreatePositionSection(Ether.UIPanel)
    Ether:CreateCustomSection(Ether.UIPanel)
    local editor = Ether.UIPanel.Frames["EDITOR"]
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:ProfileRefreshLayout()
    return true, "Profile reset to default"
end
