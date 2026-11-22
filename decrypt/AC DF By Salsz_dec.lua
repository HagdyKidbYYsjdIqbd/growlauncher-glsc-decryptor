-- ============================================================
-- Auto DF By Salsz (v39)
-- ============================================================
-- Fix: Seed drop mid-Phase 1 & Phase 2
-- Cek seed setiap 30 tile di Phase 1, setiap 10 lava di Phase 2
-- ============================================================

-- ==========================================
-- UI GENERATOR
-- ==========================================
local dfUI = UserInterface.new("Auto DF By Salsz", "Verified")

dfUI:addLabel("Target World Setting")
dfUI:addInputString("DF World (koma = multi)", "", "World", "W1,W2,W3", "Verified", "df_world")
dfUI:addInputString("Storage World", "", "World", "World storage seed & dirt", "Verified", "storage_world")
dfUI:addInputString("Storage Door", "", "ID Door", "Kosongkan jika tanpa pintu", "Verified", "storage_door")

dfUI:addDivider()
dfUI:addLabel("Storage Drop Seed Coordinate")
dfUI:addInputInt("Drop Seed X", "77", "X", "Posisi X drop Cave Seed", "Verified", "drop_x")
dfUI:addInputInt("Drop Seed Y", "23", "Y", "Posisi Y drop seed", "Verified", "drop_y")

dfUI:addDivider()
dfUI:addLabel("Storage Dirt Block Coordinate")
dfUI:addInputInt("Dirt Stock X", "50", "X", "Posisi X tempat Dirt Block ditumpuk", "Verified", "dirt_x")
dfUI:addInputInt("Dirt Stock Y", "30", "Y", "Posisi Y tempat Dirt Block ditumpuk", "Verified", "dirt_y")

dfUI:addDivider()
dfUI:addLabel("Delay & Limit Setting")
dfUI:addInputInt("Break Delay (ms)", "150", "ms", "Delay jeda break block", "Verified", "break_d")
dfUI:addInputInt("Max Hit per Block", "42", "Hit", "Maksimal pukulan per block", "Verified", "max_hit")
dfUI:addInputInt("Phase 4 Place Delay (ms)", "150", "ms", "Delay jeda PUT dirt di Phase 4", "Verified", "p4_place_d")

dfUI:addDivider()
dfUI:addLabel("Visual & Execution Menu")
dfUI:addToggle("Cek Posisi/Tile Saya Sekarang (Log)", false, "toggle_pos_check", true)
dfUI:addToggle("START / STOP BOT", false, "start_bot", true)

local json = dfUI:generateJSON()
requireModule("SalszDFUI")
addIntoModule(json, "SalszDFUI")

-----------------Setting Default-------------------
DFWorldList = {}
DFWorld = ""
StorageWorld = ""
StorageDoor = ""
DropX = 77
DropY = 23
DirtStockX = 50
DirtStockY = 30
BreakD = 150
MaxHit = 42
P4PlaceD = 150

------ID item------
CaveS = 15
DirtS = 3
DirtBe = 2
LavaID = 4
RockID = 10

------BATAS Y------
Y_MIN = 24
Y_MAX = 53

------Koordinat Phase 3------
PlaceYList = {26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52}
PlaceXStart = 2
PlaceXEnd = 97

------Koordinat Phase 4------
PlaceYList4 = {22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2}
PlaceXStart4 = 2
PlaceXEnd4 = 97

-------------------------------------------

-- ===== VARIABEL GLOBAL =====
local isRunning = false
local isThreadActive = false
local currentWorldIdx = 1

-- Blacklist FindPath (ms)
local findPathBlacklist = {}
local BlacklistDuration = 3000

-- ==========================================
-- HOOK ON VALUE
-- ==========================================
function onValue(type, name, value)
    if name == "start_bot" then
        isRunning = value
        if isRunning then
            if not isThreadActive then
                log("[Salsz] Auto DF Started")
                parseWorldList()
                findPathBlacklist = {}

                if #DFWorldList > 0 then
                    currentWorldIdx = 1
                    warpToWorld(DFWorldList[currentWorldIdx])
                    waitForWorldLoaded(5000)
                else
                    log("[Salsz] World list kosong")
                end

                pcall(function()
                    runThread(mainLoop)
                end)
            end
        else
            log("[Salsz] STOP ditekan")
            StopAll()
        end
    elseif name == "toggle_pos_check" then
        if value then
            local p = getLocal()
            if p then
                local tileX = math.floor(p.posX / 32)
                local tileY = math.floor(p.posY / 32)
                local tile = getTile(tileX, tileY)
                local fgVal = tile and tile.fg or 0
                local bgVal = tile and tile.bg or 0
                log("[Salsz] POSISI: X=" .. tileX .. " Y=" .. tileY .. " | fg=" .. fgVal .. " bg=" .. bgVal)
            else
                log("[Salsz] Error: Karakter tidak ditemukan")
            end
        end
    elseif name == "df_world" then
        DFWorld = tostring(value)
    elseif name == "storage_world" then
        StorageWorld = tostring(value)
    elseif name == "storage_door" then
        StorageDoor = tostring(value)
    elseif name == "drop_x" then
        DropX = tonumber(value) or 77
    elseif name == "drop_y" then
        DropY = tonumber(value) or 23
    elseif name == "dirt_x" then
        DirtStockX = tonumber(value) or 50
    elseif name == "dirt_y" then
        DirtStockY = tonumber(value) or 30
    elseif name == "break_d" then
        BreakD = tonumber(value) or 150
    elseif name == "max_hit" then
        MaxHit = tonumber(value) or 42
    elseif name == "p4_place_d" then
        P4PlaceD = tonumber(value) or 150
    end
end

addHook(onValue, "onValue")
applyHook()

-- ============================================================
-- PARSE WORLD LIST
-- ============================================================
function parseWorldList()
    DFWorldList = {}
    if not DFWorld or DFWorld == "" then return end
    for w in string.gmatch(DFWorld, "([^,]+)") do
        local t = w:match("^%s*(.-)%s*$")
        if t ~= "" then table.insert(DFWorldList, t) end
    end
end

-- ============================================================
-- NORMALIZE WORLD
-- ============================================================
function normalizeWorld(name)
    if not name then return "" end
    local t = tostring(name):match("^%s*(.-)%s*$")
    if not t then return "" end
    return t:lower()
end

function isInWorld(target)
    local current = GetWorldName()
    if not current then return false end
    return normalizeWorld(current) == normalizeWorld(target)
end

-- ============================================================
-- WARP
-- ============================================================
function warpToWorld(worldName)
    if not worldName or worldName == "" then return false end

    if isInWorld(worldName) then
        sleep(500)
        return true
    end

    log("[Salsz] Warp ke: " .. worldName)

    growtopia.warpTo(worldName)
    sleep(5000)

    local current = GetWorldName()
    if normalizeWorld(current) == normalizeWorld(worldName) then
        log("[Salsz] Warp BERHASIL")
        sleep(1500)
        findPathBlacklist = {}
        return true
    end

    growtopia.warpTo(worldName)
    sleep(5000)

    current = GetWorldName()
    if normalizeWorld(current) == normalizeWorld(worldName) then
        log("[Salsz] Warp BERHASIL (retry)")
        sleep(1500)
        findPathBlacklist = {}
        return true
    end

    log("[Salsz] Warp GAGAL ke: " .. worldName)
    return false
end

function waitForWorldLoaded(timeoutMs)
    timeoutMs = timeoutMs or 5000
    local waited = 0

    while waited < timeoutMs do
        if not isRunning then return false end
        sleep(500)
        waited = waited + 500

        local tiles = getTiles()
        if tiles then
            local count = 0
            for _ in pairs(tiles) do
                count = count + 1
                if count >= 10 then return true end
            end
        end
    end
    log("[Salsz] World GAGAL load. STOP ALL.")
    isRunning = false
    return false
end

-- ============================================================
-- STOP ALL
-- ============================================================
function StopAll()
    isRunning = false

    pcall(function()
        sendPacket(2, "action|mdfly\n|enable|0")
        sendPacket(2, "action|antibounce\n|enable|0")
        sendPacket(2, "action|fastdrop\n|enable|0")
        sendPacket(2, "action|input\n|left|0\n|right|0\n|up|0\n|down|0")
        sendPacket(2, "action|input\n|space|0")
        editToggle("ModFly", false)
        editToggle("Antibounce", false)
        editToggle("Fast Drop", false)
    end)

    log("[Salsz] STOP")
    if growtopia and growtopia.notify then
        growtopia.notify("Salsz STOP")
    end
    isThreadActive = false
end

-- ============================================================
-- PACKET BREAK
-- ============================================================
function BreakAt(x, y, offset)
    local pkt = {
        type = 3, value = 18,
        x = x * 32, y = (y - offset) * 32,
        px = x, py = y
    }
    sendPacketRaw(false, pkt)
    sleep(BreakD)
end

function BreakLava(x, y) BreakAt(x, y, 1) end
function BreakDirt(x, y) BreakAt(x, y, 2) end

function PutDirt(x, y)
    local p = getLocal()
    if not p then return end
    local pkt = {
        type = 3, value = 2,
        x = p.posX, y = p.posY,
        px = x, py = y
    }
    sendPacketRaw(false, pkt)
end

-- ============================================================
-- PLAYER POSITION HELPER
-- ============================================================
function getPlayerTile()
    local p = getLocal()
    if not p then return nil, nil end
    return math.floor(p.posX / 32), math.floor(p.posY / 32)
end

-- ============================================================
-- tryFindPath — VERIFIKASI ARRIVAL
-- ============================================================
local function nowMs()
    return math.floor(os.clock() * 1000)
end

function tryFindPath(targetX, targetY, timeoutMs)
    timeoutMs = timeoutMs or 2000

    if targetY < 0 or targetY > 53 then
        return false
    end

    local key = targetX .. "_" .. targetY
    local now = nowMs()

    if findPathBlacklist[key] then
        local elapsed = now - findPathBlacklist[key]
        if elapsed < BlacklistDuration then
            return false
        else
            findPathBlacklist[key] = nil
        end
    end

    local px, py = getPlayerTile()
    if px == targetX and py == targetY then
        return true
    end

    local result = FindPath(targetX, targetY)

    if result == true then
        findPathBlacklist[key] = now
        return false
    end

    local waited = 0
    while waited < timeoutMs do
        if not isRunning then return false end
        sleep(150)
        waited = waited + 150

        local px2, py2 = getPlayerTile()
        if px2 == targetX and py2 == targetY then
            return true
        end
    end

    findPathBlacklist[key] = now
    return false
end

-- ============================================================
-- TILE HELPER
-- ============================================================
function isLavaTile(x, y)
    local t = getTile(x, y)
    if not t then return false end
    return t.fg == LavaID
end

function isSafeStandingTile(x, y)
    if x < 0 or x > 100 or y < 0 then return false end
    local t = getTile(x, y)
    if not t then return false end
    if t.fg == LavaID then return false end
    if (t.fg or 0) ~= 0 then return false end
    return true
end

-- ============================================================
-- INVENTORY
-- ============================================================
function GetItemAmount(item)
    local inv = getInventory()
    if not inv then return 0 end
    for _, object in pairs(inv) do
        if object.id == item then
            return object.amount or 0
        end
    end
    return 0
end

-- Cek apakah seed penuh (perlu storage)
function isSeedFull()
    if StorageWorld == "" or StorageWorld == nil then return false end
    local caveSeed = GetItemAmount(CaveS)
    local dirtSeed = GetItemAmount(DirtS)
    return (caveSeed >= 200) or (dirtSeed >= 200)
end

-- ============================================================
-- ANTI LAVA & BOUNCE
-- ============================================================
function AntiLava()
    local p = getLocal()
    if not p then return end
    local px = math.floor(p.posX / 32)
    local py = math.floor(p.posY / 32)

    for dx = -2, 2 do
        for dy = -2, 2 do
            local tile = getTile(px + dx, py + dy)
            if tile and tile.fg == 44 then
                sendPacket(2, "action|input\n|space|1")
                sleep(100)
                sendPacket(2, "action|input\n|space|0")
                return
            end
        end
    end
end

function AntiBounce()
    sendPacket(2, "action|input\n|left|1")
    sleep(50)
    sendPacket(2, "action|input\n|left|0")
end

-- ============================================================
-- STORAGE
-- ============================================================
function DropCaveSeed()
    sendPacket(2, "action|drop\n|itemID|" .. CaveS)
    sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. CaveS .. "|\ncount|200")
    sleep(800)
end

function DropDirtSeed()
    sendPacket(2, "action|drop\n|itemID|" .. DirtS)
    sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. DirtS .. "|\ncount|200")
    sleep(800)
end

function HandleStorageSeedDrop()
    if StorageWorld == "" or StorageWorld == nil then return end

    local caveSeed = GetItemAmount(CaveS)
    local dirtSeed = GetItemAmount(DirtS)

    if caveSeed >= 200 or dirtSeed >= 200 then
        log("[Salsz] Seed penuh, ke storage")

        local currentWorld = DFWorldList[currentWorldIdx] or ""

        if not warpToWorld(StorageWorld) then
            log("[Salsz] Gagal ke storage")
            return
        end

        if caveSeed >= 200 then
            if FindPath then FindPath(DropX, DropY) end
            sleep(700)
            DropCaveSeed()
            sleep(1000)
        end

        if dirtSeed >= 200 then
            if FindPath then FindPath(DropX + 2, DropY) end
            sleep(700)
            DropDirtSeed()
            sleep(1000)
        end

        if currentWorld ~= "" then
            warpToWorld(currentWorld)
        end
    end
end

function GoToStorageGetDirt()
    if StorageWorld == "" or StorageWorld == nil then
        log("[Salsz] Storage World kosong")
        return false
    end

    local currentWorld = DFWorldList[currentWorldIdx] or ""

    log("[Salsz] Ke storage ambil Dirt Block")

    if not warpToWorld(StorageWorld) then
        log("[Salsz] Gagal warp. STOP ALL.")
        isRunning = false
        return false
    end

    local pathOK = false
    for attempt = 1, 3 do
        if not isRunning then return false end
        if tryFindPath(DirtStockX, DirtStockY) then
            pathOK = true
            break
        end
        sleep(1000)
    end

    if not pathOK then
        log("[Salsz] Gagal jalan ke Dirt Stock. STOP ALL.")
        isRunning = false
        return false
    end

    sleep(2000)

    local dirtCount = GetItemAmount(DirtBe)
    log("[Salsz] Dirt Block di storage: " .. dirtCount)

    if currentWorld ~= "" then
        warpToWorld(currentWorld)
    end

    return dirtCount > 0
end

-- ============================================================
-- PHASE 1: CLEAR MUTLAK ODD LINE (Y24-Y53)
-- ============================================================
function ClearDirtAndRock()
    log("[Salsz] PHASE 1: CLEAR MUTLAK ODD LINE (Y24-Y53)")
    local MAX_GUARD = 10
    local passWithoutStorage = 0
    local found = true

    while found and isRunning and passWithoutStorage < MAX_GUARD do
        found = false

        findPathBlacklist = {}

        local tiles = getTiles()
        if not tiles then return end

        local tileCounter = 0
        local skippedByStorage = false

        for _, tile in pairs(tiles) do
            if not isRunning then return end

            tileCounter = tileCounter + 1

            -- Cek seed setiap 30 tile
            if tileCounter % 30 == 0 then
                if isSeedFull() then
                    log("[Salsz] Seed penuh mid-Phase 1, drop ke storage")
                    HandleStorageSeedDrop()
                    if not isRunning then return end
                    skippedByStorage = true
                    found = true
                    break
                end
            end

            if tile.y < Y_MIN or tile.y > Y_MAX then goto continue end

            local isTarget = false
            if tile.y % 2 == 1 then
                isTarget = true
            else
                if tile.x == 0 or tile.x == 1 or tile.x == 98 or tile.x == 99 then
                    isTarget = true
                end
            end

            if isTarget then
                local fg = tile.fg or 0
                local bg = tile.bg or 0
                local isEmpty = (fg == 0 and bg == 0)

                if not isEmpty then
                    found = true

                    local moveY = tile.y - 2

                    if moveY < 0 then goto continue end

                    if tryFindPath(tile.x, moveY) then
                        local hit = 0
                        while hit < MaxHit and isRunning do
                            local cek = getTile(tile.x, tile.y)
                            if not cek or (cek.fg == 0 and cek.bg == 0) then break end

                            BreakAt(tile.x, tile.y, 2)
                            hit = hit + 1
                            AntiBounce()
                            AntiLava()
                        end
                    end
                end
            end

            ::continue::
        end

        if not skippedByStorage then
            passWithoutStorage = passWithoutStorage + 1
        end

        sleep(200)
    end
end

-- ============================================================
-- PHASE 2: CLEAR LAVA ONLY DI EVEN LINE (Y24-Y52)
-- ============================================================
function FindSafePosition(targetX, targetY)
    local candidates = {
        { x = targetX, y = targetY - 1 },
        { x = targetX, y = targetY + 1 },
    }

    for _, pos in ipairs(candidates) do
        if pos.y >= 23 and pos.y <= Y_MAX then
            if isSafeStandingTile(pos.x, pos.y) then
                if tryFindPath(pos.x, pos.y) then
                    return true
                end
            end
        end
    end

    for offset = 1, 3 do
        local fb = {
            { x = targetX - offset, y = targetY - 1 },
            { x = targetX + offset, y = targetY - 1 },
            { x = targetX - offset, y = targetY + 1 },
            { x = targetX + offset, y = targetY + 1 },
        }
        for _, pos in ipairs(fb) do
            if pos.y >= 23 and pos.y <= Y_MAX then
                if isSafeStandingTile(pos.x, pos.y) then
                    if tryFindPath(pos.x, pos.y) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function ClearLavaOnly()
    log("[Salsz] PHASE 2: CLEAR LAVA EVEN LINE (Y24-Y52)")
    local MAX_GUARD = 50
    local loopGuard = 0
    local stillFound = true

    while stillFound and isRunning and loopGuard < MAX_GUARD do
        stillFound = false
        loopGuard = loopGuard + 1

        local tiles = getTiles()
        if not tiles then return end

        local lavaCounter = 0
        local skippedByStorage = false

        for _, tile in pairs(tiles) do
            if not isRunning then return end

            if tile.y < Y_MIN or tile.y > Y_MAX then goto continue end

            if tile.y % 2 == 0 and tile.fg == LavaID then
                stillFound = true
                lavaCounter = lavaCounter + 1

                -- Cek seed setiap 10 lava
                if lavaCounter % 10 == 0 then
                    if isSeedFull() then
                        log("[Salsz] Seed penuh mid-Phase 2, drop ke storage")
                        HandleStorageSeedDrop()
                        if not isRunning then return end
                        skippedByStorage = true
                        break
                    end
                end

                if FindSafePosition(tile.x, tile.y) then
                    local hit = 0
                    local cleared = false

                    while hit < MaxHit and isRunning do
                        local cek = getTile(tile.x, tile.y)
                        if not cek or cek.fg ~= LavaID then
                            cleared = true
                            break
                        end
                        BreakLava(tile.x, tile.y)
                        hit = hit + 1
                        AntiBounce()
                        AntiLava()
                    end

                    if not cleared then
                        log("[Salsz] FAIL CLEAR LAVA X=" .. tile.x .. " Y=" .. tile.y)
                    end
                else
                    log("[Salsz] NO SAFE POSITION X=" .. tile.x .. " Y=" .. tile.y)
                end
            end

            ::continue::
        end

        if skippedByStorage then
            loopGuard = loopGuard - 1
        end

        sleep(200)
    end
end

-- ============================================================
-- PHASE 3: PUT DIRT BOTTOM
-- ============================================================
local MAX_PUT_RETRY = 5

function BuildRow(yPos, startX, endX)
    local currentX = startX

    while currentX <= endX do
        if not isRunning then return false end

        local tile = getTile(currentX, yPos)
        local fg = tile and tile.fg or 0

        if fg == 2 or fg == 4 or fg == 10 then
            -- skip
        else
            if GetItemAmount(DirtBe) <= 0 then
                if not GoToStorageGetDirt() then
                    isRunning = false
                    return false
                end
            end

            if tryFindPath(currentX, yPos - 1) then
                local retry = 0
                while retry < MAX_PUT_RETRY and isRunning do
                    PutDirt(currentX, yPos)
                    sleep(150)
                    local recheck = getTile(currentX, yPos)
                    if recheck and recheck.fg == 2 then break end
                    retry = retry + 1
                end
            end

            if not isRunning then return false end
        end

        currentX = currentX + 1
    end
    return true
end

function RebuildDirt()
    log("[Salsz] PHASE 3: PUT DIRT BOTTOM")

    for _, y in ipairs(PlaceYList) do
        if not isRunning then return end
        if tryFindPath(PlaceXStart, y - 1) then
            sleep(500)
            BuildRow(y, PlaceXStart, PlaceXEnd)
        end
        if isRunning then sleep(400) end
    end
end

-- ============================================================
-- PHASE 4: PUT DIRT TOP
-- ============================================================
function PlaceDirtEmpty()
    log("[Salsz] PHASE 4: PUT DIRT TOP")

    for _, yPos in ipairs(PlaceYList4) do
        if not isRunning then return end

        local currentX = PlaceXStart4

        while currentX <= PlaceXEnd4 do
            if not isRunning then return end

            local tile = getTile(currentX, yPos)
            local fg = tile and tile.fg or 0

            if fg == 2 or fg == 4 or fg == 10 then
                -- skip
            else
                if GetItemAmount(DirtBe) <= 0 then
                    if not GoToStorageGetDirt() then
                        isRunning = false
                        return
                    end
                end

                if tryFindPath(currentX, yPos - 1) then
                    local retry = 0
                    while retry < MAX_PUT_RETRY and isRunning do
                        PutDirt(currentX, yPos)
                        sleep(P4PlaceD)
                        local recheck = getTile(currentX, yPos)
                        if recheck and recheck.fg == 2 then break end
                        retry = retry + 1
                    end
                end

                if not isRunning then return end
            end

            currentX = currentX + 1
        end

        if isRunning then sleep(100) end
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
function mainLoop()
    isThreadActive = true

    pcall(function()
        editToggle("Antibounce", true)
        editToggle("ModFly", true)
        editToggle("Fast Drop", true)
    end)

    log("[Salsz] Auto DF v39 Starting")

    while isRunning do
        local currentWorldName = DFWorldList[currentWorldIdx] or "?"

        log("[Salsz] ===== START CYCLE " .. currentWorldName .. " =====")

        findPathBlacklist = {}

        -- Baseline check di awal cycle
        HandleStorageSeedDrop()

        if isRunning then ClearDirtAndRock() end
        if isRunning then ClearLavaOnly() end
        if isRunning then RebuildDirt() end
        if isRunning then PlaceDirtEmpty() end

        log("[Salsz] ===== END CYCLE " .. currentWorldName .. " =====")

        if isRunning and #DFWorldList > 0 then
            currentWorldIdx = currentWorldIdx + 1
            if currentWorldIdx > #DFWorldList then
                currentWorldIdx = 1
            end

            if not warpToWorld(DFWorldList[currentWorldIdx]) then
                isRunning = false
                break
            end

            if not waitForWorldLoaded(5000) then
                break
            end
        end

        sleep(100)
    end

    StopAll()
end

log("[Salsz] Auto DF v39 Ready")
if growtopia and growtopia.notify then
    growtopia.notify("Salsz v39 READY")
end