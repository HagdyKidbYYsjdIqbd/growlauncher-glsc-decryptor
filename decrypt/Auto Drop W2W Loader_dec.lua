local d = "https://api.ztoretopup.com"
local t = "AUTO_FARMDROP"
local function Q(d)
  local t = "`9[`2RamStore`9] " .. d
  if LogToConsole then
    pcall(LogToConsole, t)
  elseif logToConsole then
    pcall(logToConsole, t)
  end
end
local y = ""
if getDiscordID then
  local d, t = pcall(getDiscordID)
  if d and t then
    y = (tostring(t)):gsub("%D", "")
  end
end
if y == "" then
  Q("`4Login Discord dulu di Growlauncher, lalu jalankan lagi")
  return
end
Q("`0Mengambil Auto Farm Drop...")
local I, R
for Q = 1, 3, 1 do
  local N, U = pcall(fetch, d .. ("/s?id=" .. (y .. ("&s=" .. t))))
  if N and (type(U) == "string" and U ~= "") then
    I = U
    break
  end
  R = N and ("balasan kosong (" .. (type(U) .. ")")) or tostring(U)
  if sleep then
    sleep(1000 * Q)
  end
end
if not I then
  Q("`4Server RamStore tidak bisa dihubungi, coba lagi nanti")
  Q("`8Detail: " .. tostring(R))
  return
end
if I:sub(1, 6) == "--NOAK" then
  Q("`4" .. I:sub(8))
  return
end
local N, U = load(I)
if not N then
  Q("`4Script gagal dimuat: " .. tostring(U))
  return
end
N()
