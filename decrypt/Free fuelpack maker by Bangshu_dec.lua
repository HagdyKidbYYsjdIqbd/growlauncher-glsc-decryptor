setMinimum("6.1.2")
local CONFIG_FILE = "auto_fuel_pack_maker_v10_settings.json"
local settings = nil
local settingsErrorShown = false
do
  local ok, preferenceModule = pcall(require, "preferences")
  if not ok or preferenceModule == nil then
    preferenceModule = Preferences
  end
  if preferenceModule ~= nil and type(preferenceModule.new) == "function" then
    local created, object = pcall(function()
      return preferenceModule:new(CONFIG_FILE)
    end)
    if created and object ~= nil then
      settings = object
      -- A missing file on the first run is expected on some versions.
      pcall(function()
        settings:load()
      end)
    end
  end
end
local function savedInteger(key, fallback, minimum, maximum)
  local value = fallback
  if settings ~= nil then
    local ok, readValue = pcall(function()
      return settings:get(key, fallback)
    end)
    if ok and tonumber(readValue) ~= nil then
      value = tonumber(readValue)
    end
  end
  value = math.floor(value)
  if minimum ~= nil then
    value = math.max(minimum, value)
  end
  if maximum ~= nil then
    value = math.min(maximum, value)
  end
  return value
end
local savedCookX = savedInteger("cookX", 0)
local savedCookY = savedInteger("cookY", 0)
local savedStorageX = savedInteger("storageX", 0)
local savedStorageY = savedInteger("storageY", 0)
local savedFirstPunchDelay = savedInteger("firstPunchDelay", 500, 0, 10000)
local savedPrePunchDelay = savedInteger("prePunchDelay", 700, 0, 10000)
local savedOpenPunchDelay = savedInteger("openPunchDelay", 350, 0, 10000)
local savedDropDelay = savedInteger("dropDelay", 250, 0, 10000)
local savedCollectDelay = savedInteger("collectDelay", 500, 0, 10000)
local savedPickupGap = savedInteger("pickupGap", 900, 350, 10000)
local savedVerifyDelay = savedInteger("verifyDelay", 200, 0, 10000)
local savedFuelStorePause = savedInteger("fuelStorePause", 4000, 0, 10000)
local savedPathPace = savedInteger("pathPace", 900, 500, 5000)
local savedRecipePause = savedInteger("recipePause", 1500, 500, 10000)
local LICENSE_URL =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local LICENSE_PRODUCT = "AUTOFUEL"
local LICENSE_PREF_NAME = "FuelPackV34License"
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
local ui = UserInterface.new("Fuel Pack Maker", "Science")
ui:addLabelApp("Fuel Pack Maker", "Science")
ui:addInputString("License Key", savedLicense, "A1234567", "A1234567", nil, "FUEL_licensekey")
ui:addButton("Verify License", "FUEL_verifylicense")
ui:addButton("Clear Saved License", "FUEL_clearlicense")
ui:addDisplayList("License Status", "NOT VERIFIED", "FUEL_licensestatus")
ui:addToggle("Start / Stop", false, "FUEL_enable")
ui:addInputInt("Cook Position X", tostring(savedCookX), "X", "0", nil, "FUEL_cookx")
ui:addInputInt("Cook Position Y", tostring(savedCookY), "Y", "0", nil, "FUEL_cooky")
ui:addButton("Set Cook Position = Current Tile", "FUEL_setcook")
ui:addInputInt("Storage Position X", tostring(savedStorageX), "X", "0", nil, "FUEL_storagex")
ui:addInputInt("Storage Position Y", tostring(savedStorageY), "Y", "0", nil, "FUEL_storagey")
ui:addButton("Set Storage Position = Current Tile", "FUEL_setstorage")
ui:addInputInt(
  "After Oven Open Before Pickup (ms)",
  tostring(savedFirstPunchDelay),
  "ms",
  "0",
  nil,
  "FUEL_firstpunchdelay"
)
ui:addInputInt("After Third Drop Before Punch (ms)", tostring(savedPrePunchDelay), "ms", "0", nil, "FUEL_prepunchdelay")
ui:addInputInt("After Open Punch (ms)", tostring(savedOpenPunchDelay), "ms", "0", nil, "FUEL_openpunchdelay")
ui:addInputInt("After Drop (ms)", tostring(savedDropDelay), "ms", "0", nil, "FUEL_dropdelay")
ui:addInputInt("Before Each Collect Attempt (ms)", tostring(savedPickupGap), "ms", "900", nil, "FUEL_pickupgap")
ui:addInputInt(
  "After Fuel Pack Storage Pause (ms)",
  tostring(savedFuelStorePause),
  "ms",
  "4000",
  nil,
  "FUEL_storepause"
)
ui:addInputInt("Before New Path Request (ms)", tostring(savedPathPace), "ms", "900", nil, "FUEL_pathpace")
ui:addInputInt("Between Cook Batches (ms)", tostring(savedRecipePause), "ms", "1500", nil, "FUEL_recipepause")
ui:addInputInt("After Collect (ms)", tostring(savedCollectDelay), "ms", "500", nil, "FUEL_collectdelay")
ui:addInputInt("Empty Scan Gap (ms)", tostring(savedVerifyDelay), "ms", "0", nil, "FUEL_verifydelay")
ui:addDisplayList("Phase", "STOPPED", "FUEL_phase")
ui:addDisplayList("Status", "STOPPED", "FUEL_status")
ui:addInputString("Preparation Status (view only)", "WAITING", "", "Preparation stage", nil, "FUEL_prepstatus")
ui:addInputString("Drop Diagnostics (view only)", "READY", "", "Drop stage", nil, "FUEL_dropdebug")
ui:addInputString("Drop Destination (view only)", "NONE", "", "COOK or STORAGE tile", nil, "FUEL_dropdest")
ui:addDisplayList("Mysterious Chemical", "0", "FUEL_mcount")
ui:addDisplayList("Fuel Pack", "0", "FUEL_fuelcount")
ui:addDisplayList("Fast Drop", "OFF", "FUEL_fastdrop")
ui:addDisplayList("Settings", settings ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "FUEL_settingsstatus")
pcall(function()
  addCategory("Fuel Pack Maker", "Science")
end)
local added = pcall(function()
  addIntoModule(ui:generateJSON(), "Fuel Pack Maker")
end)
if not added then
  addIntoModule(ui:generateJSON())
end
local enabled = false
local workingWorld = ""
local cookX, cookY = savedCookX, savedCookY
local storageX, storageY = savedStorageX, savedStorageY
local currentStorageX, currentStorageY = savedStorageX, savedStorageY
local phase = "STOPPED"
local status = "STOPPED"
local ID_Y = 0
local ID_B = 0
local ID_P = 0
local ID_G = 0
local ID_M = 0
local ID_FUEL = 0
local M_Y, M_B, M_P = 20, 10, 5
local FUEL_M, FUEL_G, FUEL_B = 1, 10, 2
local STACK_MAX = 200
local batchIngredientsPrimed = { M = false, FUEL = false }
local MOVE_RETRIES = 2
local MOVE_TIMEOUT_MS = 3200
local MOVE_RETRY_GAP_MS = 1200
local PATH_REQUEST_PAUSE_MS = savedPathPace
local BETWEEN_RECIPE_PAUSE_MS = savedRecipePause
local DROP_DIALOG_TIMEOUT_MS = 2500
local DROP_ACK_TIMEOUT_MS = 3000
local DROP_PATH_RETRIES = 2
local DROP_PATH_ATTEMPT_MS = 3200
local DROP_POSITION_STABLE_MS = 600
local DROP_REPATH_GAP_MS = 1200
local FULL_TILE_NO_DIALOG_RETRIES = 3
local FULL_TILE_CONFIRM_RETRIES = 3
local FULL_TILE_RETRY_DELAY_MS = 350
local MAX_DROP_POSITION_SHIFTS = 100
local MAX_FIXED_COOK_DROP_FAILURES = 12
local MAX_COOK_DROP_REOPEN_ATTEMPTS = 1
local COLLECT_MOVE_TIMEOUT_MS = 1500
local COLLECT_POLL_MS = 50
local COLLECT_RESCAN_DELAY_MS = 1200
local COLLECT_ATTEMPT_GAP_MS = savedPickupGap
local COOK_COLLECTION_DELAY_MS = savedCollectDelay
local FUEL_AFTER_STORAGE_PAUSE_MS = savedFuelStorePause
local COOK_EMPTY_SCAN_DELAY_MS = savedVerifyDelay
local COOK_EMPTY_REQUIRED_SCANS = 2
local COOK_CLEAR_MAX_PASSES = 8
local COLLECT_ACK_TIMEOUT_MS = 1400
local COLLECT_TARGET_RETRIES = 3
local COLLECT_RETRY_GAP_MS = 1600
local COLLECT_NEAR_RANGE = 1
local COOK_AFTER_DROP_MS = savedDropDelay
local COOK_BEFORE_PUNCH_MS = savedPrePunchDelay
local COOK_BETWEEN_PUNCHES_MS = 500
local COOK_FIRST_PUNCH_WAIT_MS = savedFirstPunchDelay
local COOK_OPEN_PUNCH_WAIT_MS = savedOpenPunchDelay
local COOK_PUNCH_VERIFY_POLL_MS = 50
local COOK_PATH_RETRY_GAP_MS = 400
local COOK_PATH_FAILED_CHECKS_BEFORE_REOPEN = 2
local MAX_COOK_OPEN_PATH_RETRIES = 3
local COOK_OPEN_RECOVERY_COOLDOWN_MS = 1200
local ACTION_COOLDOWN_MS = 600
local missingMSupplyScans = 0
local missingFuelSupplyScans = 0
local SUPPLY_EMPTY_CONFIRM_SCANS = 2
local NO_SUPPLY_WAIT_MS = 3000
local pendingCook = nil
local recipeDropProgress = nil
local dropStorageItem
local ensureFuelInventoryEmpty
local dropDialogPending = false
local dropDialogReady = false
local function saveSettings()
  if settings == nil then
    return false
  end
  local ok, err = pcall(function()
    settings:set("cookX", cookX)
    settings:set("cookY", cookY)
    settings:set("storageX", storageX)
    settings:set("storageY", storageY)
    settings:set("firstPunchDelay", COOK_FIRST_PUNCH_WAIT_MS)
    settings:set("prePunchDelay", COOK_BEFORE_PUNCH_MS)
    settings:set("openPunchDelay", COOK_OPEN_PUNCH_WAIT_MS)
    settings:set("dropDelay", COOK_AFTER_DROP_MS)
    settings:set("collectDelay", COOK_COLLECTION_DELAY_MS)
    settings:set("pickupGap", COLLECT_ATTEMPT_GAP_MS)
    settings:set("fuelStorePause", FUEL_AFTER_STORAGE_PAUSE_MS)
    settings:set("pathPace", PATH_REQUEST_PAUSE_MS)
    settings:set("recipePause", BETWEEN_RECIPE_PAUSE_MS)
    settings:set("verifyDelay", COOK_EMPTY_SCAN_DELAY_MS)
    settings:save()
  end)
  if not ok then
    if not settingsErrorShown then
      settingsErrorShown = true
      pcall(function()
        growtopia.notify("Fuel Maker settings could not be saved: " .. tostring(err))
      end)
    end
    pcall(function()
      editValue("FUEL_settingsstatus", "AUTO SAVE FAILED")
    end)
    return false
  end
  pcall(function()
    editValue("FUEL_settingsstatus", "AUTO SAVE ON")
  end)
  return true
end
local function notify(msg)
  pcall(function()
    growtopia.notify(tostring(msg))
  end)
end
local function setStatus(value)
  value = tostring(value or "")
  if status ~= value then
    status = value
    pcall(function()
      editValue("FUEL_status", value)
    end)
  end
end
local function setPhase(value)
  value = tostring(value or "")
  if phase ~= value then
    phase = value
    pcall(function()
      editValue("FUEL_phase", value)
    end)
  end
end
local launcherToggleCache = {}
local function setLauncherToggle(name, state)
  state = (state == true)
  if launcherToggleCache[name] == state then
    return
  end
  local fn = editToggle or EditToggle
  if fn ~= nil then
    local ok = pcall(fn, name, state)
    if ok then
      launcherToggleCache[name] = state
    end
  end
end
local function setFly(state)
  setLauncherToggle("ModFly", state == true)
end
local function setFastDrop(state)
  setLauncherToggle("Fast Drop", state == true)
end
local function cleanWorldName(value)
  value = tostring(value or ""):gsub("%s+", "")
  return value:upper()
end
local function currentWorld()
  local ok, value = pcall(function()
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
  return cleanWorldName(value)
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
local preparationMessage = "WAITING"
local dropDebugMessage = "READY"
local function setPrepDebug(message)
  message = tostring(message or "")
  if message ~= preparationMessage then
    preparationMessage = message
    pcall(function()
      editValue("FUEL_prepstatus", message)
    end)
  end
end
local function inventoryCount(itemID)
  itemID = tonumber(itemID)
  if itemID == nil or itemID <= 0 then
    return 0
  end

  -- Growlauncher can expose both APIs. Read the actual InventoryItem table
  -- first so a wrapper with stale/ambiguous results does not falsely report
  -- an ingredient as missing. Fall back to checkInventoryCount on builds that
  -- do not expose GetInventory/getInventory.
  local invFn = GetInventory or getInventory
  if type(invFn) == "function" then
    local ok, items = pcall(invFn)
    if ok and type(items) == "table" then
      local total = 0
      for _, item in pairs(items) do
        if tonumber(item.id or item.itemid) == itemID then
          total = total + (tonumber(item.amount or item.count) or 0)
        end
      end
      return math.max(0, total)
    end
  end

  if growtopia ~= nil and type(growtopia.checkInventoryCount) == "function" then
    local ok, result = pcall(growtopia.checkInventoryCount, itemID)
    if ok and tonumber(result) ~= nil then
      return math.max(0, tonumber(result))
    end
  end
  return 0
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
local function findIDByName(name)
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

  return 0
end
local function resolveItemIDs()
  ID_Y = findIDByName("Chemical Y")
  ID_B = findIDByName("Chemical B")
  ID_P = findIDByName("Chemical P")
  ID_G = findIDByName("Chemical G")
  ID_M = findIDByName("Mysterious Chemical")
  ID_FUEL = findIDByName("Fuel Pack")

  local missing = {}
  if ID_Y <= 0 then
    table.insert(missing, "Chemical Y")
  end
  if ID_B <= 0 then
    table.insert(missing, "Chemical B")
  end
  if ID_P <= 0 then
    table.insert(missing, "Chemical P")
  end
  if ID_G <= 0 then
    table.insert(missing, "Chemical G")
  end
  if ID_M <= 0 then
    table.insert(missing, "Mysterious Chemical")
  end
  if ID_FUEL <= 0 then
    table.insert(missing, "Fuel Pack")
  end

  if #missing > 0 then
    notify("Could not resolve: " .. table.concat(missing, ", "))
    return false
  end

  return true
end
local function updateCounts()
  pcall(function()
    editValue("FUEL_mcount", tostring(inventoryCount(ID_M)))
  end)
  pcall(function()
    editValue("FUEL_fuelcount", tostring(inventoryCount(ID_FUEL)))
  end)
end
local function requestPathPaced(x, y)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  if reached(x, y) then
    return true
  end
  setStatus("PATH COOLDOWN " .. tostring(PATH_REQUEST_PAUSE_MS) .. "ms")
  local wait = math.max(500, PATH_REQUEST_PAUSE_MS)
  while wait > 0 do
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    local step = math.min(wait, 100)
    Sleep(step)
    wait = wait - step
  end
  if reached(x, y) then
    return true
  end
  local ok, result = pcall(function()
    return FindPath(x, y)
  end)
  return ok and result ~= false
end
local function moveTo(x, y)
  if not enabled then
    return false
  end
  if reached(x, y) then
    return true
  end

  setFly(true)

  for attempt = 1, MOVE_RETRIES do
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end

    setStatus(
      "PATH " .. tostring(attempt) .. "/" .. tostring(MOVE_RETRIES) .. " -> " .. tostring(x) .. "," .. tostring(y)
    )

    local sent = requestPathPaced(x, y)
    if not sent then
      setStatus("PATH REJECTED - WAIT BEFORE RETRY")
    end

    local waited = 0

    while enabled and waited < MOVE_TIMEOUT_MS do
      if currentWorld() ~= workingWorld then
        return false
      end

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
local function stableAtPosition(x, y, durationMs)
  local waited = 0

  while enabled and waited < durationMs do
    if not reached(x, y) then
      return false
    end

    Sleep(100)
    waited = waited + 100
  end

  return enabled and reached(x, y)
end
local function forceFindPathTo(x, y, timeoutMs)
  if not enabled then
    return false
  end
  setFly(true)

  if not requestPathPaced(x, y) then
    return false
  end

  local waited = 0

  while enabled and waited < timeoutMs do
    if currentWorld() ~= workingWorld then
      return false
    end

    if reached(x, y) then
      return true
    end

    Sleep(100)
    waited = waited + 100
  end

  return reached(x, y)
end
local function ensureExactDropPosition(targetX, targetY)
  if not enabled then
    return false
  end

  targetX = math.floor(tonumber(targetX) or 0)
  targetY = math.floor(tonumber(targetY) or 0)

  -- V20: Never force another FindPath while already standing on the target.
  -- The former V10.5-style double FindPath caused repeated movement to the
  -- cook tile before EVERY ingredient drop, even when the player had arrived.
  if reached(targetX, targetY) then
    return true
  end

  for attempt = 1, DROP_PATH_RETRIES do
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    setStatus(
      "MOVING TO DROP "
        .. tostring(attempt)
        .. "/"
        .. tostring(DROP_PATH_RETRIES)
        .. " @ "
        .. tostring(targetX)
        .. ","
        .. tostring(targetY)
    )
    if forceFindPathTo(targetX, targetY, DROP_PATH_ATTEMPT_MS) then
      return true
    end
    if reached(targetX, targetY) then
      return true
    end
    Sleep(DROP_REPATH_GAP_MS)
  end

  return false
end
local function objectPixelPos(obj)
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
local function objectTile(obj)
  local x, y = objectPixelPos(obj)
  if x == nil or y == nil then
    return nil, nil
  end
  return math.floor(x / 32), math.floor(y / 32)
end
local function isStorageArea(tx, ty)
  -- Protect the entire horizontal storage strip used during this run.
  local leftEdge = math.min(storageX, currentStorageX) - 1
  local rightEdge = math.max(storageX, currentStorageX) + 1

  return tx >= leftEdge and tx <= rightEdge and math.abs(ty - storageY) <= 1
end
local function isCookArea(tx, ty)
  return tx >= cookX - 1 and tx <= cookX + 2 and math.abs(ty - cookY) <= 1
end
local function nearCookAmount(itemID)
  local total = 0

  for _, obj in pairs(safeObjects()) do
    if tonumber(obj.itemid) == tonumber(itemID) then
      local tx, ty = objectTile(obj)

      if tx ~= nil and ty ~= nil and isCookArea(tx, ty) then
        total = total + (tonumber(obj.amount) or 0)
      end
    end
  end

  return total
end
local function worldAmount(itemID, includeStorage)
  local total = 0

  for _, obj in pairs(safeObjects()) do
    if tonumber(obj.itemid) == tonumber(itemID) then
      local tx, ty = objectTile(obj)
      if tx ~= nil and ty ~= nil then
        -- The storage strip stores M/Fuel, not recipe Y/B/P/G.
        -- Excluding all chemicals here previously hid visible Y piles.
        if includeStorage or itemID ~= ID_M or not isStorageArea(tx, ty) then
          total = total + (tonumber(obj.amount) or 0)
        end
      end
    end
  end

  return total
end
local function totalAvailable(itemID, includeStorage)
  return inventoryCount(itemID) + worldAmount(itemID, includeStorage)
end
local function objectExists(uid)
  uid = tonumber(uid)
  if uid == nil then
    return false
  end

  for _, obj in pairs(safeObjects()) do
    if tonumber(obj.id) == uid then
      return true
    end
  end

  return false
end
local function punchOvenOnce(statusLabel, delayMs)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  -- Crucial: don't run the 250ms + 600ms stable-position drop routine
  -- between the two normal oven punches. The first punch already left
  -- us on the correct cook tile; the gap should really be 500 ms.
  if not reached(cookX, cookY) and not ensureExactDropPosition(cookX, cookY) then
    return false
  end
  local player = safeLocal()
  if player == nil then
    return false
  end

  setStatus(statusLabel or "OPEN EZ COOK")
  local ok = pcall(function()
    SendPacketRaw(false, {
      type = 3,
      value = 18,
      px = cookX + 1,
      py = cookY,
      x = player.posX,
      y = player.posY,
    })
  end)

  if ok then
    Sleep(math.max(0, delayMs or COOK_OPEN_PUNCH_WAIT_MS))
  end
  -- Return the actual packet-send outcome separately. A disconnect after
  -- sending Punch 1 must NOT cause the same first punch to be repeated.
  return ok and enabled and currentWorld() == workingWorld, ok
end
local COLLECT_ON_TILE_WAIT_MS = 250
local COLLECT_PATH_STALL_MS = 1300
local CHEM_AUTO_COLLECT_PACKET_GAP_MS = 100
local CHEM_AUTO_COLLECT_MAX_PER_VISIT = 12
local function waitCollectPace(ms)
  local remaining = math.max(0, math.floor(tonumber(ms) or 0))
  while remaining > 0 do
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    local step = math.min(100, remaining)
    Sleep(step)
    remaining = remaining - step
  end
  return enabled and currentWorld() == workingWorld
end
local function nearChemicalTile(x, y)
  local px, py = playerTile()
  return px ~= nil and py ~= nil and math.abs(px - x) <= 1 and math.abs(py - y) <= 1
end
local function collectNearbyChemicalPackets(target, itemID, before)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  if not nearChemicalTile(target.tileX, target.tileY) then
    return false
  end
  local px, py = playerTile()
  local candidates = {}
  for _, obj in pairs(safeObjects()) do
    if tonumber(obj.itemid) == tonumber(itemID) then
      local tx, ty = objectTile(obj)
      if
        tx ~= nil
        and ty ~= nil
        and math.abs(tx - px) <= 1
        and math.abs(ty - py) <= 1
        and math.abs(tx - target.tileX) <= 1
        and math.abs(ty - target.tileY) <= 1
      then
        local ox, oy = objectPixelPos(obj)
        if ox ~= nil and oy ~= nil and tonumber(obj.id) ~= nil then
          candidates[#candidates + 1] = {
            uid = tonumber(obj.id),
            x = ox,
            y = oy,
            preferred = tonumber(obj.id) == tonumber(target.uid),
          }
        end
      end
    end
  end
  table.sort(candidates, function(a, b)
    if a.preferred ~= b.preferred then
      return a.preferred
    end
    return a.uid < b.uid
  end)

  local sent = 0
  for _, obj in ipairs(candidates) do
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    if sent >= CHEM_AUTO_COLLECT_MAX_PER_VISIT then
      break
    end
    if inventoryCount(itemID) >= STACK_MAX then
      break
    end
    local ok = pcall(function()
      SendPacketRaw(false, {
        type = 11,
        value = obj.uid,
        x = obj.x,
        y = obj.y,
      })
    end)
    if ok then
      sent = sent + 1
    end
    -- Always pace requests, even if pickup is not immediately acknowledged.
    if not waitCollectPace(CHEM_AUTO_COLLECT_PACKET_GAP_MS) then
      return false
    end
  end
  if inventoryCount(itemID) > before then
    return true
  end
  if sent == 0 then
    return false
  end
  -- Do not confuse a disappearing object with an inventory ACK.
  local waited = 0
  while enabled and currentWorld() == workingWorld and waited < COLLECT_ACK_TIMEOUT_MS do
    if inventoryCount(itemID) > before then
      return true
    end
    Sleep(COLLECT_POLL_MS)
    waited = waited + COLLECT_POLL_MS
  end
  return inventoryCount(itemID) > before
end
local function collectOneObjectChecked(target, itemID, label)
  if target == nil or not enabled then
    return false
  end
  label = tostring(label or itemName(itemID))
  local isOvenObject = target.tileX == cookX + 1 and target.tileY == cookY

  local function confirmedPickup()
    if isOvenObject and pendingCook ~= nil and tonumber(itemID) == tonumber(pendingCook.outputID) then
      pendingCook.outputCollected = true
    end
    Sleep(COOK_COLLECTION_DELAY_MS)
    return true
  end

  if currentWorld() ~= workingWorld or not objectExists(target.uid) then
    return false
  end
  local before = inventoryCount(itemID)
  if before >= STACK_MAX then
    setStatus("INVENTORY FULL: " .. label)
    return false
  end
  if not waitCollectPace(COLLECT_ATTEMPT_GAP_MS) then
    return false
  end
  if inventoryCount(itemID) > before then
    return confirmedPickup()
  end
  if not objectExists(target.uid) then
    return false
  end
  setFly(true)
  local destX, destY = target.tileX, target.tileY
  setStatus("PICKUP EXACT " .. label .. " -> " .. tostring(destX) .. "," .. tostring(destY))

  -- Exact tile only. If FindPath ends adjacent to a blocked pile, direct
  -- pickup can still reach it from the left or right without another path.
  local pathSent = true
  if not reached(destX, destY) then
    pathSent = requestPathPaced(destX, destY)
  end
  if pathSent and not nearChemicalTile(destX, destY) then
    local waited, stationary = 0, 0
    local lastX, lastY = playerTile()
    while enabled and currentWorld() == workingWorld and waited < COLLECT_MOVE_TIMEOUT_MS + COLLECT_ACK_TIMEOUT_MS do
      if inventoryCount(itemID) > before then
        return confirmedPickup()
      end
      if nearChemicalTile(destX, destY) then
        break
      end
      local px, py = playerTile()
      if px == nil or py == nil then
        break
      end
      if px ~= lastX or py ~= lastY then
        stationary = 0
      else
        stationary = stationary + COLLECT_POLL_MS
      end
      if stationary >= COLLECT_PATH_STALL_MS then
        break
      end
      lastX, lastY = px, py
      Sleep(COLLECT_POLL_MS)
      waited = waited + COLLECT_POLL_MS
    end
  end

  if inventoryCount(itemID) > before then
    return confirmedPickup()
  end
  if nearChemicalTile(destX, destY) then
    setStatus("AUTO COLLECT " .. label .. " LEFT + RIGHT")
    if collectNearbyChemicalPackets(target, itemID, before) then
      setStatus("COLLECTED " .. label .. " " .. tostring(inventoryCount(itemID)))
      return confirmedPickup()
    end
  end

  -- Closed EZ Cook may have blocked the exact path; only the existing
  -- guarded, two-check recovery is allowed to reopen it. Never punch here.
  if
    isOvenObject
    and not reached(destX, destY)
    and inventoryCount(itemID) <= before
    and objectExists(target.uid)
    and pendingCook ~= nil
    and not pendingCook.outputCollected
  then
    pendingCook.openPathConfirmed = false
    pendingCook.ovenCollectPathBlocked = true
  end
  setStatus("PICKUP NOT CONFIRMED: " .. label .. " - RESCAN")
  if enabled and currentWorld() == workingWorld then
    waitCollectPace(math.max(600, COLLECT_ATTEMPT_GAP_MS))
  end
  return false
end
local function buildSingleItemTargets(itemID, includeStorage, cookOnly)
  local px, py = playerTile()
  local results = {}

  for _, obj in pairs(safeObjects()) do
    if tonumber(obj.itemid) == tonumber(itemID) then
      local ox, oy = objectPixelPos(obj)

      if ox ~= nil and oy ~= nil then
        local tx = math.floor(ox / 32)
        local ty = math.floor(oy / 32)

        local allowed = true

        if cookOnly then
          allowed = (tx == cookX + 1 and ty == cookY)
        elseif not includeStorage and itemID == ID_M and isStorageArea(tx, ty) then
          allowed = false
        end

        if allowed then
          local distance = 0

          if px ~= nil and py ~= nil then
            distance = math.abs(px - tx) + math.abs(py - ty)
          end

          table.insert(results, {
            uid = tonumber(obj.id),
            itemID = tonumber(itemID),
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

  -- Fuel phase: find stored M piles first, including the tiles used when
  -- storage shifted left because a previous storage drop target was full.
  -- Use each object's exact tile, then pickup nearby left/right with direct Auto Collect.
  table.sort(results, function(a, b)
    if includeStorage and tonumber(itemID) == tonumber(ID_M) and not cookOnly then
      local aStored = isStorageArea(a.tileX, a.tileY)
      local bStored = isStorageArea(b.tileX, b.tileY)
      if aStored ~= bStored then
        return aStored
      end
    end
    return a.distance < b.distance
  end)

  return results
end
local function fillChemicalStack(itemID, includeStorage, label, minNeeded)
  if not enabled then
    return false
  end

  label = tostring(label or itemName(itemID))
  minNeeded = math.min(STACK_MAX, math.max(1, math.floor(tonumber(minNeeded) or STACK_MAX)))

  local current = inventoryCount(itemID)

  if current >= minNeeded then
    setStatus("USE INVENTORY " .. label .. " " .. tostring(current) .. " (need " .. tostring(minNeeded) .. ")")
    return true
  end

  local noProgressPasses = 0

  while enabled and inventoryCount(itemID) < minNeeded do
    if currentWorld() ~= workingWorld then
      return false
    end

    current = inventoryCount(itemID)

    setStatus("SCAN ONLY " .. label .. " " .. tostring(current) .. " (need " .. tostring(minNeeded) .. ")")

    local targets = buildSingleItemTargets(itemID, includeStorage, false)

    if #targets == 0 then
      break
    end

    local beforePass = current
    local confirmedAny = false

    for _, target in ipairs(targets) do
      if not enabled or currentWorld() ~= workingWorld then
        return false
      end

      if inventoryCount(itemID) >= minNeeded then
        break
      end

      if objectExists(target.uid) then
        local pickupLabel = label
        if itemID == ID_M and includeStorage and isStorageArea(target.tileX, target.tileY) then
          pickupLabel = "Stored Mysterious Chemical"
        end
        local ok = collectOneObjectChecked(target, itemID, pickupLabel)

        -- Immediately check THIS SAME chemical again after pickup.
        local checkedNow = inventoryCount(itemID)

        if ok and checkedNow > beforePass then
          confirmedAny = true
        end

        if checkedNow >= minNeeded then
          break
        end
      end
    end

    local afterPass = inventoryCount(itemID)

    if afterPass <= beforePass and not confirmedAny then
      noProgressPasses = noProgressPasses + 1

      if noProgressPasses >= 2 then
        break
      end
    else
      noProgressPasses = 0
    end

    if inventoryCount(itemID) >= minNeeded then
      break
    end
    Sleep(COLLECT_RESCAN_DELAY_MS)
  end

  local finalAmount = inventoryCount(itemID)

  setStatus("CHECKED " .. label .. " " .. tostring(finalAmount) .. " (need " .. tostring(minNeeded) .. ")")

  return finalAmount >= minNeeded
end
local function showIngredientPreflight(kind)
  local specs
  if kind == "M" then
    specs = { { ID_Y, M_Y, "Y" }, { ID_B, M_B, "B" }, { ID_P, M_P, "P" } }
  else
    specs = { { ID_M, FUEL_M, "M" }, { ID_G, FUEL_G, "G" }, { ID_B, FUEL_B, "B" } }
  end
  local parts = {}
  local ready = true
  for _, spec in ipairs(specs) do
    local have = inventoryCount(spec[1])
    parts[#parts + 1] = spec[3] .. tostring(have) .. "/" .. tostring(spec[2])
    if have < spec[2] then
      ready = false
    end
  end
  local message = "BAG " .. kind .. ": " .. table.concat(parts, " ")
  setPrepDebug((ready and "READY " or "MISSING ") .. message)
  return ready
end
local function ensureRecipeIngredient(itemID, minNeeded, includeStorage, label)
  local held = inventoryCount(itemID)
  if held >= minNeeded then
    setStatus("BAG READY " .. label .. " x" .. tostring(held) .. " (need " .. tostring(minNeeded) .. ")")
    return true
  end

  setStatus("COLLECT MISSING " .. label .. " " .. tostring(held) .. "/" .. tostring(minNeeded))
  setPrepDebug("NEED " .. label .. " " .. tostring(held) .. "/" .. tostring(minNeeded))
  local ok = fillChemicalStack(itemID, includeStorage, label, minNeeded)
  local now = inventoryCount(itemID)
  if not ok or now < minNeeded then
    setStatus("WAIT " .. label .. " " .. tostring(now) .. "/" .. tostring(minNeeded))
    return false
  end
  return true
end
local function makeRoomForOvenM()
  if inventoryCount(ID_M) < STACK_MAX then
    return true
  end
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  if dropStorageItem == nil then
    return false
  end

  setStatus("OVEN M FULL - STORE 200 M FIRST")
  local dropped = dropStorageItem(ID_M, "Mysterious Chemical")
  local remaining = inventoryCount(ID_M)
  if not dropped or remaining >= STACK_MAX then
    setStatus("WAIT M STORAGE BEFORE OVEN PICKUP")
    return false
  end

  setStatus("M STORED - RETURN TO OVEN FOR M PICKUP")
  return true
end
local function collectCookItemChecked(itemID, label)
  if not enabled then
    return false
  end

  label = tostring(label or itemName(itemID))

  local noProgressPasses = 0

  while enabled do
    local targets = buildSingleItemTargets(itemID, true, true)

    if #targets == 0 then
      return true
    end

    -- A previous M collection may have filled the backpack to 200 while
    -- further M drops remain on the oven. Store, then collect again.
    if itemID == ID_M and not makeRoomForOvenM() then
      return false
    end
    -- Also free capacity if fuel output somehow filled the backpack.
    -- Do not attempt a pickup while Fuel Pack inventory is 200.
    if itemID == ID_FUEL and inventoryCount(ID_FUEL) >= STACK_MAX then
      if dropStorageItem == nil then
        return false
      end
      setStatus("OVEN FUEL FULL - STORE FIRST")
      if not dropStorageItem(ID_FUEL, "Fuel Pack") or inventoryCount(ID_FUEL) >= STACK_MAX then
        return false
      end
    end

    local beforePass = inventoryCount(itemID)
    local confirmedAny = false

    setStatus("EZ COOK GET " .. label)

    for _, target in ipairs(targets) do
      if not enabled then
        return false
      end

      if objectExists(target.uid) then
        local beforeTarget = inventoryCount(itemID)
        local ok = collectOneObjectChecked(target, itemID, label)
        local afterTarget = inventoryCount(itemID)

        if ok and afterTarget > beforeTarget then
          confirmedAny = true
        end
      end
    end

    local afterPass = inventoryCount(itemID)
    local remaining = buildSingleItemTargets(itemID, true, true)

    if #remaining == 0 then
      return true
    end

    if afterPass <= beforePass and not confirmedAny then
      noProgressPasses = noProgressPasses + 1

      if noProgressPasses >= 3 then
        notify("Could not confirm collecting " .. label .. " from EZ Cook.")

        return false
      end
    else
      noProgressPasses = 0
    end

    Sleep(COLLECT_RESCAN_DELAY_MS)
  end
  return false
end
local ensureEzCookEmpty
local function collectMOutputAndLeftovers()
  setStatus("TAKE M FIRST")

  if not collectCookItemChecked(ID_M, "Mysterious Chemical") then
    return false
  end

  setStatus("TAKE EXTRA Y")
  if not collectCookItemChecked(ID_Y, "Chemical Y") then
    return false
  end

  setStatus("TAKE EXTRA B")
  if not collectCookItemChecked(ID_B, "Chemical B") then
    return false
  end

  setStatus("TAKE EXTRA P")
  if not collectCookItemChecked(ID_P, "Chemical P") then
    return false
  end

  if not ensureEzCookEmpty() then
    return false
  end
  updateCounts()
  return true
end
local function collectFuelOutputAndLeftovers()
  setStatus("TAKE FUEL FIRST")

  if not collectCookItemChecked(ID_FUEL, "Fuel Pack") then
    return false
  end

  setStatus("TAKE EXTRA M")
  if not collectCookItemChecked(ID_M, "Mysterious Chemical") then
    return false
  end

  setStatus("TAKE EXTRA G")
  if not collectCookItemChecked(ID_G, "Chemical G") then
    return false
  end

  setStatus("TAKE EXTRA B")
  if not collectCookItemChecked(ID_B, "Chemical B") then
    return false
  end

  if not ensureEzCookEmpty() then
    return false
  end
  updateCounts()
  return true
end
local function cookTileTargets()
  local valid = {
    [ID_Y] = true,
    [ID_B] = true,
    [ID_P] = true,
    [ID_G] = true,
    [ID_M] = true,
    [ID_FUEL] = true,
  }
  local results = {}
  for _, obj in pairs(safeObjects()) do
    local id = tonumber(obj.itemid)
    local tx, ty = objectTile(obj)
    if id and valid[id] and tx == cookX + 1 and ty == cookY then
      local ox, oy = objectPixelPos(obj)
      if ox and oy then
        table.insert(results, {
          uid = tonumber(obj.id),
          itemID = id,
          pixelX = ox,
          pixelY = oy,
          tileX = tx,
          tileY = ty,
        })
      end
    end
  end
  return results
end
ensureEzCookEmpty = function()
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  local emptyScans = 0
  local passes = 0
  local cleared = false

  setStatus("EZ COOK EMPTY GUARD (X+1)")

  while enabled and currentWorld() == workingWorld and passes < COOK_CLEAR_MAX_PASSES do
    -- Only inspect the real oven tile at (cookX + 1, cookY).
    local targets = cookTileTargets()

    if #targets == 0 then
      emptyScans = emptyScans + 1
      setStatus("EZ COOK EMPTY CHECK " .. tostring(emptyScans) .. "/" .. tostring(COOK_EMPTY_REQUIRED_SCANS))
      if emptyScans >= COOK_EMPTY_REQUIRED_SCANS then
        cleared = true
        break
      end
    else
      emptyScans = 0
      passes = passes + 1
      setStatus("EZ COOK COLLECT " .. tostring(#targets) .. " OBJECT(S)")

      for _, target in ipairs(targets) do
        if not enabled or currentWorld() ~= workingWorld then
          break
        end
        if objectExists(target.uid) then
          if inventoryCount(target.itemID) >= STACK_MAX then
            if target.itemID == ID_M then
              -- Don't leave M stranded at the oven just because
              -- the backpack already holds a full 200 M stack.
              if not makeRoomForOvenM() then
                break
              end
            elseif target.itemID == ID_FUEL and dropStorageItem ~= nil then
              setStatus("OVEN FUEL FULL - STORE FIRST")
              if not dropStorageItem(ID_FUEL, "Fuel Pack") or inventoryCount(ID_FUEL) >= STACK_MAX then
                break
              end
            else
              setStatus("EZ COOK BLOCKED: INVENTORY FULL")
              break
            end
          end

          -- Oven objects: exact tile pickup, no extra punch after output.
          local ok = collectOneObjectChecked(target, target.itemID, itemName(target.itemID))
          if not ok then
            break
          end
        end
      end
    end

    Sleep(COOK_EMPTY_SCAN_DELAY_MS)
  end

  if not enabled or currentWorld() ~= workingWorld then
    return false
  end

  -- Return to the original standing/drop tile BEFORE any new drops or punches.
  if not ensureExactDropPosition(cookX, cookY) then
    setStatus("CANNOT RETURN TO COOK DROP TILE")
    return false
  end

  if not cleared then
    setStatus("EZ COOK NOT EMPTY - NEXT COOK BLOCKED")
    return false
  end

  setStatus("EZ COOK EMPTY VERIFIED")
  return true
end
local function recoverRejectedCookDrop(itemID, label, beforeCount)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  if pendingCook ~= nil or recipeDropProgress == nil then
    return false
  end
  if recipeDropProgress.blocked then
    return false
  end

  -- The server may have accepted the last drop just after our ACK timeout.
  -- Recheck inventory before sending any new action/punch.
  Sleep(FULL_TILE_RETRY_DELAY_MS)
  if inventoryCount(itemID) < beforeCount then
    setStatus("LATE DROP ACK: " .. tostring(label))
    return true
  end

  local used = recipeDropProgress.reopenAttempts or 0
  if used >= MAX_COOK_DROP_REOPEN_ATTEMPTS then
    recipeDropProgress.blocked = true
    setStatus("COOK DROP STILL REJECTED - MANUAL CHECK")
    notify("Cook ingredient still rejected after one recovery punch. Check the oven before restarting.")
    return false
  end

  setStatus("COOK DROP REJECTED - TAP OVEN " .. tostring(used + 1))
  local ok = punchOvenOnce("OPEN OVEN TO RETRY DROP", COOK_OPEN_PUNCH_WAIT_MS)
  if not ok then
    return false
  end
  recipeDropProgress.reopenAttempts = used + 1
  -- Match the requested post-punch cooldown; do not flood packets.
  Sleep(COOK_FIRST_PUNCH_WAIT_MS)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  setStatus("RETRY SAME INGREDIENT: " .. tostring(label))
  return true
end
local SILENT_DROP_POLL_MS = 50
local SILENT_DROP_DIALOG_GRACE_MS = 250
local SILENT_DROP_FALLBACK_MS = 950
local BASIC_DROP_ACK_POLL_MS = 50
local function setDropDebug(message)
  message = tostring(message or "")
  if message ~= dropDebugMessage then
    dropDebugMessage = message
    pcall(function()
      editValue("FUEL_dropdebug", message)
    end)
  end
end
local function sendBasicDrop(itemID, amount)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  local sender = sendPacket or SendPacket
  if type(sender) ~= "function" then
    setDropDebug("ERROR: sendPacket unavailable")
    setStatus("DROP PACKET API UNAVAILABLE")
    return false
  end
  if amount <= 0 then
    setDropDebug("ERROR: no items to drop")
    return false
  end

  -- The EZ Cook still receives the FULL held stack, up to 200.
  local before = inventoryCount(itemID)
  dropDialogPending = true
  dropDialogReady = false
  setDropDebug("SILENT DROP REQUEST item " .. tostring(itemID) .. " x" .. tostring(amount))
  local okRequest, requestResult = pcall(sender, 2, "action|drop\nitemID|" .. tostring(itemID))
  if not okRequest or requestResult == false then
    dropDialogPending = false
    setDropDebug("ERROR: silent drop request failed")
    return false
  end

  -- Give native Fast Drop a chance to finish first. The server may also
  -- send OnDialogRequest; our onVariant intercepts it without displaying it.
  local elapsed = 0
  while enabled and currentWorld() == workingWorld and elapsed < SILENT_DROP_FALLBACK_MS do
    if inventoryCount(itemID) < before then
      setDropDebug("FAST DROP ACK x" .. tostring(amount))
      return true
    end
    if dropDialogReady and elapsed >= SILENT_DROP_DIALOG_GRACE_MS then
      break
    end
    Sleep(SILENT_DROP_POLL_MS)
    elapsed = elapsed + SILENT_DROP_POLL_MS
  end
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  if inventoryCount(itemID) < before then
    setDropDebug("FAST DROP ACK x" .. tostring(amount))
    return true
  end

  -- Fallback is NOT a second drop request: it confirms only the currently
  -- outstanding action|drop. This also works on builds where the launcher
  -- consumes OnDialogRequest before Lua can see it.
  setDropDebug("SILENT CONFIRM item " .. tostring(itemID) .. " x" .. tostring(amount))
  local okConfirm, confirmResult = pcall(
    sender,
    2,
    "action|dialog_return\n"
      .. "dialog_name|drop_item\n"
      .. "itemID|"
      .. tostring(itemID)
      .. "|\n"
      .. "count|"
      .. tostring(amount)
      .. "\n"
  )
  if not okConfirm or confirmResult == false then
    setDropDebug("ERROR: silent confirmation failed")
    return false
  end
  setDropDebug("SILENT DROP SENT x" .. tostring(amount) .. " / waiting ACK")
  return true
end
local function dropAllV105Style(itemID, label, startX, startY, allowShift)
  -- Show where a transaction is going; fuel ingredient drops belong at
  -- Cook X/Y, whereas already-produced Fuel Packs go to Storage X/Y.
  local dropPurpose = allowShift and "STORAGE" or "COOK"
  local currentX = math.floor(tonumber(startX) or 0)
  local currentY = math.floor(tonumber(startY) or 0)
  local failedOnTile = 0
  local shifts = 0
  local itemLabel = tostring(label or itemName(itemID))

  while enabled and currentWorld() == workingWorld do
    local before = inventoryCount(itemID)
    if before <= 0 then
      return true, currentX, currentY
    end

    pcall(function()
      editValue("FUEL_dropdest", dropPurpose .. " @ " .. tostring(currentX) .. "," .. tostring(currentY))
    end)
    -- Move ONLY when we are not at the intended standing/drop coordinate.
    if not reached(currentX, currentY) then
      if not ensureExactDropPosition(currentX, currentY) then
        setStatus("WAIT DROP POSITION " .. tostring(currentX) .. "," .. tostring(currentY))
        return false, currentX, currentY
      end
    end
    if not reached(currentX, currentY) then
      return false, currentX, currentY
    end

    -- Drop the ENTIRE held stack. Do not silently convert to the per-M-Chem
    -- recipe quantities (20/10/5); surplus ingredients are recoverable.
    local fullAmount = math.min(STACK_MAX, before)
    setStatus(dropPurpose .. " DROP " .. itemLabel .. " x" .. tostring(fullAmount))
    setDropDebug(
      dropPurpose
        .. " @"
        .. tostring(currentX)
        .. ","
        .. tostring(currentY)
        .. " DROP "
        .. itemLabel
        .. " x"
        .. tostring(fullAmount)
    )
    local packetOK = sendBasicDrop(itemID, fullAmount)
    if not enabled or currentWorld() ~= workingWorld then
      return false, currentX, currentY
    end

    -- A decrease in actual inventory is the confirmation; the dialog is
    -- not required. Wait long enough for delayed server inventory updates.
    local changed = inventoryCount(itemID) < before
    local waited = 0
    if packetOK then
      while not changed and enabled and currentWorld() == workingWorld and waited < DROP_ACK_TIMEOUT_MS do
        Sleep(BASIC_DROP_ACK_POLL_MS)
        waited = waited + BASIC_DROP_ACK_POLL_MS
        changed = inventoryCount(itemID) < before
      end
    end

    if not enabled or currentWorld() ~= workingWorld then
      return false, currentX, currentY
    end

    -- This drop request has now completed its ACK window. Delayed
    -- server drop dialogs remain suppressed by the onVariant hook while
    -- automation is running; never display a prompt to the user.
    dropDialogPending = false
    dropDialogReady = false

    if changed or inventoryCount(itemID) < before then
      failedOnTile = 0
      local now = inventoryCount(itemID)
      setStatus("DROPPED " .. itemLabel .. " (" .. tostring(before - now) .. ")")
      setDropDebug("SUCCESS " .. itemLabel .. " / inventory " .. tostring(before) .. " -> " .. tostring(now))
      if now <= 0 then
        return true, currentX, currentY
      end
      if COOK_AFTER_DROP_MS > 0 then
        Sleep(COOK_AFTER_DROP_MS)
      end
    else
      -- One failure can mean lag; check again before the second try.
      failedOnTile = failedOnTile + 1
      setStatus("DROP NO ACK " .. tostring(failedOnTile) .. "/2 " .. itemLabel)
      setDropDebug("NO INVENTORY CHANGE " .. itemLabel .. " / retry " .. tostring(failedOnTile))
      Sleep(FULL_TILE_RETRY_DELAY_MS)
      if inventoryCount(itemID) < before then
        failedOnTile = 0
      elseif failedOnTile >= 2 then
        failedOnTile = 0
        if allowShift then
          shifts = shifts + 1
          if shifts > MAX_DROP_POSITION_SHIFTS then
            setStatus("STORAGE FULL - TOO MANY SHIFTS")
            return false, currentX, currentY
          end
          currentX = currentX - 1
          setStatus("FULL TILE - SHIFT LEFT " .. tostring(currentX))
          if not ensureExactDropPosition(currentX, currentY) then
            -- Keep the NEW coordinate pending; do not drop on old tile.
            return false, currentX, currentY
          end
        else
          -- Fixed cook position cannot shift. The existing recipe
          -- progress ensures a drop rejection can open the oven once
          -- and retry ONLY the unfinished ingredient.
          if not recoverRejectedCookDrop(itemID, label, before) then
            return false, currentX, currentY
          end
        end
      end
    end
  end
  return false, currentX, currentY
end
local function dropCookItem(itemID, label)
  local ok = dropAllV105Style(itemID, label, cookX, cookY, false)

  return ok == true
end
dropStorageItem = function(itemID, label)
  local ok, finalX, finalY = dropAllV105Style(itemID, label, currentStorageX, currentStorageY, true)

  if finalX ~= nil and finalY ~= nil then
    currentStorageX = finalX
    currentStorageY = finalY
  end

  return ok == true
end
local function dropRecipeInputs(recipeKind)
  if recipeDropProgress ~= nil and recipeDropProgress.kind ~= recipeKind then
    setStatus("UNFINISHED RECIPE DROP - OTHER PHASE BLOCKED")
    return false
  end
  if recipeDropProgress == nil then
    if recipeKind == "FUEL" then
      if not ensureFuelInventoryEmpty() then
        return false
      end
    end
    -- First prove the backpack has all three inputs. Do not path to Cook
    -- or scan the oven before this is true. The current phase collector is
    -- responsible for picking up missing ingredients.
    if not showIngredientPreflight(recipeKind) then
      setDropDebug("BLOCKED: INGREDIENT MISSING FROM BACKPACK")
      return false
    end

    -- The V23 guard used to rescan, path and collect on EVERY recipe, even
    -- when the oven was already empty. Only run that expensive cleanup if
    -- actual items were seen on the oven tile. This matters when the user
    -- temporarily hand-drops ingredients during debugging.
    setDropDebug("CHECK OVEN TILE ONCE")
    if #cookTileTargets() > 0 then
      setPrepDebug("OVEN HAS ITEMS - COLLECT BEFORE DROPPING")
      if not ensureEzCookEmpty() then
        setDropDebug("BLOCKED: OVEN ITEMS NOT CLEARED")
        return false
      end
      -- The guard may have picked up leftovers or made room in storage.
      -- Do not assume previous bag counts survived this cleanup.
      if not showIngredientPreflight(recipeKind) then
        setDropDebug("BLOCKED: BAG CHANGED AFTER OVEN CLEANUP")
        return false
      end
    else
      setPrepDebug("OVEN EMPTY - READY TO DROP " .. recipeKind)
    end
    setDropDebug("MOVE TO COOK " .. tostring(cookX) .. "," .. tostring(cookY))
    if not moveTo(cookX, cookY) then
      setDropDebug("WAIT: cannot reach COOK " .. tostring(cookX) .. "," .. tostring(cookY))
      return false
    end
    -- Allow the server to settle once after movement, not once per item.
    -- A player already at the cook tile can start without a new FindPath.
    Sleep(200)
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    if recipeKind == "FUEL" then
      -- Inventory-first M collection and zero Fuel output are required
      -- before we commit to the FIRST ingredient of this batch.
      if inventoryCount(ID_M) < FUEL_M then
        setStatus("M PICKUP NOT CONFIRMED - NO FUEL DROP")
        return false
      end
      if inventoryCount(ID_FUEL) ~= 0 then
        setStatus("FUEL STILL IN INVENTORY - NO FUEL DROP")
        return false
      end
    end
    setPrepDebug("BEGIN FULL-STACK DROP " .. recipeKind)
    recipeDropProgress = { kind = recipeKind, index = 1, reopenAttempts = 0, blocked = false }
  end

  if recipeDropProgress.blocked then
    setStatus("RECIPE DROP BLOCKED - MANUAL OVEN CHECK")
    return false
  end
  local inputs
  if recipeKind == "M" then
    inputs = {
      { ID_Y, "Chemical Y" },
      { ID_B, "Chemical B" },
      { ID_P, "Chemical P" },
    }
  else
    inputs = {
      { ID_M, "Mysterious Chemical" },
      { ID_G, "Chemical G" },
      { ID_B, "Chemical B" },
    }
  end

  while
    enabled
    and currentWorld() == workingWorld
    and recipeDropProgress ~= nil
    and recipeDropProgress.index <= #inputs
  do
    local entry = inputs[recipeDropProgress.index]
    setStatus("RECIPE " .. recipeKind .. " DROP " .. tostring(recipeDropProgress.index) .. "/" .. tostring(#inputs))
    local available = inventoryCount(entry[1])
    if available <= 0 then
      setDropDebug("WAIT: inventory empty for " .. entry[2])
      return false
    end
    setDropDebug(
      "INGREDIENT "
        .. tostring(recipeDropProgress.index)
        .. "/3 "
        .. entry[2]
        .. " x"
        .. tostring(math.min(available, STACK_MAX))
    )
    setPrepDebug("DROP " .. recipeKind .. " " .. entry[2] .. " x" .. tostring(math.min(available, STACK_MAX)))
    if not dropCookItem(entry[1], entry[2]) then
      return false
    end
    recipeDropProgress.index = recipeDropProgress.index + 1
    recipeDropProgress.reopenAttempts = 0
    -- Full-stack drops can empty the bag immediately. Without this pause,
    -- all three action|drop packets can be emitted in the SAME millisecond.
    -- Give the server a quiet gap before the next ingredient request.
    if recipeDropProgress.index <= #inputs then
      Sleep(math.max(700, COOK_AFTER_DROP_MS))
    end
  end

  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  -- Three ingredients were acknowledged and removed from inventory.
  recipeDropProgress = nil
  setPrepDebug("ALL THREE INGREDIENTS DROPPED " .. recipeKind)
  return true
end
local function dropMRecipeInputs()
  return dropRecipeInputs("M")
end
local function dropFuelRecipeInputs()
  return dropRecipeInputs("FUEL")
end
local function probeOpenOvenPath(outputID, beforeInventory)
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end

  if inventoryCount(outputID) > (beforeInventory or 0) then
    if pendingCook ~= nil then
      pendingCook.outputCollected = true
    end
    return true
  end
  if reached(cookX + 1, cookY) then
    return true
  end

  setStatus("CHECK OVEN PATH")
  local ok = requestPathPaced(cookX + 1, cookY)
  local pathResult = ok
  if not ok or pathResult == false then
    return false
  end

  local waited = 0
  while enabled and currentWorld() == workingWorld and waited < 1000 do
    if inventoryCount(outputID) > (beforeInventory or 0) then
      if pendingCook ~= nil then
        pendingCook.outputCollected = true
      end
      return true
    end
    if reached(cookX + 1, cookY) then
      return true
    end
    Sleep(COOK_PUNCH_VERIFY_POLL_MS)
    waited = waited + COOK_PUNCH_VERIFY_POLL_MS
  end
  return false
end
local function recoverMissedOpenFromBlockedPath()
  if pendingCook == nil or not enabled or currentWorld() ~= workingWorld then
    return false
  end
  local batch = pendingCook
  if not batch.firstSent or not batch.openSent or batch.outputCollected then
    return false
  end
  if inventoryCount(batch.outputID) > (batch.beforeInventory or 0) then
    batch.outputCollected = true
    return false
  end
  if reached(cookX + 1, cookY) then
    batch.openPathConfirmed = true
    return false
  end

  local used = batch.openRecoveryPunches or 0
  if used >= MAX_COOK_OPEN_PATH_RETRIES then
    if not batch.openRetryExhaustedNotice then
      batch.openRetryExhaustedNotice = true
      notify("Oven path still blocked after opening retries. Pausing this recipe for manual inspection; no recook.")
    end
    setStatus("OVEN PATH BLOCKED - RECOVERY LIMIT")
    Sleep(COOK_OPEN_RECOVERY_COOLDOWN_MS)
    return false
  end

  -- Keep retry attempts paced; do NOT hit again on consecutive worker ticks.
  setStatus("OPEN MISSED - RECOVER OVEN " .. tostring(used + 1))
  local done, sent = punchOvenOnce("RETRY SECOND PUNCH - OPEN EZ COOK", COOK_OPEN_PUNCH_WAIT_MS)
  if sent then
    batch.openRecoveryPunches = used + 1
    batch.pathFailures = 0
    batch.ovenCollectPathBlocked = false
    -- New path must be actually verified; never infer opening from packet send.
    batch.openPathConfirmed = false
    Sleep(COOK_OPEN_RECOVERY_COOLDOWN_MS)
  end
  return done
end
local function punchCookVerified(expectedOutputID, expectedOutputName)
  if pendingCook == nil or pendingCook.outputID ~= expectedOutputID then
    return false
  end
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end

  if not pendingCook.firstSent then
    if not pendingCook.prePunchWaited then
      setStatus("WAIT AFTER THIRD DROP BEFORE COOK")
      Sleep(COOK_BEFORE_PUNCH_MS)
      if not enabled or currentWorld() ~= workingWorld then
        return false
      end
      pendingCook.prePunchWaited = true
    end

    pendingCook.beforeInventory = inventoryCount(expectedOutputID)
    -- The helper waits 500 ms after Punch 1 before returning.
    local completed, sent = punchOvenOnce("FIRST PUNCH - COOK", COOK_BETWEEN_PUNCHES_MS)
    if sent then
      pendingCook.firstSent = true
    end
    if not completed then
      setStatus("COOK SENT - WAIT TO OPEN; NO RECOOK")
      return false
    end
  end

  -- Send the SECOND punch only once. Mark it as sent immediately after the
  -- packet call, even if a disconnect happens before its settle delay ends.
  if not pendingCook.openSent then
    local completed, sent = punchOvenOnce("SECOND PUNCH - OPEN EZ COOK", COOK_OPEN_PUNCH_WAIT_MS)
    if sent then
      pendingCook.openSent = true
    end
    if not completed then
      setStatus("OPEN SENT - WAIT FOR OVEN PATH")
      return false
    end
  end

  return pendingCook.firstSent == true and pendingCook.openSent == true
end
local function finishPendingBatch()
  if pendingCook == nil then
    return true
  end
  local outputID = pendingCook.outputID
  if not punchCookVerified(outputID, pendingCook.label) then
    return false
  end

  if not pendingCook.pickupDelayApplied then
    setStatus("WAIT AFTER SECOND PUNCH BEFORE PICKUP")
    Sleep(COOK_FIRST_PUNCH_WAIT_MS)
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    pendingCook.pickupDelayApplied = true
  end

  -- Path-not-found AFTER the second punch can mean the server ignored it.
  -- Two checks are required, so one lagging FindPath result never causes
  -- an immediate extra punch. Use exactly the same behavior for M and Fuel.
  if not pendingCook.openPathConfirmed then
    if not probeOpenOvenPath(outputID, pendingCook.beforeInventory) then
      pendingCook.pathFailures = (pendingCook.pathFailures or 0) + 1
      setStatus("OVEN PATH BLOCKED - VERIFY " .. tostring(pendingCook.pathFailures))
      if pendingCook.pathFailures >= COOK_PATH_FAILED_CHECKS_BEFORE_REOPEN then
        recoverMissedOpenFromBlockedPath()
      else
        Sleep(COOK_PATH_RETRY_GAP_MS)
      end
      return false
    end
    pendingCook.pathFailures = 0
    pendingCook.ovenCollectPathBlocked = false
    pendingCook.openPathConfirmed = true
  end

  local collected
  if outputID == ID_M then
    collected = collectMOutputAndLeftovers()
  else
    collected = collectFuelOutputAndLeftovers()
  end

  if not collected or not pendingCook.outputCollected then
    -- Missing pickup alone must NOT cause another punch. Only an explicit
    -- oven-path failure from collection resets openPathConfirmed, so the
    -- next worker iteration must verify it before any reopening attempt.
    if pendingCook.ovenCollectPathBlocked and not pendingCook.outputCollected then
      pendingCook.openPathConfirmed = false
      setStatus("OVEN PICKUP PATH BLOCKED - RECHECK OVEN")
    else
      setStatus("EZ COOK PICKUP PENDING - WAIT FOR INVENTORY")
    end
    return false
  end

  pendingCook = nil
  updateCounts()
  setStatus("COOK DONE - REST " .. tostring(BETWEEN_RECIPE_PAUSE_MS) .. "ms")
  if BETWEEN_RECIPE_PAUSE_MS > 0 then
    -- Do not start another recipe or movement while the server settles.
    if not waitCollectPace(BETWEEN_RECIPE_PAUSE_MS) then
      return false
    end
  end
  return true
end
local function batchWorldSupplies(specs)
  local wanted, totals = {}, {}
  for _, spec in ipairs(specs) do
    wanted[spec[1]] = spec[3] -- include-storage flag
    totals[spec[1]] = 0
  end
  for _, obj in pairs(safeObjects()) do
    local id = tonumber(obj.itemid)
    if id ~= nil and wanted[id] ~= nil then
      local tx, ty = objectTile(obj)
      if tx ~= nil and ty ~= nil and (wanted[id] or id ~= ID_M or not isStorageArea(tx, ty)) then
        totals[id] = totals[id] + math.max(1, tonumber(obj.amount) or 1)
      end
    end
  end
  return totals
end
local function batchIngredientGoal(held, ground, required)
  if held >= STACK_MAX then
    return STACK_MAX
  end
  if held + math.max(0, ground or 0) >= STACK_MAX then
    return STACK_MAX
  end
  return required
end
local function prepareThreeIngredients(kind)
  local specs = kind == "M"
      and {
        { ID_Y, M_Y, false, "Chemical Y" },
        { ID_B, M_B, false, "Chemical B" },
        { ID_P, M_P, false, "Chemical P" },
      }
    or {
      { ID_M, FUEL_M, true, "Mysterious Chemical" },
      { ID_G, FUEL_G, false, "Chemical G" },
      { ID_B, FUEL_B, false, "Chemical B" },
    }

  local missing = false
  for _, spec in ipairs(specs) do
    if inventoryCount(spec[1]) < spec[2] then
      missing = true
      break
    end
  end

  -- Reuse the backpack directly between successful batches: no GetObjectList
  -- or FindPath calls when there is enough for another recipe.
  if not missing and batchIngredientsPrimed[kind] then
    return showIngredientPreflight(kind)
  end

  -- G is useful in the later Fuel phase, so when 200 G is already available
  -- during initial M stocking we collect it in the same preparation visit.
  -- It is optional and NEVER blocks M production if absent or unreachable.
  local batchSpecs = {}
  for _, spec in ipairs(specs) do
    batchSpecs[#batchSpecs + 1] = spec
  end
  if kind == "M" and not batchIngredientsPrimed.M then
    batchSpecs[#batchSpecs + 1] = { ID_G, 0, false, "Chemical G (fuel reserve)", true }
  end
  local worldStock = batchWorldSupplies(batchSpecs)

  for _, spec in ipairs(batchSpecs) do
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    local id, minimum, storageAllowed, label = spec[1], spec[2], spec[3], spec[4]
    local optional = spec[5] == true
    local held = inventoryCount(id)
    local available = worldStock[id] or 0
    local target = batchIngredientGoal(held, available, minimum)

    -- Optional G prefetch only makes sense for a full 200-item stack.
    if optional and target < STACK_MAX then
      target = held
    end

    if target > held then
      setPrepDebug(
        "BATCH "
          .. kind
          .. " "
          .. label
          .. " "
          .. tostring(held)
          .. "/"
          .. tostring(target)
          .. " | ground "
          .. tostring(available)
      )
      setStatus("BATCH GET " .. label .. " -> " .. tostring(target))
      -- A failed full-stack pickup is not a failed recipe if we already
      -- have the ingredient minimum. No premature stop or phase switch.
      fillChemicalStack(id, storageAllowed, label, target)
    end

    local now = inventoryCount(id)
    if not optional and now < minimum then
      setPrepDebug("WAIT " .. label .. " " .. tostring(now) .. "/" .. tostring(minimum))
      return false
    end
  end

  batchIngredientsPrimed[kind] = true
  return showIngredientPreflight(kind)
end
local function storeItem(itemID, label)
  local beforeStorage = inventoryCount(itemID)
  if beforeStorage < 1 then
    return true
  end

  -- Keep existing inventory-confirmed storage and left-shift behavior.
  local stored = dropStorageItem(itemID, label)
  if not stored then
    return false
  end

  -- A completed Fuel Pack storage trip previously flowed straight into
  -- canMakeFuel()/ensureRecipeIngredient(), which could issue a new world
  -- FindPath immediately. Pause ONCE after confirmation and before scanning.
  -- Never apply this pause for ingredient drops at EZ Cook or M storage.
  if tonumber(itemID) == tonumber(ID_FUEL) and inventoryCount(ID_FUEL) == 0 then
    local pauseMs = FUEL_AFTER_STORAGE_PAUSE_MS
    setStatus("FUEL STORED - WAIT " .. tostring(pauseMs) .. "ms")
    setPrepDebug("FUEL STORAGE COMPLETE - PAUSE BEFORE NEXT INGREDIENT")
    if pauseMs > 0 and not waitCollectPace(pauseMs) then
      return false
    end
    if not enabled or currentWorld() ~= workingWorld then
      return false
    end
    setStatus("FUEL STORAGE SETTLED - CHECK INGREDIENTS")
  end
  return true
end
ensureFuelInventoryEmpty = function()
  if not enabled or currentWorld() ~= workingWorld then
    return false
  end
  local amount = inventoryCount(ID_FUEL)
  if amount == 0 then
    return true
  end

  setStatus("STORE " .. tostring(amount) .. " FUEL BEFORE NEXT COOK")
  if not storeItem(ID_FUEL, "Fuel Pack") then
    setStatus("FUEL STORAGE FAILED - NO NEW RECIPE")
    return false
  end

  -- Allow for inventory updates under lag, but NEVER start the next
  -- recipe unless the authoritative inventory has reached exactly zero.
  local waited = 0
  while enabled and currentWorld() == workingWorld and waited <= DROP_ACK_TIMEOUT_MS do
    if inventoryCount(ID_FUEL) == 0 then
      updateCounts()
      setStatus("FUEL INV 0 - READY FOR RECIPE")
      return true
    end
    Sleep(100)
    waited = waited + 100
  end
  setStatus("FUEL NOT ZERO - NO NEW RECIPE")
  return false
end
local function storeMIfFull()
  if inventoryCount(ID_M) >= STACK_MAX then
    setStatus("STORE M CHEM")
    return storeItem(ID_M, "Mysterious Chemical")
  end
  return true
end
local function storeFuelIfFull()
  if inventoryCount(ID_FUEL) >= STACK_MAX then
    setStatus("STORE FUEL")
    return storeItem(ID_FUEL, "Fuel Pack")
  end
  return true
end
local function hasRecipeSupply(itemID, required, includeStorage)
  local held = inventoryCount(itemID)
  -- Backpack alone is enough: no world-object scans or movement necessary.
  if held >= required then
    return true
  end
  return held + worldAmount(itemID, includeStorage) >= required
end
local function canMakeM()
  return hasRecipeSupply(ID_Y, M_Y, false) and hasRecipeSupply(ID_B, M_B, false) and hasRecipeSupply(ID_P, M_P, false)
end
local function canMakeFuel()
  return hasRecipeSupply(ID_M, FUEL_M, true)
    and hasRecipeSupply(ID_G, FUEL_G, false)
    and hasRecipeSupply(ID_B, FUEL_B, false)
end
local function scanMForCompletion()
  if not enabled or currentWorld() ~= workingWorld then
    return nil, nil
  end
  local fn = GetObjectList or getObjectList
  if type(fn) ~= "function" then
    return nil, nil
  end
  local ok, objects = pcall(fn)
  if not ok or type(objects) ~= "table" then
    return nil, nil
  end

  local worldM = 0
  for _, obj in pairs(objects) do
    if obj and tonumber(obj.itemid) == tonumber(ID_M) then
      -- Count an object as present even if its amount has not loaded yet.
      worldM = worldM + math.max(1, tonumber(obj.amount) or 1)
    end
  end
  return inventoryCount(ID_M), worldM
end
local function stopScript(reason)
  enabled = false
  setFastDrop(false)
  pcall(function()
    editValue("FUEL_fastdrop", "OFF")
  end)
  setFly(false)
  dropDialogPending = false
  dropDialogReady = false

  local fn = editToggle or EditToggle
  if fn ~= nil then
    pcall(fn, "FUEL_enable", false)
  end

  setPhase("STOPPED")
  setStatus("STOPPED")
  updateCounts()

  if reason ~= nil and reason ~= "" then
    notify(reason)
  end
end
function onVariant(var, pkt)
  if var ~= nil and var.v1 == "OnDialogRequest" and type(var.v2) == "string" then
    if enabled and var.v2:find("drop_item", 1, true) then
      -- Suppress even a late OnDialogRequest that arrived after the
      -- previous inventory ACK, so no visible dropping window appears.
      if dropDialogPending then
        dropDialogReady = true
      end
      return true
    end
  end

  return false
end
local licenseKey = savedLicense
local licenseCheckRunning = false
local licenseGeneration = 0
local startPending = false
local programmaticLicenseKey = false
local resettingStart = false
local function setLicenseStatus(value)
  local licenseLastResult = tostring(value or "")
  pcall(function()
    editValue("FUEL_licensestatus", licenseLastResult)
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

  -- Same identity logic used by Auto Collect -> Drop:
  -- prefer Growlauncher's Discord ID, then fall back to the local player name.
  if type(getDiscordID) == "function" then
    local ok, result = pcall(getDiscordID)
    if ok and result ~= nil then
      id = tostring(result)
    end
  elseif getDiscordID ~= nil then
    id = tostring(getDiscordID)
  end

  id = tostring(id or ""):gsub("^%s+", ""):gsub("%s+$", "")

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
local function verifyLicense(silent, generation)
  if licenseCheckRunning then
    return false
  end

  licenseCheckRunning = true

  local key = normalizeLicenseKey(licenseKey)
  licenseKey = key

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
      notify("Could not read a client ID. Enter the game first and try again.")
    end

    return false
  end

  setLicenseStatus("CHECKING...")

  local url = LICENSE_URL
    .. "?key="
    .. urlEncode(key)
    .. "&id="
    .. urlEncode(clientId)
    .. "&product="
    .. urlEncode(LICENSE_PRODUCT)

  local okFetch, response, fetchError = pcall(fetch, url)

  if not okFetch then
    setLicenseStatus("SERVER ERROR")
    licenseCheckRunning = false

    if not silent then
      notify("License server request failed.")
    end

    return false
  end

  if generation ~= licenseGeneration then
    licenseCheckRunning = false
    return false
  end

  response = tostring(response or "")
  response = response:gsub("^%s+", ""):gsub("%s+$", "")

  -- Accept the success token even when Google HtmlService wraps it in HTML.
  if response:find("OK|PERMANENT", 1, true) then
    setLicenseStatus("VERIFIED - PERMANENT")

    -- Save only a key that the Google server actually accepted.
    local saved = saveLicensePreference(key)
    if saved then
      savedLicense = key
    end

    licenseCheckRunning = false

    if not silent then
      notify(saved and "License verified and saved." or "License verified. Could not save the key.")
    end

    return true
  end

  local readable = response

  -- Never show the raw fetch error/URL on screen. Some Growlauncher builds
  -- return the full encoded request URL as the second fetch() result, which
  -- can create a huge overlay and expose the user's key/client ID.
  local shortMessage = "LICENSE CHECK FAILED"

  if readable:find("DENY|DISABLED", 1, true) then
    setLicenseStatus("DISABLED")
    shortMessage = "License disabled."
  elseif readable:find("DENY|WRONG_PRODUCT", 1, true) then
    setLicenseStatus("WRONG PRODUCT")
    shortMessage = "This license is for another script."
  elseif readable:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
    setLicenseStatus("BOUND TO OTHER USER")
    shortMessage = "License is bound to another user."
  elseif readable:find("DENY|INVALID_KEY", 1, true) then
    setLicenseStatus("INVALID KEY")
    shortMessage = "Invalid license key."
  elseif readable:find("DENY|BAD_KEY_FORMAT", 1, true) then
    setLicenseStatus("BAD KEY FORMAT")
    shortMessage = "License key format is invalid."
  elseif readable:find("DENY|NO_ID", 1, true) then
    setLicenseStatus("NO CLIENT ID")
    shortMessage = "Client ID is unavailable."
  elseif readable:find("DENY|", 1, true) then
    setLicenseStatus("DENIED")
    shortMessage = "License denied by server."
  elseif readable == "" then
    setLicenseStatus("NO RESPONSE")
    shortMessage = "License server gave no response."
  else
    setLicenseStatus("CHECK FAILED")
    shortMessage = "License check failed."
  end

  licenseCheckRunning = false

  if not silent then
    notify(shortMessage)
  end

  return false
end
local function handleValue(valueType, name, value)
  if name == "FUEL_prepstatus" then
    if tostring(value or "") ~= preparationMessage then
      pcall(function()
        editValue("FUEL_prepstatus", preparationMessage)
      end)
    end
    return
  end
  if name == "FUEL_dropdebug" then
    if tostring(value or "") ~= dropDebugMessage then
      pcall(function()
        editValue("FUEL_dropdebug", dropDebugMessage)
      end)
    end
    return
  end
  if name == "FUEL_enable" then
    enabled = (value == true)

    if enabled then
      if currentWorld() == "" or currentWorld() == "EXIT" then
        stopScript("Enter your Science Station world first.")
        return
      end

      if cookX == 0 and cookY == 0 then
        stopScript("Set Cook Position first.")
        return
      end

      if storageX == 0 and storageY == 0 then
        stopScript("Set Storage Position first.")
        return
      end

      if not resolveItemIDs() then
        stopScript("Could not resolve one or more recipe item IDs.")
        return
      end

      workingWorld = currentWorld()
      pendingCook = nil -- runtime only; never resume an old batch across script relaunch
      missingMSupplyScans = 0
      missingFuelSupplyScans = 0
      recipeDropProgress = nil -- do not save mid-batch progress across script relaunch
      batchIngredientsPrimed.M = false
      batchIngredientsPrimed.FUEL = false

      -- Every new run starts storage from the user's configured position.
      currentStorageX = storageX
      currentStorageY = storageY

      setFly(true)
      setLauncherToggle("Enable AutoCollect", false)
      setLauncherToggle("Autocollect", false)
      -- Restore the old built-in Fast Drop; the silent packet fallback
      -- only runs when native Fast Drop did not change inventory.
      setFastDrop(true)
      editValue("FUEL_fastdrop", "ON - SILENT")
      setPhase("M CHEM")
      setStatus("STARTING - WAIT FOR WORLD / PLAYER")
      updateCounts()

      notify("Fuel Pack V34: batch 200 ingredients when available; exact-tile pickup and M verification.")
    else
      setFastDrop(false)
      editValue("FUEL_fastdrop", "OFF")
      setFly(false)
      dropDialogPending = false
      dropDialogReady = false
      setPhase("STOPPED")
      setStatus("STOPPED")
      notify("Fuel Pack Maker stopped.")
    end

    return
  end

  local delayFields = {
    FUEL_firstpunchdelay = function(n)
      COOK_FIRST_PUNCH_WAIT_MS = n
    end,
    FUEL_prepunchdelay = function(n)
      COOK_BEFORE_PUNCH_MS = n
    end,
    FUEL_openpunchdelay = function(n)
      COOK_OPEN_PUNCH_WAIT_MS = n
    end,
    FUEL_dropdelay = function(n)
      COOK_AFTER_DROP_MS = n
    end,
    FUEL_collectdelay = function(n)
      COOK_COLLECTION_DELAY_MS = n
    end,
    FUEL_pickupgap = function(n)
      COLLECT_ATTEMPT_GAP_MS = math.max(350, n)
    end,
    FUEL_storepause = function(n)
      FUEL_AFTER_STORAGE_PAUSE_MS = math.min(10000, n)
    end,
    FUEL_pathpace = function(n)
      PATH_REQUEST_PAUSE_MS = math.max(500, n)
    end,
    FUEL_recipepause = function(n)
      BETWEEN_RECIPE_PAUSE_MS = math.max(500, n)
    end,
    FUEL_verifydelay = function(n)
      COOK_EMPTY_SCAN_DELAY_MS = n
    end,
  }
  if delayFields[name] then
    local n = tonumber(value)
    if n ~= nil then
      n = math.max(0, math.min(10000, math.floor(n)))
      delayFields[name](n)
      if name == "FUEL_pickupgap" then
        pcall(function()
          editValue("FUEL_pickupgap", tostring(COLLECT_ATTEMPT_GAP_MS))
        end)
      elseif name == "FUEL_pathpace" then
        pcall(function()
          editValue("FUEL_pathpace", tostring(PATH_REQUEST_PAUSE_MS))
        end)
      elseif name == "FUEL_recipepause" then
        pcall(function()
          editValue("FUEL_recipepause", tostring(BETWEEN_RECIPE_PAUSE_MS))
        end)
      end
      saveSettings()
    end
    return
  end

  if name == "FUEL_cookx" then
    local n = tonumber(value)
    if n ~= nil then
      cookX = math.floor(n)
      saveSettings()
    end
    return
  end

  if name == "FUEL_cooky" then
    local n = tonumber(value)
    if n ~= nil then
      cookY = math.floor(n)
      saveSettings()
    end
    return
  end

  if name == "FUEL_storagex" then
    local n = tonumber(value)
    if n ~= nil then
      storageX = math.floor(n)
      currentStorageX = storageX
      saveSettings()
    end
    return
  end

  if name == "FUEL_storagey" then
    local n = tonumber(value)
    if n ~= nil then
      storageY = math.floor(n)
      currentStorageY = storageY
      saveSettings()
    end
    return
  end

  if name == "FUEL_setcook" then
    local x, y = playerTile()

    if x == nil or y == nil then
      notify("Player position unavailable.")
      return
    end

    cookX, cookY = x, y
    saveSettings()

    editValue("FUEL_cookx", tostring(cookX))
    editValue("FUEL_cooky", tostring(cookY))

    notify(
      "Cook Position = ("
        .. tostring(cookX)
        .. ", "
        .. tostring(cookY)
        .. "), EZ Cook at ("
        .. tostring(cookX + 1)
        .. ", "
        .. tostring(cookY)
        .. ")."
    )

    return
  end

  if name == "FUEL_setstorage" then
    local x, y = playerTile()

    if x == nil or y == nil then
      notify("Player position unavailable.")
      return
    end

    storageX, storageY = x, y
    currentStorageX, currentStorageY = storageX, storageY
    saveSettings()

    editValue("FUEL_storagex", tostring(storageX))
    editValue("FUEL_storagey", tostring(storageY))

    notify("Storage Position = (" .. tostring(storageX) .. ", " .. tostring(storageY) .. ").")

    return
  end
end
local function cancelLicenseStart()
  licenseGeneration = licenseGeneration + 1
  if startPending then
    startPending = false
    resettingStart = true
    pcall(editToggle or EditToggle, "FUEL_enable", false)
    resettingStart = false
    setStatus("STOPPED")
  end
end
function onValue(valueType, name, value)
  if name == "FUEL_licensekey" then
    if programmaticLicenseKey then
      return
    end
    local key = normalizeLicenseKey(value)
    if key ~= licenseKey then
      cancelLicenseStart()
      licenseKey = key
      setLicenseStatus("NOT VERIFIED")
    end
    return
  end

  if name == "FUEL_clearlicense" then
    cancelLicenseStart()
    licenseKey, savedLicense = "", ""
    local cleared = clearLicensePreference()
    programmaticLicenseKey = true
    pcall(editValue, "FUEL_licensekey", "")
    programmaticLicenseKey = false
    setLicenseStatus(cleared and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
    return
  end

  if name == "FUEL_verifylicense" then
    local generation = licenseGeneration
    runThread(function()
      if generation == licenseGeneration then
        verifyLicense(false, generation)
      end
    end)
    return
  end

  if name ~= "FUEL_enable" then
    return handleValue(valueType, name, value)
  end
  if resettingStart then
    return
  end

  if value ~= true then
    cancelLicenseStart()
    return handleValue(valueType, name, value)
  end
  if enabled or startPending then
    return
  end

  licenseGeneration = licenseGeneration + 1
  local generation = licenseGeneration
  startPending = true
  setStatus("CHECKING LICENSE BEFORE START")
  runThread(function()
    local waited = 0
    while generation == licenseGeneration and licenseCheckRunning and waited < 30000 do
      Sleep(100)
      waited = waited + 100
    end
    if generation ~= licenseGeneration then
      return
    end
    local authorized = verifyLicense(false, generation)
    if generation ~= licenseGeneration then
      return
    end
    if not authorized then
      cancelLicenseStart()
      setStatus("LICENSE CHECK FAILED - PRESS START TO RETRY")
      return
    end
    startPending = false
    handleValue(valueType, name, true)
  end)
end
applyHook()
runThread(function()
  setFastDrop(false)
  setFly(false)
  setPhase("STOPPED")
  setStatus("STOPPED")
  updateCounts()

  while true do
    if not enabled then
      Sleep(200)
    elseif currentWorld() ~= workingWorld then
      setStatus("WAIT ORIGINAL WORLD")
      setFly(false)

      while enabled and currentWorld() ~= workingWorld do
        Sleep(500)
      end

      if enabled then
        Sleep(600)
        setFly(true)
        setFastDrop(true)
        pcall(function()
          editValue("FUEL_fastdrop", "ON - SILENT")
        end)
      end
    else
      updateCounts()

      -- =====================================================
      -- PHASE 1: MAX M FIRST
      -- =====================================================
      if recipeDropProgress ~= nil then
        -- Resume ONLY the missing ingredient. Never rescan/collect or
        -- redrop confirmed ingredients while a recipe is partially down.
        if recipeDropProgress.blocked then
          setStatus("COOK DROP BLOCKED - MANUAL CHECK")
          Sleep(500)
        else
          local recipeKind = recipeDropProgress.kind
          local completed = false
          if recipeKind == "M" then
            completed = dropMRecipeInputs()
          else
            completed = dropFuelRecipeInputs()
          end
          if completed then
            local outputID = recipeKind == "M" and ID_M or ID_FUEL
            pendingCook = {
              outputID = outputID,
              label = recipeKind == "M" and "Mysterious Chemical" or "Fuel Pack",
              firstSent = false,
              openSent = false,
              openPathConfirmed = false,
              warned = false,
            }
            finishPendingBatch()
          end
          Sleep(400)
        end
      elseif pendingCook ~= nil then
        -- Finish the previous batch; reopen only on verified blocked path.
        if finishPendingBatch() then
          Sleep(ACTION_COOLDOWN_MS)
        else
          Sleep(500)
        end
      elseif phase == "M CHEM" then
        -- First check the three input stacks in inventory. Only missing
        -- items are searched and collected, one at a time.
        if not storeMIfFull() then
          setStatus("WAIT M STORAGE")
          Sleep(1200)
        elseif prepareThreeIngredients("M") then
          missingMSupplyScans = 0
          if dropMRecipeInputs() then
            -- Mark as pending before any oven punch. A delayed server
            -- response must not repeat already-acknowledged drops.
            pendingCook = {
              outputID = ID_M,
              label = "Mysterious Chemical",
              firstSent = false,
              openSent = false,
              openPathConfirmed = false,
              warned = false,
            }
            if finishPendingBatch() then
              storeMIfFull()
            end
          else
            setStatus("M DROP WAIT / VERIFY INVENTORY")
            Sleep(1200)
          end
        else
          missingMSupplyScans = missingMSupplyScans + 1
          setStatus("M MISSING - WAIT " .. tostring(NO_SUPPLY_WAIT_MS) .. "ms")
          if missingMSupplyScans >= SUPPLY_EMPTY_CONFIRM_SCANS then
            missingMSupplyScans = 0
            setPhase("FUEL")
            setStatus("NEXT RECIPE - FUEL")
          end
          Sleep(NO_SUPPLY_WAIT_MS)
        end
      elseif phase == "FUEL" then
        -- Store completed Fuel Packs first, then check M/G/B in bag.
        -- No more than one missing ingredient search at a time.
        if not ensureFuelInventoryEmpty() then
          setStatus("WAIT FUEL STORAGE")
          Sleep(1200)
        elseif prepareThreeIngredients("FUEL") then
          missingFuelSupplyScans = 0
          if dropFuelRecipeInputs() then
            pendingCook = {
              outputID = ID_FUEL,
              label = "Fuel Pack",
              firstSent = false,
              openSent = false,
              openPathConfirmed = false,
              warned = false,
            }
            if finishPendingBatch() then
              storeFuelIfFull()
            end
          else
            setStatus("FUEL DROP WAIT / VERIFY INVENTORY")
            Sleep(1200)
          end
        else
          missingFuelSupplyScans = missingFuelSupplyScans + 1
          setStatus("FUEL MISSING - WAIT " .. tostring(NO_SUPPLY_WAIT_MS) .. "ms")
          Sleep(NO_SUPPLY_WAIT_MS)
          if missingFuelSupplyScans >= SUPPLY_EMPTY_CONFIRM_SCANS then
            missingFuelSupplyScans = 0
            -- Only now check whether the first recipe can resume.
            -- This check is not run before every cook or pickup.
            if canMakeM() then
              setPhase("M CHEM")
              setStatus("M SUPPLY FOUND - RESUME M")
            elseif canMakeFuel() then
              -- World ingredients exist but one pickup/drop may have
              -- failed; retry FUEL instead of declaring completion.
              setStatus("FUEL MATERIALS IN WORLD - RETRY PICKUP")
            else
              -- Failure to assemble M/G/B is not proof that M has
              -- run out. Inspect backpack and ALL world M objects,
              -- even ones previously dropped in storage.
              local heldM, groundM = scanMForCompletion()
              if heldM == nil then
                setStatus("WAIT WORLD M SCAN - NOT FINISHED")
                setPrepDebug("OBJECT LIST UNAVAILABLE - RETRY")
              elseif heldM > 0 or groundM > 0 then
                local availableG = totalAvailable(ID_G, false)
                local availableB = totalAvailable(ID_B, false)
                setStatus("M REMAINS: BAG " .. tostring(heldM) .. " WORLD " .. tostring(groundM))
                setPrepDebug(
                  "M STILL AVAILABLE: BAG "
                    .. tostring(heldM)
                    .. " WORLD "
                    .. tostring(groundM)
                    .. " | WAIT G "
                    .. tostring(availableG)
                    .. "/"
                    .. tostring(FUEL_G)
                    .. " B "
                    .. tostring(availableB)
                    .. "/"
                    .. tostring(FUEL_B)
                )
                -- Keep Start ON. The next FUEL pass will seek
                -- available M via exact-tile path + nearby pickup.
                -- If G/B is missing, new supply can arrive later.
              else
                -- An empty packet list may be a transient/stale
                -- scan during lag. Verify a second independent
                -- object snapshot before any real auto-stop.
                setStatus("VERIFY NO M - SECOND WORLD SCAN")
                if waitCollectPace(800) then
                  local secondHeld, secondGround = scanMForCompletion()
                  if secondHeld == nil then
                    setStatus("M SCAN UNAVAILABLE - RETRY")
                  elseif secondHeld > 0 or secondGround > 0 then
                    setStatus("LATE M FOUND - RETRY FUEL")
                  elseif canMakeM() or canMakeFuel() then
                    setStatus("LATE RECIPE SUPPLY - RETRY")
                  elseif inventoryCount(ID_FUEL) > 0 and not storeItem(ID_FUEL, "Fuel Pack") then
                    setStatus("WAIT FINAL FUEL STORAGE")
                  else
                    stopScript("Finished. No M Chemical or complete recipe remains.")
                  end
                end
              end
            end
          end
        end
      else
        setPhase("M CHEM")
      end

      Sleep(350)
    end
  end
end)
