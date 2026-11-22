local m = { ["active"] = true, ["cooldownSeconds"] = 30, ["lastJoinAt"] = 0, ["lastWorld"] = nil, ["detected"] = 0 }
local function V(m)
  local V = "[SB World Helper] " .. tostring(m)
  if type(logToConsole) == "function" then
    pcall(logToConsole, V)
  else
    print(V)
  end
end
local function S(m)
  return ((m:gsub("^%s+", "")):gsub("%s+$", ""))
end
local function r(m)
  if not m then
    return nil
  end
  m = S(m)
  if #m < 1 or #m > 24 then
    return nil
  end
  if not m:match("^[%w_]+$") then
    return nil
  end
  return m
end
local function L(m)
  if type(m) ~= "string" then
    return nil
  end
  local V = {
    "[Ww][Oo][Rr][Ll][Dd]%s*:%s*([%w_]+)",
    "[Ww][Oo][Rr][Ll][Dd]%s+([%w_]+)",
    "[Jj][Oo][Ii][Nn]%s+([%w_]+)",
    "[Vv][Ii][Ss][Ii][Tt]%s+([%w_]+)",
  }
  for V, S in ipairs(V) do
    local L = m:match(S)
    local b = r(L)
    if b then
      return b
    end
  end
  return nil
end
local function b(m)
  if type(m) ~= "string" then
    return false
  end
  local V = m:lower()
  return V:find("super broadcast", 1, true) ~= nil or V:find("superbroadcast", 1, true) ~= nil
end
local function d(S)
  local r = os["time"]()
  if m["lastWorld"] == S then
    V("World " .. (S .. " sudah diproses; dilewati."))
    return false
  end
  if r - m["lastJoinAt"] < m["cooldownSeconds"] then
    V("Cooldown aktif. World terdeteksi: " .. (S .. " (tidak mengirim permintaan join)."))
    return false
  end
  if type(joinWorld) ~= "function" then
    V("World terdeteksi: " .. (S .. ". API joinWorld tidak tersedia; silakan masuk secara manual."))
    m["lastWorld"] = S
    return false
  end
  local L, b = pcall(joinWorld, S)
  m["lastJoinAt"] = r
  m["lastWorld"] = S
  if L and b ~= false then
    V("Permintaan masuk dikirim untuk world: " .. S)
    return true
  end
  V("Gagal meminta masuk ke world: " .. S)
  return false
end
local function T(S)
  if not m["active"] or type(S) ~= "table" then
    return false
  end
  local r = {}
  for m = 1, 7, 1 do
    local V = S["v" .. m]
    if V ~= nil then
      r[#r + 1] = tostring(V)
    end
  end
  local T = table["concat"](r, " ")
  if not b(T) then
    return false
  end
  m["detected"] = m["detected"] + 1
  V("Super Broadcast terdeteksi (#" .. (m["detected"] .. ")."))
  local e = L(T)
  if not e then
    V("Nama world tidak ditemukan. Format pesan mungkin berbeda.")
    return false
  end
  V("World ditemukan: " .. e)
  d(e)
  return false
end
if type(addHook) == "function" then
  local m = pcall(addHook, "onVariant", T)
  if not m then
    V("Gagal memasang hook onVariant.")
  end
else
  V("addHook tidak tersedia pada environment ini.")
end
m["status"] = function()
  V("Aktif: " .. tostring(m["active"]))
  V("Super Broadcast terdeteksi: " .. tostring(m["detected"]))
  V("Cooldown: " .. (tostring(m["cooldownSeconds"]) .. " detik"))
  V("World terakhir: " .. tostring(m["lastWorld"]))
end
m["start"] = function()
  m["active"] = true
  V("Pemantauan diaktifkan.")
end
m["stop"] = function()
  m["active"] = false
  V("Pemantauan dihentikan.")
end
m["setCooldown"] = function(S)
  S = tonumber(S)
  if not S or S < 30 then
    V("Cooldown minimum adalah 30 detik.")
    return false
  end
  m["cooldownSeconds"] = math["floor"](S)
  V("Cooldown diatur ke " .. (m["cooldownSeconds"] .. " detik."))
  return true
end
_G["SBWorldHelper"] = m
V("SB World Helper aktif.")
V("Gunakan SBWorldHelper.status(), .stop(), atau .start().")
V("Auto-join memerlukan API joinWorld(world) resmi dari launcher.")
