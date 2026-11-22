platformID = 102
delay = 180
delayPB = 180
delayPath = 100
EditToggle("ModFly", true)
EditToggle("Antibounce", true)
function punch(V, r)
  local B = {}
  B["type"] = 3
  B["state"] = 0
  B["value"] = 18
  B["px"] = V
  B["py"] = r
  B["x"] = (GetLocal())["posX"]
  B["y"] = (GetLocal())["posY"]
  SendPacketRaw(false, B)
  sleep(delayPB)
end
function place(V, r, B)
  local b = {}
  b["type"] = 3
  b["value"] = B
  b["px"] = V
  b["py"] = r
  b["x"] = (GetLocal())["posX"]
  b["y"] = (GetLocal())["posY"]
  sendPacketRaw(false, b)
  sleep(delayPB)
end
function collectRaw(V)
  local r = {}
  r["type"] = 11
  r["value"] = V["id"]
  r["x"] = V["posX"]
  r["y"] = V["posY"]
  SendPacketRaw(false, r)
end
function collect(V)
  for r, B in pairs(GetObjectList()) do
    if
      math["abs"]((GetLocal())["posX"] - B["posX"]) <= (32 * V)
      and (math["abs"]((GetLocal())["posY"] - B["posY"]) < (32 * V) and findItem(B["itemid"]) < 200)
    then
      collectRaw(B)
      sleep(15)
    end
  end
end
function findItem(V)
  for r, B in pairs(GetInventory()) do
    if B["id"] == V then
      return B["amount"]
    end
  end
  return 0
end
function clearSide()
  local function V(V)
    for r = 24, 53, 1 do
      if (GetTile(V, r))["bg"] == 14 or (GetTile(V + 1, r))["bg"] == 14 then
        FindPath(V, r - 1)
        while (GetTile(V, r))["bg"] == 14 do
          punch(V, r)
        end
        while (GetTile(V + 1, r))["bg"] == 14 do
          punch(V + 1, r)
        end
        collect(3)
      end
    end
  end
  V(0)
  V(98)
end
function platform(V)
  if findItem(platformID) < 52 then
    LogToConsole("No Have Plat")
    sleep(math["random"](200, 300))
    while findItem(platformID) < 52 do
      for V, r in pairs(GetObjectList()) do
        if r["itemid"] == platformID then
          findPath(math["floor"]((r["posX"] + 8) / 32) - 1, math["floor"](r["posY"] / 32))
          Sleep(500)
          collectRaw(r)
          sleep(100)
          if findItem(platformID) >= 52 then
            break
          end
        end
      end
    end
    sleep(math["random"](150, 200))
  end
  for V = 2, 52, 2 do
    if (GetTile(1, V))["fg"] == 0 then
      findPath(0, V)
      sleep(delayPath)
      while (GetTile(1, V))["fg"] == 0 do
        place(1, V, platformID)
      end
    end
  end
  for V = 2, 52, 2 do
    if (GetTile(98, V))["fg"] == 0 then
      findPath(99, V)
      sleep(delayPath)
      while (GetTile(98, V))["fg"] == 0 do
        place(98, V, platformID)
      end
    end
  end
end
function clearDirt()
  for V = 27, 51, 12 do
    for r = 2, 97, 1 do
      if (GetTile(r, V - 2))["bg"] ~= 0 or (GetTile(r, V))["bg"] ~= 0 or (GetTile(r, V + 2))["bg"] ~= 0 then
        findPath(r - 1, V)
        sleep(delayPath)
        for B = -2, 2, 2 do
          while (GetTile(r, V + B))["bg"] ~= 0 do
            punch(r, V + B)
          end
        end
        collect(3)
      end
    end
    if (V + 6) ~= 57 then
      for r = 97, 2, -1 do
        if (GetTile(r, V + 4))["bg"] ~= 0 or (GetTile(r, V + 6))["bg"] ~= 0 or (GetTile(r, V + 8))["bg"] ~= 0 then
          findPath(r + 1, V + 6)
          sleep(delayPath)
          for B = 4, 8, 2 do
            while (GetTile(r, V + B))["bg"] ~= 0 do
              punch(r, V + B)
            end
          end
          collect(3)
        end
      end
    end
  end
end
function breakLava()
  for V, r in pairs(GetTiles()) do
    if r["fg"] == 4 then
      findPath(r["x"], r["y"] - 1)
      sleep(delayPath)
      while (GetTile(r["x"], r["y"]))["fg"] == 4 do
        punch(r["x"], r["y"])
      end
      sleep(delay)
      collect(3)
      while (GetTile(r["x"], r["y"]))["fg"] == 0 do
        place(r["x"], r["y"], 2)
      end
    end
  end
end
function breakRock()
  for V, r in pairs(GetTiles()) do
    if r["fg"] == 10 then
      findPath(r["x"], r["y"] - 1)
      sleep(delayPath)
      while (GetTile(r["x"], r["y"]))["fg"] == 10 do
        punch(r["x"], r["y"])
      end
      sleep(delay)
      collect(3)
      while (GetTile(r["x"], r["y"]))["fg"] == 0 do
        place(r["x"], r["y"], 2)
      end
    end
  end
end
function plantFirst()
  findPath(2, 25)
  Sleep(300)
  for V = 2, 30, 1 do
    if (GetTile(V, 25))["fg"] == 0 then
      findPath(V, 25)
      sleep(delayPath)
      while (GetTile(V, 25))["fg"] == 0 do
        place(V, 25, 3)
      end
    end
  end
  sleep(2000)
end
function checkEmpty(V, r)
  for B = 1, 5, 1 do
    if (GetTile((V - 3) + B, r))["fg"] == 0 then
      return true
    end
  end
  return false
end
function plantHarvest(V, r)
  while findItem(2) == 0 do
    for V = 2, 30, 1 do
      if (GetTile(V, 25))["readyharvest"] then
        findPath(V, 25)
        sleep(delayPath)
        while (GetTile(V, 25))["fg"] == 0 do
          place(V, 25, 3)
        end
        sleep(delay)
        while (GetTile(V, 25))["fg"] == 3 do
          punch(V, 25)
        end
        sleep(delay)
        collect(3)
        place(V, 25, 3)
      end
      if findItem(2) > 180 then
        break
      end
    end
  end
  while math["floor"]((GetLocal())["posX"] / 32) ~= V and math["floor"]((GetLocal())["posY"] / 32) ~= r do
    findPath(V, r)
    sleep(delayPath)
  end
end
function placeDirt()
  for V = 36, 2, -2 do
    for r = 4, 98, 4 do
      if checkEmpty(r, V) then
        findPath(r, V + 1)
        sleep(delayPath)
        for B = 1, 5, 1 do
          if (r - 3) + B <= 97 then
            if findItem(2) == 0 then
              plantHarvest(r, V + 1)
              sleep(delayPB)
            end
            if (GetTile((r - 3) + B, V))["fg"] == 0 then
              while (GetTile((r - 3) + B, V))["fg"] == 0 do
                place((r - 3) + B, V, 2)
              end
            end
          end
        end
      end
    end
    for r = 98, 4, 5 do
      if checkEmpty(r, V - 2) then
        findPath(r, V - 1)
        sleep(100)
        for B = 1, 5, 1 do
          if (r - 3) + B ~= 98 or (r - 3) + B ~= 99 then
            if findItem(2) == 0 then
              plantHarvest(r, V - 2)
              sleep(delayPB)
            end
            if (GetTile((r - 3) + B, V - 2))["fg"] == 0 then
              while (GetTile((r - 3) + B, V - 2))["fg"] == 0 do
                place((r - 3) + B, V - 2, 2)
              end
            end
          end
        end
      end
    end
  end
end
function hookVariant(V)
  if V["v1"] == "OnDialogRequest" then
    return true
  end
  return false
end
AddHook(hookVariant, "OnVariant")
clearSide()
sleep(50)
platform("GetWorldName()")
sleep(50)
clearDirt()
sleep(50)
breakLava()
sleep(50)
breakRock()
Sleep(50)
plantFirst()
sleep(50)
placeDirt()
logToConsole("Done")
EditToggle("ModFly", false)
EditToggle("Antibounce", false)
