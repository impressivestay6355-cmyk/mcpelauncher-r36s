local M = {}

local G = love.graphics
local Lang = require("lang")
local T = Lang.t
local W, H, u
local fTitle, fBig, fText, fSmall
local C = {
    accent = {0.99, 0.78, 0.28},
    text   = {0.95, 0.96, 0.97},
    dim    = {0.60, 0.63, 0.68},
    faint  = {0.38, 0.40, 0.45},
    card   = {0.09, 0.10, 0.13, 0.84},
    cardHi = {0.19, 0.15, 0.07, 0.94},
    bar    = {0.03, 0.04, 0.05, 0.88},
    red    = {0.95, 0.35, 0.32},
    a32    = {0.96, 0.56, 0.30},
    a64    = {0.40, 0.86, 0.94},
}
local ACT = {
    {tk = "setup_apk", sk = "act_setup_sub", col = {1.0, 0.8, 0.25}, icon = "setup"},
    {tk = "settings", sk = "act_settings_sub", col = {0.66, 0.73, 0.86}, icon = "gear"},
    {tk = "update", sk = "act_update_sub", col = {0.4, 0.82, 1.0}, icon = "update"},
    {tk = "exit", sk = "act_exit_sub", col = {0.9, 0.3, 0.3}, icon = "exit"},
}
local GRASS = {
    "GGLGGGLG",
    "GLGGLGGL",
    "GGBGGBGG",
    "BGBBBGBB",
    "BBDBBBBD",
    "BBBBDBBB",
    "DBBBBBDB",
    "BBDBBBBB",
}
local GCOL = {
    G = {0.36, 0.66, 0.22}, L = {0.47, 0.78, 0.30},
    B = {0.55, 0.38, 0.23}, D = {0.42, 0.28, 0.17},
}

local function S(x) return math.floor(x * u + 0.5) end

local function col(c, a) G.setColor(c[1], c[2], c[3], a or c[4] or 1) end

function M.load(w, h)
    W, H = w, h
    u = math.min(W / 640, H / 480)
    fTitle = Lang.font("font_titolo.ttf", math.max(14, S(22)))
    fBig   = Lang.font("font_testo.ttf", math.max(13, S(18)))
    fText  = Lang.font("font_testo.ttf", math.max(12, S(15)))
    fSmall = Lang.font("font_testo.ttf", math.max(10, S(12)))
end

local function textMid(font, s, x, y, h)
    G.setFont(font)
    G.print(s, math.floor(x), math.floor(y + (h - font:getHeight()) / 2))
end

local function chip(x, y, s, c, filled)
    G.setFont(fSmall)
    local pw, ph = fSmall:getWidth(s) + S(12), fSmall:getHeight() + S(4)
    if filled then
        col(c, 0.22)
        G.rectangle("fill", x, y, pw, ph, S(4), S(4))
    end
    G.setLineWidth(math.max(1, S(1)))
    col(c, 0.9)
    G.rectangle("line", x + 0.5, y + 0.5, pw - 1, ph - 1, S(4), S(4))
    G.print(s, math.floor(x + S(6)), math.floor(y + S(2)))
    return pw
end

local function archChips(x, y, a)
    if not a then return end
    local cx = x
    if a.a32 then cx = cx + chip(cx, y, "ARM32", C.a32, true) + S(6) end
    if a.a64 then chip(cx, y, "ARM64", C.a64, true) end
end

local function card(x, y, w, h, selected, tint, border)
    col(tint or (selected and C.cardHi or C.card))
    G.rectangle("fill", x, y, w, h, S(8), S(8))
    if border then
        G.setLineWidth(math.max(1, S(2)))
        col(border)
        G.rectangle("line", x + 1, y + 1, w - 2, h - 2, S(8), S(8))
    end
end

local function grass(x, y, size)
    local p = size / 8
    for r = 1, 8 do
        local row = GRASS[r]
        for c = 1, 8 do
            col(GCOL[row:sub(c, c)])
            G.rectangle("fill", x + (c - 1) * p, y + (r - 1) * p, math.ceil(p), math.ceil(p))
        end
    end
end

local function icon(kind, cx, cy, r, ic)
    G.setLineWidth(math.max(1.5, r * 0.16))
    col(ic or {1, 1, 1, 0.95})
    if kind == "setup" then
        G.line(cx, cy - r * 0.75, cx, cy + r * 0.15)
        G.polygon("fill", cx - r * 0.42, cy - r * 0.05, cx + r * 0.42, cy - r * 0.05, cx, cy + r * 0.42)
        G.line(cx - r * 0.75, cy + r * 0.25, cx - r * 0.75, cy + r * 0.7, cx + r * 0.75, cy + r * 0.7, cx + r * 0.75, cy + r * 0.25)
    elseif kind == "gear" then
        for i = 0, 7 do
            local a = i * math.pi / 4
            G.push()
            G.translate(cx, cy)
            G.rotate(a)
            G.rectangle("fill", -r * 0.16, -r * 0.82, r * 0.32, r * 0.34)
            G.pop()
        end
        G.circle("fill", cx, cy, r * 0.55)
        G.setColor(0.07, 0.07, 0.09, 1)
        G.circle("fill", cx, cy, r * 0.24)
    elseif kind == "update" then
        G.arc("line", "open", cx, cy, r * 0.6, -math.pi * 0.35, math.pi * 1.35, 24)
        local ax, ay = cx + r * 0.6 * math.cos(-math.pi * 0.35), cy + r * 0.6 * math.sin(-math.pi * 0.35)
        G.polygon("fill", ax - r * 0.32, ay - r * 0.12, ax + r * 0.18, ay - r * 0.34, ax + r * 0.12, ay + r * 0.22)
    else
        G.line(cx + r * 0.05, cy - r * 0.7, cx - r * 0.6, cy - r * 0.7, cx - r * 0.6, cy + r * 0.7, cx + r * 0.05, cy + r * 0.7)
        G.line(cx - r * 0.2, cy, cx + r * 0.55, cy)
        G.polygon("fill", cx + r * 0.75, cy, cx + r * 0.38, cy - r * 0.32, cx + r * 0.38, cy + r * 0.32)
    end
end

local function background(c)
    G.setColor(1, 1, 1, 1)
    local iw, ih = c.bg:getWidth(), c.bg:getHeight()
    local sc = math.max(W / iw, H / ih)
    G.draw(c.bg, (W - iw * sc) / 2, (H - ih * sc) / 2, 0, sc, sc)
    G.setColor(0.03, 0.04, 0.06, 0.74)
    G.rectangle("fill", 0, 0, W, H)
end

local function topBar(c, title)
    local th = S(52)
    col(C.bar)
    G.rectangle("fill", 0, 0, W, th)
    col(C.accent, 0.85)
    G.rectangle("fill", 0, th - math.max(1, S(2)), math.floor(W * 0.28), math.max(1, S(2)))
    col(C.faint, 0.5)
    G.rectangle("fill", math.floor(W * 0.28), th - 1, W, 1)
    local pad = S(16)
    local gs = S(26)
    grass(pad, math.floor((th - gs) / 2), gs)
    col(C.text)
    textMid(fTitle, title, pad + gs + S(12), 0, th)
    local tx = pad + gs + S(12) + fTitle:getWidth(title) + S(10)
    if c.portVersion ~= "" and title == "MCPE Launcher" then
        chip(tx, math.floor((th - fSmall:getHeight() - S(4)) / 2), "v" .. c.portVersion, C.faint, false)
    end
    return th
end

local function glyph(x, y, key, okL)
    local r = S(9)
    G.setFont(fSmall)
    if key == "dpad" then
        local s = r * 0.55
        G.setColor(0.85, 0.87, 0.9, 1)
        G.rectangle("fill", x + r - s / 2, y + r - r * 0.95, s, r * 1.9, 2, 2)
        G.rectangle("fill", x + r - r * 0.95, y + r - s / 2, r * 1.9, s, 2, 2)
        return r * 2
    end
    G.setColor(0.88, 0.89, 0.91, 1)
    G.rectangle("fill", x, y + r * 0.1, r * 2, r * 1.8, S(4), S(4))
    G.setColor(0.55, 0.56, 0.6, 1)
    G.rectangle("fill", x, y + r * 1.6, r * 2, r * 0.3, S(2), S(2))
    G.setColor(0.08, 0.08, 0.1, 1)
    local tw = fSmall:getWidth(key)
    G.print(key, math.floor(x + r - tw / 2 + 0.5), math.floor(y + r - fSmall:getHeight() / 2 + 0.5))
    return r * 2
end

local function bottomBar(c, hints, right)
    local bh = S(34)
    local y0 = H - bh
    col(C.bar)
    G.rectangle("fill", 0, y0, W, bh)
    col(C.faint, 0.5)
    G.rectangle("fill", 0, y0, W, 1)
    local x = S(16)
    local gy = y0 + math.floor((bh - S(18)) / 2)
    for _, h in ipairs(hints) do
        local key = h[1]
        if key == "OK" then key = c.okL elseif key == "BACK" then key = c.backL end
        x = x + glyph(x, gy, key) + S(6)
        col(C.text, 0.9)
        textMid(fSmall, h[2], x, y0, bh)
        x = x + fSmall:getWidth(h[2]) + S(16)
    end
    if right and right ~= "" then
        col(C.dim)
        G.setFont(fSmall)
        textMid(fSmall, right, W - S(16) - fSmall:getWidth(right), y0, bh)
    end
    return bh
end

local function section(x, y, w, label, right)
    G.setFont(fSmall)
    col(C.dim)
    G.print(label, x + S(2), y)
    if right and right ~= "" then
        G.print(right, math.floor(x + w - fSmall:getWidth(right) - S(2)), y)
    end
    return fSmall:getHeight() + S(6)
end

function M.stacked(w, h)
    w, h = w or W, h or H
    return h >= w * 0.85
end

local function drawTile(c, a, x, y, w, h, isSel)
    local t = ACT[a]
    if isSel then
        card(x, y, w, h, true, {t.col[1] * 0.25, t.col[2] * 0.25, t.col[3] * 0.25, 0.94}, t.col)
    else
        card(x, y, w, h, false)
    end
    local is = math.min(S(38), h - S(14))
    local ix, iy = x + S(10), y + math.floor((h - is) / 2)
    G.setColor(0.04, 0.04, 0.05, 0.9)
    G.rectangle("fill", ix, iy, is, is, S(6), S(6))
    G.setLineWidth(math.max(1, S(1)))
    col(t.col, isSel and 1 or 0.55)
    G.rectangle("line", ix + 0.5, iy + 0.5, is - 1, is - 1, S(6), S(6))
    icon(t.icon, ix + is / 2, iy + is / 2, is * 0.42, t.col)
    local tx = ix + is + S(10)
    local tw = w - (tx - x) - S(8)
    local sub = T(t.sk)
    if a == 3 and c.portVersion ~= "" then sub = T("installed_v", c.portVersion) end
    local block = fText:getHeight() + S(2) + fSmall:getHeight()
    local ty = y + math.floor((h - block) / 2)
    if h < S(44) then ty = y + math.floor((h - fText:getHeight()) / 2) end
    col(C.text)
    G.setFont(fText)
    G.print(c.fitText(fText, T(t.tk), tw), tx, ty)
    if h >= S(44) then
        col(isSel and {0.85, 0.87, 0.9} or C.dim)
        G.setFont(fSmall)
        G.print(c.fitText(fSmall, sub, tw), tx, ty + fText:getHeight() + S(2))
    end
end

local function drawMain(c)
    local th = topBar(c, "MCPE Launcher")
    local focusList = c.focusCol == "list" and #c.versions > 0
    local stacked = M.stacked()
    local hints
    if focusList then
        hints = {{"OK", T("hint_play")}, {"X", T("hint_delete")}, {"dpad", stacked and T("hint_move") or T("hint_menu")}, {"BACK", T("hint_exit")}}
    else
        hints = {{"OK", T("hint_open")}, {"dpad", (#c.versions > 0 and not stacked) and T("hint_versions") or T("hint_move")}, {"BACK", T("hint_exit")}}
    end
    local bh = bottomBar(c, hints, os.date("%H:%M"))
    local pad = S(16)
    local gap = S(8)
    local top = th + S(12)
    local bottom = H - bh - S(10)
    local total = #c.versions
    local lx, rx, leftW, rightW, listBottom
    if stacked then
        leftW = W - 2 * pad
        lx = pad
        local tileH = S(64)
        local gridH = fSmall:getHeight() + S(6) + 2 * tileH + gap
        listBottom = bottom - gridH - S(12)
        local gy = listBottom + S(12)
        gy = gy + section(pad, gy, leftW, T("sec_menu"))
        local tw = math.floor((leftW - gap) / 2)
        for a = 1, 4 do
            local cx = pad + ((a - 1) % 2) * (tw + gap)
            local cy = gy + math.floor((a - 1) / 2) * (tileH + gap)
            drawTile(c, a, cx, cy, tw, tileH, (not focusList) and c.selMain == total + a)
        end
    else
        rightW = math.floor((W - 3 * pad) * 0.36)
        leftW = W - 3 * pad - rightW
        lx, rx = pad, pad + leftW + pad
        listBottom = bottom
    end
    bottom = listBottom

    local cnt = T("n_installed", total)
    local ly = top + section(lx, top, leftW, T("sec_versions"), cnt)
    local cardH = S(58)
    if total == 0 then
        card(lx, ly, leftW, cardH + S(20), false, nil, {C.faint[1], C.faint[2], C.faint[3], 0.6})
        col(C.text)
        G.setFont(fBig)
        G.print(T("no_versions"), lx + S(14), ly + S(12))
        col(C.dim)
        G.setFont(fSmall)
        G.printf(T("no_versions_sub"), lx + S(14), ly + S(18) + fBig:getHeight(), leftW - S(28), "left")
    else
        local visible = math.max(1, math.floor((bottom - ly + gap) / (cardH + gap)))
        local sel = math.min(math.max(c.selMain, 1), total)
        local off = c.scrollOffset(sel, total, visible)
        for row = 1, math.min(visible, total) do
            local i = row + off
            local v = c.versions[i]
            local y = ly + (row - 1) * (cardH + gap)
            local isSel = i == c.selMain and focusList
            local armed = c.confirmDeleteVer == v
            if armed then
                card(lx, y, leftW, cardH, true, {0.32, 0.08, 0.08, 0.94}, C.red)
            elseif isSel then
                card(lx, y, leftW, cardH, true, nil, C.accent)
                col(C.accent)
                G.rectangle("fill", lx + S(3), y + S(10), S(3), cardH - S(20), S(2), S(2))
            else
                card(lx, y, leftW, cardH, false, nil, (i == c.selMain and not focusList) and {1, 1, 1, 0.12} or nil)
            end
            local pillW = 0
            if armed then
                G.setFont(fSmall)
                local s = T("again_delete")
                pillW = fSmall:getWidth(s) + S(16)
                col(C.red)
                G.print(s, math.floor(lx + leftW - pillW), math.floor(y + (cardH - fSmall:getHeight()) / 2))
            elseif isSel then
                G.setFont(fText)
                local s = T("play")
                local tw = fText:getWidth(s)
                pillW = tw + S(40)
                local ph = S(28)
                local px, py = lx + leftW - pillW - S(12), y + math.floor((cardH - ph) / 2)
                col(C.accent)
                G.rectangle("fill", px, py, pillW, ph, S(6), S(6))
                G.setColor(0.05, 0.12, 0.06, 1)
                local tr = S(6)
                local tcx, tcy = px + S(14), py + ph / 2
                G.polygon("fill", tcx - tr * 0.6, tcy - tr, tcx - tr * 0.6, tcy + tr, tcx + tr * 0.8, tcy)
                G.print(s, math.floor(px + S(26)), math.floor(py + (ph - fText:getHeight()) / 2))
                pillW = pillW + S(12)
            end
            col(armed and C.red or (isSel and C.text or {0.85, 0.87, 0.9}))
            G.setFont(fBig)
            G.print(c.fitText(fBig, v, leftW - S(28) - pillW), lx + S(14), y + S(8))
            archChips(lx + S(14), y + cardH - S(10) - fSmall:getHeight() - S(4), c.verArch[v])
        end
        if total > visible then
            G.setFont(fSmall)
            col(C.dim)
            local s = sel .. "/" .. total
            G.print(s, math.floor(lx + leftW - fSmall:getWidth(s) - S(2)), bottom - fSmall:getHeight() + S(8))
        end
    end

    if stacked then return end
    local ry = top + section(rx, top, rightW, T("sec_menu"))
    local tileH = math.min(S(68), math.floor((bottom - ry - 3 * gap) / 4))
    for a = 1, 4 do
        drawTile(c, a, rx, ry + (a - 1) * (tileH + gap), rightW, tileH, (not focusList) and c.selMain == total + a)
    end
end

local function sizeText(n)
    if not n or n <= 0 then return nil end
    local mb = n / 1048576
    if mb >= 1024 then return string.format("%.1f GB", mb / 1024) end
    return string.format("%d MB", math.max(1, math.floor(mb + 0.5)))
end

local function drawApk(c)
    local th = topBar(c, T("setup_apk"))
    local hints = c.confirmDelete and {{"X", T("hint_delete")}, {"BACK", T("hint_cancel")}} or {{"OK", T("hint_install")}, {"X", T("hint_delete")}, {"BACK", T("hint_back")}}
    local bh = bottomBar(c, hints)
    local pad, gap = S(16), S(8)
    local top = th + S(12)
    local bottom = H - bh - S(10)
    local w = W - 2 * pad
    local total = #c.apks
    local ly = top + section(pad, top, w, T("sec_apks"), total > 0 and T("n_found", total) or "")
    if total == 0 then
        card(pad, ly, w, S(110), false, nil, {C.faint[1], C.faint[2], C.faint[3], 0.6})
        col(C.text)
        G.setFont(fBig)
        G.print(T("no_apk"), pad + S(14), ly + S(12))
        col(C.dim)
        G.setFont(fText)
        G.print(T("copy_apk"), pad + S(14), ly + S(20) + fBig:getHeight())
        col(C.accent)
        G.print("mcpe_launcher/Setup Apk/", pad + S(14), ly + S(26) + fBig:getHeight() + fText:getHeight())
        return
    end
    local cardH = S(58)
    local visible = math.max(1, math.floor((bottom - ly + gap) / (cardH + gap)))
    local off = c.scrollOffset(c.selApk, total, visible)
    for row = 1, math.min(visible, total) do
        local i = row + off
        local a = c.apks[i]
        local y = ly + (row - 1) * (cardH + gap)
        local isSel = i == c.selApk
        local armed = c.confirmDelete == a
        if armed then
            card(pad, y, w, cardH, true, {0.32, 0.08, 0.08, 0.94}, C.red)
        elseif isSel then
            card(pad, y, w, cardH, true, nil, C.accent)
            col(C.accent)
            G.rectangle("fill", pad + S(3), y + S(10), S(3), cardH - S(20), S(2), S(2))
        else
            card(pad, y, w, cardH, false)
        end
        local right = 0
        if armed then
            G.setFont(fSmall)
            local s = T("again_delete")
            right = fSmall:getWidth(s) + S(16)
            col(C.red)
            G.print(s, math.floor(pad + w - right), math.floor(y + (cardH - fSmall:getHeight()) / 2))
        end
        col(armed and C.red or C.text)
        G.setFont(fBig)
        G.print(c.fitText(fBig, a, w - S(28) - right), pad + S(14), y + S(8))
        local cy = y + cardH - S(10) - fSmall:getHeight() - S(4)
        local cx = pad + S(14)
        local info = c.apkArch[a]
        if info then
            if info.a32 then cx = cx + chip(cx, cy, "ARM32", C.a32, true) + S(6) end
            if info.a64 then cx = cx + chip(cx, cy, "ARM64", C.a64, true) + S(6) end
            if not info.a32 and not info.a64 then cx = cx + chip(cx, cy, T("no_arm"), C.red, true) + S(6) end
        end
        local st = sizeText(c.apkSize[a])
        if st then chip(cx, cy, st, C.faint, false) end
    end
    if total > visible then
        G.setFont(fSmall)
        col(C.dim)
        local s = c.selApk .. "/" .. total
        G.print(s, math.floor(pad + w - fSmall:getWidth(s) - S(2)), bottom - fSmall:getHeight() + S(8))
    end
end

local function drawArch(c)
    local th = topBar(c, T("arch_title"))
    local bh = bottomBar(c, {{"OK", T("hint_confirm")}, {"BACK", T("hint_back")}})
    local pad, gap = S(16), S(8)
    local top = th + S(12)
    local w = W - 2 * pad
    local ly = top + section(pad, top, w, T("sec_both"))
    local opts = {
        {t = T("both"), d = T("both_d"), a = {a32 = true, a64 = true}},
        {t = T("a32_only"), d = T("a32_d"), a = {a32 = true}},
        {t = T("a64_only"), d = T("a64_d"), a = {a64 = true}},
    }
    local cardH = math.min(S(64), math.floor((H - bh - S(10) - ly - 2 * gap) / 3))
    for i, o in ipairs(opts) do
        local y = ly + (i - 1) * (cardH + gap)
        local isSel = i == c.selArch
        card(pad, y, w, cardH, isSel, nil, isSel and C.accent or nil)
        col(C.text)
        G.setFont(fBig)
        G.print(o.t, pad + S(14), y + S(8))
        col(C.dim)
        G.setFont(fSmall)
        G.print(o.d, pad + S(14), y + S(12) + fBig:getHeight())
        G.setFont(fSmall)
        local cw = 0
        if o.a.a32 then cw = cw + fSmall:getWidth("ARM32") + S(18) end
        if o.a.a64 then cw = cw + fSmall:getWidth("ARM64") + S(18) end
        archChips(pad + w - cw - S(8), y + math.floor((cardH - fSmall:getHeight() - S(4)) / 2), o.a)
    end
end

local function drawSettings(c)
    local th = topBar(c, T("settings"))
    local cur = c.settingItems[c.selSet]
    local okHint = (cur and cur.key == "skin") and T("hint_open") or T("hint_next")
    local bh = bottomBar(c, {{"dpad", T("hint_change")}, {"OK", okHint}, {"BACK", T("hint_back")}})
    local pad, gap = S(16), S(6)
    local top = th + S(12)
    local bottom = H - bh - S(10)
    local w = W - 2 * pad
    local items = c.settingItems
    local descH = fSmall:getHeight() * 2 + S(16)
    local ly = top
    local rowH = S(40)
    local avail = bottom - descH - gap - ly
    local visible = math.max(1, math.floor((avail + gap) / (rowH + gap)))
    local off = c.scrollOffset(c.selSet, #items, visible)
    for row = 1, math.min(visible, #items) do
        local i = row + off
        local it = items[i]
        local y = ly + (row - 1) * (rowH + gap)
        local isSel = i == c.selSet
        card(pad, y, w, rowH, isSel, nil, isSel and C.accent or nil)
        col(it.available and C.text or C.faint)
        textMid(fText, it.label, pad + S(14), y, rowH)
        local val = c.fitText(fText, c.itemValueName(it), math.floor(w * 0.45))
        G.setFont(fText)
        local vw = fText:getWidth(val)
        local pw = vw + S(44)
        local ph = rowH - S(14)
        local px, py = pad + w - pw - S(10), y + math.floor((rowH - ph) / 2)
        if it.available then
            col(isSel and C.accent or C.faint, isSel and 0.22 or 0.18)
            G.rectangle("fill", px, py, pw, ph, S(5), S(5))
        end
        col(it.available and (isSel and C.accent or C.text) or C.faint)
        G.print(val, math.floor(px + (pw - vw) / 2), math.floor(py + (ph - fText:getHeight()) / 2))
        if isSel and it.available then
            local tr = S(5)
            local cy = py + ph / 2
            G.polygon("fill", px + S(8), cy, px + S(8) + tr, cy - tr, px + S(8) + tr, cy + tr)
            G.polygon("fill", px + pw - S(8), cy, px + pw - S(8) - tr, cy - tr, px + pw - S(8) - tr, cy + tr)
        end
    end
    local it = items[c.selSet]
    if it then
        local dy = bottom - descH
        card(pad, dy, w, descH, false)
        col(C.accent)
        G.setFont(fSmall)
        G.print(it.label, pad + S(12), dy + S(6))
        col(C.dim)
        G.printf(it.available and it.desc or (it.udesc or T("not_avail")), pad + S(12), dy + S(8) + fSmall:getHeight(), w - S(24), "left")
    end
end

function M.draw(c)
    W, H = c.W, c.H
    G.origin()
    background(c)
    if c.screen == "main" then
        drawMain(c)
    elseif c.screen == "apk" then
        drawApk(c)
    elseif c.screen == "settings" then
        drawSettings(c)
    else
        drawArch(c)
    end
    G.setLineWidth(1)
end

return M
