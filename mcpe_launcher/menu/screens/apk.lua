-- screens/apk.lua -- choose an APK to install.

local UI = require("ui")

local Apk = {}

local LIST_X, LIST_Y, LIST_W, ROW_H, GAP, VISIBLE = 16, 82, 344, 56, 7, 5
local INFO_X, INFO_Y, INFO_W, INFO_H = 376, 82, 248, 352

local function selected(app)
    return app.apks[app.selApk]
end

local function clamp(app)
    app.selApk = math.max(1, math.min(app.selApk or 1, math.max(1, #app.apks)))
end

function Apk.enter(app)
    app:scanApks()
    clamp(app)
    app.apkError = nil
    app.freeBytes = app:freeSpace()
    app:ensureApkArch(selected(app))
end

local function install(app)
    local apk = selected(app)
    if not apk then return end
    app:ensureApkArch(apk)
    app.apkError = nil
    if apk.armhf and apk.arm64 then
        app.pendingApk = apk
        app.archOptions = { "both", "armhf", "arm64" }
        app.selArch = 1
        app:switch("arch")
    elseif apk.arm64 then
        app:installApk(apk.name, "arm64")
    elseif apk.armhf then
        app:installApk(apk.name, "armhf")
    else
        app.apkError = "No ARM libraries found in this APK."
    end
end

local function openDelete(app, apk)
    app:openModal({
        title = "DELETE APK?",
        body = {
            UI.fit(UI.font.body11, "Remove " .. apk.name .. " from Setup Apk?", 368),
            "Installed versions are kept.",
        },
        confirmLabel = "DELETE",
        variant = "danger",
        onConfirm = function() app:deleteApk(apk.name) end,
    })
end

function Apk.key(app, act)
    if act == "up" or act == "down" then
        local dir = (act == "up") and -1 or 1
        app.selApk = math.max(1, math.min(app.selApk + dir, math.max(1, #app.apks)))
        app.apkError = nil
        app:ensureApkArch(selected(app))
    elseif act == "a" then
        install(app)
    elseif act == "x" then
        local apk = selected(app)
        if apk then openDelete(app, apk) end
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
    UI.textMidCapsBold(UI.font.pixel16, "SETUP APK", 52, 0, 400, L.header, "left", UI.c.text)
    local label = #app.apks .. (#app.apks == 1 and " FILE" or " FILES")
    local w = UI.font.pixel8:getWidth(label) + 10
    UI.badge(label, L.w - L.margin - w, 14, nil)
end

local function archText(apk)
    if not apk.archReady then return "Scanning..." end
    return UI.archLabel(apk.armhf, apk.arm64)
end

local function drawEmpty(app)
    UI.panel(LIST_X, LIST_Y, LIST_W, 180, { fill = UI.c.panelAlt })
    UI.textBold(UI.font.pixel8, "NO APK FOUND", LIST_X + 16, LIST_Y + 20, LIST_W - 32, "left", UI.c.yellow)
    UI.text(UI.font.body11, "Copy your .apk files into:", LIST_X + 16, LIST_Y + 50, LIST_W - 32, "left", UI.c.textDim)
    UI.text(UI.font.body11, "mcpe_launcher / Setup Apk /", LIST_X + 16, LIST_Y + 70, LIST_W - 32, "left", UI.c.white)
    local lines = UI.wrap(UI.font.body9,
        "Then reopen this menu and choose the APK to extract. The filename becomes the version name.", LIST_W - 32, 3)
    for i, line in ipairs(lines) do
        UI.text(UI.font.body9, line, LIST_X + 16, LIST_Y + 100 + (i - 1) * 14, LIST_W - 32, "left", UI.c.textMuted)
    end
end

local function drawList(app)
    local total = #app.apks
    local off = math.max(0, math.min(app.selApk - VISIBLE, total - VISIBLE))
    for row = 1, math.min(VISIBLE, total - off) do
        local i = row + off
        local apk = app.apks[i]
        local y = LIST_Y + (row - 1) * (ROW_H + GAP)
        local focused = i == app.selApk
        UI.panel(LIST_X, y, LIST_W, ROW_H, {
            fill = focused and UI.c.tintFocus or UI.c.panel,
            focus = focused,
        })
        UI.panel(LIST_X + 11, y + 15, 26, 26, {
            fill = UI.c.bgDeep, border = UI.c.line, radius = 3, bevel = false,
        })
        UI.icon("file", LIST_X + 11, y + 15, 26, focused and UI.c.greenHi or UI.c.textDim)
        UI.text(UI.font.body13, UI.fit(UI.font.body13, apk.name, LIST_W - 57),
            LIST_X + 46, y + 11, LIST_W - 57, "left", focused and UI.c.greenHi or UI.c.text)
        UI.textBold(UI.font.pixel8,
            UI.humanSize(apk.bytes) .. "  -  " .. archText(apk),
            LIST_X + 46, y + 33, LIST_W - 57, "left", UI.c.textMuted)
    end

    if total > VISIBLE then
        local trackY, trackH = LIST_Y, VISIBLE * ROW_H + (VISIBLE - 1) * GAP
        UI.set(UI.c.lineSoft)
        love.graphics.rectangle("fill", LIST_X + LIST_W + 2, trackY, 2, trackH)
        local thumbH = math.max(20, math.floor(trackH * VISIBLE / total))
        local thumbY = trackY + math.floor((trackH - thumbH) * (off / (total - VISIBLE)))
        UI.set(UI.c.lineStrong)
        love.graphics.rectangle("fill", LIST_X + LIST_W + 2, thumbY, 2, thumbH)
    end
end

local function drawInfo(app)
    local apk = selected(app)
    if not apk then return end
    UI.panel(INFO_X, INFO_Y, INFO_W, INFO_H, { fill = UI.c.panelAlt })
    local x, y, w = INFO_X + 13, INFO_Y + 13, INFO_W - 26

    UI.textBold(UI.font.pixel8, "SELECTED FILE", x, y, w, "left", UI.c.textMuted)
    local nf = UI.font.body13
    local lines = UI.wrap(nf, apk.name, w, 2)
    for i, line in ipairs(lines) do
        UI.text(nf, line, x, y + 14 + (i - 1) * 17, w, "left", UI.c.white)
    end

    local kvY = y + 14 + #lines * 17 + 12
    local function kv(label, value, yy, vf)
        UI.textBold(UI.font.pixel8, label, x, yy, 108, "left", UI.c.textMuted)
        vf = vf or UI.font.pixel8
        UI.text(vf, UI.fit(vf, value, 110), x + 108, yy, 110, "right", UI.c.textDim)
    end
    kv("Size", UI.humanSize(apk.bytes), kvY)
    kv("Architectures", archText(apk), kvY + 19)
    kv("Free space", UI.humanSize(app.freeBytes or 0), kvY + 38)
    kv("Install as", apk.name:gsub("%.apk$", ""), kvY + 57, UI.font.body9)

    UI.button("INSTALL", x, 330, w, 42, { focus = false })

    if app.apkError then
        local errLines = UI.wrap(UI.font.body9, app.apkError, w, 2)
        for i, line in ipairs(errLines) do
            UI.text(UI.font.body9, line, x, 384 + (i - 1) * 14, w, "left", UI.c.red)
        end
    else
        local hint = UI.wrap(UI.font.body9,
            "If the APK contains both ABIs you can choose which one to extract. Worlds and settings are kept.",
            w, 2)
        for i, line in ipairs(hint) do
            UI.text(UI.font.body9, line, x, 384 + (i - 1) * 14, w, "left", UI.c.textMuted)
        end
    end
end

function Apk.draw(app)
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    drawHeader(app)

    if #app.apks == 0 then
        drawEmpty(app)
    else
        UI.text(UI.font.body11, "APKs in mcpe_launcher / Setup Apk / - filename = version name.",
            LIST_X, 56, UI.L.w - 2 * UI.L.margin, "left", UI.c.textDim)
        drawList(app)
        drawInfo(app)
    end

    local hints = {}
    if #app.apks > 0 then
        hints[#hints + 1] = { key = app.okLabel, label = "Install", accent = UI.c.green }
        hints[#hints + 1] = { key = "X", label = "Delete", accent = UI.c.red }
    end
    hints[#hints + 1] = { key = app.backLabel, label = "Back" }
    local right = #app.apks > 0 and (app.selApk .. " / " .. #app.apks) or nil
    UI.footer(hints, right)
end

return Apk
