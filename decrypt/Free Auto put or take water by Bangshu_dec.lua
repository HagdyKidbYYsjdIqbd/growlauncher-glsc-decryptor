setMinimum("6.1.2")
local O = "Auto Water World"
local r = 1024
local z = {
  ["put"] = true,
  ["collect"] = false,
  ["collectWorld"] = "",
  ["dropWorld"] = "",
  ["dropX"] = "",
  ["dropY"] = "",
  ["placeDelay"] = 200,
  ["pathDelay"] = 325,
  ["collectDelay"] = 100,
}
local Z, j, P = nil, false, false
local function m(O, ...)
  if type(O) ~= "function" then
    return nil
  end
  local r, z = pcall(O, ...)
  if r then
    return z
  end
end
local function I(O, ...)
  if type(O) ~= "function" then
    return false
  end
  local r, z = pcall(O, ...)
  return r and z ~= false
end
local function T(O)
  return ((tostring(O or "")):upper()):gsub("%s+", "")
end
local function U(O)
  local r, z = O:match("^([A-Z0-9]+)|([%w_-]+)$")
  if not r and O:match("^[A-Z0-9]+$") then
    r = O
  end
  if r and (r ~= "EXIT" and r ~= "EXITWORLD") then
    return r, z
  end
end
local function H(O, r, z)
  local Z = tonumber(O)
  if Z and (Z % 1 == 0 and (Z >= r and Z <= z)) then
    return Z
  end
end
local Y
pcall(function()
  local O = m(require, "preferences") or Preferences
  Y = O:new("AutoWaterWorldV1")
  Y:load()
  for O, r in pairs(z) do
    local Z = Y:get(O, tostring(r))
    if type(r) == "boolean" then
      z[O] = Z == true or Z == "true" or Z == 1 or Z == "1"
    elseif type(r) == "number" then
      z[O] = H(Z, 0, 10000) or r
    else
      z[O] = tostring(Z or r)
    end
  end
end)
local function G()
  local O = pcall(function()
    for O, r in pairs(z) do
      Y:set(O, tostring(r))
    end
    if Y:save() == false then
      error("save rejected")
    end
  end)
  return O
end
local function L(O, r)
  P = true
  m(editValue, "AW_" .. O, tostring(r))
  P = false
end
local function f(O)
  L("status", O)
end
local function d(O)
  m(growtopia and growtopia["notify"], O)
end
local function D(O, r)
  P = true
  m(editToggle or EditToggle, "AW_" .. O, r)
  P = false
end
local function E()
  return T(m(GetWorldName or getCurrentWorldName))
end
local function l()
  local O = m(GetLocal or getLocal)
  local r, z = O and tonumber(O["posX"]), O and tonumber(O["posY"])
  if r and z then
    return O, math["floor"](r / 32), math["floor"](z / 32)
  end
end
local function q(O)
  return Z == O
end
local function N(O, r)
  return m(GetTile or getTile, O, r)
end
local function u()
  return m(GetTiles or getTiles)
end
local function R(O, r, z)
  local Z, j, P = l()
  return q(O) and (E() == O["world"] and (j == r and P == z))
end
local function V(O)
  local r = m(GetInventory or getInventory)
  if type(r) ~= "table" then
    error("Could not read inventory.", 0)
  end
  for r, z in pairs(r) do
    if tonumber(z["id"]) == O then
      return tonumber(z["amount"]) or 0
    end
  end
  return 0
end
local function X(O)
  if not O then
    return nil
  end
  local z = tonumber(m(function()
    return O["flag"]
  end))
  if not z then
    z = tonumber(m(function()
      return O["flags"]
    end))
  end
  if z then
    return (math["floor"](z) & r) ~= 0
  end
  local Z = m(function()
    return O["water"]
  end)
  if type(Z) == "boolean" then
    return Z
  end
  Z = m(function()
    return O["isWater"]
  end)
  if type(Z) == "boolean" then
    return Z
  end
end
local function v(O, r)
  local z = r
  while q(O) and z > 0 do
    local O = math["min"](100, z)
    Sleep(O)
    z = z - O
  end
  return q(O)
end
local function p(O)
  local r = u()
  return E() == O and (l() ~= nil and (type(r) == "table" and next(r) ~= nil))
end
local function x(O, r)
  local z = 0
  for Z = 1, 100, 1 do
    if not q(O) then
      return false
    end
    z = p(r) and z + 1 or 0
    if z >= 4 then
      return true
    end
    Sleep(200)
  end
  return false
end
local function k(O, r)
  local z, Z = U(r)
  if not z then
    error("Invalid world route " .. r, 0)
  end
  if p(z) and O["route"] == r then
    O["world"] = z
    return true
  end
  while q(O) do
    if not p(z) or (not Z and (O["route"] and O["route"] ~= r)) then
      O["doorRoute"] = nil
      f("JOINING " .. z)
      I(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (z .. "\ninvitedWorld|0"))
    end
    if x(O, z) then
      if not Z or O["doorRoute"] == r then
        O["world"] = z
        O["route"] = r
        return true
      end
      f("ENTERING " .. r)
      if I(SendPacket or sendPacket, 3, "action|join_request\nname|" .. (r .. "\ninvitedWorld|0")) then
        v(O, 1400)
        if x(O, z) then
          O["doorRoute"] = r
          O["world"] = z
          O["route"] = r
          return true
        end
      end
    end
    f("WAITING TO RECONNECT TO " .. r)
    O["doorRoute"] = nil
    if not v(O, 3000) then
      return false
    end
  end
  return false
end
local function B(O, r, z)
  if R(O, r, z) then
    return true
  end
  if not N(r, z) then
    return false
  end
  for Z = 1, 2, 1 do
    if not v(O, O["pathDelay"]) or E() ~= O["world"] then
      return false
    end
    I(FindPath or findPath, r, z)
    for Z = 1, 20, 1 do
      if not q(O) or E() ~= O["world"] or not l() then
        return false
      end
      if R(O, r, z) then
        return true
      end
      Sleep(100)
    end
  end
  return false
end
local function M(O, r, z)
  local Z = U(O["dropRoute"])
  return O["dropX"] ~= nil
    and (
      Z == E()
      and (
        math["abs"](z - O["dropY"]) <= 2
        and (r >= math["min"](O["dropX"], O["dropStartX"]) - 2 and r <= math["max"](O["dropX"], O["dropStartX"]) + 2)
      )
    )
end
local function S(O)
  local r = m(GetObjectList or getObjectList or (growtopia and growtopia["getWorldObjects"]))
  if type(r) ~= "table" then
    return nil
  end
  local z = {}
  for r, Z in pairs(r) do
    if tonumber(Z["itemid"]) == O["bucket"] then
      local r = tonumber(Z["posX"] or (Z["pos"] and Z["pos"]["x"]))
      local j = tonumber(Z["posY"] or (Z["pos"] and Z["pos"]["y"]))
      local P = tonumber(Z["id"])
      if r and (j and P) then
        local Z, m = math["floor"](r / 32), math["floor"](j / 32)
        if not M(O, Z, m) then
          z[#z + 1] = { ["x"] = Z, ["y"] = m, ["ox"] = r, ["oy"] = j, ["uid"] = P }
        end
      end
    end
  end
  table["sort"](z, function(O, r)
    if O["y"] == r["y"] then
      return O["x"] < r["x"]
    end
    return O["y"] < r["y"]
  end)
  return z
end
local function K(O, r, z)
  if not O["collect"] then
    f("NEED WATER BUCKETS - ADD TO BACKPACK OR PRESS STOP")
    v(O, 2000)
    return false
  end
  if not k(O, O["collectRoute"]) then
    return false
  end
  local Z = S(O)
  if not Z then
    error("Could not scan bucket supply.", 0)
  end
  local j = {}
  for r, z in ipairs(Z) do
    if not q(O) then
      return false
    end
    if V(O["bucket"]) >= 200 then
      break
    end
    if not j[z["uid"]] then
      local r = false
      for Z, j in ipairs({ z["x"], z["x"] - 1, z["x"] + 1 }) do
        if j >= 0 and (not M(O, j, z["y"]) and B(O, j, z["y"])) then
          r = true
          break
        end
      end
      if r then
        local r, z, Z = l()
        local P = V(O["bucket"])
        for r, P in ipairs(S(O) or {}) do
          if not q(O) or E() ~= O["world"] then
            return false
          end
          if Z == P["y"] and (math["abs"](z - P["x"]) <= 2 and (not j[P["uid"]] and V(O["bucket"]) < 200)) then
            O["pickupUID"] = P["uid"]
            local r = I(
              SendPacketRaw or sendPacketRaw,
              false,
              { ["type"] = 11, ["value"] = P["uid"], ["x"] = P["ox"], ["y"] = P["oy"] }
            )
            O["pickupUID"] = nil
            j[P["uid"]] = true
            if r and not v(O, O["collectDelay"]) then
              return false
            end
          end
        end
        for r = 1, 15, 1 do
          if not q(O) or V(O["bucket"]) > P then
            break
          end
          Sleep(100)
        end
      end
    end
  end
  if not k(O, O["origin"]) then
    return false
  end
  if r and not B(O, r, z) then
    return false
  end
  if V(O["bucket"]) == 0 then
    f("NO REACHABLE BUCKET SUPPLY - WAITING")
    v(O, 3000)
    return false
  end
  return true
end
local function A(O)
  local r = l()
  if r and (r["isLeft"] ~= true and r["isLeft"] ~= 1) then
    return true
  end
  local z, Z = O["dropX"], O["dropY"]
  if z <= 0 or not B(O, z - 1, Z) or not B(O, z, Z) then
    return false
  end
  r = l()
  return r and (r["isLeft"] ~= true and r["isLeft"] ~= 1)
end
local function i(O, r)
  if not O["dropX"] then
    if not r and V(O["bucket"]) >= 190 then
      error("Set Drop World and Drop Position to store buckets.", 0)
    end
    return true
  end
  local z = O["put"] and 0 or 1
  if V(O["bucket"]) <= z then
    return true
  end
  local Z, j, P = l()
  if not k(O, O["dropRoute"]) then
    return false
  end
  while q(O) and V(O["bucket"]) > z do
    if not B(O, O["dropX"], O["dropY"]) or not A(O) then
      error("Could not reach the drop standing tile facing right.", 0)
    end
    local r = V(O["bucket"])
    local Z = { ["id"] = O["bucket"] }
    O["drop"] = Z
    if not I(SendPacket or sendPacket, 2, "action|drop\nitemID|" .. O["bucket"]) then
      O["drop"] = nil
      error("Could not send bucket drop request.", 0)
    end
    for z = 1, 25, 1 do
      if not q(O) or Z["open"] or Z["full"] or V(O["bucket"]) < r then
        break
      end
      Sleep(100)
    end
    if not q(O) then
      O["drop"] = nil
      return false
    end
    if not R(O, O["dropX"], O["dropY"]) then
      O["drop"] = nil
      error("Drop position changed.", 0)
    end
    if Z["open"] and (not Z["full"] and V(O["bucket"]) == r) then
      if
        not I(
          SendPacket or sendPacket,
          2,
          "action|dialog_return\ndialog_name|drop_item\nitemID|" .. (O["bucket"] .. ("|\ncount|" .. (r - z)))
        )
      then
        O["drop"] = nil
        error("Could not confirm bucket drop.", 0)
      end
      for z = 1, 15, 1 do
        if not q(O) or Z["full"] or V(O["bucket"]) < r then
          break
        end
        Sleep(100)
      end
    end
    O["drop"] = nil
    if not q(O) then
      return false
    end
    if not R(O, O["dropX"], O["dropY"]) then
      error("Drop interrupted. Check backpack.", 0)
    end
    local j = V(O["bucket"])
    if j == r and not Z["full"] then
      v(O, 500)
      j = V(O["bucket"])
    end
    if not R(O, O["dropX"], O["dropY"]) then
      error("Drop position changed during confirmation.", 0)
    end
    if j >= r then
      if not Z["full"] and not Z["open"] then
        error("Drop dialog did not open.", 0)
      end
      if O["dropX"] <= 0 then
        error("Drop space exhausted at the left edge.", 0)
      end
      O["dropX"] = O["dropX"] - 1
      L("dropCurrent", O["dropX"] .. ("," .. O["dropY"]))
      f("DROP REJECTED - SHIFT LEFT " .. O["dropX"])
    end
  end
  if not k(O, O["origin"]) then
    return false
  end
  return not j or B(O, j, P)
end
function onSendPacketRaw(O)
  local r = Z
  if not r or not O or tonumber(O["type"]) ~= 11 then
    return false
  end
  return tonumber(O["value"]) ~= r["pickupUID"]
end
function onGamePacket(O)
  if Z and (O and tonumber(O["type"]) == 26) then
    Z["doorRoute"] = nil
    Z["route"] = nil
  end
  return false
end
function onVariant(O)
  local r = Z
  local z = r and r["drop"]
  if not z or not O or type(O["v2"]) ~= "string" or not R(r, r["dropX"], r["dropY"]) then
    return false
  end
  if O["v1"] == "OnTextOverlay" then
    local r = (O["v2"]:gsub(string["char"](96) .. ".", "")):lower()
    if r:find("you can't drop that here, find an emptier spot!", 1, true) then
      z["full"] = true
    end
  elseif O["v1"] == "OnDialogRequest" and O["v2"]:find("dialog_name|drop_item", 1, true) then
    local r = tonumber(O["v2"]:match("itemID|(%d+)") or O["v2"]:match("itemid|(%d+)"))
    if not r or r == z["id"] then
      z["open"] = true
      return true
    end
  elseif O["v1"] == "OnDialogRequest" and O["v2"]:find("end_dialog|drop_item", 1, true) then
    local r = tonumber(O["v2"]:match("itemID|(%d+)") or O["v2"]:match("itemid|(%d+)"))
    if not r or r == z["id"] then
      z["open"] = true
      return true
    end
  end
  return false
end
local function y(O, r)
  local z = u()
  if type(z) ~= "table" or not next(z) then
    error("World tile data unavailable.", 0)
  end
  local Z = {}
  for z, j in pairs(z) do
    local P, m = tonumber(j["x"]), tonumber(j["y"])
    if P and m then
      local z = X(j)
      if z == nil then
        error("This build does not expose a readable tile water flag.", 0)
      end
      if z ~= O["put"] and not r[P .. ("," .. m)] then
        Z[#Z + 1] = { ["x"] = P, ["y"] = m }
      end
    end
  end
  table["sort"](Z, function(O, r)
    if O["y"] == r["y"] then
      return O["x"] < r["x"]
    end
    return O["y"] < r["y"]
  end)
  return Z
end
local function o(O, r, z)
  local Z, j, P = l()
  if j and (math["abs"](j - r["x"]) <= 2 and math["abs"](P - r["y"]) <= 2) then
    return j, P
  end
  local m = {}
  for O = math["max"](0, r["y"] - 2), r["y"] + 2, 1 do
    for Z = math["max"](0, r["x"] - 2), r["x"] + 2, 1 do
      local j = N(Z, O)
      if j and (j["collidable"] ~= true and not z[Z .. ("," .. O)]) then
        m[#m + 1] = { ["x"] = Z, ["y"] = O, ["d"] = math["abs"](Z - r["x"]) + math["abs"](O - r["y"]) }
      end
    end
  end
  table["sort"](m, function(O, r)
    if O["d"] == r["d"] then
      if O["y"] == r["y"] then
        return O["x"] < r["x"]
      end
      return O["y"] < r["y"]
    end
    return O["d"] < r["d"]
  end)
  for r, Z in ipairs(m) do
    if not q(O) then
      return
    end
    if B(O, Z["x"], Z["y"]) then
      return Z["x"], Z["y"]
    end
    if E() ~= O["world"] or not l() then
      return
    end
    z[Z["x"] .. ("," .. Z["y"])] = true
  end
end
local function e(O)
  local r, z = {}, {}
  local Z, j = 0, 0
  while q(O) do
    if not k(O, O["origin"]) then
      return
    end
    local P = y(O, r)
    if #P == 0 then
      v(O, 750)
      if not q(O) then
        return
      end
      if #y(O, r) == 0 then
        for z, Z in pairs(r) do
          if Z == "unconfirmed" then
            local Z, P = z:match("^(%d+),(%d+)$")
            if X(N(tonumber(Z), tonumber(P))) == O["put"] then
              j = j - 1
              O["confirmed"] = O["confirmed"] + 1
              r[z] = nil
            end
          end
        end
        if V(O["bucket"]) > 0 and not i(O, true) then
          return "Could not finish bucket storage."
        end
        return "Done. " .. (
            O["confirmed"] .. (" tiles confirmed; " .. (Z .. (" unreachable; " .. (j .. " unconfirmed."))))
          )
      end
    else
      if not O["put"] and V(O["bucket"]) >= 190 then
        if not i(O, false) then
          return "Bucket storage interrupted."
        end
      elseif V(O["bucket"]) == 0 then
        local r, z, Z = l()
        K(O, z, Z)
      else
        local m, T = o(O, P[1], z)
        if not m then
          if E() ~= O["world"] or not l() then
            z = {}
          else
            local O = P[1]["x"] .. ("," .. P[1]["y"])
            r[O] = true
            Z = Z + 1
          end
        else
          local U = {}
          for r, z in ipairs(P) do
            if not q(O) or E() ~= O["world"] then
              break
            end
            if math["abs"](z["x"] - m) <= 2 and math["abs"](z["y"] - T) <= 2 then
              if V(O["bucket"]) == 0 or (not O["put"] and V(O["bucket"]) >= 190) then
                break
              end
              local r = X(N(z["x"], z["y"]))
              local Z, j, P = l()
              if r ~= nil and (r ~= O["put"] and (j == m and P == T)) then
                f((O["put"] and "PUT WATER " or "TAKE WATER ") .. (z["x"] .. ("," .. z["y"])))
                if
                  I(
                    SendPacketRaw or sendPacketRaw,
                    false,
                    { ["type"] = 3, ["value"] = O["bucket"], ["px"] = z["x"], ["py"] = z["y"], ["x"] = Z["posX"], ["y"] = Z["posY"] }
                  )
                then
                  U[#U + 1] = z
                else
                  error("Could not send Water Bucket use.", 0)
                end
                if not v(O, math["max"](50, O["placeDelay"]) + math["random"](0, 100)) then
                  return
                end
              end
            end
          end
          for r = 1, 15, 1 do
            if not q(O) or E() ~= O["world"] then
              break
            end
            local z = false
            for r, Z in ipairs(U) do
              if X(N(Z["x"], Z["y"])) ~= O["put"] then
                z = true
                break
              end
            end
            if not z then
              break
            end
            Sleep(100)
          end
          if E() == O["world"] and l() then
            for z, Z in ipairs(U) do
              local P = Z["x"] .. ("," .. Z["y"])
              local m = X(N(Z["x"], Z["y"]))
              if m == O["put"] then
                O["confirmed"] = O["confirmed"] + 1
              else
                r[P] = "unconfirmed"
                j = j + 1
              end
            end
            L("progress", O["confirmed"] .. (" confirmed / " .. (Z .. (" unreachable / " .. (j .. " unconfirmed")))))
          else
            z = {}
          end
        end
      end
    end
  end
end
local function Q()
  if j then
    D("start", false)
    return
  end
  local O = E()
  if not U(O) or not l() then
    D("start", false)
    d("Enter the working world first.")
    return
  end
  local r = {}
  for O, z in pairs(z) do
    r[O] = z
  end
  r["origin"] = O
  r["world"] = O
  r["bucket"] = tonumber(m(findItemID or (growtopia and growtopia["getItemID"]), "Water Bucket")) or 822
  if r["bucket"] < 1 then
    r["bucket"] = 822
  end
  r["collectRoute"] = r["collectWorld"] == "" and O or T(r["collectWorld"])
  r["dropRoute"] = r["dropWorld"] == "" and O or T(r["dropWorld"])
  if not U(r["collectRoute"]) or not U(r["dropRoute"]) then
    D("start", false)
    d("Enter WORLD or WORLD|DOORID.")
    return
  end
  r["dropX"] = H(r["dropX"], 0, 999)
  r["dropY"] = H(r["dropY"], 0, 999)
  if (r["dropX"] ~= nil) ~= (r["dropY"] ~= nil) then
    D("start", false)
    d("Set both drop coordinates.")
    return
  end
  r["dropStartX"] = r["dropX"]
  r["confirmed"] = 0
  local P = m(getValue or GetValue, 0, "ModFly")
  r["restoreFly"] = not (P == true or P == 1 or P == "true")
  Z, j = r, true
  if not I(editToggle or EditToggle, "ModFly", true) then
    Z, j = nil, false
    D("start", false)
    d("Could not enable ModFly.")
    return
  end
  L("progress", "0 confirmed")
  local Y, G = pcall(runThread, function()
    local O = {}
    local z, P = pcall(function()
      for r, z in ipairs({ "Fast Drop", "Enable AutoCollect", "Autocollect" }) do
        local Z = m(getValue or GetValue, 0, z)
        if Z == true or Z == 1 or Z == "true" or Z == "1" then
          O[#O + 1] = z
          if not I(editToggle or EditToggle, z, false) then
            error("Could not pause " .. z, 0)
          end
        end
      end
      return e(r)
    end)
    local T = not q(r)
    if r["restoreFly"] then
      I(editToggle or EditToggle, "ModFly", false)
    end
    for O, r in ipairs(O) do
      I(editToggle or EditToggle, r, true)
    end
    Z, j = nil, false
    D("start", false)
    local U = T and "STOPPED" or (z and (P or "STOPPED") or "Stopped: " .. tostring(P))
    f(U)
    d(U)
  end)
  if not Y or G == false then
    if r["restoreFly"] then
      I(editToggle or EditToggle, "ModFly", false)
    end
    Z, j = nil, false
    D("start", false)
    f("COULD NOT START WORKER")
  end
end
function onValue(O, r, j)
  if P then
    return
  end
  if r == "AW_start" then
    if j == true or j == 1 or j == "true" or j == "1" then
      if not Z then
        Q()
      end
    else
      Z = nil
      f("STOPPED")
    end
    return
  end
  if r == "AW_put" or r == "AW_take" then
    if Z then
      D(r == "AW_put" and "put" or "take", r == "AW_put" and z["put"] or not z["put"])
      return
    end
    local O = j == true or j == 1 or j == "true" or j == "1"
    if O then
      z["put"] = r == "AW_put"
    end
    D("put", z["put"])
    D("take", not z["put"])
    G()
    return
  end
  if r == "AW_hereCollect" or r == "AW_hereDrop" then
    if Z then
      return
    end
    if not U(E()) or not l() then
      d("Enter a world first.")
      return
    end
    local O = r == "AW_hereCollect" and "collectWorld" or "dropWorld"
    z[O] = E()
    L(O, z[O])
    G()
    return
  end
  local m = type(r) == "string" and r:match("^AW_(.+)$")
  if not m or z[m] == nil then
    return
  end
  if Z then
    if type(z[m]) == "boolean" then
      D(m, z[m])
    else
      L(m, z[m])
    end
    return
  end
  if type(z[m]) == "boolean" then
    z[m] = j == true or j == 1 or j == "true" or j == "1"
  elseif type(z[m]) == "number" then
    local O = H(j, 0, 10000)
    if not O then
      L(m, z[m])
      return
    end
    z[m] = O
  elseif m == "dropX" or m == "dropY" then
    if tostring(j or "") == "" then
      z[m] = ""
    else
      local O = H(j, 0, 999)
      if not O then
        L(m, z[m])
        return
      end
      z[m] = tostring(O)
    end
  else
    z[m] = T(j)
  end
  if not G() then
    d("Settings could not be saved.")
  end
end
local t = {}
do
  local O =
    "https://script.google.com/macros/s/AKfycbxeBzpOUzvcRDkX-4eR8uioFbAUDsepIQc26kmxUkXt6YOjBxFdVsOE0zzvxYSprl5knA/exec"
  local r = "water"
  local z = "AutoWaterWorldKeyLicense"
  local m = "license_key"
  local I = nil
  local T = ""
  local function U(O)
    O = tostring(O or "")
    O = O:gsub("%s+", "")
    return O:upper()
  end
  local function H(O)
    O = U(O)
    return O:match("^[A-Z]%d%d%d%d%d%d%d$") ~= nil
  end
  local function Y()
    local O = pcall(function()
      local O = nil
      if type(require) == "function" then
        local r, z = pcall(require, "preferences")
        if r and z ~= nil then
          O = z
        end
      end
      if O == nil and type(Preferences) == "table" then
        O = Preferences
      end
      if O == nil then
        return
      end
      if type(O["new"]) == "function" then
        local r = O:new(z)
        I = r or O
      else
        I = O
      end
      if I ~= nil and type(I["load"]) == "function" then
        I:load()
      end
      if I ~= nil and type(I["get"]) == "function" then
        T = U(I:get(m, ""))
      end
    end)
    if not O then
      I = nil
      T = ""
    end
  end
  local function G(O)
    if I == nil then
      return false
    end
    local r = pcall(function()
      I:set(m, U(O))
      I:save()
    end)
    return r
  end
  local function E()
    if I == nil then
      return false
    end
    local O = pcall(function()
      I:set(m, "")
      I:save()
    end)
    return O
  end
  Y()
  local l = T
  local q = 0
  local N, u = false, false
  local function R(O)
    local r = tostring(O or "")
    pcall(function()
      editValue("AW_licensestatus", r)
    end)
  end
  local function V(O)
    O = tostring(O or "")
    O = O:gsub("\n", "\r\n")
    O = O:gsub("([^%w%-_%.~])", function(O)
      return string["format"]("%%%02X", string["byte"](O))
    end)
    return O
  end
  local function X()
    local O = ""
    if type(getDiscordID) == "function" then
      local r, z = pcall(getDiscordID)
      if r and z ~= nil then
        O = tostring(z)
      end
    elseif getDiscordID ~= nil then
      O = tostring(getDiscordID)
    end
    O = ((tostring(O or "")):gsub("^%s+", "")):gsub("%s+$", "")
    if O == "" or O == "nil" or O == "0" then
      local r = GetLocal or getLocal
      if r ~= nil then
        local z, Z = pcall(r)
        if z and (Z ~= nil and Z["name"] ~= nil) then
          O = tostring(Z["name"])
          O = (O:gsub("^%s+", "")):gsub("%s+$", "")
        end
      end
    end
    return O
  end
  local function v(z, Z)
    if u then
      return false
    end
    u = true
    local j = U(l)
    l = j
    if not H(j) then
      R("INVALID KEY FORMAT")
      u = false
      if not z then
        d("License must be 1 letter + 7 numbers, for example A1234567.")
      end
      return false
    end
    local P = X()
    if P == "" then
      R("NO CLIENT ID")
      u = false
      if not z then
        d("Could not read a client ID. Enter the game first and try again.")
      end
      return false
    end
    R("CHECKING...")
    local m = O .. ("?key=" .. (V(j) .. ("&id=" .. (V(P) .. ("&product=" .. V(r))))))
    local I, Y, L = pcall(fetch, m)
    if not I then
      R("SERVER ERROR")
      u = false
      if not z then
        d("License server request failed.")
      end
      return false
    end
    if Z ~= q then
      u = false
      return false
    end
    Y = tostring(Y or "")
    Y = (Y:gsub("^%s+", "")):gsub("%s+$", "")
    if Y:find("OK|PERMANENT", 1, true) then
      R("VERIFIED - PERMANENT")
      local O = G(j)
      if O then
        T = j
      end
      u = false
      if not z then
        d(O and "License verified and saved." or "License verified. Could not save the key.")
      end
      return true
    end
    local f = Y
    local D = "LICENSE CHECK FAILED"
    if f:find("DENY|DISABLED", 1, true) then
      R("DISABLED")
      D = "License disabled."
    elseif f:find("DENY|WRONG_PRODUCT", 1, true) then
      R("WRONG PRODUCT")
      D = "This license is for another script."
    elseif f:find("DENY|BOUND_TO_OTHER_USER", 1, true) then
      R("BOUND TO OTHER USER")
      D = "License is bound to another user."
    elseif f:find("DENY|INVALID_KEY", 1, true) then
      R("INVALID KEY")
      D = "Invalid license key."
    elseif f:find("DENY|BAD_KEY_FORMAT", 1, true) then
      R("BAD KEY FORMAT")
      D = "License key format is invalid."
    elseif f:find("DENY|NO_ID", 1, true) then
      R("NO CLIENT ID")
      D = "Client ID is unavailable."
    elseif f:find("DENY|", 1, true) then
      R("DENIED")
      D = "License denied by server."
    elseif f == "" then
      R("NO RESPONSE")
      D = "License server gave no response."
    else
      R("CHECK FAILED")
      D = "License check failed."
    end
    u = false
    if not z then
      d(D)
    end
    return false
  end
  t["saved"] = T
  local p = onValue
  local function x()
    q = q + 1
    if N then
      N = false
      D("start", false)
    end
  end
  function onValue(O, r, z)
    if P then
      return
    end
    if r == "AW_licensekey" then
      if Z then
        L("licensekey", l)
        return
      end
      local O = U(z)
      if O ~= l then
        x()
        l = O
        R("NOT VERIFIED")
      end
      return
    elseif r == "AW_clearlicense" then
      if Z then
        d("Stop the script before clearing the license.")
        return
      end
      x()
      l = ""
      T = ""
      local O = E()
      L("licensekey", "")
      R(O and "NOT VERIFIED" or "SAVED KEY COULD NOT BE CLEARED")
      return
    elseif r == "AW_verifylicense" then
      local O = q
      if not u then
        local r = pcall(runThread, function()
          v(false, O)
        end)
        if not r then
          R("COULD NOT START CHECK")
        end
      end
      return
    elseif r ~= "AW_start" then
      return p(O, r, z)
    end
    local m = z == true or z == 1 or z == "true" or z == "1"
    if not m then
      x()
      return p(O, r, false)
    end
    if Z or N then
      return
    end
    if j then
      D("start", false)
      d("Wait for the previous run to stop.")
      return
    end
    q = q + 1
    local I = q
    N = true
    f("CHECKING LICENSE BEFORE START")
    local H = pcall(runThread, function()
      local z = 0
      while u and (I == q and z < 30000) do
        Sleep(100)
        z = z + 100
      end
      if I ~= q then
        return
      end
      local Z, j = pcall(v, false, I)
      if I ~= q then
        return
      end
      N = false
      if not Z or not j then
        D("start", false)
        f("LICENSE CHECK FAILED - PRESS START TO RETRY")
        return
      end
      p(O, r, true)
    end)
    if not H then
      N = false
      D("start", false)
      f("COULD NOT START LICENSE CHECK")
    end
  end
end
local n = UserInterface["new"](O, "WaterDrop")
n:addLabelApp(O, "WaterDrop")
n:addInputString("License Key", t["saved"], "A1234567", "A1234567", nil, "AW_licensekey")
n:addButton("Verify License", "AW_verifylicense")
n:addButton("Clear Saved License", "AW_clearlicense")
n:addDisplayList("License Status", "NOT VERIFIED", "AW_licensestatus")
n:addToggle("Start / Stop", false, "AW_start")
local a = (n:addDialog("Select Mode Settings", "Choose one mode", {}))["menu"]
n:addChildToggle(a, "Put Water", z["put"], "AW_put")
n:addChildToggle(a, "Take Water", not z["put"], "AW_take")
n:addToggle("Auto Collect", z["collect"], "AW_collect")
local c = (n:addDialog("Auto Collect Settings", "Water Buckets only. Blank uses the working world.", {}))["menu"]
n:addChildInputString(
  c,
  "Collection World",
  z["collectWorld"],
  "WORLD|DOORID",
  "Current world if blank",
  nil,
  "AW_collectWorld"
)
n:addChildButton(c, "Use Current World", "AW_hereCollect")
local w = (n:addDialog("Auto Drop Settings", "Take Water stores at 190, keeping one bucket. Left shift on full.", {}))["menu"]
n:addChildInputString(w, "Drop World", z["dropWorld"], "WORLD|DOORID", "Current world if blank", nil, "AW_dropWorld")
n:addChildButton(w, "Use Current World", "AW_hereDrop")
n:addChildInputInt(w, "Drop Position X", z["dropX"], "X", "", nil, "AW_dropX")
n:addChildInputInt(w, "Drop Position Y", z["dropY"], "Y", "", nil, "AW_dropY")
n:addDisplayList("Current Drop Position", "", "AW_dropCurrent")
local h = (n:addDialog("Delay Settings", "Milliseconds", {}))["menu"]
n:addChildInputInt(h, "Place / Take Delay", tostring(z["placeDelay"]), "ms", "200", nil, "AW_placeDelay")
n:addChildInputInt(h, "FindPath Delay", tostring(z["pathDelay"]), "ms", "325", nil, "AW_pathDelay")
n:addChildInputInt(h, "Auto Collect Delay", tostring(z["collectDelay"]), "ms", "100", nil, "AW_collectDelay")
n:addDisplayList("Progress", "0 confirmed", "AW_progress")
n:addDisplayList("Status", "STOPPED", "AW_status")
m(addCategory, O, "WaterDrop")
m(addIntoModule, n:generateJSON(), O)
m(applyHook)
if type(setOnValue) == "function" then
  for O, r in ipairs({
    "AW_licensekey",
    "AW_verifylicense",
    "AW_clearlicense",
    "AW_start",
    "AW_put",
    "AW_take",
    "AW_collect",
    "AW_collectWorld",
    "AW_dropWorld",
    "AW_dropX",
    "AW_dropY",
    "AW_placeDelay",
    "AW_pathDelay",
    "AW_collectDelay",
  }) do
    local z = r
    pcall(setOnValue, z, function(...)
      local O = select("#", ...)
      if O > 0 then
        onValue(nil, z, select(O, ...))
      end
    end)
  end
end
