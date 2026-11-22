-- remap/main.lua -- press-to-bind controller mapping.
--
-- Runs as a separate LÖVE process, launched by McpeLauncher.sh with gptokeyb
-- stopped so the raw pad events reach SDL. Writes map_a..map_rb into
-- settings.conf; McpeLauncher.sh applies them to the SDL mapping.

local UI = require("ui")

local ACTIONS = {
    { key = "map_a", label = "A" },
    { key = "map_b", label = "B" },
    { key = "map_x", label = "X" },
    { key = "map_y", label = "Y" },
    { key = "map_lb", label = "L1" },
    { key = "map_rb", label = "R1" },
    { key = "map_lt", label = "L2", axis = true },
    { key = "map_rt", label = "R2", axis = true },
}

local ORDER = {
    "controller_mode", "swap_sticks", "invert_x", "invert_y",
    "ab_swap", "swap_ab", "swap_xy", "swap_shoulders", "rotation",
    "map_a", "map_b", "map_x", "map_y", "map_lb", "map_rb", "map_lt", "map_rt",
    "map_base",
}
local DEFAULTS = {
    controller_mode = "auto", swap_sticks = "0", invert_x = "0",
    invert_y = "0", ab_swap = "auto", swap_ab = "0", swap_xy = "0",
    swap_shoulders = "0", rotation = "auto",
    map_a = "auto", map_b = "auto", map_x = "auto",
    map_y = "auto", map_lb = "auto", map_rb = "auto",
    map_lt = "auto", map_rt = "auto", map_base = "",
}

local LIMIT = 12          -- seconds per button before it is skipped
local NO_PAD_LIMIT = 15   -- give up when nothing at all arrives
local EXIT_DELAY = 2.5

local settingsPath = nil
local settings, entries = {}, {}
local step = 1
local state = "capture"   -- capture | saved | error
local timer, exitTimer = 0, 0
local note = nil
local sawInput = false
local lastJoystick = -10
local lastAssign = -10
local testing = false
local axisArmed = true
local shots, shotIndex, shotFrames = false, 0, 0
local selftest = false

-- ---------------------------------------------------------------- settings

local function loadSettings()
    settings = {}
    for k, v in pairs(DEFAULTS) do settings[k] = v end
    entries = {}
    local f = io.open(settingsPath, "r")
    if f then
        for line in f:lines() do
            local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
            if k and k ~= "" then
                if DEFAULTS[k] ~= nil and k:match("^map_") and v:match("^%d+$") then
                    v = "b" .. v
                end
                entries[#entries + 1] = { k = k, v = v }
                if DEFAULTS[k] ~= nil then settings[k] = v end
            end
        end
        f:close()
    end
end

local function save()
    local seen = {}
    for _, e in ipairs(entries) do
        seen[e.k] = true
        if DEFAULTS[e.k] ~= nil then e.v = settings[e.k] end
    end
    for _, k in ipairs(ORDER) do
        if not seen[k] then entries[#entries + 1] = { k = k, v = settings[k] } end
    end
    local f = io.open(settingsPath, "w")
    if not f then return false end
    for _, e in ipairs(entries) do
        f:write(e.k .. "=" .. tostring(e.v or "") .. "\n")
    end
    f:close()
    return true
end

-- ---------------------------------------------------------------- capture

local function displayValue(key)
    local v = settings[key]
    if not v or v == "auto" then return "--" end
    if v:sub(1, 1) == "a" then return "AXIS " .. v:sub(2) end
    if v:sub(1, 1) == "b" then return "BTN " .. v:sub(2) end
    return "BTN " .. v
end

-- LÖVE reports joystick buttons and axes starting at 1, while SDL gamepad
-- mappings (and therefore the game) use 0-based indices: pressing the first
-- button must write b0, not b1.
local function sdlButton(button)
    return math.max(0, (button or 1) - 1)
end

local function sdlAxis(axis)
    return math.max(0, (axis or 1) - 1)
end

local function assignValue(value)
    if state ~= "capture" or not value then return end
    local now = love.timer.getTime()
    -- SDL reports one press as both a joystick and a gamepad event on some
    -- builds. Ignore the second one so it cannot bind the next action.
    if not testing and now - lastAssign < 0.2 then return end
    lastAssign = now
    local action = ACTIONS[step]
    if not action then return end
    sawInput = true
    -- Never leave two actions on the same physical input: the previous owner
    -- inherits whatever this action had.
    for _, other in ipairs(ACTIONS) do
        if other.key ~= action.key and settings[other.key] == value then
            settings[other.key] = settings[action.key]
            break
        end
    end
    settings[action.key] = value
    note = action.label .. "  =  " .. displayValue(action.key)
    step = step + 1
    timer = 0
    if step > #ACTIONS then
        if save() then
            state = "saved"
        else
            state = "error"
            note = "Cannot write settings.conf"
        end
        exitTimer = EXIT_DELAY
    end
end

local function finishWithoutInput()
    state = "error"
    note = "No controller input detected"
    exitTimer = EXIT_DELAY + 2
end

local function buttonIndexFromMapping(name)
    local list = love.joystick.getJoysticks()
    local js = list and list[1]
    if not js or not js.getGamepadMappingString then return nil end
    local mapping = js:getGamepadMappingString()
    if not mapping then return nil end
    local n = mapping:match("," .. name .. ":b(%d+)")
    return n and tonumber(n) or nil
end

function love.joystickpressed(_, button)
    lastJoystick = love.timer.getTime()
    assignValue("b" .. sdlButton(button))
end

-- Triggers are analog axes on most handhelds; only the L2/R2 steps accept
-- them so a stick movement can never be captured as a face button.
function love.joystickaxis(_, axis, value)
    if state ~= "capture" then return end
    local action = ACTIONS[step]
    if not action or not action.axis then return end
    if not axisArmed then
        if math.abs(value) < 0.3 then axisArmed = true end
        return
    end
    if math.abs(value) >= 0.6 then
        axisArmed = false
        lastJoystick = love.timer.getTime()
        assignValue("a" .. sdlAxis(axis))
    end
end

-- Fallback for pads that only surface mapped gamepad events. The mapping
-- string already uses SDL's 0-based indices, so no conversion is needed.
function love.gamepadpressed(_, name)
    if love.timer.getTime() - lastJoystick < 0.3 then return end
    local index = buttonIndexFromMapping(name)
    if index then assignValue("b" .. index) end
end

-- Keep the pad's current SDL mapping. McpeLauncher.sh uses it as the base when
-- the firmware does not provide an sdl_controllerconfig entry at all.
local function captureBaseMapping()
    local list = love.joystick.getJoysticks()
    local js = list and list[1]
    if not js or not js.getGamepadMappingString then return end
    local mapping = js:getGamepadMappingString()
    if mapping and mapping ~= "" then
        settings.map_base = mapping:gsub("[\r\n]", "")
    end
end

-- ---------------------------------------------------------------- update

local function stepCaptured()
    return displayValue(ACTIONS[step] and ACTIONS[step].key) ~= "--"
end

function love.update(dt)
    if shots then
        shotFrames = shotFrames + 1
        if shotFrames == 2 then
            local s = SHOTS[shotIndex]
            if s then love.graphics.captureScreenshot(s.name .. ".png") end
        elseif shotFrames == 6 then
            if shotIndex >= #SHOTS then love.event.quit(0) return end
            shotIndex = shotIndex + 1
            shotFrames = 0
            SHOTS[shotIndex].apply()
        end
        return
    end
    if selftest then return end

    if state == "capture" then
        timer = timer + dt
        if not sawInput and timer >= NO_PAD_LIMIT then
            finishWithoutInput()
            return
        end
        if timer >= LIMIT then
            step = step + 1
            timer = 0
            note = "Skipped"
            if step > #ACTIONS then
                if save() then
                    state = "saved"
                else
                    state = "error"
                    note = "Cannot write settings.conf"
                end
                exitTimer = EXIT_DELAY
            end
        end
    elseif state == "saved" or state == "error" then
        exitTimer = exitTimer - dt
        if exitTimer <= 0 then love.event.quit(0) end
    end
end

-- ---------------------------------------------------------------- draw

local function drawHeader()
    local L = UI.L
    UI.set(UI.c.header)
    love.graphics.rectangle("fill", 0, 0, L.w, L.header)
    UI.set(UI.c.line)
    love.graphics.rectangle("fill", 0, L.header - 1, L.w, 1)
    UI.logo(16, 10, 26)
    UI.textMidCapsBold(UI.font.pixel16, "BUTTON MAP", 52, 0, 400, L.header, "left", UI.c.text)
    local label = math.min(step, #ACTIONS) .. " / " .. #ACTIONS
    local w = UI.font.pixel8:getWidth(label) + 10
    UI.badge(label, L.w - L.margin - w, 14, nil)
end

local function drawSummary()
    local L = UI.L
    local w, h, gap = 146, 44, 8
    for i, action in ipairs(ACTIONS) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local x = L.margin + col * (w + gap)
        local y = 212 + row * (h + gap)
        local active = (i == step and state == "capture")
        UI.panel(x, y, w, h, {
            fill = active and UI.c.tintFocus or UI.c.panel,
            focus = active,
        })
        UI.textBold(UI.font.pixel16, action.label, x + 12, y + 12, 46, "left",
            active and UI.c.greenHi or UI.c.text)
        local value = displayValue(action.key)
        local vf = UI.font.pixel8
        local vw = vf:getWidth(value) + 10
        UI.badge(value, x + w - 12 - vw, y + 13, value == "--" and nil or "green")
    end
end

local function drawCapture()
    local L = UI.L
    local action = ACTIONS[math.min(step, #ACTIONS)]
    UI.panel(L.margin, 64, L.w - 2 * L.margin, 128, { fill = UI.c.panelAlt })
    local prompt = action.axis and "PULL THE PHYSICAL TRIGGER FOR"
        or "PRESS THE PHYSICAL BUTTON FOR"
    UI.textBold(UI.font.pixel8, prompt, L.margin, 78,
        L.w - 2 * L.margin, "center", UI.c.textDim)
    UI.textMidCapsBold(UI.font.pixel24, action.label, L.margin, 92,
        L.w - 2 * L.margin, 66, "center", UI.c.greenHi)
    local remain = math.max(0, math.ceil(LIMIT - timer))
    UI.text(UI.font.body9,
        "Step " .. step .. " of " .. #ACTIONS .. "  -  auto-skip in " .. remain .. "s",
        L.margin, 162, L.w - 2 * L.margin, "center", UI.c.textMuted)

    drawSummary()

    UI.progress(L.margin, 320, L.w - 2 * L.margin, 12, timer / LIMIT, false, 0)
    UI.text(UI.font.body9, note or "Buttons already assigned stay as they are.",
        L.margin, 344, L.w - 2 * L.margin, "center", UI.c.textDim)
    UI.text(UI.font.body9,
        "This map is used inside the game, not by this launcher menu.",
        L.margin, 366, L.w - 2 * L.margin, "center", UI.c.textMuted)

    UI.footer({}, step .. " / " .. #ACTIONS)
end

local function drawResult()
    local L = UI.L
    local ok = state == "saved"
    UI.panel(L.margin, 70, L.w - 2 * L.margin, 116, { fill = UI.c.panelAlt })
    UI.textMidCapsBold(UI.font.pixel24, ok and "SAVED" or "NO CONTROLLER",
        L.margin, 84, L.w - 2 * L.margin, 46, "center",
        ok and UI.c.greenHi or UI.c.red)
    UI.text(UI.font.body11, note or "", L.margin, 132,
        L.w - 2 * L.margin, "center", ok and UI.c.textDim or UI.c.textMuted)
    drawSummary()
    local msg
    if ok then
        msg = "Saved for the game. Returning to the menu..."
    else
        msg = "Returning to the menu..."
    end
    UI.text(UI.font.body11, msg, L.margin, 366, L.w - 2 * L.margin, "center", UI.c.textDim)
    UI.footer({}, "")
end

function love.draw()
    local L = UI.L
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    drawHeader()
    if state == "capture" then
        drawCapture()
    else
        drawResult()
    end
end

-- ---------------------------------------------------------------- shots

local function resetCapture()
    settings = {}
    for k, v in pairs(DEFAULTS) do settings[k] = v end
    entries = {}
    step = 1
    timer = 0
    state = "capture"
    note = nil
    sawInput = true
    axisArmed = true
end

SHOTS = {
    {
        name = "remap-capture",
        apply = function()
            resetCapture()
            settings.map_a = "b0"
            step = 2
            note = "A  =  BTN 0"
        end,
    },
    {
        name = "remap-saved",
        apply = function()
            resetCapture()
            settings.map_a = "b0"
            settings.map_b = "b1"
            settings.map_x = "b2"
            settings.map_y = "b3"
            settings.map_lb = "b4"
            settings.map_rb = "b5"
            settings.map_lt = "a4"
            settings.map_rt = "a5"
            step = #ACTIONS + 1
            state = "saved"
            note = "A, B, X, Y, L1, R1, L2 and R2 updated"
        end,
    },
}

-- ---------------------------------------------------------------- selftest

local function runSelftest()
    testing = true
    local tmp = (os.getenv("TEMP") or "/tmp") .. "/mcpe-remap-selftest.conf"
    settingsPath = tmp
    os.remove(tmp)
    loadSettings()

    assignValue("b3")   -- A
    assignValue("b1")   -- B
    assignValue("b2")   -- X
    assignValue("b0")   -- Y
    assignValue("b4")   -- L1
    assignValue("b5")   -- R1
    assignValue("a4")   -- L2
    assignValue("a5")   -- R2

    local fails = {}
    local function check(cond, msg)
        if not cond then fails[#fails + 1] = msg end
    end
    -- LÖVE hands out 1-based indices; the SDL mapping is 0-based.
    check(sdlButton(1) == 0, "button 1 -> b0")
    check(sdlButton(4) == 3, "button 4 -> b3")
    check(sdlAxis(1) == 0, "axis 1 -> a0")
    check(sdlAxis(5) == 4, "axis 5 -> a4")
    local f = io.open(tmp, "r")
    local body = f and f:read("*a") or ""
    if f then f:close() end
    check(state == "saved", "state saved")
    check(body:find("map_a=b3", 1, true) ~= nil, "map_a written")
    check(body:find("map_b=b1", 1, true) ~= nil, "map_b written")
    check(body:find("map_rt=a5", 1, true) ~= nil, "map_rt written")

    -- Duplicate binding must hand the old value back to the other action.
    settings = {}
    for k, v in pairs(DEFAULTS) do settings[k] = v end
    step = 1
    state = "capture"
    assignValue("b3")   -- A = b3
    assignValue("b3")   -- B = b3, A must fall back to auto
    check(settings.map_b == "b3", "duplicate reassign")
    check(settings.map_a == "auto", "duplicate swaps old value")

    os.remove(tmp)
    print(#fails == 0 and "REMAP SELFTEST PASS"
        or ("REMAP SELFTEST FAIL: " .. table.concat(fails, "; ")))
    love.event.quit(#fails == 0 and 0 or 1)
end

-- ---------------------------------------------------------------- load

function love.load(args)
    for _, a in ipairs(args or {}) do
        if a == "--shots" then
            shots = true
        elseif a == "--selftest" then
            selftest = true
        elseif a:sub(1, 1) == "/" or a:match("^%a:[/\\]") then
            settingsPath = a
        end
    end
    if not settingsPath then
        settingsPath = (os.getenv("MCPE_GAMEDIR") or ".") .. "/settings.conf"
    end
    if shots or selftest then
        love.window.setMode(640, 480, {
            fullscreen = false, vsync = 1, resizable = false, msaa = 0,
        })
    end
    UI.load()
    if selftest then
        runSelftest()
        return
    end
    loadSettings()
    if shots then
        shotIndex = 1
        shotFrames = 0
        SHOTS[1].apply()
    else
        captureBaseMapping()
    end
end
