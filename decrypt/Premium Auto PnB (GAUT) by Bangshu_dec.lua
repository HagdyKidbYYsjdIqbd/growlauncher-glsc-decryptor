setMinimum("6.1.2")
local M = "Premium Auto PnB by Bangshu"
do
  local B =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local j = "PNB"
  local K = "PNB-1-PAID-001"
  local i = "approval"
  local D = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function z()
    local M, B = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not M then
      return nil
    end
    if type(B) == "number" and (math["type"] and math["type"](B) == "integer") then
      B = tostring(B)
    end
    if type(B) ~= "string" or #B < 17 or #B > 20 or not B:match("^%d+$") then
      return nil
    end
    if B:match("^0+$") then
      return nil
    end
    return B
  end
  local function Q(M, B)
    if not B or type(M) ~= "string" or #M > 512 then
      return false
    end
    local i, z, Q = M:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (D .. '"}}%s*$')
    )
    return i == B and (z == j and Q == K)
  end
  local G, W, s = pcall(function()
    local M, B = pcall(require, "preferences")
    local j = M and (type(B) == "table" and B) or Preferences
    if type(j) ~= "table" or type(j["new"]) ~= "function" then
      return nil
    end
    local K = j:new("BangshuPremiumAutoPnB")
    if K:load() == false then
      return K
    end
    return K, K:get(i, "")
  end)
  if not G then
    W = nil
  end
  if not Q(s, z()) then
    local D, G = false, false
    local function s(M)
      pcall(editValue, "CAF_premium_status", M)
      if type(sendNotification) == "function" then
        pcall(sendNotification, M)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], M)
      end
    end
    local function T()
      if D or G then
        return
      end
      local M = z()
      if not M then
        s("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not W then
        s("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      D = true
      s("CHECKING")
      local T = pcall(runThread, function()
        local z = B
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              M .. ("&product=" .. (j .. ("&format=growlauncher&version=" .. K)))
            )
          )
        local T, y = pcall(fetch, z)
        if T and type(y) == "string" then
          local M = y:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if M and (#M <= 1024 and #M % 2 == 0) then
            y = M:gsub("..", function(M)
              return string["char"](tonumber(M, 16))
            end)
          end
        end
        if not T or type(y) ~= "string" then
          s("DENIED - REQUEST FAILED")
        elseif not Q(y, M) then
          if y:match('^%s*{"status":"DENIED",') then
            local M = y:match('"reason"%s*:%s*"([A-Z_]+)"')
            if M == "INVALID_REQUEST" then
              s("DENIED - INVALID REQUEST (CHECK DEPLOYMENT)")
            elseif M == "NO_PERMANENT_ACCESS" then
              s("DENIED - CHECK PNB ROW IN PAIDUSERS")
            else
              s("DENIED - NO PREMIUM ACCESS")
            end
          elseif y:match('^%s*{"status":"ERROR",') then
            s("DENIED - APPS SCRIPT SERVER ERROR")
          elseif y:match("^%s*<") then
            if y:find("doGet", 1, true) then
              s("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              s("DENIED - GOOGLE RETURNED HTML")
            end
          elseif y:match("^%s*$") then
            s("DENIED - EMPTY SERVER RESPONSE")
          elseif y:match('^%s*{"status":"APPROVED",') then
            s("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            s("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local B, j = pcall(function()
            if W:set(i, y) == false then
              return false
            end
            if W:save() == false then
              return false
            end
            if W:load() == false then
              return false
            end
            return Q(W:get(i, ""), M)
          end)
          G = B and j == true
          s(G and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        D = false
      end)
      if not T then
        D = false
        s("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(M, B)
      if B == "CAF_premium_verify" then
        T()
      end
    end
    onValue = OnValue
    local y = UserInterface["new"](M, "Agriculture")
    y:addButton("Verify Access", "CAF_premium_verify")
    y:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "CAF_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, M, "Agriculture")
    end
    addIntoModule(y:generateJSON(), M)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "CAF_premium_verify", T)
    end
    return
  end
end
local B = M
local j = "CustomAutoFarmV1"
local K = {
  ["autoConsumable"] = false,
  ["consumableProtocol"] = 0,
  ["consumableItems"] = "",
  ["consumableEffects"] = "",
  ["consumableDelay"] = 1000,
  ["consumableCheck"] = 30000,
  ["autoTrash"] = false,
  ["trashItems"] = "",
  ["trashCount"] = 195,
  ["clearGAUT"] = false,
  ["gautBelow"] = 0,
  ["gautInterval"] = 0,
  ["gautDelay"] = 300,
  ["gautTimeout"] = 3000,
  ["itemID"] = 5706,
  ["pattern1"] = "00000",
  ["pattern2"] = "11111",
  ["pattern3"] = "00000",
  ["pattern4"] = "00000",
  ["pattern5"] = "00000",
  ["pickerBase"] = "",
  ["autoVileVial"] = false,
  ["vileVialID"] = 0,
  ["vialDelay"] = 1000,
  ["vialCheck"] = 30000,
  ["vialUnconfirmed"] = false,
  ["autoCure"] = false,
  ["cureWorld"] = "",
  ["cureCheckDelay"] = 120000,
  ["doBreak"] = true,
  ["doPlace"] = true,
  ["hitCount"] = 1,
  ["breakDelay"] = 150,
  ["placeDelay"] = 100,
  ["autoCollect"] = true,
  ["collectDelay"] = 50,
  ["collectEvery"] = 1,
  ["pickupMax"] = 100,
  ["pickupWorlds"] = "",
  ["autoPickup"] = true,
  ["pickupBelow"] = 1,
  ["pickupDelay"] = 100,
  ["pickupWorldMax"] = 25,
  ["autoDrop"] = true,
  ["dropMinimum"] = 200,
  ["dropWorld"] = "",
  ["dropX"] = 0,
  ["dropY"] = 0,
  ["dropXSet"] = false,
  ["dropYSet"] = false,
  ["activeDropX"] = 0,
  ["farmWorld"] = "",
  ["farmX"] = 0,
  ["farmY"] = 0,
  ["farmXSet"] = false,
  ["farmYSet"] = false,
}
local i = {
  "autoVileVial",
  "vileVialID",
  "vialDelay",
  "vialCheck",
  "vialUnconfirmed",
  "autoConsumable",
  "consumableProtocol",
  "consumableItems",
  "consumableEffects",
  "consumableDelay",
  "consumableCheck",
  "autoTrash",
  "trashItems",
  "trashCount",
  "clearGAUT",
  "gautBelow",
  "gautInterval",
  "gautDelay",
  "gautTimeout",
  "itemID",
  "pattern1",
  "pattern2",
  "pattern3",
  "pattern4",
  "pattern5",
  "pickerBase",
  "autoCure",
  "cureWorld",
  "cureCheckDelay",
  "doBreak",
  "doPlace",
  "hitCount",
  "breakDelay",
  "placeDelay",
  "autoCollect",
  "collectDelay",
  "collectEvery",
  "pickupMax",
  "pickupWorlds",
  "autoPickup",
  "pickupBelow",
  "pickupDelay",
  "pickupWorldMax",
  "autoDrop",
  "dropMinimum",
  "dropWorld",
  "dropX",
  "dropY",
  "dropXSet",
  "dropYSet",
  "activeDropX",
  "farmWorld",
  "farmX",
  "farmY",
  "farmXSet",
  "farmYSet",
}
local D = nil
local z = nil
local Q = "UNAVAILABLE"
local function G(M)
  pcall(function()
    if growtopia and growtopia["notify"] then
      growtopia["notify"](tostring(M))
    end
  end)
end
local function W()
  local M
  if type(require) == "function" then
    local B, j = pcall(require, "preferences")
    if B and type(j) == "table" then
      M = j
    end
  end
  if not M and type(Preferences) == "table" then
    M = Preferences
  end
  if not M or type(M["new"]) ~= "function" then
    return
  end
  z = M
  local B, G = pcall(function()
    return M:new(j)
  end)
  if not B or not G then
    return
  end
  if
    type(G["load"]) ~= "function"
    or type(G["get"]) ~= "function"
    or type(G["set"]) ~= "function"
    or type(G["save"]) ~= "function"
  then
    return
  end
  D = G
  local W, s = pcall(function()
    return D:load()
  end)
  if not W or s == false then
    D = nil
    return
  end
  if tostring(D:get("initialized", "false")) == "true" then
    for M, B in ipairs(i) do
      local j = K[B]
      local i = D:get(B, tostring(j))
      if type(j) == "boolean" then
        K[B] = (tostring(i) == "true" or tostring(i) == "1")
      elseif type(j) == "number" then
        K[B] = tonumber(i) or j
      else
        K[B] = tostring(i)
      end
    end
    Q = "RESTORED"
  else
    Q = "READY"
  end
end
W()
local function s(M, B, j)
  return math["max"](B, math["min"](j, math["floor"](tonumber(M) or B)))
end
if K["consumableProtocol"] < 2 then
  local M = {}
  for B in K["consumableEffects"]:gmatch("[^;]+") do
    if not B:match("^%d+=%?$") then
      M[#M + 1] = B
    end
  end
  K["consumableEffects"] = table["concat"](M, ";")
  K["consumableProtocol"] = 2
end
if K["autoCure"] and K["autoVileVial"] then
  K["autoVileVial"] = false
end
K["vileVialID"] = s(K["vileVialID"], 0, 65535)
K["vialDelay"] = s(K["vialDelay"], 300, 10000)
K["vialCheck"] = s(K["vialCheck"], 5000, 3600000)
K["consumableDelay"] = s(K["consumableDelay"], 300, 10000)
K["consumableCheck"] = s(K["consumableCheck"], 5000, 3600000)
K["trashCount"] = s(K["trashCount"], 1, 200)
K["gautBelow"] = s(K["gautBelow"], 0, 200)
K["gautInterval"] = s(K["gautInterval"], 0, 3600000)
K["gautDelay"] = s(K["gautDelay"], 100, 10000)
K["gautTimeout"] = s(K["gautTimeout"], 500, 15000)
K["hitCount"] = s(K["hitCount"], 1, 40)
K["breakDelay"] = s(K["breakDelay"], 10, 3000)
K["placeDelay"] = s(K["placeDelay"], 10, 3000)
K["collectDelay"] = s(K["collectDelay"], 40, 2000)
K["collectEvery"] = s(K["collectEvery"], 1, 50)
K["pickupMax"] = s(K["pickupMax"], 1, 200)
K["pickupBelow"] = s(K["pickupBelow"], 1, 200)
K["pickupDelay"] = s(K["pickupDelay"], 50, 2000)
K["pickupWorldMax"] = s(K["pickupWorldMax"], 1, 100)
K["dropMinimum"] = s(K["dropMinimum"], 1, 200)
K["dropX"] = s(K["dropX"], 0, 199)
K["dropY"] = s(K["dropY"], 0, 119)
K["activeDropX"] = s(K["activeDropX"], 0, 199)
K["farmX"] = s(K["farmX"], 0, 199)
K["farmY"] = s(K["farmY"], 0, 119)
K["farmWorld"] = ((tostring(K["farmWorld"] or "")):upper()):gsub("%s+", "")
local T = D and tostring(D:get("smartTimingV14", "false")) ~= "true"
if T then
  K["breakDelay"], K["placeDelay"] = 150, 100
end
for M = 1, 5, 1 do
  local B = tostring(K["pattern" .. M] or "")
  local j = {}
  for M = 1, 5, 1 do
    j[M] = B:sub(M, M) == "1" and "1" or "0"
  end
  K["pattern" .. M] = table["concat"](j)
end
K["pattern3"] = (tostring(K["pattern3"])):sub(1, 2) .. ("0" .. (tostring(K["pattern3"])):sub(4, 5))
local y = {}
local function m(M, B)
  if y[M] then
    return
  end
  y[M] = true
  pcall(function()
    editValue(M, tostring(B))
  end)
  y[M] = nil
end
local p = false
local F = ""
local d = ""
local Z, a = nil, nil
local Y = false
local x = 0
local J = ""
local E = 0
local N = 1
local R = 1
local X = 0
local r = nil
local O = "STOPPED"
local c = nil
local k = 0
local o = -100000
local q = {}
local I = 0
local L = ""
local t = ""
local g = -100000
local h = ""
local w = false
local A = false
local f = false
local function v(M)
  M = tostring(M)
  if M == c then
    return
  end
  c = M
  O = M
  m("CAF_status", M)
end
local function V()
  if not D or not z then
    Q = "UNAVAILABLE"
    m("CAF_save", Q)
    return false
  end
  local M = pcall(function()
    assert(D:set("initialized", "true") ~= false)
    for M, B in ipairs(i) do
      assert(D:set(B, tostring(K[B])) ~= false)
    end
    assert(D:set("fastCycleV9", "true") ~= false)
    assert(D:set("alternateFastV13", "true") ~= false)
    assert(D:set("smartTimingV14", "true") ~= false)
    assert(D:save() ~= false)
  end)
  if M then
    local B, D = pcall(function()
      local M = z:new(j)
      if not M or type(M["load"]) ~= "function" or M:load() == false then
        return false
      end
      if tostring(M:get("initialized", "")) ~= "true" then
        return false
      end
      for B, j in ipairs(i) do
        if tostring(M:get(j, "")) ~= tostring(K[j]) then
          return false
        end
      end
      return true
    end)
    M = B and D == true
  end
  Q = M and "SAVED - REOPEN SAFE" or "SAVE FAILED - NOT VERIFIED"
  m("CAF_save", Q)
  if not M then
    G("Auto Farm settings could not be verified on disk.")
  end
  return M
end
local function P()
  local M = GetWorldName or getCurrentWorldName
  if type(M) ~= "function" then
    return ""
  end
  local B, j = pcall(M)
  return (B and (tostring(j or "")):upper()) or ""
end
local function n(M)
  return ((tostring(M or "")):upper()):match("^([^|]+)") or ""
end
local function b()
  local M = GetLocal or getLocal
  if type(M) ~= "function" then
    return nil
  end
  local B, j = pcall(M)
  if B then
    return j
  end
end
local function e()
  local M = b()
  if M and (M["posX"] and M["posY"]) then
    return math["floor"](M["posX"] / 32), math["floor"](M["posY"] / 32)
  end
end
local function u()
  return K["farmXSet"] and K["farmYSet"]
end
local function U()
  if not u() then
    return "NOT SET - USE CURRENT ON START"
  end
  local M = K["farmWorld"] ~= "" and K["farmWorld"] or "CURRENT WORLD"
  return M .. (" @ " .. (K["farmX"] .. ("," .. K["farmY"])))
end
local function C()
  m("CAF_farmpos", U())
end
local function S(M)
  M = tonumber(M)
  if not M then
    return nil
  end
  local B = GetInventory or getInventory
  if type(B) == "function" then
    local j, K = pcall(B)
    if j and type(K) == "table" then
      for B, j in pairs(K) do
        if tonumber(j["id"] or j["itemid"] or j["itemID"]) == M then
          return tonumber(j["amount"] or j["count"] or j["quantity"])
        end
      end
      if next(K) ~= nil then
        return 0
      end
    end
  end
  local j = growtopia and growtopia["checkInventoryCount"]
  if type(j) == "function" then
    local B, K = pcall(j, M)
    if B and tonumber(K) then
      return tonumber(K)
    end
  end
  return nil
end
local function l(M)
  return S(M) or 0
end
local function H(M, B)
  local j = GetTile or getTile
  if type(j) ~= "function" then
    return nil
  end
  local K, i = pcall(j, M, B)
  return K and i or nil
end
local function Ml()
  local M = GetObjectList or getObjectList
  if type(M) ~= "function" then
    return nil
  end
  local B, j = pcall(M)
  return (B and type(j) == "table") and j or nil
end
local Bl = {
  ["busy"] = false,
  ["last"] = -math["huge"],
  ["waiting"] = nil,
  ["initialCheck"] = true,
  ["missing"] = {},
  ["activeUntil"] = {},
}
local jl
local function Kl(M)
  local B = math["max"](0, math["floor"](tonumber(M) or 0))
  while p and B > 0 do
    local M = math["min"](B, 100)
    Sleep(M)
    k = k + M
    if jl then
      jl()
    end
    B = B - M
  end
  return p
end
local function il(M)
  M = (M == true)
  if f == M then
    return
  end
  local B = EditToggle or editToggle
  if type(B) == "function" then
    local j, K = pcall(B, "ModFly", M)
    if j and K ~= false then
      f = M
    end
  end
end
local function Dl(M, B)
  local j, K = e()
  return j == M and K == B
end
local function zl(M, B, j, K)
  M = math["floor"](tonumber(M) or -1)
  B = math["floor"](tonumber(B) or -1)
  if M < 0 or B < 0 then
    return false
  end
  if Dl(M, B) then
    return true
  end
  for i = 1, (j or 2), 1 do
    if not p then
      return false
    end
    local D, z = pcall(FindPath, M, B)
    if not D or z == false then
      v("PATH REJECTED " .. (M .. ("," .. B)))
    else
      local j = 0
      while p and j < (K or 2800) do
        if Dl(M, B) then
          return Kl(150)
        end
        Kl(100)
        j = j + 100
      end
    end
    if i < (j or 2) then
      Kl(300)
    end
  end
  return p and Dl(M, B)
end
local function Ql(M, B)
  local j = n(M)
  local K = 0
  while p and K < B do
    if j ~= "" and (P() == j and (b() and H(0, 0))) then
      Kl(450)
      return P() == j
    end
    Kl(100)
    K = K + 100
  end
  return false
end
local function Gl(M)
  if not p or not M or M == "" then
    return false
  end
  local B = n(M)
  if B == "" then
    return false
  end
  if P() == B and not (tostring(M)):find("|", 1, true) then
    return true
  end
  local j = Warp or JoinWorld
  v("WARP " .. tostring(M))
  if P() ~= B then
    local M, K
    if type(j) == "function" then
      M, K = pcall(j, B)
    elseif growtopia and type(growtopia["warpTo"]) == "function" then
      M, K = pcall(growtopia["warpTo"], B)
    else
      M, K = pcall(SendPacket, 3, "action|join_request\nname|" .. B)
    end
    if not M or K == false then
      return false
    end
    if not Ql(B, 18000) then
      return false
    end
    Kl(900)
  end
  if (tostring(M)):find("|", 1, true) then
    local j, K = pcall(SendPacket, 3, "action|join_request\nname|" .. (tostring(M) .. "\ninvitedWorld|0"))
    if not j or K == false then
      return false
    end
    Kl(1600)
    if not Ql(B, 12000) then
      return false
    end
    Kl(800)
  end
  return p and P() == B
end
local function Wl()
  return K["itemID"] + 1
end
local function sl()
  return { [Wl()] = true }
end
local function Tl(M, B)
  if n(K["dropWorld"]) ~= "" and P() ~= n(K["dropWorld"]) then
    return false
  end
  if n(K["dropWorld"]) == "" and P() ~= F then
    return false
  end
  return K["dropXSet"]
    and (
      K["dropYSet"]
      and (
        M >= math["min"](K["activeDropX"], K["dropX"]) - 2
        and (M <= math["max"](K["activeDropX"], K["dropX"]) + 2 and B == K["dropY"])
      )
    )
end
local function yl(M)
  if tonumber(M) ~= Wl() then
    return 0
  end
  local B = l(Wl())
  if B <= 0 then
    return 0
  end
  if not Y and B < K["dropMinimum"] then
    return 0
  end
  return math["min"](200, B)
end
local function ml()
  local M = S(Wl())
  return M ~= nil and (M >= 200 or (K["autoDrop"] and M >= K["dropMinimum"]))
end
local function pl()
  m("CAF_inventory", tostring(l(K["itemID"])) .. (" blocks / " .. (tostring(l(Wl())) .. " seeds")))
end
local Fl = false
local dl = false
local function Zl(M, B)
  if not p or P() ~= n(K["dropWorld"] ~= "" and K["dropWorld"] or F) then
    return false
  end
  if not Dl(K["activeDropX"], K["dropY"]) then
    return false
  end
  local j = l(M)
  if j < 1 then
    return true
  end
  B = math["min"](j, B)
  w = true
  A = false
  local i = pcall(SendPacket, 2, "action|drop\nitemID|" .. tostring(M))
  if not i then
    w = false
    A = false
    return false
  end
  local D = 0
  while p and (D < 1800 and (not A and (not Fl and l(M) >= j))) do
    Kl(75)
    D = D + 75
  end
  local z = A
  w = false
  A = false
  if l(M) < j then
    return true
  end
  if Fl then
    return false
  end
  if not p or not z or not Dl(K["activeDropX"], K["dropY"]) then
    return false
  end
  i = pcall(
    SendPacket,
    2,
    "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (tostring(M) .. ("|\ncount|" .. tostring(B)))
  )
  if not i then
    return false
  end
  D = 0
  while p and D < 2500 do
    if l(M) < j then
      return true
    end
    if Fl then
      return false
    end
    Kl(100)
    D = D + 100
  end
  return l(M) < j
end
local function al()
  if not p then
    return false
  end
  if not Y and not ml() then
    return true
  end
  Y = true
  if not K["dropXSet"] or not K["dropYSet"] then
    v("SET STORAGE DROP X/Y")
    return false
  end
  local M = K["dropWorld"] ~= "" and K["dropWorld"] or F
  if M == "" then
    return false
  end
  if l(Wl()) > 0 then
    if not Gl(M) then
      v("STORAGE WORLD NOT READY")
      return false
    end
    if not zl(K["activeDropX"], K["dropY"], 4, 2600) then
      v("WAIT STORAGE PATH " .. (K["activeDropX"] .. ("," .. K["dropY"])))
      return false
    end
  end
  local B = sl()
  local j = {}
  for M in pairs(B) do
    j[#j + 1] = M
  end
  table["sort"](j)
  for B, j in ipairs(j) do
    while p and yl(j) > 0 do
      if not Dl(K["activeDropX"], K["dropY"]) then
        if not zl(K["activeDropX"], K["dropY"], 4, 2600) then
          return false
        end
      end
      local B = false
      for K = 1, 2, 1 do
        if not p or P() ~= n(M) or not b() then
          v("STORAGE WORLD LOST - RETRY")
          return false
        end
        local i = l(j)
        local D = yl(j)
        if D <= 0 then
          B = true
          break
        end
        v("DROP " .. (j .. (" x" .. (D .. (" (" .. (K .. "/2)"))))))
        Fl = false
        dl = true
        local z = Zl(j, D)
        dl = false
        if z and l(j) < i then
          B = true
          break
        end
        if Fl then
          break
        end
        Kl(350)
        if l(j) < i then
          B = true
          break
        end
      end
      if not B then
        if not p or P() ~= n(M) or not b() then
          v("STORAGE DISCONNECTED - RETRY SAME DROP TILE")
          return false
        end
        if K["activeDropX"] <= 0 then
          v("STORAGE FULL / LEFT EDGE")
          return false
        end
        K["activeDropX"] = K["activeDropX"] - 1
        V()
        m("CAF_activeDropX", K["activeDropX"])
        m("CAF_activeDropY", K["dropY"])
        v("DROP FULL -> SHIFT LEFT " .. (K["activeDropX"] .. ("," .. K["dropY"])))
        if not zl(K["activeDropX"], K["dropY"], 4, 2600) then
          v("WAIT SHIFTED DROP TILE " .. (K["activeDropX"] .. ("," .. K["dropY"])))
          return false
        end
        Kl(450)
      else
        pl()
        Kl(200)
      end
    end
  end
  if P() ~= F or not b() then
    if not Gl(d) then
      v("RETURN TO FARM FAILED - RETRY")
      return false
    end
  end
  if not zl(Z, a, 3, 2400) then
    v("RETURN TO FARM POSITION FAILED - RETRY")
    return false
  end
  Y = false
  return p
end
local Yl, xl, Jl = false, false, nil
local El = false
local Nl = nil
local Rl = false
local Xl = 0
local rl = 0
local function Ol(M)
  Xl = Xl + 1
  v(M)
  if Xl >= 8 then
    Xl = 0
    Yl, xl, El, Jl = false, false, false, nil
    v("CURE FAILED - RESUMING FARM")
    G("Auto cure could not complete. Resuming farming; open the wrench again to retry.")
  end
  return false
end
local cl = -math["huge"]
local function kl(M)
  Nl = M
  if Rl then
    m("CAF_maladyStatus", "MALADY DETECTED: " .. M)
  end
  if type(log) == "function" then
    pcall(log, "CAF malady: " .. M)
  end
  if K["autoCure"] and (not Yl and not xl) then
    if K["cureWorld"] ~= "" then
      Yl = true
      Xl = 0
      if p then
        v("MALADY DETECTED - GOING TO CURE WORLD")
      end
    else
      if Rl then
        m("CAF_maladyStatus", "MALADY DETECTED: " .. (M .. " / SET CURE WORLD TO AUTO-CURE"))
      end
      G("Malady found. Set a Cure World (or use Cure World = Current World) to auto-cure. Farming continues.")
    end
  end
end
local ol
local function ql(M)
  local B = false
  for M in M:gmatch("[^\r\n]+") do
    local j = M:gsub(string["char"](96) .. ".", "")
    if (j:lower()):find("active effects:", 1, true) then
      B = true
    elseif B and j:match("^add_spacer|") then
      break
    elseif B and j:match("^add_label_with_icon|") then
      local M = j:match("^add_label_with_icon|[^|]*|([^|]*)|")
      if M and (M:lower()):find("malady:", 1, true) then
        return M
      end
    end
  end
  if B then
    return false
  end
  return nil
end
local function Il()
  local M = GetLocal or getLocal
  local B = SendPacket or sendPacket
  if not M or not B then
    return false
  end
  local j = M()
  local K = j and tonumber(j["netID"] or j["netid"])
  if not K then
    return false
  end
  ol = { ["net"] = K, ["world"] = P() }
  local i, D = pcall(B, 2, "action|wrench\n|netid|" .. K)
  return i and D ~= false
end
local function Ll()
  cl = k
  if not Il() then
    return nil
  end
  local M = ol
  for B = 1, 25, 1 do
    if M["done"] then
      return M["result"]
    end
    if not p or P() ~= M["world"] then
      break
    end
    Kl(100)
  end
  if Rl then
    m("CAF_maladyStatus", "WRENCH CHECK UNCONFIRMED - WILL RETRY")
  end
  return nil
end
function Bl.effects(M)
  local B = false
  local j = {}
  for M in M:gmatch("[^\r\n]+") do
    local K = M:gsub(string["char"](96) .. ".", "")
    if (K:lower()):find("active effects:", 1, true) then
      B = true
    elseif B and K:match("^add_spacer|") then
      break
    elseif B and K:match("^add_label_with_icon|") then
      local M = K:match("^add_label_with_icon|[^|]*|([^|]*)|")
      local B = K:match("|left|(%d+)|")
      if M then
        M = ((M:gsub("%s*%([^)]*left%)", "")):lower()):gsub("%s+$", "")
        local i = K:lower()
        local D = (
          (tonumber(i:match("(%d+)%s*hours?")) or 0) * 3600000
          + (tonumber(i:match("(%d+)%s*mins?")) or tonumber(i:match("(%d+)%s*minutes?")) or 0) * 60000
        ) + (tonumber(i:match("(%d+)%s*secs?")) or tonumber(i:match("(%d+)%s*seconds?")) or 0) * 1000
        j[(B or "0") .. (":" .. M)] = { ["name"] = M, ["icon"] = tonumber(B), ["remaining"] = D > 0 and D or nil }
      end
    end
  end
  return B and j or nil
end
function Bl.present(M, B)
  if not B or B == "?" then
    return nil
  end
  if M[B] then
    return M[B], B
  end
  local j = tonumber(B:match("^(%d+):"))
  if j and j > 0 then
    for M, B in pairs(M) do
      if B["icon"] == j then
        return B, M
      end
    end
  end
end
function Bl.read()
  local M = b()
  local B = M and tonumber(M["netID"] or M["netid"])
  if not B then
    return nil
  end
  local j = { ["net"] = B, ["world"] = P() }
  Bl["waiting"] = j
  local K, i = pcall(SendPacket or sendPacket, 2, "action|wrench\n|netid|" .. B)
  local D = 0
  while p and (P() == j["world"] and (K and (i ~= false and (not j["effects"] and D < 3000)))) do
    Kl(100)
    D = D + 100
  end
  Bl["waiting"] = nil
  return j["effects"]
end
function Bl.hex(M)
  return (M:gsub(".", function(M)
    return string["format"]("%02x", M:byte())
  end))
end
function Bl.unhex(M)
  return (M:gsub("%x%x", function(M)
    return string["char"](tonumber(M, 16))
  end))
end
function Bl.map()
  local M = {}
  for B, j in K["consumableEffects"]:gmatch("(%d+)=([^;]+)") do
    M[tonumber(B)] = j == "?" and "?" or Bl["unhex"](j)
  end
  return M
end
function Bl.remember(M)
  local B = {}
  for M, j in pairs(M) do
    B[#B + 1] = M .. ("=" .. (j == "?" and "?" or Bl["hex"](j)))
  end
  table["sort"](B)
  K["consumableEffects"] = table["concat"](B, ";")
  V()
end
function Bl.status(M)
  m("CAF_consumableStatus", M)
  m("CAF_consumableLive", M)
end
function Bl.run()
  if not p then
    return true
  end
  if not K["autoConsumable"] then
    Bl["status"]("OFF - ENABLE AUTO CONSUMABLE")
    return true
  end
  if K["consumableItems"] == "" then
    Bl["status"]("NO ITEMS SELECTED")
    return true
  end
  if not Bl["initialCheck"] and k - Bl["last"] < K["consumableCheck"] then
    return true
  end
  Bl["last"] = k
  Bl["busy"] = true
  local M, B = pcall(function()
    Bl["status"]("CHECKING PLAYER BUFFS BEFORE CONSUMING")
    local M = Bl["read"]()
    if not M then
      Bl["status"]("WAITING FOR PLAYER BUFF CHECK - FARMING PAUSED")
      Kl(1000)
      return false
    end
    Bl["initialCheck"] = false
    local B = Bl["map"]()
    for j in K["consumableItems"]:gmatch("%d+") do
      if not p or Y or ml() or Yl then
        return true
      end
      local i = tonumber(j)
      local D = B[i]
      if not D or D == "?" then
        local j = getItemInfoByID or GetItemInfo
        local K, z = pcall(j, i)
        local Q = K and (z and (z["name"] and z["name"]:lower()))
        for M, j in pairs(M) do
          local K = Q and (Q:gsub("[^a-z]", "") == "songpyeon" and j["name"]:gsub("[^a-z]", "") == "lucky")
          if j["icon"] == i or (Q and j["name"] == Q) or K then
            D = M
            B[i] = M
            Bl["remember"](B)
            break
          end
        end
      end
      local z = Bl["present"](M, D)
      if z then
        Bl["missing"][i] = 0
        if z["remaining"] then
          Bl["activeUntil"][i] = k + z["remaining"]
        end
      end
      local Q = Bl["activeUntil"][i] and k < Bl["activeUntil"][i]
      local G = false
      if D and (D ~= "?" and (not z and not Q)) then
        Bl["missing"][i] = (Bl["missing"][i] or 0) + 1
        G = Bl["missing"][i] < 3
      end
      if D == "?" then
        Bl["status"]("ITEM " .. (i .. ": EFFECT UNKNOWN - CLEAR LIST TO RESET"))
      elseif z or Q then
        Bl["status"]("ITEM " .. (i .. ": BUFF ACTIVE - WAITING FOR EXPIRY"))
      elseif G then
        Bl["status"]("ITEM " .. (i .. (": BUFF MISSING " .. (Bl["missing"][i] .. "/3 - WAITING"))))
      else
        local j = S(i)
        if j and j > 0 then
          B[i] = "?"
          Bl["remember"](B)
          local z = b()
          local Q = P()
          local G = z and tonumber(z["netID"] or z["netid"])
          if not G then
            return true
          end
          Bl["status"]("USING " .. (i .. " ON SELF"))
          local W, s = pcall(
            SendPacketRaw or sendPacketRaw,
            false,
            {
              ["type"] = 3,
              ["value"] = i,
              ["x"] = z["posX"],
              ["y"] = z["posY"],
              ["px"] = math["floor"](z["posX"] / 32),
              ["py"] = math["floor"](z["posY"] / 32),
            }
          )
          if not W or s == false then
            Bl["status"]("ITEM " .. (i .. ": USE NOT CONFIRMED"))
            return true
          end
          if not Kl(K["consumableDelay"]) or P() ~= Q then
            return false
          end
          local T = Bl["read"]()
          if not T then
            Bl["status"]("ITEM " .. (i .. ": EFFECT CHECK UNCONFIRMED"))
            return true
          end
          local y
          if D and Bl["present"](T, D) then
            y = D
          else
            local B = {}
            for j in pairs(T) do
              if not Bl["present"](M, j) then
                B[#B + 1] = j
              end
            end
            if #B == 1 then
              y = B[1]
            end
          end
          local m = S(i)
          if y and (m and m < j) then
            B[i] = y
            Bl["remember"](B)
            Bl["missing"][i] = 0
            local M = Bl["present"](T, y)
            if M and M["remaining"] then
              Bl["activeUntil"][i] = k + M["remaining"]
            end
            Bl["status"]("ITEM " .. (i .. ": EFFECT CONFIRMED - WAIT FOR EXPIRY"))
          else
            Bl["status"]("ITEM " .. (i .. ": EFFECT UNKNOWN - NO AUTOMATIC REUSE"))
          end
          M = T
        else
          Bl["status"]("ITEM " .. (i .. ": NO STOCK"))
        end
      end
    end
    return true
  end)
  Bl["busy"] = false
  Bl["waiting"] = nil
  if not M then
    error(B, 0)
  end
  return B
end
Bl["vial"] = { ["last"] = -math["huge"], ["missing"] = 0, ["seen"] = false }
function Bl.vialName(M)
  local B = getItemInfoByID or GetItemInfo
  if type(B) == "function" then
    local j, K = pcall(B, M)
    if j and (K and K["name"]) then
      return tostring(K["name"])
    end
  end
  local j = growtopia and growtopia["getItemName"]
  if type(j) == "function" then
    local B, K = pcall(j, M)
    if B then
      return tostring(K or "")
    end
  end
end
function Bl.validVial(M)
  local B = Bl["vialName"](M)
  B = B and (B:lower()):gsub("[^a-z]", "")
  return B and (B:find("vilevial", 1, true) and not B:find("seed", 1, true))
end
function Bl.vialStatus(M)
  m("CAF_vialStatus", M)
end
function Bl.runVial()
  if not p or not K["autoVileVial"] or K["autoCure"] then
    return true
  end
  local M = Bl["vial"]
  if k - M["last"] < K["vialCheck"] then
    return true
  end
  M["last"] = k
  if K["vileVialID"] <= 0 or not Bl["validVial"](K["vileVialID"]) then
    Bl["vialStatus"]("SELECT ONE VILE VIAL TYPE")
    return true
  end
  Bl["busy"] = true
  local B, j = pcall(function()
    local B = Ll()
    if B == nil then
      Bl["vialStatus"]("PLAYER STATUS UNCONFIRMED - NO VIAL USED")
      return true
    end
    if B then
      M["missing"] = 0
      M["seen"] = true
      if K["vialUnconfirmed"] then
        K["vialUnconfirmed"] = false
        V()
      end
      Bl["vialStatus"]("MALADY ACTIVE - SKIP VIAL")
      return true
    end
    if K["vialUnconfirmed"] then
      Bl["vialStatus"]("LAST USE UNCONFIRMED - RESELECT VIAL TO RESET")
      return true
    end
    if M["seen"] then
      M["missing"] = M["missing"] + 1
      if M["missing"] < 3 then
        Bl["vialStatus"]("NO MALADY " .. (M["missing"] .. "/3 - VERIFYING"))
        return true
      end
    end
    local j = S(K["vileVialID"])
    if not j or j < 1 then
      Bl["vialStatus"]("NO SELECTED VIAL IN BACKPACK")
      return true
    end
    local i = b()
    local D = P()
    if not i then
      return false
    end
    K["vialUnconfirmed"] = true
    V()
    Bl["vialStatus"]("USING VILE VIAL ON SELF")
    local z, Q = pcall(
      SendPacketRaw or sendPacketRaw,
      false,
      {
        ["type"] = 3,
        ["value"] = K["vileVialID"],
        ["x"] = i["posX"],
        ["y"] = i["posY"],
        ["px"] = math["floor"](i["posX"] / 32),
        ["py"] = math["floor"](i["posY"] / 32),
      }
    )
    if not z or Q == false then
      Bl["vialStatus"]("USE UNCONFIRMED - NO RETRY")
      return true
    end
    if not Kl(K["vialDelay"]) or P() ~= D then
      return false
    end
    local G = Ll()
    local W = S(K["vileVialID"])
    if G and (W and W < j) then
      K["vialUnconfirmed"] = false
      V()
      M["seen"] = true
      M["missing"] = 0
      Bl["vialStatus"]("VIAL CONFIRMED - MALADY ACTIVE")
    else
      Bl["vialStatus"]("USE UNCONFIRMED - NO AUTOMATIC RETRY")
    end
    return true
  end)
  Bl["busy"] = false
  if not B then
    error(j, 0)
  end
  return j
end
local function tl()
  if not K["autoCure"] or not Yl then
    return true
  end
  if K["cureWorld"] == "" then
    return Ol("CURE BLOCKED - SET CURE WORLD FIRST")
  end
  xl = true
  if El then
    if not Gl(d) or not zl(Z, a, 3, 3200) then
      return Ol("RETURN TO FARM FAILED")
    end
    local M = Ll()
    if M == false then
      El, Yl, xl, Xl = false, false, false, 0
      rl = 0
      v("CURE CONFIRMED - BACK AT FARM")
      return true
    end
    rl = rl + 1
    local B = (M and 2) or 4
    if rl >= B then
      rl = 0
      Xl = 0
      El, Yl, xl = false, false, false
      v(M and "CURE DID NOT TAKE EFFECT - RESUMING FARM" or "CURE UNVERIFIED - RESUMING FARM")
      G(
        "Auto cure did not take effect (check gems in the cure world). Farming resumed; the malady is re-checked on the next interval."
      )
      return false
    end
    v(M and "MALADY STILL ACTIVE - VERIFY CURE" or "WAITING FOR CURE VERIFICATION")
    return false
  end
  if not Gl(K["cureWorld"]) then
    return Ol("WAIT CURE WORLD")
  end
  local M = {}
  local B = GetTiles or getTiles
  local j, i = pcall(B)
  if not j or type(i) ~= "table" then
    return Ol("CURE WORLD TILES UNAVAILABLE")
  end
  local D = getItemInfoByID or GetItemInfo or getItemInfo
  local z = {}
  for B, j in pairs(i) do
    local K = tonumber(j["fg"])
    if K and not z[K] then
      local M, B = pcall(D, K)
      local j = M and (B and (tostring(B["name"] or "")):lower())
      z[K] = j and (j:gsub("[^a-z]", "")):find("autosurgeon", 1, true) ~= nil or false
    end
    if K and z[K] then
      M[#M + 1] = { ["x"] = tonumber(j["x"]), ["y"] = tonumber(j["y"]) }
    end
  end
  for M, B in ipairs(M) do
    if not p or not K["autoCure"] then
      xl = false
      return false
    end
    if B["x"] and B["y"] then
      for M, j in ipairs({ { B["x"], B["y"] }, { B["x"] - 1, B["y"] }, { B["x"] + 1, B["y"] } }) do
        if j[1] >= 0 and zl(j[1], j[2], 2, 2300) then
          local M = b()
          Jl = ""
          local i = M
            and pcall(
              SendPacketRaw,
              false,
              { ["type"] = 3, ["value"] = 32, ["px"] = B["x"], ["py"] = B["y"], ["x"] = M["posX"], ["y"] = M["posY"] }
            )
          if i then
            for M = 1, 30, 1 do
              if not p or Jl == "autoSurgeonUi" then
                break
              end
              Kl(100)
            end
            if p and Jl == "autoSurgeonUi" then
              Jl = ""
              local M, B =
                pcall(SendPacket, 2, "action|dialog_return\ndialog_name|autoSurgeonUi\nbuttonClicked|purchaseCureBtn")
              if not M or B == false then
                Jl = nil
                return Ol("CURE CLICK 1 NOT SENT")
              end
              for M = 1, 30, 1 do
                if not p or Jl == "autoSurgeonCurePurchaseUi" then
                  break
                end
                Kl(100)
              end
              if
                p and (
                  K["autoCure"] and (
                    Jl == "autoSurgeonCurePurchaseUi" and (P() == n(K["cureWorld"]) and Dl(j[1], j[2]))
                  )
                )
              then
                El = true
                Xl = 0
                rl = 0
                local M, B = pcall(
                  SendPacket,
                  2,
                  "action|dialog_return\ndialog_name|autoSurgeonCurePurchaseUi\nbuttonClicked|purchaseCureBtn"
                )
                Jl = nil
                if not M or B == false then
                  v("CURE RESULT UNKNOWN - RETURNING TO FARM")
                end
                Kl(1000)
                return false
              end
            end
          end
          Jl = nil
        end
      end
    end
  end
  return Ol("AUTO SURGEON NOT FOUND OR DIALOG UNAVAILABLE")
end
local function gl(M)
  if M == nil then
    return nil
  end
  local B, j, K = pcall(function()
    local B = M["pos"]
    return tonumber(M["posX"] or (B and B["x"])), tonumber(M["posY"] or (B and B["y"]))
  end)
  if not B or not j or not K then
    return nil
  end
  return math["floor"](j / 32), math["floor"](K / 32), j, K
end
local hl = nil
local function wl()
  local M = {}
  if not Z or not a then
    return M
  end
  for B = 1, 5, 1 do
    local j = tostring(K["pattern" .. B] or "00000")
    local i, D
    for K = 1, 5, 1 do
      if j:sub(K, K) == "1" then
        i = i or K
        D = K
        M[((Z + K) - 3) .. ("," .. ((a + B) - 3))] = true
      end
    end
    if i then
      local j = (a + B) - 3
      M[((Z + i) - 4) .. ("," .. j)] = true
      M[((Z + D) - 2) .. ("," .. j)] = true
    end
  end
  hl = M
  return M
end
local function Al(M, B)
  if not Z or not a then
    return false
  end
  if not hl then
    wl()
  end
  return hl[M .. ("," .. B)] == true
end
local function fl(M)
  local B = Ml()
  if not B then
    return nil
  end
  local j = {}
  local i, D = e()
  local z = {}
  local function Q(M)
    local B = z[M]
    if B == nil then
      B = l(M)
      z[M] = B
    end
    return B < 200
  end
  for B, z in pairs(B) do
    local G = tonumber(z and z["itemid"])
    local W = tonumber(z and (z["id"] or z["uid"]))
    local s, T, y, m = gl(z)
    local p = (M == "BLOCK" and G == K["itemID"]) or (M == "BREAK" and (G ~= nil and Al(s or -999, T or -999)))
    if G and (W and (s and (T and (p and (not Tl(s, T) and Q(G)))))) then
      local M = i and (math["abs"](i - s) + math["abs"](D - T)) or 9999
      j[#j + 1] = { ["id"] = G, ["uid"] = W, ["x"] = s, ["y"] = T, ["ox"] = y, ["oy"] = m, ["d"] = M }
    end
  end
  table["sort"](j, function(B, j)
    if M == "BREAK" and B["y"] ~= j["y"] then
      return B["y"] < j["y"]
    end
    if B["d"] ~= j["d"] then
      return B["d"] < j["d"]
    end
    if B["y"] ~= j["y"] then
      return B["y"] < j["y"]
    end
    return B["x"] < j["x"]
  end)
  return j
end
local function vl(M)
  for B, j in pairs(Ml() or {}) do
    if tonumber(j["id"]) == M then
      return true
    end
  end
  return false
end
local Vl
local Pl = 1
local function nl(M, B, j, K)
  local i = 0
  for M, D in ipairs(M) do
    if not p or P() ~= (Vl or F) or not Dl(B, j) then
      return i
    end
    if
      D["y"] == j and (
        math["abs"](D["x"] - B) <= 3 and (not K[D["uid"]] and (not Tl(D["x"], D["y"]) and l(D["id"]) < 200))
      )
    then
      local M, B =
        pcall(SendPacketRaw, false, { ["type"] = 11, ["value"] = D["uid"], ["x"] = D["ox"], ["y"] = D["oy"] })
      if M and B ~= false then
        K[D["uid"]] = true
        i = i + 1
        if ml() then
          Y = true
          return i
        end
      end
    end
  end
  return i
end
local function bl(M, B)
  if not p or P() ~= (Vl or F) or l(M["id"]) >= 200 then
    return false
  end
  local j, i = M["x"], M["y"]
  local D = H(j, i)
  if not D or tonumber(D["fg"]) ~= 0 then
    local M = H(j + 1, i)
    if M and tonumber(M["fg"]) == 0 then
      j = j + 1
    end
  end
  if not zl(j, i, 2, 3500) then
    return false
  end
  local z = fl("BLOCK")
  if not z then
    return false
  end
  local Q = nl(z, j, i, {})
  if Q > 0 then
    Kl(B or K["pickupDelay"])
  end
  return Q > 0
end
local el = false
local ul = 300
local function Ul(M)
  if not K["autoCollect"] or not p then
    return true
  end
  if P() ~= F or Y then
    return false
  end
  if not M and k - o < K["collectDelay"] then
    return true
  end
  o = k
  local B, j = e()
  if not B or not j or not Dl(Z, a) then
    return false
  end
  local i = GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"])
  local D, z = pcall(i)
  if not D or type(z) ~= "table" then
    m("CAF_collectStatus", "OBJECT SCAN UNAVAILABLE")
    return true
  end
  local Q, G, W, s, T = 0, 0, 0, 0, 0
  local y = {}
  for M, B in pairs(z) do
    if not p or P() ~= F or not Dl(Z, a) then
      return false
    end
    local j, K, i, D, z = pcall(function()
      local M = tonumber(B["posX"] or (B["pos"] and B["pos"]["x"]))
      local j = tonumber(B["posY"] or (B["pos"] and B["pos"]["y"]))
      return M, j, tonumber(B["itemid"]), tonumber(B["id"] or B["uid"])
    end)
    if j and (K and (i and (D and z))) then
      local M, B = math["floor"](K / 32), math["floor"](i / 32)
      if Al(M, B) then
        Q = Q + 1
        if Tl(M, B) then
          G = G + 1
        else
          y[#y + 1] = { ["id"] = D, ["uid"] = z, ["ox"] = K, ["oy"] = i, ["x"] = M, ["y"] = B }
        end
      end
    end
  end
  table["sort"](y, function(M, B)
    if M["y"] ~= B["y"] then
      return M["y"] < B["y"]
    end
    return M["x"] < B["x"]
  end)
  local d = {}
  local x = SendPacketRaw or sendPacketRaw
  for M, B in ipairs(y) do
    if not p or P() ~= F or not Dl(Z, a) then
      return false
    end
    if d[B["id"]] == nil then
      d[B["id"]] = l(B["id"])
    end
    if d[B["id"]] >= 200 and B["id"] ~= 112 then
      W = W + 1
    else
      local j = q[B["uid"]] or -100000
      if k - j >= ul then
        local j, K = pcall(x, false, { ["type"] = 11, ["value"] = B["uid"], ["x"] = B["ox"], ["y"] = B["oy"] })
        if j and K ~= false then
          T = T + 1
          q[B["uid"]] = k
          if M < #y then
            Kl(50)
          end
        else
          s = s + 1
        end
      end
    end
  end
  m(
    "CAF_collectStatus",
    Q .. (
        " on tiles+edges / " .. (
          T .. (" sent / " .. (G .. (" storage protected / " .. (W .. (" full / " .. (s .. " failed"))))))
        )
      )
  )
  if ml() then
    Y = true
    return false
  end
  return p
end
local function Cl(M)
  if el then
    return true
  end
  el = true
  local B, j = pcall(Ul, M)
  el = false
  if not B then
    error(j, 0)
  end
  return j
end
local Sl
local ll = false
jl = function()
  if
    Bl["busy"]
    or (Sl and Sl["busy"])
    or ll
    or el
    or not K["autoCollect"]
    or not p
    or Y
    or xl
    or P() ~= F
    or not Dl(Z, a)
  then
    return
  end
  ll = true
  local M, B = pcall(Cl, false)
  ll = false
  if not M then
    m("CAF_collectStatus", "PICKUP ERROR: " .. (tostring(B)):sub(1, 90))
  end
end
Sl = { ["busy"] = false, ["wait"] = nil, ["checked"] = {} }
function Sl.field(M, B)
  return tonumber(M:match("embed_data|" .. (B .. "|(%d+)")) or M:match("\n" .. (B .. "|(%d+)")))
end
function Sl.clean(M)
  return (M:gsub(string["char"](96) .. ".", "")):lower()
end
function Sl.name(M)
  local B = getItemInfoByID or GetItemInfo
  if type(B) == "function" then
    local j, K = pcall(B, M)
    if j and (K and K["name"]) then
      return K["name"]
    end
  end
  local j = growtopia and growtopia["getItemName"]
  if type(j) == "function" then
    local B, K = pcall(j, M)
    if B then
      return K
    end
  end
end
function Sl.await(M, B, j, i, D)
  local z, Q = e()
  local G = { ["world"] = M, ["x"] = B, ["y"] = j, ["expected"] = i, ["sx"] = z, ["sy"] = Q }
  Sl["wait"] = G
  local W, s = pcall(D)
  if W and s ~= false then
    local B = 0
    while p and (P() == M and (not G["text"] and B < K["gautTimeout"])) do
      Kl(100)
      B = B + 100
    end
  end
  Sl["wait"] = nil
  return G["text"]
end
function Sl.dialog(M)
  local B = Sl["wait"]
  if not p or not B or P() ~= B["world"] or not M or M["v1"] ~= "OnDialogRequest" or type(M["v2"]) ~= "string" then
    return false
  end
  local j = M["v2"]
  local K = j:match("end_dialog|([^|]+)|")
  if not K or (B["expected"] and K ~= B["expected"]) or (not B["expected"] and not K:find("itemsucker", 1, true)) then
    return false
  end
  local i, D = Sl["field"](j, "tilex"), Sl["field"](j, "tiley")
  if (i and i ~= B["x"]) or (D and D ~= B["y"]) then
    return false
  end
  if (not i or not D) and (not B["sx"] or not Dl(B["sx"], B["sy"])) then
    return false
  end
  B["text"] = j
  B["dialog"] = K
  return true
end
function Sl.machine(M, B, j)
  if l(B) >= 200 then
    return true
  end
  local i = false
  for B, K in ipairs({ { 0, -1 }, { 0, 1 } }) do
    if P() ~= j or not p then
      return false
    end
    local D, z = M["x"] + K[1], M["y"] + K[2]
    v("GAUT: TRY " .. ((K[2] < 0 and "TOP " or "BOTTOM ") .. (D .. ("," .. z))))
    if z >= 0 then
      for M = 1, 2, 1 do
        local B = FindPath or findPath
        if type(B) == "function" then
          pcall(B, D, z)
        end
        local K = 0
        while p and (P() == j and K < 4200) do
          if Dl(D, z) then
            if Kl(250) and Dl(D, z) then
              i = true
            end
            break
          end
          Kl(100)
          K = K + 100
        end
        if i or not p or P() ~= j then
          break
        end
        Kl(200)
      end
    end
    if i then
      break
    end
  end
  if not i then
    v("GAUT UNREACHABLE " .. (M["x"] .. ("," .. M["y"])))
    return false
  end
  local D, z = e()
  local function Q()
    return p and (P() == j and Dl(D, z))
  end
  if not Kl(K["gautDelay"]) or not Q() then
    return false
  end
  local G
  for B = 1, 2, 1 do
    if not Q() then
      return false
    end
    G = Sl["await"](j, M["x"], M["y"], nil, function()
      local j = b()
      local K = SendPacketRaw or sendPacketRaw
      if not j or not Q() or type(K) ~= "function" then
        v("GAUT: WRENCH API / STANDING POSITION UNAVAILABLE")
        return false
      end
      v("GAUT: WRENCH " .. (M["x"] .. ("," .. (M["y"] .. (" ATTEMPT " .. B)))))
      return K(
        false,
        { ["type"] = 3, ["value"] = 32, ["px"] = M["x"], ["py"] = M["y"], ["x"] = j["posX"], ["y"] = j["posY"] }
      )
    end)
    if G then
      break
    end
    if B < 2 then
      Kl(500)
    end
  end
  if not G then
    v("GAUT: NO WRENCH DIALOG AFTER 2 REQUESTS")
    return false
  end
  local W = Sl["clean"](G)
  local s = Sl["field"](G, "targetitem") or Sl["field"](G, "itemID") or Sl["field"](G, "itemid")
  if not s then
    for M in G:gmatch("[^\r\n]+") do
      if (Sl["clean"](M)):find("contains", 1, true) then
        s = tonumber(M:match("|left|(%d+)|"))
        if s then
          break
        end
      end
    end
  end
  local T = W:match("contains a total of%s+([%d,]+)")
    or W:match("contains%s+([%d,]+)")
    or W:match("currently stored:%s*([%d,]+)")
  T = T and tonumber((T:gsub(",", "")))
  if T == 0 or W:find("contains no items", 1, true) or W:find("currently empty", 1, true) then
    return true
  end
  if not s then
    local M = Sl["name"](B)
    local j = Sl["name"](K["itemID"] + 1)
    if M and (W:find(M:lower(), 1, true) and not (B == K["itemID"] and (j and W:find(j:lower(), 1, true)))) then
      s = B
    end
  end
  if s ~= B then
    v("GAUT: SKIPPED OTHER / UNKNOWN STORED ITEM")
    return true
  end
  if not G:find("add_button|retrieveitem|", 1, true) then
    v("GAUT: RETRIEVE UNAVAILABLE")
    return false
  end
  local y = G:match("end_dialog|([^|]+)|")
  if not Kl(K["gautDelay"]) or not Q() then
    return false
  end
  local m = Sl["await"](j, M["x"], M["y"], "itemremovedfromsucker", function()
    return Q()
      and SendPacket(
        2,
        "action|dialog_return\ndialog_name|"
          .. (
            y .. (
              "\ntilex|" .. (
                M["x"] .. ("|\ntiley|" .. (M["y"] .. "|\nbuttonClicked|retrieveitem\nchk_enablesucking|1"))
              )
            )
          )
      )
  end)
  if not m then
    v("GAUT: AMOUNT DIALOG NOT CONFIRMED")
    return false
  end
  local F = Sl["field"](m, "targetitem") or Sl["field"](m, "itemID") or Sl["field"](m, "itemid")
  if F and F ~= B then
    v("GAUT: AMOUNT ITEM MISMATCH")
    return false
  end
  local d = (Sl["clean"](m)):match("contains a total of%s+([%d,]+)") or (Sl["clean"](m)):match("contains%s+([%d,]+)")
  d = d and tonumber((d:gsub(",", "")))
  local Z = l(B)
  local a = math["min"](200 - Z, T or 200, d or 200)
  if a <= 0 then
    return true
  end
  if not Kl(K["gautDelay"]) or not Q() then
    return false
  end
  local Y, x = pcall(
    SendPacket,
    2,
    "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"
      .. (M["x"] .. ("|\ntiley|" .. (M["y"] .. ("|\nitemtoremove|" .. a))))
  )
  if not Y or x == false then
    return false
  end
  local J = 0
  while p and (P() == j and (l(B) <= Z and J < K["gautTimeout"])) do
    Kl(100)
    J = J + 100
  end
  if l(B) <= Z then
    v("GAUT: WITHDRAWAL UNCONFIRMED - NO BLIND RETRY")
    return false
  end
  return true
end
function Sl.trash()
  if not K["autoTrash"] or not p then
    return true
  end
  Sl["busy"] = true
  for M in K["trashItems"]:gmatch("%d+") do
    local B = tonumber(M)
    local j = l(B)
    if j >= K["trashCount"] then
      local M = P()
      local K = { ["id"] = B, ["world"] = M }
      Sl["trashWait"] = K
      v("AUTO TRASH: " .. B)
      local i = SendPacket or sendPacket
      local D, z = pcall(i, 2, "action|trash\nitemID|" .. B)
      local Q = 0
      while p and (P() == M and (D and (z ~= false and (not K["ready"] and Q < 3000)))) do
        Kl(100)
        Q = Q + 100
      end
      Sl["trashWait"] = nil
      if not p or P() ~= M or not K["ready"] then
        Sl["busy"] = false
        error("AUTO TRASH: confirmation missing for " .. B, 0)
      end
      local G = math["min"](j, l(B))
      if G > 0 then
        D, z = pcall(i, 2, "action|dialog_return\ndialog_name|trash_item\nitemID|" .. (B .. ("|\ncount|" .. G)))
        Q = 0
        while p and (P() == M and (D and (z ~= false and (l(B) >= j and Q < 3000)))) do
          Kl(100)
          Q = Q + 100
        end
        if l(B) >= j then
          Sl["busy"] = false
          error("AUTO TRASH: inventory change unconfirmed for " .. B, 0)
        end
      end
    end
  end
  Sl["busy"] = false
  return true
end
function Sl.eligible()
  if not K["clearGAUT"] then
    return false
  end
  local M = S(K["itemID"])
  m(
    "CAF_gautInventory",
    "Item " .. (
        K["itemID"] .. (": " .. ((M and tostring(M) or "UNAVAILABLE") .. (" blocks / GAUT at <= " .. K["gautBelow"])))
      )
  )
  return M ~= nil and M <= K["gautBelow"]
end
function Sl.check()
  if not Sl["eligible"]() then
    return true
  end
  if not Kl(150) then
    return false
  end
  if not Sl["eligible"]() then
    return true
  end
  local M = P()
  if K["gautInterval"] > 0 and (Sl["checked"][M] and k - Sl["checked"][M] < K["gautInterval"]) then
    return true
  end
  Sl["busy"] = true
  local B, j = pcall(function()
    local B = GetTiles or getTiles
    if type(B) ~= "function" then
      v("GAUT: TILE SCAN UNAVAILABLE")
      return false
    end
    local j = B()
    if type(j) ~= "table" or next(j) == nil then
      return false
    end
    local i = {}
    local D = findItemID or (growtopia and growtopia["getItemID"])
    local z, Q
    if type(D) == "function" then
      local M, B = pcall(D, "Unstable Tesseract")
      if M then
        z = tonumber(B)
      end
      M, B = pcall(D, "Gaia's Beacon")
      if M then
        Q = tonumber(B)
      end
    end
    for M, B in pairs(j) do
      local j = Sl["name"](tonumber(B["fg"]))
      j = j and (j:lower()):gsub("[^a-z]", "")
      local D = j == "unstabletesseract" or (z and (z > 0 and tonumber(B["fg"]) == z))
      local G = j == "gaiasbeacon" or (Q and (Q > 0 and tonumber(B["fg"]) == Q))
      if D or G then
        i[#i + 1] =
          { ["x"] = tonumber(B["x"]), ["y"] = tonumber(B["y"]), ["id"] = D and K["itemID"] or K["itemID"] + 1 }
      end
    end
    if #i == 0 then
      v("GAUT: NO GAIA / UT FOUND IN " .. M)
    end
    table["sort"](i, function(M, B)
      return M["x"] == B["x"] and M["y"] < B["y"] or M["x"] > B["x"]
    end)
    for B, j in ipairs(i) do
      if not j["x"] or not j["y"] or not Sl["machine"](j, j["id"], M) then
        return false
      end
    end
    Sl["checked"][M] = k
    return true
  end)
  Sl["busy"] = false
  Sl["wait"] = nil
  if not B then
    error("GAUT: " .. tostring(j), 0)
  end
  if not j and (p and P() == M) then
    error("GAUT check stopped: " .. (tostring(O) .. " (no automatic farm shuttle)"), 0)
  end
  return j
end
function Sl.refillCheck()
  Sl["refillWorlds"] = Sl["refillWorlds"] or {}
  local M = P()
  if Sl["refillWorlds"][M] or not Sl["eligible"]() then
    return true
  end
  Bl["missing"] = {}
  v("REFILL: CHECK GAIA / UT ONCE")
  if not Sl["check"]() then
    return false
  end
  Sl["refillWorlds"][M] = true
  return true
end
local function Hl()
  local M = Sl["eligible"]()
  if not Sl["refillCheck"]() then
    return false
  end
  local B = M and 200 or K["pickupBelow"]
  if not K["autoPickup"] or l(K["itemID"]) >= B then
    if not Gl(d) or not zl(Z, a, 3, 2300) then
      return false
    end
    if l(K["itemID"]) > 0 then
      Sl["refillWorlds"] = nil
    end
    return true
  end
  local j = {}
  for M in K["pickupWorlds"]:gmatch("[^,;]+") do
    local B = (M:upper()):gsub("%s+", "")
    if B ~= "" then
      if not B:match("^[A-Z0-9]+$") and not B:match("^[A-Z0-9]+|[%w_-]+$") then
        v("INVALID PICKUP WORLD " .. B)
        return false
      end
      j[#j + 1] = B
    end
  end
  if #j == 0 then
    j = { d }
  end
  if Pl > #j then
    Pl = 1
  end
  local i = 0
  while p and (Pl <= #j and l(K["itemID"]) < B) do
    local M = j[Pl]
    Vl = n(M)
    if not Gl(M) then
      Vl = nil
      return false
    end
    if not Sl["refillCheck"]() then
      Vl = nil
      return false
    end
    v("REFILL: COLLECT GROUND BLOCKS")
    local D = fl("BLOCK")
    if not D then
      Vl = nil
      return false
    end
    if #D == 0 then
      Kl(500)
      D = fl("BLOCK")
      if not D then
        Vl = nil
        return false
      end
      if #D == 0 then
        Pl = Pl + 1
      end
    end
    if #D > 0 then
      local M = 0
      for j, D in ipairs(D) do
        if not p or P() ~= Vl then
          Vl = nil
          return false
        end
        if i >= K["pickupWorldMax"] or l(K["itemID"]) >= B then
          break
        end
        if vl(D["uid"]) and l(K["itemID"]) < 200 then
          if bl(D, K["pickupDelay"]) then
            M = 0
          else
            M = M + 1
          end
          i = i + 1
          if M >= 3 then
            break
          end
        end
      end
      break
    end
  end
  Vl = nil
  if not p then
    return false
  end
  if not Gl(d) or not zl(Z, a, 3, 2300) then
    v("AUTO PICKUP: RETURN TO FARM FAILED")
    return false
  end
  pl()
  if l(K["itemID"]) > 0 then
    Sl["refillWorlds"] = nil
    v("REFILL COMPLETE - RESUME BREAKING")
    return true
  end
  v("REFILL: NO BLOCKS YET - WAITING FOR GROUND STOCK")
  Kl(1500)
  return false
end
local function MB(M, B)
  local j = b()
  if not j then
    return false
  end
  local K, i = pcall(
    SendPacketRaw,
    false,
    { ["type"] = 3, ["state"] = 2592, ["value"] = 18, ["px"] = M, ["py"] = B, ["x"] = j["posX"], ["y"] = j["posY"] }
  )
  return K and i ~= false
end
local function BB(M, B, j)
  local K = b()
  if not K then
    return false
  end
  local i, D = pcall(
    SendPacketRaw,
    false,
    { ["type"] = 3, ["state"] = 2592, ["value"] = j, ["px"] = M, ["py"] = B, ["x"] = K["posX"], ["y"] = K["posY"] }
  )
  return i and D ~= false
end
local function jB()
  local M = {}
  for B = 1, 5, 1 do
    local j = K["pattern" .. B]
    for K = 1, 5, 1 do
      if j:sub(K, K) == "1" then
        M[#M + 1] = { ["dx"] = K - 3, ["dy"] = B - 3 }
      end
    end
  end
  return M
end
local function KB(M)
  return type(M) == "string" and (#M == 5 and M:match("^[01]+$") ~= nil)
end
local function iB(M)
  local B = {}
  local j, K = 1, M
  while j <= K do
    B[#B + 1] = j
    if j ~= K then
      B[#B + 1] = K
    end
    j = j + 1
    K = K - 1
  end
  return B
end
local DB = {}
local function zB(M, B)
  if not K["doPlace"] then
    return false
  end
  local j = H(M, B)
  if not j or tonumber(j["fg"] or -1) ~= 0 then
    return false
  end
  if l(K["itemID"]) < 1 then
    return false
  end
  local i = tostring(M) .. ("," .. tostring(B))
  local D = k
  if D - (DB[i] or -100000) < math["max"](100, K["placeDelay"] - 50) then
    return false
  end
  if BB(M, B, K["itemID"]) then
    DB[i] = D
    Kl(math["max"](20, K["placeDelay"] - math["random"](0, 50)))
    return true
  end
  return false
end
local QB = nil
local function GB(M, B)
  local j = 0
  if QB and (QB["x"] ~= M or QB["y"] ~= B) then
    zB(QB["x"], QB["y"])
  end
  if zB(M, B) then
    j = j + 1
  elseif K["doBreak"] then
    for i = 1, K["hitCount"], 1 do
      if not p or P() ~= F then
        return false, j
      end
      if not Dl(Z, a) then
        return false, j
      end
      local D = H(M, B)
      if not D then
        return false, j
      end
      if tonumber(D["fg"]) == 0 then
        break
      end
      if not MB(M, B) then
        return false, j
      end
      j = j + 1
      if not Kl(math["max"](20, K["breakDelay"] - math["random"](0, 50))) then
        return false, j
      end
      if zB(M, B) then
        j = j + 1
        break
      end
      if K["autoCollect"] and not Cl(false) then
        return false, j
      end
    end
  end
  QB = { ["x"] = M, ["y"] = B }
  if K["autoCollect"] and not Cl(false) then
    return false, j
  end
  return true, j
end
local function WB(M)
  if M <= 1 then
    N = 1
    return
  end
  N = (N % M) + 1
end
local function sB()
  if not p or P() ~= F or not b() then
    v("FARM WORLD LOST - AUTO RESUME")
    return false
  end
  if not Dl(Z, a) then
    v("VERIFY FARM POSITION -> " .. (Z .. ("," .. a)))
    if not zl(Z, a, 2, 3000) then
      return false
    end
  end
  if Sl["eligible"]() or (K["autoPickup"] and l(K["itemID"]) < K["pickupBelow"]) then
    if not Hl() then
      return false
    end
    if l(K["itemID"]) == 0 then
      v("WAITING FOR BLOCK REFILL BEFORE BREAKING")
      Kl(1000)
      return false
    end
  end
  local M = jB()
  local B = #M
  local j = iB(B)
  if B == 0 then
    v("SELECT AT LEAST ONE 5x5 TILE")
    return false
  end
  if N < 1 or N > B then
    N = 1
    R = 1
  end
  local i = 0
  for K = 1, B, 1 do
    if not p or P() ~= F then
      return false
    end
    local D = M[j[N]]
    local z, Q = Z + D["dx"], a + D["dy"]
    if z < 0 or Q < 0 or z > 199 or Q > 119 then
      v("SELECTED TILE OUT OF WORLD: " .. (N .. (" (" .. (z .. ("," .. (Q .. ")"))))))
      return false
    end
    if z == Z and Q == a then
      v("PLAYER CENTER CANNOT BE A PINK TARGET")
      return false
    end
    local G, W = GB(z, Q)
    if not G then
      return false
    end
    i = i + W
    WB(B)
    if ml() then
      return al()
    end
  end
  if K["doPlace"] and K["doBreak"] then
    for M, B in ipairs(M) do
      if not p or P() ~= F then
        return false
      end
      zB(Z + B["dx"], a + B["dy"])
    end
  end
  E = E + 1
  if K["autoCollect"] and not Cl(false) then
    return false
  end
  if ml() or Y then
    return al()
  end
  if E % 10 == 0 then
    pl()
  end
  if i == 0 then
    Kl(100)
  end
  return p
end
local function TB()
  local M = {}
  for B = 1, 5, 1 do
    local j = {}
    local i = tostring(K["pattern" .. B] or "00000")
    for M = 1, 5, 1 do
      if B == 3 and M == 3 then
        j[#j + 1] = "P"
      elseif i:sub(M, M) == "1" then
        j[#j + 1] = "\226\150\160"
      else
        j[#j + 1] = "\226\150\161"
      end
    end
    M[#M + 1] = table["concat"](j, " ")
  end
  return table["concat"](M, " / ")
end
local function yB()
  local M = TB()
  if M ~= J then
    J = M
    m("CAF_gridPreview", M)
  end
end
local function mB()
  X = X + 1
  N = 1
  R = 1
  QB = nil
  DB = {}
  hl = nil
  q = {}
end
local function pB(M, B, j)
  if p or M == 3 and B == 3 then
    return
  end
  local i = "pattern" .. M
  local D = K[i]
  K[i] = D:sub(1, B - 1) .. ((j and "1" or "0") .. D:sub(B + 1))
  mB()
  yB()
  m("CAF_pattern" .. M, K[i])
  V()
end
local FB = UserInterface["new"](B, "Agriculture")
FB:addLabelApp(B, "Agriculture")
FB:addItemPicker("Block to Farm", tostring(K["itemID"]), tostring(K["itemID"]), "CAF_picker")
FB:addDisplayList("Block / Seed ID", tostring(K["itemID"]) .. (" / " .. tostring(Wl())), "CAF_itemInfo")
FB:addLabelApp("Select Tiles - the exact same tiles are punched, placed and collected", "Agriculture")
local dB = "{}"
do
  local M = 0
  if K["pickerBase"] == "-2..2" then
    M = 2
  elseif K["pickerBase"] == "1-5" then
    M = -1
  elseif K["pickerBase"] == "0-4" then
    M = 0
  end
  if M then
    local B = {}
    for j = 1, 5, 1 do
      for i = 1, 5, 1 do
        if (j ~= 3 or i ~= 3) and K["pattern" .. j]:sub(i, i) == "1" then
          B[#B + 1] = "{" .. (((i - 1) - M) .. ("," .. (((j - 1) - M) .. "}")))
        end
      end
    end
    if #B > 0 then
      dB = table["concat"](B)
    end
  end
end
local ZB = false
pcall(function()
  FB:addTileSelect("Select Tiles", dB, "CAF_tileSelect", 5)
  ZB = true
end)
FB:addDisplayList("Current Selection (synced)", TB(), "CAF_gridPreview")
if ZB then
  FB:addDisplayList(
    "Tile Selection Info",
    "Picker: pink = break/place targets, P = you. Tap a pink tile again to clear it. Start checks the selection and tells you here if anything is missing.",
    "CAF_gridHelp"
  )
else
  FB:addDisplayList(
    "Tile Selection Info",
    "This Growlauncher build has no tile select control; update Growlauncher.",
    "CAF_gridHelp"
  )
end
local aB = FB:addDialog("Autofarm Setting", "Break/place delays and farm position", {})
FB:addChildToggle(aB["menu"], "Break", K["doBreak"], "CAF_doBreak")
FB:addChildToggle(aB["menu"], "Place", K["doPlace"], "CAF_doPlace")
FB:addChildInputInt(
  aB["menu"],
  "Punches per Selected Tile per Visit",
  tostring(K["hitCount"]),
  "1-40",
  "1",
  nil,
  "CAF_hitCount"
)
FB:addChildInputInt(
  aB["menu"],
  "Delay Break (ms; smart -0..50)",
  tostring(K["breakDelay"]),
  "ms",
  "150",
  nil,
  "CAF_breakDelay"
)
FB:addChildInputInt(
  aB["menu"],
  "Delay Place (ms; smart -0..50)",
  tostring(K["placeDelay"]),
  "ms",
  "100",
  nil,
  "CAF_placeDelay"
)
FB:addChildTooltip(
  aB["menu"],
  "Verify position before continue",
  "Always ON; auto returns to the saved farm position/world after unexpected movement or disconnect.",
  "Agriculture",
  true
)
FB:addChildInputString(aB["menu"], "Farm World", K["farmWorld"], "WORLD|DOOR", "World", nil, "CAF_farmWorld")
FB:addChildButton(aB["menu"], "Farm World = Current World", "CAF_farmHere")
FB:addChildInputInt(
  aB["menu"],
  "Farm Position X",
  K["farmXSet"] and tostring(K["farmX"]) or "",
  "X",
  "",
  nil,
  "CAF_farmX"
)
FB:addChildInputInt(
  aB["menu"],
  "Farm Position Y",
  K["farmYSet"] and tostring(K["farmY"]) or "",
  "Y",
  "",
  nil,
  "CAF_farmY"
)
FB:addChildButton(aB["menu"], "Farm Position = Current Tile", "CAF_setfarm")
FB:addDisplayList("Farm Position (verify ON)", U(), "CAF_farmpos")
FB:addToggle("Start / Stop Autofarm", false, "CAF_enable")
FB:addDivider()
FB:addLabelApp("Auto collect - Selected tiles + 1 edge tile each side", "Agriculture")
FB:addToggle("Auto collect", K["autoCollect"], "CAF_autoCollect")
FB:addDisplayList("Collection Status", "READY", "CAF_collectStatus")
local YB = FB:addDialog("Auto collect Setting", "Pickup on selected tiles plus 1 edge tile per side", {})
FB:addChildInputInt(
  YB["menu"],
  "Collect Sweep Interval (ms)",
  tostring(K["collectDelay"]),
  "ms",
  "50",
  nil,
  "CAF_collectDelay"
)
FB:addChildTooltip(
  YB["menu"],
  "Pickup Method",
  "Every drop ON a selected tile, or on the one extra tile to the LEFT / RIGHT of each selected row, is requested with direct pickup packets. Punching and placement still use the exact mask only. It keeps firing during Break/Place; uncollected stacks are re-requested after about 300ms. Your storage drop tile stays protected.",
  "Agriculture",
  true
)
FB:addDivider()
FB:addLabelApp("Auto pickup - Farm blocks in world", "Agriculture")
FB:addToggle("Auto pickup", K["autoPickup"], "CAF_autoPickup")
local xB = (FB:addExpandableToggle("Clear GAUT", K["clearGAUT"], "CAF_clearGAUT", false))["list_child"]
FB:addChildInputString(xB, "GAUT Inventory (view only)", "Checked while running", "Count", "", nil, "CAF_gautInventory")
FB:addChildInputInt(
  xB,
  "GAUT Block Count (check at or below)",
  tostring(K["gautBelow"]),
  "0-200",
  "0",
  nil,
  "CAF_gautBelow"
)
FB:addChildInputInt(
  xB,
  "Check Interval (ms; 0 = every block refill)",
  tostring(K["gautInterval"]),
  "ms",
  "0",
  nil,
  "CAF_gautInterval"
)
FB:addChildInputInt(xB, "GAUT Action Delay (ms)", tostring(K["gautDelay"]), "ms", "300", nil, "CAF_gautDelay")
FB:addChildInputInt(
  xB,
  "GAUT Confirmation Timeout (ms)",
  tostring(K["gautTimeout"]),
  "ms",
  "3000",
  nil,
  "CAF_gautTimeout"
)
FB:addChildTooltip(
  xB,
  "Before Block Pickup",
  "Check UT for selected blocks and Gaia for selected item ID + 1 before ground block refill. Checks machines in the farm and visited supply worlds; extracts up to backpack capacity. Interval 0 checks each refill. Unknown dialogs stop the refill safely.",
  "Agriculture",
  true
)
local JB =
  FB:addDialog("Auto pickup Setting", "Collect farm blocks from supply worlds in order; blank uses farm world", {})
FB:addChildInputString(
  JB["menu"],
  "Pickup Worlds",
  K["pickupWorlds"],
  "WORLD|DOORID",
  "WORLD1, WORLD2|DOOR",
  nil,
  "CAF_pickupWorlds"
)
FB:addChildButton(JB["menu"], "Add Current World To Pickup List", "CAF_addPickupWorld")
FB:addChildButton(JB["menu"], "Remove All Pickup Worlds", "CAF_clearPickupList")
FB:addChildInputInt(
  JB["menu"],
  "Pick Up When Blocks Below",
  tostring(K["pickupBelow"]),
  "blocks",
  "1",
  nil,
  "CAF_pickupBelow"
)
FB:addChildInputInt(
  JB["menu"],
  "World Pickup Delay (ms)",
  tostring(K["pickupDelay"]),
  "ms",
  "100",
  nil,
  "CAF_pickupDelay"
)
FB:addChildInputInt(
  JB["menu"],
  "Max World Pickups per Sweep",
  tostring(K["pickupWorldMax"]),
  "items",
  "25",
  nil,
  "CAF_pickupWorldMax"
)
FB:addChildTooltip(
  JB["menu"],
  "Separate from Auto Collect",
  "When held blocks fall below the selected limit, scan the world for dropped FARM BLOCKS and return to your farm tile.",
  "Agriculture",
  true
)
FB:addDivider()
local EB = (FB:addExpandableToggle("Auto Cure", K["autoCure"], "CAF_autoCure", false, true))["list_child"]
FB:addChildInputString(EB, "Cure World", K["cureWorld"], "WORLD|DOORID", "WORLD|DOORID", nil, "CAF_cureWorld")
FB:addChildButton(EB, "Cure World = Current World", "CAF_cureWorldHere")
FB:addChildInputInt(
  EB,
  "Malady Check Interval (ms)",
  tostring(K["cureCheckDelay"]),
  "ms",
  "120000",
  nil,
  "CAF_cureCheckDelay"
)
pcall(function()
  FB:addChildDisplayList(EB, "Malady Status", "UNKNOWN - CHECKED AUTOMATICALLY WHILE FARMING", "CAF_maladyStatus")
  Rl = true
end)
FB:addChildTooltip(
  EB,
  "How auto cure works",
  "While farming: punch first, then every Check Interval the script wrenches YOU (requests your own wrench menu; the reply is read automatically, including the Malady line) and checks your own Active Effects. On detection it warps to the Cure World, automatically finds an Auto Surgeon, requests the cure, returns to your farm tile and verifies your Active Effects.",
  "Agriculture",
  true
)
FB:addDivider()
local NB = (FB:addExpandableToggle("Auto Vile Vial", K["autoVileVial"], "CAF_autoVileVial", false))["list_child"]
FB:addChildItemPicker(
  NB,
  "Select Vile Vial Type",
  K["vileVialID"] > 0 and (Bl["vialName"](K["vileVialID"]) or tostring(K["vileVialID"])) or "Select Vile Vial",
  tostring(K["vileVialID"]),
  "CAF_vileVialItem"
)
FB:addChildInputString(
  NB,
  "Selected Vial ID (one type only)",
  K["vileVialID"] > 0 and tostring(K["vileVialID"]) or "",
  "ID",
  "Select above",
  nil,
  "CAF_vileVialSelected"
)
FB:addChildButton(NB, "Clear Selected Vial", "CAF_clearVileVial")
FB:addChildInputInt(NB, "Delay After Vial Use (ms)", tostring(K["vialDelay"]), "ms", "1000", nil, "CAF_vialDelay")
FB:addChildInputInt(NB, "Malady Check Interval (ms)", tostring(K["vialCheck"]), "ms", "30000", nil, "CAF_vialCheck")
FB:addChildInputString(NB, "Vial Status (view only)", "READY", "Status", "", nil, "CAF_vialStatus")
FB:addDisplayList("Auto Consumable Status", "READY", "CAF_consumableLive")
local RB = (FB:addExpandableToggle("Auto Consumable", K["autoConsumable"], "CAF_autoConsumable", false))["list_child"]
FB:addChildItemPicker(RB, "Add Consumable", "Dirt", "2", "CAF_consumableItem")
FB:addChildInputString(
  RB,
  "Consumable IDs (selection order)",
  K["consumableItems"],
  "IDs",
  "Select items above",
  nil,
  "CAF_consumableList"
)
FB:addChildButton(RB, "Clear List", "CAF_clearConsumables")
FB:addChildInputInt(
  RB,
  "Delay Between Consumables (ms)",
  tostring(K["consumableDelay"]),
  "ms",
  "1000",
  nil,
  "CAF_consumableDelay"
)
FB:addChildInputInt(
  RB,
  "Active Effect Check Interval (ms)",
  tostring(K["consumableCheck"]),
  "ms",
  "30000",
  nil,
  "CAF_consumableCheck"
)
FB:addChildInputString(RB, "Consumable Status (view only)", "READY", "Status", "", nil, "CAF_consumableStatus")
FB:addChildTooltip(
  RB,
  "Effect Checking",
  "Use selected consumables on yourself in list order. Self-wrench checks Active Effects. Reuse only when a confirmed effect disappears. Unidentified effects are flagged instead of repeatedly consuming items. Clear List resets learned effects.",
  "Agriculture",
  true
)
FB:addDivider()
FB:addLabelApp("Auto drop - Seeds only", "Agriculture")
FB:addToggle("Auto Drop", K["autoDrop"], "CAF_autoDrop")
local XB = FB:addDialog("Auto Drop Settings", "Minimum seeds, storage world and exact X/Y coordinates", {})
FB:addChildInputInt(
  XB["menu"],
  "Minimum Seeds to Drop",
  tostring(K["dropMinimum"]),
  "1-200",
  "200",
  nil,
  "CAF_dropMinimum"
)
FB:addChildInputString(XB["menu"], "Drop World", K["dropWorld"], "WORLD|DOOR", "World", nil, "CAF_dropWorld")
FB:addChildButton(XB["menu"], "Set Drop World = Current World", "CAF_setworld")
FB:addChildInputInt(
  XB["menu"],
  "Drop Position X",
  K["dropXSet"] and tostring(K["dropX"]) or "",
  "X",
  "",
  nil,
  "CAF_dropX"
)
FB:addChildInputInt(
  XB["menu"],
  "Drop Position Y",
  K["dropYSet"] and tostring(K["dropY"]) or "",
  "Y",
  "",
  nil,
  "CAF_dropY"
)
FB:addChildButton(XB["menu"], "Set Drop Position = Current Tile", "CAF_setdrop")
FB:addChildInputString(
  XB["menu"],
  "Current Drop X (view only)",
  tostring(K["activeDropX"]),
  "X",
  "",
  nil,
  "CAF_activeDropX"
)
FB:addChildTooltip(
  XB["menu"],
  "Auto Drop Behavior",
  "Only seeds: trigger at minimum, drop held seeds, retry same position twice; shift left one tile if confirmed failure.",
  "Agriculture",
  true
)
FB:addToggle("Auto Trash", K["autoTrash"], "CAF_autoTrash")
local rB = FB:addDialog("Auto Trash Settings", "Select the items to trash automatically", {})
FB:addChildInputInt(rB["menu"], "Trash Item Count", tostring(K["trashCount"]), "1-200", "195", nil, "CAF_trashCount")
FB:addChildItemPicker(rB["menu"], "Add Item to Trash", "Dirt", "2", "CAF_trashItem")
FB:addChildInputString(
  rB["menu"],
  "Trash Item IDs (view only)",
  K["trashItems"],
  "IDs",
  "Select items above",
  nil,
  "CAF_trashList"
)
FB:addChildButton(rB["menu"], "Clear Trash List", "CAF_clearTrash")
FB:addDivider()
FB:addDisplayList("Inventory", "0 blocks / 0 seeds", "CAF_inventory")
FB:addDisplayList("Status", "STOPPED", "CAF_status")
FB:addDisplayList("Instant AutoSave", Q, "CAF_save")
pcall(function()
  addCategory(B, "Agriculture")
end)
local OB = FB:generateJSON()
local cB = pcall(function()
  addIntoModule(OB, B)
end)
if not cB then
  pcall(function()
    addIntoModule(OB)
  end)
end
local function kB(M)
  if type(M) == "number" then
    return M
  end
  if type(M) == "table" then
    local B = M["id"] or M["itemID"] or M["itemid"] or M["value"] or M["name"]
    return kB(B)
  end
  if type(M) == "string" then
    local B = tonumber(M) or tonumber(M:match("%((%d+)%)"))
    if B then
      return B
    end
    if type(findItemID) == "function" then
      local B, j = pcall(findItemID, M)
      if B then
        return tonumber(j)
      end
    end
  end
  return nil
end
local function oB(M)
  if type(M) == "table" then
    for B, j in ipairs({ "id", "itemid", "itemID", "value", "name" }) do
      local K = kB(M[j])
      if K and K > 0 then
        return K
      end
    end
    return nil
  end
  return kB(M)
end
local qB = nil
local function IB(M)
  if M == nil then
    return nil
  end
  if type(M) == "table" or type(M) == "userdata" then
    local B, j, K = pcall(function()
      return tonumber(M["x"] or M[1] or M["posX"]), tonumber(M["y"] or M[2] or M["posY"])
    end)
    if B and (j and K) then
      return { { ["x"] = j, ["y"] = K } }
    end
    local i = {}
    for M, B in pairs(M) do
      local j, K, D = pcall(function()
        return tonumber(B and (B["x"] or B[1] or B["posX"])), tonumber(B and (B["y"] or B[2] or B["posY"]))
      end)
      if j and (K and D) then
        i[#i + 1] = { ["x"] = K, ["y"] = D }
      end
    end
    if #i > 0 then
      return i
    end
  end
  local B, j = pcall(tostring, M)
  if not B then
    return nil
  end
  local K = {}
  for M, B in (tostring(j)):gmatch("(-?%d+)%D+(-?%d+)") do
    K[#K + 1] = { ["x"] = tonumber(M), ["y"] = tonumber(B) }
  end
  if #K > 0 then
    return K
  end
  return nil
end
local function LB(M)
  if M == "-2..2" then
    return 2
  end
  if M == "1-5" then
    return -1
  end
  if M == "0-4" then
    return 0
  end
  return nil
end
local function tB(M, B)
  if M < 0 or B < 0 then
    if K["pickerBase"] ~= "-2..2" then
      K["pickerBase"] = "-2..2"
      V()
    end
    return 2
  end
  if M == 5 or B == 5 then
    if K["pickerBase"] ~= "1-5" then
      K["pickerBase"] = "1-5"
      V()
    end
    return -1
  end
  if (M == 0 or B == 0) and K["pickerBase"] == "1-5" then
    K["pickerBase"] = "0-4"
    V()
  end
  if K["pickerBase"] == "" then
    K["pickerBase"] = "0-4"
    V()
  end
  return LB(K["pickerBase"]) or 0
end
local gB = false
local function hB(M)
  p = false
  Bl["waiting"] = nil
  Bl["busy"] = false
  ol = nil
  Sl["wait"] = nil
  Sl["trashWait"] = nil
  Sl["busy"] = false
  Y = false
  w = false
  A = false
  il(false)
  v(M or "STOPPED")
  gB = true
  local B = editToggle or EditToggle
  if type(B) == "function" then
    pcall(B, "CAF_enable", false)
  end
  gB = false
end
local function wB()
  if not p then
    return
  end
  hB("AUTO STOPPED - SETTING CHANGED")
  G("Farm stopped automatically so the setting could be applied. Press Start to resume.")
end
local AB = {
  ["CAF_vialDelay"] = "vialDelay",
  ["CAF_vialCheck"] = "vialCheck",
  ["CAF_autoConsumable"] = "autoConsumable",
  ["CAF_consumableDelay"] = "consumableDelay",
  ["CAF_consumableCheck"] = "consumableCheck",
  ["CAF_autoTrash"] = "autoTrash",
  ["CAF_trashCount"] = "trashCount",
  ["CAF_clearGAUT"] = "clearGAUT",
  ["CAF_gautBelow"] = "gautBelow",
  ["CAF_gautInterval"] = "gautInterval",
  ["CAF_gautDelay"] = "gautDelay",
  ["CAF_gautTimeout"] = "gautTimeout",
  ["CAF_doBreak"] = "doBreak",
  ["CAF_doPlace"] = "doPlace",
  ["CAF_pickupWorlds"] = "pickupWorlds",
  ["CAF_autoCure"] = "autoCure",
  ["CAF_cureWorld"] = "cureWorld",
  ["CAF_cureCheckDelay"] = "cureCheckDelay",
  ["CAF_autoCollect"] = "autoCollect",
  ["CAF_autoPickup"] = "autoPickup",
  ["CAF_autoDrop"] = "autoDrop",
  ["CAF_dropWorld"] = "dropWorld",
  ["CAF_dropMinimum"] = "dropMinimum",
  ["CAF_hitCount"] = "hitCount",
  ["CAF_breakDelay"] = "breakDelay",
  ["CAF_placeDelay"] = "placeDelay",
  ["CAF_collectDelay"] = "collectDelay",
  ["CAF_collectEvery"] = "collectEvery",
  ["CAF_pickupMax"] = "pickupMax",
  ["CAF_pickupBelow"] = "pickupBelow",
  ["CAF_pickupDelay"] = "pickupDelay",
  ["CAF_pickupWorldMax"] = "pickupWorldMax",
  ["CAF_dropX"] = "dropX",
  ["CAF_dropY"] = "dropY",
  ["CAF_farmWorld"] = "farmWorld",
  ["CAF_farmX"] = "farmX",
  ["CAF_farmY"] = "farmY",
}
local fB = {
  ["vialDelay"] = { 300, 10000 },
  ["vialCheck"] = { 5000, 3600000 },
  ["consumableDelay"] = { 300, 10000 },
  ["consumableCheck"] = { 5000, 3600000 },
  ["trashCount"] = { 1, 200 },
  ["gautBelow"] = { 0, 200 },
  ["gautInterval"] = { 0, 3600000 },
  ["gautDelay"] = { 100, 10000 },
  ["gautTimeout"] = { 500, 15000 },
  ["hitCount"] = { 1, 40 },
  ["breakDelay"] = { 10, 3000 },
  ["placeDelay"] = { 10, 3000 },
  ["collectDelay"] = { 40, 2000 },
  ["collectEvery"] = { 1, 50 },
  ["pickupMax"] = { 1, 40 },
  ["dropMinimum"] = { 1, 200 },
  ["pickupBelow"] = { 1, 200 },
  ["pickupDelay"] = { 50, 2000 },
  ["pickupWorldMax"] = { 1, 100 },
  ["dropX"] = { 0, 199 },
  ["dropY"] = { 0, 119 },
  ["activeDropX"] = { 0, 199 },
  ["farmX"] = { 0, 199 },
  ["farmY"] = { 0, 119 },
  ["cureCheckDelay"] = { 15000, 3600000 },
}
function onValue(M, B, j)
  if y[B] then
    return
  end
  local i = type(B) == "string" and tonumber(B:match("^CAF_pattern([1-5])$"))
  if i then
    local M = (tostring(j or "")):gsub("%s+", "")
    if #M ~= 5 or M:find("[^01]") then
      m(B, K["pattern" .. i])
      G("Use exactly five 0/1 digits per row.")
      return
    end
    if i == 3 then
      M = M:sub(1, 2) .. ("0" .. M:sub(4, 5))
    end
    if M ~= K["pattern" .. i] then
      wB()
      K["pattern" .. i] = M
      mB()
      yB()
      V()
    end
    m(B, M)
    m("CAF_gridHelp", "Saved 0/1 rows updated. Reopen the script to redraw pink tiles from this mask.")
    return
  end
  if B == "CAF_autoVileVial" or B == "CAF_autoCure" then
    local M = j == true or j == 1 or tostring(j) == "true" or tostring(j) == "1"
    local i = B == "CAF_autoVileVial" and "autoVileVial" or "autoCure"
    local D = i == "autoVileVial" and "autoCure" or "autoVileVial"
    if K[i] ~= M or (M and K[D]) then
      wB()
    end
    K[i] = M
    if M then
      K[D] = false
      local M = D == "autoCure" and "CAF_autoCure" or "CAF_autoVileVial"
      y[M] = true
      pcall(editToggle or EditToggle, M, false)
      y[M] = nil
    end
    if i == "autoVileVial" and M then
      Yl = false
      xl = false
      El = false
      Bl["vial"]["last"] = -math["huge"]
    end
    V()
    return
  elseif B == "CAF_vileVialItem" then
    local M = oB(j)
    if not M or not Bl["validVial"](M) then
      G("Select a Vile Vial consumable, not another item or seed.")
      return
    end
    wB()
    K["vileVialID"] = M
    K["vialUnconfirmed"] = false
    Bl["vial"] = { ["last"] = -math["huge"], ["missing"] = 0, ["seen"] = false }
    m("CAF_vileVialSelected", M)
    Bl["vialStatus"]("VIAL SELECTED")
    V()
    return
  elseif B == "CAF_clearVileVial" then
    wB()
    K["vileVialID"] = 0
    K["vialUnconfirmed"] = false
    Bl["vial"] = { ["last"] = -math["huge"], ["missing"] = 0, ["seen"] = false }
    m("CAF_vileVialSelected", "")
    Bl["vialStatus"]("NO VIAL SELECTED")
    V()
    return
  end
  if B == "CAF_consumableItem" then
    local M = oB(j)
    if not M or M < 1 or M > 65535 or M % 1 ~= 0 then
      return
    end
    for B in K["consumableItems"]:gmatch("%d+") do
      if tonumber(B) == M then
        return
      end
    end
    wB()
    K["consumableItems"] = K["consumableItems"] == "" and tostring(M) or K["consumableItems"] .. (", " .. M)
    m("CAF_consumableList", K["consumableItems"])
    V()
    return
  elseif B == "CAF_clearConsumables" then
    wB()
    K["consumableItems"] = ""
    K["consumableEffects"] = ""
    Bl["last"] = -math["huge"]
    Bl["missing"] = {}
    Bl["activeUntil"] = {}
    m("CAF_consumableList", "")
    Bl["status"]("LIST CLEARED")
    V()
    return
  end
  if B == "CAF_trashItem" then
    local M = oB(j)
    if not M or M < 1 or M > 65535 or M % 1 ~= 0 then
      return
    end
    for B in K["trashItems"]:gmatch("%d+") do
      if tonumber(B) == M then
        return
      end
    end
    wB()
    K["trashItems"] = K["trashItems"] == "" and tostring(M) or K["trashItems"] .. (", " .. M)
    m("CAF_trashList", K["trashItems"])
    V()
    return
  elseif B == "CAF_clearTrash" then
    wB()
    K["trashItems"] = ""
    m("CAF_trashList", "")
    V()
    return
  end
  if B == "CAF_tileSelect" then
    local B = IB(j)
    if not B or #B == 0 then
      m("CAF_gridHelp", "Could not read tile selection. Tap the tile again.")
      return
    end
    local i = {}
    for M, B in ipairs(B) do
      i[#i + 1] = B["x"] .. ("," .. B["y"])
    end
    i = table["concat"](i, ";")
    local D = M == "CAF_NATIVE_PICKER" and "native" or "hook"
    local z = (os and (os["clock"] and os["clock"]())) or 0
    if qB and (qB["signature"] == i and (qB["origin"] ~= D and z - qB["time"] < 0.25)) then
      qB = nil
      return
    end
    qB = { ["signature"] = i, ["origin"] = D, ["time"] = z }
    if p then
      wB()
    end
    local Q = tB(B[1]["x"], B[1]["y"])
    if #B == 1 then
      local M = math["floor"](B[1]["x"] + Q)
      local j = math["floor"](B[1]["y"] + Q)
      if M < 0 or M > 4 or j < 0 or j > 4 then
        m("CAF_gridHelp", "Select a tile inside the 5x5 grid.")
        return
      end
      local i, D = j + 1, M + 1
      if i == 3 and D == 3 then
        m("CAF_gridHelp", "PLAYER CENTER (TILE 13) CANNOT BE SELECTED")
        return
      end
      local z = K["pattern" .. i]:sub(D, D) ~= "1"
      pB(i, D, z)
      m(
        "CAF_gridHelp",
        "PICKER TAP "
          .. (
            B[1]["x"]
            .. (
              ","
              .. (
                B[1]["y"]
                .. (
                  " -> TILE " .. (
                    ((i - 1) * 5 + D) .. (" " .. ((z and "ON" or "OFF") .. (" / " .. (#jB() .. " selected"))))
                  )
                )
              )
            )
          )
      )
    else
      for M = 1, 5, 1 do
        K["pattern" .. M] = "00000"
      end
      local M = 0
      for B, j in ipairs(B) do
        local i = math["floor"](j["x"] + Q)
        local D = math["floor"](j["y"] + Q)
        if i >= 0 and (i <= 4 and (D >= 0 and (D <= 4 and not (i == 2 and D == 2)))) then
          local B = "pattern" .. (D + 1)
          if K[B]:sub(i + 1, i + 1) ~= "1" then
            K[B] = K[B]:sub(1, i) .. ("1" .. K[B]:sub(i + 2))
            M = M + 1
          end
        end
      end
      mB()
      yB()
      for M = 1, 5, 1 do
        m("CAF_pattern" .. M, K["pattern" .. M])
      end
      V()
      m("CAF_gridHelp", M .. " tiles selected")
    end
    return
  end
  if B == "CAF_pickupWorlds" then
    wB()
    K["pickupWorlds"] = tostring(j or "")
    Pl = 1
    V()
    return
  end
  if B == "CAF_addPickupWorld" then
    wB()
    local M = P()
    if M == "" or M == "EXIT" then
      G("Enter a world first.")
      return
    end
    local B = {}
    for M in K["pickupWorlds"]:gmatch("[^,;]+") do
      local j = (M:upper()):gsub("%s+", "")
      if j ~= "" then
        B[#B + 1] = j
      end
    end
    for B, j in ipairs(B) do
      if n(j) == M then
        G("Current world is already in the pickup list.")
        return
      end
    end
    B[#B + 1] = M
    K["pickupWorlds"] = table["concat"](B, ", ")
    m("CAF_pickupWorlds", K["pickupWorlds"])
    Pl = 1
    V()
    G("Added " .. (M .. " to the pickup list."))
    return
  end
  if B == "CAF_clearPickupList" then
    wB()
    K["pickupWorlds"] = ""
    m("CAF_pickupWorlds", "")
    Pl = 1
    V()
    G("Pickup list cleared; blank uses the farm world.")
    return
  end
  if B == "CAF_cureWorldHere" then
    local M = P()
    if M == "" or M == "EXIT" then
      G("Enter a world first.")
      return
    end
    K["cureWorld"] = M
    m("CAF_cureWorld", K["cureWorld"])
    V()
    G("Cure World set to " .. (M .. "."))
    return
  end
  if y[B] then
    return
  end
  if B == "CAF_enable" then
    if gB then
      return
    end
    if j == true or j == 1 or tostring(j) == "true" or tostring(j) == "1" then
      if p then
        return
      end
      local function M(M)
        v(M)
        gB = true
        local B = editToggle or EditToggle
        if type(B) == "function" then
          pcall(B, "CAF_enable", false)
        end
        gB = false
      end
      local B, j = e()
      local i = P()
      if (K["autoDrop"] or (S(Wl()) or 0) >= 200) and (not K["dropXSet"] or not K["dropYSet"]) then
        M("SET DROP POSITION FIRST")
        G("Set Drop Position = Current Tile or fill both X and Y.")
        return
      end
      if #jB() == 0 then
        M("SET PATTERN FIRST")
        m("CAF_gridHelp", "Select at least one tile before starting.")
        return
      end
      if K["farmXSet"] ~= K["farmYSet"] then
        M("SET BOTH FARM X AND Y")
        return
      end
      d = K["farmWorld"]
      F = n(d)
      if F == "" then
        if i == "" or i == "EXIT" then
          M("SET FARM WORLD FIRST")
          return
        end
        F = i
        d = i
        K["farmWorld"] = i
        m("CAF_farmWorld", i)
      end
      if u() then
        Z, a = K["farmX"], K["farmY"]
      elseif i == F and (B ~= nil and j ~= nil) then
        Z, a = B, j
        K["farmX"] = B
        K["farmY"] = j
        K["farmXSet"] = true
        K["farmYSet"] = true
        m("CAF_farmX", B)
        m("CAF_farmY", j)
      else
        M("SET FARM POSITION X/Y BEFORE START")
        return
      end
      C()
      V()
      Bl["vial"]["last"] = -math["huge"]
      Bl["last"] = -math["huge"]
      Bl["waiting"] = nil
      Bl["busy"] = false
      Bl["initialCheck"] = true
      Sl["checked"] = {}
      Sl["wait"] = nil
      Sl["busy"] = false
      Sl["refillWorlds"] = nil
      E = 0
      N = 1
      R = 1
      r = nil
      QB = nil
      DB = {}
      Y = (S(Wl()) or 0) >= 200
      x = 0
      o = -100000
      q = {}
      k = 0
      cl = -math["huge"]
      I = 0
      hl = nil
      p = true
      il(true)
      v(Y and "STARTED - DROP FULL SEEDS FIRST" or "STARTED - AUTO RESUME ON - " .. (Z .. ("," .. a)))
    else
      if p then
        hB("STOPPED")
      else
        v("STOPPED")
      end
    end
    return
  end
  if B == "CAF_picker" then
    local M = oB(j)
    if M and M > 0 then
      if s(M, 1, 65534) ~= K["itemID"] then
        wB()
      end
      K["itemID"] = s(M, 1, 65534)
      m("CAF_itemInfo", K["itemID"] .. (" / " .. Wl()))
      V()
    end
    return
  end
  if B == "CAF_farmHere" then
    wB()
    local M = P()
    if M == "" or M == "EXIT" then
      G("Enter a world first.")
      return
    end
    K["farmWorld"] = M
    m("CAF_farmWorld", M)
    C()
    V()
    return
  end
  if B == "CAF_setfarm" then
    wB()
    local M, B = e()
    local j = P()
    if not M or j == "" or j == "EXIT" then
      G("Enter the intended farm world first.")
      return
    end
    K["farmWorld"] = j
    K["farmX"] = M
    K["farmY"] = B
    K["farmXSet"] = true
    K["farmYSet"] = true
    m("CAF_farmWorld", j)
    m("CAF_farmX", M)
    m("CAF_farmY", B)
    C()
    V()
    v("FARM POSITION SAVED " .. (j .. (" " .. (M .. ("," .. B)))))
    return
  end
  if B == "CAF_setworld" then
    wB()
    local M = P()
    if M ~= "" and M ~= "EXIT" then
      K["dropWorld"] = M
      m("CAF_dropWorld", M)
      V()
    end
    return
  end
  if B == "CAF_setdrop" then
    wB()
    local M, B = e()
    if M then
      K["dropX"] = M
      K["dropY"] = B
      K["activeDropX"] = M
      K["dropXSet"] = true
      K["dropYSet"] = true
      m("CAF_dropX", M)
      m("CAF_dropY", B)
      m("CAF_activeDropX", M)
      m("CAF_activeDropY", B)
      V()
    end
    return
  end
  local D = AB[B]
  if not D then
    return
  end
  local z = K[D]
  local Q = K[D .. "Set"]
  if type(z) == "boolean" then
    K[D] = (j == true or tostring(j) == "true" or tostring(j) == "1")
  elseif fB[D] then
    local M = (D == "dropX" or D == "dropY" or D == "farmX" or D == "farmY")
    local B = (tostring(j or "")):gsub("%s+", "")
    if M and B == "" then
      K[D .. "Set"] = false
      K[D] = 0
    else
      K[D] = s(j, fB[D][1], fB[D][2])
      if M then
        K[D .. "Set"] = true
      end
    end
    if D == "dropX" then
      K["activeDropX"] = K["dropX"]
    end
    if D == "dropX" or D == "dropY" or D == "activeDropX" then
      m("CAF_activeDropX", K["activeDropX"])
      m("CAF_activeDropY", K["dropY"])
    end
    if D == "farmX" or D == "farmY" then
      C()
    end
  else
    K[D] = tostring(j or "")
    if D == "dropWorld" or D == "farmWorld" or D == "cureWorld" then
      K[D] = (K[D]:upper()):gsub("%s+", "")
    end
    if D == "farmWorld" then
      C()
    end
  end
  if tostring(K[D]) ~= tostring(z) or Q ~= K[D .. "Set"] then
    wB()
    V()
  end
end
function onVariant(M, B)
  if not p then
    return false
  end
  local j = Sl["trashWait"]
  if
    p
    and (
      j
      and (
        M
        and (
          M["v1"] == "OnDialogRequest"
          and (
            type(M["v2"]) == "string"
            and (
              P() == j["world"]
              and (
                M["v2"]:find("end_dialog|trash_item|", 1, true)
                and (Sl["field"](M["v2"], "itemID") or tonumber(M["v2"]:match("itemID|(%d+)"))) == j["id"]
              )
            )
          )
        )
      )
    )
  then
    j["ready"] = true
    return true
  end
  if Sl["dialog"](M) then
    return true
  end
  local i = Bl["waiting"]
  if i and (p and (M and (M["v1"] == "OnDialogRequest" and (type(M["v2"]) == "string" and P() == i["world"])))) then
    local B = M["v2"]
    local j = B:find("add_popup_name|WrenchMenu|", 1, true) or B:find("add_player_info|", 1, true)
    local K = tonumber(B:match("embed_data|netID|(%d+)") or B:match("embed_data|netid|(%d+)"))
    local D = b()
    if j and (D and (tonumber(D["netID"] or D["netid"]) == i["net"] and (not K or K == i["net"]))) then
      i["effects"] = Bl["effects"](B)
      if i["effects"] then
        return true
      end
    end
  end
  if
    M and (
      M["v1"] == "OnDialogRequest" and (
        type(M["v2"]) == "string" and M["v2"]:find("add_popup_name|WrenchMenu|", 1, true)
      )
    )
  then
    local B = b()
    local j = tonumber(M["v2"]:match("embed_data|netID|(%d+)"))
    if B and j == tonumber(B["netID"] or B["netid"]) then
      local B = Bl["waiting"]
      if B and (B["net"] == j and B["world"] == P()) then
        B["effects"] = Bl["effects"](M["v2"])
        if B["effects"] then
          return true
        end
      end
      local K = ql(M["v2"])
      if K ~= nil then
        if ol and (ol["net"] == j and ol["world"] == P()) then
          ol["done"] = true
          ol["result"] = K
        end
        if K then
          kl(K)
        else
          Nl = nil
          if Rl then
            m("CAF_maladyStatus", "NO MALADY - HEALTHY")
          end
        end
        if ol and ol["done"] then
          return true
        end
      end
    end
  end
  if p and (K["autoCure"] and (M and type(M["v2"]) == "string")) then
    if xl and (Jl ~= nil and M["v1"] == "OnDialogRequest") then
      local B = M["v2"]:match("end_dialog|([^|]+)|")
      if B == "autoSurgeonUi" or B == "autoSurgeonCurePurchaseUi" then
        Jl = B
      end
    end
  end
  if
    p
    and (
      dl
      and (
        M
        and (
          M["v1"] == "OnTextOverlay"
          and (
            type(M["v2"]) == "string"
            and (P() == n(K["dropWorld"] ~= "" and K["dropWorld"] or F) and Dl(K["activeDropX"], K["dropY"]))
          )
        )
      )
    )
  then
    local B = (M["v2"]:gsub(string["char"](96) .. ".", "")):lower()
    if B:find("you can't drop that here, find an emptier spot!", 1, true) then
      Fl = true
    end
  end
  if
    p and (
      w and (
        M and (M["v1"] == "OnDialogRequest" and (type(M["v2"]) == "string" and M["v2"]:find("drop_item", 1, true)))
      )
    )
  then
    A = true
    return true
  end
  return false
end
if type(setOnValue) == "function" then
  for M, B in ipairs({
    "CAF_autoVileVial",
    "CAF_autoCure",
    "CAF_vileVialItem",
    "CAF_clearVileVial",
    "CAF_vialDelay",
    "CAF_vialCheck",
    "CAF_autoConsumable",
    "CAF_consumableItem",
    "CAF_clearConsumables",
    "CAF_consumableDelay",
    "CAF_consumableCheck",
    "CAF_pattern1",
    "CAF_pattern2",
    "CAF_pattern3",
    "CAF_pattern4",
    "CAF_pattern5",
    "CAF_autoTrash",
    "CAF_trashCount",
    "CAF_trashItem",
    "CAF_clearTrash",
    "CAF_clearGAUT",
    "CAF_gautBelow",
    "CAF_gautInterval",
    "CAF_gautDelay",
    "CAF_gautTimeout",
    "CAF_enable",
    "CAF_cureWorld",
    "CAF_cureCheckDelay",
    "CAF_picker",
    "CAF_dropX",
    "CAF_dropY",
    "CAF_dropWorld",
    "CAF_dropMinimum",
    "CAF_farmX",
    "CAF_farmY",
    "CAF_farmWorld",
    "CAF_breakDelay",
    "CAF_placeDelay",
    "CAF_hitCount",
    "CAF_collectDelay",
    "CAF_collectEvery",
    "CAF_pickupMax",
    "CAF_pickupWorlds",
    "CAF_pickupBelow",
    "CAF_pickupDelay",
    "CAF_pickupWorldMax",
  }) do
    local j = B
    pcall(function()
      setOnValue(j, function(...)
        if y[j] then
          return
        end
        local M = { ... }
        if #M == 0 then
          return
        end
        local B = M[#M]
        onValue(nil, j, B)
      end)
    end)
  end
end
if type(setOnValue) == "function" then
  pcall(setOnValue, "CAF_tileSelect", function(...)
    local M = select("#", ...)
    if M > 0 then
      onValue("CAF_NATIVE_PICKER", "CAF_tileSelect", select(M, ...))
    end
  end)
end
pcall(function()
  applyHook()
end)
local function vB()
  if not p then
    return false
  end
  if P() ~= F or not b() then
    v("AUTO RESUME - RETURN TO " .. F)
    if not Gl(d) then
      return false
    end
  end
  if P() ~= F or not b() or not H(Z, a) then
    return false
  end
  if not Dl(Z, a) then
    v("AUTO RESUME - FARM POSITION " .. (Z .. ("," .. a)))
    if not zl(Z, a, 3, 3200) then
      return false
    end
  end
  return p and (P() == F and Dl(Z, a))
end
runThread(function()
  pl()
  yB()
  if T then
    V()
  end
  while true do
    if p then
      local M, B
      local j, i = true, nil
      if not Y and not ml() then
        j, i = pcall(Sl["trash"])
      end
      if not j then
        Sl["busy"] = false
        Sl["trashWait"] = nil
        hB(tostring(i))
      end
      if
        K["autoCure"] and (
          not xl and (not Yl and (not Y and (not ml() and (P() == F and (b() and k - cl >= K["cureCheckDelay"])))))
        )
      then
        Ll()
      end
      if Y or ml() then
        M, B = pcall(al)
      elseif K["autoCure"] and Yl then
        M, B = pcall(tl)
      elseif vB() then
        M, B = pcall(function()
          if not Bl["runVial"]() then
            return false
          end
          if not Bl["run"]() then
            return false
          end
          return sB()
        end)
      else
        M, B = true, false
      end
      if not M then
        hB("ERROR: " .. (tostring(B)):sub(1, 90))
      elseif p and B then
        x = 0
        Sleep(10)
        k = k + 10
      elseif p then
        x = math["min"](x + 1, 8)
        v(Y and "AUTO RESUME - PENDING STORAGE" or "AUTO RESUME - RECHECK FARM")
        Kl(math["min"](1200 + x * 400, 4500))
      end
    else
      Sleep(200)
    end
  end
end)
