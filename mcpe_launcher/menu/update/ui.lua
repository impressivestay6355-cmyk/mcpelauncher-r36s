-- ui.lua -- design system for the MCPE Launcher menu.
-- All colours/sizes follow DESIGN.md. Keep this file in sync with
-- mcpe_launcher/menu/{update,wait}/ui.lua (scripts/sync_ui.py does it).

local UI = {}

local function hex(s, a)
    return {
        tonumber(s:sub(2, 3), 16) / 255,
        tonumber(s:sub(4, 5), 16) / 255,
        tonumber(s:sub(6, 7), 16) / 255,
        a or 1,
    }
end

UI.c = {
    bg        = hex("#0D0D10"),
    header    = hex("#141419"),
    footer    = hex("#101014"),
    bgDeep    = hex("#08080A"),
    panel     = hex("#17171C"),
    panelAlt  = hex("#1F1F26"),
    panelHi   = hex("#26262E"),
    line      = hex("#34343E"),
    lineSoft  = hex("#2A2A32"),
    lineStrong= hex("#4A4A57"),
    text      = hex("#ECECF1"),
    textDim   = hex("#9A9AA8"),
    textMuted = hex("#6E6E7C"),
    green     = hex("#63C93F"),
    greenHi   = hex("#8EE86B"),
    greenDeep = hex("#2E6F1C"),
    greenInk  = hex("#0F2408"),
    tintFocus = hex("#19230F"),
    blue      = hex("#3F8FD8"),
    blueDeep  = hex("#275F93"),
    tintBlue  = hex("#101A24"),
    orange    = hex("#C9802F"),
    tintOrange= hex("#221A10"),
    setup     = hex("#1F8A70"),
    setupHi   = hex("#33A98A"),
    update    = hex("#1E6FA8"),
    updateHi  = hex("#2E8FCF"),
    exit      = hex("#A61B3F"),
    exitHi    = hex("#C42F57"),
    red       = hex("#B8493F"),
    redDeep   = hex("#7D2F28"),
    tintRed   = hex("#221111"),
    yellow    = hex("#E9C64A"),
    white     = hex("#FFFFFF"),
    scrim     = hex("#050506", 0.72),
}

UI.L = {
    w = 640, h = 480,
    margin = 16,
    header = 46,
    heroTop = 58,
    heroH = 102,
    sectionTop = 170,
    gridTop = 192,
    colW = 198,
    colGap = 7,
    rowH = 76,
    rowGap = 7,
    footer = 32,
    notch = 6,
    cardPad = 11,
    btnH = 52,
}

UI.font = {}

local function font(path, size, fallbackPath)
    local ok, f = pcall(love.graphics.newFont, path, size)
    if ok then
        f:setLineHeight(1.0)
        return f
    end
    if fallbackPath then
        local ok2, f2 = pcall(love.graphics.newFont, fallbackPath, size)
        if ok2 then
            f2:setLineHeight(1.0)
            return f2
        end
    end
    local fallback = love.graphics.newFont(size)
    fallback:setLineHeight(1.0)
    return fallback
end

function UI.load()
    -- SVN-Coder's Crux (CC BY 3.0) covers ASCII and Vietnamese in one pixel
    -- font. The old fonts stay as fallbacks if the file is missing.
    local CRUX = "font_crux.ttf"
    UI.font.keycap = font(CRUX, 11, "font_pixel.ttf")
    UI.font.pixel8  = font(CRUX, 13, "font_pixel.ttf")
    UI.font.pixel11 = UI.font.pixel8
    UI.font.pixel16 = font(CRUX, 16, "font_pixel.ttf")
    UI.font.pixel24 = font(CRUX, 24, "font_pixel.ttf")
    UI.font.body9   = font(CRUX, 13, "font_body.ttf")
    UI.font.body11  = font(CRUX, 13, "font_body.ttf")
    UI.font.body13  = font(CRUX, 13, "font_body_bold.ttf")
    UI.font.body22  = font(CRUX, 24, "font_body_bold.ttf")
    for _, f in pairs(UI.font) do
        f:setFilter("nearest", "nearest")
    end
    local okIcon, iconFont = pcall(love.graphics.newFont, "font_icons.ttf", 24)
    if okIcon then
        iconFont:setLineHeight(1.0)
        iconFont:setFilter("nearest", "nearest")
        UI.font.icons = iconFont
    end
    UI.loaded = true
end

-- ---------------------------------------------------------------- primitives

function UI.set(col, alpha)
    love.graphics.setColor(col[1], col[2], col[3], (col[4] or 1) * (alpha or 1))
end

function UI.panel(x, y, w, h, o)
    o = o or {}
    local fill = o.fill or UI.c.panel
    local border = o.border or UI.c.line

    if o.focus then
        UI.set(UI.c.green, 0.10)
        love.graphics.rectangle("fill", x - 6, y - 6, w + 12, h + 12)
        UI.set(UI.c.green)
        love.graphics.rectangle("fill", x - 4, y - 4, w + 8, h + 8)
        UI.set(UI.c.bg)
        love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4)
        border = UI.c.green
    end

    UI.set(UI.c.bgDeep)
    love.graphics.rectangle("fill", x - 1, y - 1, w + 2, h + 2)
    UI.set(border)
    love.graphics.rectangle("fill", x, y, w, h)
    UI.set(fill)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, h - 2)

    if o.bevel ~= false then
        UI.set(UI.c.lineSoft)
        love.graphics.rectangle("fill", x + 1, y + 1, w - 2, 2)
        UI.set(UI.c.bgDeep)
        love.graphics.rectangle("fill", x + 1, y + h - 3, w - 2, 2)
        UI.set({ 1, 1, 1 }, 0.04)
        love.graphics.rectangle("fill", x + 1, y + 1, 2, h - 2)
        UI.set({ 0, 0, 0 }, 0.18)
        love.graphics.rectangle("fill", x + w - 3, y + 1, 2, h - 2)
    end

    if o.focus then
        UI.set(UI.c.green)
        love.graphics.rectangle("fill", x + 2, y + 8, 3, h - 16)
    end
end

local gradientCache = {}

local function shade(c, f)
    return {
        math.min(1, c[1] * f),
        math.min(1, c[2] * f),
        math.min(1, c[3] * f),
        c[4] or 1,
    }
end

-- Pixel-art action fill: flat base, hard sunburst rays, hard light/dark bands.
local function colorCanvas(w, h, color)
    local key = string.format("%dx%d:%.3f,%.3f,%.3f", w, h, color[1], color[2], color[3])
    if gradientCache[key] then return gradientCache[key] end
    local ok, c = pcall(love.graphics.newCanvas, w, h)
    if not ok then return nil end

    local light = shade(color, 1.10)
    local dark = shade(color, 0.70)

    love.graphics.push("all")
    love.graphics.setCanvas(c)
    love.graphics.clear(color[1], color[2], color[3], 1)

    local cx, cy = w * 0.20, h * 0.5
    local radius = math.sqrt(w * w + h * h)
    local rays = 20
    for i = 0, rays - 1 do
        if i % 2 == 0 then
            local a1 = (i / rays) * math.pi * 2
            local a2 = ((i + 1) / rays) * math.pi * 2
            love.graphics.setColor(light[1], light[2], light[3], 1)
            love.graphics.polygon("fill",
                cx, cy,
                cx + math.cos(a1) * radius, cy + math.sin(a1) * radius,
                cx + math.cos(a2) * radius, cy + math.sin(a2) * radius)
        end
    end

    love.graphics.setColor(light[1], light[2], light[3], 1)
    love.graphics.rectangle("fill", 0, 0, w, 4)
    love.graphics.setColor(dark[1], dark[2], dark[3], 1)
    love.graphics.rectangle("fill", 0, h - 4, w, 4)

    love.graphics.pop()
    c:setFilter("nearest", "nearest")
    gradientCache[key] = c
    return c
end

-- A bright pixel action button in the Millida navigation style.
function UI.colorCard(x, y, w, h, color, opts)
    opts = opts or {}
    local focus = opts.focus
    local light = opts.light or shade(color, 1.25)

    if focus then
        UI.set({ 1, 1, 1 }, 0.10)
        love.graphics.rectangle("fill", x - 6, y - 6, w + 12, h + 12)
        UI.set({ 1, 1, 1 })
        love.graphics.rectangle("fill", x - 4, y - 4, w + 8, h + 8)
        UI.set(UI.c.bg)
        love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4)
    end

    UI.set(UI.c.bgDeep)
    love.graphics.rectangle("fill", x - 1, y - 1, w + 2, h + 2)
    UI.set(light)
    love.graphics.rectangle("fill", x, y, w, h)

    local c = colorCanvas(w - 2, h - 2, color)
    if c then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(c, x + 1, y + 1)
    else
        UI.set(color)
        love.graphics.rectangle("fill", x + 1, y + 1, w - 2, h - 2)
    end

    UI.set(light)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, 1)
    UI.set(shade(color, 0.58))
    love.graphics.rectangle("fill", x + 1, y + h - 2, w - 2, 1)
end

function UI.text(f, s, x, y, w, align, col, alpha)
    love.graphics.setFont(f)
    UI.set(col or UI.c.text, alpha)
    love.graphics.printf(s or "", x, y, w or 0, align or "left")
end

function UI.textMid(f, s, x, y, w, h, align, col, alpha)
    UI.text(f, s, x, y + math.floor((h - f:getHeight()) / 2), w, align, col, alpha)
end

-- Faux bold: redraw 1 px to the right. Crux has a single weight, and this
-- keeps headings and button labels from looking thin on a small panel.
function UI.textBold(f, s, x, y, w, align, col, alpha)
    UI.text(f, s, x, y, w, align, col, alpha)
    UI.text(f, s, x + 1, y, w, align, col, alpha)
end

function UI.textMidBold(f, s, x, y, w, h, align, col, alpha)
    UI.textMid(f, s, x, y, w, h, align, col, alpha)
    UI.textMid(f, s, x + 1, y, w, h, align, col, alpha)
end

-- Centre the visible cap-height, not the full line box. Crux has a large
-- line gap, so UPPERCASE labels otherwise sit several pixels too high.
function UI.textMidCaps(f, s, x, y, w, h, align, col, alpha)
    local dy = math.floor((f:getHeight() - f:getAscent()) / 2)
    UI.textMid(f, s, x, y + dy, w, h, align, col, alpha)
end

function UI.textMidCapsBold(f, s, x, y, w, h, align, col, alpha)
    UI.textMidCaps(f, s, x, y, w, h, align, col, alpha)
    UI.textMidCaps(f, s, x + 1, y, w, h, align, col, alpha)
end

-- UTF-8 safe one-line ellipsis.
local function prevCharStart(s, i)
    local j = i
    while j > 1 do
        local b = s:byte(j)
        if b < 0x80 or b >= 0xC0 then break end
        j = j - 1
    end
    return j
end

function UI.fit(f, s, maxw)
    s = s or ""
    if f:getWidth(s) <= maxw then return s end
    local ell = "..."
    local cut = #s
    while cut > 1 do
        cut = prevCharStart(s, cut) - 1
        if cut <= 0 then break end
        local candidate = s:sub(1, cut) .. ell
        if f:getWidth(candidate) <= maxw then return candidate end
    end
    return ell
end

-- Word wrap with a hard limit. Returns lines, truncated.
function UI.wrap(f, s, maxw, maxLines)
    s = s or ""
    local lines, cur = {}, ""
    local function push(word)
        local test = cur == "" and word or (cur .. " " .. word)
        if f:getWidth(test) <= maxw then
            cur = test
        else
            if cur ~= "" then lines[#lines + 1] = cur; cur = "" end
            if f:getWidth(word) <= maxw then
                cur = word
            else
                -- Hard-break very long tokens (paths, file names).
                local rest = word
                while rest ~= "" and #lines < maxLines do
                    local i = #rest
                    while i > 1 and f:getWidth(rest:sub(1, i) .. "...") > maxw do
                        i = prevCharStart(rest, i) - 1
                    end
                    if i <= 0 then i = 1 end
                    if f:getWidth(rest) <= maxw then
                        cur = rest
                        rest = ""
                    else
                        lines[#lines + 1] = rest:sub(1, i) .. "..."
                        rest = rest:sub(i + 1)
                        if #lines >= maxLines then return end
                    end
                end
            end
        end
    end
    for word in s:gmatch("%S+") do
        push(word)
        if #lines >= maxLines then break end
    end
    if cur ~= "" and #lines < maxLines then lines[#lines + 1] = cur end
    if #lines == 0 then lines[1] = "" end
    local joined = table.concat(lines, " ")
    local truncated = #joined < #s:gsub("%s+", " ")
    if #lines > maxLines then
        lines = { unpack(lines, 1, maxLines) }
        truncated = true
    end
    return lines, truncated
end

function UI.badge(text, x, y, variant)
    local f = UI.font.pixel8
    local w = f:getWidth(text) + 10
    local h = 18
    local border, fill, col
    if variant == "green" then
        border, fill, col = UI.c.greenDeep, UI.c.tintFocus, UI.c.greenHi
    elseif variant == "blue" then
        border, fill, col = UI.c.blueDeep, UI.c.tintBlue, UI.c.blue
    elseif variant == "orange" then
        border, fill, col = UI.c.orange, UI.c.tintOrange, UI.c.orange
    elseif variant == "red" then
        border, fill, col = UI.c.redDeep, UI.c.tintRed, UI.c.red
    else
        border, fill, col = UI.c.lineStrong, UI.c.panelAlt, UI.c.textDim
    end
    UI.set(border)
    love.graphics.rectangle("fill", x, y, w, h)
    UI.set(fill)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, h - 2)
    UI.textMidCapsBold(f, text, x, y, w, h, "center", col)
    return w
end

function UI.keycap(label, x, y, accent)
    local f = UI.font.keycap
    local size = 16
    UI.set(UI.c.bgDeep)
    love.graphics.rectangle("fill", x - 1, y - 1, size + 2, size + 2)
    UI.set(accent or UI.c.text)
    love.graphics.rectangle("fill", x, y, size, size)
    UI.set(UI.c.bgDeep)
    love.graphics.rectangle("fill", x, y + size - 2, size, 2)
    UI.textMidCaps(f, label, x, y, size, size - 1, "center", UI.c.bgDeep)
end

function UI.footer(hints, rightText)
    local y = UI.L.h - UI.L.footer
    UI.set(UI.c.footer)
    love.graphics.rectangle("fill", 0, y, UI.L.w, UI.L.footer)
    UI.set(UI.c.line)
    love.graphics.rectangle("fill", 0, y, UI.L.w, 1)

    local x = UI.L.margin
    local mid = y + math.floor((UI.L.footer - 16) / 2)
    local lf = UI.font.pixel8
    for _, hint in ipairs(hints) do
        UI.keycap(hint.key, x, mid, hint.accent)
        x = x + 20
        UI.textMidBold(lf, hint.label, x, mid, 240, 16, "left", UI.c.textDim)
        x = x + lf:getWidth(hint.label) + 16
    end
    if rightText and rightText ~= "" then
        UI.textMidBold(UI.font.pixel8, rightText, UI.L.margin, y,
            UI.L.w - UI.L.margin * 2, UI.L.footer, "right", UI.c.textMuted)
    end
end

function UI.section(label, rightText, y)
    y = y or UI.L.sectionTop
    UI.textBold(UI.font.pixel8, label, UI.L.margin, y + 1,
        UI.L.w - UI.L.margin * 2 - 120, "left", UI.c.text, 0.85)
    if rightText and rightText ~= "" then
        UI.textBold(UI.font.pixel8, rightText, UI.L.w - UI.L.margin - 140, y + 1, 140,
            "right", UI.c.textMuted)
    end
end

-- ---------------------------------------------------------------- buttons

function UI.button(label, x, y, w, h, o)
    o = o or {}
    local focus = o.focus
    local disabled = o.disabled
    local danger = o.danger
    local border = disabled and UI.c.line or (danger and UI.c.red or UI.c.greenHi)
    local fill = disabled and UI.c.panelAlt or (danger and UI.c.red or UI.c.green)
    local ink = disabled and UI.c.textMuted or (danger and UI.c.white or UI.c.greenInk)
    local top = disabled and UI.c.panel or (danger and shade(UI.c.red, 1.20) or UI.c.greenHi)
    local bottom = disabled and UI.c.bgDeep or (danger and shade(UI.c.red, 0.70) or UI.c.greenDeep)

    if focus then
        UI.set(UI.c.green, 0.12)
        love.graphics.rectangle("fill", x - 6, y - 6, w + 12, h + 12)
        UI.set(UI.c.green)
        love.graphics.rectangle("fill", x - 4, y - 4, w + 8, h + 8)
        UI.set(UI.c.bg)
        love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4)
        border = UI.c.greenHi
    end

    UI.set(UI.c.bgDeep)
    love.graphics.rectangle("fill", x - 1, y - 1, w + 2, h + 2)
    UI.set(border)
    love.graphics.rectangle("fill", x, y, w, h)
    UI.set(fill)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, h - 2)

    -- hard pixel shading
    UI.set(top)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, 4)
    UI.set(bottom)
    love.graphics.rectangle("fill", x + 1, y + h - 5, w - 2, 4)
    UI.set({ 1, 1, 1 }, 0.10)
    love.graphics.rectangle("fill", x + 1, y + 1, w - 2, 1)
    UI.set({ 0, 0, 0 }, 0.18)
    love.graphics.rectangle("fill", x + 1, y + h - 2, w - 2, 1)

    local f = h >= 48 and UI.font.pixel24 or (h >= 36 and UI.font.pixel16 or UI.font.pixel8)
    if disabled then
        UI.textMidCapsBold(f, label, x, y, w, h, "center", ink)
        return
    end

    local tri = h >= 48 and 16 or (h >= 44 and 13 or 10)
    local gap = 9
    local lw = f:getWidth(label)
    local groupW = tri + gap + lw
    local gx = x + math.floor((w - groupW) / 2)
    local cy = y + math.floor(h / 2)
    UI.set(ink)
    love.graphics.polygon("fill", gx, cy - tri / 2, gx, cy + tri / 2, gx + tri, cy)
    UI.textMidCapsBold(f, label, gx + tri + gap, y, lw, h, "left", ink)
end

function UI.progress(x, y, w, h, frac, indeterminate, t)
    UI.set(UI.c.bgDeep)
    love.graphics.rectangle("fill", x, y, w, h)
    UI.set(UI.c.line)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1)
    UI.set(UI.c.lineSoft)
    love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4)

    local iw = w - 4
    if indeterminate then
        local block = math.floor(iw * 0.28)
        local span = iw + block
        local px = x + 2 + (math.floor((t or 0) * 12) % 12) * math.floor(span / 12) - block
        local x0 = math.max(x + 2, px)
        local x1 = math.min(x + 2 + iw, px + block)
        if x1 > x0 then
            UI.set(UI.c.green)
            love.graphics.rectangle("fill", x0, y + 2, x1 - x0, h - 4)
        end
    else
        local fw = math.floor(iw * math.max(0, math.min(1, frac or 0)))
        if fw > 0 then
            UI.set(UI.c.green)
            love.graphics.rectangle("fill", x + 2, y + 2, fw, h - 4)
            UI.set({ 1, 1, 1 }, 0.18)
            love.graphics.rectangle("fill", x + 2, y + 2, fw, 2)
            UI.set({ 0, 0, 0 }, 0.12)
            for sx = x + 2, x + 2 + fw - 14, 12 do
                love.graphics.rectangle("fill", sx, y + 2, 3, h - 4)
            end
        end
    end
end

function UI.modal(title, body, buttons, focus)
    UI.set(UI.c.scrim)
    love.graphics.rectangle("fill", 0, 0, UI.L.w, UI.L.h)
    local w, h = 400, 160
    local x, y = math.floor((UI.L.w - w) / 2), 160
    UI.panel(x, y, w, h, { fill = UI.c.panelAlt, border = UI.c.lineStrong })
    UI.textBold(UI.font.pixel16, title, x + 16, y + 14, w - 32, "left", UI.c.white)
    love.graphics.setFont(UI.font.body11)
    for i, line in ipairs(body or {}) do
        UI.set(UI.c.textDim)
        love.graphics.printf(line, x + 16, y + 44 + (i - 1) * 17, w - 32, "left")
    end
    local bw, bh, gap = 140, 36, 12
    local total = #buttons * bw + (#buttons - 1) * gap
    local bx = x + math.floor((w - total) / 2)
    local by = y + h - 16 - bh
    for i, b in ipairs(buttons) do
        local focused = focus == i
        local px = bx + (i - 1) * (bw + gap)
        if focused then
            UI.set(UI.c.green, 0.12)
            love.graphics.rectangle("fill", px - 4, by - 4, bw + 8, bh + 8)
            UI.set(UI.c.green)
            love.graphics.rectangle("fill", px - 2, by - 2, bw + 4, bh + 4)
        end
        local danger = b.variant == "danger"
        local primary = b.variant == "primary"
        local border = danger and UI.c.red or (primary and UI.c.greenHi or UI.c.lineStrong)
        local fill = danger and UI.c.red or (primary and UI.c.green or UI.c.panel)
        local ink = danger and UI.c.white or (primary and UI.c.greenInk or (focused and UI.c.greenHi or UI.c.text))
        local top = danger and shade(UI.c.red, 1.20) or (primary and UI.c.greenHi or UI.c.lineSoft)
        local bottom = danger and shade(UI.c.red, 0.70) or (primary and UI.c.greenDeep or UI.c.bgDeep)
        UI.set(UI.c.bgDeep)
        love.graphics.rectangle("fill", px - 1, by - 1, bw + 2, bh + 2)
        UI.set(border)
        love.graphics.rectangle("fill", px, by, bw, bh)
        UI.set(fill)
        love.graphics.rectangle("fill", px + 1, by + 1, bw - 2, bh - 2)
        UI.set(top)
        love.graphics.rectangle("fill", px + 1, by + 1, bw - 2, 3)
        UI.set(bottom)
        love.graphics.rectangle("fill", px + 1, by + bh - 4, bw - 2, 3)
        UI.textMidCapsBold(UI.font.pixel8, b.label, px, by, bw, bh, "center", ink)
    end
end

-- ---------------------------------------------------------------- icons

local PAL = {
    g = UI.c.green, G = UI.c.greenDeep, l = UI.c.greenHi,
    d = hex("#8A5A2B"), D = hex("#6B4420"), o = UI.c.orange,
    k = hex("#24242B"), w = hex("#CFCFD8"), m = hex("#8F8F9C"),
    r = UI.c.red, R = UI.c.redDeep, b = UI.c.blue, B = UI.c.blueDeep,
    y = UI.c.yellow, t = hex("#3A3A45"),
}

-- Pixelarticons (MIT) webfont glyphs. The TTF is a 24 px icon font; use it at
-- 24 px inside 26-32 px wells. Bitmap fallbacks below are used if it is absent.
UI.glyph = {
    package    = 0xecb9,
    download   = 0xeb7f,
    logout     = 0xec70,
    file       = 0xeb9a,
    cpu        = 0xeb5b,
    warning    = 0xed5a,
    loader     = 0xec67,
}

local BITMAP_ALIAS = {
    package = "chest",
    logout = "door",
    file = "apk",
    cpu = "chip",
}

local ICONS = {
    grass = {
        "................", ".....gggggg.....", "...gggggggggg...", "..gggggggggggg..",
        ".gggggggggggggg.", ".gggggggggggggg.", "GGGGGGGGGGGGGGGG", "dddddddddddddddd",
        "ddDdddddDddddddd", "ddddddDddddddddd", "ddDddddddddDdddd", "ddddddddDddddddd",
        "dddDdddddddddddd", "dddddddddddddddd", "DDDDDDDDDDDDDDDD", "................",
    },
    chest = {
        "................", "................", "..kkkkkkkkkkkk..", "..kddddddddddk..",
        "..kdwwddddwwdk..", "..kddddddddddk..", "..kkkkkkkkkkkk..", "..kddddkkddddk..",
        "..kddddkkddddk..", "..kddddddddddk..", "..kddddddddddk..", "..kkkkkkkkkkkk..",
        "................", "................", "................", "................",
    },
    download = {
        "................", ".......ww.......", "......wwww......", ".....wwwwww.....",
        "....wwwwwwww....", ".......ww.......", ".......ww.......", ".......ww.......",
        ".......ww.......", "..wwwwwwwwwwww..", "..wwwwwwwwwwww..", "...wwwwwwwwww...",
        "................", "................", "................", "................",
    },
    door = {
        "................", "...kkkkkkkkkk...", "...kwwwwwwwwk...", "...kwwwwwwwwk...",
        "...kwwwwwwwwk...", "...kwwwwwwwwk...", "...kwwwwwwwwk...", "...kwwwwwwwkk...",
        "...kwwwwwwwwk...", "...kwwwwwwwwk...", "...kwwwwwwwwk...", "...kwwwwwwwwk...",
        "...kwwwwwwwwk...", "...kkkkkkkkkk...", "................", "................",
    },
    apk = {
        "................", "................", "..tttttttttttt..", "..tkkkkkkkkkkt..",
        "..tkgggggggkt...", "..tkkkkkkkkkkt..", "..tkgggggggkt...", "..tkkkkkkkkkkt..",
        "..tkgggggkkkt...", "..tkkkkkkkkkkt..", "..tkgggggggkt...", "..tkkkkkkkkkkt..",
        "..tttttttttttt..", "................", "................", "................",
    },
    chip = {
        "................", "...w........w...", "...w........w...", ".wwwwwwwwwwwwww.",
        ".wwwwwwwwwwwwww.", ".w.kkkkkkkkkk.w.", ".w.kggggggggk.w.", ".w.kggggggggk.w.",
        ".w.kggggggggk.w.", ".w.kggggggggk.w.", ".w.kkkkkkkkkk.w.", ".wwwwwwwwwwwwww.",
        ".wwwwwwwwwwwwww.", "...w........w...", "...w........w...", "................",
    },
    trash = {
        "................", "......kkkk......", "...kkkkkkkkkk...", "...kwwwwwwwwk...",
        "....kkkkkkkk....", "....kwwwwwwk....", "....kwkwwkwk....", "....kwkwwkwk....",
        "....kwkwwkwk....", "....kwkwwkwk....", "....kwwwwwwk....", ".....kkkkkk.....",
        "................", "................", "................", "................",
    },
    warning = {
        "................", ".......k........", "......kyk.......", "......kyk.......",
        ".....kyyyk......", ".....kyyyk......", "....kyyyyyk.....", "....kyyyyyk.....",
        "...kyyyyyyyk....", "...kyyyyyyyk....", "..kyyyyyyyyyk...", "..kyyykykyyyk...",
        "..kyyykykyyyk...", ".kyyyyyyyyyyyk..", ".kkkkkkkkkkkkkk.", "................",
    },
    check = {
        "................", "................", "............ww..", "...........www..",
        "..........www...", ".........www....", "..w.....www.....", "..ww...www......",
        "...ww.www.......", "....wwww........", ".....ww.........", "................",
        "................", "................", "................", "................",
    },
    cross = {
        "................", "..rr........rr..", "..rrr......rrr..", "...rrr....rrr...",
        "....rrr..rrr....", ".....rrrrrr.....", "......rrrr......", "......rrrr......",
        ".....rrrrrr.....", "....rrr..rrr....", "...rrr....rrr...", "..rrr......rrr..",
        "..rr........rr..", "................", "................", "................",
    },
    play = {
        "................", "....gg..........", "....gggg........", "....gggggg......",
        "....gggggggg....", "....gggggggggg..", "....gggggggggggg", "....gggggggggggg",
        "....gggggggggggg", "....gggggggg....", "....gggggg......", "....gggg........",
        "....gg..........", "................", "................", "................",
    },
}

local iconCache = {}

local function utf8char(cp)
    if cp < 0x80 then return string.char(cp) end
    if cp < 0x800 then
        return string.char(0xC0 + math.floor(cp / 0x40), 0x80 + cp % 0x40)
    end
    return string.char(
        0xE0 + math.floor(cp / 0x1000),
        0x80 + math.floor(cp / 0x40) % 0x40,
        0x80 + cp % 0x40)
end

local function iconCanvas(name, scale)
    local key = name .. ":" .. scale
    if iconCache[key] then return iconCache[key] end
    local rows = ICONS[name]
    if not rows then return nil end
    local c = love.graphics.newCanvas(16 * scale, 16 * scale)
    love.graphics.push("all")
    love.graphics.setCanvas(c)
    love.graphics.clear(0, 0, 0, 0)
    for y, row in ipairs(rows) do
        for x = 1, 16 do
            local ch = row:sub(x, x)
            local col = PAL[ch]
            if col then
                UI.set(col)
                love.graphics.rectangle("fill", (x - 1) * scale, (y - 1) * scale, scale, scale)
            end
        end
    end
    love.graphics.pop()
    c:setFilter("nearest", "nearest")
    iconCache[key] = c
    return c
end

local glyphCache = {}

local function glyphImage(cp)
    if glyphCache[cp] then return glyphCache[cp] end
    local f = UI.font.icons
    if not f then return nil end
    local w, h = 24, 24
    local ok, c = pcall(love.graphics.newCanvas, w, h)
    if not ok then return nil end
    love.graphics.push("all")
    love.graphics.setCanvas(c)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setFont(f)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(utf8char(cp), 0, 0)
    love.graphics.pop()

    local okData, data = pcall(function() return c:newImageData() end)
    if not okData or not data then return nil end
    -- 1-bit alpha: removes FreeType anti-aliasing for a true pixel icon.
    for py = 0, h - 1 do
        for px = 0, w - 1 do
            local _, _, _, a = data:getPixel(px, py)
            data:setPixel(px, py, 1, 1, 1, (a or 0) >= 0.5 and 1 or 0)
        end
    end
    local img = love.graphics.newImage(data)
    img:setFilter("nearest", "nearest")
    glyphCache[cp] = img
    return img
end

function UI.icon(name, x, y, box, color)
    local cp = UI.glyph[name]
    local f = UI.font.icons
    local img = cp and glyphImage(cp) or nil
    if img then
        local iw, ih = img:getDimensions()
        UI.set(color or UI.c.text)
        love.graphics.draw(img,
            math.floor(x + (box - iw) / 2),
            math.floor(y + (box - ih) / 2))
        return
    end
    if cp and f then
        local ch = utf8char(cp)
        local gw, gh = f:getWidth(ch), f:getHeight()
        UI.set(color or UI.c.text)
        love.graphics.setFont(f)
        love.graphics.print(ch,
            math.floor(x + (box - gw) / 2),
            math.floor(y + (box - gh) / 2))
        return
    end
    local scale = math.max(1, math.floor((box or 16) / 16))
    local c = iconCanvas(BITMAP_ALIAS[name] or name, scale)
    if not c then return end
    local size = 16 * scale
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(c, math.floor(x + (box - size) / 2), math.floor(y + (box - size) / 2))
end

local logoImage

function UI.logo(x, y, box)
    box = box or 42
    if not logoImage then
        local ok, img = pcall(love.graphics.newImage, "icon.png")
        if ok then
            img:setFilter("nearest", "nearest")
            logoImage = img
        end
    end
    if not logoImage then
        UI.icon("grass", x, y, box)
        return
    end
    local iw, ih = logoImage:getDimensions()
    local s = box / iw
    local dw, dh = iw * s, ih * s
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(logoImage,
        math.floor(x + (box - dw) / 2),
        math.floor(y + (box - dh) / 2), 0, s, s)
end

-- ---------------------------------------------------------------- background

function UI.cover(img, x, y, w, h)
    local iw, ih = img:getDimensions()
    local s = math.max(w / iw, h / ih)
    local dw, dh = iw * s, ih * s
    love.graphics.draw(img, x + (w - dw) / 2, y + (h - dh) / 2, 0, s, s)
end

local bgImage
local heroCache = {}
local backdropCache

function UI.background()
    if not bgImage then
        local ok, img = pcall(love.graphics.newImage, "bg.jpg")
        if ok then bgImage = img end
    end
    return bgImage
end

-- Hero art: cropped panorama with a left-to-right fade to panel colour.
function UI.heroCanvas(w, h)
    local key = w .. "x" .. h
    if heroCache[key] then return heroCache[key] end
    local ok, c = pcall(love.graphics.newCanvas, w, h)
    if not ok then return nil end
    love.graphics.push("all")
    love.graphics.setCanvas(c)
    love.graphics.clear(UI.c.panel[1], UI.c.panel[2], UI.c.panel[3], 1)
    local img = UI.background()
    if img then
        UI.set({ 1, 1, 1 }, 0.62)
        UI.cover(img, 0, 0, w, h)
        UI.set(UI.c.bg, 0.46)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    local strips = 96
    local sw = math.ceil(w / strips)
    for i = 0, strips - 1 do
        local a = 0.94 * (1 - i / (strips - 1))
        UI.set(UI.c.panel, a)
        love.graphics.rectangle("fill", i * sw, 0, sw, h)
    end
    -- Cut the four notched corners without using a stencil (some Mali
    -- drivers handle stencil state poorly).
    local r = math.max(2, UI.L.notch - 1)
    love.graphics.setBlendMode("replace", "premultiplied")
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.polygon("fill", 0, 0, r, 0, 0, r)
    love.graphics.polygon("fill", w, 0, w - r, 0, w, r)
    love.graphics.polygon("fill", w, h, w - r, h, w, h - r)
    love.graphics.polygon("fill", 0, h, r, h, 0, h - r)
    love.graphics.setBlendMode("alpha")
    love.graphics.pop()
    heroCache[key] = c
    return c
end

function UI.drawHeroArt(x, y, w, h)
    local c = UI.heroCanvas(w, h)
    if c then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(c, x, y)
    else
        UI.set(UI.c.panel)
        love.graphics.rectangle("fill", x, y, w, h)
    end
end

function UI.backdrop()
    if backdropCache then return backdropCache end
    local ok, c = pcall(love.graphics.newCanvas, UI.L.w, UI.L.h)
    if not ok then return nil end
    love.graphics.push("all")
    love.graphics.setCanvas(c)
    love.graphics.clear(UI.c.bg[1], UI.c.bg[2], UI.c.bg[3], 1)
    local img = UI.background()
    if img then
        UI.set({ 1, 1, 1 }, 0.55)
        UI.cover(img, 0, 0, UI.L.w, UI.L.h)
        UI.set(UI.c.bg, 0.74)
        love.graphics.rectangle("fill", 0, 0, UI.L.w, UI.L.h)
    end
    love.graphics.pop()
    backdropCache = c
    return c
end

function UI.drawBackdrop(c)
    c = c or UI.backdrop()
    if c then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(c, 0, 0)
    else
        UI.set(UI.c.bg)
        love.graphics.rectangle("fill", 0, 0, UI.L.w, UI.L.h)
    end
end

-- ---------------------------------------------------------------- helpers

function UI.humanSize(bytes)
    if not bytes or bytes <= 0 then return "--" end
    if bytes >= 1024 * 1024 * 1024 then
        return string.format("%.1f GB", bytes / (1024 * 1024 * 1024))
    end
    return string.format("%d MB", math.floor(bytes / (1024 * 1024)))
end

function UI.archLabel(armhf, arm64)
    if arm64 and armhf then return "ARM64 + ARM32" end
    if arm64 then return "ARM64" end
    if armhf then return "ARM32" end
    return "NO ABI"
end

function UI.isAscii(s)
    return s:find("[^\32-\126]") == nil
end

return UI
