local M = {}

local G = love.graphics
local Lang = require("lang")
local T = Lang.t
local utf8 = require("utf8")
local bit = require("bit")

local files = {}
local sel = 1
local top = 0
local pageRows = 5
local dir = ""
local dirLabel = ""
local okL, backL = "A", "B"
local bgImg, bgW, bgH = nil, 0, 0
local cache = {}
local fonts = {}

local function font(sz)
    sz = math.floor(sz)
    if not fonts[sz] then fonts[sz] = Lang.font("font_testo.ttf", sz) end
    return fonts[sz]
end

local function round(x) return math.floor(x + 0.5) end

local function fitText(f, text, maxw)
    if not utf8.len(text) then text = text:gsub("[\128-\255]", "?") end
    if f:getWidth(text) <= maxw then return text end
    local s = text
    while #s > 0 do
        local off = utf8.offset(s, -1)
        if not off or off <= 1 then break end
        s = s:sub(1, off - 1)
        if f:getWidth(s .. "...") <= maxw then return s .. "..." end
    end
    return "..."
end

local function makeDirLabel(d)
    d = d:gsub("/+$", "")
    local name = d:match("([^/]+)$") or d
    return name .. "/"
end

local function scan(d)
    local out = {}
    local p = io.popen("ls -p '" .. d .. "' 2>/dev/null")
    if p then
        for line in p:lines() do
            if not line:match("/$") and line:lower():match("%.png$") and line:sub(1, 1) ~= "." then
                out[#out + 1] = line
            end
        end
        p:close()
    end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

local function buildBackground(bw, bh)
    local id = love.image.newImageData(bw, bh)
    local rng = 0x2545F491
    local function rnd()
        rng = bit.bxor(rng, bit.lshift(rng, 13))
        rng = bit.bxor(rng, bit.rshift(rng, 17))
        rng = bit.bxor(rng, bit.lshift(rng, 5))
        return bit.rshift(rng, 8) / 16777216
    end
    for y = 0, bh - 1 do
        for x = 0, bw - 1 do
            if x < 4 or y < 4 or x >= bw - 4 or y >= bh - 4 then
                local r = rnd()
                local c1, c2, c3 = 20, 12, 30
                if r < 0.18 then c1, c2, c3 = 44, 26, 66
                elseif r < 0.30 then c1, c2, c3 = 60, 36, 96
                elseif r < 0.36 then c1, c2, c3 = 8, 4, 14 end
                id:setPixel(x, y, c1 / 255, c2 / 255, c3 / 255, 1)
            else
                local u = (x - 4) / 10
                local v = (y - 4) / 10
                local s = math.sin(u * 1.3 + math.sin(v * 0.9) * 2.2) + math.sin(v * 1.7 - u * 0.6)
                s = (s + 2) / 4
                local k = math.min(1, math.max(0, s * 0.8 + rnd() * 0.25))
                id:setPixel(x, y, (70 + 110 * k) / 255, (14 + 40 * k) / 255, (140 + 100 * k) / 255, 215 / 255)
            end
        end
    end
    if bgImg then bgImg:release() end
    bgImg = G.newImage(id)
    bgImg:setFilter("nearest", "nearest")
    bgW, bgH = bw, bh
end

local function loadPreview(path)
    local e = {}
    local f = io.open(path, "rb")
    if not f then return e end
    local data = f:read("*a")
    f:close()
    local ok, src = pcall(function()
        return love.image.newImageData(love.filesystem.newFileData(data, "skin.png"))
    end)
    if not ok or not src then return e end
    local w, h = src:getDimensions()
    e.label = w .. "x" .. h
    if w < 64 or w > 1024 or w % 64 ~= 0 or (h ~= w and h * 2 ~= w) then
        e.bad = true
        return e
    end
    local k = w / 64
    local modern = h == w
    if modern then
        local _, _, _, a1 = src:getPixel(54 * k, 20 * k)
        local _, _, _, a2 = src:getPixel(55 * k + k - 1, 31 * k + k - 1)
        local _, _, _, a3 = src:getPixel(45 * k, 25 * k)
        e.slim = a1 == 0 and a2 == 0 and a3 > 0
    end
    local tw, th = 16 * k, 32 * k
    local dst = love.image.newImageData(tw, th)
    local function blit(sx, sy, sw, sh, dx, dy, mirror, overlay)
        for y = 0, sh * k - 1 do
            for x = 0, sw * k - 1 do
                local rx = mirror and (sw * k - 1 - x) or x
                local r, g, b, a = src:getPixel(sx * k + rx, sy * k + y)
                local px, py = dx * k + x, dy * k + y
                if not overlay or a >= 1 then
                    dst:setPixel(px, py, r, g, b, a)
                elseif a > 0 then
                    local dr, dg, db, da = dst:getPixel(px, py)
                    dst:setPixel(px, py, dr * (1 - a) + r * a, dg * (1 - a) + g * a, db * (1 - a) + b * a, math.max(da, a))
                end
            end
        end
    end
    local function opaque(sx, sy, sw, sh)
        for y = 0, sh * k - 1 do
            for x = 0, sw * k - 1 do
                local _, _, _, a = src:getPixel(sx * k + x, sy * k + y)
                if a < 1 then return false end
            end
        end
        return true
    end
    blit(8, 8, 8, 8, 4, 0, false, false)
    if modern or not opaque(40, 8, 8, 8) then blit(40, 8, 8, 8, 4, 0, false, true) end
    blit(20, 20, 8, 12, 4, 8, false, false)
    blit(44, 20, 4, 12, 0, 8, false, false)
    blit(4, 20, 4, 12, 4, 20, false, false)
    if modern then
        blit(36, 52, 4, 12, 12, 8, false, false)
        blit(20, 52, 4, 12, 8, 20, false, false)
        blit(20, 36, 8, 12, 4, 8, false, true)
        blit(44, 36, 4, 12, 0, 8, false, true)
        blit(52, 52, 4, 12, 12, 8, false, true)
        blit(4, 36, 4, 12, 4, 20, false, true)
        blit(4, 52, 4, 12, 8, 20, false, true)
    else
        blit(44, 20, 4, 12, 12, 8, true, false)
        blit(4, 20, 4, 12, 8, 20, true, false)
    end
    e.img = G.newImage(dst)
    e.img:setFilter("nearest", "nearest")
    e.w, e.h = tw, th
    return e
end

local function entry(i)
    local name = files[i]
    if not name then return {} end
    local path = dir .. "/" .. name
    if not cache[path] then cache[path] = loadPreview(path) end
    return cache[path]
end

function M.open(d, current, ok, back)
    dir = d
    dirLabel = makeDirLabel(d)
    okL, backL = ok, back
    files = {false}
    for _, f in ipairs(scan(d)) do files[#files + 1] = f end
    sel = 1
    for i = 2, #files do
        if files[i] == current then sel = i end
    end
    top = 0
    for _, e in pairs(cache) do
        if e.img then e.img:release() end
    end
    cache = {}
end

function M.close()
    for _, e in pairs(cache) do
        if e.img then e.img:release() end
    end
    cache = {}
end

local function move(d, wrap)
    local n = #files
    if n < 1 then return end
    if wrap then
        sel = ((sel - 1 + d) % n + n) % n + 1
    else
        sel = math.max(1, math.min(n, sel + d))
    end
end

function M.key(key)
    if key == "up" then
        move(-1, true)
    elseif key == "down" then
        move(1, true)
    elseif key == "left" then
        move(-pageRows, false)
    elseif key == "right" then
        move(pageRows, false)
    elseif key == "return" then
        if not files[sel] then return "pick", "none" end
        local e = entry(sel)
        if e.img then return "pick", files[sel], e.slim end
    elseif key == "escape" then
        return "close"
    end
    return nil
end

local function shadowText(f, size, x, y, col, text)
    G.setFont(f)
    local off = math.max(1, round(size / 8))
    G.setColor(40 / 255, 10 / 255, 60 / 255, 1)
    G.print(text, math.floor(x + off), math.floor(y + off))
    G.setColor(col)
    G.print(text, math.floor(x), math.floor(y))
end

function M.draw(W, H)
    local P = math.max(2, round(math.min(W, H) / 120))
    local wfrac = W < 560 and 0.94 or 0.78
    local hfrac = H < 400 and 0.92 or 0.80
    local bw = math.max(24, math.floor(W * wfrac / P))
    local bh = math.max(24, math.floor(H * hfrac / P))
    local ww, wh = bw * P, bh * P
    local wx, wy = math.floor((W - ww) / 2), math.floor((H - wh) / 2)
    local F = 4 * P
    local ix0, iy0, ix1, iy1 = wx + F, wy + F, wx + ww - F, wy + wh - F
    local pad = 3 * P
    local titleSz = math.max(16, round(H * 0.046))
    local rowSz = math.max(13, round(H * 0.031))
    local smallSz = math.max(10, round(H * 0.024))
    local fTitle, fRow, fSmall = font(titleSz), font(rowSz), font(smallSz)

    if bw ~= bgW or bh ~= bgH or not bgImg then buildBackground(bw, bh) end

    G.setColor(0, 0, 0, 115 / 255)
    G.rectangle("fill", 0, 0, W, H)
    G.setColor(1, 1, 1, 1)
    G.draw(bgImg, wx, wy, 0, P, P)

    local titleY = iy0 + 2 * P
    shadowText(fTitle, titleSz, ix0 + pad, titleY, {1, 1, 1, 1}, T("pick_title"))
    local subY = titleY + fTitle:getHeight() + P * 0.5
    G.setFont(fSmall)
    G.setColor(225 / 255, 200 / 255, 1, 1)
    G.print(fitText(fSmall, dirLabel, ix1 - ix0 - 2 * pad), math.floor(ix0 + pad + 1), math.floor(subY))
    local sepY = subY + fSmall:getHeight() + P
    G.setColor(20 / 255, 12 / 255, 30 / 255, 200 / 255)
    G.rectangle("fill", ix0 + pad, sepY, (ix1 - pad) - (ix0 + pad), math.max(1, math.floor(P / 2)))

    local footY = iy1 - fRow:getHeight() - 3 * P
    local listTop = sepY + 2 * P + 2
    local listBottom = footY - 2 * P
    local rowH = round(rowSz * 2)
    local gap = P
    local rows = math.max(1, math.floor((listBottom - listTop + gap) / (rowH + gap)))
    local n = #files
    pageRows = rows

    local s = sel - 1
    if s < top then top = s end
    if s >= top + rows then top = s - rows + 1 end
    top = math.max(0, math.min(top, math.max(0, n - rows)))

    local innerW = ix1 - ix0
    local showPreview = innerW >= 300
    local lx0 = ix0 + pad
    local lx1 = showPreview and (lx0 + round((innerW - 3 * pad) * 0.64)) or (ix1 - pad)
    local outline = math.max(1, math.floor(P / 2))

    for r = 0, rows - 1 do
        local idx = top + r + 1
        if idx > n then break end
        local y0 = listTop + r * (rowH + gap)
        local name = files[idx] and files[idx]:gsub("%.[pP][nN][gG]$", "") or T("v_none")
        local label = fitText(fRow, name, lx1 - lx0 - 2 * pad)
        local ty = y0 + (rowH - fRow:getHeight()) / 2
        if idx == sel then
            G.setColor(200 / 255, 120 / 255, 1, 150 / 255)
            G.rectangle("fill", lx0, y0, lx1 - lx0, rowH)
            G.setColor(240 / 255, 210 / 255, 1, 1)
            G.setLineWidth(outline)
            G.rectangle("line", lx0 + outline / 2, y0 + outline / 2, lx1 - lx0 - outline, rowH - outline)
            G.setLineWidth(1)
            shadowText(fRow, rowSz, lx0 + pad * 0.8, ty, {1, 1, 85 / 255, 1}, label)
        else
            G.setColor(10 / 255, 4 / 255, 20 / 255, 110 / 255)
            G.rectangle("fill", lx0, y0, lx1 - lx0, rowH)
            shadowText(fRow, rowSz, lx0 + pad * 0.8, ty, {235 / 255, 235 / 255, 235 / 255, 1}, label)
        end
    end

    local cur = entry(sel)
    if showPreview then
        local px0, px1 = lx1 + pad, ix1 - pad
        local py0, py1 = listTop, listTop + rows * (rowH + gap) - gap
        G.setColor(10 / 255, 4 / 255, 20 / 255, 120 / 255)
        G.rectangle("fill", px0, py0, px1 - px0, py1 - py0)
        local labelH = fSmall:getHeight() + 2 * P
        if cur.img then
            local availW = px1 - px0 - 2 * P
            local availH = py1 - py0 - labelH - 2 * P
            local scale = math.floor(math.min(availW / cur.w, availH / cur.h))
            if scale < 1 then scale = math.min(availW / cur.w, availH / cur.h) end
            local dw, dh = cur.w * scale, cur.h * scale
            local bx = math.floor(px0 + (px1 - px0 - dw) / 2)
            local by = math.floor(py0 + P + (availH - dh) / 2 + P)
            G.setColor(1, 1, 1, 1)
            G.draw(cur.img, bx, by, 0, scale, scale)
        end
        local info
        if not files[sel] then
            info = T("v_none")
        elseif cur.img then
            info = cur.label
        elseif cur.label then
            info = cur.label .. " (" .. T("unsupported") .. ")"
        else
            info = T("unreadable")
        end
        G.setFont(fSmall)
        if files[sel] and not cur.img then G.setColor(1, 0.45, 0.45, 1) else G.setColor(225 / 255, 200 / 255, 1, 1) end
        G.print(fitText(fSmall, info, px1 - px0 - 4 * P), math.floor(px0 + 2 * P), math.floor(py1 - fSmall:getHeight() - P))
    end

    local foot = okL .. " " .. T("hint_select") .. "    " .. backL .. " " .. T("hint_cancel")
    shadowText(fRow, rowSz, ix0 + pad, footY, {1, 1, 1, 1}, foot)
    local count = sel .. "/" .. n
    G.setFont(fRow)
    G.setColor(225 / 255, 200 / 255, 1, 1)
    G.print(count, math.floor(ix1 - pad - fRow:getWidth(count)), math.floor(footY))
end

return M
