local B = "LOLI STORE"
local w = "discord.gg/2PMRnwtNT"
local t = "Lite"
local Q = "LOLI STORE"
local Y = "lolistore_pnb_lite.txt"
local V = sleep or Sleep
local j = log or LogToConsole
local g, H = math["floor"], math["abs"]
local function L(B)
  if type(j) == "function" then
    pcall(j, "`9[PnB Lite]`0 " .. tostring(B))
  end
end
local function W(B)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], B)
  elseif type(sendNotification) == "function" then
    pcall(sendNotification, B)
  end
end
local function h()
  if type(getTime) == "function" then
    local B, w = pcall(getTime)
    if B and tonumber(w) then
      return tonumber(w)
    end
  end
  return os["time"]() * 1000 + (os["clock"]() * 1000) % 1000
end
local function q(B)
  return ((tostring(B or "")):gsub("`.", ""))
end
local function l(B, w)
  local t, Q = pcall(function()
    return B[w]
  end)
  if t then
    return Q
  end
  return nil
end
local K = "i0M15rvpt7VqEJrTewzY0kRs"
local k = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local s = 320400
local f = 604800
local J = 43200
local function d(B)
  local w = K .. (":" .. math["floor"](B))
  local t, Q = 5381, 52711
  for B = 1, #w, 1 do
    local Y = w:byte(B)
    t = (t * 33 + Y) % 2147483647
    Q = ((Q * 131 + Y * 7) + B) % 2147483629
  end
  for B = 1, 12, 1 do
    t = (t * 48271 + Q) % 2147483647
    Q = (Q * 69621 + t) % 2147483629
  end
  local Y = {}
  for B, w in ipairs({ t, Q }) do
    for B = 1, 4, 1 do
      local t = w % 32
      w = w // 32
      Y[#Y + 1] = k:sub(t + 1, t + 1)
    end
  end
  return "LS-" .. (table["concat"](Y, "", 1, 4) .. ("-" .. table["concat"](Y, "", 5, 8)))
end
local function U(B)
  return (((tostring(B or "")):upper()):gsub("%s+", ""))
end
local E = {
  ["key"] = "",
  ["block_id"] = 0,
  ["spot_x"] = -1,
  ["spot_y"] = -1,
  ["tiles"] = "1,0",
  ["enable_place"] = true,
  ["enable_break"] = true,
  ["delay_place"] = 120,
  ["delay_punch"] = 180,
  ["max_hit"] = 40,
  ["auto_collect"] = true,
  ["collect_gems"] = true,
  ["collect_r"] = 2,
  ["auto_retrieve"] = true,
  ["gaia_guard"] = true,
  ["tess_guard"] = false,
}
local D = {
  "key",
  "block_id",
  "spot_x",
  "spot_y",
  "tiles",
  "enable_place",
  "enable_break",
  "delay_place",
  "delay_punch",
  "max_hit",
  "auto_collect",
  "collect_gems",
  "collect_r",
  "auto_retrieve",
  "gaia_guard",
  "tess_guard",
}
local O = {}
do
  local B, w = pcall(function()
    return debug["getinfo"](1, "S")
  end)
  local t = B and (w and w["source"]) or ""
  if t:sub(1, 1) == "@" then
    local B = (t:sub(2)):match("^(.*[/\\])")
    if B then
      O[#O + 1] = B
    end
  end
  for B, w in ipairs({
    "/storage/emulated/0/Android/media/launcher.powerkuy.growlauncher/ScriptLua/",
    "/storage/emulated/0/Android/media/launcher.powerkuy.growlauncher/",
    "/storage/emulated/0/Download/",
    "/storage/emulated/0/",
    "",
  }) do
    O[#O + 1] = w
  end
end
local v = nil
local function C()
  local B = U(E["key"])
  if B == "" then
    return false
  end
  local w = os["time"]()
  local t = math["floor"]((w - s) / f)
  if B == d(t) then
    return true
  end
  return ((w - s) % f) < J and B == d(t - 1)
end
local function p()
  for B, w in ipairs(O) do
    local t, Q = pcall(io["open"], w .. Y, "r")
    if t and Q then
      for B in Q:lines() do
        local w, t = B:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
        if w and E[w] ~= nil then
          local B = type(E[w])
          if B == "number" then
            E[w] = tonumber(t) or E[w]
          elseif B == "boolean" then
            E[w] = (t == "true" or t == "1")
          else
            E[w] = t
          end
        end
      end
      Q:close()
      v = w .. Y
      return true
    end
  end
  return false
end
local function r()
  local w = { "# Config Auto PnB Lite | " .. B, "# Boleh diedit manual. Format: nama = isi" }
  for B, t in ipairs(D) do
    w[#w + 1] = t .. (" = " .. tostring(E[t]))
  end
  local t = table["concat"](w, "\n") .. "\n"
  local Q = {}
  if v then
    Q[1] = v:sub(1, #v - #Y)
  end
  for B, w in ipairs(O) do
    Q[#Q + 1] = w
  end
  for B, w in ipairs(Q) do
    local Q, V = pcall(io["open"], w .. Y, "w")
    if Q and V then
      V:write(t)
      V:close()
      v = w .. Y
      return true
    end
  end
  return false
end
local x = {}
local function I()
  x = {}
  for B, w in (tostring(E["tiles"])):gmatch("(-?%d+),(-?%d+)") do
    B, w = tonumber(B), tonumber(w)
    if not (B == 0 and w == 0) and (H(B) <= 2 and H(w) <= 2) then
      x[#x + 1] = { ["dx"] = B, ["dy"] = w }
    end
  end
end
local function A(B)
  local w, t, Q = pcall(function()
    return B["x"], B["y"]
  end)
  if w and (tonumber(t) and tonumber(Q)) then
    return tonumber(t), tonumber(Q)
  end
  w, t, Q = pcall(function()
    return B[1], B[2]
  end)
  if w and (tonumber(t) and tonumber(Q)) then
    return tonumber(t), tonumber(Q)
  end
  w, t, Q = pcall(function()
    return B["X"], B["Y"]
  end)
  if w and (tonumber(t) and tonumber(Q)) then
    return tonumber(t), tonumber(Q)
  end
  if type(B) == "string" then
    local w, t = B:match("(-?%d+)%s*,%s*(-?%d+)")
    if w then
      return tonumber(w), tonumber(t)
    end
  end
  return nil
end
local function S(B)
  local w = { type(B) .. (" " .. tostring(B)) }
  if type(B) == "table" then
    local t = 0
    for B, Q in pairs(B) do
      t = t + 1
      if t > 5 then
        w[#w + 1] = "..."
        break
      end
      local Y, V = A(Q)
      w[#w + 1] = "[" .. (
          tostring(B) .. ("]=" .. (type(Q) .. (" " .. (tostring(Q) .. (Y and (" -> " .. (Y .. ("," .. V))) or "")))))
        )
    end
  end
  return table["concat"](w, " | ")
end
local function P(B)
  local w = {}
  if type(B) == "table" then
    for B, t in pairs(B) do
      local Q, Y = A(t)
      if Q then
        w[#w + 1] = { Q, Y }
      end
    end
    if #w == 0 then
      local t, Q = A(B)
      if t then
        w[1] = { t, Q }
      end
    end
  elseif type(B) == "userdata" then
    local t, Q = A(B)
    if t then
      w[1] = { t, Q }
    end
  else
    for B, t in (tostring(B or "")):gmatch("(-?%d+)%s*,%s*(-?%d+)") do
      w[#w + 1] = { tonumber(B), tonumber(t) }
    end
  end
  local t = false
  for B, w in ipairs(w) do
    if w[1] < 0 or w[2] < 0 then
      t = true
    end
  end
  local Q = {}
  for B, w in ipairs(w) do
    local Y, V = w[1], w[2]
    if not t then
      Y, V = Y - 2, V - 2
    end
    if not (Y == 0 and V == 0) and (H(Y) <= 2 and H(V) <= 2) then
      Q[#Q + 1] = Y .. ("," .. V)
    end
  end
  return table["concat"](Q, ";"), #Q
end
local i, R = 112, 18
local T, n = 60, 3
local function X()
  local B, w = pcall(getLocal)
  if B and type(w) == "table" then
    return w
  end
end
local function o()
  local B = X()
  if not B then
    return nil, nil
  end
  return g(B["posX"] / 32), g(B["posY"] / 32)
end
local function b()
  for B, w in ipairs({ GetWorldName, getCurrentWorldName }) do
    if type(w) == "function" then
      local B, t = pcall(w)
      if B and type(t) == "string" then
        return t
      end
    end
  end
  return ""
end
local function Z(B, w)
  local t, Q = pcall(getTile, B, w)
  if not t or type(Q) ~= "table" then
    return nil
  end
  return tonumber(Q["fg"]) or 0
end
local function N(B)
  if B <= 0 then
    return 0
  end
  if growtopia and type(growtopia["checkInventoryCount"]) == "function" then
    local w, t = pcall(growtopia["checkInventoryCount"], B)
    if w and tonumber(t) then
      return tonumber(t)
    end
  end
  local w, t = pcall(getInventory)
  if not w or type(t) ~= "table" then
    return 0
  end
  for w, t in pairs(t) do
    if tonumber(t["id"] or t["itemid"]) == B then
      return tonumber(t["amount"] or t["count"]) or 0
    end
  end
  return 0
end
local u = {}
local function c(B)
  B = tonumber(B) or 0
  if B <= 0 then
    return ""
  end
  if u[B] then
    return u[B]
  end
  local w = ""
  if growtopia and type(growtopia["getItemName"]) == "function" then
    local t, Q = pcall(growtopia["getItemName"], B)
    if t and type(Q) == "string" then
      w = Q
    end
  end
  u[B] = w
  return w
end
local function m(B)
  if type(B) == "table" then
    B = B["id"] or B["itemid"] or B[1]
  end
  local w = tonumber(B)
  if w then
    return g(w)
  end
  if type(B) == "string" and (B ~= "" and (growtopia and type(growtopia["getItemID"]) == "function")) then
    local w, t = pcall(growtopia["getItemID"], B)
    if w and tonumber(t) then
      return tonumber(t)
    end
  end
  return nil
end
local G = false
local M = "Idle"
local e = { ["broken"] = 0, ["placed"] = 0, ["started"] = 0 }
local z = 0
local F = ""
local function y(B)
  B = (((tostring(B or "")):gsub("\\", "\\\\")):gsub('"', '\\"')):gsub("[\r\n\t]", " ")
  return '"' .. (B .. '"')
end
local function a(B)
  return string["format"]("%02d:%02d:%02d", g(B / 3600), g((B % 3600) / 60), B % 60)
end
local function B8()
  local B = c(E["block_id"])
  local t = (G and e["started"] > 0) and (os["time"]() - e["started"]) or 0
  local Q = {
    { "Status: " .. M, G and ("Jalan " .. a(t)) or "Berhenti" },
    { "Block: " .. (B ~= "" and B or "-"), "Stok: " .. N(E["block_id"]) },
    { "Pecah: " .. (e["broken"] .. (" | Place: " .. e["placed"])), "" },
    { "Titik PnB: " .. (E["spot_x"] >= 0 and (E["spot_x"] .. ("," .. E["spot_y"])) or "belum di-set"), #x .. " tile target" },
    { "Key: " .. (C() and "valid" or "belum valid"), "Ambil di " .. (w .. " (#key-lite)") },
  }
  local Y = {}
  for B, w in ipairs(Q) do
    Y[#Y + 1] = "[" .. (y(w[1]) .. ("," .. (y(w[2]) .. "]")))
  end
  pcall(editValue, "pnb_status", "[" .. (table["concat"](Y, ",") .. "]"))
end
local function w8(B, w)
  if type(sendDialog) == "function" then
    pcall(sendDialog, { ["title"] = B, ["message"] = w, ["confirm"] = "OK", ["alias"] = "pnb_popup" })
  end
  W(B)
end
local t8, Q8, Y8, V8 = 0, 0, nil, 0
local function j8()
  t8 = t8 + 1
  Q8 = h()
  local B, w = o()
  Y8 = B and { ["x"] = B, ["y"] = w } or nil
  if G then
    L("`4[MATI] Karakter mati -> tunggu respawn, balik ke titik PnB.`0")
  end
end
local function g8()
  if t8 == 0 or h() - Q8 >= 5000 then
    return false
  end
  if not Y8 then
    return true
  end
  local B, w = o()
  return B == nil or (B == Y8["x"] and w == Y8["y"])
end
local function H8()
  local B = 0
  while B < 4000 and G do
    local w, t = o()
    if Y8 and (w and (w ~= Y8["x"] or t ~= Y8["y"])) then
      break
    end
    V(100)
    B = B + 100
  end
  V(300)
end
local L8 = nil
local function W8()
  local B = false
  pcall(function()
    local w = getValue(0, "ModFly")
    B = (w == true or w == 1 or w == "1" or w == "true")
  end)
  if B or L8 == true then
    return
  end
  pcall(editToggle, "ModFly", true)
  L8 = true
end
local h8 = ""
local function q8(B)
  B = tostring(B or "")
  local w = B:gsub("%d+", "#")
  if w ~= h8 then
    h8 = w
    L("`3[TUGAS]`0 " .. B)
  end
  M = B
end
local function l8(B, w, t)
  if g8() then
    return false
  end
  local Q = X()
  if not Q then
    return false
  end
  local Y = h() - z
  if Y < T then
    V(T - Y)
    if g8() then
      return false
    end
    Q = X()
    if not Q then
      return false
    end
  end
  local j = pcall(
    sendPacketRaw,
    false,
    { ["type"] = 3, ["value"] = B, ["x"] = Q["posX"], ["y"] = Q["posY"], ["px"] = w, ["py"] = t }
  )
  z = h()
  return j
end
local function K8(B, w, t, Q)
  local Y = 0
  while Y < Q do
    if Z(B, w) == t then
      return true
    end
    V(50)
    Y = Y + 50
  end
  return Z(B, w) == t
end
local function k8()
  local B, w = o()
  return B == E["spot_x"] and w == E["spot_y"]
end
local function s8()
  if g8() then
    H8()
  end
  if k8() then
    return true
  end
  for B = 1, 3, 1 do
    if not G then
      return false
    end
    pcall(FindPath, E["spot_x"], E["spot_y"])
    local w = 0
    while w < 5000 and (G and not k8()) do
      V(100)
      w = w + 100
    end
    if k8() then
      V(300)
      return true
    end
  end
  return k8()
end
local f8 = {}
local function J8()
  local B = E["auto_collect"] or E["collect_gems"]
  if not B then
    return
  end
  local w, t = pcall(getObjectList)
  if not w or type(t) ~= "table" then
    return
  end
  local Q, Y = o()
  if not Q then
    return
  end
  local j = math["min"](3, math["max"](0, E["collect_r"]))
  local L = 0
  for B, w in pairs(t) do
    if not G or L >= 6 or g8() then
      return
    end
    local t, W = tonumber(l(w, "posX")), tonumber(l(w, "posY"))
    if not t then
      local B = l(w, "pos")
      if B ~= nil then
        t, W = tonumber(l(B, "x")), tonumber(l(B, "y"))
      end
    end
    local h = tonumber(l(w, "id") or l(w, "oid"))
    if t and (W and h) then
      local B, q = g((t + 8) / 32), g((W + 8) / 32)
      if H(B - Q) <= j and (H(q - Y) <= j and not f8[B .. ("," .. q)]) then
        local B = tonumber(l(w, "itemid"))
        if (B == i and E["collect_gems"]) or (B ~= i and (B ~= E["block_id"] or N(B) < 200)) then
          pcall(sendPacketRaw, false, { ["type"] = 11, ["value"] = h, ["x"] = t, ["y"] = W })
          L = L + 1
          V(40)
        end
      end
    end
  end
end
local d8 = 6948
local U8 = 32
local E8 = 200
local D8 = false
local O8 = nil
local v8 = 0
local C8 = { ["way"] = 1, ["show"] = false }
local function p8(B)
  if type(B) == "table" and B["v1"] == "OnKilled" then
    local w = tonumber(B["netid"])
    local t = X()
    local Q = t and tonumber(l(t, "netID") or l(t, "netId") or l(t, "netid"))
    if not w or w < 0 or (Q and w == Q) then
      pcall(j8)
    end
    return false
  end
  if type(B) ~= "table" or B["v1"] ~= "OnDialogRequest" or type(B["v2"]) ~= "string" then
    return false
  end
  local w = B["v2"]:match("end_dialog|([^|]*)|") or ""
  if (D8 or h() < v8) and (w == "itemsucker_block" or w == "itemsucker_seed" or w == "itemremovedfromsucker") then
    O8 = { ["name"] = w, ["text"] = B["v2"], ["at"] = h() }
    if C8["show"] then
      return false
    end
    return true
  end
  return false
end
local function r8(B, w, t)
  local Q = h()
  while h() - Q < t do
    if O8 and (O8["at"] >= w and O8["name"] == B) then
      return O8
    end
    V(100)
  end
  return nil
end
local function x8(B, w)
  return B:match("embed_data|" .. (w .. "|([^\n|]*)"))
    or B:match("add_checkbox|" .. (w .. "|[^|]*|([^\n|]*)"))
    or B:match("add_text_input|" .. (w .. "|[^|]*|([^|\n]*)"))
end
local function I8()
  local B, w = pcall(getTiles)
  if not B or type(w) ~= "table" then
    return {}
  end
  local t, Q = o()
  local Y = {}
  for B, w in pairs(w) do
    if type(w) == "table" and (tonumber(w["fg"]) == d8 and tonumber(w["x"])) then
      local B, V = tonumber(w["x"]), tonumber(w["y"])
      Y[#Y + 1] = { ["x"] = B, ["y"] = V, ["dist"] = t and (H(B - t) + H(V - Q)) or 0 }
    end
  end
  table["sort"](Y, function(B, w)
    return B["dist"] < w["dist"]
  end)
  return Y
end
local function A8(B, w)
  for t = 1, 2, 1 do
    if not G then
      return false
    end
    local Q, Y = o()
    if Q == B and Y == w then
      return true
    end
    pcall(FindPath, B, w)
    local j = 0
    while j < 5000 and G do
      Q, Y = o()
      if Q == B and Y == w then
        V(300)
        return true
      end
      V(100)
      j = j + 100
    end
  end
  return false
end
local function S8(B, w)
  for t, Q in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
    if Z(B + Q[1], w + Q[2]) == 0 and A8(B + Q[1], w + Q[2]) then
      return true
    end
  end
  return false
end
C8["ways"] = { "samping Tesseract", "dialog ditampilin", "2 tile di atas/bawah", "ModFly mati sebentar" }
function C8.full(B)
  return B:find("add_textbox", 1, true) or B:find("add_item_picker", 1, true) or B:find("retrieveitem", 1, true)
end
function C8.read(B, w)
  w = w or "itemsucker_block"
  local t = { C8["way"] }
  for B = 1, #C8["ways"], 1 do
    if B ~= C8["way"] then
      t[#t + 1] = B
    end
  end
  local Q, Y = nil, false
  D8 = true
  for t, j in ipairs(t) do
    if not G then
      break
    end
    local g
    if j == 3 then
      g = A8(B["x"], B["y"] - 2) or A8(B["x"], B["y"] + 2)
    else
      g = S8(B["x"], B["y"])
    end
    if g then
      Y = true
      if j == 4 then
        pcall(editToggle, "ModFly", false)
        L8 = false
      end
      V(900)
      C8["show"] = (j == 2)
      O8 = nil
      local t = h()
      l8(U8, B["x"], B["y"])
      Q = r8(w, t, 3000)
      C8["show"] = false
      if j == 4 then
        W8()
      end
      if Q and C8["full"](Q["text"]) then
        if j ~= C8["way"] then
          L("`2Retrieve: dialog Tesseract kebaca pakai cara '" .. (C8["ways"][j] .. "' -> dipakai seterusnya`0"))
        end
        C8["way"] = j
        break
      end
      V(1000)
    end
  end
  return Q, Y
end
local P8
local function i8(B)
  local w = P8(B, 20)
  if w > 0 then
    return w
  end
  return P8(B, 1)
end
P8 = function(B, w)
  local t = I8()
  if #t == 0 then
    L("Retrieve: nggak ada Unstable Tesseract di world ini")
    return 0
  end
  for t, Q in ipairs(t) do
    if not G then
      return 0
    end
    q8("Retrieve Tesseract " .. (Q["x"] .. ("," .. Q["y"])))
    B8()
    local Y = N(B)
    local j, g = C8["read"](Q)
    if not g then
      L("Retrieve: Tesseract " .. (Q["x"] .. ("," .. (Q["y"] .. " nggak bisa didatengin"))))
      D8 = false
    else
      local t
      local g = 0
      if j and not C8["full"](j["text"]) then
        L(
          "`4Retrieve: isi Tesseract "
            .. (
              Q["x"]
              .. (
                ","
                .. (
                  Q["y"]
                  .. " nggak kebaca (server cuma ngirim dialog pendek). Cek akun ini udah punya akses World Lock?`0"
                )
              )
            )
        )
      elseif not j then
        L("Retrieve: dialog Tesseract " .. (Q["x"] .. ("," .. (Q["y"] .. " nggak muncul"))))
      else
        local H = tonumber(j["text"]:match("add_label_with_icon|small|[^|]*|[^|]*|(%d+)|"))
        local W = j["text"]:find("add_button|retrieveitem|", 1, true) ~= nil
        if H ~= B then
          L(
            "Retrieve: Tesseract " .. (
                Q["x"] .. ("," .. (Q["y"] .. (" isinya bukan block ini (ID " .. (tostring(H) .. ")"))))
              )
          )
        elseif not W then
          L("Retrieve: Tesseract " .. (Q["x"] .. ("," .. (Q["y"] .. " kosong"))))
        elseif
          (function()
            local B = (q(j["text"])):match("[Cc]ontains[^%d\n]*([%d][%d,%.]*)")
            if not B then
              return false
            end
            return (tonumber((B:gsub("[,%.]", ""))) or 0) < w
          end)()
        then
          L("Retrieve: Tesseract " .. (Q["x"] .. ("," .. (Q["y"] .. (" isinya < " .. (w .. ", dilewatin dulu"))))))
        else
          local w = x8(j["text"], "tilex") or tostring(Q["x"])
          local H = x8(j["text"], "tiley") or tostring(Q["y"])
          local W = x8(j["text"], "chk_enablesucking") or "1"
          t = h()
          pcall(
            sendPacket,
            2,
            "action|dialog_return\ndialog_name|itemsucker_block\ntilex|"
              .. (w .. ("|\ntiley|" .. (H .. ("|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|" .. (W .. "\n")))))
          )
          local q = r8("itemremovedfromsucker", t, 3000)
          if q then
            local t = tonumber(x8(q["text"], "itemtoremove")) or E8
            local Q = math["max"](1, math["min"](t, E8 - Y))
            V(300)
            pcall(
              sendPacket,
              2,
              "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"
                .. (w .. ("|\ntiley|" .. (H .. ("|\nitemtoremove|" .. (Q .. "\n")))))
            )
            local j = 0
            while j < 3000 and N(B) <= Y do
              V(200)
              j = j + 200
            end
            g = N(B) - Y
          else
            L("Retrieve: dialog jumlah nggak muncul")
          end
        end
      end
      V(800)
      D8 = false
      v8 = h() + 2000
      if g > 0 then
        L("`2Retrieve: dapet " .. (g .. (" dari Tesseract " .. (Q["x"] .. ("," .. (Q["y"] .. "`0"))))))
        return g
      end
    end
  end
  return 0
end
local R8 = 6946
local function T8(B)
  local w, t = pcall(getTiles)
  if not w or type(t) ~= "table" then
    return {}
  end
  local Q = {}
  for w, t in pairs(t) do
    if type(t) == "table" and (tonumber(t["fg"]) == B and tonumber(t["x"])) then
      Q[#Q + 1] = { ["x"] = tonumber(t["x"]), ["y"] = tonumber(t["y"]) }
    end
  end
  return Q
end
local function n8(B)
  local w = {}
  for B, t in ipairs({ d8, R8 }) do
    for B, t in ipairs(T8(t)) do
      w[#w + 1] = t
    end
  end
  local function t(B, t)
    if (Z(B, t) or 1) ~= 0 then
      return true
    end
    if H(B - E["spot_x"]) <= 3 and H(t - E["spot_y"]) <= 3 then
      return true
    end
    for w, Q in ipairs(w) do
      if H(B - Q["x"]) + H(t - Q["y"]) <= 1 then
        return true
      end
    end
    return false
  end
  local Q, Y = nil, 1000000000
  for w = -2, 2, 1 do
    for V = -6, 6, 1 do
      local j, g = B["x"] + V, B["y"] + w
      local L = H(V) + H(w)
      if j >= 0 and (g >= 0 and (L < Y and not t(j, g))) then
        Q, Y = { j, g }, L
      end
    end
  end
  if Q then
    return Q[1], Q[2]
  end
  return B["x"] - 2, B["y"]
end
local X8 = {
  function(B, w)
    if not (growtopia and growtopia["confirmDropItem"]) then
      return false
    end
    return (pcall(growtopia["confirmDropItem"], B, w))
  end,
  function(B, w)
    pcall(sendPacket, 2, "action|drop\n|itemID|" .. B)
    V(600)
    pcall(sendPacket, 2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (B .. ("|\ncount|" .. (w .. "\n"))))
    return true
  end,
}
local o8 = nil
local function b8(B, w, t, Q)
  for Y = 0, 5, 1 do
    if not G then
      return 0
    end
    if A8(t + Y, Q) then
      if g8() then
        return 0
      end
      local j = N(B)
      local g = o8 and { o8, o8 % #X8 + 1 } or { 1, 2 }
      for g, H in ipairs(g) do
        if X8[H](B, math["min"](w, N(B))) then
          local w = 0
          while w < 1500 and N(B) >= j do
            V(100)
            w = w + 100
          end
          if N(B) < j then
            o8 = H
            f8[(t + Y) .. ("," .. Q)] = true
            return j - N(B)
          end
        end
      end
    end
  end
  return 0
end
local function Z8(B, w)
  local t = x8(B["text"], "tilex")
  local Q = x8(B["text"], "tiley")
  local Y = B["text"]:match("end_dialog|([^|]*)|") or "itemsucker_block"
  local j = x8(B["text"], "chk_enablesucking") or "1"
  local g = N(w)
  local H = h()
  pcall(
    sendPacket,
    2,
    "action|dialog_return\ndialog_name|"
      .. (
        Y .. (
          "\ntilex|" .. (
            t .. ("|\ntiley|" .. (Q .. ("|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|" .. (j .. "\n"))))
          )
        )
      )
  )
  local L = r8("itemremovedfromsucker", H, 3000)
  if not L then
    return 0
  end
  local W = tonumber(x8(L["text"], "itemtoremove")) or (E8 - g)
  local q = math["max"](1, math["min"](W, E8 - g))
  V(300)
  pcall(
    sendPacket,
    2,
    "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"
      .. (t .. ("|\ntiley|" .. (Q .. ("|\nitemtoremove|" .. (q .. "\n")))))
  )
  local l = 0
  while l < 3000 and N(w) <= g do
    V(200)
    l = l + 200
  end
  return math["max"](0, N(w) - g)
end
local function N8(B, w)
  local t = (w == d8)
  local Q = t and "Tesseract" or "Gaia"
  local Y = t and "itemsucker_block" or "itemsucker_seed"
  local V, j = n8(B)
  local g, H, W, l = 0, 0, 0, nil
  while G and W < 40 do
    W = W + 1
    q8("Jaga " .. (Q .. (" " .. (B["x"] .. ("," .. B["y"])))))
    local w, K = C8["read"](B, Y)
    if not K or not w then
      break
    end
    if not C8["full"](w["text"]) then
      L(
        "`4Jaga " .. (
            Q .. (" " .. (B["x"] .. ("," .. (B["y"] .. ": isi nggak kebaca (dialog pendek). Cek akses World Lock`0"))))
          )
      )
      break
    end
    l = l or tonumber(w["text"]:match("add_label_with_icon|small|[^|]*|[^|]*|(%d+)|"))
    if not l or not w["text"]:find("retrieveitem", 1, true) then
      break
    end
    if t and l ~= E["block_id"] then
      L(
        "Jaga Tesseract " .. (B["x"] .. ("," .. (B["y"] .. (": isinya bukan block PnB (ID " .. (l .. "), dilewatin")))))
      )
      break
    end
    if N(l) >= E8 then
      D8 = false
      v8 = h() + 2000
      local B = tonumber(((((q(w["text"])):match("[Cc]ontains[^%d\n]*([%d][%d,%.]*)") or "")):gsub("[,%.]", "")))
      local Y = (t and (B and B > 0)) and math["min"](N(l), B) or N(l)
      local g = b8(l, Y, V, j)
      if g <= 0 then
        L("`4Jaga " .. (Q .. ": drop gagal, berhenti`0"))
        break
      end
      H = H + g
    else
      local B = Z8(w, l)
      D8 = false
      v8 = h() + 2000
      if B <= 0 then
        break
      end
      g = g + B
    end
  end
  D8 = false
  v8 = h() + 2000
  if l and (not t and N(l) > 0) then
    H = H + b8(l, N(l), V, j)
  end
  if g > 0 or H > 0 then
    L(
      "`2Jaga "
        .. (
          Q
          .. (
            " "
            .. (
              B["x"]
              .. (
                ","
                .. (
                  B["y"]
                  .. (
                    ": retrieve "
                    .. (
                      g
                      .. (
                        ", drop "
                        .. (
                          H .. (
                            " di " .. (
                              V .. ("," .. (j .. ((t and (" (stok tas " .. (N(E["block_id"]) .. ")")) or "") .. "`0")))
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
    )
  end
end
local function u8()
  if E["gaia_guard"] then
    for B, w in ipairs(T8(R8)) do
      if G then
        N8(w, R8)
      end
    end
  end
  if E["tess_guard"] then
    for B, w in ipairs(T8(d8)) do
      if G then
        N8(w, d8)
      end
    end
  end
end
local function c8(B, w)
  G = false
  q8(B)
  pcall(editValue, "pnb_start", false)
  L(B .. (": " .. w))
  w8(B, w)
  B8()
end
local function m8()
  e["started"] = os["time"]()
  local B, t, Q = 0, 0, os["time"]()
  local Y = os["time"]()
  local j = {}
  local g = E["block_id"]
  local H = c(g)
  H = H ~= "" and ("<" .. (H .. ">")) or ("block ID " .. g)
  while G do
    if h() - t > 2000 then
      B8()
      t = h()
    end
    if os["time"]() - Q > 300 then
      Q = os["time"]()
      if not C() then
        c8("Key kadaluarsa", "Key minggu ini udah ganti. Ambil key baru di " .. (w .. " (#key-lite)."))
        break
      end
    end
    if not X() then
      c8("Disconnect", "Bot berhenti karena disconnect.\n\nAuto reconnect + balik ke world ada di versi PREMIUM: " .. w)
      break
    end
    if (b()):upper() ~= F:upper() then
      c8("Kelempar dari world", "Bot berhenti karena pindah world.\n\nAuto warp balik ada di versi PREMIUM: " .. w)
      break
    end
    if t8 ~= V8 then
      V8 = t8
      q8("Mati -> nunggu respawn")
      H8()
    end
    if not k8() then
      q8("Jalan ke titik PnB")
      if not s8() then
        q8("Gagal jalan ke titik, coba lagi")
        V(2000)
        goto continue
      end
    end
    do
      q8("PnB jalan")
      local t = false
      for w, Q in ipairs(x) do
        if not G or not k8() or t8 ~= V8 then
          break
        end
        local Y, H = E["spot_x"] + Q["dx"], E["spot_y"] + Q["dy"]
        local W = Z(Y, H)
        if E["enable_place"] and (W == 0 and N(g) > 0) then
          if l8(g, Y, H) and K8(Y, H, g, 700) then
            e["placed"] = e["placed"] + 1
          end
          V(E["delay_place"])
          W = Z(Y, H)
        end
        if W == g then
          t = true
          if E["enable_break"] then
            local w = 0
            while G and (Z(Y, H) == g and w < E["max_hit"]) do
              l8(R, Y, H)
              w = w + 1
              V(E["delay_punch"])
            end
            if Z(Y, H) == g then
              B = B + 1
              L("Tile " .. (Y .. ("," .. (H .. (" nggak pecah setelah " .. (w .. " pukulan"))))))
            else
              e["broken"] = e["broken"] + 1
              B = 0
            end
          end
        elseif W and W ~= 0 then
          local B = Y .. ("," .. H)
          if not j[B] then
            j[B] = true
            L("Tile " .. (B .. (" isinya ID " .. (W .. " (bukan block target), dilewati"))))
          end
        end
      end
      J8()
      if (E["gaia_guard"] or E["tess_guard"]) and os["time"]() - Y >= 300 then
        Y = os["time"]()
        q8("Jaga GAUT")
        u8()
      end
      if B >= n then
        c8("Put and Break Stopped", "Tile nyangkut " .. (n .. "x berturut-turut. Cek delay / tile target."))
      elseif N(g) <= 0 and not t then
        if E["auto_retrieve"] and i8(g) > 0 then
          L("Lanjut PnB setelah retrieve")
        else
          c8(
            "Put and Break Stopped",
            "Tidak ada lagi "
              .. (
                H
                .. (
                  " to break."
                  .. (
                    (E["auto_retrieve"] and "\nGAUT (Tesseract) di world ini juga kosong." or "")
                    .. ("\n\nAuto Set GAUT, jaga GAUT nggak penuh & GAUT world lain ada di PREMIUM: " .. w)
                  )
                )
              )
          )
        end
      end
      V(30)
    end
    ::continue::
  end
  if M == "PnB jalan" then
    q8("Dihentikan")
  end
  B8()
end
local function G8()
  if not C() then
    w8(
      "Butuh Key",
      "Key kosong / salah / kadaluarsa.\n\nAmbil key GRATIS tiap Senin di "
        .. (w .. " channel #key-lite, terus isi di menu Key (Wajib).")
    )
    return false
  end
  if E["block_id"] <= 0 then
    w8("Belum lengkap", "Pilih Block dulu di PnB Setting.")
    return false
  end
  if E["spot_x"] < 0 then
    w8("Belum lengkap", 'Berdiri di titik PnB, terus tekan "Set posisi PnB" di PnB Setting.')
    return false
  end
  if #x == 0 then
    w8("Belum lengkap", "Pilih minimal 1 tile di Tile PnB.")
    return false
  end
  if not E["enable_place"] and not E["enable_break"] then
    w8("Belum lengkap", "Place & Break dua-duanya mati.")
    return false
  end
  if not X() then
    w8("Belum masuk world", "Masuk world PnB dulu.")
    return false
  end
  F = b()
  G = true
  L8 = nil
  W8()
  e = { ["broken"] = 0, ["placed"] = 0, ["started"] = os["time"]() }
  L(
    "START | block " .. (
        E["block_id"] .. (" | titik " .. (E["spot_x"] .. ("," .. (E["spot_y"] .. (" | world " .. F)))))
      )
  )
  runThread(function()
    local B, w = pcall(m8)
    if not B then
      G = false
      pcall(editValue, "pnb_start", false)
      q8("Error")
      L("`4Error: " .. tostring(w))
      B8()
    end
  end)
  return true
end
I()
local function M8(B)
  return B and true or false
end
local function e8()
  local Q = UserInterface["new"]("Auto PnB Lite", "Construction")
  Q:addLabelApp("Auto PnB " .. (t .. (" | " .. B)), "Construction")
  Q:addTooltip("Discord " .. B, w .. "  -  key gratis tiap Senin di #key-lite", "Info", true)
  Q:addToggle("START / STOP", false, "pnb_start", false)
  Q:addDisplayList("Status", "[]", "pnb_status")
  Q:addDivider()
  local Y = Q:addDialog("Key (Wajib)", "Key gratis, ganti tiap Senin", {})
  Q:addChildInputString(Y["menu"], "Key mingguan", E["key"], "Key", "LS-XXXX-XXXX", "Key", "pnb_key")
  Q:addChildButton(Y["menu"], "Cek Key", "pnb_key_check")
  Q:addChildButton(Y["menu"], "Cara Dapet Key", "pnb_key_help")
  local V = Q:addDialog("PnB Setting", "Block, titik PnB, place/break", {})
  Q:addChildItemPicker(
    V["menu"],
    "Block yang di-PnB",
    "Blank",
    tostring(E["block_id"] > 0 and E["block_id"] or ""),
    "pnb_block"
  )
  Q:addChildButton(V["menu"], "Set posisi PnB = posisi sekarang", "pnb_setpos")
  Q:addChildToggle(V["menu"], "Place", M8(E["enable_place"]), "pnb_place", false)
  Q:addChildToggle(V["menu"], "Break", M8(E["enable_break"]), "pnb_break", false)
  Q:addChildButton(V["menu"], "Lihat tile target (console)", "pnb_showtiles")
  Q:addTileSelect("Tile PnB (tengah = karakter)", "{}", "pnb_tiles", 5)
  local j = Q:addDialog("Delay Setting", "Jeda place & pukul", {})
  Q:addChildInputInt(j["menu"], "Delay place (ms)", tostring(E["delay_place"]), "ms", "0 - 2000", "Timer", "pnb_dplace")
  Q:addChildInputInt(
    j["menu"],
    "Delay punch (ms)",
    tostring(E["delay_punch"]),
    "ms",
    "50 - 2000",
    "Timer",
    "pnb_dpunch"
  )
  Q:addChildInputInt(j["menu"], "Max pukulan per tile", tostring(E["max_hit"]), "x", "5 - 200", "Timer", "pnb_maxhit")
  local g = Q:addDialog("Advanced Settings", "Collect", {})
  Q:addChildToggle(g["menu"], "Auto Collect Item (selain gems)", M8(E["auto_collect"]), "pnb_collect", false)
  Q:addChildToggle(g["menu"], "Auto Take Gems (item + gems)", M8(E["collect_gems"]), "pnb_gems", false)
  Q:addChildSlider(g["menu"], "Radius collect (tile)", 0, 3, E["collect_r"], 1, false, "pnb_radius")
  local H = Q:addDialog("GAUT", "Gaia + Unstable Tesseract", {})
  Q:addChildToggle(H["menu"], "Auto Retrieve GAUT", M8(E["auto_retrieve"]), "pnb_retrieve", false)
  Q:addChildTooltip(
    H["menu"],
    "Cara kerja (Lite)",
    "Gaia nampung seed, Tesseract nampung block. Block habis -> ambil dari Tesseract",
    "Info",
    true
  )
  Q:addChildTooltip(
    H["menu"],
    "Syarat (Lite)",
    "GAUT di world PnB & udah di-set manual (Tesseract = block, Gaia = seed)",
    "Info",
    true
  )
  Q:addChildTooltip(
    H["menu"],
    "PREMIUM: Auto Set GAUT kosong",
    "Tesseract = block, Gaia = seed, otomatis",
    "Lock",
    true
  )
  Q:addChildToggle(
    H["menu"],
    "Jaga Gaia (tiap 5 mnt: retrieve -> drop semua)",
    M8(E["gaia_guard"]),
    "pnb_gguard",
    false
  )
  Q:addChildToggle(
    H["menu"],
    "Jaga Tesseract (tiap 5 mnt, stok tas 200 disimpen)",
    M8(E["tess_guard"]),
    "pnb_tguard",
    false
  )
  Q:addChildTooltip(
    H["menu"],
    "PREMIUM: Jaga GAUT pakai batas isi",
    "Atur kapan dikosongin, sisa berapa, titik drop / World Drop",
    "Lock",
    true
  )
  Q:addChildTooltip(H["menu"], "PREMIUM: GAUT di world lain", "Warp ambil block, balik lagi ke PnB", "Lock", true)
  Q:addChildTooltip(
    H["menu"],
    "PREMIUM: Auto Reconnect + warp balik",
    "Bot jalan terus walau DC / kelempar",
    "Lock",
    true
  )
  Q:addChildTooltip(H["menu"], "Order Premium", w, "Storefront", true)
  Q:addDivider()
  Q:addButton("Simpan config (.txt)", "pnb_save")
  return Q
end
local function z8(B)
  return B == true or B == 1 or B == "1" or B == "true"
end
local function F8(B, w, t, Q)
  B = tonumber(B)
  if not B then
    return Q
  end
  return math["max"](w, math["min"](t, g(B)))
end
local function y8()
  L("Tile target (P = karakter, # = dipukul):")
  local B = {}
  for w, t in ipairs(x) do
    B[t["dx"] .. ("," .. t["dy"])] = true
  end
  for w = -2, 2, 1 do
    local t = {}
    for Q = -2, 2, 1 do
      t[#t + 1] = (Q == 0 and w == 0) and "P" or (B[Q .. ("," .. w)] and "#" or ".")
    end
    L("   " .. table["concat"](t, " "))
  end
end
local function a8(B, t, Q)
  local Y = true
  if t == "pnb_start" then
    Y = false
    if z8(Q) then
      if not G and not G8() then
        pcall(editValue, "pnb_start", false)
      end
    else
      if G then
        G = false
        q8("Dihentikan")
        L("STOP")
      end
    end
  elseif t == "pnb_key" then
    E["key"] = U(Q)
    W(C() and "Key valid" or "Key belum valid")
  elseif t == "pnb_key_check" then
    Y = false
    w8(
      C() and "Key valid" or "Key belum valid",
      C() and "Key minggu ini OK, tinggal START."
        or ("Ambil key GRATIS di " .. (w .. " channel #key-lite (ganti tiap Senin)."))
    )
  elseif t == "pnb_key_help" then
    Y = false
    w8(
      "Cara Dapet Key",
      "1. Join Discord "
        .. (
          w
          .. "\n2. Buka channel #key-lite\n3. Copy key minggu ini (LS-XXXX-XXXX)\n4. Paste di menu Key (Wajib)\n\nKey ganti tiap Senin 00:00 WIB."
        )
    )
  elseif t == "pnb_block" then
    local B = m(Q)
    if B and B > 0 then
      E["block_id"] = B
      W("Block: " .. c(B))
    else
      Y = false
    end
  elseif t == "pnb_setpos" then
    local B, w = o()
    if B then
      E["spot_x"], E["spot_y"] = B, w
      W("Titik PnB: " .. (B .. ("," .. w)))
    else
      Y = false
    end
  elseif t == "pnb_tiles" then
    local B, w = P(Q)
    L("Tile Select mentah: " .. S(Q))
    if w > 0 then
      E["tiles"] = B
      I()
      y8()
      W(w .. " tile dipilih, cek gambar di console")
    else
      L("Tile Select kosong / format nggak kebaca. Kirim baris 'mentah' di atas ke admin.")
      Y = false
    end
  elseif t == "pnb_showtiles" then
    Y = false
    y8()
    W("Tile target ada di console")
  elseif t == "pnb_place" then
    E["enable_place"] = z8(Q)
  elseif t == "pnb_break" then
    E["enable_break"] = z8(Q)
  elseif t == "pnb_dplace" then
    E["delay_place"] = F8(Q, 0, 2000, E["delay_place"])
  elseif t == "pnb_dpunch" then
    E["delay_punch"] = F8(Q, 50, 2000, E["delay_punch"])
  elseif t == "pnb_maxhit" then
    E["max_hit"] = F8(Q, 5, 200, E["max_hit"])
  elseif t == "pnb_collect" then
    E["auto_collect"] = z8(Q)
  elseif t == "pnb_gems" then
    E["collect_gems"] = z8(Q)
  elseif t == "pnb_radius" then
    E["collect_r"] = F8(Q, 0, 3, E["collect_r"])
  elseif t == "pnb_retrieve" then
    E["auto_retrieve"] = z8(Q)
  elseif t == "pnb_gguard" then
    E["gaia_guard"] = z8(Q)
  elseif t == "pnb_tguard" then
    E["tess_guard"] = z8(Q)
  elseif t == "pnb_save" then
    Y = false
    W(r() and "Config disimpan" or "Config gagal disimpan")
  else
    Y = false
  end
  if Y then
    r()
  end
end
local BZ = false
local wZ = { ["pnb_status"] = true, ["pnb_popup"] = true }
local tZ = math["huge"]
local function QZ(B, w, t)
  if BZ or type(w) ~= "string" or w:sub(1, 4) ~= "pnb_" or wZ[w] then
    return
  end
  if os["time"]() < tZ then
    return
  end
  BZ = true
  local Q, Y = pcall(a8, B, w, t)
  BZ = false
  if not Q then
    L("`4Error menu (" .. (w .. ("): " .. tostring(Y))))
  end
  B8()
end
p()
I()
local YZ = e8()
local function VZ()
  removeHook("onDraw")
  runCoroutine(function()
    V(3000)
    pcall(addCategory, Q, "Storefront")
    addIntoModule(YZ:generateJSON(), Q)
    V(2500)
    tZ = os["time"]()
    B8()
  end)
end
addHook(VZ, "onDraw")
addHook(QZ, "onValue")
addHook(p8, "onVariant")
applyHook()
L(B .. (" Auto PnB " .. (t .. (" loaded | " .. w))))
L("Config: " .. (v and ("dimuat dari " .. v) or "belum ada, pakai default"))
