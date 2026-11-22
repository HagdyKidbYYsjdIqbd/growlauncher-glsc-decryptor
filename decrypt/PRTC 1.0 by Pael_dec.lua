local SCRIPT_NAME = "PRTC 1.0"
local SCRIPT_AUTHOR = "Pael Imup"
local SPLASH_MESSAGE = "Pael Realtime Tile Coordinate\n\nThank you for using my script\naylofyu <3\n\n- pael"
local COLOR_LIST = {
  { code = "0", name = "Default" },
  { code = "1", name = "Light cyan" },
  { code = "2", name = "Green" },
  { code = "3", name = "Light blue" },
  { code = "4", name = "Crazy red" },
  { code = "5", name = "Pinky purple" },
  { code = "6", name = "Brown" },
  { code = "7", name = "Light gray" },
  { code = "8", name = "Crazy orange" },
  { code = "9", name = "Yellow" },
  { code = "!", name = "Bright cyan" },
  { code = "@", name = "Bright red/pink" },
  { code = "#", name = "Bright purple" },
  { code = "$", name = "Pale yellow" },
  { code = "^", name = "Light green" },
  { code = "&", name = "Very pale pink" },
  { code = "w", name = "White" },
  { code = "o", name = "Dreamsicle" },
  { code = "p", name = "Pink" },
  { code = "b", name = "Black" },
  { code = "q", name = "Dark blue" },
  { code = "e", name = "Medium blue" },
  { code = "r", name = "Pale green" },
  { code = "t", name = "Medium green" },
  { code = "a", name = "Dark grey" },
  { code = "s", name = "Med grey" },
  { code = "c", name = "Vibrant cyan" },
  { code = "ì", name = "Bright yellow" },
}
local loadTime = getTime()
local showImGui = false
local isFeatureEnabled = false
local colorCode = "2"
local forceUpdate = false
local cachedRealName = nil
local cachedTileX = -1
local cachedTileY = -1
local cachedColor = ""
local cachedText = ""
local function getTrueName()
  local me = getLocal()
  if not me then
    return "Player"
  end

  -- Attempt to fetch from server-side player list
  local ok, plist = pcall(getPlayerList)
  if ok and plist then
    for _, plr in pairs(plist) do
      if plr.netID == me.netID then
        local pName = plr.name
        if type(pName) == "string" then
          pName = pName:gsub("`%w", ""):gsub("`%W", "")
          if not pName:match("^%(%d+, %d+%)$") and pName ~= "" then
            return pName
          end
        end
      end
    end
  end

  -- Fallback to local memory if server list fails
  if type(me.name) == "string" then
    local pName = me.name:gsub("`%w", ""):gsub("`%W", "")
    if not pName:match("^%(%d+, %d+%)$") and pName ~= "" and pName ~= "Player" then
      return pName
    end
  end

  return "Player"
end
local function updateNameInUI(text)
  pcall(function()
    editValue("config_name_visual", text)
    editValue("name_config_active", false)
    editValue("name_config_active", true)
  end)
end
local function onDrawImGui(dt)
  local me = getLocal()
  if not me or not me.posX or not me.posY then
    return
  end

  local tileX = math.ceil(me.posX / 32)
  local tileY = math.ceil(me.posY / 32)

  local worldName = "Unknown"
  pcall(function()
    local w = getCurrentWorldName()
    if w then
      worldName = w
    end
  end)

  -- 1. Render ImGui Monitor (if enabled)
  if showImGui then
    ImGui.Begin("Location Monitor")
    ImGui.Text(string.format("Tile: %d, %d", tileX, tileY))
    ImGui.Text(string.format("World: %s", worldName))
    ImGui.Separator()
    ImGui.TextDisabled(string.format("Made with <3 by %s", SCRIPT_AUTHOR))
    ImGui.End()
  end

  if not isFeatureEnabled then
    return
  end

  -- 2. Update Name (Cached to prevent unnecessary UI spam)
  if tileX ~= cachedTileX or tileY ~= cachedTileY or colorCode ~= cachedColor or forceUpdate then
    cachedTileX = tileX
    cachedTileY = tileY
    cachedColor = colorCode
    forceUpdate = false

    cachedText = "`" .. colorCode .. string.format("(%d, %d)", tileX, tileY)
    updateNameInUI(cachedText)
  end

  -- 3. Direct Memory Patch (Ensures color renders correctly)
  me.name = cachedText
  if me.displayName then
    me.displayName = cachedText
  end
end
local function buildJsonUI()
  local colorItems = {}

  -- Dynamically generate color buttons
  for i, color in ipairs(COLOR_LIST) do
    table.insert(
      colorItems,
      string.format(
        [[
        {
            "text": "%s",
            "alias": "loc_col_%d",
            "type": "button"
        }]],
        color.name,
        i
      )
    )
  end
  local colorMenuStr = table.concat(colorItems, ",")

  -- Main UI Structure
  return string.format(
    [[
    {
        "sub_name": "%s",
        "description": "Pael Realtime Tile Coordinate",
        "icon": "TravelExplore",
        "menu": [
            {
                "text": "Name Update (Coordinate)",
                "alias": "loc_toggle_name",
                "default": false,
                "type": "toggle_button"
            },
            {
                "text": "Show ImGui Window",
                "alias": "loc_toggle_imgui",
                "default": false,
                "type": "toggle_button"
            },
            {
                "text": "Color Settings",
                "type": "dialog",
                "menu": [ %s ]
            }
        ]
    }
    ]],
    SCRIPT_NAME,
    colorMenuStr
  )
end
function onValue(vtype, name, val)
  -- Ignore events triggered automatically during the first 3 seconds of loading
  if getTime() - loadTime < 3000 then
    return
  end

  if name == "loc_toggle_name" then
    if val == true then
      -- Feature ON: Safely cache the original name
      cachedRealName = getTrueName()
      isFeatureEnabled = true
      forceUpdate = true
      pcall(sendNotification, "Coordinate: ON")
    else
      -- Feature OFF: Restore original name and disable saving
      isFeatureEnabled = false
      local me = getLocal()

      if me and cachedRealName then
        me.name = cachedRealName
        if me.displayName then
          me.displayName = cachedRealName
        end
      end

      pcall(function()
        editValue("config_name_visual", cachedRealName or "Player")
        editValue("name_config_active", true) -- Force render update
        editValue("name_config_active", false) -- Disable save feature
      end)
      pcall(sendNotification, "Coordinate: OFF (" .. (cachedRealName or "Player") .. ")")
    end
  elseif name == "loc_toggle_imgui" then
    showImGui = (val == true)
  elseif name:sub(1, 8) == "loc_col_" then
    local idx = tonumber(name:sub(9))
    if idx and COLOR_LIST[idx] then
      colorCode = COLOR_LIST[idx].code
      forceUpdate = true
      pcall(sendNotification, "Color: " .. COLOR_LIST[idx].name)
    end
  end
end
addHook(onDrawImGui, "onDrawImGui")
applyHook()
pcall(function()
  addCategory(SCRIPT_NAME, "Settings")
  addIntoModule(buildJsonUI(), SCRIPT_NAME)
end)
pcall(sendDialog, {
  title = SCRIPT_NAME,
  message = SPLASH_MESSAGE,
  confirm = "OK",
})
pcall(sendNotification, SCRIPT_NAME .. " Loaded! (Currently OFF)")
