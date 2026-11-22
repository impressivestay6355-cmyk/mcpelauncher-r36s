-- screens/settings.lua -- controller and display options.
-- Values are applied by McpeLauncher.sh on the next launch; the menu only
-- stores them in settings.conf (plus rotation.txt for the screen rotation).

local UI = require("ui")

local Settings = {}

local ANALOG = {
    {
        key = "controller_mode", label = "PAD MODE",
        desc = "AUTO keeps the firmware mapping and gptokeyb. DIRECT lets the game read the controller through SDL; use it when buttons repeat or the camera moves by itself.",
        values = { "auto", "direct" }, labels = { "AUTO", "DIRECT" },
    },
    {
        key = "swap_sticks", label = "SWAP STICKS",
        desc = "Swaps the left and right analog sticks.",
        toggle = true, values = { "0", "1" }, labels = { "OFF", "ON" },
    },
    {
        key = "invert_x", label = "INVERT LOOK X",
        desc = "Inverts the camera left / right axis.",
        toggle = true, values = { "0", "1" }, labels = { "OFF", "ON" },
    },
    {
        key = "invert_y", label = "INVERT LOOK Y",
        desc = "Inverts the camera up / down axis.",
        toggle = true, values = { "0", "1" }, labels = { "OFF", "ON" },
    },
    {
        key = "ab_swap", label = "CONFIRM BUTTON",
        desc = "Overrides the automatic A / B detection. AUTO keeps what the firmware reports.",
        values = { "auto", "normal", "swapped" }, labels = { "AUTO", "A", "B" },
    },
}

local BUTTONS = {
    {
        key = "swap_ab", label = "SWAP A / B",
        desc = "Sends the physical A and B buttons the other way round in game.",
        toggle = true, values = { "0", "1" }, labels = { "OFF", "ON" },
    },
    {
        key = "swap_xy", label = "SWAP X / Y",
        desc = "Sends the physical X and Y buttons the other way round in game.",
        toggle = true, values = { "0", "1" }, labels = { "OFF", "ON" },
    },
    {
        key = "swap_shoulders", label = "SWAP L1 / R1",
        desc = "Swaps the left and right shoulder buttons in game.",
        toggle = true, values = { "0", "1" }, labels = { "OFF", "ON" },
    },
    {
        key = "button_map", label = "BUTTON MAP",
        desc = "Opens the remap screen: press each physical button once to assign A, B, X, Y, L1, R1, L2 and R2 in game.",
        action = "remap",
    },
    {
        key = "rotation", label = "SCREEN ROTATION",
        desc = "Forces the display rotation for panels mounted rotated. Restart the game to apply.",
        values = { "auto", "0", "90", "180", "270" },
        labels = { "AUTO", "0", "90", "180", "270" },
    },
    {
        key = "reset", label = "RESET CONTROLS",
        desc = "Puts every control option on this screen back to its default.",
        action = true,
    },
}

local ROWS = {}
for _, row in ipairs(ANALOG) do ROWS[#ROWS + 1] = row end
for _, row in ipairs(BUTTONS) do ROWS[#ROWS + 1] = row end

local LIST_Y, ROW_H, GAP = 72, 44, 6
local COL_GAP = 12
local COL_W = math.floor((UI.L.w - 2 * UI.L.margin - COL_GAP) / 2)
local LEFT_ROWS = 5
local PER_COL = 6

Settings.rows = ROWS

local MAP_KEYS = { map_a = true, map_b = true, map_x = true, map_y = true,
                   map_lb = true, map_rb = true }

local function hasCustomMap(settings)
    for key in pairs(MAP_KEYS) do
        local v = settings[key]
        if v and v ~= "auto" then return true end
    end
    return false
end

local function rowPos(index)
    local col = (index <= LEFT_ROWS) and 0 or 1
    local row = (col == 0) and (index - 1) or (index - LEFT_ROWS - 1)
    return UI.L.margin + col * (COL_W + COL_GAP), LIST_Y + row * (ROW_H + GAP)
end

local function currentLabel(row, settings)
    if row.key == "button_map" then
        return hasCustomMap(settings) and "CUSTOM" or "DEFAULT"
    end
    if row.action then return "RESET" end
    local value = settings[row.key]
    for i, v in ipairs(row.values) do
        if v == value then return row.labels[i] end
    end
    return row.labels[1]
end

local function cycle(app, dir)
    local row = ROWS[app.selSetting]
    if not row or row.action then return end
    local value = app.settings[row.key]
    local index = 1
    for i, v in ipairs(row.values) do
        if v == value then index = i break end
    end
    local n = #row.values
    index = ((index - 1 + dir) % n) + 1
    app:setSetting(row.key, row.values[index])
end

local function openReset(app)
    app:openModal({
        title = "RESET CONTROLS?",
        body = {
            "Pad mode, sticks, camera, buttons,",
            "confirm and rotation return to their defaults.",
        },
        confirmLabel = "RESET",
        variant = "danger",
        onConfirm = function() app:resetSettings() end,
    })
end

function Settings.enter(app)
    app.selSetting = math.max(1, math.min(app.selSetting or 1, #ROWS))
end

function Settings.key(app, act)
    if act == "up" then
        app.selSetting = math.max(1, app.selSetting - 1)
    elseif act == "down" then
        app.selSetting = math.min(#ROWS, app.selSetting + 1)
    elseif act == "left" then
        cycle(app, -1)
    elseif act == "right" then
        cycle(app, 1)
    elseif act == "a" then
        local row = ROWS[app.selSetting]
        if row.action == "remap" then
            app:requestRemap()
        elseif row.action then
            openReset(app)
        else
            cycle(app, 1)
        end
    elseif act == "x" then
        openReset(app)
    elseif act == "b" then
        app:switch("home")
    end
end

-- ---------------------------------------------------------------- drawing

local function drawHeader(app)
    local L = UI.L
    UI.set(UI.c.header)
    love.graphics.rectangle("fill", 0, 0, L.w, L.header)
    UI.set(UI.c.line)
    love.graphics.rectangle("fill", 0, L.header - 1, L.w, 1)
    UI.logo(16, 10, 26)
    UI.textMidCapsBold(UI.font.pixel16, "SETTINGS", 52, 0, 400, L.header, "left", UI.c.text)
    local ver = app.portVersion ~= "" and ("v" .. app.portVersion) or "dev"
    local w = UI.font.pixel8:getWidth(ver) + 10
    UI.badge(ver, L.w - L.margin - w, 14, nil)
end

function Settings.draw(app)
    local L = UI.L
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    drawHeader(app)

    UI.textBold(UI.font.pixel8, "CONTROLS", L.margin, 56, COL_W, "left", UI.c.text, 0.85)
    UI.textBold(UI.font.pixel8, "BUTTONS & DISPLAY", L.margin + COL_W + COL_GAP, 56,
        COL_W, "left", UI.c.text, 0.85)

    for i, row in ipairs(ROWS) do
        local x, y = rowPos(i)
        local focused = i == app.selSetting
        local accent
        if row.action and focused then
            accent = (row.action == "remap") and "blue" or "red"
        end
        UI.settingRow(x, y, COL_W, ROW_H, {
            label = row.label,
            value = currentLabel(row, app.settings),
            toggle = row.toggle,
            on = row.toggle and app.settings[row.key] == "1" or false,
            focus = focused,
            adjustable = not row.action,
            accent = accent,
        })
    end

    local helpY = LIST_Y + PER_COL * (ROW_H + GAP) + 2
    UI.panel(L.margin, helpY, L.w - 2 * L.margin, 42, { fill = UI.c.panelAlt, bevel = false })
    local row = ROWS[app.selSetting]
    local lines = UI.wrap(UI.font.body9, row.desc or "", L.w - 2 * L.margin - 24, 2)
    for i, line in ipairs(lines) do
        UI.text(UI.font.body9, line, L.margin + 12, helpY + 8 + (i - 1) * 13,
            L.w - 2 * L.margin - 24, "left", UI.c.textDim)
    end
    UI.text(UI.font.body9, "Changes are saved immediately and apply when the game starts.",
        L.margin, helpY + 48, L.w - 2 * L.margin, "left", UI.c.textMuted)

    local actionLabel = "Change"
    if row.action == "remap" then actionLabel = "Open"
    elseif row.action then actionLabel = "Reset" end
    local hints = {
        { key = app.okLabel, label = actionLabel, accent = UI.c.green },
        { key = "X", label = "Reset", accent = UI.c.red },
        { key = app.backLabel, label = "Back" },
    }
    UI.footer(hints, app.selSetting .. " / " .. #ROWS)
end

return Settings
