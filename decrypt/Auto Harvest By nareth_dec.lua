-- ============================================
--  AUTO HARVEST + COLLECT KERAS + AUTO DROP
--  Growlauncher Module UI (Final Version)
-- ============================================

local config = {
    block_id     = 16,
    seed_id      = 17,
    gems_id      = 112,

    drop_x       = 0,
    drop_y       = 0,

    hit_count    = 2,
    delay_punch  = 140,
    path_delay   = 350,
    collect_delay= 280,
    loop_delay   = 200,

    max_block    = 180,
    max_seed     = 150,
    drop_amount  = 100,
}

local running = false
local status  = "Idle"

-- ====================== UTIL ======================
local function Log(msg)
    LogToConsole("[HarvestAC] " .. tostring(msg))
end

local function HumanSleep(ms)
    Sleep(ms + math.random(20, 50))
end

local function getPlayer()
    local ok, p = pcall(getLocal)
    if ok and p then return p end
    return nil
end

local function getPlayerTile()
    local p = getPlayer()
    if not p then return nil, nil end
    return math.floor(p.posX / 32), math.floor(p.posY / 32)
end

local function invCount(item_id)
    local ok, inv = pcall(getInventory)
    if not ok or type(inv) ~= "table" then return 0 end
    for _, item in pairs(inv) do
        if item.id == item_id then return item.amount end
    end
    return 0
end

local function safeGetObjects()
    local ok, objs = pcall(getObjectList)
    if ok and type(objs) == "table" then return objs end
    return nil
end

local function safeGetTiles()
    local ok, tiles = pcall(getTiles)
    if ok and type(tiles) == "table" then return tiles end
    return nil
end

local function isRelevantItem(itemid)
    return itemid == config.block_id or itemid == config.seed_id or itemid == config.gems_id
end

-- ====================== AKSI DASAR ======================
local function walkTo(tx, ty)
    FindPath(tx, ty)
    HumanSleep(config.path_delay)
end

local function punchTile(tx, ty)
    local p = getPlayer()
    if not p then return end
    sendPacketRaw(false, {
        type = 3,
        value = 18,
        x = p.posX,
        y = p.posY,
        px = tx,
        py = ty
    })
    HumanSleep(config.delay_punch)
end

local function dropItem(item_id, amount)
    if amount <= 0 then return false end
    local before = invCount(item_id)
    if before < amount then amount = before end
    if amount <= 0 then return false end

    walkTo(config.drop_x, config.drop_y)
    HumanSleep(config.path_delay)

    sendPacket(2, "action|drop\nitemID|" .. item_id)
    HumanSleep(250)
    sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. item_id .. "\ncount|" .. amount)
    HumanSleep(400)

    local after = invCount(item_id)
    if before - after >= amount then
        Log("Drop berhasil: " .. amount .. " (ID:" .. item_id .. ") | Sisa: " .. after)
        return true
    else
        Log("Drop gagal! ID:" .. item_id .. " | Sebelum:" .. before .. " | Sesudah:" .. after)
        return false
    end
end

local function doAutoDrop()
    local block_count = invCount(config.block_id)
    local seed_count  = invCount(config.seed_id)

    if block_count >= config.max_block then
        Log("Block penuh (" .. block_count .. "/" .. config.max_block .. ") → Drop")
        dropItem(config.block_id, config.drop_amount)
        return true
    end
    if seed_count >= config.max_seed then
        Log("Seed penuh (" .. seed_count .. "/" .. config.max_seed .. ") → Drop")
        dropItem(config.seed_id, config.drop_amount)
        return true
    end
    return false
end

-- ====================== COLLECT KERAS ======================
local function doCollectHard()
    local objects = safeGetObjects()
    if not objects then return end

    local targets = {}
    for _, obj in pairs(objects) do
        if isRelevantItem(obj.itemid) then
            local ox = math.floor(obj.pos.x / 32)
            local oy = math.floor(obj.pos.y / 32)
            table.insert(targets, {x = ox, y = oy})
        end
    end

    if #targets == 0 then return end

    for _, t in ipairs(targets) do
        if not running then return end

        FindPath(t.x, t.y)
        HumanSleep(config.collect_delay)

        -- Jalan 2x biar lebih keras keambil
        FindPath(t.x, t.y)
        HumanSleep(70)
    end
end

-- ====================== HARVEST + COLLECT LANGSUNG ======================
local function doHarvest()
    local tiles = safeGetTiles()
    if not tiles then return end

    local targets = {}
    for _, tile in pairs(tiles) do
        if tile.fg == config.seed_id and tile.readyharvest == true then
            table.insert(targets, {x = tile.x, y = tile.y})
        end
    end
    if #targets == 0 then return end

    table.sort(targets, function(a, b) return a.x < b.x end)
    local before = invCount(config.block_id)
    Log("Menemukan " .. #targets .. " tree siap harvest")

    for _, t in ipairs(targets) do
        if not running then return end

        -- Berdiri tepat di pohon
        walkTo(t.x, t.y)
        HumanSleep(100)

        -- Punch pohon
        for i = 1, config.hit_count do
            if not running then return end
            punchTile(t.x, t.y)
        end

        -- Langsung collect keras item yang baru jatuh
        HumanSleep(260)
        doCollectHard()
    end

    Log("Harvest + Collect selesai. Dapat: " .. (invCount(config.block_id) - before))
end

-- ====================== MAIN LOOP ======================
local function mainLoop()
    status = "Running"
    Log("Script dimulai | Drop Spot: (" .. config.drop_x .. "," .. config.drop_y .. ")")

    while running do
        doAutoDrop()
        if not running then break end

        doHarvest()
        if not running then break end

        HumanSleep(config.loop_delay)
    end

    status = "Stopped"
    Log("Script dihentikan")
end

-- ====================== UI MODULE ======================
local ui = UserInterface.new("AutoHarvestUI", "Agriculture")

ui:addLabelApp("AUTO HARVEST + COLLECT KERAS + DROP", "Agriculture")

ui:addInputInt("Block / Tree ID", tostring(config.block_id), "ID", "Masukkan ID", "Filter", "block_id")
ui:addInputInt("Drop X", tostring(config.drop_x), "X", "Koordinat X", "Place", "drop_x")
ui:addInputInt("Drop Y", tostring(config.drop_y), "Y", "Koordinat Y", "Place", "drop_y")

ui:addButton("Ambil Posisi Saat Ini", "btn_getpos")

ui:addDivider()

ui:addInputInt("Max Block (Auto Drop)", tostring(config.max_block), "Max", "Jika penuh → drop", "Inventory", "max_block")
ui:addInputInt("Max Seed (Auto Drop)", tostring(config.max_seed), "Max", "Jika penuh → drop", "Inventory", "max_seed")
ui:addInputInt("Jumlah Drop", tostring(config.drop_amount), "Qty", "Berapa yang di-drop", "Remove", "drop_amount")

ui:addDivider()
ui:addLabel("Delay Settings (ms)")

ui:addInputInt("Delay Punch", tostring(config.delay_punch), "ms", "Delay antar punch", "Timer", "delay_punch")
ui:addInputInt("Path Delay", tostring(config.path_delay), "ms", "Delay setelah jalan", "Timer", "path_delay")
ui:addInputInt("Collect Delay", tostring(config.collect_delay), "ms", "Delay saat collect", "Timer", "collect_delay")
ui:addInputInt("Loop Delay", tostring(config.loop_delay), "ms", "Delay antar cycle", "Timer", "loop_delay")

ui:addDivider()

ui:addToggle("START / STOP", false, "btn_start", false)

local json = ui:generateJSON()
addCategory("AutoHarvest", "Agriculture")
addIntoModule(json, "AutoHarvest")

-- ====================== HANDLER ======================
function OnValue(type, name, value)
    if name == "block_id" then
        config.block_id = tonumber(value) or 16
        config.seed_id  = config.block_id + 1
        Log("Block ID diubah ke " .. config.block_id)
    elseif name == "drop_x" then
        config.drop_x = tonumber(value) or 0
    elseif name == "drop_y" then
        config.drop_y = tonumber(value) or 0
    elseif name == "max_block" then
        config.max_block = tonumber(value) or 180
    elseif name == "max_seed" then
        config.max_seed = tonumber(value) or 150
    elseif name == "drop_amount" then
        config.drop_amount = tonumber(value) or 100
    elseif name == "delay_punch" then
        config.delay_punch = tonumber(value) or 140
    elseif name == "path_delay" then
        config.path_delay = tonumber(value) or 350
    elseif name == "collect_delay" then
        config.collect_delay = tonumber(value) or 280
    elseif name == "loop_delay" then
        config.loop_delay = tonumber(value) or 200
    elseif name == "btn_getpos" then
        local px, py = getPlayerTile()
        if px and py then
            config.drop_x = px
            config.drop_y = py
            editValue("drop_x", tostring(px))
            editValue("drop_y", tostring(py))
            Log("Drop Spot di-set ke (" .. px .. ", " .. py .. ")")
        else
            Log("Gagal ambil posisi player!")
        end
    elseif name == "btn_start" then
        if value == true then
            if config.block_id == 0 then
                Log("ERROR: Isi Block ID dulu!")
                editToggle("btn_start", false)
                return
            end
            if config.drop_x == 0 and config.drop_y == 0 then
                Log("ERROR: Set Drop Spot dulu!")
                editToggle("btn_start", false)
                return
            end
            running = true
            runThread(mainLoop)
        else
            running = false
            status = "Stopping..."
        end
    end
end

applyHook()

Log("Script AutoHarvest Final loaded!")