-- update/main.lua -- OTA update progress (separate LÖVE process).

local UI = require("ui")

local STEPS = {
    "Checking latest release",
    "Downloading update",
    "Verifying checksum",
    "Installing files",
    "Cleaning up",
}

local statusFile = nil
local step = 1
local done = false
local result = ""
local message = "Checking for updates..."
local t, poll = 0, 0
local demo = nil
local shots, frames = false, 0

local function stepOf(msg)
    local m = (msg or ""):lower()
    if m:find("check", 1, true) then return 1 end
    if m:find("download", 1, true) then return 2 end
    if m:find("verif", 1, true) then return 3 end
    if m:find("install", 1, true) then return 4 end
    if m:find("clean", 1, true) then return 5 end
    return nil
end

local function readStatus()
    if not statusFile then return end
    local f = io.open(statusFile, "r")
    if not f then return end
    local line = f:read("*l")
    f:close()
    if not line or line == "" then return end
    local kind, a, b = line:match("^([^|]*)|([^|]*)|?(.*)$")
    if kind == "END" then
        done = true
        result = a or ""
        message = (b ~= nil and b ~= "") and b or (a or "")
        if result == "ok" then step = 5 end
    elseif kind == "STEP" then
        local s = stepOf(a)
        if s then step = math.max(step, s) end
        message = a or message
    end
end

function love.load(args)
    for _, a in ipairs(args or {}) do
        if a:match("^%-%-demo=") then
            demo = a:match("=(.+)$")
            love.window.setMode(640, 480, { fullscreen = false, vsync = 1, resizable = false })
        elseif a == "--shots" then
            shots = true
            if not demo then demo = "install" end
            love.window.setMode(640, 480, { fullscreen = false, vsync = 1, resizable = false })
        elseif a:sub(1, 1) == "/" or a:match("^%a:[/\\]") then
            statusFile = a
        end
    end
    UI.load()
    if demo then
        if demo == "ok" then
            step, done, result, message = 5, true, "ok", "Updated to the latest release"
        elseif demo == "err" then
            step, done, result, message = 3, true, "err", "Checksum mismatch, nothing was changed"
        elseif demo == "none" then
            step, done, result, message = 5, true, "none", "Already up to date"
        else
            local s = stepOf(demo) or tonumber(demo) or 2
            step = s
            message = STEPS[s]
        end
    else
        readStatus()
    end
end

function love.update(dt)
    t = t + dt
    if shots then
        frames = frames + 1
        if frames == 3 then
            love.graphics.captureScreenshot("update-" .. (demo or "install") .. ".png")
        elseif frames == 9 then
            love.event.quit(0)
        end
        return
    end
    if demo or done then return end
    poll = poll + dt
    if poll >= 0.25 then
        poll = 0
        readStatus()
    end
end

local function stateOf(i)
    if done then
        if result == "err" and i == step then return "error" end
        if result == "ok" or result == "none" then return "done" end
        if i < step then return "done" end
        if i == step then return "error" end
        return "pending"
    end
    if i < step then return "done" end
    if i == step then return "active" end
    return "pending"
end

local STEP_HINTS = {
    "Contacting GitHub for the latest release.",
    "Fetching the update archive.",
    "Checking the download against SHA-256.",
    "Replacing launcher files. Your data is kept.",
    "Removing temporary files.",
}

local function phaseInfo()
    if done then
        if result == "ok" then return "UPDATE COMPLETE", "check", UI.c.greenHi end
        if result == "err" then return "UPDATE FAILED", "cross", UI.c.red end
        return "UP TO DATE", "check", UI.c.greenHi
    end
    return STEPS[step]:upper(), "download", UI.c.white
end

function love.draw()
    local L = UI.L
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    UI.drawBackdrop()

    -- header
    UI.set(UI.c.header)
    love.graphics.rectangle("fill", 0, 0, L.w, L.header)
    UI.set(UI.c.line)
    love.graphics.rectangle("fill", 0, L.header - 1, L.w, 1)
    UI.logo(16, 10, 26)
    UI.textMidCapsBold(UI.font.pixel16, "UPDATE PORT", 52, 0, 400, L.header, "left", UI.c.text)

    local chipLabel, chipVariant = "DO NOT TURN OFF", "orange"
    if done then
        if result == "ok" then chipLabel, chipVariant = "DONE", "green"
        elseif result == "err" then chipLabel, chipVariant = "FAILED", "red"
        else chipLabel, chipVariant = "UP TO DATE", "green" end
    end
    local cw = UI.font.pixel8:getWidth(chipLabel) + 10
    UI.badge(chipLabel, L.w - L.margin - cw, 14, chipVariant)

    local w, h = 520, 240
    local x, y = math.floor((L.w - w) / 2), 120
    UI.panel(x, y, w, h, { fill = UI.c.panel, border = UI.c.lineStrong })

    local title, iconName, titleCol = phaseInfo()
    local barCol = (done and result == "err") and UI.c.red or UI.c.green

    UI.icon(iconName, x + math.floor((w - 48) / 2), y + 28, 48,
        done and titleCol or UI.c.white)
    UI.textMidCapsBold(UI.font.pixel24, title, x, y + 88, w, 30, "center", titleCol)

    local msg = message or ""
    if not done and (msg == "" or msg == STEPS[step]) then
        msg = STEP_HINTS[step] or ""
    end
    local msgCol = UI.c.textDim
    if done and result == "ok" then msgCol = UI.c.greenHi
    elseif done and result == "err" then msgCol = UI.c.red
    elseif done and result == "none" then msgCol = UI.c.yellow end
    local ml = UI.wrap(UI.font.body11, msg, w - 64, 2)
    for i, line in ipairs(ml) do
        UI.textMid(UI.font.body11, line, x, y + 122 + (i - 1) * 15,
            w, 15, "center", msgCol)
    end

    local frac = step / #STEPS
    local indeterminate = (not done) and step == 2
    UI.progress(x + 40, y + 160, w - 80, 20, frac, indeterminate, t, barCol)

    UI.textMid(UI.font.pixel8, string.format("STEP %d OF %d", step, #STEPS),
        x, y + 188, w, 18, "center", UI.c.textMuted)

    UI.textMid(UI.font.body9,
        done and "You can turn off the console." or "Do not turn off the console.",
        x, y + 212, w, 14, "center", done and UI.c.textMuted or UI.c.textDim)

    if done then
        UI.footer({ { key = "A", label = "OK", accent = UI.c.green } }, "")
    else
        UI.footer({}, "YOUR VERSIONS, WORLDS AND SIGN-IN ARE KEPT")
    end
end

function love.keypressed(key)
    if done and (key == "return" or key == "kpenter" or key == "space"
        or key == "a" or key == "escape" or key == "b") then
        love.event.quit(0)
    end
end

function love.gamepadpressed(_, button)
    if done and (button == "a" or button == "b" or button == "start") then
        love.event.quit(0)
    end
end
