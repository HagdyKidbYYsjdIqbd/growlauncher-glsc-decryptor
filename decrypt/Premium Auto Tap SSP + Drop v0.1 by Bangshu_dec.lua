setMinimum("6.1.2")
local F = "Premium Auto open ssp + drop by Bangshu"
do
  local W =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local o = "SSPS"
  local z = "SSPS-38-PAID-001"
  local Z = "approval"
  local O = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function v()
    local F, W = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not F then
      return nil
    end
    if type(W) == "number" and (math["type"] and math["type"](W) == "integer") then
      W = tostring(W)
    end
    if type(W) ~= "string" or #W < 17 or #W > 20 or not W:match("^%d+$") then
      return nil
    end
    if W:match("^0+$") then
      return nil
    end
    return W
  end
  local function R(F, W)
    if not W or type(F) ~= "string" or #F > 512 then
      return false
    end
    local Z, v, R = F:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (O .. '"}}%s*$')
    )
    return Z == W and (v == o and R == z)
  end
  local c, j, w = pcall(function()
    local F, W = pcall(require, "preferences")
    local o = F and (type(W) == "table" and W) or Preferences
    if type(o) ~= "table" or type(o["new"]) ~= "function" then
      return nil
    end
    local z = o:new("BangshuPremiumSSPS")
    if z:load() == false then
      return z
    end
    return z, z:get(Z, "")
  end)
  if not c then
    j = nil
  end
  if not R(w, v()) then
    local O, c = false, false
    local function w(F)
      pcall(editValue, "TapTap_premium_status", F)
      if type(sendNotification) == "function" then
        pcall(sendNotification, F)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], F)
      end
    end
    local function J()
      if O or c then
        return
      end
      local F = v()
      if not F then
        w("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not j then
        w("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      O = true
      w("CHECKING")
      local J = pcall(runThread, function()
        local v = W
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              F .. ("&product=" .. (o .. ("&format=growlauncher&version=" .. z)))
            )
          )
        local J, P = pcall(fetch, v)
        if J and type(P) == "string" then
          local F = P:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if F and (#F <= 1024 and #F % 2 == 0) then
            P = F:gsub("..", function(F)
              return string["char"](tonumber(F, 16))
            end)
          end
        end
        if not J or type(P) ~= "string" then
          w("DENIED - REQUEST FAILED")
        elseif not R(P, F) then
          if P:match('^%s*{"status":"DENIED",') then
            w("DENIED - NO PREMIUM ACCESS")
          elseif P:match('^%s*{"status":"ERROR",') then
            w("DENIED - APPS SCRIPT SERVER ERROR")
          elseif P:match("^%s*<") then
            if P:find("doGet", 1, true) then
              w("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              w("DENIED - GOOGLE RETURNED HTML")
            end
          elseif P:match("^%s*$") then
            w("DENIED - EMPTY SERVER RESPONSE")
          elseif P:match('^%s*{"status":"APPROVED",') then
            w("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            w("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local W, o = pcall(function()
            if j:set(Z, P) == false then
              return false
            end
            if j:save() == false then
              return false
            end
            if j:load() == false then
              return false
            end
            return R(j:get(Z, ""), F)
          end)
          c = W and o == true
          w(c and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        O = false
      end)
      if not J then
        O = false
        w("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(F, W)
      if W == "TapTap_premium_verify" then
        J()
      end
    end
    onValue = OnValue
    local P = UserInterface["new"](F, "Rocket")
    P:addButton("Verify Access", "TapTap_premium_verify")
    P:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "TapTap_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, F, "Rocket")
    end
    addIntoModule(P:generateJSON(), F)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "TapTap_premium_verify", J)
    end
    return
  end
end
local W = "taptap_drop_ssp_v32_settings.json"
local o = nil
local z = false
do
  local F, z = pcall(require, "preferences")
  if not F or z == nil then
    z = Preferences
  end
  if z ~= nil and type(z["new"]) == "function" then
    local F, Z = pcall(function()
      return z:new(W)
    end)
    if F and Z ~= nil then
      o = Z
      pcall(function()
        o:load()
      end)
    end
  end
end
local function Z(F, W, z, Z)
  local O = W
  if o ~= nil then
    local z, Z = pcall(function()
      return o:get(F, W)
    end)
    if z and tonumber(Z) ~= nil then
      O = tonumber(Z)
    end
  end
  O = math["floor"](O)
  if z ~= nil then
    O = math["max"](z, O)
  end
  if Z ~= nil then
    O = math["min"](Z, O)
  end
  return O
end
local O = Z("tapItemID", 5706, 1, 65535)
local v = Z("burstTapIntervalMs", 100, 1, 100000)
local R = Z("burstTaps", 10, 1, 25)
local c = Z("burstPostAckPause", 20, 1, 10000)
local j = Z("dropDelay", 500, 200, 500)
local w = Z("minSSP", 25, 0, 200)
local J = Z("dropStartX", 2)
local P = Z("dropStartY", 32)
local N = UserInterface["new"](F, "Rocket")
N:addLabelApp(F, "Bolt")
N:addToggle("Start / Stop", false, "TapTap_enable")
N:addItemPicker("Select Item to Tap", tostring(O), tostring(O), "TapTap_itempicker")
N:addInputInt("Delay Between Taps", tostring(v), "ms", "100", nil, "TapTap_delay")
N:addSlider("Taps per Burst", 1, 25, R, 1, false, "TapTap_bursttaps")
N:addInputInt("Pause After Burst", tostring(c), "ms", "20", nil, "TapTap_burstpause")
N:addSlider("Drop Delay", 200, 500, j, 10, false, "TapTap_dropdelay")
N:addInputInt("Minimum Tap Item Threshold", tostring(w), "items", "25", nil, "TapTap_minssp")
N:addInputInt("Drop Position X", tostring(J), "X", "2", nil, "TapTap_dropx")
N:addInputInt("Drop Position Y", tostring(P), "Y", "32", nil, "TapTap_dropy")
N:addButton("Set Drop Position = Current Tile", "TapTap_setdrop")
N:addDisplayList("Current Drop Position", tostring(J) .. (", " .. tostring(P)), "TapTap_dropcurrent")
N:addDisplayList("Current Drop Target (Right)", tostring(J + 1) .. (", " .. tostring(P)), "TapTap_droptarget")
N:addDisplayList("Detected SSP Position", "NONE", "TapTap_ssppos")
N:addDisplayList("SSP Path Destination", "NONE", "TapTap_ssppath")
N:addDisplayList("Current Mode", "STOPPED", "TapTap_mode")
N:addDisplayList("End of SSP", "AUTO DROP REMAINING SEEDS", "TapTap_endseeds")
N:addDisplayList("Settings", o ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "TapTap_settingsstatus")
pcall(function()
  addCategory(F, "Rocket")
end)
local e = pcall(function()
  addIntoModule(N:generateJSON(), F)
end)
if not e then
  addIntoModule(N:generateJSON())
end
local r = 200
local X = 800
local C = 1800
local x = 1800
local b = 1800
local L = 250
local E = 350
local h = 450
local m = 2
local q = 4
local M = 300
local D = 140
local i = 300
local u = 1200
local k = 6000
local B = 2
local A = 150
local y = false
local l
local d = v
local K = R
local g = c
local n = 0
local I = false
local S = j
local U = w
local f = J
local t = P
local p = f
local G = t
local Q = false
local a = 0
local V = nil
local T, Y = nil, nil
local H, s = 0, 0
local Fy = "STOPPED"
local function Wy()
  if o == nil then
    return false
  end
  local F, W = pcall(function()
    o:set("burstTapIntervalMs", d)
    o:set("burstTaps", K)
    o:set("burstPostAckPause", g)
    o:set("dropDelay", S)
    o:set("minSSP", U)
    o:set("tapItemID", O)
    o:set("dropStartX", f)
    o:set("dropStartY", t)
    o:save()
  end)
  if not F then
    if not z then
      z = true
      pcall(function()
        growtopia["notify"]("TapTap settings could not be saved: " .. tostring(W))
      end)
    end
    pcall(function()
      editValue("TapTap_settingsstatus", "AUTO SAVE FAILED")
    end)
    return false
  end
  pcall(function()
    editValue("TapTap_settingsstatus", "AUTO SAVE ON")
  end)
  return true
end
local oy = false
local zy = false
local Zy = false
local Oy = false
local vy, Ry = nil, nil
local function cy()
  Oy = false
  vy, Ry = nil, nil
end
local function jy(F, W)
  return Oy and (vy == F and Ry == W)
end
local function wy(F)
  if type(F) ~= "string" then
    return false
  end
  local W = (F:lower()):gsub("`.", "")
  W = (W:gsub("[^%a%d%s]", " ")):gsub("%s+", " ")
  local o = W:find("can t drop", 1, true)
    or W:find("cant drop", 1, true)
    or W:find("cannot drop", 1, true)
    or W:find("unable to drop", 1, true)
  local z = W:find("any more", 1, true)
    or W:find("anymore", 1, true)
    or W:find("more items", 1, true)
    or W:find("more seeds", 1, true)
  if o and z then
    return true
  end
  if W:find("drop limit", 1, true) or W:find("maximum dropped", 1, true) or W:find("too many dropped", 1, true) then
    return true
  end
  if
    W:find("too many items", 1, true)
    and (W:find("drop", 1, true) or W:find("here", 1, true) or W:find("ground", 1, true) or W:find("tile", 1, true))
  then
    return true
  end
  return false
end
local Jy = nil
local Py = false
local Ny = false
local ey = false
local function ry(F) end
local function Xy(F)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(F))
    end)
  end
end
local function Cy(F)
  if Fy ~= F then
    Fy = F
    editValue("TapTap_mode", F)
    ry("TapTap mode: " .. F)
  end
end
local function xy(F, W)
  local o = editToggle or EditToggle
  if o ~= nil then
    pcall(o, F, W)
  end
end
local function by(F)
  xy("ModFly", F)
  xy("Anticollect", F)
end
local function Ly(F)
  xy("ModFly", F)
  xy("Anticollect", false)
end
local function Ey()
  local F = GetLocal or getLocal
  if F == nil then
    return nil
  end
  local W, o = pcall(F)
  if W then
    return o
  end
  return nil
end
local function hy()
  local F = GetWorldName or getCurrentWorldName
  if F == nil then
    return ""
  end
  local W, o = pcall(F)
  if W and type(o) == "string" then
    return o
  end
  return ""
end
local function my()
  local F = GetInventory or getInventory
  if F == nil then
    return nil
  end
  local W, o = pcall(F)
  if W and type(o) == "table" then
    return o
  end
  return nil
end
local function qy()
  local F = GetTiles or getTiles
  if F == nil then
    return nil
  end
  local W, o = pcall(F)
  if W and type(o) == "table" then
    return o
  end
  return nil
end
local function My(F, W)
  if type(F) ~= "string" or type(W) ~= "string" then
    return false
  end
  return F:upper() == W:upper()
end
local function Dy(F)
  if type(F) ~= "string" or F == "" then
    return false
  end
  return F:upper() ~= "EXIT"
end
local function iy()
  if Jy == nil or Jy == "" then
    return false
  end
  local F = Ey()
  if F == nil then
    return false
  end
  local W = hy()
  if Dy(W) then
    if My(W, Jy) then
      ey = true
      return true
    end
    ey = false
    return false
  end
  return ey == true
end
local function uy(F)
  local W = 0
  while y and W < F do
    if not iy() then
      return false
    end
    local F = my()
    local o = qy()
    if F ~= nil and (o ~= nil and next(o) ~= nil) then
      return true
    end
    Sleep(100)
    W = W + 100
  end
  return false
end
local function ky(F)
  local W = 0
  while y and W < F do
    local F = Ey()
    local o = hy()
    if Dy(o) and not My(o, Jy) then
      return false
    end
    local z = my()
    local Z = qy()
    if F ~= nil and (z ~= nil and (Z ~= nil and next(Z) ~= nil)) then
      return true
    end
    Sleep(100)
    W = W + 100
  end
  return false
end
local function By()
  local F = Ey()
  if F == nil then
    return
  end
  local W = F["posX"] // 32
  local o = F["posY"] // 32
  pcall(function()
    FindPath(W, o)
  end)
end
local function Ay(F, W)
  W = W or my()
  if W == nil then
    return 0
  end
  for W, o in pairs(W) do
    if o["id"] == F then
      return o["amount"]
    end
  end
  return 0
end
local function yy(F)
  F = F or my()
  if F == nil then
    return 0
  end
  for F, W in pairs(F) do
    if W["id"] ~= O and (W["id"] % 2 == 1 and W["amount"] >= r) then
      return W["id"]
    end
  end
  return 0
end
local function ly()
  local F = my()
  if F == nil then
    return 0
  end
  for F, W in pairs(F) do
    local o = tonumber(W["id"])
    local z = tonumber(W["amount"]) or 0
    if o ~= nil and (o > 0 and (o ~= O and (o % 2 == 1 and z > 0))) then
      return o
    end
  end
  return 0
end
local function dy()
  local F = Ey()
  if F == nil then
    return nil, nil
  end
  return F["posX"] // 32, F["posY"] // 32
end
local function Ky(F, W)
  if not y or not iy() then
    return false
  end
  for o = 1, B, 1 do
    if not y or not iy() then
      return false
    end
    local z, Z = dy()
    if z == nil then
      Py = true
      return false
    end
    if z == F and Z == W then
      return true
    end
    local O = pcall(function()
      FindPath(F, W)
    end)
    if not O then
      if o < B then
        Sleep(i)
      end
    else
      local O = 0
      local v = 0
      local R = z
      local c = Z
      while y and O < k do
        if not iy() then
          Py = true
          return false
        end
        local o, z = dy()
        if o == nil then
          Py = true
          return false
        end
        if o == F and z == W then
          Sleep(A)
          return true
        end
        if o ~= R or z ~= c then
          R = o
          c = z
          v = 0
        else
          v = v + 100
        end
        if v >= u then
          break
        end
        Sleep(100)
        O = O + 100
      end
      if o < B then
        Sleep(i)
      end
    end
  end
  Cy("WAIT PATH")
  return false
end
local function gy()
  local F = GetObjectList or getObjectList
  if F == nil then
    return {}
  end
  local W, o = pcall(F)
  if W and type(o) == "table" then
    return o
  end
  return {}
end
local function ny(F)
  if F == nil then
    return nil, nil
  end
  local W = tonumber(F["posX"])
  local o = tonumber(F["posY"])
  if (W == nil or o == nil) and F["pos"] ~= nil then
    W = W or tonumber(F["pos"]["x"])
    o = o or tonumber(F["pos"]["y"])
  end
  return W, o
end
local function Iy(F, W)
  if T ~= F or Y ~= W then
    T, Y = F, W
    s = 0
  end
  s = s + 1
  Cy("DROPPED " .. (tostring(s) .. " ON TILE"))
  return s
end
local function Sy()
  T, Y = nil, nil
  H, s = 0, 0
end
local function Uy()
  editValue("TapTap_dropcurrent", tostring(p) .. (", " .. tostring(G)))
  editValue("TapTap_droptarget", tostring(p + 1) .. (", " .. tostring(G)))
end
local function fy(F, W, o, z)
  if F ~= nil and W ~= nil then
    editValue("TapTap_ssppos", tostring(F) .. (", " .. tostring(W)))
  else
    editValue("TapTap_ssppos", "NONE")
  end
  if o ~= nil and z ~= nil then
    editValue("TapTap_ssppath", tostring(o) .. (", " .. tostring(z)))
  else
    editValue("TapTap_ssppath", "NONE")
  end
end
local function ty(F, W)
  local o = getTile or GetTile
  if o == nil then
    return nil
  end
  local z, Z = pcall(o, F, W)
  if z then
    return Z
  end
  return nil
end
local function py(F, W)
  local o = ty(F, W)
  if o == nil then
    return false
  end
  return o["collidable"] == true
end
local function Gy()
  local F = Ey()
  if F == nil or not y then
    return false
  end
  local W = hy()
  if Dy(W) and not My(W, Jy) then
    return false
  end
  local o = F["posX"] // 32
  local z = F["posY"] // 32
  local Z = { { ["x"] = o + 1, ["y"] = z }, { ["x"] = o - 1, ["y"] = z }, { ["x"] = o, ["y"] = z - 1 } }
  for F, W in ipairs(Z) do
    local Z = ty(W["x"], W["y"])
    if Z ~= nil and Z["collidable"] ~= true then
      local F = false
      for o = 1, 4, 1 do
        if not y then
          return false
        end
        local z = hy()
        if Dy(z) and not My(z, Jy) then
          return false
        end
        pcall(function()
          FindPath(W["x"], W["y"])
        end)
        local Z = 0
        while y and Z < 500 do
          local o = Ey()
          z = hy()
          if Dy(z) and not My(z, Jy) then
            return false
          end
          if o ~= nil and (o["posX"] // 32 == W["x"] and o["posY"] // 32 == W["y"]) then
            F = true
            break
          end
          Sleep(100)
          Z = Z + 100
        end
        if F then
          break
        end
        Sleep(120)
      end
      if F then
        Sleep(D)
        pcall(function()
          FindPath(o, z)
        end)
        local F = 0
        while y and F < 1200 do
          local W = Ey()
          if W ~= nil and (W["posX"] // 32 == o and W["posY"] // 32 == z) then
            Sleep(D)
            return true
          end
          Sleep(100)
          F = F + 100
        end
        return true
      end
    end
  end
  pcall(function()
    FindPath(o, z)
  end)
  Sleep(D)
  return false
end
local function Qy()
  local F = Ey()
  if F == nil or not iy() then
    return {}, 0
  end
  local W = F["posX"] // 32
  local o = F["posY"] // 32
  local z = {}
  local Z = 0
  for F, v in pairs(gy()) do
    local R = tonumber(v["itemid"])
    if R == O then
      Z = Z + 1
      local F, O = ny(v)
      if F ~= nil and O ~= nil then
        local Z = math["floor"](F / 32)
        local R = math["floor"](O / 32)
        table["insert"](
          z,
          {
            ["object"] = v,
            ["objectX"] = Z,
            ["objectY"] = R,
            ["pixelX"] = F,
            ["pixelY"] = O,
            ["distance"] = math["abs"](W - Z) + math["abs"](o - R),
          }
        )
      end
    end
  end
  table["sort"](z, function(F, W)
    return F["distance"] < W["distance"]
  end)
  if #z > 0 then
    fy(z[1]["objectX"], z[1]["objectY"], nil, nil)
  elseif Z == 0 then
    fy(nil, nil, nil, nil)
  end
  return z, Z
end
local function ay(F)
  return {
    { F["objectX"], F["objectY"] },
    { F["objectX"] - 1, F["objectY"] },
    { F["objectX"] + 1, F["objectY"] },
    { F["objectX"], F["objectY"] - 1 },
    { F["objectX"] - 1, F["objectY"] - 1 },
    { F["objectX"] + 1, F["objectY"] - 1 },
  }
end
local Vy, Ty = false, false
local function Yy(F)
  local W = n
  Cy("RESPAWNING BEFORE STOP")
  by(true)
  Vy, Ty = true, false
  local o, z = pcall(SendPacket or sendPacket, 2, "action|respawn")
  if o and z ~= false then
    for F = 1, 30, 1 do
      if not y or W ~= n or Ty then
        break
      end
      Sleep(100)
    end
  end
  Vy = false
  if not y or W ~= n then
    return
  end
  if Ty then
    Sleep(250)
  else
    ry("Shutdown respawn was not confirmed.")
  end
  if not y or W ~= n then
    return
  end
  y = false
  by(false)
  oy = false
  zy = false
  fy(nil, nil, nil, nil)
  local Z = EditToggle or editToggle
  if Z ~= nil then
    pcall(Z, "TapTap_enable", false)
  end
  if F then
    Cy("DONE - SEEDS DROPPED")
    Xy("No SSP remains. Final seed drop finished; script stopped.")
    ry("No dropped SSP remains; remaining seed stacks were dropped and verified.")
  else
    Cy("NO SSP - STOPPED")
    Xy("No SSP found and no seeds remain. Script stopped.")
    ry("No dropped SSP or remaining seed stacks found. TapTap stopped.")
  end
end
local function Hy()
  if not y or not iy() then
    return false
  end
  local F = GetObjectList or getObjectList
  if type(F) ~= "function" then
    return false
  end
  local W, o = pcall(F)
  if not W or type(o) ~= "table" then
    return false
  end
  for F, W in pairs(o) do
    if tonumber(W["itemid"]) == O then
      return false
    end
  end
  return true
end
local function sy(F)
  if not y or not iy() then
    return
  end
  if F == nil or F["object"] == nil then
    return
  end
  local W = tonumber(F["object"]["id"])
  if W == nil then
    return
  end
  if tonumber(F["object"]["itemid"]) ~= O then
    return
  end
  l = W
  pcall(function()
    if y and iy() then
      SendPacketRaw(false, { ["type"] = 11, ["value"] = W, ["x"] = F["pixelX"], ["y"] = F["pixelY"] })
    end
  end)
  l = nil
end
local function FD(F, W, o, z)
  if not y or not iy() then
    return false
  end
  fy(F["objectX"], F["objectY"], W, o)
  for Z = 1, B, 1 do
    if not y or not iy() then
      return false
    end
    local v, R = dy()
    if v == nil then
      Py = true
      return false
    end
    local c = false
    local j = pcall(function()
      FindPath(W, o)
    end)
    if j then
      local Z = 0
      local j = 0
      local w = v
      local J = R
      while y and Z < k do
        if not iy() then
          Py = true
          return false
        end
        if Ay(O) > z then
          return true
        end
        local v, R = dy()
        if v == nil then
          Py = true
          return false
        end
        local P = math["abs"](v - F["objectX"]) <= 1 and math["abs"](R - F["objectY"]) <= 1
        if P and not c then
          sy(F)
          c = true
        end
        if v == W and R == o then
          if not c then
            sy(F)
            c = true
          end
          local W = 0
          while y and W < 500 do
            if Ay(O) > z then
              return true
            end
            Sleep(50)
            W = W + 50
          end
          return false
        end
        if v ~= w or R ~= J then
          w = v
          J = R
          j = 0
        else
          j = j + 100
        end
        if j >= u then
          break
        end
        Sleep(100)
        Z = Z + 100
      end
    end
    if Z < B then
      Sleep(i)
    end
  end
  return false
end
local function WD()
  local F, W = Qy()
  if W == 0 then
    return false, "NO_SSP"
  end
  if #F == 0 then
    Cy("WAIT SSP DATA")
    ry("SSP object(s) exist, but their position data could not be read.")
    return false
  end
  local o = Ay(O)
  Cy("COLLECT SSP")
  Ly(true)
  for F, W in ipairs(F) do
    if not y or not iy() then
      Ly(false)
      return false
    end
    editValue("TapTap_ssppos", tostring(W["objectX"]) .. (", " .. tostring(W["objectY"])))
    ry("Testing SSP object at " .. (W["objectX"] .. (", " .. W["objectY"])))
    local z = ay(W)
    for F, z in ipairs(z) do
      local Z = z[1]
      local O = z[2]
      if FD(W, Z, O, o) then
        by(true)
        local F = Ky(p, G)
        if F then
          fy(W["objectX"], W["objectY"], p, G)
        end
        return F
      end
      if not y or not iy() then
        Ly(false)
        return false
      end
    end
  end
  Ly(false)
  local z = F[1]
  editValue("TapTap_ssppos", tostring(z["objectX"]) .. (", " .. tostring(z["objectY"])))
  editValue("TapTap_ssppath", "NO WORKING PATH")
  local Z = (Fy == "WAIT SSP PATH")
  Cy("WAIT SSP PATH")
  if not Z then
    Xy("Path not found!")
  end
  ry("Found " .. (W .. " SSP object(s), but actual FindPath could not reach any candidate."))
  return false
end
local function oD(F)
  local W = my()
  if not W then
    return false
  end
  local o = Ay(O, W)
  if o <= 0 or o < U or yy(W) ~= 0 then
    return false
  end
  local z = 0
  local Z = math["min"](I and 1 or K, o, (o - U) + 1)
  local v, R = p, G
  for W = 1, Z, 1 do
    if not y or F ~= n then
      return false
    end
    if not iy() then
      Py = true
      return false
    end
    local o = Ey()
    if not o or o["posX"] // 32 ~= v or o["posY"] // 32 ~= R or p ~= v or G ~= R then
      break
    end
    local c, j = pcall(
      SendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = O, ["x"] = o["posX"], ["y"] = o["posY"], ["px"] = v, ["py"] = R }
    )
    if not c or j == false then
      break
    end
    z = z + 1
    if W < Z then
      Sleep(d)
    end
  end
  if z == 0 then
    return false
  end
  local c = 0
  while y and F == n do
    if not iy() then
      Py = true
      return false
    end
    W = my()
    if W and Ay(O, W) < o then
      I = false
      Sleep(g)
      return y and F == n
    end
    if c >= b then
      break
    end
    Sleep(20)
    c = c + 20
  end
  if y and F == n then
    I = true
    Cy("WAIT SERVER")
    Sleep(L)
  end
  return false
end
local function zD(F, W)
  if not y or not iy() then
    return false, "WORLD_LOST"
  end
  oy = false
  zy = true
  SendPacket(2, "action|drop\nitemID|" .. F)
  local o = 0
  local z = 25
  while y and o < C do
    if jy(p + 1, G) then
      zy = false
      oy = false
      return false, "TILE_FULL"
    end
    if not iy() then
      Py = true
      zy = false
      return false, "WORLD_LOST"
    end
    if oy then
      break
    end
    Sleep(z)
    o = o + z
  end
  if not y then
    zy = false
    return false, "STOPPED"
  end
  if not oy then
    zy = false
    Cy("WAIT SERVER")
    Sleep(L)
    return false, "NO_DIALOG"
  end
  oy = false
  zy = false
  if jy(p + 1, G) then
    return false, "TILE_FULL"
  end
  if not y or not iy() then
    return false, "WORLD_LOST"
  end
  SendPacket(
    2,
    "action|dialog_return\n" .. ("dialog_name|drop_item\n" .. ("itemID|" .. (F .. ("|\n" .. ("count|" .. W)))))
  )
  return true, "CONFIRM_SENT"
end
local function ZD(F, W)
  local o = 0
  local z = 50
  while y and o < x do
    if not iy() then
      return false, "WORLD_LOST"
    end
    local Z = Ay(F)
    if Z < W then
      if o < S then
        Sleep(S - o)
      end
      return true, Z
    end
    if jy(p + 1, G) then
      return false, "TILE_FULL"
    end
    Sleep(z)
    o = o + z
  end
  return false, Ay(F)
end
local function OD()
  if not y or not iy() then
    return false
  end
  local F = Ey()
  if F == nil then
    Py = true
    return false
  end
  if F["isLeft"] == false then
    return true
  end
  local W = F["posX"] // 32
  local o = F["posY"] // 32
  local z = W - 1
  local Z = o
  local O = ty(z, Z)
  if O == nil or O["collidable"] == true then
    ry("Cannot safely face right because the left-side turn tile is blocked.")
    return false
  end
  if not Ky(z, Z) then
    return false
  end
  Sleep(60)
  if not y then
    return false
  end
  if not Ky(W, o) then
    return false
  end
  Sleep(60)
  local v = Ey()
  if v ~= nil and v["isLeft"] ~= nil then
    ry("Safe facing check: isLeft=" .. tostring(v["isLeft"]))
    return v["isLeft"] == false
  end
  return true
end
local function vD()
  if not y or not iy() then
    return false
  end
  local F = p - 1
  local W = G
  ry(
    "Drop target full at " .. (
        (p + 1) .. (", " .. (G .. (". Trying next standing tile to the left: " .. (F .. (", " .. W)))))
      )
  )
  if F >= 0 and Ky(F, W) then
    p = F
    G = W
    Uy()
    ry("Moved left for next drop. Stand: " .. (p .. (", " .. (G .. (" | Target: " .. ((p + 1) .. (", " .. G)))))))
    return true
  end
  local o = f
  local z = G - 1
  ry("No path to the left. Trying next row at start X: " .. (o .. (", " .. z)))
  if z >= 0 and Ky(o, z) then
    p = o
    G = z
    Uy()
    Xy("Next Drop Row = (" .. (p .. (", " .. (G .. ")"))))
    ry("Moved to next drop row. Stand: " .. (p .. (", " .. (G .. (" | Target: " .. ((p + 1) .. (", " .. G)))))))
    return true
  end
  Cy("WAIT DROP PATH")
  Xy("No drop path found!")
  ry("Could not move left and could not reach next row start at " .. (o .. (", " .. z)))
  return false
end
local function RD(F, W, o)
  local z = 0
  while y and z < o do
    if not iy() then
      return false, "WORLD_LOST"
    end
    if my() == nil then
      return false, "NO_INVENTORY"
    end
    if Ay(F) < W then
      return true, "ACCEPTED"
    end
    Sleep(50)
    z = z + 50
  end
  return Ay(F) < W, "TIMEOUT"
end
local function cD(F, W)
  if my() == nil then
    return "NO_INVENTORY"
  end
  local o = Ay(F)
  if o < W then
    return "CHANGED"
  end
  for z = 1, m, 1 do
    if not y then
      return "STOPPED"
    end
    if not iy() then
      return "WORLD_LOST"
    end
    if my() == nil then
      return "NO_INVENTORY"
    end
    if Ay(F) < o then
      return "SUCCESS"
    end
    Cy(z == 1 and "DROP - CHECK INVENTORY" or "RETRY DROP 2/2 - SAME TILE")
    Zy = true
    local Z, O = zD(F, W)
    if Z then
      local W, z = ZD(F, o)
      if W then
        Zy = false
        return "SUCCESS"
      end
      O = z
    end
    Zy = false
    if not y then
      return "STOPPED"
    end
    if O == "WORLD_LOST" or not iy() then
      return "WORLD_LOST"
    end
    if my() == nil then
      return "NO_INVENTORY"
    end
    if Ay(F) < o then
      return "SUCCESS"
    end
    if O == "TILE_FULL" or jy(p + 1, G) then
      return "REJECTED"
    end
    Cy(z == 1 and "WAIT DROP ACK - RETRY" or "WAIT DROP ACK - SHIFT")
    local v, R = RD(F, o, z == 1 and E or h)
    if v then
      return "SUCCESS"
    end
    if R == "WORLD_LOST" then
      return "WORLD_LOST"
    end
    if R == "NO_INVENTORY" then
      return "NO_INVENTORY"
    end
  end
  return "REJECTED"
end
local function jD(F)
  local W = false
  local o = true
  local z = 0
  local function Z()
    Q = true
    Zy = false
    Cy("DROP FAILED - MOVE LEFT")
    if not vD() then
      Cy("WAIT LEFT PATH - NO DROP")
      return false
    end
    Q = false
    cy()
    W, o = true, true
    z = z + 1
    return true
  end
  while y do
    if not iy() then
      Py = true
      return false
    end
    if my() == nil then
      Cy("WAIT INVENTORY")
      return false
    end
    local O = V
    if O ~= nil then
      local W = Ay(O)
      if W <= 0 or (not F and W < r) then
        V = nil
        O = nil
      end
    end
    if O == nil then
      O = F and ly() or yy()
    end
    if O == 0 then
      return true
    end
    if Q then
      if not Z() then
        return false
      end
    elseif not W then
      if not Ky(p, G) then
        Cy("WAIT DROP PATH")
        Xy("Path not found!")
        return false
      end
      W = true
      o = true
    end
    local v, R = p + 1, G
    if py(v, R) or jy(v, R) then
      V = O
      if not Z() then
        return false
      end
    else
      if o then
        if not OD() then
          Cy("WAIT DROP FACING")
          Xy("Cannot face right safely!")
          return false
        end
        o = false
      end
      local W = Ay(O)
      local z = F and math["min"](r, W) or r
      if z <= 0 or W < z then
        V = nil
        Sleep(50)
      else
        local F = cD(O, z)
        if F == "SUCCESS" then
          V = nil
          a = 0
          Iy(v, R)
        elseif F == "REJECTED" then
          V = O
          a = a + 1
          if not Z() then
            return false
          end
        elseif F == "CHANGED" then
          V = nil
        elseif F == "NO_INVENTORY" then
          Cy("WAIT INVENTORY")
          return false
        elseif F == "WORLD_LOST" then
          Py = true
          return false
        else
          return false
        end
      end
    end
    if a >= q then
      Cy("SERVER SLOW - DROP COOLDOWN")
      Sleep(1500)
      a = 0
      return false
    end
    if z >= 30 then
      Cy("DROP SHIFT BREAK")
      Sleep(400)
      return false
    end
    Sleep(30)
  end
  return false
end
local function wD()
  local F = Ey()
  if F == nil then
    ry("Cannot set drop position: player not loaded.")
    return
  end
  f = F["posX"] // 32
  t = F["posY"] // 32
  p = f
  G = t
  Sy()
  cy()
  Zy = false
  Q = false
  a = 0
  editValue("TapTap_dropx", tostring(f))
  editValue("TapTap_dropy", tostring(t))
  Uy()
  Wy()
  Xy("Drop Position = (" .. (f .. (", " .. (t .. ")"))))
  ry("Drop start position set: " .. (f .. (", " .. t)))
end
local function JD()
  if not y then
    return false
  end
  if iy() then
    if Py or Ny then
      by(false)
      Cy("RESUMING")
      Sleep(M)
      if not y then
        return false
      end
      local F = hy()
      if Dy(F) and not My(F, Jy) then
        ey = false
        return false
      end
      if not uy(3000) then
        Cy("RESUMING")
        Sleep(100)
        return false
      end
      Cy("RESUME MOVE")
      Gy()
      if not y then
        return false
      end
      F = hy()
      if Dy(F) and not My(F, Jy) then
        ey = false
        return false
      end
      Py = false
      Ny = false
      ey = true
      Xy("TapTap resumed automatically.")
    end
    return true
  end
  if Py and Ny then
    by(false)
    Cy("RESUMING")
    Sleep(M)
    if not y then
      return false
    end
    if ky(4000) then
      local F = hy()
      if Dy(F) and not My(F, Jy) then
        ey = false
        Cy("PAUSED - WAIT WORLD")
        return false
      end
      ey = true
      Cy("RESUME MOVE")
      Gy()
      if not y then
        return false
      end
      F = hy()
      if Dy(F) and not My(F, Jy) then
        ey = false
        Cy("PAUSED - WAIT WORLD")
        return false
      end
      Py = false
      Ny = false
      Xy("TapTap resumed automatically.")
      return true
    end
  end
  if not Py then
    Py = true
    Xy("TapTap paused - return to " .. tostring(Jy))
  end
  ey = false
  oy = false
  zy = false
  by(false)
  Cy("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
function onVariant(F, W)
  if F ~= nil then
    if y and (F["v1"] == "OnSpawn" and type(F["v2"]) == "string") then
      if Vy and F["v2"]:find("type|local", 1, true) then
        Ty = true
      end
      local W = F["v2"]:find("type|local", 1, true) ~= nil
      if not W then
        local o = tonumber(F["v2"]:match("netID|(%d+)"))
        local z = Ey()
        if o ~= nil and z ~= nil then
          W = tonumber(z["netID"]) == o
        end
      end
      if W and (Py or not ey) then
        Ny = true
        Py = true
      end
    end
    if y and (Py and F["v1"] == "OnSetPos") then
      Ny = true
    end
    if y and Zy then
      local W = true
      if F["v1"] == "OnTalkBubble" then
        local o = Ey()
        if o ~= nil and (o["netID"] ~= nil and tonumber(F["v2"]) ~= tonumber(o["netID"])) then
          W = false
        end
      end
      if W then
        for W = 2, 7, 1 do
          local o = F["v" .. tostring(W)]
          if wy(o) then
            vy = p + 1
            Ry = G
            Oy = true
            ry("Server says drop tile is full: " .. (tostring(vy) .. (", " .. tostring(Ry))))
            break
          end
        end
      end
    end
    if F["v1"] == "OnDialogRequest" and type(F["v2"]) == "string" then
      if F["v2"]:find("drop_item", 1, true) then
        if y and zy then
          oy = true
        end
        return true
      end
    end
  end
  return false
end
function onSendPacket(F, W)
  if y and type(W) == "string" then
    local F = W:find("action|quit", 1, true) ~= nil
    local o = W:find("action|join_request", 1, true) ~= nil
    if F or o then
      ey = false
      Py = true
      Ny = false
      oy = false
      zy = false
      by(false)
      Cy("PAUSED - WAIT WORLD")
    end
  end
  return false
end
function onSendPacketRaw(F)
  if not y or F == nil or tonumber(F["type"]) ~= 11 then
    return false
  end
  return l == nil or tonumber(F["value"]) ~= l
end
function onGamePacket(F)
  if F ~= nil and (F["type"] == 26 and y) then
    if not Py then
      Xy("TapTap paused - disconnected.")
    end
    Py = true
    Ny = false
    ey = false
    oy = false
    zy = false
    by(false)
    Cy("PAUSED - WAIT WORLD")
    ry("Disconnect detected. TapTap is paused until you manually return to the target world.")
  end
  return false
end
local PD = false
local function ND()
  PD = true
  xy("TapTap_enable", false)
  PD = false
end
local function eD(F)
  y = true
  n = n + 1
  I = false
  Jy = F
  Py = false
  Ny = false
  ey = true
  Sy()
  cy()
  Zy = false
  Q = false
  a = 0
  V = nil
  Cy("STARTING")
  Xy("TapTap started.")
end
local function rD()
  y = false
  n = n + 1
  I = false
  oy = false
  zy = false
  Zy = false
  Q = false
  a = 0
  V = nil
  cy()
  by(false)
  Cy("STOPPED")
  Py = false
  Ny = false
  ey = false
  Xy("TapTap stopped safely.")
end
local function XD(F)
  if type(F) == "table" then
    F = F["id"] or F["itemID"] or F["itemid"] or F["value"] or F["name"]
  end
  local W = tonumber(F)
  if not W and type(F) == "string" then
    W = tonumber(F:match("%((%d+)%)"))
    local o = findItemID or (growtopia and growtopia["getItemID"])
    if not W and type(o) == "function" then
      local z, Z = pcall(o, F)
      if z then
        W = tonumber(Z)
      end
    end
  end
  if not W or W < 1 or W > 65535 or W % 1 ~= 0 then
    return false
  end
  if W == O then
    return true
  end
  if y then
    Xy("Stop the script before changing the item to tap.")
    return true
  end
  O = W
  Wy()
  return true
end
function onValue(F, W, o)
  if W == "TapTap_itempicker" then
    XD(o)
    return
  end
  if W == "TapTap_enable" then
    if PD then
      return
    end
    if o ~= true then
      if y then
        rD()
      end
      return
    end
    if y then
      return
    end
    local F = hy()
    if (f < 0 or t < 0) or not Dy(F) or not Ey() then
      ND()
      Xy((f < 0 or t < 0) and "Set a valid Drop Position first." or "Enter the farming world first, then press Start.")
      return
    end
    eD(F)
    return
  end
  if W == "TapTap_delay" then
    local F = tonumber(o)
    if F ~= nil then
      if F < 1 then
        F = 1
      end
      d = math["floor"](F)
      Wy()
      ry("Pack Delay: " .. (d .. " ms"))
    end
    return
  end
  if W == "TapTap_bursttaps" then
    local F = tonumber(o)
    if F then
      K = math["max"](1, math["min"](25, math["floor"](F)))
      Wy()
    end
    return
  end
  if W == "TapTap_burstpause" then
    local F = tonumber(o)
    if F then
      g = math["max"](1, math["min"](10000, math["floor"](F)))
      Wy()
    end
    return
  end
  if W == "TapTap_dropdelay" then
    local F = tonumber(o)
    if F ~= nil then
      F = math["floor"](F)
      if F < 200 then
        F = 200
      end
      if F > 500 then
        F = 500
      end
      S = F
      Wy()
      ry("Drop Delay: " .. (S .. " ms"))
    end
    return
  end
  if W == "TapTap_minssp" then
    local F = tonumber(o)
    if F ~= nil then
      F = math["floor"](F)
      if F < 0 then
        F = 0
      end
      if F > 200 then
        F = 200
      end
      U = F
      Wy()
      ry("Minimum SSP Threshold: " .. U)
    end
    return
  end
  if W == "TapTap_dropx" then
    local F = tonumber(o)
    if F ~= nil then
      f = math["floor"](F)
      p = f
      G = t
      Sy()
      cy()
      Zy = false
      Q = false
      a = 0
      V = nil
      Uy()
      Wy()
    end
    return
  end
  if W == "TapTap_dropy" then
    local F = tonumber(o)
    if F ~= nil then
      t = math["floor"](F)
      p = f
      G = t
      Sy()
      cy()
      Zy = false
      Q = false
      a = 0
      V = nil
      Uy()
      Wy()
    end
    return
  end
  if W == "TapTap_setdrop" then
    wD()
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(setOnValue, "TapTap_itempicker", function(...)
    for F = select("#", ...), 1, -1 do
      if XD(select(F, ...)) then
        return
      end
    end
  end)
end
runThread(function()
  by(false)
  Cy("STOPPED")
  while true do
    if y then
      if not JD() then
        Sleep(200)
      else
        local F = 400
        local W = yy()
        if W ~= 0 then
          Cy("DROP")
          by(true)
          jD()
        else
          Cy("GACHA")
          by(true)
          local W = true
          if Ay(O) < U then
            local F, o = WD()
            if F then
              W = false
              Sleep(200)
            elseif o == "NO_SSP" then
              W = false
              Cy("VERIFY NO SSP")
              Sleep(250)
              if y and (iy() and Hy()) then
                if my() == nil then
                  Cy("WAIT INVENTORY")
                elseif ly() ~= 0 then
                  Cy("FINAL SEED DROP")
                  by(true)
                  local F = jD(true)
                  if F and (y and iy()) then
                    if y and iy() then
                      Yy(true)
                    end
                  end
                else
                  Yy(false)
                end
              else
                Cy("WAIT SSP DATA")
              end
              Sleep(150)
            else
              if not iy() then
                Py = true
              end
              W = false
              Sleep(500)
            end
          end
          if W and y then
            by(true)
            local W = n
            local o, z = dy()
            if o and ((o == p and z == G or Ky(p, G)) and (y and (W == n and oD(W)))) then
              F = 0
            end
          end
        end
        if F > 0 then
          Sleep(F)
        end
      end
    else
      Sleep(200)
    end
  end
end)
ry(F .. " loaded.")
