--------------------------------------------------
-- AUTO SOIL FARM
-- By Anjela | GrowLauncher
--------------------------------------------------

local BLOCK_ID = 8772
local DELAY_PUT = 170

local TAKE_X = 97
local TAKE_Y = 52

--------------------------------------------------
-- NOTIFICATION
--------------------------------------------------

pcall(function()
    SendVariantList({
        [0] = "OnTextOverlay",
        [1] = "`2AUTO SOIL FARM BY ANJELA"
    })
end)

Sleep(1000)

--------------------------------------------------
-- UTILITIES
--------------------------------------------------

local function pos()
    return {
        x = GetLocal().posX // 32,
        y = GetLocal().posY // 32
    }
end

local function log(...)
    LogToConsole("`c[`9Auto Soil Farm By Anjela``]`9 >> `0" .. table.concat({...}, " : "))
end

local function randomSleep(base)
    Sleep(math.random(base, base + 50))
end

--------------------------------------------------
-- PLACE BLOCK
--------------------------------------------------

local function placeBlock(x, y)
    SendPacketRaw(false, {
        type = 3,
        value = BLOCK_ID,
        px = x,
        py = y,
        x = GetLocal().posX,
        y = GetLocal().posY
    })
end

--------------------------------------------------
-- PATHFIND
--------------------------------------------------

local function safePath(x, y)
    local dx = math.abs(pos().x - x)
    local dy = math.abs(pos().y - y)

    if dx > 2 or dy > 2 then
        FindPath(x, y)
        Sleep(math.random(55, 70))
    end
end

--------------------------------------------------
-- INVENTORY
--------------------------------------------------

local function getBlockCount()
    local inv = GetInventory()

    for _, item in ipairs(inv) do
        if item.id == BLOCK_ID then
            return item.count
        end
    end

    return 0
end

--------------------------------------------------
-- AUTO TAKE BLOCK
--------------------------------------------------

local function autoTakeBlock()
    FindPath(TAKE_X, TAKE_Y)
    Sleep(3000)

    Sleep(1000)
end

--------------------------------------------------
-- START
--------------------------------------------------

log("Auto Soil Farm Started")

--------------------------------------------------
-- MAIN
--------------------------------------------------

for y = 1, 52, 2 do
    for x = 1, 98 do

        local tile = GetTile(x, y)

        if tile.fg == 0 then

            while getBlockCount() == 0 do
                autoTakeBlock()
            end

            safePath(x, math.max(0, y - 1))

            placeBlock(x, y)
            randomSleep(DELAY_PUT)
        end
    end
end

--------------------------------------------------
-- FINISH
--------------------------------------------------

pcall(function()
    SendVariantList({
        [0] = "OnTextOverlay",
        [1] = "`2SOIL FARM COMPLETED!"
    })
end)

log("Auto Soil Farm Selesai!")