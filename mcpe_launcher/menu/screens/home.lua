-- screens/home.lua -- version list and primary actions.

local UI = require("ui")

local Home = {}

local SPLASH = {
    "Now with 200% more blocks!",
    "Works on a tiny screen!",
    "Pocket sized, block sized.",
    "Bring your own APK!",
    "Also plays on a train.",
    "No keyboard required.",
}

local function buildItems(app)
    local t = {}
    if #app.versions > 0 then t[#t + 1] = { kind = "play" } end
    for _, v in ipairs(app.versions) do t[#t + 1] = { kind = "version", v = v } end
    t[#t + 1] = { kind = "setup" }
    t[#t + 1] = { kind = "update" }
    t[#t + 1] = { kind = "exit" }
    return t
end

local function heroVersion(app)
    for _, v in ipairs(app.versions) do
        if v.name == app.heroVer then return v end
    end
    return nil
end

local function clampSel(app)
    app.sel = math.max(1, math.min(app.sel or 1, app:homeItemCount()))
end

function Home.enter(app)
    clampSel(app)
    local found = false
    for _, v in ipairs(app.versions) do
        if v.name == app.heroVer then found = true break end
    end
    if not found then
        app.heroVer = app.versions[1] and app.versions[1].name or nil
    end
end

local function move(app, dir)
    local items = buildItems(app)
    local n = #items
    local versionCount = #app.versions
    local playOffset = (versionCount > 0) and 1 or 0
    local firstVersion = playOffset + 1
    local lastVersion = playOffset + versionCount
    local actionStart = lastVersion + 1
    local sel = math.max(1, math.min(app.sel, n))

    if playOffset == 1 and sel == 1 then
        if dir == "down" then
            sel = (versionCount > 0) and 2 or actionStart
        end
    elseif sel >= firstVersion and sel <= lastVersion then
        local vi = sel - playOffset
        local col = (vi - 1) % 3
        local row = math.floor((vi - 1) / 3)
        if dir == "left" and col > 0 then
            sel = sel - 1
        elseif dir == "right" and col < 2 and vi + 1 <= versionCount then
            sel = sel + 1
        elseif dir == "up" then
            if row > 0 then
                sel = sel - 3
            elseif playOffset == 1 then
                sel = 1
            end
        elseif dir == "down" then
            if vi + 3 <= versionCount then
                sel = sel + 3
            else
                sel = actionStart + col
            end
        end
    elseif sel >= actionStart then
        local ai = sel - actionStart
        if dir == "left" and ai > 0 then
            sel = sel - 1
        elseif dir == "right" and ai < 2 then
            sel = sel + 1
        elseif dir == "up" then
            if versionCount > 0 then
                local lastRowStart = math.floor((versionCount - 1) / 3) * 3 + 1
                local target = lastRowStart + ai
                if target > versionCount then target = versionCount end
                sel = playOffset + target
            elseif playOffset == 1 then
                sel = 1
            end
        end
    end

    app.sel = math.max(1, math.min(sel, n))
    local it = items[app.sel]
    if it and it.kind == "version" then app.heroVer = it.v.name end
end

local function openDelete(app, v)
    app:openModal({
        title = "DELETE VERSION?",
        body = {
            UI.fit(UI.font.body11, "Remove the installed game files for " .. v.name .. "?", 368),
            "Worlds, skins and settings are kept.",
        },
        confirmLabel = "DELETE",
        variant = "danger",
        onConfirm = function() app:deleteVersion(v.name) end,
    })
end

local function activate(app)
    local items = buildItems(app)
    local it = items[app.sel]
    if not it then return end
    if it.kind == "play" then
        if app.heroVer then app:playVersion(app.heroVer) end
    elseif it.kind == "version" then
        app:playVersion(it.v.name)
    elseif it.kind == "setup" then
        app:scanApks()
        app.selApk = 1
        app:switch("apk")
    elseif it.kind == "update" then
        app:openModal({
            title = "UPDATE PORT?",
            body = {
                "Update to the latest release?",
                "Wi-Fi is required, or place the release zip in update.zip.",
            },
            confirmLabel = "UPDATE",
            variant = "primary",
            onConfirm = function() app:requestUpdate() end,
        })
    else
        app:exitMenu()
    end
end

function Home.key(app, act)
    if act == "up" or act == "down" or act == "left" or act == "right" then
        move(app, act)
    elseif act == "a" then
        activate(app)
    elseif act == "x" then
        local items = buildItems(app)
        local it = items[app.sel]
        if it and it.kind == "version" then openDelete(app, it.v) end
    elseif act == "b" then
        app:exitMenu()
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
    UI.textMidCapsBold(UI.font.pixel16, "MCPE LAUNCHER", 52, 0, 300, L.header, "left", UI.c.text)

    local titleW = UI.font.pixel16:getWidth("MCPE LAUNCHER")
    local ver = app.portVersion ~= "" and ("v" .. app.portVersion) or "dev"
    local chipW = UI.font.pixel8:getWidth(ver) + 10
    UI.badge(ver, 52 + titleW + 12, 14, nil)

    local aw = UI.font.pixel8:getWidth(app.archLabel) + 10
    UI.badge(app.archLabel, L.w - L.margin - aw, 14, "green")

    local sx = 52 + titleW + 12 + chipW + 26
    local text = SPLASH[(os.time() % #SPLASH) + 1]
    local sw = UI.font.pixel8:getWidth(text)
    local archX = L.w - L.margin - aw
    if sx + sw < archX - 12 then
        love.graphics.push()
        love.graphics.translate(sx, 20)
        love.graphics.rotate(-0.06)
        UI.set(UI.c.yellow)
        love.graphics.setFont(UI.font.pixel8)
        love.graphics.print(text, 0, 0)
        love.graphics.print(text, 1, 0)
        love.graphics.pop()
    end
end

local function drawHero(app, focused)
    local L = UI.L
    local x, y, w, h = L.margin, L.heroTop, L.w - 2 * L.margin, L.heroH

    UI.panel(x, y, w, h, { focus = focused, bevel = false })
    UI.drawHeroArt(x + 1, y + 1, w - 2, h - 2)
    if focused then
        UI.set(UI.c.green)
        love.graphics.rectangle("fill", x + 2, y + 10, 3, h - 20)
    end

    -- bevel after the art so it stays visible
    UI.set({ 1, 1, 1 }, 0.05)
    love.graphics.rectangle("fill", x + 6, y + 2, w - 12, 2)
    UI.set({ 1, 1, 1 }, 0.03)
    love.graphics.rectangle("fill", x + 2, y + 6, 2, h - 12)
    UI.set({ 0, 0, 0 }, 0.34)
    love.graphics.rectangle("fill", x + 6, y + h - 4, w - 12, 2)
    UI.set({ 0, 0, 0 }, 0.24)
    love.graphics.rectangle("fill", x + w - 4, y + 6, 2, h - 12)

    UI.textBold(UI.font.pixel8, "SELECTED VERSION", x + 16, y + 10, 300, "left", UI.c.green)

    local v = heroVersion(app)
    if v then
        UI.textBold(UI.font.pixel24, UI.fit(UI.font.pixel24, v.name, 290),
            x + 16, y + 24, 290, "left", UI.c.white)
        local bx, by = x + 16, y + 66
        if v.arm64 then bx = bx + UI.badge("ARM64", bx, by, "green") + 5 end
        if v.armhf then bx = bx + UI.badge("ARM32", bx, by, nil) + 5 end
        if not v.arm64 and not v.armhf then UI.badge("NO ABI", bx, by, "red") end
    else
        UI.text(UI.font.body13, "NO VERSION INSTALLED", x + 16, y + 32, 300, "left", UI.c.textDim)
        UI.text(UI.font.body9, "Choose SETUP APK below to install one.",
            x + 16, y + 54, 300, "left", UI.c.textMuted)
    end

    UI.button("PLAY", x + w - 16 - 148, y + 25, 148, 52, {
        focus = focused,
        disabled = (v == nil),
    })
end

local function drawVersionCard(app, v, x, y, focused)
    local L = UI.L
    local fill = focused and UI.c.tintFocus or UI.c.panel
    UI.panel(x, y, L.colW, L.rowH, { fill = fill, focus = focused })
    local vf = UI.font.pixel16
    local ty = y + 9
    UI.textBold(vf, UI.fit(vf, v.name, L.colW - 22),
        x + 11, ty, L.colW - 22, "left", focused and UI.c.greenHi or UI.c.text)
    local bx, by = x + 11, y + 48
    if v.arm64 then bx = bx + UI.badge("ARM64", bx, by, focused and "green" or nil) + 4 end
    if v.armhf then bx = bx + UI.badge("ARM32", bx, by, nil) + 4 end
    if not v.arm64 and not v.armhf then UI.badge("NO ABI", bx, by, "red") end
end

local function drawActionCard(app, item, x, y, focused)
    local L = UI.L
    local def
    if item.kind == "setup" then
        def = { title = "SETUP APK", sub = "Install a version", icon = "package",
                color = UI.c.setup, light = UI.c.setupHi }
    elseif item.kind == "update" then
        def = { title = "UPDATE PORT", sub = "Check for updates", icon = "download",
                color = UI.c.update, light = UI.c.updateHi }
    else
        def = { title = "EXIT", sub = "Back to Ports", icon = "logout",
                color = UI.c.exit, light = UI.c.exitHi }
    end
    UI.colorCard(x, y, L.colW, L.rowH, def.color, { focus = focused, light = def.light })
    UI.icon(def.icon, x + 12, y + 26, 26, UI.c.bgDeep)
    UI.icon(def.icon, x + 12, y + 25, 26, UI.c.white)
    UI.text(UI.font.pixel16, UI.fit(UI.font.pixel16, def.title, L.colW - 58),
        x + 47, y + 18, L.colW - 58, "left", UI.c.bgDeep, 0.45)
    UI.textBold(UI.font.pixel16, UI.fit(UI.font.pixel16, def.title, L.colW - 58),
        x + 47, y + 17, L.colW - 58, "left", UI.c.white)
    UI.textBold(UI.font.pixel8, UI.fit(UI.font.pixel8, def.sub, L.colW - 58),
        x + 47, y + 40, L.colW - 58, "left", UI.c.white, 0.80)
end

local function drawGrid(app, items)
    local L = UI.L
    local versionCount = #app.versions
    local playOffset = (versionCount > 0) and 1 or 0
    local firstVersion = playOffset + 1
    local lastVersion = playOffset + versionCount
    local actionStart = lastVersion + 1
    local rows = math.ceil(versionCount / 3)
    local visRows = math.min(2, rows)
    local focusV = 0
    if app.sel >= firstVersion and app.sel <= lastVersion then
        focusV = app.sel - playOffset
    end
    local offRow = 0
    if focusV > 0 and rows > visRows then
        local focusRow = math.floor((focusV - 1) / 3) + 1
        offRow = math.max(0, math.min(focusRow - visRows, rows - visRows))
    end

    for slot = 1, math.min(visRows * 3, versionCount - offRow * 3) do
        local vi = offRow * 3 + slot
        local v = app.versions[vi]
        if v then
            local col = (slot - 1) % 3
            local row = math.floor((slot - 1) / 3)
            local x = L.margin + col * (L.colW + L.colGap)
            local y = L.gridTop + row * (L.rowH + L.rowGap)
            drawVersionCard(app, v, x, y, (playOffset + vi) == app.sel)
        end
    end

    local actionsY = L.gridTop + visRows * (L.rowH + L.rowGap)
    local kinds = { "setup", "update", "exit" }
    for i, kind in ipairs(kinds) do
        local x = L.margin + (i - 1) * (L.colW + L.colGap)
        drawActionCard(app, { kind = kind }, x, actionsY, (actionStart + i - 1) == app.sel)
    end

    if rows > visRows then
        local trackY = L.gridTop
        local trackH = visRows * L.rowH + (visRows - 1) * L.rowGap
        UI.set(UI.c.lineSoft)
        love.graphics.rectangle("fill", L.w - 10, trackY, 2, trackH)
        local thumbH = math.max(20, math.floor(trackH * visRows / rows))
        local thumbY = trackY + math.floor((trackH - thumbH) * (offRow / (rows - visRows)))
        UI.set(UI.c.lineStrong)
        love.graphics.rectangle("fill", L.w - 10, thumbY, 2, thumbH)
    end
end

function Home.draw(app)
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    drawHeader(app)

    local items = buildItems(app)
    local it = items[app.sel]

    drawHero(app, it and it.kind == "play")
    UI.section("MY VERSIONS", (#app.versions) .. " INSTALLED")
    drawGrid(app, items)

    local hints = {}
    local aLabel = "Play"
    if it then
        if it.kind == "setup" then aLabel = "Open"
        elseif it.kind == "update" then aLabel = "Update"
        elseif it.kind == "exit" then aLabel = "Exit" end
    end
    hints[#hints + 1] = { key = app.okLabel, label = aLabel, accent = UI.c.green }
    if it and it.kind == "version" then
        hints[#hints + 1] = { key = "X", label = "Delete", accent = UI.c.red }
    end
    hints[#hints + 1] = { key = app.backLabel, label = "Exit" }
    UI.footer(hints, app.sel .. " / " .. #items)
end

return Home
