local t = {
  ["soil_id"] = 8772,
  ["water_id"] = 822,
  ["use_water"] = true,
  ["auto_door"] = true,
  ["door_left"] = true,
  ["main_door_id"] = 6,
  ["base_y"] = 53,
  ["top_y"] = 1,
  ["row_step"] = 2,
  ["last_x"] = 99,
  ["place_delay"] = 120,
  ["path_delay"] = 300,
}
local O = false
local u = "Idle"
local T = false
local I = {}
local i = false
local function j(t)
  LogToConsole("[SoilBuild] " .. tostring(t))
end
local function w(t)
  Sleep(t + math["random"](10, 40))
end
local function s()
  local t, O = pcall(getLocal)
  if t and O then
    return O
  end
  return nil
end
local function P()
  local t = s()
  if not t then
    return nil, nil
  end
  return math["floor"](t["posX"] / 32), math["floor"](t["posY"] / 32)
end
local function W(t)
  local O, u = pcall(getInventory)
  if not O or type(u) ~= "table" then
    return 0
  end
  for O, u in pairs(u) do
    if u["id"] == t then
      return u["amount"]
    end
  end
  return 0
end
local function Y(t, O)
  return O * 1000 + t
end
local function o()
  local t, O = {}, {}
  local u, T = pcall(getTiles)
  if u and type(T) == "table" then
    for u, T in pairs(T) do
      local I = Y(T["x"], T["y"])
      t[I] = T["fg"]
      O[I] = T
    end
  end
  return t, O
end
local function m(O)
  if not O then
    return false
  end
  if O["fg"] == t["water_id"] or O["bg"] == t["water_id"] then
    return true
  end
  if O["water"] == true or O["is_water"] == true or O["iswater"] == true then
    return true
  end
  return false
end
local function x(O)
  local u = t["last_x"]
  local T = t["base_y"]
  local I = t["base_y"] - t["row_step"]
  if t["door_left"] then
    if O == T then
      return 3, u
    end
    if O == I then
      return 3, u - 1
    end
  else
    if O == T then
      return 0, u - 3
    end
    if O == I then
      return 1, u - 3
    end
  end
  return 1, u - 1
end
local function L()
  local O = {}
  local u = t["base_y"]
  while u >= t["top_y"] do
    O[#O + 1] = u
    u = u - t["row_step"]
  end
  return O
end
local function B(O, u)
  local T, I = x(O)
  for T = T, I, 1 do
    if u[Y(T, O)] ~= t["soil_id"] then
      return false
    end
  end
  return true
end
local function Z(O, u)
  local T = (u % t["row_step"]) == (t["base_y"] % t["row_step"])
  if T then
    local t, T = x(u)
    if O >= t and O <= T then
      return false
    end
  end
  return true
end
local function N()
  local O, u = pcall(getTiles)
  if not O or type(u) ~= "table" then
    return nil
  end
  for O, u in pairs(u) do
    if u["fg"] == t["main_door_id"] then
      return u["x"], u["y"]
    end
  end
  return nil
end
local function h()
  if t["door_left"] then
    return "kiri (dicerminkan)"
  end
  return "kanan (sesuai foto)"
end
local function z()
  if not t["auto_door"] then
    j("White door manual: layout " .. h())
    return
  end
  local O, u = N()
  if not O then
    j("White door tidak terdeteksi, pakai pilihan manual: layout " .. h())
    return
  end
  t["door_left"] = (O <= t["last_x"] / 2)
  j("White door terdeteksi di (" .. (O .. (", " .. (u .. (") -> layout " .. h())))))
  if u ~= t["base_y"] then
    j("Peringatan: Y white door " .. (u .. (" beda dengan Y Baris Bawah " .. t["base_y"])))
  end
end
local function y(O, u)
  FindPath(O, u)
  w(t["path_delay"])
  for t = 1, 10, 1 do
    local T, I = P()
    if T and (math["abs"](T - O) <= 1 and math["abs"](I - u) <= 1) then
      break
    end
    w(50)
  end
end
local function J(O, u, T)
  local I = s()
  if not I then
    return
  end
  sendPacketRaw(false, { ["type"] = 3, ["value"] = O, ["x"] = I["posX"], ["y"] = I["posY"], ["px"] = u, ["py"] = T })
  w(t["place_delay"])
end
local function v()
  local u, T = pcall(getObjectList)
  if not u or type(T) ~= "table" then
    return false
  end
  local I, i = P()
  local s = {}
  for O, u in pairs(T) do
    if u["itemid"] == t["soil_id"] then
      local t = math["floor"](u["pos"]["x"] / 32)
      local O = math["floor"](u["pos"]["y"] / 32)
      local T = 0
      if I and i then
        T = math["abs"](t - I) + math["abs"](O - i)
      end
      s[#s + 1] = { ["x"] = t, ["y"] = O, ["d"] = T }
    end
  end
  if #s == 0 then
    return false
  end
  table["sort"](s, function(t, O)
    return t["d"] < O["d"]
  end)
  j("Ambil soil dari world: " .. (#s .. " tumpukan"))
  for u, T in ipairs(s) do
    if not O then
      break
    end
    FindPath(T["x"], T["y"])
    w(t["path_delay"])
    FindPath(T["x"], T["y"])
    w(70)
  end
  return W(t["soil_id"]) > 0
end
local function Q()
  if W(t["soil_id"]) > 0 then
    return true
  end
  if v() then
    return true
  end
  return false
end
local function V()
  if t["soil_id"] == 0 then
    j("ERROR: Isi Soil ID dulu!")
    return false
  end
  if t["top_y"] > t["base_y"] then
    j("ERROR: Y atas harus lebih kecil dari Y bawah!")
    return false
  end
  return true
end
local function S(O)
  local u, T = 0, 0
  local I = nil
  for i, j in ipairs(L()) do
    local w, s = x(j)
    for i = w, s, 1 do
      u = u + 1
      if O[Y(i, j)] == t["soil_id"] then
        T = T + 1
      elseif not I then
        I = j
      end
    end
  end
  j("Soil terpasang: " .. (T .. (" / " .. u)))
  if T == 0 then
    j("Belum ada soil terdeteksi. Kalau farm sudah ada, cek Soil ID.")
  elseif I then
    j("Lanjut dari baris y=" .. I)
  end
  j("Soil di backpack: " .. (W(t["soil_id"]) .. (" | butuh sekitar " .. (u - T))))
  if t["use_water"] then
    j("Water di backpack: " .. (W(t["water_id"]) .. " (dipakai sebisanya)"))
  else
    j("Water dimatikan")
  end
end
local function r(u, T)
  local I, i = x(u)
  for i = I, i, 1 do
    if not O then
      return
    end
    if T[Y(i, u)] ~= t["soil_id"] then
      if not Q() then
        j("Soil habis (backpack dan world). Berhenti di y=" .. (u .. (", x=" .. i)))
        O = false
        return
      end
      local w = i
      if i > I then
        w = i - 1
      end
      y(w, u - 1)
      J(t["soil_id"], i, u)
      T[Y(i, u)] = t["soil_id"]
    end
  end
end
local function n(t, O)
  local u, T = x(O)
  if t >= u and t <= T then
    return O - 1
  end
  return O
end
local function E(O)
  local u = 0
  for T, I in ipairs(L()) do
    if I ~= t["base_y"] then
      if m(O[Y(0, I)]) then
        u = u + 1
      end
      if m(O[Y(t["last_x"], I)]) then
        u = u + 1
      end
    end
  end
  return u > 0
end
local function p(O, u, T)
  local j = O - t["row_step"]
  if not i and j >= t["top_y"] then
    local O, T = x(j)
    for O = O, T, 1 do
      if u[Y(O, j)] == t["soil_id"] then
        return true
      end
    end
  end
  for t, u in ipairs({ 0, t["last_x"] }) do
    for t = O - 1, math["max"](0, O - 3), -1 do
      if Z(u, t) then
        local O = Y(u, t)
        if not I[O] and not m(T[O]) then
          return false
        end
      end
    end
  end
  return true
end
local function a(u, i, w)
  if not t["use_water"] then
    return
  end
  local s = { { ["wx"] = 0, ["sx"] = 1 }, { ["wx"] = t["last_x"], ["sx"] = t["last_x"] - 1 } }
  for i, s in ipairs(s) do
    if not O then
      return
    end
    local P = false
    local o = math["max"](0, u - 3)
    for i = u - 1, o, -1 do
      if not O then
        return
      end
      local o = Y(s["wx"], i)
      if Z(s["wx"], i) and (not I[o] and not m(w[o])) then
        if W(t["water_id"]) <= 0 then
          if not T then
            j("Water habis, sisa tile water dilewati")
            T = true
          end
          return
        end
        if not P then
          y(s["sx"], n(s["sx"], u))
          P = true
        end
        J(t["water_id"], s["wx"], i)
        I[o] = true
      end
    end
  end
end
local function F()
  for t = 1, 2, 1 do
    if not O then
      return
    end
    local u = o()
    local T = 0
    for t, O in ipairs(L()) do
      if not B(O, u) then
        T = T + 1
      end
    end
    if T == 0 then
      return
    end
    j("Cek ulang (" .. (t .. ("): " .. (T .. " baris masih bolong"))))
    for t, T in ipairs(L()) do
      if not O then
        return
      end
      if not B(T, u) then
        r(T, u)
      end
    end
  end
end
local function A()
  u = "Running"
  z()
  if not V() then
    u = "Stopped"
    O = false
    editToggle("btn_start", false)
    return
  end
  T = false
  I = {}
  local w, s = o()
  S(w)
  i = t["use_water"] and E(s)
  if t["use_water"] then
    if i then
      j("Water terbaca: bolong water lama akan diisi")
    else
      j("Water belum terbaca di world (farm baru atau ID beda), pakai mode aman")
    end
  end
  local P = L()
  for u, T in ipairs(P) do
    if not O then
      break
    end
    local I = B(T, w)
    local i = (not t["use_water"]) or p(T, w, s)
    if not (I and i) then
      j("Baris " .. (u .. (" / " .. (#P .. (" (y=" .. (T .. ")"))))))
      if not I then
        r(T, w)
      end
      if not O then
        break
      end
      if not i then
        a(T, w, s)
      end
    end
  end
  if O then
    F()
  end
  if O then
    j("Selesai build soil farm")
  else
    j("Script dihentikan")
  end
  O = false
  u = "Stopped"
  editToggle("btn_start", false)
end
local function G()
  local O, u = o()
  local T, I = 0, t["base_y"] - 1
  local i = u[Y(T, I)]
  if not i then
    j("Tile tidak ketemu di (" .. (T .. (", " .. (I .. ")"))))
    return
  end
  local w = {}
  for t, O in pairs(i) do
    w[#w + 1] = tostring(t) .. ("=" .. tostring(O))
  end
  j("Tile (" .. (T .. (", " .. (I .. ("): " .. table["concat"](w, ", "))))))
end
local K = UserInterface["new"]("AutoBuildSoilUI", "Agriculture")
K:addLabelApp("AUTO BUILD SOIL FARM", "Agriculture")
K:addInputInt("Fertile Soil ID", tostring(t["soil_id"]), "ID", "ID Fertile Soil Block", "Filter", "soil_id")
K:addInputInt("Water ID", tostring(t["water_id"]), "ID", "ID Water", "Filter", "water_id")
K:addToggle("Pakai Water", true, "use_water", false)
K:addToggle("Deteksi White Door Otomatis", true, "auto_door", false)
K:addToggle("Manual: White Door di Kiri", true, "door_left", false)
K:addDivider()
K:addLabel("Ukuran Farm")
K:addInputInt("Y Baris Bawah", tostring(t["base_y"]), "Y", "Tepat di atas Bedrock", "Place", "base_y")
K:addInputInt("Y Baris Atas", tostring(t["top_y"]), "Y", "Baris soil paling atas", "Place", "top_y")
K:addInputInt("Jarak Antar Baris", tostring(t["row_step"]), "Baris", "Default 2", "Place", "row_step")
K:addInputInt("Kolom Paling Kanan (X)", tostring(t["last_x"]), "X", "World 100 lebar = 99", "Place", "last_x")
K:addButton("Ambil Y Bawah dari Posisi Saya", "btn_getbase")
K:addDivider()
K:addLabel("Delay Settings (ms)")
K:addInputInt("Place Delay", tostring(t["place_delay"]), "ms", "Delay tiap place", "Timer", "place_delay")
K:addInputInt("Path Delay", tostring(t["path_delay"]), "ms", "Delay setelah jalan", "Timer", "path_delay")
K:addDivider()
K:addButton("Debug: Info Tile Water", "btn_debug")
K:addToggle("START / STOP", false, "btn_start", false)
local c = K:generateJSON()
addCategory("AutoBuildSoil", "Agriculture")
addIntoModule(c, "AutoBuildSoil")
function OnValue(T, I, i)
  if I == "soil_id" then
    t["soil_id"] = tonumber(i) or 0
  elseif I == "water_id" then
    t["water_id"] = tonumber(i) or 822
  elseif I == "use_water" then
    t["use_water"] = (i == true)
  elseif I == "auto_door" then
    t["auto_door"] = (i == true)
  elseif I == "door_left" then
    t["door_left"] = (i == true)
  elseif I == "base_y" then
    t["base_y"] = tonumber(i) or 53
  elseif I == "top_y" then
    t["top_y"] = tonumber(i) or 1
  elseif I == "row_step" then
    t["row_step"] = math["max"](1, tonumber(i) or 2)
  elseif I == "last_x" then
    t["last_x"] = tonumber(i) or 99
  elseif I == "place_delay" then
    t["place_delay"] = tonumber(i) or 120
  elseif I == "path_delay" then
    t["path_delay"] = tonumber(i) or 300
  elseif I == "btn_getbase" then
    local O, u = P()
    if O and u then
      t["base_y"] = u
      editValue("base_y", tostring(u))
      j("Y Baris Bawah di-set ke " .. u)
    else
      j("Gagal ambil posisi player!")
    end
  elseif I == "btn_debug" then
    G()
  elseif I == "btn_start" then
    if i == true then
      if O then
        return
      end
      O = true
      runThread(A)
    else
      O = false
      u = "Stopping..."
    end
  end
end
applyHook()
j("Script AutoBuildSoil loaded!")
