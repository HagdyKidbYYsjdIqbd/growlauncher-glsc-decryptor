local c = "https://pastebin.com/raw/mGY8umv5"
local y = "https://pastebin.com/raw/PeyNmw7g"
local p = "thecircuscommunity"
local function L(c)
  if not c or c == "" then
    return false
  end
  if c:find("<!DOCTYPE", 1, true) then
    return false
  end
  if c:find("<html", 1, true) then
    return false
  end
  if c:find("404: Not Found", 1, true) then
    return false
  end
  return true
end
local function d(c)
  local y, p = fetch(c)
  if not L(y) then
    growtopia["notify"]("`4Fetch Invalid!")
    LogToConsole("Fetch Gagal: " .. tostring(p))
    return false
  end
  local d, j = ((loadstring or load))(y, "main")
  if not d then
    growtopia["notify"]("`4Gagal Load Script!")
    LogToConsole("Loadstring Error: " .. tostring(j))
    return false
  end
  local o, f = pcall(d)
  if not o then
    growtopia["notify"]("`4Script error!")
    LogToConsole("Runtime Error: " .. tostring(f))
    return false
  end
  return true
end
if c == "" then
  growtopia["notify"]("`4Link Fetch Kosong!")
elseif y == "" or p == "" then
  d(c)
else
  local L = fetch(y)
  if L and L:find(p, 1, true) then
    d(c)
  else
    growtopia["notify"]("`4Script Terminated - Update Script in Discord")
  end
end
