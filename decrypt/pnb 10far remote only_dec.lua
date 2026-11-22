ITEM_ID = 5640
DELAY = 120
FAR = 10
HAND = "cfist"
FACING = "right"
x, y = math.floor(GetLocal().posX / 32), math.floor(GetLocal().posY / 32)
LH, LF = string.lower(HAND), string.lower(FACING)
function requestPlaceBlock(currentX, currentY, setFacing)
  sendPacketRaw(false, {
    type = 3,
    value = ITEM_ID,
    px = currentX,
    py = currentY,
    x = currentX * 32,
    y = currentY * 32,
    state = setFacing,
  })
end
function requestBreakBlock(currentX, currentY, setFacing)
  sendPacketRaw(
    false,
    { type = 3, value = 18, px = currentX, py = currentY, x = currentX * 32, y = currentY * 32, state = setFacing }
  )
end
function FacingRightCfist()
  for loops = 1, FAR do
    requestPlaceBlock(x + loops, y, 48)
  end
  Sleep(DELAY)
  requestBreakBlock(x + 1, y, 48)
end
function FacingLeftCfist()
  for loops = 1, FAR do
    requestPlaceBlock(x - loops, y, 32)
  end
  Sleep(DELAY)
  requestBreakBlock(x - 1, y, 32)
end
function FacingRightBlade()
  for loops = 1, FAR do
    requestPlaceBlock(x + loops, y, 48)
  end
  Sleep(DELAY)
  for loops = 1, FAR do
    requestBreakBlock(x + loops, y, 48)
    Sleep(80)
  end
end
function FacingLeftBlade()
  for loops = 1, FAR do
    requestPlaceBlock(x - loops, y, 32)
  end
  Sleep(DELAY)
  for loops = 1, FAR do
    requestBreakBlock(x - loops, y, 32)
    Sleep(80)
  end
end
while true do
  if LH == "cfist" and LF == "right" then
    FacingRightCfist()
  elseif LH == "blade" and LF == "right" then
    FacingRightBlade()
  elseif LH == "cfist" and LF == "left" then
    FacingLeftCfist()
  elseif LH == "blade" and LF == "left" then
    FacingLeftBlade()
  end
end
