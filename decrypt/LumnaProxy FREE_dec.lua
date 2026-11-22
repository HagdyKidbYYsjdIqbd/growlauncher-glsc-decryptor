-------------------------------------
--Proxy Config
-------------------------------------

mode = "rgt" -- rgt / cps
fastdrop = false
realfake = false --bugged
stax = 16
betwl = 500
savew = "WorldName" --World Save
autocsn = true

-------------------------------------
--Don't Edit
-------------------------------------

Aount2 = 0
cgcek = 0
cgset = 25
systemlog = "`7[ `4lumna.proxy `7]`o "

-------------------------------------
--End of Define Section
-------------------------------------

logd = {}
conte = 0
x1 = 58
y1 = 24
x2 = 64
y2 = 24
earned = 0
Aount = betwl
lastGemLeft = 0
lastGemRight = 0
lastGemTotal = 0
modflai = "`4Disabled"
nmove = 1

-- Gem Scanner (alur /scangems + /setkiri /setkanan + /sh1-/sh6)
gemSetupSide = nil
gemPositions = {pos1 = {}, pos2 = {}}

-- =====================================
-- CASINO MODE + LOG SYSTEM
-- =====================================
gameMode = "csn" -- csn / reme / leme / qq
spinLogs = {}
gemsLogs = {}
lockLogs = {}
lastGemLogSig = nil
lastGemLogAt = 0
-- Aggregate raw gem pickups into one log entry, matching the +N Gems bubble.
pendingGemLogAmount = 0
pendingGemLogWorld = nil
lastCollectedLockSig = nil
lastCollectedLockAt = 0
lastRawLockObjectId = nil
lastRawLockObjectAt = 0
-- Dedupe spin events because GTPS can emit the same result through
-- both OnTalkBubble and OnConsoleMessage.
lastSpinLogSig = nil
lastSpinLogAt = 0
LOG_MAX = 100

local function pushLog(list, text)
    table.insert(list, 1, {time = os.date("%H:%M:%S"), world = GetWorldName(), text = tostring(text)})
    while #list > LOG_MAX do table.remove(list) end
end

local function flushPendingGemLog()
    local amount = tonumber(pendingGemLogAmount) or 0
    if amount <= 0 then return false end

    local world = pendingGemLogWorld or GetWorldName()
    local now = os.clock()
    local sig = tostring(amount) .. "|" .. tostring(world)
    if not (lastGemLogSig == sig and (now - (lastGemLogAt or 0)) < 0.5) then
        lastGemLogSig = sig
        lastGemLogAt = now
        local me = GetLocal()
        table.insert(gemsLogs, 1, {
            growid = (me and me.name) or "UNKNOWN",
            amount = amount,
            world = world,
            time = os.date("%H:%M:%S")
        })
        while #gemsLogs > LOG_MAX do table.remove(gemsLogs) end
    end

    pendingGemLogAmount = 0
    pendingGemLogWorld = nil
    return true
end

-- REME / LEME memakai penjumlahan digit yang sama seperti LumnaProxy V2.
-- Contoh: 36 -> 9, 29 -> 1, 28 -> 0, 10 -> 1, 20 -> 2, 30 -> 3.
local function calcRemeLike(num)
    local n = tostring(num or "")
    local sum = 0
    for digit in n:gmatch("%d") do
        sum = sum + tonumber(digit)
    end
    return sum % 10
end

local function calcQQ(num)
    local n = tonumber(num)
    if not n then return 0 end
    return math.floor(n) % 10
end

local function getModeResult(num)
    if gameMode == "reme" then return calcRemeLike(num), "REME" end
    if gameMode == "leme" then return calcRemeLike(num), "LEME" end
    if gameMode == "qq" then return calcQQ(num), "QQ" end
    return tonumber(num) or 0, "CSN"
end

local LOG_PAGE_SIZE = 100
local logPages = {spin = 1, gems = 1, lock = 1}

local function clampLogPage(page, total)
    page = tonumber(page) or 1
    local maxPage = math.max(1, math.ceil((tonumber(total) or 0) / LOG_PAGE_SIZE))
    if page < 1 then page = 1 end
    if page > maxPage then page = maxPage end
    return page, maxPage
end

local function addLogPagination(d, prefix, page, maxPage)
    d = d .. "\nadd_spacer|small|"
    if page > 1 then
        d = d .. "\nadd_button|"..prefix.."_prev|`wPrevious Page|noflags|"
    else
        d = d .. "\nadd_button|"..prefix.."_prev|`8Previous Page|off|"
    end
    if page < maxPage then
        d = d .. "\nadd_button|"..prefix.."_next|`wNext Page|noflags|"
    else
        d = d .. "\nadd_button|"..prefix.."_next|`8Next Page|off|"
    end
    d = d .. "\nadd_textbox|`7Page `9"..tostring(page).." `7/ `9"..tostring(maxPage).."|center|2440|"
    return d
end

local function showSimpleLog(title, list, clearId, page)
    local key = tostring(title):lower():find("spin",1,true) and "spin" or (tostring(title):lower():find("gems",1,true) and "gems" or "lock")
    local total = #list
    local maxPage
    page, maxPage = clampLogPage(page or logPages[key], total)
    logPages[key] = page

    local d = "set_default_color|`w|\nadd_quick_exit|"
    d = d .. "\nadd_label_with_icon|big|`wlumna.proxy `w- "..title.."|left|"..(key == "spin" and "5956" or "6016").."|"
    if key == "spin" then
        d = d .. "\nadd_textbox|`wLocal wheel history - max 100 entries.|left|2440|"
    elseif key == "gems" then
        d = d .. "\nadd_textbox|`wLocal Gems collection history|left|2440|"
    else
        d = d .. "\nadd_textbox|`wLocal Lock collection/drop history|left|2440|"
    end
    d = d .. "\nadd_spacer|small|"

    if total == 0 then
        d = d .. "\nadd_textbox|`9No "..key.." recorded yet.|left|2440|"
    else
        local first = (page - 1) * LOG_PAGE_SIZE + 1
        local last = math.min(page * LOG_PAGE_SIZE, total)
        local renderedSpinKeys = {}
        for i = first, last do
            local e = list[i]
            if e then
                if key == "spin" then
                    -- Normalisasi GrowID agar prefix UI selalu hanya SATU "[".
                    -- Beberapa event GTPS membawa [[GrowID]], [GrowID] atau warna.
                    local spinPlayer = tostring(e.player or "Unknown")
                    spinPlayer = spinPlayer:gsub("`.", "")
                    spinPlayer = spinPlayer:gsub("^%s+", ""):gsub("%s+$", "")
                    spinPlayer = spinPlayer:gsub("[%[%]<>]", "")
                    spinPlayer = spinPlayer:gsub("^%s+", ""):gsub("%s+$", "")
                    if spinPlayer == "" then spinPlayer = "Unknown" end

                    -- Dedupe tambahan di layer UI. Jadi record lama yang sudah
                    -- tersimpan dua kali tetap hanya tampil SATU kali.
                    local spinKey = spinPlayer .. "|" .. tostring(e.number or "?") .. "|" ..
                        tostring(e.world or "UNKNOWN") .. "|" .. tostring(e.time or "")
                    if not renderedSpinKeys[spinKey] then
                        renderedSpinKeys[spinKey] = true
                        d = d .. "\nadd_textbox|`9["..spinPlayer..
                            " `wspun the wheel got `9"..tostring(e.number or "?")..
                            "`9]`w("..tostring(e.world or "UNKNOWN").."),`9"..
                            tostring(e.time or "").."|left|2440|"
                    end
                elseif key == "gems" then
                    d = d .. "\nadd_textbox|`9"..tostring(e.growid or "UNKNOWN")..
                        " `wcollected `9"..tostring(e.amount or 0)..
                        " `wGems in `9"..tostring(e.world or "UNKNOWN")..
                        " `7["..tostring(e.time or "").."]|left|2440|"
                else
                    d = d .. "\nadd_textbox|`9"..tostring(e.time or "").." `w"..tostring(e.text or "")..
                        " `7("..tostring(e.world or "UNKNOWN")..")|left|2440|"
                end
            end
        end
    end

    d = addLogPagination(d, key.."log", page, maxPage)
    d = d .. "\nadd_spacer|small|"
    d = d .. "\nadd_button|"..clearId.."|`4Clear "..title.."|noflags|"
    d = d .. "\nadd_button|plog_back|`wBack|noflags|"
    d = d .. "\nend_dialog|"..key.."log||Close|"
    dialog(d)
end

local function showLogMenu()
    local d = "set_default_color|`w|\nadd_quick_exit|"
    d = d .. "\nadd_label_with_icon|big|`wlumna.proxy `w- LOGS|left|6016|"
    d = d .. "\nadd_textbox|`7Pilih jenis log yang ingin dilihat.|left|2440|"
    d = d .. "\nadd_spacer|small|"
    d = d .. "\nadd_button_with_icon|plog_gems|GEMS LOG|staticYellowFrame|112|"
    d = d .. "\nadd_button_with_icon|plog_lock|LOCK LOG|staticYellowFrame|242|"
    d = d .. "\nadd_button_with_icon|plog_spin|SPIN LOG|staticYellowFrame|758|"
    d = d .. "\nadd_button|plog_main|`wBack|noflags|"
    d = d .. "\nend_dialog|logmenu||Close|"
    dialog(d)
end

local function showModeMenu()
    local d = "set_default_color|`o\nadd_quick_exit|\nadd_label_with_icon|big|`wCasino Mode|left|758|\nadd_textbox|Current Mode: `9"..string.upper(gameMode).."|left|2440|\nadd_spacer|small|\nadd_button|mode_reme|`wREME|noflags|\nadd_button|mode_leme|`wLEME|noflags|\nadd_button|mode_qq|`wQQ|noflags|\nadd_button|mode_csn|`wCSN|noflags|\nadd_button|logback|`wBack|noflags|\nend_dialog|modemenu||Close|"
    dialog(d)
end


if GetWorldName() == "EXIT" then
table.insert(logd,"\nadd_label_with_icon|small|`wScript runned while not in a world|left|13806|\n")
else
table.insert(logd,"\nadd_label_with_icon|small|`wScript runned while in `2"..GetWorldName().."|left|13804|\n")
end
nameset = false
timer = os.date("%H:%M")
function inv(id)
for _, item in pairs(GetInventory()) do
if (item.id == id) then
return item.amount
end
end
return 0
end

-------------------------------------
--Start the Proxy
-------------------------------------

drop = 0

-------------------------------------
-- WRENCH / TILE INTERACTION
-- Wrench asli Growtopia = item ID 32.
-- Saat Wrench asli digunakan pada target: script meneruskan penggunaan Wrench TANPA teleport.
-- Jika GTPS mengirim dialog Door, script otomatis toggle checkbox akses lalu menekan OK.
local WRENCH_ID = 32
local wrenchTarget = {x = nil, y = nil}
local doorTarget = {x = nil, y = nil}
local forwardingWrench = false
local waitingWrenchDialog = false
local lastWrenchDialog = ""
local wrenchUseCount = 0
local doorAccessOpen = false

-- TELEPHONE AUTO BGL (Telephone block ID 3898)
local TELEPHONE_BLOCK_ID = 3898
local TELEPHONE_NUMBER = "53785"
local waitingTelephoneDialog = false
local telephoneStage = 0
local telephoneTarget = {x = nil, y = nil}

local function setWrenchTarget(x, y)
    x, y = tonumber(x), tonumber(y)
    if not x or not y then return false end
    wrenchTarget.x, wrenchTarget.y = x, y
    return true
end

local function setDoorTarget(x, y)
    x, y = tonumber(x), tonumber(y)
    if not x or not y then return false end
    doorTarget.x, doorTarget.y = x, y
    wrenchTarget.x, wrenchTarget.y = x, y
    return true
end

local function wrenchStatusText()
    if wrenchTarget.x and wrenchTarget.y then
        return "`2READY `7/ `9"..wrenchTarget.x..","..wrenchTarget.y
    end
    return "`4NO TARGET"
end

-- Wrench TIDAK melakukan teleport.
-- Teleport dipisahkan ke item ID 6336.
local TELEPORT_ID = 6336

local function teleportToTile(x, y)
    x, y = tonumber(x), tonumber(y)
    if not x or not y then return false end

    if type(FindPath) == "function" then
        FindPath(x, y)
    elseif type(path) == "function" then
        path(x, y)
    else
        ont("`4FindPath/path tidak tersedia")
        return false
    end

    Sleep(450)
    return true
end

local function sendWrenchPacket(x, y)
    x, y = tonumber(x), tonumber(y)
    if not x or not y then return false end

    local me = GetLocal()
    local mx = tonumber(me and me.posX) or (x * 32)
    local my = tonumber(me and me.posY) or (y * 32)

    forwardingWrench = true
    SendPacketRaw(false, {
        type = 3,
        value = WRENCH_ID,
        px = x,
        py = y,
        x = mx,
        y = my
    })
    forwardingWrench = false
    wrenchUseCount = wrenchUseCount + 1
    return true
end

-- LOCK AUTO-COLLECT
-- Saat player memukul tile ID 1422, otomatis ambil WL/DL/BGL yang sudah
-- berada di object list. Tidak ada FindPath/teleport yang dipanggil.
local LOCK_TRIGGER_ID = 1422
local WORLD_LOCK_ID = 242
local DIAMOND_LOCK_ID = 1796
local BLUE_GEM_LOCK_ID = 7188
local FIST_ID = 18

-- Forward declaration: collectLocksNoTeleport is defined before the UI/theme block.
-- This keeps every lock path connected to the same sendLockChat implementation.
local sendLockChat

local lockTriggerX, lockTriggerY = nil, nil

local lockCollectArmed = false
local lockCollectArmAt = 0

local function collectLocksNoTeleport(triggerX, triggerY)
    if type(GetObjectList) ~= "function" then return 0 end
    lockTriggerX = tonumber(triggerX)
    lockTriggerY = tonumber(triggerY)
    if not lockTriggerX or not lockTriggerY then return 0 end

    local collected = 0
    local totals = {[WORLD_LOCK_ID]=0,[DIAMOND_LOCK_ID]=0,[BLUE_GEM_LOCK_ID]=0}
    for _, obj in pairs(GetObjectList()) do
        local itemid = tonumber(obj.itemid)
        if itemid == WORLD_LOCK_ID or itemid == DIAMOND_LOCK_ID or itemid == BLUE_GEM_LOCK_ID then
            local ox = tonumber(obj.posX) or 0
            local oy = tonumber(obj.posY) or 0
            local tx = math.floor(ox / 32)
            local ty = math.floor(oy / 32)
            if tx == lockTriggerX and ty == lockTriggerY then
                local amount = tonumber(obj.amount) or 0
                if amount > 0 then
                    totals[itemid] = (totals[itemid] or 0) + amount
                    SendPacketRaw(false, {type=11, value=tonumber(obj.id), px=tx, py=ty, x=ox, y=oy})
                    collected = collected + amount
                end
            end
        end
    end

    if collected > 0 then
        -- Public text/log dihitung dari object yang BENAR-BENAR berada di tile 1422.
        -- Jangan ambil atau hitung lock dari tile lain.
        -- Jangan kirim teks Collected dari sisi client di sini.
        -- Server akan mengirim OnConsoleMessage "Collected ..." dan handler
        -- di bawah akan menampilkannya tepat satu kali.
        log("`2Auto Take Lock: `9"..collected.." `2at tile `9"..lockTriggerX..","..lockTriggerY)
    end
    return collected
end

local function handleLockTrigger(raw)
    if not raw or type(GetTile) ~= "function" then return false end
    if tonumber(raw.type) ~= 3 then return false end

    local useID = tonumber(raw.value or raw.int_data)
    if useID ~= FIST_ID then return false end

    local x = tonumber(raw.px or raw.int_x)
    local y = tonumber(raw.py or raw.int_y)
    if not x or not y then return false end

    local tile = GetTile(x, y)
    local fg = tonumber(tile and (tile.fg or tile.foreground or tile.id))
    if fg ~= LOCK_TRIGGER_ID then return false end

    -- HANYA punch pada tile ID 1422 yang boleh mengaktifkan auto-collect.
    -- Tidak ada FindPath/teleport dan tidak ada pencarian lock di tile lain.
    lockCollectArmed = true
    lockCollectArmAt = os.clock()
    Sleep(150)
    collectLocksNoTeleport(x, y)
    return false
end

-- ID 6336 menjadi jalur teleport terpisah dari Wrench.
-- Saat item 6336 digunakan pada tile, player dipindahkan ke tile tersebut.
local function handleTeleportUse(raw)
    if not raw or tonumber(raw.type) ~= 3 then return false end
    local useID = tonumber(raw.value or raw.int_data)
    if useID ~= TELEPORT_ID then return false end

    local x = tonumber(raw.px or raw.int_x)
    local y = tonumber(raw.py or raw.int_y)
    if not x or not y then return false end

    teleportToTile(x, y)
    return true
end

-- AUTO TELEPHONE -> SALES-MAN -> BLUE GEM LOCK -> THANK YOU -> HANG UP.
-- Ini hanya aktif bila Wrench dipakai pada Telephone block ID 3898.
local function getButtonByLabel(dialogText, needles)
    if type(dialogText) ~= "string" then return nil end
    local fallback = nil
    for line in dialogText:gmatch("[^\n]+") do
        local id, label = line:match("^add_button|([^|]+)|([^|]*)|")
        if id and label then
            local item = {id = id, label = label}
            if not fallback then fallback = item end
            local low = label:lower()
            for _, needle in ipairs(needles) do
                if low:find(needle, 1, true) then
                    return item
                end
            end
        end
    end
    return nil
end

local function getTelephoneXY(dialogText)
    local x = tonumber(dialogText:match("embed_data|x|(%-?%d+)"))
        or tonumber(dialogText:match("x|(%-?%d+)|"))
        or telephoneTarget.x
    local y = tonumber(dialogText:match("embed_data|y|(%-?%d+)"))
        or tonumber(dialogText:match("y|(%-?%d+)|"))
        or telephoneTarget.y
    return x, y
end

local function sendTelephoneReturn(dialogText, buttonId, extra)
    local x, y = getTelephoneXY(dialogText)
    local payload = "action|dialog_return\n"..
        "dialog_name|telephone\n"..
        "num|"..TELEPHONE_NUMBER.."|\n"..
        "x|"..tostring(x or 0).."|\n"..
        "y|"..tostring(y or 0).."|\n"..
        (extra or "")..
        "buttonClicked|"..buttonId
    SendPacket(2, payload)
    return true
end

local function isTelephoneDialog(d)
    if type(d) ~= "string" then return false end
    local low = d:lower()
    return low:find("dialog_name|telephone", 1, true)
        or low:find("dialog_name|3898", 1, true) ~= nil
        or low:find("telephone", 1, true) ~= nil
end

local function findTelephoneButton(dialogText, patterns)
    if type(dialogText) ~= "string" then return nil end
    for line in dialogText:gmatch("[^\n]+") do
        local id, label = line:match("^add_button|([^|]+)|([^|]*)|")
        if id then
            local low = (label or ""):lower()
            for _, pat in ipairs(patterns) do
                if low:find(pat, 1, true) then
                    return id
                end
            end
        end
    end
    return nil
end

local function telephoneHasButton(dialogText, id)
    return type(dialogText) == "string" and dialogText:find("add_button|"..id.."|", 1, true) ~= nil
end

local function sendTelephoneButton(d, buttonId)
    local x, y = getTelephoneXY(d)
    local payload = "action|dialog_return\n"..
        "dialog_name|telephone\n"..
        "num|"..TELEPHONE_NUMBER.."|\n"..
        "x|"..tostring(x or 0).."|\n"..
        "y|"..tostring(y or 0).."|\n"..
        "buttonClicked|"..buttonId.."\n"
    SendPacket(2, payload)
end

local function autoTelephone(d)
    if not waitingTelephoneDialog or not isTelephoneDialog(d) then return false end

    local low = d:lower()
    local x, y = getTelephoneXY(d)
    if x and y then telephoneTarget.x, telephoneTarget.y = x, y end

    -- Stage 0: Telephone number screen. Set 53785 and press the actual
    -- call/submit button if the server exposes one.
    if telephoneStage == 0 then
        telephoneStage = 1
        -- Most GTPS Telephone implementations use buttonClicked|call.
        sendTelephoneButton(d, "call")
        return true
    end

    -- Stage 1: Sales-Man menu. Prefer the real button ID from the dialog.
    if telephoneStage == 1 then
        local bglId = findTelephoneButton(d, {"blue gem lock", "blue gem lock", "bgl"})
        if bglId then
            telephoneStage = 2
            sendTelephoneButton(d, bglId)
            return true
        end

        -- Common GTPS button ID from Sales-Man dialog source.
        if telephoneHasButton(d, "chc2_1") or low:find("blue gem lock", 1, true) then
            telephoneStage = 2
            sendTelephoneButton(d, "chc2_1")
            return true
        end
    end

    -- Stage 2: purchase/confirmation dialog. Click Thank you! only when
    -- the server actually exposes that button.
    if telephoneStage == 2 then
        local thanksId = findTelephoneButton(d, {"thank you!", "thank you", "thanks"})
        if thanksId then
            telephoneStage = 3
            sendTelephoneButton(d, thanksId)
            return true
        end

        -- Some GTPS implementations use a confirmation button with a
        -- different ID but the dialog text still contains Thank you.
        if low:find("thank you", 1, true) then
            local any = findTelephoneButton(d, {"ok", "continue", "confirm"})
            if any then
                telephoneStage = 3
                sendTelephoneButton(d, any)
                return true
            end
        end
    end

    -- Stage 3: Hang Up. Use the real ID when present; otherwise common
    -- Telephone dialog ID is hangup.
    if telephoneStage == 3 then
        local hangId = findTelephoneButton(d, {"hang up", "hangup", "hang up!"})
        if not hangId then
            if telephoneHasButton(d, "hangup") then
                hangId = "hangup"
            elseif telephoneHasButton(d, "close") then
                hangId = "close"
            end
        end
        if hangId then
            sendTelephoneButton(d, hangId)
        else
            -- Server source commonly declares end_dialog|3898|Hang Up||
            SendPacket(2, "action|dialog_return\n"..
                "dialog_name|3898\n"..
                "buttonClicked|hangup\n")
        end
        waitingTelephoneDialog = false
        telephoneStage = 0
        telephoneTarget.x, telephoneTarget.y = nil, nil
        ont("`2Telephone: `9Sales-Man 53785 -> Blue Gem Lock -> Thank you -> Hang Up")
        return true
    end

    return true
end

-- Dipanggil saat player benar-benar memakai Wrench dari inventory.
-- Tidak ada punch/command/tombol menu: target langsung diambil dari packet Wrench,
-- player diteleport/path ke target, kemudian Wrench dikirim ulang.
function handleWrenchUse(raw)
    if forwardingWrench or not raw then return false end

    local packetType = tonumber(raw.type)
    local itemValue = tonumber(raw.value or raw.int_data)
    if packetType ~= 3 or itemValue ~= WRENCH_ID then
        return false
    end

    local x = tonumber(raw.px or raw.int_x)
    local y = tonumber(raw.py or raw.int_y)
    if not x or not y then return false end

    -- Telephone (block ID 3898) memiliki alur sendiri dan TIDAK menyentuh
    -- state close/open Door. Wrench item tetap ID 32.
    local targetIsTelephone = false
    if type(GetTile) == "function" then
        local tile = GetTile(x, y)
        local fg = tonumber(tile and (tile.fg or tile.foreground or tile.id))
        targetIsTelephone = (fg == TELEPHONE_BLOCK_ID)
    end

    if targetIsTelephone then
        telephoneTarget.x, telephoneTarget.y = x, y
        waitingTelephoneDialog = true
        telephoneStage = 0
    else
        setWrenchTarget(x, y)
        setDoorTarget(x, y)
        waitingWrenchDialog = true
    end

    -- Wrench sekarang TIDAK teleport. Kirim ulang packet Wrench dengan
    -- koordinat player saat ini sehingga interaksi Door tetap berasal dari
    -- posisi asli player.
    local me = GetLocal()
    local forwarded = {}
    for k, v in pairs(raw) do forwarded[k] = v end
    if me then
        forwarded.x = tonumber(me.posX) or forwarded.x
        forwarded.y = tonumber(me.posY) or forwarded.y
        forwarded.pos_x = tonumber(me.posX) or forwarded.pos_x
        forwarded.pos_y = tonumber(me.posY) or forwarded.pos_y
    end

    forwardingWrench = true
    SendPacketRaw(false, forwarded)
    forwardingWrench = false
    wrenchUseCount = wrenchUseCount + 1
    return true
end

-- Cari tombol akses dari dialog GTPS yang benar-benar diterima.
-- Setiap penggunaan Wrench = toggle akses Door:
-- OPEN -> CLOSED, CLOSED -> OPEN.
-- ID tombol tidak di-hardcode; script membaca ID + label yang dikirim GTPS.
-- Baca checkbox Door/Forcefield langsung dari dialog GTPS.
-- Contoh dialog pada screenshot:
-- add_checkbox|<id>|Usable by public|0|
-- 0 = tidak dicentang (akses tertutup), 1 = dicentang (akses terbuka).
local function getDoorCheckbox(dialogText)
    if type(dialogText) ~= "string" then return nil end

    -- GTPS biasanya mengirim checkbox seperti:
    -- add_checkbox|<checkbox_id>|Usable by public|0|
    -- atau nama/label bisa berbeda. Ambil semua checkbox dan prioritaskan
    -- checkbox yang berhubungan dengan public/access.
    local firstCheckbox = nil

    for line in dialogText:gmatch("[^\n]+") do
        local id, label, state = line:match("^add_checkbox|([^|]+)|([^|]*)|([01])|?")
        if id then
            local item = {
                id = id,
                label = label or "",
                state = tonumber(state) or 0
            }
            if not firstCheckbox then firstCheckbox = item end

            local lowLabel = item.label:lower()
            local lowId = item.id:lower()
            if lowLabel:find("usable by public", 1, true)
                or lowLabel:find("public", 1, true)
                or lowLabel:find("access", 1, true)
                or lowLabel:find("usable", 1, true)
                or lowId:find("public", 1, true)
                or lowId:find("access", 1, true) then
                return item
            end
        end
    end

    return firstCheckbox
end

local function getDialogName(dialogText)
    if type(dialogText) ~= "string" then return nil end

    -- OnDialogRequest biasanya TIDAK mempunyai dialog_name|...
    -- Nama dialog justru ada pada end_dialog|<name>|Cancel|OK|.
    local name = dialogText:match("end_dialog|([^|\n]+)|")
    if name and name ~= "" then return name end

    -- Beberapa GTPS memakai dialog_name di isi dialog.
    name = dialogText:match("dialog_name|([^|\n]+)")
    if name and name ~= "" then return name end

    return nil
end

local function getDialogTile(dialogText, fallbackX, fallbackY)
    if type(dialogText) ~= "string" then return fallbackX, fallbackY end

    local x = tonumber(dialogText:match("embed_data|tilex|(%-?%d+)"))
        or tonumber(dialogText:match("tilex|(%-?%d+)"))
    local y = tonumber(dialogText:match("embed_data|tiley|(%-?%d+)"))
        or tonumber(dialogText:match("tiley|(%-?%d+)"))

    return x or fallbackX, y or fallbackY
end

local function sendDoorDialogReturn(dialogText, checkbox, newState)
    local dialogName = getDialogName(dialogText)
    if not dialogName or not checkbox then
        log("`4Wrench Door: dialog name/checkbox tidak ditemukan")
        return false
    end

    local tx, ty = getDialogTile(dialogText, wrenchTarget.x, wrenchTarget.y)

    -- Sertakan tilex/tiley bila tersedia/tersimpan. Ini penting pada banyak
    -- GTPS karena server memvalidasi target Door dari koordinat dialog.
    local payload =
        "action|dialog_return\n"..
        "dialog_name|"..dialogName.."\n"..
        "tilex|"..tostring(tx or 0).."\n"..
        "tiley|"..tostring(ty or 0).."\n"..
        checkbox.id.."|"..tostring(newState).."\n"..
        "buttonClicked|ok\n"

    SendPacket(2, payload)
    return true
end

local function autoDoorAccess(dialogText)
    if type(dialogText) ~= "string" then return false end

    local low = dialogText:lower()
    local checkbox = getDoorCheckbox(dialogText)
    if not checkbox then return false end

    -- Hanya proses dialog Door/Forcefield/access.
    if not low:find("door", 1, true)
        and not low:find("forcefield", 1, true)
        and not low:find("usable by public", 1, true)
        and not low:find("access", 1, true)
        and not low:find("public", 1, true) then
        return false
    end

    -- Toggle berdasarkan keadaan checkbox yang benar-benar dikirim server:
    -- 0 -> 1 = centang / buka akses
    -- 1 -> 0 = hapus centang / tutup akses
    local currentState = (tonumber(checkbox.state) == 1) and 1 or 0
    local newState = (currentState == 1) and 0 or 1

    if not sendDoorDialogReturn(dialogText, checkbox, newState) then
        return false
    end

    doorAccessOpen = (newState == 1)
    waitingWrenchDialog = false

    if doorAccessOpen then
        ont("`2WRENCH DOOR: CHECK ON + OK `7-> ACCESS OPEN")
    else
        ont("`4WRENCH DOOR: CHECK OFF + OK `7-> ACCESS CLOSED")
    end

    log("`2Wrench Door: "..checkbox.id.." "..currentState.." -> "..newState.." + OK")
    return true
end


-- Command tetap tersedia tanpa menambah tombol menu.
local function setDoorAccess(open)
    if not wrenchTarget.x or not wrenchTarget.y then
        ont("`4Gunakan Wrench pada Door terlebih dahulu.")
        return false
    end
    doorAccessOpen = not open
    waitingWrenchDialog = true
    return autoDoorAccess(lastWrenchDialog)
end


-- =====================================
-- BGL / DL / WL SMART DROP
-- /bgl 15/2*3  -> 22 BGL + 50 DL
-- Jika DL kurang, 1 BGL otomatis dipecah menjadi 100 DL.
-- /wl 150       -> 1 DL + 50 WL
-- Jika DL kurang, BGL otomatis dipecah menjadi DL.
-- Jika WL kurang, DL otomatis dipecah menjadi WL.
-- =====================================
local BGL_ID = 7188
local DL_ID  = 1796
local WL_ID  = 242

local function evalMoneyExpr(expr)
    if type(expr) ~= "string" then return nil end
    expr = expr:gsub("%s+", "")
    if expr == "" or not expr:match("^[%d%+%-%*/%(%)%.]+$") then return nil end
    -- Safe arithmetic evaluator: only numbers/operators/parentheses.
    local fn = load("return ("..expr..")")
    if not fn then return nil end
    local ok, result = pcall(fn)
    if not ok or type(result) ~= "number" or result ~= result or result == math.huge or result == -math.huge then
        return nil
    end
    return result
end

local function dropCurrency(id, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    local have = inv(id)
    if have < amount then return false end
    rdrop(id, amount)
    Sleep(120)
    return true
end

local function smartDropBGL(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    amount = math.floor(amount * 100 + 0.5) -- BGL decimal -> DL

    local bgl = math.floor(amount / 100)
    local dl  = amount % 100

    -- Pecahkan BGL bila DL yang dibutuhkan lebih banyak daripada DL yang ada.
    local haveBGL = inv(BGL_ID)
    local haveDL  = inv(DL_ID)
    local needBGL = bgl

    if dl > haveDL then
        local deficit = dl - haveDL
        local extraBGL = math.ceil(deficit / 100)
        if haveBGL < needBGL + extraBGL then
            ont("`4BGL tidak cukup untuk konversi DL.")
            return false
        end
        needBGL = needBGL + extraBGL
        dl = dl + extraBGL * 100
    end

    -- Drop BGL yang memang menjadi bagian utama.
    if bgl > 0 then
        if haveBGL < bgl then
            ont("`4BGL tidak cukup.")
            return false
        end
        dropCurrency(BGL_ID, bgl)
        sendLockChat("drop",BGL_ID,bgl)
    end

    -- Jika perlu, pecah BGL tambahan menjadi DL dengan dialog exchange.
    local extra = needBGL - bgl
    if extra > 0 then
        -- Exchange 1 BGL -> 100 DL.
        for i = 1, extra do
            SendPacket(2, "action|dialog_return\ndialog_name|bgl_exchange\nbuttonClicked|exchange\n")
            Sleep(180)
        end
        -- Setelah exchange, drop DL sesuai kebutuhan.
        haveDL = inv(DL_ID)
    end

    local remainingDL = math.min(dl, inv(DL_ID))
    if remainingDL > 0 then
        dropCurrency(DL_ID, remainingDL)
        sendLockChat("drop",DL_ID,remainingDL)
    end

    ont("`2DROP BGL: `9"..bgl.." BGL `7+ `9"..(remainingDL or 0).." DL")
    return true
end

local function exchangeBGLToDL(count)
    count = math.floor(tonumber(count) or 0)
    if count <= 0 or inv(BGL_ID) < count then return false end
    for i = 1, count do
        SendPacket(2, "action|dialog_return\ndialog_name|bgl_exchange\nbuttonClicked|exchange\n")
        Sleep(220)
    end
    return inv(DL_ID) > 0
end

local function exchangeDLToWL(count)
    count = math.floor(tonumber(count) or 0)
    if count <= 0 or inv(DL_ID) < count then return false end
    for i = 1, count do
        SendPacket(2, "action|dialog_return\ndialog_name|dl_exchange\nbuttonClicked|exchange\n")
        Sleep(180)
    end
    return inv(WL_ID) > 0
end

local function smartDropDL(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end

    -- 100 WL = 1 DL. Example: /wl 150 = 1 DL + 50 WL.
    local needDL = math.floor(amount / 100)
    local needWL = amount % 100
    local haveDL, haveWL = inv(DL_ID), inv(WL_ID)

    if haveWL < needWL then
        local deficitWL = needWL - haveWL
        local dlToWL = math.ceil(deficitWL / 100)
        local totalDL = needDL + dlToWL

        if haveDL < totalDL then
            local missingDL = totalDL - haveDL
            local bglNeeded = math.ceil(missingDL / 100)
            if inv(BGL_ID) < bglNeeded then
                ont("`4DL/WL tidak cukup.")
                return false
            end
            exchangeBGLToDL(bglNeeded)
        end
        if inv(DL_ID) < totalDL then
            ont("`4DL tidak cukup untuk konversi WL.")
            return false
        end
        exchangeDLToWL(dlToWL)
    end

    if needDL > 0 then
        if inv(DL_ID) < needDL then return false end
        dropCurrency(DL_ID, needDL)
        sendLockChat("drop",DL_ID,needDL)
        Sleep(150)
    end
    if needWL > 0 then
        if inv(WL_ID) < needWL then return false end
        dropCurrency(WL_ID, needWL)
        sendLockChat("drop",WL_ID,needWL)
    end
    ont("`2DROP: `9"..needDL.." DL `7+ `9"..needWL.." WL")
    return true
end

local function handleMoneyCommand(packet)
    if type(packet) ~= "string" then return false end
    local cmdText = packet:match("|text|(/%S+%s*[^|\n]*)")
    if not cmdText then return false end

    local command, expr = cmdText:match("^(%/%w+)%s+(.+)$")
    if not command or not expr then return false end
    command = command:lower()

    if command == "/bgl" then
        local value = evalMoneyExpr(expr)
        if not value or value < 0 then
            ont("`4Format: /bgl 15/2*3")
            return true
        end
        return smartDropBGL(value)
    elseif command == "/wl" then
        local value = evalMoneyExpr(expr)
        if not value or value < 0 then
            ont("`4Format: /wl 150 atau /wl 7/2*3")
            return true
        end
        return smartDropDL(value)
    end

    return false
end

drop = 0
-- Public message controls. Declared before command handlers so /prefix works globally.
prefixText = "`5[lumna.`9proxy`5] `w"
showTextPrefix = true
local function extractChatCommand(packet)
    if type(packet)~="string" then return nil,nil end
    local text=packet:match("|text|([^\n|]+)")
    if not text then return nil,nil end
    text=tostring(text):gsub("^%s+",""):gsub("%s+$","")
    local command,args=text:match("^(%/%S+)%s*(.*)$")
    return command and command:lower() or nil,args or ""
end
local function handlePrefixCommand(packet)
    local command,args=extractChatCommand(packet)
    if command=="/prefix" or command=="/preflix" then
        args=tostring(args or ""):gsub("^%s+",""):gsub("%s+$","")
        if args=="" then
            LogToConsole("Current prefix: "..tostring(prefixText or ""))
        else
            -- Keep the exact text supplied by the user, including Growtopia color codes.
            prefixText=args
            showTextPrefix=true
            LogToConsole("Prefix changed to: "..tostring(prefixText))
        end
        return true
    elseif command=="/showteks" then
        local v=tostring(args or ""):lower():match("^(%S+)")
        if v=="on" or v=="1" or v=="true" then
            showTextPrefix=true
        elseif v=="off" or v=="0" or v=="false" then
            showTextPrefix=false
        else
            showTextPrefix=not showTextPrefix
        end
        LogToConsole("SHOWTEKS: "..(showTextPrefix and "ON - Collected/Dropped/Gems ditampilkan" or "OFF - Collected/Dropped/Gems disembunyikan"))
        return true
    end
    return false
end
local wrenchMode = ""

-- Player wrench handler.
-- Pull/Kick/World Ban memakai alur packet popup GTPS yang sama dengan
-- tombol Wrench asli: action|wrench -> dialog_return|popup.
-- Jangan memakai EditToggle/Fast Wrench karena API itu berbeda antar runtime.
local function handleWrenchPlayerCommand(packet)
    if type(packet) ~= "string" or wrenchMode == "" then return false end

    local low = packet:lower()
    if not low:find("action|wrench", 1, true) then return false end

    -- GrowLauncher/GTPS umumnya mengirim:
    -- action|wrench\n|netid|123
    -- Beberapa runtime menghilangkan slash sebelum netid atau memakai netID.
    local netid = tonumber(packet:match("action|wrench%s*\n?%s*|?netid|(%d+)"))
        or tonumber(packet:match("|netid|(%d+)"))
        or tonumber(packet:match("|netID|(%d+)"))
        or tonumber(packet:match("|net_id|(%d+)"))
    if not netid then return false end

    local me = GetLocal()
    local myNetID = tonumber(me and (me.netID or me.netid))
    if myNetID and myNetID == netid then return false end

    local action
    if wrenchMode == "PULL" then
        action = "pull"
    elseif wrenchMode == "KICK" then
        action = "kick"
    elseif wrenchMode == "BAN" then
        action = "world_ban"
    else
        return false
    end

    -- This is the native GTPS popup-return path used by the Wrench UI.
    local payload = "action|dialog_return\n"..
        "dialog_name|popup\n"..
        "netID|"..tostring(netid).."|\n"..
        "buttonClicked|"..action

    local ok, sent = pcall(function()
        SendPacket(2, payload)
        return true
    end)
    if not ok or not sent then
        LogToConsole("`4[lumna.`9proxy`4] Wrench "..wrenchMode.." gagal mengirim packet.")
        return false
    end

    local targetName = "netID "..tostring(netid)
    if type(GetPlayerList) == "function" then
        pcall(function()
            for _, player in pairs(GetPlayerList()) do
                local pid = tonumber(player.netID or player.netid)
                if pid == netid then
                    targetName = tostring(player.name or player.displayName or targetName)
                    break
                end
            end
        end)
    end

    local label = (wrenchMode == "BAN") and "WORLD BAN" or wrenchMode
    LogToConsole("`5[lumna.`9proxy`5] `w"..label.." -> `9"..targetName)
    ont("`2Wrench "..label.." -> `9"..targetName)
    return true
end

-- Direct world warp. This intentionally uses the normal join_request packet
-- and does NOT use any handwarp command.
local function handleWarpCommand(packet)
    if type(packet) ~= "string" then return false end
    local text = packet:match("|text|([^\n|]+)")
    if not text then return false end
    local world = text:match("^%s*/warp%s+([^%s]+)%s*$")
    if not world or world == "" then return false end
    world = tostring(world):gsub("[^%w_%-]", "")
    if world == "" then return true end
    pcall(function()
        SendPacket(3, "action|join_request\nname|"..world.."\ninvitedWorld|0")
    end)
    LogToConsole("`5[lumna.`9proxy`5] `wWarp -> "..world)
    return true
end

function on_sendpacket(str, packet)
    if handleWarpCommand(packet) then return true end
    if handleWrenchPlayerCommand(packet) then return true end
    if handlePrefixCommand(packet) then return true end
    if handleMoneyCommand(packet) then return true end


    -- ============================================================
    -- LOG UI HANDLERS (single source of truth)
    -- Unique button IDs prevent collisions with other menus.
    -- ============================================================
    local logPacket = (type(packet) == "string" and packet) or (type(str) == "string" and str) or nil

    if logPacket then
        if logPacket:find("buttonClicked|logs", 1, true) then
            showLogMenu()
            return true
        elseif logPacket:find("buttonClicked|plog_spin", 1, true) then
            logPages.spin = 1
            showSimpleLog("SPIN LOG", spinLogs, "clear_spinlog", 1)
            return true
        elseif logPacket:find("buttonClicked|plog_gems", 1, true) then
            logPages.gems = 1
            showSimpleLog("GEMS LOG", gemsLogs, "clear_gemslog", 1)
            return true
        elseif logPacket:find("buttonClicked|plog_lock", 1, true) then
            logPages.lock = 1
            showSimpleLog("LOCK LOG", lockLogs, "clear_locklog", 1)
            return true
        elseif logPacket:find("buttonClicked|plog_back", 1, true) then
            showLogMenu()
            return true
        elseif logPacket:find("buttonClicked|plog_main", 1, true) then
            if mmenu then
                dialog(mmenu)
            end
            return true
        elseif logPacket:find("buttonClicked|clear_spinlog", 1, true) then
            spinLogs = {}
            logPages.spin = 1
            showSimpleLog("SPIN LOG", spinLogs, "clear_spinlog", 1)
            return true
        elseif logPacket:find("buttonClicked|clear_gemslog", 1, true) then
            gemsLogs = {}
            logPages.gems = 1
            showSimpleLog("GEMS LOG", gemsLogs, "clear_gemslog", 1)
            return true
        elseif logPacket:find("buttonClicked|clear_locklog", 1, true) then
            lockLogs = {}
            logPages.lock = 1
            showSimpleLog("LOCK LOG", lockLogs, "clear_locklog", 1)
            return true
        elseif logPacket:find("buttonClicked|lognext_spin", 1, true) then
            logPages.spin = (logPages.spin or 1) + 1
            showSimpleLog("SPIN LOG", spinLogs, "clear_spinlog", logPages.spin)
            return true
        elseif logPacket:find("buttonClicked|logprev_spin", 1, true) then
            logPages.spin = math.max(1, (logPages.spin or 1) - 1)
            showSimpleLog("SPIN LOG", spinLogs, "clear_spinlog", logPages.spin)
            return true
        elseif logPacket:find("buttonClicked|lognext_gems", 1, true) then
            logPages.gems = (logPages.gems or 1) + 1
            showSimpleLog("GEMS LOG", gemsLogs, "clear_gemslog", logPages.gems)
            return true
        elseif logPacket:find("buttonClicked|logprev_gems", 1, true) then
            logPages.gems = math.max(1, (logPages.gems or 1) - 1)
            showSimpleLog("GEMS LOG", gemsLogs, "clear_gemslog", logPages.gems)
            return true
        elseif logPacket:find("buttonClicked|lognext_lock", 1, true) then
            logPages.lock = (logPages.lock or 1) + 1
            showSimpleLog("LOCK LOG", lockLogs, "clear_locklog", logPages.lock)
            return true
        elseif logPacket:find("buttonClicked|logprev_lock", 1, true) then
            logPages.lock = math.max(1, (logPages.lock or 1) - 1)
            showSimpleLog("LOCK LOG", lockLogs, "clear_locklog", logPages.lock)
            return true
        end
    end

inpuc0o1 = "action|input\n|text|"

function cmd(str)
if packet:find(inpuc0o1 .. str) then
match = packet:match(inpuc0o1 .. str)
return true
end
end

function ont(teks)
v = {}
v.v1 = "OnTextOverlay"
v.v2 = teks
SendVariant(v)
end

-------------------------------------
-------------------------------------
-- LUMNA.PROXY UI THEME
-- Global UI theme for proxy-generated dialogs.
-- Background format: R,G,B,Alpha
-- Text color uses Growtopia color code: `w, `2, `9, etc.
-------------------------------------
local uiTheme = {
    bg = "18,18,28,245",
    text = "`w",
    accent = "`9"
}

local uiBgPresets = {
    ["ui_bg_black"]="0,0,0,245", ["ui_bg_dark"]="18,18,28,245", ["ui_bg_gray"]="45,45,50,245", ["ui_bg_slate"]="28,38,48,245",
    ["ui_bg_blue"]="12,28,55,245", ["ui_bg_navy"]="8,18,42,245", ["ui_bg_cyan"]="8,45,52,245", ["ui_bg_teal"]="8,52,48,245",
    ["ui_bg_green"]="12,42,30,245", ["ui_bg_lime"]="35,55,12,245", ["ui_bg_olive"]="48,48,10,245", ["ui_bg_purple"]="30,16,48,245",
    ["ui_bg_violet"]="42,12,62,245", ["ui_bg_pink"]="55,18,45,245", ["ui_bg_red"]="48,18,20,245", ["ui_bg_maroon"]="55,12,22,245",
    ["ui_bg_orange"]="58,32,10,245", ["ui_bg_gold"]="55,48,10,245", ["ui_bg_white"]="225,225,225,245"
}

-- prefixText/showTextPrefix are declared above the command handler.
local function getPrefix() if showTextPrefix == false then return "" end return tostring(prefixText or "") end
local function sendPublicText(text)
    if showTextPrefix == false then return false end
    text = tostring(text or "")
    if text == "" then return false end
    local ok = pcall(function()
        SendPacket(2, "action|input\n|text|" .. text)
    end)
    return ok
end
local LOCK_CHAT_NAMES={[242]="World Lock",[1796]="Diamond Lock",[7188]="Blue Gem Lock"}
local lastLockChatSig = ""
local lastLockChatAt = 0
sendLockChat = function(action,itemID,amount)
    amount = tonumber(amount) or 0
    local name = LOCK_CHAT_NAMES[tonumber(itemID)]
    if not name or amount <= 0 then return false end

    local verb = (tostring(action) == "take") and "Collected" or "Dropped"
    local text = getPrefix().." "..verb.." `9"..tostring(amount).." `5("..name..")"
    local sig = tostring(action).."|"..tostring(itemID).."|"..tostring(amount)
    local now = os.clock()
    if sig == lastLockChatSig and (now - lastLockChatAt) < 0.35 then
        return false
    end

    -- SHOWTEKS controls the visible public Collected/Dropped message.
    local ok = sendPublicText(text)
    if ok then
        if type(pushLog)=="function" and type(lockLogs)=="table" then
            local logText = verb.." "..tostring(amount).." "..name
            local last = lockLogs[1]
            if not last or tostring(last.text or "") ~= logText then pushLog(lockLogs, logText) end
        end
        lastLockChatSig, lastLockChatAt = sig, now
        return true
    end
    return false
end

local function sendGemChat(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 or showTextPrefix == false then return false end
    local text = getPrefix().." Collected `9+"..tostring(amount).." `2Gems."
    return sendPublicText(text)
end

local uiTextPresets = {
    ["ui_text_0"] = "`0",
    ["ui_text_1"] = "`1",
    ["ui_text_2"] = "`2",
    ["ui_text_3"] = "`3",
    ["ui_text_4"] = "`4",
    ["ui_text_5"] = "`5",
    ["ui_text_6"] = "`6",
    ["ui_text_7"] = "`7",
    ["ui_text_8"] = "`8",
    ["ui_text_9"] = "`9",
    ["ui_text_a"] = "`a",
    ["ui_text_b"] = "`b",
    ["ui_text_c"] = "`c",
    ["ui_text_d"] = "`d",
    ["ui_text_e"] = "`e",
    ["ui_text_f"] = "`f",
    ["ui_text_w"] = "`w",
    ["ui_text_orange"] = "`o",
    ["ui_text_pink"] = "`p"
}

local function validUIBg(value)
    if type(value) ~= "string" then return false end
    local r,g,b,a = value:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,?%s*(%d*)%s*$")
    r,g,b = tonumber(r), tonumber(g), tonumber(b)
    a = (a == "" or a == nil) and 245 or tonumber(a)
    if not r or not g or not b or not a then return false end
    if r > 255 or g > 255 or b > 255 or a > 255 then return false end
    uiTheme.bg = string.format("%d,%d,%d,%d", r,g,b,a)
    return true
end

local function applyUITheme(d)
    d = tostring(d or "")

    -- Keep the V2 dialog flow: one global default color + one background.
    -- Remove every inline Growtopia color/control marker from the dialog so
    -- menus such as the MAIN MENU cannot override the selected UI color.
    d = d:gsub("set_bg_color|[^\n]*", "")
    d = d:gsub("set_default_color|[^\n]*", "")
    d = d:gsub("`.", "")
    d = d:gsub("^\n+", "")

    return "set_default_color|" .. uiTheme.text .. "|\n" ..
           "set_bg_color|" .. uiTheme.bg .. "|\n" .. d
end

local function showUIThemeMenu()
    local d = [[
add_quick_exit|
add_label|big|lumna.proxy - UI THEME|left|
add_spacer|small|
add_textbox|Background: ]]..uiTheme.bg..[[|left|2440|
add_textbox|Text Color: ]]..uiTheme.text..[[|left|2440|
add_spacer|small|
add_label|small|Background Presets|left|
add_button|ui_bg_black|Black|noflags|
add_button|ui_bg_dark|Dark|noflags|
add_button|ui_bg_gray|Gray|noflags|
add_button|ui_bg_slate|Slate|noflags|
add_button|ui_bg_blue|Blue|noflags|
add_button|ui_bg_navy|Navy|noflags|
add_button|ui_bg_cyan|Cyan|noflags|
add_button|ui_bg_teal|Teal|noflags|
add_button|ui_bg_green|Green|noflags|
add_button|ui_bg_lime|Lime|noflags|
add_button|ui_bg_olive|Olive|noflags|
add_button|ui_bg_purple|Purple|noflags|
add_button|ui_bg_violet|Violet|noflags|
add_button|ui_bg_pink|Pink|noflags|
add_button|ui_bg_red|Red|noflags|
add_button|ui_bg_maroon|Maroon|noflags|
add_button|ui_bg_orange|Orange|noflags|
add_button|ui_bg_gold|Gold|noflags|
add_button|ui_bg_white|White|noflags|
add_text_input|ui_custom_bg|Custom RGB + Alpha|]]..uiTheme.bg..[[|24|
add_button|ui_apply_bg|Apply Background|noflags|
add_spacer|small|
add_label|small|Text Color Palette - ALL MENU TEXT|left|
add_button|ui_text_0|`0Black / Dark|noflags|
add_button|ui_text_1|`1Blue / Dark Blue|noflags|
add_button|ui_text_2|`2Green|noflags|
add_button|ui_text_3|`3Cyan / Teal|noflags|
add_button|ui_text_4|`4Red|noflags|
add_button|ui_text_5|`5Purple / Violet|noflags|
add_button|ui_text_6|`6Yellow|noflags|
add_button|ui_text_7|`7Gray|noflags|
add_button|ui_text_8|`8Dark Gray|noflags|
add_button|ui_text_9|`9Gold / Bright Yellow|noflags|
add_button|ui_text_a|`aLight Green|noflags|
add_button|ui_text_b|`bLight Blue|noflags|
add_button|ui_text_c|`cLight Purple|noflags|
add_button|ui_text_d|`dPink / Rose|noflags|
add_button|ui_text_e|`eOrange / Yellow|noflags|
add_button|ui_text_f|`fExtended / Special|noflags|
add_button|ui_text_w|`wWhite|noflags|
add_button|ui_text_orange|`oOrange|noflags|
add_button|ui_text_pink|`pPink|noflags|
add_spacer|small|
add_button|ui_back|Back to Main Menu|noflags|
end_dialog|uitheme||Close|
]]
    dialog(d)
end

local function showInformationMenu()
    local d = [[
add_quick_exit|
add_label|big|lumna.proxy - INFORMATION|left|
add_spacer|small|
add_label|small|Bahasa Indonesia|left|
add_textbox|1. Dilarang membagikan, menjual, mengupload ulang, atau mendistribusikan script tanpa izin pemilik.|left|
add_textbox|2. Dilarang menghapus atau mengubah credit, nama brand, dan copyright script.|left|
add_textbox|3. Gunakan script dengan tanggung jawab dan sesuai aturan server yang digunakan.|left|
add_textbox|4. Pemilik script tidak bertanggung jawab atas penyalahgunaan, banned, atau kerugian akibat penggunaan script.|left|
add_textbox|5. Dengan menggunakan script ini, kamu dianggap menyetujui rules yang berlaku.|left|
add_spacer|small|
add_label|small|English|left|
add_textbox|1. Do not share, sell, re-upload, or redistribute this script without the owner's permission.|left|
add_textbox|2. Do not remove or modify the script credits, brand name, or copyright notice.|left|
add_textbox|3. Use this script responsibly and follow the rules of the server where it is used.|left|
add_textbox|4. The script owner is not responsible for misuse, bans, or losses caused by using this script.|left|
add_textbox|5. By using this script, you agree to and accept the rules above.|left|
add_spacer|small|
add_label|small|Copyright / Hak Cipta|left|
add_textbox|© lumna.proxy - All rights reserved. Do not claim this script as your own work.|left|
add_textbox|© lumna.proxy - Hak cipta dilindungi. Jangan mengklaim script ini sebagai karya milik sendiri.|left|
add_spacer|small|
add_button|info_back|Back to Main Menu|noflags|
end_dialog|info||Close|
]]
    dialog(d)
end

function dialog(tkss)
va = {}
va.v1 = "OnDialogRequest"
va.v2 = applyUITheme(tkss)
SendVariant(va)
end

function wear(ids)
pkt = {}
pkt.type = 10
pkt.value = ids
SendPacketRaw(false, pkt)
end

function path(x,y)
SendPacketRaw(false, {state = 32,
x = x*32,
y = y*32})
end

function log(aa)
LogToConsole(systemlog .. aa)
end

function rdrop(id, amount)
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..amount)
end

function cdrop(id, amount)
SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|"..id.."|\nitem_count|"..amount)
end

-------------------------------------
-- GEM SCANNER / SH1-SH6
-------------------------------------

local function saveGemPosition(slot)
    if gemSetupSide == nil then
        log("`4Gem setup belum dipilih. Gunakan /setkiri atau /setkanan terlebih dahulu.")
        ont("`4Gunakan /setkiri atau /setkanan dulu")
        return
    end

    local me = GetLocal()
    if not me then
        log("`4Gagal membaca posisi player.")
        ont("`4Gagal membaca posisi")
        return
    end

    local x = math.floor((tonumber(me.posX) or 0) / 32)
    local y = math.floor((tonumber(me.posY) or 0) / 32)

    if gemSetupSide == "kiri" then
        gemPositions.pos1[slot] = {x = x, y = y}
        log("`2Gem Kiri SH" .. slot .. " disimpan: `9" .. x .. "," .. y)
        ont("`2Kiri SH" .. slot .. " tersimpan")
    elseif gemSetupSide == "kanan" then
        local index = slot - 3
        gemPositions.pos2[index] = {x = x, y = y}
        log("`2Gem Kanan SH" .. slot .. " disimpan: `9" .. x .. "," .. y)
        ont("`2Kanan SH" .. slot .. " tersimpan")
    end
end

local function gemSetupReady()
    return gemPositions.pos1[1] and gemPositions.pos1[2] and gemPositions.pos1[3]
       and gemPositions.pos2[1] and gemPositions.pos2[2] and gemPositions.pos2[3]
end

-- Scan kedua sisi dari SATU snapshot object list.
-- Ini mencegah sisi KIRI mengubah GetObjectList sebelum sisi KANAN dibaca.
local function scanGemSideFromObjects(positions, objects)
    local total = 0
    local collected = 0

    if type(objects) ~= "table" then
        return 0, 0
    end

    for _, pos in ipairs(positions or {}) do
        if pos and pos.x and pos.y then
            for _, obj in pairs(objects) do
                local itemID = tonumber(obj.itemid)
                local ox = math.floor((tonumber(obj.posX) or 0) / 32)
                local oy = math.floor((tonumber(obj.posY) or 0) / 32)

                if itemID == 112 and ox == pos.x and oy == pos.y then
                    local amount = tonumber(obj.amount) or 0
                    local objectID = tonumber(obj.id)

                    if objectID and amount > 0 then
                        total = total + amount

                        -- Collect packet harus memakai koordinat tile terpisah.
                        -- px = X tile dan py = Y tile (bukan digabung menjadi string).
                        local pkt = {
                            type = 11,
                            value = objectID,
                            px = pos.x,
                            py = pos.y,
                            x = tonumber(obj.posX) or (pos.x * 32),
                            y = tonumber(obj.posY) or (pos.y * 32)
                        }

                        SendPacketRaw(false, pkt)
                        -- Do NOT log individual gem objects here. The final
                        -- aggregated +N Gems server message is logged once.
                        collected = collected + amount
                    end
                end
            end
        end
    end

    return total, collected
end

-- Right and Left are calculated separately from the same object snapshot.
function scanGems()
    if not gemSetupReady() then
        log("`4Scan Gems: set Kiri /sh1 /sh2 /sh3 dan Kanan /sh4 /sh5 /sh6 terlebih dahulu.")
        ont("`4Set 3 posisi Kiri + 3 posisi Kanan dulu")
        return 0, 0, 0
    end

    -- Ambil object list sekali saja agar KIRI dan KANAN memakai data yang sama.
    local objects = GetObjectList()
    if type(objects) ~= "table" then
        log("`4Scan Gems: GetObjectList tidak tersedia.")
        ont("`4Gagal membaca object list gems")
        return 0, 0, 0
    end

    local gems1, collected1 = scanGemSideFromObjects(gemPositions.pos1, objects)
    local gems2, collected2 = scanGemSideFromObjects(gemPositions.pos2, objects)

    local totalGems = gems1 + gems2
    local collectedTotal = (tonumber(collected1) or 0) + (tonumber(collected2) or 0)
    if collectedTotal > 0 then
        -- SendPacketRaw may trigger pkt() and leave an aggregated pending amount.
        -- Prefer that real pickup amount; otherwise record the scan result directly.
        if (tonumber(pendingGemLogAmount) or 0) > 0 then
            flushPendingGemLog()
        else
            local me = GetLocal()
            table.insert(gemsLogs, 1, {
                growid = (me and me.name) or "UNKNOWN",
                amount = collectedTotal,
                world = GetWorldName(),
                time = os.date("%H:%M:%S")
            })
            while #gemsLogs > LOG_MAX do table.remove(gemsLogs) end
        end
    end
    lastGemLeft = gems1
    lastGemRight = gems2
    lastGemTotal = totalGems

    log("`2Scan Gems: KIRI=`9" .. gems1 .. " `2KANAN=`9" .. gems2 ..
        " `2| TOTAL=`9" .. totalGems .. " `2| Collected=`9" .. (collected1 + collected2))

    ont("`2Gems Kiri: `9" .. gems1 ..
        " `2| Kanan: `9" .. gems2 ..
        " `2| Total: `9" .. totalGems)

    -- Tampilkan hasil scan di TalkBubble agar bisa terlihat pemain lain.
    -- Nilai terendah diberi warna merah (`4), nilai terbesar hijau (`2).
    local publicGemText
    if gems1 < gems2 then
        publicGemText = "(`4" .. gems1 .. " gems `2" .. gems2 .. " gems)"
    elseif gems2 < gems1 then
        publicGemText = "(`2" .. gems1 .. " gems `4" .. gems2 .. " gems)"
    else
        publicGemText = "(`2" .. gems1 .. " gems `2" .. gems2 .. " gems)"
    end

    local gemBubble = {}
    gemBubble.v1 = "OnTalkBubble"
    gemBubble.v2 = GetLocal().netID
    gemBubble.v3 = publicGemText
    gemBubble.v5 = 1
    SendVariant(gemBubble)

    return gems1, gems2, totalGems
end

-------------------------------------
-- WRENCH / DOOR COMMANDS
-- Tidak memakai command atau tombol menu.
-- Semua interaksi dilakukan langsung dengan Wrench ID 32.
-------------------------------------

-- Wrench player mode (referensi LumnaProxy V2)
if cmd("/wrench Pull") or cmd("/wrench pull") or
   cmd("/wrench Kick") or cmd("/wrench kick") or
   cmd("/wrench Ban") or cmd("/wrench ban") or
   cmd("/wrench WorldBan") or cmd("/wrench worldban") or
   cmd("/wrench World_Ban") or cmd("/wrench world_ban") then
    local wm = packet:match("/wrench%s+(%S+)")
    wm = wm and wm:upper() or ""
    if wm == "WORLD_BAN" or wm == "WORLDBAN" then wm = "BAN" end
    if wm == "PULL" or wm == "KICK" or wm == "BAN" then
        wrenchMode = wm
        local label = (wm == "BAN") and "WORLD BAN" or wm
        log("`2Wrench "..label.." Mode Enabled")
        ont("`2Wrench Mode: `9"..label)
    end
    return true
end
if cmd("/wrench Off") or cmd("/wrench off") or cmd("/wrench Default") or cmd("/wrench default") then
    wrenchMode = ""
    log("`4Wrench Mode Disabled")
    ont("`4Wrench Mode: DEFAULT")
    return true
end

--Create Command
-------------------------------------

if cmd("/proxy") or packet:find("buttonClicked|cmd") then
gazette = [[add_label_with_icon|big|lumna.proxy Commands    ````       |left|32|
add_spacer|small|
add_smalltext|`9Welcome, to the `5#1 Best OPEN SOURCE Proxy `9script.|left|
add_smalltext|`9What will you do today?, ]]..GetLocal().name..[[|left|
add_spacer|small|
add_label_with_icon|small|`5Information:|left|3524|
add_spacer|small|
add_textbox|`9/proxy `2- Show proxy command|left|
add_textbox|`9/pstats `2- Show proxy stats|left|
add_spacer|small|
add_label_with_icon|small|`5Lock Command:|left|1422|
add_spacer|small|
add_textbox|`9/daw `2- Drop All Locks|left|
add_textbox|`9/cd `1[AMOUNT] `2- Custom Drop Lock|left|
add_textbox|`9/prefix [text] `2- Set public prefix|left|2440|
add_textbox|`9/showteks [on/off] `2- Show/hide Collected/Dropped/Gems messages|left|2440|
add_textbox|`9/wrench [Pull/Kick/Ban/Off] `2- Wrench player mode|left|2440|
add_textbox|`9/warp [world] `2- Direct warp to world (no handwarp)|left|2440|
add_textbox|`9/wd `1[AMOUNT] `2- Drop WL only|left|
add_textbox|`9/dd `1[AMOUNT] `2- Drop DL only|left|
add_textbox|`9/bd `1[AMOUNT] `2- Drop BGL only|left|
add_textbox|`9/bal `2- Show WL Balance|left|
add_textbox|`9/rafter `1[1-9] `2- Reset gems counter|left|
add_spacer|small|
add_label_with_icon|small|`5World Command:|left|242|
add_spacer|small|
add_textbox|`9/rejoin `2- Rejoin world|left|
add_textbox|`9/save `1[TEXT] `2- Save world to save wl|left|
add_textbox|`9/gsave `2- Go to save world|left|
add_textbox|`9/res `2- Fast respawn|left|
add_spacer|small|
add_label_with_icon|small|`5CSN Helper Command:|left|758|
add_spacer|small|
add_textbox|`9/pos1 `2- Set Pos 1 (WL drop Room 1)|left|
add_textbox|`9/pos2 `2- Set Pos 2 (WL drop Room 2)|left|
add_textbox|`9/setkiri `2- Aktifkan setup Gem Kiri (SH1-SH3)|left|
add_textbox|`9/setkanan `2- Aktifkan setup Gem Kanan (SH4-SH6)|left|
add_textbox|`9/sh1 /sh2 /sh3 `2- Simpan posisi Gem Kiri|left|
add_textbox|`9/sh4 /sh5 /sh6 `2- Simpan posisi Gem Kanan|left|
add_textbox|`9/scangems `2- Scan & take Gem dari SH1-SH6|left|
add_textbox|`9/reme /leme /qq `2- Casino mode|left|
add_textbox|`9/logspin /loggems /loglock `2- Show logs|left|
add_textbox|`9/auto `2- Auto take when /w1, /w2|left|
add_textbox|`9/tax `1[AMOUNT] `2- Set tax, don't add "%"|left|
add_textbox|`9/bet `1[AMOUNT] `2- Set Bet WL, DL, BGL|left|
add_textbox|`9/take `2- Take WL, DL, BGL|left|
add_textbox|`9/w1 `2- Windrop ke Pos1 + collect Pos1/Pos2|left|
add_textbox|`9/w2 `2- Windrop ke Pos2 + collect Pos1/Pos2|left|
add_spacer|small|
add_label_with_icon|small|`5More Command:|left|2376|
add_spacer|small|
add_textbox|`9/psc `2- Security Camera (`1only show u`2)|left|
add_textbox|`9/drop `1[ITEMID] [AMOUNT] `2- Drop item with command|left|
add_textbox|`9/wl `1[AMOUNT/EXPRESSION] `2- Drop World Lock value (contoh: /wl 700/2*3 = 10 DL + 50 WL)|left|
add_textbox|`9/bgl `1[AMOUNT/EXPRESSION] `2- Drop Blue gem Lock value (contoh: /bgl 1/2*3 = 1 BGL + 50 DL)|left|
add_textbox|`9/name `1[TEXT] `2- Visual Name|left|
add_textbox|`9/relog `2- Fast Relog game|left|
add_textbox|`9/skin `1[SKIN ID] `2- Change Skin Colour (gtps)|left|
add_textbox|`9/fd `2- Fast Drop Toggle|left|
add_spacer|small|
add_label_with_icon|small|`5Wrench Player Command:|left|32|
add_textbox|`9/wrench Pull `2- Set Pull mode|left|
add_textbox|`9/wrench Kick `2- Set Kick mode|left|
add_textbox|`9/wrench Ban `2- Set Ban mode|left|
add_textbox|`9/wrench Off `2- Disable player wrench mode|left|
add_textbox|`9/warp [world] `2- Direct warp to world (no handwarp)|left|
add_quick_exit||
end_dialog|gazz|Cancel|Okay|
]]

dialog(gazette)
return true
end

if cmd("/psc") then
sekurc = [[
set_default_color|`o
add_label_with_icon|big|`wPrivate Security Camera|left|1436|
add_spacer|small|
add_label_with_icon|small|`wScript runned at ]]..timer..[[|left|3524|
]]..table.concat(logd)..[[
add_spacer|small|
add_quick_exit|
add_button|clearl|`4Clear Log|noflags|0|0|
end_dialog|priv_cam||OK|
]]
dialog(sekurc)
return true
end

if cmd("/wd (%d+)") then

if (inv(242) == 0 or inv(242) < tonumber(match)) then
ont("`4You don't have enough World Lock to drop.")
elseif inv(242) >= 1 then
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..match.." `wWorld Lock at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
log("`2Dropped `9"..match.."`2 World Lock.")
if mode == "rgt" then
rdrop(242, match)
sendLockChat("drop",242,match)
else
cdrop(242, match)
sendLockChat("drop",242,match)
end
end

return true
end

-- /wl = Drop World Lock value. Mendukung jumlah biasa atau hitungan sederhana.
-- Contoh: /wl 150 -> 1 DL + 50 WL
--         /wl 7/2*3 -> hasil 10 WL
local function evalDropAmount(expr)
    if not expr then return nil end
    expr = expr:gsub("%s+", "")
    if expr == "" or not expr:match("^[%d%+%-%*/%.%(%)]+$") then
        return nil
    end

    -- Parser aritmatika sederhana dengan prioritas * dan /, lalu + dan -.
    local pos = 1
    local len = #expr

    local function skip()
        while pos <= len and expr:sub(pos,pos):match("%s") do pos = pos + 1 end
    end

    local parseExpr, parseTerm, parseFactor

    function parseFactor()
        skip()
        if expr:sub(pos,pos) == "(" then
            pos = pos + 1
            local v = parseExpr()
            skip()
            if expr:sub(pos,pos) ~= ")" then error("bad expression") end
            pos = pos + 1
            return v
        end

        local start = pos
        while pos <= len and expr:sub(pos,pos):match("[%d%.]") do pos = pos + 1 end
        if start == pos then error("bad number") end
        local v = tonumber(expr:sub(start,pos-1))
        if not v then error("bad number") end
        return v
    end

    function parseTerm()
        local v = parseFactor()
        while true do
            skip()
            local op = expr:sub(pos,pos)
            if op ~= "*" and op ~= "/" then break end
            pos = pos + 1
            local rhs = parseFactor()
            if op == "*" then
                v = v * rhs
            else
                if rhs == 0 then error("division by zero") end
                v = v / rhs
            end
        end
        return v
    end

    function parseExpr()
        local v = parseTerm()
        while true do
            skip()
            local op = expr:sub(pos,pos)
            if op ~= "+" and op ~= "-" then break end
            pos = pos + 1
            local rhs = parseTerm()
            if op == "+" then v = v + rhs else v = v - rhs end
        end
        return v
    end

    local ok, result = pcall(function()
        local v = parseExpr()
        skip()
        if pos <= len then error("bad expression") end
        return v
    end)

    if not ok or not result or result ~= result or result == math.huge or result == -math.huge then
        return nil
    end

    result = math.floor(result)
    if result < 1 then return nil end
    return result
end

if cmd("/wl (.+)") then
    local expr = packet:match(inpuc0o1 .. "/wl (.+)")
    local amount = evalDropAmount(expr)

    if not amount then
        ont("`4Format /wl salah. Contoh: /wl 150 atau /wl 7/2*3")
        return true
    end

    local totalWL = inv(242) + inv(1796) * 100 + inv(7188) * 10000
    if totalWL < amount then
        ont("`4You don't have enough WL value. Need `9"..amount.." `4WL.")
        return true
    end

    if smartDropDL(amount) then
        table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..amount.." `wWL value at "..os.date("%H:%M").."|left|13810|\n")
        conte = 0
    end
    return true
end

if cmd("/dd (%d+)") then
if inv(1796) == 0 or inv(1796) < tonumber(match) then
ont("`4You don't have enough Diamond Lock to drop.")
else
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..match.." `wDiamond Lock at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
log("`2Dropped `9"..match.."`2 Diamond Lock.")

if mode == "rgt" then
rdrop(1796, match)
sendLockChat("drop",1796,match)
else
cdrop(1796, match)
sendLockChat("drop",1796,match)
end
end
return true
end

if cmd("/bd (%d+)") then
if inv(7188) == 0 or inv(7188) < tonumber(match) then
ont("`4You don't have enough Blue Gem Lock to drop.")
else
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..match.." `wBlue Gem Lock at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
log("`2Dropped `9"..match.."`2 Blue Gem Lock.")
if mode == "rgt" then
rdrop(7188, match)
sendLockChat("drop",7188,match)
else
cdrop(7188, match)
sendLockChat("drop",7188,match)
end
end
return true
end

if cmd("/daw") then
if inv(242) == 0 then
else
log("`2Dropped `9"..inv(242).." `2World Lock.")
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..inv(242).." `wWorld Lock at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
if mode == "rgt" then
rdrop(242, inv(242))
sendLockChat("drop",242,inv(242))
else
cdrop(242, inv(242))
sendLockChat("drop",242,inv(242))
end
end

if inv(1796) == 0 then
else
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..inv(1796).." `wDiamond Lock at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
log("`2Dropped `9"..inv(1796).." `2Diamond Lock.")
if mode == "rgt" then
rdrop(1796, inv(1796))
sendLockChat("drop",1796,inv(1796))
else
cdrop(1796, inv(1796))
sendLockChat("drop",1796,inv(1796))
end
end

if inv(7188) == 0 then
else
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..inv(7188).." `wBlue Gem Lock at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
log("`2Dropped `9"..inv(7188).." `2Blue Gem Lock.")
if mode == "rgt" then
rdrop(7188, inv(7188))
sendLockChat("drop",7188,inv(7188))
else
cdrop(7188, inv(7188))
sendLockChat("drop",7188,inv(7188))
end
end

return true
end

if cmd("/cd (%d+)") then
if mode == "rgt" then
Amount = packet:match("/cd (%d+)")
bgl =math.floor(Amount/10000)
Amount = Amount - bgl*10000
dl = math.floor(Amount/100)
wl = Amount % 100
LogToConsole("`6/cd "..packet:match("/cd (%d+)").."")
LogToConsole("`2Dropped `9"..bgl.." `2BGL, `9"..dl.." `2DL, `9"..wl.." `2WL.")
if inv(7188) < bgl then
ont("`4You don't have enough BGL.")
elseif bgl == 0 then
else
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..bgl.." `wBlue Gem Lock at "..os.date("%H:%M").."|left|13810|\n")
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|7188|\ncount|"..bgl.."")
end

if inv(1796) < dl and inv(7188) <= 0 then
ont("`4You don't have enough DL.")
elseif dl == 0 then
else
if inv(1796) < dl and inv(7188) >= 0 then wear(7188) end
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..dl.." `wDiamond Lock at "..os.date("%H:%M").."|left|13810|\n")
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|1796|\ncount|"..dl.."")
end
if inv(242) < wl and inv(1796) <= 0 then
ont("`4You don't have enough WL.")
elseif wl == 0 then
else
if inv(242) < wl and inv(1796) >= 0 then wear(1796) end
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..wl.." `wWorld Lock at "..os.date("%H:%M").."|left|13810|\n")
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|242|\ncount|"..wl.."")
end
else
LogToConsole("`7[ `2Custom Drop `7] `$CreativePS `odoes not support `$/cdrop `o(`$Custom Drop`o)")
end
return true
end

if cmd("/bal") then
dll = inv(1796) * 100
bgll = inv(7188) * 10000
hailto = inv(242) + dll + bgll
log("`2You have total: `9"..hailto.."`2 World Lock (`9"..inv(7188).." `2BGL, `9"..inv(1796).." `2DL, `9"..inv(242).." `2WL).")
return true
end

-- GEM SETUP
if cmd("/setkiri") then
gemSetupSide = "kiri"
log("`2Set Gems: `9KIRI `2aktif. Gunakan /sh1, /sh2, /sh3")
ont("`2Set Kiri aktif: /sh1 /sh2 /sh3")
return true
end

if cmd("/setkanan") then
gemSetupSide = "kanan"
log("`2Set Gems: `9KANAN `2aktif. Gunakan /sh4, /sh5, /sh6")
ont("`2Set Kanan aktif: /sh4 /sh5 /sh6")
return true
end

if cmd("/sh1") then
if gemSetupSide ~= "kiri" then
log("`4/sh1 hanya untuk KIRI. Gunakan /setkiri terlebih dahulu.")
ont("`4Aktifkan /setkiri dulu")
else
saveGemPosition(1)
end
return true
end

if cmd("/sh2") then
if gemSetupSide ~= "kiri" then
log("`4/sh2 hanya untuk KIRI. Gunakan /setkiri terlebih dahulu.")
ont("`4Aktifkan /setkiri dulu")
else
saveGemPosition(2)
end
return true
end

if cmd("/sh3") then
if gemSetupSide ~= "kiri" then
log("`4/sh3 hanya untuk KIRI. Gunakan /setkiri terlebih dahulu.")
ont("`4Aktifkan /setkiri dulu")
else
saveGemPosition(3)
end
return true
end

if cmd("/sh4") then
if gemSetupSide ~= "kanan" then
log("`4/sh4 hanya untuk KANAN. Gunakan /setkanan terlebih dahulu.")
ont("`4Aktifkan /setkanan dulu")
else
saveGemPosition(4)
end
return true
end

if cmd("/sh5") then
if gemSetupSide ~= "kanan" then
log("`4/sh5 hanya untuk KANAN. Gunakan /setkanan terlebih dahulu.")
ont("`4Aktifkan /setkanan dulu")
else
saveGemPosition(5)
end
return true
end

if cmd("/sh6") then
if gemSetupSide ~= "kanan" then
log("`4/sh6 hanya untuk KANAN. Gunakan /setkanan terlebih dahulu.")
ont("`4Aktifkan /setkanan dulu")
else
saveGemPosition(6)
end
return true
end

if cmd("/reme") then gameMode="reme"; log("Mode REME enabled"); ont("`2Mode REME enabled"); return true end
if cmd("/leme") then gameMode="leme"; log("Mode LEME enabled"); ont("`2Mode LEME enabled"); return true end
if cmd("/qq") or cmd("/qeme") then gameMode="qq"; log("Mode QQ enabled"); ont("`2Mode QQ enabled"); return true end
if cmd("/csn") then gameMode="csn"; log("Mode CSN enabled"); ont("`2Mode CSN enabled"); return true end
if cmd("/logspin") then logPages.spin=1; showSimpleLog("SPIN LOG", spinLogs, "clear_spinlog", 1); return true end
if cmd("/loggems") then logPages.gems=1; showSimpleLog("GEMS LOG", gemsLogs, "clear_gemslog", 1); return true end
if cmd("/loglock") then logPages.lock=1; showSimpleLog("LOCK LOG", lockLogs, "clear_locklog", 1); return true end

if cmd("/scangems") or cmd("/tg") or cmd("/gems") then
scanGems()
return true
end

if cmd("/pos1") then
local me = GetLocal()
if me then
x1 = math.floor((tonumber(me.posX) or 0) / 32)
y1 = math.floor((tonumber(me.posY) or 0) / 32)
ont("`2Pos1 tersimpan: `9"..x1..","..y1)
log("`2POS1 = `9"..x1..","..y1)
end
return true
end

if cmd("/pos2") then
local me = GetLocal()
if me then
x2 = math.floor((tonumber(me.posX) or 0) / 32)
y2 = math.floor((tonumber(me.posY) or 0) / 32)
ont("`2Pos2 tersimpan: `9"..x2..","..y2)
log("`2POS2 = `9"..x2..","..y2)
end
return true
end

if cmd("/tax (%d+)") then
if tonumber(match) > 100 then
log("`4Maximum Tax is `2100%`4.")
else
stax = match
log("`2Tax set to `9"..stax.."%`2.")
end
return true
end

if cmd("/bet (%d+)") then
Aount = match
log("`2Setted bet to `9"..Aount.."`2 World Lock.")
return true
end

if cmd("/take") then
    -- MANUAL COLLECT: hanya WL/DL/BGL pada Pos1 + Pos2.
    -- Jalur ini terpisah dari punch ID 1422 dan tidak mengaktifkan
    -- parser ConsoleMessage untuk mencegah teks double.
    lockCollectArmed = false
    lockCollectArmAt = 0

    local function manualTakeAt(px, py)
        px, py = tonumber(px), tonumber(py)
        if not px or not py or type(GetObjectList) ~= "function" then return 0 end

        local total = 0
        local totals = {[242]=0,[1796]=0,[7188]=0}
        local objects = GetObjectList()
        if type(objects) ~= "table" then return 0 end

        for _, obj in pairs(objects) do
            local ox = math.floor((tonumber(obj.posX) or 0) / 32)
            local oy = math.floor((tonumber(obj.posY) or 0) / 32)
            local id = tonumber(obj.itemid)
            if ox == px and oy == py and (id == 242 or id == 1796 or id == 7188) then
                local amount = tonumber(obj.amount) or 0
                if amount > 0 then
                    SendPacketRaw(false, {
                        type = 11, value = tonumber(obj.id),
                        px = px, py = py,
                        x = tonumber(obj.posX) or (px * 32),
                        y = tonumber(obj.posY) or (py * 32)
                    })
                    totals[id] = (totals[id] or 0) + amount
                    total = total + amount
                end
            end
        end

        -- Teks "Collected" berasal dari OnConsoleMessage server agar
        -- manual take tetap menampilkan pesan dan tidak double.
        return total
    end

    local manualTotal = manualTakeAt(x1, y1) + manualTakeAt(x2, y2)
    if manualTotal > 0 then
        ont("`2Collected `9"..manualTotal.." `2WL/DL/BGL")
    else
        ont("`4No WL/DL/BGL at Pos1/Pos2")
    end
    return true
end

local function collectAtPos(px, py)
    px, py = tonumber(px), tonumber(py)
    if not px or not py then return 0 end
    local count = 0
    local objects = GetObjectList()
    if type(objects) ~= "table" then return 0 end
    for _, obj in pairs(objects) do
        local ox = math.floor((tonumber(obj.posX) or 0) / 32)
        local oy = math.floor((tonumber(obj.posY) or 0) / 32)
        if ox == px and oy == py then
            local id = tonumber(obj.itemid)
            if id == 242 or id == 1796 or id == 7188 then
                SendPacketRaw(false, {type=11, value=tonumber(obj.id), px=px, py=py,
                    x=tonumber(obj.posX) or px*32, y=tonumber(obj.posY) or py*32})
                -- Jangan kirim teks Collected di sini; tunggu pesan server.
                count = count + (tonumber(obj.amount) or 0)
            end
        end
    end
    return count
end

if cmd("/w1") then
if autocsn == true then
function tp1()
for _, obj in pairs(GetObjectList()) do
        if x1 == math.floor(obj.posX / 32) and y1 == math.floor(obj.posY / 32) then
        if obj.itemid == 242 then
        wear(242)
        end
        pkt = {}
        pkt.px = x1
pkt.py = y1
        pkt.type = 11
        pkt.value = obj.id
        pkt.x = obj.posX
        pkt.y = obj.posY
        SendPacketRaw(false, pkt)
    end
end
end

function tp2()
for _, obj in pairs(GetObjectList()) do
        if x2 == math.floor(obj.posX / 32) and y2 == math.floor(obj.posY / 32) then
        pkt = {}
        pkt.px = x2
pkt.py = y2
        pkt.type = 11
        pkt.value = obj.id
        pkt.x = obj.posX
        pkt.y = obj.posY
        SendPacketRaw(false, pkt)
        if obj.itemid == 242 and obj.amount >= 100 then
        wear(242)
        end
    end
  end
end

tp1()
tp2()
ont("Collecting Pos1 And Pos2")
end
log("`6/w1")
tax = stax
jl = math.floor(tax / 100 * Aount * 2)
jumlah = math.floor(Aount * 2 - jl)
earnedwls = Aount * 2 - jumlah
earned = earned + earnedwls
bgl =math.floor(jumlah/10000)
jumlah = jumlah - bgl*10000
dl = math.floor(jumlah/100)
wl = jumlah % 100
log("`2Current Tax: `9"..tax.."%`2 (Bet: `9"..Aount.."`2), Dropped `9"..wl.." `2WL, `9"..dl.." `2DL, `9"..bgl.." `2BGL.")
earnedwl = ("`2Earned `9+"..earnedwls.." `2World Lock.")
if inv(242) <= wl then
wear(1796)
end
v = {}
v.v1 = "OnTalkBubble"
v.v2 = GetLocal().netID
v.v3 = earnedwl
v.v5 = 1
log(earnedwl)
SendVariant(v)
path(x1 - 2, y1)
if wl == 0 then
else
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|242|\ncount|"..wl)
end
if dl == 0 then
else
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|1796|\ncount|"..dl)
end
if bgl == 0 then
else
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|7188|\ncount|"..bgl)
end
return true
end

if cmd("/w2") then
if autocsn == true then
function tp1()
for _, obj in pairs(GetObjectList()) do
        if x1 == math.floor(obj.posX / 32) and y1 == math.floor(obj.posY / 32) then
        pkt = {}
        pkt.px = x2
pkt.py = y2
        pkt.type = 11
        pkt.value = obj.id
        pkt.x = obj.posX
        pkt.y = obj.posY
        SendPacketRaw(false, pkt)
        if obj.itemid == 242 then
        wear(242)
        end
    end
end
end

function tp2()
for _, obj in pairs(GetObjectList()) do
        if x2 == math.floor(obj.posX / 32) and y2 == math.floor(obj.posY / 32) then
        pkt = {}
        pkt.px = x2
pkt.py = y2
        pkt.type = 11
        pkt.value = obj.id
        pkt.x = obj.posX
        pkt.y = obj.posY
        SendPacketRaw(false, pkt)
        if obj.itemid == 242 then
        wear(242)
        end
    end
 end
end


tp1()
tp2()
ont("Collecting Pos1 And Pos2")
end

log("`6/w2")
tax = stax
jl = math.floor(tax / 100 * Aount * 2)
jumlah = math.floor(Aount * 2 - jl)
earnedwls = Aount * 2 - jumlah
earned = earned + earnedwls
bgl =math.floor(jumlah/10000)
jumlah = jumlah - bgl*10000
dl = math.floor(jumlah/100)
wl = jumlah % 100
log("`2Current Tax: `9"..tax.."%`2 (Bet: `9"..Aount.."`2), Dropped `9"..wl.." `2WL, `9"..dl.." `2DL, `9"..bgl.." `2BGL.")
earnedwl = ("`2Earned `9+"..earnedwls.." `2World Lock.")
if inv(242) < wl then
wear(1796)
end
v = {}
v.v1 = "OnTalkBubble"
v.v2 = GetLocal().netID
v.v3 = earnedwl
v.v5 = 1
log(earnedwl)
SendVariant(v)
path(x2 + 1, y2)
if wl == 0 then
else
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|242|\ncount|"..wl)
end
if dl == 0 then
else
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|1796|\ncount|"..dl)
end
if bgl == 0 then
else
SendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|7188|\ncount|"..bgl)
end

Aount2 = 0
return true
end

if cmd("/name (.*)") then
log("`9`2Name set to `9"..match.."`2. Type `1/name`2 (without space) to get default name back.")
if match == "" or match == "`" then
if nameset == false then
oriname = GetLocal().name
end
GetLocal().name = ""
nameset = true
else
if nameset == false then
oriname = GetLocal().name
end
GetLocal().name = ("`w`w`w`w"..match.."")
nameset = true
end
return true
end

if cmd("/rejoin") then
SendPacket(3,"action|join_request\nname|"..GetWorldName())
log("`2Rejoin world successfully.")
return true
end

if cmd("/relog") then
SendPacket(3,"action|quit")
log("`2Relog successfully.")
return true
end

if cmd("/name") then
if nameset == true then
log("`2Name has been reverted.")
GetLocal().name = oriname
nameset = false
else
LogToConsole("`9[ VISUAL NAME ] `4Change name first to do this action.")
end
return true
end

if cmd("/save (.*)") then
savew = match
log("`2Current World Save: `9"..savew)
return true
end

if cmd("/gsave") then
SendPacket(3,"action|join_request\nname|"..savew)
log("`2Going to `9"..savew)
return true
end

if cmd("/res") then
log("`2Respawn Succesful.")
SendPacket(2,"action|respawn")
return true
end

if cmd("/pstats") or packet:find("buttonClicked|inform") then
pstats = [[
set_default_color|`o
add_label_with_icon|big|lumna.proxy Stats         ````        |left|9474|
add_spacer|small|
add_quick_exit|
add_textbox|Earned from Tax: `w]]..earned..[[ `oWorld Lock|
add_textbox|Current Tax: `w]]..stax..[[%|
add_textbox|Current Bet: `w]]..Aount..[[ World Lock|

add_textbox|Pos 1: `w]]..x1..[[`o,`w ]]..y1..[[|
add_textbox|Pos 2: `w]]..x2..[[`o,`w ]]..y2..[[|
add_textbox|Current World Save: `w]]..savew..[[|
add_textbox|Script runned at: `w]]..timer..[[|
add_spacer|small|
end_dialog|ksis|Cancel|Okay|
]]
dialog(pstats)
return true
end

if cmd("/skin (.*)") then
log("`6/skin "..match)
log("`2Changed Skin ID to `9"..match)
SendPacket(2,"action|setSkin\ncolor|"..match)
return true
end

if cmd("/auto") then
if autocsn == false then
autocsn = true
log("`9Auto Take `2Enabled`9 (Easy got error connecting).")
else
autocsn = false
log("`9Auto Take `4Disabled`9.")
end
return true
end

if cmd("/bet") and not cmd("/bet ") then
log("`6/bet")
log("`2Current bet: `9"..Aount.." `2World Lock.")
return true
end

if cmd("/tax") and not cmd("/tax ") then
log("`6/tax")
log("`2Current Tax: `9"..stax.."%`2.")
return true
end

if cmd("/fd") then
if fastdrop == false then
fastdrop = true
log("`9Fast Drop `2Enabled")
else
fastdrop = false
log("`9Fast Drop `4Disabled")
end
return true
end

if cmd("/drop (%d+) (%d+)") then
match1 = packet:match("/drop (%d+)")
match2 = packet:match("/drop "..match1.." (%d+)")
LogToConsole("`6/drop "..match1.." "..match2)
if inv(tonumber(match1)) < tonumber(match2) then
log("`4You don't have enough Item")
ont("`4You don't have enough Item")
else
if mode == "rgt" then
rdrop(match1, match2)
else
cdrop(match1, match2)
end
log("`2Dropped `9"..match2.." `2"..growtopia.getItemName(match1).."")
end
return true
end

if cmd("/rafter (%d+)") then
log("`2Automatically Reset Gems After Doing Packet Type 0 to`9 "..match)
cgset = match
return true
end

-------------------------------------
--Packet
-------------------------------------

if packet:find("buttonClicked|clearl") then
v = {}
v.v1 = "OnTalkBubble"
v.v2 = GetLocal().netID
v.v3 = "`2Camera log cleared."
SendVariant(v)
log("`2Private Camera Log Cleared.")
logd = {}
end

if packet:find("dialog_name|drop_item\n") then
id = packet:match("itemID|(%d+)") or packet:match("temID|(%d+)")
if not packet:match("count|(%d+)") then
else
amon = packet:match("count|(%d+)")
table.insert(logd,"\nadd_label_with_icon|small|`wYou dropped `9"..amon.." `w"..growtopia.getItemName(id).." at "..os.date("%H:%M").."|left|13810|\n")
conte = 0
local lockID = tonumber(id)
if lockID == 242 or lockID == 1796 or lockID == 7188 then
    sendLockChat("drop", lockID, tonumber(amon) or 0)
end
end
end

if packet:find("quit_to_exit") then
if conte == 0 then
table.insert(logd,"\nadd_label_with_icon|small|`wYou left at "..os.date("%H:%M").."|left|13806|\n")
conte = conte + 1
elseif conte >= 1 then
end
end

if packet:find("join_request") then
nemwo = packet:match("join_request\nname|(.*)\ninv")
table.insert(logd,"\nadd_label_with_icon|small|`wYou entered `2"..nemwo.."`w at "..os.date("%H:%M").."|left|13804|\n")
conte = 0
end

if packet:find("action|friends\ndelay") or packet:find("buttonClicked|bk0") or packet == ("action|dialog_return\ndialog_name|socialportal\n") then
mmenu = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|lumna.proxy Menu       ````     |left|13824|
add_spacer|small|
add_smalltext|`9Sudah Join Dc Ku?, ]]..GetLocal().name..[[|left|
add_textbox|Current Tax: `$]]..stax..[[%|
add_textbox|Current Bet: `$]]..Aount..[[ World Lock|

add_spacer|small|
text_scaling_string|SubsToIptxtxD|
add_button_with_icon|cmd|`wCommand|staticYellowFrame|5956|
add_button_with_icon|inform|`wStats|staticYellowFrame|2586|
add_button_with_icon|control|`wController|staticYellowFrame|1660|
add_button_with_icon|gamemode|`wCasino Mode|staticYellowFrame|758|
add_button_with_icon|logs|`wLogs|staticYellowFrame|6016|
add_button_with_icon|uitheme|`wUI Theme|staticYellowFrame|3492|
add_button_with_icon|orimen|`wSocial|staticYellowFrame|9474|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|gscanback|`wInformation|staticYellowFrame|3524|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
end_dialog|k||Back|
]]

dialog(mmenu)
return true
end

if packet:find("buttonClicked|orimen") then
SendPacket(2,"action|friends\ndelay|0")
return true
end

if packet:find("buttonClicked|gscanback", 1, true) then
    showInformationMenu()
    return true
end

if packet:find("buttonClicked|info_back", 1, true) then
    if mmenu then dialog(mmenu) end
    return true
end

if packet:find("buttonClicked|uitheme") then
    showUIThemeMenu()
    return true
end

if packet:find("buttonClicked|ui_back") then
    if mmenu then dialog(mmenu) end
    return true
end

for uiId, uiBg in pairs(uiBgPresets) do
    if packet:find("buttonClicked|"..uiId, 1, true) then
        uiTheme.bg = uiBg
        showUIThemeMenu()
        return true
    end
end

for uiId, uiText in pairs(uiTextPresets) do
    if packet:find("buttonClicked|"..uiId, 1, true) then
        uiTheme.text = uiText
        showUIThemeMenu()
        return true
    end
end

if packet:find("buttonClicked|ui_apply_bg", 1, true) then
    local custom = packet:match("ui_custom_bg|([^\n|]+)")
    if validUIBg(custom or "") then
        ont("`2UI Background updated: `9"..uiTheme.bg)
    else
        ont("`4Invalid RGB. Use R,G,B or R,G,B,Alpha (0-255).")
    end
    showUIThemeMenu()
    return true
end

if packet:find("buttonClicked|gamemode") then showModeMenu(); return true end
if packet:find("buttonClicked|mode_reme") then gameMode="reme"; showModeMenu(); return true end
if packet:find("buttonClicked|mode_leme") then gameMode="leme"; showModeMenu(); return true end
if packet:find("buttonClicked|mode_qq") then gameMode="qq"; showModeMenu(); return true end
if packet:find("buttonClicked|mode_csn") then gameMode="csn"; showModeMenu(); return true end
if packet:find("buttonClicked|control") or packet:find("buttonClicked|bk1") then
cmenu = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wController         ````      |left|482|
add_spacer|small|
add_textbox|Select One:|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|ccsn|`wCasino|staticYellowFrame|758|
add_button_with_icon|cplay|`wPlayer|staticYellowFrame|10864|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk0|`wBack|
]]
dialog(cmenu)
return true
end

if packet:find("buttonClicked|ccsn") or packet:find("dialog_name|ccsn") then
    -- CSN Controller mengikuti struktur menu dari file referensi:
    -- Controller -> Casino -> Take Lock / Take Gems / Win 1 / Win 2.
    -- Fitur Gems V3 tetap dipertahankan dengan tampilan Left / Right / Total.
    local function showCSNController()
        control = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wCSN Controller     ````      |left|758|
add_spacer|small|
add_textbox|Earned: `$]]..earned..[[ World Lock|
add_textbox|Current Tax: `$]]..stax..[[%|
add_textbox|Current Bet: `$]]..Aount..[[ World Lock|
add_textbox|Gems Left: `9]]..lastGemLeft..[[|
add_textbox|Gems Right: `9]]..lastGemRight..[[|
add_textbox|Gems Total: `9]]..lastGemTotal..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|tke|`wTake Lock|staticYellowFrame|2814|
add_button_with_icon|scangems|`wScan Gems|staticYellowFrame|112|
add_button_with_icon|win1|`wWin 1|staticYellowFrame|2816|
add_button_with_icon|win2|`wWin 2|staticYellowFrame|2818|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]
        dialog(control)
    end

    showCSNController()
    return true
end

if packet:find("buttonClicked|scangems") then
    -- Scan Gems menggunakan scan Kiri/Kanan/Total dan menampilkan hasil ke TalkBubble.
    -- Tombol Put Block 340 tetap dihapus dan tidak dipanggil.
    local leftGems, rightGems, totalGems = scanGems()
    lastGemLeft = leftGems
    lastGemRight = rightGems
    lastGemTotal = totalGems

    log("`2Scan Gems: KIRI=`9"..leftGems.." `2| KANAN=`9"..rightGems.." `2| TOTAL=`9"..totalGems)
    ont("`2Scan Gems: Left `9"..leftGems.." `2| Right `9"..rightGems.." `2| Total `9"..totalGems)

    control = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wCSN Controller     ````      |left|758|
add_spacer|small|
add_textbox|Earned: `$]]..earned..[[ World Lock|
add_textbox|Current Tax: `$]]..stax..[[%|
add_textbox|Current Bet: `$]]..Aount..[[ World Lock|
add_textbox|Gems Left: `9]]..lastGemLeft..[[|
add_textbox|Gems Right: `9]]..lastGemRight..[[|
add_textbox|Gems Total: `9]]..lastGemTotal..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|tke|`wTake Lock|staticYellowFrame|2814|
add_button_with_icon|scangems|`wScan Gems|staticYellowFrame|112|
add_button_with_icon|win1|`wWin 1|staticYellowFrame|2816|
add_button_with_icon|win2|`wWin 2|staticYellowFrame|2818|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]
    dialog(control)
    return true
end

if packet:find("buttonClicked|tke") then
    -- Take Lock di posisi Pos1 dan Pos2, mengikuti referensi controller.
    function tp1()
        for _, obj in pairs(GetObjectList()) do
            if x1 == math.floor(obj.posX / 32) and y1 == math.floor(obj.posY / 32) then
                if obj.itemid == 242 then
                    wear(242)
                end
                pkt = {}
                pkt.px = x1
                pkt.py = y1
                pkt.type = 11
                pkt.value = obj.id
                pkt.x = obj.posX
                pkt.y = obj.posY
                SendPacketRaw(false, pkt)
            end
        end
    end

    function tp2()
        for _, obj in pairs(GetObjectList()) do
            if x2 == math.floor(obj.posX / 32) and y2 == math.floor(obj.posY / 32) then
                pkt = {}
                pkt.px = x2
                pkt.py = y2
                pkt.type = 11
                pkt.value = obj.id
                pkt.x = obj.posX
                pkt.y = obj.posY
                SendPacketRaw(false, pkt)
                if obj.itemid == 242 and obj.amount >= 100 then
                    wear(242)
                end
            end
        end
    end

    tp1()
    tp2()
    ont("Collected Pos1 and Pos2")
    return true
end

if packet:find("buttonClicked|win1") then
    tax = stax
    jl = math.floor(tax / 100 * Aount * 2)
    jumlah = math.floor(Aount * 2 - jl)
    earnedwls = Aount * 2 - jumlah
    earned = earned + earnedwls
    bgl = math.floor(jumlah / 10000)
    jumlah = jumlah - bgl * 10000
    dl = math.floor(jumlah / 100)
    wl = jumlah % 100
    earnedwl = ("`2Earn `9+"..earnedwls.." `2World Lock.")
    if inv(242) <= wl then
        wear(1796)
    end
    v = {}
    v.v1 = "OnTalkBubble"
    v.v2 = GetLocal().netID
    v.v3 = earnedwl
    v.v5 = 1
    log(earnedwl)
    SendVariant(v)
    path(x1 - 2, y1)
    if wl ~= 0 then rdrop(242, wl) end
    if dl ~= 0 then rdrop(1796, dl) end
    if bgl ~= 0 then rdrop(7188, bgl) end

    local control = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wCSN Controller     ````      |left|758|
add_spacer|small|
add_textbox|Earned: `$]]..earned..[[ World Lock|
add_textbox|Current Tax: `$]]..stax..[[%|
add_textbox|Current Bet: `$]]..Aount..[[ World Lock|
add_textbox|Gems Left: `9]]..lastGemLeft..[[|
add_textbox|Gems Right: `9]]..lastGemRight..[[|
add_textbox|Gems Total: `9]]..lastGemTotal..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|tke|`wTake Lock|staticYellowFrame|2814|
add_button_with_icon|scangems|`wScan Gems|staticYellowFrame|112|
add_button_with_icon|win1|`wWin 1|staticYellowFrame|2816|
add_button_with_icon|win2|`wWin 2|staticYellowFrame|2818|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]
    dialog(control)
    return true
end

if packet:find("buttonClicked|win2") then
    tax = stax
    jl = math.floor(tax / 100 * Aount * 2)
    jumlah = math.floor(Aount * 2 - jl)
    earnedwls = Aount * 2 - jumlah
    earned = earned + earnedwls
    bgl = math.floor(jumlah / 10000)
    jumlah = jumlah - bgl * 10000
    dl = math.floor(jumlah / 100)
    wl = jumlah % 100
    earnedwl = ("`2Earn `9+"..earnedwls.." `2World Lock.")
    if inv(242) < wl then
        wear(1796)
    end
    v = {}
    v.v1 = "OnTalkBubble"
    v.v2 = GetLocal().netID
    v.v3 = earnedwl
    v.v5 = 1
    log(earnedwl)
    SendVariant(v)
    path(x2 + 1, y2)
    if wl ~= 0 then rdrop(242, wl) end
    if dl ~= 0 then rdrop(1796, dl) end
    if bgl ~= 0 then rdrop(7188, bgl) end

    Aount2 = 0
    local control = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wCSN Controller     ````      |left|758|
add_spacer|small|
add_textbox|Earned: `$]]..earned..[[ World Lock|
add_textbox|Current Tax: `$]]..stax..[[%|
add_textbox|Current Bet: `$]]..Aount..[[ World Lock|
add_textbox|Gems Left: `9]]..lastGemLeft..[[|
add_textbox|Gems Right: `9]]..lastGemRight..[[|
add_textbox|Gems Total: `9]]..lastGemTotal..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|tke|`wTake Lock|staticYellowFrame|2814|
add_button_with_icon|scangems|`wScan Gems|staticYellowFrame|112|
add_button_with_icon|win1|`wWin 1|staticYellowFrame|2816|
add_button_with_icon|win2|`wWin 2|staticYellowFrame|2818|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]
    dialog(control)
    return true
end

if packet:find("buttonClicked|cplay") then
cplay = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wPlayer Controller    ````  |left|10864|
add_smalltext|Recommend to use ModFly|
add_smalltext|ModFly ]]..modflai..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|ml|`wMove Left|staticYellowFrame|5672|
add_button_with_icon|mr|`wMove Right|staticYellowFrame|5674|
add_button_with_icon|mu|`wMove Up|staticYellowFrame|5676|
add_button_with_icon|md|`wMove Down|staticYellowFrame|5678|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|menter|`wEnter Door|staticYellowFrame|5680|
add_button_with_icon|modflai|`wModFly|staticYellowFrame|1822|
add_button_with_icon|nspeed|`w+ Speed (]]..nmove..[[)|staticYellowFrame|2322|
add_button_with_icon|dspeed|`w- Speed(]]..nmove..[[)|staticYellowFrame|2628|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]

dialog(cplay)
return true
end

if packet:find("buttonClicked|ml") then
x = math.floor(GetLocal().posX / 32)
y = math.floor(GetLocal().posY / 32)
FindPath(x - nmove, y)
dialog(cplay)
ont("Going to `2"..(x - nmove).."`w, `2"..y)
return true
end

if packet:find("buttonClicked|mr") then
x = math.floor(GetLocal().posX / 32)
y = math.floor(GetLocal().posY / 32)
FindPath(x + nmove, y)
dialog(cplay)
ont("Going to `2"..(x + nmove).."`w, `2"..y)
return true
end

if packet:find("buttonClicked|mu") then
x = math.floor(GetLocal().posX / 32)
y = math.floor(GetLocal().posY / 32)
FindPath(x, y - nmove)
dialog(cplay)
ont("Going to `2"..x.."`w, `2"..(y - nmove))
return true
end

if packet:find("buttonClicked|md") then
x = math.floor(GetLocal().posX / 32)
y = math.floor(GetLocal().posY / 32)
FindPath(x, y + nmove)
dialog(cplay)
ont("Going to `2"..x.."`w, `2"..(y + nmove))
return true
end

if packet:find("buttonClicked|menter") then
function enter()
pkt = {}
pkt.type = 7;
pkt.px = math.floor(GetLocal().posX / 32);
pkt.py = math.floor(GetLocal().posY / 32);
SendPacketRaw(false, pkt)
end

enter()
dialog(cplay)
ont("Entering `2Door`w..")
return true
end

if packet:find("buttonClicked|modflai") then
if modflai == "`4Disabled" then
modflai = "`2Enabled"
EditToggle("ModFly", true)
else
modflai = "`4Disabled"
EditToggle("ModFly", false)
end
cplay = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wPlayer Controller    ````  |left|10864|
add_smalltext|Recommend to use ModFly|
add_smalltext|ModFly ]]..modflai..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|ml|`wMove Left|staticYellowFrame|5672|
add_button_with_icon|mr|`wMove Right|staticYellowFrame|5674|
add_button_with_icon|mu|`wMove Up|staticYellowFrame|5676|
add_button_with_icon|md|`wMove Down|staticYellowFrame|5678|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|menter|`wEnter Door|staticYellowFrame|5680|
add_button_with_icon|modflai|`wModFly|staticYellowFrame|1822|
add_button_with_icon|nspeed|`w+ Speed (]]..nmove..[[)|staticYellowFrame|2322|
add_button_with_icon|dspeed|`w- Speed(]]..nmove..[[)|staticYellowFrame|2628|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]

dialog(cplay)
return true
end

if packet:find("buttonClicked|nspeed") then
nmove = nmove + 1

cplay = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wPlayer Controller    ````  |left|10864|
add_smalltext|Recommend to use ModFly|
add_smalltext|ModFly ]]..modflai..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|ml|`wMove Left|staticYellowFrame|5672|
add_button_with_icon|mr|`wMove Right|staticYellowFrame|5674|
add_button_with_icon|mu|`wMove Up|staticYellowFrame|5676|
add_button_with_icon|md|`wMove Down|staticYellowFrame|5678|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|menter|`wEnter Door|staticYellowFrame|5680|
add_button_with_icon|modflai|`wModFly|staticYellowFrame|1822|
add_button_with_icon|nspeed|`w+ Speed (]]..nmove..[[)|staticYellowFrame|2322|
add_button_with_icon|dspeed|`w- Speed(]]..nmove..[[)|staticYellowFrame|2628|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]

dialog(cplay)
return true
end

if packet:find("buttonClicked|dspeed") then
if nmove < 2 then
nmove = 1
else
nmove = nmove - 1
end

cplay = [[
set_default_color|`o
add_quick_exit|
add_label_with_icon|big|`wPlayer Controller    ````  |left|10864|
add_smalltext|Recommend to use ModFly|
add_smalltext|ModFly ]]..modflai..[[|
add_spacer|small|
text_scaling_string|SubstoIptxtxD|
add_button_with_icon|ml|`wMove Left|staticYellowFrame|5672|
add_button_with_icon|mr|`wMove Right|staticYellowFrame|5674|
add_button_with_icon|mu|`wMove Up|staticYellowFrame|5676|
add_button_with_icon|md|`wMove Down|staticYellowFrame|5678|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|menter|`wEnter Door|staticYellowFrame|5680|
add_button_with_icon|modflai|`wModFly|staticYellowFrame|1822|
add_button_with_icon|nspeed|`w+ Speed (]]..nmove..[[)|staticYellowFrame|2322|
add_button_with_icon|dspeed|`w- Speed(]]..nmove..[[)|staticYellowFrame|2628|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|bk1|`wBack|
]]

dialog(cplay)
return true
end

-------------------------------------
--End of Hook
-------------------------------------
return false
end

-------------------------------------
--On Variant
-------------------------------------
function var(var)


if fastdrop == true then
if var.v1:find("OnDialogRequest") and var.v2:find("drop_item") then
fdro1 = var.v2:match("count||(%d+)|")
fdro2 = var.v2:match("itemID|(%d+)")
if mode == "rgt" then
rdrop(fdro2, fdro1)
else
cdrop(fdro2, fdro1)
end
growtopia.notify("`7[ `9Dropped "..fdro2.." `7]")
return true
end
end

if realfake == true then
if var.v1:find("OnTalkBubble") and var.v3:find("spun the whee") then
uidplayer = var.v2
spintext = var.v3
return true
end

if var.v1:find("OnConsoleMessage") and var.v2:find("<") and var.v2:find(">") and var.v2:find("spun the whee") then
v = {}
v.v1 = "OnTalkBubble"
v.v2 = uidplayer
v.v3 = ("`7[`4FAKE`7] `w"..spintext.."")
SendVariant(v)
LogToConsole(""..var.v2.." `7[`4FAKE`7]")
return true
end

if var.v1:find("OnConsoleMessage") and var.v2:find("spun the whee") then
v = {}
v.v1 = "OnTalkBubble"
v.v2 = uidplayer
v.v3 = ("`7[`2REAL`7] `w"..spintext.."")
SendVariant(v)
LogToConsole("`7[`2REAL`7] `$`w"..spintext.."")
return true
end
end --end of fake/real wheel

-- CASINO MODE + SPIN LOG
-- Support colored GTPS wheel messages on both TalkBubble and ConsoleMessage.
local function getGrowIDByNetID(netid)
    netid = tonumber(netid)
    if not netid or type(GetPlayerList) ~= "function" then return nil end
    local ok, list = pcall(GetPlayerList)
    if not ok or type(list) ~= "table" then return nil end
    for _, player in pairs(list) do
        local pid = tonumber(player.netID or player.netid)
        if pid == netid then
            return tostring(player.name or player.displayName or player.growid or "Unknown")
        end
    end
    return nil
end

if var.v1 and (var.v1:find("OnTalkBubble", 1, true) or var.v1:find("OnConsoleMessage", 1, true)) then
    local msg = tostring(var.v3 or var.v2 or "")
    local lowmsg = msg:lower()

    if lowmsg:find("spun the wheel", 1, true) then
        -- Remove Growtopia color/control marks only for parsing.
        local clean = msg:gsub("`.", "")
        local num = clean:match("spun the wheel and got%s*[%<%[]?%s*(%d+)")
            or clean:match("spun the wheel and got%s+(%d+)")
            or clean:match("wheel%s+and%s+got%s+(%d+)")
            or clean:match("got%s*[:%-]?%s*(%d+)")

        if num then
            local result, label = getModeResult(num)

            -- Simpan GrowID, bukan netID/message mentah.
            local player
            if var.v1:find("OnTalkBubble", 1, true) then
                player = getGrowIDByNetID(var.v2)
            else
                -- ConsoleMessage biasanya berbentuk: <GrowID> spun the wheel...
                player = clean:match("^%s*<?([^<>]-)>?%s+spun%s+the%s+wheel")
            end
            player = tostring(player or "Unknown")
            -- Console/TalkBubble kadang membawa warna + bracket berlapis,
            -- misalnya `9[[GrowID]]. Simpan hanya GrowID mentah.
            player = player:gsub("`.", "")
            player = player:gsub("^%s+", ""):gsub("%s+$", "")
            player = player:gsub("[%[%]<>]", "")
            player = player:gsub("^%s+", ""):gsub("%s+$", "")
            if player == "" then player = "Unknown" end

            local spinWorld = tostring(GetWorldName() or "UNKNOWN")
            local spinSig = player .. "|" .. tostring(num) .. "|" .. spinWorld
            local spinNow = os.clock()
            local spinAge = spinNow - (lastSpinLogAt or 0)
            local sameResult = (lastSpinLogSig == spinSig)
            local lastSpinPlayer = tostring(lastSpinLogSig or ""):match("^(.-)|") or ""
            -- GTPS bisa mengirim 1 hasil melalui TalkBubble lalu ConsoleMessage.
            -- Jika salah satu event belum bisa resolve GrowID, tetap anggap event
            -- tersebut duplikat selama angka+world sama dalam window singkat.
            local sameNumWorld = tostring(lastSpinLogSig or ""):find("|"..tostring(num).."|"..spinWorld, 1, true) ~= nil
            -- Bila salah satu sumber event tidak berhasil resolve GrowID,
            -- angka + world dipakai sebagai fingerprint event yang sama.
            local sameResultFallback = (spinAge < 1.0 and sameNumWorld
                and (player == "Unknown" or lastSpinPlayer == "Unknown"))
            local isDuplicateSpin = (spinAge < 1.5 and sameResult) or sameResultFallback

            if not isDuplicateSpin then
                lastSpinLogSig = spinSig
                lastSpinLogAt = spinNow
                table.insert(spinLogs, 1, {player=player, number=tonumber(num) or 0, mode=label, result=result, world=spinWorld, time=os.date("%H:%M:%S")})
                while #spinLogs > 100 do table.remove(spinLogs) end
            end

            if var.v1:find("OnTalkBubble", 1, true) and not isDuplicateSpin then
                local out = "`5[lumna.proxy] `w| "..msg.." `5["..label.." `9"..result.."`5]"
                SendVariant({v1="OnTalkBubble", v2=var.v2, v3=out, v5=1})
            end

            if not isDuplicateSpin then
                LogToConsole(systemlog.."SPIN "..num.." | "..label.." => "..result)
            end
            return true
        end
    end
end

if var.v1:find("OnDialogRequest") then
    local d = var.v2 or ""
    local lowd = d:lower()

    -- Log dialog buttons are handled in pkt()/OnSendPacket, matching the supplied V2 reference.
    -- Telephone ID 3898: auto call 53785 -> Blue Gem Lock -> Thank you -> Hang Up.
    -- Diproses TERLEBIH DAHULU agar tidak masuk ke handler Door.
    if waitingTelephoneDialog and autoTelephone(d) then
        return true
    end

    -- Hanya simpan dialog yang datang setelah Wrench, atau dialog yang jelas
    -- merupakan Door/Forcefield. Jangan mengganggu dialog lain.
    if waitingWrenchDialog or lowd:find("usable by public", 1, true)
        or lowd:find("forcefield", 1, true) then
        lastWrenchDialog = d

        local tx, ty = getDialogTile(d, wrenchTarget.x, wrenchTarget.y)
        if tx and ty then
            setWrenchTarget(tx, ty)
            setDoorTarget(tx, ty)
        end

        if waitingWrenchDialog and autoDoorAccess(d) then
            return true
        end
    end
end

if var.v1:find("OnConsoleMessage") and var.v2 then
    local cm = tostring(var.v2)
    local cleanCM = cm:gsub("`[0-9a-zA-Z]", "")

    -- LOCK COLLECT/DROP: parse the actual server console message.
    -- Supports formats such as:
    -- Collected 5 World Lock. in WORLD
    -- Dropped 5 World Lock.
    local lockAmount, lockID, lockName, lockAction

    local function parseLockMessage(text, actionWord)
        local amount, name, id
        amount = text:match(actionWord .. "%s+%+?(%d+)%s+World%s+Lock%f[%p%s]")
        if amount then return tonumber(amount), "World Lock", 242 end
        amount = text:match(actionWord .. "%s+%+?(%d+)%s+Diamond%s+Lock%f[%p%s]")
        if amount then return tonumber(amount), "Diamond Lock", 1796 end
        amount = text:match(actionWord .. "%s+%+?(%d+)%s+Blue%s+Gem%s+Lock%f[%p%s]")
        if amount then return tonumber(amount), "Blue Gem Lock", 7188 end
        return nil, nil, nil
    end

    -- DROP: tetap dicatat dari ConsoleMessage.
    lockAmount, lockName, lockID = parseLockMessage(cleanCM, "Dropped")
    if lockAmount then lockAction = "drop" end

    if lockAmount and lockID and lockAction then
        local sig = lockAction .. "|" .. tostring(lockID) .. "|" .. tostring(lockAmount)
        local now = os.clock()
        if not (lastCollectedLockSig == sig and (now - (lastCollectedLockAt or 0)) < 1.5) then
            lastCollectedLockSig = sig
            lastCollectedLockAt = now
            -- sendLockChat() mencatat satu entry log untuk event ini.
            sendLockChat(lockAction, lockID, lockAmount)
        end
    end

    -- COLLECT: berlaku untuk pickup manual maupun pickup dari punch ID 1422.
    -- Public text hanya dikirim dari event server ini supaya tidak double.
    local collectedAmount, collectedName, collectedID = parseLockMessage(cleanCM, "Collected")
    if collectedAmount and collectedID then
        local now = os.clock()
        local sig = "take|" .. tostring(collectedID) .. "|" .. tostring(collectedAmount)
        if not (lastCollectedLockSig == sig and (now - (lastCollectedLockAt or 0)) < 1.5) then
            lastCollectedLockSig = sig
            lastCollectedLockAt = now
            -- sendLockChat() juga mencatat satu entry log; jangan pushLog kedua kali.
            sendLockChat("take", collectedID, collectedAmount)
        end
        lockCollectArmed = false
    end

    -- GEMS: aggregate the server's +N Gems message as ONE log entry.
    -- Never create a log entry for each individual gem object.
    local gemAmount = cleanCM:match("Collected%s+%+?(%d+)%s+Gems?%f[%p%s]")
        or cleanCM:match("Collected%s+Gems?%s*%+?(%d+)%f[%p%s]")
        or cleanCM:match("Collected%s+%+?(%d+)%s+Gems?%.?")
    if gemAmount then
        gemAmount = tonumber(gemAmount) or 0
        if gemAmount > 0 then
            local sig = tostring(gemAmount) .. "|" .. tostring(GetWorldName())
            local now = os.clock()
            if not (lastGemLogSig == sig and (now - (lastGemLogAt or 0)) < 0.5) then
                lastGemLogSig = sig
                lastGemLogAt = now
                table.insert(gemsLogs, 1, {
                    growid = (GetLocal() and GetLocal().name) or "UNKNOWN",
                    amount = gemAmount,
                    world = GetWorldName(),
                    time = os.date("%H:%M:%S")
                })
                while #gemsLogs > 100 do table.remove(gemsLogs) end
                pendingGemLogAmount = 0
                pendingGemLogWorld = nil
                sendGemChat(gemAmount)
            end
        end
    end
end

if var.v1:find("OnConsoleMessage") then
LogToConsole(""..systemlog.." ".. var.v2)
return true
end


-------------------------------------
--End Of Variant
-------------------------------------
return false
end



function pkt(str)
    -- Wrench Door: tanpa teleport.
    if handleWrenchUse(str) then
        return true
    end

    -- Teleport terpisah menggunakan ID 6336.
    if handleTeleportUse(str) then
        return true
    end

    -- Punch ID 1422: auto collect WL/DL/BGL tanpa teleport.
    handleLockTrigger(str)

local rawGemPacket = false
if str.type == 11 and type(GetObjectList) == "function" then
    -- Direct pickup fallback hanya aktif sesaat setelah punch ID 1422 dan
    -- hanya untuk object pada tile yang sama.
    if lockCollectArmed and (os.clock() - (lockCollectArmAt or 0)) <= 1.5
        and lockTriggerX ~= nil and lockTriggerY ~= nil then
        for _, lockObj in pairs(GetObjectList()) do
            if lockObj.id == str.value then
                local lockItem = tonumber(lockObj.itemid)
                local ox = math.floor((tonumber(lockObj.posX) or 0) / 32)
                local oy = math.floor((tonumber(lockObj.posY) or 0) / 32)
                if (lockItem == 242 or lockItem == 1796 or lockItem == 7188)
                    and ox == lockTriggerX and oy == lockTriggerY then
                    local lockAmount = tonumber(lockObj.amount) or 0
                    if lockAmount > 0 then
                        local oid = tostring(lockObj.id)
                        local now = os.clock()
                        if not (oid == lastRawLockObjectId and (now - (lastRawLockObjectAt or 0)) < 0.5) then
                            lastRawLockObjectId = oid
                            lastRawLockObjectAt = now
                            -- Teks Collected akan diproses dari OnConsoleMessage server.
                            -- Jangan kirim lagi dari raw pickup agar tidak double.
                        end
                    end
                end
            end
        end
        lockCollectArmed = false
    end

    for _, obj in pairs(GetObjectList()) do
        if obj.id == str.value then
            local itemID = tonumber(obj.itemid)
            if itemID == 112 then
                rawGemPacket = true
                local amount = tonumber(obj.amount) or 0
                if amount > 0 then
                    cg = (tonumber(cg) or 0) + amount
                    pendingGemLogAmount = (tonumber(pendingGemLogAmount) or 0) + amount
                    pendingGemLogWorld = GetWorldName()

                    v = {}
                    v.v1 = "OnTalkBubble"
                    v.v2 = GetLocal().netID
                    v.v3 = ("`2Collected `9+"..cg.." `2Gems.")
                    v.v5 = 1
                    SendVariant(v)
                else
                    v = {}
                    v.v1 = "OnTalkBubble"
                    v.v2 = GetLocal().netID
                    v.v3 = ("`4Error when Check Collected Gems.")
                    SendVariant(v)
                end
            end
        end
    end
end

-- Flush the burst once the raw gem pickup sequence ends. This avoids one log
-- entry per gem object while still recording the actual collected amount.
if str.type == 0 then
flushPendingGemLog()
if tonumber(cgcek) > tonumber(cgset) then
cg = 0
cgset = cgset
else
cgcek = cgcek + 1
end
end
if not rawGemPacket then
    flushPendingGemLog()
end
return false
end

-------------------------------------
--AddHook
-------------------------------------

AddHook(pkt, "OnSendPacketRaw")
AddHook(on_sendpacket, "OnSendPacket")
AddHook(var, "OnVariant")


LogToConsole("`4[lumna.proxy] Script By `2lumna.proxy.")
LogToConsole("`4[lumna.proxy] Script is now Successfully Running.")
