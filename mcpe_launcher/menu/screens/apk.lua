-- screens/apk.lua -- choose an APK to install.

local UI = require("ui")

local Apk = {}

-- Left: framed file list. Right: selected APK details and the install action.
local LIST_X, LIST_Y, LIST_W, LIST_H = 16, 82, 356, 344
local INFO_X, INFO_Y, INFO_W, INFO_H = 384, 82, 240, 344
local ROW_X, ROW_Y, ROW_W, ROW_H, GAP, VISIBLE = LIST_X + 10, LIST_Y + 30,
    LIST_W - 20, 50, 6, 5

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

local function archShort(apk)
    if not apk.archReady then return "SCAN..." end
    if apk.armhf and apk.arm64 then return "A64 + A32" end
    if apk.arm64 then return "A64" end
    if apk.armhf then return "A32" end
    return "NO ABI"
end

local function drawEmpty(app)
    local w = UI.L.w - 2 * UI.L.margin
    UI.panel(LIST_X, LIST_Y, w, LIST_H, { fill = UI.c.panelAlt })
    UI.icon("package", 320 - 32, LIST_Y + 38, 64, UI.c.textDim)
    UI.textMidCapsBold(UI.font.pixel16, "NO APK FOUND", 0, LIST_Y + 116,
        UI.L.w, 28, "center", UI.c.text)
    UI.textMid(UI.font.body11, "Copy your .apk files into:",
        0, LIST_Y + 150, UI.L.w, 18, "center", UI.c.textDim)

    UI.panel(176, LIST_Y + 176, 288, 30,
        { fill = UI.c.bgDeep, border = UI.c.line, bevel = false })
    UI.textMid(UI.font.pixel8, "mcpe_launcher / Setup Apk /",
        176, LIST_Y + 176, 288, 30, "center", UI.c.text)

    local lines = UI.wrap(UI.font.body9,
        "Then reopen this screen. The filename becomes the version name.",
        420, 2)
    for i, line in ipairs(lines) do
        UI.textMid(UI.font.body9, line, 0, LIST_Y + 226 + (i - 1) * 14,
            UI.L.w, 14, "center", UI.c.textMuted)
    end
    UI.textMid(UI.font.body9, "No game files are included.",
        0, LIST_Y + 284, UI.L.w, 14, "center", UI.c.textMuted)
end

local function drawList(app)
    UI.panel(LIST_X, LIST_Y, LIST_W, LIST_H, { fill = UI.c.panelAlt })

    UI.textBold(UI.font.pixel8, "APK FILES", LIST_X + 12, LIST_Y + 10,
        160, "left", UI.c.textDim)
    local count = #app.apks .. (#app.apks == 1 and " FILE" or " FILES")
    local cw = UI.font.pixel8:getWidth(count) + 10
    UI.badge(count, LIST_X + LIST_W - 12 - cw, LIST_Y + 8, nil)

    local total = #app.apks
    local off = math.max(0, math.min(app.selApk - VISIBLE, total - VISIBLE))
    for row = 1, math.min(VISIBLE, total - off) do
        local i = row + off
        local apk = app.apks[i]
        local y = ROW_Y + (row - 1) * (ROW_H + GAP)
        local focused = i == app.selApk
        UI.panel(ROW_X, y, ROW_W, ROW_H, {
            fill = UI.c.panel,
            focus = focused,
            focusGap = UI.c.panelAlt,
        })
        UI.text(UI.font.body13, UI.fit(UI.font.body13, apk.name, ROW_W - 24),
            ROW_X + 12, y + 7, ROW_W - 24, "left", UI.c.text)
        UI.textBold(UI.font.pixel8,
            UI.humanSize(apk.bytes) .. "  -  " .. archText(apk),
            ROW_X + 12, y + 28, ROW_W - 24, "left", UI.c.textMuted)
    end

    if total > VISIBLE then
        local trackX = LIST_X + LIST_W - 6
        local trackY = ROW_Y
        local trackH = VISIBLE * ROW_H + (VISIBLE - 1) * GAP
        UI.set(UI.c.lineSoft)
        love.graphics.rectangle("fill", trackX, trackY, 2, trackH)
        local thumbH = math.max(20, math.floor(trackH * VISIBLE / total))
        local thumbY = trackY + math.floor((trackH - thumbH) * (off / (total - VISIBLE)))
        UI.set(UI.c.lineStrong)
        love.graphics.rectangle("fill", trackX, thumbY, 2, thumbH)
    end

    local totalBytes = 0
    for _, apk in ipairs(app.apks) do totalBytes = totalBytes + (apk.bytes or 0) end
    local summary = #app.apks .. (#app.apks == 1 and " file" or " files")
    if totalBytes > 0 then summary = summary .. "  -  " .. UI.humanSize(totalBytes) end
    UI.text(UI.font.body9, summary, LIST_X + 12, LIST_Y + LIST_H - 24,
        LIST_W - 24, "left", UI.c.textMuted)
end

local function drawInfo(app)
    local apk = selected(app)
    UI.panel(INFO_X, INFO_Y, INFO_W, INFO_H, { fill = UI.c.panelAlt })
    local x, y, w = INFO_X + 14, INFO_Y + 14, INFO_W - 28

    UI.textBold(UI.font.pixel8, "SELECTED FILE", x, y, w, "left", UI.c.textMuted)

    if not apk then
        UI.textMid(UI.font.body11, "Choose an APK on the left.",
            x, y + 100, w, 18, "center", UI.c.textDim)
        return
    end

    local nf = UI.font.body13
    local nameY = y + 22
    local lines = UI.wrap(nf, apk.name, w, 2)
    for i, line in ipairs(lines) do
        UI.text(nf, line, x, nameY + (i - 1) * 15, w, "left", UI.c.text)
    end

    local bx, by = x, nameY + #lines * 15 + 10
    if apk.arm64 then bx = bx + UI.badge("ARM64", bx, by, "green") + 5 end
    if apk.armhf then bx = bx + UI.badge("ARM32", bx, by, nil) + 5 end
    if not apk.arm64 and not apk.armhf then
        UI.badge(apk.archReady and "NO ABI" or "SCANNING", bx, by,
            apk.archReady and "red" or nil)
    end

    UI.set(UI.c.line)
    love.graphics.rectangle("fill", x, INFO_Y + 124, w, 1)

    local colW = math.floor((w - 12) / 2)
    local c1x, c2x = x, x + colW + 12
    local function stat(label, value, sx, sy)
        UI.textBold(UI.font.pixel8, label, sx, sy, colW, "left", UI.c.textMuted)
        UI.text(UI.font.body13, UI.fit(UI.font.body13, value, colW),
            sx, sy + 14, colW, "left", UI.c.text)
    end
    stat("SIZE", UI.humanSize(apk.bytes), c1x, INFO_Y + 136)
    stat("FREE SPACE", UI.humanSize(app.freeBytes or 0), c2x, INFO_Y + 136)
    stat("ARCH", archShort(apk), c1x, INFO_Y + 180)
    local installName = apk.name:gsub("%.apk$", ""):gsub("^[Mm]inecraft[%-_ ]*", "")
    stat("INSTALL AS", installName, c2x, INFO_Y + 180)

    local msgY = INFO_Y + 224
    if app.apkError then
        local errLines = UI.wrap(UI.font.body9, app.apkError, w, 2)
        for i, line in ipairs(errLines) do
            UI.text(UI.font.body9, line, x, msgY + (i - 1) * 14, w, "left", UI.c.red)
        end
    else
        local hint = UI.wrap(UI.font.body9,
            "If this APK has both ABIs, you choose the build next.",
            w, 2)
        for i, line in ipairs(hint) do
            UI.text(UI.font.body9, line, x, msgY + (i - 1) * 14, w, "left", UI.c.textMuted)
        end
    end

    UI.button("INSTALL", x, INFO_Y + INFO_H - 14 - 44, w, 44, {
        disabled = not apk.archReady,
    })
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
