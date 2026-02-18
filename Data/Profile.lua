local _, Ether = ...
local realmName = GetRealmName()

function Ether:ExportCurrentProfile()
    local editor = Ether.UIPanel.Frames["EDITOR"]
    if not editor.Created then
        Ether:CreateCustomSection(Ether.UIPanel)
        editor.Created = true
    end
    local charKey = Ether:GetCharacterKey()
    if charKey then
        ETHER_DATABASE_DX_AA.profiles[charKey] = Ether.CopyTable(Ether.DB)
    end
    if charKey and ETHER_DATABASE_DX_AA.profiles[charKey] then
        ETHER_DATABASE_DX_AA.currentProfile = charKey
    end
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
    local profileName = ETHER_DATABASE_DX_AA.currentProfile
    local profileData = ETHER_DATABASE_DX_AA.profiles[profileName]
    if not profileData then
        return nil, "Current profile not found"
    end
    local exportData = {
        version = 1.0,
        addon = "Ether",
        timestamp = time(),
        profileName = profileName,
        data = Ether.CopyTable(profileData),
    }
    local serialized = Ether.TblToString(exportData)
    local encoded = Ether.Base64Encode(serialized)
    Ether.DebugOutput("|cff00ff00Export ready:|r " .. profileName)
    Ether.DebugOutput("|cff888888Size:|r " .. #encoded .. " characters")
    return encoded
end

function Ether:ImportProfile(encodedString)
    if ETHER_DATABASE_DX_AA["VERSION"] < Ether.REQUIREMENT_VERSION then
        return false, "The import data is too old"
    end
    if not encodedString or encodedString == "" then
        return false, "Empty import string"
    end

    Ether:CreateCustomSection(Ether.UIPanel)
    Ether:CreatePositionSection(Ether.UIPanel)

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

    if importedData.addon ~= "Ether" then
        return false, "Not an Ether profile"
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

    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(Ether.UIPanel.Frames["EDITOR"])
    return true, "Successfully imported as: " .. importedName
end

function Ether:ExportProfileToClipboard()
    local encoded, err = Ether:ExportCurrentProfile()
    if not encoded then
        Ether.DebugOutput("|cffff0000Export failed:|r " .. err)
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
    Ether.DebugOutput("|cff00ff00Profile copied to clipboard!|r")
    Ether.DebugOutput("|cff888888You can now paste it anywhere|r")

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

function Ether:SwitchProfile(name)
    local editor = Ether.UIPanel.Frames["EDITOR"]
    local auras = Ether.UIPanel.Frames["AURAS"]
    if not editor.Created or not auras.Created then
        Ether:CreateCustomSection(Ether.UIPanel)
        editor.Created, auras.Created = true, true
    end
    if not ETHER_DATABASE_DX_AA.profiles[name] then
        return false, "Profile not found"
    end

    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.CopyTable(Ether.DB)

    ETHER_DATABASE_DX_AA.currentProfile = name
    Ether.DB = Ether.CopyTable(ETHER_DATABASE_DX_AA.profiles[name])

    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
    return true, "Switched to " .. name
end
function Ether:DeleteProfile(name)
    local editor = Ether.UIPanel.Frames["EDITOR"]
    local auras = Ether.UIPanel.Frames["AURAS"]
    if not editor.Created or not auras.Created then
        Ether:CreateCustomSection(Ether.UIPanel)
        editor.Created, auras.Created = true, true
    end
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
    local editor = Ether.UIPanel.Frames["EDITOR"]
    if not editor.Created then
        Ether:CreateCustomSection(Ether.UIPanel)
        editor.Created = true
    end
    ETHER_DATABASE_DX_AA.profiles[name] = Ether.CopyTable(Ether.DataDefault)
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
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
    local editor = Ether.UIPanel.Frames["EDITOR"]
    local auras = Ether.UIPanel.Frames["AURAS"]
    if not editor.Created or not auras.Created then
        Ether:CreateCustomSection(Ether.UIPanel)
        editor.Created, auras.Created = true, true
    end
    ETHER_DATABASE_DX_AA.profiles[ETHER_DATABASE_DX_AA.currentProfile] = Ether.CopyTable(Ether.DataDefault)
    Ether.DB = Ether.CopyTable(Ether.DataDefault)
    wipe(Ether.DB[1003])
    Ether.UIPanel.SpellId = nil
    Ether:UpdateAuraList()
    Ether:UpdateEditor(editor)
    Ether:RefreshAllSettings()
    Ether:RefreshFramePositions()
    return true, "Profile reset to default"
end
