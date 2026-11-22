setMinimum("6.1.2")
local LICENSE_URL =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local LICENSE_PREF_NAME = "AutoCollectToDropLicense"
local LICENSE_PREF_KEY = "license_key"
local licensePref = nil
local savedLicense = ""
local function normalizeLicenseKey(value)
  value = tostring(value or "")
  value = value:gsub("%s+", "")
  return value:upper()
end
local function validLicenseFormat(value)
  value = normalizeLicenseKey(value)
  return value:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local function initLicensePreferences()
  -- Current Growlauncher docs expose Preferences through require("preferences").
  -- Some builds also expose a global Preferences table, so support both.
  local ok = pcall(function()
    local pref = nil

    if type(require) == "function" then
      local okRequire, module = pcall(require, "preferences")
      if okRequire and module ~= nil then
        pref = module
      end
    end

    if pref == nil and type(Preferences) == "table" then
      pref = Preferences
    end

    if pref == nil then
      return
    end

    if type(pref.new) == "function" then
      local created = pref:new(LICENSE_PREF_NAME)
      licensePref = created or pref
    else
      licensePref = pref
    end

    if licensePref ~= nil and type(licensePref.load) == "function" then
      licensePref:load()
    end

    if licensePref ~= nil and type(licensePref.get) == "function" then
      savedLicense = normalizeLicenseKey(licensePref:get(LICENSE_PREF_KEY, ""))
    end
  end)

  if not ok then
    licensePref = nil
    savedLicense = ""
  end
end
local function saveLicensePreference(key)
  if licensePref == nil then
    return false
  end

  local ok = pcall(function()
    licensePref:set(LICENSE_PREF_KEY, normalizeLicenseKey(key))
    licensePref:save()
  end)

  return ok
end
local function clearLicensePreference()
  if licensePref == nil then
    return false
  end

  local ok = pcall(function()
    licensePref:set(LICENSE_PREF_KEY, "")
    licensePref:save()
  end)

  return ok
end
initLicensePreferences()
local MW_PREF_NAME = "AutoCollectToDropAllSettingsV19.json"
ACD19_LEGACY_MW_PREF_NAME = "AutoCollectToDropMultiWorldV11"
ACD19_MW_SCHEMA = "19"
ACD19_MW_KEYS = {
  "worlds",
  "dropworld",
  "dropx",
  "dropy",
  "pickupdelay",
  "acktimeout",
  "batchmax",
  "items",
  "droptotal",
  "license_key",
}
local mwPref = nil
ACD19_mwPreferenceModule = nil
local mwSaved = {}
ACD19_mwSettingsRestored = false
ACD19_mwSaveState = "UNAVAILABLE"
ACD19_guardedUIWrites = {}
function ACD19_safeEditValue(name, value)
  if ACD19_guardedUIWrites[name] then
    return
  end
  ACD19_guardedUIWrites[name] = true
  pcall(function()
    editValue(name, value)
  end)
  ACD19_guardedUIWrites[name] = nil
end
function ACD19_safeSetStartToggle(state)
  if ACD19_guardedUIWrites["ACD_enable"] then
    return
  end
  ACD19_guardedUIWrites["ACD_enable"] = true
  local fn = editToggle or EditToggle
  if fn ~= nil then
    pcall(fn, "ACD_enable", state == true)
  end
  ACD19_guardedUIWrites["ACD_enable"] = nil
end
function ACD19_setAutoSaveStatus(message)
  if ACD19_mwSaveState == message then
    return
  end
  ACD19_mwSaveState = message
  ACD19_safeEditValue("ACD_autosave", message)
end
local function normalizeMWWorldName(value)
  return tostring(value or ""):upper():gsub("%s+", "")
end
local function parseMWWorlds(value)
  local result, seen = {}, {}
  local input = tostring(value or ""):gsub("[;\r\n]", ",")
  for part in (input .. ","):gmatch("([^,]*),") do
    local name = normalizeMWWorldName(part)
    if name ~= "" and name ~= "EXIT" and not seen[name] then
      seen[name] = true
      result[#result + 1] = name
      if #result >= 30 then
        break
      end
    end
  end
  return result
end
local function serializeMWWorlds(worlds)
  return table.concat(worlds or {}, ", ")
end
local function parseSelectedItems(value)
  local out, seen = {}, {}
  local input = tostring(value or ""):gsub("[;\r\n]", ",")
  for token in (input .. ","):gmatch("([^,]*),") do
    local id = tonumber(token:match("^%s*(%d+)%s*$"))
    if id ~= nil and id > 0 and id <= 65535 and not seen[id] then
      id = math.floor(id)
      seen[id] = true
      out[#out + 1] = id
      if #out >= 30 then
        break
      end
    end
  end
  return out
end
local function serializeSelectedItems(items)
  local text = {}
  for _, id in ipairs(items or {}) do
    text[#text + 1] = tostring(id)
  end
  return table.concat(text, ", ")
end
function ACD19_mwNewPreferences(filename)
  if ACD19_mwPreferenceModule == nil or type(ACD19_mwPreferenceModule.new) ~= "function" then
    return nil
  end
  local ok, instance = pcall(function()
    return ACD19_mwPreferenceModule:new(filename)
  end)
  if not ok then
    return nil
  end
  if
    instance == nil
    or type(instance.get) ~= "function"
    or type(instance.set) ~= "function"
    or type(instance.save) ~= "function"
    or type(instance.load) ~= "function"
  then
    return nil
  end
  return instance
end
local function initMWSettings()
  if type(require) == "function" then
    local ok, module = pcall(require, "preferences")
    if ok and type(module) == "table" then
      ACD19_mwPreferenceModule = module
    end
  end
  if ACD19_mwPreferenceModule == nil and type(Preferences) == "table" then
    ACD19_mwPreferenceModule = Preferences
  end
  -- Migration: read the original V11 preference namespace first.
  local legacy = ACD19_mwNewPreferences(ACD19_LEGACY_MW_PREF_NAME)
  if legacy ~= nil then
    pcall(function()
      legacy:load()
      for _, key in ipairs(ACD19_MW_KEYS) do
        if key ~= "license_key" then
          mwSaved[key] = legacy:get(key, "")
        end
      end
    end)
  end
  mwSaved.license_key = savedLicense or ""

  local latest = ACD19_mwNewPreferences(MW_PREF_NAME)
  if latest == nil then
    return
  end
  local loaded = pcall(function()
    latest:load()
  end)
  if not loaded then
    return
  end
  mwPref = latest
  local okSchema, schema = pcall(function()
    return latest:get("schema", "")
  end)
  if okSchema and tostring(schema) == ACD19_MW_SCHEMA then
    local okRead = pcall(function()
      for _, key in ipairs(ACD19_MW_KEYS) do
        mwSaved[key] = latest:get(key, mwSaved[key] or "")
      end
    end)
    if okRead then
      ACD19_mwSettingsRestored = true
      savedLicense = normalizeLicenseKey(mwSaved.license_key)
    end
  end
end
local function saveMWSetting(key, value)
  mwSaved[key] = tostring(value)
  if mwPref == nil then
    ACD19_setAutoSaveStatus("SAVE UNAVAILABLE")
    return false
  end
  local ok = pcall(function()
    if mwPref:set("schema", ACD19_MW_SCHEMA) == false then
      error("schema write failed")
    end
    for _, k in ipairs(ACD19_MW_KEYS) do
      if mwPref:set(k, tostring(mwSaved[k] or "")) == false then
        error("settings write failed: " .. k)
      end
    end
    if mwPref:save() == false then
      error("settings save failed")
    end
  end)
  if ok then
    local verified, matches = pcall(function()
      local copy = ACD19_mwNewPreferences(MW_PREF_NAME)
      if copy == nil then
        return false
      end
      if copy:load() == false then
        return false
      end
      if tostring(copy:get("schema", "")) ~= ACD19_MW_SCHEMA then
        return false
      end
      for _, k in ipairs(ACD19_MW_KEYS) do
        if tostring(copy:get(k, "")) ~= tostring(mwSaved[k] or "") then
          return false
        end
      end
      return true
    end)
    ok = verified and matches == true
  end
  ACD19_setAutoSaveStatus(ok and "SAVED - REOPEN SAFE" or "SAVE FAILED")
  return ok
end
local function mwNumber(key, defaultValue, minV, maxV)
  local n = math.floor(tonumber(mwSaved[key]) or defaultValue)
  return math.min(maxV, math.max(minV, n))
end
initMWSettings()
local savedMWWorlds = serializeMWWorlds(parseMWWorlds(mwSaved.worlds))
local savedSelectedItems = serializeSelectedItems(parseSelectedItems(mwSaved.items))
local savedMWDropWorld = normalizeMWWorldName(mwSaved.dropworld)
local savedMWDropX = mwNumber("dropx", 0, -1, 999)
local savedMWDropY = mwNumber("dropy", 0, -1, 999)
local savedMWPickupDelay = mwNumber("pickupdelay", 0, 0, 1000)
local savedMWAckTimeout = mwNumber("acktimeout", 900, 300, 10000)
local savedMWMaxBatch = mwNumber("batchmax", 2, 1, 2)
local savedMWDropTotal = mwNumber("droptotal", 0, 0, 1000000000)
local MODULE_TITLE = "Auto Collect V6.1 DoorID"
local ui = UserInterface.new(MODULE_TITLE, "Inventory")
ui:addLabelApp("Auto Collect V6.1 DoorID", "Inventory")
ui:addInputString("License Key", savedLicense, "A1234567", "A1234567", nil, "ACD_licensekey")
ui:addButton("Verify License", "ACD_verifylicense")
ui:addButton("Clear Saved License", "ACD_clearlicense")
ui:addDisplayList("License Status", "NOT VERIFIED", "ACD_licensestatus")
ui:addToggle("Start / Stop", false, "ACD_enable")
ui:addItemPicker("Add Collect Item", "Dirt", "2", "ACD_itempicker")
ui:addInputString("Selected Items (view only)", "NONE", "Selected item IDs", "List", nil, "ACD_selecteditem")
ui:addButton("Remove Last Collect Item", "ACD_removeitem")
ui:addButton("Clear Collect Items", "ACD_clearitems")
ui:addInputString(
  "Total Drop Per Item (0 = until worlds empty)",
  tostring(savedMWDropTotal),
  "Items",
  "210",
  nil,
  "ACD_droptotal"
)
ui:addInputString("Drop Progress Per Item (view only)", "NONE", "Dropped / goal", "Status", nil, "ACD_dropprogress")
ui:addInputString(
  "Collect Item IDs (comma-separated)",
  savedSelectedItems,
  "e.g. 2, 3, 4",
  "2, 3, 4",
  nil,
  "ACD_itemlist"
)
ui:addInputString(
  "Collection Worlds (comma-separated)",
  savedMWWorlds,
  "World 1, World 2, ...",
  "FARM1, FARM2",
  nil,
  "ACD_worldlist"
)
ui:addButton("Add Current World", "ACD_addworld")
ui:addButton("Remove Last World", "ACD_removeworld")
ui:addInputString("Shared Storage World", savedMWDropWorld, "World", "STORAGE", nil, "ACD_dropworld")
ui:addButton("Storage World = Current World", "ACD_setdropworld")
ui:addInputInt("Drop Position X (Standing Tile)", tostring(savedMWDropX), "X", "0", nil, "ACD_dropx")
ui:addInputInt("Drop Position Y (Standing Tile)", tostring(savedMWDropY), "Y", "0", nil, "ACD_dropy")
ui:addButton("Drop Position = Current Tile", "ACD_setdrop")
ui:addInputInt("After Pickup Delay", tostring(savedMWPickupDelay), "ms", "0", nil, "ACD_pickupdelay")
ui:addInputInt("Batch ACK Timeout", tostring(savedMWAckTimeout), "ms", "900", nil, "ACD_acktimeout")
ui:addInputInt("Max Pickup Batch (max 2)", tostring(savedMWMaxBatch), "items", "2", nil, "ACD_batchmax")
ui:addDisplayList("Items Configured", tostring(#parseSelectedItems(savedSelectedItems)), "ACD_itemcount")
ui:addDisplayList("Worlds Configured", tostring(#parseMWWorlds(savedMWWorlds)), "ACD_worldcount")
ui:addDisplayList("Current Collection World", "NOT STARTED", "ACD_worldprogress")
ui:addDisplayList(
  "Shared Storage World",
  savedMWDropWorld ~= "" and savedMWDropWorld or "NOT SET",
  "ACD_storageprogress"
)
ui:addDisplayList("Server Pace", "CAUTIOUS (2)", "ACD_serverpace")
ui:addDisplayList("Shared Storage Trips", "0", "ACD_loops")
ui:addDisplayList("Status", "STOPPED", "ACD_status")
ui:addDisplayList("Selected Inventory", "NONE", "ACD_inventory")
ui:addDisplayList("Dropped Objects Found", "0", "ACD_objects")
ui:addDisplayList(
  "Settings Auto Save",
  mwPref == nil and "UNAVAILABLE" or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT"),
  "ACD_autosave"
)
pcall(function()
  if type(addCategory) == "function" then
    addCategory(MODULE_TITLE, "Inventory")
  end
end)
local menuJSON = ui:generateJSON()
local added, result = pcall(addIntoModule, menuJSON, MODULE_TITLE)
if not added or result == false then
  pcall(function()
    growtopia.notify("Auto Collect V6.1 DoorID menu could not be created.")
  end)
end
local enabled = false
local licenseKey = savedLicense
local licenseVerified = false
local licenseCheckRunning = false
local licenseLastResult = "NOT VERIFIED"
local startCheckPending = false
local startCheckGeneration = 0
local licenseRequestSequence = 0
local configuredItems = parseSelectedItems(savedSelectedItems)
local runItems, runItemSet = {}, {}
local INVENTORY_FULL = 200
local configuredDropTotal = savedMWDropTotal
local runDropTotal = savedMWDropTotal
local droppedByItem = {}
local storageObservationActive = false
local storageObserved = {}
local pickupDelay = savedMWPickupDelay
local pickupAckTimeout = savedMWAckTimeout
local maxPickupBatch = savedMWMaxBatch
local adaptivePickupBatch = math.min(2, savedMWMaxBatch)
local healthyBatchStreak = 0
local laggyBatchStreak = 0
local collectWorld = ""
local configuredWorlds = parseMWWorlds(savedMWWorlds)
local runWorlds = {}
local currentWorldIndex = 1
local returnToCollectPending = false
local returnWarpAttempts = 0
local emptyWorldScanCount = 0
local dropWorld = savedMWDropWorld
local dropX = savedMWDropX
local dropY = savedMWDropY
local currentDropX = 0
local currentDropY = 0
local status = "STOPPED"
local initialInventoryCheck = true
local completedLoops = 0
local DROP_EXCLUDE_RADIUS = 1
local WORLD_TIMEOUT_MS = 15000
local RETURN_WORLD_TIMEOUT_MS = 9000
local RETURN_WORLD_RETRY_DELAY_MS = 1300
local RETURN_WORLD_EXTRA_SETTLE_MS = 450
local WORLD_SETTLE_MS = 1100
local PLAYER_READY_POLL_MS = 100
local PLAYER_READY_STABLE_MS = 700
local MOVE_RETRIES = 6
local MOVE_ATTEMPT_MS = 2200
local MOVE_RETRY_GAP_MS = 350
local FAST_MOVE_TIMEOUT_MS = 6000
local FAST_MOVE_POLL_MS = 25
local FAST_MOVE_STALL_MS = 1000
local FAST_MOVE_SETTLE_MS = 60
local FAST_NEAR_RANGE = 1
local FAST_RESCAN_DELAY_MS = 80
local PICKUP_ACK_POLL_MS = 25
local PICKUP_MAX_REQUESTS = 1
local PICKUP_RETRY_GAP_MS = 180
local PICKUP_SERVER_BACKOFF_MS = 450
local BATCH_PACKET_GAP_MS = 90
local BATCH_LAG_MAX_BACKOFF_MS = 1800
local DROP_DIALOG_TIMEOUT_MS = 2000
local DROP_ACK_TIMEOUT_MS = 2200
local MAX_DROP_ATTEMPTS_PER_TILE = 2
local FULL_TILE_RETRY_DELAY_MS = 350
local MAX_DROP_POSITION_SHIFTS = 100
local ACTION_COOLDOWN_MS = 250
local DROP_WORLD_EXTRA_SETTLE_MS = 1200
local DROP_PATH_RETRIES = 4
local DROP_PATH_ATTEMPT_MS = 2600
local DROP_POSITION_STABLE_MS = 300
local DROP_REPATH_GAP_MS = 350
ACD19_DROP_SECOND_PATH_STABLE_MS = 500
ACD19_DROP_PRE_PACKET_STABLE_MS = 200
ACD19_DROP_STABLE_POLL_MS = 100
local dropDialogPending = false
local dropDialogReady = false
local protectDropZoneDuringDrop = false
local storagePending = false
local storageOnlyFullIDs = nil
local blockedByFullScanCount = 0
local pendingDropShift = false
ACD19_storageEntryConfirmed = false
ACD19_storageEntryConfirmedX = nil
ACD19_storageEntryConfirmedY = nil
local collectionSweepNumber = 0
local deferredPickupUntilSweep = {}
local FAILED_PICKUP_SKIP_SWEEPS = 2
local function notify(msg)
  pcall(function()
    growtopia.notify(tostring(msg))
  end)
end
local function setLicenseStatus(value)
  licenseLastResult = tostring(value or "")
  pcall(function()
    ACD19_safeEditValue("ACD_licensestatus", licenseLastResult)
  end)
end
local function urlEncode(value)
  value = tostring(value or "")
  value = value:gsub("\n", "\r\n")
  value = value:gsub("([^%w%-_%.~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return value
end
local function getLicenseClientID()
  local id = ""

  -- Prefer Growlauncher's Discord identifier when available.
  if type(getDiscordID) == "function" then
    local ok, result = pcall(getDiscordID)
    if ok and result ~= nil then
      id = tostring(result)
    end
  elseif getDiscordID ~= nil then
    id = tostring(getDiscordID)
  end

  id = tostring(id or ""):gsub("^%s+", ""):gsub("%s+$", "")

  -- Fallback to the local Growtopia name if this build does not expose
  -- a usable Discord identifier. This only runs when a local player exists.
  if id == "" or id == "nil" or id == "0" then
    local fn = GetLocal or getLocal
    if fn ~= nil then
      local ok, player = pcall(fn)
      if ok and player ~= nil and player.name ~= nil then
        id = tostring(player.name)
        id = id:gsub("^%s+", ""):gsub("%s+$", "")
      end
    end
  end

  return id
end
local function verifyLicense(silent)
  if licenseCheckRunning then
    return false
  end

  licenseCheckRunning = true
  licenseVerified = false

  local key = normalizeLicenseKey(licenseKey)
  licenseKey = key
  pcall(function()
    ACD19_safeEditValue("ACD_licensekey", key)
  end)

  if not validLicenseFormat(key) then
    setLicenseStatus("INVALID KEY FORMAT")
    licenseCheckRunning = false
    if not silent then
      notify("License must be 1 letter + 7 numbers, for example A1234567.")
    end
    return false
  end

  local clientId = getLicenseClientID()
  if clientId == "" then
    setLicenseStatus("NO CLIENT ID")
    licenseCheckRunning = false
    if not silent then
      notify("Could not read a client ID. Connect Growlauncher/Discord or enter the game first.")
    end
    return false
  end

  setLicenseStatus("CHECKING...")

  -- Each verification uses a distinct URL, so an old cached success cannot
  -- silently authorize a key that the owner has since disabled in the Sheet.
  licenseRequestSequence = licenseRequestSequence + 1
  local requestNonce = tostring(licenseRequestSequence)
    .. "_"
    .. tostring((os and type(os.time) == "function") and os.time() or math.random(100000, 999999))
  local url = LICENSE_URL
    .. "?key="
    .. urlEncode(key)
    .. "&id="
    .. urlEncode(clientId)
    .. "&nonce="
    .. urlEncode(requestNonce)

  local okFetch, response, fetchError = pcall(fetch, url)

  if not okFetch then
    setLicenseStatus("SERVER ERROR")
    licenseCheckRunning = false
    if not silent then
      notify("License server request failed.")
    end
    return false
  end

  response = tostring(response or "")
  response = response:gsub("^%s+", ""):gsub("%s+$", "")

  if response:find("OK|PERMANENT", 1, true) then
    licenseVerified = true
    setLicenseStatus("VERIFIED - PERMANENT")

    -- Save only a key that the server has actually accepted.
    if saveLicensePreference(key) then
      savedLicense = key
    end

    licenseCheckRunning = false
    if not silent then
      notify("License verified and saved.")
    end
    return true
  end

  local readable = response
  if readable == "" then
    local errText = tostring(fetchError or "")
    if errText ~= "" and errText ~= "nil" then
      readable = errText
    else
      readable = "NO RESPONSE - UPDATE GOOGLE APPS SCRIPT TO HTMLSERVICE"
    end
  end

  if readable:find("DENY|DISABLED", 1, true) then
    setLicenseStatus("DISABLED")
  elseif readable:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    setLicenseStatus("BOUND TO OTHER USER")
  elseif readable:find("DENY|INVALID_KEY", 1, true) then
    setLicenseStatus("INVALID KEY")
  elseif readable:find("DENY|BAD_KEY_FORMAT", 1, true) then
    setLicenseStatus("BAD KEY FORMAT")
  elseif readable:find("DENY|NO_ID", 1, true) then
    setLicenseStatus("NO CLIENT ID")
  else
    setLicenseStatus("CHECK FAILED")
  end

  licenseCheckRunning = false
  if not silent then
    notify("License denied: " .. readable)
  end
  return false
end
local function setStatus(s)
  s = tostring(s)
  if status ~= s then
    status = s
    ACD19_safeEditValue("ACD_status", s)
  end
end
local function updateWorldProgress()
  local count = #runWorlds
  if enabled and count > 0 and currentWorldIndex <= count then
    pcall(function()
      ACD19_safeEditValue(
        "ACD_worldprogress",
        tostring(currentWorldIndex) .. "/" .. tostring(count) .. " - " .. tostring(collectWorld)
      )
    end)
  elseif count > 0 and currentWorldIndex > count then
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "ALL WORLDS SCANNED")
    end)
  else
    pcall(function()
      ACD19_safeEditValue("ACD_worldprogress", "NOT STARTED")
    end)
  end
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#configuredWorlds))
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_storageprogress", dropWorld ~= "" and dropWorld or "NOT SET")
  end)
end
local function saveConfiguredWorlds()
  local text = serializeMWWorlds(configuredWorlds)
  pcall(function()
    ACD19_safeEditValue("ACD_worldlist", text)
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_worldcount", tostring(#configuredWorlds))
  end)
  saveMWSetting("worlds", text)
end
local function setLauncherToggle(name, state)
  local fn = editToggle or EditToggle
  if fn ~= nil then
    pcall(fn, name, state == true)
  end
end
local lastFlyState = nil
local lastAutoCollectState = nil
local function setFly(state)
  state = state == true
  if state == lastFlyState then
    return
  end
  lastFlyState = state
  setLauncherToggle("ModFly", state)
end
local function setAutoCollect(state)
  state = state == true
  if state == lastAutoCollectState then
    return
  end
  lastAutoCollectState = state
  setLauncherToggle("Enable AutoCollect", state)
  setLauncherToggle("Autocollect", state)
end
local function cleanWorldName(s)
  s = tostring(s or "")
  s = s:gsub("%s+", "")
  return s:upper()
end
ACD61_activeDoorRoute = ""
function ACD61_physicalWorld()
  local ok, world = pcall(function()
    if type(GetWorldName) == "function" then
      return GetWorldName()
    elseif type(getCurrentWorldName) == "function" then
      return getCurrentWorldName()
    end
    return ""
  end)
  if not ok then
    return ""
  end
  return cleanWorldName(world)
end
local function currentWorld()
  local physical = ACD61_physicalWorld()
  if ACD61_activeDoorRoute ~= "" and physical ~= "" then
    local expectedBase = ACD61_activeDoorRoute:match("^([^|]+)|")
    if expectedBase == physical then
      return ACD61_activeDoorRoute
    end
  end
  return physical
end
function ACD61_parseWorldRoute(route)
  route = cleanWorldName(route)
  if route == "" then
    return "", nil
  end
  local base, doorID = route:match("^([^|]+)|([^|]+)$")
  if base then
    return base, doorID
  end
  if route:find("|", 1, true) then
    return "", nil
  end
  return route, nil
end
local function sameWorld(a, b)
  a = cleanWorldName(a)
  b = cleanWorldName(b)
  return a ~= "" and b ~= "" and a == b
end
local function dropZoneEnabled()
  return sameWorld(collectWorld, dropWorld) and sameWorld(currentWorld(), dropWorld)
end
local function dropZoneProtectionActive()
  return sameWorld(currentWorld(), dropWorld) and (dropZoneEnabled() or protectDropZoneDuringDrop)
end
local function isInsideDropZone(tileX, tileY)
  tileX = tonumber(tileX)
  tileY = tonumber(tileY)
  if tileX == nil or tileY == nil then
    return false
  end

  -- V10.5:
  -- When the server says a drop position is full, the standing position moves
  -- left. Protect the whole used horizontal drop strip so Same-World mode
  -- does not collect previously dropped items again.
  local leftEdge = math.min(dropX, currentDropX) - DROP_EXCLUDE_RADIUS
  local rightEdge = math.max(dropX, currentDropX) + DROP_EXCLUDE_RADIUS

  return tileX >= leftEdge and tileX <= rightEdge and math.abs(tileY - dropY) <= DROP_EXCLUDE_RADIUS
end
local function safeLocal()
  local fn = GetLocal or getLocal
  if fn == nil then
    return nil
  end
  local ok, p = pcall(fn)
  if ok then
    return p
  end
  return nil
end
local function safeTiles()
  local fn = GetTiles or getTiles
  if fn == nil then
    return nil
  end
  local ok, tiles = pcall(fn)
  if ok and type(tiles) == "table" then
    return tiles
  end
  return nil
end
local function safeObjects()
  local fn = GetObjectList or getObjectList
  if fn == nil then
    return {}
  end
  local ok, objects = pcall(fn)
  if ok and type(objects) == "table" then
    return objects
  end
  return {}
end
local function inventoryCount(itemID)
  local ok, amount = pcall(function()
    if growtopia ~= nil and type(growtopia.checkInventoryCount) == "function" then
      return growtopia.checkInventoryCount(itemID)
    end

    local fn = GetInventory or getInventory
    if fn == nil then
      return 0
    end
    local inv = fn()
    for _, item in pairs(inv or {}) do
      if tonumber(item.id) == tonumber(itemID) then
        return tonumber(item.amount) or 0
      end
    end
    return 0
  end)
  if not ok then
    return 0
  end
  return tonumber(amount) or 0
end
local function itemName(itemID)
  local ok, name = pcall(function()
    if growtopia ~= nil and type(growtopia.getItemName) == "function" then
      return growtopia.getItemName(itemID)
    end
    if type(getItemInfoByID) == "function" then
      local info = getItemInfoByID(itemID)
      if info ~= nil then
        return info.name
      end
    end
    return nil
  end)
  if ok and name ~= nil and tostring(name) ~= "" then
    return tostring(name)
  end
  return "Item " .. tostring(itemID)
end
local function activeItemIDs()
  if #runItems > 0 and enabled then
    return runItems
  end
  return configuredItems
end
local function selectedTotalInventory()
  local total = 0
  for _, id in ipairs(activeItemIDs()) do
    total = total + inventoryCount(id)
  end
  return total
end
local function remainingDropGoal(itemID)
  if runDropTotal <= 0 then
    return nil
  end
  return math.max(0, runDropTotal - (droppedByItem[itemID] or 0))
end
local function allDropGoalsMet()
  if runDropTotal <= 0 or #runItems == 0 then
    return false
  end
  for _, id in ipairs(runItems) do
    if (droppedByItem[id] or 0) < runDropTotal then
      return false
    end
  end
  return true
end
local function itemNeedsPickup(itemID)
  local count = inventoryCount(itemID)
  if count >= INVENTORY_FULL then
    return false
  end
  local remaining = remainingDropGoal(itemID)
  return remaining == nil or count < remaining
end
local function anySelectedFull()
  for _, id in ipairs(activeItemIDs()) do
    if inventoryCount(id) >= INVENTORY_FULL then
      return id
    end
  end
  return nil
end
local function dropEligibleAmount(itemID)
  local bag = math.max(0, inventoryCount(itemID))
  local remaining = remainingDropGoal(itemID)
  if remaining == nil then
    return bag
  end
  return math.min(bag, remaining)
end
local function selectedEligibleInventory()
  local total = 0
  for _, id in ipairs(runItems) do
    total = total + dropEligibleAmount(id)
  end
  return total
end
local function allSelectedReadyForStorage()
  if #runItems == 0 then
    return false
  end
  for _, id in ipairs(runItems) do
    if itemNeedsPickup(id) then
      return false
    end
  end
  return selectedEligibleInventory() > 0
end
local function unfinishedGoalSummary()
  if runDropTotal <= 0 then
    return "UNLIMITED"
  end
  local parts = {}
  for _, id in ipairs(runItems) do
    local remain = remainingDropGoal(id)
    if remain and remain > 0 then
      parts[#parts + 1] = tostring(id) .. ":" .. tostring(remain)
    end
  end
  return #parts == 0 and "ALL COMPLETE" or table.concat(parts, ", ")
end
local function updateDropProgress()
  local ids = (#runItems > 0 and enabled) and runItems or configuredItems
  local labels = {}
  for _, id in ipairs(ids) do
    labels[#labels + 1] = tostring(id)
      .. ": "
      .. tostring(droppedByItem[id] or 0)
      .. " / "
      .. (runDropTotal > 0 and tostring(runDropTotal) or "unlimited")
  end
  pcall(function()
    ACD19_safeEditValue("ACD_dropprogress", #labels > 0 and table.concat(labels, " | ") or "NONE")
  end)
end
local function beginStorageObservation()
  if storageObservationActive then
    return
  end
  storageObservationActive = true
  storageObserved = {}
  for _, id in ipairs(runItems) do
    storageObserved[id] = inventoryCount(id)
  end
end
local function observeStoredDrops()
  if not storageObservationActive then
    return
  end
  local changed = false
  for _, id in ipairs(runItems) do
    local now = inventoryCount(id)
    local old = storageObserved[id]
    if old ~= nil and now < old then
      droppedByItem[id] = (droppedByItem[id] or 0) + (old - now)
      changed = true
    end
    storageObserved[id] = now
  end
  if changed then
    updateDropProgress()
  end
end
local function endStorageObservation()
  observeStoredDrops()
  storageObservationActive = false
  storageObserved = {}
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
end
local function selectedItemLabel()
  if #configuredItems == 0 then
    return "NONE"
  end
  local parts = {}
  for _, id in ipairs(configuredItems) do
    parts[#parts + 1] = itemName(id) .. " (" .. tostring(id) .. ")"
  end
  return table.concat(parts, ", ")
end
local function updateSelectedDisplay()
  pcall(function()
    ACD19_safeEditValue("ACD_selecteditem", selectedItemLabel())
  end)
  pcall(function()
    ACD19_safeEditValue("ACD_itemcount", tostring(#configuredItems))
  end)
end
local function saveConfiguredItems()
  local text = serializeSelectedItems(configuredItems)
  pcall(function()
    ACD19_safeEditValue("ACD_itemlist", text)
  end)
  saveMWSetting("items", text)
  updateSelectedDisplay()
  updateDropProgress()
end
local lastInventoryDisplay = nil
local function updateInventoryDisplay()
  local items = activeItemIDs()
  local output = "NONE"
  if #items > 0 then
    local labels = {}
    for _, id in ipairs(items) do
      labels[#labels + 1] = tostring(id) .. ":" .. tostring(inventoryCount(id))
    end
    output = table.concat(labels, "  |  ")
  end
  if output ~= lastInventoryDisplay then
    lastInventoryDisplay = output
    pcall(function()
      ACD19_safeEditValue("ACD_inventory", output)
    end)
  end
end
local function updateLoopDisplay()
  -- Display confirmed combined storage trips, not a loop limit.
  ACD19_safeEditValue("ACD_loops", tostring(completedLoops))
end
local function playerTile()
  local p = safeLocal()
  if p == nil then
    return nil, nil
  end
  return p.posX // 32, p.posY // 32
end
local function reached(x, y)
  local px, py = playerTile()
  return px == x and py == y
end
local validatedWorld = ""
local worldWasPresent = ""
local actionReadyWorld = ""
local function worldReady(worldName)
  local liveWorld = ACD61_physicalWorld()
  local route = cleanWorldName(worldName)
  local expected, doorID = ACD61_parseWorldRoute(route)
  if expected == "" then
    return false
  end
  if liveWorld ~= worldWasPresent then
    worldWasPresent = liveWorld
    validatedWorld = ""
    actionReadyWorld = ""
    ACD61_activeDoorRoute = ""
  end
  local p = safeLocal()
  if liveWorld ~= expected or p == nil then
    return false
  end
  if doorID and ACD61_activeDoorRoute ~= route then
    return false
  end
  if not doorID and ACD61_activeDoorRoute ~= "" then
    return false
  end
  if tonumber(p.posX) == nil or tonumber(p.posY) == nil then
    return false
  end
  if validatedWorld == expected then
    return true
  end
  local tiles = safeTiles()
  if tiles ~= nil and next(tiles) ~= nil then
    validatedWorld = expected
    return true
  end
  return false
end
local function actionReady(worldName)
  local expected = cleanWorldName(worldName)
  return actionReadyWorld == expected and worldReady(expected)
end
local function waitForWorld(worldName, timeoutMs, minimumWaitMs)
  local expected = cleanWorldName(worldName)
  if actionReady(expected) then
    return true
  end
  local waited = 0
  local stableMs = 0
  local lastPX, lastPY = nil, nil
  setStatus("WAIT PLAYER READY " .. tostring(expected))
  while enabled and waited < timeoutMs do
    if worldReady(expected) then
      local p = safeLocal()
      local px = p and tonumber(p.posX)
      local py = p and tonumber(p.posY)
      if px ~= nil and py ~= nil then
        if lastPX == px and lastPY == py then
          stableMs = stableMs + PLAYER_READY_POLL_MS
        else
          stableMs = 0
          lastPX, lastPY = px, py
        end
        if stableMs >= PLAYER_READY_STABLE_MS and waited >= (minimumWaitMs or 0) then
          actionReadyWorld = expected
          return enabled and actionReady(expected)
        end
      end
    else
      stableMs = 0
      lastPX, lastPY = nil, nil
    end
    Sleep(PLAYER_READY_POLL_MS)
    waited = waited + PLAYER_READY_POLL_MS
  end
  return false
end
local function warpAndWait(worldName, timeoutMs)
  worldName = cleanWorldName(worldName)
  if worldName == "" then
    return false
  end
  timeoutMs = timeoutMs or WORLD_TIMEOUT_MS
  if worldName ~= dropWorld then
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX = nil
    ACD19_storageEntryConfirmedY = nil
  end

  local baseWorld, doorID = ACD61_parseWorldRoute(worldName)
  if baseWorld == "" then
    setStatus("INVALID WORLD OR DOOR ID")
    return false
  end

  if doorID then
    if actionReady(worldName) then
      setFly(true)
      return true
    end

    -- Switch only the world-entry layer. Never touch item pickup logic.
    if ACD61_physicalWorld() ~= baseWorld or ACD61_activeDoorRoute ~= "" then
      ACD61_activeDoorRoute = ""
      validatedWorld = ""
      actionReadyWorld = ""
      lastFlyState = nil
      setStatus("WARP BASE " .. baseWorld)
      local ok, result = pcall(function()
        return growtopia.warpTo(baseWorld)
      end)
      if not ok or result == false then
        return false
      end
    end
    if not waitForWorld(baseWorld, timeoutMs, WORLD_SETTLE_MS) then
      return false
    end
    if not enabled or ACD61_physicalWorld() ~= baseWorld then
      return false
    end

    -- Request the linked door inside the base world. The API does not
    -- provide a verified door-arrival ACK. This is only a settling check.
    setStatus("ENTER DOOR " .. worldName)
    validatedWorld = ""
    actionReadyWorld = ""
    local ok, result = pcall(function()
      return SendPacket(3, "action|join_request\nname|" .. worldName .. "\ninvitedWorld|0")
    end)
    if not ok or result == false then
      return false
    end
    Sleep(1400)
    if not enabled or ACD61_physicalWorld() ~= baseWorld then
      return false
    end
    if not waitForWorld(baseWorld, timeoutMs, WORLD_SETTLE_MS) then
      return false
    end

    ACD61_activeDoorRoute = worldName
    validatedWorld = ""
    actionReadyWorld = ""
    local ready = waitForWorld(worldName, timeoutMs, WORLD_SETTLE_MS)
    if ready then
      setFly(true)
    end
    return ready
  end

  if ACD61_activeDoorRoute ~= "" then
    -- A plain WORLD is different from WORLD|DOORID in the same base world.
    -- Force a fresh base entry, rather than reusing the old door position.
    ACD61_activeDoorRoute = ""
    validatedWorld = ""
    actionReadyWorld = ""
    lastFlyState = nil
    setStatus("RETURN BASE " .. worldName)
    local ok, result = pcall(function()
      return growtopia.warpTo(worldName)
    end)
    if not ok or result == false then
      return false
    end
    local ready = waitForWorld(worldName, timeoutMs, WORLD_SETTLE_MS)
    if ready then
      setFly(true)
    end
    return ready
  end

  if actionReady(worldName) then
    setFly(true)
    return true
  end
  -- The right world can be visible before its player data becomes usable.
  -- In that case WAIT, don't send another unnecessary warp packet.
  if worldReady(worldName) then
    local ready = waitForWorld(worldName, timeoutMs, WORLD_SETTLE_MS)
    if ready then
      setFly(true)
    end
    return ready
  end

  setStatus("WARP " .. worldName)
  validatedWorld = ""
  actionReadyWorld = ""
  lastFlyState = nil
  local ok = pcall(function()
    growtopia.warpTo(worldName)
  end)
  if not ok then
    return false
  end

  local ready = waitForWorld(worldName, timeoutMs, WORLD_SETTLE_MS)
  if ready then
    setFly(true)
  end
  return ready
end
local function moveTo(x, y)
  if reached(x, y) then
    return true
  end

  -- All collector/drop travel uses ModFly while the automation is running.
  setFly(true)

  for attempt = 1, MOVE_RETRIES do
    if not enabled then
      return false
    end

    setStatus(
      "PATH " .. tostring(attempt) .. "/" .. tostring(MOVE_RETRIES) .. " -> " .. tostring(x) .. "," .. tostring(y)
    )

    pcall(function()
      FindPath(x, y)
    end)

    local waited = 0
    while enabled and waited < MOVE_ATTEMPT_MS do
      if reached(x, y) then
        Sleep(120)
        return true
      end
      Sleep(100)
      waited = waited + 100
    end

    Sleep(MOVE_RETRY_GAP_MS)
  end

  return reached(x, y)
end
local function ensureExactDropPosition(targetX, targetY)
  if not enabled or not actionReady(dropWorld) then
    return false
  end
  targetX = math.floor(tonumber(targetX) or currentDropX or dropX)
  targetY = math.floor(tonumber(targetY) or currentDropY or dropY)
  if reached(targetX, targetY) then
    return true
  end

  setFly(true)
  for attempt = 1, DROP_PATH_RETRIES do
    if not enabled or not actionReady(dropWorld) then
      return false
    end
    setStatus(
      "DROP PATH "
        .. tostring(attempt)
        .. "/"
        .. tostring(DROP_PATH_RETRIES)
        .. " -> "
        .. tostring(targetX)
        .. ","
        .. tostring(targetY)
    )
    pcall(function()
      FindPath(targetX, targetY)
    end)
    local waited = 0
    while enabled and actionReady(dropWorld) and waited < DROP_PATH_ATTEMPT_MS do
      if reached(targetX, targetY) then
        Sleep(DROP_POSITION_STABLE_MS)
        return enabled and reached(targetX, targetY)
      end
      Sleep(100)
      waited = waited + 100
    end
    if attempt < DROP_PATH_RETRIES then
      Sleep(DROP_REPATH_GAP_MS)
    end
  end
  return reached(targetX, targetY)
end
function ACD19_stableAtStorageTile(x, y, stableMs, maxWaitMs)
  local stable, waited = 0, 0
  while enabled and waited <= maxWaitMs do
    if not actionReady(dropWorld) then
      return false
    end
    if reached(x, y) then
      if stable >= stableMs then
        return true
      end
      stable = stable + ACD19_DROP_STABLE_POLL_MS
    else
      stable = 0
    end
    if waited >= maxWaitMs then
      break
    end
    Sleep(ACD19_DROP_STABLE_POLL_MS)
    waited = waited + ACD19_DROP_STABLE_POLL_MS
  end
  return enabled and actionReady(dropWorld) and reached(x, y) and stable >= stableMs
end
function ACD19_confirmStorageDropPosition()
  if not enabled or not actionReady(dropWorld) then
    ACD19_storageEntryConfirmed = false
    return false
  end
  local x, y = currentDropX, currentDropY
  if
    ACD19_storageEntryConfirmed
    and ACD19_storageEntryConfirmedX == x
    and ACD19_storageEntryConfirmedY == y
    and reached(x, y)
  then
    return true
  end
  ACD19_storageEntryConfirmed = false
  setStatus("STORAGE PATH 1/2 -> " .. tostring(x) .. "," .. tostring(y))
  if not ensureExactDropPosition(x, y) then
    return false
  end
  if not ACD19_stableAtStorageTile(x, y, DROP_POSITION_STABLE_MS, 900) then
    setStatus("WAIT FIRST STORAGE ARRIVAL")
    return false
  end

  -- Sending the second FindPath too early would interrupt the first route.
  -- A false return from a same-tile path request is not proof of failure;
  -- the final authority is repeated verified player coordinates.
  setStatus("STORAGE PATH 2/2 -> " .. tostring(x) .. "," .. tostring(y))
  local sent = pcall(function()
    FindPath(x, y)
  end)
  if not sent then
    setStatus("WAIT SECOND STORAGE PATH")
    return false
  end
  if not ACD19_stableAtStorageTile(x, y, ACD19_DROP_SECOND_PATH_STABLE_MS, 1400) then
    setStatus("WAIT VERIFIED STORAGE POSITION")
    return false
  end
  ACD19_storageEntryConfirmed = true
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = x, y
  setStatus("STORAGE POSITION CONFIRMED " .. tostring(x) .. "," .. tostring(y))
  return true
end
local function safeGetTile(x, y)
  local fn = GetTile or getTile
  if fn == nil then
    return nil
  end
  local ok, tile = pcall(fn, x, y)
  if ok then
    return tile
  end
  return nil
end
local function tileUsableForFastSweep(x, y)
  local tile = safeGetTile(x, y)
  return tile ~= nil and tile.collidable ~= true
end
local function fastDestinationForTarget(target)
  local px, py = playerTile()
  local candidates = {
    { target.tileX, target.tileY },
    { target.tileX - 1, target.tileY },
    { target.tileX + 1, target.tileY },
    { target.tileX, target.tileY - 1 },
    { target.tileX - 1, target.tileY - 1 },
    { target.tileX + 1, target.tileY - 1 },
  }

  local best = nil
  local bestDistance = math.huge
  for _, pos in ipairs(candidates) do
    if tileUsableForFastSweep(pos[1], pos[2]) then
      local d = 0
      if px ~= nil and py ~= nil then
        d = math.abs(px - pos[1]) + math.abs(py - pos[2])
      end
      if d < bestDistance then
        bestDistance = d
        best = pos
      end
    end
  end

  -- If tile data is temporarily stale, still try the object's own tile once.
  if best == nil then
    best = { target.tileX, target.tileY }
  end
  return best[1], best[2]
end
local function getObjectPixelPos(obj)
  if obj == nil then
    return nil, nil
  end

  local x = tonumber(obj.posX)
  local y = tonumber(obj.posY)

  if (x == nil or y == nil) and obj.pos ~= nil then
    x = x or tonumber(obj.pos.x)
    y = y or tonumber(obj.pos.y)
  end

  return x, y
end
local function objectExists(objectUID)
  objectUID = tonumber(objectUID)
  if objectUID == nil then
    return false
  end

  for _, obj in pairs(safeObjects()) do
    if tonumber(obj.id) == objectUID then
      return true
    end
  end
  return false
end
local function findTargetObjects()
  local px, py = playerTile()
  local results = {}

  for _, obj in pairs(safeObjects()) do
    if runItemSet[tonumber(obj.itemid)] == true and itemNeedsPickup(tonumber(obj.itemid)) then
      local ox, oy = getObjectPixelPos(obj)
      if ox ~= nil and oy ~= nil then
        local tx = math.floor(ox / 32)
        local ty = math.floor(oy / 32)
        local distance = 0
        if px ~= nil and py ~= nil then
          distance = math.abs(px - tx) + math.abs(py - ty)
        end

        -- If collection and dropping happen in the SAME world, ignore
        -- our drop zone completely. This prevents the scanner from
        -- selecting items that this script dropped itself.
        local excludedByDropZone = dropZoneEnabled() and isInsideDropZone(tx, ty)

        if not excludedByDropZone then
          table.insert(results, {
            object = obj,
            uid = tonumber(obj.id),
            itemID = tonumber(obj.itemid),
            amount = tonumber(obj.amount) or 0,
            pixelX = ox,
            pixelY = oy,
            tileX = tx,
            tileY = ty,
            distance = distance,
          })
        end
      end
    end
  end

  -- V10 ROW-BY-ROW ORDER:
  -- Group all detected objects by tile Y, then collect one complete row at a time.
  -- To avoid running back to the same side after every row, the direction alternates:
  --
  -- Row 1: left  -> right
  -- Row 2: right -> left
  -- Row 3: left  -> right
  -- ...
  --
  -- The first row chooses its direction from the player's current X position,
  -- so it begins from whichever edge is closer when possible.
  if #results > 1 then
    local rowMap = {}
    local rowYs = {}

    for _, target in ipairs(results) do
      local y = target.tileY
      if rowMap[y] == nil then
        rowMap[y] = {}
        table.insert(rowYs, y)
      end
      table.insert(rowMap[y], target)
    end

    -- Work from the upper row downward.
    table.sort(rowYs, function(a, b)
      return a < b
    end)

    local firstLeftToRight = true

    -- Pick the nearer edge of the first row as the starting side.
    if px ~= nil and #rowYs > 0 then
      local firstRow = rowMap[rowYs[1]]
      local minX = math.huge
      local maxX = -math.huge

      for _, target in ipairs(firstRow) do
        if target.tileX < minX then
          minX = target.tileX
        end
        if target.tileX > maxX then
          maxX = target.tileX
        end
      end

      if math.abs(px - maxX) < math.abs(px - minX) then
        firstLeftToRight = false
      end
    end

    local ordered = {}

    for rowIndex, y in ipairs(rowYs) do
      local row = rowMap[y]
      local leftToRight

      if rowIndex % 2 == 1 then
        leftToRight = firstLeftToRight
      else
        leftToRight = not firstLeftToRight
      end

      table.sort(row, function(a, b)
        if leftToRight then
          return a.tileX < b.tileX
        else
          return a.tileX > b.tileX
        end
      end)

      for _, target in ipairs(row) do
        table.insert(ordered, target)
      end
    end

    results = ordered
  end

  ACD19_safeEditValue("ACD_objects", tostring(#results))
  return results
end
local function fullSelectedTypesStillOnGround()
  local fullIDs = {}
  for _, obj in pairs(safeObjects()) do
    local id = tonumber(obj and obj.itemid)
    if id and runItemSet[id] and inventoryCount(id) >= INVENTORY_FULL then
      local ox, oy = getObjectPixelPos(obj)
      if ox ~= nil and oy ~= nil then
        local tx, ty = math.floor(ox / 32), math.floor(oy / 32)
        if not (dropZoneEnabled() and isInsideDropZone(tx, ty)) then
          fullIDs[id] = true
        end
      end
    end
  end
  return fullIDs, next(fullIDs) ~= nil
end
local function activateObject(target)
  if target == nil or target.uid == nil then
    return false
  end

  local ok = pcall(function()
    SendPacketRaw(false, {
      type = 11,
      value = target.uid,
      x = target.pixelX,
      y = target.pixelY,
    })
  end)
  return ok
end
local function nearTarget(target, range)
  local px, py = playerTile()
  if px == nil or py == nil then
    return false
  end
  range = tonumber(range) or 1
  return math.abs(px - target.tileX) <= range and math.abs(py - target.tileY) <= range
end
local function waitForPickupACK(beforeAmount)
  local waited = 0
  while enabled and currentWorld() == collectWorld and waited < pickupAckTimeout do
    if selectedTotalInventory() > beforeAmount then
      return true
    end
    Sleep(PICKUP_ACK_POLL_MS)
    waited = waited + PICKUP_ACK_POLL_MS
  end
  return enabled and currentWorld() == collectWorld and selectedTotalInventory() > beforeAmount
end
local function fastMoveNearTarget(target)
  if target == nil or not enabled or currentWorld() ~= collectWorld then
    return false
  end
  if nearTarget(target, FAST_NEAR_RANGE) then
    return true
  end

  local destX, destY = fastDestinationForTarget(target)
  setFly(true)
  local sent = pcall(function()
    FindPath(destX, destY)
  end)
  if not sent then
    return false
  end

  local waited, stillMs = 0, 0
  local lastX, lastY = playerTile()
  while enabled and waited < FAST_MOVE_TIMEOUT_MS do
    if currentWorld() ~= collectWorld then
      return false
    end

    local px, py = playerTile()
    if px == nil or py == nil then
      return false
    end

    if reached(destX, destY) then
      Sleep(FAST_MOVE_SETTLE_MS)
      return enabled and currentWorld() == collectWorld and nearTarget(target, FAST_NEAR_RANGE)
    end

    if px ~= lastX or py ~= lastY then
      stillMs = 0
      lastX, lastY = px, py
    else
      stillMs = stillMs + FAST_MOVE_POLL_MS
    end

    if nearTarget(target, FAST_NEAR_RANGE) and stillMs >= FAST_MOVE_SETTLE_MS then
      return true
    end
    if stillMs >= FAST_MOVE_STALL_MS then
      return nearTarget(target, FAST_NEAR_RANGE)
    end

    Sleep(FAST_MOVE_POLL_MS)
    waited = waited + FAST_MOVE_POLL_MS
  end
  return false
end
local function updateServerPace()
  local mode = "CAUTIOUS"
  if adaptivePickupBatch >= 3 then
    mode = "FAST"
  end
  if adaptivePickupBatch == 1 then
    mode = "LAG SAFE"
  end
  pcall(function()
    ACD19_safeEditValue("ACD_serverpace", mode .. " (" .. tostring(adaptivePickupBatch) .. ")")
  end)
end
local function setLagSafePace()
  adaptivePickupBatch = 1
  healthyBatchStreak = 0
  laggyBatchStreak = math.min(laggyBatchStreak + 1, 5)
  updateServerPace()
end
local function setHealthyPace()
  laggyBatchStreak = 0
  healthyBatchStreak = healthyBatchStreak + 1
  -- Do not instantly jump from LAG SAFE to three requests on a single ACK.
  if healthyBatchStreak >= 2 and adaptivePickupBatch < maxPickupBatch then
    adaptivePickupBatch = adaptivePickupBatch + 1
    healthyBatchStreak = 0
  end
  updateServerPace()
end
local function requestTargetForBatch(target, index, total)
  if not enabled or currentWorld() ~= collectWorld then
    return "WORLD"
  end
  if not itemNeedsPickup(target.itemID) then
    return "FULL"
  end
  if not objectExists(target.uid) then
    return "GONE"
  end

  local beforeMove = inventoryCount(target.itemID)
  setStatus("PATH " .. tostring(index) .. "/" .. tostring(total))
  if not fastMoveNearTarget(target) then
    return "PATH"
  end
  if not enabled or currentWorld() ~= collectWorld then
    return "WORLD"
  end
  if inventoryCount(target.itemID) > beforeMove then
    return "ACK"
  end
  if not itemNeedsPickup(target.itemID) then
    return "FULL"
  end
  if not objectExists(target.uid) then
    return "GONE"
  end
  if not nearTarget(target, FAST_NEAR_RANGE) then
    return "PATH"
  end

  -- Only one manual type-11 request for this UID. No built-in AutoCollect.
  if not activateObject(target) then
    return "PACKET"
  end
  if pickupDelay > 0 then
    Sleep(pickupDelay)
  end
  -- Allow server to update the backpack before considering another target.
  Sleep(BATCH_PACKET_GAP_MS)
  return "SENT"
end
local function fastSweepTargets(targets)
  if type(targets) ~= "table" or #targets == 0 then
    return false
  end
  collectionSweepNumber = collectionSweepNumber + 1
  setStatus("ADAPTIVE COLLECT")
  setFly(true)
  setAutoCollect(false)
  updateServerPace()

  local sentTargets = {}
  local batchBefore = selectedTotalInventory()
  local attemptedAny = false
  local progressAny = false

  local function finishBatch()
    if #sentTargets == 0 then
      batchBefore = selectedTotalInventory()
      return true
    end

    -- Only a full combined batch (or all goals staged) starts storage.
    if allSelectedReadyForStorage() then
      sentTargets = {}
      return true
    end
    setStatus("WAIT BATCH ACK")
    local acknowledged = selectedTotalInventory() > batchBefore
    if not acknowledged then
      acknowledged = waitForPickupACK(batchBefore)
    end

    if acknowledged then
      progressAny = true
      setHealthyPace()
      -- A changed inventory confirms server progress, NOT necessarily all
      -- objects in the batch. Any surviving UIDs are revisited by a rescan.
      for _, t in ipairs(sentTargets) do
        if not objectExists(t.uid) then
          deferredPickupUntilSweep[tostring(t.uid)] = nil
        end
      end
    else
      -- No pickup server ACK. Shrink to a single request and give the
      -- server time; never keep sending the entire row during lag.
      setLagSafePace()
      for _, t in ipairs(sentTargets) do
        deferredPickupUntilSweep[tostring(t.uid)] = collectionSweepNumber + FAILED_PICKUP_SKIP_SWEEPS
      end
      setStatus("SERVER SLOW - BACKOFF")
      local backoff = math.min(PICKUP_SERVER_BACKOFF_MS + 250 * laggyBatchStreak, BATCH_LAG_MAX_BACKOFF_MS)
      Sleep(backoff)
    end

    sentTargets = {}
    batchBefore = selectedTotalInventory()
    return acknowledged
  end

  for index, target in ipairs(targets) do
    if not enabled or currentWorld() ~= collectWorld then
      break
    end
    if allSelectedReadyForStorage() then
      break
    end

    local uid = tostring(target.uid or "")
    if uid ~= "" and collectionSweepNumber >= (deferredPickupUntilSweep[uid] or 0) then
      -- Do not start a new FindPath beyond the allowed batch size until
      -- the shared inventory acknowledgement has been checked.
      if #sentTargets >= adaptivePickupBatch then
        -- Stop this sweep on a missing ACK. A fresh rescan, rather than
        -- another string of movement/pickup requests, is safer in lag.
        if not finishBatch() then
          break
        end
        if not enabled or currentWorld() ~= collectWorld then
          break
        end
      end

      if allSelectedReadyForStorage() then
        break
      end
      attemptedAny = true
      local result = requestTargetForBatch(target, index, #targets)

      if result == "WORLD" or result == "FULL" then
        break
      elseif result == "ACK" then
        progressAny = true
        -- Movement itself collected the item. This is an inventory ACK.
        -- Reconcile older in-flight requests before continuing.
        if #sentTargets > 0 then
          if not finishBatch() then
            break
          end
        else
          setHealthyPace()
        end
      elseif result == "SENT" then
        sentTargets[#sentTargets + 1] = target
      elseif result == "PATH" or result == "PACKET" then
        deferredPickupUntilSweep[uid] = collectionSweepNumber + FAILED_PICKUP_SKIP_SWEEPS
      end
    end
  end

  -- Reconcile outstanding requests before rescanning/warping/dropping.
  -- A failed batch always enters cooldown and ends the current sweep.
  if enabled and currentWorld() == collectWorld and not allSelectedReadyForStorage() then
    finishBatch()
  end

  if enabled and currentWorld() == collectWorld and not allSelectedReadyForStorage() and not attemptedAny then
    setStatus("WAIT DEFERRED PICKUPS")
    Sleep(300)
  end

  updateInventoryDisplay()
  return progressAny
end
local function stopScript(reason)
  enabled = false
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  returnToCollectPending = false
  returnWarpAttempts = 0
  setAutoCollect(false)
  setFly(false)
  dropDialogPending = false
  dropDialogReady = false
  protectDropZoneDuringDrop = false
  storagePending = false
  storageOnlyFullIDs = nil
  blockedByFullScanCount = 0
  pendingDropShift = false
  endStorageObservation()
  ACD19_safeSetStartToggle(false)
  setStatus("STOPPED")
  if reason ~= nil and reason ~= "" then
    notify(reason)
  end
end
local function shiftDropLeft()
  if not enabled then
    return false
  end
  local nextX = currentDropX - 1
  local nextY = currentDropY
  pendingDropShift = true
  setStatus("DROP SHIFT LEFT -> " .. tostring(nextX) .. "," .. tostring(nextY))
  if not ensureExactDropPosition(nextX, nextY) then
    setStatus("WAIT LEFT PATH " .. tostring(nextX) .. "," .. tostring(nextY))
    return false
  end
  currentDropX = nextX
  currentDropY = nextY
  ACD19_storageEntryConfirmed = false -- the new tile must pass double confirmation
  pendingDropShift = false
  notify("Storage moved left to (" .. tostring(nextX) .. ", " .. tostring(nextY) .. ")")
  return true
end
local function tryDropOnce(itemID, before, requested)
  if not enabled or not actionReady(dropWorld) then
    return false
  end
  if not ACD19_storageEntryConfirmed or not reached(currentDropX, currentDropY) then
    setStatus("WAIT SAFE DROP POSITION")
    return false
  end
  -- Check again directly before opening the drop dialog, so a late warp or
  -- bounce to the white door cannot drop items at the wrong coordinates.
  if not ACD19_stableAtStorageTile(currentDropX, currentDropY, ACD19_DROP_PRE_PACKET_STABLE_MS, 650) then
    ACD19_storageEntryConfirmed = false
    setStatus("DROP BLOCKED - LEFT STORAGE TILE")
    return false
  end

  -- An outstanding delayed drop from an earlier attempt may already be done.
  if inventoryCount(itemID) < before then
    return true
  end
  dropDialogPending = true
  dropDialogReady = false
  setStatus("DROP REQUEST " .. tostring(itemID))
  local ok = pcall(function()
    SendPacket(2, "action|drop\nitemID|" .. tostring(itemID))
  end)
  if not ok then
    dropDialogPending = false
    dropDialogReady = false
    return false
  end

  local waited = 0
  while enabled and actionReady(dropWorld) and waited < DROP_DIALOG_TIMEOUT_MS do
    if dropDialogReady or inventoryCount(itemID) < before then
      break
    end
    Sleep(75)
    waited = waited + 75
  end
  local gotDialog = dropDialogReady
  dropDialogPending = false
  dropDialogReady = false

  if not enabled or not actionReady(dropWorld) then
    return false
  end
  if inventoryCount(itemID) < before then
    return true
  end
  if not gotDialog then
    return false
  end
  -- A dialog can arrive late while FindPath or warping is still settling.
  -- Never submit it unless the player is STILL on the exact storage tile.
  if
    not ACD19_storageEntryConfirmed
    or not ACD19_stableAtStorageTile(currentDropX, currentDropY, ACD19_DROP_PRE_PACKET_STABLE_MS, 650)
  then
    ACD19_storageEntryConfirmed = false
    setStatus("DROP CANCELLED - POSITION CHANGED")
    return false
  end

  setStatus("DROP CONFIRM " .. tostring(itemID))
  local sent = pcall(function()
    SendPacket(
      2,
      "action|dialog_return\n"
        .. "dialog_name|drop_item\n"
        .. "itemID|"
        .. tostring(itemID)
        .. "|\n"
        .. "count|"
        .. tostring(requested)
    )
  end)
  if not sent then
    return false
  end

  waited = 0
  while enabled and actionReady(dropWorld) and waited < DROP_ACK_TIMEOUT_MS do
    if inventoryCount(itemID) < before then
      return true
    end
    Sleep(100)
    waited = waited + 100
  end
  return inventoryCount(itemID) < before
end
local function dropOneItemAtTarget(reasonText, itemID)
  while enabled do
    if not actionReady(dropWorld) then
      return false
    end
    observeStoredDrops()
    if dropEligibleAmount(itemID) <= 0 then
      return true
    end
    if pendingDropShift then
      if not shiftDropLeft() then
        return false
      end
    end
    if not ACD19_confirmStorageDropPosition() then
      setStatus("WAIT VERIFIED STORAGE PATH")
      return false
    end

    observeStoredDrops()
    local before = inventoryCount(itemID)
    local wanted = dropEligibleAmount(itemID)
    if wanted <= 0 then
      return true
    end
    -- Example: goal=210, previously dropped=200, backpack=200 -> request
    -- only 10, leaving the other 190 untouched.
    local successful = false
    for attempt = 1, MAX_DROP_ATTEMPTS_PER_TILE do
      if not enabled or not actionReady(dropWorld) then
        return false
      end
      observeStoredDrops()
      if inventoryCount(itemID) < before then
        successful = true
        break
      end
      wanted = dropEligibleAmount(itemID)
      if wanted <= 0 then
        return true
      end
      setStatus(
        "DROP "
          .. tostring(itemID)
          .. " x"
          .. tostring(wanted)
          .. " TRY "
          .. tostring(attempt)
          .. "/"
          .. tostring(MAX_DROP_ATTEMPTS_PER_TILE)
      )
      if tryDropOnce(itemID, before, wanted) then
        successful = true
        break
      end
      -- A warp/bounce while opening the drop dialog is NOT a full tile.
      -- Retry the original saved position rather than shifting left.
      if not ACD19_storageEntryConfirmed or not actionReady(dropWorld) or not reached(currentDropX, currentDropY) then
        setStatus("STORAGE MOVED - RECHECK DROP TILE")
        return false
      end
      Sleep(FULL_TILE_RETRY_DELAY_MS)
      observeStoredDrops()
      if inventoryCount(itemID) < before then
        successful = true
        break
      end
    end

    observeStoredDrops()
    if successful then
      local after = inventoryCount(itemID)
      if after < before then
        setStatus("DROPPED " .. tostring(before - after) .. " " .. itemName(itemID))
        updateInventoryDisplay()
      end
      -- Continue at the same standing tile if more of this item is
      -- still eligible; if quota is reached we leave any excess in bag.
    else
      if not shiftDropLeft() then
        return false
      end
    end
  end
  return false
end
local function selectedStorageRemaining(onlyIDs)
  local sum = 0
  for _, id in ipairs(runItems) do
    if onlyIDs == nil or onlyIDs[id] then
      sum = sum + dropEligibleAmount(id)
    end
  end
  return sum
end
local function dropAllSelectedAtTarget(reasonText, onlyIDs)
  beginStorageObservation()
  observeStoredDrops()
  if selectedStorageRemaining(onlyIDs) <= 0 then
    return true
  end
  setAutoCollect(false)
  if not warpAndWait(dropWorld) then
    setStatus("WAIT SHARED STORAGE WORLD")
    return false
  end
  protectDropZoneDuringDrop = true
  if pendingDropShift and not shiftDropLeft() then
    protectDropZoneDuringDrop = false
    return false
  end
  if not ACD19_confirmStorageDropPosition() then
    protectDropZoneDuringDrop = false
    setStatus("WAIT VERIFIED STORAGE PATH")
    return false
  end
  for _, id in ipairs(runItems) do
    if not enabled then
      break
    end
    observeStoredDrops()
    if (onlyIDs == nil or onlyIDs[id]) and dropEligibleAmount(id) > 0 then
      if not dropOneItemAtTarget(reasonText, id) then
        protectDropZoneDuringDrop = false
        return false
      end
    end
  end
  observeStoredDrops()
  protectDropZoneDuringDrop = false
  updateInventoryDisplay()
  return enabled and selectedStorageRemaining(onlyIDs) <= 0
end
local function queueReturnToCollectionWorld()
  if not enabled or currentWorldIndex > #runWorlds then
    returnToCollectPending = false
    return
  end
  local activeWorld = runWorlds[currentWorldIndex]
  collectWorld = activeWorld
  if worldReady(activeWorld) then
    returnToCollectPending = false
    returnWarpAttempts = 0
    return
  end
  returnToCollectPending = true
  returnWarpAttempts = 0
  setStatus("STORED - RETURN TO " .. tostring(activeWorld))
end
local function tryReturnToCollectionWorld()
  if not returnToCollectPending then
    return true
  end
  if not enabled then
    return false
  end
  if currentWorldIndex > #runWorlds then
    returnToCollectPending = false
    return true
  end

  local activeWorld = runWorlds[currentWorldIndex]
  collectWorld = activeWorld
  returnWarpAttempts = returnWarpAttempts + 1
  setStatus("RETURN " .. tostring(returnWarpAttempts) .. " -> " .. tostring(activeWorld))

  if warpAndWait(activeWorld, RETURN_WORLD_TIMEOUT_MS) and worldReady(activeWorld) then
    -- World name/tiles can load before the game accepts path/pickup actions.
    -- Keep this small; collection still validates position and inventory.
    Sleep(RETURN_WORLD_EXTRA_SETTLE_MS)
    if enabled and worldReady(activeWorld) then
      returnToCollectPending = false
      returnWarpAttempts = 0
      emptyWorldScanCount = 0
      blockedByFullScanCount = 0
      collectionSweepNumber = 0
      deferredPickupUntilSweep = {}
      setStatus("RESUMED " .. tostring(activeWorld))
      return true
    end
  end

  setStatus("RETURN WARP RETRY " .. tostring(returnWarpAttempts) .. " -> " .. tostring(activeWorld))
  Sleep(RETURN_WORLD_RETRY_DELAY_MS)
  return false
end
local function itemIDFromName(name)
  if type(name) ~= "string" or name == "" then
    return nil
  end

  local ok, id = pcall(function()
    if type(findItemID) == "function" then
      return findItemID(name)
    end
    if growtopia ~= nil and type(growtopia.getItemID) == "function" then
      return growtopia.getItemID(name)
    end
    return nil
  end)

  if ok and tonumber(id) ~= nil and tonumber(id) > 0 then
    return math.floor(tonumber(id))
  end
  return nil
end
local function extractItemID(value)
  if type(value) == "number" then
    return math.floor(value)
  end

  if type(value) == "string" then
    local direct = tonumber(value)
    if direct ~= nil and direct > 0 then
      return math.floor(direct)
    end

    local byName = itemIDFromName(value)
    if byName ~= nil then
      return byName
    end

    local digits = value:match("(%d+)")
    if digits ~= nil then
      local n = tonumber(digits)
      if n ~= nil and n > 0 then
        return math.floor(n)
      end
    end
    return nil
  end

  if type(value) == "table" then
    local fields = {
      value.id,
      value.itemid,
      value.itemID,
      value.value,
      value.item,
      value.name,
      value.itemName,
      value.selected,
    }
    for _, field in ipairs(fields) do
      local id = extractItemID(field)
      if id ~= nil and id > 0 then
        return id
      end
    end
  end

  return nil
end
local function applyPickedItem(value)
  local id = extractItemID(value)
  if id == nil or id <= 0 or id > 65535 then
    return false
  end
  if enabled then
    notify("Stop before changing selected items.")
    return true
  end
  for _, selectedID in ipairs(configuredItems) do
    if selectedID == id then
      notify("Already selected: " .. itemName(id) .. " (" .. tostring(id) .. ")")
      return true
    end
  end
  if #configuredItems >= 30 then
    notify("Maximum 30 selected items.")
    return true
  end
  configuredItems[#configuredItems + 1] = id
  saveConfiguredItems()
  updateInventoryDisplay()
  ACD19_safeEditValue("ACD_objects", "0")
  initialInventoryCheck = true
  notify("Added collect item: " .. itemName(id) .. " (" .. tostring(id) .. ")")
  return true
end
function onVariant(var, pkt)
  if var ~= nil and var.v1 == "OnDialogRequest" and type(var.v2) == "string" then
    if enabled and dropDialogPending and var.v2:find("drop_item", 1, true) then
      dropDialogReady = true
      return true
    end
  end
  return false
end
function onGamePacket(pkt)
  if pkt ~= nil and tonumber(pkt.type) == 26 then
    validatedWorld = ""
    worldWasPresent = ""
    actionReadyWorld = ""
    ACD61_activeDoorRoute = ""
    ACD19_storageEntryConfirmed = false
    ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  end
  return false
end
function onSendPacketRaw(pkt)
  if enabled and pkt ~= nil and tonumber(pkt.type) == 11 and dropZoneProtectionActive() then
    -- Prefer the object/pickup packet coordinates when they are available.
    local rawX = tonumber(pkt.x)
    local rawY = tonumber(pkt.y)
    if rawX ~= nil and rawY ~= nil then
      local objectTileX = math.floor(rawX / 32)
      local objectTileY = math.floor(rawY / 32)
      if isInsideDropZone(objectTileX, objectTileY) then
        return true
      end
    end

    -- Fallback: if the player is currently inside the protected drop zone,
    -- block automatic pickup requests while passing through it.
    local px, py = playerTile()
    if px ~= nil and py ~= nil and isInsideDropZone(px, py) then
      return true
    end
  end

  return false
end
local function startVerifiedCollectionRun()
  enabled = true
  setFly(true)
  setAutoCollect(false)
  if #configuredItems == 0 then
    stopScript("Add at least one Collect Item first.")
    return
  end
  if #configuredWorlds == 0 then
    stopScript("Add at least one Collection World in Settings first.")
    return
  end
  if dropWorld == "" then
    stopScript("Set Drop World first.")
    return
  end

  -- V13 is ONE PASS ONLY. Clear legacy V12 repeat/loop settings so
  -- an old saved value can never restart the world list or end early.
  saveMWSetting("repeat", false)
  saveMWSetting("loops", 0)

  -- Snapshot the configured list: editing Settings during collection
  -- never changes the active world mid-path or mid-drop.
  runWorlds, runItems, runItemSet = {}, {}, {}
  runDropTotal = configuredDropTotal
  droppedByItem = {}
  storageObservationActive = false
  storageObserved = {}
  for _, worldName in ipairs(configuredWorlds) do
    runWorlds[#runWorlds + 1] = worldName
  end
  for _, id in ipairs(configuredItems) do
    runItems[#runItems + 1] = id
    runItemSet[id] = true
  end
  currentWorldIndex = 1
  returnToCollectPending = false
  returnWarpAttempts = 0
  collectWorld = runWorlds[1]
  emptyWorldScanCount = 0
  updateWorldProgress()

  -- Every new manual START begins from the configured drop position.
  -- During the session currentDropX may move left as tiles become full.
  currentDropX = dropX
  currentDropY = dropY
  ACD19_storageEntryConfirmed = false
  ACD19_storageEntryConfirmedX, ACD19_storageEntryConfirmedY = nil, nil
  storagePending = false
  storageOnlyFullIDs = nil
  blockedByFullScanCount = 0
  pendingDropShift = false
  collectionSweepNumber = 0
  deferredPickupUntilSweep = {}
  adaptivePickupBatch = math.min(2, maxPickupBatch)
  healthyBatchStreak = 0
  laggyBatchStreak = 0
  updateServerPace()

  initialInventoryCheck = false -- V15: partial items alone do not trigger storage.
  completedLoops = 0
  updateInventoryDisplay()
  updateDropProgress()
  updateLoopDisplay()
  setStatus("STARTING")
  notify(
    "Auto Collect V6.1 started: "
      .. (runDropTotal == 0 and "UNLIMITED UNTIL WORLDS EMPTY" or ("per-item drop goal " .. tostring(runDropTotal)))
  )
end
function onValue(valueType, name, value)
  -- editValue/editToggle may synchronously invoke onValue again. Never
  -- reenter a field handler from a programmatic UI refresh.
  if ACD19_guardedUIWrites[name] then
    return
  end
  if name == "ACD_licensekey" then
    local newKey = normalizeLicenseKey(value)
    if startCheckPending and newKey ~= normalizeLicenseKey(licenseKey) then
      startCheckGeneration = startCheckGeneration + 1
      startCheckPending = false
      ACD19_safeSetStartToggle(false)
      setStatus("STOPPED - LICENSE CHANGED")
    end
    licenseKey = newKey
    licenseVerified = false
    saveMWSetting("license_key", newKey)
    setLicenseStatus("NOT VERIFIED")
    return
  end

  if name == "ACD_verifylicense" then
    runThread(function()
      verifyLicense(false)
    end)
    return
  end

  if name == "ACD_clearlicense" then
    if startCheckPending then
      startCheckGeneration = startCheckGeneration + 1
      startCheckPending = false
      ACD19_safeSetStartToggle(false)
      setStatus("STOPPED - LICENSE CLEARED")
    end
    licenseVerified = false
    licenseKey = ""
    savedLicense = ""
    clearLicensePreference()
    saveMWSetting("license_key", "")
    pcall(function()
      ACD19_safeEditValue("ACD_licensekey", "")
    end)
    setLicenseStatus("NOT VERIFIED")
    notify("Saved license cleared.")
    return
  end

  if name == "ACD_enable" then
    if value == true then
      -- A previous successful Verify button or saved key is NOT sufficient.
      -- Start always asks Google Sheets for the current key status.
      if enabled or startCheckPending then
        return
      end

      startCheckGeneration = startCheckGeneration + 1
      local myGeneration = startCheckGeneration
      local requestedKey = normalizeLicenseKey(licenseKey)
      startCheckPending = true
      licenseVerified = false
      enabled = false -- worker cannot collect/drop during authorization
      setFly(false)
      setAutoCollect(false)
      setStatus("CHECKING LICENSE BEFORE START")

      runThread(function()
        -- If Verify License was just pressed, wait for that request to end
        -- before making the mandatory, fresh Start request.
        local waited = 0
        while licenseCheckRunning and startCheckPending and startCheckGeneration == myGeneration and waited < 30000 do
          Sleep(100)
          waited = waited + 100
        end

        if not startCheckPending or startCheckGeneration ~= myGeneration then
          return -- user turned OFF or changed the key
        end

        local authorized = false
        if not licenseCheckRunning then
          authorized = verifyLicense(true)
        else
          setLicenseStatus("VERIFY BUSY - RETRY START")
        end

        -- Do not start if Stop was pressed or the license field changed
        -- while the network request was in flight.
        if not startCheckPending or startCheckGeneration ~= myGeneration then
          return
        end
        if normalizeLicenseKey(licenseKey) ~= requestedKey then
          authorized = false
          licenseVerified = false
          setLicenseStatus("KEY CHANGED - RETRY START")
        end

        startCheckPending = false
        if not authorized then
          enabled = false
          ACD19_safeSetStartToggle(false)
          setAutoCollect(false)
          setFly(false)
          setStatus("LICENSE NOT VALID - NOT STARTED")
          notify("License was not approved by the server. Start blocked (" .. tostring(licenseLastResult) .. ").")
          return
        end

        -- Start remains enabled during this run; there is deliberately no
        -- periodic license polling. Pressing Start again re-verifies.
        startVerifiedCollectionRun()
      end)
    else
      -- Stop also cancels any in-flight Start verification. A delayed
      -- positive server reply must not restart a manually stopped script.
      startCheckGeneration = startCheckGeneration + 1
      startCheckPending = false
      enabled = false
      setAutoCollect(false)
      setFly(false)
      dropDialogPending = false
      dropDialogReady = false
      protectDropZoneDuringDrop = false
      storagePending = false
      pendingDropShift = false
      endStorageObservation()
      setStatus("STOPPED")
      notify("Auto Collect -> Drop stopped.")
    end
    return
  end

  if name == "ACD_itempicker" then
    if not applyPickedItem(value) then
      notify("Could not read selected item.")
    end
    return
  end

  if name == "ACD_selecteditem" then
    -- Status field is for viewing only, not editing.
    updateSelectedDisplay()
    return
  end

  if name == "ACD_itemlist" then
    if enabled then
      pcall(function()
        ACD19_safeEditValue("ACD_itemlist", serializeSelectedItems(configuredItems))
      end)
      notify("Stop before editing the item list.")
      return
    end
    configuredItems = parseSelectedItems(value)
    saveConfiguredItems()
    updateInventoryDisplay()
    return
  end

  if name == "ACD_removeitem" then
    if enabled then
      notify("Stop before removing items.")
      return
    end
    if #configuredItems > 0 then
      local id = table.remove(configuredItems)
      saveConfiguredItems()
      updateInventoryDisplay()
      notify("Removed selected item " .. tostring(id))
    end
    return
  end

  if name == "ACD_clearitems" then
    if enabled then
      notify("Stop before clearing items.")
      return
    end
    configuredItems = {}
    saveConfiguredItems()
    updateInventoryDisplay()
    notify("Selected item list cleared.")
    return
  end

  if name == "ACD_droptotal" then
    local n = tonumber(value)
    if n == nil or n < 0 then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(configuredDropTotal))
      end)
      notify("Total Drop Per Item must be 0 or a positive whole number.")
      return
    end
    n = math.max(0, math.min(1000000000, math.floor(n)))
    configuredDropTotal = n
    saveMWSetting("droptotal", configuredDropTotal)
    if tostring(value) ~= tostring(n) then
      pcall(function()
        ACD19_safeEditValue("ACD_droptotal", tostring(n))
      end)
    end
    if enabled then
      notify("Drop total saved. The new goal applies on next Start.")
    else
      -- Preview what the next run will use without altering active totals.
      runDropTotal = configuredDropTotal
      updateDropProgress()
    end
    return
  end

  if name == "ACD_pickupdelay" then
    local n = tonumber(value)
    if n ~= nil then
      n = math.floor(n)
      if n < 0 then
        n = 0
      end
      if n > 1000 then
        n = 1000
      end
      pickupDelay = n
      ACD19_safeEditValue("ACD_pickupdelay", tostring(pickupDelay))
      saveMWSetting("pickupdelay", pickupDelay)
    end
    return
  end

  if name == "ACD_batchmax" then
    local n = math.floor(tonumber(value) or maxPickupBatch)
    maxPickupBatch = math.max(1, math.min(2, n))
    adaptivePickupBatch = math.min(adaptivePickupBatch, maxPickupBatch)
    pcall(function()
      ACD19_safeEditValue("ACD_batchmax", tostring(maxPickupBatch))
    end)
    updateServerPace()
    saveMWSetting("batchmax", maxPickupBatch)
    return
  end

  if name == "ACD_acktimeout" then
    local n = tonumber(value)
    if n ~= nil then
      n = math.floor(n)
      if n < 300 then
        n = 300
      end
      if n > 10000 then
        n = 10000
      end
      pickupAckTimeout = n
      ACD19_safeEditValue("ACD_acktimeout", tostring(pickupAckTimeout))
      saveMWSetting("acktimeout", pickupAckTimeout)
    end
    return
  end

  if name == "ACD_worldlist" then
    configuredWorlds = parseMWWorlds(value)
    saveConfiguredWorlds()
    updateWorldProgress()
    if enabled then
      notify("World list saved; changes take effect on the next Start.")
    end
    return
  end

  if name == "ACD_addworld" then
    local world = currentWorld()
    if world == "" or world == "EXIT" then
      notify("Enter the world you want to add first.")
      return
    end
    local found = false
    for _, name in ipairs(configuredWorlds) do
      if name == world then
        found = true
        break
      end
    end
    if not found then
      if #configuredWorlds >= 30 then
        notify("Maximum 30 collection worlds.")
        return
      end
      configuredWorlds[#configuredWorlds + 1] = world
    end
    saveConfiguredWorlds()
    updateWorldProgress()
    notify("Collection worlds: " .. serializeMWWorlds(configuredWorlds))
    return
  end

  if name == "ACD_removeworld" then
    if #configuredWorlds > 0 then
      local removed = table.remove(configuredWorlds)
      saveConfiguredWorlds()
      updateWorldProgress()
      notify("Removed collection world " .. tostring(removed))
    end
    return
  end

  if name == "ACD_dropworld" then
    if enabled then
      pcall(function()
        ACD19_safeEditValue("ACD_dropworld", dropWorld)
      end)
      notify("Stop the script before editing the Shared Storage World.")
      return
    end
    dropWorld = cleanWorldName(value)
    saveMWSetting("dropworld", dropWorld)
    updateWorldProgress()
    return
  end

  if name == "ACD_setdropworld" then
    if enabled then
      notify("Stop before editing Shared Storage World.")
      return
    end
    local world = currentWorld()
    if world == "" or world == "EXIT" then
      notify("Current world is not available.")
      return
    end
    dropWorld = world
    ACD19_safeEditValue("ACD_dropworld", dropWorld)
    saveMWSetting("dropworld", dropWorld)
    updateWorldProgress()
    notify("Shared Storage World = " .. dropWorld)
    return
  end

  if name == "ACD_dropx" then
    if enabled then
      pcall(function()
        ACD19_safeEditValue("ACD_dropx", tostring(dropX))
      end)
      notify("Stop before editing Drop X.")
      return
    end
    local n = tonumber(value)
    if n ~= nil then
      dropX = math.floor(n)
      currentDropX = dropX
      saveMWSetting("dropx", dropX)
    end
    return
  end

  if name == "ACD_dropy" then
    if enabled then
      pcall(function()
        ACD19_safeEditValue("ACD_dropy", tostring(dropY))
      end)
      notify("Stop before editing Drop Y.")
      return
    end
    local n = tonumber(value)
    if n ~= nil then
      dropY = math.floor(n)
      currentDropY = dropY
      saveMWSetting("dropy", dropY)
    end
    return
  end

  if name == "ACD_setdrop" then
    if enabled then
      notify("Stop before setting Drop Position.")
      return
    end
    local x, y = playerTile()
    if x == nil or y == nil then
      notify("Player position is not available.")
      return
    end

    dropX = x
    dropY = y
    currentDropX = dropX
    currentDropY = dropY

    ACD19_safeEditValue("ACD_dropx", tostring(dropX))
    ACD19_safeEditValue("ACD_dropy", tostring(dropY))
    saveMWSetting("dropx", dropX)
    saveMWSetting("dropy", dropY)
    notify("Drop Position = (" .. tostring(dropX) .. ", " .. tostring(dropY) .. ")")
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(function()
    setOnValue("ACD_itempicker", function(...)
      local args = { ... }
      for i = #args, 1, -1 do
        if applyPickedItem(args[i]) then
          return
        end
      end
    end)
  end)
end
runThread(function()
  setFly(false)
  updateSelectedDisplay()
  updateInventoryDisplay()
  updateLoopDisplay()
  updateDropProgress()
  updateWorldProgress()
  updateServerPace()
  ACD19_safeEditValue("ACD_objects", "0")
  setStatus("STOPPED")
  ACD19_mwSaveState = mwPref == nil and "UNAVAILABLE"
    or (ACD19_mwSettingsRestored and "RESTORED" or "READY - SAVES ON EDIT")
  ACD19_safeEditValue("ACD_autosave", ACD19_mwSaveState)

  -- Saved key only pre-fills the field. Each Start performs its own online
  -- verification (including when the key was verified on an earlier run).
  if licenseKey ~= "" then
    pcall(function()
      ACD19_safeEditValue("ACD_licensekey", licenseKey)
    end)
    setLicenseStatus("SAVED - CHECK ON START")
  else
    setLicenseStatus("NOT VERIFIED")
  end

  while true do
    if not enabled then
      Sleep(200)
    else
      -- The inventory display is refreshed on collection/drop transactions,
      -- not unconditionally every worker tick.

      -- Return to the SAME collection world after intermediate storage.
      if returnToCollectPending then
        tryReturnToCollectionWorld()

        -- Quota completion is based on actual DROPPED counts, not collected.
        -- Once every selected type hits its own target, stop immediately.
      elseif allDropGoalsMet() then
        stopScript("All selected item drop totals reached (" .. tostring(runDropTotal) .. " each).")

        -- Normally wait until all selected types are full/goal-ready.
        -- Exception for unlimited mode: if a full type still has objects on
        -- the ground, store ONLY full types and return to this same world.
      elseif storagePending or allSelectedReadyForStorage() then
        storagePending = true
        setAutoCollect(false)
        if storageOnlyFullIDs then
          setStatus("UNLIMITED -> FREE FULL ITEM STACKS")
        else
          setStatus("ALL ITEMS READY -> SHARED STORAGE")
        end
        if dropAllSelectedAtTarget("Ready selected items dropped", storageOnlyFullIDs) then
          storagePending = false
          storageOnlyFullIDs = nil
          blockedByFullScanCount = 0
          endStorageObservation()
          completedLoops = completedLoops + 1
          updateLoopDisplay()
          if allDropGoalsMet() then
            stopScript("All selected item drop totals reached (" .. tostring(runDropTotal) .. " each).")
          else
            queueReturnToCollectionWorld()
            Sleep(150)
          end
        else
          Sleep(400)
        end
      elseif currentWorldIndex > #runWorlds then
        -- All worlds exhausted. A final partial storage trip is allowed
        -- only here, or to satisfy a quota smaller than 200.
        if selectedEligibleInventory() > 0 then
          setStatus("FINAL STORAGE -> STOP")
          if dropAllSelectedAtTarget("Last eligible collected items dropped") then
            endStorageObservation()
            updateWorldProgress()
            if runDropTotal > 0 and not allDropGoalsMet() then
              stopScript("All worlds scanned. Drop targets not met: " .. unfinishedGoalSummary())
            else
              stopScript("All " .. tostring(#runWorlds) .. " collection worlds finished. Eligible items stored.")
            end
          elseif enabled then
            Sleep(500)
          end
        else
          endStorageObservation()
          updateWorldProgress()
          if runDropTotal > 0 and not allDropGoalsMet() then
            stopScript("All worlds scanned. Drop targets not met: " .. unfinishedGoalSummary())
          else
            stopScript("All collection worlds finished. No more eligible items.")
          end
        end
      else
        -- The collectWorld variable is the ACTIVE world for the original
        -- V10.8 adaptive sweep; its callbacks/ACK guards stay unchanged.
        collectWorld = runWorlds[currentWorldIndex]
        if not warpAndWait(collectWorld) then
          -- Keep Start ON and retry after lag. Never skip a world on a
          -- failed warp, because that could silently lose its items.
          setStatus("WAIT COLLECT WORLD " .. tostring(collectWorld))
          Sleep(1300)
        elseif not actionReady(collectWorld) then
          setStatus("WAIT COLLECT PLAYER READY")
          Sleep(300)
        else
          setStatus("SCAN " .. tostring(collectWorld))
          local targets = findTargetObjects()

          if #targets == 0 then
            -- 0 = unlimited means all SELECTED floating items must be
            -- exhausted, not merely those that fit in the backpack.
            -- A full type with more floating copies must be stored
            -- and re-collected before declaring this world empty.
            local fullIDs, blockedByFull = nil, false
            if runDropTotal == 0 then
              fullIDs, blockedByFull = fullSelectedTypesStillOnGround()
            end
            if blockedByFull then
              emptyWorldScanCount = 0
              blockedByFullScanCount = blockedByFullScanCount + 1
              if blockedByFullScanCount >= 2 then
                storageOnlyFullIDs = fullIDs
                storagePending = true
                blockedByFullScanCount = 0
                setStatus("UNLIMITED / FULL STACK: STORE & RESUME")
              else
                setStatus("VERIFY FULL STACK BACKLOG")
              end
              Sleep(400)
            else
              blockedByFullScanCount = 0
              -- A single empty GetObjectList result may be transient
              -- during a delayed warp or a server pickup update.
              emptyWorldScanCount = emptyWorldScanCount + 1
              if emptyWorldScanCount < 3 then
                setStatus("CONFIRM EMPTY " .. tostring(emptyWorldScanCount) .. "/3 " .. tostring(collectWorld))
                Sleep(400)
              else
                setStatus("WORLD COMPLETE " .. tostring(collectWorld))
                emptyWorldScanCount = 0
                currentWorldIndex = currentWorldIndex + 1
                collectionSweepNumber = 0
                deferredPickupUntilSweep = {}
                if currentWorldIndex <= #runWorlds then
                  collectWorld = runWorlds[currentWorldIndex]
                end
                updateWorldProgress()
                Sleep(250)
              end
            end
          else
            emptyWorldScanCount = 0
            blockedByFullScanCount = 0
            fastSweepTargets(targets)
            setAutoCollect(false)
            setStatus("RESCAN " .. tostring(collectWorld))
            Sleep(FAST_RESCAN_DELAY_MS)
          end
        end
      end

      Sleep(120)
    end
  end
end)
