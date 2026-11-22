-- dev.lua -- desktop preview data. Never used on a console.
-- Excluded from release zips by scripts/build_release.py.

local Dev = {}

local VERSIONS = {
    { "1.21.4", true, true },
    { "1.20.1", true, false },
    { "1.19.2", false, true },
    { "1.18.30", true, true },
    { "1.16.221", false, true },
    { "1.14.60", true, false },
    { "1.12.0", false, true },
    { "1.10.0", true, false },
    { "1.8.0", false, true },
    { "1.6.0", true, false },
    { "1.4.0", false, true },
    { "1.2.0", true, false },
    { "1.1.0", true, false },
    { "1.0.0", false, true },
    { "0.16.0", true, true },
    { "0.15.0", false, true },
    { "0.14.0", true, false },
    { "0.13.0", false, true },
    { "0.12.1", true, true },
    { "Bản sao lưu 1.9.0 (cũ)", true, false },
}

local APKS = {
    { "Minecraft-1.21.4.apk", 842 * 1024 * 1024, true, true },
    { "Minecraft-1.20.1.apk", 712 * 1024 * 1024, true, false },
    { "Minecraft-1.19.2.apk", 689 * 1024 * 1024, false, true },
    { "Minecraft-1.18.30.apk", 604 * 1024 * 1024, true, true },
    { "Minecraft-1.16.221.apk", 512 * 1024 * 1024, false, true },
    { "Minecraft 1.14.60 (old).apk", 388 * 1024 * 1024, true, false },
    { "Minecraft-1.12.0.apk", 301 * 1024 * 1024, false, true },
    { "bản sao lưu 1.10.0.apk", 240 * 1024 * 1024, true, false },
}

local function mkdir(path)
    if love.system.getOS() == "Windows" then
        os.execute('mkdir "' .. path:gsub("/", "\\") .. '" 2>nul')
    else
        os.execute("mkdir -p '" .. path .. "'")
    end
end

local function writeFile(path, data)
    local f = io.open(path, "w")
    if f then f:write(data); f:close() end
end

function Dev.setup(basedir, state)
    local temp = os.getenv("TEMP") or os.getenv("TMP") or "/tmp"
    local base = basedir or (temp .. "/mcpe-launcher-dev")
    base = base:gsub("\\", "/"):gsub("/+$", "")
    Dev.base = base
    Dev.state = state or "many"
    mkdir(base)
    mkdir(base .. "/menu")
    mkdir(base .. "/versions")
    mkdir(base .. "/Setup Apk")
    mkdir(base .. "/Import Skins")
    writeFile(base .. "/version.txt", "1.9.0\n")
    return base
end

local function countForState(n)
    if Dev.state == "empty" then return 0 end
    if Dev.state == "one" then return math.min(1, n) end
    return n
end

function Dev.versions()
    local out = {}
    for i = 1, countForState(#VERSIONS) do
        local v = VERSIONS[i]
        out[#out + 1] = { name = v[1], armhf = v[2], arm64 = v[3] }
    end
    return out
end

function Dev.apks()
    local out = {}
    for i = 1, countForState(#APKS) do
        local a = APKS[i]
        out[#out + 1] = {
            name = a[1], bytes = a[2], armhf = a[3], arm64 = a[4],
            archReady = true,
        }
    end
    return out
end

function Dev.freeSpace()
    return 4.2 * 1024 * 1024 * 1024
end

function Dev.isWindows()
    return love.system.getOS() == "Windows"
end

return Dev
