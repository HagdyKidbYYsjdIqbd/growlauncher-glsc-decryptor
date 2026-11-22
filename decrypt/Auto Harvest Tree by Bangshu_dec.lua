setMinimum("6.1.2")
local c = "Premium Auto Harvest by Bangshu"
do
  local Y =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local t = "HARVEST"
  local H = "HARVEST-1-PAID-001"
  local p = "approval"
  local V = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function g()
    local c, Y = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not c then
      return nil
    end
    if type(Y) == "number" and (math["type"] and math["type"](Y) == "integer") then
      Y = tostring(Y)
    end
    if type(Y) ~= "string" or #Y < 17 or #Y > 20 or not Y:match("^%d+$") then
      return nil
    end
    if Y:match("^0+$") then
      return nil
    end
    return Y
  end
  local function C(c, Y)
    if not Y or type(c) ~= "string" or #c > 512 then
      return false
    end
    local p, g, C = c:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (V .. '"}}%s*$')
    )
    return p == Y and (g == t and C == H)
  end
  local r, m, G = pcall(function()
    local c, Y = pcall(require, "preferences")
    local t = c and (type(Y) == "table" and Y) or Preferences
    if type(t) ~= "table" or type(t["new"]) ~= "function" then
      return nil
    end
    local H = t:new("BangshuPremiumAutoHarvest")
    if H:load() == false then
      return H
    end
    return H, H:get(p, "")
  end)
  if not r then
    m = nil
  end
  if not C(G, g()) then
    local V, r = false, false
    local function G(c)
      pcall(editValue, "AHS_premium_status", c)
      if type(sendNotification) == "function" then
        pcall(sendNotification, c)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], c)
      end
    end
    local function U()
      if V or r then
        return
      end
      local c = g()
      if not c then
        G("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not m then
        G("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      V = true
      G("CHECKING")
      local U = pcall(runThread, function()
        local g = Y
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              c .. ("&product=" .. (t .. ("&format=growlauncher&version=" .. H)))
            )
          )
        local U, O = pcall(fetch, g)
        if U and type(O) == "string" then
          local c = O:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if c and (#c <= 1024 and #c % 2 == 0) then
            O = c:gsub("..", function(c)
              return string["char"](tonumber(c, 16))
            end)
          end
        end
        if not U or type(O) ~= "string" then
          G("DENIED - REQUEST FAILED")
        elseif not C(O, c) then
          if O:match('^%s*{"status":"DENIED",') then
            local c = O:match('"reason"%s*:%s*"([A-Z_]+)"')
            if c == "INVALID_REQUEST" then
              G("DENIED - INVALID REQUEST (CHECK DEPLOYMENT)")
            elseif c == "NO_PERMANENT_ACCESS" then
              G("DENIED - CHECK HARVEST ROW IN PAIDUSERS")
            else
              G("DENIED - NO PREMIUM ACCESS")
            end
          elseif O:match('^%s*{"status":"ERROR",') then
            G("DENIED - APPS SCRIPT SERVER ERROR")
          elseif O:match("^%s*<") then
            if O:find("doGet", 1, true) then
              G("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              G("DENIED - GOOGLE RETURNED HTML")
            end
          elseif O:match("^%s*$") then
            G("DENIED - EMPTY SERVER RESPONSE")
          elseif O:match('^%s*{"status":"APPROVED",') then
            G("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            G("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local Y, t = pcall(function()
            if m:set(p, O) == false then
              return false
            end
            if m:save() == false then
              return false
            end
            if m:load() == false then
              return false
            end
            return C(m:get(p, ""), c)
          end)
          r = Y and t == true
          G(r and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        V = false
      end)
      if not U then
        V = false
        G("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(c, Y)
      if Y == "AHS_premium_verify" then
        U()
      end
    end
    onValue = OnValue
    local O = UserInterface["new"](c, "Agriculture")
    O:addButton("Verify Access", "AHS_premium_verify")
    O:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "AHS_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, c, "Agriculture")
    end
    addIntoModule(O:generateJSON(), c)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "AHS_premium_verify", U)
    end
    return
  end
end
local Y = c
local t, H = 200, 10
local p = 180
local V = {
  ["antiMiss"] = true,
  ["collect"] = false,
  ["sorrow"] = false,
  ["dcs"] = false,
  ["autoFuel"] = false,
  ["dropWorld"] = "",
  ["dropX"] = "",
  ["dropY"] = "",
  ["harvestWorlds"] = "",
  ["fuelWorld"] = "",
  ["returnDoor"] = "",
  ["punchDelay"] = 180,
  ["pathDelay"] = 500,
  ["pickupDelay"] = 50,
}
local function g(c, ...)
  if type(c) ~= "function" then
    return nil
  end
  local Y, t = pcall(c, ...)
  if Y then
    return t
  end
end
local function C(c, ...)
  if type(c) ~= "function" then
    return false
  end
  local Y, t = pcall(c, ...)
  return Y and t ~= false
end
local function r(c)
  return (((tostring(c or "")):upper()):gsub("%s+", ""))
end
local function m(c)
  local Y, t = c:match("^([A-Z0-9]+)|([^|]+)$")
  if not Y and c:match("^[A-Z0-9]+$") then
    Y = c
  end
  if Y and (Y ~= "EXIT" and Y ~= "EXITWORLD") then
    return Y, t
  end
end
local function G(c, Y, t)
  local H = tonumber(c)
  if H and (H >= Y and (H <= t and H % 1 == 0)) then
    return H
  end
end
local U
pcall(function()
  local c = g(require, "preferences") or Preferences
  U = c:new("AutoHarvestSweep")
  U:load()
  for c, Y in pairs(V) do
    local t = U:get(c, tostring(Y))
    if type(Y) == "boolean" then
      V[c] = t == true or t == "true"
    elseif type(Y) == "number" then
      V[c] = G(t, 0, 10000) or Y
    else
      V[c] = tostring(t or Y)
    end
  end
end)
local function O(c)
  pcall(function()
    U:set(c, tostring(V[c]))
    U:save()
  end)
end
local function B()
  local c = UserInterface["new"](Y, "Agriculture")
  c:addLabelApp(Y, "Agriculture")
  c:addToggle("Start / Stop", false, "AHS_start")
  c:addToggle("Anti-Miss", V["antiMiss"], "AHS_antiMiss")
  c:addToggle("Auto Collect Harvest Drops", V["collect"], "AHS_collect")
  local t = (c:addDialog("World Settings", "Harvest worlds in order. Blank uses the current world.", {}))["menu"]
  c:addChildInputString(
    t,
    "Harvest Worlds",
    V["harvestWorlds"],
    "WORLD|DOORID",
    "FARM1, FARM2|DOOR",
    nil,
    "AHS_harvestWorlds"
  )
  c:addChildButton(t, "Add Current World", "AHS_hereHarvestWorld")
  c:addChildButton(t, "Clear List", "AHS_clearHarvestWorlds")
  local H = (c:addDialog("Drop Settings", "Store collected stacks at 180 in this world or another world", {}))["menu"]
  c:addChildInputString(H, "Drop World", V["dropWorld"], "WORLD|DOORID", "WORLD|DOORID", nil, "AHS_dropWorld")
  c:addChildButton(H, "Set Drop World = Current World", "AHS_hereDropWorld")
  c:addChildInputInt(H, "Drop Position X", V["dropX"], "X", "", nil, "AHS_dropX")
  c:addChildInputInt(H, "Drop Position Y", V["dropY"], "Y", "", nil, "AHS_dropY")
  c:addChildButton(H, "Set Drop Position = Current Tile", "AHS_hereDrop")
  c:addToggle("Auto Collect Fuel Packs Below 10", V["autoFuel"], "AHS_autoFuel")
  local p = (c:addDialog("Fuel Pack Settings", "Supply world and harvest return Door ID", {}))["menu"]
  c:addChildInputString(p, "Fuel Pack World", V["fuelWorld"], "WORLD|DOORID", "WORLD|DOORID", nil, "AHS_fuelWorld")
  c:addChildButton(p, "Set Fuel Pack World = Current World", "AHS_hereFuelWorld")
  c:addChildInputString(p, "Harvest Return Door ID (optional)", V["returnDoor"], "Door ID", "", nil, "AHS_returnDoor")
  local g = (c:addDialog("Delay Settings", "Punch, movement and Fuel Pack pickup delays", {}))["menu"]
  c:addChildInputInt(g, "Punch Delay (ms)", tostring(V["punchDelay"]), "ms", "180", nil, "AHS_punchDelay")
  c:addChildInputInt(g, "FindPath Delay (ms)", tostring(V["pathDelay"]), "ms", "500", nil, "AHS_pathDelay")
  c:addChildInputInt(g, "Fuel Pickup Settle Delay (ms)", tostring(V["pickupDelay"]), "ms", "50", nil, "AHS_pickupDelay")
  c:addDisplayList("Status", "STOPPED", "AHS_status")
  c:addDisplayList("Trees Confirmed", "0", "AHS_count")
  c:addToggle("Use Harvester of Sorrows", V["sorrow"], "AHS_sorrow")
  c:addToggle("Use Dreamcatcher Staff", V["dcs"], "AHS_dcs")
  return c:generateJSON()
end
local A, Q, F
local function v(c, Y)
  F = true
  g(editValue, "AHS_" .. c, tostring(Y))
  F = false
end
local function i(c)
  v("status", c)
end
local function E(c)
  g(growtopia and growtopia["notify"], c)
end
local function u(c)
  F = true
  g(editToggle or EditToggle, "AHS_start", c)
  F = false
end
local function n()
  F = true
  local c = editToggle or EditToggle
  local Y = { "antiMiss", "collect", "autoFuel", "sorrow", "dcs" }
  for Y, t in ipairs(Y) do
    V[t] = false
    g(c, "AHS_" .. t, false)
  end
  F = false
  pcall(function()
    for c, Y in ipairs(Y) do
      U:set(Y, "false")
    end
    U:save()
  end)
end
local function J(c)
  return A == c
end
local function W()
  return r(g(GetWorldName or getCurrentWorldName))
end
local function S()
  local c = g(GetLocal or getLocal)
  if c and (tonumber(c["posX"]) and tonumber(c["posY"])) then
    return c, math["floor"](c["posX"] / 32), math["floor"](c["posY"] / 32)
  end
end
local function x(c)
  return J(c) and (c["world"] == W() and S() ~= nil)
end
local function b(c, Y)
  return g(GetTile or getTile or (tile and tile["getTile"]), c, Y)
end
local function e()
  return g(GetTiles or getTiles)
end
local function f()
  local c = g(GetInventory or getInventory)
  if type(c) ~= "table" then
    error("Could not read the backpack.", 0)
  end
  local Y = {}
  for c, t in pairs(c) do
    local H, p = tonumber(t["id"]), tonumber(t["amount"])
    if H and p then
      Y[H] = p
    end
  end
  return Y
end
local function T(c)
  return (f())[c] or 0
end
local function R(c, Y, t)
  for Y = 0, math["floor"](Y / 100), 1 do
    if not J(c) then
      return false
    end
    if t() then
      return true
    end
    Sleep(100)
  end
  return false
end
local function o(c)
  if W() ~= c or not S() then
    return false
  end
  local Y = e()
  return type(Y) == "table" and next(Y) ~= nil
end
local function z(c, Y)
  for t = 1, 200, 1 do
    if not J(c) then
      return false
    end
    if o(Y) then
      Sleep(1000)
      if J(c) and o(Y) then
        return true
      end
    end
    Sleep(100)
  end
  return false
end
local function j(c)
  return C(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (c .. "\ninvitedWorld|0"))
end
local function D(c, Y)
  if not J(c) then
    return false
  end
  if o(Y) then
    return true
  end
  c["doorRoute"] = nil
  if W() == Y and z(c, Y) then
    return true
  end
  if not J(c) then
    return false
  end
  i("WARPING TO " .. Y)
  local t = C(growtopia and growtopia["warpTo"], Y) or j(Y)
  if t and z(c, Y) then
    return true
  end
  if not J(c) then
    return false
  end
  i("RETRYING WARP TO " .. Y)
  Sleep(1500)
  if not J(c) then
    return false
  end
  if o(Y) then
    return z(c, Y)
  end
  return j(Y) and z(c, Y)
end
local function M(c, Y)
  local t, H = m(Y)
  if not t or not D(c, t) then
    return false
  end
  if H and c["doorRoute"] ~= Y then
    for H = 1, 2, 1 do
      if not J(c) then
        return false
      end
      i((H == 1 and "ENTERING " or "RETRYING DOOR ") .. Y)
      if j(Y) then
        Sleep(1400)
        if z(c, t) then
          c["doorRoute"] = Y
          break
        end
      end
      if H == 2 or not J(c) then
        return false
      end
      Sleep(1500)
      if not D(c, t) then
        return false
      end
    end
  end
  c["world"] = t
  return x(c)
end
local function X(c, Y, t)
  local function H()
    local H, p, V = S()
    return x(c) and (p == Y and V == t)
  end
  if H() then
    return true
  end
  for p, V in ipairs({ 2800, 4500 }) do
    if not x(c) then
      return false
    end
    Sleep(c["pathDelay"])
    if not x(c) then
      return false
    end
    C(FindPath or findPath, Y, t)
    if R(c, V, H) then
      return true
    end
  end
  return false
end
local function I(c)
  local Y = findItemID or (growtopia and growtopia["getItemID"])
  local t = tonumber(g(Y, c))
  if not t or t <= 0 then
    error("Could not resolve " .. (c .. " in the item database."), 0)
  end
  return t
end
local function P(c, Y, t, H)
  local p = S()
  if not x(c) or not p["equip"] then
    error("Could not read equipped items.", 0)
  end
  if T(t) == 0 then
    error("You need " .. (H .. " in your backpack."), 0)
  end
  local V = tonumber(p["equip"][Y]) or 0
  c["gear"] = c["gear"] or {}
  if not c["gear"][Y] then
    c["gear"][Y] = { ["original"] = V, ["used"] = t }
  end
  if V == t then
    return
  end
  if not C(SendPacketRaw or sendPacketRaw, false, { ["type"] = 10, ["value"] = t }) then
    error("Could not equip " .. (H .. "."), 0)
  end
  local g = R(c, 4000, function()
    local H = S()
    return x(c) and (H["equip"] and tonumber(H["equip"][Y]) == t)
  end)
  if not g then
    error("Equip " .. (H .. " manually and restart."), 0)
  end
end
local function a(c)
  if not c["gear"] then
    return true
  end
  local Y = true
  for t, H in ipairs({ "hand", "back", "feet" }) do
    local p = c["gear"][H]
    if p and p["original"] ~= p["used"] then
      local c = S()
      if not c or not c["equip"] or not m(W()) then
        return false
      end
      if tonumber(c["equip"][H]) == p["used"] then
        local t = p["original"]
        local V = t ~= 0 and T(t) > 0
        local g = V and t or p["used"]
        local r = V and t or 0
        local m = false
        if T(g) > 0 and C(SendPacketRaw or sendPacketRaw, false, { ["type"] = 10, ["value"] = g }) then
          for Y = 1, 20, 1 do
            c = S()
            if not c or not c["equip"] then
              break
            end
            if (tonumber(c["equip"][H]) or 0) == r then
              m = true
              break
            end
            Sleep(100)
          end
        end
        if not m or (t ~= 0 and not V) then
          Y = false
        end
      end
    end
  end
  return Y
end
local q = {}
local function d(c)
  if not c then
    return false
  end
  local Y = c["extra"] and tonumber(c["extra"]["type"])
  if Y and Y ~= 0 then
    return Y == 4
  end
  local t = tonumber(c["fg"])
  if not t or t <= 0 then
    return false
  end
  if q[t] == nil then
    local c = g(getItemInfoByID or GetItemInfo, t)
    if not c then
      return false
    end
    q[t] = tonumber(c["type"]) == 19
  end
  return q[t]
end
local function s(c)
  return d(c) and c["readyharvest"] == true
end
local function l(c, Y, t)
  local H = b(Y, t)
  return H and (not H["collidable"] and (not c["sorrow"] or not d(H)))
end
local function L(c, Y)
  if c["y"] ~= Y["y"] then
    return c["y"] < Y["y"]
  end
  if c["x"] ~= Y["x"] then
    return c["x"] < Y["x"]
  end
  return (c["uid"] or 0) < (Y["uid"] or 0)
end
local function N()
  local c = g(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(c) ~= "table" then
    error("Could not read dropped items.", 0)
  end
  return c
end
local function w()
  local c = N()
  local Y = {}
  for c, t in pairs(c) do
    local H = tonumber(t["posX"] or (t["pos"] and t["pos"]["x"]))
    local p = tonumber(t["posY"] or (t["pos"] and t["pos"]["y"]))
    local V, g = tonumber(t["itemid"]), tonumber(t["id"])
    if H and (p and (V and g)) then
      Y[#Y + 1] =
        { ["x"] = math["floor"](H / 32), ["y"] = math["floor"](p / 32), ["ox"] = H, ["oy"] = p, ["id"] = V, ["uid"] = g }
    end
  end
  table["sort"](Y, L)
  return Y
end
local function y(c, Y)
  return c["collect"]
    and (
      W() == c["dropBase"]
      and (Y["x"] >= (c["dropStandX"] or c["dropX"]) - 2 and (Y["x"] <= c["dropX"] + 2 and Y["y"] == c["dropY"]))
    )
end
function onSendPacketRaw(c)
  local Y = A
  if not Y or not Y["collect"] or not c or tonumber(c["type"]) ~= 11 or W() ~= Y["dropBase"] then
    return false
  end
  local t, H = pcall(w)
  if t then
    for t, H in ipairs(H) do
      if H["uid"] == tonumber(c["value"]) then
        return y(Y, H)
      end
    end
  end
  return false
end
local function Z(c)
  for Y, t in pairs(N()) do
    if tonumber(t["id"]) == c then
      return true
    end
  end
  return false
end
local function k(c, Y, H)
  local p, V, g = S()
  if not x(c) or not V or g ~= Y["y"] or y(c, Y) then
    return false
  end
  if H then
    if V ~= Y["x"] and V ~= Y["x"] - 1 then
      return false
    end
  elseif math["abs"](V - Y["x"]) > 2 then
    return false
  end
  local r = T(Y["id"])
  if r >= t or not Z(Y["uid"]) then
    return false
  end
  if
    not C(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 11, ["value"] = Y["uid"], ["x"] = Y["ox"], ["y"] = Y["oy"] }
    )
  then
    return false
  end
  Sleep(100 + (H and 0 or c["pickupDelay"]))
  return R(c, 1200, function()
    return not x(c) or T(Y["id"]) > r or (H and not Z(Y["uid"]))
  end) and x(c)
end
local function h(c, Y, t)
  if not M(c, c["returnRoute"]) then
    error("Could not return to the harvest world.", 0)
  end
  if not X(c, Y, t) then
    error("Could not return to the working tile.", 0)
  end
end
local function K(c)
  if not x(c) or c["world"] ~= c["dropBase"] then
    return false
  end
  local Y, t, H = S()
  return t == c["dropStandX"] and H == c["dropY"]
end
local function ci(c)
  for Y = 1, 3, 1 do
    if not K(c) then
      return false
    end
    Sleep(100)
  end
  return K(c)
end
local function Yi(c)
  if not x(c) or c["world"] ~= c["dropBase"] then
    return false
  end
  local Y, t = c["dropStandX"], c["dropY"]
  i("VERIFYING DROP TILE " .. (Y .. ("," .. t)))
  if not X(c, Y, t) or not ci(c) then
    return false
  end
  Sleep(c["pathDelay"])
  if not K(c) then
    return false
  end
  if not C(FindPath or findPath, Y, t) then
    if not K(c) then
      return false
    end
  end
  return R(c, 1400, function()
    return ci(c)
  end)
end
function onVariant(c)
  local Y = A
  local t = Y and Y["dropDialog"]
  local H = c and c["v2"]
  if not t or not x(Y) or Y["world"] ~= Y["dropBase"] or c["v1"] ~= "OnDialogRequest" or type(H) ~= "string" then
    return false
  end
  H = H:lower()
  if not H:find("drop_item", 1, true) then
    return false
  end
  local p = tonumber(H:match("embed_data|itemid|(%d+)") or H:match("[\r\n]itemid|(%d+)"))
  if p and p ~= t["id"] then
    return false
  end
  t["open"] = true
  return true
end
local function ti(c, Y, t)
  local H = SendPacket or sendPacket
  if not ci(c) then
    return nil, "MOVED"
  end
  local p = T(Y)
  if p < t then
    return p
  end
  local V = { ["id"] = Y }
  c["dropDialog"] = V
  i("DROP REQUEST " .. (Y .. (" x" .. t)))
  local g = C(H, 2, "action|drop\nitemID|" .. Y)
  if g then
    R(c, 5000, function()
      return not K(c) or V["open"] or T(Y) < t
    end)
  end
  c["dropDialog"] = nil
  if not K(c) then
    return nil, "MOVED"
  end
  p = T(Y)
  if p < t then
    return p
  end
  if not g then
    return nil, "Could not send the drop request for item " .. (Y .. ".")
  end
  if not V["open"] then
    return nil, "Drop dialog did not open for item " .. (Y .. ".")
  end
  if not ci(c) then
    return nil, "MOVED"
  end
  p = T(Y)
  if p < t then
    return p
  end
  i("CONFIRMING DROP " .. (Y .. (" x" .. p)))
  if not C(H, 2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (Y .. ("|\ncount|" .. p))) then
    return nil, "Could not send the drop confirmation for item " .. (Y .. ".")
  end
  R(c, 8000, function()
    return not K(c) or T(Y) < t
  end)
  if not K(c) then
    return nil, "MOVED"
  end
  local r = T(Y)
  if r < t then
    return r
  end
  return nil, "UNCONFIRMED"
end
local function Hi(c, Y, t)
  local H = false
  while t > 0 and J(c) do
    local p, V = ti(c, Y, t)
    if p ~= nil then
      i("DROPPED " .. ((t - p) .. (" OF ITEM " .. Y)))
      t, H = p, false
    elseif V == "MOVED" then
      if H or not Yi(c) then
        error("Could not return to the configured drop tile.", 0)
      end
      H = true
    elseif V == "UNCONFIRMED" then
      i("WAITING FOR DROP ACK " .. Y)
      Sleep(1500)
      if not J(c) then
        return
      end
      p = T(Y)
      if p < t then
        t, H = p, false
      elseif K(c) then
        if c["dropStandX"] <= 0 then
          error("Storage is full. No drop tile remains to the left.", 0)
        end
        c["dropStandX"] = c["dropStandX"] - 1
        i("SHIFTING DROP TILE LEFT TO " .. (c["dropStandX"] .. ("," .. c["dropY"])))
        if not Yi(c) then
          error("Could not reach the next drop tile to the left.", 0)
        end
        H = false
      end
    else
      error(V, 0)
    end
  end
end
local function pi(c)
  if not c["collect"] or not x(c) then
    return false
  end
  local Y = {}
  local t = f()
  for c in pairs(c["harvestItems"]) do
    if (t[c] or 0) >= p then
      Y[#Y + 1] = c
    end
  end
  if #Y == 0 then
    return false
  end
  table["sort"](Y)
  local H, V, g = S()
  c["dropStandX"] = c["dropStandX"] or c["dropX"]
  if not M(c, c["dropWorld"]) or not Yi(c) then
    error("Could not reach the configured drop position.", 0)
  end
  for Y, t in ipairs(Y) do
    if not J(c) then
      return false
    end
    local H = T(t)
    if H >= p then
      Hi(c, t, H)
    end
  end
  if not J(c) then
    return false
  end
  Sleep(300)
  h(c, V, g)
  return true
end
local function Vi(c)
  if not c["autoFuel"] or T(c["fuelID"]) >= H then
    return
  end
  local Y, p, V = S()
  if not M(c, c["fuelWorld"]) then
    error("Could not enter the Fuel Pack world.", 0)
  end
  i("COLLECTING FUEL PACKS")
  for Y, H in ipairs(w()) do
    if not x(c) then
      return
    end
    if T(c["fuelID"]) >= t then
      break
    end
    if H["id"] == c["fuelID"] and (not y(c, H) and X(c, H["x"], H["y"])) then
      k(c, H)
    end
  end
  h(c, p, V)
  if T(c["fuelID"]) < H then
    error("Fuel supply could not bring the backpack up to 10 Fuel Packs.", 0)
  end
end
local function gi(c)
  if not x(c) then
    return false
  end
  Vi(c)
  if not x(c) then
    return false
  end
  if c["dcs"] then
    P(c, "hand", c["dcsID"], "Dreamcatcher Staff")
  end
  if c["sorrow"] then
    P(c, "feet", c["sorrowID"], "Harvester of Sorrows")
    P(c, "back", c["fuelID"], "Fuel Pack")
  end
  return x(c)
end
local function Ci()
  local c = {}
  for Y, t in pairs(N()) do
    local H = tonumber(t["id"])
    if H then
      c[H] = t
    end
  end
  return c
end
local function ri(c, Y, H)
  local p, V, g = S()
  if not x(c) or not V or g ~= Y then
    return
  end
  local r, m = f(), Ci()
  for Y, H in ipairs(H) do
    if not x(c) then
      return
    end
    local p = m[H["uid"]]
    if
      p and (
        tonumber(p["itemid"]) == H["id"] and ((r[H["id"]] or 0) < t and (math["abs"](V - H["x"]) <= 2 and not y(c, H)))
      )
    then
      if
        C(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 11, ["value"] = H["uid"], ["x"] = H["ox"], ["y"] = H["oy"] }
        )
      then
        c["sentHarvestPickup"] = true
      end
    end
  end
end
local function mi(c, Y, t)
  if #t == 0 then
    return
  end
  pi(c)
  for H = 1, #t + 1, 1 do
    if not x(c) then
      return
    end
    ri(c, Y, t)
    if not x(c) then
      return
    end
    local V = f()
    if not pi(c) then
      return
    end
    local g = Ci()
    local C = {}
    for Y, t in ipairs(t) do
      if c["harvestItems"][t["id"]] and ((V[t["id"]] or 0) >= p and g[t["uid"]]) then
        C[#C + 1] = t
      end
    end
    if #C == 0 then
      return
    end
    t = C
  end
end
local function Gi(c, Y, t, H)
  local p, V = {}, {}
  for g, C in ipairs(w()) do
    if C["y"] == Y and (C["x"] >= t and (C["x"] <= H and (not y(c, C) and not V[C["uid"]]))) then
      V[C["uid"]] = true
      p[#p + 1] = C
    end
  end
  return p
end
local function Ui(c, Y, t)
  if not c["collect"] or not x(c) then
    return
  end
  mi(c, t, Gi(c, t, Y - 2, Y + 2))
end
local function Oi(c)
  local Y = b(c["x"], c["y"])
  return s(Y) and tonumber(Y["fg"]) == c["fg"]
end
local function Bi(c)
  local Y = b(c["x"], c["y"])
  local t = Y and tonumber(Y["fg"])
  return t ~= nil and (t ~= c["fg"] or Y["readyharvest"] == false)
end
local function Ai(c, Y)
  return c .. ("," .. Y)
end
local function Qi(c, Y)
  for Y, t in ipairs(Y) do
    if not t["counted"] and Bi(t) then
      t["counted"] = true
      if c["collect"] then
        c["harvestItems"][t["fg"]] = true
        if t["fg"] > 1 and t["fg"] % 2 == 1 then
          c["harvestItems"][t["fg"] - 1] = true
        end
      end
      c["missedStands"][Ai(t["x"], t["y"])] = nil
      c["confirmed"] = c["confirmed"] + 1
    end
  end
end
local function Fi(c, Y)
  if not x(c) then
    return
  end
  R(c, 1600, function()
    if not x(c) then
      return true
    end
    for c, Y in ipairs(Y) do
      if not Bi(Y) then
        return false
      end
    end
    return true
  end)
  if not x(c) then
    return
  end
  Qi(c, Y)
  v("count", c["confirmed"])
end
local function vi(c, Y, t, H)
  for p, V in ipairs(Y) do
    if not x(c) then
      return
    end
    local g, r, m = S()
    if r ~= t or m ~= H or not l(c, t, H) then
      break
    end
    if Oi(V) then
      if
        not C(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 3, ["value"] = 18, ["x"] = g["posX"], ["y"] = g["posY"], ["px"] = V["x"], ["py"] = V["y"] }
        )
      then
        error("Could not send the harvest punch.", 0)
      end
      Sleep(c["punchDelay"])
      if c["antiMiss"] and x(c) then
        Qi(c, Y)
      end
    end
  end
end
local function ii(c, Y, t, H)
  if not gi(c) then
    return
  end
  i("HARVESTING ROW " .. (Y[1]["y"] .. (" FROM " .. (t .. ("," .. H)))))
  vi(c, Y, t, H)
  if not x(c) then
    return
  end
  local p, V, g = S()
  if c["antiMiss"] and (V == t and g == H) then
    local p = {}
    for c, Y in ipairs(Y) do
      if Oi(Y) then
        p[#p + 1] = Y
      end
    end
    if #p > 0 and gi(c) then
      i("ANTI-MISS RETRY ROW " .. Y[1]["y"])
      vi(c, p, t, H)
    end
  end
  Fi(c, Y)
  if x(c) then
    if c["antiMiss"] then
      local p = Ai(t, H)
      for Y, t in ipairs(Y) do
        if Oi(t) then
          local Y = Ai(t["x"], t["y"])
          local H = c["missedStands"][Y] or {}
          H[p] = true
          c["missedStands"][Y] = H
        end
      end
    end
    pi(c)
    Ui(c, t, H)
  end
end
local function Ei(c, Y, t, H, p)
  local V, g = Y[1]["x"], Y[1]["x"]
  for c, Y in ipairs(Y) do
    V, g = math["min"](V, Y["x"]), math["max"](g, Y["x"])
  end
  local C = {}
  local r = math["floor"]((V + g) / 2)
  local function m(t)
    if t < 0 then
      return
    end
    local H = {}
    for p = math["max"](0, V - 2), g + 2, 1 do
      if l(c, p, t) then
        local V, g = {}, 0
        local C = Ai(p, t)
        for Y, t in ipairs(Y) do
          if math["abs"](p - t["x"]) <= 2 then
            V[#V + 1] = t
            local Y = c["missedStands"][Ai(t["x"], t["y"])]
            if not Y or not Y[C] then
              g = g + 1
            end
          end
        end
        if #V > 0 then
          H[#H + 1] = { ["x"] = p, ["y"] = t, ["batch"] = V, ["fresh"] = g, ["centerDistance"] = math["abs"](p - r) }
        end
      end
    end
    table["sort"](H, function(c, Y)
      if c["fresh"] ~= Y["fresh"] then
        return c["fresh"] > Y["fresh"]
      end
      if #c["batch"] ~= #Y["batch"] then
        return #c["batch"] > #Y["batch"]
      end
      if c["centerDistance"] ~= Y["centerDistance"] then
        return c["centerDistance"] < Y["centerDistance"]
      end
      return c["x"] * p < Y["x"] * p
    end)
    for c, Y in ipairs(H) do
      C[#C + 1] = Y
    end
  end
  if c["sorrow"] and not H then
    m(t - 2)
  end
  m(t)
  return C
end
local function ui(c, Y, t, H, p)
  while x(c) do
    local V = {}
    for c, Y in ipairs(Y) do
      if not Y["attempted"] and Oi(Y) then
        V[#V + 1] = Y
      end
    end
    if #V == 0 then
      return
    end
    local g
    for Y, t in ipairs(Ei(c, V, t, H, p)) do
      if not x(c) then
        return
      end
      if X(c, t["x"], t["y"]) then
        for c, Y in ipairs(t["batch"]) do
          Y["attempted"] = true
        end
        ii(c, t["batch"], t["x"], t["y"])
        g = true
        break
      end
    end
    if not g then
      return
    end
  end
end
local function ni()
  local c = e()
  if type(c) ~= "table" or next(c) == nil then
    error("Could not read the harvest world.", 0)
  end
  local Y, t = {}, {}
  for c, H in pairs(c) do
    local p, V, g = tonumber(H["x"]), tonumber(H["y"]), tonumber(H["fg"])
    if p and (V and (g and s(H))) then
      local c = Y[V]
      if not c then
        c = { ["y"] = V, ["targets"] = {} }
        Y[V] = c
        t[#t + 1] = c
      end
      c["targets"][#c["targets"] + 1] = { ["x"] = p, ["y"] = V, ["fg"] = g }
    end
  end
  table["sort"](t, function(c, Y)
    return c["y"] < Y["y"]
  end)
  for c, Y in ipairs(t) do
    table["sort"](Y["targets"], L)
  end
  return t
end
local function Ji(c)
  if c["restoreFly"] then
    return
  end
  local Y = g(getValue or GetValue, 0, "ModFly")
  if Y == true or Y == 1 or Y == "true" or Y == "1" then
    return
  end
  if C(editToggle or EditToggle, "ModFly", true) then
    c["restoreFly"] = true
  end
end
local function Wi(c)
  if c["restoreFly"] and C(editToggle or EditToggle, "ModFly", false) then
    c["restoreFly"] = nil
  end
end
local function Si(c, Y, t, H)
  local p = t
  for Y, t in ipairs(Y) do
    if not x(c) then
      return
    end
    local V = t["y"] == H
    if c["sorrow"] and V then
      Ji(c)
    end
    local g = t["targets"]
    local C, r = p == 1 and 1 or #g, p == 1 and #g or 1
    while x(c) and (r - C) * p >= 0 do
      local Y, H = g[C]["x"], {}
      repeat
        local c = g[C]
        c["attempted"] = nil
        H[#H + 1] = c
        C = C + p
      until (r - C) * p < 0 or math["abs"](g[C]["x"] - Y) > 4
      ui(c, H, t["y"], V, p)
    end
    if c["sorrow"] and V then
      Wi(c)
    end
    p = -p
  end
end
local function xi(c)
  if not c["collect"] or not x(c) then
    return 0
  end
  Ji(c)
  i("FINAL CLEANUP: TOP TO BOTTOM")
  local Y, t = {}, nil
  for H, p in ipairs(w()) do
    if not y(c, p) then
      if not t or t["y"] ~= p["y"] then
        t = { ["y"] = p["y"], ["xs"] = {} }
        Y[#Y + 1] = t
      end
      local c = t["xs"]
      if c[#c] ~= p["x"] then
        c[#c + 1] = p["x"]
      end
    end
  end
  local H = 1
  local p = Y[1] and Y[1]["xs"]
  local V, g = S()
  if p and (g and math["abs"](g - p[#p]) < math["abs"](g - p[1])) then
    H = -1
  end
  for Y, t in ipairs(Y) do
    local p = t["xs"]
    local V, g = H == 1 and 1 or #p, H == 1 and #p or 1
    for Y = V, g, H do
      if not x(c) then
        return 0
      end
      local H, V = p[Y], t["y"]
      if #Gi(c, V, H, H) > 0 then
        for Y, t in ipairs({ H, H - 1 }) do
          if not x(c) then
            return 0
          end
          if t >= 0 and (not y(c, { ["x"] = t, ["y"] = V }) and X(c, t, V)) then
            Ui(c, t, V)
            break
          end
        end
      end
    end
    H = -H
  end
  if not x(c) then
    return 0
  end
  if c["sentHarvestPickup"] then
    Sleep(500)
    c["sentHarvestPickup"] = nil
  end
  if not x(c) then
    return 0
  end
  pi(c)
  if not x(c) then
    return 0
  end
  local C = 0
  for Y, t in ipairs(w()) do
    if not y(c, t) then
      C = C + 1
    end
  end
  Wi(c)
  return C
end
local function bi(c)
  local Y = c["confirmed"]
  c["missedStands"] = {}
  c["harvestItems"] = {}
  local t = ni()
  if c["sorrow"] or c["autoFuel"] then
    c["fuelID"] = I("Fuel Pack")
  end
  if c["sorrow"] then
    c["sorrowID"] = I("Harvester Of Sorrows")
    if T(c["sorrowID"]) == 0 then
      error("You need Harvester of Sorrows in your backpack.", 0)
    end
  end
  if c["dcs"] then
    c["dcsID"] = I("Dreamcatcher Staff")
    if T(c["dcsID"]) == 0 then
      error("You need Dreamcatcher Staff in your backpack.", 0)
    end
  end
  if #t == 0 then
    return "No ready trees found."
  end
  if not gi(c) then
    return
  end
  local H, p = 0, t[1]["y"]
  local V = c["antiMiss"] and 4 or 1
  for Y = 1, V, 1 do
    if Y > 1 then
      i("FINAL READY-TREE SWEEP " .. (Y - 1))
    end
    local g, C = S()
    local r = t[1]["targets"]
    local m = math["abs"](C - r[1]["x"]) <= math["abs"](C - r[#r]["x"]) and 1 or -1
    Si(c, t, m, p)
    if not x(c) then
      return "Harvest interrupted. Check the current world."
    end
    for Y, t in ipairs(t) do
      Qi(c, t["targets"])
    end
    local G = ni()
    if #G == 0 or Y == V then
      H = xi(c)
      if not x(c) then
        return "Harvest interrupted. Check the current world."
      end
      for Y, t in ipairs(t) do
        Qi(c, t["targets"])
      end
      pi(c)
      if not x(c) then
        return "Harvest interrupted. Check the current world."
      end
      G = ni()
    end
    v("count", c["confirmed"])
    t = G
    if #t == 0 then
      break
    end
  end
  if c["collect"] then
    H = xi(c)
  end
  if not x(c) then
    return "Harvest interrupted. Check the current world."
  end
  local g = 0
  for c, Y in ipairs(t) do
    g = g + #Y["targets"]
  end
  local C = "Confirmed " .. ((c["confirmed"] - Y) .. " trees.")
  if g > 0 then
    C = C .. (" " .. (g .. (" ready tree(s) remain" .. (c["antiMiss"] and " after the retry limit." or "."))))
  end
  if H > 0 then
    C = C .. (" " .. (H .. " drop stack(s) remain outside storage."))
  end
  return C
end
local function ei()
  return not m(W()) or S() == nil
end
local function fi(c)
  c["doorRoute"] = nil
  while J(c) do
    i("RECONNECTING TO " .. c["returnRoute"])
    Sleep(2500)
    if J(c) and M(c, c["returnRoute"]) then
      return true
    end
  end
  return false
end
local function Ti(c, Y)
  local t = #Y == 0
  if t then
    Y = { c["world"] }
  end
  local H = {}
  for p, V in ipairs(Y) do
    if not J(c) then
      return
    end
    local g, C = m(V)
    c["returnRoute"] = C and V or (c["returnDoor"] == "" and g or g .. ("|" .. c["returnDoor"]))
    c["sentHarvestPickup"] = nil
    if not t and not M(c, V) then
      if not J(c) then
        return
      end
      if not ei() then
        error("Could not enter harvest world " .. (V .. "."), 0)
      end
      if not fi(c) then
        return
      end
    end
    local r = c["confirmed"]
    while J(c) do
      i("HARVEST WORLD " .. (p .. ("/" .. (#Y .. (" " .. g)))))
      local t, V = pcall(bi, c)
      if not J(c) then
        return
      end
      if ei() then
        if not fi(c) then
          return
        end
      else
        if not t then
          error(V, 0)
        end
        if not x(c) or not V then
          return V or "Harvest interrupted in " .. (g .. ".")
        end
        local Y = c["confirmed"] - r
        V = V:gsub("^Confirmed %d+ trees%.", "Confirmed " .. (Y .. " trees."))
        H[#H + 1] = g .. (" " .. V)
        break
      end
    end
  end
  return table["concat"](H, " ")
end
local function Ri()
  local c = W()
  if not m(c) or not S() then
    return "Enter the harvest world first."
  end
  local Y = { ["world"] = c, ["confirmed"] = 0 }
  for c, t in pairs(V) do
    Y[c] = t
  end
  if Y["returnDoor"]:find("|", 1, true) then
    return "Set a valid harvest return Door ID."
  end
  local t, H = {}, {}
  for c in Y["harvestWorlds"]:gmatch("[^,%s;]+") do
    c = r(c)
    if not m(c) then
      return "Invalid harvest world route " .. (c .. ".")
    end
    if not H[c] then
      t[#t + 1], H[c] = c, true
    end
  end
  Y["returnRoute"] = Y["returnDoor"] == "" and c or c .. ("|" .. Y["returnDoor"])
  Y["dropX"], Y["dropY"] = G(Y["dropX"], 0, 999), G(Y["dropY"], 0, 999)
  Y["dropBase"] = m(Y["dropWorld"])
  if Y["collect"] and (not Y["dropBase"] or not Y["dropX"] or not Y["dropY"]) then
    return "Set the Drop World and Drop Position before starting Auto Collect."
  end
  if Y["autoFuel"] and not m(Y["fuelWorld"]) then
    return "Set the Fuel Pack World before starting."
  end
  A, Q = Y, true
  v("count", 0)
  i("SCANNING READY TREES")
  runThread(function()
    local c, H = pcall(Ti, Y, t)
    local p = not J(Y)
    A = nil
    u(false)
    n()
    Wi(Y)
    local V, g = pcall(a, Y)
    Q = false
    if p then
      H = "STOPPED"
    elseif not c then
      H = "Stopped. " .. tostring(H)
    end
    H = H or "STOPPED"
    if not V or not g then
      H = H .. " Check equipped gear."
    end
    i(H)
    E(H)
  end)
end
function onValue(c, Y, t)
  if F or type(Y) ~= "string" then
    return
  end
  if Y == "AHS_start" then
    if t ~= true then
      A = nil
      i("STOPPED")
    elseif not A then
      local c = Q and "Wait for the previous run to stop." or Ri()
      if c then
        u(false)
        i(c)
        E(c)
      end
    end
    return
  end
  local H = Y:match("^AHS_(.+)$")
  if H == "hereHarvestWorld" then
    local c = W()
    if not m(c) or not S() then
      E("Enter a world first.")
      return
    end
    local Y = {}
    for t in V["harvestWorlds"]:gmatch("[^,%s;]+") do
      if m(r(t)) == c then
        return
      end
      Y[#Y + 1] = t
    end
    Y[#Y + 1] = c
    H, t = "harvestWorlds", table["concat"](Y, ", ")
    v(H, t)
  elseif H == "clearHarvestWorlds" then
    H, t = "harvestWorlds", ""
    v(H, t)
  elseif H == "hereDropWorld" or H == "hereFuelWorld" then
    local c = W()
    if not m(c) or not S() then
      E("Enter a world first.")
      return
    end
    H = H == "hereDropWorld" and "dropWorld" or "fuelWorld"
    t = c
    v(H, t)
  elseif H == "hereDrop" then
    local c, Y, t = S()
    if not Y or not m(W()) then
      E("Enter the drop world first.")
      return
    end
    V["dropX"], V["dropY"] = tostring(Y), tostring(t)
    v("dropX", Y)
    v("dropY", t)
    O("dropX")
    O("dropY")
    return
  end
  if V[H] == nil then
    return
  end
  if type(V[H]) == "boolean" then
    t = t == true
  elseif type(V[H]) == "number" then
    t = G(t, H == "pickupDelay" and 0 or 100, 10000)
    if not t then
      v(H, V[H])
      return
    end
  elseif H == "harvestWorlds" then
    t = tostring(t or "")
  elseif H == "dropX" or H == "dropY" then
    local c = G(t, 0, 999)
    t = c and tostring(c) or ""
  else
    t = r(t)
  end
  V[H] = t
  O(H)
end
local oi, zi = pcall(B)
if not oi or type(zi) ~= "string" or zi == "" then
  E("Auto Harvest could not build its menu. Check the Growlauncher version.")
  return
end
if not C(addCategory, Y, "Agriculture") or not C(addIntoModule, zi, Y) then
  E("Auto Harvest could not register its menu.")
  return
end
if not C(applyHook) then
  E("Auto Harvest could not register its hooks.")
  return
end
if type(setOnValue) == "function" then
  for c, Y in ipairs({
    "harvestWorlds",
    "dropWorld",
    "dropX",
    "dropY",
    "fuelWorld",
    "returnDoor",
    "punchDelay",
    "pathDelay",
    "pickupDelay",
  }) do
    local t = "AHS_" .. Y
    pcall(setOnValue, t, function(...)
      local c = select("#", ...)
      if c > 0 then
        onValue(nil, t, select(c, ...))
      end
    end)
  end
end
