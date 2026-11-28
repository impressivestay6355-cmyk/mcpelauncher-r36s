local ACCENT  = {0.20, 0.80, 0.40}
local FG      = {1.00, 1.00, 1.00}
local DIM     = {0.50, 0.50, 0.50}
local BLOCK_H = 52
local PIN_H   = 44
local PADDING = 20
local LIST_TOP = 90
local PIN_GAP = 10
local PINNED_BLOCK_H
local FOOTER_TEXT_H = 24
local MAIN_RESERVE
local APK_RESERVE  = 58
local ACTIONS = 4

local fontTitolo
local fontTesto
local fontHint
local bgImage
local W, H
local Modern
local Lang = require("lang")
local utf8 = require("utf8")
local SkinPick = require("skinpick")
local T = Lang.t

local BASEDIR = os.getenv("MCPE_GAMEDIR")
local VERDIR  = BASEDIR.."/versions"
local APKDIR  = BASEDIR.."/Setup Apk"
local MENUDIR = BASEDIR.."/menu"
local SETFILE = BASEDIR.."/settings.conf"
local SKINDIR = BASEDIR.."/Import Skins"
local BASE_CONFIRM_B = (os.getenv("MCPE_CONFIRM_SDL") or "a"):lower() == "b"
local BASE_OK_L = (os.getenv("MCPE_CONFIRM_LABEL") or "A"):upper() == "B" and "B" or "A"
local CONFIRM_B = BASE_CONFIRM_B
local OK_L = BASE_OK_L
local BACK_L = OK_L == "A" and "B" or "A"
local DEVICE_ARCH = (os.getenv("DEVICE_ARCH") or ""):lower()
local PORT_VERSION = ""
do
    local vf = io.open(BASEDIR.."/version.txt", "r")
    if vf then PORT_VERSION = (vf:read("*l") or ""):gsub("%s", ""); vf:close() end
end

local screen  = "main"
local selMain = 1
local selApk  = 1
local selArch = 1
local selSet  = 1
local focusCol = "list"
local lastVer = 1
local lastAct = 1
local versions = {}
local verArch = {}
local apks = {}
local apkArch = {}
local apkSize = {}
local archOptions = {}
local pendingApk = nil
local confirmDelete = nil
local confirmDeleteVer = nil
local settings = {}
local settingsOrder = {}
local settingItems = {}

local function readFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end

local function words(s)
    local out = {}
    for w in (s or ""):gmatch("%S+") do out[#out+1] = w end
    return out
end

local function loadSettings()
    settings = {}
    settingsOrder = {}
    local s = readFile(SETFILE)
    if not s then return end
    for line in s:gmatch("[^\r\n]+") do
        local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
        if k then
            if settings[k] == nil then settingsOrder[#settingsOrder+1] = k end
            settings[k] = v
        end
    end
end

local function saveSettings()
    local f = io.open(SETFILE, "w")
    if not f then return end
    for _, k in ipairs(settingsOrder) do
        if settings[k] ~= nil then f:write(k.."="..settings[k].."\n") end
    end
    f:close()
end

local function getSetting(k, def)
    local v = settings[k]
    if v == nil or v == "" then return def end
    return v
end

local function setSetting(k, v)
    if settings[k] == nil then settingsOrder[#settingsOrder+1] = k end
    settings[k] = v
    saveSettings()
end

local function applyMenuButtons()
    if getSetting("menu_ab", "auto") == "swapped" then
        CONFIRM_B = not BASE_CONFIRM_B
        OK_L = BASE_OK_L == "A" and "B" or "A"
    else
        CONFIRM_B = BASE_CONFIRM_B
        OK_L = BASE_OK_L
    end
    BACK_L = OK_L == "A" and "B" or "A"
end

local function findDevfreq(patterns)
    local p = io.popen("ls /sys/class/devfreq 2>/dev/null")
    if not p then return nil end
    local found = nil
    for name in p:lines() do
        local low = name:lower()
        for _, pat in ipairs(patterns) do
            if not found and low:find(pat, 1, true) then found = name end
        end
    end
    p:close()
    if not found then return nil end
    for _, g in ipairs(words(readFile("/sys/class/devfreq/"..found.."/available_governors"))) do
        if g == "performance" then return found end
    end
    return nil
end

local function buildSettingItems()
    local govs = {"default"}
    local govNames = {T("v_default")}
    for _, g in ipairs(words(readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"))) do
        if g ~= "userspace" then
            govs[#govs+1] = g
            govNames[#govNames+1] = g:sub(1,1):upper()..g:sub(2)
        end
    end
    local gpu = findDevfreq({"gpu", "mali"})
    local dmc = findDevfreq({"dmc"})
    local offOn = {T("v_off"), T("v_on")}
    local gpuVals, gpuNames = {"0", "1"}, {T("v_off"), T("v_max")}
    if gpu then
        local seen, mhzs = {}, {}
        for _, f in ipairs(words(readFile("/sys/class/devfreq/"..gpu.."/available_frequencies"))) do
            local n = tonumber(f)
            if n and n > 0 and f:match("^%d+$") then
                local m = n >= 1000000 and math.floor((n + 500000) / 1000000) or math.floor((n + 500) / 1000)
                if m > 1 and not seen[m] then seen[m] = true; mhzs[#mhzs+1] = m end
            end
        end
        table.sort(mhzs)
        for _, m in ipairs(mhzs) do
            gpuVals[#gpuVals+1] = tostring(m)
            gpuNames[#gpuNames+1] = m.." MHz"
        end
    end
    local memMB = 0
    local kb = (readFile("/proc/meminfo") or ""):match("MemTotal:%s*(%d+)")
    if kb then memMB = math.floor(tonumber(kb) / 1024) end
    local zramVals, zramNames = {"0", "1"}, {T("v_off"), T("v_auto")}
    for _, sz in ipairs({128, 256, 384, 512, 768, 1024, 1536, 2048}) do
        if memMB == 0 or sz <= memMB * 1.5 then
            zramVals[#zramVals+1] = tostring(sz)
            zramNames[#zramNames+1] = sz.." MB"
        end
    end
    local skins = {"none"}
    local skinNames = {T("v_none")}
    local sp = io.popen("ls -p '"..SKINDIR.."' 2>/dev/null")
    if sp then
        local found = {}
        for line in sp:lines() do
            if not line:match("/$") and line:lower():match("%.png$") then found[#found+1] = line end
        end
        sp:close()
        table.sort(found, function(a, b) return a:lower() < b:lower() end)
        for _, f in ipairs(found) do
            skins[#skins+1] = f
            skinNames[#skinNames+1] = f:gsub("%.[pP][nN][gG]$", "")
        end
    end
    settingItems = {
        {key="theme", label=T("lbl_theme"), values={"classic","modern"}, names={T("v_classic"),T("v_modern")}, def="classic",
         desc=T("d_theme")},
        {key="language", label=T("lbl_language"), values=Lang.codes, names=Lang.names, def="en",
         desc=T("d_language")},
        {key="menu_ab", label=T("lbl_menu_ab"), values={"auto","swapped"}, names={T("v_auto"),T("v_swapped")}, def="auto",
         desc=T("d_menu_ab")},
        {key="game_ab", label=T("lbl_game_ab"), values={"normal","swapped"}, names={T("v_normal"),T("v_swapped")}, def="normal",
         desc=T("d_game_ab")},
        {key="skin", label=T("lbl_skin"), values=skins, names=skinNames, def="none",
         available=#skins > 1, desc=T("d_skin"), udesc=T("u_skin")},
        {key="cpu_governor", label=T("lbl_cpu"), values=govs, names=govNames, def="default",
         available=#govs > 1, desc=T("d_cpu")},
        {key="gpu_boost", label=T("lbl_gpu"), values=gpuVals, names=gpuNames, def="0",
         available=gpu ~= nil, desc=T("d_gpu")},
        {key="ram_boost", label=T("lbl_ram"), values={"0","1"}, names=offOn, def="0",
         available=dmc ~= nil, desc=T("d_ram")},
        {key="zram", label=T("lbl_zram"), values=zramVals, names=zramNames, def="0",
         desc=T("d_zram")},
    }
    for _, it in ipairs(settingItems) do
        if it.available == nil then it.available = true end
    end
end

local function itemIndex(it)
    local v = getSetting(it.key, it.def)
    for i, x in ipairs(it.values) do
        if x == v then return i end
    end
    return 1
end

local function itemValueName(it)
    if not it.available then return T("na") end
    return it.names[itemIndex(it)]
end

local function changeSetting(dir)
    local it = settingItems[selSet]
    if not it or not it.available then return end
    local i = itemIndex(it) + dir
    if i < 1 then i = #it.values end
    if i > #it.values then i = 1 end
    setSetting(it.key, it.values[i])
    if it.key == "menu_ab" then applyMenuButtons() end
    if it.key == "language" then
        Lang.set(it.values[i])
        buildSettingItems()
    end
end

local function isModern()
    return getSetting("theme", "classic") == "modern"
end

local function scanVersions()
    local out = {}
    local p = io.popen("ls -d '"..VERDIR.."'/*/ 2>/dev/null")
    if p then
        for line in p:lines() do
            local name = line:match(".+/(.-)/$")
            if name then out[#out+1] = name end
        end
        p:close()
    end
    table.sort(out)
    return out
end

local function scanVersionArchs()
    local out = {}
    local cmd = "for d in '"..VERDIR.."'/*/lib/armeabi-v7a '"..VERDIR.."'/*/lib/arm64-v8a; do [ -n \"$(ls -A \"$d\" 2>/dev/null)\" ] && echo \"$d\"; done"
    local p = io.popen(cmd)
    if p then
        for line in p:lines() do
            local name, abi = line:match(".+/(.-)/lib/(.-)$")
            if name then
                out[name] = out[name] or {}
                if abi == "armeabi-v7a" then out[name].a32 = true end
                if abi == "arm64-v8a" then out[name].a64 = true end
            end
        end
        p:close()
    end
    return out
end

local function scanApks()
    local out = {}
    local p = io.popen("ls -p '"..APKDIR.."' 2>/dev/null")
    if p then
        for line in p:lines() do
            if not line:match("/$") and line:lower():match("%.apk$") then
                out[#out+1] = line
            end
        end
        p:close()
    end
    table.sort(out)
    return out
end

local function checkApkArchs(path)
    local hasArmhf, hasArm64 = false, false
    local p = io.popen("unzip -l '"..path.."' 2>/dev/null")
    if p then
        for line in p:lines() do
            if line:find("lib/armeabi-v7a", 1, true) then hasArmhf = true end
            if line:find("lib/arm64-v8a", 1, true) then hasArm64 = true end
        end
        p:close()
    end
    return hasArmhf, hasArm64
end

local function fileSize(path)
    local f = io.open(path, "rb")
    if not f then return 0 end
    local n = f:seek("end") or 0
    f:close()
    return n
end

local function archTag(a)
    if not a then return "" end
    if a.a32 and a.a64 then return "ARM32/64" end
    if a.a64 then return "ARM64" end
    if a.a32 then return "ARM32" end
    return ""
end

local function refresh()
    versions = scanVersions()
    verArch = scanVersionArchs()
    apks = scanApks()
end

local APK_CACHE = MENUDIR.."/apk_info.cache"
local apkCache = nil
local apkRunning = 0
local apkThreadCode = [[
local inq = love.thread.getChannel("mcpe_apk_in")
local outq = love.thread.getChannel("mcpe_apk_out")
while true do
    local job = inq:pop()
    if not job then break end
    local h32, h64 = false, false
    local p = io.popen("unzip -l '"..job.path:gsub("'", "'\\''").."' 2>/dev/null")
    if p then
        for line in p:lines() do
            if not h32 and line:find("lib/armeabi-v7a", 1, true) then h32 = true end
            if not h64 and line:find("lib/arm64-v8a", 1, true) then h64 = true end
        end
        p:close()
    end
    outq:push({name = job.name, size = job.size, a32 = h32, a64 = h64})
end
outq:push({done = true})
]]

local function loadApkCache()
    apkCache = {}
    local s = readFile(APK_CACHE)
    if not s then return end
    for line in s:gmatch("[^\n]+") do
        local size, a32, a64, name = line:match("^(%d+)\t([01])\t([01])\t(.+)$")
        if name then apkCache[name] = {size = tonumber(size), a32 = a32 == "1", a64 = a64 == "1"} end
    end
end

local function saveApkCache()
    local f = io.open(APK_CACHE, "w")
    if not f then return end
    for _, a in ipairs(apks) do
        local c = apkCache[a]
        if c and c.size == apkSize[a] then
            f:write(c.size.."\t"..(c.a32 and 1 or 0).."\t"..(c.a64 and 1 or 0).."\t"..a.."\n")
        end
    end
    f:close()
end

local function refreshApkInfo()
    apkArch = {}
    apkSize = {}
    if not apkCache then loadApkCache() end
    local inq = love.thread.getChannel("mcpe_apk_in")
    inq:clear()
    local jobs = 0
    for _, a in ipairs(apks) do
        local size = fileSize(APKDIR.."/"..a)
        apkSize[a] = size
        local c = apkCache[a]
        if c and c.size == size then
            apkArch[a] = {a32 = c.a32, a64 = c.a64}
        else
            inq:push({name = a, path = APKDIR.."/"..a, size = size})
            jobs = jobs + 1
        end
    end
    if jobs > 0 then
        local ok, th = pcall(love.thread.newThread, apkThreadCode)
        if ok and th and pcall(th.start, th) then
            apkRunning = apkRunning + 1
        else
            inq:clear()
            for _, a in ipairs(apks) do
                if not apkArch[a] then
                    local h32, h64 = checkApkArchs(APKDIR.."/"..a)
                    apkArch[a] = {a32 = h32, a64 = h64}
                    apkCache[a] = {size = apkSize[a], a32 = h32, a64 = h64}
                end
            end
            saveApkCache()
        end
    end
end

local function pollApkInfo()
    if apkRunning <= 0 then return end
    local outq = love.thread.getChannel("mcpe_apk_out")
    local changed = false
    while true do
        local r = outq:pop()
        if not r then break end
        if r.done then
            apkRunning = apkRunning - 1
            changed = true
        else
            apkCache[r.name] = {size = r.size, a32 = r.a32, a64 = r.a64}
            if apkSize[r.name] == r.size then apkArch[r.name] = {a32 = r.a32, a64 = r.a64} end
        end
    end
    if changed and apkRunning <= 0 then
        apkRunning = 0
        saveApkCache()
    end
end

local function writeSelected(ver)
    local f = io.open(MENUDIR.."/selected_version.txt", "w")
    if f then f:write(ver); f:close() end
    love.event.quit(0)
end

local function writeApkSelected(name)
    local f = io.open(MENUDIR.."/setup_apk_selected.txt", "w")
    if f then f:write(name); f:close() end
    love.event.quit(0)
end

local function writeApkArch(value)
    local f = io.open(MENUDIR.."/setup_apk_arch.txt", "w")
    if f then f:write(value); f:close() end
end

local function maxVisible(reserve)
    local n = math.floor((H - LIST_TOP - reserve) / BLOCK_H)
    if n < 1 then n = 1 end
    return n
end

local function scrollOffset(sel, total, visible)
    if total <= visible then return 0 end
    local off = sel - 1 - math.floor(visible/2)
    if off < 0 then off = 0 end
    if off > total - visible then off = total - visible end
    return off
end

local function fitText(font, text, maxw)
    if not utf8.len(text) then text = text:gsub("[\128-\255]", "?") end
    if font:getWidth(text) <= maxw then return text end
    local s = text
    while #s > 0 do
        local off = utf8.offset(s, -1)
        if not off or off <= 1 then break end
        s = s:sub(1, off - 1)
        if font:getWidth(s.."...") <= maxw then return s.."..." end
    end
    return "..."
end

local function drawRow(x, y, w, label, selected, color, selColor, h, tag)
    h = h or BLOCK_H
    if selected then
        love.graphics.setColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.15)
        love.graphics.rectangle("fill", x, y+4, w, h-8, 6, 6)
        love.graphics.setColor(ACCENT)
        love.graphics.rectangle("fill", x, y+4, 4, h-8, 2, 2)
    end
    local font = love.graphics.getFont()
    local maxw = w - 24
    local tw = 0
    if tag and tag ~= "" then
        tw = fontHint:getWidth(tag) + 12
        maxw = maxw - tw
    end
    love.graphics.setColor(selected and selColor or color)
    love.graphics.print(fitText(font, label, maxw), x+16, math.floor(y+(h-font:getHeight())/2))
    if tw > 0 then
        love.graphics.setFont(fontHint)
        love.graphics.setColor(DIM[1], DIM[2], DIM[3], selected and 0.95 or 0.7)
        love.graphics.print(tag, x+w-tw, math.floor(y+(h-fontHint:getHeight())/2))
        love.graphics.setFont(font)
    end
end

local function drawMain()
    local total = #versions
    local visible = maxVisible(MAIN_RESERVE)
    local clampedSel = math.min(math.max(selMain, 1), math.max(total, 1))
    local off = scrollOffset(clampedSel, total, visible)

    love.graphics.setFont(fontTesto)
    for row = 1, math.min(visible, total) do
        local i = row + off
        local v = versions[i]
        if v then
            local y = LIST_TOP + (row-1)*BLOCK_H
            if confirmDeleteVer == v then
                drawRow(PADDING, y, 320, v, i == selMain, {0.75,0.25,0.2}, {1.0,0.35,0.3}, nil, archTag(verArch[v]))
            else
                drawRow(PADDING, y, 320, v, i == selMain, DIM, FG, nil, archTag(verArch[v]))
            end
        end
    end

    local pinnedRows = math.min(total, visible)
    local pinnedY = LIST_TOP + pinnedRows*BLOCK_H
    love.graphics.setColor(DIM)
    love.graphics.rectangle("fill", PADDING, pinnedY+PIN_GAP, 320, 1)

    local setupY  = pinnedY + PIN_GAP + 1 + PIN_GAP
    local setY    = setupY + PIN_H
    local updateY = setY + PIN_H
    local exitY   = updateY + PIN_H

    drawRow(PADDING, setupY,  320, T("c_setup"),   selMain == total+1, {0.75,0.6,0.2}, {1.0,0.8,0.25}, PIN_H)
    drawRow(PADDING, setY,    320, T("c_settings"),    selMain == total+2, {0.5,0.56,0.67}, {0.76,0.83,0.96}, PIN_H)
    drawRow(PADDING, updateY, 320, T("c_update"), selMain == total+3, {0.25,0.6,0.8}, {0.4,0.82,1.0}, PIN_H)
    drawRow(PADDING, exitY,   320, T("c_exit"),            selMain == total+4, {0.6,0.2,0.2},  {0.9,0.3,0.3}, PIN_H)

    love.graphics.setFont(fontHint)
    if confirmDeleteVer then
        love.graphics.setColor(1.0,0.35,0.3)
        love.graphics.printf(T("c_delete_q").." X="..T("yes").."   "..BACK_L.."="..T("no"), PADDING+16, H-FOOTER_TEXT_H+4, 320, "left")
    elseif selMain == total+3 then
        love.graphics.setColor(DIM)
        local label = PORT_VERSION ~= "" and T("c_installed", PORT_VERSION) or ""
        love.graphics.printf(label, PADDING+16, H-FOOTER_TEXT_H+4, 320, "left")
    elseif selMain <= total then
        love.graphics.setColor(DIM)
        local label = "X="..T("hint_delete")
        if total > visible then label = clampedSel.."/"..total.."   "..label end
        love.graphics.printf(label, PADDING+16, H-FOOTER_TEXT_H+4, 320, "left")
    elseif total > visible then
        love.graphics.setColor(DIM)
        love.graphics.printf(clampedSel.."/"..total, PADDING+16, H-FOOTER_TEXT_H+4, 320, "left")
    end
end

local function drawApk()
    love.graphics.setFont(fontTesto)
    if #apks == 0 then
        love.graphics.setColor(DIM)
        love.graphics.printf(T("no_apk")..".", PADDING+16, LIST_TOP+10, 320, "left")
        love.graphics.printf(T("copy_apk"), PADDING+16, LIST_TOP+42, 320, "left")
        love.graphics.printf("mcpe_launcher/Setup Apk/", PADDING+16, LIST_TOP+68, 320, "left")
        love.graphics.printf("("..BACK_L.."="..T("hint_back")..")", PADDING+16, LIST_TOP+104, 320, "left")
        return
    end

    local total = #apks
    local visible = maxVisible(APK_RESERVE)
    local off = scrollOffset(selApk, total, visible)

    for row = 1, math.min(visible, total) do
        local i = row + off
        local a = apks[i]
        if a then
            local y = LIST_TOP + (row-1)*BLOCK_H
            if confirmDelete == a then
                drawRow(PADDING, y, 320, a, i == selApk, {0.75,0.25,0.2}, {1.0,0.35,0.3}, nil, archTag(apkArch[a]))
            else
                drawRow(PADDING, y, 320, a, i == selApk, DIM, FG, nil, archTag(apkArch[a]))
            end
        end
    end

    love.graphics.setFont(fontHint)
    if confirmDelete then
        love.graphics.setColor(1.0,0.35,0.3)
        love.graphics.printf(T("c_delete_q").." X="..T("yes").."   "..BACK_L.."="..T("no"), PADDING+16, H-APK_RESERVE+6, 320, "left")
    else
        love.graphics.setColor(DIM)
        love.graphics.printf(OK_L.."="..T("c_setup_short").."   X="..T("hint_delete").."   "..BACK_L.."="..T("hint_back"), PADDING+16, H-APK_RESERVE+6, 320, "left")
    end
    if total > visible then
        love.graphics.setColor(DIM)
        love.graphics.printf(selApk.."/"..total, PADDING+16, H-APK_RESERVE+6+22, 320, "left")
    end
end

local function drawArch()
    love.graphics.setFont(fontTesto)
    for i, label in ipairs(archOptions) do
        local y = LIST_TOP + (i-1)*BLOCK_H
        drawRow(PADDING, y, 320, label, i == selArch, DIM, FG)
    end
    love.graphics.setFont(fontHint)
    love.graphics.setColor(DIM)
    love.graphics.printf(OK_L.."="..T("hint_confirm").."   "..BACK_L.."="..T("hint_back"), PADDING+16, H-APK_RESERVE+6, 320, "left")
end

local function drawSettings()
    local rowH = math.min(BLOCK_H, math.max(30, math.floor((H - LIST_TOP - APK_RESERVE) / #settingItems)))
    local visible = math.max(1, math.floor((H - LIST_TOP - APK_RESERVE) / rowH))
    local off = scrollOffset(selSet, #settingItems, visible)
    love.graphics.setFont(fontTesto)
    for row = 1, math.min(visible, #settingItems) do
        local i = row + off
        local it = settingItems[i]
        local y = LIST_TOP + (row-1)*rowH
        local sel = i == selSet
        local col = it.available and DIM or {0.35,0.35,0.35}
        drawRow(PADDING, y, 320, it.label, sel, col, FG, rowH)
        local val = fitText(fontTesto, itemValueName(it), 150)
        if sel and it.available then val = "< "..val.." >" end
        love.graphics.setColor(sel and ACCENT or col)
        love.graphics.printf(val, PADDING, math.floor(y+(rowH-fontTesto:getHeight())/2), 320-12, "right")
    end
    love.graphics.setFont(fontHint)
    love.graphics.setColor(DIM)
    local it = settingItems[selSet]
    if it then
        love.graphics.printf(it.available and it.desc or (it.udesc or T("not_avail")), PADDING+16, H-APK_RESERVE+6, 320, "left")
    end
    love.graphics.printf(T("c_leftright").."="..T("hint_change").."   "..BACK_L.."="..T("hint_back"), PADDING+16, H-APK_RESERVE+6+22, 320, "left")
end

local function ctx()
    return {
        W = W, H = H, screen = screen, versions = versions, verArch = verArch,
        apks = apks, apkArch = apkArch, apkSize = apkSize, archOptions = archOptions,
        selMain = selMain, selApk = selApk, selArch = selArch, selSet = selSet,
        focusCol = focusCol, confirmDelete = confirmDelete, confirmDeleteVer = confirmDeleteVer,
        settingItems = settingItems, itemValueName = itemValueName, archTag = archTag,
        okL = OK_L, backL = BACK_L, portVersion = PORT_VERSION, deviceArch = DEVICE_ARCH,
        bg = bgImage, actions = ACTIONS, scrollOffset = scrollOffset, fitText = fitText,
    }
end

function love.load()
    bgImage = love.graphics.newImage("bg.jpg")
    W = love.graphics.getWidth()
    H = love.graphics.getHeight()

    BLOCK_H = math.max(30, math.min(52, math.floor((H - LIST_TOP - FOOTER_TEXT_H - 2*PIN_GAP - 1) / 5)))
    PIN_H = math.min(44, BLOCK_H)
    PINNED_BLOCK_H = PIN_GAP + 1 + PIN_GAP + PIN_H*ACTIONS
    MAIN_RESERVE = PINNED_BLOCK_H + FOOTER_TEXT_H

    fontTitolo = Lang.font("font_titolo.ttf", 24)
    fontTesto  = Lang.font("font_testo.ttf", 16)
    fontHint   = Lang.font("font_testo.ttf", 13)

    loadSettings()
    Lang.set(getSetting("language", "en"))
    applyMenuButtons()
    buildSettingItems()
    os.execute("mkdir -p '"..APKDIR.."'")
    refresh()
    local ok, mod = pcall(require, "modern")
    if ok and type(mod) == "table" and pcall(mod.load, W, H) then Modern = mod end
    if isModern() and #versions == 0 then focusCol = "actions"; selMain = 1 end
end

local function drawClassic()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(bgImage, 0, 0, 0, W/bgImage:getWidth(), H/bgImage:getHeight())
    love.graphics.setColor(0.15,0.12,0.15,0.55)
    love.graphics.rectangle("fill", 0, 0, 360, H)

    love.graphics.setColor(ACCENT)
    love.graphics.setFont(fontTitolo)
    local title = "MCPE Launcher"
    if screen == "apk" then
        title = T("setup_apk")
    elseif screen == "archchoice" then
        title = T("arch_sel_title")
    elseif screen == "settings" then
        title = T("settings")
    end
    love.graphics.printf(title, 36, 30, 320, "left")

    love.graphics.setColor(DIM)
    love.graphics.rectangle("fill", PADDING*3, 62, 280, 1)

    if screen == "main" then
        drawMain()
    elseif screen == "apk" then
        drawApk()
    elseif screen == "settings" then
        drawSettings()
    else
        drawArch()
    end
end

local function drawTheme()
    if Modern and isModern() then
        local ok = pcall(Modern.draw, ctx())
        if ok then return end
        love.graphics.origin()
        love.graphics.setScissor()
        love.graphics.clear(0, 0, 0, 1)
    end
    drawClassic()
end

function love.draw()
    if screen == "skinpick" then
        screen = "settings"
        drawTheme()
        screen = "skinpick"
        love.graphics.origin()
        love.graphics.setScissor()
        love.graphics.setLineWidth(1)
        local ok = pcall(SkinPick.draw, W, H)
        if not ok then
            SkinPick.close()
            screen = "settings"
        end
        return
    end
    drawTheme()
end

function love.update()
    pollApkInfo()
end

function love.threaderror(t, err)
    apkRunning = math.max(0, apkRunning - 1)
end

function love.quit()
    love.thread.getChannel("mcpe_apk_in"):clear()
    return false
end

local function enterApk()
    refresh()
    refreshApkInfo()
    screen = "apk"
    selApk = 1
    confirmDelete = nil
end

local function syncFocus()
    local total = #versions
    if not isModern() then return end
    if selMain <= total and total > 0 then
        focusCol = "list"
        lastVer = math.max(selMain, 1)
    else
        focusCol = "actions"
        lastAct = math.min(math.max(selMain - total, 1), ACTIONS)
        selMain = total + lastAct
    end
end

local function isStacked()
    return Modern ~= nil and Modern.stacked ~= nil and Modern.stacked(W, H)
end

local function moveStacked(dir)
    local total = #versions
    if focusCol == "list" and total > 0 then
        local i = math.min(math.max(selMain, 1), total) + dir
        if i < 1 then i = 1 end
        if i > total then
            focusCol = "actions"
            selMain = total + 1
            lastAct = 1
            return
        end
        selMain = i
        lastVer = i
    else
        local a = selMain - total
        if a < 1 or a > ACTIONS then a = lastAct end
        if dir > 0 and a <= 2 then
            a = a + 2
        elseif dir < 0 and a >= 3 then
            a = a - 2
        elseif dir < 0 and total > 0 then
            focusCol = "list"
            selMain = math.min(math.max(lastVer, 1), total)
            return
        end
        focusCol = "actions"
        selMain = total + a
        lastAct = a
    end
end

local function moveModernMain(dir)
    local total = #versions
    if isStacked() then
        moveStacked(dir)
        return
    end
    if focusCol == "list" and total > 0 then
        local i = math.min(math.max(selMain, 1), total) + dir
        if i < 1 then i = total end
        if i > total then i = 1 end
        selMain = i
        lastVer = i
    else
        local a = selMain - total
        if a < 1 or a > ACTIONS then a = lastAct end
        a = a + dir
        if a < 1 then a = ACTIONS end
        if a > ACTIONS then a = 1 end
        selMain = total + a
        lastAct = a
        focusCol = "actions"
    end
end

local function switchColumn(dir)
    if screen ~= "main" or not isModern() then return end
    local total = #versions
    confirmDeleteVer = nil
    if isStacked() then
        if focusCol ~= "list" or total == 0 then
            local a = selMain - total
            if a < 1 or a > ACTIONS then a = lastAct end
            if dir > 0 and a % 2 == 1 then a = a + 1 elseif dir < 0 and a % 2 == 0 then a = a - 1 end
            focusCol = "actions"
            selMain = total + a
            lastAct = a
        end
        return
    end
    if focusCol == "list" then
        focusCol = "actions"
        selMain = total + lastAct
    elseif total > 0 then
        focusCol = "list"
        selMain = math.min(math.max(lastVer, 1), total)
    end
end

local function moveSel(dir)
    if screen == "main" then
        confirmDeleteVer = nil
        if isModern() then
            moveModernMain(dir)
            return
        end
        local n = #versions + ACTIONS
        selMain = selMain + dir
        if selMain < 1 then selMain = n end
        if selMain > n then selMain = 1 end
    elseif screen == "archchoice" then
        local n = #archOptions
        if n < 1 then return end
        selArch = selArch + dir
        if selArch < 1 then selArch = n end
        if selArch > n then selArch = 1 end
    elseif screen == "settings" then
        local n = #settingItems
        selSet = selSet + dir
        if selSet < 1 then selSet = n end
        if selSet > n then selSet = 1 end
    else
        confirmDelete = nil
        local n = #apks
        if n < 1 then return end
        selApk = selApk + dir
        if selApk < 1 then selApk = n end
        if selApk > n then selApk = 1 end
    end
end

local function activate()
    if screen == "main" then
        local total = #versions
        if selMain <= total then
            confirmDeleteVer = nil
            writeSelected(versions[selMain])
        elseif selMain == total+1 then
            enterApk()
        elseif selMain == total+2 then
            buildSettingItems()
            screen = "settings"
            selSet = 1
        elseif selMain == total+3 then
            local f = io.open(MENUDIR.."/update_request.txt", "w")
            if f then f:write("1"); f:close() end
            love.event.quit(0)
        else
            writeSelected("")
        end
    elseif screen == "apk" then
        local a = apks[selApk]
        if a then
            confirmDelete = nil
            local info = apkArch[a]
            local hasArmhf, hasArm64
            if info then
                hasArmhf, hasArm64 = info.a32, info.a64
            else
                hasArmhf, hasArm64 = checkApkArchs(APKDIR.."/"..a)
                apkArch[a] = {a32 = hasArmhf, a64 = hasArm64}
            end
            if hasArmhf and hasArm64 then
                pendingApk = a
                archOptions = {T("both"), "ARM32", "ARM64"}
                selArch = 1
                screen = "archchoice"
            else
                writeApkSelected(a)
            end
        end
    elseif screen == "settings" then
        local it = settingItems[selSet]
        if it and it.key == "skin" then
            if it.available then
                SkinPick.open(SKINDIR, getSetting("skin", "none"), OK_L, BACK_L)
                screen = "skinpick"
            end
            return
        end
        changeSetting(1)
        if it and it.key == "theme" then syncFocus() end
    else
        local archValues = {"both", "armhf", "arm64"}
        writeApkArch(archValues[selArch] or "both")
        writeApkSelected(pendingApk)
    end
end

local function deleteArmed()
    if screen ~= "apk" then return end
    local cur = apks[selApk]
    if not cur then confirmDelete = nil; return end
    if confirmDelete == cur then
        os.remove(APKDIR.."/"..cur)
        confirmDelete = nil
        refresh()
        if selApk > #apks then selApk = #apks end
        if selApk < 1 then selApk = 1 end
    else
        confirmDelete = cur
    end
end

local function deleteVerArmed()
    if screen ~= "main" then return end
    local total = #versions
    if selMain > total then confirmDeleteVer = nil; return end
    local cur = versions[selMain]
    if not cur then confirmDeleteVer = nil; return end
    if confirmDeleteVer == cur then
        os.execute("rm -rf '"..VERDIR.."/"..cur.."'")
        confirmDeleteVer = nil
        refresh()
        local n = #versions
        if n == 0 then
            selMain = 1
            if isModern() then focusCol = "actions"; lastAct = 1 end
        else
            if selMain > n then selMain = n end
            if selMain < 1 then selMain = 1 end
            lastVer = selMain
        end
    else
        confirmDeleteVer = cur
    end
end

local function goBack()
    if screen == "apk" then
        if confirmDelete then
            confirmDelete = nil
        else
            screen = "main"
        end
    elseif screen == "archchoice" then
        pendingApk = nil
        screen = "apk"
    elseif screen == "settings" then
        screen = "main"
        syncFocus()
    else
        if confirmDeleteVer then
            confirmDeleteVer = nil
        else
            writeSelected("")
        end
    end
end

local function leftRight(dir)
    if screen == "settings" then
        changeSetting(dir)
        if settingItems[selSet] and settingItems[selSet].key == "theme" then syncFocus() end
    elseif screen == "main" then
        switchColumn(dir)
    end
end

function love.keypressed(key)
    if screen == "skinpick" then
        local k = key
        if k == "dpup" then k = "up" elseif k == "dpdown" then k = "down" elseif k == "dpleft" then k = "left" elseif k == "dpright" then k = "right" elseif k == "a" or k == "space" then k = "return" end
        local act, val, slim = SkinPick.key(k)
        if act == "pick" then
            if val ~= "none" then setSetting("skin_arms", slim and "slim" or "classic") end
            setSetting("skin", val)
            SkinPick.close()
            screen = "settings"
        elseif act == "close" then
            SkinPick.close()
            screen = "settings"
        end
        return
    end
    if key == "up" or key == "dpup" then
        moveSel(-1)
    elseif key == "down" or key == "dpdown" then
        moveSel(1)
    elseif key == "left" or key == "dpleft" then
        leftRight(-1)
    elseif key == "right" or key == "dpright" then
        leftRight(1)
    elseif key == "return" or key == "a" or key == "space" then
        activate()
    elseif key == "x" then
        if screen == "main" then deleteVerArmed() else deleteArmed() end
    elseif key == "escape" then
        goBack()
    end
end

function love.gamepadpressed(joystick, button)
    if CONFIRM_B then
        if button == "a" then button = "b" elseif button == "b" then button = "a" end
    end
    if button == "dpup" then love.keypressed("up")
    elseif button == "dpdown" then love.keypressed("down")
    elseif button == "dpleft" then love.keypressed("left")
    elseif button == "dpright" then love.keypressed("right")
    elseif button == "a" then love.keypressed("return")
    elseif button == "x" then love.keypressed("x")
    elseif button == "b" then love.keypressed("escape")
    end
end
