local Ether      = select(2, ...)
local Smooth     = Ether.Smooth

-- Lokale Referenzen für Speed (WICHTIG in OnUpdate Loops!)
local min, abs   = math.min, math.abs
local pairs      = pairs
local next       = next

Smooth.SMOOTHBAR = {}

if not Smooth.UPDATER then
    Smooth.UPDATER = CreateFrame('Frame')
end

local function SmoothBar_SetValue(bar, value)
    local data = Smooth.SMOOTHBAR[bar]
    if not data then
        -- Fallback, falls die Bar irgendwie aus der Tabelle geflogen ist
        bar:SetValue_(value)
        return
    end

    -- Nur triggern, wenn sich wirklich was ändert
    if data.target ~= value then
        data.target = value
        data.needsUpdate = true

        -- Optional: Wenn der Balken voll ist (z.B. Target Wechsel),
        -- sofort springen statt langsam hochzuzählen?
        -- if value == select(2, bar:GetMinMaxValues()) then
        --     data.current = value
        --     data.needsUpdate = false
        --     bar:SetValue_(value)
        -- end
    end
end

local function SmoothBar_OnUpdate(self, elapsed)
    -- Kein Throttle (0.01) nötig!
    -- Framerate-Unabhängigkeit regelst du über 'elapsed'.
    -- Throttle sorgt nur für Ruckeln bei 144Hz Monitoren.

    local count = 0 -- Nur zum Prüfen, ob wir den Updater stoppen können

    for bar, data in pairs(Smooth.SMOOTHBAR) do
        if data.needsUpdate then
            local cur = data.current
            local target = data.target
            local diff = target - cur

            -- Ist die Differenz klein genug? Dann fertig.
            if abs(diff) < 0.1 then -- 0.1 ist oft besser als 0.01 bei HP Werten von 500.000
                data.current = target
                data.needsUpdate = false
                bar:SetValue_(target)
            else
                -- Die Formel für Framerate-unabhängiges Smoothing:
                -- Je höher 'speed', desto schneller
                local new = cur + diff * min(elapsed * data.speed, 1)
                data.current = new
                bar:SetValue_(new)
                count = count + 1
            end
        end
    end

    -- Wenn sich gar nichts mehr bewegt, Script abschalten um CPU zu sparen
    if count == 0 then
        self:SetScript('OnUpdate', nil)
    end
end

local function SmoothBar(bar, speed)
    if not bar or Smooth.SMOOTHBAR[bar] then return end

    local current = bar:GetValue()
    -- Wenn Bar leer ist (0), holen wir uns den echten Wert direkt,
    -- damit sie nicht von 0 hochfährt beim Einloggen/Reload.
    if current == 0 and bar.unit and UnitExists(bar.unit) then
        -- Optimierung: UnitHealth ist C-Code, sehr schnell
        current = UnitHealth(bar.unit)
    end

    Smooth.SMOOTHBAR[bar] = {
        current     = current,
        target      = current,
        speed       = speed or 15, -- 15 ist "snappy", 8 ist "langsam"
        needsUpdate = false
    }

    -- Hook
    if not bar.SetValue_ then
        bar.SetValue_ = bar.SetValue
        bar.SetValue  = SmoothBar_SetValue
    end

    -- Startet den Updater sofort beim Erstellen, falls nötig
    -- (oder beim ersten SetValue Aufruf, siehe oben logic)
end

local function RemoveBar(bar)
    if not bar or not Smooth.SMOOTHBAR[bar] then return end

    -- Restore original function
    if bar.SetValue_ then
        bar.SetValue = bar.SetValue_
        bar.SetValue_ = nil
    end

    Smooth.SMOOTHBAR[bar] = nil
end

Smooth.SmoothBar = SmoothBar
Smooth.RemoveBar = RemoveBar
