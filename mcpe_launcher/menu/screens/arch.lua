-- screens/arch.lua -- choose which ABI to extract from a dual-ABI APK.

local UI = require("ui")

local Arch = {}

local OPTIONS = {
    both = {
        title = "BOTH",
        desc = "Extract armeabi-v7a and arm64-v8a. Recommended if you are unsure.",
        path = "v7a + v8a",
        badge = "RECOMMENDED",
    },
    armhf = {
        title = "32-BIT",
        desc = "32-bit build for older armhf systems. Lower memory use.",
        path = "lib/armeabi-v7a",
    },
    arm64 = {
        title = "64-BIT",
        desc = "64-bit build for aarch64 systems. Needs a 64-bit OS.",
        path = "lib/arm64-v8a",
    },
}

local CARD_W, CARD_H, CARD_Y, GAP = 192, 180, 96, 16

function Arch.enter(app)
    app.selArch = math.max(1, math.min(app.selArch or 1, #app.archOptions))
end

function Arch.key(app, act)
    if act == "left" then
        app.selArch = math.max(1, app.selArch - 1)
    elseif act == "right" then
        app.selArch = math.min(#app.archOptions, app.selArch + 1)
    elseif act == "a" then
        local apk = app.pendingApk
        local arch = app.archOptions[app.selArch]
        if apk and arch then app:installApk(apk.name, arch) end
    elseif act == "b" then
        app:switch("apk")
    end
end

function Arch.draw(app)
    local L = UI.L
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)

    UI.set(UI.c.header)
    love.graphics.rectangle("fill", 0, 0, L.w, L.header)
    UI.set(UI.c.line)
    love.graphics.rectangle("fill", 0, L.header - 1, L.w, 1)
    UI.logo(16, 10, 26)
    UI.textMidCapsBold(UI.font.pixel16, "SELECT ARCHITECTURE", 52, 0, 420, L.header, "left", UI.c.text)

    local name = app.pendingApk and app.pendingApk.name or ""
    local prompt = UI.fit(UI.font.body11, "Which build should be extracted from " .. name .. "?", L.w - 2 * L.margin)
    UI.text(UI.font.body11, prompt, L.margin, 56, L.w - 2 * L.margin, "left", UI.c.textDim)

    for i, arch in ipairs(app.archOptions) do
        local def = OPTIONS[arch]
        if def then
            local x = L.margin + (i - 1) * (CARD_W + GAP)
            local focused = i == app.selArch
            UI.panel(x, CARD_Y, CARD_W, CARD_H, {
                fill = UI.c.panelAlt,
                focus = focused,
            })
            UI.icon("cpu", x + 16, CARD_Y + 16, 32, UI.c.textDim)
            if def.badge then
                local bw = UI.font.pixel8:getWidth(def.badge) + 10
                UI.badge(def.badge, x + CARD_W - 16 - bw, CARD_Y + 20, "green")
            end
            UI.textBold(UI.font.pixel16, def.title, x + 16, CARD_Y + 64, CARD_W - 32, "left",
                UI.c.text)
            local lines = UI.wrap(UI.font.body9, def.desc, CARD_W - 32, 3)
            for li, line in ipairs(lines) do
                UI.text(UI.font.body9, line, x + 16, CARD_Y + 90 + (li - 1) * 13,
                    CARD_W - 32, "left", UI.c.textDim)
            end
            UI.text(UI.font.body9, def.path, x + 16, CARD_Y + CARD_H - 24,
                CARD_W - 32, "left", UI.c.textMuted)
        end
    end

    UI.footer({
        { key = app.okLabel, label = "Extract", accent = UI.c.green },
        { key = app.backLabel, label = "Back" },
    }, app.selArch .. " / " .. #app.archOptions)
end

return Arch
