local D = {
  ["on"] = false,
  ["cancel"] = false,
  ["src"] = "",
  ["doBg"] = true,
  ["doFg"] = true,
  ["doGlue"] = true,
  ["glueId"] = 1866,
  ["glueBit"] = 2048,
  ["skipTree"] = true,
  ["black"] = "Bedrock,White Door",
  ["delay"] = 250,
  ["reach"] = 3,
  ["verbose"] = false,
}
local T, S = pcall(require, "preferences")
local z = T and S:new("autocopyworld.json") or nil
local function n(D, T)
  return tonumber(z and z:get(D, tostring(T)) or T) or T
end
local function w(D, T)
  local S = z and z:get(D, T or "") or T or ""
  return tostring(S or "")
end
local function J(D, T)
  if z then
    z:set(D, tostring(T))
    z:save()
  end
end
D["src"] = (w("src")):upper()
D["delay"] = n("delay", D["delay"])
D["doBg"] = w("doBg", "1") ~= "0"
D["doFg"] = w("doFg", "1") ~= "0"
D["skipTree"] = w("skipTree", "1") ~= "0"
D["doGlue"] = w("doGlue", "1") ~= "0"
D["black"] = w("black", D["black"])
D["glueId"] = n("glueId", D["glueId"])
D["glueBit"] = n("glueBit", D["glueBit"])
local function I(D, T)
  return math["floor"]((D or 0) / T) % 2 == 1
end
local function k(D)
  LogToConsole("`8[`2RamStore`8] `0" .. D)
end
local function c(T)
  if D["verbose"] then
    k(T)
  end
end
local function y()
  if D["cancel"] or not D["on"] then
    error("__STOP__")
  end
end
local b = (tostring(RS_API or "https://api.ztoretopup.com")):gsub("/+$", "")
local Q = (tostring(RS_DISCORD_ID or "")):gsub("%D", "")
if Q == "" and getDiscordID then
  local D, T = pcall(getDiscordID)
  if D and T then
    Q = (tostring(T)):gsub("%D", "")
  end
end
local d = false
ACW = { ["ok"] = d, ["exp"] = d and (os["time"]() + 3153600000) or 0, ["why"] = "" }
if RS_DISCORD_ID and (tonumber(RS_EXPIRES) or 0) > os["time"]() then
  ACW["ok"], ACW["exp"] = true, tonumber(RS_EXPIRES)
end
local function i()
  if d then
    ACW["ok"] = true
    return true
  end
  if Q == "" then
    ACW["ok"], ACW["why"] = false, "Login Discord dulu di Growlauncher"
    return ACW["ok"]
  end
  local D
  for T = 1, 3, 1 do
    local S, z = pcall(fetch, b .. ("/check?id=" .. (Q .. "&s=AUTO_COPYWORLD")))
    if S and (type(z) == "string" and z ~= "") then
      D = z
      break
    end
    sleep(1000 * T)
  end
  if not D then
    ACW["why"] = "Server RamStore tidak bisa dihubungi"
    return ACW["ok"]
  end
  local T = D:match("OK|(%d+)")
  if T then
    ACW["ok"], ACW["exp"], ACW["why"] = true, tonumber(T) or 0, ""
  elseif D:find("NO|", 1, true) then
    ACW["ok"], ACW["why"] = false, "Akses tidak aktif. Beli Auto Copy World di Discord RamStore"
  end
  return ACW["ok"]
end
local function X()
  local D = getLocal()
  if not D then
    return nil
  end
  return D["posX"] // 32, D["posY"] // 32, D
end
local function m(D)
  if not D or D <= 0 then
    return 0
  end
  local T, S = pcall(function()
    return growtopia["checkInventoryCount"](D)
  end)
  if T and type(S) == "number" then
    return S
  end
  local z, n = pcall(getInventory)
  if z and type(n) == "table" then
    for T, S in pairs(n) do
      if S["id"] == D then
        return S["amount"] or 0
      end
    end
  end
  return 0
end
local B = {}
local function K(D)
  if B[D] ~= nil then
    return B[D] or ("ID " .. D)
  end
  local T
  local S, z = pcall(function()
    return growtopia["getItemName"](D)
  end)
  if S and (type(z) == "string" and z ~= "") then
    T = z
  end
  if not T then
    local S, z = pcall(getItemInfoByID, D)
    if S and (type(z) == "table" and z["name"]) then
      T = tostring(z["name"])
    end
  end
  B[D] = T or false
  return T or ("ID " .. D)
end
local function V()
  local D, T = pcall(GetWorldName)
  if D and (T and T ~= "") then
    return (tostring(T)):upper()
  end
  return ""
end
local function j(D, T)
  local S, z = pcall(getTile, D, T)
  if S and z then
    return z["fg"] or 0, z["bg"] or 0, z["flag"] or z["flags"] or 0
  end
  return nil, nil, nil
end
local function F(D, T)
  for S = 1, 2, 1 do
    y()
    local z, n = X()
    if z == D and n == T then
      return true
    end
    pcall(FindPath, D, T)
    local w = 0
    while w < 40 do
      sleep(100)
      w = w + 1
      z, n = X()
      if z == D and n == T then
        return true
      end
    end
  end
  return false
end
local Y = 4
local function x(D, T, S)
  local z, n, w = X()
  if not w then
    return false
  end
  if math["abs"](z - T) > Y or math["abs"](n - S) > Y then
    return false
  end
  if z == T and n == S then
    return false
  end
  sendPacketRaw(false, { ["type"] = 3, ["value"] = D, ["x"] = w["posX"], ["y"] = w["posY"], ["px"] = T, ["py"] = S })
  return true
end
local t = {
  [0] = true,
  [6] = true,
  [8] = true,
  [3760] = true,
  [202] = true,
  [204] = true,
  [206] = true,
  [242] = true,
  [1796] = true,
  [4802] = true,
  [4994] = true,
  [5814] = true,
  [7188] = true,
}
local N = { ["ids"] = {}, ["names"] = {}, ["cache"] = {} }
local function E()
  N["ids"], N["names"], N["cache"] = {}, {}, {}
  for D in (tostring(D["black"] or "")):gmatch("[^,;]+") do
    local T = (D:gsub("^%s+", "")):gsub("%s+$", "")
    if tonumber(T) then
      N["ids"][tonumber(T)] = true
    elseif T ~= "" then
      N["names"][#N["names"] + 1] = T:lower()
    end
  end
end
E()
local function L(D)
  if N["ids"][D] then
    return true
  end
  if N["cache"][D] ~= nil then
    return N["cache"][D]
  end
  local T = (K(D)):lower()
  local S = false
  for D, z in ipairs(N["names"]) do
    if T:find(z, 1, true) then
      S = true
      break
    end
  end
  N["cache"][D] = S
  return S
end
local function U(T)
  if not T or T <= 0 or t[T] then
    return true
  end
  if D["skipTree"] and T % 2 == 1 then
    return true
  end
  if L(T) then
    return true
  end
  return false
end
local function u()
  local T = V()
  if T == "" then
    k("`4Masuk world dulu")
    return
  end
  local S, z = pcall(getTiles)
  if not S or type(z) ~= "table" then
    k("`4Gagal baca world, coba lagi")
    return
  end
  local n, c, y, b, Q = {}, 0, 0, 0, 0
  nGlue = 0
  for T, S in pairs(z) do
    local z, w = S["x"] or (S["pos"] and S["pos"]["x"]), S["y"] or (S["pos"] and S["pos"]["y"])
    if z and w then
      local T, J, k = S["fg"] or 0, S["bg"] or 0, S["flag"] or S["flags"] or 0
      if T > 0 or J > 0 then
        n[#n + 1] = z .. ("," .. (w .. ("," .. (T .. ("," .. (J .. ("," .. k)))))))
        if I(k, D["glueBit"]) and not U(T) then
          nGlue = (nGlue or 0) + 1
        end
        if not U(T) then
          c = c + 1
        end
        if not U(J) then
          y = y + 1
        end
      end
      if z > b then
        b = z
      end
      if w > Q then
        Q = w
      end
    end
  end
  J("L_" .. T, table["concat"](n, ";"))
  local d = {}
  for D in (w("list")):gmatch("[^,]+") do
    if D ~= T then
      d[#d + 1] = D
    end
  end
  d[#d + 1] = T
  while #d > 10 do
    table["remove"](d, 1)
  end
  J("list", table["concat"](d, ","))
  D["src"] = T
  J("src", T)
  k(
    "`9"
      .. (
        T .. (
          " `2kesimpen! `0" .. (
            c .. (" block, " .. (y .. (" bg" .. ((nGlue or 0) > 0 and (", " .. (nGlue .. " glue")) or ""))))
          )
        )
      )
  )
end
local function G(D)
  local T = w("L_" .. D)
  local S = {}
  for D in T:gmatch("[^;]+") do
    local T, z, n, w, J = D:match("^(%d+),(%d+),(%d+),(%d+),?(%d*)$")
    if T then
      S[#S + 1] =
        { ["x"] = tonumber(T), ["y"] = tonumber(z), ["fg"] = tonumber(n), ["bg"] = tonumber(w), ["fl"] = tonumber(J)
          or 0 }
    end
  end
  return S
end
local function g(T)
  local S = {}
  for T, z in ipairs(T) do
    if D["doBg"] and not U(z["bg"]) then
      S[#S + 1] = { ["x"] = z["x"], ["y"] = z["y"], ["id"] = z["bg"], ["layer"] = "bg" }
    end
  end
  for T, z in ipairs(T) do
    if D["doFg"] and not U(z["fg"]) then
      S[#S + 1] = { ["x"] = z["x"], ["y"] = z["y"], ["id"] = z["fg"], ["layer"] = "fg", ["fl"] = z["fl"] or 0 }
    end
  end
  local z, n = {}, {}
  for D, T in ipairs(S) do
    z[T["y"]] = true
  end
  local w = {}
  for D in pairs(z) do
    w[#w + 1] = D
  end
  table["sort"](w)
  for D, T in ipairs(w) do
    n[T] = D
  end
  for D, T in ipairs(S) do
    T["dir"] = (n[T["y"]] % 2 == 1) and 1 or -1
  end
  table["sort"](S, function(D, T)
    if D["y"] ~= T["y"] then
      return D["y"] < T["y"]
    end
    if D["x"] ~= T["x"] then
      if n[D["y"]] % 2 == 1 then
        return D["x"] < T["x"]
      end
      return D["x"] > T["x"]
    end
    return D["layer"] == "bg" and T["layer"] ~= "bg"
  end)
  return S
end
local function A(D)
  local T, S = j(D["x"], D["y"])
  if D["layer"] == "bg" then
    return S == D["id"]
  end
  return T == D["id"]
end
local function a(D)
  local T, S = j(D["x"], D["y"])
  if D["layer"] == "bg" then
    return (S or 0) ~= 0 and S ~= D["id"]
  end
  return (T or 0) ~= 0 and T ~= D["id"]
end
local function C(D, T, S, z)
  if D < 0 or T < 0 then
    return false
  end
  if D == S and T == z then
    return false
  end
  return j(D, T) == 0
end
local function W(D, T, S)
  S = S or 1
  local z, n = X()
  local w = { { 0, 1 }, { S, 0 }, { -S, 0 }, { 0, -1 }, { S, 1 }, { -S, 1 } }
  for S, w in ipairs(w) do
    local J, I = D + w[1], T + w[2]
    if z == J and n == I then
      return true
    end
    if C(J, I, D, T) and F(J, I) then
      return true
    end
  end
  local J = {}
  for S = -3, 3, 1 do
    for z = -3, 3, 1 do
      local n, w = D + z, T + S
      if C(n, w, D, T) then
        J[#J + 1] = { ["x"] = n, ["y"] = w, ["d"] = math["abs"](z) + math["abs"](S) }
      end
    end
  end
  table["sort"](J, function(D, T)
    return D["d"] < T["d"]
  end)
  for D = 1, math["min"](#J, 8), 1 do
    if F(J[D]["x"], J[D]["y"]) then
      return true
    end
  end
  return false
end
local function p(D)
  return D["posX"] or (D["pos"] and D["pos"]["x"]), D["posY"] or (D["pos"] and D["pos"]["y"])
end
local function e()
  local D = {}
  local T, S = pcall(getObjectList)
  if not T or type(S) ~= "table" then
    return D
  end
  for T, S in pairs(S) do
    if S["itemid"] then
      D[S["itemid"]] = (D[S["itemid"]] or 0) + (S["amount"] or 1)
    end
  end
  return D
end
local function q(D)
  local T, S = pcall(getObjectList)
  if not T or type(S) ~= "table" then
    return false
  end
  local z = false
  for T, S in pairs(S) do
    if S["itemid"] == D then
      z = true
      break
    end
  end
  if not z then
    return false
  end
  c("Ambil stok `8(" .. (D .. ")"))
  pcall(editToggle, "Anticollect", false)
  local n, w = {}, 0
  while m(D) < 200 and w < 30 do
    y()
    T, S = pcall(getObjectList)
    if not T or type(S) ~= "table" then
      break
    end
    local z, J, I = X()
    if not I then
      break
    end
    local k, c
    for T, S in pairs(S) do
      local z, w = p(S)
      if S["itemid"] == D and (not n[S["id"]] and z) then
        local D = math["abs"](z - I["posX"]) + math["abs"](w - I["posY"])
        if not c or D < c then
          k, c = { ["o"] = S, ["x"] = z, ["y"] = w }, D
        end
      end
    end
    if not k then
      break
    end
    local b = m(D)
    if F(math["floor"]((k["x"] + 8) / 32), math["floor"]((k["y"] + 8) / 32)) then
      local T = 0
      while m(D) <= b and T < 10 do
        sleep(100)
        T = T + 1
      end
      if m(D) <= b then
        sendPacketRaw(false, { ["type"] = 11, ["value"] = k["o"]["id"], ["x"] = k["x"], ["y"] = k["y"] })
        T = 0
        while m(D) <= b and T < 10 do
          sleep(100)
          T = T + 1
        end
      end
    end
    if m(D) <= b then
      n[k["o"]["id"]] = true
    end
    w = w + 1
    sleep(150)
  end
  pcall(editToggle, "Anticollect", true)
  return m(D) > 0
end
local function Z(T)
  for S = 1, 3, 1 do
    y()
    if A(T) then
      return "ok"
    end
    if m(T["id"]) <= 0 and not q(T["id"]) then
      return "habis"
    end
    if not W(T["x"], T["y"], T["dir"]) then
      return "jauh"
    end
    if not x(T["id"], T["x"], T["y"]) then
      return "jauh"
    end
    local z = 0
    while not A(T) and z < 12 do
      sleep(100)
      z = z + 1
    end
    sleep(D["delay"])
    if A(T) then
      return "ok"
    end
  end
  return "gagal"
end
local R = false
local function O(T)
  if not D["doGlue"] or not I(T["fl"] or 0, D["glueBit"]) then
    return "skip"
  end
  local S, z, n = j(T["x"], T["y"])
  if S ~= T["id"] then
    return "skip"
  end
  if I(n, D["glueBit"]) then
    return "ok"
  end
  if m(D["glueId"]) <= 0 and not q(D["glueId"]) then
    return "habis"
  end
  if not x(D["glueId"], T["x"], T["y"]) then
    if not (W(T["x"], T["y"], T["dir"]) and x(D["glueId"], T["x"], T["y"])) then
      return "gagal"
    end
  end
  local w, k = 0, n
  repeat
    sleep(100)
    w = w + 1
    z, z, k = j(T["x"], T["y"])
  until k ~= n or w >= 12
  sleep(D["delay"])
  if I(k, D["glueBit"]) then
    return "ok"
  end
  if k ~= n and not R then
    local T = math["abs"](k - n)
    c("`8bit glue " .. (D["glueBit"] .. (" > " .. T)))
    D["glueBit"], R = T, true
    J("glueBit", T)
    if I(k, T) then
      return "ok"
    end
  end
  return "gagal"
end
function glueStep(T)
  local S = {}
  for T, z in ipairs(T) do
    if z["fg"] > 0 and I(z["fl"], D["glueBit"]) then
      S[#S + 1] = z
    end
  end
  if #S == 0 then
    return
  end
  c("`8cek glue " .. (#S .. " block"))
  local z, n, w, b = 0, 0, 0, false
  for S, Q in ipairs(S) do
    y()
    local d, i, X = j(Q["x"], Q["y"])
    if d ~= Q["fg"] then
      n = n + 1
    elseif I(X, D["glueBit"]) then
      z = z + 1
    elseif m(D["glueId"]) <= 0 and not q(D["glueId"]) then
      k("`4Glue habis!")
      break
    elseif W(Q["x"], Q["y"]) and x(D["glueId"], Q["x"], Q["y"]) then
      local S, n = 0, X
      repeat
        sleep(100)
        S = S + 1
        i, i, n = j(Q["x"], Q["y"])
      until n ~= X or S >= 12
      sleep(D["delay"])
      if I(n, D["glueBit"]) then
        z = z + 1
      elseif n ~= X and not b then
        local S = math["abs"](n - X)
        c("`8bit glue " .. (D["glueBit"] .. (" > " .. S)))
        D["glueBit"], b = S, true
        J("glueBit", S)
        if not I(Q["fl"], S) then
          if x(D["glueId"], Q["x"], Q["y"]) then
            sleep(D["delay"])
          end
        end
        return glueStep(T)
      else
        w = w + 1
      end
    else
      w = w + 1
    end
  end
  if w > 0 then
    k("`4" .. (w .. " glue gagal nempel"))
  else
    c("`8glue aman")
  end
end
local function o()
  local T, S = X()
  if not T then
    return
  end
  local z, n, w = j(T, S + 1)
  k(
    "Bawah kaki: `9"
      .. (
        K(z or 0) .. (
          "`0, glue " .. ((I(w, D["glueBit"]) and "`2ada" or "`4nggak") .. (" `8(flag " .. (tostring(w) .. ")")))
        )
      )
  )
end
local function h()
  if D["src"] == "" then
    k("`4Scan world asalnya dulu")
    return
  end
  local T = G(D["src"])
  if #T == 0 then
    k("`4Scan `9" .. (D["src"] .. "`4 kosong, scan ulang"))
    return
  end
  if V() == D["src"] then
    k("`4Ini masih world asal, pindah ke world tujuan")
    return
  end
  local S = g(T)
  local z = {}
  for D, T in ipairs(S) do
    if not A(T) and not a(T) then
      z[T["id"]] = (z[T["id"]] or 0) + 1
    end
  end
  local n = {}
  local w = e()
  for D, T in pairs(z) do
    local S = m(D) + (w[D] or 0)
    if S < T then
      n[#n + 1] = K(D) .. (" " .. (S .. ("/" .. T)))
    end
  end
  if #n > 0 then
    k("`6" .. (#n .. " block kurang `8(dilewati, cek /item)"))
  end
  k("Copy `9" .. (D["src"] .. ("`0, " .. (#S .. " tile"))))
  local J = { ["ok"] = 0, ["skip"] = 0, ["habis"] = 0, ["gagal"] = 0, ["glue"] = 0 }
  local b = {}
  for T, z in ipairs(S) do
    y()
    if A(z) then
      J["ok"] = J["ok"] + 1
      if z["layer"] == "fg" and (O(z) == "ok" and I(z["fl"] or 0, D["glueBit"])) then
        J["glue"] = J["glue"] + 1
      end
    elseif a(z) then
      J["skip"] = J["skip"] + 1
    else
      local T = Z(z)
      if T == "ok" then
        J["ok"] = J["ok"] + 1
        if z["layer"] == "fg" then
          local T = O(z)
          if T == "ok" and I(z["fl"] or 0, D["glueBit"]) then
            J["glue"] = J["glue"] + 1
          elseif T == "habis" then
            J["glueHabis"] = true
          elseif T == "gagal" then
            c("`4Glue gagal `8(" .. (z["x"] .. ("," .. (z["y"] .. ")"))))
          end
        end
      elseif T == "habis" then
        J["habis"] = J["habis"] + 1
        b[z["id"]] = (b[z["id"]] or 0) + 1
      else
        J["gagal"] = J["gagal"] + 1
        c("`4Gagal " .. (K(z["id"]) .. (" `8(" .. (z["x"] .. ("," .. (z["y"] .. ")"))))))
      end
    end
    if T % 200 == 0 then
      k("`8" .. (T .. ("/" .. #S)))
    end
  end
  if J["glueHabis"] then
    k("`4Glue habis!")
  end
  if D["doGlue"] then
    glueStep(T)
  end
  local Q = {}
  if J["glue"] > 0 then
    Q[#Q + 1] = J["glue"] .. " glue"
  end
  if J["skip"] > 0 then
    Q[#Q + 1] = "`6" .. (J["skip"] .. " kehalang`0")
  end
  if J["habis"] > 0 then
    Q[#Q + 1] = "`6" .. (J["habis"] .. " kurang item`0")
  end
  if J["gagal"] > 0 then
    Q[#Q + 1] = "`4" .. (J["gagal"] .. " gagal`0")
  end
  k("`2Done! `0" .. (J["ok"] .. (" tile" .. (#Q > 0 and (", " .. table["concat"](Q, ", ")) or ""))))
  local d = 0
  for D in pairs(b) do
    d = d + 1
  end
  if d > 0 then
    k("`6" .. (d .. " block masih kurang, cek `9/item"))
  end
end
local P = false
function copyWorldLoop()
  runThread(function()
    while P do
      sleep(200)
    end
    if not D["on"] then
      return
    end
    if not ACW["ok"] or (ACW["exp"] > 0 and ACW["exp"] <= os["time"]()) then
      if not (i() and ACW["exp"] > os["time"]()) then
        D["on"] = false
        pcall(editToggle, "cw_on", false)
        k("`4" .. (ACW["why"] ~= "" and ACW["why"] or "Akses tidak aktif. Beli Auto Copy World di Discord RamStore"))
        return
      end
    end
    D["cancel"], P = false, true
    pcall(editToggle, "Anticollect", true)
    local T, S = pcall(getValue, 0, "ModFly")
    pcall(editToggle, "ModFly", true)
    local z, n = pcall(h)
    if not (T and S == true) then
      pcall(editToggle, "ModFly", false)
    end
    if not z and not (tostring(n)):find("__STOP__") then
      k("`4Error: " .. tostring(n))
    end
    P = false
    D["on"] = false
    pcall(editToggle, "cw_on", false)
  end)
end
local function s()
  local T = {}
  if D["src"] == "" then
    return T
  end
  local S = G(D["src"])
  local z = {}
  for D, T in ipairs(g(S)) do
    z[T["id"]] = (z[T["id"]] or 0) + 1
  end
  if D["doGlue"] then
    for T, S in ipairs(S) do
      if S["fg"] > 0 and I(S["fl"], D["glueBit"]) then
        z[D["glueId"]] = (z[D["glueId"]] or 0) + 1
      end
    end
  end
  local n = (V() ~= D["src"]) and e() or {}
  for D, S in pairs(z) do
    T[#T + 1] = { ["id"] = D, ["n"] = S, ["have"] = m(D) + (n[D] or 0) }
  end
  table["sort"](T, function(D, T)
    return D["n"] > T["n"]
  end)
  return T
end
local function f()
  if D["src"] == "" then
    k("`4Belum ada hasil scan, ketik `9/copy`4 di world asal")
    return
  end
  local T = s()
  local S = 0
  for D, T in ipairs(T) do
    if T["have"] < T["n"] then
      S = S + 1
    end
  end
  local z = {
    "set_default_color|`o",
    "add_label_with_icon|big|`wCopy World``|left|1866|",
    "add_textbox|`9"
      .. (
        D["src"]
        .. (
          "`` - " .. (
            #T .. (" jenis block" .. ((S > 0 and (", `4" .. (S .. " kurang``")) or ", `2semua cukup``") .. "|left|"))
          )
        )
      ),
    "add_spacer|small|",
    "text_scaling_string|Defibrillators|",
  }
  for D, T in ipairs(T) do
    if D > 120 then
      break
    end
    z[#z + 1] = "add_button_with_icon|cwi_"
      .. (
        T["id"] .. (
          "|" .. ((T["have"] < T["n"] and "`4" or "`2") .. (T["n"] .. ("``|staticBlueFrame|" .. (T["id"] .. "||"))))
        )
      )
  end
  z[#z + 1] = "add_button_with_icon||END_LIST|noflags|0||"
  z[#z + 1] = "end_dialog|cw_need|Close||"
  z[#z + 1] = "add_quick_exit|"
  pcall(sendVariant, { ["v1"] = "OnDialogRequest", ["v2"] = table["concat"](z, "\n") })
end
local function v(D)
  local T = type(D["addDialog"]) == "function"
    and (
      type(D["addChildInputString"]) == "function"
      and (type(D["addChildToggle"]) == "function" and type(D["addChildTooltip"]) == "function")
    )
  local S = {}
  function S.settings(S)
    if T then
      local T, z = pcall(D["addDialog"], D, S, "Klik untuk buka pengaturan", {})
      if T and (type(z) == "table" and z["menu"]) then
        return z["menu"]
      end
    end
    D:addDivider()
    D:addLabel(S)
  end
  function S.tog(T, S, z, n)
    if T then
      D:addChildToggle(T, S, z, n, false)
    else
      D:addToggle(S, z, n, false)
    end
  end
  function S.inp(T, S, z, n, w, J)
    if T then
      D:addChildInputString(T, S, z, n, w, "Info", J)
    else
      D:addInputString(S, z, n, w, "Info", J)
    end
  end
  function S.tip(T, S, z)
    if T then
      D:addChildTooltip(T, S, z, "Info", false)
    else
      D:addTooltip(S, z, "Info", false)
    end
  end
  return S
end
local M = UserInterface["new"]("AutoCopyWorld", "Article")
M:addLabelApp("AutoCopyWorld", "Article")
M:addTooltip(
  "Information",
  "/copy di world asal, /paste di world tujuan, /stop buat berhenti, /item lihat block yang dibutuhin. // RamStore by Akram",
  "Info",
  false
)
local l = v(M)
local H = l["settings"]("Copy Setting")
l["inp"](H, "World Sumber (hasil scan)", D["src"], "kosong = scan terakhir", "NAMA WORLD", "cw_src")
l["tog"](H, "Copy Background", D["doBg"], "cw_doBg")
l["tog"](H, "Copy Block Depan", D["doFg"], "cw_doFg")
l["tog"](H, "Lewati Seed / Pohon", D["skipTree"], "cw_skipTree")
l["tog"](H, "Copy Glue", D["doGlue"], "cw_doGlue")
l["inp"](
  H,
  "Blacklist Item (nama / ID)",
  D["black"],
  "pisah koma, contoh: Bedrock,White Door,242",
  "Bedrock,White Door",
  "cw_black"
)
l["inp"](H, "ID Block Glue", tostring(D["glueId"]), "default 1866", "1866", "cw_glueId")
l["inp"](H, "Delay Taruh (ms)", tostring(D["delay"]), "jeda antar block", "250", "cw_delay")
local function r(T, S)
  if T == "cw_on" then
    D["on"] = S and true or false
    if not D["on"] then
      D["cancel"] = true
      k("`4Stop")
      return
    end
    copyWorldLoop()
  elseif T == "cw_scan" then
    k("Scan `9" .. (V() .. "`0..."))
    runThread(function()
      if not ACW["ok"] then
        i()
      end
      if not ACW["ok"] then
        k("`4" .. (ACW["why"] ~= "" and ACW["why"] or "Akses tidak aktif"))
        return
      end
      u()
    end)
  elseif T == "cw_show" then
    f()
  elseif T == "cw_src" then
    D["src"] = ((tostring(S or "")):gsub("%s", "")):upper()
    J("src", D["src"])
  elseif T == "cw_check" then
    o()
  elseif T == "cw_black" then
    D["black"] = tostring(S or "")
    J("black", D["black"])
    E()
    k("Blacklist: " .. (D["black"] ~= "" and D["black"] or "-"))
  elseif T == "cw_glueId" then
    local T = tonumber(((tostring(S or "")):gsub("%s", "")))
    if T and T > 0 then
      D["glueId"] = math["floor"](T)
      J("glueId", D["glueId"])
    end
  elseif T == "cw_doBg" or T == "cw_doFg" or T == "cw_skipTree" or T == "cw_doGlue" then
    local z = T:sub(4)
    D[z] = S and true or false
    J(z, D[z] and "1" or "0")
  elseif T == "cw_verbose" then
    D["verbose"] = S and true or false
  elseif T == "cw_delay" then
    local T = tonumber(((tostring(S or "")):gsub("%s", "")))
    if T and T >= 0 then
      D["delay"] = math["floor"](T)
      J("delay", D["delay"])
    end
  end
end
local Dk = {}
local function Tk(D, T)
  D = tostring(D or "")
  if D:sub(1, 3) ~= "cw_" then
    return
  end
  local S = D .. ("=" .. tostring(T))
  local z = os["clock"]()
  if Dk[S] and z - Dk[S] < 0.3 then
    return
  end
  Dk[S] = z
  local n, w = pcall(r, D, T)
  if not n then
    k("`4Error " .. (D .. (": " .. tostring(w))))
  end
end
local Sk = false
local function zk(D, T, S)
  Tk(T, S)
end
if type(addHook) == "function" then
  Sk = pcall(addHook, zk, "onValue")
end
if not Sk and type(AddHook) == "function" then
  Sk = pcall(AddHook, zk, "OnValue")
end
if type(setOnValue) == "function" then
  for D, T in ipairs({
    "cw_on",
    "cw_scan",
    "cw_show",
    "cw_check",
    "cw_src",
    "cw_glueId",
    "cw_doBg",
    "cw_doFg",
    "cw_skipTree",
    "cw_doGlue",
    "cw_verbose",
    "cw_delay",
    "cw_black",
  }) do
    pcall(setOnValue, T, function(...)
      local D = { ... }
      local S = D[#D]
      if #D >= 2 and D[1] == T then
        S = D[2]
      end
      Tk(T, S)
    end)
  end
end
local nk = OnValue
function OnValue(D, T, S)
  if (tostring(T)):sub(1, 3) == "cw_" then
    return Tk(T, S)
  end
  if nk then
    return nk(D, T, S)
  end
end
local function wk()
  if D["on"] then
    k("`6Lagi jalan, ketik `9/stop`6 buat berhenti")
    return
  end
  D["on"] = true
  pcall(editToggle, "cw_on", true)
  copyWorldLoop()
end
local function Jk()
  if not D["on"] then
    k("Nggak ada yang jalan")
    return
  end
  D["on"], D["cancel"] = false, true
  pcall(editToggle, "cw_on", false)
  k("`4Stop")
end
local Ik = {
  ["/copy"] = function()
    runThread(function()
      if not ACW["ok"] then
        i()
      end
      if not ACW["ok"] then
        k("`4" .. (ACW["why"] ~= "" and ACW["why"] or "Akses tidak aktif"))
        return
      end
      k("Scan `9" .. (V() .. "`0..."))
      u()
      if D["src"] ~= "" then
        sleep(300)
        f()
      end
    end)
  end,
  ["/paste"] = wk,
  ["/stop"] = Jk,
  ["/item"] = f,
  ["/cw"] = function()
    k("`9/copy `0scan world ini  `9/paste `0build di sini  `9/stop")
    k("`9/item `0lihat block + glue yang dibutuhin")
  end,
}
local function kk(...)
  local D
  for T, S in ipairs({ ... }) do
    if type(S) == "string" then
      D = S
      break
    end
  end
  if not D then
    return false
  end
  if D:find("dialog_name|cw_need", 1, true) then
    if D:find("buttonClicked|cw_paste", 1, true) then
      wk()
    end
    return true
  end
  local T = D:match("action|input\n|text|([^\n]*)")
  if not T then
    return false
  end
  local S = T:match("^%s*(/%S+)")
  local z = S and Ik[S:lower()]
  if not z then
    return false
  end
  local n, w = pcall(z)
  if not n then
    k("`4Error " .. (S .. (": " .. tostring(w))))
  end
  return true
end
local ck = false
if type(addHook) == "function" then
  ck = pcall(addHook, kk, "onSendPacket")
end
if not ck and type(AddHook) == "function" then
  pcall(AddHook, kk, "OnSendPacket")
end
pcall(applyHook)
runCoroutine(function()
  sleep(1000)
  addCategory("AutoCopyWorld", "Article")
  addIntoModule(M:generateJSON(), "AutoCopyWorld")
end)
runThread(function()
  if not ACW["ok"] then
    i()
  end
  if d then
    k("`6Beta `0- free dulu")
  elseif ACW["ok"] then
    k("`2Akses aktif")
  else
    k("`4" .. (ACW["why"] ~= "" and ACW["why"] or "Akses tidak aktif"))
  end
end)
k("Copy World loaded, ketik `9/cw`0 buat command")
