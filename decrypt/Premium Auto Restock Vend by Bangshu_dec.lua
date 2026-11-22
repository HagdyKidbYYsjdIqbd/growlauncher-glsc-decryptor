setMinimum("6.1.2")
local V = "Premium Auto Restock Vend by Bangshu"
do
  local u =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local S = "RESTOCK"
  local M = "RESTOCK-1-PAID-001"
  local k = "approval"
  local X = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function a()
    local V, u = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not V then
      return nil
    end
    if type(u) == "number" and (math["type"] and math["type"](u) == "integer") then
      u = tostring(u)
    end
    if type(u) ~= "string" or #u < 17 or #u > 20 or not u:match("^%d+$") then
      return nil
    end
    if u:match("^0+$") then
      return nil
    end
    return u
  end
  local function x(V, u)
    if not u or type(V) ~= "string" or #V > 512 then
      return false
    end
    local k, a, x = V:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (X .. '"}}%s*$')
    )
    return k == u and (a == S and x == M)
  end
  local j, i, z = pcall(function()
    local V, u = pcall(require, "preferences")
    local S = V and (type(u) == "table" and u) or Preferences
    if type(S) ~= "table" or type(S["new"]) ~= "function" then
      return nil
    end
    local M = S:new("BangshuPremiumAutoRestockVend")
    if M:load() == false then
      return M
    end
    return M, M:get(k, "")
  end)
  if not j then
    i = nil
  end
  if not x(z, a()) then
    local X, j = false, false
    local function z(V)
      pcall(editValue, "RSV_premium_status", V)
      if type(sendNotification) == "function" then
        pcall(sendNotification, V)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], V)
      end
    end
    local function s()
      if X or j then
        return
      end
      local V = a()
      if not V then
        z("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not i then
        z("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      X = true
      z("CHECKING")
      local s = pcall(runThread, function()
        local a = u
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              V .. ("&product=" .. (S .. ("&format=growlauncher&version=" .. M)))
            )
          )
        local s, b = pcall(fetch, a)
        if s and type(b) == "string" then
          local V = b:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if V and (#V <= 1024 and #V % 2 == 0) then
            b = V:gsub("..", function(V)
              return string["char"](tonumber(V, 16))
            end)
          end
        end
        if not s or type(b) ~= "string" then
          z("DENIED - REQUEST FAILED")
        elseif not x(b, V) then
          if b:match('^%s*{"status":"DENIED",') then
            local V = b:match('"reason"%s*:%s*"([A-Z_]+)"')
            if V == "INVALID_REQUEST" then
              z("DENIED - INVALID REQUEST (CHECK DEPLOYMENT)")
            elseif V == "NO_PERMANENT_ACCESS" then
              z("DENIED - CHECK RESTOCK ROW IN PAIDUSERS")
            else
              z("DENIED - NO PREMIUM ACCESS")
            end
          elseif b:match('^%s*{"status":"ERROR",') then
            z("DENIED - APPS SCRIPT SERVER ERROR")
          elseif b:match("^%s*<") then
            if b:find("doGet", 1, true) then
              z("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              z("DENIED - GOOGLE RETURNED HTML")
            end
          elseif b:match("^%s*$") then
            z("DENIED - EMPTY SERVER RESPONSE")
          elseif b:match('^%s*{"status":"APPROVED",') then
            z("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            z("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local u, S = pcall(function()
            if i:set(k, b) == false then
              return false
            end
            if i:save() == false then
              return false
            end
            if i:load() == false then
              return false
            end
            return x(i:get(k, ""), V)
          end)
          j = u and S == true
          z(j and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        X = false
      end)
      if not s then
        X = false
        z("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(V, u)
      if u == "RSV_premium_verify" then
        s()
      end
    end
    onValue = OnValue
    local b = UserInterface["new"](V, "ShoppingCart")
    b:addButton("Verify Access", "RSV_premium_verify")
    b:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "RSV_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, V, "ShoppingCart")
    end
    addIntoModule(b:generateJSON(), V)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "RSV_premium_verify", s)
    end
    return
  end
end
local u = V
local S = 600
local M = 250
local k = 5000
local function X(V, ...)
  if type(V) ~= "function" then
    return nil
  end
  local u, S = pcall(V, ...)
  if u then
    return S
  end
end
local function a(V, ...)
  if type(V) ~= "function" then
    return false
  end
  local u, S = pcall(V, ...)
  return u and S ~= false
end
local function x(V)
  return (((tostring(V or "")):upper()):gsub("%s+", ""))
end
local function j(V)
  local u, S = V:match("^([A-Z0-9]+)|([^|]+)$")
  if u then
    return u, S
  end
  if V:match("^[A-Z0-9]+$") then
    return V
  end
end
local function i(V, u)
  local S = tonumber(V)
  if S then
    return math["max"](0, math["min"](u, math["floor"](S)))
  end
end
local z, s, b, Q, G = nil, false, "", "", 50
local O, I = "", false
local q = {}
local function D(V, u)
  return V .. (":" .. (u["x"] .. (":" .. (u["y"] .. (":" .. u["id"])))))
end
local o, l = S, M
pcall(function()
  local V, u = pcall(require, "preferences")
  if not V or type(u) ~= "table" then
    u = Preferences
  end
  if type(u) ~= "table" or type(u["new"]) ~= "function" then
    return
  end
  z = u:new("AutoRestockVendSettings")
  z:load()
  O = tostring(z:get("restockItems", "") or "")
  for V in (tostring(z:get("fullVendChecks", "") or "")):gmatch("[^,]+") do
    q[V] = true
  end
  I = z:get("customRestock", O:find("%S") and "on" or "off") == "on"
  s = z:get("autoCollect", "off") == "on"
  b = tostring(z:get("collectWorld", "") or "")
  Q = x(z:get("returnDoor", ""))
  G = i(z:get("pickupDelayMs", "50"), 1000) or 50
  o = i(z:get("pathDelayMs", tostring(o)), 10000) or o
  l = i(z:get("actionDelayMs", tostring(l)), 10000) or l
end)
local function F()
  if not z then
    return
  end
  pcall(function()
    z:set("restockItems", O)
    local V = {}
    for u in pairs(q) do
      V[#V + 1] = u
    end
    z:set("fullVendChecks", table["concat"](V, ","))
    z:set("customRestock", I and "on" or "off")
    z:set("autoCollect", s and "on" or "off")
    z:set("collectWorld", b)
    z:set("returnDoor", Q)
    z:set("pickupDelayMs", tostring(G))
    z:set("pathDelayMs", tostring(o))
    z:set("actionDelayMs", tostring(l))
    z:save()
  end)
end
local U = UserInterface["new"](u, "ShoppingCart")
U:addLabelApp(u, "ShoppingCart")
U:addToggle("Start / Stop", false, "RSV_start")
U:addToggle("Auto Collect", s, "RSV_collect")
local g = U:addDialog("Auto Collect Settings", "Supply world and Door IDs", {})
U:addChildInputString(
  g["menu"],
  "Collect Worlds (in order)",
  b,
  "Comma-separated routes",
  "WORLD1, WORLD2|DOORID",
  nil,
  "RSV_world"
)
U:addChildButton(g["menu"], "Collect World = Current World", "RSV_here")
U:addChildInputString(g["menu"], "Vend Return Door ID (optional)", Q, "Door ID", "", nil, "RSV_door")
local L = (U:addDialog("Restock Settings", "Choose which assigned items to restock", {}))["menu"]
U:addChildButton(L, "Clear Saved Vend Checks", "RSV_clearchecks")
local f = {
  ["type"] = "toggle",
  ["text"] = "Custom Restock",
  ["alias"] = "RSV_custom",
  ["default"] = I,
  ["expandable"] = true,
  ["always_expand"] = false,
  ["list_child"] = {},
}
L[#L + 1] = f
U:addChildItemPicker(f["list_child"], "Add Restock Item", "Dirt", "2", "RSV_pickitem")
U:addChildInputString(f["list_child"], "Restock Item IDs", O, "IDs", "2, 4, 6", nil, "RSV_items")
U:addChildButton(f["list_child"], "Remove Last Item", "RSV_removeitem")
U:addChildButton(f["list_child"], "Clear List", "RSV_clearitems")
local t = U:addDialog("Delay Settings", "FindPath, vending and pickup delays", {})
U:addChildInputInt(t["menu"], "FindPath Delay (ms)", tostring(o), "Delay", "600", nil, "RSV_pathdelay")
U:addChildInputInt(t["menu"], "Action Delay (ms)", tostring(l), "Delay", "250", nil, "RSV_actiondelay")
U:addChildInputInt(t["menu"], "Extra Wait on Supply Tile (ms)", tostring(G), "Delay", "50", nil, "RSV_delay")
U:addDisplayList("Status", "STOPPED", "RSV_status")
X(addCategory, u, "ShoppingCart")
X(addIntoModule, U:generateJSON(), u)
local T, N, A
local n
local function R(V)
  if n == V then
    return
  end
  n = V
  X(editValue, "RSV_status", V)
end
local function v()
  A = true
  X(editToggle or EditToggle, "RSV_start", false)
  A = false
end
local function h(V)
  X(growtopia and growtopia["notify"], V)
end
local function d(V)
  return T == V
end
local function e()
  return x(X(GetWorldName or getCurrentWorldName))
end
local function r()
  local V = X(GetLocal or getLocal)
  if V and (tonumber(V["posX"]) and tonumber(V["posY"])) then
    return V, math["floor"](V["posX"] / 32), math["floor"](V["posY"] / 32)
  end
end
local function W(V)
  if not d(V) then
    return false
  end
  if V["world"] ~= e() or not r() then
    V["disconnected"] = true
    return false
  end
  return not V["disconnected"]
end
local function m(V, u)
  return X(GetTile or getTile or (tile and tile["getTile"]), V, u)
end
local function K()
  return X(GetTiles or getTiles)
end
local function J()
  local V = X(GetInventory or getInventory)
  if type(V) ~= "table" then
    return nil
  end
  local u = {}
  for V, S in pairs(V) do
    local M, k = tonumber(S["id"] or S["itemid"] or S["itemID"]), tonumber(S["amount"] or S["count"])
    if M and k then
      u[M] = k
    end
  end
  return u
end
local function B(V, u)
  local S = tonumber(X(growtopia and growtopia["checkInventoryCount"], u))
  if S and S > 0 then
    return S
  end
  return V[u] or 0
end
local function C(V)
  local u = r()
  local S = u and tonumber(u["backpackSize"] or u["backpack_slots"] or u["inventorySize"] or u["inventorySlots"])
  if not S or S < 1 then
    return true
  end
  local M = 0
  for V, u in pairs(V) do
    if u > 0 then
      M = M + 1
    end
  end
  return M < S
end
local function H(V)
  if e() ~= V or not r() then
    return false
  end
  local u = K()
  return type(u) == "table" and next(u) ~= nil
end
local function Z(V, u)
  for S = 1, 200, 1 do
    if not d(V) then
      return false
    end
    if H(u) then
      Sleep(1000)
      if d(V) and H(u) then
        return true
      end
    end
    Sleep(100)
  end
  return false
end
local function c(V)
  return a(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (V .. "\ninvitedWorld|0"))
end
local function P(V, u)
  if not d(V) then
    return false
  end
  if H(u) then
    return true
  end
  V["doorRoute"] = nil
  V["firstMove"] = true
  if e() == u and Z(V, u) then
    return true
  end
  if not d(V) then
    return false
  end
  R("WARPING TO " .. u)
  local S = a(growtopia and growtopia["warpTo"], u) or c(u)
  if S and Z(V, u) then
    return true
  end
  if not d(V) then
    return false
  end
  R("RETRYING WARP TO " .. u)
  Sleep(1500)
  if not d(V) then
    return false
  end
  if H(u) then
    return Z(V, u)
  end
  return c(u) and Z(V, u)
end
local function w(V, u)
  local S, M = j(u)
  if not S or not P(V, S) then
    return false
  end
  if M and V["doorRoute"] ~= u then
    for M = 1, 2, 1 do
      if not d(V) then
        return false
      end
      R((M == 1 and "ENTERING " or "RETRYING DOOR ") .. u)
      if c(u) then
        Sleep(1400)
        if Z(V, S) then
          V["doorRoute"] = u
          V["firstMove"] = true
          break
        end
      end
      if M == 2 or not d(V) then
        return false
      end
      Sleep(1500)
      if not P(V, S) then
        return false
      end
    end
  end
  V["world"] = S
  return W(V)
end
local function Y(V)
  local u = j(V["returnRoute"])
  V["doorRoute"], V["dialog"] = nil, nil
  V["firstMove"] = true
  for S = 0, 60000, 250 do
    if not d(V) then
      return false
    end
    if H(u) then
      Sleep(1000)
      if not d(V) then
        return false
      end
      if H(u) then
        V["disconnected"] = false
        return w(V, V["returnRoute"])
      end
    elseif S % 5000 == 0 then
      R("RECONNECTING TO VENDING WORLD " .. u)
      if not c(u) then
        a(growtopia and growtopia["warpTo"], u)
      end
    end
    if S < 60000 then
      Sleep(250)
    end
  end
  return false
end
local function y(V, u, S)
  if not W(V) then
    return false
  end
  local M, k, X = r()
  if k == u and X == S then
    return true
  end
  local a = V["firstMove"] and 2 or 1
  V["firstMove"] = false
  for M = 1, a, 1 do
    Sleep(V["pathDelay"])
    if not W(V) then
      return false
    end
    local a = pcall(FindPath or findPath, u, S)
    if a then
      local M, a, x = k, X, 0
      for j = 1, 60, 1 do
        Sleep(100)
        if not W(V) then
          return false
        end
        j, k, X = r()
        if k == u and X == S then
          return true
        end
        if k == M and X == a then
          x = x + 1
          if x >= 12 then
            break
          end
        else
          M, a, x = k, X, 0
        end
      end
    end
  end
  return false
end
local function p(V)
  if not V or (tonumber(V["fg"]) ~= 2978 and tonumber(V["fg"]) ~= 9268) or not V["extra"] then
    return
  end
  return tonumber(V["extra"]["vend_item"] or V["extra"]["vendItem"]),
    tonumber(V["extra"]["vend_price"] or V["extra"]["vendPrice"])
end
local function E(V, u)
  if V["y"] ~= u["y"] then
    return V["y"] < u["y"]
  end
  if V["x"] ~= u["x"] then
    return V["x"] < u["x"]
  end
  return (V["uid"] or 0) < (u["uid"] or 0)
end
local function Vh(V)
  local u = V and tonumber(V["fg"])
  return u == 2978 or u == 9268
end
local function uh(V)
  local u = K()
  if type(u) ~= "table" or not next(u) then
    return nil
  end
  local S = {}
  for u, M in pairs(u) do
    local k = p(M)
    local X, a = tonumber(M["x"]), tonumber(M["y"])
    if Vh(M) and (X and (a and (not k or k <= 0 or not V or V[k]))) then
      S[#S + 1] = { ["x"] = X, ["y"] = a, ["id"] = k }
    end
  end
  table["sort"](S, E)
  return S
end
local function Sh(V, u)
  for V in V:gmatch("[^\r\n]+") do
    local S = V:match("^embed_data|" .. (u .. "|([^|]+)")) or V:match("^" .. (u .. "|([^|]+)"))
    if S then
      return tonumber(S)
    end
  end
end
function onVariant(V)
  local u = T
  local S = u and u["dialog"]
  if not S or not W(u) or not V or V["v1"] ~= "OnDialogRequest" or type(V["v2"]) ~= "string" then
    return false
  end
  local M = V["v2"]
  if M:find("end_dialog|vending", 1, true) and (Sh(M, "tilex") == S["x"] and Sh(M, "tiley") == S["y"]) then
    S["text"] = M
    return true
  end
  return false
end
local function Mh(V, u)
  local S, M, k = r()
  if M == V and k == u then
    return S
  end
end
local function kh(V, u)
  local S = Mh(u["x"], u["y"])
  if not W(V) or not S then
    return nil
  end
  local M = { ["x"] = u["x"], ["y"] = u["y"] }
  V["dialog"] = M
  if
    a(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = 32, ["px"] = u["x"], ["py"] = u["y"], ["x"] = S["posX"], ["y"] = S["posY"] }
    )
  then
    for u = 1, 25, 1 do
      if M["text"] or not W(V) then
        break
      end
      Sleep(100)
    end
  end
  V["dialog"] = nil
  return M["text"]
end
local function Xh(V)
  local u = Sh(V, "expectitem")
  if u and u > 0 then
    return u
  end
  for V in V:gmatch("[^\r\n]+") do
    if V:find("The machine contains", 1, true) then
      return tonumber(V:match("|left|(%d+)|"))
    end
  end
end
local function ah(V, u)
  if not y(V, u["x"], u["y"]) then
    return nil
  end
  Sleep(V["actionDelay"])
  local S = m(u["x"], u["y"])
  local M = p(S)
  if not W(V) or not Vh(S) or (M and (M > 0 and M ~= u["id"])) then
    return nil
  end
  local k = kh(V, u)
  if not k then
    return nil
  end
  local X = Xh(k)
  if (X and X ~= u["id"]) or ((not M or M <= 0) and X ~= u["id"]) then
    return nil
  end
  local a = (k:lower()):gsub("`.", "")
  local x = a:match("contains%s+a%s+total%s+of%s+([%d,]+)") or a:match("contains%s+([%d,]+)")
  if
    not x
    and (
      a:find("contains no items", 1, true)
      or a:find("vending machine is empty", 1, true)
      or a:find("out of service", 1, true)
      or a:find("out of order", 1, true)
    )
  then
    return k, 0
  end
  return k, x and tonumber((x:gsub(",", "")))
end
local function xh(V, u)
  R("RESTOCK VEND " .. (u["x"] .. ("," .. u["y"])))
  local S = J()
  if not S then
    return "ERROR"
  end
  if B(S, u["id"]) == 0 then
    return "EMPTY"
  end
  local M, X = ah(V, u)
  if X and X >= k then
    h("Vend " .. (u["x"] .. ("," .. (u["y"] .. (" skipped: stock " .. (X .. (" / limit " .. k)))))))
    return "FULL"
  end
  if not M then
    h("Could not reach or open vend at " .. (u["x"] .. ("," .. (u["y"] .. (" for item ID " .. u["id"])))))
    return "SKIP"
  end
  if not M:find("|addstock|", 1, true) then
    h("Add Stock unavailable at vend " .. (u["x"] .. ("," .. (u["y"] .. "."))))
    return "SKIP"
  end
  Sleep(V["actionDelay"])
  local x = m(u["x"], u["y"])
  local j, i = p(x)
  if Vh(x) and (not j or j <= 0) then
    j = Xh(M)
  end
  local z = Sh(M, "expectitem")
  local s = Sh(M, "expectprice")
  local b = tonumber(M:match("add_text_input|setprice|[^|]*|(%d+)|"))
  local Q = M:match("add_checkbox|chk_perlock|[^|]*|([01])")
  local G = M:match("add_checkbox|chk_peritem|[^|]*|([01])")
  if b and (Q and (G and Q ~= G)) then
    i = Q == "1" and -b or b
  end
  if not W(V) or not Mh(u["x"], u["y"]) or j ~= u["id"] or not i or (z and z ~= j) or (s and s ~= i) then
    h("Vend position, item, or price changed at " .. (u["x"] .. ("," .. (u["y"] .. "."))))
    return "SKIP"
  end
  S = J()
  if not S then
    return "ERROR"
  end
  local O = B(S, j)
  if O == 0 then
    return "EMPTY"
  end
  R("ADDING STOCK AT " .. (u["x"] .. ("," .. (u["y"] .. (" | VEND: " .. ((X or "unknown") .. (" | BAG: " .. O)))))))
  local I = G ~= nil and (Q ~= nil and G ~= Q)
  if I then
    I = G == "1"
  else
    I = i >= 0
  end
  V["pendingTransfer"] = { ["id"] = j, ["before"] = O }
  if
    not a(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|vending\ntilex|"
        .. (
          u["x"]
          .. (
            "|\ntiley|"
            .. (
              u["y"]
              .. (
                "|\nbuttonClicked|addstock\n\nsetprice|"
                .. (
                  math["abs"](i) .. (
                    "\nchk_peritem|" .. ((I and "1" or "0") .. ("\nchk_perlock|" .. (I and "0" or "1")))
                  )
                )
              )
            )
          )
        )
    )
  then
    if not W(V) then
      return "ERROR"
    end
    V["pendingTransfer"] = nil
    return "SKIP"
  end
  for u = 1, 35, 1 do
    Sleep(100)
    if not W(V) then
      return "ERROR"
    end
    S = J()
    if S and B(S, j) < O then
      Sleep(350)
      if not W(V) then
        return "ERROR"
      end
      S = J()
      if not S then
        return "ERROR"
      end
      local u = B(S, j)
      if u < O then
        local S = O - u
        V["moved"] = V["moved"] + S
        V["pendingTransfer"] = nil
        if X and X + S >= k then
          return "FULL"
        end
        return u == 0 and "ADDED" or "PARTIAL"
      end
    end
  end
  if not W(V) or not J() then
    return "ERROR"
  end
  V["pendingTransfer"] = nil
  h("No stock transfer confirmed at vend " .. (u["x"] .. ("," .. (u["y"] .. "."))))
  return "REJECTED"
end
local function jh(V, u, S)
  if B(u, S["id"]) <= 0 then
    return nil
  end
  local M, k
  for V, u in ipairs(V) do
    if not u["unavailable"] and (not u["tried"] and u["id"] == S["id"]) then
      local V = math["abs"](u["x"] - S["x"]) + math["abs"](u["y"] - S["y"])
      if not k or V < k then
        M, k = u, V
      end
    end
  end
  return M
end
local function ih(V, u)
  for V, u in ipairs(u) do
    u["tried"] = false
  end
  for S, M in ipairs(u) do
    local k = M
    while k and (not k["unavailable"] and not k["tried"]) do
      if not W(V) then
        return false
      end
      local S = J()
      if not S then
        return false
      end
      if B(S, k["id"]) == 0 then
        break
      end
      k["tried"] = true
      local M = xh(V, k)
      if M == "SKIP" and W(V) then
        Sleep(500)
        if not W(V) then
          return false
        end
        M = xh(V, k)
      end
      if M == "ERROR" then
        return false
      end
      if M == "FULL" or M == "SKIP" or M == "PARTIAL" or M == "REJECTED" then
        k["unavailable"] = true
        k["atStockLimit"] = M == "FULL"
        if k["atStockLimit"] then
          q[D(V["world"], k)] = true
          F()
        end
        S = J()
        if not S then
          return false
        end
        k = jh(u, S, k)
      else
        break
      end
    end
  end
  return W(V)
end
local function zh(V)
  local u = X(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(u) ~= "table" then
    return nil
  end
  local S = {}
  for u, M in pairs(u) do
    local k, X = tonumber(M["itemid"]), tonumber(M["id"])
    local a = tonumber(M["posX"] or (M["pos"] and M["pos"]["x"]))
    local x = tonumber(M["posY"] or (M["pos"] and M["pos"]["y"]))
    if k and (V[k] and (X and (a and x))) then
      local V, u = math["floor"](a / 32), math["floor"](x / 32)
      local M = a - V * 32 >= 24 and (m(V + 1, u) and V + 1) or nil
      S[#S + 1] = { ["id"] = k, ["uid"] = X, ["x"] = V, ["y"] = u, ["rightX"] = M, ["ox"] = a, ["oy"] = x }
    end
  end
  table["sort"](S, E)
  return S
end
local function sh(V)
  local u = X(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(u) ~= "table" then
    return false
  end
  for u, S in pairs(u) do
    if tonumber(S["id"]) == V["uid"] and tonumber(S["itemid"]) == V["id"] then
      return true
    end
  end
  return false
end
local function bh(V, u)
  local S = V[u] or 0
  return S < 200 and (S > 0 or C(V))
end
local function Qh(V, u, S, M, k)
  local X = zh(u)
  if not X then
    return
  end
  for u, X in ipairs(X) do
    local x = r()
    if not W(V) or not x then
      return
    end
    if math["floor"](x["posX"] / 32) ~= S or math["floor"](x["posY"] / 32) ~= M then
      return
    end
    if X["y"] == M and ((X["x"] == S or X["x"] == S + 1) and not k[X["uid"]]) then
      local V = J()
      if not V then
        return
      end
      if bh(V, X["id"]) then
        k[X["uid"]] = a(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 11, ["value"] = X["uid"], ["x"] = X["ox"], ["y"] = X["oy"] }
        )
      end
    end
  end
end
local function Gh(V, u)
  local S = J()
  if not S then
    return nil
  end
  local M = 0
  while W(V) do
    local k = J()
    if not k then
      return nil
    end
    local X, a = {}, {}
    local x = zh(u)
    if not x then
      return nil
    end
    local j = false
    for S, M in ipairs(x) do
      if not W(V) then
        return nil
      end
      if sh(M) then
        local S = { M["x"], M["rightX"] }
        for S, k in ipairs(S) do
          if not W(V) then
            return nil
          end
          if not sh(M) then
            break
          end
          local x = k .. ("," .. M["y"])
          if not X[x] then
            local S = J()
            if not S then
              return nil
            end
            if not bh(S, M["id"]) then
              break
            end
            j = true
            X[x] = true
            if y(V, k, M["y"]) then
              if k == M["x"] then
                Qh(V, u, k, M["y"], a)
              end
              Sleep(900 + V["pickupDelay"])
            end
          end
        end
      end
    end
    if not W(V) then
      return nil
    end
    local i = J()
    local z = zh(u)
    if not i or not z then
      return nil
    end
    local s, b, Q = false, false, false
    for V in pairs(u) do
      local u = i[V] or 0
      if u > (S[V] or 0) then
        s = true
      end
      if u > (k[V] or 0) then
        b = true
      end
    end
    for V, u in ipairs(z) do
      if bh(i, u["id"]) then
        Q = true
        break
      end
    end
    if not Q or not j then
      return s, #z > 0
    end
    M = b and 0 or M + 1
    if M >= 2 then
      return s, #z > 0
    end
    if not b then
      Sleep(500)
    end
  end
end
local function Oh(V)
  local u = X(getValue, 0, "ModFly")
  if u == true or u == 1 then
    return true
  end
  if not a(editToggle or EditToggle, "ModFly", true) then
    return false
  end
  V["restoreFly"] = true
  return true
end
local function Ih(V)
  if V["restoreFly"] then
    V["restoreFly"] = nil
    a(editToggle or EditToggle, "ModFly", false)
  end
end
local function qh(V)
  local u = uh(V["itemFilter"])
  if not u then
    return "Could not scan the vending world."
  end
  if #u == 0 then
    return "No assigned vending machines match the restock settings."
  end
  for S = #u, 1, -1 do
    local M = u[S]
    if not M["id"] or M["id"] <= 0 then
      local k
      if y(V, M["x"], M["y"]) then
        Sleep(V["actionDelay"])
        if Vh(m(M["x"], M["y"])) then
          k = kh(V, M)
        end
      end
      if not W(V) then
        return "Interrupted while checking vending assignments."
      end
      local X = k and Xh(k)
      if X and (X > 0 and (not V["itemFilter"] or V["itemFilter"][X])) then
        M["id"] = X
      else
        table["remove"](u, S)
      end
    end
  end
  if #u == 0 then
    return "No matching vending assignments could be verified."
  end
  for S = #u, 1, -1 do
    if q[D(V["world"], u[S])] then
      table["remove"](u, S)
    end
  end
  if #u == 0 then
    return "All matching vends are saved as full. Clear Saved Vend Checks to recheck."
  end
  local S = J()
  if not S then
    return "Could not read backpack inventory."
  end
  local M = 0
  for V, u in ipairs(u) do
    if B(S, u["id"]) > 0 then
      M = M + 1
    end
  end
  if M == 0 and not V["collect"] then
    return "No backpack match for " .. (#u .. " assigned vend(s). Enable Auto Collect to fetch stock.")
  end
  while W(V) do
    local S = V["collectRoutes"][V["collectIndex"]]
    if not S then
      if not ih(V, u) then
        return "Stopped during restocking. Check your world and inventory."
      end
      break
    end
    local M = J()
    if not M then
      return "Could not read backpack inventory."
    end
    local k, X = {}, false
    for V, u in ipairs(u) do
      if not u["unavailable"] then
        k[u["id"]] = true
        if bh(M, u["id"]) then
          X = true
        end
      end
    end
    if not next(k) then
      break
    end
    local a, x = true, false
    if X then
      R("COLLECT WORLD " .. (V["collectIndex"] .. ("/" .. (#V["collectRoutes"] .. (" " .. S)))))
      if not w(V, S) then
        return "Could not enter collect route " .. (S .. ".")
      end
      local u = Oh(V)
      if u then
        x, a = Gh(V, k)
      end
      Ih(V)
      if not d(V) then
        return "STOPPED"
      end
      if not w(V, V["returnRoute"]) then
        return "Could not return to the vending world."
      end
      if not u then
        return "Could not enable ModFly for Auto Collect."
      end
      if x == nil then
        return "Could not read supply world or inventory."
      end
    end
    local j = V["moved"]
    if not ih(V, u) then
      return "Stopped during restocking. Check your world and inventory."
    end
    if not a then
      V["collectIndex"] = V["collectIndex"] + 1
    elseif not x and V["moved"] == j then
      return "Collection stalled in " .. (
          S .. (". Check the supply path or backpack. Added " .. (V["moved"] .. " items."))
        )
    end
  end
  local k = 0
  for V, u in ipairs(u) do
    if u["unavailable"] then
      k = k + 1
    end
  end
  if k > 0 then
    return "Done. Added " .. (V["moved"] .. (" items. Could not fill or already full: " .. (k .. " vend(s).")))
  end
  if V["moved"] == 0 and M == 0 then
    return "Scanned " .. (#u .. " assigned vend(s). No matching stock found in backpack or Collect World.")
  end
  return "Done. Added " .. (V["moved"] .. " items. No more matching stock.")
end
local function Dh(V)
  V = tostring(V or "")
  V = V:gsub("\n", "\r\n")
  V = V:gsub("([^%w%-_%.~])", function(V)
    return string["format"]("%%%02X", string["byte"](V))
  end)
  return V
end
local function oh(V)
  T, N = V, true
  R("SCANNING VENDING WORLD")
  runThread(function()
    local u, S
    while d(V) do
      u, S = pcall(qh, V)
      Ih(V)
      if not d(V) then
        break
      end
      local M = e()
      if not V["disconnected"] and (r() and (M ~= "" and (M ~= "EXIT" and M ~= "EXITWORLD"))) then
        break
      end
      R("CONNECTION LOST - RETURNING TO VENDING WORLD")
      if not Y(V) then
        u, S = true, "Could not reconnect to the original vending world."
        break
      end
      if V["pendingTransfer"] then
        local M = V["pendingTransfer"]
        local k = J()
        if not k then
          u, S = true, "Could not read inventory after reconnecting."
          break
        end
        V["moved"] = V["moved"] + math["max"](0, M["before"] - B(k, M["id"]))
        V["pendingTransfer"] = nil
      end
      R("RECONNECTED - RESCANNING VENDS")
    end
    Ih(V)
    N = false
    if not d(V) then
      return
    end
    T = nil
    v()
    local M = u and S or ("Restock stopped: " .. tostring(S))
    R(M)
    h(M)
  end)
end
function onValue(V, u, S)
  if u == "RSV_clearchecks" then
    if N then
      h("Stop restocking before clearing saved vend checks.")
      return
    end
    q = {}
    F()
    h("Saved vend checks cleared. The next run will recheck matching vends.")
    return
  end
  if u == "RSV_custom" then
    I = S == true or S == 1 or S == "true" or S == "1"
    F()
    return
  end
  if u == "RSV_pickitem" or u == "RSV_removeitem" or u == "RSV_clearitems" then
    local V = {}
    for u in O:gmatch("[^,%s]+") do
      V[#V + 1] = u
    end
    if u == "RSV_pickitem" then
      if type(S) == "table" then
        S = S["id"] or S["itemID"] or S["itemid"] or S["value"] or S["name"]
      end
      local u = tonumber(S)
      if not u and type(S) == "string" then
        u = tonumber(S:match("%((%d+)%)")) or tonumber(X(findItemID or (growtopia and growtopia["getItemID"]), S))
      end
      if not u or u < 1 or u > 65535 or u % 1 ~= 0 then
        return
      end
      for V, S in ipairs(V) do
        if tonumber(S) == u then
          return
        end
      end
      V[#V + 1] = tostring(u)
    elseif u == "RSV_removeitem" then
      if #V > 0 then
        table["remove"](V)
      end
    else
      V = {}
    end
    O = table["concat"](V, ", ")
    F()
    X(editValue, "RSV_items", O)
    return
  end
  if u == "RSV_items" then
    O = tostring(S or "")
    F()
    return
  end
  if u == "RSV_collect" then
    s = S == true
    F()
    return
  end
  if u == "RSV_here" then
    local V = j(e())
    if not V or V == "EXIT" or not r() then
      h("Enter the collect world first.")
      return
    end
    b = V
    F()
    X(editValue, "RSV_world", b)
    return
  end
  if u == "RSV_world" then
    local V = tostring(S or "")
    if V ~= b then
      b = V
      F()
    end
    return
  end
  if u == "RSV_door" then
    local V = x(S)
    if V ~= Q then
      Q = V
      F()
    end
    return
  end
  if u == "RSV_pathdelay" then
    local V = i(S, 10000)
    if V and V ~= o then
      o = V
      F()
    end
    return
  end
  if u == "RSV_actiondelay" then
    local V = i(S, 10000)
    if V and V ~= l then
      l = V
      F()
    end
    return
  end
  if u == "RSV_delay" then
    local V = i(S, 1000)
    if V and V ~= G then
      G = V
      F()
    end
    return
  end
  if u ~= "RSV_start" or A then
    return
  end
  if S ~= true then
    local V = T
    T = nil
    if V then
      Ih(V)
    end
    R("STOPPED")
    return
  end
  if T then
    return
  end
  if N then
    v()
    h("Wait for the previous run to stop.")
    return
  end
  local M = e()
  if M == "" or M == "EXIT" or not r() then
    v()
    h("Enter your vending world before pressing Start.")
    return
  end
  local k, a = {}, {}
  if s then
    for V in b:gmatch("[^,;\r\n]+") do
      local u = x(V)
      if u ~= "" then
        local V = j(u)
        if not V or V == "EXIT" or V == "EXITWORLD" then
          v()
          h("Invalid Collect World route " .. (u .. "."))
          return
        end
        if not a[u] then
          k[#k + 1], a[u] = u, true
        end
      end
    end
    if #k == 0 or Q:find("|", 1, true) then
      v()
      h("Check Collect Worlds and the optional Vend Return Door ID.")
      return
    end
  end
  local z
  for V in ((I and O or "")):gmatch("[^,%s]+") do
    local u = tonumber(V)
    if not V:match("^%d+$") or not u or u < 1 or u > 65535 then
      v()
      h("Enter valid Restock Item IDs.")
      return
    end
    z = z or {}
    z[u] = true
  end
  if I and not z then
    v()
    h("Add at least one item in Restock Settings.")
    return
  end
  local D = {
    ["itemFilter"] = z,
    ["world"] = M,
    ["collect"] = s,
    ["collectRoutes"] = k,
    ["collectIndex"] = 1,
    ["pickupDelay"] = G,
    ["pathDelay"] = o,
    ["actionDelay"] = l,
    ["returnRoute"] = Q == "" and M or (M .. ("|" .. Q)),
    ["moved"] = 0,
  }
  oh(D)
end
applyHook()
if type(setOnValue) == "function" then
  for V, u in ipairs({ "RSV_pickitem", "RSV_items", "RSV_world", "RSV_door", "RSV_pathdelay", "RSV_actiondelay", "RSV_delay" }) do
    local S = u
    pcall(setOnValue, S, function(...)
      local V = select("#", ...)
      if V > 0 then
        onValue(nil, S, select(V, ...))
      end
    end)
  end
end
