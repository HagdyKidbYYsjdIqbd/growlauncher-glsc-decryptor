LogToConsole("`2AUTO CLEAR START")
TARGET_ID = {
  1536, -- Undersea Rock
  1538, -- Deep Rock
  1522, -- Jellyfish
  8252, -- Sea Urchin
  846, -- Seaweed
  8256, -- Sea Lantern
  1520, -- Great White Shark
  832, -- Coral
  1528, -- Sunken Anchor
  8254, -- Copper Block
  5038, -- Anemone
  850,
}
WORLD_WIDTH = 99
WORLD_HEIGHT = 53
DELAY_BREAK = 175
REACH = 1
local function isTarget(id)
  for _, v in ipairs(TARGET_ID) do
    if id == v then
      return true
    end
  end
  return false
end
local function punch(x, y)
  sendPacketRaw(false, {
    type = 3,
    value = 18,
    state = 32,
    px = x,
    py = y,
    x = getLocal().posX,
    y = getLocal().posY,
  })
end
local function breakTile(x, y)
  local tile = getTile(x, y)
  if not tile then
    return
  end

  local startFg = tile.fg
  local startBg = tile.bg

  local punchCount = 0
  local MAX_PUNCH = 12

  while true do
    local currentTile = getTile(x, y)
    if not currentTile then
      break
    end

    -- Jika ID tile sudah berubah, langsung lanjut jalan
    if currentTile.fg ~= startFg and currentTile.bg ~= startBg then
      break
    end

    if not isTarget(currentTile.fg) and not isTarget(currentTile.bg) then
      break
    end

    if punchCount >= MAX_PUNCH then
      break
    end

    punch(x, y)
    punchCount = punchCount + 1

    Sleep(DELAY_BREAK)
  end
end
for y = 0, WORLD_HEIGHT do
  for x = 0, WORLD_WIDTH do
    local tile = getTile(x, y)

    if tile and (isTarget(tile.fg) or isTarget(tile.bg)) then
      local px = math.floor(getLocal().posX / 32)
      local py = math.floor(getLocal().posY / 32)

      -- Hitung jarak ke target
      local dist_x = math.abs(px - x)
      local dist_y = math.abs(py - y)

      -- JIKA SUDAH BERDIRI DI SEBELAH TARGET (1-FAR), LANGSUNG PUKUL
      if dist_x <= REACH and dist_y <= REACH then
        breakTile(x, y)
      else
        -- Jalan tepat ke atas target (y - 1)
        FindPath(x, y - 1)

        -- DYNAMIC WAIT: Berhenti menunggu jalan jika sudah tiba di lokasi (max tunggu 1000ms)
        local elapsed = 0
        while elapsed < 1000 do
          local cur_px = math.floor(getLocal().posX / 32)
          local cur_py = math.floor(getLocal().posY / 32)

          -- Jika sudah sampai tepat di atas target
          if cur_px == x and cur_py == (y - 1) then
            break
          end

          Sleep(20) -- Cek posisi super cepat
          elapsed = elapsed + 20
        end

        -- Verifikasi ulang posisi 1-far sebelum memukul
        local final_px = math.floor(getLocal().posX / 32)
        local final_py = math.floor(getLocal().posY / 32)

        if math.abs(final_px - x) <= REACH and math.abs(final_py - y) <= REACH then
          breakTile(x, y)
        else
          LogToConsole("`4PATH FAILED @ " .. x .. "," .. y)
        end
      end
    end
  end
end
LogToConsole("`2AUTO CLEAR DONE")
