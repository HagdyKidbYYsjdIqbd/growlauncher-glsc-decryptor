setMinimum("6.1.2")
local R = "Premium Auto Restock Vend by Bangshu"
do
  local Z =
    "https://script.google.com/macros/s/AKfycbxWY0ROC3V1HOTJuRPfovwsN8CfTkXrcFF6VvhlS0EQRfWleUWVHZNUSW1M2UcVesSC/exec"
  local F = "RESTOCK"
  local E = "RESTOCK-1-PAID-001"
  local H = "approval"
  local d = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
  local function I()
    local R, Z = pcall(function()
      if type(getDiscordID) == "function" then
        return getDiscordID()
      end
      return getDiscordID
    end)
    if not R then
      return nil
    end
    if type(Z) == "number" and (math["type"] and math["type"](Z) == "integer") then
      Z = tostring(Z)
    end
    if type(Z) ~= "string" or #Z < 17 or #Z > 20 or not Z:match("^%d+$") then
      return nil
    end
    if Z:match("^0+$") then
      return nil
    end
    return Z
  end
  local function Q(R, Z)
    if not Z or type(R) ~= "string" or #R > 512 then
      return false
    end
    local H, I, Q = R:match(
      '^%s*{"status":"APPROVED","approval":{"discordId":"(%d+)","product":"([A-Z]+)","version":"([%w._-]+)","receiptId":"'
        .. (d .. '"}}%s*$')
    )
    return H == Z and (I == F and Q == E)
  end
  local G, W, a = pcall(function()
    local R, Z = pcall(require, "preferences")
    local F = R and (type(Z) == "table" and Z) or Preferences
    if type(F) ~= "table" or type(F["new"]) ~= "function" then
      return nil
    end
    local E = F:new("BangshuPremiumAutoRestockVend")
    if E:load() == false then
      return E
    end
    return E, E:get(H, "")
  end)
  if not G then
    W = nil
  end
  if not Q(a, I()) then
    local d, G = false, false
    local function a(R)
      pcall(editValue, "RSV_premium_status", R)
      if type(sendNotification) == "function" then
        pcall(sendNotification, R)
      elseif growtopia and type(growtopia["notify"]) == "function" then
        pcall(growtopia["notify"], R)
      end
    end
    local function p()
      if d or G then
        return
      end
      local R = I()
      if not R then
        a("DENIED - DISCORD ID UNAVAILABLE")
        return
      end
      if not W then
        a("DENIED - PREFERENCES UNAVAILABLE")
        return
      end
      d = true
      a("CHECKING")
      local p = pcall(runThread, function()
        local I = Z
          .. (
            "?action=verifyPaidAccess&discordId=" .. (
              R .. ("&product=" .. (F .. ("&format=growlauncher&version=" .. E)))
            )
          )
        local p, x = pcall(fetch, I)
        if p and type(x) == "string" then
          local R = x:match("BANGSHU_PREMIUM_V1_BEGIN_([0-9a-f]+)_BANGSHU_PREMIUM_V1_END")
          if R and (#R <= 1024 and #R % 2 == 0) then
            x = R:gsub("..", function(R)
              return string["char"](tonumber(R, 16))
            end)
          end
        end
        if not p or type(x) ~= "string" then
          a("DENIED - REQUEST FAILED")
        elseif not Q(x, R) then
          if x:match('^%s*{"status":"DENIED",') then
            local R = x:match('"reason"%s*:%s*"([A-Z_]+)"')
            if R == "INVALID_REQUEST" then
              a("DENIED - INVALID REQUEST (CHECK DEPLOYMENT)")
            elseif R == "NO_PERMANENT_ACCESS" then
              a("DENIED - CHECK RESTOCK ROW IN PAIDUSERS")
            else
              a("DENIED - NO PREMIUM ACCESS")
            end
          elseif x:match('^%s*{"status":"ERROR",') then
            a("DENIED - APPS SCRIPT SERVER ERROR")
          elseif x:match("^%s*<") then
            if x:find("doGet", 1, true) then
              a("DENIED - DEPLOYED APP MISSING GET HANDLER")
            else
              a("DENIED - GOOGLE RETURNED HTML")
            end
          elseif x:match("^%s*$") then
            a("DENIED - EMPTY SERVER RESPONSE")
          elseif x:match('^%s*{"status":"APPROVED",') then
            a("DENIED - APPROVAL DETAILS DO NOT MATCH")
          else
            a("DENIED - UNEXPECTED SERVER RESPONSE")
          end
        else
          local Z, F = pcall(function()
            if W:set(H, x) == false then
              return false
            end
            if W:save() == false then
              return false
            end
            if W:load() == false then
              return false
            end
            return Q(W:get(H, ""), R)
          end)
          G = Z and F == true
          a(G and "APPROVED - RELOAD SCRIPT" or "DENIED - COULD NOT SAVE APPROVAL")
        end
        d = false
      end)
      if not p then
        d = false
        a("DENIED - COULD NOT START CHECK")
      end
    end
    function OnValue(R, Z)
      if Z == "RSV_premium_verify" then
        p()
      end
    end
    onValue = OnValue
    local x = UserInterface["new"](R, "ShoppingCart")
    x:addButton("Verify Access", "RSV_premium_verify")
    x:addInputString("Verification Status", "NOT VERIFIED", "", "", nil, "RSV_premium_status")
    if type(addCategory) == "function" then
      pcall(addCategory, R, "ShoppingCart")
    end
    addIntoModule(x:generateJSON(), R)
    if type(applyHook) == "function" then
      pcall(applyHook)
    end
    if type(setOnValue) == "function" then
      pcall(setOnValue, "RSV_premium_verify", p)
    end
    return
  end
end
local Z = R
local F = 600
local E = 250
local H = 5000
local function d(R, ...)
  if type(R) ~= "function" then
    return nil
  end
  local Z, F = pcall(R, ...)
  if Z then
    return F
  end
end
local function I(R, ...)
  if type(R) ~= "function" then
    return false
  end
  local Z, F = pcall(R, ...)
  return Z and F ~= false
end
local function Q(R)
  return (((tostring(R or "")):upper()):gsub("%s+", ""))
end
local function G(R)
  local Z, F = R:match("^([A-Z0-9]+)|([^|]+)$")
  if Z then
    return Z, F
  end
  if R:match("^[A-Z0-9]+$") then
    return R
  end
end
local function W(R, Z)
  local F = tonumber(R)
  if F then
    return math["max"](0, math["min"](Z, math["floor"](F)))
  end
end
local a, p, x, K, S = nil, false, "", "", 50
local J, u = "", false
local t = {}
local function T(R, Z)
  return R .. (":" .. (Z["x"] .. (":" .. (Z["y"] .. (":" .. Z["id"])))))
end
local L, m = F, E
pcall(function()
  local R, Z = pcall(require, "preferences")
  if not R or type(Z) ~= "table" then
    Z = Preferences
  end
  if type(Z) ~= "table" or type(Z["new"]) ~= "function" then
    return
  end
  a = Z:new("AutoRestockVendSettings")
  a:load()
  J = tostring(a:get("restockItems", "") or "")
  for R in (tostring(a:get("fullVendChecks", "") or "")):gmatch("[^,]+") do
    t[R] = true
  end
  u = a:get("customRestock", J:find("%S") and "on" or "off") == "on"
  p = a:get("autoCollect", "off") == "on"
  x = tostring(a:get("collectWorld", "") or "")
  K = Q(a:get("returnDoor", ""))
  S = W(a:get("pickupDelayMs", "50"), 1000) or 50
  L = W(a:get("pathDelayMs", tostring(L)), 10000) or L
  m = W(a:get("actionDelayMs", tostring(m)), 10000) or m
end)
local function w()
  if not a then
    return
  end
  pcall(function()
    a:set("restockItems", J)
    local R = {}
    for Z in pairs(t) do
      R[#R + 1] = Z
    end
    a:set("fullVendChecks", table["concat"](R, ","))
    a:set("customRestock", u and "on" or "off")
    a:set("autoCollect", p and "on" or "off")
    a:set("collectWorld", x)
    a:set("returnDoor", K)
    a:set("pickupDelayMs", tostring(S))
    a:set("pathDelayMs", tostring(L))
    a:set("actionDelayMs", tostring(m))
    a:save()
  end)
end
local y = UserInterface["new"](Z, "ShoppingCart")
y:addLabelApp(Z, "ShoppingCart")
y:addToggle("Start / Stop", false, "RSV_start")
y:addToggle("Auto Collect", p, "RSV_collect")
local c = y:addDialog("Auto Collect Settings", "Supply world and Door IDs", {})
y:addChildInputString(
  c["menu"],
  "Collect Worlds (in order)",
  x,
  "Comma-separated routes",
  "WORLD1, WORLD2|DOORID",
  nil,
  "RSV_world"
)
y:addChildButton(c["menu"], "Collect World = Current World", "RSV_here")
y:addChildInputString(c["menu"], "Vend Return Door ID (optional)", K, "Door ID", "", nil, "RSV_door")
local P = (y:addDialog("Restock Settings", "Choose which assigned items to restock", {}))["menu"]
y:addChildButton(P, "Clear Saved Vend Checks", "RSV_clearchecks")
local B = {
  ["type"] = "toggle",
  ["text"] = "Custom Restock",
  ["alias"] = "RSV_custom",
  ["default"] = u,
  ["expandable"] = true,
  ["always_expand"] = false,
  ["list_child"] = {},
}
P[#P + 1] = B
y:addChildItemPicker(B["list_child"], "Add Restock Item", "Dirt", "2", "RSV_pickitem")
y:addChildInputString(B["list_child"], "Restock Item IDs", J, "IDs", "2, 4, 6", nil, "RSV_items")
y:addChildButton(B["list_child"], "Remove Last Item", "RSV_removeitem")
y:addChildButton(B["list_child"], "Clear List", "RSV_clearitems")
local V = y:addDialog("Delay Settings", "FindPath, vending and pickup delays", {})
y:addChildInputInt(V["menu"], "FindPath Delay (ms)", tostring(L), "Delay", "600", nil, "RSV_pathdelay")
y:addChildInputInt(V["menu"], "Action Delay (ms)", tostring(m), "Delay", "250", nil, "RSV_actiondelay")
y:addChildInputInt(V["menu"], "Extra Wait on Supply Tile (ms)", tostring(S), "Delay", "50", nil, "RSV_delay")
y:addDisplayList("Status", "STOPPED", "RSV_status")
d(addCategory, Z, "ShoppingCart")
d(addIntoModule, y:generateJSON(), Z)
local N, A, l
local h
local function z(R)
  if h == R then
    return
  end
  h = R
  d(editValue, "RSV_status", R)
end
local function s()
  l = true
  d(editToggle or EditToggle, "RSV_start", false)
  l = false
end
local function g(R)
  d(growtopia and growtopia["notify"], R)
end
local function C(R)
  return N == R
end
local function M()
  return Q(d(GetWorldName or getCurrentWorldName))
end
local function n()
  local R = d(GetLocal or getLocal)
  if R and (tonumber(R["posX"]) and tonumber(R["posY"])) then
    return R, math["floor"](R["posX"] / 32), math["floor"](R["posY"] / 32)
  end
end
local function q(R)
  if not C(R) then
    return false
  end
  if R["world"] ~= M() or not n() then
    R["disconnected"] = true
    return false
  end
  return not R["disconnected"]
end
local function Y(R, Z)
  return d(GetTile or getTile or (tile and tile["getTile"]), R, Z)
end
local function f()
  return d(GetTiles or getTiles)
end
local function U()
  local R = d(GetInventory or getInventory)
  if type(R) ~= "table" then
    return nil
  end
  local Z = {}
  for R, F in pairs(R) do
    local E, H = tonumber(F["id"] or F["itemid"] or F["itemID"]), tonumber(F["amount"] or F["count"])
    if E and H then
      Z[E] = H
    end
  end
  return Z
end
local function j(R, Z)
  local F = tonumber(d(growtopia and growtopia["checkInventoryCount"], Z))
  if F and F > 0 then
    return F
  end
  return R[Z] or 0
end
local function o(R)
  local Z = n()
  local F = Z and tonumber(Z["backpackSize"] or Z["backpack_slots"] or Z["inventorySize"] or Z["inventorySlots"])
  if not F or F < 1 then
    return true
  end
  local E = 0
  for R, Z in pairs(R) do
    if Z > 0 then
      E = E + 1
    end
  end
  return E < F
end
local function O(R)
  if M() ~= R or not n() then
    return false
  end
  local Z = f()
  return type(Z) == "table" and next(Z) ~= nil
end
local function b(R, Z)
  for F = 1, 200, 1 do
    if not C(R) then
      return false
    end
    if O(Z) then
      Sleep(1000)
      if C(R) and O(Z) then
        return true
      end
    end
    Sleep(100)
  end
  return false
end
local function i(R)
  return I(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (R .. "\ninvitedWorld|0"))
end
local function v(R, Z)
  if not C(R) then
    return false
  end
  if O(Z) then
    return true
  end
  R["doorRoute"] = nil
  R["firstMove"] = true
  if M() == Z and b(R, Z) then
    return true
  end
  if not C(R) then
    return false
  end
  z("WARPING TO " .. Z)
  local F = I(growtopia and growtopia["warpTo"], Z) or i(Z)
  if F and b(R, Z) then
    return true
  end
  if not C(R) then
    return false
  end
  z("RETRYING WARP TO " .. Z)
  Sleep(1500)
  if not C(R) then
    return false
  end
  if O(Z) then
    return b(R, Z)
  end
  return i(Z) and b(R, Z)
end
local function X(R, Z)
  local F, E = G(Z)
  if not F or not v(R, F) then
    return false
  end
  if E and R["doorRoute"] ~= Z then
    for E = 1, 2, 1 do
      if not C(R) then
        return false
      end
      z((E == 1 and "ENTERING " or "RETRYING DOOR ") .. Z)
      if i(Z) then
        Sleep(1400)
        if b(R, F) then
          R["doorRoute"] = Z
          R["firstMove"] = true
          break
        end
      end
      if E == 2 or not C(R) then
        return false
      end
      Sleep(1500)
      if not v(R, F) then
        return false
      end
    end
  end
  R["world"] = F
  R["disconnected"] = false
  return q(R)
end
local function e(R, Z)
  if not G(Z) then
    return false
  end
  while C(R) do
    local F = M()
    if R["disconnected"] or F == "" or F == "EXIT" or F == "EXITWORLD" or not n() then
      R["doorRoute"], R["dialog"] = nil, nil
    end
    if X(R, Z) then
      return true
    end
    if not C(R) then
      return false
    end
    R["doorRoute"], R["dialog"] = nil, nil
    z("WAITING TO RECONNECT - " .. Z)
    for Z = 1, 50, 1 do
      if not C(R) then
        return false
      end
      Sleep(100)
    end
  end
  return false
end
local function r(R)
  R["doorRoute"], R["dialog"] = nil, nil
  R["firstMove"] = true
  return e(R, R["returnRoute"])
end
local function k(R, Z, F)
  if not q(R) then
    return false
  end
  local E, H, d = n()
  if H == Z and d == F then
    return true
  end
  local I = R["firstMove"] and 2 or 1
  R["firstMove"] = false
  for E = 1, I, 1 do
    Sleep(R["pathDelay"])
    if not q(R) then
      return false
    end
    local I = pcall(FindPath or findPath, Z, F)
    if I then
      local E, I, Q = H, d, 0
      for G = 1, 60, 1 do
        Sleep(100)
        if not q(R) then
          return false
        end
        G, H, d = n()
        if H == Z and d == F then
          return true
        end
        if H == E and d == I then
          Q = Q + 1
          if Q >= 12 then
            break
          end
        else
          E, I, Q = H, d, 0
        end
      end
    end
  end
  return false
end
local function D(R)
  if not R or (tonumber(R["fg"]) ~= 2978 and tonumber(R["fg"]) ~= 9268) or not R["extra"] then
    return
  end
  return tonumber(R["extra"]["vend_item"] or R["extra"]["vendItem"]),
    tonumber(R["extra"]["vend_price"] or R["extra"]["vendPrice"])
end
local function RM(R, Z)
  if R["y"] ~= Z["y"] then
    return R["y"] < Z["y"]
  end
  if R["x"] ~= Z["x"] then
    return R["x"] < Z["x"]
  end
  return (R["uid"] or 0) < (Z["uid"] or 0)
end
local function ZM(R)
  local Z = R and tonumber(R["fg"])
  return Z == 2978 or Z == 9268
end
local function FM(R)
  local Z = f()
  if type(Z) ~= "table" or not next(Z) then
    return nil
  end
  local F = {}
  for Z, E in pairs(Z) do
    local H = D(E)
    local d, I = tonumber(E["x"]), tonumber(E["y"])
    if ZM(E) and (d and (I and (not H or H <= 0 or not R or R[H]))) then
      F[#F + 1] = { ["x"] = d, ["y"] = I, ["id"] = H }
    end
  end
  table["sort"](F, RM)
  return F
end
local function EM(R, Z)
  for R in R:gmatch("[^\r\n]+") do
    local F = R:match("^embed_data|" .. (Z .. "|([^|]+)")) or R:match("^" .. (Z .. "|([^|]+)"))
    if F then
      return tonumber(F)
    end
  end
end
function onVariant(R)
  local Z = N
  local F = Z and Z["dialog"]
  if not F or not q(Z) or not R or R["v1"] ~= "OnDialogRequest" or type(R["v2"]) ~= "string" then
    return false
  end
  local E = R["v2"]
  if E:find("end_dialog|vending", 1, true) and (EM(E, "tilex") == F["x"] and EM(E, "tiley") == F["y"]) then
    F["text"] = E
    return true
  end
  return false
end
local function HM(R, Z)
  local F, E, H = n()
  if E == R and H == Z then
    return F
  end
end
local function dM(R, Z)
  local F = HM(Z["x"], Z["y"])
  if not q(R) or not F then
    return nil
  end
  local E = { ["x"] = Z["x"], ["y"] = Z["y"] }
  R["dialog"] = E
  if
    I(
      SendPacketRaw or sendPacketRaw,
      false,
      { ["type"] = 3, ["value"] = 32, ["px"] = Z["x"], ["py"] = Z["y"], ["x"] = F["posX"], ["y"] = F["posY"] }
    )
  then
    for Z = 1, 25, 1 do
      if E["text"] or not q(R) then
        break
      end
      Sleep(100)
    end
  end
  R["dialog"] = nil
  return E["text"]
end
local function IM(R)
  local Z = EM(R, "expectitem")
  if Z and Z > 0 then
    return Z
  end
  for R in R:gmatch("[^\r\n]+") do
    if R:find("The machine contains", 1, true) then
      return tonumber(R:match("|left|(%d+)|"))
    end
  end
end
local function QM(R, Z)
  if not k(R, Z["x"], Z["y"]) then
    return nil
  end
  Sleep(R["actionDelay"])
  local F = Y(Z["x"], Z["y"])
  local E = D(F)
  if not q(R) or not ZM(F) or (E and (E > 0 and E ~= Z["id"])) then
    return nil
  end
  local H = dM(R, Z)
  if not H then
    return nil
  end
  local d = IM(H)
  if (d and d ~= Z["id"]) or ((not E or E <= 0) and d ~= Z["id"]) then
    return nil
  end
  local I = (H:lower()):gsub("`.", "")
  local Q = I:match("contains%s+a%s+total%s+of%s+([%d,]+)") or I:match("contains%s+([%d,]+)")
  if
    not Q
    and (
      I:find("contains no items", 1, true)
      or I:find("vending machine is empty", 1, true)
      or I:find("out of service", 1, true)
      or I:find("out of order", 1, true)
    )
  then
    return H, 0
  end
  return H, Q and tonumber((Q:gsub(",", "")))
end
local function GM(R, Z)
  z("RESTOCK VEND " .. (Z["x"] .. ("," .. Z["y"])))
  local F = U()
  if not F then
    return "ERROR"
  end
  if j(F, Z["id"]) == 0 then
    return "EMPTY"
  end
  local E, d = QM(R, Z)
  if d and d >= H then
    g("Vend " .. (Z["x"] .. ("," .. (Z["y"] .. (" skipped: stock " .. (d .. (" / limit " .. H)))))))
    return "FULL"
  end
  if not E then
    g("Could not reach or open vend at " .. (Z["x"] .. ("," .. (Z["y"] .. (" for item ID " .. Z["id"])))))
    return "SKIP"
  end
  if not E:find("|addstock|", 1, true) then
    g("Add Stock unavailable at vend " .. (Z["x"] .. ("," .. (Z["y"] .. "."))))
    return "SKIP"
  end
  Sleep(R["actionDelay"])
  local Q = Y(Z["x"], Z["y"])
  local G, W = D(Q)
  if ZM(Q) and (not G or G <= 0) then
    G = IM(E)
  end
  local a = EM(E, "expectitem")
  local p = EM(E, "expectprice")
  local x = tonumber(E:match("add_text_input|setprice|[^|]*|(%d+)|"))
  local K = E:match("add_checkbox|chk_perlock|[^|]*|([01])")
  local S = E:match("add_checkbox|chk_peritem|[^|]*|([01])")
  if x and (K and (S and K ~= S)) then
    W = K == "1" and -x or x
  end
  if not q(R) or not HM(Z["x"], Z["y"]) or G ~= Z["id"] or not W or (a and a ~= G) or (p and p ~= W) then
    g("Vend position, item, or price changed at " .. (Z["x"] .. ("," .. (Z["y"] .. "."))))
    return "SKIP"
  end
  F = U()
  if not F then
    return "ERROR"
  end
  local J = j(F, G)
  if J == 0 then
    return "EMPTY"
  end
  z("ADDING STOCK AT " .. (Z["x"] .. ("," .. (Z["y"] .. (" | VEND: " .. ((d or "unknown") .. (" | BAG: " .. J)))))))
  local u = S ~= nil and (K ~= nil and S ~= K)
  if u then
    u = S == "1"
  else
    u = W >= 0
  end
  R["pendingTransfer"] = { ["id"] = G, ["before"] = J }
  if
    not I(
      SendPacket or sendPacket,
      2,
      "action|dialog_return\ndialog_name|vending\ntilex|"
        .. (
          Z["x"]
          .. (
            "|\ntiley|"
            .. (
              Z["y"]
              .. (
                "|\nbuttonClicked|addstock\n\nsetprice|"
                .. (
                  math["abs"](W) .. (
                    "\nchk_peritem|" .. ((u and "1" or "0") .. ("\nchk_perlock|" .. (u and "0" or "1")))
                  )
                )
              )
            )
          )
        )
    )
  then
    if not q(R) then
      return "ERROR"
    end
    R["pendingTransfer"] = nil
    return "SKIP"
  end
  for Z = 1, 35, 1 do
    Sleep(100)
    if not q(R) then
      return "ERROR"
    end
    F = U()
    if F and j(F, G) < J then
      Sleep(350)
      if not q(R) then
        return "ERROR"
      end
      F = U()
      if not F then
        return "ERROR"
      end
      local Z = j(F, G)
      if Z < J then
        local F = J - Z
        R["moved"] = R["moved"] + F
        R["pendingTransfer"] = nil
        if d and d + F >= H then
          return "FULL"
        end
        return Z == 0 and "ADDED" or "PARTIAL"
      end
    end
  end
  if not q(R) or not U() then
    return "ERROR"
  end
  R["pendingTransfer"] = nil
  g("No stock transfer confirmed at vend " .. (Z["x"] .. ("," .. (Z["y"] .. "."))))
  return "REJECTED"
end
local function WM(R, Z, F)
  if j(Z, F["id"]) <= 0 then
    return nil
  end
  local E, H
  for R, Z in ipairs(R) do
    if not Z["unavailable"] and (not Z["tried"] and Z["id"] == F["id"]) then
      local R = math["abs"](Z["x"] - F["x"]) + math["abs"](Z["y"] - F["y"])
      if not H or R < H then
        E, H = Z, R
      end
    end
  end
  return E
end
local function aM(R, Z)
  for R, Z in ipairs(Z) do
    Z["tried"] = false
  end
  for F, E in ipairs(Z) do
    local H = E
    while H and (not H["unavailable"] and not H["tried"]) do
      if not q(R) then
        return false
      end
      local F = U()
      if not F then
        return false
      end
      if j(F, H["id"]) == 0 then
        break
      end
      H["tried"] = true
      local E = GM(R, H)
      if E == "SKIP" and q(R) then
        Sleep(500)
        if not q(R) then
          return false
        end
        E = GM(R, H)
      end
      if E == "ERROR" then
        return false
      end
      if E == "FULL" or E == "SKIP" or E == "PARTIAL" or E == "REJECTED" then
        H["unavailable"] = true
        H["atStockLimit"] = E == "FULL"
        if H["atStockLimit"] then
          t[T(R["world"], H)] = true
          w()
        end
        F = U()
        if not F then
          return false
        end
        H = WM(Z, F, H)
      else
        break
      end
    end
  end
  return q(R)
end
local function pM(R)
  local Z = d(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(Z) ~= "table" then
    return nil
  end
  local F = {}
  for Z, E in pairs(Z) do
    local H, d = tonumber(E["itemid"]), tonumber(E["id"])
    local I = tonumber(E["posX"] or (E["pos"] and E["pos"]["x"]))
    local Q = tonumber(E["posY"] or (E["pos"] and E["pos"]["y"]))
    if H and (R[H] and (d and (I and Q))) then
      local R, Z = math["floor"](I / 32), math["floor"](Q / 32)
      local E = I - R * 32 >= 24 and (Y(R + 1, Z) and R + 1) or nil
      F[#F + 1] = { ["id"] = H, ["uid"] = d, ["x"] = R, ["y"] = Z, ["rightX"] = E, ["ox"] = I, ["oy"] = Q }
    end
  end
  table["sort"](F, RM)
  return F
end
local function xM(R)
  local Z = d(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(Z) ~= "table" then
    return false
  end
  for Z, F in pairs(Z) do
    if tonumber(F["id"]) == R["uid"] and tonumber(F["itemid"]) == R["id"] then
      return true
    end
  end
  return false
end
local function KM(R, Z)
  local F = R[Z] or 0
  return F < 200 and (F > 0 or o(R))
end
local function SM(R, Z, F, E, H)
  local d = pM(Z)
  if not d then
    return
  end
  for Z, d in ipairs(d) do
    local Q = n()
    if not q(R) or not Q then
      return
    end
    if math["floor"](Q["posX"] / 32) ~= F or math["floor"](Q["posY"] / 32) ~= E then
      return
    end
    if d["y"] == E and ((d["x"] == F or d["x"] == F + 1) and not H[d["uid"]]) then
      local R = U()
      if not R then
        return
      end
      if KM(R, d["id"]) then
        H[d["uid"]] = I(
          SendPacketRaw or sendPacketRaw,
          false,
          { ["type"] = 11, ["value"] = d["uid"], ["x"] = d["ox"], ["y"] = d["oy"] }
        )
      end
    end
  end
end
local function JM(R, Z)
  local F = U()
  if not F then
    return nil
  end
  local E = 0
  while q(R) do
    local H = U()
    if not H then
      return nil
    end
    local d, I = {}, {}
    local Q = pM(Z)
    if not Q then
      return nil
    end
    local G = false
    for F, E in ipairs(Q) do
      if not q(R) then
        return nil
      end
      if xM(E) then
        local F = { E["x"], E["rightX"] }
        for F, H in ipairs(F) do
          if not q(R) then
            return nil
          end
          if not xM(E) then
            break
          end
          local Q = H .. ("," .. E["y"])
          if not d[Q] then
            local F = U()
            if not F then
              return nil
            end
            if not KM(F, E["id"]) then
              break
            end
            G = true
            d[Q] = true
            if k(R, H, E["y"]) then
              if H == E["x"] then
                SM(R, Z, H, E["y"], I)
              end
              Sleep(900 + R["pickupDelay"])
            end
          end
        end
      end
    end
    if not q(R) then
      return nil
    end
    local W = U()
    local a = pM(Z)
    if not W or not a then
      return nil
    end
    local p, x, K = false, false, false
    for R in pairs(Z) do
      local Z = W[R] or 0
      if Z > (F[R] or 0) then
        p = true
      end
      if Z > (H[R] or 0) then
        x = true
      end
    end
    for R, Z in ipairs(a) do
      if KM(W, Z["id"]) then
        K = true
        break
      end
    end
    if not K or not G then
      return p, #a > 0
    end
    E = x and 0 or E + 1
    if E >= 2 then
      return p, #a > 0
    end
    if not x then
      Sleep(500)
    end
  end
end
local function uM(R)
  local Z = d(getValue, 0, "ModFly")
  if Z == true or Z == 1 then
    return true
  end
  if not I(editToggle or EditToggle, "ModFly", true) then
    return false
  end
  R["restoreFly"] = true
  return true
end
local function tM(R)
  if R["restoreFly"] then
    R["restoreFly"] = nil
    I(editToggle or EditToggle, "ModFly", false)
  end
end
local function TM(R)
  local Z = FM(R["itemFilter"])
  if not Z then
    return "Could not scan the vending world."
  end
  if #Z == 0 then
    return "No assigned vending machines match the restock settings."
  end
  for F = #Z, 1, -1 do
    local E = Z[F]
    if not E["id"] or E["id"] <= 0 then
      local H
      if k(R, E["x"], E["y"]) then
        Sleep(R["actionDelay"])
        if ZM(Y(E["x"], E["y"])) then
          H = dM(R, E)
        end
      end
      if not q(R) then
        return "Interrupted while checking vending assignments."
      end
      local d = H and IM(H)
      if d and (d > 0 and (not R["itemFilter"] or R["itemFilter"][d])) then
        E["id"] = d
      else
        table["remove"](Z, F)
      end
    end
  end
  if #Z == 0 then
    return "No matching vending assignments could be verified."
  end
  for F = #Z, 1, -1 do
    if t[T(R["world"], Z[F])] then
      table["remove"](Z, F)
    end
  end
  if #Z == 0 then
    return "All matching vends are saved as full. Clear Saved Vend Checks to recheck."
  end
  local F = U()
  if not F then
    return "Could not read backpack inventory."
  end
  local E = 0
  for R, Z in ipairs(Z) do
    if j(F, Z["id"]) > 0 then
      E = E + 1
    end
  end
  if E == 0 and not R["collect"] then
    return "No backpack match for " .. (#Z .. " assigned vend(s). Enable Auto Collect to fetch stock.")
  end
  while q(R) do
    local F = R["collectRoutes"][R["collectIndex"]]
    if not F then
      if not aM(R, Z) then
        return "Stopped during restocking. Check your world and inventory."
      end
      break
    end
    local E = U()
    if not E then
      return "Could not read backpack inventory."
    end
    local H, d = {}, false
    for R, Z in ipairs(Z) do
      if not Z["unavailable"] then
        H[Z["id"]] = true
        if KM(E, Z["id"]) then
          d = true
        end
      end
    end
    if not next(H) then
      break
    end
    local I, Q = true, false
    if d then
      z("COLLECT WORLD " .. (R["collectIndex"] .. ("/" .. (#R["collectRoutes"] .. (" " .. F)))))
      if not e(R, F) then
        return "Could not enter collect route " .. (F .. ".")
      end
      local Z = uM(R)
      if Z then
        local E = false
        while C(R) do
          Q, I = JM(R, H)
          E = E or Q == true
          if not R["disconnected"] and q(R) then
            Q = E
            break
          end
          if not C(R) or not e(R, F) then
            break
          end
          if not uM(R) then
            Z = false
            break
          end
        end
      end
      tM(R)
      if not C(R) then
        return "STOPPED"
      end
      if not e(R, R["returnRoute"]) then
        return "Could not return to the vending world."
      end
      if not Z then
        return "Could not enable ModFly for Auto Collect."
      end
      if Q == nil then
        return "Could not read supply world or inventory."
      end
    end
    local G = R["moved"]
    if not aM(R, Z) then
      return "Stopped during restocking. Check your world and inventory."
    end
    if not I then
      R["collectIndex"] = R["collectIndex"] + 1
    elseif not Q and R["moved"] == G then
      z("STOCK REMAINS - WAITING FOR PICKUP IN " .. F)
      for Z = 1, 30, 1 do
        if not C(R) then
          return "STOPPED"
        end
        Sleep(100)
      end
    end
  end
  local H = 0
  for R, Z in ipairs(Z) do
    if Z["unavailable"] then
      H = H + 1
    end
  end
  if H > 0 then
    return "Done. Added " .. (R["moved"] .. (" items. Could not fill or already full: " .. (H .. " vend(s).")))
  end
  if R["moved"] == 0 and E == 0 then
    return "Scanned " .. (#Z .. " assigned vend(s). No matching stock found in backpack or Collect World.")
  end
  return "Done. Added " .. (R["moved"] .. " items. No more matching stock.")
end
local function LM(R)
  R = tostring(R or "")
  R = R:gsub("\n", "\r\n")
  R = R:gsub("([^%w%-_%.~])", function(R)
    return string["format"]("%%%02X", string["byte"](R))
  end)
  return R
end
local function mM(R)
  N, A = R, true
  z("SCANNING VENDING WORLD")
  runThread(function()
    local Z, F
    while C(R) do
      Z, F = pcall(TM, R)
      tM(R)
      if not C(R) then
        break
      end
      local E = M()
      if not R["disconnected"] and (n() and (E ~= "" and (E ~= "EXIT" and E ~= "EXITWORLD"))) then
        break
      end
      z("CONNECTION LOST - RETURNING TO VENDING WORLD")
      if not r(R) then
        Z, F = true, "Could not reconnect to the original vending world."
        break
      end
      if R["pendingTransfer"] then
        local E = R["pendingTransfer"]
        local H = U()
        if not H then
          Z, F = true, "Could not read inventory after reconnecting."
          break
        end
        R["moved"] = R["moved"] + math["max"](0, E["before"] - j(H, E["id"]))
        R["pendingTransfer"] = nil
      end
      z("RECONNECTED - RESCANNING VENDS")
    end
    tM(R)
    A = false
    if not C(R) then
      return
    end
    N = nil
    s()
    local E = Z and F or ("Restock stopped: " .. tostring(F))
    z(E)
    g(E)
  end)
end
function onValue(R, Z, F)
  if Z == "RSV_clearchecks" then
    if A then
      g("Stop restocking before clearing saved vend checks.")
      return
    end
    t = {}
    w()
    g("Saved vend checks cleared. The next run will recheck matching vends.")
    return
  end
  if Z == "RSV_custom" then
    u = F == true or F == 1 or F == "true" or F == "1"
    w()
    return
  end
  if Z == "RSV_pickitem" or Z == "RSV_removeitem" or Z == "RSV_clearitems" then
    local R = {}
    for Z in J:gmatch("[^,%s]+") do
      R[#R + 1] = Z
    end
    if Z == "RSV_pickitem" then
      if type(F) == "table" then
        F = F["id"] or F["itemID"] or F["itemid"] or F["value"] or F["name"]
      end
      local Z = tonumber(F)
      if not Z and type(F) == "string" then
        Z = tonumber(F:match("%((%d+)%)")) or tonumber(d(findItemID or (growtopia and growtopia["getItemID"]), F))
      end
      if not Z or Z < 1 or Z > 65535 or Z % 1 ~= 0 then
        return
      end
      for R, F in ipairs(R) do
        if tonumber(F) == Z then
          return
        end
      end
      R[#R + 1] = tostring(Z)
    elseif Z == "RSV_removeitem" then
      if #R > 0 then
        table["remove"](R)
      end
    else
      R = {}
    end
    J = table["concat"](R, ", ")
    w()
    d(editValue, "RSV_items", J)
    return
  end
  if Z == "RSV_items" then
    J = tostring(F or "")
    w()
    return
  end
  if Z == "RSV_collect" then
    p = F == true
    w()
    return
  end
  if Z == "RSV_here" then
    local R = G(M())
    if not R or R == "EXIT" or not n() then
      g("Enter the collect world first.")
      return
    end
    x = R
    w()
    d(editValue, "RSV_world", x)
    return
  end
  if Z == "RSV_world" then
    local R = tostring(F or "")
    if R ~= x then
      x = R
      w()
    end
    return
  end
  if Z == "RSV_door" then
    local R = Q(F)
    if R ~= K then
      K = R
      w()
    end
    return
  end
  if Z == "RSV_pathdelay" then
    local R = W(F, 10000)
    if R and R ~= L then
      L = R
      w()
    end
    return
  end
  if Z == "RSV_actiondelay" then
    local R = W(F, 10000)
    if R and R ~= m then
      m = R
      w()
    end
    return
  end
  if Z == "RSV_delay" then
    local R = W(F, 1000)
    if R and R ~= S then
      S = R
      w()
    end
    return
  end
  if Z ~= "RSV_start" or l then
    return
  end
  if F ~= true then
    local R = N
    N = nil
    if R then
      tM(R)
    end
    z("STOPPED")
    return
  end
  if N then
    return
  end
  if A then
    s()
    g("Wait for the previous run to stop.")
    return
  end
  local E = M()
  if E == "" or E == "EXIT" or not n() then
    s()
    g("Enter your vending world before pressing Start.")
    return
  end
  local H, I = {}, {}
  if p then
    for R in x:gmatch("[^,;\r\n]+") do
      local Z = Q(R)
      if Z ~= "" then
        local R = G(Z)
        if not R or R == "EXIT" or R == "EXITWORLD" then
          s()
          g("Invalid Collect World route " .. (Z .. "."))
          return
        end
        if not I[Z] then
          H[#H + 1], I[Z] = Z, true
        end
      end
    end
    if #H == 0 or K:find("|", 1, true) then
      s()
      g("Check Collect Worlds and the optional Vend Return Door ID.")
      return
    end
  end
  local a
  for R in ((u and J or "")):gmatch("[^,%s]+") do
    local Z = tonumber(R)
    if not R:match("^%d+$") or not Z or Z < 1 or Z > 65535 then
      s()
      g("Enter valid Restock Item IDs.")
      return
    end
    a = a or {}
    a[Z] = true
  end
  if u and not a then
    s()
    g("Add at least one item in Restock Settings.")
    return
  end
  local T = {
    ["itemFilter"] = a,
    ["world"] = E,
    ["collect"] = p,
    ["collectRoutes"] = H,
    ["collectIndex"] = 1,
    ["pickupDelay"] = S,
    ["pathDelay"] = L,
    ["actionDelay"] = m,
    ["returnRoute"] = K == "" and E or (E .. ("|" .. K)),
    ["moved"] = 0,
  }
  mM(T)
end
applyHook()
if type(setOnValue) == "function" then
  for R, Z in ipairs({ "RSV_pickitem", "RSV_items", "RSV_world", "RSV_door", "RSV_pathdelay", "RSV_actiondelay", "RSV_delay" }) do
    local F = Z
    pcall(setOnValue, F, function(...)
      local R = select("#", ...)
      if R > 0 then
        onValue(nil, F, select(R, ...))
      end
    end)
  end
end
