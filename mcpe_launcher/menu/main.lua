local ACCENT  = {0.20, 0.80, 0.40}
local FG      = {1.00, 1.00, 1.00}
local DIM     = {0.50, 0.50, 0.50}
local BLOCK_H = 52
local PADDING = 20
local LIST_TOP = 90
local PIN_GAP = 10
local PINNED_BLOCK_H = PIN_GAP + 1 + PIN_GAP + BLOCK_H*2
local FOOTER_TEXT_H = 24
local MAIN_RESERVE = PINNED_BLOCK_H + FOOTER_TEXT_H
local APK_RESERVE  = 58

local fontTitolo
local fontTesto
local fontHint
local bgImage
local W, H

local BASEDIR = os.getenv("MCPE_GAMEDIR")
local VERDIR  = BASEDIR.."/versions"
local APKDIR  = BASEDIR.."/Setup Apk"
local MENUDIR = BASEDIR.."/menu"

local screen  = "main"
local selMain = 1
local selApk  = 1
local versions = {}
local apks = {}
local confirmDelete = nil

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

local function refresh()
    versions = scanVersions()
    apks = scanApks()
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

local function drawRow(x, y, w, label, selected, color, selColor)
    if selected then
        love.graphics.setColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.15)
        love.graphics.rectangle("fill", x, y+4, w, BLOCK_H-8, 6, 6)
        love.graphics.setColor(ACCENT)
        love.graphics.rectangle("fill", x, y+4, 4, BLOCK_H-8, 2, 2)
        love.graphics.setColor(selColor)
    else
        love.graphics.setColor(color)
    end
    love.graphics.printf(label, x+16, y+(BLOCK_H-16)/2, w, "left")
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
            drawRow(PADDING, y, 320, v, i == selMain, DIM, FG)
        end
    end

    local pinnedRows = math.min(total, visible)
    local pinnedY = LIST_TOP + pinnedRows*BLOCK_H
    love.graphics.setColor(DIM)
    love.graphics.rectangle("fill", PADDING, pinnedY+PIN_GAP, 320, 1)

    local setupY = pinnedY + PIN_GAP + 1 + PIN_GAP
    local exitY  = setupY + BLOCK_H

    drawRow(PADDING, setupY, 320, "[ Setup Apk ]", selMain == total+1, {0.75,0.6,0.2}, {1.0,0.8,0.25})
    drawRow(PADDING, exitY,  320, "Exit",          selMain == total+2, {0.6,0.2,0.2},  {0.9,0.3,0.3})

    if total > visible then
        love.graphics.setFont(fontHint)
        love.graphics.setColor(DIM)
        love.graphics.printf(clampedSel.."/"..total, PADDING+16, H-FOOTER_TEXT_H+4, 320, "left")
    end
end

local function drawApk()
    love.graphics.setFont(fontTesto)
    if #apks == 0 then
        love.graphics.setColor(DIM)
        love.graphics.printf("No APK found.", PADDING+16, LIST_TOP+10, 320, "left")
        love.graphics.printf("Copy .apk files into:", PADDING+16, LIST_TOP+42, 320, "left")
        love.graphics.printf("mcpe_launcher/Setup Apk/", PADDING+16, LIST_TOP+68, 320, "left")
        love.graphics.printf("(B = back)", PADDING+16, LIST_TOP+104, 320, "left")
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
                drawRow(PADDING, y, 320, a, i == selApk, {0.75,0.25,0.2}, {1.0,0.35,0.3})
            else
                drawRow(PADDING, y, 320, a, i == selApk, DIM, FG)
            end
        end
    end

    love.graphics.setFont(fontHint)
    if confirmDelete then
        love.graphics.setColor(1.0,0.35,0.3)
        love.graphics.printf("Delete? X=Yes   B=No", PADDING+16, H-APK_RESERVE+6, 320, "left")
    else
        love.graphics.setColor(DIM)
        love.graphics.printf("A=Setup   X=Delete   B=Back", PADDING+16, H-APK_RESERVE+6, 320, "left")
    end
    if total > visible then
        love.graphics.setColor(DIM)
        love.graphics.printf(selApk.."/"..total, PADDING+16, H-APK_RESERVE+6+22, 320, "left")
    end
end

function love.load()
    bgImage = love.graphics.newImage("bg.jpg")
    W = love.graphics.getWidth()
    H = love.graphics.getHeight()

    fontTitolo = love.graphics.newFont("font_titolo.ttf", 24)
    fontTesto  = love.graphics.newFont("font_testo.ttf", 16)
    fontHint   = love.graphics.newFont("font_testo.ttf", 13)

    os.execute("mkdir -p '"..APKDIR.."'")
    refresh()
end

function love.draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(bgImage, 0, 0, 0, W/bgImage:getWidth(), H/bgImage:getHeight())
    love.graphics.setColor(0.15,0.12,0.15,0.55)
    love.graphics.rectangle("fill", 0, 0, 360, H)

    love.graphics.setColor(ACCENT)
    love.graphics.setFont(fontTitolo)
    local title = (screen == "apk") and "Setup Apk" or "MCPE Launcher"
    love.graphics.printf(title, 36, 30, 320, "left")

    love.graphics.setColor(DIM)
    love.graphics.rectangle("fill", PADDING*3, 62, 280, 1)

    if screen == "main" then
        drawMain()
    else
        drawApk()
    end
end

local function moveSel(dir)
    if screen == "main" then
        local n = #versions + 2
        selMain = selMain + dir
        if selMain < 1 then selMain = n end
        if selMain > n then selMain = 1 end
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
            writeSelected(versions[selMain])
        elseif selMain == total+1 then
            refresh()
            screen = "apk"
            selApk = 1
            confirmDelete = nil
        else
            writeSelected("")
        end
    else
        local a = apks[selApk]
        if a then
            confirmDelete = nil
            writeApkSelected(a)
        end
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

local function goBack()
    if screen == "apk" then
        if confirmDelete then
            confirmDelete = nil
        else
            screen = "main"
        end
    else
        writeSelected("")
    end
end

function love.keypressed(key)
    if key == "up" or key == "dpup" then
        moveSel(-1)
    elseif key == "down" or key == "dpdown" then
        moveSel(1)
    elseif key == "return" or key == "a" or key == "space" then
        activate()
    elseif key == "x" then
        deleteArmed()
    elseif key == "escape" then
        goBack()
    end
end

function love.gamepadpressed(joystick, button)
    if button == "dpup" then love.keypressed("up")
    elseif button == "dpdown" then love.keypressed("down")
    elseif button == "a" then love.keypressed("return")
    elseif button == "x" then love.keypressed("x")
    elseif button == "b" then love.keypressed("escape")
    end
end
