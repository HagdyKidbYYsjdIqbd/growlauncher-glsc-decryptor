setMinimum("6.1.2")
local B = "Auto Restock Vend"
local K = 600
local M = 250
local l = 5000
local X =
  "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
local s = "RESTOCK"
local p
local U = ""
local m = 0
local function G(B)
  return (((tostring(B or "")):gsub("%s+", ""))):upper()
end
pcall(function()
  local B = Preferences
  if type(require) == "function" then
    local K, M = pcall(require, "preferences")
    if K and type(M) == "table" then
      B = M
    end
  end
  if type(B) ~= "table" or type(B["new"]) ~= "function" then
    return
  end
  p = B:new("AutoRestockVendLicense")
  p:load()
  U = G(p:get("license_key", ""))
end)
local function x(B)
  if not p then
    return false
  end
  return pcall(function()
    p:set("license_key", B)
    p:save()
  end)
end
local function N(B, ...)
  if type(B) ~= "function" then
    return nil
  end
  local K, M = pcall(B, ...)
  if K then
    return M
  end
end
local function I(B, ...)
  if type(B) ~= "function" then
    return false
  end
  local K, M = pcall(B, ...)
  return K and M ~= false
end
local function u(B)
  return (((tostring(B or "")):upper()):gsub("%s+", ""))
end
local function P(B)
  local K, M = B:match("^([A-Z0-9]+)|([^|]+)$")
  if K then
    return K, M
  end
  if B:match("^[A-Z0-9]+$") then
    return B
  end
end
local function y(B, K)
  local M = tonumber(B)
  if M then
    return math["max"](0, math["min"](K, math["floor"](M)))
  end
end
local Y, R, A, H, L = nil, false, "", "", 50
local h, d = K, M
pcall(function()
  local B, K = pcall(require, "preferences")
  if not B or type(K) ~= "table" then
    K = Preferences
  end
  if type(K) ~= "table" or type(K["new"]) ~= "function" then
    return
  end
  Y = K:new("AutoRestockVendSettings")
  Y:load()
  R = Y:get("autoCollect", "off") == "on"
  A = u(Y:get("collectWorld", ""))
  H = u(Y:get("returnDoor", ""))
  L = y(Y:get("pickupDelayMs", "50"), 1000) or 50
  h = y(Y:get("pathDelayMs", tostring(h)), 10000) or h
  d = y(Y:get("actionDelayMs", tostring(d)), 10000) or d
end)
local function j()
  if not Y then
    return
  end
  pcall(function()
    Y:set("autoCollect", R and "on" or "off")
    Y:set("collectWorld", A)
    Y:set("returnDoor", H)
    Y:set("pickupDelayMs", tostring(L))
    Y:set("pathDelayMs", tostring(h))
    Y:set("actionDelayMs", tostring(d))
    Y:save()
  end)
end
local k = UserInterface["new"](B, "ShoppingCart")
k:addLabelApp(B, "ShoppingCart")
k:addInputString("License Key", U, "A1234567", "A1234567", nil, "RSV_licensekey")
k:addButton("Verify License", "RSV_verifylicense")
k:addButton("Clear Saved License", "RSV_clearlicense")
k:addDisplayList("License Status", "NOT VERIFIED", "RSV_licensestatus")
k:addToggle("Start / Stop", false, "RSV_start")
k:addToggle("Auto Collect", R, "RSV_collect")
local o = k:addDialog("Auto Collect Settings", "Supply world and Door IDs", {})
k:addChildInputString(o["menu"], "Collect World", A, "WORLD or WORLD|DOORID", "WORLD|DOORID", nil, "RSV_world")
k:addChildButton(o["menu"], "Collect World = Current World", "RSV_here")
k:addChildInputString(o["menu"], "Vend Return Door ID (optional)", H, "Door ID", "", nil, "RSV_door")
local a = k:addDialog("Delay Settings", "FindPath, vending and pickup delays", {})
k:addChildInputInt(a["menu"], "FindPath Delay (ms)", tostring(h), "Delay", "600", nil, "RSV_pathdelay")
k:addChildInputInt(a["menu"], "Action Delay (ms)", tostring(d), "Delay", "250", nil, "RSV_actiondelay")
k:addChildInputInt(a["menu"], "Extra Pickup Delay (ms)", tostring(L), "Delay", "50", nil, "RSV_delay")
k:addDisplayList("Status", "STOPPED", "RSV_status")
N(addCategory, B, "ShoppingCart")
N(addIntoModule, k:generateJSON(), B)
local f, e, Z
local n
local function w(B)
  if n == B then
    return
  end
  n = B
  N(editValue, "RSV_status", B)
end
local function r()
  Z = true
  N(editToggle or EditToggle, "RSV_start", false)
  Z = false
end
local function F(B)
  N(growtopia and growtopia["notify"], B)
end
local function T(B)
  return f == B
end
local function Q()
  return u(N(GetWorldName or getCurrentWorldName))
end
local function z()
  local B = N(GetLocal or getLocal)
  if B and (tonumber(B["posX"]) and tonumber(B["posY"])) then
    return B, math["floor"](B["posX"] / 32), math["floor"](B["posY"] / 32)
  end
end
local function g(B)
  return T(B) and (B["world"] == Q() and z() ~= nil)
end
local function b(B, K)
  return N(GetTile or getTile or (tile and tile["getTile"]), B, K)
end
local function W()
  return N(GetTiles or getTiles)
end
local function t()
  local B = N(GetInventory or getInventory)
  if type(B) ~= "table" then
    return nil
  end
  local K = {}
  for B, M in pairs(B) do
    local l, X = tonumber(M["id"]), tonumber(M["amount"])
    if l and X then
      K[l] = X
    end
  end
  return K
end
local function c(B)
  local K = z()
  local M = K and tonumber(K["backpackSize"] or K["backpack_slots"] or K["inventorySize"] or K["inventorySlots"])
  if not M or M < 1 then
    return true
  end
  local l = 0
  for B, K in pairs(B) do
    if K > 0 then
      l = l + 1
    end
  end
  return l < M
end
local function q(B, K)
  for M = 1, 150, 1 do
    if not T(B) then
      return false
    end
    if Q() == K and z() then
      local M = W()
      if type(M) == "table" and next(M) then
        Sleep(300)
        if T(B) and (Q() == K and z()) then
          return true
        end
      end
    end
    Sleep(100)
  end
  return false
end
local function C(B, K)
  local M, l = P(K)
  if not T(B) or not M then
    return false
  end
  local X = SendPacket or sendPacket
  if Q() ~= M then
    B["doorRoute"] = nil
    w("WARPING TO " .. M)
    local K = growtopia and growtopia["warpTo"]
    local l = I(K, M)
    if not l then
      l = I(X, 3, "action|join_request\nname|" .. (M .. "\ninvitedWorld|0"))
    end
    if not l or not q(B, M) then
      return false
    end
    Sleep(1000)
    B["firstMove"] = true
  end
  if not T(B) or Q() ~= M or not z() then
    return false
  end
  if l and B["doorRoute"] ~= K then
    w("ENTERING " .. K)
    if not I(X, 3, "action|join_request\nname|" .. (K .. "\ninvitedWorld|0")) then
      return false
    end
    Sleep(1400)
    if not q(B, M) then
      return false
    end
    Sleep(1000)
    B["doorRoute"] = K
    B["firstMove"] = true
  end
  B["world"] = M
  return g(B)
end
local function E(B, K, M)
  if not g(B) then
    return false
  end
  local l, X, s = z()
  if X == K and s == M then
    return true
  end
  local p = B["firstMove"] and 2 or 1
  B["firstMove"] = false
  for l = 1, p, 1 do
    Sleep(B["pathDelay"])
    if not g(B) then
      return false
    end
    local p = pcall(FindPath or findPath, K, M)
    if p then
      local l, p, U = X, s, 0
      for m = 1, 60, 1 do
        Sleep(100)
        if not g(B) then
          return false
        end
        m, X, s = z()
        if X == K and s == M then
          return true
        end
        if X == l and s == p then
          U = U + 1
          if U >= 12 then
            break
          end
        else
          l, p, U = X, s, 0
        end
      end
    end
  end
  return false
end
local function i(B)
  if not B or (tonumber(B["fg"]) ~= 2978 and tonumber(B["fg"]) ~= 9268) or not B["extra"] then
    return
  end
  return tonumber(B["extra"]["vend_item"]), tonumber(B["extra"]["vend_price"])
end
local function O(B, K)
  if B["y"] ~= K["y"] then
    return B["y"] < K["y"]
  end
  if B["x"] ~= K["x"] then
    return B["x"] < K["x"]
  end
  return (B["uid"] or 0) < (K["uid"] or 0)
end
local function v()
  local B = W()
  if type(B) ~= "table" or not next(B) then
    return nil
  end
  local K = {}
  for B, M in pairs(B) do
    local l = i(M)
    local X, s = tonumber(M["x"]), tonumber(M["y"])
    if l and (l > 0 and (X and s)) then
      K[#K + 1] = { ["x"] = X, ["y"] = s, ["id"] = l }
    end
  end
  table["sort"](K, O)
  return K
end
local function V(B, K)
  for B in B:gmatch("[^\r\n]+") do
    local M = B:match("^embed_data|" .. (K .. "|([^|]+)")) or B:match("^" .. (K .. "|([^|]+)"))
    if M then
      return tonumber(M)
    end
  end
end
function onVariant(B)
  local K = f
  local M = K and K["dialog"]
  if not M or not g(K) or not B or B["v1"] ~= "OnDialogRequest" or type(B["v2"]) ~= "string" then
    return false
  end
  local l = B["v2"]
  if l:find("end_dialog|vending", 1, true) and (V(l, "tilex") == M["x"] and V(l, "tiley") == M["y"]) then
    M["text"] = l
    return true
  end
  return false
end
local function S(B, K)
  local M, l, X = z()
  if l == B and X == K then
    return M
  end
end
local function J(B, K)
  local M = S(K["x"], K["y"])
  if not g(B) or not M then
    return nil
  end
  local l = { ["x"] = K["x"], ["y"] = K["y"] }
  B["dialog"] = l
  if
    I(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = 32, ["px"] = K["x"], ["py"] = K["y"], ["x"] = M["posX"], ["y"] = M["posY"] }
    )
  then
    for K = 1, 25, 1 do
      if l["text"] or not g(B) then
        break
      end
      Sleep(100)
    end
  end
  B["dialog"] = nil
  return l["text"]
end
local function D(B, K)
  if not E(B, K["x"], K["y"]) then
    return nil
  end
  Sleep(B["actionDelay"])
  if not g(B) or i(b(K["x"], K["y"])) ~= K["id"] then
    return nil
  end
  local M = J(B, K)
  if not M then
    return nil
  end
  local l = V(M, "expectitem")
  if l and l ~= K["id"] then
    return nil
  end
  local X = (M:lower()):gsub("`.", "")
  local s = X:match("contains a total of%s+([%d,]+)") or X:match("contains%s+([%d,]+)")
  if not s and (X:find("contains no items", 1, true) or X:find("vending machine is empty", 1, true)) then
    return M, 0
  end
  return M, s and tonumber((s:gsub(",", "")))
end
local function B5(B, K)
  for M, X in ipairs(K) do
    if not g(B) then
      return false
    end
    if not X["unavailable"] and not X["stockChecked"] then
      w("CHECKING VEND " .. (M .. ("/" .. (#K .. (" AT " .. (X["x"] .. ("," .. X["y"])))))))
      local s, p = D(B, X)
      if p and p >= l then
        X["unavailable"], X["atStockLimit"] = true, true
      elseif not p or not s:find("add_button|addstock|", 1, true) then
        X["unavailable"] = true
      else
        X["stockChecked"] = true
      end
    end
  end
  return g(B)
end
local function K5(B, K)
  w("RESTOCK VEND " .. (K["x"] .. ("," .. K["y"])))
  local M = t()
  if not M then
    return "ERROR"
  end
  if (M[K["id"]] or 0) == 0 then
    return "EMPTY"
  end
  local X, s = D(B, K)
  if s and s >= l then
    return "FULL"
  end
  if not s or not X:find("add_button|addstock|", 1, true) then
    return "SKIP"
  end
  K["stockChecked"] = true
  Sleep(B["actionDelay"])
  local p, U = i(b(K["x"], K["y"]))
  local m = V(X, "expectitem")
  local G = V(X, "expectprice")
  if not g(B) or not S(K["x"], K["y"]) or p ~= K["id"] or not U or (m and m ~= p) or (G and G ~= U) then
    return "SKIP"
  end
  M = t()
  if not M then
    return "ERROR"
  end
  local x = M[p] or 0
  if x == 0 then
    return "EMPTY"
  end
  local N = U >= 0
  if
    not I(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|vending\ntilex|"
        .. (
          K["x"]
          .. (
            "|\ntiley|"
            .. (
              K["y"]
              .. (
                "|\nbuttonClicked|addstock\n\nsetprice|"
                .. (
                  math["abs"](U) .. (
                    "\nchk_peritem|" .. ((N and "1" or "0") .. ("\nchk_perlock|" .. (N and "0" or "1")))
                  )
                )
              )
            )
          )
        )
    )
  then
    return "SKIP"
  end
  for K = 1, 35, 1 do
    Sleep(100)
    if not g(B) then
      return "ERROR"
    end
    M = t()
    if M and (M[p] or 0) < x then
      Sleep(350)
      if not g(B) then
        return "ERROR"
      end
      M = t()
      if not M then
        return "ERROR"
      end
      local K = M[p] or 0
      if K < x then
        local M = x - K
        B["moved"] = B["moved"] + M
        if s + M >= l then
          return "FULL"
        end
        return K == 0 and "ADDED" or "PARTIAL"
      end
    end
  end
  if not t() then
    return "ERROR"
  end
  return "REJECTED"
end
local function M5(B, K, M)
  if (K[M["id"]] or 0) <= 0 then
    return nil
  end
  local l, X
  for B, K in ipairs(B) do
    if not K["unavailable"] and (not K["tried"] and K["id"] == M["id"]) then
      local B = math["abs"](K["x"] - M["x"]) + math["abs"](K["y"] - M["y"])
      if not X or B < X then
        l, X = K, B
      end
    end
  end
  return l
end
local function l5(B, K)
  for B, K in ipairs(K) do
    K["tried"] = false
  end
  for M, l in ipairs(K) do
    local X = l
    while X and (not X["unavailable"] and not X["tried"]) do
      if not g(B) then
        return false
      end
      local M = t()
      if not M then
        return false
      end
      if (M[X["id"]] or 0) == 0 then
        break
      end
      X["tried"] = true
      local l = K5(B, X)
      if l == "ERROR" then
        return false
      end
      if l == "FULL" or l == "SKIP" or l == "PARTIAL" or l == "REJECTED" then
        X["unavailable"] = true
        X["atStockLimit"] = l == "FULL"
        M = t()
        if not M then
          return false
        end
        X = M5(K, M, X)
      else
        break
      end
    end
  end
  return g(B)
end
local function X5(B)
  local K = N(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(K) ~= "table" then
    return nil
  end
  local M = {}
  for K, l in pairs(K) do
    local X, s = tonumber(l["itemid"]), tonumber(l["id"])
    local p = tonumber(l["posX"] or (l["pos"] and l["pos"]["x"]))
    local U = tonumber(l["posY"] or (l["pos"] and l["pos"]["y"]))
    if B[X] and (s and (p and U)) then
      M[#M + 1] =
        { ["id"] = X, ["uid"] = s, ["ox"] = p, ["oy"] = U, ["x"] = math["floor"](p / 32), ["y"] = math["floor"](U / 32) }
    end
  end
  table["sort"](M, O)
  return M
end
local function s5(B)
  local K = N(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(K) ~= "table" then
    return false
  end
  for K, M in pairs(K) do
    if tonumber(M["id"]) == B["uid"] and tonumber(M["itemid"]) == B["id"] then
      return true
    end
  end
  return false
end
local function p5(B)
  local K, M, l = z()
  return M and (math["abs"](M - B["x"]) <= 1 and math["abs"](l - B["y"]) <= 1)
end
local function U5(B, K)
  if p5(K) then
    return true
  end
  local M, l, X = z()
  if not l then
    return false
  end
  local s, p, U
  for B, M in ipairs({ { 0, 0 }, { -1, 0 }, { 1, 0 }, { 0, -1 }, { -1, -1 }, { 1, -1 } }) do
    local m, G = K["x"] + M[1], K["y"] + M[2]
    local x = b(m, G)
    if
      x
      and (
        x["collidable"] ~= true
        and (x["collidable"] ~= 1 and (tonumber(x["fg"]) == 0 or x["collidable"] == false or x["collidable"] == 0))
      )
    then
      local B = math["abs"](l - m) + math["abs"](X - G)
      if not U or B < U then
        s, p, U = m, G, B
      end
    end
  end
  if not s then
    return false
  end
  return E(B, s, p) and p5(K)
end
local function m5(B, K, M)
  if not s5(K) or not U5(B, K) then
    return true
  end
  Sleep(B["actionDelay"])
  if not g(B) then
    return false
  end
  local l = t()
  if not l then
    return false
  end
  if (l[K["id"]] or 0) ~= M or not s5(K) or not p5(K) then
    return true
  end
  if
    not I(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 11, ["value"] = K["uid"], ["x"] = K["ox"], ["y"] = K["oy"] }
    )
  then
    return true
  end
  Sleep(90 + B["pickupDelay"])
  for X = 1, 36, 1 do
    if not g(B) then
      return false
    end
    l = t()
    if l and (l[K["id"]] or 0) > M then
      return true
    end
    Sleep(25)
  end
  Sleep(500)
  return g(B)
end
local function G5(B, K)
  local M = t()
  if not M then
    return nil
  end
  local l = {}
  while g(B) do
    local X = X5(K)
    if not X then
      return nil
    end
    local s = false
    for K, M in ipairs(X) do
      if not g(B) then
        return nil
      end
      if not l[M["uid"]] then
        local K = t()
        if not K then
          return nil
        end
        local X = K[M["id"]] or 0
        if X < 200 and (X > 0 or c(K)) then
          l[M["uid"]] = true
          s = true
          if not m5(B, M, X) then
            return nil
          end
        end
      end
    end
    if not s then
      local B = t()
      if not B then
        return nil
      end
      for K in pairs(K) do
        if (B[K] or 0) > (M[K] or 0) then
          return true, #X > 0
        end
      end
      return false, #X > 0
    end
  end
end
local function x5(B)
  local K = N(getValue, 0, "ModFly")
  if K == true or K == 1 then
    return true
  end
  if not I(editToggle or EditToggle, "ModFly", true) then
    return false
  end
  B["restoreFly"] = true
  return true
end
local function N5(B)
  if B["restoreFly"] then
    B["restoreFly"] = nil
    I(editToggle or EditToggle, "ModFly", false)
  end
end
local function I5(B)
  local K = v()
  if not K then
    return "Could not scan the vending world."
  end
  if #K == 0 then
    return "No vending machines with an assigned item were found."
  end
  local M = B["collect"]
  while g(B) do
    if not l5(B, K) then
      return "Stopped during restocking. Check your world and inventory."
    end
    if not M then
      break
    end
    if not B5(B, K) then
      return "Could not finish checking vending stock."
    end
    local l = {}
    for B, K in ipairs(K) do
      if not K["unavailable"] then
        l[K["id"]] = true
      end
    end
    if not next(l) then
      local M, l = 0, 0
      for B, K in ipairs(K) do
        if K["atStockLimit"] then
          M = M + 1
        elseif K["unavailable"] then
          l = l + 1
        end
      end
      return "No eligible stock to collect. Added "
        .. (
          B["moved"]
          .. (
            " items. " .. (M .. (" vend(s) at 5,000 or more, " .. (l .. " vend check(s) or stock transfer(s) failed.")))
          )
        )
    end
    w("ENTERING COLLECT WORLD " .. B["collectRoute"])
    if not C(B, B["collectRoute"]) then
      return "Could not enter collect route " .. (B["collectRoute"] .. ".")
    end
    w("COLLECTING MATCHING ITEMS")
    local X = x5(B)
    local s, p
    if X then
      s, p = G5(B, l)
    end
    N5(B)
    if not T(B) then
      return "STOPPED"
    end
    if not C(B, B["returnRoute"]) then
      return "Could not return to the vending world."
    end
    if not X then
      return "Could not enable ModFly for Auto Collect."
    end
    if s == nil then
      return "Could not read supply world or inventory."
    end
    if not s then
      if p then
        return "No matching pickup confirmed. Check the supply path or backpack."
      end
      break
    end
    M = p
  end
  local l = 0
  for B, K in ipairs(K) do
    if K["unavailable"] then
      l = l + 1
    end
  end
  if l > 0 then
    return "Done. Added " .. (B["moved"] .. (" items. Skipped or full: " .. (l .. " vend(s).")))
  end
  return "Done. Added " .. (B["moved"] .. " items. No more matching stock.")
end
local function u5(B)
  B = tostring(B or "")
  B = B:gsub("\n", "\r\n")
  B = B:gsub("([^%w%-_%.~])", function(B)
    return string["format"]("%%%02X", string["byte"](B))
  end)
  return B
end
local function P5()
  local B = ""
  if type(getDiscordID) == "function" then
    local K, M = pcall(getDiscordID)
    if K and M ~= nil then
      B = tostring(M)
    end
  elseif getDiscordID ~= nil then
    B = tostring(getDiscordID)
  end
  B = ((tostring(B or "")):gsub("^%s+", "")):gsub("%s+$", "")
  if B == "" or B == "nil" or B == "0" then
    local K = GetLocal or getLocal
    if K ~= nil then
      local M, l = pcall(K)
      if M and (l ~= nil and l["name"] ~= nil) then
        B = tostring(l["name"])
        B = (B:gsub("^%s+", "")):gsub("%s+$", "")
      end
    end
  end
  if B == "nil" or B == "0" then
    return ""
  end
  return B
end
local function y5(B)
  pcall(editValue, "RSV_licensestatus", B)
end
local Y5 = {
  ["DISABLED"] = { "DISABLED", "License disabled." },
  ["WRONG_PRODUCT"] = { "WRONG PRODUCT", "This license is for another script." },
  ["BOUND_TO_OTHER_USER"] = { "BOUND TO OTHER USER", "License is bound to another user." },
  ["INVALID_KEY"] = { "INVALID KEY", "Invalid license key." },
  ["BAD_KEY_FORMAT"] = { "BAD KEY FORMAT", "License key format is invalid." },
  ["NO_ID"] = { "NO CLIENT ID", "Client ID is unavailable." },
}
local function R5(B)
  if not B:match("^[A-Z]%d%d%d%d%d%d%d$") then
    return false, "INVALID KEY FORMAT", "License must be 1 letter + 7 numbers, for example A1234567."
  end
  local K = P5()
  if K == "" then
    return false, "NO CLIENT ID", "Could not read a client ID. Enter the game first and try again."
  end
  local M = X .. ("?key=" .. (u5(B) .. ("&id=" .. (u5(K) .. ("&product=" .. u5(s))))))
  local l, p = pcall(fetch, M)
  if not l then
    return false, "SERVER ERROR", "License server request failed."
  end
  p = (tostring(p or "")):match("^%s*(.-)%s*$")
  local U = p:match("DENY|([A-Z_]+)")
  if U then
    local B = Y5[U]
    if B then
      return false, B[1], B[2]
    end
    return false, "DENIED", "License denied by server."
  end
  if p:find("OK|PERMANENT", 1, true) then
    return true, "VERIFIED - PERMANENT"
  end
  if p == "" then
    return false, "NO RESPONSE", "License server gave no response."
  end
  return false, "CHECK FAILED", "License check failed."
end
local A5, H5
local L5 = false
local function h5(B)
  f, e = B, true
  w("SCANNING VENDING WORLD")
  runThread(function()
    local K, M = pcall(I5, B)
    N5(B)
    e = false
    if not T(B) then
      return
    end
    f = nil
    r()
    local l = K and M or ("Restock stopped: " .. tostring(M))
    w(l)
    F(l)
  end)
end
local function d5(B)
  B["key"] = U
  B["revision"] = m
  H5 = B
  if L5 then
    return
  end
  L5 = true
  runThread(function()
    while H5 do
      local B = H5
      H5 = nil
      if B["revision"] == m and (not B["world"] or A5 == B) then
        y5("CHECKING...")
        local K, M, l = R5(B["key"])
        if B["revision"] == m then
          y5(M)
          if K then
            local K = x(B["key"])
            if B["manual"] then
              F(K and "License verified and saved." or "License verified. Could not save it.")
            end
          elseif B["manual"] or A5 == B then
            F(l)
          end
          if A5 == B then
            A5 = nil
            if K and (Q() == B["world"] and z()) then
              h5(B)
            else
              if K then
                F("Return to the vending world and press Start.")
              end
              r()
              w("STOPPED")
            end
          end
        end
      end
    end
    L5 = false
  end)
end
local function j5()
  if not A5 then
    return
  end
  A5 = nil
  r()
  w("STOPPED")
end
function onValue(B, K, M)
  if K == "RSV_licensekey" then
    local B = G(M)
    if B ~= U then
      U = B
      m = m + 1
      j5()
      y5("NOT VERIFIED")
    end
    return
  end
  if K == "RSV_verifylicense" then
    if not A5 then
      d5({ ["manual"] = true })
    end
    return
  end
  if K == "RSV_clearlicense" then
    U = ""
    m = m + 1
    j5()
    local B = x("")
    pcall(editValue, "RSV_licensekey", "")
    y5("NOT VERIFIED")
    F(B and "Saved license cleared." or "Could not update saved license storage.")
    return
  end
  if K == "RSV_collect" then
    R = M == true
    j()
    return
  end
  if K == "RSV_here" then
    local B = P(Q())
    if not B or B == "EXIT" or not z() then
      F("Enter the collect world first.")
      return
    end
    A = B
    j()
    N(editValue, "RSV_world", A)
    return
  end
  if K == "RSV_world" then
    local B = u(M)
    if B ~= A then
      A = B
      j()
    end
    return
  end
  if K == "RSV_door" then
    local B = u(M)
    if B ~= H then
      H = B
      j()
    end
    return
  end
  if K == "RSV_pathdelay" then
    local B = y(M, 10000)
    if B and B ~= h then
      h = B
      j()
    end
    return
  end
  if K == "RSV_actiondelay" then
    local B = y(M, 10000)
    if B and B ~= d then
      d = B
      j()
    end
    return
  end
  if K == "RSV_delay" then
    local B = y(M, 1000)
    if B and B ~= L then
      L = B
      j()
    end
    return
  end
  if K ~= "RSV_start" or Z then
    return
  end
  if M ~= true then
    local B = f
    A5 = nil
    f = nil
    if B then
      N5(B)
    end
    w("STOPPED")
    return
  end
  if f or A5 then
    return
  end
  if e then
    r()
    F("Wait for the previous run to stop.")
    return
  end
  local l = Q()
  if l == "" or l == "EXIT" or not z() then
    r()
    F("Enter your vending world before pressing Start.")
    return
  end
  if R and (not P(A) or P(A) == "EXIT" or H:find("|", 1, true)) then
    r()
    F("Check the Collect World and optional Vend Return Door ID.")
    return
  end
  local X = {
    ["world"] = l,
    ["collect"] = R,
    ["collectRoute"] = A,
    ["pickupDelay"] = L,
    ["pathDelay"] = h,
    ["actionDelay"] = d,
    ["returnRoute"] = H == "" and l or (l .. ("|" .. H)),
    ["moved"] = 0,
  }
  A5 = X
  w("CHECKING LICENSE BEFORE START")
  d5(X)
end
applyHook()
if type(setOnValue) == "function" then
  for B, K in ipairs({ "RSV_world", "RSV_door", "RSV_pathdelay", "RSV_actiondelay", "RSV_delay" }) do
    local M = K
    pcall(setOnValue, M, function(...)
      local B = select("#", ...)
      if B > 0 then
        onValue(nil, M, select(B, ...))
      end
    end)
  end
end
if U ~= "" then
  d5({})
end
