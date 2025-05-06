if GetLocale() == "enUS" or GetLocale() == "enGB" then
    local L = {}
    LOCALIZATION_L = L

    L.MAIN_ADDON = "|cff00ccffEtherWatch:|r "

    L.MINIMAP_TOOLTIP_HEADER = "EtherWatch"
    L.MINIMAP_TOOLTIP_NAME = "Click for Settings"
    L.MINIMAP_TOOLTIP_FOOTER = "(enUS/enGB Version)"

    L.ERROR_INITIALIZING_MODULE = "|cFFFF0000Error initializing module:|r"
    L.PROFILE_REALLY_DELETE = "Really delete profile |cffff0000%s|r?"
    L.DELETE = "Delete"
    L.CANCEL = "Cancel"
    L.DELETED = "Deleted"
    L.ERROR_PROFILE_NAME = "|cFFFF0000Error:|r No profile name specified"
    L.ASSERT_DATABASE = "|cFFFF0000Error:|r Failed to create database"
    L.PROFILE_CHANGED = "|cff00ff00Switched to profile:|r |cff00ccff%s|r"
    L.PROFILE_COPIED = "|cff00ff00Copied to profile:|r |cff00ccff%s|r"
    L.PROFILE_RESET = "|cff00ff00Reset profile:|r |cff00ccff%s|r"
    L.PROFILE_DELETED = "|cffff0000Deleted profile:|r |cff00ccff%s|r (switched to default)"
    L.PROFILE_UNKNOWN = "Unknown"
    L.SETTINGS_UPDATED = "|cff00ff00Settings updated|r"

    L.DRINK_NAME = "Drink"
end
