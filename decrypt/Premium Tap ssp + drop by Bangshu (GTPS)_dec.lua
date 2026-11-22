setMinimum("6.1.2")
local U = "Premium Auto open ssp + drop by Bangshu (GTPS)"
local g =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local D = "SSPS"
local I
local f = ""
local T = 0
local function F(U)
  return (((tostring(U or "")):gsub("%s+", ""))):upper()
end
pcall(function()
  local U = Preferences
  if type(require) == "function" then
    local g, D = pcall(require, "preferences")
    if g and type(D) == "table" then
      U = D
    end
  end
  if type(U) ~= "table" or type(U["new"]) ~= "function" then
    return
  end
  I = U:new("PremiumAutoOpenSSPSLicense")
  I:load()
  f = F(I:get("license_key", ""))
end)
local function R(U)
  if not I then
    return false
  end
  return pcall(function()
    I:set("license_key", U)
    I:save()
  end)
end
local t = "taptap_drop_ssp_v32_settings.json"
local n = nil
local l = false
do
  local U, g = pcall(require, "preferences")
  if not U or g == nil then
    g = Preferences
  end
  if g ~= nil and type(g["new"]) == "function" then
    local U, D = pcall(function()
      return g:new(t)
    end)
    if U and D ~= nil then
      n = D
      pcall(function()
        n:load()
      end)
    end
  end
end
local function q(U, g, D, I)
  local f = g
  if n ~= nil then
    local D, I = pcall(function()
      return n:get(U, g)
    end)
    if D and tonumber(I) ~= nil then
      f = tonumber(I)
    end
  end
  f = math["floor"](f)
  if D ~= nil then
    f = math["max"](D, f)
  end
  if I ~= nil then
    f = math["min"](I, f)
  end
  return f
end
local s = q("tapItemID", 5706, 1, 65535)
local w = q("burstTapIntervalMs", 100, 1, 100000)
local b = q("burstTaps", 10, 1, 25)
local N = q("burstPostAckPause", 20, 1, 10000)
local x = q("dropDelay", 500, 200, 500)
local M = q("minSSP", 25, 0, 200)
local o = q("packStartX", 0)
local Y = q("packStartY", 0)
local J = q("dropStartX", 2)
local u = q("dropStartY", 32)
local z = q("packXInputSet", 0, 0, 1) == 1
local G = q("packYInputSet", 0, 0, 1) == 1
local m = q("packPositionSet", 0, 0, 1) == 1 and (z and G)
local L = "NOT SET"
if m then
  L = tostring(o) .. (", " .. tostring(Y))
elseif z or G then
  L = (z and tostring(o) or "NOT SET") .. (", " .. (G and tostring(Y) or "NOT SET"))
end
local O = m and (tostring(o) .. (", " .. tostring(Y))) or "NOT SET"
local P = UserInterface["new"](U, "Rocket")
P:addLabelApp(U, "Bolt")
P:addInputString("License Key", f, "A1234567", "A1234567", nil, "TapTap_licensekey")
P:addButton("Verify License", "TapTap_verifylicense")
P:addButton("Clear Saved License", "TapTap_clearlicense")
P:addDisplayList("License Status", "NOT VERIFIED", "TapTap_licensestatus")
P:addToggle("Start / Stop", false, "TapTap_enable")
P:addItemPicker("Select Item to Tap", tostring(s), tostring(s), "TapTap_itempicker")
P:addInputInt("Delay Between Taps", tostring(w), "ms", "100", nil, "TapTap_delay")
P:addSlider("Taps per Burst", 1, 25, b, 1, false, "TapTap_bursttaps")
P:addInputInt("Pause After Burst", tostring(N), "ms", "20", nil, "TapTap_burstpause")
P:addSlider("Drop Delay", 200, 500, x, 10, false, "TapTap_dropdelay")
P:addInputInt("Minimum Tap Item Threshold", tostring(M), "items", "25", nil, "TapTap_minssp")
P:addInputInt("Pack Position X", tostring(o), "X", "0", nil, "TapTap_packx")
P:addInputInt("Pack Position Y", tostring(Y), "Y", "0", nil, "TapTap_packy")
P:addButton("Set Pack Position = Current Tile", "TapTap_setpack")
P:addDisplayList("Selected Pack Position", L, "TapTap_packstart")
P:addDisplayList("Current Pack Position", O, "TapTap_packcurrent")
P:addInputInt("Drop Position X", tostring(J), "X", "2", nil, "TapTap_dropx")
P:addInputInt("Drop Position Y", tostring(u), "Y", "32", nil, "TapTap_dropy")
P:addButton("Set Drop Position = Current Tile", "TapTap_setdrop")
P:addDisplayList("Current Drop Position", tostring(J) .. (", " .. tostring(u)), "TapTap_dropcurrent")
P:addDisplayList("Current Drop Target (Right)", tostring(J + 1) .. (", " .. tostring(u)), "TapTap_droptarget")
P:addDisplayList("Detected SSP Position", "NONE", "TapTap_ssppos")
P:addDisplayList("SSP Path Destination", "NONE", "TapTap_ssppath")
P:addDisplayList("Current Mode", "STOPPED", "TapTap_mode")
P:addDisplayList("End of SSP", "AUTO DROP REMAINING SEEDS", "TapTap_endseeds")
P:addDisplayList("Settings", n ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "TapTap_settingsstatus")
pcall(function()
  addCategory(U, "Rocket")
end)
local W = pcall(function()
  addIntoModule(P:generateJSON(), U)
end)
if not W then
  addIntoModule(P:generateJSON())
end
local d = 200
local Q = 800
local B = 1800
local E = 1800
local H = 1800
local A = 250
local e = 350
local a = 450
local y = 2
local V = 4
local p = 300
local i = 140
local r = 300
local K = 1200
local h = 6000
local j = 2
local v = 150
local Z = false
local k = w
local X = b
local c = N
local S = 0
local C = false
local UA = x
local gA = M
local DA = o
local IA = Y
local fA = o
local TA = Y
local FA = m
local RA = z
local tA = G
local nA = J
local lA = u
local qA = nA
local sA = lA
local wA = false
local bA = 0
local NA = nil
local xA, MA = nil, nil
local oA, YA = 0, 0
local JA = "STOPPED"
local function uA()
  if n == nil then
    return false
  end
  local U, g = pcall(function()
    n:set("burstTapIntervalMs", k)
    n:set("burstTaps", X)
    n:set("burstPostAckPause", c)
    n:set("dropDelay", UA)
    n:set("minSSP", gA)
    n:set("tapItemID", s)
    n:set("packStartX", fA)
    n:set("packStartY", TA)
    n:set("packXInputSet", RA and 1 or 0)
    n:set("packYInputSet", tA and 1 or 0)
    n:set("packPositionSet", FA and 1 or 0)
    n:set("dropStartX", nA)
    n:set("dropStartY", lA)
    n:save()
  end)
  if not U then
    if not l then
      l = true
      pcall(function()
        growtopia["notify"]("TapTap settings could not be saved: " .. tostring(g))
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
local zA = false
local GA = false
local mA = false
local LA = false
local OA = false
local PA, WA = nil, nil
local function dA()
  OA = false
  PA, WA = nil, nil
end
local function QA(U, g)
  return OA and (PA == U and WA == g)
end
local function BA(U)
  if type(U) ~= "string" then
    return false
  end
  local g = (U:lower()):gsub("`.", "")
  g = (g:gsub("[^%a%d%s]", " ")):gsub("%s+", " ")
  local D = g:find("can t drop", 1, true)
    or g:find("cant drop", 1, true)
    or g:find("cannot drop", 1, true)
    or g:find("unable to drop", 1, true)
  local I = g:find("any more", 1, true)
    or g:find("anymore", 1, true)
    or g:find("more items", 1, true)
    or g:find("more seeds", 1, true)
  if D and I then
    return true
  end
  if g:find("drop limit", 1, true) or g:find("maximum dropped", 1, true) or g:find("too many dropped", 1, true) then
    return true
  end
  if
    g:find("too many items", 1, true)
    and (g:find("drop", 1, true) or g:find("here", 1, true) or g:find("ground", 1, true) or g:find("tile", 1, true))
  then
    return true
  end
  return false
end
local EA = nil
local HA = false
local AA = false
local eA = false
local function aA(U) end
local function yA(U)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(U))
    end)
  end
end
local function VA(U)
  if JA ~= U then
    JA = U
    editValue("TapTap_mode", U)
    aA("TapTap mode: " .. U)
  end
end
local function pA(U, g)
  local D = editToggle or EditToggle
  if D ~= nil then
    pcall(D, U, g)
  end
end
local function iA(U)
  pA("ModFly", U)
  pA("Anticollect", U)
  zA = (U == true)
end
local function rA(U)
  pA("ModFly", U)
  pA("Anticollect", false)
  zA = false
end
local function KA()
  local U = GetLocal or getLocal
  if U == nil then
    return nil
  end
  local g, D = pcall(U)
  if g then
    return D
  end
  return nil
end
local function hA()
  local U = GetWorldName or getCurrentWorldName
  if U == nil then
    return ""
  end
  local g, D = pcall(U)
  if g and type(D) == "string" then
    return D
  end
  return ""
end
local function jA()
  local U = GetInventory or getInventory
  if U == nil then
    return nil
  end
  local g, D = pcall(U)
  if g and type(D) == "table" then
    return D
  end
  return nil
end
local function vA()
  local U = GetTiles or getTiles
  if U == nil then
    return nil
  end
  local g, D = pcall(U)
  if g and type(D) == "table" then
    return D
  end
  return nil
end
local function ZA(U, g)
  if type(U) ~= "string" or type(g) ~= "string" then
    return false
  end
  return U:upper() == g:upper()
end
local function kA(U)
  if type(U) ~= "string" or U == "" then
    return false
  end
  return U:upper() ~= "EXIT"
end
local function XA()
  if EA == nil or EA == "" then
    return false
  end
  local U = KA()
  if U == nil then
    return false
  end
  local g = hA()
  if kA(g) then
    if ZA(g, EA) then
      eA = true
      return true
    end
    eA = false
    return false
  end
  return eA == true
end
local function cA(U)
  local g = 0
  while Z and g < U do
    if not XA() then
      return false
    end
    local U = jA()
    local D = vA()
    if U ~= nil and (D ~= nil and next(D) ~= nil) then
      return true
    end
    Sleep(100)
    g = g + 100
  end
  return false
end
local function SA(U)
  local g = 0
  while Z and g < U do
    local U = KA()
    local D = hA()
    if kA(D) and not ZA(D, EA) then
      return false
    end
    local I = jA()
    local f = vA()
    if U ~= nil and (I ~= nil and (f ~= nil and next(f) ~= nil)) then
      return true
    end
    Sleep(100)
    g = g + 100
  end
  return false
end
local function CA()
  local U = KA()
  if U == nil then
    return
  end
  local g = U["posX"] // 32
  local D = U["posY"] // 32
  pcall(function()
    FindPath(g, D)
  end)
end
local function Ul(U, g)
  g = g or jA()
  if g == nil then
    return 0
  end
  for g, D in pairs(g) do
    if D["id"] == U then
      return D["amount"]
    end
  end
  return 0
end
local function gl(U)
  U = U or jA()
  if U == nil then
    return 0
  end
  for U, g in pairs(U) do
    if g["id"] ~= s and (g["id"] % 2 == 1 and g["amount"] >= d) then
      return g["id"]
    end
  end
  return 0
end
local function Dl()
  local U = jA()
  if U == nil then
    return 0
  end
  for U, g in pairs(U) do
    local D = tonumber(g["id"])
    local I = tonumber(g["amount"]) or 0
    if D ~= nil and (D > 0 and (D ~= s and (D % 2 == 1 and I > 0))) then
      return D
    end
  end
  return 0
end
local function Il()
  local U = KA()
  if U == nil then
    return nil, nil
  end
  return U["posX"] // 32, U["posY"] // 32
end
local function fl(U, g)
  if not Z or not XA() then
    return false
  end
  for D = 1, j, 1 do
    if not Z or not XA() then
      return false
    end
    local I, f = Il()
    if I == nil then
      HA = true
      return false
    end
    if I == U and f == g then
      return true
    end
    local T = pcall(function()
      FindPath(U, g)
    end)
    if not T then
      if D < j then
        Sleep(r)
      end
    else
      local T = 0
      local F = 0
      local R = I
      local t = f
      while Z and T < h do
        if not XA() then
          HA = true
          return false
        end
        local D, I = Il()
        if D == nil then
          HA = true
          return false
        end
        if D == U and I == g then
          Sleep(v)
          return true
        end
        if D ~= R or I ~= t then
          R = D
          t = I
          F = 0
        else
          F = F + 100
        end
        if F >= K then
          break
        end
        Sleep(100)
        T = T + 100
      end
      if D < j then
        Sleep(r)
      end
    end
  end
  VA("WAIT PATH")
  return false
end
local function Tl()
  local U = GetObjectList or getObjectList
  if U == nil then
    return {}
  end
  local g, D = pcall(U)
  if g and type(D) == "table" then
    return D
  end
  return {}
end
local function Fl(U)
  if U == nil then
    return nil, nil
  end
  local g = tonumber(U["posX"])
  local D = tonumber(U["posY"])
  if (g == nil or D == nil) and U["pos"] ~= nil then
    g = g or tonumber(U["pos"]["x"])
    D = D or tonumber(U["pos"]["y"])
  end
  return g, D
end
local function Rl(U, g)
  if xA ~= U or MA ~= g then
    xA, MA = U, g
    YA = 0
  end
  YA = YA + 1
  VA("DROPPED " .. (tostring(YA) .. " ON TILE"))
  return YA
end
local function tl()
  xA, MA = nil, nil
  oA, YA = 0, 0
end
local function nl()
  if FA then
    editValue("TapTap_packstart", tostring(fA) .. (", " .. tostring(TA)))
  elseif RA or tA then
    local U = RA and tostring(fA) or "NOT SET"
    local g = tA and tostring(TA) or "NOT SET"
    editValue("TapTap_packstart", U .. (", " .. g))
  else
    editValue("TapTap_packstart", "NOT SET")
  end
end
local function ll()
  if FA then
    editValue("TapTap_packcurrent", tostring(DA) .. (", " .. tostring(IA)))
  else
    editValue("TapTap_packcurrent", "NOT SET")
  end
end
local function ql(U, g)
  if not Z or not FA or not XA() then
    return false
  end
  VA("RETURN PACK")
  if g then
    iA(true)
  else
    rA(true)
  end
  local D = fl(fA, TA)
  if D then
    DA = fA
    IA = TA
    ll()
    if U == "SSP" then
      yA("SSP collected - back to Pack Position")
    elseif U == "DROP" then
      yA("Drop finished - back to Pack Position")
    end
  else
    VA("WAIT PACK PATH")
    yA("Cannot return to Pack Position!")
  end
  iA(false)
  zA = false
  return D
end
local function sl()
  nl()
  if RA and tA then
    FA = true
    DA = fA
    IA = TA
    nl()
    ll()
    aA("Manual pack start position set: " .. (fA .. (", " .. TA)))
  end
end
local function wl()
  editValue("TapTap_dropcurrent", tostring(qA) .. (", " .. tostring(sA)))
  editValue("TapTap_droptarget", tostring(qA + 1) .. (", " .. tostring(sA)))
end
local function bl(U, g, D, I)
  if U ~= nil and g ~= nil then
    editValue("TapTap_ssppos", tostring(U) .. (", " .. tostring(g)))
  else
    editValue("TapTap_ssppos", "NONE")
  end
  if D ~= nil and I ~= nil then
    editValue("TapTap_ssppath", tostring(D) .. (", " .. tostring(I)))
  else
    editValue("TapTap_ssppath", "NONE")
  end
end
local function Nl(U, g)
  local D = getTile or GetTile
  if D == nil then
    return nil
  end
  local I, f = pcall(D, U, g)
  if I then
    return f
  end
  return nil
end
local function xl(U, g)
  local D = Nl(U, g)
  if D == nil then
    return false
  end
  return D["collidable"] == true
end
local function Ml()
  local U = KA()
  if U == nil or not Z then
    return false
  end
  local g = hA()
  if kA(g) and not ZA(g, EA) then
    return false
  end
  local D = U["posX"] // 32
  local I = U["posY"] // 32
  local f = { { ["x"] = D + 1, ["y"] = I }, { ["x"] = D - 1, ["y"] = I }, { ["x"] = D, ["y"] = I - 1 } }
  for U, g in ipairs(f) do
    local f = Nl(g["x"], g["y"])
    if f ~= nil and f["collidable"] ~= true then
      local U = false
      for D = 1, 4, 1 do
        if not Z then
          return false
        end
        local I = hA()
        if kA(I) and not ZA(I, EA) then
          return false
        end
        pcall(function()
          FindPath(g["x"], g["y"])
        end)
        local f = 0
        while Z and f < 500 do
          local D = KA()
          I = hA()
          if kA(I) and not ZA(I, EA) then
            return false
          end
          if D ~= nil and (D["posX"] // 32 == g["x"] and D["posY"] // 32 == g["y"]) then
            U = true
            break
          end
          Sleep(100)
          f = f + 100
        end
        if U then
          break
        end
        Sleep(120)
      end
      if U then
        Sleep(i)
        pcall(function()
          FindPath(D, I)
        end)
        local U = 0
        while Z and U < 1200 do
          local g = KA()
          if g ~= nil and (g["posX"] // 32 == D and g["posY"] // 32 == I) then
            Sleep(i)
            return true
          end
          Sleep(100)
          U = U + 100
        end
        return true
      end
    end
  end
  pcall(function()
    FindPath(D, I)
  end)
  Sleep(i)
  return false
end
local function ol()
  local U = KA()
  if U == nil or not XA() then
    return {}, 0
  end
  local g = U["posX"] // 32
  local D = U["posY"] // 32
  local I = {}
  local f = 0
  for U, T in pairs(Tl()) do
    local F = tonumber(T["itemid"])
    if F == s then
      f = f + 1
      local U, F = Fl(T)
      if U ~= nil and F ~= nil then
        local f = math["floor"](U / 32)
        local R = math["floor"](F / 32)
        table["insert"](
          I,
          {
            ["object"] = T,
            ["objectX"] = f,
            ["objectY"] = R,
            ["pixelX"] = U,
            ["pixelY"] = F,
            ["distance"] = math["abs"](g - f) + math["abs"](D - R),
          }
        )
      end
    end
  end
  table["sort"](I, function(U, g)
    return U["distance"] < g["distance"]
  end)
  if #I > 0 then
    bl(I[1]["objectX"], I[1]["objectY"], nil, nil)
  elseif f == 0 then
    bl(nil, nil, nil, nil)
  end
  return I, f
end
local function Yl(U)
  return {
    { U["objectX"], U["objectY"] },
    { U["objectX"] - 1, U["objectY"] },
    { U["objectX"] + 1, U["objectY"] },
    { U["objectX"], U["objectY"] - 1 },
    { U["objectX"] - 1, U["objectY"] - 1 },
    { U["objectX"] + 1, U["objectY"] - 1 },
  }
end
local function Jl(U)
  Z = false
  iA(false)
  zA = false
  GA = false
  mA = false
  bl(nil, nil, nil, nil)
  local g = EditToggle or editToggle
  if g ~= nil then
    pcall(g, "TapTap_enable", false)
  end
  if U then
    VA("DONE - SEEDS DROPPED")
    yA("No SSP remains. Final seed drop finished; script stopped.")
    aA("No dropped SSP remains; remaining seed stacks were dropped and verified.")
  else
    VA("NO SSP - STOPPED")
    yA("No SSP found and no seeds remain. Script stopped.")
    aA("No dropped SSP or remaining seed stacks found. TapTap stopped.")
  end
end
local function ul()
  if not Z or not XA() then
    return false
  end
  local U = GetObjectList or getObjectList
  if type(U) ~= "function" then
    return false
  end
  local g, D = pcall(U)
  if not g or type(D) ~= "table" then
    return false
  end
  for U, g in pairs(D) do
    if tonumber(g["itemid"]) == s then
      return false
    end
  end
  return true
end
local function zl(U)
  if not Z or not XA() then
    return
  end
  if U == nil or U["object"] == nil then
    return
  end
  local g = tonumber(U["object"]["id"])
  if g == nil then
    return
  end
  pcall(function()
    if Z and XA() then
      SendPacketRaw(false, { ["type"] = 11, ["value"] = g, ["x"] = U["pixelX"], ["y"] = U["pixelY"] })
    end
  end)
end
local function Gl(U, g, D, I)
  if not Z or not XA() then
    return false
  end
  bl(U["objectX"], U["objectY"], g, D)
  for f = 1, j, 1 do
    if not Z or not XA() then
      return false
    end
    local T, F = Il()
    if T == nil then
      HA = true
      return false
    end
    local R = false
    local t = pcall(function()
      FindPath(g, D)
    end)
    if t then
      local f = 0
      local t = 0
      local n = T
      local l = F
      while Z and f < h do
        if not XA() then
          HA = true
          return false
        end
        if Ul(s) > I then
          return true
        end
        local T, F = Il()
        if T == nil then
          HA = true
          return false
        end
        local q = math["abs"](T - U["objectX"]) <= 1 and math["abs"](F - U["objectY"]) <= 1
        if q and not R then
          zl(U)
          R = true
        end
        if T == g and F == D then
          if not R then
            zl(U)
            R = true
          end
          local g = 0
          while Z and g < 500 do
            if Ul(s) > I then
              return true
            end
            Sleep(50)
            g = g + 50
          end
          return false
        end
        if T ~= n or F ~= l then
          n = T
          l = F
          t = 0
        else
          t = t + 100
        end
        if t >= K then
          break
        end
        Sleep(100)
        f = f + 100
      end
    end
    if f < j then
      Sleep(r)
    end
  end
  return false
end
local function ml()
  local U, g = ol()
  if g == 0 then
    return false, "NO_SSP"
  end
  if #U == 0 then
    VA("WAIT SSP DATA")
    aA("SSP object(s) exist, but their position data could not be read.")
    return false
  end
  local D = Ul(s)
  VA("COLLECT SSP")
  rA(true)
  for U, g in ipairs(U) do
    if not Z or not XA() then
      rA(false)
      return false
    end
    editValue("TapTap_ssppos", tostring(g["objectX"]) .. (", " .. tostring(g["objectY"])))
    aA("Testing SSP object at " .. (g["objectX"] .. (", " .. g["objectY"])))
    local I = Yl(g)
    for U, I in ipairs(I) do
      local f = I[1]
      local T = I[2]
      if Gl(g, f, T, D) then
        local U = ql("SSP", false)
        if U then
          bl(g["objectX"], g["objectY"], fA, TA)
        end
        return U
      end
      if not Z or not XA() then
        rA(false)
        return false
      end
    end
  end
  rA(false)
  local I = U[1]
  editValue("TapTap_ssppos", tostring(I["objectX"]) .. (", " .. tostring(I["objectY"])))
  editValue("TapTap_ssppath", "NO WORKING PATH")
  local f = (JA == "WAIT SSP PATH")
  VA("WAIT SSP PATH")
  if not f then
    yA("Path not found!")
  end
  aA("Found " .. (g .. " SSP object(s), but actual FindPath could not reach any candidate."))
  return false
end
local function Ll(U)
  local g = jA()
  if not g then
    return false
  end
  local D = Ul(s, g)
  if D <= 0 or D < gA or gl(g) ~= 0 then
    return false
  end
  local I = 0
  local f = math["min"](C and 1 or X, D, (D - gA) + 1)
  local T, F = DA, IA
  for g = 1, f, 1 do
    if not Z or U ~= S then
      return false
    end
    if not XA() then
      HA = true
      return false
    end
    local D = KA()
    if not D or D["posX"] // 32 ~= T or D["posY"] // 32 ~= F or DA ~= T or IA ~= F then
      break
    end
    local R, t = pcall(
      SendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = s, ["x"] = D["posX"], ["y"] = D["posY"], ["px"] = T, ["py"] = F }
    )
    if not R or t == false then
      break
    end
    I = I + 1
    if g < f then
      Sleep(k)
    end
  end
  if I == 0 then
    return false
  end
  local R = 0
  while Z and U == S do
    if not XA() then
      HA = true
      return false
    end
    g = jA()
    if g and Ul(s, g) < D then
      C = false
      Sleep(c)
      return Z and U == S
    end
    if R >= H then
      break
    end
    Sleep(20)
    R = R + 20
  end
  if Z and U == S then
    C = true
    VA("WAIT SERVER")
    Sleep(A)
  end
  return false
end
local function Ol(U, g)
  if not Z or not XA() then
    return false, "WORLD_LOST"
  end
  GA = false
  mA = true
  SendPacket(2, "action|drop\n|itemID|" .. U)
  local D = 0
  local I = 25
  while Z and D < B do
    if QA(qA + 1, sA) then
      mA = false
      GA = false
      return false, "TILE_FULL"
    end
    if not XA() then
      HA = true
      mA = false
      return false, "WORLD_LOST"
    end
    if GA then
      break
    end
    Sleep(I)
    D = D + I
  end
  if not Z then
    mA = false
    return false, "STOPPED"
  end
  if not GA then
    mA = false
    VA("WAIT SERVER")
    Sleep(A)
    return false, "NO_DIALOG"
  end
  GA = false
  mA = false
  if QA(qA + 1, sA) then
    return false, "TILE_FULL"
  end
  if not Z or not XA() then
    return false, "WORLD_LOST"
  end
  SendPacket(
    2,
    "action|dialog_return\n" .. ("dialog_name|drop_item\n" .. ("itemID|" .. (U .. ("|\n" .. ("count|" .. g)))))
  )
  return true, "CONFIRM_SENT"
end
local function Pl(U, g)
  local D = 0
  local I = 50
  while Z and D < E do
    if not XA() then
      return false, "WORLD_LOST"
    end
    local f = Ul(U)
    if f < g then
      if D < UA then
        Sleep(UA - D)
      end
      return true, f
    end
    if QA(qA + 1, sA) then
      return false, "TILE_FULL"
    end
    Sleep(I)
    D = D + I
  end
  return false, Ul(U)
end
local function Wl()
  if not Z or not XA() then
    return false
  end
  local U = KA()
  if U == nil then
    HA = true
    return false
  end
  if U["isLeft"] == false then
    return true
  end
  local g = U["posX"] // 32
  local D = U["posY"] // 32
  local I = g - 1
  local f = D
  local T = Nl(I, f)
  if T == nil or T["collidable"] == true then
    aA("Cannot safely face right because the left-side turn tile is blocked.")
    return false
  end
  if not fl(I, f) then
    return false
  end
  Sleep(60)
  if not Z then
    return false
  end
  if not fl(g, D) then
    return false
  end
  Sleep(60)
  local F = KA()
  if F ~= nil and F["isLeft"] ~= nil then
    aA("Safe facing check: isLeft=" .. tostring(F["isLeft"]))
    return F["isLeft"] == false
  end
  return true
end
local function dl()
  if not Z or not XA() then
    return false
  end
  local U = qA - 1
  local g = sA
  aA(
    "Drop target full at " .. (
        (qA + 1) .. (", " .. (sA .. (". Trying next standing tile to the left: " .. (U .. (", " .. g)))))
      )
  )
  if fl(U, g) then
    qA = U
    sA = g
    wl()
    aA("Moved left for next drop. Stand: " .. (qA .. (", " .. (sA .. (" | Target: " .. ((qA + 1) .. (", " .. sA)))))))
    return true
  end
  local D = nA
  local I = sA - 1
  aA("No path to the left. Trying next row at start X: " .. (D .. (", " .. I)))
  if fl(D, I) then
    qA = D
    sA = I
    wl()
    yA("Next Drop Row = (" .. (qA .. (", " .. (sA .. ")"))))
    aA("Moved to next drop row. Stand: " .. (qA .. (", " .. (sA .. (" | Target: " .. ((qA + 1) .. (", " .. sA)))))))
    return true
  end
  VA("WAIT DROP PATH")
  yA("No drop path found!")
  aA("Could not move left and could not reach next row start at " .. (D .. (", " .. I)))
  return false
end
local function Ql(U, g, D)
  local I = 0
  while Z and I < D do
    if not XA() then
      return false, "WORLD_LOST"
    end
    if jA() == nil then
      return false, "NO_INVENTORY"
    end
    if Ul(U) < g then
      return true, "ACCEPTED"
    end
    Sleep(50)
    I = I + 50
  end
  return Ul(U) < g, "TIMEOUT"
end
local function Bl(U, g)
  if jA() == nil then
    return "NO_INVENTORY"
  end
  local D = Ul(U)
  if D < g then
    return "CHANGED"
  end
  for I = 1, y, 1 do
    if not Z then
      return "STOPPED"
    end
    if not XA() then
      return "WORLD_LOST"
    end
    if jA() == nil then
      return "NO_INVENTORY"
    end
    if Ul(U) < D then
      return "SUCCESS"
    end
    zA = true
    VA(I == 1 and "DROP - CHECK INVENTORY" or "RETRY DROP 2/2 - SAME TILE")
    LA = true
    local f, T = Ol(U, g)
    if f then
      local g, I = Pl(U, D)
      if g then
        LA = false
        return "SUCCESS"
      end
      T = I
    end
    LA = false
    if not Z then
      return "STOPPED"
    end
    if T == "WORLD_LOST" or not XA() then
      return "WORLD_LOST"
    end
    if jA() == nil then
      return "NO_INVENTORY"
    end
    if Ul(U) < D then
      return "SUCCESS"
    end
    if T == "TILE_FULL" or QA(qA + 1, sA) then
      return "REJECTED"
    end
    VA(I == 1 and "WAIT DROP ACK - RETRY" or "WAIT DROP ACK - SHIFT")
    local F, R = Ql(U, D, I == 1 and e or a)
    if F then
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
local function El(U)
  local g = false
  local D = true
  local I = 0
  local function f()
    wA = true
    LA = false
    VA("DROP FAILED - MOVE LEFT")
    if not dl() then
      VA("WAIT LEFT PATH - NO DROP")
      return false
    end
    wA = false
    dA()
    g, D = true, true
    I = I + 1
    return true
  end
  while Z do
    if not XA() then
      HA = true
      return false
    end
    if jA() == nil then
      VA("WAIT INVENTORY")
      return false
    end
    local T = NA
    if T ~= nil then
      local g = Ul(T)
      if g <= 0 or (not U and g < d) then
        NA = nil
        T = nil
      end
    end
    if T == nil then
      T = U and Dl() or gl()
    end
    if T == 0 then
      return true
    end
    if wA then
      if not f() then
        return false
      end
    elseif not g then
      if not fl(qA, sA) then
        VA("WAIT DROP PATH")
        yA("Path not found!")
        return false
      end
      g = true
      D = true
    end
    local F, R = qA + 1, sA
    if xl(F, R) or QA(F, R) then
      NA = T
      if not f() then
        return false
      end
    else
      if D then
        if not Wl() then
          VA("WAIT DROP FACING")
          yA("Cannot face right safely!")
          return false
        end
        D = false
      end
      local g = Ul(T)
      local I = U and math["min"](d, g) or d
      if I <= 0 or g < I then
        NA = nil
        Sleep(50)
      else
        local U = Bl(T, I)
        if U == "SUCCESS" then
          NA = nil
          bA = 0
          Rl(F, R)
        elseif U == "REJECTED" then
          NA = T
          bA = bA + 1
          if not f() then
            return false
          end
        elseif U == "CHANGED" then
          NA = nil
        elseif U == "NO_INVENTORY" then
          VA("WAIT INVENTORY")
          return false
        elseif U == "WORLD_LOST" then
          HA = true
          return false
        else
          return false
        end
      end
    end
    if bA >= V then
      VA("SERVER SLOW - DROP COOLDOWN")
      Sleep(1500)
      bA = 0
      return false
    end
    if I >= 30 then
      VA("DROP SHIFT BREAK")
      Sleep(400)
      return false
    end
    Sleep(30)
  end
  return false
end
local function Hl()
  local U = KA()
  if U == nil then
    aA("Cannot set pack position: player not loaded.")
    return
  end
  fA = U["posX"] // 32
  TA = U["posY"] // 32
  DA = fA
  IA = TA
  RA = true
  tA = true
  FA = true
  editValue("TapTap_packx", tostring(fA))
  editValue("TapTap_packy", tostring(TA))
  nl()
  ll()
  uA()
  yA("Pack Position = (" .. (fA .. (", " .. (TA .. ")"))))
  aA("Pack start position set: " .. (fA .. (", " .. TA)))
end
local function Al()
  local U = KA()
  if U == nil then
    aA("Cannot set drop position: player not loaded.")
    return
  end
  nA = U["posX"] // 32
  lA = U["posY"] // 32
  qA = nA
  sA = lA
  tl()
  dA()
  LA = false
  wA = false
  bA = 0
  editValue("TapTap_dropx", tostring(nA))
  editValue("TapTap_dropy", tostring(lA))
  wl()
  uA()
  yA("Drop Position = (" .. (nA .. (", " .. (lA .. ")"))))
  aA("Drop start position set: " .. (nA .. (", " .. lA)))
end
local function el()
  if not Z then
    return false
  end
  if XA() then
    if HA or AA then
      iA(false)
      VA("RESUMING")
      Sleep(p)
      if not Z then
        return false
      end
      local U = hA()
      if kA(U) and not ZA(U, EA) then
        eA = false
        return false
      end
      if not cA(3000) then
        VA("RESUMING")
        Sleep(100)
        return false
      end
      VA("RESUME MOVE")
      Ml()
      if not Z then
        return false
      end
      U = hA()
      if kA(U) and not ZA(U, EA) then
        eA = false
        return false
      end
      HA = false
      AA = false
      eA = true
      yA("TapTap resumed automatically.")
    end
    return true
  end
  if HA and AA then
    iA(false)
    VA("RESUMING")
    Sleep(p)
    if not Z then
      return false
    end
    if SA(4000) then
      local U = hA()
      if kA(U) and not ZA(U, EA) then
        eA = false
        VA("PAUSED - WAIT WORLD")
        return false
      end
      eA = true
      VA("RESUME MOVE")
      Ml()
      if not Z then
        return false
      end
      U = hA()
      if kA(U) and not ZA(U, EA) then
        eA = false
        VA("PAUSED - WAIT WORLD")
        return false
      end
      HA = false
      AA = false
      yA("TapTap resumed automatically.")
      return true
    end
  end
  if not HA then
    HA = true
    yA("TapTap paused - return to " .. tostring(EA))
  end
  eA = false
  GA = false
  mA = false
  iA(false)
  VA("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
function onVariant(U, g)
  if U ~= nil then
    if Z and (U["v1"] == "OnSpawn" and type(U["v2"]) == "string") then
      local g = U["v2"]:find("type|local", 1, true) ~= nil
      if not g then
        local D = tonumber(U["v2"]:match("netID|(%d+)"))
        local I = KA()
        if D ~= nil and I ~= nil then
          g = tonumber(I["netID"]) == D
        end
      end
      if g and (HA or not eA) then
        AA = true
        HA = true
      end
    end
    if Z and (HA and U["v1"] == "OnSetPos") then
      AA = true
    end
    if Z and LA then
      local g = true
      if U["v1"] == "OnTalkBubble" then
        local D = KA()
        if D ~= nil and (D["netID"] ~= nil and tonumber(U["v2"]) ~= tonumber(D["netID"])) then
          g = false
        end
      end
      if g then
        for g = 2, 7, 1 do
          local D = U["v" .. tostring(g)]
          if BA(D) then
            PA = qA + 1
            WA = sA
            OA = true
            aA("Server says drop tile is full: " .. (tostring(PA) .. (", " .. tostring(WA))))
            break
          end
        end
      end
    end
    if U["v1"] == "OnDialogRequest" and type(U["v2"]) == "string" then
      if U["v2"]:find("drop_item", 1, true) then
        if Z and mA then
          GA = true
        end
        return true
      end
    end
  end
  return false
end
function onSendPacket(U, g)
  if Z and type(g) == "string" then
    local U = g:find("action|quit", 1, true) ~= nil
    local D = g:find("action|join_request", 1, true) ~= nil
    if U or D then
      eA = false
      HA = true
      AA = false
      GA = false
      mA = false
      iA(false)
      VA("PAUSED - WAIT WORLD")
    end
  end
  return false
end
function onSendPacketRaw(U)
  if Z and (zA and U ~= nil) then
    if tonumber(U["type"]) == 11 then
      aA("Blocked item collect packet during protected drop travel.")
      return true
    end
  end
  return false
end
function onGamePacket(U)
  if U ~= nil and (U["type"] == 26 and Z) then
    if not HA then
      yA("TapTap paused - disconnected.")
    end
    HA = true
    AA = false
    eA = false
    GA = false
    mA = false
    iA(false)
    VA("PAUSED - WAIT WORLD")
    aA("Disconnect detected. TapTap is paused until you manually return to the target world.")
  end
  return false
end
local function al(U)
  U = tostring(U or "")
  U = U:gsub("\n", "\r\n")
  U = U:gsub("([^%w%-_%.~])", function(U)
    return string["format"]("%%%02X", string["byte"](U))
  end)
  return U
end
local function yl()
  local U = ""
  if type(getDiscordID) == "function" then
    local g, D = pcall(getDiscordID)
    if g and D ~= nil then
      U = tostring(D)
    end
  elseif getDiscordID ~= nil then
    U = tostring(getDiscordID)
  end
  U = ((tostring(U or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if U == "" or U == "nil" or U == "0" then
    local g = GetLocal or getLocal
    if g ~= nil then
      local D, I = pcall(g)
      if D and (I ~= nil and I["name"] ~= nil) then
        U = tostring(I["name"])
        U = (U:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  if U == "nil" or U == "0" then
    return ""
  end
  return U
end
local function Vl(U)
  pcall(editValue, "TapTap_licensestatus", U)
end
local pl = {
  ["DISABLED"] = { "DISABLED", "License disabled." },
  ["WRONG_PRODUCT"] = { "WRONG PRODUCT", "This license is for another script." },
  ["BOUND_TO_OTHER_USER"] = { "BOUND TO OTHER USER", "License is bound to another user." },
  ["INVALID_KEY"] = { "INVALID KEY", "Invalid license key." },
  ["BAD_KEY_FORMAT"] = { "BAD KEY FORMAT", "License key format is invalid." },
  ["NO_ID"] = { "NO CLIENT ID", "Client ID is unavailable." },
}
local function il(U)
  if not U:match("^[A-Z]%d%d%d%d%d%d%d$") then
    return false, "INVALID KEY FORMAT", "License must be 1 letter + 7 numbers, for example A1234567."
  end
  local I = yl()
  if I == "" then
    return false, "NO CLIENT ID", "Could not read a client ID. Enter the game first and try again."
  end
  local f = g .. ("?key=" .. (al(U) .. ("&id=" .. (al(I) .. ("&product=" .. al(D))))))
  local T, F = pcall(fetch, f)
  if not T then
    return false, "SERVER ERROR", "License server request failed."
  end
  F = (tostring(F or "")):match("^%s*(.-)%s*$")
  local R = F:match("DENY|([A-Z_]+)")
  if R then
    local U = pl[R]
    if U then
      return false, U[1], U[2]
    end
    return false, "DENIED", "License denied by server."
  end
  if F:find("OK|PERMANENT", 1, true) then
    return true, "VERIFIED - PERMANENT"
  end
  if F == "" then
    return false, "NO RESPONSE", "License server gave no response."
  end
  return false, "CHECK FAILED", "License check failed."
end
local rl, Kl
local hl, jl = false, false
local function vl()
  jl = true
  pA("TapTap_enable", false)
  jl = false
end
local function Zl(U)
  Z = true
  S = S + 1
  C = false
  EA = U
  HA = false
  AA = false
  eA = true
  tl()
  dA()
  LA = false
  wA = false
  bA = 0
  NA = nil
  VA("STARTING")
  yA("TapTap started.")
end
local function kl()
  Z = false
  S = S + 1
  C = false
  rl = nil
  zA = false
  GA = false
  mA = false
  LA = false
  wA = false
  bA = 0
  NA = nil
  dA()
  iA(false)
  VA("STOPPED")
  HA = false
  AA = false
  eA = false
  yA("TapTap stopped safely.")
end
local function Xl(U)
  U["key"] = f
  U["revision"] = T
  Kl = U
  if hl then
    return
  end
  hl = true
  runThread(function()
    while Kl do
      local U = Kl
      Kl = nil
      if U["revision"] == T and (not U["world"] or rl == U) then
        Vl("CHECKING...")
        local g, D, I = il(U["key"])
        if U["revision"] == T then
          Vl(D)
          if g then
            local g = R(U["key"])
            if U["manual"] then
              yA(g and "License verified and saved." or "License verified. Could not save it.")
            end
          elseif U["manual"] or rl == U then
            yA(I)
          end
          if rl == U then
            rl = nil
            if g and (FA and (ZA(hA(), U["world"]) and KA())) then
              Zl(U["world"])
            else
              if g then
                yA("Return to the farming world and check your Pack Position.")
              end
              vl()
              VA("STOPPED")
            end
          end
        end
      end
    end
    hl = false
  end)
end
local function cl()
  if not rl then
    return
  end
  rl = nil
  vl()
  VA("STOPPED")
end
local function Sl(U)
  if type(U) == "table" then
    U = U["id"] or U["itemID"] or U["itemid"] or U["value"] or U["name"]
  end
  local g = tonumber(U)
  if not g and type(U) == "string" then
    g = tonumber(U:match("%((%d+)%)"))
    local D = findItemID or (growtopia and growtopia["getItemID"])
    if not g and type(D) == "function" then
      local I, f = pcall(D, U)
      if I then
        g = tonumber(f)
      end
    end
  end
  if not g or g < 1 or g > 65535 or g % 1 ~= 0 then
    return false
  end
  if g == s then
    return true
  end
  if Z or rl then
    yA("Stop the script before changing the item to tap.")
    return true
  end
  s = g
  uA()
  return true
end
function onValue(U, g, D)
  if g == "TapTap_itempicker" then
    Sl(D)
    return
  end
  if g == "TapTap_enable" then
    if jl then
      return
    end
    if D ~= true then
      if Z or rl then
        kl()
      end
      return
    end
    if Z or rl then
      return
    end
    local U = hA()
    if not FA or not kA(U) or not KA() then
      vl()
      yA(not FA and "Set Pack Position first." or "Enter the farming world first, then press Start.")
      return
    end
    rl = { ["world"] = U }
    VA("CHECKING LICENSE")
    Xl(rl)
    return
  end
  if g == "TapTap_licensekey" then
    local U = F(D)
    if U ~= f then
      f = U
      T = T + 1
      cl()
      Vl("NOT VERIFIED")
    end
    return
  end
  if g == "TapTap_verifylicense" then
    if not rl then
      Xl({ ["manual"] = true })
    end
    return
  end
  if g == "TapTap_clearlicense" then
    f = ""
    T = T + 1
    cl()
    local U = R("")
    pcall(editValue, "TapTap_licensekey", "")
    Vl("NOT VERIFIED")
    yA(U and "Saved license cleared." or "Could not update saved license storage.")
    return
  end
  if g == "TapTap_delay" then
    local U = tonumber(D)
    if U ~= nil then
      if U < 1 then
        U = 1
      end
      k = math["floor"](U)
      uA()
      aA("Pack Delay: " .. (k .. " ms"))
    end
    return
  end
  if g == "TapTap_bursttaps" then
    local U = tonumber(D)
    if U then
      X = math["max"](1, math["min"](25, math["floor"](U)))
      uA()
    end
    return
  end
  if g == "TapTap_burstpause" then
    local U = tonumber(D)
    if U then
      c = math["max"](1, math["min"](10000, math["floor"](U)))
      uA()
    end
    return
  end
  if g == "TapTap_dropdelay" then
    local U = tonumber(D)
    if U ~= nil then
      U = math["floor"](U)
      if U < 200 then
        U = 200
      end
      if U > 500 then
        U = 500
      end
      UA = U
      uA()
      aA("Drop Delay: " .. (UA .. " ms"))
    end
    return
  end
  if g == "TapTap_minssp" then
    local U = tonumber(D)
    if U ~= nil then
      U = math["floor"](U)
      if U < 0 then
        U = 0
      end
      if U > 200 then
        U = 200
      end
      gA = U
      uA()
      aA("Minimum SSP Threshold: " .. gA)
    end
    return
  end
  if g == "TapTap_packx" then
    local U = tonumber(D)
    if U ~= nil then
      fA = math["floor"](U)
      RA = true
      sl()
      uA()
    end
    return
  end
  if g == "TapTap_packy" then
    local U = tonumber(D)
    if U ~= nil then
      TA = math["floor"](U)
      tA = true
      sl()
      uA()
    end
    return
  end
  if g == "TapTap_setpack" then
    Hl()
    return
  end
  if g == "TapTap_dropx" then
    local U = tonumber(D)
    if U ~= nil then
      nA = math["floor"](U)
      qA = nA
      sA = lA
      tl()
      dA()
      LA = false
      wA = false
      bA = 0
      NA = nil
      wl()
      uA()
    end
    return
  end
  if g == "TapTap_dropy" then
    local U = tonumber(D)
    if U ~= nil then
      lA = math["floor"](U)
      qA = nA
      sA = lA
      tl()
      dA()
      LA = false
      wA = false
      bA = 0
      NA = nil
      wl()
      uA()
    end
    return
  end
  if g == "TapTap_setdrop" then
    Al()
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(setOnValue, "TapTap_itempicker", function(...)
    for U = select("#", ...), 1, -1 do
      if Sl(select(U, ...)) then
        return
      end
    end
  end)
end
runThread(function()
  iA(false)
  VA("STOPPED")
  if f ~= "" and (not rl and not hl) then
    Xl({})
  end
  while true do
    if Z then
      if not el() then
        Sleep(200)
      else
        local U = 400
        local g = gl()
        if g ~= 0 then
          VA("DROP")
          iA(true)
          local U = El()
          if U and (Z and XA()) then
            ql("DROP", true)
          end
        else
          VA("GACHA")
          iA(false)
          local g = true
          if Ul(s) < gA then
            local U, D = ml()
            if U then
              g = false
              Sleep(200)
            elseif D == "NO_SSP" then
              g = false
              VA("VERIFY NO SSP")
              Sleep(250)
              if Z and (XA() and ul()) then
                if jA() == nil then
                  VA("WAIT INVENTORY")
                elseif Dl() ~= 0 then
                  VA("FINAL SEED DROP")
                  iA(true)
                  local U = El(true)
                  if U and (Z and XA()) then
                    ql("DROP", true)
                    if Z and XA() then
                      Jl(true)
                    end
                  end
                else
                  Jl(false)
                end
              else
                VA("WAIT SSP DATA")
              end
              Sleep(150)
            else
              if not XA() then
                HA = true
              end
              g = false
              Sleep(500)
            end
          end
          if g and Z then
            local g = S
            local D, I = Il()
            if D and ((D == DA and I == IA or fl(DA, IA)) and (Z and (g == S and Ll(g)))) then
              U = 0
            end
          end
        end
        if U > 0 then
          Sleep(U)
        end
      end
    else
      Sleep(200)
    end
  end
end)
aA(U .. " loaded.")
