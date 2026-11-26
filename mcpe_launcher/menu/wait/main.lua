-- wait/main.lua -- APK extraction progress (separate LÖVE process).

local UI = require("ui")

local dir, total = nil, 0
local done = 0
local t, poll = 0, 0
local isDev, demo = false, nil
local shots, frames = false, 0

local function measure()
    if not dir or total <= 0 then return end
    local p = io.popen('du -sk "' .. dir .. '" 2>/dev/null')
    if not p then return end
    local out = p:read("*l")
    p:close()
    local kb = tonumber(out and out:match("^(%d+)"))
    if kb then done = kb end
end

function love.load(args)
    for _, a in ipairs(args or {}) do
        if a == "--dev" then
            isDev = true
        elseif a == "--shots" then
            isDev, shots = true, true
        elseif a:match("^%-%-demo=") then
            demo = tonumber(a:match("=(.+)$"))
            isDev = true
        elseif tonumber(a) then
            total = tonumber(a)
        elseif a:sub(1, 1) == "/" then
            dir = a
        end
    end
    if isDev then
        love.window.setMode(640, 480, { fullscreen = false, vsync = 1, resizable = false })
    end
    if shots and not demo then demo = 0.42 end
    UI.load()
end

function love.update(dt)
    t = t + dt
    poll = poll + dt
    if poll >= 0.5 then
        poll = 0
        measure()
    end
    if shots then
        frames = frames + 1
        if frames == 3 then
            love.graphics.captureScreenshot("wait.png")
        elseif frames == 9 then
            love.event.quit(0)
        end
    end
end

function love.draw()
    local L = UI.L
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    UI.drawBackdrop()

    local w, h = 460, 220
    local x, y = math.floor((L.w - w) / 2), 130
    UI.panel(x, y, w, h, { fill = UI.c.panelAlt, border = UI.c.lineStrong })

    UI.textBold(UI.font.pixel16, "EXTRACTING APK", x + 20, y + 20, w - 40, "left", UI.c.white)
    local name = dir and dir:match("([^/]+)/?$") or ""
    UI.text(UI.font.body11, UI.fit(UI.font.body11, name, w - 40), x + 20, y + 48,
        w - 40, "left", UI.c.textDim)

    local frac = nil
    if demo then
        frac = math.max(0, math.min(1, demo))
    elseif total > 0 and done > 0 then
        frac = math.max(0, math.min(0.99, done / total))
    end

    UI.progress(x + 20, y + 96, w - 40, 16, frac or 0, frac == nil, t)

    if frac then
        UI.text(UI.font.body11, string.format("%d%%", math.floor(frac * 100)),
            x + 20, y + 120, w - 40, "right", UI.c.text)
    else
        UI.text(UI.font.body11, "Preparing...", x + 20, y + 120, w - 40, "left", UI.c.textDim)
    end

    local lines = UI.wrap(UI.font.body9,
        "The APK is being unpacked onto the SD card. This can take a few minutes on a slow card.",
        w - 40, 2)
    for i, line in ipairs(lines) do
        UI.text(UI.font.body9, line, x + 20, y + 160 + (i - 1) * 13, w - 40, "left", UI.c.textMuted)
    end
end
