setMinimum("6.1.2")
local z = "Premium Auto open ssp + drop by Bangshu"
local t =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local S = "SSPS"
local o
local B = ""
local v = 0
local function Q(z)
  return (((tostring(z or "")):gsub("%s+", ""))):upper()
end
pcall(function()
  local z = Preferences
  if type(require) == "function" then
    local t, S = pcall(require, "preferences")
    if t and type(S) == "table" then
      z = S
    end
  end
  if type(z) ~= "table" or type(z["new"]) ~= "function" then
    return
  end
  o = z:new("PremiumAutoOpenSSPSLicense")
  o:load()
  B = Q(o:get("license_key", ""))
end)
local function F(z)
  if not o then
    return false
  end
  return pcall(function()
    o:set("license_key", z)
    o:save()
  end)
end
local u = "taptap_drop_ssp_v32_settings.json"
local H = nil
local W = false
do
  local z, t = pcall(require, "preferences")
  if not z or t == nil then
    t = Preferences
  end
  if t ~= nil and type(t["new"]) == "function" then
    local z, S = pcall(function()
      return t:new(u)
    end)
    if z and S ~= nil then
      H = S
      pcall(function()
        H:load()
      end)
    end
  end
end
local function b(z, t, S, o)
  local B = t
  if H ~= nil then
    local S, o = pcall(function()
      return H:get(z, t)
    end)
    if S and tonumber(o) ~= nil then
      B = tonumber(o)
    end
  end
  B = math["floor"](B)
  if S ~= nil then
    B = math["max"](S, B)
  end
  if o ~= nil then
    B = math["min"](o, B)
  end
  return B
end
local x = b("tapItemID", 5706, 1, 65535)
local h = b("burstTapIntervalMs", 100, 1, 100000)
local n = b("burstTaps", 10, 1, 25)
local T = b("burstPostAckPause", 20, 1, 10000)
local k = b("dropDelay", 500, 200, 500)
local V = b("minSSP", 25, 0, 200)
local e = b("packStartX", 0)
local K = b("packStartY", 0)
local P = b("dropStartX", 2)
local X = b("dropStartY", 32)
local a = b("packXInputSet", 0, 0, 1) == 1
local A = b("packYInputSet", 0, 0, 1) == 1
local D = b("packPositionSet", 0, 0, 1) == 1 and (a and A)
local g = "NOT SET"
if D then
  g = tostring(e) .. (", " .. tostring(K))
elseif a or A then
  g = (a and tostring(e) or "NOT SET") .. (", " .. (A and tostring(K) or "NOT SET"))
end
local O = D and (tostring(e) .. (", " .. tostring(K))) or "NOT SET"
local s = UserInterface["new"](z, "Rocket")
s:addLabelApp(z, "Bolt")
s:addInputString("License Key", B, "A1234567", "A1234567", nil, "TapTap_licensekey")
s:addButton("Verify License", "TapTap_verifylicense")
s:addButton("Clear Saved License", "TapTap_clearlicense")
s:addDisplayList("License Status", "NOT VERIFIED", "TapTap_licensestatus")
s:addToggle("Start / Stop", false, "TapTap_enable")
s:addItemPicker("Select Item to Tap", tostring(x), tostring(x), "TapTap_itempicker")
s:addInputInt("Delay Between Taps", tostring(h), "ms", "100", nil, "TapTap_delay")
s:addSlider("Taps per Burst", 1, 25, n, 1, false, "TapTap_bursttaps")
s:addInputInt("Pause After Burst", tostring(T), "ms", "20", nil, "TapTap_burstpause")
s:addSlider("Drop Delay", 200, 500, k, 10, false, "TapTap_dropdelay")
s:addInputInt("Minimum Tap Item Threshold", tostring(V), "items", "25", nil, "TapTap_minssp")
s:addInputInt("Pack Position X", tostring(e), "X", "0", nil, "TapTap_packx")
s:addInputInt("Pack Position Y", tostring(K), "Y", "0", nil, "TapTap_packy")
s:addButton("Set Pack Position = Current Tile", "TapTap_setpack")
s:addDisplayList("Selected Pack Position", g, "TapTap_packstart")
s:addDisplayList("Current Pack Position", O, "TapTap_packcurrent")
s:addInputInt("Drop Position X", tostring(P), "X", "2", nil, "TapTap_dropx")
s:addInputInt("Drop Position Y", tostring(X), "Y", "32", nil, "TapTap_dropy")
s:addButton("Set Drop Position = Current Tile", "TapTap_setdrop")
s:addDisplayList("Current Drop Position", tostring(P) .. (", " .. tostring(X)), "TapTap_dropcurrent")
s:addDisplayList("Current Drop Target (Right)", tostring(P + 1) .. (", " .. tostring(X)), "TapTap_droptarget")
s:addDisplayList("Detected SSP Position", "NONE", "TapTap_ssppos")
s:addDisplayList("SSP Path Destination", "NONE", "TapTap_ssppath")
s:addDisplayList("Current Mode", "STOPPED", "TapTap_mode")
s:addDisplayList("End of SSP", "AUTO DROP REMAINING SEEDS", "TapTap_endseeds")
s:addDisplayList("Settings", H ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "TapTap_settingsstatus")
pcall(function()
  addCategory(z, "Rocket")
end)
local q = pcall(function()
  addIntoModule(s:generateJSON(), z)
end)
if not q then
  addIntoModule(s:generateJSON())
end
local l = 200
local C = 800
local N = 1800
local y = 1800
local j = 1800
local Z = 250
local w = 350
local E = 450
local m = 2
local L = 4
local d = 300
local p = 140
local c = 300
local M = 1200
local r = 6000
local I = 2
local G = 150
local R = false
local J = h
local Y = n
local f = T
local i = 0
local U = false
local zT = k
local tT = V
local ST = e
local oT = K
local BT = e
local vT = K
local QT = D
local FT = a
local uT = A
local HT = P
local WT = X
local bT = HT
local xT = WT
local hT = false
local nT = 0
local TT = nil
local kT, VT = nil, nil
local eT, KT = 0, 0
local PT = "STOPPED"
local function XT()
  if H == nil then
    return false
  end
  local z, t = pcall(function()
    H:set("burstTapIntervalMs", J)
    H:set("burstTaps", Y)
    H:set("burstPostAckPause", f)
    H:set("dropDelay", zT)
    H:set("minSSP", tT)
    H:set("tapItemID", x)
    H:set("packStartX", BT)
    H:set("packStartY", vT)
    H:set("packXInputSet", FT and 1 or 0)
    H:set("packYInputSet", uT and 1 or 0)
    H:set("packPositionSet", QT and 1 or 0)
    H:set("dropStartX", HT)
    H:set("dropStartY", WT)
    H:save()
  end)
  if not z then
    if not W then
      W = true
      pcall(function()
        growtopia["notify"]("TapTap settings could not be saved: " .. tostring(t))
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
local aT = false
local AT = false
local DT = false
local gT = false
local OT = false
local sT, qT = nil, nil
local function lT()
  OT = false
  sT, qT = nil, nil
end
local function CT(z, t)
  return OT and (sT == z and qT == t)
end
local function NT(z)
  if type(z) ~= "string" then
    return false
  end
  local t = (z:lower()):gsub("`.", "")
  t = (t:gsub("[^%a%d%s]", " ")):gsub("%s+", " ")
  local S = t:find("can t drop", 1, true)
    or t:find("cant drop", 1, true)
    or t:find("cannot drop", 1, true)
    or t:find("unable to drop", 1, true)
  local o = t:find("any more", 1, true)
    or t:find("anymore", 1, true)
    or t:find("more items", 1, true)
    or t:find("more seeds", 1, true)
  if S and o then
    return true
  end
  if t:find("drop limit", 1, true) or t:find("maximum dropped", 1, true) or t:find("too many dropped", 1, true) then
    return true
  end
  if
    t:find("too many items", 1, true)
    and (t:find("drop", 1, true) or t:find("here", 1, true) or t:find("ground", 1, true) or t:find("tile", 1, true))
  then
    return true
  end
  return false
end
local yT = nil
local jT = false
local ZT = false
local wT = false
local function ET(z) end
local function mT(z)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(z))
    end)
  end
end
local function LT(z)
  if PT ~= z then
    PT = z
    editValue("TapTap_mode", z)
    ET("TapTap mode: " .. z)
  end
end
local function dT(z, t)
  local S = editToggle or EditToggle
  if S ~= nil then
    pcall(S, z, t)
  end
end
local function pT(z)
  dT("ModFly", z)
  dT("Anticollect", z)
  aT = (z == true)
end
local function cT(z)
  dT("ModFly", z)
  dT("Anticollect", false)
  aT = false
end
local function MT()
  local z = GetLocal or getLocal
  if z == nil then
    return nil
  end
  local t, S = pcall(z)
  if t then
    return S
  end
  return nil
end
local function rT()
  local z = GetWorldName or getCurrentWorldName
  if z == nil then
    return ""
  end
  local t, S = pcall(z)
  if t and type(S) == "string" then
    return S
  end
  return ""
end
local function IT()
  local z = GetInventory or getInventory
  if z == nil then
    return nil
  end
  local t, S = pcall(z)
  if t and type(S) == "table" then
    return S
  end
  return nil
end
local function GT()
  local z = GetTiles or getTiles
  if z == nil then
    return nil
  end
  local t, S = pcall(z)
  if t and type(S) == "table" then
    return S
  end
  return nil
end
local function RT(z, t)
  if type(z) ~= "string" or type(t) ~= "string" then
    return false
  end
  return z:upper() == t:upper()
end
local function JT(z)
  if type(z) ~= "string" or z == "" then
    return false
  end
  return z:upper() ~= "EXIT"
end
local function YT()
  if yT == nil or yT == "" then
    return false
  end
  local z = MT()
  if z == nil then
    return false
  end
  local t = rT()
  if JT(t) then
    if RT(t, yT) then
      wT = true
      return true
    end
    wT = false
    return false
  end
  return wT == true
end
local function fT(z)
  local t = 0
  while R and t < z do
    if not YT() then
      return false
    end
    local z = IT()
    local S = GT()
    if z ~= nil and (S ~= nil and next(S) ~= nil) then
      return true
    end
    Sleep(100)
    t = t + 100
  end
  return false
end
local function iT(z)
  local t = 0
  while R and t < z do
    local z = MT()
    local S = rT()
    if JT(S) and not RT(S, yT) then
      return false
    end
    local o = IT()
    local B = GT()
    if z ~= nil and (o ~= nil and (B ~= nil and next(B) ~= nil)) then
      return true
    end
    Sleep(100)
    t = t + 100
  end
  return false
end
local function UT()
  local z = MT()
  if z == nil then
    return
  end
  local t = z["posX"] // 32
  local S = z["posY"] // 32
  pcall(function()
    FindPath(t, S)
  end)
end
local function zn(z, t)
  t = t or IT()
  if t == nil then
    return 0
  end
  for t, S in pairs(t) do
    if S["id"] == z then
      return S["amount"]
    end
  end
  return 0
end
local function tn(z)
  z = z or IT()
  if z == nil then
    return 0
  end
  for z, t in pairs(z) do
    if t["id"] ~= x and (t["id"] % 2 == 1 and t["amount"] >= l) then
      return t["id"]
    end
  end
  return 0
end
local function Sn()
  local z = IT()
  if z == nil then
    return 0
  end
  for z, t in pairs(z) do
    local S = tonumber(t["id"])
    local o = tonumber(t["amount"]) or 0
    if S ~= nil and (S > 0 and (S ~= x and (S % 2 == 1 and o > 0))) then
      return S
    end
  end
  return 0
end
local function on()
  local z = MT()
  if z == nil then
    return nil, nil
  end
  return z["posX"] // 32, z["posY"] // 32
end
local function Bn(z, t)
  if not R or not YT() then
    return false
  end
  for S = 1, I, 1 do
    if not R or not YT() then
      return false
    end
    local o, B = on()
    if o == nil then
      jT = true
      return false
    end
    if o == z and B == t then
      return true
    end
    local v = pcall(function()
      FindPath(z, t)
    end)
    if not v then
      if S < I then
        Sleep(c)
      end
    else
      local v = 0
      local Q = 0
      local F = o
      local u = B
      while R and v < r do
        if not YT() then
          jT = true
          return false
        end
        local S, o = on()
        if S == nil then
          jT = true
          return false
        end
        if S == z and o == t then
          Sleep(G)
          return true
        end
        if S ~= F or o ~= u then
          F = S
          u = o
          Q = 0
        else
          Q = Q + 100
        end
        if Q >= M then
          break
        end
        Sleep(100)
        v = v + 100
      end
      if S < I then
        Sleep(c)
      end
    end
  end
  LT("WAIT PATH")
  return false
end
local function vn()
  local z = GetObjectList or getObjectList
  if z == nil then
    return {}
  end
  local t, S = pcall(z)
  if t and type(S) == "table" then
    return S
  end
  return {}
end
local function Qn(z)
  if z == nil then
    return nil, nil
  end
  local t = tonumber(z["posX"])
  local S = tonumber(z["posY"])
  if (t == nil or S == nil) and z["pos"] ~= nil then
    t = t or tonumber(z["pos"]["x"])
    S = S or tonumber(z["pos"]["y"])
  end
  return t, S
end
local function Fn(z, t)
  if kT ~= z or VT ~= t then
    kT, VT = z, t
    KT = 0
  end
  KT = KT + 1
  LT("DROPPED " .. (tostring(KT) .. " ON TILE"))
  return KT
end
local function un()
  kT, VT = nil, nil
  eT, KT = 0, 0
end
local function Hn()
  if QT then
    editValue("TapTap_packstart", tostring(BT) .. (", " .. tostring(vT)))
  elseif FT or uT then
    local z = FT and tostring(BT) or "NOT SET"
    local t = uT and tostring(vT) or "NOT SET"
    editValue("TapTap_packstart", z .. (", " .. t))
  else
    editValue("TapTap_packstart", "NOT SET")
  end
end
local function Wn()
  if QT then
    editValue("TapTap_packcurrent", tostring(ST) .. (", " .. tostring(oT)))
  else
    editValue("TapTap_packcurrent", "NOT SET")
  end
end
local function bn(z, t)
  if not R or not QT or not YT() then
    return false
  end
  LT("RETURN PACK")
  if t then
    pT(true)
  else
    cT(true)
  end
  local S = Bn(BT, vT)
  if S then
    ST = BT
    oT = vT
    Wn()
    if z == "SSP" then
      mT("SSP collected - back to Pack Position")
    elseif z == "DROP" then
      mT("Drop finished - back to Pack Position")
    end
  else
    LT("WAIT PACK PATH")
    mT("Cannot return to Pack Position!")
  end
  pT(false)
  aT = false
  return S
end
local function xn()
  Hn()
  if FT and uT then
    QT = true
    ST = BT
    oT = vT
    Hn()
    Wn()
    ET("Manual pack start position set: " .. (BT .. (", " .. vT)))
  end
end
local function hn()
  editValue("TapTap_dropcurrent", tostring(bT) .. (", " .. tostring(xT)))
  editValue("TapTap_droptarget", tostring(bT + 1) .. (", " .. tostring(xT)))
end
local function nn(z, t, S, o)
  if z ~= nil and t ~= nil then
    editValue("TapTap_ssppos", tostring(z) .. (", " .. tostring(t)))
  else
    editValue("TapTap_ssppos", "NONE")
  end
  if S ~= nil and o ~= nil then
    editValue("TapTap_ssppath", tostring(S) .. (", " .. tostring(o)))
  else
    editValue("TapTap_ssppath", "NONE")
  end
end
local function Tn(z, t)
  local S = getTile or GetTile
  if S == nil then
    return nil
  end
  local o, B = pcall(S, z, t)
  if o then
    return B
  end
  return nil
end
local function kn(z, t)
  local S = Tn(z, t)
  if S == nil then
    return false
  end
  return S["collidable"] == true
end
local function Vn()
  local z = MT()
  if z == nil or not R then
    return false
  end
  local t = rT()
  if JT(t) and not RT(t, yT) then
    return false
  end
  local S = z["posX"] // 32
  local o = z["posY"] // 32
  local B = { { ["x"] = S + 1, ["y"] = o }, { ["x"] = S - 1, ["y"] = o }, { ["x"] = S, ["y"] = o - 1 } }
  for z, t in ipairs(B) do
    local B = Tn(t["x"], t["y"])
    if B ~= nil and B["collidable"] ~= true then
      local z = false
      for S = 1, 4, 1 do
        if not R then
          return false
        end
        local o = rT()
        if JT(o) and not RT(o, yT) then
          return false
        end
        pcall(function()
          FindPath(t["x"], t["y"])
        end)
        local B = 0
        while R and B < 500 do
          local S = MT()
          o = rT()
          if JT(o) and not RT(o, yT) then
            return false
          end
          if S ~= nil and (S["posX"] // 32 == t["x"] and S["posY"] // 32 == t["y"]) then
            z = true
            break
          end
          Sleep(100)
          B = B + 100
        end
        if z then
          break
        end
        Sleep(120)
      end
      if z then
        Sleep(p)
        pcall(function()
          FindPath(S, o)
        end)
        local z = 0
        while R and z < 1200 do
          local t = MT()
          if t ~= nil and (t["posX"] // 32 == S and t["posY"] // 32 == o) then
            Sleep(p)
            return true
          end
          Sleep(100)
          z = z + 100
        end
        return true
      end
    end
  end
  pcall(function()
    FindPath(S, o)
  end)
  Sleep(p)
  return false
end
local function en()
  local z = MT()
  if z == nil or not YT() then
    return {}, 0
  end
  local t = z["posX"] // 32
  local S = z["posY"] // 32
  local o = {}
  local B = 0
  for z, v in pairs(vn()) do
    local Q = tonumber(v["itemid"])
    if Q == x then
      B = B + 1
      local z, Q = Qn(v)
      if z ~= nil and Q ~= nil then
        local B = math["floor"](z / 32)
        local F = math["floor"](Q / 32)
        table["insert"](
          o,
          {
            ["object"] = v,
            ["objectX"] = B,
            ["objectY"] = F,
            ["pixelX"] = z,
            ["pixelY"] = Q,
            ["distance"] = math["abs"](t - B) + math["abs"](S - F),
          }
        )
      end
    end
  end
  table["sort"](o, function(z, t)
    return z["distance"] < t["distance"]
  end)
  if #o > 0 then
    nn(o[1]["objectX"], o[1]["objectY"], nil, nil)
  elseif B == 0 then
    nn(nil, nil, nil, nil)
  end
  return o, B
end
local function Kn(z)
  return {
    { z["objectX"], z["objectY"] },
    { z["objectX"] - 1, z["objectY"] },
    { z["objectX"] + 1, z["objectY"] },
    { z["objectX"], z["objectY"] - 1 },
    { z["objectX"] - 1, z["objectY"] - 1 },
    { z["objectX"] + 1, z["objectY"] - 1 },
  }
end
local function Pn(z)
  R = false
  pT(false)
  aT = false
  AT = false
  DT = false
  nn(nil, nil, nil, nil)
  local t = EditToggle or editToggle
  if t ~= nil then
    pcall(t, "TapTap_enable", false)
  end
  if z then
    LT("DONE - SEEDS DROPPED")
    mT("No SSP remains. Final seed drop finished; script stopped.")
    ET("No dropped SSP remains; remaining seed stacks were dropped and verified.")
  else
    LT("NO SSP - STOPPED")
    mT("No SSP found and no seeds remain. Script stopped.")
    ET("No dropped SSP or remaining seed stacks found. TapTap stopped.")
  end
end
local function Xn()
  if not R or not YT() then
    return false
  end
  local z = GetObjectList or getObjectList
  if type(z) ~= "function" then
    return false
  end
  local t, S = pcall(z)
  if not t or type(S) ~= "table" then
    return false
  end
  for z, t in pairs(S) do
    if tonumber(t["itemid"]) == x then
      return false
    end
  end
  return true
end
local function an(z)
  if not R or not YT() then
    return
  end
  if z == nil or z["object"] == nil then
    return
  end
  local t = tonumber(z["object"]["id"])
  if t == nil then
    return
  end
  pcall(function()
    if R and YT() then
      SendPacketRaw(false, { ["type"] = 11, ["value"] = t, ["x"] = z["pixelX"], ["y"] = z["pixelY"] })
    end
  end)
end
local function An(z, t, S, o)
  if not R or not YT() then
    return false
  end
  nn(z["objectX"], z["objectY"], t, S)
  for B = 1, I, 1 do
    if not R or not YT() then
      return false
    end
    local v, Q = on()
    if v == nil then
      jT = true
      return false
    end
    local F = false
    local u = pcall(function()
      FindPath(t, S)
    end)
    if u then
      local B = 0
      local u = 0
      local H = v
      local W = Q
      while R and B < r do
        if not YT() then
          jT = true
          return false
        end
        if zn(x) > o then
          return true
        end
        local v, Q = on()
        if v == nil then
          jT = true
          return false
        end
        local b = math["abs"](v - z["objectX"]) <= 1 and math["abs"](Q - z["objectY"]) <= 1
        if b and not F then
          an(z)
          F = true
        end
        if v == t and Q == S then
          if not F then
            an(z)
            F = true
          end
          local t = 0
          while R and t < 500 do
            if zn(x) > o then
              return true
            end
            Sleep(50)
            t = t + 50
          end
          return false
        end
        if v ~= H or Q ~= W then
          H = v
          W = Q
          u = 0
        else
          u = u + 100
        end
        if u >= M then
          break
        end
        Sleep(100)
        B = B + 100
      end
    end
    if B < I then
      Sleep(c)
    end
  end
  return false
end
local function Dn()
  local z, t = en()
  if t == 0 then
    return false, "NO_SSP"
  end
  if #z == 0 then
    LT("WAIT SSP DATA")
    ET("SSP object(s) exist, but their position data could not be read.")
    return false
  end
  local S = zn(x)
  LT("COLLECT SSP")
  cT(true)
  for z, t in ipairs(z) do
    if not R or not YT() then
      cT(false)
      return false
    end
    editValue("TapTap_ssppos", tostring(t["objectX"]) .. (", " .. tostring(t["objectY"])))
    ET("Testing SSP object at " .. (t["objectX"] .. (", " .. t["objectY"])))
    local o = Kn(t)
    for z, o in ipairs(o) do
      local B = o[1]
      local v = o[2]
      if An(t, B, v, S) then
        local z = bn("SSP", false)
        if z then
          nn(t["objectX"], t["objectY"], BT, vT)
        end
        return z
      end
      if not R or not YT() then
        cT(false)
        return false
      end
    end
  end
  cT(false)
  local o = z[1]
  editValue("TapTap_ssppos", tostring(o["objectX"]) .. (", " .. tostring(o["objectY"])))
  editValue("TapTap_ssppath", "NO WORKING PATH")
  local B = (PT == "WAIT SSP PATH")
  LT("WAIT SSP PATH")
  if not B then
    mT("Path not found!")
  end
  ET("Found " .. (t .. " SSP object(s), but actual FindPath could not reach any candidate."))
  return false
end
local function gn(z)
  local t = IT()
  if not t then
    return false
  end
  local S = zn(x, t)
  if S <= 0 or S < tT or tn(t) ~= 0 then
    return false
  end
  local o = 0
  local B = math["min"](U and 1 or Y, S, (S - tT) + 1)
  local v, Q = ST, oT
  for t = 1, B, 1 do
    if not R or z ~= i then
      return false
    end
    if not YT() then
      jT = true
      return false
    end
    local S = MT()
    if not S or S["posX"] // 32 ~= v or S["posY"] // 32 ~= Q or ST ~= v or oT ~= Q then
      break
    end
    local F, u = pcall(
      SendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = x, ["x"] = S["posX"], ["y"] = S["posY"], ["px"] = v, ["py"] = Q }
    )
    if not F or u == false then
      break
    end
    o = o + 1
    if t < B then
      Sleep(J)
    end
  end
  if o == 0 then
    return false
  end
  local F = 0
  while R and z == i do
    if not YT() then
      jT = true
      return false
    end
    t = IT()
    if t and zn(x, t) < S then
      U = false
      Sleep(f)
      return R and z == i
    end
    if F >= j then
      break
    end
    Sleep(20)
    F = F + 20
  end
  if R and z == i then
    U = true
    LT("WAIT SERVER")
    Sleep(Z)
  end
  return false
end
local function On(z, t)
  if not R or not YT() then
    return false, "WORLD_LOST"
  end
  AT = false
  DT = true
  SendPacket(2, "action|drop\nitemID|" .. z)
  local S = 0
  local o = 25
  while R and S < N do
    if CT(bT + 1, xT) then
      DT = false
      AT = false
      return false, "TILE_FULL"
    end
    if not YT() then
      jT = true
      DT = false
      return false, "WORLD_LOST"
    end
    if AT then
      break
    end
    Sleep(o)
    S = S + o
  end
  if not R then
    DT = false
    return false, "STOPPED"
  end
  if not AT then
    DT = false
    LT("WAIT SERVER")
    Sleep(Z)
    return false, "NO_DIALOG"
  end
  AT = false
  DT = false
  if CT(bT + 1, xT) then
    return false, "TILE_FULL"
  end
  if not R or not YT() then
    return false, "WORLD_LOST"
  end
  SendPacket(
    2,
    "action|dialog_return\n" .. ("dialog_name|drop_item\n" .. ("itemID|" .. (z .. ("|\n" .. ("count|" .. t)))))
  )
  return true, "CONFIRM_SENT"
end
local function sn(z, t)
  local S = 0
  local o = 50
  while R and S < y do
    if not YT() then
      return false, "WORLD_LOST"
    end
    local B = zn(z)
    if B < t then
      if S < zT then
        Sleep(zT - S)
      end
      return true, B
    end
    if CT(bT + 1, xT) then
      return false, "TILE_FULL"
    end
    Sleep(o)
    S = S + o
  end
  return false, zn(z)
end
local function qn()
  if not R or not YT() then
    return false
  end
  local z = MT()
  if z == nil then
    jT = true
    return false
  end
  if z["isLeft"] == false then
    return true
  end
  local t = z["posX"] // 32
  local S = z["posY"] // 32
  local o = t - 1
  local B = S
  local v = Tn(o, B)
  if v == nil or v["collidable"] == true then
    ET("Cannot safely face right because the left-side turn tile is blocked.")
    return false
  end
  if not Bn(o, B) then
    return false
  end
  Sleep(60)
  if not R then
    return false
  end
  if not Bn(t, S) then
    return false
  end
  Sleep(60)
  local Q = MT()
  if Q ~= nil and Q["isLeft"] ~= nil then
    ET("Safe facing check: isLeft=" .. tostring(Q["isLeft"]))
    return Q["isLeft"] == false
  end
  return true
end
local function ln()
  if not R or not YT() then
    return false
  end
  local z = bT - 1
  local t = xT
  ET(
    "Drop target full at " .. (
        (bT + 1) .. (", " .. (xT .. (". Trying next standing tile to the left: " .. (z .. (", " .. t)))))
      )
  )
  if Bn(z, t) then
    bT = z
    xT = t
    hn()
    ET("Moved left for next drop. Stand: " .. (bT .. (", " .. (xT .. (" | Target: " .. ((bT + 1) .. (", " .. xT)))))))
    return true
  end
  local S = HT
  local o = xT - 1
  ET("No path to the left. Trying next row at start X: " .. (S .. (", " .. o)))
  if Bn(S, o) then
    bT = S
    xT = o
    hn()
    mT("Next Drop Row = (" .. (bT .. (", " .. (xT .. ")"))))
    ET("Moved to next drop row. Stand: " .. (bT .. (", " .. (xT .. (" | Target: " .. ((bT + 1) .. (", " .. xT)))))))
    return true
  end
  LT("WAIT DROP PATH")
  mT("No drop path found!")
  ET("Could not move left and could not reach next row start at " .. (S .. (", " .. o)))
  return false
end
local function Cn(z, t, S)
  local o = 0
  while R and o < S do
    if not YT() then
      return false, "WORLD_LOST"
    end
    if IT() == nil then
      return false, "NO_INVENTORY"
    end
    if zn(z) < t then
      return true, "ACCEPTED"
    end
    Sleep(50)
    o = o + 50
  end
  return zn(z) < t, "TIMEOUT"
end
local function Nn(z, t)
  if IT() == nil then
    return "NO_INVENTORY"
  end
  local S = zn(z)
  if S < t then
    return "CHANGED"
  end
  for o = 1, m, 1 do
    if not R then
      return "STOPPED"
    end
    if not YT() then
      return "WORLD_LOST"
    end
    if IT() == nil then
      return "NO_INVENTORY"
    end
    if zn(z) < S then
      return "SUCCESS"
    end
    aT = true
    LT(o == 1 and "DROP - CHECK INVENTORY" or "RETRY DROP 2/2 - SAME TILE")
    gT = true
    local B, v = On(z, t)
    if B then
      local t, o = sn(z, S)
      if t then
        gT = false
        return "SUCCESS"
      end
      v = o
    end
    gT = false
    if not R then
      return "STOPPED"
    end
    if v == "WORLD_LOST" or not YT() then
      return "WORLD_LOST"
    end
    if IT() == nil then
      return "NO_INVENTORY"
    end
    if zn(z) < S then
      return "SUCCESS"
    end
    if v == "TILE_FULL" or CT(bT + 1, xT) then
      return "REJECTED"
    end
    LT(o == 1 and "WAIT DROP ACK - RETRY" or "WAIT DROP ACK - SHIFT")
    local Q, F = Cn(z, S, o == 1 and w or E)
    if Q then
      return "SUCCESS"
    end
    if F == "WORLD_LOST" then
      return "WORLD_LOST"
    end
    if F == "NO_INVENTORY" then
      return "NO_INVENTORY"
    end
  end
  return "REJECTED"
end
local function yn(z)
  local t = false
  local S = true
  local o = 0
  local function B()
    hT = true
    gT = false
    LT("DROP FAILED - MOVE LEFT")
    if not ln() then
      LT("WAIT LEFT PATH - NO DROP")
      return false
    end
    hT = false
    lT()
    t, S = true, true
    o = o + 1
    return true
  end
  while R do
    if not YT() then
      jT = true
      return false
    end
    if IT() == nil then
      LT("WAIT INVENTORY")
      return false
    end
    local v = TT
    if v ~= nil then
      local t = zn(v)
      if t <= 0 or (not z and t < l) then
        TT = nil
        v = nil
      end
    end
    if v == nil then
      v = z and Sn() or tn()
    end
    if v == 0 then
      return true
    end
    if hT then
      if not B() then
        return false
      end
    elseif not t then
      if not Bn(bT, xT) then
        LT("WAIT DROP PATH")
        mT("Path not found!")
        return false
      end
      t = true
      S = true
    end
    local Q, F = bT + 1, xT
    if kn(Q, F) or CT(Q, F) then
      TT = v
      if not B() then
        return false
      end
    else
      if S then
        if not qn() then
          LT("WAIT DROP FACING")
          mT("Cannot face right safely!")
          return false
        end
        S = false
      end
      local t = zn(v)
      local o = z and math["min"](l, t) or l
      if o <= 0 or t < o then
        TT = nil
        Sleep(50)
      else
        local z = Nn(v, o)
        if z == "SUCCESS" then
          TT = nil
          nT = 0
          Fn(Q, F)
        elseif z == "REJECTED" then
          TT = v
          nT = nT + 1
          if not B() then
            return false
          end
        elseif z == "CHANGED" then
          TT = nil
        elseif z == "NO_INVENTORY" then
          LT("WAIT INVENTORY")
          return false
        elseif z == "WORLD_LOST" then
          jT = true
          return false
        else
          return false
        end
      end
    end
    if nT >= L then
      LT("SERVER SLOW - DROP COOLDOWN")
      Sleep(1500)
      nT = 0
      return false
    end
    if o >= 30 then
      LT("DROP SHIFT BREAK")
      Sleep(400)
      return false
    end
    Sleep(30)
  end
  return false
end
local function jn()
  local z = MT()
  if z == nil then
    ET("Cannot set pack position: player not loaded.")
    return
  end
  BT = z["posX"] // 32
  vT = z["posY"] // 32
  ST = BT
  oT = vT
  FT = true
  uT = true
  QT = true
  editValue("TapTap_packx", tostring(BT))
  editValue("TapTap_packy", tostring(vT))
  Hn()
  Wn()
  XT()
  mT("Pack Position = (" .. (BT .. (", " .. (vT .. ")"))))
  ET("Pack start position set: " .. (BT .. (", " .. vT)))
end
local function Zn()
  local z = MT()
  if z == nil then
    ET("Cannot set drop position: player not loaded.")
    return
  end
  HT = z["posX"] // 32
  WT = z["posY"] // 32
  bT = HT
  xT = WT
  un()
  lT()
  gT = false
  hT = false
  nT = 0
  editValue("TapTap_dropx", tostring(HT))
  editValue("TapTap_dropy", tostring(WT))
  hn()
  XT()
  mT("Drop Position = (" .. (HT .. (", " .. (WT .. ")"))))
  ET("Drop start position set: " .. (HT .. (", " .. WT)))
end
local function wn()
  if not R then
    return false
  end
  if YT() then
    if jT or ZT then
      pT(false)
      LT("RESUMING")
      Sleep(d)
      if not R then
        return false
      end
      local z = rT()
      if JT(z) and not RT(z, yT) then
        wT = false
        return false
      end
      if not fT(3000) then
        LT("RESUMING")
        Sleep(100)
        return false
      end
      LT("RESUME MOVE")
      Vn()
      if not R then
        return false
      end
      z = rT()
      if JT(z) and not RT(z, yT) then
        wT = false
        return false
      end
      jT = false
      ZT = false
      wT = true
      mT("TapTap resumed automatically.")
    end
    return true
  end
  if jT and ZT then
    pT(false)
    LT("RESUMING")
    Sleep(d)
    if not R then
      return false
    end
    if iT(4000) then
      local z = rT()
      if JT(z) and not RT(z, yT) then
        wT = false
        LT("PAUSED - WAIT WORLD")
        return false
      end
      wT = true
      LT("RESUME MOVE")
      Vn()
      if not R then
        return false
      end
      z = rT()
      if JT(z) and not RT(z, yT) then
        wT = false
        LT("PAUSED - WAIT WORLD")
        return false
      end
      jT = false
      ZT = false
      mT("TapTap resumed automatically.")
      return true
    end
  end
  if not jT then
    jT = true
    mT("TapTap paused - return to " .. tostring(yT))
  end
  wT = false
  AT = false
  DT = false
  pT(false)
  LT("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
function onVariant(z, t)
  if z ~= nil then
    if R and (z["v1"] == "OnSpawn" and type(z["v2"]) == "string") then
      local t = z["v2"]:find("type|local", 1, true) ~= nil
      if not t then
        local S = tonumber(z["v2"]:match("netID|(%d+)"))
        local o = MT()
        if S ~= nil and o ~= nil then
          t = tonumber(o["netID"]) == S
        end
      end
      if t and (jT or not wT) then
        ZT = true
        jT = true
      end
    end
    if R and (jT and z["v1"] == "OnSetPos") then
      ZT = true
    end
    if R and gT then
      local t = true
      if z["v1"] == "OnTalkBubble" then
        local S = MT()
        if S ~= nil and (S["netID"] ~= nil and tonumber(z["v2"]) ~= tonumber(S["netID"])) then
          t = false
        end
      end
      if t then
        for t = 2, 7, 1 do
          local S = z["v" .. tostring(t)]
          if NT(S) then
            sT = bT + 1
            qT = xT
            OT = true
            ET("Server says drop tile is full: " .. (tostring(sT) .. (", " .. tostring(qT))))
            break
          end
        end
      end
    end
    if z["v1"] == "OnDialogRequest" and type(z["v2"]) == "string" then
      if z["v2"]:find("drop_item", 1, true) then
        if R and DT then
          AT = true
        end
        return true
      end
    end
  end
  return false
end
function onSendPacket(z, t)
  if R and type(t) == "string" then
    local z = t:find("action|quit", 1, true) ~= nil
    local S = t:find("action|join_request", 1, true) ~= nil
    if z or S then
      wT = false
      jT = true
      ZT = false
      AT = false
      DT = false
      pT(false)
      LT("PAUSED - WAIT WORLD")
    end
  end
  return false
end
function onSendPacketRaw(z)
  if R and (aT and z ~= nil) then
    if tonumber(z["type"]) == 11 then
      ET("Blocked item collect packet during protected drop travel.")
      return true
    end
  end
  return false
end
function onGamePacket(z)
  if z ~= nil and (z["type"] == 26 and R) then
    if not jT then
      mT("TapTap paused - disconnected.")
    end
    jT = true
    ZT = false
    wT = false
    AT = false
    DT = false
    pT(false)
    LT("PAUSED - WAIT WORLD")
    ET("Disconnect detected. TapTap is paused until you manually return to the target world.")
  end
  return false
end
local function En(z)
  z = tostring(z or "")
  z = z:gsub("\n", "\r\n")
  z = z:gsub("([^%w%-_%.~])", function(z)
    return string["format"]("%%%02X", string["byte"](z))
  end)
  return z
end
local function mn()
  local z = ""
  if type(getDiscordID) == "function" then
    local t, S = pcall(getDiscordID)
    if t and S ~= nil then
      z = tostring(S)
    end
  elseif getDiscordID ~= nil then
    z = tostring(getDiscordID)
  end
  z = ((tostring(z or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if z == "" or z == "nil" or z == "0" then
    local t = GetLocal or getLocal
    if t ~= nil then
      local S, o = pcall(t)
      if S and (o ~= nil and o["name"] ~= nil) then
        z = tostring(o["name"])
        z = (z:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  if z == "nil" or z == "0" then
    return ""
  end
  return z
end
local function Ln(z)
  pcall(editValue, "TapTap_licensestatus", z)
end
local dn = {
  ["DISABLED"] = { "DISABLED", "License disabled." },
  ["WRONG_PRODUCT"] = { "WRONG PRODUCT", "This license is for another script." },
  ["BOUND_TO_OTHER_USER"] = { "BOUND TO OTHER USER", "License is bound to another user." },
  ["INVALID_KEY"] = { "INVALID KEY", "Invalid license key." },
  ["BAD_KEY_FORMAT"] = { "BAD KEY FORMAT", "License key format is invalid." },
  ["NO_ID"] = { "NO CLIENT ID", "Client ID is unavailable." },
}
local function pn(z)
  if not z:match("^[A-Z]%d%d%d%d%d%d%d$") then
    return false, "INVALID KEY FORMAT", "License must be 1 letter + 7 numbers, for example A1234567."
  end
  local o = mn()
  if o == "" then
    return false, "NO CLIENT ID", "Could not read a client ID. Enter the game first and try again."
  end
  local B = t .. ("?key=" .. (En(z) .. ("&id=" .. (En(o) .. ("&product=" .. En(S))))))
  local v, Q = pcall(fetch, B)
  if not v then
    return false, "SERVER ERROR", "License server request failed."
  end
  Q = (tostring(Q or "")):match("^%s*(.-)%s*$")
  local F = Q:match("DENY|([A-Z_]+)")
  if F then
    local z = dn[F]
    if z then
      return false, z[1], z[2]
    end
    return false, "DENIED", "License denied by server."
  end
  if Q:find("OK|PERMANENT", 1, true) then
    return true, "VERIFIED - PERMANENT"
  end
  if Q == "" then
    return false, "NO RESPONSE", "License server gave no response."
  end
  return false, "CHECK FAILED", "License check failed."
end
local cn, Mn
local rn, In = false, false
local function Gn()
  In = true
  dT("TapTap_enable", false)
  In = false
end
local function Rn(z)
  R = true
  i = i + 1
  U = false
  yT = z
  jT = false
  ZT = false
  wT = true
  un()
  lT()
  gT = false
  hT = false
  nT = 0
  TT = nil
  LT("STARTING")
  mT("TapTap started.")
end
local function Jn()
  R = false
  i = i + 1
  U = false
  cn = nil
  aT = false
  AT = false
  DT = false
  gT = false
  hT = false
  nT = 0
  TT = nil
  lT()
  pT(false)
  LT("STOPPED")
  jT = false
  ZT = false
  wT = false
  mT("TapTap stopped safely.")
end
local function Yn(z)
  z["key"] = B
  z["revision"] = v
  Mn = z
  if rn then
    return
  end
  rn = true
  runThread(function()
    while Mn do
      local z = Mn
      Mn = nil
      if z["revision"] == v and (not z["world"] or cn == z) then
        Ln("CHECKING...")
        local t, S, o = pn(z["key"])
        if z["revision"] == v then
          Ln(S)
          if t then
            local t = F(z["key"])
            if z["manual"] then
              mT(t and "License verified and saved." or "License verified. Could not save it.")
            end
          elseif z["manual"] or cn == z then
            mT(o)
          end
          if cn == z then
            cn = nil
            if t and (QT and (RT(rT(), z["world"]) and MT())) then
              Rn(z["world"])
            else
              if t then
                mT("Return to the farming world and check your Pack Position.")
              end
              Gn()
              LT("STOPPED")
            end
          end
        end
      end
    end
    rn = false
  end)
end
local function fn()
  if not cn then
    return
  end
  cn = nil
  Gn()
  LT("STOPPED")
end
local function Un(z)
  if type(z) == "table" then
    z = z["id"] or z["itemID"] or z["itemid"] or z["value"] or z["name"]
  end
  local t = tonumber(z)
  if not t and type(z) == "string" then
    t = tonumber(z:match("%((%d+)%)"))
    local S = findItemID or (growtopia and growtopia["getItemID"])
    if not t and type(S) == "function" then
      local o, B = pcall(S, z)
      if o then
        t = tonumber(B)
      end
    end
  end
  if not t or t < 1 or t > 65535 or t % 1 ~= 0 then
    return false
  end
  if t == x then
    return true
  end
  if R or cn then
    mT("Stop the script before changing the item to tap.")
    return true
  end
  x = t
  XT()
  return true
end
function onValue(z, t, S)
  if t == "TapTap_itempicker" then
    Un(S)
    return
  end
  if t == "TapTap_enable" then
    if In then
      return
    end
    if S ~= true then
      if R or cn then
        Jn()
      end
      return
    end
    if R or cn then
      return
    end
    local z = rT()
    if not QT or not JT(z) or not MT() then
      Gn()
      mT(not QT and "Set Pack Position first." or "Enter the farming world first, then press Start.")
      return
    end
    cn = { ["world"] = z }
    LT("CHECKING LICENSE")
    Yn(cn)
    return
  end
  if t == "TapTap_licensekey" then
    local z = Q(S)
    if z ~= B then
      B = z
      v = v + 1
      fn()
      Ln("NOT VERIFIED")
    end
    return
  end
  if t == "TapTap_verifylicense" then
    if not cn then
      Yn({ ["manual"] = true })
    end
    return
  end
  if t == "TapTap_clearlicense" then
    B = ""
    v = v + 1
    fn()
    local z = F("")
    pcall(editValue, "TapTap_licensekey", "")
    Ln("NOT VERIFIED")
    mT(z and "Saved license cleared." or "Could not update saved license storage.")
    return
  end
  if t == "TapTap_delay" then
    local z = tonumber(S)
    if z ~= nil then
      if z < 1 then
        z = 1
      end
      J = math["floor"](z)
      XT()
      ET("Pack Delay: " .. (J .. " ms"))
    end
    return
  end
  if t == "TapTap_bursttaps" then
    local z = tonumber(S)
    if z then
      Y = math["max"](1, math["min"](25, math["floor"](z)))
      XT()
    end
    return
  end
  if t == "TapTap_burstpause" then
    local z = tonumber(S)
    if z then
      f = math["max"](1, math["min"](10000, math["floor"](z)))
      XT()
    end
    return
  end
  if t == "TapTap_dropdelay" then
    local z = tonumber(S)
    if z ~= nil then
      z = math["floor"](z)
      if z < 200 then
        z = 200
      end
      if z > 500 then
        z = 500
      end
      zT = z
      XT()
      ET("Drop Delay: " .. (zT .. " ms"))
    end
    return
  end
  if t == "TapTap_minssp" then
    local z = tonumber(S)
    if z ~= nil then
      z = math["floor"](z)
      if z < 0 then
        z = 0
      end
      if z > 200 then
        z = 200
      end
      tT = z
      XT()
      ET("Minimum SSP Threshold: " .. tT)
    end
    return
  end
  if t == "TapTap_packx" then
    local z = tonumber(S)
    if z ~= nil then
      BT = math["floor"](z)
      FT = true
      xn()
      XT()
    end
    return
  end
  if t == "TapTap_packy" then
    local z = tonumber(S)
    if z ~= nil then
      vT = math["floor"](z)
      uT = true
      xn()
      XT()
    end
    return
  end
  if t == "TapTap_setpack" then
    jn()
    return
  end
  if t == "TapTap_dropx" then
    local z = tonumber(S)
    if z ~= nil then
      HT = math["floor"](z)
      bT = HT
      xT = WT
      un()
      lT()
      gT = false
      hT = false
      nT = 0
      TT = nil
      hn()
      XT()
    end
    return
  end
  if t == "TapTap_dropy" then
    local z = tonumber(S)
    if z ~= nil then
      WT = math["floor"](z)
      bT = HT
      xT = WT
      un()
      lT()
      gT = false
      hT = false
      nT = 0
      TT = nil
      hn()
      XT()
    end
    return
  end
  if t == "TapTap_setdrop" then
    Zn()
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(setOnValue, "TapTap_itempicker", function(...)
    for z = select("#", ...), 1, -1 do
      if Un(select(z, ...)) then
        return
      end
    end
  end)
end
runThread(function()
  pT(false)
  LT("STOPPED")
  if B ~= "" and (not cn and not rn) then
    Yn({})
  end
  while true do
    if R then
      if not wn() then
        Sleep(200)
      else
        local z = 400
        local t = tn()
        if t ~= 0 then
          LT("DROP")
          pT(true)
          local z = yn()
          if z and (R and YT()) then
            bn("DROP", true)
          end
        else
          LT("GACHA")
          pT(false)
          local t = true
          if zn(x) < tT then
            local z, S = Dn()
            if z then
              t = false
              Sleep(200)
            elseif S == "NO_SSP" then
              t = false
              LT("VERIFY NO SSP")
              Sleep(250)
              if R and (YT() and Xn()) then
                if IT() == nil then
                  LT("WAIT INVENTORY")
                elseif Sn() ~= 0 then
                  LT("FINAL SEED DROP")
                  pT(true)
                  local z = yn(true)
                  if z and (R and YT()) then
                    bn("DROP", true)
                    if R and YT() then
                      Pn(true)
                    end
                  end
                else
                  Pn(false)
                end
              else
                LT("WAIT SSP DATA")
              end
              Sleep(150)
            else
              if not YT() then
                jT = true
              end
              t = false
              Sleep(500)
            end
          end
          if t and R then
            local t = i
            local S, o = on()
            if S and ((S == ST and o == oT or Bn(ST, oT)) and (R and (t == i and gn(t)))) then
              z = 0
            end
          end
        end
        if z > 0 then
          Sleep(z)
        end
      end
    else
      Sleep(200)
    end
  end
end)
ET(z .. " loaded.")
