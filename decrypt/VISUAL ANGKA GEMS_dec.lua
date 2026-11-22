sendNotification("KILLYOURIDOL PROJECT")

local function getTotalGemsAtTile(x_tile, y_tile)
    local total_amount = 0

    if type(getObjectList()) == "table" then
        for _, obj in pairs(getObjectList()) do
            if obj.itemid == 112 then
                local tx = math.floor((obj.posX + 8) / 32)
                local ty = math.floor((obj.posY + 8) / 32)

                if tx == x_tile and ty == y_tile then
                    total_amount = total_amount + (obj.amount or 1)
                end
            end
        end
    end

    return total_amount
end

local function spawnGemsParticle(x_tile, y_tile, amount)
    local px = (x_tile * 32) + 16
    local py = (y_tile * 32) + 16

    if amount and amount > 0 then
        if type(sendPacketRaw) == "function" then
            sendPacketRaw(true, {
                type = 17,
                x = px,
                y = py,
                xspeed = 0,
                yspeed = 181,
                padding5 = math.floor(amount)
            })
        end
    end
end

local function triggerParticleAt(tx, ty, delay)
    runThread(function()
        sleep(delay or 100)
        local total = getTotalGemsAtTile(tx, ty)
        if total > 0 then
            spawnGemsParticle(tx, ty, total)
        end
    end)
end

addHook(function(pkt)
    if type(pkt) == "table" then
        if pkt.type == 0 then
            local tx = pkt.px or (pkt.x and math.floor(pkt.x / 32))
            local ty = pkt.py or (pkt.y and math.floor(pkt.y / 32))

            if tx and ty then
                triggerParticleAt(tx, ty, 80)
            end
        end
    end
    return false
end, "OnSendPacketRaw")

addHook(function(game)
    if type(game) == "table" then
        if game.type == 11 and game.value == 112 then
            triggerParticleAt(game.px, game.py, 100)
        elseif game.type == 14 then
            local tx = math.floor((game.x or 0) / 32)
            local ty = math.floor((game.y or 0) / 32)
            triggerParticleAt(tx, ty, 150)
        end
    end
    return false
end, "onGamePacket")
