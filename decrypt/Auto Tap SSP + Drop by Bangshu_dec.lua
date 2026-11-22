setMinimum("6.1.2")
local o = "taptap_drop_ssp_v32_settings.json"
local t = nil
local A = false
do
  local A, v = pcall(require, "preferences")
  if not A or v == nil then
    v = Preferences
  end
  if v ~= nil and type(v["new"]) == "function" then
    local A, p = pcall(function()
      return v:new(o)
    end)
    if A and p ~= nil then
      t = p
      pcall(function()
        t:load()
      end)
    end
  end
end
local function v(o, A, v, p)
  local c = A
  if t ~= nil then
    local v, p = pcall(function()
      return t:get(o, A)
    end)
    if v and tonumber(p) ~= nil then
      c = tonumber(p)
    end
  end
  c = math["floor"](c)
  if v ~= nil then
    c = math["max"](v, c)
  end
  if p ~= nil then
    c = math["min"](p, c)
  end
  return c
end
local p = v("packDelay", 10, 1, 100000)
local c = v("dropDelay", 500, 200, 500)
local s = v("minSSP", 25, 0, 200)
local g = v("packStartX", 0)
local i = v("packStartY", 0)
local f = v("dropStartX", 2)
local z = v("dropStartY", 32)
local E = v("packXInputSet", 0, 0, 1) == 1
local S = v("packYInputSet", 0, 0, 1) == 1
local M = v("packPositionSet", 0, 0, 1) == 1 and (E and S)
local H = "NOT SET"
if M then
  H = tostring(g) .. (", " .. tostring(i))
elseif E or S then
  H = (E and tostring(g) or "NOT SET") .. (", " .. (S and tostring(i) or "NOT SET"))
end
local V = M and (tostring(g) .. (", " .. tostring(i))) or "NOT SET"
local B =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local r = "SSP"
local X = "ssp_license_key"
local y = "AutoOpenSSPLicense"
local Q = "license_key"
local function D(o)
  return ((tostring(o or "")):gsub("%s+", "")):upper()
end
local function x(o)
  return (D(o)):match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
end
local u = nil
local function e()
  local o = pcall(function()
    local o = nil
    if type(require) == "function" then
      local t, A = pcall(require, "preferences")
      if t and A ~= nil then
        o = A
      end
    end
    if o == nil and type(Preferences) == "table" then
      o = Preferences
    end
    if o == nil then
      return
    end
    if type(o["new"]) == "function" then
      u = o:new(y) or o
    else
      u = o
    end
    if u ~= nil and type(u["load"]) == "function" then
      u:load()
    end
  end)
  if not o then
    u = nil
  end
end
e()
local b = ""
if t ~= nil then
  local o, A = pcall(function()
    return t:get(X, "")
  end)
  if o then
    b = D(A)
  end
end
if u ~= nil and type(u["get"]) == "function" then
  local o, t = pcall(function()
    return u:get(Q, "")
  end)
  if o and (t ~= nil and tostring(t) ~= "") then
    b = D(t)
  end
end
local T = false
local F = 0
local O = 0
local w = false
local C = false
local k = "NOT VERIFIED"
local function h()
  local o = false
  local A = D(b)
  if u ~= nil then
    local t, v = pcall(function()
      if u:set(Q, A) == false then
        return false
      end
      return u:save()
    end)
    if t and v ~= false then
      o = true
    end
  end
  if t ~= nil then
    local v, p = pcall(function()
      if t:set(X, A) == false then
        return false
      end
      return t:save()
    end)
    if v and p ~= false then
      o = true
    end
  end
  return o
end
local a = UserInterface["new"]("Auto Open SSP V1", "Rocket")
a:addLabelApp("Auto Open SSP V1", "Bolt")
a:addInputString("License Key", b, "A1234567", "A1234567", nil, "SSP_licensekey")
a:addButton("Verify License", "SSP_verifylicense")
a:addButton("Clear Saved License", "SSP_clearlicense")
a:addDisplayList("License Status", "NOT VERIFIED", "SSP_licensestatus")
a:addDisplayList("License Detail", "Press Verify License", "SSP_licensedetail")
a:addDisplayList("License Request", "PRODUCT SSP | NOT CHECKED", "SSP_licenserequest")
a:addToggle("Start / Stop", false, "TapTap_enable")
a:addInputInt("Pack Delay", tostring(p), "ms", "10", nil, "TapTap_delay")
a:addSlider("Drop Delay", 200, 500, c, 10, false, "TapTap_dropdelay")
a:addInputInt("Minimum SSP Threshold", tostring(s), "SSP", "25", nil, "TapTap_minssp")
a:addInputInt("Pack Position X", tostring(g), "X", "0", nil, "TapTap_packx")
a:addInputInt("Pack Position Y", tostring(i), "Y", "0", nil, "TapTap_packy")
a:addButton("Set Pack Position = Current Tile", "TapTap_setpack")
a:addDisplayList("Selected Pack Position", H, "TapTap_packstart")
a:addDisplayList("Current Pack Position", V, "TapTap_packcurrent")
a:addInputInt("Drop Position X", tostring(f), "X", "2", nil, "TapTap_dropx")
a:addInputInt("Drop Position Y", tostring(z), "Y", "32", nil, "TapTap_dropy")
a:addButton("Set Drop Position = Current Tile", "TapTap_setdrop")
a:addDisplayList("Current Drop Position", tostring(f) .. (", " .. tostring(z)), "TapTap_dropcurrent")
a:addDisplayList("Current Drop Target (Right)", tostring(f + 1) .. (", " .. tostring(z)), "TapTap_droptarget")
a:addDisplayList("Detected SSP Position", "NONE", "TapTap_ssppos")
a:addDisplayList("SSP Path Destination", "NONE", "TapTap_ssppath")
a:addDisplayList("Current Mode", "STOPPED", "TapTap_mode")
a:addDisplayList("End of SSP", "AUTO DROP REMAINING SEEDS", "TapTap_endseeds")
a:addDisplayList("Settings", t ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "TapTap_settingsstatus")
pcall(function()
  addCategory("Auto Open SSP V1", "Rocket")
end)
local G = pcall(function()
  addIntoModule(a:generateJSON(), "Auto Open SSP V1")
end)
if not G then
  addIntoModule(a:generateJSON())
end
local I = 5706
local q = 200
local Y = 800
local N = 1800
local U = 1800
local Z = 1800
local P = 250
local m = 350
local d = 450
local n = 2
local K = 4
local W = 300
local R = 140
local J = 300
local l = 1200
local j = 6000
local L = 2
local oO = 150
local tO = false
local AO = p
local vO = c
local pO = s
local cO = g
local sO = i
local gO = g
local iO = i
local fO = M
local zO = E
local EO = S
local SO = f
local MO = z
local HO = SO
local VO = MO
local BO = false
local rO = 0
local XO = nil
local yO, QO = nil, nil
local DO, xO = 0, 0
local uO = "STOPPED"
local function eO()
  if t == nil then
    return false
  end
  local o, v = pcall(function()
    t:set("packDelay", AO)
    t:set("dropDelay", vO)
    t:set("minSSP", pO)
    t:set("packStartX", gO)
    t:set("packStartY", iO)
    t:set("packXInputSet", zO and 1 or 0)
    t:set("packYInputSet", EO and 1 or 0)
    t:set("packPositionSet", fO and 1 or 0)
    t:set("dropStartX", SO)
    t:set("dropStartY", MO)
    t:save()
  end)
  if not o then
    if not A then
      A = true
      pcall(function()
        growtopia["notify"]("TapTap settings could not be saved: " .. tostring(v))
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
local bO = false
local TO = false
local FO = false
local OO = false
local wO = false
local CO, kO = nil, nil
local function hO()
  wO = false
  CO, kO = nil, nil
end
local function aO(o, t)
  return wO and (CO == o and kO == t)
end
local function GO(o)
  if type(o) ~= "string" then
    return false
  end
  local t = (o:lower()):gsub("`.", "")
  t = (t:gsub("[^%a%d%s]", " ")):gsub("%s+", " ")
  local A = t:find("can t drop", 1, true)
    or t:find("cant drop", 1, true)
    or t:find("cannot drop", 1, true)
    or t:find("unable to drop", 1, true)
  local v = t:find("any more", 1, true)
    or t:find("anymore", 1, true)
    or t:find("more items", 1, true)
    or t:find("more seeds", 1, true)
  if A and v then
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
local IO = nil
local qO = false
local YO = false
local NO = false
local function UO(o) end
local function ZO(o)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(o))
    end)
  end
end
local function PO(o)
  if uO ~= o then
    uO = o
    editValue("TapTap_mode", o)
    UO("TapTap mode: " .. o)
  end
end
local function mO(o, t)
  local A = editToggle or EditToggle
  if A ~= nil then
    pcall(A, o, t)
  end
end
local function dO(o)
  mO("ModFly", o)
  mO("Anticollect", o)
  bO = (o == true)
end
local function nO(o)
  mO("ModFly", o)
  mO("Anticollect", false)
  bO = false
end
local function KO()
  local o = GetLocal or getLocal
  if o == nil then
    return nil
  end
  local t, A = pcall(o)
  if t then
    return A
  end
  return nil
end
local function WO()
  local o = GetWorldName or getCurrentWorldName
  if o == nil then
    return ""
  end
  local t, A = pcall(o)
  if t and type(A) == "string" then
    return A
  end
  return ""
end
local function RO()
  local o = GetInventory or getInventory
  if o == nil then
    return nil
  end
  local t, A = pcall(o)
  if t and type(A) == "table" then
    return A
  end
  return nil
end
local function JO()
  local o = GetTiles or getTiles
  if o == nil then
    return nil
  end
  local t, A = pcall(o)
  if t and type(A) == "table" then
    return A
  end
  return nil
end
local function lO(o, t)
  if type(o) ~= "string" or type(t) ~= "string" then
    return false
  end
  return o:upper() == t:upper()
end
local function jO(o)
  if type(o) ~= "string" or o == "" then
    return false
  end
  return o:upper() ~= "EXIT"
end
local function LO()
  if IO == nil or IO == "" then
    return false
  end
  local o = KO()
  if o == nil then
    return false
  end
  local t = WO()
  if jO(t) then
    if lO(t, IO) then
      NO = true
      return true
    end
    NO = false
    return false
  end
  return NO == true
end
local function oI(o)
  local t = 0
  while tO and t < o do
    if not LO() then
      return false
    end
    local o = RO()
    local A = JO()
    if o ~= nil and (A ~= nil and next(A) ~= nil) then
      return true
    end
    Sleep(100)
    t = t + 100
  end
  return false
end
local function tI(o)
  local t = 0
  while tO and t < o do
    local o = KO()
    local A = WO()
    if jO(A) and not lO(A, IO) then
      return false
    end
    local v = RO()
    local p = JO()
    if o ~= nil and (v ~= nil and (p ~= nil and next(p) ~= nil)) then
      return true
    end
    Sleep(100)
    t = t + 100
  end
  return false
end
local function AI()
  local o = KO()
  if o == nil then
    return
  end
  local t = o["posX"] // 32
  local A = o["posY"] // 32
  pcall(function()
    FindPath(t, A)
  end)
end
local function vI(o)
  local t = RO()
  if t == nil then
    return 0
  end
  for t, A in pairs(t) do
    if A["id"] == o then
      return A["amount"]
    end
  end
  return 0
end
local function pI()
  local o = RO()
  if o == nil then
    return 0
  end
  for o, t in pairs(o) do
    if t["id"] % 2 == 1 and t["amount"] >= q then
      return t["id"]
    end
  end
  return 0
end
local function cI()
  local o = RO()
  if o == nil then
    return 0
  end
  for o, t in pairs(o) do
    local A = tonumber(t["id"])
    local v = tonumber(t["amount"]) or 0
    if A ~= nil and (A > 0 and (A % 2 == 1 and v > 0)) then
      return A
    end
  end
  return 0
end
local function sI()
  local o = KO()
  if o == nil then
    return nil, nil
  end
  return o["posX"] // 32, o["posY"] // 32
end
local function gI(o, t)
  if not tO or not LO() then
    return false
  end
  for A = 1, L, 1 do
    if not tO or not LO() then
      return false
    end
    local v, p = sI()
    if v == nil then
      qO = true
      return false
    end
    if v == o and p == t then
      return true
    end
    local c = pcall(function()
      FindPath(o, t)
    end)
    if not c then
      if A < L then
        Sleep(J)
      end
    else
      local c = 0
      local s = 0
      local g = v
      local i = p
      while tO and c < j do
        if not LO() then
          qO = true
          return false
        end
        local A, v = sI()
        if A == nil then
          qO = true
          return false
        end
        if A == o and v == t then
          Sleep(oO)
          return true
        end
        if A ~= g or v ~= i then
          g = A
          i = v
          s = 0
        else
          s = s + 100
        end
        if s >= l then
          break
        end
        Sleep(100)
        c = c + 100
      end
      if A < L then
        Sleep(J)
      end
    end
  end
  PO("WAIT PATH")
  return false
end
local function iI()
  local o = GetObjectList or getObjectList
  if o == nil then
    return {}
  end
  local t, A = pcall(o)
  if t and type(A) == "table" then
    return A
  end
  return {}
end
local function fI(o)
  if o == nil then
    return nil, nil
  end
  local t = tonumber(o["posX"])
  local A = tonumber(o["posY"])
  if (t == nil or A == nil) and o["pos"] ~= nil then
    t = t or tonumber(o["pos"]["x"])
    A = A or tonumber(o["pos"]["y"])
  end
  return t, A
end
local function zI(o, t)
  if yO ~= o or QO ~= t then
    yO, QO = o, t
    xO = 0
  end
  xO = xO + 1
  PO("DROPPED " .. (tostring(xO) .. " ON TILE"))
  return xO
end
local function EI()
  yO, QO = nil, nil
  DO, xO = 0, 0
end
local function SI()
  if fO then
    editValue("TapTap_packstart", tostring(gO) .. (", " .. tostring(iO)))
  elseif zO or EO then
    local o = zO and tostring(gO) or "NOT SET"
    local t = EO and tostring(iO) or "NOT SET"
    editValue("TapTap_packstart", o .. (", " .. t))
  else
    editValue("TapTap_packstart", "NOT SET")
  end
end
local function MI()
  if fO then
    editValue("TapTap_packcurrent", tostring(cO) .. (", " .. tostring(sO)))
  else
    editValue("TapTap_packcurrent", "NOT SET")
  end
end
local function HI(o, t)
  if not tO or not fO or not LO() then
    return false
  end
  PO("RETURN PACK")
  if t then
    dO(true)
  else
    nO(true)
  end
  local A = gI(gO, iO)
  if A then
    cO = gO
    sO = iO
    MI()
    if o == "SSP" then
      ZO("SSP collected - back to Pack Position")
    elseif o == "DROP" then
      ZO("Drop finished - back to Pack Position")
    end
  else
    PO("WAIT PACK PATH")
    ZO("Cannot return to Pack Position!")
  end
  dO(false)
  bO = false
  return A
end
local function VI()
  SI()
  if zO and EO then
    fO = true
    cO = gO
    sO = iO
    SI()
    MI()
    UO("Manual pack start position set: " .. (gO .. (", " .. iO)))
  end
end
local function BI()
  editValue("TapTap_dropcurrent", tostring(HO) .. (", " .. tostring(VO)))
  editValue("TapTap_droptarget", tostring(HO + 1) .. (", " .. tostring(VO)))
end
local function rI(o, t, A, v)
  if o ~= nil and t ~= nil then
    editValue("TapTap_ssppos", tostring(o) .. (", " .. tostring(t)))
  else
    editValue("TapTap_ssppos", "NONE")
  end
  if A ~= nil and v ~= nil then
    editValue("TapTap_ssppath", tostring(A) .. (", " .. tostring(v)))
  else
    editValue("TapTap_ssppath", "NONE")
  end
end
local function XI(o, t)
  local A = getTile or GetTile
  if A == nil then
    return nil
  end
  local v, p = pcall(A, o, t)
  if v then
    return p
  end
  return nil
end
local function yI(o, t)
  local A = XI(o, t)
  if A == nil then
    return false
  end
  return A["collidable"] == true
end
local function QI()
  local o = KO()
  if o == nil or not tO then
    return false
  end
  local t = WO()
  if jO(t) and not lO(t, IO) then
    return false
  end
  local A = o["posX"] // 32
  local v = o["posY"] // 32
  local p = { { ["x"] = A + 1, ["y"] = v }, { ["x"] = A - 1, ["y"] = v }, { ["x"] = A, ["y"] = v - 1 } }
  for o, t in ipairs(p) do
    local p = XI(t["x"], t["y"])
    if p ~= nil and p["collidable"] ~= true then
      local o = false
      for A = 1, 4, 1 do
        if not tO then
          return false
        end
        local v = WO()
        if jO(v) and not lO(v, IO) then
          return false
        end
        pcall(function()
          FindPath(t["x"], t["y"])
        end)
        local p = 0
        while tO and p < 500 do
          local A = KO()
          v = WO()
          if jO(v) and not lO(v, IO) then
            return false
          end
          if A ~= nil and (A["posX"] // 32 == t["x"] and A["posY"] // 32 == t["y"]) then
            o = true
            break
          end
          Sleep(100)
          p = p + 100
        end
        if o then
          break
        end
        Sleep(120)
      end
      if o then
        Sleep(R)
        pcall(function()
          FindPath(A, v)
        end)
        local o = 0
        while tO and o < 1200 do
          local t = KO()
          if t ~= nil and (t["posX"] // 32 == A and t["posY"] // 32 == v) then
            Sleep(R)
            return true
          end
          Sleep(100)
          o = o + 100
        end
        return true
      end
    end
  end
  pcall(function()
    FindPath(A, v)
  end)
  Sleep(R)
  return false
end
local function DI()
  local o = KO()
  if o == nil or not LO() then
    return {}, 0
  end
  local t = o["posX"] // 32
  local A = o["posY"] // 32
  local v = {}
  local p = 0
  for o, c in pairs(iI()) do
    local s = tonumber(c["itemid"])
    if s == I then
      p = p + 1
      local o, s = fI(c)
      if o ~= nil and s ~= nil then
        local p = math["floor"](o / 32)
        local g = math["floor"](s / 32)
        table["insert"](
          v,
          {
            ["object"] = c,
            ["objectX"] = p,
            ["objectY"] = g,
            ["pixelX"] = o,
            ["pixelY"] = s,
            ["distance"] = math["abs"](t - p) + math["abs"](A - g),
          }
        )
      end
    end
  end
  table["sort"](v, function(o, t)
    return o["distance"] < t["distance"]
  end)
  if #v > 0 then
    rI(v[1]["objectX"], v[1]["objectY"], nil, nil)
  elseif p == 0 then
  elseif p == 0 then
    rI(nil, nil, nil, nil)
  end
  return v, p
end
local function xI(o)
  return {
    { o["objectX"], o["objectY"] },
    { o["objectX"] - 1, o["objectY"] },
    { o["objectX"] + 1, o["objectY"] },
    { o["objectX"], o["objectY"] - 1 },
    { o["objectX"] - 1, o["objectY"] - 1 },
    { o["objectX"] + 1, o["objectY"] - 1 },
  }
end
local function uI(o)
  tO = false
  dO(false)
  bO = false
  TO = false
  FO = false
  rI(nil, nil, nil, nil)
  local t = EditToggle or editToggle
  if t ~= nil then
    pcall(t, "TapTap_enable", false)
  end
  if o then
    PO("DONE - SEEDS DROPPED")
    ZO("No SSP remains. Final seed drop finished; script stopped.")
    UO("No dropped SSP remains; remaining seed stacks were dropped and verified.")
  else
    PO("NO SSP - STOPPED")
    ZO("No SSP found and no seeds remain. Script stopped.")
    UO("No dropped SSP or remaining seed stacks found. TapTap stopped.")
  end
end
local function eI()
  if not tO or not LO() then
    return false
  end
  local o = GetObjectList or getObjectList
  if type(o) ~= "function" then
    return false
  end
  local t, A = pcall(o)
  if not t or type(A) ~= "table" then
    return false
  end
  for o, t in pairs(A) do
    if tonumber(t["itemid"]) == I then
      return false
    end
  end
  return true
end
local function bI(o)
  if not tO or not LO() then
    return
  end
  if o == nil or o["object"] == nil then
    return
  end
  local t = tonumber(o["object"]["id"])
  if t == nil then
    return
  end
  pcall(function()
    if tO and LO() then
      SendPacketRaw(false, { ["type"] = 11, ["value"] = t, ["x"] = o["pixelX"], ["y"] = o["pixelY"] })
    end
  end)
end
local function TI(o, t, A, v)
  if not tO or not LO() then
    return false
  end
  rI(o["objectX"], o["objectY"], t, A)
  for p = 1, L, 1 do
    if not tO or not LO() then
      return false
    end
    local c, s = sI()
    if c == nil then
      qO = true
      return false
    end
    local g = false
    local i = pcall(function()
      FindPath(t, A)
    end)
    if i then
      local p = 0
      local i = 0
      local f = c
      local z = s
      while tO and p < j do
        if not LO() then
          qO = true
          return false
        end
        if vI(I) > v then
          return true
        end
        local c, s = sI()
        if c == nil then
          qO = true
          return false
        end
        local E = math["abs"](c - o["objectX"]) <= 1 and math["abs"](s - o["objectY"]) <= 1
        if E and not g then
          bI(o)
          g = true
        end
        if c == t and s == A then
          if not g then
            bI(o)
            g = true
          end
          local t = 0
          while tO and t < 500 do
            if vI(I) > v then
              return true
            end
            Sleep(50)
            t = t + 50
          end
          return false
        end
        if c ~= f or s ~= z then
          f = c
          z = s
          i = 0
        else
          i = i + 100
        end
        if i >= l then
          break
        end
        Sleep(100)
        p = p + 100
      end
    end
    if p < L then
      Sleep(J)
    end
  end
  return false
end
local function FI()
  local o, t = DI()
  if t == 0 then
    return false, "NO_SSP"
  end
  if #o == 0 then
    PO("WAIT SSP DATA")
    UO("SSP object(s) exist, but their position data could not be read.")
    return false
  end
  local A = vI(I)
  PO("COLLECT SSP")
  nO(true)
  for o, t in ipairs(o) do
    if not tO or not LO() then
      nO(false)
      return false
    end
    editValue("TapTap_ssppos", tostring(t["objectX"]) .. (", " .. tostring(t["objectY"])))
    UO("Testing SSP object at " .. (t["objectX"] .. (", " .. t["objectY"])))
    local v = xI(t)
    for o, v in ipairs(v) do
      local p = v[1]
      local c = v[2]
      if TI(t, p, c, A) then
        local o = HI("SSP", false)
        if o then
          rI(t["objectX"], t["objectY"], gO, iO)
        end
        return o
      end
      if not tO or not LO() then
        nO(false)
        return false
      end
    end
  end
  nO(false)
  local v = o[1]
  editValue("TapTap_ssppos", tostring(v["objectX"]) .. (", " .. tostring(v["objectY"])))
  editValue("TapTap_ssppath", "NO WORKING PATH")
  local p = (uO == "WAIT SSP PATH")
  PO("WAIT SSP PATH")
  if not p then
    ZO("Path not found!")
  end
  UO("Found " .. (t .. " SSP object(s), but actual FindPath could not reach any candidate."))
  return false
end
local function OI()
  if not tO then
    return false
  end
  local o = KO()
  if o == nil or not LO() then
    qO = true
    return false
  end
  local t = vI(I)
  SendPacketRaw(
    false,
    { ["type"] = 3, ["value"] = I, ["x"] = o["posX"], ["y"] = o["posY"], ["px"] = o["posX"] // 32, ["py"] = o["posY"]
      // 32 }
  )
  local A = 0
  local v = 10
  while tO and A < Z do
    if not LO() then
      qO = true
      return false
    end
    if vI(I) < t then
      if AO > 0 then
        PO("GACHA DELAY")
        Sleep(AO)
      end
      return tO
    end
    Sleep(v)
    A = A + v
  end
  PO("WAIT SERVER")
  Sleep(P)
  return false
end
local function wI(o, t)
  if not tO or not LO() then
    return false, "WORLD_LOST"
  end
  TO = false
  FO = true
  SendPacket(2, "action|drop\nitemID|" .. o)
  local A = 0
  local v = 25
  while tO and A < N do
    if aO(HO + 1, VO) then
      FO = false
      TO = false
      return false, "TILE_FULL"
    end
    if not LO() then
      qO = true
      FO = false
      return false, "WORLD_LOST"
    end
    if TO then
      break
    end
    Sleep(v)
    A = A + v
  end
  if not tO then
    FO = false
    return false, "STOPPED"
  end
  if not TO then
    FO = false
    PO("WAIT SERVER")
    Sleep(P)
    return false, "NO_DIALOG"
  end
  TO = false
  FO = false
  if aO(HO + 1, VO) then
    return false, "TILE_FULL"
  end
  if not tO or not LO() then
    return false, "WORLD_LOST"
  end
  SendPacket(
    2,
    "action|dialog_return\n" .. ("dialog_name|drop_item\n" .. ("itemID|" .. (o .. ("|\n" .. ("count|" .. t)))))
  )
  return true, "CONFIRM_SENT"
end
local function CI(o, t)
  local A = 0
  local v = 50
  while tO and A < U do
    if not LO() then
      return false, "WORLD_LOST"
    end
    local p = vI(o)
    if p < t then
      if A < vO then
        Sleep(vO - A)
      end
      return true, p
    end
    if aO(HO + 1, VO) then
      return false, "TILE_FULL"
    end
    Sleep(v)
    A = A + v
  end
  return false, vI(o)
end
local function kI()
  if not tO or not LO() then
    return false
  end
  local o = KO()
  if o == nil then
    qO = true
    return false
  end
  if o["isLeft"] == false then
    return true
  end
  local t = o["posX"] // 32
  local A = o["posY"] // 32
  local v = t - 1
  local p = A
  local c = XI(v, p)
  if c == nil or c["collidable"] == true then
    UO("Cannot safely face right because the left-side turn tile is blocked.")
    return false
  end
  if not gI(v, p) then
    return false
  end
  Sleep(60)
  if not tO then
    return false
  end
  if not gI(t, A) then
    return false
  end
  Sleep(60)
  local s = KO()
  if s ~= nil and s["isLeft"] ~= nil then
    UO("Safe facing check: isLeft=" .. tostring(s["isLeft"]))
    return s["isLeft"] == false
  end
  return true
end
local function hI()
  if not tO or not LO() then
    return false
  end
  local o = HO - 1
  local t = VO
  UO(
    "Drop target full at " .. (
        (HO + 1) .. (", " .. (VO .. (". Trying next standing tile to the left: " .. (o .. (", " .. t)))))
      )
  )
  if gI(o, t) then
    HO = o
    VO = t
    BI()
    UO("Moved left for next drop. Stand: " .. (HO .. (", " .. (VO .. (" | Target: " .. ((HO + 1) .. (", " .. VO)))))))
    return true
  end
  local A = SO
  local v = VO - 1
  UO("No path to the left. Trying next row at start X: " .. (A .. (", " .. v)))
  if gI(A, v) then
    HO = A
    VO = v
    BI()
    ZO("Next Drop Row = (" .. (HO .. (", " .. (VO .. ")"))))
    UO("Moved to next drop row. Stand: " .. (HO .. (", " .. (VO .. (" | Target: " .. ((HO + 1) .. (", " .. VO)))))))
    return true
  end
  PO("WAIT DROP PATH")
  ZO("No drop path found!")
  UO("Could not move left and could not reach next row start at " .. (A .. (", " .. v)))
  return false
end
local function aI(o, t, A)
  local v = 0
  while tO and v < A do
    if not LO() then
      return false, "WORLD_LOST"
    end
    if RO() == nil then
      return false, "NO_INVENTORY"
    end
    if vI(o) < t then
      return true, "ACCEPTED"
    end
    Sleep(50)
    v = v + 50
  end
  return vI(o) < t, "TIMEOUT"
end
local function GI(o, t)
  if RO() == nil then
    return "NO_INVENTORY"
  end
  local A = vI(o)
  if A < t then
    return "CHANGED"
  end
  for v = 1, n, 1 do
    if not tO then
      return "STOPPED"
    end
    if not LO() then
      return "WORLD_LOST"
    end
    if RO() == nil then
      return "NO_INVENTORY"
    end
    if vI(o) < A then
      return "SUCCESS"
    end
    bO = true
    PO(v == 1 and "DROP - CHECK INVENTORY" or "RETRY DROP 2/2 - SAME TILE")
    OO = true
    local p, c = wI(o, t)
    if p then
      local t, v = CI(o, A)
      if t then
        OO = false
        return "SUCCESS"
      end
      c = v
    end
    OO = false
    if not tO then
      return "STOPPED"
    end
    if c == "WORLD_LOST" or not LO() then
      return "WORLD_LOST"
    end
    if RO() == nil then
      return "NO_INVENTORY"
    end
    if vI(o) < A then
      return "SUCCESS"
    end
    if c == "TILE_FULL" or aO(HO + 1, VO) then
      return "REJECTED"
    end
    PO(v == 1 and "WAIT DROP ACK - RETRY" or "WAIT DROP ACK - SHIFT")
    local s, g = aI(o, A, v == 1 and m or d)
    if s then
      return "SUCCESS"
    end
    if g == "WORLD_LOST" then
      return "WORLD_LOST"
    end
    if g == "NO_INVENTORY" then
      return "NO_INVENTORY"
    end
  end
  return "REJECTED"
end
local function II(o)
  local t = false
  local A = true
  local v = 0
  local function p()
    BO = true
    OO = false
    PO("DROP FAILED - MOVE LEFT")
    if not hI() then
      PO("WAIT LEFT PATH - NO DROP")
      return false
    end
    BO = false
    hO()
    t, A = true, true
    v = v + 1
    return true
  end
  while tO do
    if not LO() then
      qO = true
      return false
    end
    if RO() == nil then
      PO("WAIT INVENTORY")
      return false
    end
    local c = XO
    if c ~= nil then
      local t = vI(c)
      if t <= 0 or (not o and t < q) then
        XO = nil
        c = nil
      end
    end
    if c == nil then
      c = o and cI() or pI()
    end
    if c == 0 then
      return true
    end
    if BO then
      if not p() then
        return false
      end
    elseif not t then
      if not gI(HO, VO) then
        PO("WAIT DROP PATH")
        ZO("Path not found!")
        return false
      end
      t = true
      A = true
    end
    local s, g = HO + 1, VO
    if yI(s, g) or aO(s, g) then
      XO = c
      if not p() then
        return false
      end
    else
      if A then
        if not kI() then
          PO("WAIT DROP FACING")
          ZO("Cannot face right safely!")
          return false
        end
        A = false
      end
      local t = vI(c)
      local v = o and math["min"](q, t) or q
      if v <= 0 or t < v then
        XO = nil
        Sleep(50)
      else
        local o = GI(c, v)
        if o == "SUCCESS" then
          XO = nil
          rO = 0
          zI(s, g)
        elseif o == "REJECTED" then
          XO = c
          rO = rO + 1
          if not p() then
            return false
          end
        elseif o == "CHANGED" then
          XO = nil
        elseif o == "NO_INVENTORY" then
          PO("WAIT INVENTORY")
          return false
        elseif o == "WORLD_LOST" then
          qO = true
          return false
        else
          return false
        end
      end
    end
    if rO >= K then
      PO("SERVER SLOW - DROP COOLDOWN")
      Sleep(1500)
      rO = 0
      return false
    end
    if v >= 30 then
      PO("DROP SHIFT BREAK")
      Sleep(400)
      return false
    end
    Sleep(30)
  end
  return false
end
local function qI()
  local o = KO()
  if o == nil then
    UO("Cannot set pack position: player not loaded.")
    return
  end
  gO = o["posX"] // 32
  iO = o["posY"] // 32
  cO = gO
  sO = iO
  zO = true
  EO = true
  fO = true
  editValue("TapTap_packx", tostring(gO))
  editValue("TapTap_packy", tostring(iO))
  SI()
  MI()
  eO()
  ZO("Pack Position = (" .. (gO .. (", " .. (iO .. ")"))))
  UO("Pack start position set: " .. (gO .. (", " .. iO)))
end
local function YI()
  local o = KO()
  if o == nil then
    UO("Cannot set drop position: player not loaded.")
    return
  end
  SO = o["posX"] // 32
  MO = o["posY"] // 32
  HO = SO
  VO = MO
  EI()
  hO()
  OO = false
  BO = false
  rO = 0
  editValue("TapTap_dropx", tostring(SO))
  editValue("TapTap_dropy", tostring(MO))
  BI()
  eO()
  ZO("Drop Position = (" .. (SO .. (", " .. (MO .. ")"))))
  UO("Drop start position set: " .. (SO .. (", " .. MO)))
end
local function NI()
  if not tO then
    return false
  end
  if LO() then
    if qO or YO then
      dO(false)
      PO("RESUMING")
      Sleep(W)
      if not tO then
        return false
      end
      local o = WO()
      if jO(o) and not lO(o, IO) then
        NO = false
        return false
      end
      if not oI(3000) then
        PO("RESUMING")
        Sleep(100)
        return false
      end
      PO("RESUME MOVE")
      QI()
      if not tO then
        return false
      end
      o = WO()
      if jO(o) and not lO(o, IO) then
        NO = false
        return false
      end
      qO = false
      YO = false
      NO = true
      ZO("TapTap resumed automatically.")
    end
    return true
  end
  if qO and YO then
    dO(false)
    PO("RESUMING")
    Sleep(W)
    if not tO then
      return false
    end
    if tI(4000) then
      local o = WO()
      if jO(o) and not lO(o, IO) then
        NO = false
        PO("PAUSED - WAIT WORLD")
        return false
      end
      NO = true
      PO("RESUME MOVE")
      QI()
      if not tO then
        return false
      end
      o = WO()
      if jO(o) and not lO(o, IO) then
        NO = false
        PO("PAUSED - WAIT WORLD")
        return false
      end
      qO = false
      YO = false
      ZO("TapTap resumed automatically.")
      return true
    end
  end
  if not qO then
    qO = true
    ZO("TapTap paused - return to " .. tostring(IO))
  end
  NO = false
  TO = false
  FO = false
  dO(false)
  PO("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
local function UI(o)
  k = tostring(o)
  pcall(function()
    editValue("SSP_licensestatus", k)
  end)
end
local function ZI(o)
  local t = tostring(o or "")
  t = t:gsub("[\r\n\t]+", " ")
  if #t > 140 then
    t = t:sub(1, 137) .. "..."
  end
  pcall(function()
    editValue("SSP_licensedetail", t)
  end)
end
local function PI(o, t)
  o = D(o)
  local A
  if #o == 8 then
    A = o:sub(1, 1) .. ("*****" .. o:sub(-2))
  else
    A = "length " .. tostring(#o)
  end
  local v = "PRODUCT=" .. (r .. (" | KEY=" .. (A .. (" | ID=" .. tostring(t or "NOT CHECKED")))))
  pcall(function()
    editValue("SSP_licenserequest", v)
  end)
end
local function mI(o, t, A)
  UI(o)
  ZI(t)
  if A then
    ZO("SSP License: " .. tostring(o))
  end
end
local function dI(o)
  C = true
  pcall(function()
    local t = EditToggle or editToggle
    if type(t) == "function" then
      t("TapTap_enable", o == true)
    end
  end)
  C = false
end
local function nI(o)
  return (tostring(o or "")):gsub("([^%w%-%._~])", function(o)
    return string["format"]("%%%02X", string["byte"](o))
  end)
end
local function KI()
  local o = getDiscordID
  local t, A = pcall(function()
    return type(o) == "function" and o() or o
  end)
  A = t and tostring(A or "") or ""
  A = (A:gsub("^%s+", "")):gsub("%s+$", "")
  if A ~= "" and (A ~= "nil" and (A ~= "0" and A ~= "false")) then
    return A, "DISCORD"
  end
  local v = KO()
  A = v and tostring(v["name"] or "") or ""
  A = (A:gsub("^%s+", "")):gsub("%s+$", "")
  if A == "" then
    return "", "NONE"
  end
  return A, "PLAYER"
end
local function WI()
  if T then
    mI("VERIFY BUSY", "Previous request is still running", false)
    return false
  end
  T = true
  UI("CHECKING SERVER...")
  ZI("Checking SSP product license")
  local o = D(b)
  PI(o, "CHECKING")
  if not x(o) then
    T = false
    mI("INVALID KEY FORMAT", "Use one letter followed by seven digits, e.g. A1234567", true)
    return false
  end
  local t, A = KI()
  PI(o, A)
  if t == "" then
    T = false
    mI("NO CLIENT ID", "Connect to Growlauncher/Discord or enter a world, then verify", true)
    return false
  end
  F = F + 1
  local v = tostring(F)
    .. ("_" .. tostring((os and type(os["time"]) == "function") and os["time"]() or math["random"](100000, 999999)))
  local p = B .. ("?key=" .. (nI(o) .. ("&id=" .. (nI(t) .. ("&product=" .. (nI(r) .. ("&nonce=" .. nI(v))))))))
  local c, s, g = pcall(fetch, p)
  T = false
  if D(b) ~= o then
    mI("KEY CHANGED", "The key was edited while verifying; press Verify again", true)
    return false
  end
  if not c then
    mI("SERVER ERROR", "Growlauncher fetch failed. Check the license server and internet connection", true)
    return false
  end
  local i
  if type(s) == "table" then
    i = tostring(s["body"] or s["text"] or s["data"] or "")
  else
    i = tostring(s or "")
  end
  i = (i:gsub("^%s+", "")):gsub("%s+$", "")
  if (i:upper()):find("OK|PERMANENT", 1, true) then
    b = o
    local t = h()
    mI(
      "VERIFIED - PERMANENT",
      t and "Product SSP accepted; license saved" or "Product SSP accepted; license could not be saved",
      true
    )
    return true
  end
  local f = i:upper()
  if f:find("WRONG_PRODUCT", 1, true) then
    mI(
      "WRONG PRODUCT (SSP)",
      "Server replied WRONG_PRODUCT. The Sheet row and deployed script must authorize PRODUCT=SSP.",
      true
    )
  elseif f:find("DISABLED", 1, true) then
    mI(
      "LICENSE DISABLED",
      "Server replied DISABLED. Recheck active status in the Sheet used by the deployed web app.",
      true
    )
  elseif f:find("BOUND_TO_OTHER_USER", 1, true) then
    mI("BOUND TO OTHER USER", "This key is already bound to another client ID", true)
  elseif f:find("INVALID_KEY", 1, true) then
    mI(
      "INVALID LICENSE",
      "Server replied DENY|INVALID_KEY to PRODUCT=SSP. Check saved key vs Sheet row and deployed Apps Script source.",
      true
    )
  elseif f:find("BAD_KEY", 1, true) then
    mI("BAD KEY FORMAT", "The server rejected the key format", true)
  elseif f:find("NO_ID", 1, true) then
    mI("NO CLIENT ID", "The licensing server did not accept the client ID", true)
  elseif i == "" or f == "NIL" or f == "FALSE" then
    local o = "Empty server response; check Apps Script deployment and fetch compatibility"
    mI("NO SERVER RESPONSE", o, true)
  elseif f:find("<HTML", 1, true) or f:find("<!DOCTYPE", 1, true) then
    mI("SERVER RETURNED HTML", "Verify Google Apps Script web-app deployment and response format", true)
  else
    local o = "Unrecognized server reply (" .. (tostring(#i) .. " chars)")
    mI("LICENSE CHECK FAILED", o, true)
  end
  return false
end
local function RI()
  if not fO then
    tO = false
    dI(false)
    PO("STOPPED - SET PACK POSITION")
    UO("Set Pack Position first.")
    return
  end
  local o = WO()
  if not jO(o) or KO() == nil then
    tO = false
    dI(false)
    PO("STOPPED - WORLD NOT READY")
    UO("Enter the farming world first, then press Start.")
    return
  end
  tO = true
  IO = o
  qO = false
  YO = false
  NO = true
  EI()
  hO()
  OO = false
  BO = false
  rO = 0
  XO = nil
  ZO("TapTap started - SSP license verified.")
  UO("TapTap started in world: " .. IO)
end
function onVariant(o, t)
  if o ~= nil then
    if tO and (o["v1"] == "OnSpawn" and type(o["v2"]) == "string") then
      local t = o["v2"]:find("type|local", 1, true) ~= nil
      if not t then
        local A = tonumber(o["v2"]:match("netID|(%d+)"))
        local v = KO()
        if A ~= nil and v ~= nil then
          t = tonumber(v["netID"]) == A
        end
      end
      if t and (qO or not NO) then
        YO = true
        qO = true
      end
    end
    if tO and (qO and o["v1"] == "OnSetPos") then
      YO = true
    end
    if tO and OO then
      local t = true
      if o["v1"] == "OnTalkBubble" then
        local A = KO()
        if A ~= nil and (A["netID"] ~= nil and tonumber(o["v2"]) ~= tonumber(A["netID"])) then
          t = false
        end
      end
      if t then
        for t = 2, 7, 1 do
          local A = o["v" .. tostring(t)]
          if GO(A) then
            CO = HO + 1
            kO = VO
            wO = true
            UO("Server says drop tile is full: " .. (tostring(CO) .. (", " .. tostring(kO))))
            break
          end
        end
      end
    end
    if o["v1"] == "OnDialogRequest" and type(o["v2"]) == "string" then
      if o["v2"]:find("drop_item", 1, true) then
        if tO and FO then
          TO = true
        end
        return true
      end
    end
  end
  return false
end
function onSendPacket(o, t)
  if tO and type(t) == "string" then
    local o = t:find("action|quit", 1, true) ~= nil
    local A = t:find("action|join_request", 1, true) ~= nil
    if o or A then
      NO = false
      qO = true
      YO = false
      TO = false
      FO = false
      dO(false)
      PO("PAUSED - WAIT WORLD")
    end
  end
  return false
end
function onSendPacketRaw(o)
  if tO and (bO and o ~= nil) then
    if tonumber(o["type"]) == 11 then
      UO("Blocked item collect packet during protected drop travel.")
      return true
    end
  end
  return false
end
function onGamePacket(o)
  if o ~= nil and (o["type"] == 26 and tO) then
    if not qO then
      ZO("TapTap paused - disconnected.")
    end
    qO = true
    YO = false
    NO = false
    TO = false
    FO = false
    dO(false)
    PO("PAUSED - WAIT WORLD")
    UO("Disconnect detected. TapTap is paused until you manually return to the target world.")
  end
  return false
end
function onValue(o, t, A)
  if C and t == "TapTap_enable" then
    return
  end
  if t == "SSP_licensekey" then
    local o = D(A)
    if o ~= b then
      b = o
      h()
      UI("NOT VERIFIED")
      ZI("Key changed; press Verify License")
      PI(o, "NOT CHECKED")
      if w or tO then
        O = O + 1
        w = false
        tO = false
        bO = false
        FO = false
        TO = false
        OO = false
        dO(false)
        dI(false)
        PO("STOPPED - LICENSE CHANGED")
      end
    end
    return
  end
  if t == "SSP_verifylicense" then
    local o, t = pcall(function()
      runThread(function()
        local o = pcall(WI)
        if not o then
          T = false
          mI("VERIFY SCRIPT ERROR", "Verification function encountered a Lua runtime error", true)
        end
      end)
    end)
    if not o then
      mI("VERIFY THREAD ERROR", "Growlauncher could not start the verification worker", true)
    end
    return
  end
  if t == "SSP_clearlicense" then
    O = O + 1
    w = false
    tO = false
    bO = false
    FO = false
    TO = false
    OO = false
    dO(false)
    dI(false)
    b = ""
    h()
    UI("NOT VERIFIED")
    ZI("License cleared. Enter a new SSP key")
    PI("", "NOT CHECKED")
    pcall(function()
      editValue("SSP_licensekey", "")
    end)
    PO("STOPPED - LICENSE CLEARED")
    UO("SSP saved license cleared.")
    return
  end
  if t == "TapTap_enable" then
    if A == true then
      if tO or w then
        return
      end
      O = O + 1
      local o = O
      local t = D(b)
      w = true
      tO = false
      PO("VERIFYING SSP LICENSE")
      runThread(function()
        local A = 0
        while T and (w and (O == o and A < 30000)) do
          Sleep(100)
          A = A + 100
        end
        if not w or O ~= o then
          return
        end
        if T then
          w = false
          UI("VERIFY BUSY - RETRY START")
          dI(false)
          PO("STOPPED - RETRY LICENSE")
          return
        end
        local v, p = pcall(WI)
        if not v then
          T = false
          p = false
          mI("VERIFY SCRIPT ERROR", "Growlauncher raised an error while checking the SSP license", true)
        end
        if not w or O ~= o then
          return
        end
        w = false
        if t ~= D(b) then
          p = false
          UI("KEY CHANGED - VERIFY AGAIN")
        end
        if not p then
          tO = false
          dI(false)
          PO("STOPPED - LICENSE DENIED")
          UO("SSP Start blocked: " .. k)
          return
        end
        RI()
      end)
    else
      O = O + 1
      w = false
      tO = false
      bO = false
      TO = false
      FO = false
      OO = false
      BO = false
      rO = 0
      XO = nil
      hO()
      dO(false)
      PO("STOPPED")
      qO = false
      YO = false
      NO = false
      ZO("TapTap stopped safely.")
      UO("TapTap stopped manually. Packet automation is idle.")
    end
    return
  end
  if t == "TapTap_delay" then
    local o = tonumber(A)
    if o ~= nil then
      if o < 1 then
        o = 1
      end
      AO = math["floor"](o)
      eO()
      UO("Pack Delay: " .. (AO .. " ms"))
    end
    return
  end
  if t == "TapTap_dropdelay" then
    local o = tonumber(A)
    if o ~= nil then
      o = math["floor"](o)
      if o < 200 then
        o = 200
      end
      if o > 500 then
        o = 500
      end
      vO = o
      eO()
      UO("Drop Delay: " .. (vO .. " ms"))
    end
    return
  end
  if t == "TapTap_minssp" then
    local o = tonumber(A)
    if o ~= nil then
      o = math["floor"](o)
      if o < 0 then
        o = 0
      end
      if o > 200 then
        o = 200
      end
      pO = o
      eO()
      UO("Minimum SSP Threshold: " .. pO)
    end
    return
  end
  if t == "TapTap_packx" then
    local o = tonumber(A)
    if o ~= nil then
      gO = math["floor"](o)
      zO = true
      VI()
      eO()
    end
    return
  end
  if t == "TapTap_packy" then
    local o = tonumber(A)
    if o ~= nil then
      iO = math["floor"](o)
      EO = true
      VI()
      eO()
    end
    return
  end
  if t == "TapTap_setpack" then
    qI()
    return
  end
  if t == "TapTap_dropx" then
    local o = tonumber(A)
    if o ~= nil then
      SO = math["floor"](o)
      HO = SO
      VO = MO
      EI()
      hO()
      OO = false
      BO = false
      rO = 0
      XO = nil
      BI()
      eO()
    end
    return
  end
  if t == "TapTap_dropy" then
    local o = tonumber(A)
    if o ~= nil then
      MO = math["floor"](o)
      HO = SO
      VO = MO
      EI()
      hO()
      OO = false
      BO = false
      rO = 0
      XO = nil
      BI()
      eO()
    end
    return
  end
  if t == "TapTap_setdrop" then
    YI()
    return
  end
end
applyHook()
runThread(function()
  dO(false)
  PO("STOPPED")
  while true do
    if tO then
      if not NI() then
        Sleep(200)
      else
        local o = pI()
        if o ~= 0 then
          PO("DROP")
          dO(true)
          local o = II()
          if o and (tO and LO()) then
            HI("DROP", true)
          end
        else
          PO("GACHA")
          dO(false)
          local o = true
          if vI(I) < pO then
            local t, A = FI()
            if t then
              o = false
              Sleep(200)
            elseif A == "NO_SSP" then
              o = false
              PO("VERIFY NO SSP")
              Sleep(250)
              if tO and (LO() and eI()) then
                if RO() == nil then
                  PO("WAIT INVENTORY")
                elseif cI() ~= 0 then
                  PO("FINAL SEED DROP")
                  dO(true)
                  local o = II(true)
                  if o and (tO and LO()) then
                    HI("DROP", true)
                    if tO and LO() then
                      uI(true)
                    end
                  end
                else
                  uI(false)
                end
              else
                PO("WAIT SSP DATA")
              end
              Sleep(150)
            else
              if not LO() then
                qO = true
              end
              o = false
              Sleep(500)
            end
          end
          if o and tO then
            PO("GACHA")
            local o = KO()
            if o ~= nil then
              local t = o["posX"] // 32
              local A = o["posY"] // 32
              if t ~= cO or A ~= sO then
                gI(cO, sO)
                Sleep(200)
              end
              if tO then
                OI()
              end
            else
              Sleep(500)
            end
          end
        end
        Sleep(400)
      end
    else
      Sleep(200)
    end
  end
end)
if b ~= "" then
  UI("SAVED - CHECK ON START")
  ZI("Saved SSP key loaded; online verification required on Start")
  PI(b, "NOT CHECKED")
else
  UI("NOT VERIFIED")
end
UO("Auto Open SSP V1 - ACD-style SSP license verification; fresh check each Start.")
