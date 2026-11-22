setMinimum("6.1.2")
local p = "Premium Auto open ssp + drop by Bangshu"
do
  local l =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local G = "SSPS"
  local b = "SSPS-38-PAID-001"
  local Q = "approval"
  local x = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function w()
    local p, l = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not p then
      return nil
    end
    if type(l) == "number" and (math["type"] and math["type"](l) == "integer") then
      l = tostring(l)
    end
    if type(l) ~= "string" or #l < 17 or #l > 20 or not l:match("^%d+$") then
      return nil
    end
    if l:match("^0+$") then
      return nil
    end
    return l
  end
  local function L(p, l)
    if not l or type(p) ~= "string" or #p > 512 then
      return false
    end
    local Q, w, L = p:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (x .. '"}}%s*$')
    )
    return Q == l and (w == G and L == b)
  end
  local m, H, g = pcall(function()
    local p, l = pcall(require, "preferences")
    local G = p and (type(l) == "table" and l) or Preferences
    if type(G) ~= "table" or type(G["new"]) ~= "function" then
      return nil
    end
    local b = G:new("BangshuPremiumSSPS")
    if b:load() == false then
      return b
    end
    return b, b:get(Q, "")
  end)
  if not m then
    H = nil
  end
  if not L(g, w()) then
    local x, m = false, false
    local function g(p)
      pcall(editValue, "TapTap_premium_status", p)
      if type(sendNotification) == "function" then
        pcall(sendNotification, p)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], p)
      end
    end
    local function X()
      if x or m then
        return
      end
      local p = w()
      if not p then
        g("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not H then
        g("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      x = true
      g("CHECKING")
      local X = pcall(runThread, function()
        local w = l
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              p .. ("&product=" .. (G .. ("&format=growlauncher&version=" .. b)))
            )
          )
        local X, F = pcall(fetch, w)
        if X and type(F) == "string" then
          local p = F:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if p and (#p <= 1024 and #p % 2 == 0) then
            F = p:gsub("..", function(p)
              return string["char"](tonumber(p, 16))
            end)
          end
        end
        if not X or type(F) ~= "string" then
          g("DENIED - REQUEST FAILED")
        elseif not L(F, p) then
          if F:match('^%s*{"status":"DENIED",') then
            g("DENIED - NO PREMIUM ACCESS")
          elseif F:match('^%s*{"status":"ERROR",') then
            g("DENIED - APPS SCRIPT SERVER ERROR")
          elseif F:match("^%s*<") then
            if F:find("doGet", 1, true) then
              g("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              g("DENIED - GOOGLE RETURNED HTML")
            end
          elseif F:match("^%s*$") then
            g("DENIED - EMPTY SERVER RESPONSE")
          elseif F:match('^%s*{"status":"APPROVED",') then
            g("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            g("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local l, G = pcall(function()
            if H:set(Q, F) == false then
              return false
            end
            if H:save() == false then
              return false
            end
            if H:load() == false then
              return false
            end
            return L(H:get(Q, ""), p)
          end)
          m = l and G == true
          g(m and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        x = false
      end)
      if not X then
        x = false
        g("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(p, l)
      if l == "TapTap_premium_verify" then
        X()
      end
    end
    onValue = OnValue
    local F = UserInterface["new"](p, "Rocket")
    F:addButton("Verify Access", "TapTap_premium_verify")
    F:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "TapTap_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, p, "Rocket")
    end
    addIntoModule(F:generateJSON(), p)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "TapTap_premium_verify", X)
    end
    return
  end
end
local l = "taptap_drop_ssp_v32_settings.json"
local G = nil
local b = false
do
  local p, b = pcall(require, "preferences")
  if not p or b == nil then
    b = Preferences
  end
  if b ~= nil and type(b["new"]) == "function" then
    local p, Q = pcall(function()
      return b:new(l)
    end)
    if p and Q ~= nil then
      G = Q
      pcall(function()
        G:load()
      end)
    end
  end
end
local function Q(p, l, b, Q)
  local x = l
  if G ~= nil then
    local b, Q = pcall(function()
      return G:get(p, l)
    end)
    if b and tonumber(Q) ~= nil then
      x = tonumber(Q)
    end
  end
  x = math["floor"](x)
  if b ~= nil then
    x = math["max"](b, x)
  end
  if Q ~= nil then
    x = math["min"](Q, x)
  end
  return x
end
local x = Q("tapItemID", 5706, 1, 65535)
local w = Q("burstTapIntervalMs", 100, 1, 100000)
local L = Q("burstTaps", 10, 1, 25)
local m = Q("burstPostAckPause", 20, 1, 10000)
local H = Q("dropDelay", 500, 200, 500)
local g = Q("minSSP", 25, 0, 200)
local X = Q("packStartX", 0)
local F = Q("packStartY", 0)
local I = Q("dropStartX", 2)
local t = Q("dropStartY", 32)
local c = Q("packXInputSet", 0, 0, 1) == 1
local S = Q("packYInputSet", 0, 0, 1) == 1
local E = Q("packPositionSet", 0, 0, 1) == 1 and (c and S)
local O = "NOT SET"
if E then
  O = tostring(X) .. (", " .. tostring(F))
elseif c or S then
  O = (c and tostring(X) or "NOT SET") .. (", " .. (S and tostring(F) or "NOT SET"))
end
local v = E and (tostring(X) .. (", " .. tostring(F))) or "NOT SET"
local R = UserInterface["new"](p, "Rocket")
R:addLabelApp(p, "Bolt")
R:addToggle("Start / Stop", false, "TapTap_enable")
R:addItemPicker("Select Item to Tap", tostring(x), tostring(x), "TapTap_itempicker")
R:addInputInt("Delay Between Taps", tostring(w), "ms", "100", nil, "TapTap_delay")
R:addSlider("Taps per Burst", 1, 25, L, 1, false, "TapTap_bursttaps")
R:addInputInt("Pause After Burst", tostring(m), "ms", "20", nil, "TapTap_burstpause")
R:addSlider("Drop Delay", 200, 500, H, 10, false, "TapTap_dropdelay")
R:addInputInt("Minimum Tap Item Threshold", tostring(g), "items", "25", nil, "TapTap_minssp")
R:addInputInt("Pack Position X", tostring(X), "X", "0", nil, "TapTap_packx")
R:addInputInt("Pack Position Y", tostring(F), "Y", "0", nil, "TapTap_packy")
R:addButton("Set Pack Position = Current Tile", "TapTap_setpack")
R:addDisplayList("Selected Pack Position", O, "TapTap_packstart")
R:addDisplayList("Current Pack Position", v, "TapTap_packcurrent")
R:addInputInt("Drop Position X", tostring(I), "X", "2", nil, "TapTap_dropx")
R:addInputInt("Drop Position Y", tostring(t), "Y", "32", nil, "TapTap_dropy")
R:addButton("Set Drop Position = Current Tile", "TapTap_setdrop")
R:addDisplayList("Current Drop Position", tostring(I) .. (", " .. tostring(t)), "TapTap_dropcurrent")
R:addDisplayList("Current Drop Target (Right)", tostring(I + 1) .. (", " .. tostring(t)), "TapTap_droptarget")
R:addDisplayList("Detected SSP Position", "NONE", "TapTap_ssppos")
R:addDisplayList("SSP Path Destination", "NONE", "TapTap_ssppath")
R:addDisplayList("Current Mode", "STOPPED", "TapTap_mode")
R:addDisplayList("End of SSP", "AUTO DROP REMAINING SEEDS", "TapTap_endseeds")
R:addDisplayList("Settings", G ~= nil and "AUTO SAVE ON" or "AUTO SAVE UNAVAILABLE", "TapTap_settingsstatus")
pcall(function()
  addCategory(p, "Rocket")
end)
local y = pcall(function()
  addIntoModule(R:generateJSON(), p)
end)
if not y then
  addIntoModule(R:generateJSON())
end
local K = 200
local e = 800
local s = 1800
local j = 1800
local V = 1800
local k = 250
local W = 350
local D = 450
local q = 2
local n = 4
local P = 300
local M = 140
local U = 300
local Y = 1200
local d = 6000
local f = 2
local o = 150
local T = false
local u = w
local J = L
local z = m
local A = 0
local a = false
local h = H
local i = g
local r = X
local N = F
local Z = X
local B = F
local C = E
local pg = c
local lg = S
local Gg = I
local bg = t
local Qg = Gg
local xg = bg
local wg = false
local Lg = 0
local mg = nil
local Hg, gg = nil, nil
local Xg, Fg = 0, 0
local Ig = "STOPPED"
local function tg()
  if G == nil then
    return false
  end
  local p, l = pcall(function()
    G:set("burstTapIntervalMs", u)
    G:set("burstTaps", J)
    G:set("burstPostAckPause", z)
    G:set("dropDelay", h)
    G:set("minSSP", i)
    G:set("tapItemID", x)
    G:set("packStartX", Z)
    G:set("packStartY", B)
    G:set("packXInputSet", pg and 1 or 0)
    G:set("packYInputSet", lg and 1 or 0)
    G:set("packPositionSet", C and 1 or 0)
    G:set("dropStartX", Gg)
    G:set("dropStartY", bg)
    G:save()
  end)
  if not p then
    if not b then
      b = true
      pcall(function()
        growtopia["notify"]("TapTap settings could not be saved: " .. tostring(l))
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
local cg = false
local Sg = false
local Eg = false
local Og = false
local vg = false
local Rg, yg = nil, nil
local function Kg()
  vg = false
  Rg, yg = nil, nil
end
local function eg(p, l)
  return vg and (Rg == p and yg == l)
end
local function sg(p)
  if type(p) ~= "string" then
    return false
  end
  local l = (p:lower()):gsub("`.", "")
  l = (l:gsub("[^%a%d%s]", " ")):gsub("%s+", " ")
  local G = l:find("can t drop", 1, true)
    or l:find("cant drop", 1, true)
    or l:find("cannot drop", 1, true)
    or l:find("unable to drop", 1, true)
  local b = l:find("any more", 1, true)
    or l:find("anymore", 1, true)
    or l:find("more items", 1, true)
    or l:find("more seeds", 1, true)
  if G and b then
    return true
  end
  if l:find("drop limit", 1, true) or l:find("maximum dropped", 1, true) or l:find("too many dropped", 1, true) then
    return true
  end
  if
    l:find("too many items", 1, true)
    and (l:find("drop", 1, true) or l:find("here", 1, true) or l:find("ground", 1, true) or l:find("tile", 1, true))
  then
    return true
  end
  return false
end
local jg = nil
local Vg = false
local kg = false
local Wg = false
local function Dg(p) end
local function qg(p)
  if growtopia ~= nil and type(growtopia["notify"]) == "function" then
    pcall(function()
      growtopia["notify"](tostring(p))
    end)
  end
end
local function ng(p)
  if Ig ~= p then
    Ig = p
    editValue("TapTap_mode", p)
    Dg("TapTap mode: " .. p)
  end
end
local function Pg(p, l)
  local G = editToggle or EditToggle
  if G ~= nil then
    pcall(G, p, l)
  end
end
local function Mg(p)
  Pg("ModFly", p)
  Pg("Anticollect", p)
  cg = (p == true)
end
local function Ug(p)
  Pg("ModFly", p)
  Pg("Anticollect", false)
  cg = false
end
local function Yg()
  local p = GetLocal or getLocal
  if p == nil then
    return nil
  end
  local l, G = pcall(p)
  if l then
    return G
  end
  return nil
end
local function dg()
  local p = GetWorldName or getCurrentWorldName
  if p == nil then
    return ""
  end
  local l, G = pcall(p)
  if l and type(G) == "string" then
    return G
  end
  return ""
end
local function fg()
  local p = GetInventory or getInventory
  if p == nil then
    return nil
  end
  local l, G = pcall(p)
  if l and type(G) == "table" then
    return G
  end
  return nil
end
local function og()
  local p = GetTiles or getTiles
  if p == nil then
    return nil
  end
  local l, G = pcall(p)
  if l and type(G) == "table" then
    return G
  end
  return nil
end
local function Tg(p, l)
  if type(p) ~= "string" or type(l) ~= "string" then
    return false
  end
  return p:upper() == l:upper()
end
local function ug(p)
  if type(p) ~= "string" or p == "" then
    return false
  end
  return p:upper() ~= "EXIT"
end
local function Jg()
  if jg == nil or jg == "" then
    return false
  end
  local p = Yg()
  if p == nil then
    return false
  end
  local l = dg()
  if ug(l) then
    if Tg(l, jg) then
      Wg = true
      return true
    end
    Wg = false
    return false
  end
  return Wg == true
end
local function zg(p)
  local l = 0
  while T and l < p do
    if not Jg() then
      return false
    end
    local p = fg()
    local G = og()
    if p ~= nil and (G ~= nil and next(G) ~= nil) then
      return true
    end
    Sleep(100)
    l = l + 100
  end
  return false
end
local function Ag(p)
  local l = 0
  while T and l < p do
    local p = Yg()
    local G = dg()
    if ug(G) and not Tg(G, jg) then
      return false
    end
    local b = fg()
    local Q = og()
    if p ~= nil and (b ~= nil and (Q ~= nil and next(Q) ~= nil)) then
      return true
    end
    Sleep(100)
    l = l + 100
  end
  return false
end
local function ag()
  local p = Yg()
  if p == nil then
    return
  end
  local l = p["posX"] // 32
  local G = p["posY"] // 32
  pcall(function()
    FindPath(l, G)
  end)
end
local function hg(p, l)
  l = l or fg()
  if l == nil then
    return 0
  end
  for l, G in pairs(l) do
    if G["id"] == p then
      return G["amount"]
    end
  end
  return 0
end
local function ig(p)
  p = p or fg()
  if p == nil then
    return 0
  end
  for p, l in pairs(p) do
    if l["id"] ~= x and (l["id"] % 2 == 1 and l["amount"] >= K) then
      return l["id"]
    end
  end
  return 0
end
local function rg()
  local p = fg()
  if p == nil then
    return 0
  end
  for p, l in pairs(p) do
    local G = tonumber(l["id"])
    local b = tonumber(l["amount"]) or 0
    if G ~= nil and (G > 0 and (G ~= x and (G % 2 == 1 and b > 0))) then
      return G
    end
  end
  return 0
end
local function Ng()
  local p = Yg()
  if p == nil then
    return nil, nil
  end
  return p["posX"] // 32, p["posY"] // 32
end
local function Zg(p, l)
  if not T or not Jg() then
    return false
  end
  for G = 1, f, 1 do
    if not T or not Jg() then
      return false
    end
    local b, Q = Ng()
    if b == nil then
      Vg = true
      return false
    end
    if b == p and Q == l then
      return true
    end
    local x = pcall(function()
      FindPath(p, l)
    end)
    if not x then
      if G < f then
        Sleep(U)
      end
    else
      local x = 0
      local w = 0
      local L = b
      local m = Q
      while T and x < d do
        if not Jg() then
          Vg = true
          return false
        end
        local G, b = Ng()
        if G == nil then
          Vg = true
          return false
        end
        if G == p and b == l then
          Sleep(o)
          return true
        end
        if G ~= L or b ~= m then
          L = G
          m = b
          w = 0
        else
          w = w + 100
        end
        if w >= Y then
          break
        end
        Sleep(100)
        x = x + 100
      end
      if G < f then
        Sleep(U)
      end
    end
  end
  ng("WAIT PATH")
  return false
end
local function Bg()
  local p = GetObjectList or getObjectList
  if p == nil then
    return {}
  end
  local l, G = pcall(p)
  if l and type(G) == "table" then
    return G
  end
  return {}
end
local function Cg(p)
  if p == nil then
    return nil, nil
  end
  local l = tonumber(p["posX"])
  local G = tonumber(p["posY"])
  if (l == nil or G == nil) and p["pos"] ~= nil then
    l = l or tonumber(p["pos"]["x"])
    G = G or tonumber(p["pos"]["y"])
  end
  return l, G
end
local function pq(p, l)
  if Hg ~= p or gg ~= l then
    Hg, gg = p, l
    Fg = 0
  end
  Fg = Fg + 1
  ng("DROPPED " .. (tostring(Fg) .. " ON TILE"))
  return Fg
end
local function lq()
  Hg, gg = nil, nil
  Xg, Fg = 0, 0
end
local function Gq()
  if C then
    editValue("TapTap_packstart", tostring(Z) .. (", " .. tostring(B)))
  elseif pg or lg then
    local p = pg and tostring(Z) or "NOT SET"
    local l = lg and tostring(B) or "NOT SET"
    editValue("TapTap_packstart", p .. (", " .. l))
  else
    editValue("TapTap_packstart", "NOT SET")
  end
end
local function bq()
  if C then
    editValue("TapTap_packcurrent", tostring(r) .. (", " .. tostring(N)))
  else
    editValue("TapTap_packcurrent", "NOT SET")
  end
end
local function Qq(p, l)
  if not T or not C or not Jg() then
    return false
  end
  ng("RETURN PACK")
  if l then
    Mg(true)
  else
    Ug(true)
  end
  local G = Zg(Z, B)
  if G then
    r = Z
    N = B
    bq()
    if p == "SSP" then
      qg("SSP collected - back to Pack Position")
    elseif p == "DROP" then
      qg("Drop finished - back to Pack Position")
    end
  else
    ng("WAIT PACK PATH")
    qg("Cannot return to Pack Position!")
  end
  Mg(false)
  cg = false
  return G
end
local function xq()
  Gq()
  if pg and lg then
    C = true
    r = Z
    N = B
    Gq()
    bq()
    Dg("Manual pack start position set: " .. (Z .. (", " .. B)))
  end
end
local function wq()
  editValue("TapTap_dropcurrent", tostring(Qg) .. (", " .. tostring(xg)))
  editValue("TapTap_droptarget", tostring(Qg + 1) .. (", " .. tostring(xg)))
end
local function Lq(p, l, G, b)
  if p ~= nil and l ~= nil then
    editValue("TapTap_ssppos", tostring(p) .. (", " .. tostring(l)))
  else
    editValue("TapTap_ssppos", "NONE")
  end
  if G ~= nil and b ~= nil then
    editValue("TapTap_ssppath", tostring(G) .. (", " .. tostring(b)))
  else
    editValue("TapTap_ssppath", "NONE")
  end
end
local function mq(p, l)
  local G = getTile or GetTile
  if G == nil then
    return nil
  end
  local b, Q = pcall(G, p, l)
  if b then
    return Q
  end
  return nil
end
local function Hq(p, l)
  local G = mq(p, l)
  if G == nil then
    return false
  end
  return G["collidable"] == true
end
local function gq()
  local p = Yg()
  if p == nil or not T then
    return false
  end
  local l = dg()
  if ug(l) and not Tg(l, jg) then
    return false
  end
  local G = p["posX"] // 32
  local b = p["posY"] // 32
  local Q = { { ["x"] = G + 1, ["y"] = b }, { ["x"] = G - 1, ["y"] = b }, { ["x"] = G, ["y"] = b - 1 } }
  for p, l in ipairs(Q) do
    local Q = mq(l["x"], l["y"])
    if Q ~= nil and Q["collidable"] ~= true then
      local p = false
      for G = 1, 4, 1 do
        if not T then
          return false
        end
        local b = dg()
        if ug(b) and not Tg(b, jg) then
          return false
        end
        pcall(function()
          FindPath(l["x"], l["y"])
        end)
        local Q = 0
        while T and Q < 500 do
          local G = Yg()
          b = dg()
          if ug(b) and not Tg(b, jg) then
            return false
          end
          if G ~= nil and (G["posX"] // 32 == l["x"] and G["posY"] // 32 == l["y"]) then
            p = true
            break
          end
          Sleep(100)
          Q = Q + 100
        end
        if p then
          break
        end
        Sleep(120)
      end
      if p then
        Sleep(M)
        pcall(function()
          FindPath(G, b)
        end)
        local p = 0
        while T and p < 1200 do
          local l = Yg()
          if l ~= nil and (l["posX"] // 32 == G and l["posY"] // 32 == b) then
            Sleep(M)
            return true
          end
          Sleep(100)
          p = p + 100
        end
        return true
      end
    end
  end
  pcall(function()
    FindPath(G, b)
  end)
  Sleep(M)
  return false
end
local function Xq()
  local p = Yg()
  if p == nil or not Jg() then
    return {}, 0
  end
  local l = p["posX"] // 32
  local G = p["posY"] // 32
  local b = {}
  local Q = 0
  for p, w in pairs(Bg()) do
    local L = tonumber(w["itemid"])
    if L == x then
      Q = Q + 1
      local p, x = Cg(w)
      if p ~= nil and x ~= nil then
        local Q = math["floor"](p / 32)
        local L = math["floor"](x / 32)
        table["insert"](
          b,
          {
            ["object"] = w,
            ["objectX"] = Q,
            ["objectY"] = L,
            ["pixelX"] = p,
            ["pixelY"] = x,
            ["distance"] = math["abs"](l - Q) + math["abs"](G - L),
          }
        )
      end
    end
  end
  table["sort"](b, function(p, l)
    return p["distance"] < l["distance"]
  end)
  if #b > 0 then
    Lq(b[1]["objectX"], b[1]["objectY"], nil, nil)
  elseif Q == 0 then
    Lq(nil, nil, nil, nil)
  end
  return b, Q
end
local function Fq(p)
  return {
    { p["objectX"], p["objectY"] },
    { p["objectX"] - 1, p["objectY"] },
    { p["objectX"] + 1, p["objectY"] },
    { p["objectX"], p["objectY"] - 1 },
    { p["objectX"] - 1, p["objectY"] - 1 },
    { p["objectX"] + 1, p["objectY"] - 1 },
  }
end
local function Iq(p)
  T = false
  Mg(false)
  cg = false
  Sg = false
  Eg = false
  Lq(nil, nil, nil, nil)
  local l = EditToggle or editToggle
  if l ~= nil then
    pcall(l, "TapTap_enable", false)
  end
  if p then
    ng("DONE - SEEDS DROPPED")
    qg("No SSP remains. Final seed drop finished; script stopped.")
    Dg("No dropped SSP remains; remaining seed stacks were dropped and verified.")
  else
    ng("NO SSP - STOPPED")
    qg("No SSP found and no seeds remain. Script stopped.")
    Dg("No dropped SSP or remaining seed stacks found. TapTap stopped.")
  end
end
local function tq()
  if not T or not Jg() then
    return false
  end
  local p = GetObjectList or getObjectList
  if type(p) ~= "function" then
    return false
  end
  local l, G = pcall(p)
  if not l or type(G) ~= "table" then
    return false
  end
  for p, l in pairs(G) do
    if tonumber(l["itemid"]) == x then
      return false
    end
  end
  return true
end
local function cq(p)
  if not T or not Jg() then
    return
  end
  if p == nil or p["object"] == nil then
    return
  end
  local l = tonumber(p["object"]["id"])
  if l == nil then
    return
  end
  pcall(function()
    if T and Jg() then
      SendPacketRaw(false, { ["type"] = 11, ["value"] = l, ["x"] = p["pixelX"], ["y"] = p["pixelY"] })
    end
  end)
end
local function Sq(p, l, G, b)
  if not T or not Jg() then
    return false
  end
  Lq(p["objectX"], p["objectY"], l, G)
  for Q = 1, f, 1 do
    if not T or not Jg() then
      return false
    end
    local w, L = Ng()
    if w == nil then
      Vg = true
      return false
    end
    local m = false
    local H = pcall(function()
      FindPath(l, G)
    end)
    if H then
      local Q = 0
      local H = 0
      local g = w
      local X = L
      while T and Q < d do
        if not Jg() then
          Vg = true
          return false
        end
        if hg(x) > b then
          return true
        end
        local w, L = Ng()
        if w == nil then
          Vg = true
          return false
        end
        local F = math["abs"](w - p["objectX"]) <= 1 and math["abs"](L - p["objectY"]) <= 1
        if F and not m then
          cq(p)
          m = true
        end
        if w == l and L == G then
          if not m then
            cq(p)
            m = true
          end
          local l = 0
          while T and l < 500 do
            if hg(x) > b then
              return true
            end
            Sleep(50)
            l = l + 50
          end
          return false
        end
        if w ~= g or L ~= X then
          g = w
          X = L
          H = 0
        else
          H = H + 100
        end
        if H >= Y then
          break
        end
        Sleep(100)
        Q = Q + 100
      end
    end
    if Q < f then
      Sleep(U)
    end
  end
  return false
end
local function Eq()
  local p, l = Xq()
  if l == 0 then
    return false, "NO_SSP"
  end
  if #p == 0 then
    ng("WAIT SSP DATA")
    Dg("SSP object(s) exist, but their position data could not be read.")
    return false
  end
  local G = hg(x)
  ng("COLLECT SSP")
  Ug(true)
  for p, l in ipairs(p) do
    if not T or not Jg() then
      Ug(false)
      return false
    end
    editValue("TapTap_ssppos", tostring(l["objectX"]) .. (", " .. tostring(l["objectY"])))
    Dg("Testing SSP object at " .. (l["objectX"] .. (", " .. l["objectY"])))
    local b = Fq(l)
    for p, b in ipairs(b) do
      local Q = b[1]
      local x = b[2]
      if Sq(l, Q, x, G) then
        local p = Qq("SSP", false)
        if p then
          Lq(l["objectX"], l["objectY"], Z, B)
        end
        return p
      end
      if not T or not Jg() then
        Ug(false)
        return false
      end
    end
  end
  Ug(false)
  local b = p[1]
  editValue("TapTap_ssppos", tostring(b["objectX"]) .. (", " .. tostring(b["objectY"])))
  editValue("TapTap_ssppath", "NO WORKING PATH")
  local Q = (Ig == "WAIT SSP PATH")
  ng("WAIT SSP PATH")
  if not Q then
    qg("Path not found!")
  end
  Dg("Found " .. (l .. " SSP object(s), but actual FindPath could not reach any candidate."))
  return false
end
local function Oq(p)
  local l = fg()
  if not l then
    return false
  end
  local G = hg(x, l)
  if G <= 0 or G < i or ig(l) ~= 0 then
    return false
  end
  local b = 0
  local Q = math["min"](a and 1 or J, G, (G - i) + 1)
  local w, L = r, N
  for l = 1, Q, 1 do
    if not T or p ~= A then
      return false
    end
    if not Jg() then
      Vg = true
      return false
    end
    local G = Yg()
    if not G or G["posX"] // 32 ~= w or G["posY"] // 32 ~= L or r ~= w or N ~= L then
      break
    end
    local m, H = pcall(
      SendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = x, ["x"] = G["posX"], ["y"] = G["posY"], ["px"] = w, ["py"] = L }
    )
    if not m or H == false then
      break
    end
    b = b + 1
    if l < Q then
      Sleep(u)
    end
  end
  if b == 0 then
    return false
  end
  local m = 0
  while T and p == A do
    if not Jg() then
      Vg = true
      return false
    end
    l = fg()
    if l and hg(x, l) < G then
      a = false
      Sleep(z)
      return T and p == A
    end
    if m >= V then
      break
    end
    Sleep(20)
    m = m + 20
  end
  if T and p == A then
    a = true
    ng("WAIT SERVER")
    Sleep(k)
  end
  return false
end
local function vq(p, l)
  if not T or not Jg() then
    return false, "WORLD_LOST"
  end
  Sg = false
  Eg = true
  SendPacket(2, "action|drop\nitemID|" .. p)
  local G = 0
  local b = 25
  while T and G < s do
    if eg(Qg + 1, xg) then
      Eg = false
      Sg = false
      return false, "TILE_FULL"
    end
    if not Jg() then
      Vg = true
      Eg = false
      return false, "WORLD_LOST"
    end
    if Sg then
      break
    end
    Sleep(b)
    G = G + b
  end
  if not T then
    Eg = false
    return false, "STOPPED"
  end
  if not Sg then
    Eg = false
    ng("WAIT SERVER")
    Sleep(k)
    return false, "NO_DIALOG"
  end
  Sg = false
  Eg = false
  if eg(Qg + 1, xg) then
    return false, "TILE_FULL"
  end
  if not T or not Jg() then
    return false, "WORLD_LOST"
  end
  SendPacket(
    2,
    "action|dialog_return\n" .. ("dialog_name|drop_item\n" .. ("itemID|" .. (p .. ("|\n" .. ("count|" .. l)))))
  )
  return true, "CONFIRM_SENT"
end
local function Rq(p, l)
  local G = 0
  local b = 50
  while T and G < j do
    if not Jg() then
      return false, "WORLD_LOST"
    end
    local Q = hg(p)
    if Q < l then
      if G < h then
        Sleep(h - G)
      end
      return true, Q
    end
    if eg(Qg + 1, xg) then
      return false, "TILE_FULL"
    end
    Sleep(b)
    G = G + b
  end
  return false, hg(p)
end
local function yq()
  if not T or not Jg() then
    return false
  end
  local p = Yg()
  if p == nil then
    Vg = true
    return false
  end
  if p["isLeft"] == false then
    return true
  end
  local l = p["posX"] // 32
  local G = p["posY"] // 32
  local b = l - 1
  local Q = G
  local x = mq(b, Q)
  if x == nil or x["collidable"] == true then
    Dg("Cannot safely face right because the left-side turn tile is blocked.")
    return false
  end
  if not Zg(b, Q) then
    return false
  end
  Sleep(60)
  if not T then
    return false
  end
  if not Zg(l, G) then
    return false
  end
  Sleep(60)
  local w = Yg()
  if w ~= nil and w["isLeft"] ~= nil then
    Dg("Safe facing check: isLeft=" .. tostring(w["isLeft"]))
    return w["isLeft"] == false
  end
  return true
end
local function Kq()
  if not T or not Jg() then
    return false
  end
  local p = Qg - 1
  local l = xg
  Dg(
    "Drop target full at " .. (
        (Qg + 1) .. (", " .. (xg .. (". Trying next standing tile to the left: " .. (p .. (", " .. l)))))
      )
  )
  if Zg(p, l) then
    Qg = p
    xg = l
    wq()
    Dg("Moved left for next drop. Stand: " .. (Qg .. (", " .. (xg .. (" | Target: " .. ((Qg + 1) .. (", " .. xg)))))))
    return true
  end
  local G = Gg
  local b = xg - 1
  Dg("No path to the left. Trying next row at start X: " .. (G .. (", " .. b)))
  if Zg(G, b) then
    Qg = G
    xg = b
    wq()
    qg("Next Drop Row = (" .. (Qg .. (", " .. (xg .. ")"))))
    Dg("Moved to next drop row. Stand: " .. (Qg .. (", " .. (xg .. (" | Target: " .. ((Qg + 1) .. (", " .. xg)))))))
    return true
  end
  ng("WAIT DROP PATH")
  qg("No drop path found!")
  Dg("Could not move left and could not reach next row start at " .. (G .. (", " .. b)))
  return false
end
local function eq(p, l, G)
  local b = 0
  while T and b < G do
    if not Jg() then
      return false, "WORLD_LOST"
    end
    if fg() == nil then
      return false, "NO_INVENTORY"
    end
    if hg(p) < l then
      return true, "ACCEPTED"
    end
    Sleep(50)
    b = b + 50
  end
  return hg(p) < l, "TIMEOUT"
end
local function sq(p, l)
  if fg() == nil then
    return "NO_INVENTORY"
  end
  local G = hg(p)
  if G < l then
    return "CHANGED"
  end
  for b = 1, q, 1 do
    if not T then
      return "STOPPED"
    end
    if not Jg() then
      return "WORLD_LOST"
    end
    if fg() == nil then
      return "NO_INVENTORY"
    end
    if hg(p) < G then
      return "SUCCESS"
    end
    cg = true
    ng(b == 1 and "DROP - CHECK INVENTORY" or "RETRY DROP 2/2 - SAME TILE")
    Og = true
    local Q, x = vq(p, l)
    if Q then
      local l, b = Rq(p, G)
      if l then
        Og = false
        return "SUCCESS"
      end
      x = b
    end
    Og = false
    if not T then
      return "STOPPED"
    end
    if x == "WORLD_LOST" or not Jg() then
      return "WORLD_LOST"
    end
    if fg() == nil then
      return "NO_INVENTORY"
    end
    if hg(p) < G then
      return "SUCCESS"
    end
    if x == "TILE_FULL" or eg(Qg + 1, xg) then
      return "REJECTED"
    end
    ng(b == 1 and "WAIT DROP ACK - RETRY" or "WAIT DROP ACK - SHIFT")
    local w, L = eq(p, G, b == 1 and W or D)
    if w then
      return "SUCCESS"
    end
    if L == "WORLD_LOST" then
      return "WORLD_LOST"
    end
    if L == "NO_INVENTORY" then
      return "NO_INVENTORY"
    end
  end
  return "REJECTED"
end
local function jq(p)
  local l = false
  local G = true
  local b = 0
  local function Q()
    wg = true
    Og = false
    ng("DROP FAILED - MOVE LEFT")
    if not Kq() then
      ng("WAIT LEFT PATH - NO DROP")
      return false
    end
    wg = false
    Kg()
    l, G = true, true
    b = b + 1
    return true
  end
  while T do
    if not Jg() then
      Vg = true
      return false
    end
    if fg() == nil then
      ng("WAIT INVENTORY")
      return false
    end
    local x = mg
    if x ~= nil then
      local l = hg(x)
      if l <= 0 or (not p and l < K) then
        mg = nil
        x = nil
      end
    end
    if x == nil then
      x = p and rg() or ig()
    end
    if x == 0 then
      return true
    end
    if wg then
      if not Q() then
        return false
      end
    elseif not l then
      if not Zg(Qg, xg) then
        ng("WAIT DROP PATH")
        qg("Path not found!")
        return false
      end
      l = true
      G = true
    end
    local w, L = Qg + 1, xg
    if Hq(w, L) or eg(w, L) then
      mg = x
      if not Q() then
        return false
      end
    else
      if G then
        if not yq() then
          ng("WAIT DROP FACING")
          qg("Cannot face right safely!")
          return false
        end
        G = false
      end
      local l = hg(x)
      local b = p and math["min"](K, l) or K
      if b <= 0 or l < b then
        mg = nil
        Sleep(50)
      else
        local p = sq(x, b)
        if p == "SUCCESS" then
          mg = nil
          Lg = 0
          pq(w, L)
        elseif p == "REJECTED" then
          mg = x
          Lg = Lg + 1
          if not Q() then
            return false
          end
        elseif p == "CHANGED" then
          mg = nil
        elseif p == "NO_INVENTORY" then
          ng("WAIT INVENTORY")
          return false
        elseif p == "WORLD_LOST" then
          Vg = true
          return false
        else
          return false
        end
      end
    end
    if Lg >= n then
      ng("SERVER SLOW - DROP COOLDOWN")
      Sleep(1500)
      Lg = 0
      return false
    end
    if b >= 30 then
      ng("DROP SHIFT BREAK")
      Sleep(400)
      return false
    end
    Sleep(30)
  end
  return false
end
local function Vq()
  local p = Yg()
  if p == nil then
    Dg("Cannot set pack position: player not loaded.")
    return
  end
  Z = p["posX"] // 32
  B = p["posY"] // 32
  r = Z
  N = B
  pg = true
  lg = true
  C = true
  editValue("TapTap_packx", tostring(Z))
  editValue("TapTap_packy", tostring(B))
  Gq()
  bq()
  tg()
  qg("Pack Position = (" .. (Z .. (", " .. (B .. ")"))))
  Dg("Pack start position set: " .. (Z .. (", " .. B)))
end
local function kq()
  local p = Yg()
  if p == nil then
    Dg("Cannot set drop position: player not loaded.")
    return
  end
  Gg = p["posX"] // 32
  bg = p["posY"] // 32
  Qg = Gg
  xg = bg
  lq()
  Kg()
  Og = false
  wg = false
  Lg = 0
  editValue("TapTap_dropx", tostring(Gg))
  editValue("TapTap_dropy", tostring(bg))
  wq()
  tg()
  qg("Drop Position = (" .. (Gg .. (", " .. (bg .. ")"))))
  Dg("Drop start position set: " .. (Gg .. (", " .. bg)))
end
local function Wq()
  if not T then
    return false
  end
  if Jg() then
    if Vg or kg then
      Mg(false)
      ng("RESUMING")
      Sleep(P)
      if not T then
        return false
      end
      local p = dg()
      if ug(p) and not Tg(p, jg) then
        Wg = false
        return false
      end
      if not zg(3000) then
        ng("RESUMING")
        Sleep(100)
        return false
      end
      ng("RESUME MOVE")
      gq()
      if not T then
        return false
      end
      p = dg()
      if ug(p) and not Tg(p, jg) then
        Wg = false
        return false
      end
      Vg = false
      kg = false
      Wg = true
      qg("TapTap resumed automatically.")
    end
    return true
  end
  if Vg and kg then
    Mg(false)
    ng("RESUMING")
    Sleep(P)
    if not T then
      return false
    end
    if Ag(4000) then
      local p = dg()
      if ug(p) and not Tg(p, jg) then
        Wg = false
        ng("PAUSED - WAIT WORLD")
        return false
      end
      Wg = true
      ng("RESUME MOVE")
      gq()
      if not T then
        return false
      end
      p = dg()
      if ug(p) and not Tg(p, jg) then
        Wg = false
        ng("PAUSED - WAIT WORLD")
        return false
      end
      Vg = false
      kg = false
      qg("TapTap resumed automatically.")
      return true
    end
  end
  if not Vg then
    Vg = true
    qg("TapTap paused - return to " .. tostring(jg))
  end
  Wg = false
  Sg = false
  Eg = false
  Mg(false)
  ng("PAUSED - WAIT WORLD")
  Sleep(200)
  return false
end
function onVariant(p, l)
  if p ~= nil then
    if T and (p["v1"] == "OnSpawn" and type(p["v2"]) == "string") then
      local l = p["v2"]:find("type|local", 1, true) ~= nil
      if not l then
        local G = tonumber(p["v2"]:match("netID|(%d+)"))
        local b = Yg()
        if G ~= nil and b ~= nil then
          l = tonumber(b["netID"]) == G
        end
      end
      if l and (Vg or not Wg) then
        kg = true
        Vg = true
      end
    end
    if T and (Vg and p["v1"] == "OnSetPos") then
      kg = true
    end
    if T and Og then
      local l = true
      if p["v1"] == "OnTalkBubble" then
        local G = Yg()
        if G ~= nil and (G["netID"] ~= nil and tonumber(p["v2"]) ~= tonumber(G["netID"])) then
          l = false
        end
      end
      if l then
        for l = 2, 7, 1 do
          local G = p["v" .. tostring(l)]
          if sg(G) then
            Rg = Qg + 1
            yg = xg
            vg = true
            Dg("Server says drop tile is full: " .. (tostring(Rg) .. (", " .. tostring(yg))))
            break
          end
        end
      end
    end
    if p["v1"] == "OnDialogRequest" and type(p["v2"]) == "string" then
      if p["v2"]:find("drop_item", 1, true) then
        if T and Eg then
          Sg = true
        end
        return true
      end
    end
  end
  return false
end
function onSendPacket(p, l)
  if T and type(l) == "string" then
    local p = l:find("action|quit", 1, true) ~= nil
    local G = l:find("action|join_request", 1, true) ~= nil
    if p or G then
      Wg = false
      Vg = true
      kg = false
      Sg = false
      Eg = false
      Mg(false)
      ng("PAUSED - WAIT WORLD")
    end
  end
  return false
end
function onSendPacketRaw(p)
  if T and (cg and p ~= nil) then
    if tonumber(p["type"]) == 11 then
      Dg("Blocked item collect packet during protected drop travel.")
      return true
    end
  end
  return false
end
function onGamePacket(p)
  if p ~= nil and (p["type"] == 26 and T) then
    if not Vg then
      qg("TapTap paused - disconnected.")
    end
    Vg = true
    kg = false
    Wg = false
    Sg = false
    Eg = false
    Mg(false)
    ng("PAUSED - WAIT WORLD")
    Dg("Disconnect detected. TapTap is paused until you manually return to the target world.")
  end
  return false
end
local Dq = false
local function qq()
  Dq = true
  Pg("TapTap_enable", false)
  Dq = false
end
local function nq(p)
  T = true
  A = A + 1
  a = false
  jg = p
  Vg = false
  kg = false
  Wg = true
  lq()
  Kg()
  Og = false
  wg = false
  Lg = 0
  mg = nil
  ng("STARTING")
  qg("TapTap started.")
end
local function Pq()
  T = false
  A = A + 1
  a = false
  cg = false
  Sg = false
  Eg = false
  Og = false
  wg = false
  Lg = 0
  mg = nil
  Kg()
  Mg(false)
  ng("STOPPED")
  Vg = false
  kg = false
  Wg = false
  qg("TapTap stopped safely.")
end
local function Mq(p)
  if type(p) == "table" then
    p = p["id"] or p["itemID"] or p["itemid"] or p["value"] or p["name"]
  end
  local l = tonumber(p)
  if not l and type(p) == "string" then
    l = tonumber(p:match("%((%d+)%)"))
    local G = findItemID or (growtopia and growtopia["getItemID"])
    if not l and type(G) == "function" then
      local b, Q = pcall(G, p)
      if b then
        l = tonumber(Q)
      end
    end
  end
  if not l or l < 1 or l > 65535 or l % 1 ~= 0 then
    return false
  end
  if l == x then
    return true
  end
  if T then
    qg("Stop the script before changing the item to tap.")
    return true
  end
  x = l
  tg()
  return true
end
function onValue(p, l, G)
  if l == "TapTap_itempicker" then
    Mq(G)
    return
  end
  if l == "TapTap_enable" then
    if Dq then
      return
    end
    if G ~= true then
      if T then
        Pq()
      end
      return
    end
    if T then
      return
    end
    local p = dg()
    if not C or not ug(p) or not Yg() then
      qq()
      qg(not C and "Set Pack Position first." or "Enter the farming world first, then press Start.")
      return
    end
    nq(p)
    return
  end
  if l == "TapTap_delay" then
    local p = tonumber(G)
    if p ~= nil then
      if p < 1 then
        p = 1
      end
      u = math["floor"](p)
      tg()
      Dg("Pack Delay: " .. (u .. " ms"))
    end
    return
  end
  if l == "TapTap_bursttaps" then
    local p = tonumber(G)
    if p then
      J = math["max"](1, math["min"](25, math["floor"](p)))
      tg()
    end
    return
  end
  if l == "TapTap_burstpause" then
    local p = tonumber(G)
    if p then
      z = math["max"](1, math["min"](10000, math["floor"](p)))
      tg()
    end
    return
  end
  if l == "TapTap_dropdelay" then
    local p = tonumber(G)
    if p ~= nil then
      p = math["floor"](p)
      if p < 200 then
        p = 200
      end
      if p > 500 then
        p = 500
      end
      h = p
      tg()
      Dg("Drop Delay: " .. (h .. " ms"))
    end
    return
  end
  if l == "TapTap_minssp" then
    local p = tonumber(G)
    if p ~= nil then
      p = math["floor"](p)
      if p < 0 then
        p = 0
      end
      if p > 200 then
        p = 200
      end
      i = p
      tg()
      Dg("Minimum SSP Threshold: " .. i)
    end
    return
  end
  if l == "TapTap_packx" then
    local p = tonumber(G)
    if p ~= nil then
      Z = math["floor"](p)
      pg = true
      xq()
      tg()
    end
    return
  end
  if l == "TapTap_packy" then
    local p = tonumber(G)
    if p ~= nil then
      B = math["floor"](p)
      lg = true
      xq()
      tg()
    end
    return
  end
  if l == "TapTap_setpack" then
    Vq()
    return
  end
  if l == "TapTap_dropx" then
    local p = tonumber(G)
    if p ~= nil then
      Gg = math["floor"](p)
      Qg = Gg
      xg = bg
      lq()
      Kg()
      Og = false
      wg = false
      Lg = 0
      mg = nil
      wq()
      tg()
    end
    return
  end
  if l == "TapTap_dropy" then
    local p = tonumber(G)
    if p ~= nil then
      bg = math["floor"](p)
      Qg = Gg
      xg = bg
      lq()
      Kg()
      Og = false
      wg = false
      Lg = 0
      mg = nil
      wq()
      tg()
    end
    return
  end
  if l == "TapTap_setdrop" then
    kq()
    return
  end
end
applyHook()
if type(setOnValue) == "function" then
  pcall(setOnValue, "TapTap_itempicker", function(...)
    for p = select("#", ...), 1, -1 do
      if Mq(select(p, ...)) then
        return
      end
    end
  end)
end
runThread(function()
  Mg(false)
  ng("STOPPED")
  while true do
    if T then
      if not Wq() then
        Sleep(200)
      else
        local p = 400
        local l = ig()
        if l ~= 0 then
          ng("DROP")
          Mg(true)
          local p = jq()
          if p and (T and Jg()) then
            Qq("DROP", true)
          end
        else
          ng("GACHA")
          Mg(false)
          local l = true
          if hg(x) < i then
            local p, G = Eq()
            if p then
              l = false
              Sleep(200)
            elseif G == "NO_SSP" then
              l = false
              ng("VERIFY NO SSP")
              Sleep(250)
              if T and (Jg() and tq()) then
                if fg() == nil then
                  ng("WAIT INVENTORY")
                elseif rg() ~= 0 then
                  ng("FINAL SEED DROP")
                  Mg(true)
                  local p = jq(true)
                  if p and (T and Jg()) then
                    Qq("DROP", true)
                    if T and Jg() then
                      Iq(true)
                    end
                  end
                else
                  Iq(false)
                end
              else
                ng("WAIT SSP DATA")
              end
              Sleep(150)
            else
              if not Jg() then
                Vg = true
              end
              l = false
              Sleep(500)
            end
          end
          if l and T then
            local l = A
            local G, b = Ng()
            if G and ((G == r and b == N or Zg(r, N)) and (T and (l == A and Oq(l)))) then
              p = 0
            end
          end
        end
        if p > 0 then
          Sleep(p)
        end
      end
    else
      Sleep(200)
    end
  end
end)
Dg(p .. " loaded.")
