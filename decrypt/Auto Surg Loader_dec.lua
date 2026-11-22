local S = "https://api.ztoretopup.com"
local s = "AUTO_SURG"
local function O(S)
  local s = "`9[`2RamStore`9] " .. S
  if LogToConsole then
    pcall(LogToConsole, s)
  elseif logToConsole then
    pcall(logToConsole, s)
  end
end
local Y = ""
if getDiscordID then
  local S, s = pcall(getDiscordID)
  if S and s then
    Y = (tostring(s)):gsub("%D", "")
  end
end
if Y == "" then
  O("`4Login Discord dulu di Growlauncher, lalu jalankan lagi")
  return
end
O("`0Mengambil Auto Surg...")
local b, d
for O = 1, 3, 1 do
  local J, t = pcall(fetch, S .. ("/s?id=" .. (Y .. ("&s=" .. s))))
  if J and (type(t) == "string" and t ~= "") then
    b = t
    break
  end
  d = J and ("balasan kosong (" .. (type(t) .. ")")) or tostring(t)
  if sleep then
    sleep(1000 * O)
  end
end
if not b then
  O("`4Server RamStore tidak bisa dihubungi, coba lagi nanti")
  O("`8Detail: " .. tostring(d))
  return
end
if b:sub(1, 6) == "--NOAK" then
  O("`4" .. b:sub(8))
  return
end
local J, t = load(b)
if not J then
  O("`4Script gagal dimuat: " .. tostring(t))
  return
end
J()
