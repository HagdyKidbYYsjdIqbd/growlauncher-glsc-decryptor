local TAG = "JimiProxy"
local VERSION = "v1.8-r0"
-- Banner: halloween / winter / thanksgiving / blackfriday
local BANNER_SEASON = "thanksgiving"
local OWNER = "Jimi"
local DISCORD = "@hi_jimi"
local DC_LINK = "https://discord.gg/JuMxXMMpw3"
local WA_LINK = "https://chat.whatsapp.com/IQk004d5FJo6XI8MoOaqIG"
local WEB_LINK = "https://hijimi.site"
local LAST_UPDATED = "11-11-2026"
local NEWS = {
    "+ add Native Tabs UI",
    "+ add Settings",
    "+ add Config Profiles",
    "+ add Custom Hotkeys",
    "+ add Calculator /c",
    "+ add Pull Tile PT1-PT4",
    "+ add Role Skins",
    "+ add Blink Skin",
    "+ add Anti Troll",
    "+ add Seasonal Banners",
    "+ add BTK Mode",
    "+ add Decimal Tax",
    "+ add /streammode",
    "+ add Follow Other Player Chat",
    "+ add /mods",
    "~ rework /logs",
    "~ rework Gem Number",
    "~ rework Role/Title",
    "~ fix /cv",
    "- delete /g1-/g6",
    "- delete /s"
}
local WL_ID, DL_ID, BGL_ID = 242, 1796, 7188
local TELEPHONE_ID = 3898
local GEM_ID, MAX_GEMS = 112, 21
local LOGS_ICON = 3524
local NEWS_ICON = 1752
local WRENCH_ICON = 32
local SPAM_ICON = 2586
local NICK_ICON = 1794
local SEARCH_ICON = 6016 
local FEATURED_ICON = 14514
local MORE_ICON = 32
local locks = {
    {id = BGL_ID, short = "BGL", name = "Blue Gem Lock", value = 10000},
    {id = DL_ID, short = "DL", name = "Diamond Lock", value = 100},
    {id = WL_ID, short = "WL", name = "World Lock", value = 1}
}
local rouletteMode = "REME"
local consoleWatermark = false
local bubbleRoulette = true
local innerVariant, innerPacket = 0, 0
local converting = false
local cvSignal = 0
local cvLastError = ""
local wheelLogs, dropLogs, sbLogs, bjGemLogs = {}, {}, {}, {}
local worldLogs, playerJoinLogs, playerLeaveLogs = {}, {}, {}
local vendingLogs, walletLogs, lockDropLogs = {}, {}, {}
local wlDropLogs, dlDropLogs, bglDropLogs = {}, {}, {}
local playerLogNames, playerLogJoinAt = {}, {}
local recentSpin = {}
local pendingDrops = {}
local currentLogType = ""
local currentLogPage = 1
local LOG_PER_PAGE = 50
local BORDER_COLOR = "112,86,191,255"
local BG_COLOR = "43,34,74,200"
local selectedUITheme = "purple"
local fastMode = ""
local fastDrop = false
local fastTrash = false
local lastFastWrenchAt = 0
local FAST_WRENCH_COOLDOWN = 500
local blockPopupUntil = 0
local pendingWrench = {netid = 0, name = "", untilMs = 0}
local autoJoinMode = ""
local autoJoinQueue = {}
local autoJoinBusy = false
local autoJoinSeen = {}
local autoJoinReadyAt = 0
local autoJoinWorldSerial = 0
local AUTO_JOIN_ACTION_DELAY = 900
local AUTO_JOIN_DEDUPE_MS = 4000
local AUTO_JOIN_MAX_QUEUE = 8
local lastTPAt = 0
local TP_COOLDOWN = 650
local spamActive = false
local spamText = ""
local spamDelay = 1200
local spamSerial = 0
local spamColorIndex = 1
local spamColorChat = true
local spamColors = {"`2", "`3", "`5", "`6", "`9", "`c", "`e", "`b"}
local nickReal = ""
local nickName = ""
local lastWheelNumber = nil

local manualGemLast = nil
local manualGemPending = 0
local manualGemToken = 0
local manualGemSampleToken = 0
local manualGemSuppressUntil = 0
local MANUAL_GEM_BATCH = 500

local function suppressManualGemPickup(delay)
    delay = tonumber(delay) or 900

    local now = 0

    if type(getTime) == "function" then
        local ok, value = pcall(getTime)
        if ok and type(value) == "number" then
            now = value
        end
    end

    if now == 0 then
        now = (os.clock() or 0) * 1000
    end

    local untilAt = now + delay

    if untilAt > manualGemSuppressUntil then
        manualGemSuppressUntil = untilAt
    end
end

local greenBoxToken = 0
local GREENBOX_LIFETIME = 5000

local function clearGreenBox(token)
    runThread(function()
        sleep(GREENBOX_LIFETIME)

        if token ~= greenBoxToken then
            return
        end

        pcall(function()
            sendPacketRaw(true, {
                type = 38,
                netid = 0
            })
        end)
    end)
end

local function greenBox(x, y)
    x = math.floor(tonumber(x) or -1)
    y = math.floor(tonumber(y) or -1)
    if x < 0 or y < 0 then return false end

    local encoded = tonumber(string.format("%02d%02d", y, x))
    if not encoded then return false end

    greenBoxToken = greenBoxToken + 1
    local token = greenBoxToken

    local ok = pcall(function()
        sendPacketRaw(true, {
            type = 38,
            netid = encoded
        })
    end)

    if ok then
        clearGreenBox(token)
    end

    return ok
end
local selectedTitle = "original"
selectedRoleID = 6
activityLogging = true
hotkeyMode = "shortcut"
blinkActive = false
blinkToken = 0
blinkDefaultSkin = 3370516479
buttonHotkeyRecording = false
buttonHotkeySlot = 0
buttonHotkeyTemp = ""

local selectedWeather = nil
local lastServerWeather = nil
local weatherIconCache = {}
local recentSpinBubble = {}
local BUBBLE_MAX_X_TILES = 16
local BUBBLE_MAX_Y_TILES = 7
local WEATHER_ICON = 932
local TITLE_ICON = 6276
local PROFILE_ICON = 1794

JimiProxyExt = {}
JimiProxyExt.inventoryTxn = ""
JimiProxyDelay = {
    drop = 180,
    fastWrench = 80,
    autoWrench = AUTO_JOIN_ACTION_DELAY,
    blink = 180,
    spam = 1200,
    tp = 650,
    max = 60000,
    fastDropKey = "",
    fastDropAt = 0
}

local UI_THEMES = {
    red =    {name = "Red",    color = "`4", border = "205,78,90,255",  bg = "74,30,38,220",  desc = "Tema merah."},
    purple = {name = "Default+", color = "`5", border = "112,86,191,255", bg = "43,34,74,200",  desc = "Default JimiProxy."},
    blue =   {name = "Blue", color = "`1", border = "55,170,245,255", bg = "24,58,94,220",  desc = "Biru klasik JimiProxy."},
    yellow = {name = "Yellow", color = "`e", border = "240,201,72,255", bg = "82,70,24,220",  desc = "Tema kuning terang."},
    green =  {name = "Green",  color = "`2", border = "74,194,118,255", bg = "27,72,54,220",  desc = "Tema hijau."},
    black =  {name = "Black",  color = "`0", border = "95,105,120,255", bg = "18,18,23,225", desc = "Tema gelap simpel."}
}
local UI_THEME_ORDER = {"red", "purple", "blue", "yellow", "green", "black"}

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
    return nil
end

local function trim(s)
    s = tostring(s or "")
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local function strip(s)
    return tostring(s or ""):gsub("`.", "")
end

local function cleanDialog(s)
    s = tostring(s or ""):gsub("|", "/"):gsub("\r", " "):gsub("\n", " ")
    s = s:gsub("%s+", " ")
    return trim(s)
end

local function cut(s, n)
    s = cleanDialog(s)
    n = tonumber(n) or 70
    if #s <= n then return s end
    return s:sub(1, n - 3) .. "..."
end

local function ms()
    local t = safe(getTime)
    if type(t) == "number" then return t end
    return math.floor((os.clock() or 0) * 1000)
end

local function stamp()
    local ok, s = pcall(function() return os.date("%H:%M:%S") end)
    if ok and type(s) == "string" then return s end
    return tostring(math.floor(ms() / 1000)) .. "s"
end

local function push(t, v, max)
    table.insert(t, 1, v)
    while #t > (max or 120) do table.remove(t) end
end

local function worldName()
    local w = safe(GetWorldName) or safe(getCurrentWorldName) or "UNKNOWN"
    w = strip(w)
    if w == "" then w = "UNKNOWN" end
    return w
end

local function localPlayer()
    return safe(getLocal)
end

local function myName()
    local p = localPlayer()
    local n = strip((p and p.name) or "Jimi"):gsub("^@", "")
    n = trim(n)
    if n == "" then n = "Jimi" end
    return n
end

local function myNetID()
    local p = localPlayer()
    return tonumber(p and (p.netID or p.netid)) or 0
end

local function sendVar(v)
    innerVariant = innerVariant + 1
    pcall(function() sendVariant(v) end)
    innerVariant = innerVariant - 1
end

local function sendNameVar(v, id)
    innerVariant = innerVariant + 1
    if id then
        pcall(function() sendVariant(v, tonumber(id)) end)
    else
        pcall(function() sendVariant(v) end)
    end
    innerVariant = innerVariant - 1
end

local function sendConsole(text)
    text = tostring(text or "")
    if JimiProxyStream and JimiProxyStream.enabled and type(JimiProxyStream.redact) == "function" then
        text = JimiProxyStream.redact(text)
    end
    sendVar({v1 = "OnConsoleMessage", v2 = text})
end

local function prefix()
    return "`9[`6" .. TAG .. "`9] `w"
end

local function say(text)
    sendConsole(prefix() .. tostring(text or ""))
end

local function bubble(text, netid)
    text = tostring(text or "")
    if JimiProxyStream and JimiProxyStream.enabled and type(JimiProxyStream.redact) == "function" then
        text = JimiProxyStream.redact(text)
    end
    sendVar({v1 = "OnTalkBubble", v2 = tonumber(netid) or myNetID(), v3 = text, v4 = 1})
end

local function overlay(text)
    -- Keep feedback in console only; JimiProxy does not use center-screen text overlays.
    sendConsole(prefix() .. tostring(text or ""))
end

local function packet2(text)
    innerPacket = innerPacket + 1
    pcall(function() sendPacket(2, tostring(text or "")) end)
    innerPacket = innerPacket - 1
end

local function itemCount(id)
    id = tonumber(id) or 0
    if growtopia and type(growtopia.checkInventoryCount) == "function" then
        local c = safe(growtopia.checkInventoryCount, id)
        if type(c) == "number" then return c end
    end
    local inv = safe(getInventory)
    local total = 0
    if type(inv) == "table" then
        for _, it in pairs(inv) do
            local iid = tonumber(it.id or it.id_ or it.itemID or it.itemid)
            if iid == id then total = total + (tonumber(it.amount or it.count or it.count_ or 0) or 0) end
        end
    end
    return total
end

local function lockInfo(id)
    for _, l in ipairs(locks) do
        if l.id == tonumber(id) then return l end
    end
    return {id = tonumber(id) or 0, short = "ITEM", name = "Item", value = 0}
end

local function valueText(value)
    value = math.floor(tonumber(value) or 0)
    local bgl = math.floor(value / 10000)
    value = value % 10000
    local dl = math.floor(value / 100)
    local wl = value % 100
    local out = {}
    if bgl > 0 then table.insert(out, bgl .. " BGL") end
    if dl > 0 then table.insert(out, dl .. " DL") end
    if wl > 0 then table.insert(out, wl .. " WL") end
    if #out == 0 then return "0 WL" end
    return table.concat(out, " + ")
end

local function dialog(s)
    if JimiProxyExt.UI then JimiProxyExt.UI.suspend() end
    if JimiProxyStream and JimiProxyStream.enabled and type(JimiProxyStream.redactDialog) == "function" then
        s = JimiProxyStream.redactDialog(s)
    end
    if growtopia and type(growtopia.sendDialog) == "function" then
        growtopia.sendDialog(s)
    else
        sendVar({v1 = "OnDialogRequest", v2 = s})
    end
end

local function theme()
    return "set_border_color|"..BORDER_COLOR.."\nset_bg_color|"..BG_COLOR.."\nset_default_color|`9\n"
end

local function applyUITheme(key)
    local t = UI_THEMES[key]
    if not t then return false end
    selectedUITheme = key
    BORDER_COLOR = t.border
    BG_COLOR = t.bg
    return true
end

function JimiProxyExt.inventoryBusy()
    return tostring(JimiProxyExt.inventoryTxn or "") ~= ""
end

function JimiProxyExt.beginInventoryTxn(kind)
    if JimiProxyExt.inventoryBusy() then return false end
    JimiProxyExt.inventoryTxn = tostring(kind or "inventory")
    return true
end

function JimiProxyExt.endInventoryTxn(kind)
    kind = tostring(kind or "")
    if kind == "" or JimiProxyExt.inventoryTxn == kind then
        JimiProxyExt.inventoryTxn = ""
        return true
    end
    return false
end

local function playerNameByNetID(id)
    id = tonumber(id) or 0
    if id <= 0 then return "" end
    local p = safe(getPlayerByNetID, id)
    if type(p) == "table" then
        local n = strip(p.name or p.name_ or p.userName or ""):gsub("^@", "")
        if trim(n) ~= "" then return trim(n) end
    end
    local list = safe(getPlayerList)
    if type(list) == "table" then
        for _, pl in pairs(list) do
            local nid = tonumber(pl.netID or pl.netid or pl.net_id)
            if nid == id then
                local n = strip(pl.name or pl.name_ or pl.userName or ""):gsub("^@", "")
                if trim(n) ~= "" then return trim(n) end
            end
        end
    end
    return ""
end

local function playerByNetID(id)
    id = tonumber(id) or 0
    if id <= 0 then return nil end
    local p = safe(getPlayerByNetID, id)
    if type(p) == "table" then return p end
    local list = safe(getPlayerList)
    if type(list) == "table" then
        for _, pl in pairs(list) do
            local nid = tonumber(pl.netID or pl.netid or pl.net_id)
            if nid == id then return pl end
        end
    end
    return nil
end

local function playerTilePos(p)
    if type(p) ~= "table" then return nil, nil end
    local tx = tonumber(p.tileX or p.tile_x)
    local ty = tonumber(p.tileY or p.tile_y)
    if tx and ty then return tx, ty end
    local x = tonumber(p.posX or p.x or (p.pos and p.pos.x))
    local y = tonumber(p.posY or p.y or (p.pos and p.pos.y))
    if x and y then return x / 32, y / 32 end
    return nil, nil
end

function JimiProxyExt.profileNumber(value)
    value = math.floor(tonumber(value) or 0)
    local s = tostring(value)
    local sign = ""

    if s:sub(1, 1) == "-" then
        sign = "-"
        s = s:sub(2)
    end

    while true do
        local n
        s, n = s:gsub("^(%d+)(%d%d%d)", "%1,%2")
        if n == 0 then break end
    end

    return sign .. s
end

function JimiProxyExt.profileValue(p, ...)
    if type(p) ~= "table" then return nil end

    local keys = {...}
    for _, key in ipairs(keys) do
        local value = p[key]
        if value ~= nil and tostring(value) ~= "" then
            return value
        end
    end

    return nil
end

function JimiProxyExt.profilePlayerCount()
    local list = safe(getPlayerList)
    if type(list) ~= "table" then return 0 end

    local count = 0
    for _, player in pairs(list) do
        if type(player) == "table" then
            count = count + 1
        end
    end

    return count
end

function JimiProxyExt.profileBackpackUsed()
    local inv = safe(getInventory)
    if type(inv) ~= "table" then return 0 end

    local used = 0
    for _, item in pairs(inv) do
        if type(item) == "table" then
            local amount = tonumber(
                item.amount or
                item.count or
                item.count_ or
                item.amount_ or
                0
            ) or 0

            if amount > 0 then
                used = used + 1
            end
        end
    end

    return used
end

function JimiProxyExt.showProfile()
    local p = localPlayer() or {}

    local name = nickName ~= "" and nickName or myName()
    if JimiProxyStream and JimiProxyStream.enabled then name = "HIDDEN" end
    name = cleanDialog(strip(name):gsub("^@", ""))

    local userID = tonumber(p.userID or p.userId or p.userid or p.user_id)
    local netID = tonumber(p.netID or p.netid or p.net_id)

    local country = p.country
    if country == nil or tostring(country) == "" then
        country = "N/A"
    end

    local tx, ty = playerTilePos(p)

    if tx == nil then
        local px = tonumber(p.posX)
        if px then tx = px / 32 end
    end

    if ty == nil then
        local py = tonumber(p.posY)
        if py then ty = py / 32 end
    end

    local txText = tx ~= nil and tostring(math.floor(tx)) or "?"
    local tyText = ty ~= nil and tostring(math.floor(ty)) or "?"

    local gems = tonumber(safe(getGems)) or 0
    local players = JimiProxyExt.profilePlayerCount()
    local usedSlots = JimiProxyExt.profileBackpackUsed()

    local s = theme()
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Profile|left|" .. PROFILE_ICON .. "|\n"
    s = s .. "add_smalltext|`9Player information|\n"
    s = s .. "add_spacer|small|\n"

    s = s .. "add_textbox|`9Name      : `2" .. name .. "|left|\n"
    s = s .. "add_textbox|`9User ID   : `w" .. cleanDialog(userID or "N/A") .. "|left|\n"
    s = s .. "add_textbox|`9Net ID    : `w" .. cleanDialog(netID or "N/A") .. "|left|\n"
    s = s .. "add_textbox|`9Country   : `w" .. cleanDialog(country) .. "|left|\n"
    s = s .. "add_textbox|`9World     : `2" .. cleanDialog(worldName()) .. "|left|\n"
    s = s .. "add_textbox|`9Position  : `wX " .. txText .. "`8, `wY " .. tyText .. "|left|\n"
    s = s .. "add_textbox|`9Players   : `w" .. tostring(players) .. "|left|\n"
    s = s .. "add_spacer|small|\n"

    s = s .. "add_label_with_icon|small|`2Gems `w" .. JimiProxyExt.profileNumber(gems) .. "|left|" .. GEM_ID .. "|\n"
    s = s .. "add_label_with_icon|small|`2WL `w" .. JimiProxyExt.profileNumber(itemCount(WL_ID)) .. "|left|" .. WL_ID .. "|\n"
    s = s .. "add_label_with_icon|small|`2DL `w" .. JimiProxyExt.profileNumber(itemCount(DL_ID)) .. "|left|" .. DL_ID .. "|\n"
    s = s .. "add_label_with_icon|small|`2BGL `w" .. JimiProxyExt.profileNumber(itemCount(BGL_ID)) .. "|left|" .. BGL_ID .. "|\n"
    s = s .. "add_smalltext|`9Backpack Used : `2" .. tostring(usedSlots) .. " slots|\n"
    s = s .. "add_spacer|small|\n"

    s = s .. "add_label_with_icon|small|`2Version|left|9474|\n"
    s = s .. "add_smalltext|`9Script    : `2JimiProxy " .. VERSION .. "|\n"
    s = s .. "add_smalltext|`9Growlauncher : `2" .. tostring(safe(growlauncher and growlauncher.getVersion) or "Unavailable") .. "|\n"

    s = s .. "add_spacer|small|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|profile_close|Close||\n"

    dialog(s)
    return true
end

local function bubbleVisibleForNetID(id)
    id = tonumber(id) or 0
    if id <= 0 or id == myNetID() then return true end
    local me = localPlayer()
    local target = playerByNetID(id)
    if not me or not target then return true end
    local mx, my = playerTilePos(me)
    local tx, ty = playerTilePos(target)
    if not mx or not my or not tx or not ty then return true end
    return math.abs(tx - mx) <= BUBBLE_MAX_X_TILES and math.abs(ty - my) <= BUBBLE_MAX_Y_TILES
end

local function escPattern(s)
    return tostring(s):gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

local function nickPlayerList()
    local list = safe(getPlayerList)
    if type(list) == "table" then return list end
    return {}
end

local function nickLocalName()
    local p = localPlayer()
    local n = strip((p and p.name) or ""):gsub("^@", "")
    n = trim(n)
    if n ~= "" then return n end
    return myName()
end

local function nickNetID()
    local id = myNetID()
    if id > 0 then return id end
    local n = nickLocalName()
    for _, pl in pairs(nickPlayerList()) do
        if strip(pl.name or ""):gsub("^@", "") == n then
            id = tonumber(pl.netID or pl.netid or pl.net_id)
            if id then return id end
        end
    end
    return 0
end

local function nickBaseName()
    if nickName ~= "" then return nickName end
    if nickReal ~= "" then return nickReal end
    return nickLocalName()
end

local wheelRed = {
    [1]=true,[3]=true,[5]=true,[7]=true,[9]=true,[12]=true,[14]=true,[16]=true,[18]=true,
    [19]=true,[21]=true,[23]=true,[25]=true,[27]=true,[30]=true,[32]=true,[34]=true,[36]=true
}

local function wheelNumberColor(n)
    n = tonumber(n)
    if n == 0 then return "`2" end
    if n and wheelRed[n] then return "`4" end
    if n and n >= 1 and n <= 36 then return "`b" end
    return "`w"
end

local function nickVisualText()
    local suffix = ""
    if lastWheelNumber ~= nil then
        suffix = " `9[" .. wheelNumberColor(lastWheelNumber) .. tostring(lastWheelNumber) .. "`9]"
    end

    if selectedTitle == "legend" then
        local wheelBefore = ""
        if lastWheelNumber ~= nil then
            wheelBefore = "`9[" .. wheelNumberColor(lastWheelNumber) .. tostring(lastWheelNumber) .. "`9] "
        end
        return wheelBefore .. "`2" .. nickBaseName() .. " of Legend``"
    end

    local visual = "`2" .. nickBaseName() .. suffix
    if selectedTitle == "doctor" then
        visual = "`2Dr." .. nickBaseName() .. suffix
    end
    return visual
end

local function setVisualName(name)
    local id = nickNetID()
    if id <= 0 then return false end
    sendNameVar({v1 = "OnNameChanged", v2 = tostring(name or nickVisualText())}, id)
    return true
end

local function applyNick()
    if nickReal == "" then nickReal = nickLocalName() end
    if nickName == "" then nickName = nickReal end
    return setVisualName(nickVisualText())
end

local function nickReplace(text)
    if nickReal == "" or nickName == "" or nickReal == nickName then return text end
    text = tostring(text or "")
    text = text:gsub(escPattern(nickReal), nickName)
    text = text:gsub(escPattern(nickReal:lower()), nickName)
    return text
end

local function wheelNickName(name)
    local n = trim(strip(name or ""):gsub("^@", ""))
    if nickReal ~= "" and nickName ~= "" then
        local a = n:lower()
        if a == nickReal:lower() or a == nickName:lower() then
            return nickName
        end
    end
    return n
end

local function setNick(name)
    name = trim(name)
    if strip(name):gsub("%s+", "") == "" then say("`4Nickname cannot be empty."); return true end
    if nickReal == "" then nickReal = nickLocalName() end
    nickName = name
    if applyNick() then say("`2Nick: `w" .. strip(name)) else say("`4Nickname update failed.") end
    return true
end

local TITLES = {
    original = {name = "Original", state = "jo|", desc = "Restore original title."},
    master = {name = "Mentor", state = "jo|master", desc = "Show Mentor title."},
    g4g = {name = "Grow4Good", state = "jo|donor", desc = "Show Grow4Good title."},
    doctor = {name = "Dr.", state = "jo|doctor", desc = "Show Dr. title."},
    maxlevel = {name = "Level 125", state = "jo|maxLevel", desc = "Show Level 125 title."},
    animal = {name = "Animal", state = "jo|euphoriaTitle", desc = "Show Animal title."},
    legend = {name = "Of Legend", state = "jo|doctor", desc = "Show Of Legend title."}
}

local TITLE_ORDER = {"original", "master", "g4g", "doctor", "maxlevel", "animal", "legend"}

local WEATHER_DATA = {
[0]={"Sunny","Sunny",{"Weather Machine - Sunny"}},
[1]={"Beach Blast","Beach",{"Beach Blast"}},
[2]={"Night","Night",{"Weather Machine - Night"}},
[3]={"Arid","Arid",{"Weather Machine - Arid"}},
[4]={"Sunny Alt","Sunny2",{"Weather Machine - Sunny"}},
[5]={"Rainy City","Rainy",{"Weather Machine - Rainy City"}},
[6]={"Harvest Moon Blast","Harvest",{"Harvest Moon Blast"}},
[7]={"Mars Blast","Mars",{"Mars Blast"}},
[8]={"Spooky","Spooky",{"Weather Machine - Spooky"}},
[9]={"GrowGanoth","Ganoth",{"Weather Machine - Growganoth","Growganoth"}},
[10]={"Nothingness","Nothing",{"Weather Machine - Nothingness"}},
[11]={"Snowy","Snowy",{"Weather Machine - Snowy"}},
[12]={"Snowy Night Growch Angry","Growch",{"Weather Machine - Snowy Night"}},
[13]={"Snowy Growch Happy","Happy",{"Weather Machine - Snowy"}},
[14]={"Undersea Blast","Undersea",{"Undersea Blast"}},
[15]={"Warp Speed","Warp",{"Weather Machine - Warp Speed"}},
[16]={"Night Of The Comet","N.Comet",{"Weather Machine - Comet"}},
[17]={"Comet","Comet",{"Weather Machine - Comet"}},
[18]={"Party","Party",{"Weather Machine - Party"}},
[19]={"Pineapple","Pine",{"Pineapple Blast","Weather Machine - Pineapple"}},
[20]={"Snowy Night","SnowNight",{"Weather Machine - Snowy Night"}},
[21]={"Spring","Spring",{"Weather Machine - Spring"}},
[22]={"Howling Sky","Howling",{"Weather Machine - Howling Sky"}},
[23]={"Sunny Uninitialized","Sunny3",{"Weather Machine - Sunny"}},
[24]={"Purple Heatwave","Purple",{"Weather Machine - Heatwave"}},
[25]={"Orange Heatwave","Orange",{"Weather Machine - Heatwave"}},
[26]={"Green Heatwave","Green",{"Weather Machine - Heatwave"}},
[27]={"Cyan Heatwave","Cyan",{"Weather Machine - Heatwave"}},
[28]={"Custom Heatwave","Custom",{"Weather Machine - Heatwave"}},
[29]={"Stuff","Stuff",{"Weather Machine - Stuff"}},
[30]={"Pagoda","Pagoda",{"Weather Machine - Pagoda"}},
[31]={"Apocalypse","Apoc",{"Weather Machine - Apocalypse"}},
[32]={"Jungle","Jungle",{"Weather Machine - Jungle"}},
[33]={"Balloon Warz","Balloon",{"Weather Machine - Balloon Warz"}},
[34]={"Background","BG",{"Weather Machine - Background"}},
[35]={"Autumn","Autumn",{"Weather Machine - Autumn"}},
[36]={"Hearts","Hearts",{"Weather Machine - Valentine's","Weather Machine - Valentines"}},
[37]={"St. Patrick's","Patrick",{"Weather Machine - St. Patrick's","Weather Machine - St Patricks"}},
[38]={"Frozen Cliffs","Frozen",{"Weather Machine - Frozen Cliffs","Weather Machine - Iceberg"}},
[39]={"Volcano","Volcano",{"Weather Machine - Volcano"}},
[40]={"Flying Castles","Castles",{"Weather Machine - Flying Castles"}},
[41]={"Guild Mascot","Guild",{"Weather Machine - Guild"}},
[42]={"Digital Rain","D.Rain",{"Weather Machine - Digital Rain"}},
[43]={"Monochrome","Mono",{"Weather Machine - Monochrome","Weather Machine - Monochrome Blast"}},
[44]={"Treasure","Treasure",{"Weather Machine - Treasure","Treasure Blast"}},
[45]={"SurgWorld","Surg",{"Weather Machine - SurgWorld","SurgWorld Blast"}},
[46]={"Bountiful","Bount",{"Weather Machine - Bountiful","Bountiful Blast"}},
[47]={"Meteor Shower","Meteor",{"Weather Machine - Meteor Shower"}},
[48]={"Stargazing","Stars",{"Weather Machine - Stargazing"}},
[49]={"Ascended","Ascend",{"Weather Machine - Ascended"}},
[50]={"Descended","Descend",{"Weather Machine - Descended"}},
[51]={"Celebrity Hills","Celeb",{"Weather Machine - Celebrity Hills"}},
[52]={"Dungeons","Dungeon",{"Weather Machine - Dungeons"}},
[53]={"Legendary City","Legend",{"Weather Machine - Legendary City"}},
[54]={"Blood Dragon","B.Dragon",{"Weather Machine - Blood Dragon"}},
[55]={"Prince Of Persia","Persia",{"Prince of Persia Lock","Prince Of Persia Lock"}},
[56]={"Anzu","Anzu",{"Anzu's Mystical Weather Machine","Anzu"}},
[57]={"TMNT City","TMNT",{"TMNT Shellraiser","TMNT City"}},
[58]={"Rad City","RadCity",{"Weather Machine - Rad City","Rad City"}},
[59]={"Plaza","Plaza",{"Weather Machine - Plaza","Plaza"}},
[60]={"Nebula","Nebula",{"Weather Machine - Nebula"}},
[61]={"Protostar Landing","Proto",{"Weather Machine - Protostar Landing"}},
[62]={"Dark Mountains","DarkMt",{"Weather Machine - Dark Mountains"}},
[63]={"Assassin's Weekend","AC",{"Assassin's Creed Lock","Assassin's Weekend"}},
[64]={"Mt. Growmore","Growmore",{"Weather Machine - Mt. Growmore","Weather Machine - Mount Growmore"}},
[65]={"Crack In Reality","Crack",{"Weather Machine - Crack in Reality"}},
[66]={"Nian's Mountain","Nian",{"Weather Machine - Nian's Mountain"}},
[67]={"Rayman","Rayman",{"Rayman's Fist","Rayman"}},
[68]={"Steampunk","Steam",{"Weather Machine - Steampunk","Weather Machine - SteamPunk"}},
[69]={"Realm Of Spirits","Spirits",{"Weather Machine - Realm of Spirits"}},
[70]={"Black Hole","BlackHole",{"Weather Machine - Black Hole"}},
[71]={"Rainin' Gems","Gems",{"Weather Machine - Rainin' Gems","Weather Machine - Raining Gems"}},
[72]={"Holiday Haven","Holiday",{"Weather Machine - Holiday Haven"}},
[73]={"Immortals Fenyx Rising","Fenyx",{"Immortals Fenyx Rising Lock"}},
[74]={"Enchanted Lock Weather","Enchant",{"Enchanted Lock"}},
[75]={"Royal Enchanted Weather","Royal",{"Royal Enchanted Lock"}},
[76]={"Neptune's Atlantis","Atlantis",{"Neptune's Weather Machine - Atlantis"}},
[77]={"Pinuski Petal Haven","Pinuski",{"Weather Machine - Pinuski's Petal Purrfect Haven"}},
[78]={"Candy Land","Candy",{"Weather Machine - Candy Land"}},
[79]={"Dragon's Keep","Dragon",{"Draconic Weather Machine - Dragon's Keep"}},
[80]={"Emerald City","Emerald",{"Weather Machine - Emerald City"}},
[81]={"Ancestral Plane","Ancestral",{"Weather Machine - Ancestral Plane"}},
[82]={"Black Digital Rain","BlackRain",{"Weather Machine - Black Digital Rain"}}
}

local WEATHER = {}
for id = 0, 82 do
    local d = WEATHER_DATA[id]
    if d then WEATHER[#WEATHER + 1] = {id = id, name = d[1], short = d[2], items = d[3]} end
end

local function validItemID(id)
    id = tonumber(id)
    return id and id > 0 and id < 100000
end

local function findIconByName(name)
    if not name or name == "" then return nil end
    if type(getItemInfoByName) == "function" then
        local ok, info = pcall(function() return getItemInfoByName(name) end)
        if ok and type(info) == "table" and validItemID(info.id) then return tonumber(info.id) end
    end
    if growtopia and type(growtopia.getItemID) == "function" then
        local ok, id = pcall(function() return growtopia.getItemID(name) end)
        if ok and validItemID(id) then return tonumber(id) end
    end
    if type(findItemID) == "function" then
        local ok, id = pcall(function() return findItemID(name) end)
        if ok and validItemID(id) then return tonumber(id) end
    end
    return nil
end

NICK_ICON = findIconByName("Birth Certificate") or NICK_ICON
WEATHER_ICON = findIconByName("Weather Machine - Sunny") or WEATHER_ICON

local function weatherById(id)
    id = tonumber(id)
    if id == nil then return nil end
    return WEATHER[id + 1]
end

local function weatherIcon(w)
    if not w then return WEATHER_ICON end
    if weatherIconCache[w.id] ~= nil then return weatherIconCache[w.id] end
    local icon = nil
    for _, name in ipairs(w.items or {}) do
        icon = findIconByName(name)
        if icon then break end
    end
    weatherIconCache[w.id] = icon or WEATHER_ICON
    return weatherIconCache[w.id]
end

local function setWeatherLocal(id, label, keepSelected)
    id = tonumber(id)
    if id == nil then return false end
    if keepSelected ~= false then selectedWeather = id end

    if growtopia and type(growtopia.setWeather) == "function" then
        local ok = pcall(function() growtopia.setWeather(id) end)
        if ok then
            return true
        end
    end

    sendVar({v1 = "OnSetCurrentWeather", v2 = id})
    return true
end

local function resetWeather()
    selectedWeather = nil
    if lastServerWeather == nil then
        overlay("`6Original weather has not been detected yet.")
        return true
    end
    return setWeatherLocal(lastServerWeather, "Original", false)
end

local function showWeatherUI()
    local s = theme()
    s = s .. "text_scaling_string|LLLLLLLLLLLLLLLLLLLLLLLL|\n"
    s = s .. "add_label_with_icon|small|[`cJimi`6Proxy`9] Weather Visual|left|" .. WEATHER_ICON .. "|\n"
    s = s .. "add_smalltext|`9All Weather `8- `w8 per row `8- ID 0-82|left|\n"
    s = s .. "add_spacer|small|\n"

    local resetFrame = selectedWeather == nil and "staticYellowFrame" or "staticGreyFrame"
    s = s .. "add_button_with_icon|weather_reset|`wOriginal|" .. resetFrame .. "|" .. WEATHER_ICON .. "||\n"
    s = s .. "add_button_with_icon||END_LIST|noflags|0||\n"

    local inRow = 0
    for _, w in ipairs(WEATHER) do
        local frame = selectedWeather == w.id and "staticYellowFrame" or "staticBlueFrame"
        s = s .. "add_button_with_icon|weather_pick_" .. w.id .. "|`w" .. w.short .. "|" .. frame .. "|" .. weatherIcon(w) .. "||\n"
        inRow = inRow + 1
        if inRow >= 8 then
            s = s .. "add_button_with_icon||END_LIST|noflags|0||\n"
            inRow = 0
        end
    end
    if inRow > 0 then s = s .. "add_button_with_icon||END_LIST|noflags|0||\n" end

    s = s .. "add_spacer|small|\n"
    if selectedWeather == nil then
        s = s .. "add_smalltext|`9Selected: `2Original|left|\n"
    else
        local selected = weatherById(selectedWeather)
        s = s .. "add_smalltext|`9Selected: `2" .. (selected and selected.name or "Raw ID") .. " `8[`w" .. tostring(selectedWeather) .. "`8]|left|\n"
    end
    s = s .. "add_smalltext|`8Yellow = selected `w• `8Blue = weather `w• `8Test ID: /wid <83-255>|left|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|jimi_weather_dialog|Close||\n"
    dialog(s)
    return true
end

local function applyTitle(key)
    local t = TITLES[key]
    if not t then return false end
    local id = nickNetID()
    if id <= 0 then
        overlay("`4NetID is not available yet.")
        return true
    end
    selectedTitle = key
    sendNameVar({v1 = "OnCountryState", v2 = t.state}, id)
    applyNick()
    return true
end

local function showTitleUI()
    local s = theme()
    s = s .. "text_scaling_string|LLLLLLLLLLLLLLLLLLLLLLLL|\n"
    s = s .. "add_label_with_icon|small|[`cJimi`6Proxy`9] Role Title|left|" .. TITLE_ICON .. "|\n"
    s = s .. "add_spacer|small|\n"

    for _, key in ipairs(TITLE_ORDER) do
        local t = TITLES[key]
        s = s .. "add_checkbox|title_choice_" .. key .. "|`w" .. t.name .. "|" .. (selectedTitle == key and "1" or "0") .. "|\n"
        s = s .. "add_smalltext|`6" .. cleanDialog(t.desc or "Show title.") .. "|left|\n"
    end

    s = s .. "add_spacer|small|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|jimi_title_dialog||OK|\n"
    dialog(s)
    return true
end


ROLE_SKINS = {
    {id=2, key="surgeon", name="Surgeon", icon=7068},
    {id=1, key="builder", name="Builder", icon=7070},
    {id=3, key="fisher", name="Fisher", icon=7072},
    {id=4, key="cook", name="Cook", icon=7076},
    {id=0, key="farmer", name="Farmer", icon=7064},
    {id=5, key="startopian", name="Startopian", icon=7074},
    {id=6, key="disable", name="Disable", icon=170}
}

function JimiProxyExt.applyRoleSkin(id)
    id=tonumber(id)
    if id==nil then return false end
    local netid=myNetID()
    if netid<=0 then
        overlay("`4NetID is not available yet.")
        return true
    end
    selectedRoleID=math.floor(id)
    sendNameVar({v1="OnSetRoleSkinsAndIcons",v2=selectedRoleID,v3=selectedRoleID,v4=0},netid)
    return true
end

function JimiProxyExt.showRoleUI()
    local out=theme()
        .."text_scaling_string|LLLLLLLLLLLLLLLLLLLLLLLL|\n"
        .."add_label_with_icon|small|[`cJimi`6Proxy`9] `2Role Skins|left|7068|\n"
        .."add_smalltext|`9Choose one visual role.|left|\n"
        .."add_spacer|tiny|\n"
    for _,role in ipairs(ROLE_SKINS) do
        local frame=(selectedRoleID==role.id) and "staticYellowFrame" or "staticBlueFrame"
        local color=(role.id==6) and "`4" or "`w"
        out=out.."add_button_with_icon|role_pick_"..role.id.."|"..color..role.name.."|"..frame.."|"..role.icon.."|left|\n"
    end
    out=out.."add_quick_exit|\nend_dialog|jimi_role_dialog|Close||\n"
    dialog(out)
    return true
end

function JimiProxyExt.handleRoleDialog(packet)
    packet=tostring(packet or "")
    local button=packet:match("\nbuttonClicked|([^\n\r]+)") or packet:match("^buttonClicked|([^\n\r]+)") or ""
    local id=button:match("^role_pick_(%d+)$")
    if id then
        JimiProxyExt.applyRoleSkin(tonumber(id))
        JimiProxyExt.showRoleUI()
    end
    return true
end

local function packetField(packet, key)
    packet = tostring(packet or "")
    local v = packet:match("\n" .. key .. "|([^\n\r]*)")
    if v == nil then v = packet:match("^" .. key .. "|([^\n\r]*)") end
    return v
end

function JimiProxyExt.handleWeatherDialog(packet)
    local button = packet:match("buttonClicked|([^\n\r]+)") or ""
    if button == "weather_reset" then
        resetWeather()
        showWeatherUI()
        return true
    end
    local id = button:match("^weather_pick_(%d+)$")
    if id then
        id = tonumber(id)
        local w = weatherById(id)
        setWeatherLocal(id, w and w.name or "Weather")
        showWeatherUI()
        return true
    end
    return true
end

function JimiProxyExt.handleTitleDialog(packet)
    packet = tostring(packet or "")

    local checked = {}

    local function checkedValue(key)
        local field = "title_choice_" .. key
        local raw =
            packet:match("\n" .. field .. "|([^\n\r]*)")
            or packet:match("^" .. field .. "|([^\n\r]*)")
            or ""

        raw = tostring(raw):lower()
        return raw == "1"
            or raw == "true"
            or raw == "on"
            or raw == "yes"
    end

    for _, key in ipairs(TITLE_ORDER) do
        if checkedValue(key) then
            checked[#checked + 1] = key
        end
    end

    local pick = selectedTitle

    if #checked == 1 then
        pick = checked[1]
    elseif #checked >= 2 then

        for _, key in ipairs(checked) do
            if key ~= selectedTitle then
                pick = key
                break
            end
        end
    end

    if not TITLES[pick] then
        pick = selectedTitle or "original"
    end

    applyTitle(pick)
    return true
end

function JimiProxyExt.fastText(mode)
    if mode == "pull" then return "Pull" end
    if mode == "kick" then return "Kick" end
    if mode == "ban" then return "Ban" end
    if mode == "trade" then return "Trade" end
    return "Wrench"
end

function JimiProxyExt.fastButton(mode)
    if mode == "pull" then return "pull" end
    if mode == "kick" then return "kick" end
    if mode == "ban" then return "world_ban" end
    if mode == "trade" then return "trade" end
    return ""
end

function JimiProxyExt.setFast(mode)
    fastMode = mode or ""
    pendingWrench = {netid = 0, name = "", untilMs = 0}
    if fastMode == "" then
        say("`4wrench off")
        overlay("`4wrench off")
    else
        say("`2change fast " .. fastMode)
        overlay("`2change fast " .. fastMode)
    end
    return true
end

function JimiProxyExt.doFastWrench(netid)
    netid = tonumber(netid) or 0
    if netid <= 0 or fastMode == "" or netid == myNetID() then return false end
    local now = ms()
    if now - lastFastWrenchAt < FAST_WRENCH_COOLDOWN then
        return true
    end
    lastFastWrenchAt = now
    local btn = JimiProxyExt.fastButton(fastMode)
    if btn == "" then return false end
    local name = playerNameByNetID(netid)
    if name == "" then name = "player" end
    pendingWrench = {netid = netid, name = name, untilMs = ms() + 2000}
    blockPopupUntil = ms() + 2000
    local mode = fastMode
    runThread(function()
        sleep(JimiProxyDelay.fastWrench)
        if fastMode ~= mode or pendingWrench.netid ~= netid then return end
        packet2("action|dialog_return\ndialog_name|popup\nnetID|" .. tostring(netid) .. "|\nbuttonClicked|" .. btn)
        if mode == "ban" then
            sleep(250)
            if fastMode == mode and pendingWrench.netid == netid then
                packet2("action|dialog_return\ndialog_name|popup\nnetID|" .. tostring(netid) .. "|\nbuttonClicked|worldban")
            end
        end
        overlay("`2" .. JimiProxyExt.fastText(mode) .. " `w" .. name)
    end)
    return false
end

function JimiProxyExt.isFastPlayerPopup(text)
    text = tostring(text or "")
    if text == "" then return false end
    local low = text:lower()
    local hasButton = low:find("button|pull", 1, true)
        or low:find("button|kick", 1, true)
        or low:find("button|world_ban", 1, true)
        or low:find("button|trade", 1, true)
        or low:find("buttonclicked|pull", 1, true)
        or low:find("buttonclicked|kick", 1, true)
        or low:find("buttonclicked|world_ban", 1, true)
        or low:find("buttonclicked|trade", 1, true)
    local looksPlayer = low:find("account age", 1, true)
        or low:find("send message", 1, true)
        or low:find("battle leash", 1, true)
        or low:find("dialog_name|popup", 1, true)
    return hasButton or (looksPlayer and (low:find("pull", 1, true) or low:find("kick", 1, true) or low:find("world ban", 1, true) or low:find("trade", 1, true)))
end

function JimiProxyExt.blockFastPopup(text)
    if fastMode == "" or not JimiProxyExt.isFastPlayerPopup(text) then return false end
    if pendingWrench.netid <= 0 or ms() > pendingWrench.untilMs then return ms() < blockPopupUntil end
    local id = tostring(text or ""):match("netID|(%d+)") or tostring(text or ""):match("netid|(%d+)")
    if id then return tonumber(id) == pendingWrench.netid end
    return true
end

local function dialogChecked(packet, key)
    local raw = packetField(packet, key) or ""
    raw = tostring(raw):lower()
    return raw == "1" or raw == "true" or raw == "on" or raw == "yes"
end

local function dialogItemAndCount(text)
    text = tostring(text or "")
    local itemID = tonumber(
        text:match("embed_data|itemID|(%d+)")
        or text:match("embed_data|itemid|(%d+)")
        or text:match("itemID|(%d+)")
        or text:match("itemid|(%d+)")
    )
    local count = tonumber(
        text:match("add_text_input|count|[^|]*|(%d+)|")
        or text:match("count||(%d+)|")
        or text:match("you have (%d+)")
        or text:match("You have (%d+)")
    )
    return itemID, count
end

function JimiProxyExt.setFastDrop(enabled)
    fastDrop = enabled == nil and not fastDrop or enabled == true
    say(fastDrop and "`2fast drop on" or "`4fast drop off")
    overlay(fastDrop and "`2Fast Drop ON" or "`4Fast Drop OFF")
    return true
end

function JimiProxyExt.setFastTrash(enabled)
    fastTrash = enabled == nil and not fastTrash or enabled == true
    say(fastTrash and "`2fast trash on" or "`4fast trash off")
    overlay(fastTrash and "`2Fast Trash ON" or "`4Fast Trash OFF")
    return true
end

function JimiProxyExt.stopFastTools()
    fastMode = ""
    fastDrop = false
    fastTrash = false
    autoJoinMode = ""
    autoJoinQueue = {}
    autoJoinBusy = false
    pendingWrench = {netid = 0, name = "", untilMs = 0}
    blockPopupUntil = 0
    say("`4all fast/auto tools stopped")
    overlay("`4Fast/Auto Tools OFF")
    return true
end

local function cleanPlayerName(value)
    local name = trim(strip(value or "")):gsub("^@", "")
    return trim(name)
end

local function allPlayers()
    local list = safe(getPlayerList)
    if type(list) ~= "table" then return {} end
    return list
end

local function playerNetID(p)
    return tonumber(type(p) == "table" and (p.netID or p.netid or p.net_id)) or 0
end

local function isCallable(value)
    if type(value) == "function" then return true end
    local ok, mt = pcall(getmetatable, value)
    return ok and type(mt) == "table" and type(mt.__call) == "function"
end

local function pathfinderCandidates()
    local out = {}
    local used = {}
    local function add(fn, owner)
        if fn == nil or used[fn] then return end
        used[fn] = true
        out[#out + 1] = {fn = fn, owner = owner}
    end

    local okDirect, direct = pcall(function() return FindPath end)
    if okDirect then add(direct) end
    local okLower, lower = pcall(function() return findPath end)
    if okLower then add(lower) end

    if type(_G) == "table" then
        add(rawget(_G, "FindPath"))
        add(rawget(_G, "findPath"))
        add(rawget(_G, "findpath"))
        add(rawget(_G, "PathFind"))
        add(rawget(_G, "pathFind"))
    end

    if type(growtopia) == "table" then
        add(growtopia.FindPath, growtopia)
        add(growtopia.findPath, growtopia)
        add(growtopia.findpath, growtopia)
        add(growtopia.PathFind, growtopia)
    end

    if type(growlauncher) == "table" then
        add(growlauncher.FindPath, growlauncher)
        add(growlauncher.findPath, growlauncher)
        add(growlauncher.findpath, growlauncher)
        add(growlauncher.PathFind, growlauncher)
    end

    return out
end

local function runPathfinder(x, y)
    x = math.floor(tonumber(x) or 0)
    y = math.floor(tonumber(y) or 0)
    for _, candidate in ipairs(pathfinderCandidates()) do
        local fn, owner = candidate.fn, candidate.owner
        if isCallable(fn) then

            local ok, result = pcall(fn, x, y)
            if not ok then ok, result = pcall(fn, x, y, false) end
            if not ok and owner ~= nil then ok, result = pcall(fn, owner, x, y) end
            if not ok and owner ~= nil then ok, result = pcall(fn, owner, x, y, false) end
            if ok then return result ~= false, true end
        end
    end
    return false, false
end

local function moveToPlayer(p)
    if type(p) ~= "table" then return false end
    local now = ms()
    if now - lastTPAt < TP_COOLDOWN then
        sendConsole("`6TP cooldown")
        return true
    end

    local x, y = playerTilePos(p)
    if not x or not y then
        sendConsole("`4Player position unavailable")
        return true
    end

    lastTPAt = now
    local moved, available = runPathfinder(x, y)
    if not available then
        sendConsole("`4Pathfinding unavailable")
    elseif not moved then
        sendConsole("`4Path blocked")
    end
    return true
end

local function tpMatches(query)
    query = cleanPlayerName(query):lower()
    local exact, prefix, inside = {}, {}, {}
    local mine = myNetID()
    for _, p in pairs(allPlayers()) do
        if type(p) == "table" and playerNetID(p) ~= mine then
            local name = cleanPlayerName(p.name or p.name_ or p.userName or "")
            local low = name:lower()
            if name ~= "" then
                if low == query then
                    exact[#exact + 1] = p
                elseif low:sub(1, #query) == query then
                    prefix[#prefix + 1] = p
                elseif low:find(query, 1, true) then
                    inside[#inside + 1] = p
                end
            end
        end
    end
    if #exact > 0 then return exact end
    if #prefix > 0 then return prefix end
    return inside
end

function JimiProxyExt.showTPChoices(matches, query)
    local s = theme()
    s = s .. "text_scaling_string|LLLLLLLLLLLLLLLLLLLLLLLLLLLL|\n"
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Player Search|left|32|\n"
    s = s .. "add_smalltext|`8Multiple matches for `w" .. cleanDialog(query) .. "`8. Choose one.|left|\n"
    s = s .. "add_spacer|small|\n"
    for _, p in ipairs(matches) do
        local nid = playerNetID(p)
        local name = cleanPlayerName(p.name or p.name_ or p.userName or "player")
        local x, y = playerTilePos(p)
        local pos = (x and y) and (" `8@ `w" .. math.floor(x) .. "," .. math.floor(y)) or ""
        s = s .. "add_button|tp_pick_" .. tostring(nid) .. "|`2" .. cleanDialog(name) .. pos .. "|noflags|0|0|\n"
    end
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|jimi_tp_dialog|Close||\n"
    dialog(s)
    return true
end

function JimiProxyExt.tpSearch(query)
    query = cleanPlayerName(query)
    if #query < 2 then
        sendConsole("`6Use /tp <at least 2 letters>")
        return true
    end
    local matches = tpMatches(query)
    if #matches == 0 then
        sendConsole("`4Player not found: `w" .. query)
        return true
    end
    if #matches == 1 then return moveToPlayer(matches[1]) end
    return JimiProxyExt.showTPChoices(matches, query)
end

function JimiProxyExt.handleTPDialog(packet)
    local button = tostring(packet or ""):match("buttonClicked|([^\n\r]+)") or ""
    local id = tonumber(button:match("^tp_pick_(%d+)$"))
    if id then
        local p = playerByNetID(id)
        if p then return moveToPlayer(p) end
        sendConsole("`4Player already left")
    end
    return true
end

local function autoJoinText(mode)
    if mode == "pull" then return "Auto Pull" end
    if mode == "kick" then return "Auto Kick" end
    if mode == "ban" then return "Auto Ban" end
    return "OFF"
end

local function snapshotAutoJoinSeen()
    autoJoinSeen = {}
    local now = ms()
    for _, p in pairs(allPlayers()) do
        local id = playerNetID(p)
        if id > 0 then autoJoinSeen[id] = now end
    end
end

function JimiProxyExt.setAutoJoinMode(mode)
    if mode ~= "pull" and mode ~= "kick" and mode ~= "ban" then mode = "" end
    autoJoinMode = mode
    autoJoinQueue = {}
    autoJoinBusy = false
    snapshotAutoJoinSeen()
    autoJoinReadyAt = ms() + 900
    say(mode == "" and "`4auto wrench off" or ("`2" .. autoJoinText(mode) .. " enabled"))
    overlay(mode == "" and "`4Auto Wrench OFF" or ("`2" .. autoJoinText(mode) .. " ON"))
    return true
end

function JimiProxyExt.showWAuto()
    local s = theme()
    s = s .. "text_scaling_string|LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL|\n"
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Auto Wrench Options|left|"..WRENCH_ICON.."|\n"
    s = s .. "add_smalltext|`8Only one auto action can be active at a time to avoid packet bursts.|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_checkbox|wauto_pull|`2Auto Pull|" .. (autoJoinMode == "pull" and "1" or "0") .. "|\n"
    s = s .. "add_smalltext|`8Pulls a newly joined player once after spawn.|left|\n"
    s = s .. "add_checkbox|wauto_kick|`eAuto Kick|" .. (autoJoinMode == "kick" and "1" or "0") .. "|\n"
    s = s .. "add_smalltext|`8Kicks a newly joined player once after spawn.|left|\n"
    s = s .. "add_checkbox|wauto_ban|`4Auto Ban|" .. (autoJoinMode == "ban" and "1" or "0") .. "|\n"
    s = s .. "add_smalltext|`8Bans a newly joined player once after spawn.|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_smalltext|`9Status: " .. (autoJoinMode == "" and "`4OFF" or ("`2" .. autoJoinText(autoJoinMode))) .. "|left|\n"
    s = s .. "add_button|wauto_apply|`2Apply|noflags|0|0|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|jimi_wauto_dialog|Close||\n"
    dialog(s)
    return true
end

function JimiProxyExt.handleWAutoDialog(packet)
    packet = tostring(packet or "")
    local checked = {}
    if dialogChecked(packet, "wauto_pull") then checked[#checked+1] = "pull" end
    if dialogChecked(packet, "wauto_kick") then checked[#checked+1] = "kick" end
    if dialogChecked(packet, "wauto_ban") then checked[#checked+1] = "ban" end
    local pick = ""
    if #checked == 1 then
        pick = checked[1]
    elseif #checked >= 2 then
        for _, mode in ipairs(checked) do
            if mode ~= autoJoinMode then pick = mode; break end
        end
        if pick == "" then pick = checked[1] end
    end
    JimiProxyExt.setAutoJoinMode(pick)
    JimiProxyExt.showWAuto()
    return true
end

local function spawnPlayerInfo(text)
    text = tostring(text or "")
    local id = tonumber(text:match("netID|(%d+)") or text:match("netid|(%d+)") or text:match("net_id|(%d+)")) or 0
    local raw = text:match("name|([^\n\r]+)") or ""
    local name = cleanPlayerName(raw)
    return id, name
end

local function startAutoJoinWorker()
    if autoJoinBusy or #autoJoinQueue == 0 then return end
    autoJoinBusy = true
    local serial = autoJoinWorldSerial
    runThread(function()
        while #autoJoinQueue > 0 and serial == autoJoinWorldSerial do
            local job = table.remove(autoJoinQueue, 1)
            if job and job.mode == autoJoinMode and job.name ~= "" and job.netid ~= myNetID() then
                packet2("action|input\n|text|/" .. job.mode .. " " .. job.name)
                overlay("`2" .. autoJoinText(job.mode) .. " `w" .. job.name)
                sleep(JimiProxyDelay.autoWrench)
            end
        end
        autoJoinBusy = false
        if #autoJoinQueue > 0 and serial == autoJoinWorldSerial then startAutoJoinWorker() end
    end)
end

function JimiProxyExt.onAutoJoinSpawn(text)
    if autoJoinMode == "" then return false end
    local id, name = spawnPlayerInfo(text)
    if id <= 0 or name == "" or id == myNetID() then return false end
    local now = ms()
    local seenAt = autoJoinSeen[id]
    autoJoinSeen[id] = now
    if now < autoJoinReadyAt then return false end
    if seenAt and now - seenAt < AUTO_JOIN_DEDUPE_MS then return false end
    if #autoJoinQueue >= AUTO_JOIN_MAX_QUEUE then
        return false
    end
    autoJoinQueue[#autoJoinQueue + 1] = {mode = autoJoinMode, netid = id, name = name}
    startAutoJoinWorker()
    return false
end

function JimiProxyExt.resetAutoJoinWorld()
    autoJoinWorldSerial = autoJoinWorldSerial + 1
    autoJoinQueue = {}
    autoJoinBusy = false
    autoJoinSeen = {}
    autoJoinReadyAt = ms() + 2500
end

function JimiProxyExt.handleFastDropDialog(text)
    if not fastDrop then return false end
    local itemID, count = dialogItemAndCount(text)
    if not itemID or not count or count <= 0 then return false end

    local key = tostring(itemID) .. ":" .. tostring(count)
    local now = ms()
    if key == JimiProxyDelay.fastDropKey and (now - JimiProxyDelay.fastDropAt) < 350 then
        return true
    end
    JimiProxyDelay.fastDropKey = key
    JimiProxyDelay.fastDropAt = now

    runThread(function()
        sleep(JimiProxyDelay.drop)
        if fastDrop then
            packet2("action|dialog_return\ndialog_name|drop_item\nitemID|" .. tostring(itemID) .. "|\ncount|" .. tostring(count))
        end
    end)
    return true
end

function JimiProxyExt.handleFastTrashDialog(text)
    if not fastTrash then return false end
    local itemID, count = dialogItemAndCount(text)
    if not itemID or not count or count <= 0 then return false end
    packet2("action|dialog_return\ndialog_name|trash_item\nitemID|" .. tostring(itemID) .. "|\ncount|" .. tostring(count))
    return true
end

function JimiProxyExt.showUI()
    local out=theme()
        .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
        .."add_label_with_icon|small|[`cJimi`6Proxy`9] `2UI Colors|left|9474|\n"
        .."add_smalltext|`9Choose one preset.|left|\n"
        .."add_spacer|tiny|\n"
    for _,key in ipairs(UI_THEME_ORDER) do
        local t=UI_THEMES[key]
        out=out.."add_checkbox|ui_"..key.."|"..t.color..t.name.."|"..(selectedUITheme==key and "1" or "0").."|\n"
    end
    out=out.."add_spacer|tiny|\n"
        .."add_button|ui_apply|`2Apply|noflags|0|0|\n"
        .."add_quick_exit|\nend_dialog|jimi_ui_dialog|Close||\n"
    dialog(out)
    return true
end

function JimiProxyExt.showCustomUI()
    local out=theme()
        .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
        .."add_label_with_icon|small|[`cJimi`6Proxy`9] `2Custom UI Colors|left|9474|\n"
        .."add_smalltext|`9RGBA example: 43,34,74,200|left|\n"
        .."add_spacer|tiny|\n"
        .."add_text_input|custom_bg|Background RGBA|"..cleanDialog(BG_COLOR).."|22|\n"
        .."add_text_input|custom_border|Border RGBA|"..cleanDialog(BORDER_COLOR).."|22|\n"
        .."add_spacer|tiny|\n"
        .."add_button|custom_ui_save|`2Save|noflags|0|0|\n"
        .."add_quick_exit|\nend_dialog|jimi_custom_ui|Close||\n"
    dialog(out)
    return true
end

function JimiProxyExt.validRGBA(value)
    value=tostring(value or "")
    local r,g,b,a=value:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
    if not r then return nil end
    r,g,b,a=tonumber(r),tonumber(g),tonumber(b),tonumber(a)
    if r>255 or g>255 or b>255 or a>255 then return nil end
    return string.format("%d,%d,%d,%d",r,g,b,a)
end

function JimiProxyExt.handleCustomUI(packet)
    local bg=JimiProxyExt.validRGBA(packetField(packet,"custom_bg"))
    local border=JimiProxyExt.validRGBA(packetField(packet,"custom_border"))
    if not bg or not border then
        overlay("`4Use RGBA: 43,34,74,200")
        return JimiProxyExt.showCustomUI()
    end
    BG_COLOR=bg
    BORDER_COLOR=border
    selectedUITheme="custom"
    overlay("`2UI colors saved.")
    return JimiProxyExt.showCustomUI()
end

function JimiProxyExt.showCustomDelay()
    local out=theme()
        .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
        .."add_label_with_icon|small|[`cJimi`6Proxy`9] `2Custom Delay|left|32|\n"
        .."add_smalltext|`9Milliseconds.|left|\n"
        .."add_spacer|tiny|\n"
        .."add_text_input|delay_drop|Drop|"..tostring(JimiProxyDelay.drop).."|6|\n"
        .."add_text_input|delay_wrench|Wrench|"..tostring(JimiProxyDelay.fastWrench).."|6|\n"
        .."add_text_input|delay_auto_wrench|Auto Wrench|"..tostring(JimiProxyDelay.autoWrench).."|6|\n"
        .."add_text_input|delay_blink|Blink Skin|"..tostring(JimiProxyDelay.blink).."|6|\n"
        .."add_text_input|delay_spam|Spammer|"..tostring(spamDelay).."|6|\n"
        .."add_text_input|delay_tp|TP Cooldown|"..tostring(TP_COOLDOWN).."|6|\n"
        .."add_spacer|tiny|\n"
        .."add_button|delay_apply|`2Save|noflags|0|0|\n"
        .."add_quick_exit|\nend_dialog|jimi_custom_delay|Close||\n"
    dialog(out)
    return true
end

function JimiProxyExt.handleCustomDelay(packet)
    local function read(key,fallback,minValue,maxValue)
        local n=tonumber(packetField(packet,key))
        if n==nil then return fallback end
        n=math.floor(n)
        if n<(minValue or 0) then n=minValue or 0 end
        if n>(maxValue or JimiProxyDelay.max) then n=maxValue or JimiProxyDelay.max end
        return n
    end
    JimiProxyDelay.drop=read("delay_drop",JimiProxyDelay.drop,0,5000)
    JimiProxyDelay.fastWrench=read("delay_wrench",JimiProxyDelay.fastWrench,0,5000)
    JimiProxyDelay.autoWrench=read("delay_auto_wrench",JimiProxyDelay.autoWrench,100,5000)
    JimiProxyDelay.blink=read("delay_blink",JimiProxyDelay.blink,120,5000)
    spamDelay=read("delay_spam",spamDelay,800,60000)
    JimiProxyDelay.spam=spamDelay
    TP_COOLDOWN=read("delay_tp",TP_COOLDOWN,0,10000)
    JimiProxyDelay.tp=TP_COOLDOWN
    overlay("`2Custom Delay updated.")
    return JimiProxyExt.showCustomDelay()
end

function JimiProxyExt.handleUIDialog(packet)
    packet = tostring(packet or "")
    local checked = {}
    for _, key in ipairs(UI_THEME_ORDER) do
        if dialogChecked(packet, "ui_" .. key) then checked[#checked+1] = key end
    end
    local pick = selectedUITheme
    if #checked == 1 then
        pick = checked[1]
    elseif #checked >= 2 then
        for _, key in ipairs(checked) do
            if key ~= selectedUITheme then pick = key; break end
        end
    end
    applyUITheme(pick)
    JimiProxyExt.showUI()
    return true
end


BLINK_SKINS = {
    1348237567,1685231359,2022356223,2190853119,
    2527912447,2864971775,3033464831,3370516479
}

function JimiProxyExt.setBlink(enabled)
    if enabled==nil then enabled=not blinkActive end
    blinkActive=enabled==true
    blinkToken=blinkToken+1
    local token=blinkToken
    if not blinkActive then
        packet2("action|setSkin\ncolor|"..tostring(blinkDefaultSkin))
        overlay("`4Blink Skin OFF")
        return true
    end
    overlay("`2Blink Skin ON")
    runThread(function()
        local index=1
        while blinkActive and token==blinkToken do
            packet2("action|setSkin\ncolor|"..tostring(BLINK_SKINS[index]))
            index=index+1
            if index>#BLINK_SKINS then index=1 end
            sleep(math.max(120,tonumber(JimiProxyDelay.blink) or 180))
        end
    end)
    return true
end

function JimiProxyExt.spamLine()
    local t = trim(spamText)
    if #t > 110 then t = t:sub(1, 110) end
    if not spamColorChat then return t end
    local c = spamColors[spamColorIndex] or "`2"
    spamColorIndex = spamColorIndex + 1
    if spamColorIndex > #spamColors then spamColorIndex = 1 end
    return c .. t
end

function JimiProxyExt.startSpam()
    spamText = cleanDialog(spamText)
    spamDelay = tonumber(spamDelay) or 1200
    if spamDelay < 800 then spamDelay = 800 end
    if spamDelay > 60000 then spamDelay = 60000 end
    if spamText == "" then
        say("`4empty spam text")
        return true
    end
    if spamActive then
        say("`6spam updated")
        return true
    end
    spamActive = true
    spamSerial = spamSerial + 1
    local token = spamSerial
    say("`2spam start")
    runThread(function()
        while spamActive and token == spamSerial do
            packet2("action|input\n|text|" .. JimiProxyExt.spamLine())
            sleep(spamDelay)
        end
    end)
    return true
end

function JimiProxyExt.stopSpam()
    spamActive = false
    spamSerial = spamSerial + 1
    say("`4spam off")
    overlay("`4spam off")
    return true
end

function JimiProxyExt.showSpamDialog()
    local s = theme()
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Spammer|left|"..SPAM_ICON.."|\n"
    s = s .. "add_smalltext|`9Stop: `2/soff `8| `9Min delay: `2800ms|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_text_input|spam_text|Spam text:|" .. cleanDialog(spamText) .. "|120|\n"
    s = s .. "add_text_input|spam_delay|Delay ms:|" .. tostring(spamDelay) .. "|6|\n"
    s = s .. "add_checkbox|spam_color|`2Auto change color|" .. (spamColorChat and "1" or "0") .. "|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_textbox|`8Status: " .. (spamActive and "`2ON" or "`4OFF") .. " `8| `9Delay: `w" .. tostring(spamDelay) .. "ms|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_button|spam_start|`2Start Spam|noflags|0|0|\n"
    s = s .. "end_dialog|spam_dialog|Close||\n"
    dialog(s)
    return true
end

function JimiProxyExt.dialogValue(packet, key)
    packet = tostring(packet or "")
    key = tostring(key or "")
    local v = packet:match("\n" .. key .. "|([^\n\r]*)")
    if v == nil then v = packet:match("^" .. key .. "|([^\n\r]*)") end
    return v
end

function JimiProxyExt.handleSpamDialog(packet)
    local text = JimiProxyExt.dialogValue(packet, "spam_text")
    local delay = JimiProxyExt.dialogValue(packet, "spam_delay")
    local color = JimiProxyExt.dialogValue(packet, "spam_color")
    if text ~= nil then spamText = cleanDialog(text) end
    if delay ~= nil then spamDelay = tonumber(delay) or spamDelay end
    spamColorChat = tostring(color) == "1"
    spamDelay = tonumber(spamDelay) or 1200
    if spamDelay < 800 then spamDelay = 800 end
    if spamDelay > 60000 then spamDelay = 60000 end
    local button = packet:match("buttonClicked|([^\n\r]+)") or ""
    if button == "spam_start" then return JimiProxyExt.startSpam() end
    return true
end

local function jimiScriptLuaPath()
    local fallback = '/storage/emulated/0/Android/media/launcher.powerkuy.growlauncher/ScriptLua/'
    if type(getAppLibrary) ~= 'function' then return fallback end
    local ok, given = pcall(getAppLibrary)
    if not ok or type(given) ~= 'string' or given == '' then return fallback end
    local path = given:gsub('\\', '/')
    
    local exact = path:match('^(.-/ScriptLua)/?')
    if exact then return exact .. '/' end

    local root = path:match('^(.-/launcher%.powerkuy%.growlauncher)/?')
    if root then
        if root:find('/Android/media/', 1, true) then return root .. '/ScriptLua/' end
        if root:find('/Android/data/', 1, true) then return root .. '/files/ScriptLua/' end
    end
    
    local mediaRoot = path:match('^(.-/Android/media/[^/]+)/')
        or path:match('^(.-/Android/media/[^/]+)$')
    if mediaRoot then return mediaRoot .. '/ScriptLua/' end
    local dataRoot = path:match('^(.-/Android/data/[^/]+)/')
        or path:match('^(.-/Android/data/[^/]+)$')
    if dataRoot then return dataRoot .. '/files/ScriptLua/' end
    return fallback
end

function JimiProxyExt.showNews(native)
    return JimiProxyExt.UI.open("news",native)
end

function JimiProxyExt.showDiscord()
    local s = theme()
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `5Discord|left|486|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_textbox|`9Join Discord for update, request, and report bug.|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_image_button|discord_btn|interface/large/gazette/gazette_5columns_social_btn01.rttex|7imageslayout20|" .. DC_LINK .. "|Join Discord|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|discord_close|||\n"
    dialog(s)
    say("`5Discord: `b" .. DC_LINK)
end

function JimiProxyExt.showWA()
    local s = theme()
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2WhatsApp|left|32|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_textbox|`9Join WhatsApp group for chat and support.|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_url_button||`2Join WhatsApp|NOFLAGS|" .. WA_LINK .. "|Open WhatsApp?|0|0|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|wa_close|| |\n"
    dialog(s)
    say("`2WhatsApp: `b" .. WA_LINK)
end

function JimiProxyExt.showWeb()
    local s = theme()
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Website|left|32|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_textbox|`9Official JimiProxy website.|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_url_button||`2Open hijimi.site|NOFLAGS|" .. WEB_LINK .. "|Open Website?|0|0|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|web_close|||\n"
    dialog(s)
    say("`2Website: `b" .. WEB_LINK)
end

function JimiProxyExt.identity(title,icon)
    return "add_label_with_icon|small|[`cJimi`6Proxy`9] `2"..title.."|left|"..icon.."|\n"
        .."add_smalltext|`6"..VERSION.." `9[Free] `8• `9Updated `6"..LAST_UPDATED.."|left|\n"
end

function JimiProxyExt.discordImage()
    return "add_image_button|discord_btn|interface/large/gazette/gazette_5columns_social_btn01.rttex|7imageslayout20|"..DC_LINK.."|Join Discord|\n"
end

function JimiProxyExt.newsContent()
    local s=JimiProxyExt.identity("News",NEWS_ICON)
        .."add_spacer|tiny|\n"
        .."add_textbox|`2Update Logs|left|\n"
    for _,line in ipairs(NEWS)do
        local color="`9"
        if line:find("^%+") then color="`2"
        elseif line:find("^~") then color="`6"
        elseif line:find("^%-") then color="`4"
        end
        s=s.."add_smalltext|`8> "..color..cleanDialog(line).."|left|\n"
    end
    return s.."add_spacer|small|\n"..JimiProxyExt.discordImage()
end

function JimiProxyExt.featureContent()
    local s=JimiProxyExt.identity("Main Features",FEATURED_ICON)
        .."add_smalltext|`9Website `c"..WEB_LINK.." `8• `9Discord `c"..DISCORD.."|left|\n"
        .."add_smalltext|`4Do not sell this script.|left|\n"

    local sections={
        {"Auto Active",32,{
            {"Entrance Visual","Door open / close effect"},
            {"Gem Number","Local gem counter"},
            {"Green Box","Saved tile marker"},
            {"Startup Banner & Sound","Startup banner + sound"},
            {"Place FX","Local place effect"},
            {"Activity Logging","Automatic activity logs"}
        },true},
        {"Featured",FEATURED_ICON,{{"/chat","JimiProxy chat to Discord"}}},
        {"Calculator",1752,{{"/c (expression)","+  -  x  *  /  ( )"}}},
        {"Profile",PROFILE_ICON,{{"/profile","Player profile"}}},
        {"Pull Tile",WRENCH_ICON,{
            {"/pt1 - /pt4","Set Pull Tile positions"},
            {"/pt","Pull saved positions"}
        }},
        {"Wheel Games",758,{
            {"/reme","REME mode"},{"/qeme","QEME mode"},{"/leme","LEME mode"}
        }},
        -- Existing BJ section is intentionally left as plain heading content.
        {"BJ",nil,{
            {"/p1","Set P1 drop position"},
            {"/p2","Set P2 drop position"},
            {"/take","Take both lock drops"},
            {"/w1","Select P1 winner + payout"},
            {"/w2","Select P2 winner + payout"},
            {"/tax (percent)","Set payout tax"}
        }},
        {"Drop",242,{{"/drop (id) (amount)","Drop item by ID"}}},
        {"Locks",BGL_ID,{
            {"/dw (amount)","Drop World Lock"},
            {"/dd (amount)","Drop Diamond Lock"},
            {"/dbgl (amount)","Drop Blue Gem Lock • /db supported"},
            {"/cd (WL value)","Custom lock drop"},
            {"/daw /dao","Drop all locks"},
            {"/cv","Convert DL to BGL"}
        }},
        {"Fast Wrench",WRENCH_ICON,{
            {"/wauto","Auto Wrench setup"},{"/fastpull","Fast Pull"},{"/fastkick","Fast Kick"},
            {"/fastban","Fast Ban"},{"/fasttrade","Fast Trade"},{"/woff","Fast Wrench OFF"}
        }},
        {"Fast Drop & Trash",242,{
            {"/fastdrop","Fast Drop"},{"/fasttrash","Fast Trash"},{"/faststop","Stop all fast tools"}
        }},
        {"Role Title",14404,{
            {"/nick (name)","Local nickname"},
            {"/role","Role title selector"},
            {"/title","Visual title selector"}
        }},
        {"Weather",WEATHER_ICON,{{"/weather","Visual weather"}}},
        {"Visual Drop",9474,{{"/vdrop (id) (amount)","Visual drop"}}},
        {"Gems",GEM_ID,{{"/cgems","Show dropped Gem amounts"},{"/balance","WL / DL / BGL / Gems"}}},
        {"Search",SEARCH_ICON,{{"/sitem (id/name)","Find dropped item"},{"/vends (id/name)","Find vending item"}}},
        {"Inventory",3524,{{"/inv","Inventory list"}}},
        {"Players",NICK_ICON,{
            {"/tp (name)","Pathfind to player"},
            {"/hidden","Hide clothes / FX locally"},
            {"/streammode","Mask all player names locally"},
            {"Wrench player","Follow Chat / Stop Follow Chat"}
        }},
        {"Utility",6016,{
            {"/mods","Show moderators currently online"}
        }},
        {"World",6,{
            {"/relog","Relog once"},{"/res /respawn","Respawn"},{"/dc /disconnect","Disconnect"},{"/back","Return to previous world"}
        }},
        {"Other Commands",SPAM_ICON,{
            {"/blink","Blink Skin"},
            {"/spam","Open Spammer"},{"/soff","Stop Spammer"}
        }},
        {"Support",486,{{"/discord","Discord"},{"/whatsapp","WhatsApp Group"},{"/web","hijimi.site"}}}
    }

    for _,section in ipairs(sections)do
        s=s.."add_spacer|tiny|\n"
        if section[2] then
            s=s.."add_label_with_icon|small|`2"..section[1].."|left|"..section[2].."|\n"
        else
            s=s.."add_textbox|`2"..section[1].."|left|\n"
        end
        for _,entry in ipairs(section[3])do
            if section[4] then
                s=s.."add_smalltext|`w"..entry[1].." `8[`6"..entry[2].."`8]|left|\n"
            else
                local cmd=entry[1]:gsub("(%b())","`e%1`1")
                s=s.."add_smalltext|`1"..cmd.." `8[`6"..entry[2].."`8]|left|\n"
            end
        end
    end

    return s
        .."add_spacer|small|\n"
        .."add_smalltext|`9Made by `cJimi `8• `9"..DISCORD.."|left|\n"
        .."add_spacer|small|\n"
end

function JimiProxyExt.creditsContent()
    return JimiProxyExt.identity("Credits",12436)
        .."add_smalltext|`9Website `c"..WEB_LINK.."|left|\n"
        .."add_smalltext|`9Discord `c"..DISCORD.."|left|\n"
        .."add_spacer|small|\n"
        .."add_label_with_icon|small|`2Official Links|left|482|\n"
        .."add_url_button|credits_website|`cWebsite JimiProxy|NOFLAGS|"..WEB_LINK.."|Open hijimi.site?|0|0|\n"
        .."add_url_button|credits_whatsapp|`2WhatsApp Group|NOFLAGS|"..WA_LINK.."|Join WhatsApp?|0|0|\n"
        .."add_spacer|small|\n"
        .."add_label_with_icon|small|`6Credits|left|12436|\n"
        .."add_smalltext|`9Created by `cJimi `8• `9"..DISCORD.."|left|\n"
        .."add_smalltext|`9JimiProxy `c"..VERSION.." `8• `9Free Version|left|\n"
        .."add_smalltext|`4Do not sell this script.|left|\n"
        .."add_smalltext|`6Thanks for using JimiProxy.|left|\n"
        .."add_smalltext|`9Growtopia artwork belongs to its respective owners.|left|\n"
        .."add_smalltext|`6(c) 2026 Jimi.|left|\n"
        .."add_spacer|small|\nadd_spacer|small|\n"
        .."add_label_with_icon|small|`1Discord Community|left|486|\n"
        .."add_smalltext|`4Updates, support, requests, and bug reports.|left|\n"
        .."add_spacer|small|\n"
        ..JimiProxyExt.discordImage()
        .."add_spacer|small|\nadd_spacer|small|\n"
end

function JimiProxyExt.logsContent()
    if JimiProxyExt.logView then
        return JimiProxyExt.identity("Logs",LOGS_ICON)
            ..JimiProxyExt.logView
    end
    return JimiProxyExt.identity("Logs",LOGS_ICON)
        .."add_smalltext|`9Choose a log category from Settings.|left|\n"
end

function JimiProxyExt.pageContent(page)
    if page=="news" then return JimiProxyExt.newsContent() end
    if page=="features" then return JimiProxyExt.featureContent() end
    if page=="credits" then return JimiProxyExt.creditsContent() end
    return JimiProxySettings.content()
end

function JimiProxyExt.showTotalFitur()
    return JimiProxyExt.UI.open("features")
end

function JimiProxyExt.showMenu(native)
    return JimiProxyExt.UI.open("features", native)
end

function JimiProxyExt.recLine(r)
    local text = tostring(r.text or "")
    if JimiProxyStream and JimiProxyStream.enabled and type(JimiProxyStream.redact) == "function" then
        text = JimiProxyStream.redact(text)
    end
    return "`8[" .. tostring(r.time or "--:--:--") .. "] `9[" .. cut(r.world or "UNKNOWN", 14) .. "] `w" .. cut(text, 88)
end

function JimiProxyExt.showLogs(native)
    JimiProxyExt.logView=nil
    if JimiProxySettings then return JimiProxySettings.open("home",native) end
    return false
end

local function clearLogList(list)
    if type(list)~="table" then return end
    for i=#list,1,-1 do list[i]=nil end
end

function JimiProxyExt.clearAllLogs()
    local lists={wheelLogs,dropLogs,sbLogs,bjGemLogs,worldLogs,playerJoinLogs,playerLeaveLogs,vendingLogs,walletLogs,lockDropLogs,wlDropLogs,dlDropLogs,bglDropLogs}
    for _,list in ipairs(lists)do clearLogList(list) end
    currentLogType=""
    currentLogPage=1
    JimiProxyExt.logView=nil
    overlay("`2All session logs cleared.")
    return true
end

function JimiProxyExt.lockLogsContent()
    return ""
end

function JimiProxyExt.showLockLogs(native)
    JimiProxyExt.logView=nil
    return JimiProxySettings.open("home",native)
end

function JimiProxyExt.currentLogList()
    local map={
        drop=dropLogs,
        vending=vendingLogs,
        player_join=playerJoinLogs,
        player_leave=playerLeaveLogs,
        world=worldLogs,
        wheel=wheelLogs,
        sb=sbLogs,
        bj_gems=bjGemLogs,
        lock_wl=wlDropLogs,
        lock_dl=dlDropLogs,
        lock_bgl=bglDropLogs
    }
    return map[currentLogType]
end

function JimiProxyExt.showLogPage(title,list,page,native)
    page=math.max(1,tonumber(page) or 1)
    local totalPage=math.max(1,math.ceil(#list/LOG_PER_PAGE))
    if page>totalPage then page=totalPage end
    currentLogPage=page

    local out="add_textbox|`2"..cleanDialog(title).."|left|\n"
        .."add_smalltext|`8"..tostring(#list).." entries `9• Page "..page.."/"..totalPage.."|left|\n"
        .."add_spacer|tiny|\n"
    local first=(page-1)*LOG_PER_PAGE+1
    local last=math.min(first+LOG_PER_PAGE-1,#list)
    if #list==0 then
        out=out.."add_smalltext|`6No data yet.|left|\n"
    else
        for i=first,last do
            out=out.."add_smalltext|"..cleanDialog(JimiProxyExt.recLine(list[i])).."|left|\n"
        end
    end
    out=out.."add_spacer|tiny|\n"
    if page>1 then out=out.."add_button|log_prev|`9< Prev|noflags|0|0|\n" end
    if page<totalPage then out=out.."add_button|log_next|`9Next >|noflags|0|0|\n" end
    out=out.."add_button|log_clear_current|`4Clear This Log|noflags|0|0|\n"
        .."add_button|logs_back|`9Back to Settings|noflags|0|0|\n"
    JimiProxyExt.logView=out
    return JimiProxyExt.UI.open("logs",native)
end

function JimiProxyExt.handleLogAction(button,native)
    local categories={
        log_drop={key="drop",title="Drop Logs",list=dropLogs},
        log_vending={key="vending",title="Vending Logs",list=vendingLogs},
        log_player_join={key="player_join",title="Player Join Logs",list=playerJoinLogs},
        log_player_leave={key="player_leave",title="Player Leave Logs",list=playerLeaveLogs},
        log_world={key="world",title="World Logs",list=worldLogs},
        log_wheel={key="wheel",title="Wheel Logs",list=wheelLogs},
        log_sb={key="sb",title="SB Logs",list=sbLogs},
        log_bj_gems={key="bj_gems",title="BJ Logs",list=bjGemLogs},
        log_lock_wl={key="lock_wl",title="World Lock Drops",list=wlDropLogs},
        log_lock_dl={key="lock_dl",title="Diamond Lock Drops",list=dlDropLogs},
        log_lock_bgl={key="lock_bgl",title="Blue Gem Lock Drops",list=bglDropLogs}
    }

    if button=="logs_back" then
        JimiProxyExt.logView=nil
        return JimiProxySettings.open("home",native)
    end

    if button=="log_clear_current" then
        local list=JimiProxyExt.currentLogList()
        if list then clearLogList(list) end
    elseif button=="log_next" then
        currentLogPage=currentLogPage+1
    elseif button=="log_prev" then
        currentLogPage=math.max(1,currentLogPage-1)
    else
        local selected=categories[button]
        if selected then
            currentLogType=selected.key
            currentLogPage=1
        else
            return false
        end
    end

    for _,category in pairs(categories) do
        if category.key==currentLogType then
            return JimiProxyExt.showLogPage(category.title,category.list,currentLogPage,native)
        end
    end
    return true
end

function JimiProxyExt.isProxyText(text)
    text = strip(text or "")
    return text:find("%[" .. TAG .. "%]") or text:find(TAG, 1, true)
end

function JimiProxyExt.numColor(n)
    n = tonumber(n) or 0
    if n == 0 then return "`4" end
    if n % 2 == 0 then return "`2" end
    return "`4"
end

function JimiProxyExt.calcWheel(n)
    n = tonumber(n) or 0
    local result = 0
    if rouletteMode == "QEME" then
        result = n % 10
        if result == 0 then return result, "QEME", " `6x3" end
        return result, "QEME", ""
    end
    local sum = 0
    for c in tostring(n):gmatch("%d") do sum = sum + (tonumber(c) or 0) end
    result = sum % 10
    if rouletteMode == "LEME" then
        if result == 0 then return result, "LEME", " `6x4" end
        if result == 1 then return result, "LEME", " `6x3" end
        if result == 9 then return result, "LEME", " `4AUTO LOSE" end
        return result, "LEME", ""
    end
    if result == 0 then return result, "REME", " `6x3" end
    return result, "REME", ""
end

function JimiProxyExt.parseWheel(text)
    local clean = strip(text or ""):gsub("\r", " "):gsub("\n", " "):gsub("%s+", " ")
    clean = trim(clean)
    if clean == "" or JimiProxyExt.isProxyText(clean) then return nil end
    if not clean:lower():find("spun the wheel", 1, true) then return nil end
    local p, n = clean:match("^(.-)%s+spun%s+the%s+wheel%s+and%s+got%s+(%d+)")
    if not p or not n then return nil end
    p = trim(p)
    p = p:gsub("^%[[^%]]-%]%s*", "")
    p = p:gsub("^%d%d:%d%d:%d%d%s*", "")
    if nickReal ~= "" and nickName ~= "" then
        local low = p:lower()
        if low:find(nickName:lower(), 1, true) then p = nickName end
        if low:find(nickReal:lower(), 1, true) then p = nickName end
    end
    return {player = wheelNickName(p), number = tonumber(n)}
end

function JimiProxyExt.wheelLine(player, number, mode, result, extra)
    extra = tostring(extra or "")
    return "`w[ `2REAL `w] [`2" .. tostring(player or myName()) .. " `wspun the wheel and got " .. JimiProxyExt.numColor(number) .. tostring(number) .. "`w!] [ `2" .. mode .. " `w] [ `2" .. tostring(result) .. " `w]" .. extra
end

function JimiProxyExt.isLocalWheelPlayer(player, netid)
    local nid = tonumber(netid) or 0
    if nid > 0 and nid == myNetID() then return true end

    local p = trim(strip(player or ""):gsub("^@", "")):lower()
    if p == "" then return false end

    local names = {nickName, nickReal, nickLocalName()}
    for _, name in ipairs(names) do
        local n = trim(strip(name or ""):gsub("^@", "")):lower()
        if n ~= "" and p == n then return true end
    end
    return false
end

function JimiProxyExt.emitWheel(parsed, netid)
    if not parsed then return false end
    local result, mode, extra = JimiProxyExt.calcWheel(parsed.number)
    local pname = wheelNickName(parsed.player)
    local key = tostring(pname):lower() .. ":" .. tostring(parsed.number) .. ":" .. mode
    local now = ms()
    local duplicate = recentSpin[key] and (now - recentSpin[key]) < 1700

    local number = tonumber(parsed.number)
    if not duplicate and number and number >= 0 and number <= 36 and JimiProxyExt.isLocalWheelPlayer(parsed.player, netid) then
        lastWheelNumber = math.floor(number)
        applyNick()
    end

    local line = JimiProxyExt.wheelLine(pname, parsed.number, mode, result, extra)

    if not duplicate then
        recentSpin[key] = now
        if activityLogging then
            push(wheelLogs, {time = stamp(), world = worldName(), text = strip(line)}, 80)
        end
        sendConsole(prefix() .. line)
    end

    local bubbleNetID = tonumber(netid) or 0
    if bubbleNetID <= 0 and JimiProxyExt.isLocalWheelPlayer(parsed.player, nil) then
        bubbleNetID = myNetID()
    end

    if bubbleRoulette and bubbleNetID > 0 and bubbleVisibleForNetID(bubbleNetID) then
        if not recentSpinBubble[key] or (now - recentSpinBubble[key]) >= 1700 then
            recentSpinBubble[key] = now
            bubble(line, bubbleNetID)
        end
    end

    return true
end

function JimiProxyExt.logWallet(reason)
    if not activityLogging then return end
    local text=(reason and (tostring(reason).." • ") or "")
        .."WL "..tostring(itemCount(WL_ID))
        .." | DL "..tostring(itemCount(DL_ID))
        .." | BGL "..tostring(itemCount(BGL_ID))
        .." | Gems "..tostring(tonumber(safe(getGems)) or 0)
    push(walletLogs,{time=stamp(),world=worldName(),text=text},80)
end

function JimiProxyExt.logDrop(text)
    if not activityLogging then return end
    text=tostring(text or "")
    local rec={time=stamp(),world=worldName(),text=text}
    push(dropLogs,rec,80)
    local low=strip(text):lower()
    local isWL=low:find("world lock",1,true) or low:find(" wl",1,true)
    local isDL=low:find("diamond lock",1,true) or low:find(" dl",1,true)
    local isBGL=low:find("blue gem lock",1,true) or low:find(" bgl",1,true)
    if isWL or isDL or isBGL or low:find("drop all",1,true) then
        push(lockDropLogs,{time=rec.time,world=rec.world,text=rec.text},80)
        if isWL then push(wlDropLogs,{time=rec.time,world=rec.world,text=rec.text},80) end
        if isDL then push(dlDropLogs,{time=rec.time,world=rec.world,text=rec.text},80) end
        if isBGL then push(bglDropLogs,{time=rec.time,world=rec.world,text=rec.text},80) end
    end
    JimiProxyExt.logWallet("After drop")
end

function JimiProxyExt.logConsoleActivity(text)
    if not activityLogging then return end
    local clean=trim(strip(text or ""))
    if clean=="" or JimiProxyExt.isProxyText(clean) then return end
    local low=clean:lower()
    if low:find("vending machine",1,true) or low:find("you bought",1,true)
        or low:find("you sold",1,true) or (low:find("bought",1,true) and low:find("world lock",1,true)) then
        push(vendingLogs,{time=stamp(),world=worldName(),text=cut(clean,110)},80)
        JimiProxyExt.logWallet("Vending")
    end
end

function JimiProxyExt.logPlayerSpawn(raw)
    if not activityLogging then return end
    raw=tostring(raw or "")
    local id=tonumber(raw:match("netID|(%d+)") or raw:match("netid|(%d+)")) or 0
    if id<=0 or id==myNetID() then return end
    local name=raw:match("name|([^\n]+)") or raw:match("name|([^|]+)") or ("NetID "..id)
    name=trim(strip(name):gsub("^@",""))
    local now=ms()
    if playerLogJoinAt[id] and now-playerLogJoinAt[id]<1500 then return end
    playerLogJoinAt[id]=now
    playerLogNames[id]=name
    push(playerJoinLogs,{time=stamp(),world=worldName(),text=name.." joined"},80)
end

function JimiProxyExt.logPlayerRemove(var)
    if not activityLogging then return end
    local id=tonumber(type(var)=="table" and (var.v2 or var.netid or var.netID or var.net_id)) or 0
    if id<=0 then
        local raw=tostring(type(var)=="table" and var.v2 or "")
        id=tonumber(raw:match("netID|(%d+)") or raw:match("netid|(%d+)")) or 0
    end
    if id<=0 or id==myNetID() then return end
    local name=playerLogNames[id] or ("NetID "..id)
    playerLogNames[id]=nil
    playerLogJoinAt[id]=nil
    push(playerLeaveLogs,{time=stamp(),world=worldName(),text=name.." left"},80)
end

function JimiProxyExt.confirmDropPacket(itemID, count)
    packet2("action|dialog_return\ndialog_name|drop_item\nitemID|"..tostring(itemID).."|\ncount|"..tostring(count))
end

function JimiProxyExt.onlyPendingDrop()
    local foundID, foundData, total = nil, nil, 0
    local now = ms()
    for id, data in pairs(pendingDrops) do
        if data and (now - (tonumber(data.ts) or 0)) <= (2500 + JimiProxyDelay.drop) then
            foundID, foundData = id, data
            total = total + 1
        end
    end
    if total == 1 then return foundID, foundData end
    return nil, nil
end

function JimiProxyExt.dropItemFast(itemID, count, label)
    itemID = tonumber(itemID) or 0
    count = tonumber(count) or 0
    local info = lockInfo(itemID)
    label = label or info.short

    if count <= 0 then sendConsole("`4Invalid amount"); return true end
    if JimiProxyExt.inventoryBusy() or converting then
        sendConsole("`6Drop busy - wait a moment")
        return true
    end

    local before = itemCount(itemID)
    if before < count then
        sendConsole("`4Not enough " .. tostring(info.name or label))
        return true
    end
    if not JimiProxyExt.beginInventoryTxn("direct_drop") then
        sendConsole("`6Drop busy - wait a moment")
        return true
    end

    pendingDrops[itemID] = {count = count, label = label, ts = ms(), sent = false, txn = "direct_drop", before = before}
    packet2("action|drop\nitemID|" .. tostring(itemID))

    runThread(function()
        local started = ms()
        local success = false
        while ms() - started < (3200 + JimiProxyDelay.drop) do
            local pd = pendingDrops[itemID]
            if not pd or pd.txn ~= "direct_drop" then break end
            if pd.sent and itemCount(itemID) <= before - count then
                success = true
                break
            end
            sleep(100)
        end

        local pd = pendingDrops[itemID]
        if pd and pd.txn == "direct_drop" then pendingDrops[itemID] = nil end
        JimiProxyExt.endInventoryTxn("direct_drop")

        if success then
            local msg = "Drop " .. tostring(info.name or label) .. " " .. tostring(count)
            JimiProxyExt.logDrop(msg)
            sendConsole("`c" .. msg)
        else
            sendConsole("`4Drop failed")
        end
    end)

    return true
end

local LockTools = {busy = false, MAX_LOCK_CONVERSIONS = 3} 

function LockTools.totalValue()
    return itemCount(BGL_ID) * 10000 + itemCount(DL_ID) * 100 + itemCount(WL_ID)
end

function LockTools.waitUntil(cond, timeout, delay)
    timeout = tonumber(timeout) or 1800
    delay = tonumber(delay) or 80
    local started = ms()
    while ms() - started < timeout do
        if cond() then return true end
        sleep(delay)
    end
    return cond()
end

function LockTools.activate(id)
    id = tonumber(id) or 0
    local beforeB = itemCount(BGL_ID)
    local beforeD = itemCount(DL_ID)
    local beforeW = itemCount(WL_ID)
    pcall(function() sendPacketRaw(false, {type = 10, value = id}) end)
    return LockTools.waitUntil(function()
        return itemCount(BGL_ID) ~= beforeB or itemCount(DL_ID) ~= beforeD or itemCount(WL_ID) ~= beforeW
    end, 2000, 100)
end

function LockTools.findPlan(value)
    value = math.max(0, math.floor(tonumber(value) or 0))
    local haveB = itemCount(BGL_ID)
    local haveD = itemCount(DL_ID)
    local haveW = itemCount(WL_ID)
    local maxB = math.min(math.floor(value / 10000), haveB)
    for b = maxB, 0, -1 do
        local left = value - b * 10000
        local maxD = math.min(math.floor(left / 100), haveD)
        for d = maxD, 0, -1 do
            local w = left - d * 100
            if w >= 0 and w <= haveW then
                return {bgl = b, dl = d, wl = w}
            end
        end
    end
    return nil
end

function LockTools.preparePlan(value)
    value = math.max(0, math.floor(tonumber(value) or 0))
    local total = LockTools.totalValue()
    if total < value then
        return nil, "Not enough locks. Need " .. valueText(value - total) .. " more."
    end

    for _ = 1, LockTools.MAX_LOCK_CONVERSIONS do
        local plan = LockTools.findPlan(value)
        if plan then return plan end

        local wlRemainder = value % 100
        if itemCount(WL_ID) < wlRemainder then
            if itemCount(DL_ID) > 0 then
                if not LockTools.activate(DL_ID) then return nil, "Failed to break DL into WL." end
            elseif itemCount(BGL_ID) > 0 then
                if not LockTools.activate(BGL_ID) then return nil, "Failed to break BGL into DL." end
            else
                return nil, "Unable to create the required WL amount."
            end
        elseif itemCount(BGL_ID) > 0 then
            if not LockTools.activate(BGL_ID) then return nil, "Failed to break BGL into DL." end
        elseif itemCount(DL_ID) > 0 then
            if not LockTools.activate(DL_ID) then return nil, "Failed to break DL into WL." end
        else
            return nil, "Unable to make an exact lock value."
        end
        sleep(160)
    end
    return nil, "Too many lock conversions."
end

function LockTools.dropItem(id, count, label, announce)
    id = tonumber(id) or 0
    count = math.max(0, math.floor(tonumber(count) or 0))
    if count <= 0 then return true end
    local before = itemCount(id)
    if before < count then return false end

    pendingDrops[id] = {count = count, label = label or lockInfo(id).short, ts = ms(), sent = false, txn = JimiProxyExt.inventoryTxn, before = before}
    packet2("action|drop\nitemID|" .. tostring(id))

    local ok = LockTools.waitUntil(function()
        return itemCount(id) <= before - count
    end, 3200 + JimiProxyDelay.drop, 100)

    local pd = pendingDrops[id]
    if pd and pd.count == count then pendingDrops[id] = nil end

    if ok and announce ~= false then
        local msg = "Drop " .. tostring(count) .. " " .. tostring(label or lockInfo(id).short)
        JimiProxyExt.logDrop(msg)
    end
    return ok
end

function LockTools.dropPlan(plan, announce)
    local jobs = {
        {id = BGL_ID, count = tonumber(plan and plan.bgl) or 0, label = "BGL"},
        {id = DL_ID, count = tonumber(plan and plan.dl) or 0, label = "DL"},
        {id = WL_ID, count = tonumber(plan and plan.wl) or 0, label = "WL"}
    }
    for _, job in ipairs(jobs) do
        if job.count > 0 then
            if not LockTools.dropItem(job.id, job.count, job.label, announce) then
                return false, "Failed to drop " .. job.count .. " " .. job.label .. "."
            end
            sleep(140)
        end
    end
    return true
end

function LockTools.countsText(counts)
    counts = counts or {}
    local out = {}
    local b = tonumber(counts[BGL_ID]) or 0
    local d = tonumber(counts[DL_ID]) or 0
    local w = tonumber(counts[WL_ID]) or 0
    if b > 0 then table.insert(out, b .. " BGL") end
    if d > 0 then table.insert(out, d .. " DL") end
    if w > 0 then table.insert(out, w .. " WL") end
    if #out == 0 then return "0 WL" end
    return table.concat(out, " + ")
end

function JimiProxyExt.dropValue(value)
    value = math.floor(tonumber(value) or 0)
    if value <= 0 then sendConsole("`6Example: /cd 150"); return true end
    if JimiProxyExt.inventoryBusy() or converting or LockTools.busy then
        sendConsole("`6Drop busy - wait a moment")
        return true
    end
    if not JimiProxyExt.beginInventoryTxn("custom_drop") then
        sendConsole("`6Drop busy - wait a moment")
        return true
    end

    LockTools.busy = true
    runThread(function()
        local okRun, runErr = pcall(function()
            local plan, err = LockTools.preparePlan(value)
            if not plan then error(tostring(err or "unable to prepare locks"), 0) end
            local ok, dropErr = LockTools.dropPlan(plan, false)
            if not ok then error(tostring(dropErr or "drop error"), 0) end
            local msg = "Custom Drop " .. tostring(value) .. " WL"
            JimiProxyExt.logDrop(msg)
            sendConsole("`c" .. msg)
        end)
        LockTools.busy = false
        JimiProxyExt.endInventoryTxn("custom_drop")
        if not okRun then sendConsole("`4Custom Drop failed: `w" .. tostring(runErr)) end
    end)
    return true
end

function JimiProxyExt.dropAllLocks()
    if JimiProxyExt.inventoryBusy() or converting or LockTools.busy then
        sendConsole("`6Drop busy - wait a moment")
        return true
    end
    local b, d, w = itemCount(BGL_ID), itemCount(DL_ID), itemCount(WL_ID)
    if b + d + w <= 0 then sendConsole("`4No locks"); return true end
    if not JimiProxyExt.beginInventoryTxn("drop_all") then
        sendConsole("`6Drop busy - wait a moment")
        return true
    end

    LockTools.busy = true
    runThread(function()
        local okRun, runErr = pcall(function()
            local plan = {bgl = b, dl = d, wl = w}
            local ok, err = LockTools.dropPlan(plan, false)
            if not ok then error(tostring(err or "drop error"), 0) end
            local msg = "Drop All " .. LockTools.countsText({[BGL_ID] = b, [DL_ID] = d, [WL_ID] = w})
            JimiProxyExt.logDrop(msg)
            sendConsole("`c" .. msg)
        end)
        LockTools.busy = false
        JimiProxyExt.endInventoryTxn("drop_all")
        if not okRun then sendConsole("`4Drop All failed: `w" .. tostring(runErr)) end
    end)
    return true
end

function JimiProxyExt.tileID(t)
    return tonumber(t and (t.fg or t.foreground or t.id or t.itemid or t.itemID)) or 0
end

function JimiProxyExt.tileXY(t)
    if type(t) ~= "table" then return nil, nil end
    local pos = type(t.pos) == "table" and t.pos or nil
    local x = tonumber(t.x or t.posX or t.pos_x or t.tileX or t.tile_x or (pos and pos.x))
    local y = tonumber(t.y or t.posY or t.pos_y or t.tileY or t.tile_y or (pos and pos.y))
    return x, y
end

function JimiProxyExt.getTilesSafe()
    local tiles = safe(getTiles)
    if type(tiles) ~= "table" then tiles = safe(GetTiles) end
    if type(tiles) ~= "table" then return {} end
    return tiles
end

function JimiProxyExt.currentTile()
    local p = localPlayer()
    if type(p) ~= "table" then return nil, nil end
    local pos = type(p.pos) == "table" and p.pos or nil
    local x = tonumber(p.posX or p.pos_x or p.x or (pos and pos.x))
    local y = tonumber(p.posY or p.pos_y or p.y or (pos and pos.y))
    if not x or not y then return nil, nil end
    return math.floor(x / 32), math.floor(y / 32)
end

function JimiProxyExt.tileDistance(x1, y1, x2, y2)
    if x1 == nil or y1 == nil or x2 == nil or y2 == nil then return 9999 end
    local dx, dy = x1 - x2, y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

function JimiProxyExt.findTelephone()
    local px, py = JimiProxyExt.currentTile()
    local bestX, bestY, bestDist = nil, nil, math.huge

    for _, t in pairs(JimiProxyExt.getTilesSafe()) do
        if JimiProxyExt.tileID(t) == TELEPHONE_ID then
            local x, y = JimiProxyExt.tileXY(t)
            if x ~= nil and y ~= nil then
                local d = JimiProxyExt.tileDistance(px, py, x, y)
                if d < bestDist then
                    bestX, bestY, bestDist = x, y, d
                end
            end
        end
    end

    return bestX, bestY
end

function JimiProxyExt.nearTelephone(tx, ty)
    local px, py = JimiProxyExt.currentTile()
    return JimiProxyExt.tileDistance(px, py, tx, ty) <= 3
end

function JimiProxyExt.moveNearTelephone(tx, ty)
    if JimiProxyExt.nearTelephone(tx, ty) then return true end

    local called = false
    if type(FindPath) == "function" then
        called = pcall(FindPath, tx, ty)
    elseif type(findPath) == "function" then
        called = pcall(findPath, tx, ty)
    end

    if not called then return false end

    local started = ms()
    while ms() - started < 4500 do
        if JimiProxyExt.nearTelephone(tx, ty) then return true end
        sleep(90)
    end
    return JimiProxyExt.nearTelephone(tx, ty)
end

function JimiProxyExt.sendBGLConvert(tx, ty)
    packet2(
        "action|dialog_return\n" ..
        "dialog_name|phonecall\n" ..
        "tilex|" .. tostring(math.floor(tx)) .. "|\n" ..
        "tiley|" .. tostring(math.floor(ty)) .. "|\n" ..
        "num|-34|\n" ..
        "buttonClicked|chc0"
    )
end

function JimiProxyExt.waitConvert(beforeDL, beforeBGL, beforeSignal, timeout)
    local started = ms()
    timeout = tonumber(timeout) or 5000

    while ms() - started < timeout do
        if cvSignal > beforeSignal then return true end
        if itemCount(BGL_ID) > beforeBGL then return true end
        if itemCount(DL_ID) <= beforeDL - 100 then return true end
        sleep(100)
    end

    return cvSignal > beforeSignal
        or itemCount(BGL_ID) > beforeBGL
        or itemCount(DL_ID) <= beforeDL - 100
end

function JimiProxyExt.convertDLToBGL()
    if converting or JimiProxyExt.inventoryBusy() or LockTools.busy then
        overlay("`6Inventory operation busy")
        return true
    end

    local dlNow = itemCount(DL_ID)
    if dlNow < 100 then
        say("`4Need at least `w100 DL `4to convert.")
        return true
    end

    local tx, ty = JimiProxyExt.findTelephone()
    if tx == nil or ty == nil then
        say("`4Telephone not found in this world.")
        return true
    end

    if not JimiProxyExt.beginInventoryTxn("convert") then
        overlay("`6Inventory operation busy")
        return true
    end
    converting = true
    cvLastError = ""

    runThread(function()
        if not JimiProxyExt.moveNearTelephone(tx, ty) then
            converting = false
            JimiProxyExt.endInventoryTxn("convert")
            overlay("`4Can't reach Telephone. Stand within 3 blocks and use /cv again.")
            return
        end

        local wanted = math.floor(itemCount(DL_ID) / 100)
        local made = 0

        for _ = 1, wanted do
            local beforeDL = itemCount(DL_ID)
            local beforeBGL = itemCount(BGL_ID)
            if beforeDL < 100 then break end

            if not JimiProxyExt.nearTelephone(tx, ty) and not JimiProxyExt.moveNearTelephone(tx, ty) then
                cvLastError = "Telephone out of range"
                break
            end

            local success = false

            for _attempt = 1, 3 do
                local signalBefore = cvSignal
                cvLastError = ""

                JimiProxyExt.sendBGLConvert(tx, ty)

                if JimiProxyExt.waitConvert(beforeDL, beforeBGL, signalBefore, 5000) then
                    success = true
                    break
                end

                if cvLastError ~= "" and not JimiProxyExt.nearTelephone(tx, ty) then
                    JimiProxyExt.moveNearTelephone(tx, ty)
                end
                sleep(250)
            end

            if not success then break end

            made = made + 1
            sleep(250)
        end

        converting = false
        JimiProxyExt.endInventoryTxn("convert")

        if made > 0 then
            overlay("`cConverted `w" .. tostring(made * 100) .. " DL `6-> `e" .. tostring(made) .. " BGL")
        else
            local reason = cvLastError ~= "" and (" (" .. cvLastError .. ")") or ""
            overlay("`4Convert failed" .. reason)
        end
    end)

    return true
end

local bj = {
    lockValue = {
        [WL_ID] = 1,
        [DL_ID] = 100,
        [BGL_ID] = 10000
    },
    lockName = {
        [WL_ID] = "WL",
        [DL_ID] = "DL",
        [BGL_ID] = "BGL"
    },
    p1 = nil,
    p2 = nil,
    scanBusy = false,
    takeBusy = false,
    payoutBusy = false,
    tax = 3,
    taxBps = 300,
    round = 0,
    bet = nil,
    lastBet = nil,
    lastWinner = 0,
    lastReason = nil
}

function bj.playerTile()
    local p = localPlayer()
    local x = tonumber(p and (p.posX or p.x or (p.pos and p.pos.x))) or 0
    local y = tonumber(p and (p.posY or p.y or (p.pos and p.pos.y))) or 0
    return math.floor(x / 32), math.floor(y / 32)
end

function bj.samePos(a, b)
    return a and b and a.x == b.x and a.y == b.y
end

function bj.posText(pos)
    if not pos then return "not set" end
    return tostring(pos.x) .. "," .. tostring(pos.y)
end

function bj.objectList()
    local list = safe(getObjectList)
    if type(list) == "table" then return list end
    list = safe(GetObjectList)
    if type(list) == "table" then return list end
    return {}
end

function bj.objectPos(obj)
    if type(obj) ~= "table" then return nil, nil end
    return tonumber(obj.posX or obj.x or (obj.pos and obj.pos.x)),
           tonumber(obj.posY or obj.y or (obj.pos and obj.pos.y))
end

function bj.objectTile(obj)
    local x, y = bj.objectPos(obj)
    if not x or not y then return nil, nil end
    return math.floor(x / 32), math.floor(y / 32)
end

function bj.objectItemID(obj)
    return tonumber(obj and (obj.itemid or obj.itemID or obj.id_)) or 0
end

function bj.objectAmount(obj)
    return math.max(0, math.floor(tonumber(obj and (obj.amount or obj.count)) or 0))
end

function bj.objectOID(obj)
    return tonumber(obj and (obj.id or obj.oid or obj.objectID)) or 0
end

function bj.collectObject(obj)
    local oid = bj.objectOID(obj)
    local x, y = bj.objectPos(obj)
    if oid <= 0 or not x or not y then return false end
    if bj.objectItemID(obj) == GEM_ID then return false end

    pcall(function()
        sendPacketRaw(false, {type = 11, value = oid, x = x, y = y})
    end)
    return true
end

function bj.setPos(key, label)
    local x, y = bj.playerTile()
    bj[key] = {x = x, y = y}
    greenBox(x, y)
    overlay("`c" .. label .. " `6position set")
    return true
end

function bj.scanBetAt(pos, objects)
    local scan = {value = 0, targets = {}, counts = {}}
    if not pos then return scan end

    for _, obj in pairs(objects or bj.objectList()) do
        local id = bj.objectItemID(obj)
        local lockValue = bj.lockValue[id]
        if lockValue then
            local x, y = bj.objectTile(obj)
            local amount = bj.objectAmount(obj)
            if x == pos.x and y == pos.y and amount > 0 then
                scan.value = scan.value + amount * lockValue
                scan.counts[id] = (scan.counts[id] or 0) + amount
                scan.targets[#scan.targets + 1] = obj
            end
        end
    end

    return scan
end

function bj.newBet(p1Value, p2Value)
    bj.round = bj.round + 1
    bj.bet = {
        round = bj.round,
        p1 = math.floor(tonumber(p1Value) or 0),
        p2 = math.floor(tonumber(p2Value) or 0),
        total = 0,
        taxPercent = bj.tax,
        taxValue = 0,
        payout = 0,
        paidValue = 0,
        p1Pos = bj.p1 and {x = bj.p1.x, y = bj.p1.y} or nil,
        p2Pos = bj.p2 and {x = bj.p2.x, y = bj.p2.y} or nil,
        ready = false,
        paid = false,
        closed = false,
        winner = 0
    }

    bj.bet.total = bj.bet.p1 + bj.bet.p2
    bj.bet.taxValue = JimiProxyRules.taxValue(bj.bet.total, bj.taxBps)
    bj.bet.payout = bj.bet.total - bj.bet.taxValue
    bj.bet.ready = bj.bet.p1 > 0 and bj.bet.p1 == bj.bet.p2
end

function bj.takeBet()
    if bj.takeBusy then
        say("`6Take is already running.")
        return true
    end

    if bj.lastBet and bj.lastWinner > 0 and not bj.lastBet.paid then
        say("`6Finish the last payout first with /w" .. tostring(bj.lastWinner) .. ".")
        return true
    end

    if not bj.p1 or not bj.p2 then
        say("`4Set /p1 and /p2 first.")
        return true
    end

    if bj.samePos(bj.p1, bj.p2) then
        say("`4P1 and P2 positions cannot be the same.")
        return true
    end

    if bj.payoutBusy then
        say("`6Lock operation is still running.")
        return true
    end

    if bj.bet and bj.bet.ready and not bj.bet.closed then
        say("`6Round already active. Use /w1 or /w2 first.")
        return true
    end

    bj.takeBusy = true
    runThread(function()
        local ok, err = pcall(function()
            local objects = bj.objectList()
            local p1Scan = bj.scanBetAt(bj.p1, objects)
            local p2Scan = bj.scanBetAt(bj.p2, objects)

            if p1Scan.value <= 0 or p2Scan.value <= 0 then
                say("`4Drop missing `8| `wP1 " .. valueText(p1Scan.value) ..
                    " `8| `wP2 " .. valueText(p2Scan.value))
                return
            end

            if p1Scan.value ~= p2Scan.value then
                say("`4Drop mismatch `8| `wP1 " .. valueText(p1Scan.value) ..
                    " `8| `wP2 " .. valueText(p2Scan.value))
                return
            end

            local beforeValue = LockTools.totalValue()

            for _, obj in ipairs(p1Scan.targets) do
                bj.collectObject(obj)
                sleep(20)
            end
            for _, obj in ipairs(p2Scan.targets) do
                bj.collectObject(obj)
                sleep(20)
            end

            local expected = p1Scan.value + p2Scan.value
            local collected = LockTools.waitUntil(function()
                return LockTools.totalValue() >= beforeValue + expected
            end, 2800, 100)

            if not collected then
                say("`4Take incomplete. Check backpack space and dropped locks.")
                return
            end

            bj.newBet(p1Scan.value, p2Scan.value)
            local bet = bj.bet

            say("`2Round ready `8| `wP1 `2" .. LockTools.countsText(p1Scan.counts) ..
                " `8| `wP2 `2" .. LockTools.countsText(p2Scan.counts))
            say("`wTax `2" .. bet.taxPercent .. "% `8| `wPayout `2" ..
                valueText(bet.payout) .. " `8| `wChoose `2/w1 `wor `2/w2")
        end)

        bj.takeBusy = false
        if not ok then
            say("`4Take error: `w" .. tostring(err or "unknown"))
        end
    end)

    return true
end

function bj.setTax(value)
    if value == nil then
        say("`2Tax `w" .. bj.tax .. "%")
        return true
    end

    local basis = JimiProxyRules.parseTax(value)
    if not basis then
        say("`4Tax: 0-100%, up to two decimal places.")
        return true
    end

    bj.taxBps = basis
    bj.tax = basis / 100
    say("`2Tax: `w" .. bj.tax .. "%")
    return true
end

function bj.moveTo(pos)
    if not pos then return false end

    local function nearTarget()
        local px, py = bj.playerTile()
        return math.abs(px - pos.x) <= 1 and math.abs(py - pos.y) <= 1
    end

    if nearTarget() then return true end

    local called = false
    if type(FindPath) == "function" then
        called = pcall(FindPath, pos.x, pos.y)
    elseif type(findPath) == "function" then
        called = pcall(findPath, pos.x, pos.y)
    end

    if not called then return false end
    return LockTools.waitUntil(nearTarget, 5000, 120)
end

function bj.payWinner(winner)
    winner = tonumber(winner) or 0

    if bj.payoutBusy then
        say("`6Payout is still running.")
        return true
    end

    local bet = bj.lastBet
    if not bet then
        say("`6No round ready for payout.")
        return true
    end

    if winner ~= bj.lastWinner or winner <= 0 then
        say("`4Use /w" .. tostring(bj.lastWinner) .. " to finish this round.")
        return true
    end

    if bet.paid then
        say("`6This round is already paid.")
        return true
    end

    local remaining = bet.payout - bet.paidValue
    if remaining <= 0 then
        bet.paid = true
        return true
    end

    if LockTools.busy then
        say("`6Lock operation is busy. Payout was not started.")
        return true
    end

    bj.payoutBusy = true
    LockTools.busy = true

    runThread(function()
        local backX, backY = bj.playerTile()
        local target = winner == 1 and bet.p1Pos or bet.p2Pos

        say("`2P" .. winner .. " selected `8| `wPayout `2" ..
            remaining .. " WL `8(`2" .. valueText(remaining) .. "`8)")

        local plan, err = LockTools.preparePlan(remaining)
        if not plan then
            say("`4Payout failed: `w" .. tostring(err or "lock conversion error"))
            LockTools.busy = false
            bj.payoutBusy = false
            return
        end

        if not bj.moveTo(target) then
            say("`4Payout failed: cannot reach P" .. winner ..
                " position " .. bj.posText(target))
            LockTools.busy = false
            bj.payoutBusy = false
            return
        end

        sleep(250)

        local jobs = {
            {id = BGL_ID, count = plan.bgl, label = "BGL"},
            {id = DL_ID, count = plan.dl, label = "DL"},
            {id = WL_ID, count = plan.wl, label = "WL"}
        }

        for _, job in ipairs(jobs) do
            if job.count > 0 then
                if LockTools.dropItem(job.id, job.count, job.label, false) then
                    bet.paidValue = bet.paidValue + job.count * bj.lockValue[job.id]
                    say("`2Dropped `w" .. job.count .. " " .. job.label ..
                        " `8| `wPaid `2" .. bet.paidValue .. "/" .. bet.payout .. " WL")
                else
                    say("`4Payout drop failed: `w" .. job.count .. " " .. job.label)
                    break
                end
                sleep(160)
            end
        end

        if bet.paidValue >= bet.payout then
            bet.paidValue = bet.payout
            bet.paid = true
            say("`2Payout complete `8| `wTax retained `2" ..
                bet.taxValue .. " WL `8(`2" .. valueText(bet.taxValue) .. "`8)")
        else
            say("`4Payout incomplete `8| `wRemaining `2" ..
                (bet.payout - bet.paidValue) .. " WL")
        end

        sleep(300)

        if type(FindPath) == "function" then
            safe(FindPath, backX, backY)
        elseif type(findPath) == "function" then
            safe(findPath, backX, backY)
        end

        LockTools.busy = false
        bj.payoutBusy = false
    end)

    return true
end

function bj.chooseWinner(winner)
    winner = tonumber(winner) or 0
    if winner ~= 1 and winner ~= 2 then return true end

    if bj.lastBet and bj.lastWinner > 0 and not bj.lastBet.paid then
        if bj.lastWinner == winner then
            return bj.payWinner(winner)
        end
        say("`6Finish current payout with /w" .. tostring(bj.lastWinner) .. " first.")
        return true
    end

    local bet = bj.bet
    if not bet or not bet.ready or bet.closed then
        say("`6Use /take first.")
        return true
    end

    bet.closed = true
    bet.winner = winner

    bj.lastBet = bet
    bj.lastWinner = winner
    bj.lastReason = "manual"
    bj.bet = nil

    if activityLogging then
        push(bjGemLogs, {
            time = stamp(),
            world = worldName(),
            text = "R#" .. tostring(bet.round) ..
                " P" .. tostring(winner) .. " selected | " ..
                valueText(bet.p1) .. " each"
        }, 80)
    end

    return bj.payWinner(winner)
end

function bj.handleCommand(cmd, low)
    if low == "/p1" then return bj.setPos("p1", "P1") end
    if low == "/p2" then return bj.setPos("p2", "P2") end
    if low == "/take" then return bj.takeBet() end
    if low == "/w1" then return bj.chooseWinner(1) end
    if low == "/w2" then return bj.chooseWinner(2) end
    if low == "/tax" then return bj.setTax(nil) end

    local tax = low:match("^/tax%s+(.+)$")
    if tax then return bj.setTax(tax) end

    return false
end

local function parseSB(text)
    local clean = strip(text or ""):gsub("\r", " "):gsub("\n", " "):gsub("%s+", " ")
    local name, wrld, msg = clean:match("%*%*%s*from%s*%((.-)%)%s*in%s*%[(.-)%]%s*%*%*%s*:%s*(.+)")
    if not name then name, wrld, msg = clean:match("from%s*%((.-)%)%s*in%s*%[(.-)%]%s*:%s*(.+)") end
    if activityLogging and name and wrld and msg then push(sbLogs, {time = stamp(), world = trim(wrld), text = trim(name) .. ": " .. trim(msg)}, 80) end
end

local function showBalance()
    local gems = safe(getGems) or 0
    say("`6Balance: `w" .. itemCount(BGL_ID) .. " BGL / " .. itemCount(DL_ID) .. " DL / " .. itemCount(WL_ID) .. " WL")
    say("`6Gems: `w" .. (gems or 0))
    overlay("`9Balance: `2"..itemCount(BGL_ID).."`eBGL `2"..itemCount(DL_ID).."`1DL `2"..itemCount(WL_ID).."`9WL `8| `9Gems: `2"..(gems or 0))
    return true
end

JimiProxyItems = {}

function JimiProxyItems.field(obj, key)
    if obj == nil then return nil end
    local ok, value = pcall(function() return obj[key] end)
    if ok then return value end
    return nil
end

function JimiProxyItems.manager()
    if type(getItemInfoManager) == "function" then
        return safe(getItemInfoManager)
    end
    if type(GetItemInfoManager) == "function" then
        return safe(GetItemInfoManager)
    end
    return nil
end

function JimiProxyItems.byID(id)
    id = math.floor(tonumber(id) or 0)
    if id <= 0 then return nil end

    local mgr = JimiProxyItems.manager()
    if mgr then
        local fn = JimiProxyItems.field(mgr, "getItemInfoByID")
        if type(fn) == "function" then
            local ok, info = pcall(fn, mgr, id)
            if ok and info then return info end
            ok, info = pcall(fn, id)
            if ok and info then return info end
        end
    end

    if type(getItemInfoByID) == "function" then
        local info = safe(getItemInfoByID, id)
        if info then return info end
    end
    if type(GetItemInfo) == "function" then
        local info = safe(GetItemInfo, id)
        if info then return info end
    end
    return nil
end

function JimiProxyItems.byName(name)
    name = trim(name)
    if name == "" then return nil end

    local mgr = JimiProxyItems.manager()
    if mgr then
        local fn = JimiProxyItems.field(mgr, "getItemInfoByName")
        if type(fn) == "function" then
            local ok, info = pcall(fn, mgr, name)
            if ok and info then return info end
            ok, info = pcall(fn, name)
            if ok and info then return info end
        end
    end

    if type(getItemInfoByName) == "function" then
        local info = safe(getItemInfoByName, name)
        if info then return info end
    end
    return nil
end

function JimiProxyItems.name(id)
    local info = JimiProxyItems.byID(id)
    local name = trim(info and JimiProxyItems.field(info, "name") or "")
    if name == "" then name = "Item #" .. tostring(id) end
    return cleanDialog(name), info
end

function JimiProxyItems.inventory()
    local inv = safe(getInventory)
    if type(inv) == "table" then return inv end
    inv = safe(GetInventory)
    if type(inv) == "table" then return inv end
    return {}
end

JimiProxyDaily = {
    PLACE_FX_ID = 88,
    VDROP_MAX_STACK = 200,
    VDROP_MAX_TOTAL = 10000,
    VDROP_STACK_SPACING_X = 16,
    VDROP_STACK_SPACING_Y = 12,
    VDROP_STACKS_PER_ROW = 6,
    placeLastKey = "",
    placeLastAt = 0,
    placeDedupeMs = 90
}

function JimiProxyDaily.showInventory()
    local rows = {}
    local seen = {}

    local function add(it)
        if it == nil or seen[it] then return end
        seen[it] = true
        local id = math.floor(tonumber(JimiProxyItems.field(it, "id") or JimiProxyItems.field(it, "itemID") or JimiProxyItems.field(it, "itemid")) or 0)
        local amount = math.floor(tonumber(JimiProxyItems.field(it, "amount") or JimiProxyItems.field(it, "count") or JimiProxyItems.field(it, "count_")) or 0)
        if id <= 0 or amount <= 0 then return end
        local name, info = JimiProxyItems.name(id)
        rows[#rows + 1] = {
            id = id,
            amount = amount,
            name = name,
            rarity = math.floor(tonumber(info and JimiProxyItems.field(info, "rarity")) or 0)
        }
    end

    local inv = JimiProxyItems.inventory()
    for _, it in ipairs(inv) do add(it) end
    for _, it in pairs(inv) do add(it) end
    table.sort(rows, function(a, b)
        if a.name ~= b.name then return a.name:lower() < b.name:lower() end
        return a.id < b.id
    end)

    local out = theme()
    out = out .. "text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
    out = out .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Inventory|left|32|\n"
    out = out .. "add_smalltext|`8Items: `w" .. tostring(#rows) .. "|left|\n"
    out = out .. "add_spacer|small|\n"

    if #rows == 0 then
        out = out .. "add_smalltext|`8Backpack is empty.|left|\n"
    else
        for _, row in ipairs(rows) do
            local text = "`w" .. cleanDialog(row.name)
                .. " `8[#" .. tostring(row.id) .. "]"
                .. " `6x" .. tostring(row.amount)
                .. " `8• `9Rarity " .. tostring(row.rarity)
            out = out .. "add_label_with_icon|small|" .. text .. "|left|" .. tostring(row.id) .. "|\n"
            out = out .. "add_spacer|small|\n"
        end
    end

    out = out .. "add_quick_exit|\n"
    out = out .. "end_dialog|jimi_inventory_viewer||||\n"
    dialog(out)
    return true
end

function JimiProxyDaily.customDrop(id, amount)
    id = math.floor(tonumber(id) or 0)
    amount = math.floor(tonumber(amount) or 0)
    if id <= 0 or amount <= 0 then
        sendConsole(prefix() .. "`4Usage: /drop <itemID> <amount>")
        return true
    end
    if JimiProxyExt.inventoryBusy() or converting or LockTools.busy then
        sendConsole(prefix() .. "`6A drop transaction is already running.")
        return true
    end

    local have = itemCount(id)
    if have <= 0 then
        sendConsole(prefix() .. "`4Item #" .. tostring(id) .. " was not found in backpack.")
        return true
    end
    if amount > have then
        sendConsole(prefix() .. "`4Not enough item #" .. tostring(id) .. ". Backpack: " .. tostring(have))
        return true
    end

    local name = JimiProxyItems.name(id)
    local txn = "custom_item_drop_" .. tostring(ms()) .. "_" .. tostring(id)
    if not JimiProxyExt.beginInventoryTxn(txn) then
        sendConsole(prefix() .. "`6A drop transaction is already running.")
        return true
    end

    local state = {count = amount, label = name, ts = ms(), sent = false, txn = txn, before = have, strict = true}
    pendingDrops[id] = state
    packet2("action|drop\nitemID|" .. tostring(id))

    runThread(function()
        local started = ms()
        local success = false
        while ms() - started < (3500 + JimiProxyDelay.drop) do
            if pendingDrops[id] ~= state then break end
            if state.sent and itemCount(id) <= have - amount then
                success = true
                break
            end
            sleep(100)
        end

        if pendingDrops[id] == state then pendingDrops[id] = nil end
        JimiProxyExt.endInventoryTxn(txn)
        if success then
            local msg = "Drop " .. tostring(amount) .. "x " .. tostring(name)
            JimiProxyExt.logDrop(msg)
            sendConsole(prefix() .. "`2" .. msg)
        elseif worldName():lower() ~= "exit" then
            sendConsole(prefix() .. "`4Drop failed or timed out.")
        end
    end)
    return true
end

function JimiProxyDaily.splitVisualStacks(amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return {} end
    if amount > JimiProxyDaily.VDROP_MAX_TOTAL then amount = JimiProxyDaily.VDROP_MAX_TOTAL end
    local out = {}
    while amount > 0 do
        local stack = math.min(JimiProxyDaily.VDROP_MAX_STACK, amount)
        out[#out + 1] = stack
        amount = amount - stack
    end
    return out
end

function JimiProxyDaily.visualDrop(itemID, totalAmount)
    itemID = math.floor(tonumber(itemID) or 0)
    totalAmount = math.floor(tonumber(totalAmount) or 0)
    if itemID <= 0 or totalAmount <= 0 then
        sendConsole(prefix() .. "`4Usage: /vdrop <itemID> <amount>")
        return true
    end
    if totalAmount > JimiProxyDaily.VDROP_MAX_TOTAL then
        totalAmount = JimiProxyDaily.VDROP_MAX_TOTAL
    end

    local p = localPlayer()
    if not p then
        sendConsole(prefix() .. "`4Player is not in a world.")
        return true
    end
    local pos = JimiProxyItems.field(p, "pos")
    local baseX = tonumber(JimiProxyItems.field(p, "posX") or JimiProxyItems.field(p, "pos_x") or JimiProxyItems.field(pos, "x"))
    local baseY = tonumber(JimiProxyItems.field(p, "posY") or JimiProxyItems.field(p, "pos_y") or JimiProxyItems.field(pos, "y"))
    if not baseX or not baseY then
        sendConsole(prefix() .. "`4Player position is unavailable.")
        return true
    end

    local stacks = JimiProxyDaily.splitVisualStacks(totalAmount)
    for i, amount in ipairs(stacks) do
        local idx = i - 1
        local col = idx % JimiProxyDaily.VDROP_STACKS_PER_ROW
        local row = math.floor(idx / JimiProxyDaily.VDROP_STACKS_PER_ROW)
        pcall(function()
            sendPacketRaw(true, {
                type = 14,
                netid = -1,
                value = itemID,
                x = baseX - 32 + col * JimiProxyDaily.VDROP_STACK_SPACING_X,
                y = baseY + row * JimiProxyDaily.VDROP_STACK_SPACING_Y,
                padding1 = 2,
                padding2 = 2,
                padding4 = amount
            })
        end)
    end

    local name = JimiProxyItems.name(itemID)
    sendConsole(prefix() .. "`2Visual Drop: `w" .. tostring(name) .. " x" .. tostring(totalAmount) .. " `8(" .. tostring(#stacks) .. " stack(s))")
    return true
end

function JimiProxyDaily.rawValue(pkt)
    return tonumber(JimiProxyItems.field(pkt, "value") or JimiProxyItems.field(pkt, "int_data") or JimiProxyItems.field(pkt, "intData"))
end

function JimiProxyDaily.rawTile(pkt)
    local tx = tonumber(JimiProxyItems.field(pkt, "px") or JimiProxyItems.field(pkt, "int_x") or JimiProxyItems.field(pkt, "intX") or JimiProxyItems.field(pkt, "punchX"))
    local ty = tonumber(JimiProxyItems.field(pkt, "py") or JimiProxyItems.field(pkt, "int_y") or JimiProxyItems.field(pkt, "intY") or JimiProxyItems.field(pkt, "punchY"))
    return tx, ty
end

function JimiProxyDaily.onSendPacketRaw(pkt)
    if tonumber(JimiProxyItems.field(pkt, "type")) ~= 3 then return false end

    local value = math.floor(JimiProxyDaily.rawValue(pkt) or 0)
    if value <= 0 or value == 18 or value == 32 then return false end

    local manager = JimiProxyItems.manager()
    if manager and not JimiProxyItems.byID(value) then return false end

    local tx, ty = JimiProxyDaily.rawTile(pkt)
    if tx == nil or ty == nil then return false end
    tx, ty = math.floor(tx), math.floor(ty)

    local key = tostring(value) .. ":" .. tostring(tx) .. ":" .. tostring(ty)
    local now = ms()
    if key == JimiProxyDaily.placeLastKey and (now - JimiProxyDaily.placeLastAt) < JimiProxyDaily.placeDedupeMs then
        return false
    end
    JimiProxyDaily.placeLastKey = key
    JimiProxyDaily.placeLastAt = now

    sendVar({v1 = "OnParticleEffect", v2 = JimiProxyDaily.PLACE_FX_ID, v3 = {x = tx * 32 + 16, y = ty * 32 + 16}})
    return false
end

function JimiProxyDaily.resetWorld()
    JimiProxyDaily.placeLastKey = ""
    JimiProxyDaily.placeLastAt = 0
    JimiProxyDelay.fastDropKey = ""
    JimiProxyDelay.fastDropAt = 0
end

JimiProxyVends = {
    rows = {},
    query = "",
    world = "",
    activeItemID = nil,
    vendingIDs = {},
    VENDING_ICON = 2978,
    DIGIVEND_ICON = 9268,
    lastPathAt = -100000,
    lastPathKey = ""
}

function JimiProxyVends.clear()
    JimiProxyVends.rows = {}
    JimiProxyVends.query = ""
    JimiProxyVends.world = ""
    JimiProxyVends.activeItemID = nil
    JimiProxyVends.lastPathAt = -100000
    JimiProxyVends.lastPathKey = ""
end

function JimiProxyVends.resolveIDs()
    local ids = {}
    for _, name in ipairs({"Vending Machine", "DigiVend Machine"}) do
        local info = JimiProxyItems.byName(name)
        local id = tonumber(info and JimiProxyItems.field(info, "id"))
        if id and id > 0 then ids[math.floor(id)] = true end
    end
    ids[JimiProxyVends.VENDING_ICON] = true
    ids[JimiProxyVends.DIGIVEND_ICON] = true
    JimiProxyVends.vendingIDs = ids
end

function JimiProxyVends.isVend(id)
    id = math.floor(tonumber(id) or 0)
    if next(JimiProxyVends.vendingIDs) == nil then JimiProxyVends.resolveIDs() end
    return JimiProxyVends.vendingIDs[id] == true
end

function JimiProxyVends.tiles()
    local tiles = safe(getTiles)
    if type(tiles) == "table" then return tiles end
    tiles = safe(GetTiles)
    if type(tiles) == "table" then return tiles end
    return nil
end

function JimiProxyVends.tile(x, y)
    local tile = safe(getTile, x, y)
    if tile ~= nil then return tile end
    return safe(GetTile, x, y)
end

function JimiProxyVends.priceText(price)
    price = math.floor(tonumber(price) or 0)
    if price < 0 then return tostring(math.abs(price)) .. " / 1 WL" end
    if price > 0 then return "1 / " .. tostring(price) .. " WL" end
    return "No price"
end

function JimiProxyVends.playerTile()
    local p = localPlayer()
    if not p then return nil, nil end
    local x, y = playerTilePos(p)
    if x and y then return math.floor(x), math.floor(y) end
    return nil, nil
end

function JimiProxyVends.distance(row)
    local px, py = JimiProxyVends.playerTile()
    if px == nil or py == nil then return math.huge end
    local dx = (tonumber(row.x) or 0) - px
    local dy = (tonumber(row.y) or 0) - py
    return math.floor(math.sqrt(dx * dx + dy * dy) + 0.5)
end

function JimiProxyVends.scan(query)
    JimiProxyVends.clear()
    local w = worldName()
    if w == "" or w:lower() == "unknown" or w:lower() == "exit" or not localPlayer() then
        return false, "Not inside a world."
    end

    local tiles = JimiProxyVends.tiles()
    if type(tiles) ~= "table" then return false, "getTiles is unavailable on this build." end

    JimiProxyVends.resolveIDs()
    local rows = {}
    for _, tile in pairs(tiles) do
        local fg = math.floor(tonumber(JimiProxyItems.field(tile, "fg")) or 0)
        if JimiProxyVends.isVend(fg) then
            local x = tonumber(JimiProxyItems.field(tile, "x"))
            local y = tonumber(JimiProxyItems.field(tile, "y"))
            local extra = JimiProxyItems.field(tile, "extra")
            local itemID = math.floor(tonumber(JimiProxyItems.field(extra, "vend_item")) or 0)
            local price = math.floor(tonumber(JimiProxyItems.field(extra, "vend_price")) or 0)
            if x and y and itemID > 0 then
                local name, info = JimiProxyItems.name(itemID)
                rows[#rows + 1] = {
                    x = math.floor(x), y = math.floor(y), machineID = fg,
                    itemID = itemID, name = name, price = price,
                    iconID = info and itemID or fg
                }
            end
        end
    end

    JimiProxyVends.rows = rows
    JimiProxyVends.world = w
    JimiProxyVends.query = trim(query or "")
    return true
end

function JimiProxyVends.groups(query)
    query = trim(query or ""):lower()
    local numeric = query:match("^%d+$") ~= nil
    local byID, out = {}, {}

    for idx, row in ipairs(JimiProxyVends.rows) do
        local idText = tostring(row.itemID)
        local nameLow = tostring(row.name or ""):lower()
        local match = query == ""
            or (numeric and idText == query)
            or ((not numeric) and nameLow:find(query, 1, true) ~= nil)
        if match then
            local g = byID[idText]
            if not g then
                g = {itemID = row.itemID, name = row.name, iconID = row.iconID, rows = {}, previewPrice = row.price, previewDistance = JimiProxyVends.distance(row)}
                byID[idText] = g
                out[#out + 1] = g
            end
            g.rows[#g.rows + 1] = idx
            local d = JimiProxyVends.distance(row)
            if d < (g.previewDistance or math.huge) then
                g.previewDistance = d
                g.previewPrice = row.price
            end
        end
    end

    table.sort(out, function(a, b)
        local an, bn = tostring(a.name or ""):lower(), tostring(b.name or ""):lower()
        if an ~= bn then return an < bn end
        return (tonumber(a.itemID) or 0) < (tonumber(b.itemID) or 0)
    end)
    return out
end

function JimiProxyVends.showMain(message)
    if JimiProxyVends.world ~= "" and worldName() ~= JimiProxyVends.world then
        JimiProxyVends.clear()
        message = "World changed. Run /vends again."
    end

    local groups = JimiProxyVends.groups(JimiProxyVends.query)
    local out = theme()
    out = out .. "text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
    out = out .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Vending Search|left|" .. tostring(SEARCH_ICON) .. "|\n"
    out = out .. "add_spacer|small|\n"
    out = out .. "add_text_input|vends_search|Search item / ID|" .. cleanDialog(JimiProxyVends.query) .. "|32|\n"
    out = out .. "add_button|vends_search_apply|`2Search|noflags|0|0|\n"
    out = out .. "add_spacer|small|\n"

    if message and trim(message) ~= "" then
        out = out .. "add_smalltext|`6" .. cleanDialog(message) .. "|left|\n"
        out = out .. "add_spacer|small|\n"
    end

    if #groups == 0 then
        out = out .. "add_smalltext|`8No matching vending items.|left|\n"
    else
        for _, g in ipairs(groups) do
            local count = #(g.rows or {})
            local vendWord = count == 1 and "vend" or "vends"
            local label = "`w" .. cleanDialog(g.name) .. " `8[#" .. tostring(g.itemID) .. "] `6• " .. tostring(count) .. " " .. vendWord .. " `8• `2" .. cleanDialog(JimiProxyVends.priceText(g.previewPrice))
            out = out .. "add_label_with_icon_button|small|" .. label .. "|left|" .. tostring(g.iconID or g.itemID) .. "|vend_item_" .. tostring(g.itemID) .. "|\n"
            out = out .. "add_spacer|small|\n"
        end
    end

    if #groups <= 2 then out = out .. "add_spacer|big|\nadd_spacer|big|\n" end
    out = out .. "add_quick_exit|\n"
    out = out .. "end_dialog|jimi_vends_main|||\n"
    dialog(out)
    return true
end

function JimiProxyVends.groupByID(itemID)
    itemID = math.floor(tonumber(itemID) or 0)
    for _, g in ipairs(JimiProxyVends.groups("")) do
        if math.floor(tonumber(g.itemID) or 0) == itemID then return g end
    end
    return nil
end

function JimiProxyVends.detailRows(group)
    local rows = {}
    for _, idx in ipairs((group and group.rows) or {}) do
        local row = JimiProxyVends.rows[idx]
        if row then
            rows[#rows + 1] = {row = row, index = idx, distance = JimiProxyVends.distance(row)}
        end
    end
    table.sort(rows, function(a, b)
        if a.distance ~= b.distance then return a.distance < b.distance end
        return a.index < b.index
    end)
    return rows
end

function JimiProxyVends.showDetail(itemID, message)
    if JimiProxyVends.world == "" or worldName() ~= JimiProxyVends.world then
        JimiProxyVends.clear()
        return JimiProxyVends.showMain("World changed. Run /vends again.")
    end

    local group = JimiProxyVends.groupByID(itemID)
    if not group then return JimiProxyVends.showMain("Item is no longer in the scan result.") end
    JimiProxyVends.activeItemID = group.itemID

    local list = JimiProxyVends.detailRows(group)
    local out = theme()
    out = out .. "text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
    out = out .. "add_label_with_icon|small|`w" .. cleanDialog(group.name) .. " `8[#" .. tostring(group.itemID) .. "]|left|" .. tostring(group.iconID or group.itemID) .. "|\n"
    if message and trim(message) ~= "" then out = out .. "add_smalltext|`6" .. cleanDialog(message) .. "|left|\n" end
    out = out .. "add_spacer|small|\n"

    for _, entry in ipairs(list) do
        local row = entry.row
        local distText = entry.distance == math.huge and "? tiles" or (tostring(entry.distance) .. " tiles")
        out = out .. "add_textbox|`6Price: `2" .. cleanDialog(JimiProxyVends.priceText(row.price)) .. " `8• `w" .. distText .. "|left|\n"
        out = out .. "add_button|vend_go_" .. tostring(entry.index) .. "|`2Teleport to X" .. tostring(row.x) .. " Y" .. tostring(row.y) .. "|noflags|0|0|\n"
        out = out .. "add_spacer|small|\n"
    end

    if #list <= 2 then out = out .. "add_spacer|big|\nadd_spacer|big|\n" end
    out = out .. "add_quick_exit|\n"
    out = out .. "end_dialog|jimi_vends_item|||\n"
    dialog(out)
    return true
end

function JimiProxyVends.rowValid(row)
    if type(row) ~= "table" then return false end
    if JimiProxyVends.world == "" or worldName() ~= JimiProxyVends.world then return false end
    local tile = JimiProxyVends.tile(row.x, row.y)
    if tile == nil then return false end
    local fg = math.floor(tonumber(JimiProxyItems.field(tile, "fg")) or 0)
    if not JimiProxyVends.isVend(fg) then return false end
    local extra = JimiProxyItems.field(tile, "extra")
    local itemID = math.floor(tonumber(JimiProxyItems.field(extra, "vend_item")) or 0)
    return itemID == math.floor(tonumber(row.itemID) or 0)
end

function JimiProxyVends.path(row)
    if not JimiProxyVends.rowValid(row) then return false, "Vending changed or disappeared." end

    local key = tostring(row.x) .. ":" .. tostring(row.y)
    local now = ms()
    if key == JimiProxyVends.lastPathKey and (now - JimiProxyVends.lastPathAt) < 1200 then
        return true
    end
    JimiProxyVends.lastPathKey = key
    JimiProxyVends.lastPathAt = now

    local candidates = {}
    if type(FindPath) == "function" then candidates[#candidates + 1] = {fn = FindPath} end
    if type(findPath) == "function" then candidates[#candidates + 1] = {fn = findPath} end
    if type(growtopia) == "table" and type(growtopia.FindPath) == "function" then candidates[#candidates + 1] = {fn = growtopia.FindPath, owner = growtopia} end
    if type(growtopia) == "table" and type(growtopia.findPath) == "function" then candidates[#candidates + 1] = {fn = growtopia.findPath, owner = growtopia} end
    if #candidates == 0 then return false, "FindPath is unavailable." end

    local c = candidates[1]
    local ok
    if c.owner then
        ok = pcall(c.fn, c.owner, row.x, row.y)
        if not ok then ok = pcall(c.fn, row.x, row.y) end
    else
        ok = pcall(c.fn, row.x, row.y)
    end
    if ok then return true end
    return false, "Pathfind failed."
end

function JimiProxyVends.handleCommand(query)
    local ok, err = JimiProxyVends.scan(query)
    if not ok then
        JimiProxyVends.showMain(err)
        return true
    end
    if #JimiProxyVends.rows == 0 then
        JimiProxyVends.showMain("No stocked vending machines in this world.")
        return true
    end
    JimiProxyVends.showMain()
    return true
end

function JimiProxyVends.handleDialog(packet)
    local dialogName = packetField(packet, "dialog_name") or ""
    local button = packetField(packet, "buttonClicked") or ""

    if dialogName == "jimi_vends_main" then
        JimiProxyVends.query = trim(packetField(packet, "vends_search") or JimiProxyVends.query)
        local itemID = tonumber(button:match("^vend_item_(%d+)$"))
        if itemID then return JimiProxyVends.showDetail(itemID) end
        return JimiProxyVends.showMain()
    end

    if dialogName == "jimi_vends_item" then
        local idx = tonumber(button:match("^vend_go_(%d+)$"))
        if idx and JimiProxyVends.rows[idx] then
            local ok, err = JimiProxyVends.path(JimiProxyVends.rows[idx])
            if not ok then return JimiProxyVends.showDetail(JimiProxyVends.activeItemID, err) end
            return true
        end
        return true
    end
    return false
end

JimiProxyEntrance = {
    PUBLIC_FLAG = 128,
    ids = {},
    tracked = {},
    refreshQueued = false,
    session = 0,
    names = {
        "Portcullis", "House Entrance", "Ancient Stone Gate", "Air Vent", "Forcefield",
        "Jail Door", "Secret Passage", "Red House Entrance", "Coin Door", "Dark Magic Barrier",
        "Jade Portcullis", "Baroque Iron Gate", "Hidden Door", "Growtorial Entrance", "VIP Entrance",
        "Friends Entrance", "Guild Entrance", "Guild Entrance - Normal", "Guild Entrance - Ornate",
        "Team Entrance - Punch", "Team Entrance - Grow", "Team Entrance - Build",
        "Team Entrance Punch", "Team Entrance Grow", "Team Entrance Build"
    }
}

function JimiProxyEntrance.resolveIDs()
    JimiProxyEntrance.ids = {}
    for _, name in ipairs(JimiProxyEntrance.names) do
        local info = JimiProxyItems.byName(name)
        local id = tonumber(info and JimiProxyItems.field(info, "id"))
        if id and id > 0 then JimiProxyEntrance.ids[math.floor(id)] = name end
    end
end

function JimiProxyEntrance.isOpen(flag)
    return ((tonumber(flag) or 0) & JimiProxyEntrance.PUBLIC_FLAG) ~= 0
end

function JimiProxyEntrance.key(x, y)
    return tostring(x) .. ":" .. tostring(y)
end

function JimiProxyEntrance.collect()
    local current = {}
    local tiles = safe(getTiles)
    if type(tiles) ~= "table" then tiles = safe(GetTiles) end
    if type(tiles) ~= "table" then return current end

    for _, tile in pairs(tiles) do
        local fg = math.floor(tonumber(JimiProxyItems.field(tile, "fg")) or 0)
        local name = JimiProxyEntrance.ids[fg]
        if name then
            local x = tonumber(JimiProxyItems.field(tile, "x"))
            local y = tonumber(JimiProxyItems.field(tile, "y"))
            if x ~= nil and y ~= nil then
                x, y = math.floor(x), math.floor(y)
                current[JimiProxyEntrance.key(x, y)] = {
                    x = x,
                    y = y,
                    fg = fg,
                    name = name,
                    open = JimiProxyEntrance.isOpen(JimiProxyItems.field(tile, "flag"))
                }
            end
        end
    end
    return current
end

function JimiProxyEntrance.emit(entry)
    if not entry then return false end
    local ok = pcall(function()
        sendPacketRaw(true, {
            type = 17,
            state = 0x8,
            x = entry.x * 32 + 10,
            y = entry.y * 32 + 17,
            xspeed = entry.open and 2 or 0,
            yspeed = 114,
            padding1 = 114
        })
    end)
    return ok
end

function JimiProxyEntrance.baseline()
    
    JimiProxyEntrance.tracked = JimiProxyEntrance.collect()
end

function JimiProxyEntrance.syncChanged()
    local current = JimiProxyEntrance.collect()

    for key, entry in pairs(current) do
        local old = JimiProxyEntrance.tracked[key]

        if old and old.fg == entry.fg and old.open ~= entry.open then
            JimiProxyEntrance.emit(entry)
        end
    end

    JimiProxyEntrance.tracked = current
end

function JimiProxyEntrance.queueBaseline(delay)
    JimiProxyEntrance.session = JimiProxyEntrance.session + 1
    local session = JimiProxyEntrance.session
    runThread(function()
        sleep(delay or 450)
        if session ~= JimiProxyEntrance.session then return end
        JimiProxyEntrance.baseline()
    end)
end

function JimiProxyEntrance.queueSync(delay)
    if JimiProxyEntrance.refreshQueued then return end
    JimiProxyEntrance.refreshQueued = true
    local session = JimiProxyEntrance.session
    runThread(function()
        sleep(delay or 100)
        JimiProxyEntrance.refreshQueued = false
        if session ~= JimiProxyEntrance.session then return end
        JimiProxyEntrance.syncChanged()
    end)
end

function JimiProxyEntrance.onGame(pkt)
    local tp = tonumber(JimiProxyItems.field(pkt, "type")) or -1

    if tp == 4 then
        JimiProxyEntrance.tracked = {}
        JimiProxyEntrance.queueBaseline(450)
    elseif tp == 5 or tp == 6 or tp == 15 then
        JimiProxyEntrance.queueSync(100)
    end

    return false
end

function JimiProxyEntrance.start()
    JimiProxyEntrance.resolveIDs()
    JimiProxyEntrance.session = JimiProxyEntrance.session + 1
    JimiProxyEntrance.baseline()
end

JimiProxySession = {
    relogging = false,
    currentWorld = "",
    history = {},
    backTarget = nil,
    worldSerial = 0
}

function JimiProxySession.validWorld(name)
    name = trim(name or ""):upper()
    return name ~= "" and name ~= "EXIT" and name ~= "UNKNOWN"
end

function JimiProxySession.sendServer(tp, payload)
    innerPacket = innerPacket + 1
    local ok = false
    if type(sendPacket) == "function" then
        ok = pcall(sendPacket, tonumber(tp) or 2, tostring(payload or ""))
    elseif type(SendPacket) == "function" then
        ok = pcall(SendPacket, tonumber(tp) or 2, tostring(payload or ""))
    end
    innerPacket = innerPacket - 1
    return ok
end

function JimiProxySession.trackWorld()
    local now = trim(worldName()):upper()
    if not JimiProxySession.validWorld(now) then return end

    if JimiProxySession.currentWorld == "" then
        JimiProxySession.currentWorld = now
        if activityLogging then push(worldLogs,{time=stamp(),world=now,text="Enter "..now},80) end
        return
    end

    if now == JimiProxySession.currentWorld then return end

    if JimiProxySession.backTarget and now == JimiProxySession.backTarget then
        JimiProxySession.currentWorld = now
        JimiProxySession.backTarget = nil
        return
    end

    if JimiProxySession.history[#JimiProxySession.history] ~= JimiProxySession.currentWorld then
        JimiProxySession.history[#JimiProxySession.history + 1] = JimiProxySession.currentWorld
        if #JimiProxySession.history > 25 then table.remove(JimiProxySession.history, 1) end
    end

    JimiProxySession.currentWorld = now
    if activityLogging then push(worldLogs,{time=stamp(),world=now,text="Enter "..now},80) end
end

function JimiProxySession.onWorldLoad()
    JimiProxySession.worldSerial = JimiProxySession.worldSerial + 1
    local serial = JimiProxySession.worldSerial
    runThread(function()
        sleep(500)
        if serial == JimiProxySession.worldSerial then
            JimiProxySession.trackWorld()
            JimiProxyExt.logWallet("World load")
        end
    end)
end

function JimiProxySession.disconnect()
    
    JimiProxySession.sendServer(3, "action|quit")
    return true
end

function JimiProxySession.respawn()
    JimiProxySession.sendServer(2, "action|respawn")
    return true
end

function JimiProxySession.relog()
    if JimiProxySession.relogging then
        sendConsole(prefix() .. "`6Relog is already running.")
        return true
    end

    JimiProxySession.trackWorld()
    local target = trim(JimiProxySession.currentWorld ~= "" and JimiProxySession.currentWorld or worldName()):upper()
    if not JimiProxySession.validWorld(target) then
        sendConsole(prefix() .. "`4No active world for relog.")
        return true
    end

    JimiProxySession.relogging = true
    runThread(function()
        local ok, err = pcall(function()
            
            JimiProxySession.sendServer(3, "action|quit_to_exit")

            local waited = 0
            while waited < 5000 do
                sleep(250)
                waited = waited + 250
                if not JimiProxySession.validWorld(worldName()) then break end
            end

            sleep(900)
            JimiProxySession.sendServer(3, "action|join_request\nname|" .. target .. "\ninvitedWorld|0")
        end)
        JimiProxySession.relogging = false
        if not ok then
            sendConsole(prefix() .. "`4Relog failed: `w" .. cleanDialog(err or "unknown"))
        end
    end)
    return true
end

function JimiProxySession.back()
    JimiProxySession.trackWorld()

    while #JimiProxySession.history > 0 do
        local target = table.remove(JimiProxySession.history)
        if JimiProxySession.validWorld(target) and target ~= JimiProxySession.currentWorld then
            JimiProxySession.backTarget = target
            JimiProxySession.sendServer(3, "action|join_request\nname|" .. target .. "\ninvitedWorld|0")
            return true
        end
    end

    sendConsole(prefix() .. "`6No previous world yet.")
    return true
end

JimiProxySession.trackWorld()

JimiProxyHidden = {
    enabled = false,
    applying = false,
    cache = {},
    PALE_SKIN = 3033464831
}

function JimiProxyHidden.players()
    local list = safe(getPlayerList) or safe(GetPlayerList)
    if type(list) == "table" then return list end
    return {}
end

function JimiProxyHidden.netID(p)
    return tonumber(p and (p.netID or p.netid or p.net_id)) or 0
end

function JimiProxyHidden.equipment(p)
    local e = p and (p.equip or p.clothes) or nil
    if not e then return nil end
    return {
        hair = tonumber(e.hair) or 0,
        shirt = tonumber(e.shirt) or 0,
        pants = tonumber(e.pants) or 0,
        feet = tonumber(e.feet) or 0,
        face = tonumber(e.face) or 0,
        hand = tonumber(e.hand) or 0,
        back = tonumber(e.back) or 0,
        mask = tonumber(e.mask) or 0,
        necklace = tonumber(e.necklace) or 0,
        ancestry = tonumber(e.ancestry or e.ances) or 0,
        skin = tonumber(p.skinColor or p.skincolor or p.skin_color) or JimiProxyHidden.PALE_SKIN
    }
end

function JimiProxyHidden.remember(p)
    local id = JimiProxyHidden.netID(p)
    if id <= 0 or JimiProxyHidden.cache[id] ~= nil then return end
    local e = JimiProxyHidden.equipment(p)
    if e then JimiProxyHidden.cache[id] = e end
end

function JimiProxyHidden.blank(id)
    id = tonumber(id) or 0
    if id <= 0 then return false end
    sendNameVar({
        v1 = "OnSetClothing",
        v2 = {x = 0, y = 0, z = 0},
        v3 = {x = 0, y = 0, z = 0},
        v4 = {x = 0, y = 0, z = 0},
        v5 = JimiProxyHidden.PALE_SKIN,
        v6 = {x = 0, y = 0, z = 0}
    }, id)
    return true
end

function JimiProxyHidden.restore(id, e)
    if not e then return false end
    sendNameVar({
        v1 = "OnSetClothing",
        v2 = {x = e.hair, y = e.shirt, z = e.pants},
        v3 = {x = e.feet, y = e.face, z = e.hand},
        v4 = {x = e.back, y = e.mask, z = e.necklace},
        v5 = e.skin or JimiProxyHidden.PALE_SKIN,
        v6 = {x = e.ancestry or 0, y = 0, z = 0}
    }, tonumber(id) or 0)
    return true
end

function JimiProxyHidden.applyAll()
    if not JimiProxyHidden.enabled then return end
    JimiProxyHidden.applying = true
    for _, p in pairs(JimiProxyHidden.players()) do
        local id = JimiProxyHidden.netID(p)
        if id > 0 then
            JimiProxyHidden.remember(p)
            JimiProxyHidden.blank(id)
        end
    end
    JimiProxyHidden.applying = false
end

function JimiProxyHidden.toggle()
    JimiProxyHidden.enabled = not JimiProxyHidden.enabled
    if JimiProxyHidden.enabled then
        JimiProxyHidden.cache = {}
        JimiProxyHidden.applyAll()
        overlay("`2Hidden ON")
        sendConsole(prefix() .. "`2Hidden ON `8- clothes/effects hidden locally; names stay visible.")
    else
        JimiProxyHidden.applying = true
        for id, e in pairs(JimiProxyHidden.cache) do
            JimiProxyHidden.restore(id, e)
        end
        JimiProxyHidden.applying = false
        JimiProxyHidden.cache = {}
        overlay("`4Hidden OFF")
        sendConsole(prefix() .. "`4Hidden OFF")
    end
    return true
end

function JimiProxyHidden.spawnNetID(text)
    text = tostring(text or "")
    return tonumber(text:match("netID|(%d+)") or text:match("netid|(%d+)") or text:match("net_id|(%d+)")) or 0
end

function JimiProxyHidden.variantNetID(var, pkt)
    return tonumber(
        (type(var) == "table" and (var.netid or var.netID or var.net_id))
        or (type(pkt) == "table" and (pkt.netid or pkt.netID or pkt.net_id))
    ) or 0
end

function JimiProxyHidden.onVariant(var, pkt)
    if not var or not JimiProxyHidden.enabled then return false end

    if var.v1 == "OnSpawn" and type(var.v2) == "string" then
        local id = JimiProxyHidden.spawnNetID(var.v2)
        if id > 0 then
            runThread(function()
                sleep(60)
                if not JimiProxyHidden.enabled then return end
                for _, p in pairs(JimiProxyHidden.players()) do
                    if JimiProxyHidden.netID(p) == id then
                        JimiProxyHidden.remember(p)
                        break
                    end
                end
                JimiProxyHidden.blank(id)
            end)
        end
        return false
    end

    if JimiProxyHidden.applying then return false end

    if var.v1 == "OnSetClothing" then
        local id = JimiProxyHidden.variantNetID(var, pkt)
        if id > 0 then JimiProxyHidden.blank(id) end
        return true
    end
    return false
end

function JimiProxyHidden.onWorldChange()
    JimiProxyHidden.cache = {}
    if not JimiProxyHidden.enabled then return end
    runThread(function()
        sleep(500)
        if JimiProxyHidden.enabled then JimiProxyHidden.applyAll() end
    end)
end

JimiProxyStream = {
    enabled = false,
    applying = false,
    names = {},
    history = {},
    MASK = "`8HIDDEN``"
}

function JimiProxyStream.players()
    local list = safe(getPlayerList) or safe(GetPlayerList)
    if type(list) == "table" then return list end
    return {}
end

function JimiProxyStream.netID(p)
    return tonumber(p and (p.netID or p.netid or p.net_id)) or 0
end

function JimiProxyStream.rememberName(value)
    value = trim(tostring(value or ""))
    if value == "" or strip(value) == "HIDDEN" then return end
    JimiProxyStream.history[value] = true
end

function JimiProxyStream.remember(p)
    local id = JimiProxyStream.netID(p)
    if id <= 0 or JimiProxyStream.names[id] ~= nil then return end
    if id == myNetID() then
        local own = nickVisualText()
        JimiProxyStream.names[id] = own
        JimiProxyStream.rememberName(own)
        JimiProxyStream.rememberName(nickReal)
        JimiProxyStream.rememberName(nickName)
        JimiProxyStream.rememberName(nickLocalName())
        return
    end
    local name = tostring(p and (p.name or p.name_ or p.userName) or "")
    if name ~= "" then
        JimiProxyStream.names[id] = name
        JimiProxyStream.rememberName(name)
    end
end

function JimiProxyStream.mask(id)
    id = tonumber(id) or 0
    if id <= 0 then return false end
    JimiProxyStream.applying = true
    local ok = pcall(function()
        sendNameVar({v1 = "OnNameChanged", v2 = JimiProxyStream.MASK}, id)
    end)
    JimiProxyStream.applying = false
    return ok
end

function JimiProxyStream.applyAll()
    if not JimiProxyStream.enabled then return false end
    for _, p in pairs(JimiProxyStream.players()) do
        local id = JimiProxyStream.netID(p)
        if id > 0 then
            JimiProxyStream.remember(p)
            JimiProxyStream.mask(id)
        end
    end
    return true
end

function JimiProxyStream.restoreAll()
    JimiProxyStream.applying = true
    for id, name in pairs(JimiProxyStream.names) do
        if tonumber(id) and tonumber(id) > 0 and tostring(name or "") ~= "" then
            pcall(function() sendNameVar({v1 = "OnNameChanged", v2 = tostring(name)}, tonumber(id)) end)
        end
    end
    JimiProxyStream.applying = false
    JimiProxyStream.names = {}
    pcall(applyNick)
    return true
end

function JimiProxyStream.set(value, quiet)
    local enabled = value == true
    if JimiProxyStream.enabled == enabled then return true end
    JimiProxyStream.enabled = enabled
    if enabled then
        JimiProxyStream.names = {}
        JimiProxyStream.history = {}
        JimiProxyStream.applyAll()
        if not quiet then sendConsole(prefix() .. "`2Streamer Mode ON") end
    else
        JimiProxyStream.restoreAll()
        JimiProxyStream.history = {}
        if not quiet then sendConsole(prefix() .. "`4Streamer Mode OFF") end
    end
    return true
end

function JimiProxyStream.toggle()
    return JimiProxyStream.set(not JimiProxyStream.enabled)
end

function JimiProxyStream.nameCandidates()
    local out, seen = {}, {}
    local function add(value)
        value = trim(tostring(value or ""))
        if value == "" then return end
        local plain = trim(strip(value):gsub("^@", ""))
        for _, item in ipairs({value, plain}) do
            item = trim(item)
            if #item >= 2 and item ~= "HIDDEN" and not seen[item] then
                seen[item] = true
                out[#out + 1] = item
            end
        end
    end
    for _, name in pairs(JimiProxyStream.names) do add(name) end
    for name in pairs(JimiProxyStream.history) do add(name) end
    for _, p in pairs(JimiProxyStream.players()) do add(p and (p.name or p.name_ or p.userName)) end
    add(nickReal)
    add(nickName)
    add(nickLocalName())
    table.sort(out, function(a, b) return #a > #b end)
    return out
end

function JimiProxyStream.replaceCI(text, needle, replacement)
    text = tostring(text or "")
    needle = tostring(needle or "")
    replacement = tostring(replacement or "")
    if text == "" or needle == "" then return text end
    local lowerText, lowerNeedle = text:lower(), needle:lower()
    local out, from = {}, 1
    while true do
        local s, e = lowerText:find(lowerNeedle, from, true)
        if not s then
            out[#out + 1] = text:sub(from)
            break
        end
        out[#out + 1] = text:sub(from, s - 1)
        out[#out + 1] = replacement
        from = e + 1
    end
    return table.concat(out)
end

function JimiProxyStream.redact(text)
    text = tostring(text or "")
    if not JimiProxyStream.enabled or text == "" then return text end
    local tagToken = "\1JP_STREAM_TAG\1"
    text = text:gsub(escPattern(TAG), tagToken)
    for _, name in ipairs(JimiProxyStream.nameCandidates()) do
        text = JimiProxyStream.replaceCI(text, name, "HIDDEN")
    end
    text = text:gsub("([Oo]wner%s*:%s*)[%w_%-]+", "%1HIDDEN")
    text = text:gsub("([Oo]wned%s+[Bb]y%s+)[%w_%-]+", "%1HIDDEN")
    text = text:gsub("([Ll]ocked%s+[Bb]y%s+)[%w_%-]+", "%1HIDDEN")
    text = text:gsub("([Ww]orld%s+[Ll]ocked%s+[Bb]y%s+)[%w_%-]+", "%1HIDDEN")
    text = text:gsub("([Pp]layer%s*:%s*)[%w_%-]+", "%1HIDDEN")
    text = text:gsub("@[%w_%-]+", "@HIDDEN")
    text = text:gsub(tagToken, TAG)
    return text
end

function JimiProxyStream.redactDialog(text)
    text = tostring(text or "")
    if not JimiProxyStream.enabled or text == "" then return text end

    local out = {}
    for rawLine in (text .. "\n"):gmatch("(.-)\n") do
        local line = rawLine
        local cmd = line:match("^([^|]+)") or ""
        local a, b, c, rest

        if cmd == "add_textbox" or cmd == "add_smalltext" then
            a, b, rest = line:match("^([^|]+)|([^|]*)(.*)$")
            if a then line = a .. "|" .. JimiProxyStream.redact(b) .. rest end
        elseif cmd == "add_label_with_icon" or cmd == "add_label" then
            a, b, c, rest = line:match("^([^|]+)|([^|]*)|([^|]*)(.*)$")
            if a then line = a .. "|" .. b .. "|" .. JimiProxyStream.redact(c) .. rest end
        elseif cmd == "add_button" or cmd == "add_url_button" or cmd == "add_checkbox"
            or cmd == "add_text_input" or cmd == "add_input" or cmd == "add_friend_image_label_button" then
            a, b, c, rest = line:match("^([^|]+)|([^|]*)|([^|]*)(.*)$")
            if a then line = a .. "|" .. b .. "|" .. JimiProxyStream.redact(c) .. rest end
        elseif cmd == "add_player_info" or cmd == "add_player_info_small" or cmd == "add_custom_textbox" then
            a, b, rest = line:match("^([^|]+)|([^|]*)(.*)$")
            if a then line = a .. "|" .. JimiProxyStream.redact(b) .. rest end
        else
            if cmd ~= "embed_data" and cmd ~= "end_dialog" and cmd ~= "set_default_color"
                and cmd ~= "set_border_color" and cmd ~= "set_bg_color" and cmd ~= "add_spacer"
                and cmd ~= "add_quick_exit" then
                line = JimiProxyStream.redact(line)
            end
        end

        out[#out + 1] = line
    end

    return table.concat(out, "\n")
end

function JimiProxyStream.spawnNetID(text)
    text = tostring(text or "")
    return tonumber(text:match("netID|(%d+)") or text:match("netid|(%d+)") or text:match("net_id|(%d+)")) or 0
end

function JimiProxyStream.spawnName(text)
    text = tostring(text or "")
    return text:match("name|([^\n]+)") or text:match("name|([^|]+)") or ""
end

function JimiProxyStream.onVariant(var, pkt)
    if not var or not JimiProxyStream.enabled then return false end

    if var.v1 == "OnSpawn" and type(var.v2) == "string" then
        local id = JimiProxyStream.spawnNetID(var.v2)
        local name = JimiProxyStream.spawnName(var.v2)
        if id > 0 and name ~= "" and JimiProxyStream.names[id] == nil then
            JimiProxyStream.names[id] = name
            JimiProxyStream.rememberName(name)
        end
        if id > 0 then
            JimiProxyStream.mask(id)
            runThread(function()
                sleep(25)
                if JimiProxyStream.enabled then JimiProxyStream.mask(id) end
                sleep(95)
                if JimiProxyStream.enabled then JimiProxyStream.mask(id) end
            end)
        end
        return false
    end

    if var.v1 == "OnRemove" then
        local id = tonumber(var.v2 or var.netid or var.netID or var.net_id) or 0
        if id <= 0 then
            local raw = tostring(var.v2 or "")
            id = tonumber(raw:match("netID|(%d+)") or raw:match("netid|(%d+)")) or 0
        end
        if id > 0 then JimiProxyStream.names[id] = nil end
        return false
    end

    if var.v1 == "OnNameChanged" and not JimiProxyStream.applying then
        local id = JimiProxyHidden.variantNetID(var, pkt)
        if id > 0 then
            local nextName = tostring(var.v2 or "")
            if nextName ~= "" and strip(nextName) ~= "HIDDEN" then
                JimiProxyStream.names[id] = nextName
                JimiProxyStream.rememberName(nextName)
            end
            JimiProxyStream.mask(id)
            return true
        end
    end
    return false
end

function JimiProxyStream.onWorldChange()
    JimiProxyStream.names = {}
    if not JimiProxyStream.enabled then return end
    runThread(function()
        sleep(550)
        if JimiProxyStream.enabled then JimiProxyStream.applyAll() end
    end)
end


-- Tested feature integration: Follow Chat (wrench-only) and Mods Online.
do
    JimiProxyFollowChat = JimiProxyFollowChat or {
        targetNetID = 0,
        targetName = "",
        wrenchNetID = 0,
        wrenchName = "",
        sending = false,
        lastSentText = "",
        lastSentAt = 0
    }

    local function fcNormalizeName(value)
        local name = trim(strip(value or "")):gsub("^@", "")
        return name:lower()
    end

    local function fcPlayerList()
        local list = safe(getPlayerList) or safe(GetPlayerList)
        if type(list) == "table" then return list end
        return {}
    end

    local function fcPlayerNetID(player)
        return tonumber(player and (player.netID or player.netid or player.net_id)) or 0
    end

    local function fcPlayerName(player)
        if type(player) ~= "table" then return "" end
        return trim(strip(player.name or player.name_ or player.displayName or player.display_name
            or player.growID or player.growId or player.growid or player.username or player.userName or ""))
    end

    local function fcNameByNetID(netID)
        netID = tonumber(netID) or 0
        if netID <= 0 then return "" end
        for _, player in pairs(fcPlayerList()) do
            if fcPlayerNetID(player) == netID then return fcPlayerName(player) end
        end
        return ""
    end

    local function fcExtractChatText(raw, targetName)
        local plain = trim(strip(raw or ""))
        if plain == "" then return "" end

        local cpBody = plain:match("^CP:%d+_PL:%d+_OID:_[^_]*_CT:%[[^%]]+%]_%s*(.*)$")
            or plain:match("^CP:%d+_PL:%d+_OID:_%s*(.*)$")
        if cpBody and cpBody ~= "" then plain = trim(cpBody) end

        local bracketName, body = plain:match("^<([^>]+)>%s*(.*)$")
        if bracketName and body then
            if targetName == "" or fcNormalizeName(bracketName) == fcNormalizeName(targetName) then
                plain = trim(body)
            end
        end

        if targetName ~= "" then
            local escaped = targetName:gsub("([^%w])", "%%%1")
            local body2 = plain:match("^@?" .. escaped .. "%s*:%s*(.*)$")
            if body2 then plain = trim(body2) end
        end

        plain = plain:gsub("^_CT:%[[^%]]+%]_%s*", ""):gsub("^:+%s*", "")
        plain = trim(plain)
        if plain == "" or plain:sub(1, 1) == "/" then return "" end
        return plain
    end

    local function fcSendChat(text)
        text = trim(strip(text or ""))
        if text == "" or text:sub(1, 1) == "/" or JimiProxyFollowChat.sending then return false end
        local now = ms()
        if text == JimiProxyFollowChat.lastSentText and now - JimiProxyFollowChat.lastSentAt < 700 then
            return false
        end
        JimiProxyFollowChat.lastSentText = text
        JimiProxyFollowChat.lastSentAt = now
        JimiProxyFollowChat.sending = true
        packet2("action|input\n|text|" .. text)
        JimiProxyFollowChat.sending = false
        return true
    end

    function JimiProxyFollowChat.setTarget(netID, knownName)
        netID = tonumber(netID) or 0
        if netID <= 0 or netID == myNetID() then
            say("`4Follow Chat target is not valid.")
            return false
        end
        JimiProxyFollowChat.targetNetID = netID
        JimiProxyFollowChat.targetName = trim(strip(knownName or ""))
        if JimiProxyFollowChat.targetName == "" then
            JimiProxyFollowChat.targetName = fcNameByNetID(netID)
        end
        if JimiProxyFollowChat.targetName == "" then JimiProxyFollowChat.targetName = "Player" end
        JimiProxyFollowChat.lastSentText = ""
        JimiProxyFollowChat.lastSentAt = 0
        say("`2Follow Chat: `w" .. JimiProxyFollowChat.targetName)
        return true
    end

    function JimiProxyFollowChat.stop()
        if JimiProxyFollowChat.targetNetID <= 0 then return true end
        local name = JimiProxyFollowChat.targetName ~= "" and JimiProxyFollowChat.targetName or "player"
        JimiProxyFollowChat.targetNetID = 0
        JimiProxyFollowChat.targetName = ""
        JimiProxyFollowChat.lastSentText = ""
        JimiProxyFollowChat.lastSentAt = 0
        say("`4Stopped Follow Chat: `w" .. name)
        return true
    end

    local function fcWrenchPacketNetID(packet)
        if type(packet) ~= "string" or not packet:lower():find("action|wrench", 1, true) then return 0 end
        return tonumber(packet:match("netID|(%d+)") or packet:match("netid|(%d+)") or packet:match("net_id|(%d+)")) or 0
    end

    local function fcDialogNetID(text)
        text = tostring(text or "")
        return tonumber(text:match("embed_data|netID|(%d+)") or text:match("embed_data|netid|(%d+)")
            or text:match("netID|(%d+)")) or 0
    end

    local function fcPlayerWrenchDialog(text)
        text = tostring(text or "")
        return text:find("add_popup_name|WrenchMenu|", 1, true) ~= nil
            or text:find("add_player_info|", 1, true) ~= nil
            or text:find("add_button|trade", 1, true) ~= nil
    end

    local function fcAddButton(text, target)
        if target <= 0 or target == myNetID() or text:find("jimi_follow_chat_button", 1, true) then return text end
        local same = JimiProxyFollowChat.targetNetID > 0 and JimiProxyFollowChat.targetNetID == target
        local label = same and "`4Stop Follow Chat``" or "`2Follow Chat``"
        local button = "add_button|jimi_follow_chat_button|" .. label .. "|noflags|0|0|\n"
        local changed
        text, changed = text:gsub("add_button|trade", button .. "add_button|trade", 1)
        if changed > 0 then return text end
        text, changed = text:gsub("add_button_with_icon|trade", button .. "add_button_with_icon|trade", 1)
        if changed > 0 then return text end
        text = text:gsub("end_dialog|", button .. "end_dialog|", 1)
        return text
    end

    function JimiProxyFollowChat.onPacket(tp, packet)
        if type(packet) ~= "string" then return false end
        local wrench = fcWrenchPacketNetID(packet)
        if wrench > 0 then
            JimiProxyFollowChat.wrenchNetID = wrench
            JimiProxyFollowChat.wrenchName = fcNameByNetID(wrench)
            return false
        end
        if tonumber(tp) ~= 2 or not packet:find("action|dialog_return", 1, true)
            or not packet:find("buttonClicked|jimi_follow_chat_button", 1, true) then
            return false
        end
        local target = tonumber(packet:match("netID|(%d+)") or packet:match("netid|(%d+)")
            or packet:match("embed_data|netID|(%d+)")) or JimiProxyFollowChat.wrenchNetID
        if target <= 0 then
            say("`4Follow Chat target could not be read.")
            return true
        end
        if JimiProxyFollowChat.targetNetID == target then
            JimiProxyFollowChat.stop()
        else
            JimiProxyFollowChat.setTarget(target, JimiProxyFollowChat.wrenchName)
        end
        return true
    end

    function JimiProxyFollowChat.onVariant(var)
        if type(var) ~= "table" then return false end
        if var.v1 == "OnDialogRequest" and type(var.v2) == "string" and fcPlayerWrenchDialog(var.v2) then
            local target = fcDialogNetID(var.v2)
            if target <= 0 then target = JimiProxyFollowChat.wrenchNetID end
            if target > 0 and target ~= myNetID() then
                JimiProxyFollowChat.wrenchNetID = target
                JimiProxyFollowChat.wrenchName = fcNameByNetID(target)
                local modified = fcAddButton(var.v2, target)
                if modified ~= var.v2 then
                    dialog(modified)
                    return true
                end
            end
        elseif var.v1 == "OnRemove" then
            local raw = tostring(var.v2 or "")
            local removed = tonumber(var.v2) or tonumber(raw:match("netID|(%d+)") or raw:match("netid|(%d+)")) or 0
            if removed > 0 and removed == JimiProxyFollowChat.targetNetID then JimiProxyFollowChat.stop() end
        elseif var.v1 == "OnTalkBubble" and JimiProxyFollowChat.targetNetID > 0 then
            local sender = tonumber(var.v2) or 0
            if sender == JimiProxyFollowChat.targetNetID and sender ~= myNetID() then
                local bubbleType = tonumber(var.v4)
                if bubbleType == nil or bubbleType == 0 then
                    local text = fcExtractChatText(var.v3, JimiProxyFollowChat.targetName)
                    if text ~= "" then fcSendChat(text) end
                end
            end
        elseif var.v1 == "OnConsoleMessage" and type(var.v2) == "string"
            and JimiProxyFollowChat.targetNetID > 0 and JimiProxyFollowChat.targetName ~= "" then
            local plain = trim(strip(var.v2))
            local name, body = plain:match("^CP:%d+_PL:%d+_OID:_CT:%[[^%]]+%]_%s*<([^>]+)>%s*(.*)$")
            if not name then name, body = plain:match("^<([^>]+)>%s*(.*)$") end
            if name and body and fcNormalizeName(name) == fcNormalizeName(JimiProxyFollowChat.targetName) then
                fcSendChat(body)
            end
        end
        return false
    end

    function JimiProxyFollowChat.onWorldChange()
        JimiProxyFollowChat.targetNetID = 0
        JimiProxyFollowChat.targetName = ""
        JimiProxyFollowChat.wrenchNetID = 0
        JimiProxyFollowChat.wrenchName = ""
        JimiProxyFollowChat.lastSentText = ""
        JimiProxyFollowChat.lastSentAt = 0
    end
end

do
    JimiProxyMods = JimiProxyMods or {pending = false, requestAt = 0}
    local MOD_ICON = 732

    local function modsUnique(text)
        local mods, seen = {}, {}
        for name in tostring(text or ""):gmatch("@([%w_]+)") do
            local key = name:lower()
            if not seen[key] then seen[key] = true; mods[#mods + 1] = "@" .. name end
        end
        return mods
    end

    local function modsParse(raw)
        local plain = trim(strip(raw or ""))
        local lower = plain:lower()
        local pos = lower:find("mods online:", 1, true)
        if not pos then return nil end
        local body = trim(plain:sub(pos + #"mods online:"))
        local bodyLower = body:lower()
        if bodyLower:find("all are hidden", 1, true) then return {}, "all_hidden" end
        if bodyLower == "" or bodyLower:find("everyone is offline", 1, true) or bodyLower == "none" then
            return {}, "none"
        end
        return modsUnique(body), "visible"
    end

    local function modsShow(mods, state)
        local online = state == "all_hidden" and "`#Hidden``" or "`2" .. tostring(#mods) .. "``"
        local rows = ""
        if #mods > 0 then
            for _, name in ipairs(mods) do rows = rows .. "add_textbox|`#" .. name .. "``|left|\n" end
        elseif state == "all_hidden" then
            rows = "add_textbox|`7All online moderators are hidden.``|left|\n"
        else
            rows = "add_textbox|`7No visible moderators online.``|left|\n"
        end
        dialog(theme()
            .. "add_label_with_icon|big|`wMods Online``|left|" .. tostring(MOD_ICON) .. "|\n"
            .. "add_smalltext|`9Online: " .. online .. "|left|\n"
            .. "add_spacer|small|\n" .. rows
            .. "add_quick_exit|\nend_dialog|jimi_mods_online|Close||\n")
    end

    function JimiProxyMods.request()
        JimiProxyMods.pending = true
        JimiProxyMods.requestAt = ms()
        packet2("action|input\n|text|/mods")
        runThread(function(stamp)
            sleep(3000)
            if JimiProxyMods.pending and JimiProxyMods.requestAt == stamp then
                JimiProxyMods.pending = false
                say("`4Server did not return the moderator list.")
            end
        end, JimiProxyMods.requestAt)
        return true
    end

    function JimiProxyMods.onVariant(var)
        if not JimiProxyMods.pending or type(var) ~= "table" then return false end
        if var.v1 == "OnConsoleMessage" and type(var.v2) == "string" then
            local mods, state = modsParse(var.v2)
            if mods then
                JimiProxyMods.pending = false
                modsShow(mods, state)
                return true
            end
        end
        return false
    end

    function JimiProxyMods.onWorldChange()
        JimiProxyMods.pending = false
    end
end

JimiProxySearch = {
    query = "",
    lastPathAt = -100000,
    lastPathKey = ""
}

function JimiProxySearch.objectList()
    local list = safe(getObjectList) or safe(GetObjectList)
    if type(list) == "table" then return list end
    return {}
end

function JimiProxySearch.objectTile(obj)
    local pos = obj and obj.pos or nil
    local x = tonumber(obj and (obj.posX or obj.x) or nil) or tonumber(JimiProxyItems.field(pos, "x"))
    local y = tonumber(obj and (obj.posY or obj.y) or nil) or tonumber(JimiProxyItems.field(pos, "y"))
    if not x or not y then return nil, nil end
    return math.floor(x / 32), math.floor(y / 32)
end

function JimiProxySearch.localTile()
    local p = localPlayer()
    if not p then return 0, 0 end
    local x, y = playerTilePos(p)
    if x and y then return math.floor(x), math.floor(y) end
    return 0, 0
end

function JimiProxySearch.distance(x, y)
    local px, py = JimiProxySearch.localTile()
    return math.abs((tonumber(x) or 0) - px) + math.abs((tonumber(y) or 0) - py)
end

function JimiProxySearch.scan(query)
    query = trim(query or "")
    local low = query:lower()
    local numeric = tonumber(query)
    local grouped = {}

    for _, obj in pairs(JimiProxySearch.objectList()) do
        local id = math.floor(tonumber(obj and (obj.itemid or obj.itemID or obj.item_id or obj.id_)) or 0)
        local amount = math.max(0, math.floor(tonumber(obj and (obj.amount or obj.count or obj.count_)) or 0))
        local x, y = JimiProxySearch.objectTile(obj)
        if id > 0 and amount > 0 and x and y then
            local key = tostring(id)
            local row = grouped[key]
            if not row then
                local name = JimiProxyItems.name(id)
                row = {id = id, name = name, total = 0, stacks = 0, nearest = math.huge, x = x, y = y}
                grouped[key] = row
            end
            row.total = row.total + amount
            row.stacks = row.stacks + 1
            local d = JimiProxySearch.distance(x, y)
            if d < row.nearest then
                row.nearest, row.x, row.y = d, x, y
            end
        end
    end

    local result = {}
    for _, row in pairs(grouped) do
        local match = query == ""
        if numeric then match = row.id == math.floor(numeric) end
        if not numeric and query ~= "" then
            match = tostring(row.name or ""):lower():find(low, 1, true) ~= nil
        end
        if match then result[#result + 1] = row end
    end

    table.sort(result, function(a, b)
        if a.nearest ~= b.nearest then return a.nearest < b.nearest end
        return tostring(a.name):lower() < tostring(b.name):lower()
    end)
    return result
end

function JimiProxySearch.pathTo(x, y)
    x, y = math.floor(tonumber(x) or 0), math.floor(tonumber(y) or 0)
    local key = tostring(x) .. ":" .. tostring(y)
    local now = ms()
    if key == JimiProxySearch.lastPathKey and now - JimiProxySearch.lastPathAt < 650 then
        return true
    end
    JimiProxySearch.lastPathKey = key
    JimiProxySearch.lastPathAt = now
    local moved, available = runPathfinder(x, y)
    if not available then
        sendConsole(prefix() .. "`4Pathfinding unavailable.")
    elseif not moved then
        sendConsole(prefix() .. "`4Path blocked.")
    end
    return true
end

function JimiProxySearch.goNearest(id)
    local list = JimiProxySearch.scan(tostring(id))
    if #list == 0 then
        sendConsole(prefix() .. "`4Dropped item is no longer in this world.")
        return true
    end
    local row = list[1]
    return JimiProxySearch.pathTo(row.x, row.y)
end

function JimiProxySearch.show(query, message)
    query = trim(query or "")
    JimiProxySearch.query = query
    local list = JimiProxySearch.scan(query)

    local s = theme()
    s = s .. "text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2Dropped Item Search|left|" .. tostring(SEARCH_ICON) .. "|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_text_input|sitem_search|Search item / ID|" .. cleanDialog(query) .. "|32|\n"
    s = s .. "add_button|sitem_search_apply|`2Search|noflags|0|0|\n"
    s = s .. "add_spacer|small|\n"

    if message and trim(message) ~= "" then
        s = s .. "add_smalltext|`6" .. cleanDialog(message) .. "|left|\n"
        s = s .. "add_spacer|small|\n"
    end

    if #list == 0 then
        s = s .. "add_smalltext|`8No matching dropped item.|left|\n"
    else
        for _, row in ipairs(list) do
            local stackText = row.stacks == 1 and "1 stack" or (tostring(row.stacks) .. " stacks")
            local label = "`w" .. cleanDialog(row.name)
                .. " `8[#" .. tostring(row.id) .. "]"
                .. " `6• `2" .. tostring(row.total)
                .. " `8• " .. stackText
                .. " `8• `w" .. tostring(row.nearest) .. " tiles"
            s = s .. "add_label_with_icon_button|small|" .. label .. "|left|" .. tostring(row.id) .. "|sitem_item_" .. tostring(row.id) .. "|\n"
            s = s .. "add_spacer|small|\n"
        end
    end

    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|jimi_sitem|Close||\n"
    dialog(s)
    return true
end

function JimiProxySearch.handle(query)
    query = trim(query or "")
    if query == "" then return JimiProxySearch.show("") end
    local list = JimiProxySearch.scan(query)
    if #list == 1 then return JimiProxySearch.goNearest(list[1].id) end
    if #list == 0 then return JimiProxySearch.show(query, "No matching dropped item.") end
    return JimiProxySearch.show(query)
end

function JimiProxySearch.handleDialog(packet)
    local button = packetField(packet, "buttonClicked") or ""
    local query = trim(packetField(packet, "sitem_search") or JimiProxySearch.query)
    local id = tonumber(button:match("^sitem_item_(%d+)$"))
    if id then return JimiProxySearch.goNearest(id) end
    if button == "sitem_search_apply" then return JimiProxySearch.show(query) end
    return true
end

JimiProxyChat = {
    API = "https://hijimi.site/api/jimiproxy/chat",
    lastSendAt = -100000,
    cooldown = 1500
}

function JimiProxyChat.cleanGrowID(name)
    name = tostring(name or ""):gsub("`.", ""):gsub("^@", "")
    name = trim(name):gsub(" of Legend$", ""):gsub("^Dr%.", "")
    if name == "" then name = "Unknown" end
    return name
end

function JimiProxyChat.urlEncode(value)
    return (tostring(value or ""):gsub("([^%w%-%._~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

function JimiProxyChat.show()
    local s = theme()
    s = s .. "text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
    s = s .. "add_label_with_icon|big|[`cJimi`6Proxy`9] `2JimiProxy Chat|left|" .. tostring(FEATURED_ICON) .. "|\n"
    s = s .. "add_smalltext|`8Send a message to JimiProxy Discord chat.|left|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_text_input|chat_message|Message||180|\n"
    s = s .. "add_spacer|small|\n"
    s = s .. "add_button|chat_send|`2Send Message|noflags|0|0|\n"
    s = s .. "add_quick_exit|\n"
    s = s .. "end_dialog|jimi_chat|Close||\n"
    dialog(s)
    return true
end

function JimiProxyChat.send(message)
    message = trim(message or "")
    if message == "" then
        sendConsole(prefix() .. "`6Message is empty.")
        return true
    end
    if #message > 180 then message = message:sub(1, 180) end

    local now = ms()
    if now - JimiProxyChat.lastSendAt < JimiProxyChat.cooldown then
        sendConsole(prefix() .. "`6Chat cooldown. Try again in a moment.")
        return true
    end
    JimiProxyChat.lastSendAt = now

    if type(fetch) ~= "function" then
        sendConsole(prefix() .. "`4fetch() is unavailable on this Growlauncher build.")
        return true
    end

    local growid = JimiProxyChat.cleanGrowID(myName())
    local world = trim(worldName()):upper()
    if world == "" or world == "UNKNOWN" then world = "EXIT" end
    local url = JimiProxyChat.API
        .. "?growid=" .. JimiProxyChat.urlEncode(growid)
        .. "&world=" .. JimiProxyChat.urlEncode(world)
        .. "&message=" .. JimiProxyChat.urlEncode(message)

    runThread(function()
        local ok, response, err = pcall(fetch, url)
        if not ok then
            sendConsole(prefix() .. "`4Chat relay failed.")
            return
        end
        response = tostring(response or "")
        if response:find('"ok":true', 1, true) or response:find("CHAT_SENT", 1, true) then
            sendConsole(prefix() .. "`2Chat sent.")
        else
            local detail = trim(err or "")
            if detail ~= "" then sendConsole(prefix() .. "`6Chat relay: `w" .. cleanDialog(detail)) end
            sendConsole(prefix() .. "`4Chat relay rejected/unavailable.")
        end
    end)
    return true
end

function JimiProxyChat.handleDialog(packet)
    local button = packetField(packet, "buttonClicked") or ""
    if button ~= "chat_send" then return true end
    local message = packetField(packet, "chat_message") or ""
    return JimiProxyChat.send(message)
end

JimiProxyRules=(function()
local rules = {}
function rules.parseTax(value)
    local text=tostring(value or ""):match("^%s*(.-)%s*$"):gsub(",",".")
    if not text:match("^%d+%.?%d*$") then return nil end
    local whole,fraction=text:match("^(%d+)%.(%d*)$")
    whole=whole or text;fraction=fraction or ""
    if #whole>3 or #fraction>2 then return nil end
    local basis=tonumber(whole)*100+tonumber((fraction.."00"):sub(1,2))
    if basis<0 or basis>10000 then return nil end
    return basis
end
function rules.taxValue(total,basis)
    return math.floor(total*basis/10000)
end
function rules.resolve(mode,left,right)
    left=tonumber(left) or 0;right=tonumber(right) or 0
    if mode~="BTK" then
        if left>21 and right>21 then return 0,"both_bust" end
        if left>21 then return 2,"p1_bust" end
        if right>21 then return 1,"p2_bust" end
    end
    if left==right then return 0,"tie" end
    return left>right and 1 or 2,"score"
end

return rules
end)()

do
    JimiProxyCalc=(function()
return function(c)
    local packet2,say,ms=c.send,c.notify,c.clock
    local api={}
    local lastSent
    function api.evaluate(expression)
        if type(expression)~="string" or #expression>160 then return nil,"Expression is too long or invalid."end
        local text=expression:gsub("×","*"):gsub("÷","/"):gsub("[xX]","*"):gsub(",",".")
        if text:find("[^%d%+%-%*/%(%)%. ]") or not text:find("%d") then return nil,"Use numbers and math operators only."end
        local position,depth=1,0
        local sum,product,primary
        local function skip()while text:sub(position,position)==" " do position=position+1 end end
        local function finite(value)
            if value~=value or value==math.huge or value==-math.huge then error("Result is outside the supported number range.",0)end
            return value
        end
        primary=function()
            depth=depth+1;if depth>24 then error("Expression is nested too deeply.",0)end
            skip();local token=text:sub(position,position);local value
            if token=="+" or token=="-" then
                position=position+1;value=primary();if token=="-" then value=-value end
            elseif token=="(" then
                position=position+1;value=sum();skip()
                if text:sub(position,position)~=")" then error("Parentheses are incomplete.",0)end
                position=position+1
            else
                local number=text:sub(position):match("^%d+%.?%d*") or text:sub(position):match("^%.%d+")
                if not number then error("Number or operator is incomplete.",0)end
                position=position+#number;value=tonumber(number)
                if not value then error("Invalid number.",0)end
            end
            depth=depth-1;return finite(value)
        end
        product=function()
            local value=primary()
            while true do
                skip();local token=text:sub(position,position)
                if token~="*" and token~="/" then return value end
                position=position+1;local right=primary()
                if token=="/" and right==0 then error("Cannot divide by zero.",0)end
                value=finite(token=="*" and value*right or value/right)
            end
        end
        sum=function()
            local value=product()
            while true do
                skip();local token=text:sub(position,position)
                if token~="+" and token~="-" then return value end
                position=position+1;local right=product()
                value=finite(token=="+" and value+right or value-right)
            end
        end
        local ok,result=pcall(function()
            local value=sum();skip()
            if position<=#text then error("Invalid expression.",0)end
            return value
        end)
        if not ok then return nil,tostring(result)end
        return result
    end
    function api.handle(command,low)
        if type(command)~="string" then return false end
        local name,expression=command:match("^/([%a]+)%s*(.*)$")
        name=name and name:lower()
        if name~="c" and name~="calc" then return false end
        local suffix=command:sub(#name+2,#name+2)
        if suffix~="" and not suffix:match("%s") then return false end
        if not expression or expression:match("^%s*$") then
            if JimiProxySettings and type(JimiProxySettings.showCalculator)=="function" then
                return JimiProxySettings.showCalculator()
            end
            say("`6Example: /c 20+5 • /c 12x3 • /c 100/4 • /c (8+2)x5")
            return true
        end
        if lastSent and ms()-lastSent<1000 then return true end
        local value,err=api.evaluate(expression)
        if value==nil then say("`4"..err);return true end
        if value==0 then value=0 end
        local output=string.format("%.12g",value)
        if #output>120 or output:find("[\r\n|`]") then say("`4Result is too long for world chat.");return true end
        lastSent=ms();packet2("action|input\n|text|"..output)
        return true
    end
    return api
end
end)()({send=packet2,notify=say,clock=ms})
    local function tilePosition()
        local p=localPlayer()
        if not p then return end
        local x=tonumber(p.posX or p.x or (p.pos and p.pos.x))
        local y=tonumber(p.posY or p.y or (p.pos and p.pos.y))
        if x and y then return math.floor(x/32),math.floor(y/32)end
    end
    JimiProxyPullTile=(function()
return function(c)
    local api={}
    local slots,serial,busy,nextAt={},0,false,0
    local function valid(slot)return type(slot)=='number' and slot%1==0 and slot>=1 and slot<=4 end
    local function netID(p)return tonumber(p and (p.netID or p.netid or p.net_id))end
    local function position(p)
        if not p then return end
        local x=tonumber(p.posX or p.x or (p.pos and p.pos.x))
        local y=tonumber(p.posY or p.y or (p.pos and p.pos.y))
        if x and y then return math.floor(x/32),math.floor(y/32)end
    end
    local function find(id)
        for _,p in pairs(c.players() or {})do if netID(p)==id then return p end end
    end
    function api.get(slot)
        local tile=slots[slot]
        if tile then return {x=tile.x,y=tile.y,world=tile.world}end
    end
    function api.set(slot,x,y)
        x=tonumber(x);y=tonumber(y)
        local world=c.world()
        if not valid(slot) or not x or not y or x%1~=0 or y%1~=0 or x<0 or y<0 or x>999 or y>999 then
            c.notify('`4Invalid Pull Tile position.');return false
        end
        if world=='' or world=='EXIT' or world=='UNKNOWN' then c.notify('`6Enter a world first.');return false end
        serial=serial+1;busy=false
        slots[slot]={x=x,y=y,world=world}
        c.greenBox(x,y)
        c.notify('`1PT'..slot..' `6saved at `e('..x..', '..y..')')
        return true
    end
    function api.clear(slot)
        if not valid(slot) then return false end
        slots[slot]=nil;serial=serial+1;busy=false;return true
    end
    function api.clearAll()
        slots={};serial=serial+1;busy=false;nextAt=0;return true
    end
    function api.resetWorld()return api.clearAll()end
    local function selected(slot)
        local world=c.world()
        local result={}
        if slot then
            local tile=api.get(slot)
            if tile and tile.world==world then result[1]={slot=slot,x=tile.x,y=tile.y,world=tile.world}end
            return result
        end
        for i=1,4 do
            local tile=api.get(i)
            if tile and tile.world==world then result[#result+1]={slot=i,x=tile.x,y=tile.y,world=tile.world}end
        end
        return result
    end
    local function startPull(slot)
        if slot and not valid(slot) then return false end
        if busy or c.clock()<nextAt then return true end
        local tiles=selected(slot)
        if #tiles==0 then
            c.notify(slot and ('`6Set /pt'..slot..' first.') or '`6Set at least one Pull Tile first.')
            return true
        end
        local picked,seen={},{}
        for _,p in pairs(c.players() or {})do
            local id=netID(p);local x,y=position(p)
            if id and id>0 and id%1==0 and id~=c.localID() and not seen[id] and #picked<16 then
                for _,tile in ipairs(tiles)do
                    if x==tile.x and y==tile.y then
                        seen[id]=true
                        picked[#picked+1]={id=id,name=tostring(p.name or ''),x=tile.x,y=tile.y,world=tile.world}
                        break
                    end
                end
            end
        end
        if #picked==0 then c.notify(slot and ('`6No player at PT'..slot..'.') or '`6No players on saved Pull Tiles.');return true end
        local token=serial
        busy=true;nextAt=c.clock()+800
        local started=pcall(c.thread,function()
            local ok=pcall(function()
                for _,target in ipairs(picked)do
                    if token~=serial or c.world()~=target.world then return end
                    local p=find(target.id);local x,y=position(p)
                    if p and tostring(p.name or '')==target.name and target.id~=c.localID() and x==target.x and y==target.y then
                        c.send('action|dialog_return\ndialog_name|popup\nnetID|'..target.id..'|\nbuttonClicked|pull')
                        c.sleep(300)
                    end
                end
            end)
            if token==serial then busy=false end
            if not ok then c.notify('`4Pull Tile failed. Try again.')end
        end)
        if not started then busy=false;c.notify('`4Pull Tile could not start.')end
        return true
    end
    function api.pull(slot)return startPull(slot)end
    function api.pullAll()return startPull(nil)end
    return api
end
end)()({clock=ms,world=worldName,localID=myNetID,
        players=function()return safe(getPlayerList) or {}end,greenBox=greenBox,notify=overlay,
        send=packet2,thread=runThread,sleep=sleep})

    JimiProxyBTK=(function()
return function(c)
    local api={}
    local mode='BJ'
    function api.mode()return mode end
    function api.set(nextMode)
        if nextMode~='BJ' and nextMode~='BTK' then return false end
        if c.blocked() then c.notify('`6Finish the current round before changing mode.');return true end
        mode=nextMode;c.notify('`2'..mode..' mode enabled.');return true
    end
    function api.command(low)
        if low=='/btk' then return api.set(mode=='BTK' and 'BJ' or 'BTK')end
        if low=='/btk on' then return api.set('BTK')end
        if low=='/btk off' then return api.set('BJ')end
        return false
    end
    return api
end
end)()({blocked=function()
        return bj.takeBusy or bj.payoutBusy or (bj.bet and bj.bet.ready and not bj.bet.closed)
            or (bj.lastBet and bj.lastWinner>0 and not bj.lastBet.paid)
    end,notify=say})
    JimiProxyGuard=(function()
return function(c)
    local api={}
    local options={
        {key="bunny",name="Psychotic Bunny",icon=618,items={[618]=true}},
        {key="crime",name="Henchman / Crime Wave",icon=2382,items={[2380]=true,[2382]=true}},
        {key="whistle",name="Pet Trainer Whistle",icon=3676,items={[3676]=true}},
        {key="bell",name="Thanksgiving Bell",icon=7342,items={[7342]=true}}
    }
    local enabled=false
    local selected,seen={},{}
    local serial,queued=0,0
    local function find(netid)
        for _,p in pairs(c.players() or {})do
            if tonumber(p.netID or p.netid)==netid then return p end
        end
    end
    function api.resetWorld()serial=serial+1;queued=0;seen={}end
    function api.show()
        local s=c.theme()..c.identity("Anti Troll",618)
            .."add_smalltext|`9Select the supported consumables to block.|left|\n"
            .."add_checkbox|guard_enabled|`cEnable Auto Ban|"..(enabled and "1" or "0").."|\n"
        for _,o in ipairs(options)do
            s=s.."add_label_with_icon|small|`c"..o.name.."|left|"..o.icon.."|\n"
                .."add_checkbox|guard_"..o.key.."|`9Block "..o.name.."|"..(selected[o.key] and "1" or "0").."|\n"
        end
        s=s.."add_spacer|tiny|\n"
            .."add_button|guard_apply|`2Save|noflags|0|0|\nadd_quick_exit|\nend_dialog|jimi_antitroll|Close||\n"
        c.dialog(s);return true
    end
    function api.handleDialog(packet)
        if c.field(packet,"dialog_name")~="jimi_antitroll" then return false end
        if c.field(packet,"buttonClicked")=="guard_apply" then
            api.resetWorld()
            enabled=c.field(packet,"guard_enabled")=="1"
            for _,o in ipairs(options)do selected[o.key]=c.field(packet,"guard_"..o.key)=="1" end
            api.show()
        end
        return true
    end
    function api.onGame(pkt)
        if not enabled or tonumber(pkt.type)~=0 or queued>=8 then return end
        local item,netid=tonumber(pkt.value),tonumber(pkt.netid)
        if not item or not netid or netid%1~=0 or netid<=0 or netid==c.localID() then return end
        local matched=false
        for _,o in ipairs(options)do if selected[o.key] and o.items[item] then matched=true;break end end
        if not matched or (seen[netid] and c.clock()-seen[netid]<5000) then return end
        local actor=find(netid);local world=c.world()
        if not actor or world=="" or world=="EXIT" or world=="UNKNOWN" then return end
        local name=tostring(actor.name or "")
        local token=serial
        local function current()
            local p=find(netid)
            return enabled and token==serial and c.world()==world and p and tostring(p.name or "")==name
        end
        seen[netid]=c.clock();queued=queued+1
        local started=pcall(c.thread,function()
            pcall(function()
                c.sleep(120)
                if not current() then return end
                c.send("action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nbuttonClicked|world_ban")
                c.sleep(250)
                if not current() then return end
                c.send("action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nbuttonClicked|worldban")
            end)
            if token==serial then queued=math.max(0,queued-1)end
        end)
        if not started then queued=math.max(0,queued-1);seen[netid]=nil end
    end
    function api.configState()
        local keys={}
        for _,o in ipairs(options)do if selected[o.key] then keys[#keys+1]=o.key end end
        return enabled,table.concat(keys,",")
    end
    function api.applyConfig(on,list)
        enabled=tostring(on)=="1" or on==true
        selected={}
        for key in tostring(list or ""):gmatch("[^,]+")do selected[key]=true end
        api.resetWorld()
        return true
    end
    return api
end
end)()({players=function()return safe(getPlayerList) or {}end,
        clock=ms,world=worldName,localID=myNetID,theme=theme,identity=JimiProxyExt.identity,
        field=packetField,dialog=dialog,thread=runThread,sleep=sleep,send=packet2,notify=say})
    do
    local actions={}
    for slot=1,4 do
        actions[#actions+1]={slot=slot,key='slot'..slot,label='Hotkey '..slot,alias='JimiProxyHotkey'..slot}
    end
    local pref
    local prefMemory={}
    local function preferences()
        if pref then return pref end

        local ok,p=pcall(require,'preferences')
        if not ok or p==nil then ok,p=pcall(require,'Preferences') end

        if ok and p~=nil then
            local obj=p
            local made,created=pcall(function()
                if type(p.new)=='function' then return p:new('JimiProxy_hotkeys_v2') end
                return nil
            end)
            if made and created~=nil then obj=created end

            local hasGet=pcall(function() return type(obj.get)=='function' end)
            local hasSet=pcall(function() return type(obj.set)=='function' end)
            if hasGet and hasSet then
                pcall(function() if type(obj.load)=='function' then obj:load() end end)
                pref=obj
                return pref
            end
        end

        -- Safe runtime fallback: keeps Hotkeys usable even when the optional
        -- preferences module is unavailable. It intentionally does not crash
        -- the whole proxy.
        pref={}
        function pref:get(key,default)
            local value=prefMemory[key]
            if value==nil then return default end
            return value
        end
        function pref:set(key,value) prefMemory[key]=value return true end
        function pref:save() return true end
        function pref:load() return true end
        return pref
    end
    local legacyAliases={
        'JimiProxyPullPT1','JimiProxyPullPT2','JimiProxyPullPT3','JimiProxyPullPT4',
        'JimiProxyCalculator','JimiProxySettings',
        'JimiProxyHotkey1','JimiProxyHotkey2','JimiProxyHotkey3','JimiProxyHotkey4'
    }
    JimiProxyHotkeys=(function()
return function(c)
    local api={}
    local commands,last={},{}
    local ready,changing=false,false
    local function call(fn,...)
        if type(fn)~='function' then return false end
        local ok,result=pcall(fn,...);return ok and result~=false
    end
    local function valid(slot)
        slot=tonumber(slot);return slot and slot%1==0 and slot>=1 and slot<=4
    end
    local function clean(value)
        local text=tostring(value or ''):gsub('[\r\n|]',' '):gsub('%s+',' '):gsub('^%s+',''):gsub('%s+$','')
        if #text>120 then text=text:sub(1,120)end
        return text
    end
    local function action(slot)
        for _,item in ipairs(c.actions or {})do if tonumber(item.slot)==tonumber(slot) then return item end end
    end
    function api.command(slot)
        if not valid(slot) then return '' end
        return commands[tonumber(slot)] or ''
    end
    function api.enabled(slot)return api.command(slot)~='' end
    function api.init()
        changing=true
        if type(c.cleanup)=='function' then pcall(c.cleanup)end
        if not call(c.register,c.actions) then changing=false;return false end
        for slot=1,4 do
            local item=action(slot)
            local ok,value=pcall(c.read,'slot'..slot)
            local command=ok and clean(value) or ''
            commands[slot]=command
            if item and command~='' then call(c.pin,item.alias)end
        end
        changing=false;ready=true;return true
    end
    function api.set(slot,value)
        slot=tonumber(slot)
        if not ready or not valid(slot) then return false end
        local item=action(slot);if not item then return false end
        local before=commands[slot] or ''
        local command=clean(value)
        changing=true
        local success=true
        if before=='' and command~='' then success=call(c.pin,item.alias)
        elseif before~='' and command=='' then success=call(c.unpin,item.alias)end
        if success then
            commands[slot]=command
            if not call(c.write,'slot'..slot,command) then success=false end
            if success and not call(c.save) then success=false end
        end
        changing=false;return success
    end
    function api.onValue(kind,name,value)
        if hotkeyMode~="shortcut" then return false end
        if not ready or changing or tonumber(kind)~=0 or type(value)~='boolean' then return false end
        for slot=1,4 do
            local item=action(slot)
            if item and name==item.alias then
                local now=c.clock()
                if last[slot] and now-last[slot]<900 then return true end
                last[slot]=now
                local command=commands[slot] or ''
                if command=='' then
                    if type(c.notify)=='function' then c.notify('`6Hotkey '..slot..' is not set.')end
                    return true
                end
                return call(c.run,command) or true
            end
        end
        return false
    end
    return api
end
end)()({clock=ms,actions=actions,
        cleanup=function()
            if type(removeShortcut)~='function' then return true end
            for _,alias in ipairs(legacyAliases)do pcall(removeShortcut,alias)end
            return true
        end,
        register=function(list)
            if type(addIntoModule)~='function' then return false end
            if type(addCategory)=='function' then pcall(addCategory,'JimiProxy','TouchApp')end
            local rows={}
            for _,a in ipairs(list)do rows[#rows+1]='{"type":"button","text":"'..a.label..'","alias":"'..a.alias..'"}'end
            return addIntoModule('{"sub_name":"JimiProxy Hotkeys","icon":"TouchApp","menu":['..table.concat(rows,',')..']}', 'JimiProxy')
        end,
        pin=type(addShortcut)=='function' and addShortcut or nil,
        unpin=type(removeShortcut)=='function' and removeShortcut or nil,
        read=function(k)return preferences():get(k,'')end,
        write=function(k,v)return preferences():set(k,v)end,
        save=function()return preferences():save()end,
        run=function(value)
            if type(JimiProxyExt.executeHotkeyText)=='function' then return JimiProxyExt.executeHotkeyText(value)end
            return false
        end,
        notify=overlay
    })

    JimiProxyButtonHotkeys = {
        entries = {},
        recording = false,
        slot = 0,
        tempPacket = ""
    }

    local function buttonHotkeyPref()
        return preferences()
    end

    function JimiProxyButtonHotkeys.clean(value)
        local text=tostring(value or ""):gsub("[\r\n|]"," "):gsub("%s+"," ")
        text=trim(text)
        if #text>120 then text=text:sub(1,120) end
        return text
    end

    function JimiProxyButtonHotkeys.fingerprint(packet)
        packet=tostring(packet or "")
        local dialogName=packetField(packet,"dialog_name") or ""
        local button=packetField(packet,"buttonClicked") or ""
        if dialogName~="" and button~="" then
            return "dialog:"..dialogName.."|button:"..button
        end
        local action=packetField(packet,"action") or ""
        if action~="" then
            local compact=packet:gsub("\r",""):gsub("\n+","\n")
            if #compact>300 then compact=compact:sub(1,300) end
            return compact
        end
        return ""
    end

    function JimiProxyButtonHotkeys.label(fp)
        fp=tostring(fp or "")
        local d,b=fp:match("^dialog:([^|]+)|button:(.+)$")
        if d and b then return b.." @ "..d end
        if fp=="" then return "Not set" end
        return cut(fp:gsub("\n"," / "),44)
    end

    function JimiProxyButtonHotkeys.load()
        local p=buttonHotkeyPref()
        for i=1,4 do
            JimiProxyButtonHotkeys.entries[i]={
                packet=tostring(p:get("button_pkt_"..i,"") or ""),
                command=tostring(p:get("button_cmd_"..i,"") or "")
            }
        end
        local mode=tostring(p:get("hotkey_mode","shortcut") or "shortcut")
        if mode=="button" or mode=="shortcut" then hotkeyMode=mode end
    end

    function JimiProxyButtonHotkeys.save()
        local p=buttonHotkeyPref()
        p:set("hotkey_mode",hotkeyMode)
        for i=1,4 do
            local e=JimiProxyButtonHotkeys.entries[i] or {}
            p:set("button_pkt_"..i,tostring(e.packet or ""))
            p:set("button_cmd_"..i,tostring(e.command or ""))
        end
        p:save()
    end

    function JimiProxyButtonHotkeys.setMode(mode)
        if mode~="shortcut" and mode~="button" then return false end
        hotkeyMode=mode
        JimiProxyButtonHotkeys.save()
        return true
    end

    function JimiProxyButtonHotkeys.open()
        local out=theme()
            .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
            ..JimiProxyExt.identity("Button Hotkeys",32)
            .."add_smalltext|`9Bind one game/UI button to one command.|left|\n"
            .."add_spacer|tiny|\n"
        for i=1,4 do
            local e=JimiProxyButtonHotkeys.entries[i] or {}
            out=out.."add_button|buttonhk_edit_"..i.."|`w"..i..". `9"..cleanDialog(JimiProxyButtonHotkeys.label(e.packet)).." `8[`6"..cleanDialog(e.command or "").."`8]|noflags|0|0|\n"
        end
        out=out.."add_quick_exit|\nend_dialog|jimi_button_hotkeys|Close||\n"
        dialog(out)
        return true
    end

    function JimiProxyButtonHotkeys.edit(slot)
        slot=tonumber(slot) or 0
        if slot<1 or slot>4 then return false end
        local e=JimiProxyButtonHotkeys.entries[slot] or {}
        local out=theme()
            .."add_label_with_icon|small|[`cJimi`6Proxy`9] `2Button Hotkey "..slot.."|left|32|\n"
            .."add_smalltext|`9Current: `w"..cleanDialog(JimiProxyButtonHotkeys.label(e.packet)).."|left|\n"
            .."add_spacer|tiny|\n"
            .."add_button|buttonhk_record_"..slot.."|`2Start Record|noflags|0|0|\n"
            .."add_button|buttonhk_clear_"..slot.."|`4Clear|noflags|0|0|\n"
            .."add_quick_exit|\nend_dialog|jimi_button_hotkey_edit|Close||\n"
        dialog(out)
        return true
    end

    function JimiProxyButtonHotkeys.input(slot)
        slot=tonumber(slot) or JimiProxyButtonHotkeys.slot
        local out=theme()
            .."add_label_with_icon|small|[`cJimi`6Proxy`9] `2Save Button Hotkey|left|32|\n"
            .."add_smalltext|`9Captured: `w"..cleanDialog(JimiProxyButtonHotkeys.label(JimiProxyButtonHotkeys.tempPacket)).."|left|\n"
            .."add_spacer|tiny|\n"
            .."add_text_input|buttonhk_command|Command / chat||120|\n"
            .."add_button|buttonhk_save_"..slot.."|`2Save|noflags|0|0|\n"
            .."add_quick_exit|\nend_dialog|jimi_button_hotkey_input|Close||\n"
        dialog(out)
        return true
    end

    function JimiProxyButtonHotkeys.handleDialog(packet)
        local name=packetField(packet,"dialog_name") or ""
        local button=packetField(packet,"buttonClicked") or ""
        if name=="jimi_button_hotkeys" then
            local slot=button:match("^buttonhk_edit_(%d+)$")
            if slot then return JimiProxyButtonHotkeys.edit(slot) end
            return true
        end
        if name=="jimi_button_hotkey_edit" then
            local slot=button:match("^buttonhk_record_(%d+)$")
            if slot then
                JimiProxyButtonHotkeys.slot=tonumber(slot)
                JimiProxyButtonHotkeys.recording=true
                JimiProxyButtonHotkeys.tempPacket=""
                overlay("`6Recording... press a button.")
                return true
            end
            slot=button:match("^buttonhk_clear_(%d+)$")
            if slot then
                slot=tonumber(slot)
                JimiProxyButtonHotkeys.entries[slot]={packet="",command=""}
                JimiProxyButtonHotkeys.save()
                overlay("`2Button hotkey cleared.")
                return JimiProxyButtonHotkeys.open()
            end
            return true
        end
        if name=="jimi_button_hotkey_input" then
            local slot=button:match("^buttonhk_save_(%d+)$")
            if slot then
                slot=tonumber(slot)
                local command=JimiProxyButtonHotkeys.clean(packetField(packet,"buttonhk_command") or "")
                if command=="" or JimiProxyButtonHotkeys.tempPacket=="" then
                    overlay("`4Command or button is empty.")
                    return true
                end
                JimiProxyButtonHotkeys.entries[slot]={packet=JimiProxyButtonHotkeys.tempPacket,command=command}
                JimiProxyButtonHotkeys.tempPacket=""
                JimiProxyButtonHotkeys.save()
                overlay("`2Button hotkey saved.")
                return JimiProxyButtonHotkeys.open()
            end
            return true
        end
        return false
    end

    function JimiProxyButtonHotkeys.onPacket(tp,packet)
        if tonumber(tp)~=2 or type(packet)~="string" then return false end
        if packet:find("action|input",1,true) then return false end

        if JimiProxyButtonHotkeys.recording then
            local fp=JimiProxyButtonHotkeys.fingerprint(packet)
            if fp~="" then
                JimiProxyButtonHotkeys.recording=false
                JimiProxyButtonHotkeys.tempPacket=fp
                overlay("`2Button captured.")
                JimiProxyButtonHotkeys.input(JimiProxyButtonHotkeys.slot)
                return true
            end
            return false
        end

        if hotkeyMode~="button" then return false end
        local fp=JimiProxyButtonHotkeys.fingerprint(packet)
        if fp=="" then return false end
        for i=1,4 do
            local e=JimiProxyButtonHotkeys.entries[i] or {}
            if e.packet~="" and e.command~="" and e.packet==fp then
                return JimiProxyExt.executeHotkeyText(e.command) or true
            end
        end
        return false
    end

    JimiProxyButtonHotkeys.load()

    JimiProxyConfig = {}
    local configPrefCache=nil
    local CONFIG_SEP=string.char(30)

    local function configPref()
        if configPrefCache then return configPrefCache end
        local ok,p=pcall(require,"Preferences")
        if not ok or not p then ok,p=pcall(require,"preferences") end
        if not ok or not p then return nil end
        local made,obj=pcall(function() return p:new("JimiProxy_named_configs_v1") end)
        if made and obj then p=obj end
        pcall(function() p:load() end)
        configPrefCache=p
        return p
    end

    local function hexEncode(value)
        return (tostring(value or ""):gsub(".",function(c)return string.format("%02X",string.byte(c))end))
    end

    local function hexDecode(value)
        value=tostring(value or "")
        return (value:gsub("(%x%x)",function(h)return string.char(tonumber(h,16) or 32)end))
    end

    local function profileKey(name)
        return "profile_"..hexEncode(name:lower())
    end

    function JimiProxyConfig.names()
        local p=configPref()
        if not p then return {} end
        local raw=tostring(p:get("config_names","") or "")
        local out={}
        if raw~="" then
            for name in (raw..CONFIG_SEP):gmatch("(.-)"..CONFIG_SEP) do
                local cleanName=trim(name)
                if cleanName~="" then out[#out+1]=cleanName end
            end
        end
        return out
    end

    function JimiProxyConfig.writeNames(names)
        local p=configPref()
        if not p then return false end
        p:set("config_names",table.concat(names,CONFIG_SEP))
        return pcall(function() p:save() end)
    end

    function JimiProxyConfig.snapshot()
        local rows={}
        local function put(k,v) rows[#rows+1]=k.."="..hexEncode(v) end
        put("uiTheme",selectedUITheme)
        put("border",BORDER_COLOR)
        put("bg",BG_COLOR)
        put("delayDrop",JimiProxyDelay.drop)
        put("delayWrench",JimiProxyDelay.fastWrench)
        put("delayAutoWrench",JimiProxyDelay.autoWrench)
        put("delayBlink",JimiProxyDelay.blink)
        put("delaySpam",spamDelay)
        put("delayTP",TP_COOLDOWN)
        put("title",selectedTitle)
        put("role",selectedRoleID)
        if JimiProxyGuard and JimiProxyGuard.configState then
            local guardOn,guardList=JimiProxyGuard.configState()
            put("guardEnabled",guardOn and "1" or "0")
            put("guardSelected",guardList or "")
        end
        put("hotkeyMode",hotkeyMode)
        for i=1,4 do
            put("shortcut"..i,JimiProxyHotkeys.command(i))
            local e=JimiProxyButtonHotkeys.entries[i] or {}
            put("buttonPkt"..i,e.packet or "")
            put("buttonCmd"..i,e.command or "")
        end
        return table.concat(rows,"\n")
    end

    function JimiProxyConfig.parse(raw)
        local out={}
        for line in tostring(raw or ""):gmatch("[^\r\n]+") do
            local k,v=line:match("^([^=]+)=(.*)$")
            if k then out[k]=hexDecode(v) end
        end
        return out
    end

    function JimiProxyConfig.apply(data)
        if type(data)~="table" then return false end
        if data.uiTheme and data.uiTheme~="" then selectedUITheme=data.uiTheme end
        if JimiProxyExt.validRGBA(data.border) then BORDER_COLOR=JimiProxyExt.validRGBA(data.border) end
        if JimiProxyExt.validRGBA(data.bg) then BG_COLOR=JimiProxyExt.validRGBA(data.bg) end
        JimiProxyDelay.drop=tonumber(data.delayDrop) or JimiProxyDelay.drop
        JimiProxyDelay.fastWrench=tonumber(data.delayWrench) or JimiProxyDelay.fastWrench
        JimiProxyDelay.autoWrench=tonumber(data.delayAutoWrench) or JimiProxyDelay.autoWrench
        JimiProxyDelay.blink=math.max(120,tonumber(data.delayBlink) or JimiProxyDelay.blink)
        spamDelay=math.max(800,tonumber(data.delaySpam) or spamDelay)
        JimiProxyDelay.spam=spamDelay
        TP_COOLDOWN=math.max(0,tonumber(data.delayTP) or TP_COOLDOWN)
        JimiProxyDelay.tp=TP_COOLDOWN
        if data.title and TITLES[data.title] then applyTitle(data.title) end
        if data.role and tonumber(data.role) then JimiProxyExt.applyRoleSkin(tonumber(data.role)) end
        if data.guardEnabled and JimiProxyGuard and JimiProxyGuard.applyConfig then
            JimiProxyGuard.applyConfig(data.guardEnabled,data.guardSelected or "")
        end
        if data.hotkeyMode=="shortcut" or data.hotkeyMode=="button" then
            JimiProxyButtonHotkeys.setMode(data.hotkeyMode)
        end
        for i=1,4 do
            if data["shortcut"..i]~=nil then pcall(JimiProxyHotkeys.set,i,data["shortcut"..i]) end
            local e=JimiProxyButtonHotkeys.entries[i] or {}
            if data["buttonPkt"..i]~=nil then e.packet=data["buttonPkt"..i] end
            if data["buttonCmd"..i]~=nil then e.command=data["buttonCmd"..i] end
            JimiProxyButtonHotkeys.entries[i]=e
        end
        JimiProxyButtonHotkeys.save()
        return true
    end

    function JimiProxyConfig.save(name)
        name=cleanDialog(name)
        if name=="" then overlay("`4Enter a config name.");return true end
        if #name>32 then name=name:sub(1,32) end
        local p=configPref()
        if not p then overlay("`4Config storage unavailable.");return true end
        p:set(profileKey(name),JimiProxyConfig.snapshot())
        local names=JimiProxyConfig.names()
        local found=false
        for _,n in ipairs(names)do if n:lower()==name:lower() then found=true;break end end
        if not found then names[#names+1]=name end
        p:set("config_names",table.concat(names,CONFIG_SEP))
        p:save()
        overlay("`2Config saved: `w"..name)
        return true
    end

    function JimiProxyConfig.load(name)
        name=cleanDialog(name)
        local p=configPref()
        if not p or name=="" then overlay("`4Enter a config name.");return true end
        local raw=tostring(p:get(profileKey(name),"") or "")
        if raw=="" then overlay("`4Config not found: `w"..name);return true end
        JimiProxyConfig.apply(JimiProxyConfig.parse(raw))
        overlay("`2Config loaded: `w"..name)
        return true
    end

    function JimiProxyConfig.delete(name)
        name=cleanDialog(name)
        local p=configPref()
        if not p or name=="" then overlay("`4Enter a config name.");return true end
        p:set(profileKey(name),"")
        local out={}
        for _,n in ipairs(JimiProxyConfig.names())do
            if n:lower()~=name:lower() then out[#out+1]=n end
        end
        p:set("config_names",table.concat(out,CONFIG_SEP))
        p:save()
        overlay("`4Config deleted: `w"..name)
        return true
    end

    function JimiProxyConfig.show()
        local names=JimiProxyConfig.names()
        local out=theme()
            .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
            ..JimiProxyExt.identity("Config",3234)
            .."add_smalltext|`9Same name overwrites the saved config.|left|\n"
            .."add_spacer|tiny|\n"
            .."add_text_input|config_name|Name||32|\n"
            .."add_button|config_save|`2Save|noflags|0|0|\n"
            .."add_button|config_load|`9Load|noflags|0|0|\n"
            .."add_button|config_delete|`4Delete|noflags|0|0|\n"
        if #names>0 then
            out=out.."add_spacer|tiny|\nadd_smalltext|`8Saved: `w"..cleanDialog(table.concat(names,", ")).."|left|\n"
        end
        out=out.."add_quick_exit|\nend_dialog|jimi_config|Close||\n"
        dialog(out)
        return true
    end

    function JimiProxyConfig.handle(packet)
        if packetField(packet,"dialog_name")~="jimi_config" then return false end
        local name=packetField(packet,"config_name") or ""
        local button=packetField(packet,"buttonClicked") or ""
        if button=="config_save" then JimiProxyConfig.save(name)
        elseif button=="config_load" then JimiProxyConfig.load(name)
        elseif button=="config_delete" then JimiProxyConfig.delete(name)
        end
        return JimiProxyConfig.show()
    end
    end -- hotkeys + named config scope

    JimiProxySettings = {}
    local settingsView = "home"

    local SETTINGS_BUTTON_SPRITES = {
        settings_config      = {"game/tiles_page14.rttex", 28,23},
        settings_hotkeys     = {"game/tiles_page1.rttex",  10, 2},
        settings_ui          = {"game/tiles_page10.rttex",  8, 2},
        settings_custom_ui   = {"game/tiles_page10.rttex",  9, 2},
        settings_antitroll   = {"game/tiles_page14.rttex", 30,23},
        settings_delay       = {"game/tiles_page1.rttex",  10, 2},

        log_drop             = {"game/tiles_page16.rttex",  8,22},
        log_lock_wl          = {"game/tiles_page16.rttex",  8,22},
        log_lock_dl          = {"game/tiles_page16.rttex",  8,22},
        log_lock_bgl         = {"game/tiles_page16.rttex",  8,22},
        log_vending          = {"game/tiles_page4.rttex",  11, 9},
        log_player_join      = {"game/tiles_page1.rttex",   0,12},
        log_player_leave     = {"game/tiles_page1.rttex",   0,12},
        log_world            = {"game/tiles_page1.rttex",   0,12},
        log_wheel            = {"game/tiles_page1.rttex",  27,10},
        log_sb               = {"game/tiles_page2.rttex",  24,22},
        log_bj_gems          = {"game/tiles_page16.rttex",  9,22},
    }

    local function settingsButton(id,label,icon,frame)
        local spec = SETTINGS_BUTTON_SPRITES[id] or {"game/tiles_page14.rttex", 28,23}
        -- Full-width image-label button: icon and text stay in one row.
        return "add_friend_image_label_button|"..id.."|``  `w"..label.."|"
            ..spec[1].."|1.6|"..tostring(spec[2]).."|"..tostring(spec[3]).."|32|false|false|\n"
    end

    local function settingsDesc(text)
        -- Keep the description tucked under the button instead of creating a tall gap.
        return "add_custom_margin|x:30;y:-5|\n"
            .."add_custom_textbox|`8"..text.."|size:tiny;color:150,150,150,255;x:100;y:100;|\n"
            .."reset_placement_x|\n"
    end

    function JimiProxySettings.open(nextView,native)
        settingsView=nextView=="logs" and "logs" or "home"
        return JimiProxyExt.UI.open("settings",native)
    end

    function JimiProxySettings.applyInlineSettings(packet)
        packet=tostring(packet or "")
        local a=packetField(packet,"hotkey_shortcut_mode")
        local b=packetField(packet,"hotkey_button_mode")
        if a~=nil or b~=nil then
            local shortcut=(tostring(a)=="1")
            local button=(tostring(b)=="1")
            if shortcut and button then
                if hotkeyMode=="shortcut" then hotkeyMode="button" else hotkeyMode="shortcut" end
            elseif button then hotkeyMode="button"
            elseif shortcut then hotkeyMode="shortcut"
            end
            JimiProxyButtonHotkeys.setMode(hotkeyMode)
        end
    end

    function JimiProxySettings.logButtons()
        local rows={
            {"log_drop","Drop Logs",242,#dropLogs},
            {"log_lock_wl","World Lock Drops",WL_ID,#wlDropLogs},
            {"log_lock_dl","Diamond Lock Drops",DL_ID,#dlDropLogs},
            {"log_lock_bgl","Blue Gem Lock Drops",BGL_ID,#bglDropLogs},
            {"log_vending","Vending Logs",SEARCH_ICON,#vendingLogs},
            {"log_player_join","Player Join Logs",NICK_ICON,#playerJoinLogs},
            {"log_player_leave","Player Leave Logs",NICK_ICON,#playerLeaveLogs},
            {"log_world","World Logs",6,#worldLogs},
            {"log_wheel","Wheel Logs",758,#wheelLogs},
            {"log_sb","SB Logs",LOGS_ICON,#sbLogs},
            {"log_bj_gems","BJ Logs",GEM_ID,#bjGemLogs}
        }
        local out="add_spacer|tiny|\nadd_label_with_icon|small|`2Logs|left|"..LOGS_ICON.."|\n"
        for _,row in ipairs(rows)do
            out=out..settingsButton(row[1],row[2].." `8("..row[4]..")",row[3])
        end
        return out
    end

    function JimiProxySettings.content()
        if settingsView=="logs" then return JimiProxyExt.logsContent() end
        local out=JimiProxyExt.identity("Settings",32)
            .."add_spacer|tiny|\n"
            ..settingsButton("settings_config","Config",32)
            ..settingsDesc("Save, load, or delete named settings.")
            .."add_spacer|tiny|\n"
            .."add_checkbox|hotkey_shortcut_mode|`2Shortcut Mode|"..(hotkeyMode=="shortcut" and "1" or "0").."|\n"
            ..settingsDesc("Use 4 quick shortcuts.")
            .."add_checkbox|hotkey_button_mode|`2Button Mode|"..(hotkeyMode=="button" and "1" or "0").."|\n"
            ..settingsDesc("Bind a game button to a command.")
            ..settingsButton("settings_hotkeys","Hotkeys",2724)
            .."add_spacer|tiny|\n"
            ..settingsButton("settings_ui","UI Colors",9474)
            ..settingsDesc("Choose a color preset.")
            ..settingsButton("settings_custom_ui","Custom UI Colors",9474)
            ..settingsDesc("Set background and border RGBA.")
            .."add_spacer|tiny|\n"
            ..settingsButton("settings_antitroll","Anti Troll",618)
            ..settingsDesc("Supported consumable protection.")
            ..settingsButton("settings_delay","Custom Delay",WRENCH_ICON)
            ..settingsDesc("Drop, wrench, blink, spam, and TP delays.")
            ..JimiProxySettings.logButtons()
            .."add_spacer|small|\n"
        return out
    end

    function JimiProxySettings.showHotkeys()
        if hotkeyMode=="button" then return JimiProxyButtonHotkeys.open() end
        local out=theme()
            .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
            ..JimiProxyExt.identity("Shortcut Hotkeys",32)
            .."add_smalltext|`9Command, emote, or normal chat.|left|\n"
            .."add_spacer|tiny|\n"
        for slot=1,4 do
            out=out.."add_text_input|hk_cmd_"..slot.."|"..slot.."|"..cleanDialog(JimiProxyHotkeys.command(slot)).."|120|\n"
        end
        out=out.."add_spacer|tiny|\nadd_button|hotkeys_save|`2Save|noflags|0|0|\n"
            .."add_quick_exit|\nend_dialog|jimi_hotkeys|Close||\n"
        dialog(out)
        return true
    end

    function JimiProxySettings.saveHotkeys(packet)
        local success=true
        for slot=1,4 do
            local value=packetField(packet,"hk_cmd_"..slot) or ""
            if not JimiProxyHotkeys.set(slot,value) then success=false end
        end
        overlay(success and "`2Hotkeys saved." or "`4One or more hotkeys could not be saved.")
        return JimiProxySettings.showHotkeys()
    end

    function JimiProxySettings.handle(name,packet)
        JimiProxySettings.applyInlineSettings(packet)
        if name=="settings_home" then
            JimiProxyExt.logView=nil
            return JimiProxySettings.open("home",true)
        end
        if name=="settings_config" then return JimiProxyConfig.show() end
        if name=="settings_hotkeys" then return JimiProxySettings.showHotkeys() end
        if name=="settings_ui" then return JimiProxyExt.showUI() end
        if name=="settings_custom_ui" then return JimiProxyExt.showCustomUI() end
        if name=="settings_delay" then return JimiProxyExt.showCustomDelay() end
        if name=="settings_antitroll" then return JimiProxyGuard.show() end
        if name=="logs_back" then
            JimiProxyExt.logView=nil
            return JimiProxySettings.open("home",true)
        end
        if name:match("^log_") then
            settingsView="logs"
            return JimiProxyExt.handleLogAction(name,true)
        end
        if settingsView=="logs" then return JimiProxyExt.handleLogAction(name,true) end
        return false
    end

    function JimiProxySettings.pullContent()
        local out=JimiProxyExt.identity("Pull Tile",32)
            .."add_smalltext|`9PT1-PT4 save positions. Pull uses every saved position.|left|\n"
        for slot=1,4 do
            local pos=JimiProxyPullTile.get(slot)
            out=out.."add_smalltext|`1PT"..slot.." `8[`6"..(pos and (pos.x..", "..pos.y) or "Not set").."`8]|left|\n"
                .."add_button|pt_set_"..slot.."|`cSet PT"..slot.." Here|noflags|0|0|\n"
        end
        return out.."add_spacer|tiny|\nadd_button|pt_pull_all|`2Pull|noflags|0|0|\n"
    end

    function JimiProxySettings.showPullTile()
        dialog(theme()..JimiProxySettings.pullContent().."add_quick_exit|\nend_dialog|jimi_pulltile|Close||\n")
        return true
    end

    function JimiProxySettings.handlePullTile(packet)
        if packetField(packet,"dialog_name")~="jimi_pulltile" then return false end
        local button=packetField(packet,"buttonClicked") or ""
        if button=="pt_pull_all" then
            JimiProxyPullTile.pullAll()
            JimiProxySettings.showPullTile()
            return true
        end
        local action,slot=button:match("^pt_([a-z]+)_([1-4])$")
        slot=tonumber(slot)
        if action=="set" then
            local x,y=tilePosition()
            JimiProxyPullTile.set(slot,x,y)
            JimiProxySettings.showPullTile()
            return true
        end
        if action=="clear" then
            JimiProxyPullTile.clear(slot)
            JimiProxySettings.showPullTile()
            return true
        end
        return true
    end

    function JimiProxySettings.showCalculator()
        dialog(theme()
            .."text_scaling_string|WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW|\n"
            ..JimiProxyExt.identity("Calculator",1752)
            .."add_smalltext|`9Supported: `1+  -  x  *  /  ( )|left|\n"
            .."add_spacer|tiny|\n"
            .."add_text_input|calc_expression|Expression||84|\n"
            .."add_button|calc_send|`2Calculate & Send|noflags|0|0|\n"
            .."add_quick_exit|\nend_dialog|jimi_calculator|Close||\n")
        return true
    end

    function JimiProxySettings.handleDialog(packet)
        local name=packetField(packet,"dialog_name")
        if name=="jimi_hotkeys" then
            if packetField(packet,"buttonClicked")=="hotkeys_save" then return JimiProxySettings.saveHotkeys(packet) end
            return true
        end
        if name=="jimi_button_hotkeys" or name=="jimi_button_hotkey_edit" or name=="jimi_button_hotkey_input" then
            return JimiProxyButtonHotkeys.handleDialog(packet)
        end
        if name=="jimi_config" then return JimiProxyConfig.handle(packet) end
        if name=="jimi_calculator" then
            if packetField(packet,"buttonClicked")=="calc_send" then
                JimiProxyCalc.handle("/c "..(packetField(packet,"calc_expression") or ""),"")
            end
            return true
        end
        if name=="jimi_pulltile" then return JimiProxySettings.handlePullTile(packet) end
        return JimiProxyGuard.handleDialog(packet)
    end

    function JimiProxySettings.mainAction(button)
        return false
    end

    function JimiProxySettings.command(cmd,low)
        if low=="/settings" or low=="/setting" then JimiProxySettings.open("home");return true end
        if low=="/hotkeys" or low=="/hotkey" then return JimiProxySettings.showHotkeys() end
        if low=="/config" then return JimiProxyConfig.show() end
        if low=="/pt" then return JimiProxyPullTile.pullAll() end
        if low=="/pt pull" then return JimiProxyPullTile.pullAll() end
        if low=="/pt clear" then JimiProxyPullTile.clearAll();overlay("`6Pull Tile positions cleared.");return true end
        if low=="/antitroll" then return JimiProxyGuard.show() end
        local slot,rest=low:match("^/pt([1-4])%s+(.*)$")
        if not slot then slot=low:match("^/pt([1-4])$");rest="" end
        slot=tonumber(slot)
        if slot then
            if rest=="" or rest=="set" then
                local x,y=tilePosition();JimiProxyPullTile.set(slot,x,y)
            elseif rest=="clear" then
                JimiProxyPullTile.clear(slot)
            elseif rest=="pull" then
                overlay("`6Use /pt pull to trigger all saved Pull Tiles.")
            else
                local x,y=rest:match("^(%d+)%s+(%d+)$")
                if x then JimiProxyPullTile.set(slot,x,y) else overlay("`6Use /pt"..slot..", /pt"..slot.." clear, or /pt pull.") end
            end
            return true
        end
        return false
    end
end


local function handleCommand(raw)
    local cmd = trim(raw or "")
    local low = cmd:lower()
    if low == "" then return false end
    if JimiProxyCalc.handle(cmd,low) or JimiProxySettings.command(cmd,low) then return true end
    if low == "/proxy" or low == "/news" then JimiProxyExt.showNews(); return true end
    if low == "/menu" then JimiProxyExt.showMenu(); return true end
    if low == "/credits" then JimiProxyExt.UI.open("credits"); return true end
    if low == "/startupfix" then
        JimiProxyStartup.start(true)
        return true
    end
    if low == "/profile" or low == "/profil" then return JimiProxyExt.showProfile() end
    if low == "/ui" then return JimiProxyExt.showUI() end
    if low == "/costumdelay" then return JimiProxyExt.showCustomDelay() end
    if low == "/inv" then return JimiProxyDaily.showInventory() end
    local sitemQuery = cmd:match("^/[Ss][Ii][Tt][Ee][Mm]%s*(.*)$")
    if sitemQuery ~= nil then return JimiProxySearch.handle(sitemQuery) end
    if low == "/relog" then return JimiProxySession.relog() end
    if low == "/res" or low == "/respawn" then return JimiProxySession.respawn() end
    if low == "/dc" or low == "/disconnect" then return JimiProxySession.disconnect() end
    if low == "/back" then return JimiProxySession.back() end
    if low == "/hidden" then return JimiProxyHidden.toggle() end
    if low == "/streammode" then return JimiProxyStream.toggle() end
    if low == "/mods" then return JimiProxyMods.request() end
    if low == "/chat" then return JimiProxyChat.show() end
    if low == "/cgems" then return JimiProxyExt.showCurrentGems() end
    if low == "/vends" then return JimiProxyVends.handleCommand("") end
    local vendsQuery = cmd:match("^/[Vv][Ee][Nn][Dd][Ss]%s+(.+)$")
    if vendsQuery then return JimiProxyVends.handleCommand(vendsQuery) end
    local vdropID, vdropAmount = cmd:match("^/[Vv][Dd][Rr][Oo][Pp]%s+(%d+)%s+(%d+)%s*$")
    if vdropID and vdropAmount then return JimiProxyDaily.visualDrop(vdropID, vdropAmount) end
    local dropID, dropAmount = cmd:match("^/[Dd][Rr][Oo][Pp]%s+(%d+)%s+(%d+)%s*$")
    if dropID and dropAmount then return JimiProxyDaily.customDrop(dropID, dropAmount) end
    if low:match("^/vdrop") then return JimiProxyDaily.visualDrop(0, 0) end
    if low:match("^/drop") then return JimiProxyDaily.customDrop(0, 0) end
    if low == "/wauto" then return JimiProxyExt.showWAuto() end
    local tpq = cmd:match("^/[Tt][Pp]%s+(.+)$")
    if tpq then return JimiProxyExt.tpSearch(tpq) end
    if low == "/discord" then JimiProxyExt.showDiscord(); return true end
    if low == "/whatsapp" then JimiProxyExt.showWA(); return true end
    if low == "/web" then JimiProxyExt.showWeb(); return true end
    if low == "/weather" or low == "/wth" then return showWeatherUI() end
    if low == "/wreset" then resetWeather(); showWeatherUI(); return true end
    local wid = low:match("^/wid%s+(%-?%d+)$")
    if wid then
        local id = tonumber(wid)
        if id < 0 or id > 255 then overlay("`4Weather ID 0-255."); return true end
        local w = weatherById(id)
        return setWeatherLocal(id, w and w.name or "Weather")
    end
    if low == "/role" or low == "/roles" then return JimiProxyExt.showRoleUI() end
    if low == "/title" or low == "/titles" then return showTitleUI() end
    if low == "/titlereset" then applyTitle("original"); showTitleUI(); return true end
    if low == "/blink" then return JimiProxyExt.setBlink() end
    if low == "/logs" or low == "/log" then JimiProxyExt.logView=nil;JimiProxySettings.open("home"); return true end
    if low == "/totalfitur" or low == "/fitur" then JimiProxyExt.showTotalFitur(); return true end
    if low == "/balance" or low == "/bal" then return showBalance() end
    if low == "/reme" then rouletteMode = "REME"; say("`2REME mode enabled."); return true end
    if low == "/qeme" or low == "/qrme" then rouletteMode = "QEME"; say("`2QEME mode enabled."); return true end
    if low == "/leme" then rouletteMode = "LEME"; say("`2LEME mode enabled."); return true end
    if bj.handleCommand(cmd, low) then return true end
    if low == "/fpull" or low == "/fastpull" then return JimiProxyExt.setFast("pull") end
    if low == "/fkick" or low == "/fastkick" then return JimiProxyExt.setFast("kick") end
    if low == "/fban" or low == "/fastban" then return JimiProxyExt.setFast("ban") end
    if low == "/fasttrade" then return JimiProxyExt.setFast("trade") end
    if low == "/fdrop" or low == "/fastdrop" then return JimiProxyExt.setFastDrop() end
    if low == "/ftrash" or low == "/fasttrash" then return JimiProxyExt.setFastTrash() end
    if low == "/fstop" or low == "/faststop" then return JimiProxyExt.stopFastTools() end
    if low == "/woff" then return JimiProxyExt.setFast("") end
    local nn = cmd:match("^/[Nn][Ii][Cc][Kk]%s+(.+)$")
    if nn then return setNick(nn) end
    if low == "/soff" then return JimiProxyExt.stopSpam() end
    if low == "/spam" or low:find("^/spam%s") then return JimiProxyExt.showSpamDialog() end
    if low == "/daw" or low == "/dao" then return JimiProxyExt.dropAllLocks() end
    if low == "/cv" then return JimiProxyExt.convertDLToBGL() end
    local dw = low:match("^/dw%s+(%d+)$")
    if dw then return JimiProxyExt.dropItemFast(WL_ID, dw, "WL") end
    local dd = low:match("^/dd%s+(%d+)$")
    if dd then return JimiProxyExt.dropItemFast(DL_ID, dd, "DL") end
    local db = low:match("^/db%s+(%d+)$") or low:match("^/dbgl%s+(%d+)$")
    if db then return JimiProxyExt.dropItemFast(BGL_ID, db, "BGL") end
    local cd = low:match("^/cd%s+(%d+)$")
    if cd then return JimiProxyExt.dropValue(cd) end
    return false
end

JimiProxyExt.executeLocalCommand = handleCommand

function JimiProxyExt.executeHotkeyText(text)
    local raw=trim(tostring(text or ""):gsub("[\r\n|]"," "):gsub("%s+"," "))
    if raw=="" then return false end
    local ok=pcall(runThread,function(value)
        -- onValue comes from Growlauncher UI. Delay once so packet work is
        -- executed from the worker instead of the UI callback.
        sleep(100)
        local handled=false
        if value:sub(1,1)=="/" then
            local good,result=pcall(handleCommand,value)
            handled=good and result==true
        end
        if not handled then
            packet2("action|input\n|text|"..value)
        end
    end,raw)
    if not ok then overlay("`4Hotkey failed.") end
    return ok
end

local function onVar(var, pkt)
    if not var or innerVariant > 0 then return false end

    if JimiProxyFollowChat.onVariant(var, pkt) then return true end
    if JimiProxyMods.onVariant(var, pkt) then return true end
    if JimiProxyHidden.onVariant(var, pkt) then return true end
    if JimiProxyStream.onVariant(var, pkt) then return true end

    if var.v1 == "OnSpawn" and type(var.v2) == "string" then
        JimiProxyExt.onAutoJoinSpawn(var.v2)
        JimiProxyExt.logPlayerSpawn(var.v2)
    end
    if var.v1 == "OnRemove" then
        JimiProxyExt.logPlayerRemove(var)
    end

    if converting and var.v1 == "OnDialogRequest" and type(var.v2) == "string" then
        local cvText = strip(var.v2):lower()
        if cvText:find("wow, that's fast delivery.", 1, true) then
            cvSignal = cvSignal + 1
            return true
        end
        if cvText:find("phone cord doesn't reach that far", 1, true) then
            cvLastError = "Telephone out of range"
            return true
        end
    end
    if var.v1 == "OnSetCurrentWeather" then
        local serverID = tonumber(var.v2)
        if serverID ~= nil then
            lastServerWeather = serverID
            if selectedWeather ~= nil and selectedWeather ~= serverID then
                local w = weatherById(selectedWeather)
                setWeatherLocal(selectedWeather, w and w.name or "Weather")
                return true
            end
        end
    end
    if var.v1 == "OnDialogRequest" and type(var.v2) == "string" and JimiProxyExt.blockFastPopup(var.v2) then
        return true
    end
    if var.v1 == "OnDialogRequest" and type(var.v2) == "string" and var.v2:find("drop_item", 1, true) then
        local dialogText = var.v2
        local itemID = tonumber(dialogText:match("itemID|(%d+)") or dialogText:match("itemid|(%d+)"))
        if not itemID then
            if dialogText:find("Blue Gem Lock", 1, true) then itemID = BGL_ID elseif dialogText:find("Diamond Lock", 1, true) then itemID = DL_ID elseif dialogText:find("World Lock", 1, true) then itemID = WL_ID end
        end
        local pd = itemID and pendingDrops[itemID]
        if not pd then itemID, pd = JimiProxyExt.onlyPendingDrop() end
        if itemID and pd then
            if not pd.sent then
                pd.sent = true
                local expected = pd
                local expectedID = itemID
                runThread(function()
                    sleep(JimiProxyDelay.drop)
                    if pendingDrops[expectedID] == expected then
                        JimiProxyExt.confirmDropPacket(expectedID, expected.count)
                    end
                end)
            end
            return true
        end
        if JimiProxyExt.handleFastDropDialog(dialogText) then return true end
        if JimiProxyExt.UI then JimiProxyExt.UI.suspend() end
        return false
    end
    if var.v1 == "OnDialogRequest" and type(var.v2) == "string" and var.v2:find("trash_item", 1, true) then
        if JimiProxyExt.handleFastTrashDialog(var.v2) then return true end
    end
    if var.v1 == "OnConsoleMessage" and type(var.v2) == "string" then
        local originalText = var.v2
        local text = nickReplace(originalText)
        JimiProxyExt.logConsoleActivity(text)
        parseSB(text)
        local wheel = JimiProxyExt.parseWheel(text)
        if wheel then JimiProxyExt.emitWheel(wheel, nil); return true end
        if JimiProxyStream.enabled then
            text = JimiProxyStream.redact(text)
        end
        if text ~= originalText then
            sendVar({v1 = "OnConsoleMessage", v2 = text})
            return true
        end
        if consoleWatermark and trim(strip(text)) ~= "" and not JimiProxyExt.isProxyText(text) then
            sendConsole(prefix() .. text)
            return true
        end
        return false
    end
    if var.v1 == "OnTalkBubble" and type(var.v3) == "string" then
        local bubbleNetID = tonumber(var.v2) or 0
        if bubbleNetID > 0 and not bubbleVisibleForNetID(bubbleNetID) then
            return true
        end
        local wheel = JimiProxyExt.parseWheel(var.v3)
        if wheel then JimiProxyExt.emitWheel(wheel, bubbleNetID > 0 and bubbleNetID or myNetID()); return true end
        if JimiProxyStream.enabled then
            local masked = JimiProxyStream.redact(var.v3)
            if masked ~= var.v3 then
                sendVar({v1 = "OnTalkBubble", v2 = bubbleNetID, v3 = masked, v4 = var.v4 or 1})
                return true
            end
        end
        return false
    end
    if JimiProxyStream.enabled and var.v1 == "OnTextOverlay" and type(var.v2) == "string" then
        local masked = JimiProxyStream.redact(var.v2)
        if masked ~= var.v2 then
            sendVar({v1 = "OnTextOverlay", v2 = masked})
            return true
        end
    end
    if JimiProxyStream.enabled and var.v1 == "OnAddNotification" and type(var.v3) == "string" then
        local masked = JimiProxyStream.redact(var.v3)
        if masked ~= var.v3 then
            sendVar({v1 = "OnAddNotification", v2 = var.v2, v3 = masked, v4 = var.v4})
            return true
        end
    end
    if JimiProxyStream.enabled and var.v1 == "OnDialogRequest" and type(var.v2) == "string" then
        local masked = JimiProxyStream.redactDialog(var.v2)
        if masked ~= var.v2 then
            sendVar({v1 = "OnDialogRequest", v2 = masked})
            return true
        end
    end
    if var.v1=="OnDialogRequest" and JimiProxyExt.UI and not JimiProxyExt.UI.isDialog(var.v2) then JimiProxyExt.UI.suspend() end
    return false
end

local function onPkt(tp, packet)
    if innerPacket > 0 or type(packet) ~= "string" then return false end
    if JimiProxyFollowChat.onPacket(tp,packet) then return true end
    if JimiProxyButtonHotkeys and JimiProxyButtonHotkeys.onPacket(tp,packet) then return true end
    if JimiProxyExt.UI.handle(tp,packet) then return true end
    if (tp==2 or tp==3) and packetField(packet,"action")=="dialog_return" and JimiProxySettings.handleDialog(packet) then return true end
    if tp ~= 2 then return false end
    if packet:find("action|input", 1, true) then
        local cmd = packet:match("|text|([^\n]+)") or packet:match("text|([^\n]+)")
        if cmd then return handleCommand(cmd) end
        return false
    end
    if fastMode ~= "" and packet:find("action|wrench", 1, true) then
        local netid = packet:match("netID|(%d+)") or packet:match("netid|(%d+)") or packet:match("netID|(%d+)|") or packet:match("netid|(%d+)|")
        if JimiProxyExt.doFastWrench(netid) then return true end
        return false
    end
    if packet:find("action|dialog_return", 1, true) then
        local dialogName = packet:match("dialog_name|([^\n]+)") or ""
        local button = packet:match("buttonClicked|([^\n]+)") or ""
        if dialogName == "spam_dialog" then return JimiProxyExt.handleSpamDialog(packet) end
        if dialogName == "jimi_weather_dialog" then return JimiProxyExt.handleWeatherDialog(packet) end
        if dialogName == "jimi_title_dialog" then return JimiProxyExt.handleTitleDialog(packet) end
        if dialogName == "jimi_role_dialog" then return JimiProxyExt.handleRoleDialog(packet) end
        if dialogName == "jimi_ui_dialog" then return JimiProxyExt.handleUIDialog(packet) end
        if dialogName == "jimi_custom_ui" then return JimiProxyExt.handleCustomUI(packet) end
        if dialogName == "jimi_custom_delay" then return JimiProxyExt.handleCustomDelay(packet) end
        if dialogName == "jimi_wauto_dialog" then return JimiProxyExt.handleWAutoDialog(packet) end
        if dialogName == "jimi_tp_dialog" then return JimiProxyExt.handleTPDialog(packet) end
        if dialogName == "jimi_sitem" then return JimiProxySearch.handleDialog(packet) end
        if dialogName == "jimi_chat" then return JimiProxyChat.handleDialog(packet) end
        if dialogName == "jimi_vends_main" or dialogName == "jimi_vends_item" then return JimiProxyVends.handleDialog(packet) end
        if dialogName == "jimi_inventory_viewer" then return true end
        if dialogName == "menu_dialog" or dialogName == "news_close" or dialogName == "discord_close" or dialogName == "wa_close" or dialogName == "web_close" or dialogName == "fitur_close" or dialogName == "profile_close" then return true end
        if dialogName == "logs_main" or dialogName == "log_page" then
            return JimiProxyExt.handleLogAction(button,false)
        end
    end
    return false
end

local ManualGem = {
    eventBusy = false,
    lastEvent = 0,
    QUIET_MS = 140,
    SAMPLE_DELAY = 60
}

function ManualGem.balance()
    local value = safe(getGems)
    value = tonumber(value)
    if value == nil then return nil end
    return math.floor(value)
end

function ManualGem.reset()
    manualGemPending = 0
    manualGemToken = manualGemToken + 1
    manualGemSampleToken = manualGemSampleToken + 1
    manualGemLast = ManualGem.balance()
end

function ManualGem.flushLater()
    manualGemToken = manualGemToken + 1
    local token = manualGemToken

    runThread(function()
        sleep(MANUAL_GEM_BATCH)

        if token ~= manualGemToken then return end

        local total = math.floor(tonumber(manualGemPending) or 0)
        manualGemPending = 0

        if total > 0 then

            packet2("action|input\n|text|Collected +`2" .. tostring(total))
        end
    end)
end

function ManualGem.sample()
    local current = ManualGem.balance()
    if current == nil then return end

    if manualGemLast == nil then
        manualGemLast = current
        return
    end

    local gain = current - manualGemLast
    manualGemLast = current

    if gain <= 0 then return end
    if ms() < manualGemSuppressUntil then return end

    manualGemPending = manualGemPending + gain
    ManualGem.flushLater()
end

function ManualGem.trigger()
    ManualGem.lastEvent = ms()
    manualGemSampleToken = manualGemSampleToken + 1
    local token = manualGemSampleToken

    if ManualGem.eventBusy then return end
    ManualGem.eventBusy = true

    runThread(function()
        sleep(ManualGem.SAMPLE_DELAY)

        while ms() - ManualGem.lastEvent < ManualGem.QUIET_MS do
            if token <= manualGemSampleToken then
                ManualGem.sample()
            end
            sleep(80)
        end

        ManualGem.sample()
        ManualGem.eventBusy = false
    end)
end

local GemNumber = {
    EFFECT = 181,
    SAMPLE_MS = 55,
    QUIET_MS = 230,
    seen = {},
    lastWorld = "",
    eventBusy = false,
    lastEvent = 0,
    lastWorldAmount = 0,
    eventGain = 0,
    lastX = nil,
    lastY = nil
}

function GemNumber.worldName()
    return tostring(safe(GetWorldName) or safe(getCurrentWorldName) or "")
end

function GemNumber.objectList()
    local list = safe(getObjectList)
    if type(list) == "table" then return list end
    return {}
end

function GemNumber.bigNumber(amount, x, y)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end

    pcall(function()
        sendPacketRaw(true, {
            type = 17,
            netid = 0,
            secnetid = 0,
            state = 0,
            value = 0,
            x = tonumber(x) or 0,
            y = tonumber(y) or 0,
            xspeed = 1,
            yspeed = GemNumber.EFFECT,
            px = 0,
            py = 0,
            time = amount
        })
    end)
end

function GemNumber.localPixelPos()
    local p = localPlayer()
    if type(p) ~= "table" then return 0, 0 end
    return tonumber(p.posX or p.pos_x or 0) or 0, tonumber(p.posY or p.pos_y or 0) or 0
end

function GemNumber.worldAmount()
    local now = {}
    local total = 0
    local bestX, bestY, bestDelta = nil, nil, 0

    for _, obj in pairs(GemNumber.objectList()) do
        if tonumber(obj.itemid) == GEM_ID then
            local id = tostring(obj.id or "")
            local amount = math.max(0, math.floor(tonumber(obj.amount) or 0))
            local pos = obj.pos or {}
            local x = tonumber(pos.x) or 0
            local y = tonumber(pos.y) or 0
            total = total + amount
            now[id] = {amount = amount, x = x, y = y}

            local old = GemNumber.seen[id]
            local delta = old and (amount - (tonumber(old.amount) or 0)) or amount
            if delta > bestDelta then
                bestDelta = delta
                bestX, bestY = x, y
            end
        end
    end

    GemNumber.seen = now
    if bestX ~= nil and bestY ~= nil then
        GemNumber.lastX, GemNumber.lastY = bestX, bestY
    end
    return total
end

function GemNumber.sampleSpawn()
    local current = GemNumber.worldAmount()
    local previous = tonumber(GemNumber.lastWorldAmount) or 0
    local gain = current - previous

    GemNumber.lastWorldAmount = current

    if gain > 0 then
        GemNumber.eventGain = GemNumber.eventGain + gain
        return gain
    end
    return 0
end

function GemNumber.resetWorld()
    GemNumber.seen = {}
    GemNumber.eventGain = 0
    GemNumber.lastX, GemNumber.lastY = GemNumber.localPixelPos()
    GemNumber.lastWorldAmount = GemNumber.worldAmount()
end

function GemNumber.trigger()
    GemNumber.lastEvent = ms()
    if GemNumber.eventBusy then return end

    GemNumber.eventBusy = true
    GemNumber.eventGain = 0

    runThread(function()
        sleep(10)

        while ms() - GemNumber.lastEvent < GemNumber.QUIET_MS do
            local w = GemNumber.worldName()
            if w ~= GemNumber.lastWorld then
                GemNumber.lastWorld = w
                sleep(300)
                GemNumber.resetWorld()
                GemNumber.eventBusy = false
                return
            end

            GemNumber.sampleSpawn()
            sleep(GemNumber.SAMPLE_MS)
        end

        GemNumber.sampleSpawn()

        if GemNumber.eventGain > 0 then
            local x, y = GemNumber.lastX, GemNumber.lastY
            if x == nil or y == nil then x, y = GemNumber.localPixelPos() end
            GemNumber.bigNumber(GemNumber.eventGain, (tonumber(x) or 0) + 16, (tonumber(y) or 0) + 16)
        end

        GemNumber.eventBusy = false
    end)
end

function GemNumber.start()
    GemNumber.lastWorld = GemNumber.worldName()
    GemNumber.resetWorld()
end


function GemNumber.punch(pkt)
    if type(pkt)~="table" then return false end
    if tonumber(pkt.type)~=0 then return false end
    local state=tonumber(pkt.state) or 0
    if state~=2592 and state~=2608 then return false end

    local tx=tonumber(pkt.int_x or pkt.px)
    local ty=tonumber(pkt.int_y or pkt.py)
    if tx==nil or ty==nil then return false end
    tx,ty=math.floor(tx),math.floor(ty)

    local total=0
    for _,obj in pairs(GemNumber.objectList()) do
        -- Do not fall back to object id/id_: those are not item IDs.
        local itemid=tonumber(obj.itemid or obj.itemID)
        if itemid==GEM_ID then
            local amount=math.max(0,math.floor(tonumber(obj.amount or obj.count) or 0))
            local pos=obj.pos or {}
            local x=tonumber(pos.x or obj.posX or obj.x)
            local y=tonumber(pos.y or obj.posY or obj.y)
            if amount>0 and x and y then
                local ox=math.floor((x+10)/32)
                local oy=math.floor((y+10)/32)
                if ox==tx and oy==ty then
                    total=total+amount
                end
            end
        end
    end

    if total>0 then
        GemNumber.bigNumber(total,tx*32+16,ty*32+16)
    end
    return false
end


function JimiProxyExt.showCurrentGems()
    local groups={}

    for _,obj in pairs(GemNumber.objectList()) do
        -- Strict item identity. Object id/id_ must never be treated as item id.
        local itemid=tonumber(obj.itemid or obj.itemID)
        if itemid==GEM_ID then
            local amount=math.max(0,math.floor(tonumber(obj.amount or obj.count) or 0))
            local pos=obj.pos or {}
            local x=tonumber(pos.x or obj.posX or obj.x)
            local y=tonumber(pos.y or obj.posY or obj.y)

            if amount>0 and x and y then
                local found=nil
                for _,g in ipairs(groups)do
                    if math.abs(g.cx-x)<=40 and math.abs(g.cy-y)<=40 then
                        found=g
                        break
                    end
                end

                if found then
                    local old=found.amount
                    local newTotal=old+amount
                    if newTotal>0 then
                        found.cx=((found.cx*old)+(x*amount))/newTotal
                        found.cy=((found.cy*old)+(y*amount))/newTotal
                    end
                    found.amount=newTotal
                else
                    groups[#groups+1]={amount=amount,cx=x,cy=y}
                end
            end
        end
    end

    if #groups==0 then
        say("`6No dropped Gems in this world.")
        return true
    end

    for _,g in ipairs(groups)do
        GemNumber.bigNumber(g.amount,g.cx,g.cy)
    end

    return true
end

JimiProxyExt.UI = (function()
    local banners = {
        halloween = {file="jimi18_halloween_wide_r10.rttex", url="https://hijimi.site/assets/jimiproxy/startup/banner-halloween-wide-v18.b64", b64=524776, raw=393580, version=10, prefs="jimi18_r10_rttex_assets", key="banner"},
        winter = {file="JimiProxy_winter.rttex", b64=756176, raw=567130, version=1},
        thanksgiving = {file="JimiProxy_thanksgiving.rttex", b64=731208, raw=548404, version=1},
        blackfriday = {file="JimiProxy_blackfriday.rttex", b64=817892, raw=613418, version=1}
    }
    local season = tostring(BANNER_SEASON):lower():match("^%s*(.-)%s*$")
    local banner = assert(banners[season], "Pilih banner: halloween, winter, thanksgiving, atau blackfriday.")
    local directory = jimiScriptLuaPath()
    local bannerPath = directory .. banner.file
    local bannerURL = banner.url or ("https://hijimi.site/assets/jimiproxy/banners/JimiProxy_" .. season .. ".b64")
    local atlasFile = "JimiProxy_tabs_settings_v1.rttex"
    local atlasPath = directory .. atlasFile
    local atlasData = [[UlRQQUNLAAB9XgAAfD4KAAEAAAAAAAAAAAAAAAAAAAB42uy9B1QVydqwe77/u/+6a/33fvd+a91zZnRmjhlFMSugooCiOOqYMIAJRRQkSRQUAyAKSM5IEBQJZjGAIIoKBgQxpzGnGR0nJ2d0Qt2/Crvp6t692b1j783baz1Ld9db1VW1efuhI06zZ7vMdvrHPwL+4x//aPyPf/zjP/7J+f8/WtF0Ydr7h+3/otb/c/h0BACA4bD0L0Zz9vxKyH2JAACQCVZesQAAyATYJwEA+BEAAPAjAMiZf1rOAADAgFj674TzqwAgQ/6rnx0AAAbkQxsX1G1qAOG/h0wGAMCAdLJbxOYj7J8AQEZ+HDoZAAADwvUjnN8CAPmcX/339FAAAAzIyHVVbD7C/gkA5OPHLjNCAQAwIKPWgx8BQJZ+nBkGAIAB4frxX1YzAQAwIJYBXD+uBgDAgIxafwz8CABy9KPTagAADMioDeBHAJCjH7s6rQEAwICAHwFApn6ctQYAAAMCfgQAufoxHAAAAzJqQ3WbH62djAqxxdjGAQAMlgElbX6cvdaoEFuMbRwAwDAqAvwIAOBH8CMAmKIf+/TpQwGeBEzBj93mrDMq2stHYxsPANhE1IAfAQD8CH4EgA7gxzdNRYQvC7wI4EvAKP04d71RITUfjW18QMfDJhL8CADgR/AjACj144hZRgmzMHnI8O3eGYQnISMIrCeNdJyA6WMZyPGj8wajRGo+Gus4AdPHJvI4+BEAZOjH7s4RRonUfDTWcQKmjy78aKiFn4d8wJOAUfnRJUIrGEs+amu8AKAtbKLAjwAgSz/Oi9QKRuNHLY0XALSFTVStzvw4alFPvcIsTN6BJwHwY6TR5SPslwHwI/gRAJT5scf8KK1gbPmorXEDgKaM3sjx48jZWoGfj3M2jNQrantSS+MHAHWxDCzl+HGjVjDWfNTW+AFAXUZvPAF+BD8CcvTjgo1awWj9qKXxA4C6cP34wcjZWsHQ+ahpXmprHgBAKlaUH6O1grHno7bmAQCkAn4EPwIy9ePCaK1g9H7U0jwAgFRGR2vfj8bqyfQdNQTwJCAHP/ZcuEmrGHs+ans+AKA9RkefBD+CHwE5+nHRJq1i9H7U8nwAQHtQfhw1RycY6v5yVe83Z/Lw1zmLKFhP6mheAICPVRDXj5t1grHno67mBQD4gB/Bj4BM/egaoxOM3o86mhcA4DN6U53e/Hj2QK4sYJblwekUTB6+iYolgCcBQ/qxl2uMTjCVfNTV/AAAwxjwI/gRkKcfF8fqBJPxo47mBwAYdOlHfh7+dLtWVjALPw/5gB8BU/CjqeUj7L8BvfrRZq5WMTk/anl+AICPVVBZmx+XxGkVk/OjlucHAPiM2Xyqw/qRf34H/AjIyo9uW7SKqeWjtucHAPiAHw3jx8FOPmic2xo00WMDsnUNRd0nLAY/qEk3B1c0bM5K5OAeTuZz5Pwg9LH9fKP3o5nbFq1iavmozbkZH5aHXGJK0eKEXWh2dDEa6p2q9fnvKAz2SkETwwvQ/NgyMp/TIopQf48koxwL+DFX5b/3qul8WEz1RBFb96C6qw/RlcdfU7Q8fI12nWhGbuvTUacxLmyd1F01VNxnPlGCdid7RVIxx1vuoY/tWv0QlLRdsC0xFq9LY9scOstXQR+/QvU3n6Lalvtod10Lit1+GM0LTWK3pYj8Q2eoNvDvBGKxiSWVVOyMlZtFYyetiEBRefvQ0cZbCsfSfP8lSt99nPweYrR+XBqvVUwtHzWdD9uQHLS99hJ6/cMvgrb/+vtvdO3Rl2j9jhpkviyBrVPZdJeKW5a6T9Cue/JeKubldz8hC+yHpfEoveKsyuNbu72abXPCmnxB+Z9//Y1++PU39Oq7n9GNxy/R3obraFV+JbstRZy58YhqwyW2TDS24vwtKtYr46BorFvSHlRy8jJ6/Oo7hWN598ef6FjzXTR+db7Wf651yZiY0+BHPfjRKSAGnbv9XCVP9ZiwRJIfS2uaqJjlkdlsmTb9KEbd1Udoqs9GvfqxsvG2Sn2rv/GEjAX8CH7k4pNZgX5+81al7QzzTZPkx5b7L6iYqJITbJk2/Si2fP3jL8gjbb9e/fjkq+9U6tsPv/xGxgJ+ND4/6mqfh4/v8LEXd7/dePcLtPXAKbSp4ACKLz6C9p+5ii4/ei3Zj44e66nyk1ceUOcW9eFHDO47PvbVtx/xdg+fvYFSy6rJXKaUHUP11x9T7WTsqTVOP7onaBVjy0dtj5/BPWUfOfbiLm/evkOnrj1EZaeuogPnbqI7z16jv9+HDPNLZ+sK/bifats1cTdVjo9N+69IYcvTD51T3Y87ath6E8ILkJQF93198XHB2AV+jCsTnaeKCzw/Zh4UjX3y1ffsdh98+Q06evEOmcsjF++g739+Q7VT03JPZ9+ttqH8ONpZqxidH7U8fkwXh0Xk+Iq7vy482oD6TFkmiB3uHIAy955APRzd2HUCP/pupOoUV1+gyj03baXKg5J2UOU+Mfkq9XvobD+q3p5Tl8n6D8e4kPPE88KS0OHzN+lzmg9eIWuXQKqd/EP1tB+XhotuM7GU50f/GNFYfH53Q84ect2RX9br06Xo1LU2R17437+LdLJ10cn3q22sgrl+TNQqxufHRK0z0DsNff3jr9T++tytJ2hkYLYgdtL6InKtYphfBrtOsR/b6jR9/pwq37zrFFXO9+OWvWdU6veE8G1UvZtPXpH1vZclojEhuWhVQRV69PJbKuaPP/9CUyK2U+2cufGY58dy0W1WXLjN82OFaOyNx69Q0fFLyHFtoaDMyj8LffNT25y/+f0d6rMsSSffr7YZE3MG/KhDPy6LyqL2+dXNn6OuDq4q11fmR6fAWKoMXxf8t8MinfqR737sKW4c7q8+/PgRvuappP+7TjZTbfX8dKnR+RHv+7SJseWjtsePiSo9Qe3zX3zzIxrsk6Zy/apm2o/L0/azZX7Zh6iyV9//jAZ5023z/Ri/94xK23Vcy/Pj01eCmEE+acRT3AX3lxtTz/PjvLhy0W0e4vnRO6tCNLafZ7LS/l979JJqy9I/Uyffr7axjQU/6tKPWw+epvbT3jF5kurz/eixMRvZua1By6Oy0fm7L6iyOSFbBPV16UcM7gs3DvfpI/sFOvejGANmeKGwtFL2XDVzX9HHYxcYoR+TtIrx+TFJ6+BzqPzjNyn1q5o/p+pvKq9DzrFlKLqsDv36+zuqLCD3qKB++qHzCvzY/nbxcRntx68UxuG+cBfcJ4sVqWy50I+7RLcp9OMhyfM9Niwf5VQ2sueqmfuKBnil6eT71TZcP36Iz59pEXbp8n9SyDUftT1+TNXFu9Q+327Jakn103h+FLtX02/LNoX1g3l+3F55Dq3JKBPgHpFJ1RvG8+PeU5cVto/vteVf7xs+158t5/vRYWm46Fj5fpzpH9Pu/OBnO2YHxZFrl/y5ZiiubtTJd6sLKD8uT9IqxpaP2h4/5tnrH6h9/tzYMkn1+X4Uu1czcX+Dwvrph2k/Nt59hvKONQmIKDlB1XNcp8CPCtrv45GEvv/lNyp20oYitrz+Js+PW3aJjlWhH9uZn8G+6Wjl1iPk2iV/rpml+d4LnXy3ugD8qFs/Ntx8Su2rh8zy1bof99S1IAf3tSr5UYySmotq+RFzsOGaqAN16cd5YYmC+eXTcOspslkYYqR+TNYqxufHZK3z46+0OyasLZRUXxU/3njyCi2I362wPt+PYkvL/S+oeo7rihT4UXEf7734mufAtr4I/bhbtB3FfhSfm+CCKsH88pcff/0dzYwu0cl3qwtsY+u17ke556E+/Yiv73P31/jZdU38iJ/pw8d7+Nm/IxduUecQ5wRvMYgf8TVVbuyoBcE696NLaILS8Zy4/ABF5+9H/ad7GY0b+X7s45GsFYw1H7U1fi5ffvcTtb+evnGnpPp8Px679DnKq25CO+uuUM/+4XOIAXlHBfUzVPXjgy+oehPX03689fQr0T7ia6rcZUZ02xj5fpwfv1u0nUONtB99sg+JxmI3Klu++v5nVHrqKrJfna+T71VX2MZx/DjGRSsYrR+1NH4upcfpZxMXrEmRVD9t93HB/TlMWbfxi9FpzrlNfH/OR3YLqPrBybQf8yrOkHOxfOaHJVH18H2hAj8q6F/fqR68a32vyb0wTLnAj+7homNNLK2i/RgQIxpbXkvP65kbT8g5VveoLHK82Ml2nk6+T11jFVzO8WOKVjBeP6ZoncsPvqT222GF1ZLq8/3okX6QLRvil4m+/ekNdX9OvxVpVP2Mwxeo+qdvPCLnYvms2naMqjdx/XYFfhT2b/SqPOpaH37PgWVANluu2I+Kx3qo8Q7Pj4dFY68+pOf1u5/fkPtfo8rq0MzoUmTumaKT71PXaNOPYnloLPcD6GJ/tyqthL4WVtMoad+tzI+YnTUXqfLBs3yU+tEntkCl7arqx+j8A1Qc9ha3XFd+PHv7WVvfTl9BXca7GqUPlfrRM1UjjD0fNR2/IrIrL9LXwu6/QOYrVK9fdeke7ceMCqr80v0vqPLxa4uo8owjtB/j9zeotN2JG3YI/aggrvT0NSru6qOXVHn9zSe0HxP2iG5T4MecI6KxP735va1vz16jQX6ZOvn+9I1tXAP4UYd+HOTkQ+6f4e73V6XuVBjb2W4ecl2Xirpy9vXK/NjdcQk5buKWW7sE6cWPvSa5o4jcvYLzmrPxOV49+PHcnbZ3EeUcqBONG+Mahj4ZtxD8CH4kOKwtJPfPcJesoxcVxvZdkYbCd9SiwSuzVPLjMP9sctzEXT6L2qkXP1oFbUU7Tl4RnNf0z6vUix9/+a3tXUQnrz0UjZsdW44G+maAH5Xko1zO7+jDj+QYMnWnwCP4vCs+Fzh95SY0d1UCWpNRiqoa77Q+qzfRTdSPzPXHmKJDgut+Fz//UnAcxffjgfprpA1FWExfIepHfB8MjsnadxKVn2hGTTznY3Bf+cfGYn70TygUbL+GNx48R/yYiZ4bSP2iynPUu3vith9BLqGJaPrKzWh5VA7asHUvO59mk9yN04/43JwGGHs+ajp+MbJ4x5B4ufzwSxRVfgqtyD6MggqOodzqZvT0/f2XloFb2bp8Px5ruYfyai6h3Q03BNf9fnv3BxqE3crZdsaRRirm7ouvSRuKsF29ja3H9yO+zwXH1F59QI4R3/KcT559vHQPmXvRYxf4MXEvWZ9ccV6w/S++/UkwR/yYxSn7Sf0Ld59T7+7Zd+4WCt5Wjbyyj6CNu06j7SevsPM5IiRPZ9+ttrHdAn7UtR/xcSF+l7eq72pT5kdlYMfyt833ozLw+3vE/NgecdsPKzxOE/Mjf72Ud+Dh+p+uiCTXOlWpY6x+NF+RphHGno+ajl+Mfl7paO/Zmyq/qw37kanL96OyJa+6WbBtvh+VLVMid7L1PuX5sb1l39mb5Bwnf/t8Py5I3KtwvarLup0nSH231APkWqcqy8iQPJ19t9rGzoB+NPT9AvryIwO+B6byovh7tfH+fuvBU+iTsQsl+RHfq4nPm2IP69OPDbeekffhMcd0itCVHzH4uLu95zvwdUru/UJG5UevdI0w9nzUdPztEVpUwx7TKFrw/v7U9cdooF8WW0cVP371wy8o4cBZ1M87Q7DNjKMS/BhVwtb7NKK43Xh8DbD2ygO0JPWA6Jjrb/H9uE/hepX9WHKSbTtoWzU5rlXex7fIKjhX59+ttrDbcrbNj/jcmAYYvR81HL8qdLZfgGyXrEYe0VvRmsxyFL3tILmHxzk0EZl/5iGIx++nwdf0+ODziGMWhyGL6V6ok9180e1ZzgtUWF8R3fFx6/t6+Nomv/wzv2hy3GazOBT1n+Gt0ngdlq2j2jCbvEzhelUZhO8/4rTfZcJiNCsoDq1KLUHRBQfInHrH5qO5oQlo2Fx/pXMjR6xCOH7E+1cNMHo/ajh+VbDwzURz4/egzXvqUX5NCyqrv4GyjzWh4MIaZBO2TRDvnLAXBRQcE+CVcxTN2bIb2YUXor4+4tubEl2qsL4ihgflsvWGBeUKyj2yDiO39Ao0K243sl9bpNJ4FyTvp9oYGZqvcL2qjF+/g2p/cEAO8surQtlVTajszHUyp1v2nyXu/DRyp9K5kSN28br3o6poml/qbpdFj54EAEP50djy0Zj2p4BpAX4EPwIy9aNPpkaYjB81nAcAUBe7+HNG70eN8xA8CcjQj319MjXC1PJR0/kAAKmAH8GPgEz96JulESbnRw3nAwCkYpfA8SO+l0EDNM1H2cD4UcP5AACpWIXs4vgxWyNMLR81nQ8AkIpdwnnwI/gRkKMf/bI1wuT8qOF8AIBUwI/gR0Cefuznl6MRppaPms4HAEjFHvwIfgTk6ceVORphcn7UcD4AQCr2iW1+xM9Sa4Kx5eOf3v+g4OejpvMBAFKxpvy4VSNMLR81nQ8AkIp94gXwI/gRkKMf/bdqhMn5UcP5AACpUH60X6ARJudHDecDAKRivYrrx1yNMD0/5gKAXgE/gh8BefrRIiBPI0wtHzWdDwCQin1SI/gR/AiAH8GPAAB+BD8CxuHHwHyNMDk/ajgfACAVbfpRVU/y80BbaPt+cthfAwb1Y1C+VjCVfNTWfACAqtgngx/Bj4Ac/dg/qEArmEo+ams+AEBVxiZfbPPj2IVaxdDndyTnL+NFLc8DAKiK9ardbX4M3qZVjDUftT0PAKAq4EfwIwB+BD8CgH79KPCkvhaJ523Ai4As/RhSqBOMJR91NX4AUJWxKU3gR/AjAH4EPwKAAfyob1RdYH8MyNmPA1YVmQSqLqYyXsB0AD8CAPgR/AgA7fhx3CIAAAyIdSjHj6HbAQAwIGNTm8GPACBLP+4AAMCAgB8BQKZ+DNsBAIABAT8CgDz9ODCsGAAAAzIu9RL4EQDk6MfVxQAAGJBxaW1+7OzgCgCAAbEO3cPx404AAAwI+BEAZOrHNSUAABiQcWkt4EcAkKEfB4WXAABgQMali/vRcnE4AAB6QujHUoqJiZUAAOgJnHPgRwCQqR/XllJMTKoEAEBP4JxT5kcAAAx4fnVtGQAABmRc+mU2H63D9gAAYEAc066w+Tgu4zIAAAbks6KnbD4CAAAAAAAAAAAAgCpY+hcDAGBAJiS2PY8c1vgOAACZYOUVCwCATMh9iQAAkAmwTwIA8CMAAEL+aTkDAAADYum/kz2/CvskAJAP/9XPDgAAA/KhjQvqNjWA8N9DJgMAYEA62S1i8xH2TwAgIz8OnQwAgAHh+hHObwGAfM6v/nt6KAAABmTkuio2H2H/BADy8WOXGaEAABiQUevBjwAgSz/ODAMAwIBw/fgvq5kAABgQywCuH1cDAGBARq0/Bn4EADn60Wk1AAAGZNQG8CMAyNGPXZ3WAABgQMCPACBTP85aAwCAAQE/AoBc/RgOAIABGbWhus2P1k46odOwSYRPBowifDzIjtBp6ESCrrYLAMaGZUBJmx9nr9UJ3SZ7EbrbTG3Ffi6h2yRPgq62CwDGxqgI8CMAgB/BjwCgUz++P0fE+K/zkPGED4dNInQ1H0To1asXRY9evQkfDbIjwH4SAD/+irrNWacZ2IWz16LuY11acXQjdJviQ+gxeBRBkI+9+xK6j51H0LgfAGCk2ETUgB8BAPwIfgQAXfrxPR8PHEPg5x1Dnz59CGLljF9hfwl0aD/OXa8VmPOn6uZjj7EuBG31BwCMBZtI8CMAgB/BjwCg1I8jZmmVLuZDCEyeBQYGEhYtWkTo378/gZ+PzHlYbfcHAOSOZSDHj84btEr3obYEqfnYY9BIgrb7AwByxybyOPgRAGTox+7OEdpFQz9qvT8AIHO04ccPh08msOeJ3q//wHoGoWeffoTxExwJd+/eJVy/fp2wZMkSApuPZuYE2F8CHdqPLhHqMW1lK/iYEcOsnxNOMLMYRJjg6EhoLx97mvcnqN0fADBSbKLAjwAgSz/Oi1SP6StbcdnQCrN+bjjBzGIwYYLjRILKflS3PwBgpNhE1Ur240eD7FsZ4tDK+8/d+gwgfGA5lcDEdxo+idCrlxkhODiYcO/ePcKVK1cIbX7sTYD9JQB+VAGHBYQeE5cQmM89B1oRujuFtMLET/Mj9DIzI7SXjz379CXA/hIAP4IfAUAOfuwxP0o1xi9sZaJbK+8/M37sMWtVK0z89JUEqX5UuT8AYCKM3sjx48jZKsE898/kT7d+Qwn85/07D51AYHKfOW/KxNXV1RGYvBwxYgShO342uXdflfsDAKaCZWApx48bVeNTdwJ7T80wu1YYv/XuS+gxaXkr8yIJzHnT9vKxZ7+BBJX7AwAmwuiNJ8CPACBHPy7YqBp8Pw63a4Xvx8nLW5kfSejZtz9BZT+q2h8AMBG4fvxg5GyV6Gw5mcC/D9zc3JwguD/crA+B+ZyQkEBg8pDB0tKS0L23BUHV/gCAqWBF+TFaNWYEEFTNR+Z+OVXzsUf/oa2o2h8AMBHAjwAgUz8ujFaNmQEEnftR1f4AgIkwOlq6Hz+0nk5g8iskJIRgbW1NEHtflVgeXrp0icCP79J3GOED/KwIBvafQAfyY8+Fm1TDeS1B1/nYw9KB0HPBxlZU7R8AGCmjo0+CHwFAjn5ctEk1XNYSdO5HKwdCz4UbW1G1fwBgpFB+HDVHEr169yGEhYURmLxydnYmtJeHDCUlJQSx9yN37TeU8MEIp1Yk9hMAjAWrIK4fN0vCzLwfQdf52HO4PYG9z0diPwHAWAA/AoBM/egaIwm9+dHSntBjQRRBaj8BwFgYvalObT92tRhOsLEZTWDeU8XkWUVFBUEsDxmYej4+PgQmD83MzAjscyTmgwgfjnQiwP4UMGU/9nKNkYb1eILN6NEEXedjzyGjCL3mR7Yitb8AIHPGgB8BQJ5+XBwrDUP5cUFUK1L7CwAyRxM/fjR0PIF/XwDznmN+3jU1NRHay9Pw8HAC027v3r0JzOfufSwIH46YQYD9KgB+jEU9p3gQ9J2PvQYMa2XehlZgvwqYoh9t5krio2ETCAbz48iZBKn9BgC5YhVU1ubHJXGS6PmZJ8Fgfpwf0YrEfgOAXBmz+ZTafmToMmAEgZ8/o0aNIgwbPpyg6v3lDEy5WF72wO/M6t0XdbKeRoD9K2BSfnTboh6jP2tFNB8tCdrOx54Wg1txXkNQu/8AIBPAj/qj85h5qO9ny5HNwhA00WMDcli6BllM9QQvaIHBTj5onNsaMq9j3Vaj/tO90IejnVWq23uSO7J2CUCOHuvRhOXr0NBZvqjTGGeD+9HMbYtaGNqPvbAbndeo3X99Ye6egGwCs9DMqB1occIuNC+2FI0JypZ9v42B8WF5yCWmlMyrc0wJsgvJQb2XqlZ3hH8GmrK+ELkm7EKLtpSjCWvyUZ+l8QYZhzb8yFw7+XioA6FLfytCt35DCMznTwbbEbr0HUpQNS8LCgoITD7yn3dm3nve2eozgpz2230mu6MVm7ai/ENnUOPdL9CVx18LqGq8g5ZFZincJ5+/+0JhHT4Nt56K9mFOyBYqNrbokMr9X51RStXF/RSLXRm/jYrFn7nlqeXVVDmeG34bcUWHBGPrPmGxwu3h3y0itu5FdVcfKpyTc7efo8y9tch5VQL6yG4+W+9ju/lo4ZpklFpWjc7ceKKwbv2NJyg8swx1c3A1nB/xPkEd3OIIvSYva8VmUivDbVthPjsuJPSwHEfQVj4y7z03m7OqFXXHoQNGBmShmF116MyNR+jN23dI0fL0q+9RZEkt6uOeIKj/6+9vkSrLj7/+LtqHgK2Hqdg9Z66p3P/cqkaqLu6nWGzS/noqFn/mlldevEOV47nht7Gn/rpgbEN90hRuzzYkB+2obUGvf/hF4Zz8/OYtOt5yDwXlHkH9PJLYehYeSShsWxU6evEO+u7nNwrr/vDLbyj/2EU02DtVrz8vY2JOgx91yLzQRJX8honK29eh/Thszkp06cErlfzoFBiDzt15rvLcYhcydQfO8FK5XvmJZsqt4Efj9mNI/lGk6lJy8nKH9uPEtQXoz7/+UsmPvlkV6Jff3qo8t9iFTN2xobkq17v68EvKrUbhRzV9yjwfompelpeXEywsLAgCT/YyIzDvT5ebH/HxTOHRBnKMtLnwICqtaUKXH71my/H/8Xm+jurH9N3HFY6N78fPfKJQy8OvqJimey9RweF6tKngABkfnltuecaeWoV+bLr/EpXXNqH44iOkbu7B06j5/kuqrtuGDMP4ER+/6AN83mvpFtRrxIRWtJSPPc36EHrNDibobTxKCMmvpI5nzt16Qo6Rdp25hloefIH+/rttX4z//1nEdqr+r7+/U92PIn0IyD1C+7H+usr9z626yPPjCdHYpAM8Px6op8orm3h+DMyiyo9d+lzh2Ib6plNxy1L3oz//+puK+f3dH6jh5mNUduoqGR+eW+5S03KPrT82LI9d//aPP9GVh1+iA+dukrqnrz9E7/74k6q7Yedxvf28UH7E12v0wft9Qdf+wwla96PVFILexqOEeaFJqKTmInIOTUAf2y8QlAckFlH7Yr+4Aqqc70d1+jAnJJ724/ZDKtddnVFG+zEqSzRWoR855anlNbQfpyxjy0a7hlK/K9B+XMLGdXVwRaeuPabK8e8c5p8tp7bVbcJioR/flw2c6Y0qG28jr5g81PPTpYJxOHpuoOrm7K/T28+LVTDXj4n64f3vyr1GOLaidT+GEPQ2HiVgP7bcf4GC8iqRhWeKoDz14FlqX5ywr54q5/tRnT4E5B5V4EfV6ir2o+LYpAMNPD82UOWVTXd5fsxmy5yiS6jfFWg/ZrBxg7zT0Dc//UqV4985RgXlUNsa4puuwI+tZWPD8tGTr75HsbtPo+ErMwXjcE3cQ9U9ceWB3n5exsSc0b8fNfQkcz/68OHDCYL7BN7z0TBHgiH9SM7NKSmf4hNF7Ysjcvd1SD9uO9LArm95+FrUj8ujsulrtxfvoi4OiwR9UebHTrbzUCdbF9Fx8OvuqWsxiB97L0vUL+7xhF4jHVvRWj6aEcymeRH0Pi4O/TyTlZbjYyHusuNEC1XO96M6fQhU4EdV6+Ydo/0YVXpCNDaZ50f8mVvO9+OooGy27OytJ+z6v3iiHOaXwcZFl52kyp69/gEN8kkT9GWon9CPTFlfjyRkvjxJdBz8ujefvNLbz4ttLPjREOBjSezGiobr1L44LK20w/mRe7yGjw3zD9eL+jGv4gxVhu994m6jh6MbGuTkjaznBYr6UQzszNGLVqGtB09RdXdUnTeQH5P0i3sCQXd+9CbofVwq0H9FKlqWegDd++Ibal+cU9lIxQn9KH1biv2oWt28Y008P54UjU0+cJbnx7NUudCPOWT94qS97Dp8bIjPk9J+zGTbwPc5cZeY3aepbeDjQYc1BWhqZLECPyofq/nyZOS0qQTVXXtI1b1495nefi64fsT3wxsEm7kEqZ6sq6sjMH/HR8yTnwwdRzDY+N5j7RKIAhOL0M7qC6L3sk703EDV4ftxTUaZQqxcAkS3O1eBH1Xt8xoFfhSL9ef5EX/mlvP9aD5lGeo0xgXtOtnMrvPYmE1cxo3rMWEJ20Z18+dUma1rmNI+cP2oqM8W0zyRe2QWcWL99ccK6+LvTF8/I5Qf8e/UhmBZAkGqJ9vPx/eenLyUYLDxvWdK5A6UWnEONd17jt68/UPhuUTsCm4dvh+xrxQxJWK76HYD83h+bLiucp8Ffiw7KRqbzDtXjD9zywV+DM5BfTyS0LVHL9l1m8rrUHXLPdqPKzPZNl588yNVNjumVGkfKD8q6POYVbkosvQEceL3v/ymsC7+zvT1MwJ+1D3mU5ajnAN17d5jk7DzqKCuqvfnzPSPMUo/zgqMZT9j931iv0CpH8/efkaVDXbyVsuPeDtrs8oF53L57D19hdwfZBg/JhuG9+eWdOdHd4KhxjcqOBedvPqw3XtsDp6/Jair6v053lmHRLcfmFfJ8+MNlfuu2I+KYxX7sa1c6MetyDen7d5a7L7+XmkK/JjFtvHTm9+pMofwbUr70ObH+1Qc3k5+dbPgXC5/ufX0KzQUH7/q6WfFNrbe8H7U0JPMe7Ls7e0J/PcoM3wy2JbA395HlpMIHw8b38rwCYROI2cSNBkTftaOfw6VC36eAZ+/mx+aRI6lOpIf+031QIfP3WA/L1iTQuKU+bG25T5VNsIlkNqGvdsaco8TH6cAen7ii48qnc8D9deQ35Zt5NqmPnOA68c+HsmGZXkiwWykI0Hb+WjmuJDA317v2UEEs6kehN7TvVtx3UjQZEwWXqnoPu8cKnfBzzNc/Pw5WrXtGDL3FNZX1Y8+2YdE+xCUL/Sjqv3Pq6b9uLHspGisIj9yyyubaT+OCc1DD778lv0cVlRN4mp4fhzun8W28er7n6myqVHF1Dac48pR4v4GAdjD3Dh8v6qy5e7zr8n9RYN80/WaA7ZxHD/i/bMheb+P6NrfkqB1Pw6xI/C395HVZEKbHx0JnUY5ETQZ0xTvSGq/i+/RLKttQqGpJWiGfwy5f1JZfb4f8T5bEUNn+4m2MXdVAs+Ph1Xuv9CP2aKx/gmFtB8TCqny1F01vLG0xePfITrbzSdxGXtO0H50dGPbwHPHLZu/Olnyd9LdcYnguPHIhVsoMncfmh+WhPrP8DZYDlgFl3P8mGJYlicRzEZOJOjOj/T22vzoSWjzYzRBkzG5px2g9rv4cAU/T5BTeRF5Zx1GlgHZSuvz/aho349xXFck2kZQfpUCP6rW/7zqZp4f60Rjkw+e4/nxHFVe2fw57/7WNp/i3yH6rUglcfhYj/Zj2xzhueMuoYXVkr8TfDzKP258/Oo7VHzyCvk9xX51gcFyQFZ+bMeTzPuWxfLyypUrhGnTphHE/r5rt76DCT3M+hBE/w4sc352yFiCOmPx2pxL7Yexq6TU5/tRnT7I1Y8NN5+y/8e/KzBxyvyI71/ilhXXNJL7UaXMh+3iMN57GfZLbkMvfvRMlQfvf5c2GzWRoO187DXMltDT3IIgno/vz89OWkJQZyyxe85Q+2HsKin1+X5Upw8K/ahiXYEfy0+JxiZX8PxYcY4q5/sRP7PJnh/OPszG1Vzm+TEghy3bWkUfzzbff4HMV0ibjzmxu6g2dtZdldyGrrCNawA/6tCP3jF51L4Yv3tVUVzPiW5oxLzADuVH9h01tU1UnDI/Dp7lg5p579hZm70LdbZT7LdPxi1E7lFZqPfkZew6uyWrqfrLo3IU1v147EISC340HT/G7aWfmZ+5qVRhnGVgDpq6saRD+ZF9R82jl1ScMj+OX1uE/viTfsfOtuMtqO+KNIV9GuibgaLK6tDIkFx23dy4XSqNqb9PBont8H7U0JPM3/OZP38+QXBe5/35HsHf6RH5O7A9zHoTOtnMIUgZg4P7WmpfXHnxNnkmAR8v4XODgQlFKHv/SfIel6j8fe36Eb9jRhH4XCU5n+sTJSgr552TPNZ0VxDjE1uAlkZkCtYfOX9TcL8KP2ZWUJxGfpzgsV5lP2JWpZWIXi90CoxFMwNiyD2piaVV7P083HOmXce7kvftMHVxTEhKMZoVFItmB29BPjH55PokPr7F4zWYH/E+Rk54phCkelLb+dizTz9Cn2XxrUgYw4LEvfS7Vl9/j2L2nEHeOUdQaFENSj10Hp24+pC8x6Xk1FVBfb4fj7XcU0gSPpe5Ig0ty6gQlF3l3B+Kl+df/yiIid/fgCLK6gTrH778jr5f5dlrQczKvEqy7eSK8zw/nqfGIubHRcn7qTiBHwNzqPJs3jEkuV744muUeOAs8t16FPnkHEWRZXXo0MU76Kc3re+gsw8vZOsP9s9Gv79re0cOjsk8ehH55VYi/7wqtGV/Azpw/jY5vsXj1efPvO0W8KMu/YjP2+HnOVR6/6oKfhQDP5+A4/GxkKrvFuWSte8kitt+WK26wck71PYjftaRP+b2/IjndFNhhaQ+8q8pruG9N0/Z/auG8qP5ijR54ZlCkIsfzZfFtyJhDH290lDzvReqvX/11FVBfVXvzzl1/RGJj951GqmznLj6AO07e1OtuhlHGsm2U3h+xJ+5Y6lS4MeGW08EY+b7ER9b8+d0V/0NSX0cG15ItcE/LhZbbj97rdefeTs5+1FDT969e5fg4eFBYOoNGTKE4OPjQ4iIiCAwfwfW0dGRILy/R73zrL0muZP3eirbD+P7RfBxUUfyI75XyWbRKsl+ZMDHegfPXlPaN3wuFh+f43tyuHXxvUDrsncL3uPKp+joWcP50StdnqxIJZiN+pRgqHzsPdmNILX/I0Ly0Okbj5Xuh/H9Ivi4iF9XdT8+JvHRu9X140O079wt9fx4tJFsO+UQz4+HzlNjqbp0T3CvklNMuWDMNZcf0H4M2qpwXgPyqwTvV+Av+FzsiWsP0fBAug0LnwxUWHtZ8B5X/nLh7jO9/qzbbTnb5kd8j4IcYc6LGdqPQ8cS1B3HiPlByHPTVrJfxveEBCXtIOcBJ3hsQN0nuims4xQYRzzQHvg8Lo4fMttPpXg+Y93D0WjXMLXqWuLrprbz0HCXQGo9/swdi53bGqocnwtWNGb7peFUHL4OKDannezmoxELgsk8hqWXoehtB9HarF3IOzaftN8NPxui5DvpN30Fcl2XRq6z4rqrUkvIdzRt5SZkPtVT7z/rViEcP3pnyJP/fbyAMbP5lGAwP05ZSlB3HNM2laGYvfWo8MRltPPUNZR+tBFFlZ9CrikH0PCgXIV1fHMrUUDBsXZZkLSPxDtGFKsUz2de4j40O263WnWnRJeSbU/ZWEKv31hCjcU5YS9VvizjkMIxu/Di+vtlic5pX58MNH1zGZnHrdXNqKz+BiqobUFb9p8l7Q/FXlTyndiuKURrd55EeTWXSF38Owr+jlZkH0GjV2/T+8+6XbwR+FFDTzIcOXKEwOSpWNytW7cIzPuymPcudx1gTZD9PAFGi1H4UUNPaisfzcZMJch+ngCjBfwIfgRk6kefTHnjnU4wmB9tpxJkP0+A0WIXf854/KglT/IpLi4m8Nczz0Ez7Xc1H0iA/TigDz/29ck0DrzTCep6Ut187DnUhmA08wQYHeBH8CMgUz/6ZhkHPq3XnQzmR2OZJ8DosEvg+BG/38uYeL9P6TrAkiA1L5k4sXpnzpwhCPxobPMEGA1WIbs4fsw2Lt7/zm1mM4mg63zsOXQ0wejmCTAa7BLOgx/Bj4Ac/eiXbVz4ZhL07kdjmyfAaDBqP/I9aTGUwOQP83db28vD7n36Efh5ydwXwMb1HUSA/TigDz/288sxTnyzCGbWDgSp+dhrwLBW2slHs2GjCUY7T4DssQc/gh8BefpxZY5x4pdFMBvhQNC5H411ngDZY5/Y5kf8rLUx06PfYIKtrS2hvTzsajGMgN9Xhuk2wJLAlHt5eRGYz/8eOpZg7PMEyBdryo9bjZrew8cQbG3tCO16Eb+zbtRE1M8vm9B79CSCWD72+WwpwdjnCZAv9okXwI/gR0COfvTfatSo7ceV2QSV/Wjk8wTIF8qP9guMGrG/31pSUkLgv5+K+ftWnUbPbuX9PqrbACsCP/5j68kEY58nQL5Yr+L6MdeokZqPzN+36uuRSGDOcfUePZnAjzd3CSUY+zwB8gX8CH4E5OlHi4A8o0ZtP3omEdjjUDE/zgsjGPs8AfLFPqnR6P3YefRsApM3GRkZBP75HGdnZwL/7+h07zeYwD/XxffkR6NmEGA/DoAfxennkUBQNx/NLO0IgvO1PE/2ddtEgP04AH4EPwIdzI+B+UZJP89EgsZ+DMil6D1mMoH149JNBGOdJ0D+mIIfmec7evbpS5g2fTqBn4+XLl0iWFlZEXqb9yV0HTiC8JGNE4Ftm+fJTmPmtgL7cUAffgzKN0r6+ecQzCwGEqZPn0FoLx/79LUg9LafQei3PJbAthuYS2A82c83jWCs8wTIH/tk8CP4EZCjH/sHFRglFv5bCZr60WJ5HIFtNzCP0HvMFIKFbzrBWOcJkD9jky+2+XHsQqPm38MdCMz5F4fx4wnM+46bmpoIe/bsITBx3QZaE0TbZvZfRj4/gPyxXrW7zY/B24wa8xkrCFLzsY/dVIJYu8zv9sY+P4D8AT+CHwHwI/gRAEzbj4zHWE/id8Zx3hvXHkw92E8DsvBjSKFRYxFcQDCfuYLQu/8ggqr5yNQz9nkAjJexKU3gR/AjAH4EPwKAKfuRx4d28wgfW08idBlq38rg0QTGhx+PmELoPHoWAfbTgBz8OGBVkUnRH58TDcpHfeeHEsw/c2tl4rxWZnoR+i0KJ1isSCSY2jwAxgP4EfwIgB/BjwDQjh/HLQIAwIBYh3L8GLodAAADMja1GfwIALL04w4AAAwI+BEAZOrHsB0AABgQ8CMAyNOPA8OKAQAwIONSL4EfAUCOflxdDACAARmX1ubHzg6uAAAYEOvQPRw/7gQAwICAHwFApn5cUwIAgAEZl9YCfgQAGfpxUHgJAAAGZFy6uB8tF4cDAKAnhH4spZiYWAkAgJ7AOQd+BACZ+nFtKcXEpEoAAPQEzjllfgQAwIDnV9eWAQBgQMalX2bz0TpsDwAABsQx7Qqbj+MyLgMAYEA+K3rK5iMAAAAAAAAAAAAAqIKlfzEAAAZkQmLb88hhje8AAJAJVl6xAADIhNyXCAAAmQD7JAAAPwIAIOSfljMAADAglv472fOrsE8CAPnwX/3sAAAwIB/auKBuUwMI/z1kMgAABqST3SI2H2H/BAAy8uPQyQAAGBCuH+H8FgDI5/zqv6eHAgBgQEauq2LzEfZPACAfP3aZEQoAgAEZtR78CACy9OPMMAAADAjXj/+ymgkAgAGxDOD6cTUAAAZk1Ppj4EcAkKMfnVYDAGBARm0APwKAHP3Y1WkNAAAGBPwIADL146w1AAAYEPAjAMjVj+EAABiQURuq2/xo7QQAgAGxDChp8+PstQAAGJBREeBHAAA/AgBgSD/+2vwPipenW/lgxEyCtrfHtMtshw/sjwE5+7HbnHU6RSwfu89ZS9D29ph2xfJR1+MFAKnYRNSAHwEA/Ah+BAAD+JH5+efnIz8vteUtfnvtbRf2y4As/Th3vU6Qmo/a2p6q29XVuAFAKjaR4EfYLwPgR/AjACj144hZWuWDkU6Ex8f/kyCWF6Lekrg9pt7PF1tRdXvaHjcAqItlIMePzhu0Snfn9YTHtf8HQWo+St2euvmo7XEDgLrYRB4HP8J+GZChH7s7R2iVHs4bCOr6Uer21M1HbY8bANRFl37ke0vV/BC9j+e9bxk0bR/9sJMA+2VAln50idAJ2srHHi4bKDRtn8lHXY0bAKRiEwV+hP0yIEs/zovUCVrz47wICk3bZ/2oo3EDgFRsompl70ex+wY0bRf8CIAf5ZePsF8GwI/gRwBQ5sce86N0gtzzUVfjBgCpjN7I8ePI2TpBW/modt69EIHxo47GDQBSsQws5fhxo06Qez7qatwAIJXRG0+AH2G/DMjRjws26gTZ+1FH4wYAqXD9+MHI2TpFX3kpmn+8PNT1eAFAKlaUH6N1itzyUdfjBQCpgB8BQKZ+XBitU2TnRx2PFwCkMjradPzYbh6CHwEj8mPPhZt0itzyUdfjBQCpjI4+CX4EJNHZxhkNn+OHxi4JQzbzg1APB1dZ9a/b2IVomJMP6d+oeYGou8Mi4/Tjok06RXZ+1PF4TZXeS2LQxNVb0dyN29G09QVoiGeirPo3cHk8mhCaQ/o3dV0BGuyZYDRzS/lx1Bydou18VDn/xPyo4/Fi5gRvQVcef83ysd08pfFdxy6k4sWY7BWBBs3wQpcfvWbXTVi2VmGbQ5x8qLrj3dvilkdksevP332htG/dx7ui6Pz9JI7bHu5Dac1F5LB0jaCOU8BmKrbbuEVU+ezAWKp8kmcEWe8Xm9/uHFQ13mHbGTbLF0Xm7kVHLtwSxOH+FVdfQLaLQvXynWuCVRDXj5t1itzyUdfjxfhnHUTcpd/SLUrjByxPQKosbgnlyD44C/39d9u6BTElCtt0WJVD1Z3PiYssrmHX//rbW6V9G+yZiEpOtJA47oL70HLvOXLZJJxTn/T9VOzA5QlUuW/GAap88ZYysj5+d127c/D0q+/YdiaEbkU7jjejRy+/FcTh/jXdfYacIov08p1rAvjReP2I44uPXWDXxRZVKGwzIKGQjalu+hx1Gj1Xsh//PXYB2n/mqtI+tTz8iu2XKn780GYu1WbZ8YtsmVQ/LovMbDe+8e4XaNhsP+Pxo2uMTpGdH3U8Xox/dgXtR/d4pfEDPBJV9OMuEo/3+8yy+/RVhW2m7D/Dxjz/+gdktjiWLRP4UaRf/ZcloNtPv1Lapz//+pvtF4PAjx6JbFmvxTFUm5fvv2DLVPbj+/gIzjjEljdv3yHHsFy9fO/qMnpTnd78qC1Pqp2H79Hn/k5TP2btPYFWp5cKGOrkQ+IXhaewsWdvPUObtx0UUNtyn41ZlVxMbU9VP66IzqGOxzZk70ZTvCKRa3gyOt5yjy07euEW5V9lfpzut4kqw+0p8uOFO18onAOfzXmUH3G/io6eRcsjs5Cjx3pkvyQMuYanotPXH7Nt4eNfY/FjL7zP0gOGzkd9jRMTwPOjhXu80viBPD8ev/Q5yj16QQA+XsLxa7ZVsrE/vfkdlZ+6IuDVdz+xMZkVZ6ntRfH8KNavzaUnqOOxouom5J64G60uOIpeftvW/uNX36Lei2PZenw/DvJIZMtWpO6lynB7TBnXj29+f6dwDuJ21bHx2PO4X+dvPUEbdx5HrnFlaG50MQrfVom+/elXtq3Sky16/f6lMgb8KGs/zgqIURrfzWEROS5S5ZgT+2PIe69K9eOOqvNsXH7FGaqM7zlrZ/92/dhptDN17Fh+oolqk+vHuquP2p3nUfOD0PA5KxWWBSVuZ9vC54GNxo94v6YHDO5HPY0TI/DjsgSl8QM9k6h438yDSuMHr0gmx0WqLNgf47FXOfWjdh6n/SiynYt3nrJxZ64/pMpWpO2jtjNlbQFb5sM7fzrIM4ms7+MWh+48azt2vPrgC6rN+D2n2LKvf/yl3XmetqEQfbomX2FZ2sEGtq2W+y/0+v1LRZ9+XOpjRVD7/cUvtAPTD1PwIya5pIo61tpT18JSf/OpUjeo6kfuMWhw0naqrM9kd6rPM/03K/Wj+eRlaFPBAXZd84NXxG+a+FGMAdM90e6Tl9i28PEl+PH9vnLjXIKh85Hphyn4EXP4wi3qWOvG45csP/zym1I3qOpH7jFo+sEGqmzkynSqz97p+5X6caR/Biqvu8Ku++PPv4jfNPGjGHbB2ejaoy/Zts7ffmI8frSZq1OW+lgTDO/H1n7oeryYOSG0H/0TCpFfbAHF6IUhbHzXcYuo+KSSKkE8di53G5NWRLT58e4XqMu4hWT9h6Od0bGmu2zZknXpgv4tj8ym/SgyDnzulonz2JhDlX1kN5/q8/ywJLbMKTBG6TEtdiPuA397eJzcfvHnADN0lq+g3sf289E0v01o07aD6ED9Ner+JUxYaolevnd1sQoqa/Pjkjid4hM9l2BwP77vh67HiwnIOUT5IXn/GRS/5zTFzMjtbPxAz2Qq/tD5W4J4/+xD1DaWJO6m/DgAH6MtiUNmbnHo+esf2LJ126sF/aP8+Ptb0XHgc7fMEl16girru4y+p2hV/tG27zzzoNJjWuxG3Af+9vA4uf3izwFmwuo8QT2L5YnIM20fOa9859lr6v4lvGQfOa+X711dxmw+pXM/Mvn3/YX/QTBUHjK8e/I/COzfzdKjHxXhGZ0j6kdFFB5toLbRaYwLdXzH+NPWNZRd13TvJeoxYYlu/Gg7j+rfgtXJKvuxouEa+hTfs6rEj2LM9I+h6uB2Tlx+IBq/99QV1G28q/H40W2LTmB+7n9o/E+CofPxj6f/SWD6patxYwK2Hm73vOemspNs/MAVKe3Gn7v1hNpGH/d49Oq7n9ly/5xDZP2s6GJ23e/v/kBDfVIF/YsqqaX9KDIOyo9lJ6gyc54fQwsq2bL2/HjvxddoMb7uyNte/N7T7c6Dd8YBqg5u56vvfxaNv/X0FRrsnaLT71tTwI/G70fMmoyytnt69p0g6zbk7GHXpZZXK+yfvv04zTeasDJ+G3E2c9/rRI8NGvnRYqonOnfnucJ7VvMqzqDF69JQ5zHzZO1Gvh/N3LboBLn7UVfjNlPRj5vLTrLxg1T0I387eVWNbHltyz2yruh4M7uu8uIdhf3j+1FsHFw/bio7QZX1VeBHpsyX50fPtP2EpP1niLOZ+14XJ+yi2kxQ0Y9M/JigbPQL77kT5p5VfL107fZqZO6eoNPvWhvo0o+Gvu6vKrr0JN+Pw+auRINmelN0n7BY1I/LIrME8eZTlgu2M3yuP3Ws2NNxCXUs9ZlPlCz82M2h7fgtdvthdn3O/pOifjxz44lgDjDMeWQMPnfMxJ+7/RytSilGI+YFGoUTRf24NF6rGFs+anv8GL4fP127DY0Ly6MY6pPGxg/ySqXiI0tqBfGjArME25m0bht1rDjcN506llqWuk9h/6JKTtB+FBkH7ceTVFnf5Yk8P1axZb5Z9PXXwd6pbNnehuvs+hNX7lNtJuxteyblu5/fCOYAM9ArhY1ft6PtPtyf37xFmYfPo6kR25H5skSdfK+6YkzMafCjHv2Ir48pi+f7cVZgrMrb2l3XwtbbsuMI5/6Wh6KekIsf8bVCMT+S+3PaGXtw0g42Ht/7oygGX48FP4IfuUt/z2Sl8Xw/+mUfUnlb+H4cZtl/9gb7/9c//CLqCbn48e7z16J+xPfntDf29EPn2PiyU1cUxvR271h+/HD0HIK2njvWVz7y85IZh77uz5kXmiTp/hzMJ2MXKHUdl3VZu9gYvC1uO9n7TrbdK3P/pWA7Q5x8tepHfO8OnpOQ5B2o6f7LtmdGDp2RfH/O9JWbqHEx8SevPEAzVm5GA2asQJbO/uR+nYite9DRxlvG5Ud8/kkD8P4HY+z5yIxD0/nABOQeoe/POdCAEvadoViFz0e+jx/kTfvx0IXbgnjMAHzsxNtWFOcZRe6yraaZjcHb4rZTe+U+G/fujz8F25kQXkDqUX4sP0ltt68Hfc9t6LYqtsw3m74/adW2KjInGYfPo7d//Nn2zMiNR1SbeNtt3n6ncA68Mg5S4+L+PuCVeRDZh+WhyeuL0IqMA2h7bQt6/Oo7rXynuoTyI/79WgM+HDOXYPR+fD8OTecDMyckvt3raOW1TWx8VwdXlZ5l7PXpUsG28LpmjnPY5xHnBbIxeFuqtM8wA1/jG+2Mzt7m+BFfL+Vsl3//6oI1KWyZE+/9cWLPZWKHcdv0i2v/+mNqeQ0b38VhEXl2W1k8vrdXG9+pLrEK5voxUSN6E0cmmIAfW8eh6XxgAnKPtnsd7crDL9n4Qd5pKj3LaOWfJdgWXveO4xxm+SxiBxuDtyVl8cqsIPVoP9ZR2+3rkczz4zG2jO9HsecyPdMPUm0m7Ktvt15l0102fqB3Gvri2x+Vvz/n93da+U51yZiYMxr78WO7OQRjzUOxvPzEfjbBWPyIwffmUPdsnr5ClcvJjxc//5K8U47vRnX8iBkyyxftrGlU/BzJ/ZeoBD//aUR+7L0sUS0sPOIIppaP/T3jCOrOCyZQRT8y8YN9VPOjdUCWwu3VXr7Pu2fzK6pcqh+9sypIPb4fuW324z2TElZ4jC3zU+LH3979gS4/+AKtyDgoGIeqfuTWmRC+DV26/0JhLP69AT//qcl3qQ9sY8GPuvQj9t0gJ2+l9JvmycZ3snVpNx7TyXaewu31cHSj4vgexdtSpX0GfFyG6w2Y4cWu646fE6HOG9B97jZ+MXVcp6hdfhvtjUMRvSe7K6xrMd0LjV+2Ds0OikOTvCLJ8fNH9gtk70ahH5PUwsJjC8H0/LiFoO68YAb7pCOHNQVKGROSy8abL09uNx6Dj9kUbW/4ykwqzjogmyrH21KlfYZBPumk3tiwfHbdML9Mqs0+y5OoOkN8M9iyQSLj57fR3jgUMTIwR2Fd+9A8tDB+N1q59QhamrIPTY0sRhYrUjX6HvUF14/4/gV1MJU8FL8e6QwAeoHy4/IktTD1fFR3XgBAKuBH8CMgVz8mq4Xp+zEZAPSCbWy92n6Uzd/HAU8CJujHPh7Jkuho+Sh1fgBAKrZxHD+OcZFEh/OjxPkBAKlYBZdz/JgiiY7nxxQA0Cma+PHb8/9JMNU8ZPj90X8SYP8N6NWPnqmS+PbC/ySYfD4+/p8EqfMDAFKxjWsAP4IfAfAj+BEAtOhHUz+Pw/LDTgLsvwG9+nFFmiQ6Wj5KnR8AkIrtFvAj+BGQox/NV6RJoqPlo9T5AQCp2Gngxy7j5hCYn1e10XEesYgt/HJePU32d3NXJbDvcKm8eLvdePyuUSZ+gsd6sg6/A4dZF5W3X7TugYbrgrjg5GJ2XXXz51T83lOX2TK3DRlUmcX0FeT9Nty/iQH+0rMfvdIlMcg3iWDq+Sh1XrgEbatmm336+od24/G7RpnFNWU/WXf72Wt23c5TV0Xrfv7FN4K4zKMX2XUvvvmRir/FaXdDaR1VZremkLzfhv2bGL+91WgeANWw23K2zY+28yTRxWEuweT9KHFeuMwN5frxTrvxtB83kHUrNuey605ff4w+sl8oqDfMOYB6n5rN4lCyPjiF50dOHYEfOWVxnL//wfpRg3kAVMMqhONH7wxJDPJLJpi8HyXOCxeBH9uJp/14gKyL2dv2rrVvf36DLHyzBPUmR5VQQ5oVt5usz6zk+ZFTh/JjWR1Vtu/8Lao94kcN5gFQDbt49f2oLh/ZuxD465n7trV2PlQG+zsxP/abvgL5bdlG6PnpUqV+7PPZctT84BW7PmNPLdpcdIhi5/GLbHlFw3W2PXX8ONwlkPzNYvCjcflRXfr5pBH467Wdj3LY34n50XZNIUqsOEewDM5T6kebsAL0x59/seurL99HuxtuUlx60PZe1ftffsu2p44fp2wsIX+zGPwIfuwoflyTUcau947JU+pHTM7BUyq/U9wnrkAjP2bsPSFoE/xoAD/6ZOqFfr7pBP56rftRT+NRRlBhDe3H9+vzalrY9XH7z7LrKT+mHmTX111/rPI7xRMOnmPrZVY2cfz4E9U32o+n2PXHrzwUtEn8KIP5NHXs4s/p3Y9idBQ//nu8K6q/8YRdX3XxLupsP1+pH2cFx1G+wtca99ZdJhxravu7Tvi4Dx+bqutH2yWryd+bwuv2nGoBPxrQj319Mg2KtvPR0OPBBPP8iNcNCdiKvv/lN3b9s69/JOdM+/L8uDj1INuOf/4xylf4WuPNp68Jz79p+7tO+LjPLryIrcf3I7dvXD9GlJ0i6+bG7yV/bwovN55+RflRDvNp6oAf9e9H1/VpguOzaSs3KfXjx+MWUU6dGRjLlq3L3t32d4YPN1Dbl+rHoqNnyWf896xmB28BPxrSj3gfbUC07kcDjwcTXHSc9qNvFlpXWif8O4tbK0kZ5ce0Cradgf45lFN986rYssKTV9j1DbefUtvPrOL48dufqDLKj+WnyLoLd5+Tzz+9eYsCOOeGiR9lMJ+mjl0Cx49282XB87r/IEjNwz++3UGQyzgwc0MTaT/azUf766+1/t3Hk82o6uId8v9tRxtIGeVHzw1UW9EFB9iytN3HybrOYxeQvzHHrHdZnUTVCU7ZSfuRU7b3VNt9sW4RmWiyz0b2c2DidjTRK5L2o4zm1VSxCtnF8WO2LHhe9z8I0vOxmCCXcWCEfsxGd1+03md67fErcuyIl3N3npMyoR/b2iqrv8GWHWt5QNZZ+OWgl9//zK5ftb2WqpNZ1czzY1sZ7cfTaFnmEfZz2pGLaEn6IZ4fswEdY5dwHvyoRz86eKynXOYdl0/+j89pDnMJVOpHO7dwtqzx7peom6Mbcli+jnJYF8fFavsR+5q5R7b7RDfwo6H96JctCzT2o0zGgeH7cVFqRZvLdtSi+IPnyP/xOc0pm8poP6ZXUG05J+5v+9vCb/9Aw0Ly0cLUg5TDhgTnUXUEfuSU8f147ckr9h7Z4SH5aEkGz48ymldTRY5+VPu8DnNeVcZ+ZO59qbv6EH3s4Ip6TnJHF+5+0frMYsF+pX7EHDl/ky13DkuijiljdxwWxKvqx8LKs+z/l0dvJeXgR8P6sZ9fjizQNB/lMg5MSFEt5cea9/e+fP3jr2hQQC6yDi1Eb962PmdYeuYGz4+HBO09evU9Wx6yvRaV1d9kP+89f1sQn8XzI7fs1rOv2bLz78+r4mXz3gZS7pZxmPKjnObVVLEHP+rNj/ia3qX3z2lgbzExmworWh105wVqvv9SqR9XJhSx5XkVZ9Cpa4/Zz/hYUl0/MuB7fbC3wY8y8OPKHFmgsR9lMg4Mdhiz4Gt6f/7V+pxG1rFmNmbX2dZnDX/5/R16x3mOg/iR117KkUa2/Mytp+jbn96wnxelVQji8XYoP3LKbj3/WnAd9Pk3P6FBgbmk3C2T50cZzaupYp/Y5sdOdvNlhdS8lFv/Mc4cPzJgB+J7TJkY6/nB7D2jXBw9NwjaGzDTB7U8FMa23gO7QBAfwvMjt0yRHxeEp7Lln/L8KMf5NTWsKT9ulRVS81Fu/ceEbD8hcBB2oN26YjZmWsxu9p5R7rI4/bCgvXEbStBfCoLxPawW/sLtZx27xPNjW5kiP67ZWceWu3GuR7b6cSugY+wTL4Af9ezH5LJqQdz2qvMq+RFTVHlOEIvvU1UUK8WPFWevo4/GLgQ/ysWPeP8qIyT7UWb9x4TsEPrx6KX7griL974Q+jHjsMI2L3z+QhCbiY9HFcQK/Mgp4/vx/svv0AB87Pi+XOBHGc6vqUH5ER9/yAiV8/H9eRy59R+DrxHyXWbvvlYQ58R5loL144oIhW3OD0+l4vCx55C5/gpjQ1J5fuSUcd/r2vrMSBxVTvnxznNZzq+pYb2K68dcWSE1H+XWf4wiP85LOSiIW7mtRoEfjyhsc3UJ/XwIPpycGF2uMFbox7Yyvh99C2qocqEfcwEdA37ULd0nLkVD5qxkGTzHT2EcPm7jxmG6OC5RGPuJgysVN3CWn+j2e01ZzsYNcPKlyixmelPt8Ovi7TNlg2b7gb/07EeLgDxZITUf5dZ/jGVYEXEXg2N0ucK4AYH5VBxm6KpChbGDgguouAlRZaLbHxm+g40bz4sbG1FKtcOvi7fP9ntjuSzn19SwT2qUrR8ZjNGLAGBqfmQwRi8CAPgRAEzIj4H5sqRdP8q03wAgFWPwo+h5HfAjYMp+DMqXJe3lo1z7DQBSsU8GPwKAHP3YP6hAlrSXj3LtNwBIZWzyxTY/4nv7ZQw/L+XeXwCQivWq3W1+DN4ma/j5KPf+AoBUwI8AAH4EPwKAcfsRADqUH0MKAQAwIGNTmsCPAAB+BAAA/AgARuHHAauKAAAwIOBHAAA/AgDQjh/HLQIAwIBYh3L8GLodAAADMja1GfwIALL04w4AAAwI+BEAZOrHsB0AABgQ8CMAyNOPA8OKAQAwIONSL4EfAUCOflxdDACAARmX1ubHzg6uAAAYEOvQPRw/7gQAwICAHwFApn5cUwIAgAEZl9YCfgQAGfpxUHgJAAAGZFy6uB8tF4cDAKAnhH4spZiYWAkAgJ7AOQd+BACZ+nFtKcXEpEoAAPQEzjllfgQAwIDnV9eWAQBgQMalX2bz0TpsDwAABsQx7Qqbj+MyLgMAYEA+K3rK5iMAAAAAAAAAAAAASGFC4iVk6V8MAICewbnH5GFY4zsAAGSClVcsAAAywHFLHcp9iQAAkAmwXwIA8CMAAEKY8zqW/jvRPy1nAACgZ3DuMXkI+yQAkA/dpgYQPrRxQf/Vzw4AAD2Dcw/noM3aI2w+drJbhP57yGQAAPQMzj0mD8GPACBTPw6dDACAnuH6Ec6vAoB8zq8yjFxXhf49PRQAAD2Dc4+fj+BHAJCPH0etr0JdZoQCAKBncO6BHwFA5n6cGQYAgJ5R6MeAnehfVjMBANAzOPeEfjyGusxcDQCAnsG5B34EABn7ccMx1MVpNQAAegbnHvgRAOTtx65OawAA0DPgRwAwAj/OWgMAgJ4BPwKA3P1YjbrOCgcAQM/g3BP6sQT9y9qpXfYWrFPIqYNpCrlQU6SUKw37NeJOSy3F4zsX1YKpz7R7siKLoMqcAIAm4NwT+DGiGnWdvbZdOlo+qjInAKAJOPfAj+BHAPwIfgQA/ftRV/nXXl6CHwFT8KNNRA3qNmddu3S0fFRlTgBAE3DugR/BjwD4EfwIANrzI0NBchDB0Hmp7fM54EVAFn6MrEHd5q5XGVPPRylzAQCagHMP/Ah+BMCP4EcAUMGPgSXoXyNmSaa9fLxUt5Nwo/EQRXv5ef/6KYpn9y9R3Gk5/h7Fefj6i3sKadeLaswBAGgCzj2hH4+jbs4bJGNq+ajOHACAJuDcAz+CHwF5+7G7c4RkTC0f1ZkDANAEffixuW4ngVlfWRZHsSNzNYGfj0z+MfnBcK5mRyvHiwmVu1MI/Hxk8q7l7EGF1B0pIIAfAVn7Meo46u4SIRlTy0d15gAANAHnHvgR/AjI2Y+1qPu8SMmYnB/VmAMA0ASce7r2I3MeRzwfwwiq52MxBfgRAD+q7kdjzUfYXwPgR/AjAH7kMnpjLeoxP0oyppaP6swBAGgCzj2hH0vRv0bOloz+8lFP51fVmAMA0ASce0I/nkA95m+UjKnlozpzAACagHMP/Ah+BGTuxwUbJWNyflRjDgBAExT50SqwFH0wcrZk2rufPGuLP4G5/s+/D0DsfvJ9RdEUTP615aHy+8mZvOPT3v3k6swBAGiClagfoyVjavmozhwAgCaAH8GPgMz9GH0C9VgYLRmT86MacwAAmoBzT1t+ZN5rZSrA/hqQhx9Pop4LN0nG1PJRnTkAAE3AuQd+BD8CMvfjok2SMTk/qjEHAKAJCv0YVIo+GDVHZcTeh6yt9yK3lzfaeh8y/3wO60kJcwEAmoBzT7EfN6uMqeejlLkAAE0AP4IfAZn7cVMd6ukaozIm70cJcwEAmoBzT10/6uu8StQ//1+l6O18K+y/AQP4ccymOtTLNaZdOlo+qjInAKAJY8CP4EdA/n5cHNsuHc6PKswJAGiCOn5sLz+0zaL/5/9Siq63v+v/+78pYD8OyMmPHT0fYT8O6NePZegDm7midHg/KpkbANAEnHsCP24+hXotiROlw/tRydwAgCbg3FPXj9mZ8Sqxb9dWgth6MdqL11Z7qo4D/AgYzI9uW0Tp6PmobG4AQBPAj+BHbdBpjAsyn7IcjZwfhCZ6bEDj3deigTO8YG605Eczty2idPR8VDY3HRVz93g0KiALTYsoQosTdqEFcWVo7KqtMDcS0YYfb10/pxRV80nT/FO3PVX7r44fe010Q1cef82Svvu4IMbs06Xo3J3nVFxiSSUVE5y0gypXxqK1qYJtfDjaGdVff0zFHblwS2GfjzbeouJwPVyfH9fTcQlyj8hEOftPCvrPcLzlHvKLLUAf2c4D/6nrx5jTyGxpvCgdPR+VzQ0fq5UZiLsca74riLH2z0S//PaWiqs4f4uKST90Dqm6hBcdE2yjt3s8+v7nN1Tc41ffKewzXs9dcD1cnx833DcdRe6sRSeu3Bf0n1lefvcTSth7BvVdnihp3joqOPfAj4b144acPQKvaNuPls7+CmP7THan4vpMXqYwbvhcf0Gbk1ZEqNyn1F014D/wo1H4sej4JYFXtO3HyesKFcaODMii4kYFZimMm7Rum6BNt6Q9Kvepsuku+E/Pfnz6+JZCvvn6BUFu53OYfon1Wx9+tJi2AjXdf6lzP7ptyFAY6xQYQ8XNDoxVGOe2Pl2pHy/c/QLtOHYexW0/gjZtO4h2VJ1HLQ9fU204eqwHB6rrR/cEUTp6PiqbGz5W/pm0Hy99TpXbrcpFb//4U+jHC7eoOEl+3F4t6MeGnccVxvpmH6LiVuYcVhi3vvi4oE235L1s+Zvf36GLd5+hfWdvoPLTV1Hj3Wfor7//ptpwTdwtae46Igr9GFyGPsDn00To8H5UMjd8en26lPbjnlqqPG7HEYU+SiytpOKCk2k/esXkSepHUkmVwu3gY1duXGTePsX9KakUtDnJKxLtOXUZua5NQ/92WCQod4vIpNpYl7VLUp87Ijj3hH48g8zcE0UBPyaqjJV/lgI/tpVjnyhaKi7cpuLSD52nymN3n5bUj0MXbivcDj525cYVn7isMO4gPp7ltemWvA/dfPIKhW+vQQO90gTlG3bWUm1sq2mW1OeOCM49ffmxvfzkwz+vws8vsfMuYoj1w1B+HDbXH7U8/Iqs5x9raduPxy99ztatu/oI1d98Sv6/u66Fitt7+gpZf+72c3Ti8gO2TnXz54I2P7Kbr3SbNotW0edYy6vBgWr40Tb2DOq9LFGUjp6PyuaGj3UA7cfqS5+zZZPWF6I//2o9xuIfa2GfcdvJOEz7MW7PaUn9+OLbH9m6X//4K/rx19/I/288fkXF3Xr6FVn/85u36Kvvf2brvPjmR0Gb/TyTlW5zZvROqs9Hm+5I6nNHBOce+NEwfszYU0sdn+nKj/1neAn6sPXgafL/Sw9eoW7jF5O47hOWsL7OP1yPUstrqHoWUz1V2l5n2/nkXOquk81U/ZiiCnCg2n5MEgX8mKQy1gHZCvzYWlbTco+63ij0Y1s7iv2oWh/sw/IFfTh17SH5/59//YWG+GaQuGF+mayvG24+JtcMuYvtqjyVttfXIwW5Ju5F1x69pOrvrr8uae46ImJ+xPcriqGtfBRDrB1+Pra3vfbaVzcflc0NHzOeH7ET8Xpb1zB0+VHrMePZ28+QpXOAwI/cdvh+LKo8h9ZklAlYGpEp6MO8sESqrsfGbOS3ZRv7GV9HxHFTfKLYdYEJRWhZVBZVb25IvOg4h87yRb6xBajo6FnRe1mdVyVImruOiKgflyeJ0tHzUdnc8LEOVODH5UlodkwpYg4Zf3rzO5q8YbvQj5x2+H68cOcpyjvWJGBDSa2gD8EFVVTdTeV1KHF/A/vZLWUfiVuWdoBdl1pxFkWVnaTqBeYdFR3nhLWFKH5fPTp/56novaxB+ZWS5q4jAn40jB+xR5h1AQmF5NlBKX4Uo7i6UdAHfL8MN8ZmQTByWBrOfg5JKSZxq9NK2HUTlq8jzzJy623M2y9ou+dEN9Frm1xyD55GnW3ngQPV8mM96r08WRTwY7LKWAfm8Px4j6zHHmGWlIPn0KjgXAV+bGsn4/AFle7Nab73QtCH8jPXqJgZ0SVo3pbd7OfMIxdI3Naqi+y6hYl70LQo+vxoSd1VQdvD/bPR4cY77fbr1PVHqK9niqS564jg3AM/6teP3Ps+8bXArg6LdOrHQ2evs+X4WBV76hP7Bajp3kv2WBTH7axpJJ+b779EXRwWoc62Lqjh1lO27v4zV6l28TsBmDqKwNdUy2ubyL2v4EYN/BhXj/p4JIvS0fNR2dzwGRHE82PLPeSWsp/9/M2Pv6LBfhnIJoTnx8bbVDsZR1T3I78P97/8hi3Hx6r9VqSgAd5p6Pd3f7w/Fn1G4i7df0E+v/vjTzTIN5347Mdff2fr3nn+mmrX3LOtjqIFX1O9+vBLtH5nLdmmlHnrqODcE/qxHH04xkWUDu9HJXPDx2ySO8+PJ9Ceuhb28/KoHBJn/pkHz49VVDvBycWC4zF8jpTPvLAkql6vSe7seVxyXfFQPVtW/N5t+NkMfO2Rec6krLaJjcl9f52S8V0PRze2zGZhiMCJe+suo7VZ5WhWUBzqPXmZpLkCXEjuKfZjiijgxxSVGRG0lXJGTct9dOPJK/bzxvI6EmcTksfz4x2qHb4f8fEYPkfKJ2TbMaoePn7l3vpTf/MxW4ZdyjybMXRlFvucyZWHX7IxeDtc3+HjRaZsZnSpwIk3n3yFCmouoZVbj6KRwVslzRWQAn7Usx8bbrYdjx1ruos+HrtQLT96x+SptP0Z/jFUPf+EQrZsdXopu94ntoD9P/YbE+O3pZCq/5nvRrYMu5i6rhmdA47TiR8bUB/PVFE6vB+VzA2fEbzzptzjsedf/4j6+2SQOJtVCvzIaSfjSCN9f86+epW2751NP8+YXHGOLcs91sSuj+dcj8R+Y2KSDp6l6ntkVLBlIduq6euau09LmhtACM498KP+/Mhl/upkNk5XflybvYuq5+C+li3DrmPWn7zykP3/9JWb2RgH93CqflhaKVs2n+fHKd6RCvuA74/Fz3qA/8CPcvMjdwktrGbjdOXHbcdbqHoLEvayZdh1zPL6h1/Y/3tlHWZj5ifQ78jZWtXElq0qpP3onnZQYR+GrMxCMzeXgf/Aj7L144GG66iz3Ty1/YivBeJ38Sii3zRPtl75ibZnLPD1xk/eH69i8L01/Ocu8blYfE6WicHxzHVKzM7qC2wZfn6TW7f28n3kG1eAZgbEIJfQRLQyvhCl7T6OGu9+Qf4F/6npxy0NqM+KNFE6vB+VzA2fEbzzpszy+YtvUF+vdDbOJpR+BuPQxTtUOxlHaT/eef41OtZyTyFjwgrYelc5z1j8/u5PNMA3ky2zDNwqeO4Sf7QOzmVjcDyuxyxN+Prm+7JJkcW8d63+jBIOnEU+OUdR8LZqlFRxDlVduod+e/sH+VfKvHVUcO6BH/XvR+4xmjp+VAb2Fq7Tdbwran7wqu3enZpGQf8O1F+j6uJ7efgx2IlijsXXU1XpE/hRfT/abWlA5ivSROno+ahsbviMFPGjd/YRKm60Aj9yyzN5flS2TIooJnWG+GejP/78i11/6f9v315+o6riAI7/GdTEjXHTB22DRhoTY8tgWk3YGNFFFW0kxmBf2AfFooaCG6HQUsZpy5RHH4PTGgwLGnxsqoFCKYwxbjDowkTZGP+GnzmTTDP3njmXmR7mcqfn2+Sz6T333s5JfvNN77QP/tF+vvt//+s594+H/2lrcp9T5hrb0BXfOPZ95kFRP5PqYyn75qpm+hh6H1M/3NHWlaOPbR9+bnw2mnMsecWz5osLV7U16rz8NbH9wxvHVIPHLn/n+RugQgpdF8X28YZUH5gwcr6PAXvj9+JgUmtF5s+H2rqXhmZ8fbzvOR6/tlZ8H4/OZ8/pGP/W+2z0+rp239SK938/0j//pq1R5+V/tY9+s3FsR++kXFv/XXy/hmpfha4LnZo9rY8DX8s29ff4Bs73MWBv/J6O7ZO9/V967Njbra/b7V33csdhz/Gd7X3adUyeae3InqPuk//9+tc7tfv612Tb6lujzstf0/iGfp3n3uyR/SOJ7OedI8kr0j82Jx8cm5TXDozIs+p5bQl75jI1e1ofT9yQ6o/OGjnfx4C98WvoScjBmeserer3O9+6xl7vurdOLHmO7zme0q5j8nzfdPYcdZ/878c+vaTd17/mVdVW3xp1Xv6aVz6b1da0HZ2XkfSKnP8xIwsrv0p8eU2OL/4k709clZ0D50raM5ep2aOP5esjQB+j00eAPtJHbKU+3pTqzriR830M2BvAhpo9+kgfEe0+1nTGjVyfx6C9AWzQR/qIiPfx5E2p6frKyPk+BuwNYEPNnt7HtGxrbjdyvo8BewPYULOn93FVaroSRvQxAZSFmj36SB8R8T52J4yc72PA3gA26CN9RLT72HJyVWq7J41cn8egvQFstNBH+oho93F0VWp7Jo2c72PA3gA21Oz557FpIC1Vze1Grs9j0N4ANpoK9vGW1PZMGdHHKaAs1OzRR/qIiPexd8rI+T4G7A1go2AfB9NS1fK2kfN9DNgbwIaavcJ9nDaij9NAWdBH+oiI9/HUbak7eM7I9XkM2hvAhpq9UvuY49o88v6NKPYxx7V55P0b9JE+gj7WfZx8JOf6WMSeADZs+piz1eeR92080T6evi11fcmibfV5LGUvABtq9ugjfUR0+7jr9Jps75sp2lafx1L2ArChZk/v46JU7Xpn03LPPyptHjeeo1q8dsCGmr2Cfew/v2mVPo82rx2wQR/pI+gjfQTC6WOxvXzS80gPURF9HLsj2wcuPDZRn8fH+VoBG2r26CPvy6CP9BEIv4+mXhY7j6aO+ef8UfNID1GpfawfvFg2m51H03VKncdyvjbABn0E6CN9BIrs46FFqYrtAxAyNXtaH8fXpf7QJQAhU7NHH4Go93EWQMjoI1ABfRyaBRAy+ghEu4+x8bvSMDQHIGRq9ugjEOE+nrkrDYfnAIRMzZ7exyV5ave7AEKmZq9wH+cBhIw+AlHv4z1p+GQBQMjU7NFHIMJ9nLgnjcMLAEKmZs/UxxfeGwYQkuA+pqRtdBlASNTM0UegAvp4JCVtp5YBhETNXFAfAUTh+WpGGo9cBhAyNXv+eWw984s0DS0BCJmaPf887rn4l8TOZgCETM2efx4BAAAAAAjyPyIXf44=]]
    local atlasBytes = 24221
    local tabs = {
        {id="news", button="tab_jimi_news", row=0},
        {id="features", button="tab_jimi_features", row=1},
        {id="settings", button="tab_jimi_settings", row=2},
        {id="credits", button="tab_jimi_credits", row=3}
    }
    local state = {ready=false, visible=false, sending=false, untilAt=0, page="news", dialog=""}
    local api = {}
    local function id(page) return "jimiproxy_" .. page end
    local function owned(name)
        if name=="jimiproxy_logs" then return true end
        for _,tab in ipairs(tabs) do if name==id(tab.id) then return true end end
        return false
    end
    local function field(packet,key)
        return packet:match("^"..key.."|([^\r\n]*)") or packet:match("\n"..key.."|([^\r\n]*)") or packet:match("\n|"..key.."|([^\r\n]*)")
    end
    local function preferences(name)
        local ok,p=pcall(require,"Preferences")
        if not ok or not p then ok,p=pcall(require,"preferences") end
        assert(ok and p,"Penyimpanan pengaturan tidak tersedia.")
        local made,instance=pcall(function()return p:new(name)end)
        assert(made,"Pengaturan tidak dapat dibuka.")
        p=instance or p;pcall(function()p:load()end)
        return p
    end
    local function marked(p,key,version)
        local ok,value=pcall(function()return p:get(key,0)end)
        return ok and tonumber(value)==version
    end
    local function mark(p,key,version)
        local ok,result=pcall(function()return p:set(key,version)end)
        assert(ok and result~=false,"Pengaturan media gagal disimpan.")
        ok,result=pcall(function()return p:save()end)
        assert(ok and result~=false,"Pengaturan media gagal disimpan.")
    end
    local function exists(file)
        local fn=(type(fileExists)=="function" and fileExists) or (type(isFileExist)=="function" and isFileExist)
        if not fn then return nil end
        local ok,value=pcall(fn,directory..file)
        if ok and type(value)=="boolean" then return value end
        return nil
    end
    local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map={};for i=1,#alphabet do map[alphabet:byte(i)]=i-1 end
    local function decode(text,size)
        assert(type(text)=="string" and #text==size and #text%4==0,"Data media tidak lengkap.")
        local chunks,chunk,count={},{},0
        for i=1,#text,4 do
            local x,y,z,w=text:byte(i,i+3)
            local a,b,c,d=map[x],map[y],z==61 and 0 or map[z],w==61 and 0 or map[w]
            assert(a and b and c and d,"Data media tidak valid.")
            assert(not(z==61 and w~=61) and not((z==61 or w==61) and i+3~=#text),"Data media tidak valid.")
            local n=a*262144+b*4096+c*64+d
            count=count+1;chunk[count]=string.char(math.floor(n/65536)%256)
            if z~=61 then count=count+1;chunk[count]=string.char(math.floor(n/256)%256)end
            if w~=61 then count=count+1;chunk[count]=string.char(n%256)end
            if count>=12288 then
                chunks[#chunks+1]=table.concat(chunk);chunk,count={},0
                if type(sleep)=="function" then sleep(1)end
            end
        end
        if count>0 then chunks[#chunks+1]=table.concat(chunk)end
        return table.concat(chunks)
    end
    local function write(file,bytes,size)
        assert(#bytes==size and bytes:sub(1,6)=="RTPACK","Gambar media tidak valid.")
        assert(type(writeToLocal)=="function","Penyimpanan media tidak tersedia.")
        local ok,result=pcall(writeToLocal,file,bytes)
        assert(ok and result~=false,"Gambar media gagal disimpan.")
    end
    function api.prepare(force)
        state.ready=false
        local wrote=false
        local p=preferences(banner.prefs or "JimiProxy_banners")
        local key=banner.key or season
        if force or not marked(p,key,banner.version) or exists(banner.file)==false then
            assert(type(fetch)=="function","Koneksi media tidak tersedia.")
            local ok,text=pcall(fetch,bannerURL)
            assert(ok and type(text)=="string","Banner belum dapat diunduh.")
            local bytes=decode(text,banner.b64)
            write(banner.file,bytes,banner.raw);mark(p,key,banner.version)
            wrote=true;bytes=nil;text=nil;pcall(collectgarbage,"step",256)
        end
        local ptab=preferences("JimiProxy_tabs_settings_v1")
        if force or not marked(ptab,"installed",1) or exists(atlasFile)==false then
            local bytes=decode(atlasData,#atlasData)
            write(atlasFile,bytes,atlasBytes);mark(ptab,"installed",1)
            wrote=true
        end
        if wrote and type(sleep)=="function" then sleep(120)end
        state.ready=true
        return true
    end
    local function busy()
        if state.sending then return true end
        if state.untilAt==0 then return false end
        if ms()<state.untilAt then return true end
        state.untilAt=0;return false
    end
    local function markup(page)
        local t={theme(),"text_scaling_string|"..string.rep("W",42).."|","disable_resize|","start_custom_tabs|","set_custom_spacing|x:0;y:0|"}
        for _,tab in ipairs(tabs)do
            t[#t+1]="add_custom_button|"..tab.button.."|image:"..atlasPath..";image_size:228,92;frame:"..(tab.id==page and 1 or 0)..","..tab.row..";width:0.15;|"
        end
        t[#t+1]="end_custom_tabs|"
        if page=="news" then
            t[#t+1]="add_image_button|jimi_banner|"..bannerPath.."|noflags|||"
            t[#t+1]="add_spacer|small|"
        end
        t[#t+1]=JimiProxyExt.pageContent(page)
        t[#t+1]="add_quick_exit|"
        t[#t+1]="end_dialog|"..id(page).."|||"
        return table.concat(t,"\n").."\n"
    end
    function api.open(page,native)
        if page=="logs" then return JimiProxySettings.open("logs",native)end
        if not owned(id(page)) or busy() then return false end
        if not state.ready then JimiProxyStartup.start();return false end
        local content=markup(page)
        state.sending=true
        local ok,result
        innerVariant=innerVariant+1
        if native then
            state.untilAt=ms()+500
            ok,result=pcall(sendVariant,{v1="OnDialogRequest",v2=content},-1,500)
        elseif growtopia and type(growtopia.sendDialog)=="function" then
            ok,result=pcall(growtopia.sendDialog,content)
        else
            ok,result=pcall(sendVariant,{v1="OnDialogRequest",v2=content})
        end
        innerVariant=innerVariant-1
        state.sending=false
        if not ok or result==false then
            state.untilAt=0
            say("`4Menu could not be opened. Try again.")
            return false
        end
        state.page=page;state.dialog=id(page);state.visible=true
        return true
    end
    function api.suspend()state.visible=false end
    function api.isDialog(text)
        local name=tostring(text or ""):match("end_dialog|([^|\r\n]+)")
        return name and owned(name) or false
    end
    function api.handle(kind,packet)
        if (tonumber(kind)~=2 and tonumber(kind)~=3) or type(packet)~="string" or field(packet,"action")~="dialog_return" then return false end
        local name=field(packet,"dialog_name") or ""
        if not owned(name) then return false end
        local button=field(packet,"buttonClicked") or ""
        if button=="__close__" or button=="Close" or button=="close" then
            if name==state.dialog then state.visible=false end
            return true
        end
        if busy() or not state.visible or name~=state.dialog then return true end
        for _,tab in ipairs(tabs)do
            if button==tab.button then
                JimiProxyExt.logView=nil
                if tab.id=="settings" then JimiProxySettings.open("home",true)else api.open(tab.id,true)end;return true
            end
        end
        if state.page=="settings" then JimiProxySettings.handle(button,packet)end
        if state.page=="features" then JimiProxySettings.mainAction(button)end
        return true
    end
    return api
end)()

JimiProxyStartup = {
    ASSET_VERSION = 6,
    SOUND_FILE = "jimiproxy_startup_audio_v2.wav",
    SOUND_URL = "https://hijimi.site/assets/jimiproxy/startup/jimiproxy-startup-audio-v2.b64",
    SOUND_B64_SIZE = 1315064,
    SOUND_RAW_SIZE = 986298,
    PREF_NAME = "jimi_proxy_startup_audio_v6",
    PREF_KEY = "asset_version",
    FORCE_REFRESH = false,
    running = false,
    B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
}

function JimiProxyStartup.reportError(stage, err)
    say("`4Media belum dapat dimuat. Periksa koneksi, lalu gunakan /startupfix.")
end

function JimiProxyStartup.need(ok, msg)
    if not ok then error(tostring(msg), 0) end
end

function JimiProxyStartup.basePath()
    return jimiScriptLuaPath()
end

function JimiProxyStartup.openPreferences()
    local okRequire, pref = pcall(require, "Preferences")
    if not okRequire or pref == nil then
        okRequire, pref = pcall(require, "preferences")
    end
    JimiProxyStartup.need(okRequire and pref ~= nil, "preferences module unavailable")

    local okNew, created = pcall(function()
        return pref:new(JimiProxyStartup.PREF_NAME)
    end)
    JimiProxyStartup.need(okNew, "preferences init failed")
    if created ~= nil then pref = created end
    pcall(function() pref:load() end)
    return pref
end

function JimiProxyStartup.cachedVersion(pref)
    if JimiProxyStartup.FORCE_REFRESH then return 0 end
    local ok, value = pcall(function()
        return pref:get(JimiProxyStartup.PREF_KEY, 0)
    end)
    if not ok then return 0 end
    return tonumber(value) or 0
end

function JimiProxyStartup.markCached(pref)
    local okSet, setErr = pcall(function()
        return pref:set(JimiProxyStartup.PREF_KEY, JimiProxyStartup.ASSET_VERSION)
    end)
    JimiProxyStartup.need(okSet and setErr~=false, "preferences set failed: " .. tostring(setErr))

    local okSave, saveErr = pcall(function() return pref:save() end)
    JimiProxyStartup.need(okSave and saveErr~=false, "preferences save failed: " .. tostring(saveErr))
end

function JimiProxyStartup.b64Map()
    if type(JimiProxyStartup.B64_MAP) == "table" then return JimiProxyStartup.B64_MAP end
    local map = {}
    for i = 1, #JimiProxyStartup.B64_CHARS do
        map[string.byte(JimiProxyStartup.B64_CHARS, i)] = i - 1
    end
    JimiProxyStartup.B64_MAP = map
    return map
end

function JimiProxyStartup.decodeBase64(data)
    JimiProxyStartup.need(type(data) == "string" and #data > 0, "empty Base64")
    JimiProxyStartup.need(#data % 4 == 0, "invalid Base64 length")

    local map = JimiProxyStartup.b64Map()
    local chunks, buf, count = {}, {}, 0
    for i = 1, #data, 4 do
        if type(sleep) == "function" and i % 32768 == 1 then sleep(1) end

        local c1, c2, c3, c4 = string.byte(data, i, i + 3)
        local a = map[c1]
        local b = map[c2]
        local c = (c3 == 61) and 0 or map[c3]
        local d = (c4 == 61) and 0 or map[c4]
        JimiProxyStartup.need(a ~= nil and b ~= nil and c ~= nil and d ~= nil, "invalid Base64 data")

        local n = a * 262144 + b * 4096 + c * 64 + d
        count = count + 1
        buf[count] = string.char(math.floor(n / 65536) % 256)
        if c3 ~= 61 then
            count = count + 1
            buf[count] = string.char(math.floor(n / 256) % 256)
        end
        if c4 ~= 61 then
            count = count + 1
            buf[count] = string.char(n % 256)
        end
        if count >= 24576 then
            chunks[#chunks + 1] = table.concat(buf)
            buf, count = {}, 0
        end
    end
    if count > 0 then chunks[#chunks + 1] = table.concat(buf) end
    return table.concat(chunks)
end

function JimiProxyStartup.fetchText(url, expectedSize)
    local okCall, body, fetchErr = pcall(function() return fetch(url) end)
    JimiProxyStartup.need(okCall, "fetch call failed")
    JimiProxyStartup.need(type(body) == "string", "fetch failed: " .. tostring(fetchErr or "no text response"))
    JimiProxyStartup.need(#body > 0, "empty transport")
    JimiProxyStartup.need(
        #body == expectedSize,
        "transport size mismatch " .. tostring(#body) .. "/" .. tostring(expectedSize)
    )
    return body
end

function JimiProxyStartup.writeSound()
    local transport = JimiProxyStartup.fetchText(JimiProxyStartup.SOUND_URL, JimiProxyStartup.SOUND_B64_SIZE)
    local bytes = JimiProxyStartup.decodeBase64(transport)
    transport = nil
    pcall(collectgarbage, "step", 256)

    JimiProxyStartup.need(
        #bytes == JimiProxyStartup.SOUND_RAW_SIZE,
        "sound decoded size mismatch " .. tostring(#bytes) .. "/" .. tostring(JimiProxyStartup.SOUND_RAW_SIZE)
    )
    JimiProxyStartup.need(bytes:sub(1, 4) == "RIFF", "invalid WAV")
    JimiProxyStartup.need(bytes:sub(9, 12) == "WAVE", "invalid WAV")
    local r1, r2, r3, r4 = bytes:byte(5, 8)
    local riffSize = r1 + r2 * 256 + r3 * 65536 + r4 * 16777216
    JimiProxyStartup.need(riffSize + 8 == #bytes, "invalid WAV length")
    local okWrite, writeErr = pcall(function()
        return writeToLocal(JimiProxyStartup.SOUND_FILE, bytes, false)
    end)
    if not okWrite then
        okWrite, writeErr = pcall(function()
            return writeToLocal(JimiProxyStartup.SOUND_FILE, bytes)
        end)
    end
    bytes = nil
    pcall(collectgarbage, "step", 512)
    JimiProxyStartup.need(okWrite and writeErr~=false, "sound write failed: " .. tostring(writeErr))
end

function JimiProxyStartup.localFileValid(filename)
    local fn=(type(fileExists)=="function" and fileExists) or (type(isFileExist)=="function" and isFileExist)
    if not fn then return nil end
    local ok,value=pcall(fn,JimiProxyStartup.basePath()..filename)
    if ok and type(value)=="boolean" then return value end
    return nil
end

function JimiProxyStartup.installAssets(pref)
    JimiProxyExt.UI.prepare(true)
    JimiProxyStartup.writeSound()
    JimiProxyStartup.markCached(pref)
end

function JimiProxyStartup.playSound()
    local base = JimiProxyStartup.basePath()
    sendVar({
        v1 = "OnAddNotification",
        v2 = "interface/large/adventure.rttex",
        v3 = "JimiProxy",
        v4 = base .. JimiProxyStartup.SOUND_FILE
    })
end

function JimiProxyStartup.showBanner()
    
    return JimiProxyExt.showNews()
end

function JimiProxyStartup.launchLocal()
    JimiProxyStartup.playSound()
    if type(sleep) == "function" then sleep(100) end
    JimiProxyExt.showNews()
end

function JimiProxyStartup.run()
    JimiProxyExt.UI.prepare(false)
    local pref=JimiProxyStartup.openPreferences()
    local cached=JimiProxyStartup.cachedVersion(pref)==JimiProxyStartup.ASSET_VERSION
    if not cached or JimiProxyStartup.localFileValid(JimiProxyStartup.SOUND_FILE)==false then
        JimiProxyStartup.writeSound()
        JimiProxyStartup.markCached(pref)
    end
    JimiProxyStartup.launchLocal()
end

function JimiProxyStartup.start(force)
    if JimiProxyStartup.running then return false end
    JimiProxyStartup.running=true
    local runner=function()
        local ok,err=pcall(function()
            if force then
                JimiProxyStartup.installAssets(JimiProxyStartup.openPreferences())
                JimiProxyStartup.launchLocal()
            else JimiProxyStartup.run()end
        end)
        JimiProxyStartup.running=false
        if not ok then JimiProxyStartup.reportError("startup",err)end
    end
    if type(runThread)=="function" then
        local ok,err=pcall(runThread,runner)
        if not ok then JimiProxyStartup.running=false;JimiProxyStartup.reportError("startup",err);return false end
    else runner()end
    return true
end

JimiProxyAutoStatus = JimiProxyAutoStatus or {shown=false}

function JimiProxyAutoStatus.tryShow()
    if JimiProxyAutoStatus.shown then return false end
    local w=tostring(worldName() or "")
    if w=="" or w:upper()=="EXIT" then return false end
    local me=safe(getLocal)
    if type(me)~="table" then return false end
    JimiProxyAutoStatus.shown=true
    say("`2Login successful.")
    say("`6Wealth: `w"..tostring(LockTools.totalValue()).." WL")
    return true
end

local function onGame(pkt)
    if type(pkt) ~= "table" then return false end
    local tp = tonumber(pkt.type) or -1

    JimiProxyGuard.onGame(pkt)
    JimiProxyEntrance.onGame(pkt)

    if tp == 4 then
        JimiProxyPullTile.resetWorld()
        JimiProxyGuard.resetWorld()
        JimiProxySession.onWorldLoad()
        JimiProxyVends.clear()
        JimiProxyFollowChat.onWorldChange()
        JimiProxyMods.onWorldChange()
        JimiProxyHidden.onWorldChange()
        JimiProxyStream.onWorldChange()
        JimiProxyDaily.resetWorld()
        JimiProxyExt.resetAutoJoinWorld()
        JimiProxyExt.inventoryTxn = ""
        LockTools.busy = false
        converting = false
        pendingDrops = {}
        runThread(function()
            sleep(450)
            GemNumber.lastWorld = GemNumber.worldName()
            GemNumber.resetWorld()
            ManualGem.reset()
            JimiProxyAutoStatus.tryShow()
        end)
    elseif tp == 14 then
        GemNumber.trigger()
        ManualGem.trigger()
    end

    return false
end

local function onRaw(pkt)
    if JimiProxyDaily.onSendPacketRaw(pkt) then return true end
    GemNumber.punch(pkt)
    return false
end

addHook(onVar, "onVariant")
addHook(onPkt, "onSendPacket")
addHook(onRaw, "onSendPacketRaw")
addHook(onGame, "onGamePacket")
addHook(function(kind,name,value)JimiProxyHotkeys.onValue(kind,name,value);return false end,"onValue")
if type(applyHook) == "function" then applyHook() end
GemNumber.start()
ManualGem.reset()
JimiProxyEntrance.start()
runThread(function()
    sleep(700)
    JimiProxyAutoStatus.tryShow()
end)

runThread(function()
    while true do
        sleep(300000)
        local now = ms()
        for k, ts in pairs(recentSpin) do
            if now - ts > 10000 then recentSpin[k] = nil end
        end
    end
end)
runThread(function()
    for _ = 1, 10 do
        sleep(500)
        if applyNick() then break end
    end
end)

JimiProxyHotkeys.init()
JimiProxyStartup.start()
