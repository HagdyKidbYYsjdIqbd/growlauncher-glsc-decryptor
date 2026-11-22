-- Surg-E Helper 1.4-r0 by Jimi
-- Auto surgery for Growtopia (GrowLauncher).
--
-- Modes   : Auto - Player (wrench a player, surgery starts right away), Auto - Surg-E (wrenches Surg-E for you), Manual (helper).
-- Commands: /surg opens the menu, /sdelay sets the auto delay.
-- Tweaks  : constants below (FAST_SURG, SPONGE_BEFORE_PINS, SPONGE_BEFORE_SCALPEL, PRIZE_STRICT, LOG_LAYOUT, LOW_WARN, ...).
local DEBUG = false
local MAX_CUT = 8
local LOG_STATE = false
local REPEAT_MAX = 4  -- same tool repeated with no change in the patient: skip it for a while
local STUCK_NOPROG = 8  -- dialogs in a row with no change: the surgery counts as stuck (Auto gives up)
local GIVEUP_TURNS = 80  -- hard cap on moves per surgery (normal ones stay well below)
local LOW_WARN = 20  -- warn when any tool is at or below this
local LOW_REPEAT = 90  -- seconds between repeated warnings
local TAKE_SKIP_SEC = 90  -- seconds to skip an item that could not be picked up
local FAST_SURG = true  -- Player modes: wrenching a player starts the surgery right away (no profile popup)
local SPONGE_BEFORE_PINS = false  -- true: Sponge first when the view is blurry, before Pins (safer, uses more Sponge)
local SPONGE_BEFORE_SCALPEL = false  -- true: Sponge first when the view is blurry, before Scalpel (safer, uses more Sponge)
local LOG_LAYOUT = "tiles"  -- "tiles" (icon boxes) or "rows" (one line per item)

local function useSelf(id)
    local p = getLocal()
    if not p then return false end
    sendPacketRaw(false, {
        type = 3, value = id,
        x = p.posX, y = p.posY,
        px = math.floor(p.posX / 32), py = math.floor(p.posY / 32)
    })
    return true
end

local ITEM_ID = 5114
local TEA_DEFAULT_MIN = 2
local SPICE_DEFAULT_MIN = 30
local BUFF_DELAY_MIN, BUFF_DELAY_MAX = 1, 180
local NEED_TEA = true

local CADUCEUS_ID = 4298
local GOLDEN_ID   = 4300
local GOLDEN_AT   = 100

local SURGE_ID  = 4296
local PUT_MAX   = 5

local LEGAL_ID = 3172
local SPICE_ID = 6912
local WRENCH_ID = 32
local IDLE_SEC  = 5
local WRENCH_GAP = 10
local SURG_TIMEOUT = 60
local MIN_TOOL  = 10
local AUTO_WALK = true
local REACH     = 1
local REACH_Y   = 2
local PUT_REACH = 2
local WALK_TIMEOUT = 15

local DELAY_MIN, DELAY_MAX = 0, 10000

local T = {
    Sponge      = 1258,
    Scalpel     = 1260,
    Anesthetic  = 1262,
    Antiseptic  = 1264,
    Antibiotic  = 1266,
    Splint      = 1268,
    Stitches    = 1270,
    FixIt       = 1296,
    Pins        = 4308,
    Transfusion = 4310,
    Defib       = 4312,
    Clamp       = 4314,
    Ultrasound  = 4316,
    LabKit      = 4318,
}

local NAME = {}
for k, v in pairs(T) do NAME[v] = k end
NAME[4296], NAME[3172], NAME[6912], NAME[5114] = "Surg-E", "Legal Briefs", "Skill Spice", "Tea"

local UI_THEMES = {
    red =    {name = "Red",    color = "`4", border = "205,78,90,255",  bg = "74,30,38,220",  desc = "Warm red interface theme."},
    purple = {name = "Purple", color = "`5", border = "112,86,191,255", bg = "43,34,74,200",  desc = "Classic purple theme."},
    blue =   {name = "Default+", color = "`1", border = "55,170,245,255", bg = "24,58,94,220",  desc = "Default blue interface theme."},
    yellow = {name = "Yellow", color = "`e", border = "240,201,72,255", bg = "82,70,24,220",  desc = "Bright golden interface theme."},
    green =  {name = "Green",  color = "`2", border = "74,194,118,255", bg = "27,72,54,220",  desc = "Fresh green interface theme."},
    black =  {name = "Black",  color = "`0", border = "95,105,120,255", bg = "18,18,23,225", desc = "Dark minimal interface theme."}
}
local THEME_ORDER = { "blue", "red", "purple", "yellow", "green", "black" }

AUTOSURG_GEN = (tonumber(rawget(_G, "AUTOSURG_GEN")) or 0) + 1
local MY_GEN = AUTOSURG_GEN
local function stale() return AUTOSURG_GEN ~= MY_GEN end

-- mode: "off" | "auto" | "manual"
-- kind (when mode is "auto"): "player" = you wrench the player yourself, "surge" = wrenches Surg-E for you
CFG = { mode = "off", kind = "player", guard = true, delay = 600, teaDelay = TEA_DEFAULT_MIN, spiceDelay = SPICE_DEFAULT_MIN,
        theme = "blue", wrench = false, tea = false, golden = false, legal = false, spice = false, putsurge = false, take = false }

local LOVE_MALLET = 9310
NAME[LOVE_MALLET] = "LoveMallet"

local saved

local function clampDelay(n)
    n = math.floor(tonumber(n) or 600)
    if n < DELAY_MIN then n = DELAY_MIN elseif n > DELAY_MAX then n = DELAY_MAX end
    return n
end

local function clampBuffDelay(n, defaultValue)
    n = math.floor(tonumber(n) or defaultValue)
    if n < BUFF_DELAY_MIN then n = BUFF_DELAY_MIN elseif n > BUFF_DELAY_MAX then n = BUFF_DELAY_MAX end
    return n
end

local function persist()
    if not saved then return end
    saved:set("cfg_guard", CFG.guard and "1" or "0")
    saved:set("cfg_theme", CFG.theme)
    saved:set("cfg_delay", tostring(CFG.delay))
    saved:set("cfg_tea_delay", tostring(CFG.teaDelay))
    saved:set("cfg_spice_delay", tostring(CFG.spiceDelay))
    saved:set("cfg_kind", CFG.kind)
    saved:save()
end

local function loadCfg()
    if not saved then return end
    CFG.guard = saved:get("cfg_guard", "1") == "1"
    local th = saved:get("cfg_theme", "blue")
    if UI_THEMES[th] then CFG.theme = th end
    local d = tonumber(saved:get("cfg_delay", "600"))
    if d then CFG.delay = clampDelay(d) end
    CFG.teaDelay = clampBuffDelay(saved:get("cfg_tea_delay", tostring(TEA_DEFAULT_MIN)), TEA_DEFAULT_MIN)
    CFG.spiceDelay = clampBuffDelay(saved:get("cfg_spice_delay", tostring(SPICE_DEFAULT_MIN)), SPICE_DEFAULT_MIN)
    local k = saved:get("cfg_kind", "player")
    if k == "player" or k == "surge" then CFG.kind = k end
end

local function setToggle(key, v)
    CFG[key] = v and true or false
    persist()
end

local S = { fixed = false, lastTool = nil, lab = false, lastTemp = nil, flu = false, ban = {}, turn = 0, used = {} }

local function resetState()
    S.fixed, S.lastTool, S.lab, S.lastTemp, S.flu, S.ban = false, nil, false, nil, false, {}
    S.fixedReal, S.fixSeen = false, false
    S.turn, S.used = 0, {}
    S.lupus, S.worms, S.noseJob, S.hs = false, false, false, 0
    S.preAnt, S.preAbx, S.usCount, S.labCount = 0, 0, 0, 0
    S.sig, S.noProg, S.st0, S.cutDone, S.heartProne = nil, 0, 0, false, false
    S.lastP, S.lastRaw, S.blockedAt, S.reshowRaw = nil, nil, {}, nil
end

local function clog() end

local function notify(msg)
    clog("`9[`2AutoSurg`9] " .. msg)
    pcall(growtopia.notify, msg)
end

local function setDelay(n)
    CFG.delay = clampDelay(n)
    persist()
    notify("`9Delay set to `0" .. CFG.delay .. " ms")
end

local function since(id)
    return S.used[id] and (S.turn - S.used[id]) or 99
end

local function newStats() return { ok = 0, fail = 0, abort = 0, why = {}, tools = {}, items = {}, disOk = {}, disFail = {} } end
local SES, ALL, RUN = newStats(), newStats(), nil
local TOOL_SET = {}
for _, id in pairs(T) do TOOL_SET[id] = true end
local function bump(t, k, n) t[k] = (t[k] or 0) + (n or 1) end

local function ser(t)
    local a = {}
    for k, v in pairs(t) do a[#a + 1] = tostring(k) .. ":" .. tostring(v) end
    return table.concat(a, ",")
end
local function deser(str, numKey)
    local t = {}
    for k, v in tostring(str or ""):gmatch("([^:,]+):(%d+)") do t[numKey and tonumber(k) or k] = tonumber(v) end
    return t
end
local function persistLogs()
    if not saved then return end
    saved:set("log_ok", tostring(ALL.ok)); saved:set("log_fail", tostring(ALL.fail)); saved:set("log_abort", tostring(ALL.abort))
    saved:set("log_why", ser(ALL.why)); saved:set("log_tools", ser(ALL.tools)); saved:set("log_items", ser(ALL.items))
    saved:set("log_disok", ser(ALL.disOk)); saved:set("log_disfail", ser(ALL.disFail))
    saved:save()
end
local function loadLogs()
    if not saved then return end
    ALL.ok = tonumber(saved:get("log_ok", "0")) or 0
    ALL.fail = tonumber(saved:get("log_fail", "0")) or 0
    ALL.abort = tonumber(saved:get("log_abort", "0")) or 0
    ALL.why = deser(saved:get("log_why", ""), false)
    ALL.tools = deser(saved:get("log_tools", ""), true)
    ALL.items = deser(saved:get("log_items", ""), true)
    ALL.disOk = deser(saved:get("log_disok", ""), false)
    ALL.disFail = deser(saved:get("log_disfail", ""), false)
end
local function resetLogs()
    SES, ALL = newStats(), newStats()
    persistLogs()
end

local function itemName(id)
    for _, fn in ipairs({ "getItemInfoByID", "getItemInfo" }) do
        local f = _G[fn]
        if type(f) == "function" then
            local ok, info = pcall(f, id)
            if ok then
                if type(info) == "table" then
                    local nm = info.name or info.itemName
                    if type(nm) == "string" and nm ~= "" then return nm end
                elseif type(info) == "string" and info ~= "" then
                    return info
                end
            end
        end
    end
    return "Item #" .. tostring(id)
end

local function invSnapshot()
    local snap = {}
    for _, it in pairs(getInventory() or {}) do snap[it.id] = (snap[it.id] or 0) + it.amount end
    return snap
end

local DISEASES = {
    { "broken arm", "Broken Arm" }, { "broke his arm", "Broken Arm" }, { "broke her arm", "Broken Arm" }, { "broke their arm", "Broken Arm" },
    { "broken leg", "Broken Leg" }, { "broke his leg", "Broken Leg" }, { "broke her leg", "Broken Leg" }, { "broke their leg", "Broken Leg" },
    { "bird flu", "Bird Flu" }, { "turtle flu", "Turtle Flu" }, { "monkey flu", "Monkey Flu" },
    { "nose job", "Nose Job" }, { "lung tumor", "Lung Tumor" }, { "heart attack", "Heart Attack" }, { "brain tumor", "Brain Tumor" },
    { "liver infection", "Liver Infection" }, { "kidney failure", "Kidney Failure" }, { "appendicitis", "Appendicitis" },
    { "world lock", "Swallowed World Lock" }, { "herniated disc", "Herniated Disc" }, { "broken everything", "Broken Everything" },
    { "head injury", "Head Injury" }, { "serious trauma", "Serious Trauma" }, { "massive trauma", "Massive Trauma" },
    { "punching muscle", "Torn Punching Muscle" }, { "gem cut", "Gem Cuts" }, { "broken heart", "Broken Heart" },
    { "grumbleteeth", "Grumbleteeth" }, { "chicken feet", "Chicken Feet" }, { "chaos infection", "Chaos Infection" },
    { "lupus", "Lupus" }, { "brainworm", "Brainworms" }, { "moldy guts", "Moldy Guts" },
    { "ecto-bones", "Ecto-Bones" }, { "ecto bones", "Ecto-Bones" }, { "fatty liver", "Fatty Liver" }, { "love struck", "Love Struck" },
}
local function noteDiseases(lowerText)
    if not RUN or RUN.done then return end
    for _, d in ipairs(DISEASES) do
        if lowerText:find(d[1], 1, true) then RUN.dis[d[2]] = true end
    end
    if S.lupus then RUN.dis["Lupus"] = true end
    if S.noseJob then RUN.dis["Nose Job"] = true end
    if S.flu then RUN.flu = true end
end
local function runDiseases(r)
    local list = {}
    for k in pairs(r.dis) do list[#list + 1] = k end
    if #list == 0 and r.flu then list[1] = "Flu" end
    if #list == 0 then list[1] = "Unknown" end
    table.sort(list)
    return list
end

local function startRun() RUN = { tools = {}, snap = invSnapshot(), done = false, dis = {}, flu = false, trace = {} } end
local function logTool(id)
    if RUN and not RUN.done then
        bump(RUN.tools, id)
        RUN.since = RUN.since or {}
        bump(RUN.since, id)  -- tools used since the last snapshot
    end
end

local function abortRun()
    local r = RUN
    if not r or r.done then return end
    r.done = true
    if next(r.tools) == nil then return end
    for _, st in ipairs({ SES, ALL }) do
        st.abort = st.abort + 1
        for id, n in pairs(r.tools) do bump(st.tools, id, n) end
    end
    persistLogs()
end

-- ===== Webhook ke hijimi.site (hasil surgery -> Discord, total global dihitung di server) =====
local SURG_API = "https://hijimi.site/api/jimiproxy/surg"
local function surgEnc(v)
    return (tostring(v or ""):gsub("([^%w%-%._~])", function(c) return string.format("%%%02X", string.byte(c)) end))
end
local function sendSurgWebhook(ok, why, dis, trace, items)
    if type(fetch) ~= "function" then return end
    local p = getLocal()
    local growid = tostring(p and p.name or "Unknown"):gsub("`.", ""):gsub("^@", "")
    local url = SURG_API
        .. "?growid=" .. surgEnc(growid)
        .. "&ok=" .. (ok and "1" or "0")
        .. "&disease=" .. surgEnc(table.concat(dis or {}, ", "):sub(1, 100))
        .. "&why=" .. surgEnc(why or "")
    if ok and items and #items > 0 then
        local parts = {}
        for i, it in ipairs(items) do
            if i > 10 then break end
            parts[#parts + 1] = (tostring(it.name):gsub("[;%*]", " ")) .. "*" .. it.count
        end
        url = url .. "&items=" .. surgEnc(table.concat(parts, ";"):sub(1, 480))
    end
    if not ok and trace and #trace > 0 then
        url = url .. "&trace=" .. surgEnc(table.concat(trace, " > "):sub(-400))
    end
    runThread(function() pcall(fetch, url) end)
end

-- World objects come from getObjectList() (GrowLauncher docs: WorldObject has pos, itemid, amount, invbit, id). The other names are only fallbacks.
-- Surgery prize list (Growtopia wiki, Surgery Rewards). Items outside it, like Diamond Lock, are never counted as a prize.
-- A new prize that is not on the wiki yet will not show up. Set PRIZE_STRICT = false to accept any new item.
local PRIZE_STRICT = true
local PRIZE_IDS = {}
for _, id in ipairs({ 4298,
    1242, 1244, 1246, 1248, 1282, 1284, 1286, 1290, 1292, 1288, 1294, 1256, 2586, 782, 3536, 764, 4176, 4322, 2976, 4080, 3790,
    4990, 8954, 1506, 1274, 1252, 8284, 2992, 3172, 10092, 11224, 9000, 10112, 10094, 13698, 14676, 14690, 14678, 14672, 14688,
    14686, 12450, 14674, 14682, 14684, 5482, 4328, 4330, 4326, 10570, 4324, 4334, 11086, 11088, 11090, 11092, 11076, 14680, 8534,
    8478, 8480, 11488, 8486, 12456, 12458, 12460, 12462, 14250, 8484, 8482, 8466, 8468, 8494, 8458, 8490, 8456, 8472, 8470, 8496,
    8452, 8454, 8488, 13686, 8474, 8476, 8498, 8460, 8492, 14670, 8446, 8550, 8450, 8442, 8448, 8444,
    6398, 6426, 6340, 6342, 6350, 6818, 8244, 8242, 8240, 14664, 15124,
    13034, 11566, 14156, 13158, 11674, 13138, 10638, 9312, 9316, 9320, 9314, 14264, 14340, 10774, 11770, 15388, 16088, 11872,
    6114, 11036, 12224, 9738, 12566, 12568, 10168, 11288, 12640, 13936, 14836, 15694, 16408, 10216, 12778, 3204, 15084, 2240 }) do
    PRIZE_IDS[id] = true
end
for _, id in pairs(T) do PRIZE_IDS[id] = true end -- tool x5
PRIZE_IDS[T.FixIt] = nil
PRIZE_IDS[9310] = nil  -- Love Mallet is not a prize
local NEVER_PRIZE = { [242] = true, [1796] = true, [7188] = true } -- WL / DL / BGL are never surgery rewards
local function validPrize(id)
    return id and id ~= GOLDEN_ID and not NEVER_PRIZE[id] and (PRIZE_IDS[id] or not PRIZE_STRICT)
end

local OBJ_FUNCS = { "getObjectList", "getObjects", "getWorldObjects", "getDroppedItems", "getObjectsList" }
local OBJ_FN_NAME
local function listObjects()
    for _, name in ipairs(OBJ_FUNCS) do
        local f = rawget(_G, name)
        if type(f) == "function" then
            local ok, res = pcall(f)
            if ok and type(res) == "table" then OBJ_FN_NAME = name; return res, name end
        end
    end
    return nil
end

-- GrowLauncher docs (struct WorldObject): pos (Vector2, pixels), itemid (item id), amount, invbit, id (unique object id).
local function objTile(o)
    if type(o.pos) == "table" and o.pos.x and o.pos.y then
        return math.floor(o.pos.x / 32 + 0.5), math.floor(o.pos.y / 32 + 0.5)
    end
    local x = tonumber(o.x or o.posX or o.px)
    local y = tonumber(o.y or o.posY or o.py)
    if not x or not y then return nil end
    if x > 120 or y > 120 then x, y = x / 32, y / 32 end
    return math.floor(x + 0.5), math.floor(y + 0.5)
end


-- Snapshot of dropped items in the world, keyed by object id. Returns nil when the object list is not available.
local function objSnapshot()
    local objs = listObjects()
    if not objs then return nil end
    local m = {}
    for _, o in pairs(objs) do
        local id = tonumber(o.itemid or o.itemID or o.itemId)
        local tx, ty = objTile(o)
        if id and tx then
            -- key = unique object id, so items that move do not look new
            local k = o.id and ("o" .. tostring(o.id)) or (id .. ":" .. tx .. ":" .. ty)
            local n = tonumber(o.amount) or 1
            if m[k] then m[k].n = m[k].n + n else m[k] = { id = id, x = tx, y = ty, n = n } end
        end
    end
    return m
end

local function finishRun(ok, why)
    local r = RUN
    if not r or r.done then return end
    r.done = true
    local dis = runDiseases(r)
    if not ok then sendSurgWebhook(false, why, dis, r.trace) end
    for _, st in ipairs({ SES, ALL }) do
        if ok then st.ok = st.ok + 1 else st.fail = st.fail + 1; bump(st.why, why or "other") end
        for id, n in pairs(r.tools) do bump(st.tools, id, n) end
        for _, name in ipairs(dis) do bump(ok and st.disOk or st.disFail, name) end
    end
    persistLogs()
    if ok then
        -- The prize goes straight into the inventory. Compare it with the snapshot from the last dialog (before the final tool tap);
        -- tools used since then are added back, so a x5 tool prize still shows up even though stock went down.
        runThread(function()
            local function collect()
                -- Inventory delta from the last surgery dialog. If a pre-existing ground object disappears near us,
                -- treat that amount as a pickup and subtract it so tagged/Auto-Take items do not become surgery rewards.
                local cur = {}
                for _, it in pairs(getInventory() or {}) do cur[it.id] = (cur[it.id] or 0) + it.amount end
                local after = r.objs and objSnapshot()
                local me = getLocal()
                local picked = {}
                local mx, my
                if me then mx, my = math.floor(me.posX / 32), math.floor(me.posY / 32) end
                if r.objs and after and mx then
                    for k, before in pairs(r.objs) do
                        local now = after[k]
                        local d = before.n - (now and now.n or 0)
                        if d > 0 and math.abs(before.x - mx) <= 4 and math.abs(before.y - my) <= 4 then
                            picked[before.id] = (picked[before.id] or 0) + d
                        end
                    end
                end

                local gained = {}
                for id, amt in pairs(cur) do
                    local d = amt - (r.snap[id] or 0) + ((r.since and r.since[id]) or 0) - (picked[id] or 0)
                    if d > 0 and validPrize(id) then gained[id] = d end
                end

                -- Full backpack: a real surgery reward can appear as a new/increased world object after the final tool.
                if after and r.objs and mx then
                    local drop = {}
                    for k, o in pairs(after) do
                        local d = o.n - ((r.objs[k] and r.objs[k].n) or 0)
                        if d > 0 and validPrize(o.id)
                            and math.abs(o.x - mx) <= 4 and math.abs(o.y - my) <= 4 then
                            drop[o.id] = (drop[o.id] or 0) + d
                        end
                    end
                    for id, d in pairs(drop) do
                        gained[id] = math.max(gained[id] or 0, d)
                    end
                end
                return gained
            end
            local gained = {}
            for attempt = 1, 3 do
                sleep(attempt == 1 and 1500 or 1200)
                if stale() then return end
                gained = collect()
                if next(gained) ~= nil then
                    sleep(700) -- hadiah kedua (misal Caduceus) kadang masuk sedikit telat
                    if stale() then return end
                    gained = collect()
                    break
                end
            end
            if not W.detectNoted then
                W.detectNoted = true
                if r.objs then
                    notify("`9Item tracking is on (inventory + dropped items)")
                else
                    notify("`4Can't see dropped items, only your inventory. Items that drop because your backpack is full won't show up")
                end
            end
            local list = {}
            for id, d in pairs(gained) do list[#list + 1] = { id = id, name = itemName(id), count = d } end
            table.sort(list, function(a, b)
                if a.count ~= b.count then return a.count > b.count end
                return a.name < b.name
            end)
            for _, st in ipairs({ SES, ALL }) do for id, d in pairs(gained) do bump(st.items, id, d) end end
            persistLogs()
            sendSurgWebhook(true, why, dis, r.trace, list)
        end)
    end
end

local function use(id)
    S.lastTool = id
    S.used[id] = S.turn
    if id == T.LabKit then S.labCount = (S.labCount or 0) + 1 end
    if id == T.Stitches and S.lastP and S.lastP.incisions == 0 then S.st0 = (S.st0 or 0) + 1 end
    if id == T.Ultrasound then S.usCount = (S.usCount or 0) + 1 end
    SendPacket(2, "action|dialog_return\ndialog_name|surgery\nbuttonClicked|tool" .. id)
    logTool(id)
    clog("`9[`2AutoSurg`9] `c" .. (NAME[id] or id))
end

local function parse(raw)
    local c = raw:gsub("`.", "")
    local P = {}

    local function has(id)
        if (S.ban[id] or 0) > 0 then return false end
        return raw:find("tool" .. id, 1, true) ~= nil
    end
    P.has = has

    P.status    = (c:match("Status: ([%a ]+)") or ""):lower()
    P.incisions = tonumber(c:match("Incisions: (%d+)")) or 0
    P.pulse     = (c:match("Pulse: ([%a ]+)") or ""):lower()
    P.temp      = tonumber(c:match("Temp: ([%d%.]+)")) or 98.6
    P.site      = (c:match("Operation site: ([%a ]+)") or ""):lower()
    P.broken    = tonumber(c:match("(%d+) broken")) or 0
    P.shattered = tonumber(c:match("(%d+) shattered")) or 0

    P.heartStopped = c:find("[Hh]eart stopped") or c:find("heart has stopped")
    P.awake        = P.status:find("awake") ~= nil
    P.comingTo     = P.status:find("coming to") ~= nil

    P.asleep       = not P.awake and not P.comingTo
    P.nearComa     = P.status:find("coma") ~= nil
    if P.status == "" then
        P.awake  = since(T.Anesthetic) >= 8
        P.asleep = not P.awake
    end
    P.bleeding     = c:find("losing blood") or c:find("loosing blood")
    P.bleedFast    = c:find("quickly")
    P.bleedMed     = c:find("losing blood!")
    P.dirtyBad     = c:find("can't see what you are doing")
    P.dirtyMild    = c:find("to see your work")
    P.feverUp      = c:find("fever is") ~= nil
    P.undiagnosed  = c:find("not been diagnosed")

    -- his/her/their all count (it used to match "his" only)
    P.flu          = c:find("flu%.") ~= nil
    P.noSurgery    = c:find("flu%.") or c:find("broke %a+ arm") or c:find("broke %a+ leg")
    return P, c
end

local function cutLimit() return S.noseJob and 1 or MAX_CUT end

local function decideCore(P)
    local tempFalling = S.lastTemp and P.temp < S.lastTemp
    -- Stitches without an incision: at most 4 per surgery (stops endless stitching)
    local st0ok = (S.st0 or 0) < 4

    if P.dirtyBad and P.has(T.Sponge) then return T.Sponge end

    -- Heart stopped + hard to see: Sponge first, then Defib (wiki advice). A blurry view makes Defib fail more often.
    if P.heartStopped then
        if P.dirtyMild and (S.hs or 1) <= 1 and P.has(T.Sponge) then return T.Sponge end
        return T.Defib
    end

    if P.has(LOVE_MALLET) then return LOVE_MALLET end

    if S.lupus and (P.awake or P.comingTo) and P.has(T.Anesthetic) then return T.Anesthetic end

    if (P.awake or P.comingTo) and P.incisions > 0 then if P.has(T.Anesthetic) then return T.Anesthetic end end

    if (S.fixedReal or (S.fixed and P.noSurgery)) and P.incisions > 0 and P.shattered == 0 and P.asleep
        and P.temp < 100.5
        and not (S.worms and since(T.FixIt) < 4)
        and P.has(T.Stitches) then return T.Stitches end

    if P.pulse:find("extremely weak") then
        if not P.asleep and P.has(T.Anesthetic) then return T.Anesthetic end

        if P.bleeding and P.incisions > 0 and S.lastTool == T.Transfusion and P.has(T.Clamp) then
            return T.Clamp
        end
        if P.has(T.Transfusion) then return T.Transfusion end
    end

    -- Flu: Antibiotic stays locked until the Lab Kit is used, so use the Lab Kit on the first move instead of waiting for the fever.
    if (P.flu or S.flu) and not S.lab and (S.labCount or 0) < 2 and P.has(T.LabKit) then return T.LabKit end

    if P.has(T.FixIt) and P.temp < 106 then return T.FixIt end

    -- Heavy bleeding from the start with a weak pulse (Head Injury): Transfusion first for a blood buffer, then Stitches
    if P.bleedFast and P.incisions == 0 and P.pulse:find("weak") and not P.pulse:find("extremely")
        and since(T.Transfusion) >= 2 and P.temp < 105 and P.has(T.Transfusion) then
        return T.Transfusion
    end

    if P.bleedFast and P.temp < 105 then
        if P.incisions > 0 and P.has(T.Clamp) then return T.Clamp end
        if P.incisions == 0 and st0ok and P.has(T.Stitches) then return T.Stitches end
    end

    -- Blood before fever: bleeding with a weak pulse and a safe temperature is handled first. Otherwise Antibiotic wins over slow/medium bleeding,
    -- and feverish patients (Liver Infection, Appendicitis) bleed out while the temperature comes down.
    if P.bleeding and P.pulse:find("weak") and P.temp < 104 then
        if P.incisions == 0 and st0ok and P.has(T.Stitches) then return T.Stitches end
        if P.incisions > 0 and P.has(T.Clamp) and since(T.Clamp) >= 2 then return T.Clamp end
        if since(T.Transfusion) >= 2 and P.has(T.Transfusion) then return T.Transfusion end
    end

    -- Antibiotic starts earlier: flu from 99, a climbing fever from 99.5, everything else from 100
    local feverFrom = (P.flu or S.flu) and 99 or (P.feverUp and 99.5 or 100)
    if P.temp >= feverFrom and (P.feverUp or not tempFalling or P.flu or S.flu) then
        if not S.lab and P.has(T.LabKit) then if P.has(T.LabKit) then return T.LabKit end end
        if P.has(T.Antibiotic) then if P.has(T.Antibiotic) then return T.Antibiotic end end
    end

    if P.bleeding and P.incisions > 0 and P.has(T.Clamp) and since(T.Clamp) >= 2 then
        return T.Clamp
    end

    if P.bleeding and P.incisions == 0 and st0ok and P.has(T.Stitches) then return T.Stitches end
    if (P.bleedFast or P.bleedMed) and P.has(T.Clamp) then return T.Clamp end

    -- unsanitary/unclean site with incisions or bleeding starts a fever: Antiseptic every 2 moves (unsanitary) or 3 (unclean)
    if (P.site:find("unsanitary") or P.site:find("unclean"))
        and (P.incisions > 0 or P.bleeding) and P.has(T.Antiseptic)
        and since(T.Antiseptic) >= (P.site:find("unsanitary") and 2 or 3) then
        return T.Antiseptic
    end

    -- Ultrasound once (up to 3 tries if it skill-fails)
    if P.undiagnosed and (S.usCount or 0) < 3 and P.has(T.Ultrasound) then return T.Ultrasound end

    if P.has(T.FixIt) then return T.FixIt end

    if P.shattered > 0 then
        if P.incisions > 0 and P.has(T.Pins) then if P.has(T.Pins) then return T.Pins end end
        if not P.asleep then if P.has(T.Anesthetic) then return T.Anesthetic end end
        if P.has(T.Scalpel) then return T.Scalpel end
    end

    if P.broken > 0 then if P.has(T.Splint) then return T.Splint end end

    if not S.fixed and not P.noSurgery and P.incisions < cutLimit() and not S.fixSeen and not S.cutDone then
        if not P.asleep then if P.has(T.Anesthetic) then return T.Anesthetic end end
        -- Every extra cut adds bleeding: with a weak pulse, give blood first (at most once per 3 moves)
        if P.incisions >= 1 and P.pulse:find("weak") and since(T.Transfusion) >= 3 and P.has(T.Transfusion) then
            return T.Transfusion
        end
        if P.has(T.Scalpel) then return T.Scalpel end
    end

    -- Cut limit reached but Fix It never showed up: stop cutting (otherwise it loops stitch -> cut -> stitch)
    if not S.fixed and P.incisions >= cutLimit() then S.cutDone = true end
    if P.incisions > 0 and (S.fixed or P.incisions >= cutLimit() or S.cutDone)
        and not (S.worms and S.fixed and since(T.FixIt) < 4) then
        if P.has(T.Stitches) then return T.Stitches end
    end

    if P.bleeding then
        if P.has(T.Clamp) then if P.has(T.Clamp) then return T.Clamp end end
        if (P.incisions > 0 or st0ok) and P.has(T.Stitches) then return T.Stitches end
    end

    -- Temperature >= 100.5
    if P.temp >= 100.5 then
        if not S.lab and P.has(T.LabKit) then if P.has(T.LabKit) then return T.LabKit end end
        -- wait for the fever to drop with Antibiotic (useful) instead of Sponge (wasted)
        if P.has(T.Antibiotic) then return T.Antibiotic end
    end

    -- Last resort filler: Antiseptic only when the site is actually dirty, otherwise Sponge
    if P.site ~= "" and not P.site:find("^clean") and P.has(T.Antiseptic) then return T.Antiseptic end
    if P.has(T.Sponge) then return T.Sponge end
    if P.has(T.Antiseptic) then return T.Antiseptic end
end

-- Sponge before a risky tool is limited to Fix It (Pins is optional): a failed Fix It costs more. A failed Scalpel only adds bleeding that
-- can be handled, so there is no Sponge before every cut.
local RISKY = { [T.FixIt] = true }
if SPONGE_BEFORE_PINS then RISKY[T.Pins] = true end
if SPONGE_BEFORE_SCALPEL then RISKY[T.Scalpel] = true end

local function decide(P)
    local t = decideCore(P)

    -- Prep before the first cut (Sponge / Antiseptic / Lab Kit + Antibiotic) happens BEFORE Anesthetic,
    -- otherwise sleep turns are wasted (hyperactive patients only sleep 4) and Anesthetic gets used twice.
    if t == T.Anesthetic and P.incisions == 0 and not P.asleep and not S.fixed and not P.noSurgery
        and not S.fixSeen and P.shattered == 0 and not P.bleeding and not S.lupus
        and not P.pulse:find("weak") and not P.heartStopped then
        if SPONGE_BEFORE_SCALPEL and (P.dirtyMild or P.dirtyBad) and since(T.Sponge) >= 2 and P.has(T.Sponge) then return T.Sponge end
        if P.site ~= "" and not P.site:find("^clean") and (S.preAnt or 0) < 3 and P.has(T.Antiseptic) then
            S.preAnt = (S.preAnt or 0) + 1
            return T.Antiseptic
        end
        if P.feverUp and P.temp >= 99 and (S.preAbx or 0) < 4 then
            if not S.lab and P.has(T.LabKit) then return T.LabKit end
            if P.has(T.Antibiotic) then S.preAbx = (S.preAbx or 0) + 1; return T.Antibiotic end
        end
    end

    -- After a heart stop in this surgery: Sponge when the view gets blurry (so the next Defib is less likely to fail),
    -- only on calm moves (never over Anesthetic / bleeding / Defib).
    if S.heartProne and P.dirtyMild and not P.heartStopped and not P.bleeding and P.asleep
        and since(T.Sponge) >= 3 and P.has(T.Sponge)
        and t ~= T.Anesthetic and t ~= T.Defib and t ~= T.Sponge and t ~= T.Clamp and t ~= T.Stitches and t ~= T.Transfusion then
        return T.Sponge
    end

    if t and RISKY[t] and (P.dirtyMild or P.dirtyBad) and since(T.Sponge) >= 3
        and P.has(T.Sponge) then return T.Sponge end

    -- an empty site (parse failure) is not treated as dirty
    if t == T.Scalpel and P.incisions == 0 and P.site ~= "" and not P.site:find("^clean")
        and P.has(T.Antiseptic) then
        return T.Antiseptic
    end

    if t == T.Scalpel and P.awake then
        if P.has(T.Anesthetic) then return T.Anesthetic end
        notify("`4Patient is awake but you have no Anesthetic. Restock it")
        if P.has(T.Sponge) then return T.Sponge end
        if P.has(T.Antiseptic) then return T.Antiseptic end
        return nil
    end

    if t == T.Anesthetic and not (P.awake or P.comingTo) then
        if P.has(T.Scalpel) and P.incisions < cutLimit() and not S.fixed then return T.Scalpel end
        if P.has(T.Sponge) then return T.Sponge end
        return nil
    end
    return t
end

local FRIENDLY = { FixIt = "Fix It", Defib = "Defibrillator", LabKit = "Lab Kit", LoveMallet = "Love Mallet" }
local function toolName(id)
    local n = NAME[id]
    return n and (FRIENDLY[n] or n) or tostring(id)
end

local function explain(tool, P)
    if tool == T.Sponge then
        if P.dirtyBad then return "can't see, Sponge only" end
        if P.heartStopped then return "blurry, Sponge before Defib" end
        return "visibility low"
    elseif tool == T.Defib then return "heart stopped"
    elseif tool == T.Anesthetic then return P.awake and "patient awake" or "waking up"
    elseif tool == T.Scalpel then return "cut #" .. (P.incisions + 1)
    elseif tool == T.FixIt then return "ready"
    elseif tool == T.Stitches then return P.incisions > 0 and "close up" or "stop bleeding"
    elseif tool == T.Clamp then return "bleeding"
    elseif tool == T.Transfusion then return "pulse low"
    elseif tool == T.Antibiotic then return "fever"
    elseif tool == T.LabKit then return "check for flu"
    elseif tool == T.Ultrasound then return "diagnose"
    elseif tool == T.Antiseptic then return "dirty site"
    elseif tool == T.Pins then return "shattered bones"
    elseif tool == T.Splint then return "broken bones"
    elseif tool == LOVE_MALLET then return "love struck"
    end
    return ""
end

local function overlay(msg)
    pcall(sendVariant, { v1 = "OnTextOverlay", v2 = msg })
    clog("`9[`2AutoSurg`9] " .. msg)
end

local DISCORD_URL  = "https://hijimi.site/discord"
local function themeBg() return "set_bg_color|" .. UI_THEMES[CFG.theme].bg .. "|" end
local function themeBorder() return "set_border_color|" .. UI_THEMES[CFG.theme].border .. "|" end
local function tc(str) return (str:gsub("`9", UI_THEMES[CFG.theme].color)) end

local DISCORD_TEXT = { "Join our Discord: ", "Updates & support: ", "Questions or ideas? Hop in: " }
local function discordLine(i)
    local label = DISCORD_TEXT[((i or 1) - 1) % #DISCORD_TEXT + 1]
    return "add_smalltext|`6" .. label .. "`9" .. DISCORD_URL .. "``|"
end

local function decorate(raw, tool, P, warn)
    local why = tool and explain(tool, P) or ""
    local top
    if tool then
        for l in (raw .. "\n"):gmatch("(.-)\n") do
            if l:find("|tool" .. tool .. "|", 1, true) then
                local parts = {}
                for f in (l .. "|"):gmatch("([^|]*)|") do parts[#parts + 1] = f end
                if parts[1] == "add_button_with_icon" and parts[2] == "tool" .. tool and parts[3] and parts[4] then
                    parts[3] = "`9" .. toolName(tool)
                    parts[4] = "staticYellowFrame"
                    top = table.concat(parts, "|")
                end
                break
            end
        end
    end
    local out, done = { themeBg(), themeBorder() }, false
    for l in (raw .. "\n"):gmatch("(.-)\n") do
        if not (l:find("^set_bg_color|") or l:find("^set_border_color|") or l:find("^set_default_color|")) then

            if not done and (l:find("^add_button_with_icon|") or l:find("|tool%d%d%d%d")) then
                done = true
                out[#out + 1] = "add_spacer|small|"
                if warn then out[#out + 1] = "add_smalltext|" .. warn .. "|" end
                if top then
                    out[#out + 1] = top
                    out[#out + 1] = "add_button_with_icon||END_LIST|noflags|0||"
                end
                if tool then
                    out[#out + 1] = "add_smalltext|`9USE `4" .. toolName(tool) .. (why ~= "" and ("  `6" .. why) or "") .. "``|"
                end
                out[#out + 1] = discordLine()
                out[#out + 1] = "add_spacer|small|"
            end
            local line = (l:gsub("^add_label_with_icon|big|", "add_label_with_icon|small|"))
            -- Tool frames: the normal dialog shows a white frame behind each tool, Manual Mode lost them.
            -- If the frame field is empty, set one explicitly so the frame shows again.
            if line:find("^add_button_with_icon|tool%d+|") then
                local parts = {}
                for f in (line .. "|"):gmatch("([^|]*)|") do parts[#parts + 1] = f end
                if parts[4] == "" or parts[4] == "noflags" then
                    parts[4] = "staticBlueFrame"
                    line = table.concat(parts, "|")
                end
            end
            out[#out + 1] = line
        end
    end
    return table.concat(out, "\n")
end

local function markUsed(id)
    S.lastTool = id
    S.used[id] = S.turn
    if id == T.LabKit then S.labCount = (S.labCount or 0) + 1 end
    if id == T.Stitches and S.lastP and S.lastP.incisions == 0 then S.st0 = (S.st0 or 0) + 1 end
    if id == T.Ultrasound then S.usCount = (S.usCount or 0) + 1 end
    logTool(id)
end

local function badTap(id, P)
    if id == T.Scalpel and P.awake then
        return "block", "`9STOP: `6patient is awake. Anesthetic first."
    end
    if id == T.Anesthetic and not (P.awake or P.comingTo) then
        return "block", "`9STOP: `6patient is already sedated (coma risk)."
    end
    if id == T.Scalpel and P.has(T.FixIt) then return "warn", "`6Fix It is ready, extra cuts only add bleeding." end
    if id == T.Stitches and P.incisions == 0 and not P.bleeding then return "warn", "`6No incision, no bleeding: Stitches wasted." end
    if id == T.Clamp and (P.incisions == 0 or not P.bleeding) then return "warn", "`6Clamp needs an incision and bleeding." end
    if id == T.Pins and (P.incisions == 0 or P.shattered == 0) then return "warn", "`6Pins need shattered bones and an incision." end
    if id == T.Splint and P.broken == 0 then return "warn", "`6No broken bones: Splint wasted." end
    if id == T.Transfusion and P.pulse:find("strong") then return "warn", "`6Pulse is fine: Transfusion wasted." end
    if id == T.Antibiotic and P.temp <= 98.7 then return "warn", "`6Temp is normal: Antibiotic wasted." end
    if id == T.Antiseptic and P.site:find("^clean") then return "warn", "`6Site is clean: Antiseptic wasted." end
    return nil
end

local function ck(b) return b and "1" or "0" end

-- star icon next to "made by jimi": change the number to any item id you like
local STAR_ICON = 4300
local function showMenu()
    -- one line per item: small icon + name + effect (keeps the popup short)
    local function row(id, name, desc)
        return "add_label_with_icon|small|`9" .. name .. " `6- " .. desc .. "``|left|" .. id .. "|"
    end
    local berryId
    local okB, idB = pcall(findItemID, "Berry Crepe")
    if okB and type(idB) == "number" and idB > 0 then berryId = idB end
    local lines = {
        themeBg(),
        themeBorder(),
        "add_label_with_icon|big|`9Surg-E Helper``|left|4296|",
        "add_smalltext|`6Versi 1.4-r0``|",
        "add_label_with_icon|small|`6made by jimi - dc @hi_jimi``|left|" .. STAR_ICON .. "|",
        discordLine(1),
        "add_smalltext|`6cipcip rto dr. hhhe: `9SAVEJIMII``|",
        "add_spacer|small|",
        "add_smalltext|`9Before you surg``|",
        row(4298, "Surgeon role Lv 2", "Steady Hands: up to 3% less skill fail"),
        row(4298, "Surgeon skill 100", "skill fail about 20% -> 5%"),
        "add_smalltext|`9Clothes``|",
        row(3130, "Stethoscope", "skill fail -50%"),
        row(6252, "Exquisite Bone Saw", "skill fail -50%"),
        row(9068, "Nano Nurse Bot", "skill fail -50%, tool may not be used up"),
        row(8954, "Healing Tome", "malpractice cooldown -25%"),
        row(13168, "Pet Chorizo", "malpractice cooldown -25%"),
        "add_smalltext|`9Food & drink``|",
        row(6912, "Skill Spice `4(wajib)`9", "skill fail -50% for 30 min"),
        row(5114, "Tea `4(wajib)`9", "skill fail -50%, no stack with other skill-fail items"),
        berryId and row(berryId, "Berry Crepe", "+30% surgery XP for 30 min")
            or "add_smalltext|`9Berry Crepe `6- +30% surgery XP for 30 min``|",
        "add_smalltext|`6Healing Tome and Pet Chorizo don't stack. Legal Briefs wipes malpractice right away.``|",
        "add_button|open_settings|`9Settings``|noflags|0|0|",
        "add_smalltext|`6Auto delay and other options.``|",
    }
    for _, l in ipairs({
        "add_spacer|small|",
        "add_label|small|`9Mode `6(pick one)``|left|",
        "add_label|small|`9Auto Mode``|left|",
        "add_checkbox|m_auto_player|`9Auto - Player``|" .. ck(CFG.mode == "auto" and CFG.kind == "player") .. "|",
        "add_smalltext|`6Wrench a player and the surgery starts right away, no profile popup. The tools get tapped for you.``|",
        "add_checkbox|m_auto_surge|`9Auto - Surg-E``|" .. ck(CFG.mode == "auto" and CFG.kind == "surge") .. "|",
        "add_smalltext|`6Wrenches Surg-E and taps all the tools. You just watch.``|",
        "add_smalltext|`6Delay: `9" .. CFG.delay .. " ms`6. Change it in Settings.``|",
        "add_spacer|small|",
        "add_checkbox|m_manual|`9Manual Mode (Helper)``|" .. ck(CFG.mode == "manual") .. "|",
        "add_smalltext|`6Wrench a player and surgery starts right away. You still tap the tools yourself; the suggested one is marked yellow.``|",
        "add_checkbox|o_guard|`4Malpractice guard``|" .. ck(CFG.guard) .. "|",
        "add_smalltext|`6Manual only. Blocks taps that would get you malpractice, like cutting an awake patient. Tap twice to do it anyway.``|",
        "add_spacer|small|",
        "add_label|small|`9Extras `6(work in any mode)``|left|",
        "add_checkbox|o_tea|`9Auto Tea``|" .. ck(CFG.tea) .. "|",
        "add_smalltext|`6Drinks Tea every " .. CFG.teaDelay .. " min. Change it in Settings.``|",
        "add_checkbox|o_spice|`9Auto Skill Spice``|" .. ck(CFG.spice) .. "|",
        "add_smalltext|`6Uses Skill Spice every " .. CFG.spiceDelay .. " min. Switches to Tea when it runs out.``|",
        "add_checkbox|o_legal|`9Auto Legal Briefs``|" .. ck(CFG.legal) .. "|",
        "add_smalltext|`6Uses Legal Briefs the moment you get malpractice.``|",
        "add_checkbox|o_golden|`9Auto Golden Caduceus``|" .. ck(CFG.golden) .. "|",
        "add_smalltext|`6Swaps Caduceus into Golden Caduceus at 100.``|",
        "add_checkbox|o_put|`9Auto Put Surg-E``|" .. ck(CFG.putsurge) .. "|",
        "add_smalltext|`6Auto - Surg-E only. Places Surg-E on up to 5 free tiles next to you.``|",
        "add_checkbox|o_take|`9Auto Take Tools``|" .. ck(CFG.take) .. "|",
        "add_smalltext|`6Auto - Surg-E only. Walks over and picks up surgical tools lying in the world while you're idle.``|",
        "add_spacer|small|",
        "add_button|theme_next|`9Theme: " .. UI_THEMES[CFG.theme].name .. "``|noflags|0|0|",
        "add_smalltext|`6" .. UI_THEMES[CFG.theme].desc .. " Tap to switch.``|",
        "add_button|view_logs|`9View Logs``|noflags|0|0|",
        "add_smalltext|`6Success and fail count, tools used, items you got.``|",
        "add_spacer|small|",
        "add_smalltext|`6Everything is off when the script loads.``|",
        "end_dialog|autosurg_menu||Save|",
    }) do lines[#lines + 1] = l end
    local d = tc(table.concat(lines, "\n"))
    local ok = pcall(sendVariant, { v1 = "OnDialogRequest", v2 = d })
    if not ok then pcall(growtopia.sendDialog, d) end
end

-- Settings: tool-tap delay plus Tea / Skill Spice intervals.
local function showDelay()
    local lines = {
        themeBg(),
        themeBorder(),
        "add_label_with_icon|small|`9Settings ``|left|4296|",
        "add_label|small|`9Auto surgery delay``|left|",
        "add_smalltext|`6Wait before each automatic tool tap (ms).``|",
        "add_smalltext|`6Lower is faster, but taps may get rejected. " .. DELAY_MIN .. "-" .. DELAY_MAX .. ", default 600.``|",
        "add_text_input|delay|Tool delay (ms)|" .. CFG.delay .. "|5|",
        "add_smalltext|`6Tip: `9/sdelay 800`6 still works.``|",
        "add_spacer|small|",
        "add_label|small|`9Extras delay``|left|",
        "add_smalltext|`6Set how often Tea and Skill Spice are used. Range " .. BUFF_DELAY_MIN .. "-" .. BUFF_DELAY_MAX .. " minutes.``|",
        "add_text_input|tea_delay|Tea interval (min)|" .. CFG.teaDelay .. "|3|",
        "add_text_input|spice_delay|Skill Spice interval (min)|" .. CFG.spiceDelay .. "|3|",
        "end_dialog|autosurg_delay||Save|",
    }
    local d = tc(table.concat(lines, "\n"))
    local ok = pcall(sendVariant, { v1 = "OnDialogRequest", v2 = d })
    if not ok then pcall(growtopia.sendDialog, d) end
end

local WHY_LABEL = { bled = "Bled out", infection = "Infection", heart = "Heart stopped", license = "License revoked", stuck = "Stuck", other = "Other" }
local LOGVIEW = "ses"

local function sortedPairs(t, limit)
    local arr = {}
    for k, v in pairs(t) do arr[#arr + 1] = { k = k, v = v } end
    table.sort(arr, function(a, b)
        if a.v ~= b.v then return a.v > b.v end
        return tostring(a.k) < tostring(b.k)
    end)
    while #arr > limit do arr[#arr] = nil end
    return arr
end

local function textList(t, nameFn, limit)
    local parts = {}
    for _, e in ipairs(sortedPairs(t, limit)) do parts[#parts + 1] = nameFn(e.k) .. " x" .. e.v end
    return parts
end

local function addWrapped(lines, color, label, parts, per)
    if #parts == 0 then
        lines[#lines + 1] = "add_smalltext|" .. color .. label .. ": `6none``|"
        return
    end
    for i = 1, #parts, per do
        local chunk = table.concat(parts, ", ", i, math.min(i + per - 1, #parts))
        lines[#lines + 1] = "add_smalltext|" .. (i == 1 and (color .. label .. ": ") or "      ") .. "`6" .. chunk .. "``|"
    end
end

-- Short labels for tools only (long names like Defibrillator / Transfusion widen the tile).
-- Items gained keep their full names.
local TOOL_SHORT = { Sponge = "Sponge", Scalpel = "Scalpel", Anesthetic = "Anest", Antiseptic = "Antisep", Antibiotic = "Antibio",
    Splint = "Splint", Stitches = "Stitch", FixIt = "Fix It", Pins = "Pins", Transfusion = "Transf", Defib = "Defib",
    Clamp = "Clamp", Ultrasound = "Ultra", LabKit = "Lab Kit", LoveMallet = "Mallet" }
local function shortTool(id)
    local n = NAME[id]
    return (n and TOOL_SHORT[n]) or toolName(id)
end

local function addTiles(lines, header, t, nameFn, frame, limit)
    lines[#lines + 1] = "add_label|small|`9" .. header .. "``|left|"
    local arr = sortedPairs(t, limit)
    if #arr == 0 then
        lines[#lines + 1] = "add_smalltext|`6none yet``|"
        return
    end
    for _, e in ipairs(arr) do
        if LOG_LAYOUT == "rows" then
            lines[#lines + 1] = "add_label_with_icon|small|`9" .. nameFn(e.k) .. " `6x" .. e.v .. "``|left|" .. e.k .. "|"
        else
            lines[#lines + 1] = "add_button_with_icon|log_" .. tostring(e.k) .. "|`9" .. nameFn(e.k) .. "|" .. frame .. "|" .. e.k .. "|" .. e.v .. "|"
        end
    end
    if LOG_LAYOUT ~= "rows" then lines[#lines + 1] = "add_button_with_icon||END_LIST|noflags|0||" end
end

local function showLogs()
    local st = (LOGVIEW == "all") and ALL or SES
    local total = st.ok + st.fail
    local rate = total > 0 and math.floor(st.ok * 100 / total + 0.5) or 0
    local lines = {
        themeBg(),
        themeBorder(),
        "add_label_with_icon|small|`9AutoSurg Logs `6- " .. (LOGVIEW == "all" and "All time" or "This session") .. "``|left|4296|",
        discordLine(1),
        "add_spacer|small|",
        "add_smalltext|`2Success: " .. st.ok .. "      `4Fail: " .. st.fail .. "      `9Rate: " .. rate .. "%"
            .. (st.abort > 0 and ("      `6Unfinished: " .. st.abort) or "") .. "``|",
        "add_spacer|small|",
    }
    addTiles(lines, "Tools used", st.tools, shortTool, "staticBlueFrame", 18)
    lines[#lines + 1] = "add_spacer|small|"
    -- Items gained: semua item tampil (tanpa batas), ikon kecil satu baris per item
    lines[#lines + 1] = "add_label|small|`9Items gained``|left|"
    local gained = sortedPairs(st.items, 100000)
    if #gained == 0 then
        lines[#lines + 1] = "add_smalltext|`6none yet``|"
    else
        for _, e in ipairs(gained) do
            lines[#lines + 1] = "add_label_with_icon|small|`9" .. itemName(e.k) .. " `6x" .. e.v .. "``|left|" .. e.k .. "|"
        end
    end
    lines[#lines + 1] = "add_spacer|small|"
    lines[#lines + 1] = "add_label|small|`2Cured by disease``|left|"
    addWrapped(lines, "`2", "Disease", textList(st.disOk, function(k) return k end, 12), 3)
    lines[#lines + 1] = "add_spacer|small|"
    lines[#lines + 1] = "add_label|small|`4Fails by disease``|left|"
    addWrapped(lines, "`4", "Disease", textList(st.disFail, function(k) return k end, 12), 3)
    addWrapped(lines, "`4", "Cause", textList(st.why, function(k) return WHY_LABEL[k] or k end, 6), 3)
    lines[#lines + 1] = "add_spacer|small|"
    lines[#lines + 1] = "add_button|logs_ses|`9This session``|noflags|0|0|"
    lines[#lines + 1] = "add_button|logs_all|`9All time``|noflags|0|0|"
    lines[#lines + 1] = "add_button|logs_back|`9Back``|noflags|0|0|"
    lines[#lines + 1] = "add_button|logs_reset|`4Reset logs``|noflags|0|0|"
    lines[#lines + 1] = "end_dialog|autosurg_logs||Close|"
    local d = tc(table.concat(lines, "\n"))
    local ok = pcall(sendVariant, { v1 = "OnDialogRequest", v2 = d })
    if not ok then pcall(growtopia.sendDialog, d) end
end

local function modeLabel()
    if CFG.mode == "auto" then
        return CFG.kind == "surge" and "`9Auto - Surg-E" or "`9Auto - Player"
    elseif CFG.mode == "manual" then
        return "`9Manual (Helper)"
    end
    return "`4Off"
end

local function applyMenu(pkt)
    local kv = {}
    for k, v in pkt:gmatch("([%w_]+)|([^\n]*)") do kv[k] = v end

    -- 3 checkbox (Auto-Player, Auto-Surg-E, Manual), pilih salah satu
    local picks = {}
    if kv.m_auto_player == "1" then picks[#picks + 1] = "player" end
    if kv.m_auto_surge == "1" then picks[#picks + 1] = "surge" end
    if kv.m_manual == "1" then picks[#picks + 1] = "manual" end

    local oldMode, oldKind = CFG.mode, CFG.kind
    local oldKey = (oldMode == "auto") and oldKind or (oldMode == "manual" and "manual" or nil)
    local newKey
    if #picks == 1 then
        newKey = picks[1]
    elseif #picks > 1 then
        for _, k in ipairs(picks) do
            if k ~= oldKey then newKey = k; break end
        end
    end

    if newKey == "manual" then
        CFG.mode = "manual"
    elseif newKey == "player" or newKey == "surge" then
        CFG.mode, CFG.kind = "auto", newKey
    else
        CFG.mode = "off"
    end

    CFG.guard    = kv.o_guard == "1"
    CFG.tea      = kv.o_tea == "1"
    CFG.spice    = kv.o_spice == "1"
    CFG.legal    = kv.o_legal == "1"
    CFG.wrench   = (CFG.mode == "auto" and CFG.kind == "surge")
    CFG.putsurge = kv.o_put == "1"
    CFG.golden   = kv.o_golden == "1"
    CFG.take     = kv.o_take == "1"
    if CFG.mode ~= oldMode or CFG.kind ~= oldKind then resetState() end
    persist()
    if pkt:find("buttonClicked|theme_next", 1, true) then
        local cur = 1
        for i, k in ipairs(THEME_ORDER) do if k == CFG.theme then cur = i end end
        CFG.theme = THEME_ORDER[cur % #THEME_ORDER + 1]
        persist()
        showMenu()
        return
    end
    if pkt:find("buttonClicked|view_logs", 1, true) then
        LOGVIEW = "ses"
        showLogs()
        return
    end
    if pkt:find("buttonClicked|open_settings", 1, true) then
        showDelay()
        return
    end
    notify("`9Saved. `0Mode: " .. modeLabel())
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

local function sendHook(ptype, pkt)
    if stale() then return false end
    pkt = tostring(pkt or "")
    if pkt:find("action|input", 1, true) then
        local txt = trim(pkt:match("text|([^\n]*)") or ""):lower()
        if txt == "/surg" then
            showMenu()
            return true
        end
        if txt == "/sdelay" or txt:find("^/sdelay%s") then
            local n = txt:match("^/sdelay%s+(%d+)%s*$")
            if n then setDelay(n) else showDelay() end
            return true
        end
        return false
    end
    if pkt:find("dialog_name|autosurg_delay", 1, true) then
        local n = pkt:match("\ndelay|(%d+)")
        local tea = pkt:match("\ntea_delay|(%d+)")
        local spice = pkt:match("\nspice_delay|(%d+)")
        if not n or not tea or not spice then
            overlay("`4Settings have to be numbers")
            return true
        end
        CFG.delay = clampDelay(n)
        CFG.teaDelay = clampBuffDelay(tea, TEA_DEFAULT_MIN)
        CFG.spiceDelay = clampBuffDelay(spice, SPICE_DEFAULT_MIN)
        persist()
        notify("`9Settings saved. `0Tool " .. CFG.delay .. " ms, Tea " .. CFG.teaDelay .. " min, Spice " .. CFG.spiceDelay .. " min")
        return true
    end
    if pkt:find("dialog_name|autosurg_logs", 1, true) then
        if pkt:find("buttonClicked|logs_reset", 1, true) then
            resetLogs()
            showLogs()
        elseif pkt:find("buttonClicked|logs_back", 1, true) then
            showMenu()
        elseif pkt:find("buttonClicked|logs_ses", 1, true) then
            LOGVIEW = "ses"; showLogs()
        elseif pkt:find("buttonClicked|logs_all", 1, true) then
            LOGVIEW = "all"; showLogs()
        elseif pkt:find("buttonClicked|log_", 1, true) then
            showLogs()
        end
        return true
    end
    if pkt:find("dialog_name|autosurg_menu", 1, true) then
        if pkt:find("buttonClicked|tip_", 1, true) then showMenu() return true end
        applyMenu(pkt)
        return true
    end
    if CFG.mode == "manual" and pkt:find("dialog_name|surgery", 1, true) then
        local id = tonumber(pkt:match("buttonClicked|tool(%d+)"))
        if id then
            local lvl, msg
            if CFG.guard and S.lastP then lvl, msg = badTap(id, S.lastP) end
            if lvl == "block" then
                local last = S.blockedAt[id]
                if last and os.time() - last <= 4 then
                    S.blockedAt[id] = nil
                    overlay("`6Okay, tapped anyway")
                else
                    S.blockedAt[id] = os.time()
                    overlay(msg)
                    if S.lastRaw and S.lastP then
                        local d = decorate(S.lastRaw, S.suggest, S.lastP, msg)
                        S.reshowRaw = d
                        pcall(sendVariant, { v1 = "OnDialogRequest", v2 = d })
                    end
                    return true
                end
            elseif lvl == "warn" then
                overlay(msg)
            end
            markUsed(id)
        end
    end
    return false
end

local function findGiveUp(raw)
    for l in ((raw or "") .. "\n"):gmatch("(.-)\n") do
        local low = l:lower()
        if low:find("^add_button|") and (low:find("give up", 1, true) or low:find("giveup", 1, true)
            or low:find("quit", 1, true) or low:find("surrender", 1, true)) then
            local nm = l:match("^add_button|([^|]+)|")
            if nm then return nm end
        end
    end
end

-- Auto Give Up: called when a surgery is stuck. The button name is read from the dialog.
local function giveUp(raw, why)
    local nm = findGiveUp(raw)
    if not nm then
        notify("`4Surgery is stuck (" .. why .. ") and there is no Give Up button. Auto is off, finish it yourself")
        CFG.mode, CFG.wrench = "off", false
        return false
    end
    notify("`4Surgery is stuck (" .. why .. "), giving up")
    SendPacket(2, "action|dialog_return\ndialog_name|surgery\nbuttonClicked|" .. nm)
    finishRun(false, "stuck")
    resetState()
    if W then W.busy, W.lastSurg = false, os.time() end
    return true
end

function surg(var)
    if stale() then return false end

    local all = ""
    for _, k in ipairs({ "v2", "v3", "v4" }) do
        if var[k] ~= nil then all = all .. " " .. tostring(var[k]) end
    end
    all = all:lower()

    if RUN and not RUN.done and not var.v1:find("OnDialogRequest") then
        -- Match the exact sentences from the wiki instead of loose words like "license" that can show up in chat or other messages.
        -- Chat bubbles from other players are ignored.
        if var.v1 ~= "OnTalkBubble" then
            if all:find("saved your patient", 1, true) then finishRun(true)
            elseif all:find("patient has bled out", 1, true) then finishRun(false, "bled")
            elseif all:find("succumbed to infection", 1, true) then finishRun(false, "infection")
            elseif all:find("not resuscitated in time", 1, true) then finishRun(false, "heart")
            elseif all:find("medical license is revoked", 1, true) or all:find("stabbed someone who was fully awake", 1, true) then finishRun(false, "license")
            elseif all:find("put the patient to sleep. permanently", 1, true) or all:find("couldn't save them", 1, true)
                or all:find("abandoned your patient", 1, true) or all:find("smashed your surgical robot", 1, true) then
                finishRun(false, "other")
            end
        end
    end

    if all:find("can't use that tool right now", 1, true) and S.lastTool
        and S.lastTool ~= T.Defib then
        S.ban[S.lastTool] = 3
        clog("`9[`2AutoSurg`9] `4" .. (NAME[S.lastTool] or S.lastTool) .. " was rejected, skipping it for now")
    end

    if S.turn > 0 then
        if all:find("howls in their sleep", 1, true) then S.lupus = true end
        if all:find("worm", 1, true) then S.worms = true end
        if all:find("self-esteem", 1, true) then S.noseJob = true end
        if all:find("abnormal masses", 1, true) then S.flu = true end
    end

    if all:find("suffering from") and all:find("flu") then S.flu = true end

    if all:find("performed lab work", 1, true) then S.lab = true end

    local sfp = tonumber(all:match("skill fail %((%d+)%%%)"))
    if sfp and sfp >= 10 and os.time() - (W.sfWarn or 0) > 600 then
        W.sfWarn = os.time()
        notify("`4Skill fail is " .. sfp .. "%. Turn on Auto Tea / Skill Spice and check your stock")
    end

    if all:find("malpractice") or all:find("license is revoked") then
        if CFG.legal then
            if not W.needLegal then clog("`9[`2AutoSurg`9] `cLegal `4Malpractice, using Legal Briefs...") end
            W.needLegal = true
        elseif CFG.wrench and all:find("malpractice") then
            CFG.wrench = false
            setToggle("wrench", false)
            notify("`4Malpractice! Auto wrench is off")
            return false
        end
    end
    if all:find("stunned the judge") then
        W.needLegal = false
        notify("`2Legal Briefs used, malpractice is gone")
    end

    if not var.v1:find("OnDialogRequest") then return false end
    local raw = var.v2
    if not raw:find("tool%d%d%d%d") then
        resetState()
        if W and (CFG.mode == "auto" or CFG.mode == "manual") and W.handleConfirm(raw) then return true end
        if W and ((CFG.mode == "auto" and CFG.kind == "player") or CFG.mode == "manual") and W.fastSurg(raw) then return true end
        return false
    end
    if CFG.mode == "off" then return false end
    if S.reshowRaw and S.reshowRaw == raw then S.reshowRaw = nil; return false end
    if W then W.lastSurg = os.time(); W.busy = true end

    for k, v in pairs(S.ban) do S.ban[k] = v - 1 end
    S.turn = S.turn + 1
    if S.turn == 1 then
        abortRun()
        startRun()
    elseif not RUN or RUN.done then
        startRun()
    end
    local P, clean = parse(raw)
    if RUN and not RUN.done then RUN.snap, RUN.since, RUN.objs = invSnapshot(), {}, objSnapshot() end
    noteDiseases(tostring(clean):lower())
    S.lastP, S.lastRaw = P, raw
    if P.heartStopped then S.hs = (S.hs or 0) + 1; S.heartProne = true else S.hs = 0 end
    if P.has(T.FixIt) then S.fixSeen = true end
    if DEBUG then LogToConsole(clean) end
    if LOG_STATE then
        LogToConsole(string.format("`8[P] st=%s inc=%d pulse=%s T=%.1f site=%s bone=%d/%d%s%s%s%s",
            P.status ~= "" and P.status or "?", P.incisions, P.pulse ~= "" and P.pulse or "?",
            P.temp, P.site ~= "" and P.site or "?", P.broken, P.shattered,
            P.bleeding and " BLEED" or "", P.heartStopped and " HEART" or "",
            P.dirtyBad and " DIRTY!" or (P.dirtyMild and " dirty" or ""),
            P.undiagnosed and " undiag" or ""))
    end

    if S.lastTool == T.FixIt and not P.has(T.FixIt) then S.fixed = true; S.fixedReal = true end
    if S.flu then P.noSurgery = true end
    if P.noSurgery then S.fixed = true end
    if S.lastTool == T.LabKit and not P.has(T.LabKit) then S.lab = true end

    -- Anti-stuck: the same tool repeated with no change in the patient is skipped for 3 dialogs; if it stays stuck, Auto gives up.
    local sig = table.concat({ P.incisions, P.pulse, P.temp, P.status, P.bleeding and 1 or 0, P.broken, P.shattered,
        P.site, P.has(T.FixIt) and 1 or 0 }, "|")
    if sig == S.sig then S.noProg = (S.noProg or 0) + 1 else S.noProg = 0 end
    S.sig = sig

    local tool = decide(P)
    if tool and tool ~= T.Defib and tool == S.lastTool and (S.noProg or 0) >= REPEAT_MAX then
        S.ban[tool] = 3
        clog("`9[`2AutoSurg`9] `4" .. (NAME[tool] or tostring(tool)) .. " repeated with no change, skipping it for now")
        tool = decide(P)
    end
    if (S.noProg or 0) >= STUCK_NOPROG or S.turn >= GIVEUP_TURNS then
        local why = (S.turn >= GIVEUP_TURNS) and "too many moves" or "no progress"
        if CFG.mode == "auto" then
            return giveUp(raw, why)
        elseif CFG.mode == "manual" and (S.noProg or 0) == STUCK_NOPROG then
            overlay("`4Surgery looks stuck (" .. why .. "). You may want to give up")
        end
    end
    if RUN and not RUN.done and RUN.trace then
        local tr = RUN.trace
        local pl = (P.pulse == "" and "?") or (P.pulse:find("extremely weak") and "XW") or (P.pulse:find("weak") and "W") or "ok"
        local bl = (P.bleedFast and "BB") or (P.bleeding and "B") or "-"
        tr[#tr + 1] = (tool and (NAME[tool] or tostring(tool)) or "none")
            .. "(" .. pl .. "," .. bl .. ",i" .. tostring(P.incisions) .. ",T" .. tostring(math.floor(P.temp)) .. ")"
        if #tr > 8 then table.remove(tr, 1) end
    end
    S.lastTemp = P.temp
    S.suggest = tool
    if CFG.mode == "manual" then
        if tool then
            local d = decorate(raw, tool, P)
            S.reshowRaw = d
            if pcall(sendVariant, { v1 = "OnDialogRequest", v2 = d }) then
                clog("`9[`2AutoSurg`9] Suggested: `0" .. toolName(tool))
                return true
            end
            S.reshowRaw = nil
        end
        return false
    end
    if tool then
        local d = tonumber(CFG.delay) or 0
        if d > 0 then d = math.floor(d * (0.85 + math.random() * 0.3)) end
        if d > 0 then
            runThread(function()
                sleep(d)
                use(tool)
            end)
        else
            use(tool)
        end
        return true
    end
    return false
end

W = { lastSurg = 0, lastWrench = 0, busy = false, target = nil, moving = nil, walkFail = 0 }

local function findSurgeID()
    if SURGE_ID > 0 then return SURGE_ID end
    for _, n in ipairs({ "Surg-E Anatomical Dummy", "Surg-E", "Surg-e", "SurgE" }) do
        local ok, id = pcall(findItemID, n)
        if ok and id and id > 0 then
            SURGE_ID = id
            clog("`9[`2AutoSurg`9] `cWrench `2Surg-E ID: `0" .. id)
            return id
        end
    end
    return nil
end

local function myTile()
    local me = getLocal()
    if not me then return nil end
    return math.floor(me.posX / 32), math.floor(me.posY / 32), me
end

local function surgeList()
    local id = findSurgeID()
    local list = {}
    if not id then return list end
    for _, t in pairs(getTiles() or {}) do
        if t.fg == id then list[#list + 1] = { x = t.x, y = t.y } end
    end
    return list
end

local function inReach(ax, ay, bx, by)
    return math.abs(ax - bx) <= REACH and math.abs(ay - by) <= REACH_Y
end

local function standable(x, y)
    local ok, t = pcall(getTile, x, y)
    local ok2, bl = pcall(getTile, x, y + 1)
    return ok and t and ok2 and bl and t.fg ~= SURGE_ID and bl.fg ~= 0
        and t.fg == 0
end

local function bestSpot(list, mx, my)
    local cand, seen = {}, {}
    for _, c in ipairs(list) do
        for dx = -REACH, REACH do
            local x, y = c.x + dx, c.y
            local k = x .. "," .. y
            if not seen[k] then
                seen[k] = true
                if standable(x, y) then cand[#cand + 1] = { x = x, y = y } end
            end
        end
    end
    if #cand == 0 then cand = list end
    local best, bestN, bestD
    for _, c in ipairs(cand) do
        local n = 0
        for _, t in ipairs(list) do
            if inReach(c.x, c.y, t.x, t.y) then n = n + 1 end
        end
        local d = math.abs(c.x - mx) + math.abs(c.y - my)
        if not best or n > bestN or (n == bestN and d < bestD) then
            best, bestN, bestD = c, n, d
        end
    end
    return best, bestN
end

function W.wrench()
    local mx, my, me = myTile()
    if not mx then return nil end
    local list = surgeList()
    if #list == 0 then return nil end

    local t, td
    W.skip = W.skip or {}
    for _, s in ipairs(list) do
        local sk = W.skip[s.x .. "," .. s.y]
        if inReach(mx, my, s.x, s.y) and not (sk and os.time() - sk < 60) then
            local d = math.abs(s.x - mx) + math.abs(s.y - my)
            if not td or d < td then t, td = s, d end
        end
    end
    if t then
        W.pending = { x = t.x, y = t.y, t = os.time() }
        sendPacketRaw(false, {
            type = 3, value = WRENCH_ID,
            x = me.posX, y = me.posY, px = t.x, py = t.y
        })
        W.lastWrench = os.time()
        W.target = { x = t.x, y = t.y }
        clog("`9[`2AutoSurg`9] `cWrench `2Surg-E di `0" .. t.x .. "," .. t.y)
        return "wrench"
    end

    if not AUTO_WALK then return nil end
    local spot, n = bestSpot(list, mx, my)
    W.moving = { x = spot.x, y = spot.y, since = os.time() }
    clog("`9[`2AutoSurg`9] `cWalk `2Walking to `0" .. spot.x .. "," .. spot.y .. " `2(" .. n .. " Surg-E in reach)")
    pcall(FindPath, spot.x, spot.y)
    return "move"
end

-- Fast start for player surgery: Auto - Player and Manual Helper both skip the profile confirmation.
-- Dialog name, button and embed data are read from the dialog itself.
function W.fastSurg(raw)
    if not FAST_SURG or raw:find("autosurg_", 1, true) then return false end
    local dname = raw:match("end_dialog|([^|\n]*)|")
    if not dname or dname == "" then return false end
    -- only the player profile dialog (has netID), and never click twice in a row
    if not raw:find("netID", 1, true) then return false end
    if W.fastAt and os.time() - W.fastAt < 2 then return false end
    -- never touch the surgery / Surg-E dialogs: a dialog_return without a button counts as leaving the patient = malpractice
    if dname == "surgery" or dname == "surge" or raw:find("add_button_with_icon", 1, true) then return false end
    local fields = ""
    for k, v in raw:gmatch("embed_data|([^|\n]+)|([^|\n]*)") do fields = fields .. k .. "|" .. v .. "|\n" end

    local btn
    for l in (raw .. "\n"):gmatch("(.-)\n") do
        if l:find("^add_button|") then
            local nm, label = l:match("^add_button|([^|]*)|([^|]*)|")
            if nm and label and label:gsub("`.", ""):lower():find("surgery", 1, true) then btn = nm; break end
        end
    end
    if btn then
        SendPacket(2, "action|dialog_return\ndialog_name|" .. dname .. "\n" .. fields .. "buttonClicked|" .. btn)
        W.fastAt = os.time()
        clog("`9[`2AutoSurg`9] `cFast start `2surgery opened")
        return true
    end
    return false
end

function W.handleConfirm(raw)

    if raw:find("end_dialog|surge|", 1, true) then
        local x, y = raw:match("|tilex|(%d+)"), raw:match("|tiley|(%d+)")
        if not x or not y then return false end
        SendPacket(2, "action|dialog_return\ndialog_name|surge\ntilex|" .. x .. "|\ntiley|" .. y .. "|")
        W.busy, W.lastSurg = true, os.time()
        W.pending = nil
        W.target = { x = tonumber(x), y = tonumber(y) }
        findSurgeID()
        clog("`9[`2AutoSurg`9] `cWrench `2Okay! `0(" .. x .. "," .. y .. ")")
        return true
    end
    if DEBUG and os.time() - W.lastWrench <= 5 then LogToConsole(raw:gsub("`.", "")) end
    return false
end

local function lowTools()
    local inv = {}
    for _, it in pairs(getInventory() or {}) do inv[it.id] = it.amount end
    local low = {}
    for name, id in pairs(T) do
        if id ~= T.FixIt and (inv[id] or 0) < MIN_TOOL then
            table.insert(low, name .. ":" .. (inv[id] or 0))
        end
    end
    return low
end

local function teaCount()
    for _, it in pairs(getInventory() or {}) do
        if it.id == ITEM_ID then return it.amount end
    end
    return 0
end

local function drinkTea()
    local p = getLocal()
    if not p then return false end
    local n = teaCount()
    if n <= 0 then return false end
    sendPacketRaw(false, {
        type = 3, value = ITEM_ID,
        x = p.posX, y = p.posY,
        px = math.floor(p.posX / 32), py = math.floor(p.posY / 32)
    })
    clog("`9[`2AutoSurg`9] `cTea `2Drunk `0(left " .. (n - 1) .. ")")
    return true
end

local okPref, pref = pcall(require, "preferences")
saved = okPref and pref:new("autosurg.json") or nil
loadCfg()
loadLogs()

local ui = UserInterface.new("AutoSurg", "Article")
ui:addLabelApp("AutoSurg", "Article")
ui:addTooltip("Menu", "Open the AutoSurg menu", "Info", false)
ui:addButton("Open AutoSurg Menu", "as_open")

local prevOnValue = OnValue
function OnValue(type, name, value)
    if prevOnValue and tostring(name):sub(1, 3) == "df_" then
        return prevOnValue(type, name, value)
    end
    if name == "as_open" then showMenu() end
end

runCoroutine(function()
    sleep(6000)
    addCategory("AutoSurg", "Article")
    addIntoModule(ui:generateJSON(), "AutoSurg")
end)

AddHook(surg, "OnVariant")
AddHook(sendHook, "OnSendPacket")
applyHook()

local function invCount(id)
    local ok, n = pcall(growtopia.checkInventoryCount, id)
    if ok and type(n) == "number" then return n end
    for _, it in pairs(getInventory() or {}) do
        if it.id == id then return it.amount end
    end
    return 0
end

runThread(function()
    local warned = false
    sleep(2000)
    while true do
        if stale() then return end
        local now = os.time()

        if W.busy and W.target and SURGE_ID > 0 then
            local ok, tl = pcall(getTile, W.target.x, W.target.y)
            if ok and tl and tl.fg ~= SURGE_ID then
                W.busy, W.target, W.lastSurg = false, nil, now
                clog("`9[`2AutoSurg`9] `cWrench `0Surg-E gone, surgery finished")
            end
        elseif W.busy and now - W.lastSurg >= SURG_TIMEOUT then
            W.busy = false
        end

        if W.pending and not W.busy and now - W.pending.t >= 6 then
            W.skip = W.skip or {}
            W.skip[W.pending.x .. "," .. W.pending.y] = now
            clog("`9[`2AutoSurg`9] `cWrench `4Surg-E " .. W.pending.x .. "," .. W.pending.y .. " not responding, trying another")
            W.pending, W.lastWrench = nil, 0
        end

        if W.moving then
            local mx, my = myTile()
            local arrived = mx == W.moving.x and math.abs((my or 0) - W.moving.y) <= 1
            if not arrived and mx and W.moving.take then
                arrived = math.abs(mx - W.moving.x) <= 1 and math.abs(my - W.moving.y) <= 1
            end
            if not arrived and mx and not W.moving.take then
                for _, sg in ipairs(surgeList()) do
                    if inReach(mx, my, sg.x, sg.y) then arrived = true; break end
                end
            end
            if arrived then
                W.moving, W.walkFail = nil, 0
                clog("`9[`2AutoSurg`9] `cWalk `2Arrived")
            elseif now - W.moving.since >= WALK_TIMEOUT then
                local wasTake = W.moving.take
                W.moving = nil
                if not wasTake then W.walkFail = W.walkFail + 1 end
                if not wasTake and W.walkFail >= 3 then
                    CFG.wrench = false
                    setToggle("wrench", false)
                    notify("`4Can't reach Surg-E (path blocked). Auto wrench is off")
                    W.walkFail = 0
                end
            end
        end
        if CFG.wrench and not W.busy and not W.moving
            and not W.needLegal and os.time() >= (W.legalPauseUntil or 0)
            and now - W.lastSurg >= IDLE_SEC and now - W.lastWrench >= WRENCH_GAP then
            local low = lowTools()
            local noTea = NEED_TEA and teaCount() <= 0
            if CFG.take and W.take() then
                warned = false
            elseif noTea then
                CFG.wrench = false
                setToggle("wrench", false)
                notify("`4No Tea left. Auto wrench is off")
            elseif #low > 0 then
                CFG.wrench = false
                setToggle("wrench", false)
                notify("`4Auto wrench is off, low on (under " .. MIN_TOOL .. "): `0" .. table.concat(low, ", "))
            elseif CFG.putsurge and #surgeList() == 0 and W.putSurge() > 0 then
                warned = false
            elseif W.wrench() then
                warned = false
            elseif not warned then
                notify("`4No Surg-E found in this world")
                warned = true
            end
        end
        sleep(1000)
    end
end)

function W.putSurge()

    if not CFG.putsurge then return 0 end
    local id = findSurgeID() or 4296
    local mx, my, me = myTile()
    if not mx then return 0 end
    local spots = {}
    for dx = -PUT_REACH, PUT_REACH do
        local x = mx + dx
        local ok, t = pcall(getTile, x, my)
        local ok2, bl = pcall(getTile, x, my + 1)
        W.putFail = W.putFail or {}
        if ok and t and t.fg == 0 and ok2 and bl and bl.fg ~= 0 and not W.putFail[x .. "," .. my] then
            spots[#spots + 1] = { x = x, y = my, d = math.abs(dx) }
        end
    end
    if #spots == 0 then return 0 end
    local have = invCount(id)
    if have <= 0 then
        notify("`4Out of Surg-E, Auto Put is off")
        CFG.putsurge = false
        setToggle("putsurge", false)
        return 0
    end
    table.sort(spots, function(a, b) return a.d < b.d end)
    local placed = 0
    for _, sp in ipairs(spots) do
        if placed >= math.min(have, PUT_MAX) then break end
        local ok, t
        for try = 1, 2 do
            sendPacketRaw(false, { type = 3, value = id, x = me.posX, y = me.posY, px = sp.x, py = sp.y })
            sleep(700)
            ok, t = pcall(getTile, sp.x, sp.y)
            if ok and t and t.fg == id then break end
        end
        if ok and t and t.fg == id then
            placed = placed + 1
        elseif sp.d > 0 then
            W.putFail[sp.x .. "," .. sp.y] = true
        end
    end
    if placed > 0 then
        clog("`9[`2AutoSurg`9] `cPut `2Placed " .. placed .. " Surg-E `0(left " .. invCount(id) .. ")")
    end
    return placed
end

function W.take()
    local mx, my = myTile()
    if not mx then return false end
    local objs, fname = listObjects()
    if not objs then
        if not W.takeWarned then
            W.takeWarned = true
            notify("`4Auto Take can't read dropped items here, so it is off")
        end
        CFG.take = false
        return false
    end
    if not W.takeFound then
        W.takeFound = true
        clog("`9[`2AutoSurg`9] `cTake `2object API: `0" .. fname)
    end
    W.takeSkip = W.takeSkip or {}
    local best, bd
    for _, o in pairs(objs) do
        local id = tonumber(o.itemid or o.itemID or o.itemId)
        if id and TOOL_SET[id] and id ~= T.FixIt and invCount(id) < 200 then
            local tx, ty = objTile(o)
            if tx then
                local key = o.id and ("o" .. tostring(o.id)) or (id .. ":" .. tx .. "," .. ty)
                local sk = W.takeSkip[key]
                if not (sk and os.time() - sk < TAKE_SKIP_SEC) then
                    local d = math.abs(tx - mx) + math.abs(ty - my)
                    if not bd or d < bd then best, bd = { x = tx, y = ty, key = key, id = id }, d end
                end
            end
        end
    end
    if not best then return false end
    W.takeSkip[best.key] = os.time()  -- if the pickup fails, do not chase it again
    if bd <= 1 then return false end
    W.moving = { x = best.x, y = best.y, since = os.time(), take = true }
    clog("`9[`2AutoSurg`9] `cTake `2Going for " .. (NAME[best.id] or best.id) .. " at `0" .. best.x .. "," .. best.y)
    pcall(FindPath, best.x, best.y)
    return true
end

runThread(function()
    local tries, waitUntil, warned = 0, 0, false
    while true do
        if stale() then return end
        if W.needLegal and CFG.legal and not W.busy and os.time() >= waitUntil then
            local have = invCount(LEGAL_ID)
            if have <= 0 then
                if not warned then notify("`4No Legal Briefs left. Waiting for malpractice to end") end
                warned, tries = true, 0
                W.needLegal, W.legalPauseUntil = false, os.time() + 60
            elseif tries >= 4 then
                notify("`4Legal Briefs didn't work, trying again in 1 minute")
                tries = 0
                W.needLegal, W.legalPauseUntil = false, os.time() + 60
            else
                tries = tries + 1
                if tries % 2 == 1 then
                    useSelf(LEGAL_ID)
                else
                    sendPacketRaw(false, { type = 10, value = LEGAL_ID })
                end
                sleep(2500)
                local now = invCount(LEGAL_ID)
                if now < have then
                    clog("`9[`2AutoSurg`9] `cLegal `2Legal Briefs used `0(left " .. now .. ")")
                    W.needLegal, tries, warned = false, 0, false
                    W.lastSurg = os.time()
                end
            end
        else
            if not W.needLegal then tries, warned = 0, false end
            sleep(1000)
        end
    end
end)

runThread(function()
    local warned, lastUse, retryAt, tries, wasOn = false, nil, 0, 0, false
    while true do
        if stale() then return end
        local nowTime = os.time()
        if CFG.spice and not wasOn then lastUse, retryAt = nil, 0 end
        wasOn = CFG.spice
        local interval = math.max(1, tonumber(CFG.spiceDelay) or SPICE_DEFAULT_MIN) * 60
        local due = not lastUse or (nowTime - lastUse >= interval)
        if CFG.spice and due and nowTime >= retryAt and not W.busy then
            local have = invCount(SPICE_ID)
            if have <= 0 then
                if not warned then notify("`4Out of Skill Spice, using Tea instead") end
                warned, W.spiceUntil, retryAt = true, 0, nowTime + 60
            else
                tries = tries + 1
                if tries % 2 == 1 then useSelf(SPICE_ID)
                else sendPacketRaw(false, { type = 10, value = SPICE_ID }) end
                sleep(2500)
                local left = invCount(SPICE_ID)
                if left < have then
                    warned, tries = false, 0
                    lastUse, retryAt = os.time(), 0
                    W.spiceUntil = lastUse + interval
                    clog("`9[`2AutoSurg`9] `cSpice `2Skill Spice used `0(left " .. left .. ", next in " .. CFG.spiceDelay .. " min)")
                elseif tries >= 4 then
                    W.spiceUntil, tries = 0, 0
                    retryAt = os.time() + 300
                    notify("`4Skill Spice didn't work, using Tea for now. Trying again in 5 min")
                end
            end
        end
        sleep(1000)
    end
end)

runThread(function()
    local warned, lastDrink, wasOn = false, nil, false
    while true do
        if stale() then return end
        local nowTime = os.time()
        if CFG.tea and not wasOn then lastDrink = nil end
        wasOn = CFG.tea
        local interval = math.max(1, tonumber(CFG.teaDelay) or TEA_DEFAULT_MIN) * 60
        local spiceOn = CFG.spice and nowTime < (W.spiceUntil or 0)
        local due = not lastDrink or (nowTime - lastDrink >= interval)
        if CFG.tea and not spiceOn and due then
            if drinkTea() then
                warned, lastDrink = false, os.time()
            elseif not warned then
                if CFG.wrench then
                    CFG.wrench = false
                    setToggle("wrench", false)
                    notify("`4Out of Tea. Auto wrench is off, skill fail goes up without it")
                else
                    notify("`4No Tea in your inventory")
                end
                warned = true
            end
        end
        sleep(1000)
    end
end)

local function itemCount(id)
    local ok, n = pcall(growtopia.checkInventoryCount, id)
    if ok and type(n) == "number" then return n end
    for _, it in pairs(getInventory() or {}) do
        if it.id == id then return it.amount end
    end
    return 0
end

runThread(function()
    while true do
        if stale() then return end
        if CFG.golden and not W.busy and not W.moving
            and CADUCEUS_ID > 0 and CADUCEUS_ID ~= GOLDEN_ID
            and itemCount(CADUCEUS_ID) >= GOLDEN_AT then
            local basic0, gold0 = itemCount(CADUCEUS_ID), itemCount(GOLDEN_ID)
            local done = false
            for try = 1, 2 do
                sendPacketRaw(false, { type = 10, value = CADUCEUS_ID })
                sleep(1500)
                if itemCount(GOLDEN_ID) > gold0 or itemCount(CADUCEUS_ID) ~= basic0 then break end
            end
            local basic1, gold1 = itemCount(CADUCEUS_ID), itemCount(GOLDEN_ID)
            if gold1 > gold0 and basic1 < basic0 then
                notify("`2Swapped " .. GOLDEN_AT .. " Caduceus into a Golden Caduceus `0(you have " .. gold1 .. ")")
            else

                CFG.golden = false
                setToggle("golden", false)
                notify(string.format("`4Caduceus swap failed (Caduceus %d->%d, Golden %d->%d). Auto Golden is off",
                    basic0, basic1, gold0, gold1))
            end
        end
        sleep(3000)
    end
end)

-- Low tools warning: short text in the middle of the screen when any tool is <= LOW_WARN (only while a mode is on)
runThread(function()
    local lastWarn, lastKey = 0, ""
    sleep(5000)
    while true do
        if stale() then return end
        if CFG.mode ~= "off" then
            local inv = {}
            for _, it in pairs(getInventory() or {}) do inv[it.id] = it.amount end
            local low = {}
            for _, id in pairs(T) do
                if id ~= T.FixIt and (inv[id] or 0) <= LOW_WARN then
                    low[#low + 1] = { name = shortTool(id), n = inv[id] or 0 }
                end
            end
            table.sort(low, function(a, b) return a.name < b.name end)
            local parts, key = {}, {}
            for i, e in ipairs(low) do
                key[#key + 1] = e.name
                if i <= 6 then parts[#parts + 1] = e.name .. " " .. e.n end
            end
            key = table.concat(key, ",")
            if #low > 0 and (key ~= lastKey or os.time() - lastWarn >= LOW_REPEAT) then
                overlay("`4Running low: `0" .. table.concat(parts, ", ") .. (#low > 6 and " ..." or ""))
                lastWarn, lastKey = os.time(), key
            elseif #low == 0 then
                lastKey = ""
            end
        end
        sleep(5000)
    end
end)
