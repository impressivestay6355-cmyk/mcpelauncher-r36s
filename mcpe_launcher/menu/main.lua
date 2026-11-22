-- main.lua -- MCPE Launcher menu.
-- The menu is a thin controller: screens draw, this file owns file I/O and
-- the handshake with McpeLauncher.sh.

local UI = require("ui")
local Home = require("screens.home")
local Apk = require("screens.apk")
local Arch = require("screens.arch")

local App = {
    screenName = "home",
    screens = {},
    versions = {},
    apks = {},
    sel = 1,
    selApk = 1,
    selArch = 1,
    archOptions = { "both", "armhf", "arm64" },
    modal = nil,
    heroVer = nil,
    portVersion = "",
}

local REPEAT_DELAY, REPEAT_RATE = 0.35, 0.09
local repeatKey, repeatTimer = nil, 0

local function shq(s)
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function popenLines(cmd)
    local p = io.popen(cmd)
    if not p then return {} end
    local out = {}
    for line in p:lines() do out[#out + 1] = line end
    p:close()
    return out
end

local function readLine(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*l")
    f:close()
    return s
end

local function writeFile(path, data)
    local f = io.open(path, "w")
    if not f then return false end
    f:write(data)
    f:close()
    return true
end

local function versionLess(a, b)
    local function nums(s)
        local t = {}
        for n in s:gmatch("%d+") do t[#t + 1] = tonumber(n) end
        return t
    end
    local ta, tb = nums(a), nums(b)
    for i = 1, math.max(#ta, #tb) do
        local x, y = ta[i] or -1, tb[i] or -1
        if x ~= y then return x < y end
    end
    return a:lower() < b:lower()
end

function App:writeMenu(name, data)
    return writeFile(self.menudir .. "/" .. name, data)
end

function App:quitMenu()
    if not self.shots and not self.noQuit then love.event.quit(0) end
end

function App:playVersion(name)
    self:writeMenu("selected_version.txt", name)
    self:quitMenu()
end

function App:exitMenu()
    self:writeMenu("selected_version.txt", "")
    self:quitMenu()
end

function App:requestUpdate()
    self:writeMenu("update_request.txt", "1")
    self:quitMenu()
end

function App:installApk(name, arch)
    self:writeMenu("setup_apk_arch.txt", arch)
    self:writeMenu("setup_apk_selected.txt", name)
    self:quitMenu()
end

function App:scanVersions()
    local out
    if self.dev then
        out = self.devModule.versions()
    else
        out = {}
        for _, line in ipairs(popenLines("ls -d " .. shq(self.verdir) .. "/*/ 2>/dev/null")) do
            local name = line:match("([^/]+)/%s*$")
            if name then out[#out + 1] = { name = name, armhf = false, arm64 = false } end
        end
        local map = {}
        for _, v in ipairs(out) do map[v.name] = v end
        for _, line in ipairs(popenLines("ls -d " .. shq(self.verdir) .. "/*/lib/* 2>/dev/null")) do
            local name, abi = line:match("([^/]+)/lib/([^/]+)/?%s*$")
            if name and map[name] then
                if abi == "armeabi-v7a" then
                    map[name].armhf = true
                elseif abi == "arm64-v8a" then
                    map[name].arm64 = true
                end
            end
        end
    end
    -- Newest first: 1.21.4 before 1.9.0, and before 0.12.1.
    table.sort(out, function(a, b) return versionLess(b.name, a.name) end)
    self.versions = out
end

function App:scanApks()
    if self.dev then
        self.apks = self.devModule.apks()
        return
    end
    local out = {}
    for _, line in ipairs(popenLines("ls -1 " .. shq(self.apkdir) .. " 2>/dev/null")) do
        if line:lower():match("%.apk$") then
            local size = tonumber(popenLines("stat -c %s " .. shq(self.apkdir .. "/" .. line))[1] or "")
            out[#out + 1] = { name = line, bytes = size or 0, archReady = false }
        end
    end
    table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
    self.apks = out
end

function App:ensureApkArch(apk)
    if not apk or apk.archReady then return end
    if self.dev then
        apk.armhf, apk.arm64 = true, true
        apk.archReady = true
        return
    end
    apk.armhf, apk.arm64 = false, false
    for _, line in ipairs(popenLines("unzip -l " .. shq(self.apkdir .. "/" .. apk.name) .. " 2>/dev/null")) do
        if line:find("lib/armeabi-v7a", 1, true) then apk.armhf = true end
        if line:find("lib/arm64-v8a", 1, true) then apk.arm64 = true end
    end
    apk.archReady = true
end

function App:freeSpace()
    if self.dev then return self.devModule.freeSpace() end
    local out = popenLines("df -Pk " .. shq(self.base) .. " 2>/dev/null")
    local fields = {}
    for f in (out[2] or ""):gmatch("%S+") do fields[#fields + 1] = f end
    local kb = tonumber(fields[4])
    return kb and kb * 1024 or 0
end

function App:deleteVersion(name)
    if self.dev then
        for i, v in ipairs(self.versions) do
            if v.name == name then table.remove(self.versions, i) break end
        end
    else
        os.execute("rm -rf " .. shq(self.verdir .. "/" .. name))
        self:scanVersions()
    end
    local stillHere = false
    for _, v in ipairs(self.versions) do
        if v.name == self.heroVer then stillHere = true break end
    end
    if not stillHere then
        self.heroVer = self.versions[1] and self.versions[1].name or nil
    end
    self.sel = math.max(1, math.min(self.sel, self:homeItemCount()))
end

function App:deleteApk(name)
    if self.dev then
        for i, a in ipairs(self.apks) do
            if a.name == name then table.remove(self.apks, i) break end
        end
    else
        os.remove(self.apkdir .. "/" .. name)
        self:scanApks()
    end
    self.selApk = math.max(1, math.min(self.selApk, math.max(1, #self.apks)))
end

function App:homeItemCount()
    return #self.versions + 3 + (#self.versions > 0 and 1 or 0)
end

function App:switch(name)
    self.screenName = name
    local s = self.screens[name]
    if s and s.enter then s.enter(self) end
end

function App:openModal(m)
    m.focus = 1
    self.modal = m
end

function App:closeModal()
    self.modal = nil
end

function App:modalKey(act)
    local m = self.modal
    if act == "left" or act == "right" then
        m.focus = (m.focus == 1) and 2 or 1
    elseif act == "a" then
        if m.focus == 1 then
            self:closeModal()
        else
            local fn = m.onConfirm
            self:closeModal()
            if fn then fn() end
        end
    elseif act == "b" then
        self:closeModal()
    end
end

function App:key(act)
    if self.modal then return self:modalKey(act) end
    local s = self.screens[self.screenName]
    if s and s.key then s.key(self, act) end
end

App.screens.home = Home
App.screens.apk = Apk
App.screens.arch = Arch

-- ---------------------------------------------------------------- arguments

local function parseArgs(args)
    local o = {}
    for _, a in ipairs(args or {}) do
        if a == "--dev" then
            o.dev = true
        elseif a == "--shots" then
            o.dev, o.shots = true, true
        elseif a == "--selftest" then
            o.dev, o.selftest = true, true
        elseif a:match("^%-%-screen=") then
            o.screen = a:match("=(.+)$")
        elseif a:match("^%-%-state=") then
            o.state = a:match("=(.+)$")
        elseif a:match("^%-%-basedir=") then
            o.basedir = a:match("=(.+)$")
        end
    end
    return o
end

function love.load(args)
    local t0 = love.timer.getTime()
    local opts = parseArgs(args)
    local envBase = os.getenv("MCPE_GAMEDIR")
    local devMode = opts.dev or (envBase == nil)

    if devMode then
        local ok, dev = pcall(require, "dev")
        if not ok then
            error("MCPE_GAMEDIR is not set and dev.lua is unavailable")
        end
        App.devModule = dev
        App.dev = true
        App.base = dev.setup(opts.basedir, opts.state)
    else
        App.base = envBase
    end

    App.base = App.base:gsub("\\", "/")
    App.verdir = App.base .. "/versions"
    App.apkdir = App.base .. "/Setup Apk"
    App.menudir = App.base .. "/menu"
    App.portVersion = readLine(App.base .. "/version.txt") or ""
    App.confirmB = (os.getenv("MCPE_CONFIRM_SDL") or "a"):lower() == "b"
    App.okLabel = (os.getenv("MCPE_CONFIRM_LABEL") or "A"):upper() == "B" and "B" or "A"
    App.backLabel = App.okLabel == "A" and "B" or "A"
    local arch = os.getenv("DEVICE_ARCH") or ""
    App.archLabel = (arch == "armhf") and "ARM32" or "ARM64"

    if devMode then
        love.window.setMode(640, 480, {
            fullscreen = false, vsync = 1, resizable = false, msaa = 0,
        })
    end

    UI.load()
    App:scanVersions()
    App.heroVer = App.versions[1] and App.versions[1].name or nil

    if opts.shots then
        App.shots = true
        App:startShots()
    elseif opts.selftest then
        App.noQuit = true
        App:runSelftest()
        return
    else
        App:switch(opts.screen or "home")
        if opts.state == "confirm" then
            App.sel = (#App.versions > 0) and 2 or 1
            local v = App.versions[App.sel - 1]
            if v then
                App:openModal({
                    title = "DELETE VERSION?",
                    body = {
                        UI.fit(UI.font.body11, "Remove the installed game files for " .. v.name .. "?", 368),
                        "Worlds, skins and settings are kept.",
                    },
                    confirmLabel = "DELETE",
                    variant = "danger",
                    onConfirm = function() App:deleteVersion(v.name) end,
                })
            end
        elseif opts.state == "arch" then
            App:scanApks()
            App.pendingApk = App.apks[1]
            App:switch("arch")
        end
    end

    print("SAVE " .. love.filesystem.getSaveDirectory())
    print(string.format("MENU READY %.3fs", love.timer.getTime() - t0))
end

-- ---------------------------------------------------------------- shots

local SHOTS = {
    {
        name = "01-home-play",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions(); app:scanApks()
            app.heroVer = app.versions[1] and app.versions[1].name
            app.modal = nil
            app:switch("home")
            app.sel = 1
        end,
    },
    {
        name = "02-home-list",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions(); app:scanApks()
            app.heroVer = app.versions[1] and app.versions[1].name
            app.modal = nil
            app:switch("home")
            app.sel = 2
        end,
    },
    {
        name = "03-home-empty",
        apply = function(app)
            app.devModule.state = "empty"
            app:scanVersions(); app:scanApks()
            app.heroVer = nil
            app.modal = nil
            app:switch("home")
            app.sel = 1
        end,
    },
    {
        name = "04-setup",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions(); app:scanApks()
            app.modal = nil
            app:switch("apk")
            app.selApk = 1
        end,
    },
    {
        name = "05-setup-empty",
        apply = function(app)
            app.devModule.state = "empty"
            app:scanApks()
            app.modal = nil
            app:switch("apk")
        end,
    },
    {
        name = "06-arch",
        apply = function(app)
            app.devModule.state = "many"
            app:scanApks()
            app.pendingApk = app.apks[1]
            app:ensureApkArch(app.pendingApk)
            app.archOptions = { "both", "armhf", "arm64" }
            app.modal = nil
            app:switch("arch")
            app.selArch = 1
        end,
    },
    {
        name = "07-modal-delete",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions()
            app:switch("home")
            app.sel = 2
            local v = app.versions[1]
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
        end,
    },
    {
        name = "08-modal-update",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions()
            app:switch("home")
            app.sel = app:homeItemCount() - 1
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
        end,
    },
    {
        name = "09-setup-unicode",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions(); app:scanApks()
            app.modal = nil
            app:switch("apk")
            app.selApk = 8
        end,
    },
    {
        name = "10-home-unicode",
        apply = function(app)
            app.devModule.state = "many"
            app:scanVersions()
            app.modal = nil
            app:switch("home")
            app.sel = 1 + #app.versions
            app.heroVer = app.versions[#app.versions].name
            for i, v in ipairs(app.versions) do
                if v.name:find("Bản", 1, true) then
                    app.sel = 1 + i
                    app.heroVer = v.name
                    break
                end
            end
        end,
    },
}

function App:startShots()
    self.shotIndex = 0
    self.shotFrames = 0
    self:applyShot(1)
end

function App:applyShot(i)
    self.shotIndex = i
    self.shotFrames = 0
    local s = SHOTS[i]
    if s then s.apply(self) end
end

local function updateShots()
    App.shotFrames = App.shotFrames + 1
    if App.shotFrames == 2 then
        local s = SHOTS[App.shotIndex]
        if s then
            love.graphics.captureScreenshot(s.name .. ".png")
        end
    elseif App.shotFrames == 6 then
        if App.shotIndex >= #SHOTS then
            love.event.quit(0)
            return
        end
        App:applyShot(App.shotIndex + 1)
    end
end

-- Headless-ish regression test for the desktop preview build. It exercises
-- navigation and the handshake files without needing a console.
function App:runSelftest()
    local fails = {}
    local function check(cond, msg)
        if not cond then fails[#fails + 1] = msg end
    end
    local function read(name)
        local f = io.open(self.menudir .. "/" .. name, "r")
        if not f then return nil end
        local s = f:read("*l")
        f:close()
        return s
    end
    local function clear()
        for _, n in ipairs({
            "selected_version.txt", "setup_apk_selected.txt",
            "setup_apk_arch.txt", "update_request.txt",
        }) do
            os.remove(self.menudir .. "/" .. n)
        end
    end
    local function reset(state)
        self.devModule.state = state or "many"
        self.modal = nil
        self:scanVersions()
        self:scanApks()
        self.heroVer = self.versions[1] and self.versions[1].name or nil
        self.sel, self.selApk, self.selArch = 1, 1, 1
        self:switch("home")
    end

    clear()

    reset("many")
    self:key("down"); check(self.sel == 2, "down from play")
    self:key("right"); check(self.sel == 3, "right in grid")
    self:key("up"); check(self.sel == 1, "up back to play")

    clear()
    reset("many")
    self.sel = 2
    self:key("a")
    check(read("selected_version.txt") == self.versions[1].name, "play writes selected_version")

    clear()
    reset("many")
    self.sel = self:homeItemCount() - 1
    self:key("a")
    check(self.modal ~= nil, "update opens modal")
    self:key("right")
    self:key("a")
    check(read("update_request.txt") == "1", "update writes request")

    reset("many")
    self.sel = 2
    local count = #self.versions
    self:key("x")
    check(self.modal ~= nil, "delete opens modal")
    self:key("a")
    check(self.modal == nil and #self.versions == count, "cancel keeps version")
    self:key("x")
    self:key("right")
    self:key("a")
    check(#self.versions == count - 1, "delete removes version")

    clear()
    reset("many")
    self.sel = #self.versions + 2
    self:key("a")
    check(self.screenName == "apk", "setup opens apk screen")
    self.selApk = 1
    self:key("a")
    check(self.screenName == "arch", "dual apk opens arch screen")
    self:key("b")
    check(self.screenName == "apk" and self.selApk == 1, "arch back keeps selection")
    self:key("a")
    self:key("a")
    check(read("setup_apk_selected.txt") == self.apks[1].name, "arch writes apk name")
    check(read("setup_apk_arch.txt") == "both", "arch writes both")

    clear()
    reset("many")
    self.sel = #self.versions + 2
    self:key("a")
    self.selApk = 3
    self:key("a")
    check(self.screenName == "apk", "single apk skips arch")
    check(read("setup_apk_arch.txt") == "arm64", "single apk writes arm64")

    clear()
    reset("many")
    self.sel = #self.versions + 2
    self:key("a")
    self.selApk = 1
    self:key("a")
    self:key("right")
    self:key("a")
    check(read("setup_apk_arch.txt") == "armhf", "choose armhf")

    reset("empty")
    check(#self.versions == 0 and #self.apks == 0, "empty state has no items")
    self:key("a")
    check(self.screenName == "apk", "empty home opens setup")
    self:key("b")
    check(self.screenName == "home", "back returns home")

    clear()
    if #fails == 0 then
        print("SELFTEST PASS")
    else
        print("SELFTEST FAIL: " .. table.concat(fails, "; "))
    end
    love.event.quit(#fails == 0 and 0 or 1)
end

-- ---------------------------------------------------------------- love loop

local function heldDirection()
    if love.keyboard.isDown("up") then return "up" end
    if love.keyboard.isDown("down") then return "down" end
    if love.keyboard.isDown("left") then return "left" end
    if love.keyboard.isDown("right") then return "right" end
    return nil
end

function love.update(dt)
    if App.shots then
        updateShots()
        return
    end
    local d = heldDirection()
    if d then
        if d ~= repeatKey then
            repeatKey, repeatTimer = d, REPEAT_DELAY
        else
            repeatTimer = repeatTimer - dt
            if repeatTimer <= 0 then
                repeatTimer = REPEAT_RATE
                App:key(d)
            end
        end
    else
        repeatKey = nil
    end
end

function love.draw()
    UI.set(UI.c.bg)
    love.graphics.rectangle("fill", 0, 0, UI.L.w, UI.L.h)
    local s = App.screens[App.screenName]
    if s and s.draw then s.draw(App) end
    if App.modal then
        UI.modal(App.modal.title, App.modal.body, {
            { label = "CANCEL" },
            { label = App.modal.confirmLabel or "OK", variant = App.modal.variant },
        }, App.modal.focus)
    end
end

local function normalize(key)
    if key == "up" or key == "dpup" then return "up" end
    if key == "down" or key == "dpdown" then return "down" end
    if key == "left" or key == "dpleft" then return "left" end
    if key == "right" or key == "dpright" then return "right" end
    if key == "return" or key == "kpenter" or key == "space" or key == "a" then return "a" end
    if key == "escape" or key == "b" or key == "backspace" then return "b" end
    if key == "x" then return "x" end
    return nil
end

function love.keypressed(key)
    if key == "f12" then
        love.graphics.captureScreenshot("manual-" .. os.time() .. ".png")
        return
    end
    local act = normalize(key)
    if act then App:key(act) end
end

function love.gamepadpressed(_, button)
    local map = {
        dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
        a = "a", b = "b", x = "x",
    }
    local act = map[button]
    if not act then return end
    if App.confirmB and (act == "a" or act == "b") then
        act = (act == "a") and "b" or "a"
    end
    App:key(act)
end
