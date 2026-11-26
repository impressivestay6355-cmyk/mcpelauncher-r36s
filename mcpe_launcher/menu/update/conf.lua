local dev = false
for _, a in ipairs(arg or {}) do
    if a == "--dev" or a:match("^%-%-demo=") then dev = true end
end

function love.errorhandler(msg)
    local base = os.getenv("MCPE_GAMEDIR")
    if base and base ~= "" then
        local f = io.open(base .. "/menu_error.txt", "w")
        if f then
            f:write(tostring(msg))
            f:write("\n")
            f:close()
        end
    end
    return function()
        love.graphics.clear(0.05, 0.05, 0.06, 1)
        love.graphics.setColor(0.92, 0.30, 0.26)
        love.graphics.print("MCPE LAUNCHER ERROR", 16, 16)
        love.graphics.setColor(0.90, 0.90, 0.94)
        love.graphics.printf(tostring(msg), 16, 44, 608)
        love.graphics.setColor(0.60, 0.60, 0.68)
        love.graphics.print("Saved to menu_error.txt. Press A or Esc to close.", 16, 448)
        if love.keyboard.isDown("return") or love.keyboard.isDown("escape")
            or love.keyboard.isDown("space") or love.keyboard.isDown("a")
            or love.keyboard.isDown("b") then
            love.event.quit(1)
        end
    end
end

function love.conf(t)
    if dev then t.identity = "mcpe-launcher-ui" end
    t.window.title = "MCPE Launcher"
    t.window.width = 640
    t.window.height = 480
    t.window.fullscreen = not dev
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.highdpi = false
    t.window.resizable = false
    t.modules.audio = false
    t.modules.sound = false
    t.modules.physics = false
    t.console = false
end
