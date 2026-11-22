local SCRIPT_NAME = "Growganoth 3-Mode Bot"
local KEY = "BWK72lJS9NAI"
local GROWGANOTH_WORLD = "GROWGANOTH"
local DROP_TARGET_X = 49
local DROP_TARGET_Y = 15
local WHITE_DOOR_ID = 6
local function resolveScriptPath()
  for _, dir in ipairs(CANDIDATE_PATHS) do
    local ok, f = pcall(function()
      return io.open(dir .. ".path_test", "w")
    end)
    if ok and f then
      pcall(function()
        f:close()
      end)
      pcall(function()
        os.remove(dir .. ".path_test")
      end)
      return dir
    end
  end
  return CANDIDATE_PATHS[1]
end
local SCRIPT_PATH = resolveScriptPath()
local KEY_FILE = SCRIPT_PATH .. "key_growganoth_3mode.txt"
local CONFIG_FILE = SCRIPT_PATH .. "growganoth_3mode_config.txt"
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
local keyVerified = false
local bot_running = false
local isUpdatingUI = false
local drop_world = ""
local drop_door = ""
local save_world = ""
local save_door = ""
local target_item_id = 4584
local target_item_name = "Pepper Tree"
local drop_threshold = 1
local save_drop_threshold = 200
local total_dropped_count = 0
local total_prizes_saved = 0
local last_detected_prize_str = "None"
local prize_received_this_drop = false
local mode_teleport = true
local mode_elder_sigil = false
local mode_ktesh_sigil = false
local tracked_prize_items = {}
local pending_save_prize_id = nil
local delay_world_change_s = 6
local delay_before_drop_s = 1
local delay_after_drop_s = 4
local delay_pickup_ms = 150
local delay_path_ms = 100
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
local function resolveItemIDByName(targetName)
  if not targetName or targetName == "" then
    return 0
  end
  local cleanName = targetName:gsub("``", ""):gsub("`.", ""):gsub("`", ""):gsub("^%s+", ""):gsub("%s+$", "")
  if cleanName == "" then
    return 0
  end

  local resolved = 0
  pcall(function()
    if type(getItemID) == "function" then
      local id = tonumber(getItemID(cleanName)) or 0
      if id > 0 then
        resolved = id
      end
    end
    if resolved <= 0 and type(GetItemID) == "function" then
      local id = tonumber(GetItemID(cleanName)) or 0
      if id > 0 then
        resolved = id
      end
    end
    if resolved <= 0 and type(growtopia) == "table" and type(growtopia.getItemID) == "function" then
      local id = tonumber(growtopia.getItemID(cleanName)) or 0
      if id > 0 then
        resolved = id
      end
    end
    if resolved <= 0 and type(findItemID) == "function" then
      local id = tonumber(findItemID(cleanName)) or 0
      if id > 0 then
        resolved = id
      end
    end
  end)

  -- Fallback ke scan inventory jika ada perbedaan huruf besar/kecil
  if resolved <= 0 then
    local lowerTarget = cleanName:lower()
    local inv = _getInv()
    if inv then
      for _, item in pairs(inv) do
        local id = tonumber(item.id) or 0
        if id > 0 then
          local iname = getItemNameSafely(id):lower()
          if iname == lowerTarget or iname:find(lowerTarget, 1, true) then
            resolved = id
            break
          end
        end
      end
    end
  end

  return resolved
end
local ELDER_SIGIL_ID = 0
local KTESH_SIGIL_ID = 0
local function refreshSigilIDs()
  if ELDER_SIGIL_ID <= 0 then
    ELDER_SIGIL_ID = resolveItemIDByName("Elder Sigil")
  end
  if KTESH_SIGIL_ID <= 0 then
    KTESH_SIGIL_ID = resolveItemIDByName("Sigil Of K'Tesh")
    if KTESH_SIGIL_ID <= 0 then
      KTESH_SIGIL_ID = resolveItemIDByName("Sigil of K'Tesh")
    end
  end
  if KTESH_SIGIL_ID > 0 and not tracked_prize_items[KTESH_SIGIL_ID] then
    tracked_prize_items[KTESH_SIGIL_ID] = "Sigil Of K'Tesh"
  end
end
refreshSigilIDs()
local function checkSavedKey()
  local verified = false
  pcall(function()
    local f = io.open(KEY_FILE, "r")
    if f then
      local content = f:read("*all")
      f:close()
      if content then
        content = content:gsub("^%s+", ""):gsub("%s+$", "")
        if content == KEY then
          verified = true
        end
      end
    end
  end)
  return verified
end
local function saveVerifiedKey()
  pcall(function()
    local f = io.open(KEY_FILE, "w")
    if f then
      f:write(KEY)
      f:close()
    end
  end)
end
local function enforceSingleMode()
  if mode_teleport then
    mode_elder_sigil = false
    mode_ktesh_sigil = false
  elseif mode_elder_sigil then
    mode_teleport = false
    mode_ktesh_sigil = false
  elseif mode_ktesh_sigil then
    mode_teleport = false
    mode_elder_sigil = false
  else
    mode_teleport = true
    mode_elder_sigil = false
    mode_ktesh_sigil = false
  end
end
local function loadConfig()
  pcall(function()
    local f = io.open(CONFIG_FILE, "r")
    if not f then
      return
    end
    for line in f:lines() do
      local k, v = line:match("^%s*([^=]+)=(.*)%s*$")
      if k and v then
        k = k:gsub("^%s+", ""):gsub("%s+$", "")
        v = v:gsub("^%s+", ""):gsub("%s+$", "")
        if k == "drop_world" then
          drop_world = v
        elseif k == "drop_door" then
          drop_door = v
        elseif k == "save_world" then
          save_world = v
        elseif k == "save_door" then
          save_door = v
        elseif k == "target_item_id" then
          target_item_id = tonumber(v) or 4584
        elseif k == "target_item_name" and v ~= "" then
          target_item_name = v
        elseif k == "drop_threshold" then
          drop_threshold = math.max(1, math.min(200, tonumber(v) or 1))
        elseif k == "save_drop_threshold" then
          save_drop_threshold = math.max(1, math.min(200, tonumber(v) or 200))
        elseif k == "mode_teleport" then
          mode_teleport = (v == "true")
        elseif k == "mode_elder_sigil" then
          mode_elder_sigil = (v == "true")
        elseif k == "mode_ktesh_sigil" then
          mode_ktesh_sigil = (v == "true")
        elseif k == "delay_world_change_s" then
          delay_world_change_s = tonumber(v) or 6
        elseif k == "delay_before_drop_s" then
          delay_before_drop_s = tonumber(v) or 1
        elseif k == "delay_after_drop_s" then
          delay_after_drop_s = tonumber(v) or 4
        elseif k == "delay_pickup_ms" then
          delay_pickup_ms = tonumber(v) or 150
        elseif k == "delay_path_ms" then
          delay_path_ms = tonumber(v) or 100
        end
      end
    end
    f:close()
  end)
  enforceSingleMode()
end
local function saveConfig()
  pcall(function()
    local f = io.open(CONFIG_FILE, "w")
    if not f then
      return
    end
    f:write("drop_world=" .. tostring(drop_world) .. "\n")
    f:write("drop_door=" .. tostring(drop_door) .. "\n")
    f:write("save_world=" .. tostring(save_world) .. "\n")
    f:write("save_door=" .. tostring(save_door) .. "\n")
    f:write("target_item_id=" .. tostring(target_item_id) .. "\n")
    f:write("target_item_name=" .. tostring(target_item_name) .. "\n")
    f:write("drop_threshold=" .. tostring(drop_threshold) .. "\n")
    f:write("save_drop_threshold=" .. tostring(save_drop_threshold) .. "\n")
    f:write("mode_teleport=" .. tostring(mode_teleport) .. "\n")
    f:write("mode_elder_sigil=" .. tostring(mode_elder_sigil) .. "\n")
    f:write("mode_ktesh_sigil=" .. tostring(mode_ktesh_sigil) .. "\n")
    f:write("delay_world_change_s=" .. tostring(delay_world_change_s) .. "\n")
    f:write("delay_before_drop_s=" .. tostring(delay_before_drop_s) .. "\n")
    f:write("delay_after_drop_s=" .. tostring(delay_after_drop_s) .. "\n")
    f:write("delay_pickup_ms=" .. tostring(delay_pickup_ms) .. "\n")
    f:write("delay_path_ms=" .. tostring(delay_path_ms) .. "\n")
    f:close()
  end)
end
keyVerified = checkSavedKey()
loadConfig()
target_item_name = getItemNameSafely(target_item_id)
local function Log(msg)
  pcall(function()
    LogToConsole("`9[" .. SCRIPT_NAME .. "]`o " .. tostring(msg))
  end)
end
local function Warn(msg)
  pcall(function()
    LogToConsole("`4[" .. SCRIPT_NAME .. "]`o " .. tostring(msg))
  end)
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
local function enableModFlyOnly()
  setToggleSafe("ModFly", true)
  setToggleSafe("AntiGravity", true)
end
local function disableModFlyOnly()
  setToggleSafe("ModFly", false)
  setToggleSafe("AntiGravity", false)
end
local function enableAllCheats()
  enableModFlyOnly()
  setToggleSafe("Night Vision", true)
  setToggleSafe("NightVision", true)
  setToggleSafe("Antibounce", true)
  setToggleSafe("AntiBounce", true)
  setToggleSafe("Anti Bounce", true)
end
enableAllCheats()
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
local function getDropWorldDisplay()
  if drop_world == "" then
    return "Not Set (/setdrop world|doorid)"
  end
  if drop_door ~= "" then
    return drop_world .. "|" .. drop_door
  end
  return drop_world
end
local function getSaveWorldDisplay()
  if save_world == "" then
    return "Not Set (/setsave world|doorid)"
  end
  if save_door ~= "" then
    return save_world .. "|" .. save_door
  end
  return save_world
end
local function getTargetItemDisplay()
  return target_item_name .. " (ID: " .. tostring(target_item_id) .. ")"
end
local function getActiveModeName()
  if mode_elder_sigil then
    return "Elder Sigil Mode"
  end
  if mode_ktesh_sigil then
    return "Sigil Of K'Tesh Mode"
  end
  return "Teleport Mode"
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
      editValue("ui_status", bot_running and "RUNNING" or "STOPPED")
      editValue("ui_active_mode", getActiveModeName())
      editValue("ui_drop_world", getDropWorldDisplay())
      editValue("ui_save_world", getSaveWorldDisplay())
      editValue("ui_target_item", getTargetItemDisplay())
      editValue("ui_last_prize", last_detected_prize_str)
      editValue("ui_drop_amount", tostring(drop_threshold) .. " / " .. tostring(save_drop_threshold))
      editValue("ui_total_dropped", tostring(total_dropped_count) .. " (Saved: " .. tostring(total_prizes_saved) .. ")")

      editValue("tog_mode_teleport", mode_teleport)
      editValue("tog_mode_elder", mode_elder_sigil)
      editValue("tog_mode_ktesh", mode_ktesh_sigil)
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
    local wait_t = math.min(step, ms - elapsed)
    _sleep(wait_t)
    elapsed = elapsed + wait_t
  end
  return bot_running
end
local function respawnPlayer()
  Log("Respawning player...")
  sendPkt(2, "action|respawn\n")
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
local function teleportTo(tx, ty)
  if not bot_running then
    return false
  end
  if tx < 0 or tx > 99 or ty < 0 or ty > 59 then
    return false
  end

  local px, py = getPlayerPos()
  if px == tx and py == ty then
    return true
  end

  for attempt = 1, 4 do
    if not bot_running then
      return false
    end

    pcall(function()
      _findPath(tx, ty)
    end)
    _sleep(delay_path_ms)

    local waited = 0
    while bot_running and waited < 1000 do
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
  end
  return false
end
local function useSigilAtPlayerLocation(sigilID, sigilLabel)
  local px, py, rx, ry = getPlayerPos()
  if not px then
    return false
  end

  -- Turn OFF ModFly before using sendPacketRaw (Packet 3) on Sigils
  Log("Turning OFF ModFly before using " .. tostring(sigilLabel) .. "...")
  disableModFlyOnly()
  _sleep(100)

  px, py, rx, ry = getPlayerPos()
  if not px then
    return false
  end

  Log("Using " .. tostring(sigilLabel) .. " (ID: " .. tostring(sigilID) .. ") at (" .. px .. ", " .. py .. ")...")
  sendRaw(false, {
    type = 3,
    value = sigilID,
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
  return true
end
local function warpToWorldSpec(worldName, doorID, label)
  if not worldName or worldName == "" then
    Warn(label .. " belum diatur!")
    return false
  end

  local target_w = worldName:upper()
  if getCurrentWorldUpper() == target_w then
    return true
  end

  local join_str = worldName
  if doorID and doorID ~= "" then
    join_str = worldName .. "|" .. doorID
  end

  while bot_running and getCurrentWorldUpper() ~= target_w do
    Log("Warping to " .. label .. ": " .. join_str)
    sendPkt(3, "action|join_request\nname|" .. join_str .. "\ninvitedWorld|0")

    local waited = 0
    while bot_running and waited < 8000 do
      if getCurrentWorldUpper() == target_w then
        smartSleep(delay_world_change_s * 1000)
        return true
      end
      _sleep(250)
      waited = waited + 250
    end
  end
  return (getCurrentWorldUpper() == target_w)
end
local function warpToGrowganoth()
  if getCurrentWorldUpper():find("^GROWGANOTH") then
    return true
  end

  while bot_running and not getCurrentWorldUpper():find("^GROWGANOTH") do
    Log("Warping to " .. GROWGANOTH_WORLD .. "...")
    sendPkt(3, "action|join_request\nname|" .. GROWGANOTH_WORLD .. "\ninvitedWorld|0")

    local waited = 0
    while bot_running and waited < 8000 do
      if getCurrentWorldUpper():find("^GROWGANOTH") then
        smartSleep(delay_world_change_s * 1000)
        return true
      end
      _sleep(250)
      waited = waited + 250
    end
  end
  return (getCurrentWorldUpper():find("^GROWGANOTH") ~= nil)
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
    if not bot_running then
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
local function dropItemPacket(itemID, countToDrop)
  local current_bag = getInvCount(itemID)
  local actual_drop = math.min(current_bag, math.max(1, math.min(200, countToDrop)))
  if actual_drop <= 0 then
    return false
  end

  sendPkt(2, "action|drop\n|itemID|" .. tostring(itemID))
  _sleep(250)
  sendPkt(
    2,
    "action|dialog_return\ndialog_name|drop_item\nitemID|"
      .. tostring(itemID)
      .. "|\ncount|"
      .. tostring(actual_drop)
      .. "\n"
  )
  return true
end
local function buildDroppedTileMap()
  local map = {}
  local objs = _getObjects()
  if not objs then
    return map
  end
  for _, obj in pairs(objs) do
    local ox_raw = (obj.pos and obj.pos.x) or obj.x or 0
    local oy_raw = (obj.pos and obj.pos.y) or obj.y or 0
    local tx = math.floor((ox_raw + 10) / 32)
    local ty = math.floor((oy_raw + 10) / 32)
    local key = tx .. "," .. ty
    map[key] = (map[key] or 0) + 1
  end
  return map
end
local function isTileStandableAndClean(tx, ty, droppedMap)
  if tx < 1 or tx > 97 or ty < 1 or ty > 58 then
    return false
  end
  -- Jangan pernah menginjak tile yang sudah ada dropped item
  if droppedMap[tx .. "," .. ty] and droppedMap[tx .. "," .. ty] > 0 then
    return false
  end
  local t = getSingleTile(tx, ty)
  if t and t.collidable then
    return false
  end
  return true
end
local function isDropTileValid(drop_x, drop_y, droppedMap, requireEmpty)
  if drop_x < 1 or drop_x > 98 or drop_y < 1 or drop_y > 58 then
    return false
  end
  local t = getSingleTile(drop_x, drop_y)
  if t then
    if t.collidable then
      return false
    end
    if tonumber(t.fg) == WHITE_DOOR_ID then
      return false
    end
  end
  local count = droppedMap[drop_x .. "," .. drop_y] or 0
  if requireEmpty then
    return count == 0
  else
    return count < 15
  end
end
local function findClosestSafeSaveSpot()
  local px, py = getPlayerPos()
  if not px or not py then
    return nil
  end
  local droppedMap = buildDroppedTileMap()

  for pass = 1, 2 do
    local requireEmptyDropTile = (pass == 1)
    local best = nil
    local best_dist = 999999

    for dy = -15, 15 do
      for dx = -25, 25 do
        local stand_x = px + dx
        local stand_y = py + dy
        local drop_x = stand_x + 1
        local drop_y = stand_y

        if
          isTileStandableAndClean(stand_x, stand_y, droppedMap)
          and isDropTileValid(drop_x, drop_y, droppedMap, requireEmptyDropTile)
        then
          local is_blocked = false
          pcall(function()
            is_blocked = _findPath(stand_x, stand_y, true)
          end)

          if not is_blocked then
            local dist = math.abs(dx) + math.abs(dy)
            if dist < best_dist then
              best_dist = dist
              best = { stand_x = stand_x, stand_y = stand_y, drop_x = drop_x, drop_y = drop_y }
            end
          end
        end
      end
    end

    if best then
      return best
    end
  end
  return nil
end
local function faceRightAtCurrentPos()
  local _, _, rx, ry = getPlayerPos()
  if not rx or not ry then
    return
  end
  pcall(function()
    sendRaw(false, {
      type = 0,
      state = 0,
      characterState = 0,
      x = rx,
      y = ry,
      px = -1,
      py = -1,
      punchX = -1,
      punchY = -1,
    })
  end)
end
local function getFullPrizeToSave()
  if pending_save_prize_id and pending_save_prize_id > 0 then
    local c = getInvCount(pending_save_prize_id)
    if c >= save_drop_threshold then
      return pending_save_prize_id,
        (tracked_prize_items[pending_save_prize_id] or getItemNameSafely(pending_save_prize_id)),
        c
    end
  end

  for pid, pname in pairs(tracked_prize_items) do
    if pid ~= target_item_id then
      local c = getInvCount(pid)
      if c >= save_drop_threshold then
        return pid, pname, c
      end
    end
  end

  return nil, nil, 0
end
local function checkAndSaveTrackedPrizesIfFull()
  local prize_id, prize_name, prize_count = getFullPrizeToSave()
  if not prize_id or prize_id <= 0 or prize_count < save_drop_threshold then
    return false
  end

  local dest_world = (save_world ~= "" and save_world) or drop_world
  local dest_door = (save_world ~= "" and save_door) or drop_door

  if dest_world == "" then
    Warn(
      "Prize "
        .. tostring(prize_name)
        .. " sudah "
        .. tostring(prize_count)
        .. ", tapi /setsave world|doorid belum diatur!"
    )
    return false
  end

  enableModFlyOnly()
  Log(
    "Prize "
      .. tostring(prize_name)
      .. " (ID: "
      .. tostring(prize_id)
      .. ") mencapai "
      .. tostring(prize_count)
      .. " (>= "
      .. tostring(save_drop_threshold)
      .. ")! Warping ke Save World..."
  )
  if not warpToWorldSpec(dest_world, dest_door, "Save World") then
    return false
  end

  -- Loop untuk menjatuhkan semua prize yang sudah >= save_drop_threshold
  while bot_running do
    local pid, pname, pcount = getFullPrizeToSave()
    if not pid or pcount < save_drop_threshold then
      break
    end

    local spot = findClosestSafeSaveSpot()
    if not spot then
      Warn(
        "Tidak menemukan tile kosong yang aman di Save World! Drop " .. tostring(pname) .. " di +1x posisi saat ini..."
      )
      faceRightAtCurrentPos()
      _sleep(200)
      local before_c = getInvCount(pid)
      dropItemPacket(pid, before_c)
      smartSleep(2000)
      local after_c = getInvCount(pid)
      if after_c < before_c then
        total_prizes_saved = total_prizes_saved + (before_c - after_c)
        updateModuleUI()
      else
        break
      end
    else
      Log(
        "Pindah ke tile bersih ("
          .. spot.stand_x
          .. ", "
          .. spot.stand_y
          .. ") untuk drop "
          .. tostring(pname)
          .. " di +1x ("
          .. spot.drop_x
          .. ", "
          .. spot.drop_y
          .. ")..."
      )
      if teleportTo(spot.stand_x, spot.stand_y) then
        faceRightAtCurrentPos()
        if not smartSleep(400) then
          break
        end

        local before_c = getInvCount(pid)
        dropItemPacket(pid, before_c)
        if not smartSleep(2500) then
          break
        end

        local after_c = getInvCount(pid)
        if after_c < before_c then
          total_prizes_saved = total_prizes_saved + (before_c - after_c)
          updateModuleUI()
          Log(
            "Berhasil menyimpan "
              .. tostring(before_c - after_c)
              .. "x "
              .. tostring(pname)
              .. " di ("
              .. spot.drop_x
              .. ", "
              .. spot.drop_y
              .. ")!"
          )
        end
      else
        smartSleep(1000)
      end
    end
  end

  pending_save_prize_id = nil
  return true
end
local function stopBotEngine(reason)
  bot_running = false
  disableModFlyOnly()
  if reason then
    Warn(reason)
  end
  updateModuleUI()
end
local function restockItemInDropWorld(itemID, itemName, minRequired)
  enableModFlyOnly()
  if not warpToWorldSpec(drop_world, drop_door, "Drop/Restock World") then
    return false
  end

  while bot_running and getInvCount(itemID) < 200 do
    local drop_spot = findDroppedTargetCluster(itemID)
    if not drop_spot then
      if getInvCount(itemID) >= minRequired then
        Log("Sisa " .. itemName .. " di lantai habis, lanjut dengan " .. tostring(getInvCount(itemID)) .. " di tas.")
        return true
      else
        stopBotEngine("Tidak ada lagi " .. itemName .. " di Drop World! Bot berhenti.")
        return false
      end
    end

    Log("Teleporting ke " .. itemName .. " di (" .. drop_spot.x .. ", " .. drop_spot.y .. ")...")
    if teleportTo(drop_spot.x, drop_spot.y) then
      pickup5x5AtCurrentSpot(itemID)
    end
    smartSleep(300)
  end
  return (getInvCount(itemID) >= minRequired)
end
local function mainBotLoop()
  Log("Bot started! Mode: " .. getActiveModeName() .. " | Target: " .. getTargetItemDisplay())

  while bot_running do
    refreshSigilIDs()

    -- 1. Cek apakah ada Prize yang sudah mencapai save_drop_threshold (Default 200)
    local full_pid = getFullPrizeToSave()
    if full_pid then
      checkAndSaveTrackedPrizesIfFull()
      if not bot_running then
        break
      end
    end

    -- 2. Cek ketersediaan Target Item untuk di-drop ke Growganoth
    if getInvCount(target_item_id) < drop_threshold then
      if not restockItemInDropWorld(target_item_id, target_item_name, drop_threshold) then
        break
      end
    end

    if not bot_running then
      break
    end

    -- 3. Jika Elder Sigil Mode atau Sigil Of K'Tesh Mode aktif, pastikan Sigil tersedia
    if mode_elder_sigil then
      refreshSigilIDs()
      if ELDER_SIGIL_ID <= 0 or getInvCount(ELDER_SIGIL_ID) <= 0 then
        if ELDER_SIGIL_ID > 0 then
          Log("Elder Sigil habis di tas, mencari di Drop World...")
          if not restockItemInDropWorld(ELDER_SIGIL_ID, "Elder Sigil", 1) then
            break
          end
        else
          stopBotEngine("Elder Sigil tidak ditemukan (getItemID = 0)! Pastikan getItemID('Elder Sigil') valid.")
          break
        end
      end
    elseif mode_ktesh_sigil then
      refreshSigilIDs()
      if KTESH_SIGIL_ID <= 0 or getInvCount(KTESH_SIGIL_ID) <= 0 then
        if KTESH_SIGIL_ID > 0 then
          Log("Sigil Of K'Tesh habis di tas, mencari di Drop World...")
          if not restockItemInDropWorld(KTESH_SIGIL_ID, "Sigil Of K'Tesh", 1) then
            break
          end
        else
          stopBotEngine("Sigil Of K'Tesh tidak ditemukan (getItemID = 0)!")
          break
        end
      end
    end

    if not bot_running then
      break
    end

    -- 4. Masuk ke GROWGANOTH & jalankan sesuai Mode yang dipilih
    if getInvCount(target_item_id) >= drop_threshold then
      if warpToGrowganoth() then
        while bot_running and getInvCount(target_item_id) >= drop_threshold do
          if not getCurrentWorldUpper():find("^GROWGANOTH") then
            break
          end

          -- Jika ada prize yang sudah mencapai save_drop_threshold, langsung simpan ke Save World
          if getFullPrizeToSave() then
            checkAndSaveTrackedPrizesIfFull()
            break
          end

          local ready_to_drop = false

          if mode_teleport then
            -- MODE 1: TELEPORT BIASA KE (49, 15)
            enableModFlyOnly()
            Log("[Teleport Mode] Teleporting ke (" .. DROP_TARGET_X .. ", " .. DROP_TARGET_Y .. ")...")
            if teleportTo(DROP_TARGET_X, DROP_TARGET_Y) then
              ready_to_drop = true
            else
              Warn(
                "Gagal teleport ke (" .. DROP_TARGET_X .. ", " .. DROP_TARGET_Y .. "), respawning & mencoba ulang..."
              )
              respawnPlayer()
              smartSleep(3000)
            end
          elseif mode_elder_sigil then
            -- MODE 2: GUNAKAN ELDER SIGIL (PACKET 3 DI LOKASI PLAYER, MODFLY OFF SEBELUM PAKAI)
            refreshSigilIDs()
            if ELDER_SIGIL_ID <= 0 or getInvCount(ELDER_SIGIL_ID) <= 0 then
              enableModFlyOnly()
              Log("Elder Sigil di tas habis, keluar untuk restock...")
              break
            end
            local _, start_py = getPlayerPos()
            useSigilAtPlayerLocation(ELDER_SIGIL_ID, "Elder Sigil")

            local waited_tp = 0
            while bot_running and waited_tp < 3000 do
              local _, now_py = getPlayerPos()
              if now_py and start_py and now_py < (start_py - 5) then
                ready_to_drop = true
                break
              end
              _sleep(50)
              waited_tp = waited_tp + 50
            end
            ready_to_drop = true
          elseif mode_ktesh_sigil then
            -- MODE 3: GUNAKAN SIGIL OF K'TESH (PACKET 3 DI LOKASI PLAYER, MODFLY OFF SEBELUM PAKAI)
            refreshSigilIDs()
            if KTESH_SIGIL_ID <= 0 or getInvCount(KTESH_SIGIL_ID) <= 0 then
              enableModFlyOnly()
              Log("Sigil Of K'Tesh di tas habis, keluar untuk restock...")
              break
            end
            local _, start_py = getPlayerPos()
            useSigilAtPlayerLocation(KTESH_SIGIL_ID, "Sigil Of K'Tesh")

            local waited_tp = 0
            while bot_running and waited_tp < 3000 do
              local _, now_py = getPlayerPos()
              if now_py and start_py and now_py < (start_py - 5) then
                ready_to_drop = true
                break
              end
              _sleep(50)
              waited_tp = waited_tp + 50
            end
            ready_to_drop = true
          end

          if ready_to_drop and bot_running then
            if not smartSleep(delay_before_drop_s * 1000) then
              break
            end

            prize_received_this_drop = false
            local before_drop = getInvCount(target_item_id)
            Log("Dropping " .. tostring(drop_threshold) .. "x " .. target_item_name .. " ke Growganoth...")
            dropItemPacket(target_item_id, drop_threshold)

            if not smartSleep(delay_after_drop_s * 1000) then
              break
            end

            -- Turn ModFly back ON after finishing the drop
            if mode_elder_sigil or mode_ktesh_sigil then
              Log("Drop selesai, turning ModFly back ON...")
              enableModFlyOnly()
            end

            local after_drop = getInvCount(target_item_id)
            if after_drop < before_drop and prize_received_this_drop then
              total_dropped_count = total_dropped_count + (before_drop - after_drop)
              updateModuleUI()
            else
              Warn("Gagal drop atau prize tidak terlihat! Respawning dan mengulang loop...")
              respawnPlayer()
              if not smartSleep(3000) then
                break
              end
            end

            -- Setelah drop & OnConsoleMessage masuk, cek apakah ada prize yang sudah >= save_drop_threshold
            if getFullPrizeToSave() then
              checkAndSaveTrackedPrizesIfFull()
              break
            end
          end
        end
      end
    end

    smartSleep(400)
  end
end
local function openKeyDialog()
  runCoroutine(function()
    _sleep(200)
    local dialog = "set_default_color|`o\n"
      .. "add_label_with_icon|big|`9GROWGANOTH BOT // AUTH``|left|18|\n"
      .. "add_textbox|`c--------------------------------------------|\n"
      .. "add_textbox|`7Enter your license key to unlock the module.|\n"
      .. "add_spacer|small|\n"
      .. "add_text_input|key_input|Secret Key:| |24|\n"
      .. "add_spacer|small|\n"
      .. "add_button|btn_verify_key|`9UNLOCK MODULE``|noflags|0|0|\n"
      .. "add_quick_exit|\n"
      .. "end_dialog|growganoth_auth|Close||"
    sendDialog(dialog)
  end)
end
local COMMON_DROP_ITEMS = {
  { id = 4584, name = "Pepper Tree" },
  { id = 5666, name = "Laser Grid" },
  { id = 340, name = "Chandelier" },
  { id = 5480, name = "Sorcerer Stone" },
  { id = 3004, name = "Fish Tank" },
  { id = 320, name = "Pinball Bumper" },
  { id = 2724, name = "High Tech Block" },
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
        if id > 0 and id ~= 18 and id ~= 32 and not seen[id] then
          seen[id] = true
          table.insert(list, { id = id, name = getItemNameSafely(id), tag = "[Bag]" })
        end
      end
    end

    local objs = _getObjects()
    if objs then
      for _, obj in pairs(objs) do
        local id = tonumber(obj.itemid or obj.id) or 0
        if id > 0 and not seen[id] then
          seen[id] = true
          table.insert(list, { id = id, name = getItemNameSafely(id), tag = "[Dropped]" })
        end
      end
    end

    for _, f in ipairs(COMMON_DROP_ITEMS) do
      if not seen[f.id] then
        seen[f.id] = true
        table.insert(list, { id = f.id, name = f.name, tag = "[Preset]" })
      end
    end

    local dialog = "set_default_color|`o\n"
      .. "add_label_with_icon|big|`9Choose Item To Drop``|left|"
      .. target_item_id
      .. "|\n"
      .. "add_textbox|Current Item: `2"
      .. getTargetItemDisplay()
      .. "``|\n"
      .. "add_spacer|small|\n"
      .. "add_text_input|custom_item_id|Or Enter Custom Item ID:|"
      .. tostring(target_item_id)
      .. "|6|\n"
      .. "add_button|btn_save_custom_id|Save Custom Item ID|noflags|0|0|\n"
      .. "add_spacer|small|\n"

    for _, entry in ipairs(list) do
      dialog = dialog
        .. "add_button|pickitem_"
        .. entry.id
        .. "|"
        .. entry.tag
        .. " "
        .. entry.name
        .. " (ID: "
        .. entry.id
        .. ")|noflags|0|0|\n"
    end

    dialog = dialog .. "add_quick_exit|\nend_dialog|growganoth_item_select|Close||"
    sendDialog(dialog)
  end)
end
local registerModule
registerModule = function()
  local ui = UserInterface.new(SCRIPT_NAME, "Verified")
  ui:addLabelApp("Growganoth 3-Mode Dropper", "Verified")
  ui:addDivider()

  if not keyVerified then
    ui:addLabel("License Locked")
    ui:addDisplayList("Status", "UNVERIFIED (LOCKED)", "ui_key_status")
    ui:addButton("Unlock Key Module", "btn_verify")
  else
    ui:addLabel("Bot Status")
    ui:addDisplayList("Status", bot_running and "RUNNING" or "STOPPED", "ui_status")
    ui:addDisplayList("Active Mode", getActiveModeName(), "ui_active_mode")
    ui:addDisplayList("Take/Drop World", getDropWorldDisplay(), "ui_drop_world")
    ui:addDisplayList("Prize Save World", getSaveWorldDisplay(), "ui_save_world")
    ui:addDisplayList("Drop Item", getTargetItemDisplay(), "ui_target_item")
    ui:addDisplayList("Last Prize", last_detected_prize_str, "ui_last_prize")
    ui:addDisplayList(
      "Drop / Save Limit",
      tostring(drop_threshold) .. " / " .. tostring(save_drop_threshold),
      "ui_drop_amount"
    )
    ui:addDisplayList(
      "Total Dropped",
      tostring(total_dropped_count) .. " (Saved: " .. tostring(total_prizes_saved) .. ")",
      "ui_total_dropped"
    )

    ui:addDivider()
    ui:addLabel("Controls")
    ui:addButton("START", "btn_start")
    ui:addButton("STOP", "btn_stop")

    ui:addDivider()
    ui:addLabel("Select Mode (Only 1 Active)")
    ui:addToggle("Teleport Mode", mode_teleport, "tog_mode_teleport", true)
    ui:addToggle("Elder Sigil Mode", mode_elder_sigil, "tog_mode_elder", true)
    ui:addToggle("Sigil Of K'Tesh Mode", mode_ktesh_sigil, "tog_mode_ktesh", true)

    ui:addDivider()
    ui:addLabel("Drop & Save Thresholds")
    ui:addButton("Choose Item To Drop", "btn_choose_item")
    ui:addItemPicker("Drop Item Picker", target_item_name, tostring(target_item_id), "inp_item_picker")
    ui:addSlider("Drop Threshold (1-200)", 1, 200, drop_threshold, 1, false, "sld_drop_threshold")
    ui:addSlider("Save Drop Threshold (1-200)", 1, 200, save_drop_threshold, 1, false, "sld_save_threshold")

    ui:addDivider()
    ui:addLabel("Delay Settings")
    ui:addSlider("World Warp Delay (s)", 2, 20, delay_world_change_s, 1, false, "sld_world_change")
    ui:addSlider("Before Drop Delay (s)", 1, 10, delay_before_drop_s, 1, false, "sld_before_drop")
    ui:addSlider("After Drop Delay (s)", 1, 15, delay_after_drop_s, 1, false, "sld_after_drop")
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
local function parseWorldDoorString(str)
  if not str or str == "" then
    return "", ""
  end
  str = str:gsub("^%s+", ""):gsub("%s+$", "")
  local w, d = str:match("^([^|]+)|(.*)$")
  if w then
    return w:gsub("^%s+", ""):gsub("%s+$", ""), (d or ""):gsub("^%s+", ""):gsub("%s+$", "")
  end
  return str, ""
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
      if drop_world == "" then
        Warn("Atur world bahan terlebih dahulu dengan /setdrop world|doorid!")
        return
      end
      bot_running = true
      enableAllCheats()
      Log("Bot STARTED dalam mode: " .. getActiveModeName())
      updateModuleUI()
      runCoroutine(mainBotLoop)
    end
    return
  end

  if name == "btn_stop" then
    if bot_running then
      stopBotEngine("Bot STOPPED oleh user.")
    else
      disableModFlyOnly()
      Log("Bot sudah berhenti.")
    end
    return
  end

  -- 3 Mutually Exclusive Mode Toggles
  if name == "tog_mode_teleport" then
    local state = (value == true or value == 1 or value == "1" or value == "true")
    if state then
      mode_teleport = true
      mode_elder_sigil = false
      mode_ktesh_sigil = false
    else
      if not mode_elder_sigil and not mode_ktesh_sigil then
        mode_teleport = true
      end
    end
    saveConfig()
    updateModuleUI()
    Log("Active Mode: " .. getActiveModeName())
    return
  end

  if name == "tog_mode_elder" then
    local state = (value == true or value == 1 or value == "1" or value == "true")
    if state then
      mode_elder_sigil = true
      mode_teleport = false
      mode_ktesh_sigil = false
    else
      if not mode_teleport and not mode_ktesh_sigil then
        mode_teleport = true
      end
    end
    saveConfig()
    updateModuleUI()
    Log("Active Mode: " .. getActiveModeName())
    return
  end

  if name == "tog_mode_ktesh" then
    local state = (value == true or value == 1 or value == "1" or value == "true")
    if state then
      mode_ktesh_sigil = true
      mode_teleport = false
      mode_elder_sigil = false
    else
      if not mode_teleport and not mode_elder_sigil then
        mode_teleport = true
      end
    end
    saveConfig()
    updateModuleUI()
    Log("Active Mode: " .. getActiveModeName())
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
      Log("Drop Item diubah ke: " .. getTargetItemDisplay())
      updateModuleUI()
    end
    return
  end

  if name == "sld_drop_threshold" then
    drop_threshold = math.max(1, math.min(200, math.floor(tonumber(value) or 1)))
    saveConfig()
    updateModuleUI()
    return
  end

  if name == "sld_save_threshold" then
    save_drop_threshold = math.max(1, math.min(200, math.floor(tonumber(value) or 200)))
    saveConfig()
    updateModuleUI()
    return
  end

  if name == "sld_world_change" then
    delay_world_change_s = math.max(2, math.floor(tonumber(value) or 6))
    saveConfig()
    return
  end

  if name == "sld_before_drop" then
    delay_before_drop_s = math.max(1, math.floor(tonumber(value) or 1))
    saveConfig()
    return
  end

  if name == "sld_after_drop" then
    delay_after_drop_s = math.max(1, math.floor(tonumber(value) or 4))
    saveConfig()
    return
  end

  if name == "sld_pickup_ms" then
    delay_pickup_ms = math.max(50, math.floor(tonumber(value) or 150))
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

      -- /setdrop world|doorid (World ambil bahan drop)
      if text:sub(1, 8):lower() == "/setdrop" then
        local arg = text:match("^/[sS][eE][tT][dD][rR][oO][pP]%s+(.+)$")
        if arg and arg ~= "" then
          drop_world, drop_door = parseWorldDoorString(arg)
        else
          drop_world, drop_door = parseWorldDoorString(_getWorld() or "")
        end
        saveConfig()
        updateModuleUI()
        Log("Take/Drop World tersimpan: " .. getDropWorldDisplay())
        return true
      end

      -- /setsave world|doorid (World simpan hadiah prize)
      if text:sub(1, 8):lower() == "/setsave" then
        local arg = text:match("^/[sS][eE][tT][sS][aA][vV][eE]%s+(.+)$")
        if arg and arg ~= "" then
          save_world, save_door = parseWorldDoorString(arg)
        else
          save_world, save_door = parseWorldDoorString(_getWorld() or "")
        end
        saveConfig()
        updateModuleUI()
        Log("Prize Save World tersimpan: " .. getSaveWorldDisplay())
        return true
      end

      if text:sub(1, 4):lower() == "/key" then
        local input_k = text:match("^/[kK][eE][yY]%s+(.+)$")
        if input_k and input_k:gsub("^%s+", ""):gsub("%s+$", "") == KEY then
          keyVerified = true
          saveVerifiedKey()
          Log("Key verified! Membuka module...")
          registerModule()
          updateModuleUI()
        else
          Warn("Key salah!")
        end
        return true
      end
    end
  end

  if packet:find("action|dialog_return") then
    if packet:find("dialog_name|growganoth_auth") and packet:find("buttonClicked|btn_verify_key") then
      local input = packet:match("key_input|([^\n\r]+)")
      if input and input:gsub("^%s+", ""):gsub("%s+$", "") == KEY then
        keyVerified = true
        saveVerifiedKey()
        Log("Key verified! Module terbuka.")
        registerModule()
        updateModuleUI()
      else
        Warn("Key salah! Coba lagi.")
        openKeyDialog()
      end
      return true
    end

    if packet:find("dialog_name|growganoth_item_select") then
      if packet:find("buttonClicked|btn_save_custom_id") then
        local cid = tonumber(packet:match("custom_item_id|(%d+)"))
        if cid and cid > 0 then
          target_item_id = cid
          target_item_name = getItemNameSafely(cid)
          saveConfig()
          Log("Drop Item diatur ke: " .. getTargetItemDisplay())
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
          Log("Drop Item diatur ke: " .. getTargetItemDisplay())
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

  -- Auto-detect semua nama item dari "A `2<Item Name>`` was bestowed upon you!" lalu panggil getItemID
  if
    var.v1 == "OnConsoleMessage"
    or var[0] == "OnConsoleMessage"
    or var.v1 == "OnTalkBubble"
    or var[0] == "OnTalkBubble"
  then
    local raw_msg = tostring(var.v3 or var.v2 or var[1] or "")
    local clean_msg = raw_msg:gsub("``", ""):gsub("`.", ""):gsub("`", ""):gsub("^%s+", ""):gsub("%s+$", "")

    if clean_msg:lower():find("was bestowed upon you") then
      prize_received_this_drop = true

      -- 1. Coba ambil dari antara tag warna `2...`` terlebih dahulu
      local extracted_name = raw_msg:match("`2(.-)``%s*was bestowed upon you")
      -- 2. Fallback ambil dari kalimat bersih "A/An <Item Name> was bestowed upon you"
      if not extracted_name or extracted_name == "" then
        extracted_name = clean_msg:match("[Aa]n?%s+(.-)%s+was bestowed upon you")
      end

      if extracted_name and extracted_name ~= "" then
        extracted_name = extracted_name:gsub("``", ""):gsub("`.", ""):gsub("`", ""):gsub("^%s+", ""):gsub("%s+$", "")
        local prize_id = resolveItemIDByName(extracted_name)

        if prize_id > 0 then
          tracked_prize_items[prize_id] = extracted_name
          local cur_count = getInvCount(prize_id)
          last_detected_prize_str = string.format("%s (ID: %d | Bag: %d)", extracted_name, prize_id, cur_count)
          Log("Prize Detected -> " .. last_detected_prize_str .. " / " .. tostring(save_drop_threshold))
          updateModuleUI()

          if cur_count >= save_drop_threshold then
            pending_save_prize_id = prize_id
          end
        else
          Warn("Prize terdeteksi ('" .. tostring(extracted_name) .. "'), tetapi getItemID mengembalikan 0!")
        end
      end
    end
  end

  -- Sembunyikan popup konfirmasi drop saat bot berjalan
  if (var.v1 == "OnDialogRequest" or var[0] == "OnDialogRequest") and bot_running then
    local dlg = tostring(var.v2 or var[1] or "")
    if dlg:find("end_dialog|drop_item") then
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
addHook(onVariant, "onVariant")
if type(applyHook) == "function" then
  pcall(applyHook)
end
registerModule()
updateModuleUI()
if keyVerified then
  Log("Loaded! Gunakan /setdrop world|doorid (bahan) & /setsave world|doorid (simpan Prize).")
else
  Log("Loaded (LOCKED). Klik 'Unlock Key Module' di UI atau ketik /key BWK72lJS9NAI.")
end
