local SCRIPT_NAME = "Dark Ticket Bot"
local KEY = "HALLOWEENBRUHH"
local DARK_TICKET_ID = 9018
local ALTAR_ID = 9020
local ULTIMATE_ALTAR_ID = 9022
local FIST_ID = 18
local WHITE_DOOR_ID = 6
local TRIGGER_BLOCK_ID = 7394
local TRIGGER_OPEN_FLAG = 65
local WELL_MAX_SOULS = 8000
local TARGET_TOTAL_SOULS = 48000
local PROXY_API_URL = "https://discord-jacko.geostorming900.workers.dev/"
local DISCORD_WEBHOOK =
  "https://discord.com/api/webhooks/1563441881717678090/f7mRaekLmqe4pfGLOR151emOKvxW68QEZGH8hRX6GhUJ0swFifd-tDhEpsZYwk4kJW_v"
local pref = require("preferences")
local json = require("json")
local saved = pref:new("dark_ticket_cfg.json")
local _sleep = sleep or Sleep or CSleep
local _findPath = FindPath or findPath
local _getTiles = getTiles or GetTiles
local _getTile = getTile or GetTile
local _getObjects = getObjectList or GetObjectList or getObjects or GetObjects
local _getLocal = getLocal or GetLocal
local _getInv = getInventory or GetInventory
local _getWorld = GetWorldName or getCurrentWorldName or getWorldName
local sendRaw = sendPacketRaw or SendPacketRaw
local sendPkt = sendPacket or SendPacket
local keyVerified = (saved:get("auth_key", "") == KEY)
local bot_running = false
local bot_paused = false
local isUpdatingUI = false
local save_world = tostring(saved:get("save_world", ""))
local save_door = tostring(saved:get("save_door", ""))
local target_item_id = tonumber(saved:get("target_item_id", 4584)) or 4584
local target_item_name = tostring(saved:get("target_item_name", "Pepper Tree"))
local run_limit = tonumber(saved:get("run_limit", 0)) or 0
local completed_runs = 0
local secret_chat_enabled = saved:get("sc_flag", true)
local console_logging_enabled = saved:get("console_logging_enabled", false)
local auto_hacks = saved:get("auto_hacks", true)
local use_modfly = saved:get("use_modfly", true)
local blacklist_only_when_full = saved:get("blacklist_only_when_full", true)
local blacklist_zero_souls = saved:get("blacklist_zero_souls", true)
local delay_world_change_s = tonumber(saved:get("delay_world_change_s", 12)) or 12
local delay_before_put_s = tonumber(saved:get("delay_before_put_s", 3)) or 3
local delay_after_put_s = tonumber(saved:get("delay_after_put_s", 5)) or 5
local delay_respawn_s = tonumber(saved:get("delay_respawn_s", 5)) or 5
local delay_ultimate_wait_s = tonumber(saved:get("delay_ultimate_wait_s", 5)) or 5
local delay_after_prize_s = tonumber(saved:get("delay_after_prize_s", 10)) or 10
local delay_pickup_ms = tonumber(saved:get("delay_pickup_ms", 150)) or 150
local delay_path_ms = tonumber(saved:get("delay_path_ms", 100)) or 100
local blacklisted_altars = {}
local well_souls = {}
local active_well_key = nil
local current_total_souls = 0
local last_sacrifice_granted_souls = 0
local sacrifice_console_received = false
local stuck_attempts = {}
local well_zero_souls_flag = false
local last_webhook_time = 0
local function Log(msg)
  if not console_logging_enabled then
    return
  end
  pcall(function()
    LogToConsole("`9[" .. SCRIPT_NAME .. "]`o " .. tostring(msg))
  end)
end
local function Warn(msg)
  if not console_logging_enabled then
    return
  end
  pcall(function()
    LogToConsole("`4[" .. SCRIPT_NAME .. "]`o " .. tostring(msg))
  end)
end
local function saveConfig()
  saved:set("save_world", save_world)
  saved:set("save_door", save_door)
  saved:set("target_item_id", target_item_id)
  saved:set("target_item_name", target_item_name)
  saved:set("run_limit", run_limit)
  saved:set("sc_flag", secret_chat_enabled)
  saved:set("console_logging_enabled", console_logging_enabled)
  saved:set("auto_hacks", auto_hacks)
  saved:set("use_modfly", use_modfly)
  saved:set("blacklist_only_when_full", blacklist_only_when_full)
  saved:set("blacklist_zero_souls", blacklist_zero_souls)
  saved:set("delay_world_change_s", delay_world_change_s)
  saved:set("delay_before_put_s", delay_before_put_s)
  saved:set("delay_after_put_s", delay_after_put_s)
  saved:set("delay_respawn_s", delay_respawn_s)
  saved:set("delay_ultimate_wait_s", delay_ultimate_wait_s)
  saved:set("delay_after_prize_s", delay_after_prize_s)
  saved:set("delay_pickup_ms", delay_pickup_ms)
  saved:set("delay_path_ms", delay_path_ms)
  saved:save()
end
local function setToggleSafe(name, state)
  pcall(function()
    if type(editToggle) == "function" then
      editToggle(name, state)
    end
    if type(EditToggle) == "function" then
      EditToggle(name, state)
    end
  end)
end
local function enableAllCheats()
  setToggleSafe("ModFly", true)
  setToggleSafe("AntiGravity", true)
  setToggleSafe("Night Vision", true)
  setToggleSafe("NightVision", true)
  setToggleSafe("Antibounce", true)
  setToggleSafe("AntiBounce", true)
  setToggleSafe("Anti Bounce", true)
end
local function disableModFlyOnly()
  setToggleSafe("ModFly", false)
  setToggleSafe("AntiGravity", false)
end
enableAllCheats()
local function getItemNameSafely(id)
  local num_id = tonumber(id) or 0
  if num_id <= 0 then
    return "None"
  end
  local name = ""
  pcall(function()
    if type(growtopia) == "table" and type(growtopia.getItemName) == "function" then
      name = growtopia.getItemName(num_id)
    elseif type(getItemInfoByID) == "function" then
      local info = getItemInfoByID(num_id)
      if info and info.name then
        name = info.name
      end
    elseif type(getItemInfoManager) == "function" then
      local mgr = getItemInfoManager()
      if mgr then
        local info = mgr.getItemInfoByID(num_id)
        if info and info.name then
          name = info.name
        end
      end
    end
  end)
  if name and name ~= "" and not name:lower():find("unknown") then
    return (name:gsub("`.", ""))
  end
  return "Item ID " .. tostring(num_id)
end
local FALLBACK_RARITIES = {
  [4584] = 81, -- Pepper Tree
  [5666] = 63, -- Laser Grid
  [340] = 87, -- Chandelier
  [5480] = 77, -- Sorcerer Stone
  [3004] = 42, -- Fish Tank
  [320] = 55, -- Pinball Bumper
  [2724] = 69, -- High Tech Block
  [184] = 33, -- Venus Guytrap
  [994] = 21, -- Sugarcane
}
local function getItemRarity(id)
  local num_id = tonumber(id) or 0
  if num_id <= 0 then
    return 1
  end
  local rar = 0
  pcall(function()
    if type(getItemInfoByID) == "function" then
      local info = getItemInfoByID(num_id)
      if info and tonumber(info.rarity) and tonumber(info.rarity) > 0 then
        rar = tonumber(info.rarity)
      end
    end
    if rar <= 0 and type(getItemInfoManager) == "function" then
      local mgr = getItemInfoManager()
      if mgr and type(mgr.getItemInfoByID) == "function" then
        local info = mgr.getItemInfoByID(num_id)
        if info and tonumber(info.rarity) and tonumber(info.rarity) > 0 then
          rar = tonumber(info.rarity)
        end
      end
    end
  end)
  if rar <= 0 and FALLBACK_RARITIES[num_id] then
    rar = FALLBACK_RARITIES[num_id]
  end
  return rar > 0 and rar or 1
end
local function resolveItemIDByName(targetName)
  local resolved = 0
  pcall(function()
    if type(growtopia) == "table" and type(growtopia.getItemID) == "function" then
      local id = growtopia.getItemID(targetName)
      if id and id > 0 then
        resolved = id
      end
    end
    if resolved <= 0 and type(getItemID) == "function" then
      local id = getItemID(targetName)
      if id and id > 0 then
        resolved = id
      end
    end
    if resolved <= 0 and type(findItemID) == "function" then
      local id = findItemID(targetName)
      if id and id > 0 then
        resolved = id
      end
    end
    if resolved <= 0 and type(getItemInfoByName) == "function" then
      local info = getItemInfoByName(targetName)
      if info and info.id then
        resolved = info.id
      end
    end
  end)
  return resolved
end
local HELLGATE_ID = resolveItemIDByName("Hellgate")
local RUPTURE_ID = resolveItemIDByName("Time Space Rupture")
local TRACKED_PRIZES = {
  { name = "Horns of Growganoth", alt = "Horn of Growganoth", is_horns = true, id = 0 },
  { name = "Cloak of Equilibrium", alt = nil, is_horns = false, id = 0 },
  { name = "Cursed Katana", alt = nil, is_horns = false, id = 0 },
  { name = "Pharaoh's Pendant", alt = "Pharaohs Pendant", is_horns = false, id = 0 },
  { name = "Scythe of the Underworld", alt = nil, is_horns = false, id = 0 },
  { name = "Apocalypse Scythe", alt = nil, is_horns = false, id = 0 },
  { name = "Waay Chivo Cannon", alt = "Way Chivo Cannon", is_horns = false, id = 0 },
  { name = "Monster Koach", alt = "Monster Coach", is_horns = false, id = 0 },
  { name = "Bloated Bullfrog Ballon", alt = "Bloated Bullfrog Balloon", is_horns = false, id = 0 },
}
local function refreshTrackedPrizeIDs()
  for _, prize in ipairs(TRACKED_PRIZES) do
    if not prize.id or prize.id <= 0 then
      local id = resolveItemIDByName(prize.name)
      if (not id or id <= 0) and prize.alt then
        id = resolveItemIDByName(prize.alt)
      end
      if id and id > 0 then
        prize.id = id
      end
    end
  end
end
refreshTrackedPrizeIDs()
local function matchTrackedPrize(itemNameOrStr)
  if not itemNameOrStr or itemNameOrStr == "" then
    return nil
  end
  refreshTrackedPrizeIDs()

  local clean = itemNameOrStr:gsub("``", ""):gsub("`.", ""):gsub("`", ""):gsub("^%s+", ""):gsub("%s+$", "")
  local clean_lower = clean:lower()

  local resolved_id = resolveItemIDByName(clean)
  if resolved_id and resolved_id > 0 then
    for _, prize in ipairs(TRACKED_PRIZES) do
      if prize.id > 0 and prize.id == resolved_id then
        return prize
      end
    end
  end

  for _, prize in ipairs(TRACKED_PRIZES) do
    if clean_lower == prize.name:lower() or clean_lower:find(prize.name:lower(), 1, true) then
      return prize
    end
    if prize.alt and (clean_lower == prize.alt:lower() or clean_lower:find(prize.alt:lower(), 1, true)) then
      return prize
    end
  end

  return nil
end
target_item_name = getItemNameSafely(target_item_id)
local function urlencode(str)
  if str then
    str = str:gsub("\n", "\r\n")
    str = str:gsub("([^%w%-%_%.%~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
  end
  return str
end
local function getDiscordMentionID()
  local discord_id = "UnknownPlayer"
  pcall(function()
    if type(getDiscordID) == "function" then
      local did = getDiscordID()
      if did and tostring(did) ~= "" then
        discord_id = tostring(did)
      end
    end
  end)
  return discord_id
end
local function sendWebhookPrize(prizeName, isHorns, isTestMode)
  if not isTestMode then
    if os.time() - last_webhook_time < 8 then
      return
    end
    last_webhook_time = os.time()
  end

  local discord_id = getDiscordMentionID()
  local content_msg = ""
  local embed_title = "Growganoth Prize Claimed"

  if isTestMode then
    content_msg = string.format("Congratulation <@%s> for getting NOTHING\ntesting only", discord_id)
    embed_title = "Webhook Test"
  elseif isHorns then
    content_msg = string.format("Congratulation <@%s> for getting %s @everyone", discord_id, prizeName)
    embed_title = "Horns of Growganoth Claimed"
  else
    content_msg = string.format("Congratulation <@%s> for getting %s", discord_id, prizeName)
  end

  local payload_table = {
    url = DISCORD_WEBHOOK,
    content = content_msg,
    username = "Growganoth Bot",
    embeds = {
      {
        title = embed_title,
        description = content_msg,
        color = 65280,
        footer = {
          text = "Jacko999 Farming System",
        },
      },
    },
  }

  local json_payload = json:encode(payload_table)
  local safe_payload = urlencode(json_payload)
  local final_url = PROXY_API_URL .. "?data=" .. safe_payload

  runCoroutine(function()
    local ok = pcall(function()
      return fetch(final_url)
    end)
    if not isTestMode then
      if ok then
        Log("[Webhook] Prize alert sent to Discord: " .. tostring(prizeName))
      else
        Warn("[Webhook] Failed to send prize alert.")
      end
    end
  end)
end
local function sendDialog(str)
  pcall(function()
    if type(growtopia) == "table" and type(growtopia.sendDialog) == "function" then
      growtopia.sendDialog(str)
    elseif type(sendVariant) == "function" then
      sendVariant({ v1 = "OnDialogRequest", v2 = str })
    elseif type(SendVariantList) == "function" then
      SendVariantList({ v1 = "OnDialogRequest", v2 = str })
    elseif type(SendVarlist) == "function" then
      SendVarlist({ v1 = "OnDialogRequest", v2 = str })
    end
  end)
end
local function getSaveWorldDisplay()
  if save_world == "" then
    return "Not Set (Use /setdrop world|doorid)"
  end
  if save_door ~= "" then
    return save_world .. "|" .. save_door
  end
  return save_world
end
local function getTargetItemDisplay()
  local rar = getItemRarity(target_item_id)
  return target_item_name .. " (ID: " .. tostring(target_item_id) .. " | Rarity: " .. tostring(rar) .. ")"
end
local function getBlacklistCount()
  local c = 0
  for _, v in pairs(blacklisted_altars) do
    if v then
      c = c + 1
    end
  end
  return c
end
local function updateModuleUI()
  if isUpdatingUI then
    return
  end
  isUpdatingUI = true
  pcall(function()
    if not keyVerified then
      editValue("ui_key_status", "UNVERIFIED (LOCKED)")
    else
      local st = "STOPPED"
      if bot_running then
        st = bot_paused and "PAUSED" or "RUNNING"
      end
      editValue("ui_status", st)
      editValue("ui_save_world", getSaveWorldDisplay())
      editValue("ui_target_item", getTargetItemDisplay())
      local run_str = tostring(completed_runs) .. " / " .. (run_limit <= 0 and "Unlimited" or tostring(run_limit))
      editValue("ui_runs", run_str)
      editValue("ui_souls", tostring(current_total_souls) .. " / " .. tostring(TARGET_TOTAL_SOULS))
      editValue("ui_blacklisted", tostring(getBlacklistCount()))
    end
  end)
  isUpdatingUI = false
end
local function getPlayerPos()
  local p = _getLocal()
  if not p then
    return nil, nil, nil, nil
  end
  local rx = p.posX or (p.pos and p.pos.x) or p.x or 0
  local ry = p.posY or (p.pos and p.pos.y) or p.y or 0
  return math.floor(rx / 32), math.floor(ry / 32), rx, ry
end
local function getInvCount(itemID)
  if not itemID or itemID <= 0 then
    return 0
  end
  local inv = _getInv()
  if not inv then
    return 0
  end
  for _, item in pairs(inv) do
    if tonumber(item.id) == tonumber(itemID) then
      return tonumber(item.amount or item.count) or 0
    end
  end
  return 0
end
local function snapshotTrackedPrizeCounts()
  refreshTrackedPrizeIDs()
  local counts = {}
  for i, prize in ipairs(TRACKED_PRIZES) do
    if prize.id and prize.id > 0 then
      counts[i] = getInvCount(prize.id)
    else
      counts[i] = 0
    end
  end
  return counts
end
local function getCurrentWorldUpper()
  local w = _getWorld()
  if not w then
    return ""
  end
  return tostring(w):upper()
end
local function smartSleep(ms)
  local elapsed = 0
  local step = 100
  while bot_running and elapsed < ms do
    while bot_running and bot_paused do
      _sleep(200)
    end
    if not bot_running then
      return false
    end
    local wait_t = math.min(step, ms - elapsed)
    _sleep(wait_t)
    elapsed = elapsed + wait_t
  end
  return bot_running
end
local function checkPause()
  while bot_running and bot_paused do
    _sleep(200)
  end
  return bot_running
end
local function getSingleTile(tx, ty)
  if tx < 0 or tx > 99 or ty < 0 or ty > 59 then
    return nil
  end
  if type(_getTile) == "function" then
    local ok, t = pcall(_getTile, tx, ty)
    if ok and t then
      return t
    end
  end
  local tiles = _getTiles()
  if tiles then
    for _, t in pairs(tiles) do
      if t.x == tx and t.y == ty then
        return t
      end
    end
  end
  return nil
end
local function getTileFlag(t)
  if not t then
    return 0
  end
  return tonumber(t.flag) or tonumber(t.flags) or tonumber(t.Flags) or 0
end
local function findWhiteDoor()
  local tiles = _getTiles()
  if tiles then
    for _, t in pairs(tiles) do
      if tonumber(t.fg) == WHITE_DOOR_ID then
        return { x = t.x, y = t.y }
      end
    end
  end
  return nil
end
local function isPlayerAtWhiteDoor()
  local px, py = getPlayerPos()
  if not px or not py then
    return false, nil
  end
  local wd = findWhiteDoor()
  if wd then
    if math.abs(px - wd.x) <= 2 and math.abs(py - wd.y) <= 2 then
      return true, wd
    end
  end
  return false, wd
end
local function isAccessibleTile(tx, ty)
  if tx < 0 or tx > 99 or ty < 0 or ty > 59 then
    return false
  end
  local t = getSingleTile(tx, ty)
  if t and t.collidable then
    return false
  end
  local is_blocked = true
  pcall(function()
    is_blocked = _findPath(tx, ty, true)
  end)
  return (is_blocked == false)
end
local function handleWhiteDoorStuck7394(wd_pos)
  if not checkPause() then
    return false
  end
  local px, py = getPlayerPos()
  local cx = (wd_pos and wd_pos.x) or px or 0
  local cy = (wd_pos and wd_pos.y) or py or 0

  Log(
    "Stuck at White Door ("
      .. cx
      .. ", "
      .. cy
      .. ") after 2 teleport attempts! Scanning 11x11 area for block ID 7394 with accessible -1y..."
  )

  local candidates = {}
  for dy = -5, 5 do
    for dx = -5, 5 do
      local bx = cx + dx
      local by = cy + dy
      local t = getSingleTile(bx, by)
      if t and (tonumber(t.fg) == TRIGGER_BLOCK_ID or tonumber(t.bg) == TRIGGER_BLOCK_ID) then
        local target_x = bx
        local target_y = by - 1
        if target_y >= 0 and isAccessibleTile(target_x, target_y) then
          local cur_flag = getTileFlag(t)
          local dist = math.abs(target_x - (px or cx)) + math.abs(target_y - (py or cy))
          table.insert(candidates, {
            bx = bx,
            by = by,
            tx = target_x,
            ty = target_y,
            flag = cur_flag,
            dist = dist,
          })
        end
      end
    end
  end

  if #candidates == 0 then
    Warn(
      "No block ID 7394 with an accessible -1y tile found in 11x11 area around White Door (" .. cx .. ", " .. cy .. ")."
    )
    return false
  end

  table.sort(candidates, function(a, b)
    local a_untriggered = (a.flag ~= TRIGGER_OPEN_FLAG)
    local b_untriggered = (b.flag ~= TRIGGER_OPEN_FLAG)
    if a_untriggered ~= b_untriggered then
      return a_untriggered
    end
    return a.dist < b.dist
  end)

  local chosen = candidates[1]
  Log(
    "Found block 7394 at ("
      .. chosen.bx
      .. ", "
      .. chosen.by
      .. ") [Flag: "
      .. tostring(chosen.flag)
      .. "]. Teleporting to accessible -1y at ("
      .. chosen.tx
      .. ", "
      .. chosen.ty
      .. ")..."
  )

  local arrived = false
  for try_move = 1, 4 do
    if not checkPause() then
      return false
    end
    _findPath(chosen.tx, chosen.ty)
    _sleep(delay_path_ms)

    local waited = 0
    while bot_running and waited < 1000 do
      if not checkPause() then
        return false
      end
      px, py = getPlayerPos()
      if px == chosen.tx and py == chosen.ty then
        arrived = true
        break
      end
      _sleep(50)
      waited = waited + 50
    end
    if arrived then
      break
    end
  end

  if not arrived then
    Warn("Failed to reach accessible -1y tile (" .. chosen.tx .. ", " .. chosen.ty .. ") above block 7394.")
    return false
  end

  Log(
    "Waiting at ("
      .. chosen.tx
      .. ", "
      .. chosen.ty
      .. ") for block 7394 at ("
      .. chosen.bx
      .. ", "
      .. chosen.by
      .. ") flag to change to 65..."
  )
  local waited_change = 0
  while bot_running and waited_change < 15000 do
    if not checkPause() then
      return false
    end
    local check_t = getSingleTile(chosen.bx, chosen.by)
    if check_t then
      local f = getTileFlag(check_t)
      if f == TRIGGER_OPEN_FLAG then
        Log("Block 7394 at (" .. chosen.bx .. ", " .. chosen.by .. ") flag changed to 65! Continuing...")
        smartSleep(250)
        return true
      end
    end
    _sleep(100)
    waited_change = waited_change + 100
  end

  Warn("Timed out waiting for block 7394 at (" .. chosen.bx .. ", " .. chosen.by .. ") flag to change to 65.")
  return false
end
local function isHellgateAt(tx, ty)
  local t = getSingleTile(tx, ty)
  if not t then
    return false
  end
  local fg = tonumber(t.fg) or 0
  local bg = tonumber(t.bg) or 0
  if HELLGATE_ID > 0 and (fg == HELLGATE_ID or bg == HELLGATE_ID) then
    return true
  end
  if fg > 0 and getItemNameSafely(fg):lower():find("hellgate") then
    return true
  end
  if bg > 0 and getItemNameSafely(bg):lower():find("hellgate") then
    return true
  end
  return false
end
local function findTimeSpaceRupture()
  local tiles = _getTiles()
  if not tiles then
    return nil
  end
  local px, py = getPlayerPos()
  local closest = nil
  local min_dist = 999999

  for _, t in pairs(tiles) do
    local fg = tonumber(t.fg) or 0
    local bg = tonumber(t.bg) or 0
    local match = false

    if RUPTURE_ID > 0 and (fg == RUPTURE_ID or bg == RUPTURE_ID) then
      match = true
    else
      if fg > 0 then
        local fn = getItemNameSafely(fg):lower()
        if fn:find("time space rupture") or fn:find("rupture") then
          match = true
        end
      end
      if not match and bg > 0 then
        local bn = getItemNameSafely(bg):lower()
        if bn:find("time space rupture") or bn:find("rupture") then
          match = true
        end
      end
    end

    if match then
      local dist = math.abs(t.x - (px or 0)) + math.abs(t.y - (py or 0))
      if dist < min_dist then
        min_dist = dist
        closest = { x = t.x, y = t.y }
      end
    end
  end
  return closest
end
local function sendPacket7At(tx, ty)
  Log("Sending Packet 7 at (" .. tx .. ", " .. ty .. ")...")
  sendRaw(false, {
    type = 7,
    padding1 = 0,
    padding2 = 0,
    padding3 = 0,
    netid = 0,
    secnetid = 0,
    state = 0,
    characterState = 0,
    padding4 = 0,
    padding5 = 0,
    value = 0,
    x = 0,
    y = 0,
    xspeed = 0,
    yspeed = 0,
    XSpeed = 0,
    YSpeed = 0,
    time = 0,
    ptime = 0,
    px = tx,
    py = ty,
    punchX = tx,
    punchY = ty,
    extDataSize = 0,
  })
end
local function respawnPlayer()
  Log("Respawning player...")
  sendPkt(2, "action|respawn\n")
end
local function teleportTo(tx, ty)
  if not checkPause() then
    return false
  end
  if tx < 0 or tx > 99 or ty < 0 or ty > 59 then
    return false
  end

  local px, py = getPlayerPos()
  if px == tx and py == ty then
    return true
  end

  local white_door_fails = 0
  local tried_7394_unlock = false

  for attempt = 1, 4 do
    if not checkPause() then
      return false
    end

    local is_blocked = false
    pcall(function()
      is_blocked = _findPath(tx, ty, true)
    end)

    if not is_blocked then
      _findPath(tx, ty)
      _sleep(delay_path_ms)

      local waited = 0
      while bot_running and waited < 1000 do
        if not checkPause() then
          return false
        end
        px, py = getPlayerPos()
        if px == tx and py == ty then
          return true
        end
        _sleep(50)
        waited = waited + 50
      end

      px, py = getPlayerPos()
      if px and py and math.abs(px - tx) <= 1 and math.abs(py - ty) <= 1 and attempt >= 2 then
        return true
      end
    else
      _sleep(100)
    end

    local at_wd, wd_pos = isPlayerAtWhiteDoor()
    if at_wd then
      white_door_fails = white_door_fails + 1
      if white_door_fails >= 2 and not tried_7394_unlock then
        tried_7394_unlock = true
        if handleWhiteDoorStuck7394(wd_pos) then
          _findPath(tx, ty)
          _sleep(delay_path_ms)
          local waited = 0
          while bot_running and waited < 1200 do
            if not checkPause() then
              return false
            end
            px, py = getPlayerPos()
            if px == tx and py == ty then
              return true
            end
            _sleep(50)
            waited = waited + 50
          end
        end
      end
    elseif is_blocked then
      return false
    end
  end
  return false
end
local function reachAltarWithFallback(ax, ay)
  if teleportTo(ax, ay) then
    return true, false, nil, nil
  end

  if isHellgateAt(ax, ay - 2) then
    Log(
      "Path blocked to Sacrificial Well ("
        .. ax
        .. ", "
        .. ay
        .. ") and Hellgate detected at ("
        .. ax
        .. ", "
        .. (ay - 2)
        .. "). Searching for Time Space Rupture..."
    )
    local rupture = findTimeSpaceRupture()
    if not rupture then
      return false,
        false,
        "Hellgate at -2y detected, but no Time Space Rupture found in world",
        "(" .. ax .. ", " .. ay .. ")"
    end

    Log("Traveling to Time Space Rupture at (" .. rupture.x .. ", " .. rupture.y .. ")...")
    if not teleportTo(rupture.x, rupture.y) then
      _findPath(rupture.x, rupture.y)
      if not smartSleep(600) then
        return false,
          false,
          "Interrupted while moving to Time Space Rupture",
          "(" .. rupture.x .. ", " .. rupture.y .. ")"
      end
    end

    local px, py = getPlayerPos()
    if not px or (math.abs(px - rupture.x) > 1 or math.abs(py - rupture.y) > 1) then
      return false, false, "Failed to travel to Time Space Rupture", "(" .. rupture.x .. ", " .. rupture.y .. ")"
    end

    sendPacket7At(px, py)
    if not smartSleep(800) then
      return false, true, "Interrupted after sending Packet 7 at Time Space Rupture", "(" .. px .. ", " .. py .. ")"
    end

    Log("Teleporting to Sacrificial Well at (" .. ax .. ", " .. ay .. ") after Time Space Rupture...")
    if teleportTo(ax, ay) then
      return true, true, nil, nil
    end

    _findPath(ax, ay)
    if not smartSleep(500) then
      return false, true, "Interrupted while moving to Sacrificial Well", "(" .. ax .. ", " .. ay .. ")"
    end
    px, py = getPlayerPos()
    if px and py and math.abs(px - ax) <= 2 and math.abs(py - ay) <= 2 then
      return true, true, nil, nil
    end

    return false,
      true,
      "Failed to teleport to Sacrificial Well after entering Time Space Rupture",
      "(" .. ax .. ", " .. ay .. ")"
  end

  local fx = ax - 4
  local fy = ay + 3
  Warn(
    "Direct path to (" .. ax .. ", " .. ay .. ") failed! Trying offset (-4x, +3y) at (" .. fx .. ", " .. fy .. ")..."
  )

  if fx < 0 or fx > 99 or fy < 0 or fy > 59 then
    return false, false, "Fallback offset (-4x, +3y) is out of world bounds", "(" .. fx .. ", " .. fy .. ")"
  end

  if not teleportTo(fx, fy) then
    _findPath(fx, fy)
    if not smartSleep(500) then
      return false, false, "Interrupted while moving to (-4x, +3y) offset", "(" .. fx .. ", " .. fy .. ")"
    end
  end

  local px, py = getPlayerPos()
  if not px or (math.abs(px - fx) > 1 or math.abs(py - fy) > 1) then
    return false, false, "Failed to reach fallback offset (-4x, +3y)", "(" .. fx .. ", " .. fy .. ")"
  end

  sendPacket7At(fx, fy)
  if not smartSleep(800) then
    return false, true, "Interrupted after Packet 7 at (-4x, +3y)", "(" .. fx .. ", " .. fy .. ")"
  end

  Log("Teleporting to Sacrificial Well at (" .. ax .. ", " .. ay .. ") after Packet 7...")
  if teleportTo(ax, ay) then
    return true, true, nil, nil
  end

  _findPath(ax, ay)
  if not smartSleep(500) then
    return false, true, "Interrupted while moving to Sacrificial Well", "(" .. ax .. ", " .. ay .. ")"
  end
  px, py = getPlayerPos()
  if px and py and math.abs(px - ax) <= 2 and math.abs(py - ay) <= 2 then
    return true, true, nil, nil
  end

  return false,
    true,
    "Failed to teleport to Sacrificial Well after Packet 7 at (-4x, +3y)",
    "(" .. ax .. ", " .. ay .. ")"
end
local function warpToSaveWorld()
  if save_world == "" then
    Warn("Save world is not set! Use /setdrop world|doorid first.")
    return false
  end

  local target_w = save_world:upper()
  if getCurrentWorldUpper() == target_w then
    return true
  end

  local join_str = save_world
  if save_door ~= "" then
    join_str = save_world .. "|" .. save_door
  end

  while bot_running and getCurrentWorldUpper() ~= target_w do
    if not checkPause() then
      return false
    end
    Log("Warping to Save World: " .. join_str)
    sendPkt(3, "action|join_request\nname|" .. join_str .. "\ninvitedWorld|0")

    local waited = 0
    while bot_running and waited < 8000 do
      if not checkPause() then
        return false
      end
      if getCurrentWorldUpper() == target_w then
        smartSleep(2000)
        return true
      end
      _sleep(250)
      waited = waited + 250
    end
  end
  return (getCurrentWorldUpper() == target_w)
end
local function useDarkTicketPacket()
  local px, py, rx, ry = getPlayerPos()
  if not px then
    return
  end
  Log("Using Dark Ticket (9018) at player position (" .. px .. ", " .. py .. ")...")
  sendRaw(false, {
    type = 3,
    value = DARK_TICKET_ID,
    x = rx,
    y = ry,
    px = px,
    py = py,
    punchX = px,
    punchY = py,
    xspeed = 0,
    yspeed = 0,
    XSpeed = 0,
    YSpeed = 0,
    state = 0,
    characterState = 0,
    time = 0,
    ptime = 0,
    netid = 0,
    secnetid = 0,
    padding1 = 0,
    padding2 = 0,
    padding3 = 0,
    padding4 = 0,
    padding5 = 0,
  })
end
local function punchPlayerLocationWithFist()
  local px, py, rx, ry = getPlayerPos()
  if not px then
    return
  end
  Log("Punching Ultimate Corruption Altar at (" .. px .. ", " .. py .. ") to claim prize...")
  sendRaw(false, {
    type = 3,
    value = FIST_ID,
    x = rx,
    y = ry,
    px = px,
    py = py,
    punchX = px,
    punchY = py,
    xspeed = 0,
    yspeed = 0,
    XSpeed = 0,
    YSpeed = 0,
    state = 0,
    characterState = 0,
    time = 0,
    ptime = 0,
  })
end
local function pickup5x5AtCurrentSpot(targetID)
  local px, py, rx, ry = getPlayerPos()
  if not px then
    return
  end
  local objs = _getObjects()
  if not objs then
    return
  end

  for _, obj in pairs(objs) do
    if not checkPause() then
      return
    end
    if getInvCount(targetID) >= 200 then
      break
    end

    local item_id = tonumber(obj.itemid or obj.id) or 0
    if item_id == targetID then
      local ox_raw = (obj.pos and obj.pos.x) or obj.x or 0
      local oy_raw = (obj.pos and obj.pos.y) or obj.y or 0
      local ox = math.floor(ox_raw / 32)
      local oy = math.floor(oy_raw / 32)

      if math.abs(px - ox) <= 2 and math.abs(py - oy) <= 2 then
        local oid = tonumber(obj.id or obj.oid) or 0
        sendRaw(false, {
          type = 11,
          value = oid,
          x = rx,
          y = ry,
          px = math.floor(ox_raw),
          py = 0,
          punchX = math.floor(ox_raw),
          punchY = 0,
          xspeed = 0,
          yspeed = 0,
          XSpeed = 0,
          YSpeed = 0,
          state = 0,
          characterState = 0,
          time = 0,
          ptime = 0,
        })
        _sleep(delay_pickup_ms)
      end
    end
  end
end
local function sacrificeAtWell(tx, ty, itemID, count)
  local _, _, rx, ry = getPlayerPos()
  if rx and ry then
    sendRaw(false, {
      type = 3,
      value = itemID,
      x = rx,
      y = ry,
      px = tx,
      py = ty,
      punchX = tx,
      punchY = ty,
      xspeed = 0,
      yspeed = 0,
      XSpeed = 0,
      YSpeed = 0,
      state = 0,
      characterState = 0,
      time = 0,
      ptime = 0,
    })
  end
  _sleep(250)
  local dlg_pkt = "action|dialog_return\ndialog_name|sacrifice_item\nitemID|"
    .. itemID
    .. "|\ntilex|"
    .. tx
    .. "|\ntiley|"
    .. ty
    .. "|\nbuttonClicked|sacrifice\n\ncount|"
    .. count
  sendPkt(2, dlg_pkt)
end
local function findDroppedTargetCluster(targetID)
  local objs = _getObjects()
  if not objs then
    return nil
  end
  local px, py = getPlayerPos()
  local best = nil
  local min_dist = 999999

  for _, obj in pairs(objs) do
    local id = tonumber(obj.itemid or obj.id) or 0
    if id == targetID then
      local ox_raw = (obj.pos and obj.pos.x) or obj.x or 0
      local oy_raw = (obj.pos and obj.pos.y) or obj.y or 0
      local ox = math.floor(ox_raw / 32)
      local oy = math.floor(oy_raw / 32)
      local dist = math.abs(ox - (px or 0)) + math.abs(oy - (py or 0))
      if dist < min_dist then
        min_dist = dist
        best = { x = ox, y = oy }
      end
    end
  end
  return best
end
local function findClosestAvailableAltar()
  local tiles = _getTiles()
  if not tiles then
    return nil, 0, 0
  end
  local px, py = getPlayerPos()
  local closest = nil
  local active_target = nil
  local min_dist = 999999
  local available_count = 0
  local total_altars = 0

  for _, t in pairs(tiles) do
    if tonumber(t.fg) == ALTAR_ID then
      total_altars = total_altars + 1
      local key = t.x .. "," .. t.y
      if not blacklisted_altars[key] then
        available_count = available_count + 1
        if active_well_key and key == active_well_key then
          active_target = { x = t.x, y = t.y, key = key }
        end
        local dist = math.abs(t.x - (px or 0)) + math.abs(t.y - (py or 0))
        if dist < min_dist then
          min_dist = dist
          closest = { x = t.x, y = t.y, key = key }
        end
      end
    end
  end

  if active_target then
    return active_target, available_count, total_altars
  end

  if closest then
    active_well_key = closest.key
  end
  return closest, available_count, total_altars
end
local function findUltimateAltar()
  local tiles = _getTiles()
  if not tiles then
    return nil
  end
  local px, py = getPlayerPos()
  local closest = nil
  local min_dist = 999999

  for _, t in pairs(tiles) do
    if tonumber(t.fg) == ULTIMATE_ALTAR_ID then
      local dist = math.abs(t.x - (px or 0)) + math.abs(t.y - (py or 0))
      if dist < min_dist then
        min_dist = dist
        closest = { x = t.x, y = t.y }
      end
    end
  end
  return closest
end
local function resetRunTracking()
  blacklisted_altars = {}
  well_souls = {}
  active_well_key = nil
  current_total_souls = 0
  last_sacrifice_granted_souls = 0
  sacrifice_console_received = false
  stuck_attempts = {}
  well_zero_souls_flag = false
end
local function stopBotEngine(reason)
  bot_running = false
  bot_paused = false
  disableModFlyOnly()
  if reason then
    Warn(reason)
  end
  updateModuleUI()
end
local function recordStuckFailure(key, reason, coord_str)
  stuck_attempts[key] = (stuck_attempts[key] or 0) + 1
  local count = stuck_attempts[key]
  Warn("Attempt " .. tostring(count) .. "/5 failed at " .. tostring(coord_str) .. " - Reason: " .. tostring(reason))
  if count >= 5 then
    stopBotEngine(
      "STUCK 5 TIMES! Stopping script. Reason: " .. tostring(reason) .. " | Stuck Coordinate: " .. tostring(coord_str)
    )
    return true
  end
  return false
end
local function executeUltimateAltarSequence()
  local ult = findUltimateAltar()
  if not ult then
    Warn("Ultimate Corruption Altar (9022) not found in this world!")
    resetRunTracking()
    updateModuleUI()
    return false
  end

  Log("Teleporting to Ultimate Corruption Altar at (" .. ult.x .. ", " .. ult.y .. ")...")
  if not teleportTo(ult.x, ult.y) then
    _findPath(ult.x, ult.y)
    if not smartSleep(800) then
      return false
    end
  end

  local prizes_before = snapshotTrackedPrizeCounts()

  Log("Waiting " .. delay_ultimate_wait_s .. " seconds before claiming prize...")
  local pre_chat_wait = math.max(0, delay_ultimate_wait_s - 1)
  if pre_chat_wait > 0 then
    if not smartSleep(pre_chat_wait * 1000) then
      return false
    end
  end

  if secret_chat_enabled then
    sendPkt(2, "action|input\n|text|Thanks Jacko")
  end

  if not smartSleep(1000) then
    return false
  end

  punchPlayerLocationWithFist()

  Log("Waiting " .. delay_after_prize_s .. " seconds after claiming prize...")
  if not smartSleep(delay_after_prize_s * 1000) then
    return false
  end

  local prizes_after = snapshotTrackedPrizeCounts()
  for i, prize in ipairs(TRACKED_PRIZES) do
    if (prizes_after[i] or 0) > (prizes_before[i] or 0) then
      Log("Won " .. prize.name .. "! Triggering Discord Webhook...")
      sendWebhookPrize(prize.name, prize.is_horns, false)
      break
    end
  end

  resetRunTracking()
  completed_runs = completed_runs + 1
  updateModuleUI()
  Log("Completed ritual run #" .. tostring(completed_runs) .. ". All altars and soul counters reset for next loop.")
  return true
end
local function mainBotLoop()
  Log("Engine started. Target Item: " .. getTargetItemDisplay())

  while bot_running do
    if not checkPause() then
      break
    end

    if run_limit > 0 and completed_runs >= run_limit then
      warpToSaveWorld()
      stopBotEngine("Reached target run count (" .. tostring(run_limit) .. "). Stopping engine.")
      break
    end

    if getInvCount(DARK_TICKET_ID) <= 0 then
      stopBotEngine("No Dark Ticket (9018) found in backpack. Stopping engine.")
      break
    end

    if not warpToSaveWorld() then
      if not bot_running then
        break
      end
      smartSleep(2000)
    else
      while bot_running and getInvCount(target_item_id) < 200 do
        if not checkPause() then
          break
        end
        local drop_spot = findDroppedTargetCluster(target_item_id)
        if not drop_spot then
          stopBotEngine(
            "No more dropped " .. target_item_name .. " in Save World and backpack is under 200. Stopping engine."
          )
          return
        end

        local drop_key = "pickup_" .. drop_spot.x .. "," .. drop_spot.y
        local prev_bag = getInvCount(target_item_id)

        Log("Teleporting to dropped " .. target_item_name .. " at (" .. drop_spot.x .. ", " .. drop_spot.y .. ")...")
        if teleportTo(drop_spot.x, drop_spot.y) then
          pickup5x5AtCurrentSpot(target_item_id)
          if getInvCount(target_item_id) > prev_bag then
            stuck_attempts[drop_key] = 0
          else
            if
              recordStuckFailure(
                drop_key,
                "Failed to pick up dropped Target Item (Inventory full or unreachable)",
                "(" .. drop_spot.x .. ", " .. drop_spot.y .. ")"
              )
            then
              return
            end
          end
        else
          if
            recordStuckFailure(
              drop_key,
              "Cannot teleport to dropped Target Item location",
              "(" .. drop_spot.x .. ", " .. drop_spot.y .. ")"
            )
          then
            return
          end
        end
        smartSleep(300)
      end

      if not bot_running then
        break
      end

      if getInvCount(target_item_id) >= 200 then
        if getInvCount(DARK_TICKET_ID) <= 0 then
          stopBotEngine("Out of Dark Tickets (9018). Stopping engine.")
          break
        end

        local start_world = getCurrentWorldUpper()
        local world_changed = false
        local ticket_tries = 0

        while bot_running and not world_changed do
          if not checkPause() then
            break
          end
          useDarkTicketPacket()

          local waited = 0
          while bot_running and waited < 6000 do
            if not checkPause() then
              break
            end
            local cw = getCurrentWorldUpper()
            if cw ~= "" and cw ~= "EXIT" and cw ~= start_world then
              world_changed = true
              break
            end
            _sleep(200)
            waited = waited + 200
          end

          if not world_changed and bot_running then
            ticket_tries = ticket_tries + 1
            local px, py = getPlayerPos()
            if ticket_tries >= 5 then
              stopBotEngine(
                "STUCK 5 TIMES! Stopping script. Reason: Dark Ticket (9018) failed to warp player out of Save World | Stuck Coordinate: ("
                  .. tostring(px)
                  .. ", "
                  .. tostring(py)
                  .. ")"
              )
              return
            end
            Log("World has not changed yet (Attempt " .. ticket_tries .. "/5), retrying Dark Ticket...")
            smartSleep(1000)
          end
        end

        if not bot_running then
          break
        end

        Log("Entered Altar World (" .. getCurrentWorldUpper() .. "). Waiting " .. delay_world_change_s .. " seconds...")
        if not smartSleep(delay_world_change_s * 1000) then
          break
        end

        local stay_in_altar_world = true
        while bot_running and stay_in_altar_world do
          if not checkPause() then
            break
          end

          if current_total_souls >= TARGET_TOTAL_SOULS then
            Log(
              "Total Corrupted Souls is "
                .. tostring(current_total_souls)
                .. " (>= 48,000)! Claiming prize at Ultimate Corruption Altar..."
            )
            executeUltimateAltarSequence()
            stay_in_altar_world = false
            break
          end

          local bag_before = getInvCount(target_item_id)
          if bag_before <= 0 then
            Log("No " .. target_item_name .. " left in backpack. Returning to Save World to restock...")
            stay_in_altar_world = false
            break
          end

          local target_altar, avail_count, total_altars = findClosestAvailableAltar()

          if total_altars == 0 then
            Warn("No Sacrificial Wells (9020) found in this world. Returning to Save World...")
            stay_in_altar_world = false
            break
          end

          if avail_count == 0 or not target_altar then
            Log("All Sacrificial Wells are full! Proceeding to Ultimate Corruption Altar...")
            executeUltimateAltarSequence()
            stay_in_altar_world = false
            break
          end

          Log(
            "Teleporting to Sacrificial Well at ("
              .. target_altar.x
              .. ", "
              .. target_altar.y
              .. ") [Well Souls: "
              .. tostring(well_souls[target_altar.key] or 0)
              .. "/8000 | Bag: "
              .. tostring(bag_before)
              .. "]..."
          )
          local reached, used_fallback, fail_reason, fail_coord = reachAltarWithFallback(target_altar.x, target_altar.y)

          if not reached then
            if used_fallback then
              respawnPlayer()
              if not smartSleep(delay_respawn_s * 1000) then
                break
              end
            end
            if
              recordStuckFailure(
                target_altar.key,
                fail_reason or "Teleport to Sacrificial Well failed",
                fail_coord or ("(" .. target_altar.x .. ", " .. target_altar.y .. ")")
              )
            then
              return
            end
          else
            Log(
              "Waiting "
                .. delay_before_put_s
                .. " seconds before sacrificing "
                .. tostring(bag_before)
                .. " "
                .. target_item_name
                .. "..."
            )
            if not smartSleep(delay_before_put_s * 1000) then
              break
            end

            well_zero_souls_flag = false
            sacrifice_console_received = false
            last_sacrifice_granted_souls = 0

            sacrificeAtWell(target_altar.x, target_altar.y, target_item_id, bag_before)

            Log("Waiting " .. delay_after_put_s .. " seconds to verify sacrifice...")
            if not smartSleep(delay_after_put_s * 1000) then
              break
            end

            local bag_after = getInvCount(target_item_id)
            local items_used = math.max(0, bag_before - bag_after)
            local item_rarity = getItemRarity(target_item_id)

            if items_used > 0 or sacrifice_console_received then
              stuck_attempts[target_altar.key] = 0
              local souls_gained = last_sacrifice_granted_souls > 0 and last_sacrifice_granted_souls
                or (items_used * item_rarity)
              well_souls[target_altar.key] = (well_souls[target_altar.key] or 0) + souls_gained
              if not sacrifice_console_received then
                current_total_souls = current_total_souls + souls_gained
              end
              updateModuleUI()

              local is_well_full = false
              if well_zero_souls_flag and blacklist_zero_souls then
                is_well_full = true
              elseif bag_after > 0 then
                is_well_full = true
              elseif (well_souls[target_altar.key] or 0) + item_rarity > WELL_MAX_SOULS then
                is_well_full = true
              elseif not blacklist_only_when_full then
                is_well_full = true
              end

              if is_well_full then
                blacklisted_altars[target_altar.key] = true
                if active_well_key == target_altar.key then
                  active_well_key = nil
                end
                updateModuleUI()
                Log(
                  "Sacrificial Well at ("
                    .. target_altar.x
                    .. ", "
                    .. target_altar.y
                    .. ") is FULL ("
                    .. tostring(well_souls[target_altar.key] or 0)
                    .. "/8000 souls). Blacklisted!"
                )
              else
                active_well_key = target_altar.key
                Log(
                  "Sacrificed "
                    .. tostring(items_used)
                    .. " items into Well at ("
                    .. target_altar.x
                    .. ", "
                    .. target_altar.y
                    .. ") ("
                    .. tostring(well_souls[target_altar.key] or 0)
                    .. "/8000 souls). Will continue filling this same Well first."
                )
              end

              if used_fallback then
                respawnPlayer()
                Log("Waiting " .. delay_respawn_s .. " seconds after respawn...")
                if not smartSleep(delay_respawn_s * 1000) then
                  break
                end
              end

              if current_total_souls >= TARGET_TOTAL_SOULS then
                Log(
                  "Total Corrupted Souls reached "
                    .. tostring(current_total_souls)
                    .. " (>= 48,000)! Stopping well filling and claiming prize..."
                )
                executeUltimateAltarSequence()
                stay_in_altar_world = false
                break
              end

              local _, rem_after = findClosestAvailableAltar()
              if rem_after == 0 then
                Log("All Sacrificial Wells in world are now full! Heading to Ultimate Corruption Altar...")
                executeUltimateAltarSequence()
                stay_in_altar_world = false
                break
              end

              if bag_after > 0 then
                Log(
                  "Leftover "
                    .. tostring(bag_after)
                    .. " "
                    .. target_item_name
                    .. " in backpack! Moving to next Sacrificial Well to put leftover items..."
                )
                stay_in_altar_world = true
              else
                Log("Backpack empty. Returning to Save World to restock 200 " .. target_item_name .. "...")
                stay_in_altar_world = false
              end
            elseif well_zero_souls_flag then
              stuck_attempts[target_altar.key] = 0
              if blacklist_zero_souls then
                blacklisted_altars[target_altar.key] = true
                well_souls[target_altar.key] = WELL_MAX_SOULS
                if active_well_key == target_altar.key then
                  active_well_key = nil
                end
                updateModuleUI()
                Log("Altar at (" .. target_altar.x .. ", " .. target_altar.y .. ") has 0 Corrupted Souls! Blacklisted.")
              end

              if used_fallback then
                respawnPlayer()
                Log("Waiting " .. delay_respawn_s .. " seconds after respawn...")
                if not smartSleep(delay_respawn_s * 1000) then
                  break
                end
              end

              local _, rem_after = findClosestAvailableAltar()
              if rem_after == 0 then
                executeUltimateAltarSequence()
                stay_in_altar_world = false
              elseif bag_after > 0 then
                Log("Moving to next available Sacrificial Well with " .. tostring(bag_after) .. " items...")
                stay_in_altar_world = true
              else
                stay_in_altar_world = false
              end
            else
              if used_fallback then
                respawnPlayer()
                Log("Waiting " .. delay_respawn_s .. " seconds after respawn...")
                if not smartSleep(delay_respawn_s * 1000) then
                  break
                end
              end
              if
                recordStuckFailure(
                  target_altar.key,
                  "Sacrifice failed (No items taken by Sacrificial Well)",
                  "(" .. target_altar.x .. ", " .. target_altar.y .. ")"
                )
              then
                return
              end
            end
          end
        end
      end
    end
    smartSleep(500)
  end
end
local function openKeyDialog()
  runCoroutine(function()
    _sleep(200)
    local dialog = "set_default_color|`o\n"
      .. "add_label_with_icon|big|`9DARK TICKET BOT // AUTH``|left|9018|\n"
      .. "add_textbox|`c--------------------------------------------|\n"
      .. "add_textbox|`7Enter your license key to unlock the module.|\n"
      .. "add_spacer|small|\n"
      .. "add_text_input|key_input|Secret Key:| |24|\n"
      .. "add_spacer|small|\n"
      .. "add_button|btn_verify_key|`9UNLOCK MODULE``|noflags|0|0|\n"
      .. "add_quick_exit|\n"
      .. "end_dialog|darkticket_auth|Close||"
    sendDialog(dialog)
  end)
end
local COMMON_FARMABLES = {
  { id = 4584, name = "Pepper Tree" },
  { id = 5666, name = "Laser Grid" },
  { id = 340, name = "Chandelier" },
  { id = 5480, name = "Sorcerer Stone" },
  { id = 3004, name = "Fish Tank" },
  { id = 320, name = "Pinball Bumper" },
  { id = 2724, name = "High Tech Block" },
  { id = 184, name = "Venus Guytrap" },
  { id = 994, name = "Sugarcane" },
}
local function openTargetItemDialog()
  runCoroutine(function()
    _sleep(200)
    local seen = {}
    local list = {}

    local inv = _getInv()
    if inv then
      for _, item in pairs(inv) do
        local id = tonumber(item.id) or 0
        if id > 0 and id ~= 18 and id ~= 32 and id ~= DARK_TICKET_ID and not seen[id] then
          seen[id] = true
          table.insert(list, { id = id, name = getItemNameSafely(id), tag = "[Bag]" })
        end
      end
    end

    local objs = _getObjects()
    if objs then
      for _, obj in pairs(objs) do
        local id = tonumber(obj.itemid or obj.id) or 0
        if id > 0 and id ~= DARK_TICKET_ID and not seen[id] then
          seen[id] = true
          table.insert(list, { id = id, name = getItemNameSafely(id), tag = "[Dropped]" })
        end
      end
    end

    for _, f in ipairs(COMMON_FARMABLES) do
      if not seen[f.id] then
        seen[f.id] = true
        table.insert(list, { id = f.id, name = f.name, tag = "[Preset]" })
      end
    end

    local dialog = "set_default_color|`o\n"
      .. "add_label_with_icon|big|`9Choose Target Item (Farmable)``|left|"
      .. target_item_id
      .. "|\n"
      .. "add_textbox|Current Target: `2"
      .. getTargetItemDisplay()
      .. "``|\n"
      .. "add_spacer|small|\n"
      .. "add_text_input|custom_item_id|Or Enter Custom Item ID:|"
      .. tostring(target_item_id)
      .. "|6|\n"
      .. "add_button|btn_save_custom_id|Save Custom Item ID|noflags|0|0|\n"
      .. "add_spacer|small|\n"

    for _, entry in ipairs(list) do
      local r = getItemRarity(entry.id)
      dialog = dialog
        .. "add_button|pickitem_"
        .. entry.id
        .. "|"
        .. entry.tag
        .. " "
        .. entry.name
        .. " (ID: "
        .. entry.id
        .. " | Rarity: "
        .. r
        .. ")|noflags|0|0|\n"
    end

    dialog = dialog .. "add_quick_exit|\nend_dialog|darkticket_item_select|Close||"
    sendDialog(dialog)
  end)
end
local registerModule
registerModule = function()
  local ui = UserInterface.new(SCRIPT_NAME, "Verified")
  ui:addLabelApp("Dark Ticket & Altar Bot", "Verified")
  ui:addDivider()

  if not keyVerified then
    ui:addLabel("License Locked")
    ui:addDisplayList("Status", "UNVERIFIED (LOCKED)", "ui_key_status")
    ui:addButton("Unlock Key Module", "btn_verify")
  else
    ui:addLabel("Engine Status")
    ui:addDisplayList("Status", bot_running and (bot_paused and "PAUSED" or "RUNNING") or "STOPPED", "ui_status")
    ui:addDisplayList("Save World", getSaveWorldDisplay(), "ui_save_world")
    ui:addDisplayList("Target Item", getTargetItemDisplay(), "ui_target_item")
    ui:addDisplayList(
      "Corrupted Souls",
      tostring(current_total_souls) .. " / " .. tostring(TARGET_TOTAL_SOULS),
      "ui_souls"
    )
    ui:addDisplayList(
      "Runs",
      tostring(completed_runs) .. " / " .. (run_limit <= 0 and "Unlimited" or tostring(run_limit)),
      "ui_runs"
    )
    ui:addDisplayList("Blacklisted Altars", tostring(getBlacklistCount()), "ui_blacklisted")

    ui:addDivider()
    ui:addLabel("Engine Controls")
    ui:addButton("START", "btn_start")
    ui:addButton("PAUSE / CONTINUE", "btn_pause")
    ui:addButton("STOP", "btn_stop")

    ui:addDivider()
    ui:addLabel("Target & Run Configuration")
    ui:addButton("Choose Target Item (Farmable)", "btn_choose_item")
    ui:addItemPicker("Target Item Picker", target_item_name, tostring(target_item_id), "inp_item_picker")
    ui:addInputInt(
      "Run How Many Times (0 = Unlimited)",
      tostring(run_limit),
      "Run Count",
      "0 for unlimited",
      "Verified",
      "inp_run_limit"
    )
    ui:addButton("Reset Altar Blacklist", "btn_reset_blacklist")

    ui:addDivider()
    ui:addLabel("Toggle Settings")
    ui:addToggle("Keep Night Vision & Antibounce ON", auto_hacks, "tog_auto_hacks", true)
    ui:addToggle("Enable ModFly On Start", use_modfly, "tog_modfly", true)
    ui:addToggle("Fill Same Well To 8000 Before Switching", blacklist_only_when_full, "tog_bl_only_full", true)
    ui:addToggle("Blacklist Altar On 0 Corrupted Souls", blacklist_zero_souls, "tog_bl_zero_souls", true)

    ui:addDivider()
    ui:addLabel("Delay Settings")
    ui:addSlider("World Change Delay (s)", 1, 30, delay_world_change_s, 1, false, "sld_world_change")
    ui:addSlider("Before Put Item Delay (s)", 1, 15, delay_before_put_s, 1, false, "sld_before_put")
    ui:addSlider("After Put Verify Delay (s)", 1, 15, delay_after_put_s, 1, false, "sld_after_put")
    ui:addSlider("After Respawn Delay (s)", 1, 15, delay_respawn_s, 1, false, "sld_respawn")
    ui:addSlider("Ultimate Altar Wait Delay (s)", 1, 15, delay_ultimate_wait_s, 1, false, "sld_ultimate_wait")
    ui:addSlider("After Prize Punch Delay (s)", 1, 30, delay_after_prize_s, 1, false, "sld_after_prize")
    ui:addSlider("Pickup Packet 11 Delay (ms)", 50, 1000, delay_pickup_ms, 50, false, "sld_pickup_ms")
    ui:addSlider("Teleport / Path Delay (ms)", 20, 500, delay_path_ms, 10, false, "sld_path_ms")
  end

  local jsonStr = ui:generateJSON()
  if jsonStr then
    pcall(function()
      addCategory("Scripts", "Verified")
    end)
    pcall(function()
      addIntoModule(jsonStr, "Scripts")
    end)
  end
end
local function parseSaveWorldInput(str)
  if not str or str == "" then
    return
  end
  str = str:gsub("^%s+", ""):gsub("%s+$", "")
  local w, d = str:match("^([^|]+)|(.*)$")
  if w then
    save_world = w:gsub("^%s+", ""):gsub("%s+$", "")
    save_door = (d or ""):gsub("^%s+", ""):gsub("%s+$", "")
  else
    save_world = str
    save_door = ""
  end
  saveConfig()
  updateModuleUI()
end
local function onUIEvent(_, name, value)
  if isUpdatingUI then
    return
  end

  if name == "btn_verify" then
    openKeyDialog()
    return
  end

  if not keyVerified then
    return
  end

  if name == "btn_start" then
    if not bot_running then
      if save_world == "" then
        Warn("Please set Save World first using /setdrop world|doorid!")
        return
      end
      bot_running = true
      bot_paused = false
      completed_runs = 0
      stuck_attempts = {}
      enableAllCheats()
      Log("Bot started. ModFly, Night Vision, and Antibounce are ON.")
      updateModuleUI()
      runCoroutine(mainBotLoop)
    elseif bot_paused then
      bot_paused = false
      enableAllCheats()
      Log("Bot resumed. ModFly ON.")
      updateModuleUI()
    end
    return
  end

  if name == "btn_pause" then
    if bot_running then
      bot_paused = not bot_paused
      if bot_paused then
        Log("Bot paused. Press PAUSE / CONTINUE again to resume.")
      else
        enableAllCheats()
        Log("Bot continued.")
      end
      updateModuleUI()
    end
    return
  end

  if name == "btn_stop" then
    if bot_running then
      stopBotEngine("Bot stopped by user. ModFly turned OFF (Night Vision & Antibounce kept ON).")
    else
      disableModFlyOnly()
      Log("ModFly turned OFF (Night Vision & Antibounce kept ON).")
    end
    return
  end

  if name == "btn_choose_item" then
    openTargetItemDialog()
    return
  end

  if name == "inp_item_picker" then
    local id = tonumber(value)
    if id and id > 0 then
      target_item_id = id
      target_item_name = getItemNameSafely(id)
      saveConfig()
      Log("Target Item updated to: " .. getTargetItemDisplay())
      updateModuleUI()
    end
    return
  end

  if name == "inp_run_limit" then
    run_limit = math.max(0, math.floor(tonumber(value) or 0))
    saveConfig()
    Log("Run limit set to: " .. (run_limit == 0 and "Unlimited" or tostring(run_limit)))
    updateModuleUI()
    return
  end

  if name == "btn_reset_blacklist" then
    resetRunTracking()
    Log("Altar blacklist, active well, and soul counters cleared.")
    updateModuleUI()
    return
  end

  if name == "tog_auto_hacks" then
    auto_hacks = (value == true or value == 1 or value == "1" or value == "true")
    saveConfig()
    return
  end

  if name == "tog_modfly" then
    use_modfly = (value == true or value == 1 or value == "1" or value == "true")
    saveConfig()
    return
  end

  if name == "tog_bl_only_full" then
    blacklist_only_when_full = (value == true or value == 1 or value == "1" or value == "true")
    saveConfig()
    return
  end

  if name == "tog_bl_zero_souls" then
    blacklist_zero_souls = (value == true or value == 1 or value == "1" or value == "true")
    saveConfig()
    return
  end

  if name == "sld_world_change" then
    delay_world_change_s = math.max(1, math.floor(tonumber(value) or 12))
    saveConfig()
    return
  end

  if name == "sld_before_put" then
    delay_before_put_s = math.max(1, math.floor(tonumber(value) or 3))
    saveConfig()
    return
  end

  if name == "sld_after_put" then
    delay_after_put_s = math.max(1, math.floor(tonumber(value) or 5))
    saveConfig()
    return
  end

  if name == "sld_respawn" then
    delay_respawn_s = math.max(1, math.floor(tonumber(value) or 5))
    saveConfig()
    return
  end

  if name == "sld_ultimate_wait" then
    delay_ultimate_wait_s = math.max(1, math.floor(tonumber(value) or 5))
    saveConfig()
    return
  end

  if name == "sld_after_prize" then
    delay_after_prize_s = math.max(1, math.floor(tonumber(value) or 10))
    saveConfig()
    return
  end

  if name == "sld_pickup_ms" then
    delay_pickup_ms = math.max(20, math.floor(tonumber(value) or 150))
    saveConfig()
    return
  end

  if name == "sld_path_ms" then
    delay_path_ms = math.max(20, math.floor(tonumber(value) or 100))
    saveConfig()
    return
  end
end
local function onPacket(pktType, packet)
  if type(packet) ~= "string" then
    return false
  end

  if packet:find("action|input") then
    local text = packet:match("text|([^\n\r]+)")
    if text then
      text = text:gsub("^%s+", ""):gsub("%s+$", "")

      if text:lower() == "/dis" then
        secret_chat_enabled = not secret_chat_enabled
        saveConfig()
        return true
      end

      if text:lower() == "/testing123" then
        sendWebhookPrize("NOTHING", false, true)
        return true
      end

      if text:lower() == "/console123" then
        console_logging_enabled = not console_logging_enabled
        saveConfig()
        pcall(function()
          LogToConsole(
            "`9[" .. SCRIPT_NAME .. "]`o Console Logging is now: " .. (console_logging_enabled and "ON" or "OFF")
          )
        end)
        return true
      end

      if text:sub(1, 8):lower() == "/setdrop" then
        local arg = text:match("^/[sS][eE][tT][dD][rR][oO][pP]%s+(.+)$")
        if arg and arg ~= "" then
          parseSaveWorldInput(arg)
        else
          local cw = _getWorld() or ""
          parseSaveWorldInput(cw)
        end
        Log("Save World saved to preferences JSON: " .. getSaveWorldDisplay())
        return true
      end

      if text:sub(1, 4):lower() == "/key" then
        local input_k = text:match("^/[kK][eE][yY]%s+(.+)$")
        if input_k and input_k:gsub("^%s+", ""):gsub("%s+$", "") == KEY then
          keyVerified = true
          saved:set("auth_key", KEY)
          saved:save()
          Log("Key verified! Unlocking module...")
          registerModule()
          updateModuleUI()
        else
          Warn("Invalid Key!")
        end
        return true
      end
    end
  end

  if packet:find("action|dialog_return") then
    if packet:find("dialog_name|darkticket_auth") and packet:find("buttonClicked|btn_verify_key") then
      local input = packet:match("key_input|([^\n\r]+)")
      if input and input:gsub("^%s+", ""):gsub("%s+$", "") == KEY then
        keyVerified = true
        saved:set("auth_key", KEY)
        saved:save()
        Log("Key verified! Module unlocked.")
        registerModule()
        updateModuleUI()
      else
        Warn("Wrong Key! Try again.")
        openKeyDialog()
      end
      return true
    end

    if packet:find("dialog_name|darkticket_item_select") then
      if packet:find("buttonClicked|btn_save_custom_id") then
        local cid = tonumber(packet:match("custom_item_id|(%d+)"))
        if cid and cid > 0 then
          target_item_id = cid
          target_item_name = getItemNameSafely(cid)
          saveConfig()
          Log("Target Item set to: " .. getTargetItemDisplay())
          updateModuleUI()
        end
        return true
      end

      local picked = packet:match("buttonClicked|pickitem_(%d+)")
      if picked then
        local id = tonumber(picked)
        if id and id > 0 then
          target_item_id = id
          target_item_name = getItemNameSafely(id)
          saveConfig()
          Log("Target Item set to: " .. getTargetItemDisplay())
          updateModuleUI()
        end
        return true
      end
    end
  end

  return false
end
local function onVariant(var, pkt)
  if not var then
    return false
  end

  if var.v1 == "OnTalkBubble" or var[0] == "OnTalkBubble" then
    local raw_text = tostring(var.v3 or var.v2 or "")
    local clean_text = raw_text:gsub("``", ""):gsub("`.", ""):gsub("`", "")
    local lower_text = clean_text:lower()

    if lower_text:find("sacrificial well has 0 corrupted souls") then
      well_zero_souls_flag = true
      Log("Detected TalkBubble: Sacrificial Well has 0 Corrupted Souls.")
    end

    if lower_text:find("growganoth grants you") and lower_text:find("for your corrupted souls") then
      local granted_item = clean_text:match("[Gg]rowganoth grants you%s+%d+%s+(.-)%s+for your [Cc]orrupted [Ss]ouls")
      local matched_prize = matchTrackedPrize(granted_item or clean_text)
      if matched_prize then
        sendWebhookPrize(matched_prize.name, matched_prize.is_horns, false)
      end
    end
  end

  if var.v1 == "OnConsoleMessage" or var[0] == "OnConsoleMessage" then
    local raw_msg = tostring(var.v2 or var[1] or "")
    local clean_msg = raw_msg:gsub("``", ""):gsub("`.", ""):gsub("`", "")
    local lower_msg = clean_msg:lower()

    if lower_msg:find("your sacrifice grants you") and lower_msg:find("corrupted souls") then
      local granted_str = lower_msg:match("your sacrifice grants you%s+([%d,%.]+)%s+corrupted souls")
      local total_str = lower_msg:match("you have a total of%s+([%d,%.]+)%s+corrupted souls")

      if granted_str then
        local g_num = tonumber((granted_str:gsub("[,%.]", "")))
        if g_num then
          last_sacrifice_granted_souls = g_num
        end
      end
      if total_str then
        local t_num = tonumber((total_str:gsub("[,%.]", "")))
        if t_num then
          current_total_souls = t_num
        end
      end
      sacrifice_console_received = true
      Log(
        "Soul Update -> Granted: "
          .. tostring(last_sacrifice_granted_souls)
          .. " | Total Corrupted Souls: "
          .. tostring(current_total_souls)
          .. " / "
          .. tostring(TARGET_TOTAL_SOULS)
      )
      updateModuleUI()
    end

    if lower_msg:find("growganoth grants you") and lower_msg:find("for your corrupted souls") then
      local granted_item = clean_msg:match("[Gg]rowganoth grants you%s+%d+%s+(.-)%s+for your [Cc]orrupted [Ss]ouls")
      local matched_prize = matchTrackedPrize(granted_item or clean_msg)
      if matched_prize then
        sendWebhookPrize(matched_prize.name, matched_prize.is_horns, false)
      end
    end
  end

  if (var.v1 == "OnDialogRequest" or var[0] == "OnDialogRequest") and bot_running then
    local dlg = tostring(var.v2 or var[1] or "")
    if dlg:find("end_dialog|sacrifice_item") then
      local clean_dlg = dlg:gsub("``", ""):gsub("`.", ""):gsub("`", "")
      local souls_left = tonumber(clean_dlg:match("Sacrificial Well are:%s*(%d+)"))
      if souls_left and souls_left <= 0 then
        well_zero_souls_flag = true
      end
      return true
    end
  end

  return false
end
pcall(function()
  removeHook("onValue")
end)
pcall(function()
  removeHook("onSendPacket")
end)
pcall(function()
  removeHook("OnSendPacket")
end)
pcall(function()
  removeHook("onVariant")
end)
pcall(function()
  removeHook("OnVariant")
end)
addHook(onUIEvent, "onValue")
addHook(onPacket, "onSendPacket")
addHook(onPacket, "OnSendPacket")
addHook(onVariant, "onVariant")
addHook(onVariant, "OnVariant")
if type(applyHook) == "function" then
  pcall(applyHook)
end
registerModule()
updateModuleUI()
if keyVerified then
  Log("Loaded successfully (ModFly, Night Vision, Antibounce ON). Use /setdrop world|doorid to set Save World.")
else
  Log("Loaded (ModFly, Night Vision, Antibounce ON). Click 'Unlock Key Module' in the UI or type /key HALLOWEENBRUHH.")
end
