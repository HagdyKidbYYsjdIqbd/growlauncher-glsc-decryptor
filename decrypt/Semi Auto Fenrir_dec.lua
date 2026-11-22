local C = "Auto Fenrir Bot"
local N = "FenrirBLE23"
local L = "wolfworld"
local m = 18
local A = {
  "/storage/emulated/0/Android/media/launcher.powerkuy.growlauncher/ScriptLua/",
  "/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/media/ScriptLua/",
  "/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/files/ScriptLua/",
  "/storage/emulated/0/Android/data/launcher.powerkuy.growlauncher/ScriptLua/",
}
local function O()
  for C, N in ipairs(A) do
    local L, m = pcall(function()
      return io["open"](N .. ".path_test", "w")
    end)
    if L and m then
      pcall(function()
        m:close()
      end)
      pcall(function()
        os["remove"](N .. ".path_test")
      end)
      return N
    end
  end
  return A[1]
end
local F = O()
local J = F .. "key_fenrir.txt"
local s = F .. "fenrir_config.txt"
local r = sleep or Sleep or CSleep
local I = FindPath or findPath
local T = getTiles or GetTiles
local d = getTile or GetTile
local a = getLocal or GetLocal
local P = getInventory or GetInventory
local v = GetWorldName or getCurrentWorldName or getWorldName
local c = sendPacketRaw or SendPacketRaw
local i = sendPacket or SendPacket
local function g(C, N)
  local L = 0
  pcall(function()
    if type(getItemID) == "function" then
      L = tonumber(getItemID(C)) or 0
    elseif type(GetItemID) == "function" then
      L = tonumber(GetItemID(C)) or 0
    elseif type(growtopia) == "table" and type(growtopia["getItemID"]) == "function" then
      L = tonumber(growtopia["getItemID"](C)) or 0
    elseif type(findItemID) == "function" then
      L = tonumber(findItemID(C)) or 0
    end
  end)
  if L and L > 0 then
    return L
  end
  return N or 0
end
local e = g("Challenge of Fenrir", 0)
local q = g("Valhowla Treasure", 0)
local z = g("White Wallpaper", 544)
local function K()
  if e <= 0 then
    e = g("Challenge of Fenrir", 0)
  end
  if q <= 0 then
    q = g("Valhowla Treasure", 0)
  end
  if z <= 0 then
    z = g("White Wallpaper", 544)
  end
end
K()
local X = false
local V = false
local p = false
local Y = false
local R = false
local x = 0
local j = 0
local y = "None"
local B = false
local Z = false
local D = 12
local o = 6
local M = 3
local b = 12
local l = 100
local u = {}
local t = {}
local function h()
  local C = false
  pcall(function()
    local L = io["open"](J, "r")
    if L then
      local m = L:read("*all")
      L:close()
      if m then
        m = (m:gsub("^%s+", "")):gsub("%s+$", "")
        if m == N or m == "verified" then
          C = true
        end
      end
    end
  end)
  return C
end
local function w()
  pcall(function()
    local C = io["open"](J, "w")
    if C then
      C:write(N)
      C:close()
    end
  end)
end
local function S()
  pcall(function()
    local C = io["open"](s, "r")
    if not C then
      return
    end
    for C in C:lines() do
      local N, L = C:match("^%s*([^=]+)=(.*)%s*$")
      if N and L then
        N = (N:gsub("^%s+", "")):gsub("%s+$", "")
        L = (L:gsub("^%s+", "")):gsub("%s+$", "")
        if N == "console_logging_enabled" then
          R = (L == "true")
        elseif N == "delay_world_change_s" then
          D = tonumber(L) or 12
        elseif N == "delay_after_prize_s" then
          o = tonumber(L) or 6
        elseif N == "delay_before_wolfworld_s" then
          M = tonumber(L) or 3
        elseif N == "delay_after_wolfworld_s" then
          b = tonumber(L) or 12
        elseif N == "delay_path_ms" then
          l = tonumber(L) or 100
        end
      end
    end
    C:close()
  end)
end
local function W()
  pcall(function()
    local C = io["open"](s, "w")
    if not C then
      return
    end
    C:write("console_logging_enabled=" .. (tostring(R) .. "\n"))
    C:write("delay_world_change_s=" .. (tostring(D) .. "\n"))
    C:write("delay_after_prize_s=" .. (tostring(o) .. "\n"))
    C:write("delay_before_wolfworld_s=" .. (tostring(M) .. "\n"))
    C:write("delay_after_wolfworld_s=" .. (tostring(b) .. "\n"))
    C:write("delay_path_ms=" .. (tostring(l) .. "\n"))
    C:close()
  end)
end
X = h()
S()
local function H(N)
  if not R then
    return
  end
  pcall(function()
    LogToConsole("`9[" .. (C .. ("]`o " .. tostring(N))))
  end)
end
local function n(N)
  if not R then
    return
  end
  pcall(function()
    LogToConsole("`4[" .. (C .. ("]`o " .. tostring(N))))
  end)
end
local function U(C, N)
  pcall(function()
    if type(editToggle) == "function" then
      editToggle(C, N)
    end
    if type(EditToggle) == "function" then
      EditToggle(C, N)
    end
  end)
end
local function Q()
  U("ModFly", true)
  U("AntiGravity", true)
  U("Night Vision", true)
  U("NightVision", true)
  U("Antibounce", true)
  U("AntiBounce", true)
  U("Anti Bounce", true)
end
local function E()
  U("ModFly", false)
  U("AntiGravity", false)
  U("Night Vision", false)
  U("NightVision", false)
  U("Antibounce", false)
  U("AntiBounce", false)
  U("Anti Bounce", false)
end
local function k()
  U("ModFly", false)
  U("AntiGravity", false)
end
local function f(C)
  local N = a()
  local L = (N and (N["netid"] or N["netID"] or N["netId"])) or -1
  pcall(function()
    if type(sendVariant) == "function" then
      sendVariant({ ["v1"] = "OnTalkBubble", ["v2"] = L, ["v3"] = C })
    elseif type(SendVariantList) == "function" then
      SendVariantList({ ["v1"] = "OnTalkBubble", ["v2"] = L, ["v3"] = C })
    elseif type(SendVarlist) == "function" then
      SendVarlist({ ["v1"] = "OnTalkBubble", ["v2"] = L, ["v3"] = C })
    end
  end)
  H("Notification: " .. tostring(C))
end
local function G()
  local C = a()
  if not C then
    return nil, nil, nil, nil
  end
  local N = C["posX"] or (C["pos"] and C["pos"]["x"]) or C["x"] or 0
  local L = C["posY"] or (C["pos"] and C["pos"]["y"]) or C["y"] or 0
  return math["floor"](N / 32), math["floor"](L / 32), N, L
end
local function Ch(C)
  if not C or C <= 0 then
    return 0
  end
  local N = P()
  if not N then
    return 0
  end
  for N, L in pairs(N) do
    if tonumber(L["id"]) == tonumber(C) then
      return tonumber(L["amount"] or L["count"]) or 0
    end
  end
  return 0
end
local function Nh()
  local C = v()
  if not C then
    return ""
  end
  return (tostring(C)):upper()
end
local function Lh()
  local C = Nh()
  return (C:find("VALHOWLA") ~= nil)
end
local function mh()
  while V and p do
    r(200)
  end
  return V
end
local function Ah(C)
  local N = 0
  local L = 50
  while V and N < C do
    if not mh() then
      return false
    end
    local m = math["min"](L, C - N)
    r(m)
    N = N + m
  end
  return V
end
local function Oh(C, N)
  if C < 0 or C > 99 or N < 0 or N > 59 then
    return nil
  end
  if type(d) == "function" then
    local L, m = pcall(d, C, N)
    if L and m then
      return m
    end
  end
  local L = T()
  if L then
    for L, m in pairs(L) do
      if m["x"] == C and m["y"] == N then
        return m
      end
    end
  end
  return nil
end
local function Fh(C, N)
  if C < 0 or C > 99 or N < 0 or N > 59 then
    return false
  end
  local L = Oh(C, N)
  if not L then
    return false
  end
  if L["collidable"] then
    return false
  end
  return true
end
local function Jh(C, N)
  local L, m = G()
  local A = nil
  local O = 999999
  for F = 1, 8, 1 do
    for J = -F, F, 1 do
      for F = -F, F, 1 do
        local s = C + F
        local r = N + J
        if s >= 0 and (s <= 99 and (r >= 0 and r <= 59)) then
          local F = true
          pcall(function()
            F = I(s, r, true)
          end)
          if F == false then
            local F = math["abs"](s - (L or C)) + math["abs"](r - (m or N))
            if F < O then
              O = F
              A = { ["x"] = s, ["y"] = r }
            end
          end
        end
      end
    end
    if A then
      break
    end
  end
  return A
end
local function sh(C, N)
  if not mh() then
    return false
  end
  if C < 0 or C > 99 or N < 0 or N > 59 then
    return false
  end
  local L, m = G()
  if L == C and m == N then
    return true
  end
  for A = 1, 4, 1 do
    if not mh() then
      return false
    end
    pcall(function()
      I(C, N)
    end)
    r(l)
    local O = 0
    while V and O < 1000 do
      if not mh() then
        return false
      end
      L, m = G()
      if L == C and m == N then
        return true
      end
      r(50)
      O = O + 50
    end
    L, m = G()
    if L and (m and (math["abs"](L - C) <= 1 and (math["abs"](m - N) <= 1 and A >= 2))) then
      return true
    end
  end
  return false
end
local function rh(C, N, L)
  if C < 0 or C > 99 or N < 0 or N > 59 then
    return
  end
  pcall(function()
    if type(tile) == "table" and (type(tile["setBg"]) == "function" and type(tile["getTile"]) == "function") then
      local m = tile["getTile"](C, N)
      if m then
        tile["setBg"](m, L)
      end
    end
  end)
  pcall(function()
    local m = Oh(C, N)
    if m then
      m["bg"] = L
    end
  end)
  pcall(function()
    local m = a()
    local A = (m and (m["netid"] or m["netID"] or m["netId"])) or -1
    c(
      true,
      { ["type"] = 3, ["netid"] = A, ["value"] = L, ["px"] = C, ["py"] = N, ["punchX"] = C, ["punchY"] = N, ["x"] = C
        * 32, ["y"] = N
        * 32 }
    )
  end)
end
local function Ih(C, N)
  t = {}
  K()
  local L = (z > 0) and z or 544
  for m = -2, 2, 1 do
    for A = -2, 2, 1 do
      local O = C + A
      local F = N + m
      if O >= 0 and (O <= 99 and (F >= 0 and F <= 59)) then
        local C = Oh(O, F)
        local N = (C and tonumber(C["bg"])) or 0
        table["insert"](t, { ["x"] = O, ["y"] = F, ["bg"] = N })
        rh(O, F, L)
      end
    end
  end
end
local function Th()
  for C, N in ipairs(t) do
    rh(N["x"], N["y"], N["bg"])
  end
  t = {}
end
local function dh()
  local C, N, L, A = G()
  if not C then
    return false
  end
  c(
    false,
    {
      ["type"] = 3,
      ["value"] = m,
      ["x"] = L,
      ["y"] = A,
      ["px"] = C,
      ["py"] = N,
      ["punchX"] = C,
      ["punchY"] = N,
      ["xspeed"] = 0,
      ["yspeed"] = 0,
      ["XSpeed"] = 0,
      ["YSpeed"] = 0,
      ["state"] = 0,
      ["characterState"] = 0,
      ["time"] = 0,
      ["ptime"] = 0,
    }
  )
  return true
end
local function ah(C, N)
  Ih(C, N)
  Z = false
  Q()
  local L = N - 1
  local m = (L >= 0) and Fh(C, L)
  if m then
    local m = sh(C, L)
    if m then
      k()
      local C = 0
      while C < 500 do
        local L, m = G()
        if m and m >= N then
          break
        end
        r(40)
        C = C + 40
      end
      dh()
      local L = 0
      while V and L < 2500 do
        if Z or B then
          break
        end
        r(50)
        L = L + 50
      end
      Th()
      Q()
      return (Z or B)
    end
  end
  local A = false
  local O = Fh(C - 1, N)
  local F = Fh(C + 1, N)
  if O and sh(C - 1, N) then
    A = true
    f("`4GO RIGHT")
  elseif F and sh(C + 1, N) then
    A = true
    f("`4GO LEFT")
  end
  if not A and (Fh(C, N + 1) and sh(C, N + 1)) then
    A = true
    f("`4GO UP")
  end
  if not A and sh(C, N) then
    A = true
    dh()
  end
  if not A then
    local L = Jh(C, N)
    if L then
      sh(L["x"], L["y"])
    end
    f("`4WAY CLOSED GO URSELF")
  end
  local J = 0
  while V and J < 30000 do
    if not mh() then
      break
    end
    if Z or B then
      break
    end
    r(100)
    J = J + 100
  end
  Th()
  Q()
  return (Z or B)
end
local function Ph()
  K()
  if e <= 0 then
    n("Challenge of Fenrir item ID not found via getItemID!")
    return false
  end
  local C, N, L, m = G()
  if not C then
    return false
  end
  H("Using Challenge of Fenrir (ID: " .. (tostring(e) .. (") at (" .. (C .. (", " .. (N .. ")..."))))))
  c(
    false,
    {
      ["type"] = 3,
      ["value"] = e,
      ["x"] = L,
      ["y"] = m,
      ["px"] = C,
      ["py"] = N,
      ["punchX"] = C,
      ["punchY"] = N,
      ["xspeed"] = 0,
      ["yspeed"] = 0,
      ["XSpeed"] = 0,
      ["YSpeed"] = 0,
      ["state"] = 0,
      ["characterState"] = 0,
      ["time"] = 0,
      ["ptime"] = 0,
    }
  )
  return true
end
local function vh(C)
  if not C or C == "" then
    return false
  end
  local N = C:upper()
  if Nh() == N then
    return true
  end
  while V and Nh() ~= N do
    if not mh() then
      return false
    end
    H("Warping to " .. (tostring(C) .. "..."))
    i(3, "action|join_request\nname|" .. (tostring(C) .. "\ninvitedWorld|0"))
    local L = 0
    while V and L < 8000 do
      if not mh() then
        return false
      end
      if Nh() == N then
        Ah(2000)
        return true
      end
      r(250)
      L = L + 250
    end
  end
  return (Nh() == N)
end
local function ch()
  K()
  local C = T()
  if not C then
    return nil, 0
  end
  local N, L = G()
  local m = nil
  local A = 999999
  local O = 0
  for C, F in pairs(C) do
    local J = tonumber(F["fg"]) or 0
    if q > 0 and J == q then
      local C = F["x"] .. ("," .. F["y"])
      if not u[C] then
        O = O + 1
        local J = math["abs"](F["x"] - (N or 0)) + math["abs"](F["y"] - (L or 0))
        if J < A then
          A = J
          m = { ["x"] = F["x"], ["y"] = F["y"], ["key"] = C }
        end
      end
    end
  end
  return m, O
end
local function ih()
  if Y then
    return
  end
  Y = true
  pcall(function()
    if not X then
      editValue("ui_key_status", "UNVERIFIED (LOCKED)")
    else
      local C = "STOPPED"
      if V then
        C = p and "PAUSED" or "RUNNING"
      end
      editValue("ui_status", C)
      editValue("ui_treasures", tostring(j))
      editValue("ui_challenges", tostring(x))
      editValue("ui_last_prize", tostring(y))
    end
  end)
  Y = false
end
local function gh()
  runCoroutine(function()
    r(200)
    local C =
      "set_default_color|`o\nadd_label_with_icon|big|`9AUTO FENRIR // AUTH``|left|18|\nadd_textbox|`c--------------------------------------------|\nadd_textbox|`7Enter your license key to unlock the module.|\nadd_spacer|small|\nadd_text_input|key_input|Secret Key:| |24|\nadd_spacer|small|\nadd_button|btn_verify_key|`9UNLOCK MODULE``|noflags|0|0|\nadd_quick_exit|\nend_dialog|fenrir_auth|Close||"
    pcall(function()
      if type(growtopia) == "table" and type(growtopia["sendDialog"]) == "function" then
        growtopia["sendDialog"](C)
      elseif type(sendVariant) == "function" then
        sendVariant({ ["v1"] = "OnDialogRequest", ["v2"] = C })
      end
    end)
  end)
end
local eh
eh = function()
  local N = UserInterface["new"](C, "Verified")
  N:addLabelApp("Auto Fenrir Engine", "Verified")
  N:addDivider()
  if not X then
    N:addLabel("License Locked")
    N:addDisplayList("Status", "UNVERIFIED (LOCKED)", "ui_key_status")
    N:addButton("Unlock Key Module", "btn_verify")
  else
    N:addLabel("Bot Status")
    N:addDisplayList("Status", V and (p and "PAUSED" or "RUNNING") or "STOPPED", "ui_status")
    N:addDisplayList("Treasures Claimed", tostring(j), "ui_treasures")
    N:addDisplayList("Completed Challenges", tostring(x), "ui_challenges")
    N:addDisplayList("Last Prize", tostring(y), "ui_last_prize")
    N:addDivider()
    N:addLabel("Engine Controls")
    N:addButton("START", "btn_start")
    N:addButton("PAUSE / CONTINUE", "btn_pause")
    N:addButton("STOP", "btn_stop")
    N:addDivider()
    N:addLabel("Delay Settings")
    N:addSlider("World Change Delay (s)", 2, 30, D, 1, false, "sld_world_change")
    N:addSlider("After Prize Delay (s)", 1, 20, o, 1, false, "sld_after_prize")
    N:addSlider("Before Wolfworld Delay (s)", 1, 15, M, 1, false, "sld_before_wolfworld")
    N:addSlider("After Wolfworld Delay (s)", 2, 30, b, 1, false, "sld_after_wolfworld")
    N:addSlider("Teleport / Path Delay (ms)", 20, 500, l, 10, false, "sld_path_ms")
  end
  local L = N:generateJSON()
  if L then
    pcall(function()
      addCategory("Scripts", "Verified")
    end)
    pcall(function()
      addIntoModule(L, "Scripts")
    end)
  end
end
local function qh(C)
  V = false
  p = false
  Th()
  E()
  if C then
    n(C)
  end
  ih()
end
local function zh()
  H("Auto Fenrir Engine STARTED. Cheats enabled.")
  while V do
    if not mh() then
      break
    end
    if Lh() then
      H("Already inside " .. (Nh() .. "! Bypassing Challenge of Fenrir..."))
    else
      K()
      if e <= 0 then
        qh("Challenge of Fenrir item not found (ID = 0)! Bot stopped.")
        break
      end
      if Ch(e) <= 0 then
        qh("No Challenge of Fenrir found in backpack! Bot stopped.")
        break
      end
      local C = Nh()
      local N = false
      local L = 0
      while V and not N do
        if not mh() then
          break
        end
        Ph()
        local m = 0
        while V and m < 8000 do
          if not mh() then
            break
          end
          local L = Nh()
          if L ~= "" and (L ~= "EXIT" and L ~= C) then
            N = true
            break
          end
          r(200)
          m = m + 200
        end
        if not N and V then
          L = L + 1
          if L >= 5 then
            qh("Failed to enter Challenge of Fenrir after 5 attempts! Bot stopped.")
            return
          end
          H("World has not changed yet, retrying Challenge of Fenrir (" .. (L .. "/5)..."))
          Ah(1500)
        end
      end
      if not V then
        break
      end
      H("Entered Fenrir World (" .. (Nh() .. ("). Waiting " .. (D .. " seconds..."))))
      if not Ah(D * 1000) then
        break
      end
    end
    u = {}
    B = false
    while V do
      if not mh() then
        break
      end
      if B then
        break
      end
      local C, N = ch()
      if not C or N == 0 then
        H("All Valhowla Treasures in this world have been processed.")
        break
      end
      H("Targeting Valhowla Treasure at (" .. (C["x"] .. (", " .. (C["y"] .. ")..."))))
      local L = ah(C["x"], C["y"])
      u[C["key"]] = true
      if L then
        j = j + 1
        ih()
      end
      if B then
        H("Challenge completion message detected!")
        break
      end
      H("Waiting " .. (o .. " seconds before next treasure..."))
      if not Ah(o * 1000) then
        break
      end
    end
    if not V then
      break
    end
    H("Finished sweeping treasures. Waiting " .. (M .. (" seconds before warping to " .. (L .. "..."))))
    if not Ah(M * 1000) then
      break
    end
    x = x + 1
    ih()
    H("Warping to " .. (L .. "..."))
    if vh(L) then
      H("Arrived in " .. (L .. (". Waiting " .. (b .. " seconds before looping..."))))
      if not Ah(b * 1000) then
        break
      end
    else
      n("Failed to warp to " .. (L .. ". Retrying..."))
      Ah(2000)
    end
  end
end
local function Kh(C, N, L)
  if Y then
    return
  end
  if N == "btn_verify" then
    gh()
    return
  end
  if not X then
    return
  end
  if N == "btn_start" then
    if not V then
      V = true
      p = false
      Q()
      H("Bot STARTED. ModFly, Night Vision, and Antibounce ON.")
      ih()
      runCoroutine(zh)
    elseif p then
      p = false
      Q()
      H("Bot RESUMED. ModFly, Night Vision, and Antibounce ON.")
      ih()
    end
    return
  end
  if N == "btn_pause" then
    if V then
      p = not p
      if p then
        E()
        H("Bot PAUSED. ModFly, Night Vision, and Antibounce OFF.")
      else
        Q()
        H("Bot RESUMED. ModFly, Night Vision, and Antibounce ON.")
      end
      ih()
    end
    return
  end
  if N == "btn_stop" then
    if V then
      qh("Bot STOPPED by user. ModFly, Night Vision, and Antibounce OFF.")
    else
      E()
      H("Bot is already stopped.")
    end
    return
  end
  if N == "sld_world_change" then
    D = math["max"](2, math["floor"](tonumber(L) or 12))
    W()
    return
  end
  if N == "sld_after_prize" then
    o = math["max"](1, math["floor"](tonumber(L) or 6))
    W()
    return
  end
  if N == "sld_before_wolfworld" then
    M = math["max"](1, math["floor"](tonumber(L) or 3))
    W()
    return
  end
  if N == "sld_after_wolfworld" then
    b = math["max"](2, math["floor"](tonumber(L) or 12))
    W()
    return
  end
  if N == "sld_path_ms" then
    l = math["max"](20, math["floor"](tonumber(L) or 100))
    W()
    return
  end
end
local function Xh(L, m)
  if type(m) ~= "string" then
    return false
  end
  if m:find("action|input") then
    local L = m:match("text|([^\n\r]+)")
    if L then
      L = (L:gsub("^%s+", "")):gsub("%s+$", "")
      if L:lower() == "/console123" then
        R = not R
        W()
        pcall(function()
          LogToConsole("`9[" .. (C .. ("]`o Console Logging is now: " .. (R and "ON" or "OFF"))))
        end)
        return true
      end
      if (L:sub(1, 4)):lower() == "/key" then
        local C = L:match("^/[kK][eE][yY]%s+(.+)$")
        if C and (C:gsub("^%s+", "")):gsub("%s+$", "") == N then
          X = true
          w()
          H("Key valid! Unlocking module...")
          eh()
          ih()
        else
          n("Invalid key!")
        end
        return true
      end
    end
  end
  if m:find("action|dialog_return") then
    if m:find("dialog_name|fenrir_auth") and m:find("buttonClicked|btn_verify_key") then
      local C = m:match("key_input|([^\n\r]+)")
      if C and (C:gsub("^%s+", "")):gsub("%s+$", "") == N then
        X = true
        w()
        H("Key valid! Module unlocked.")
        eh()
        ih()
      else
        n("Invalid key! Please try again.")
        gh()
      end
      return true
    end
  end
  return false
end
local function Vh(C, N)
  if not C then
    return false
  end
  if
    C["v1"] == "OnConsoleMessage"
    or C[0] == "OnConsoleMessage"
    or C["v1"] == "OnTalkBubble"
    or C[0] == "OnTalkBubble"
  then
    local N = tostring(C["v3"] or C["v2"] or C[1] or "")
    local L = ((((N:gsub("``", "")):gsub("`.", "")):gsub("`", "")):gsub("^%s+", "")):gsub("%s+$", "")
    local m = L:lower()
    if m:find("fenrir graces you with") then
      Z = true
      local C = L:match("[Ff]enrir graces you with%s+(.-)[!%.]?$")
      if C and C ~= "" then
        y = C
      else
        y = L
      end
      H("Prize received: " .. tostring(y))
      ih()
    end
    if m:find("you have completed the challenge of fenrir") then
      B = true
      H("Challenge completed message detected: " .. L)
      ih()
    end
  end
  return false
end
pcall(function()
  removeHook("onValue")
end)
pcall(function()
  removeHook("onSendPacket")
end)
pcall(function()
  removeHook("OnSendPacket")
end)
pcall(function()
  removeHook("onVariant")
end)
pcall(function()
  removeHook("OnVariant")
end)
addHook(Kh, "onValue")
addHook(Xh, "onSendPacket")
addHook(Vh, "onVariant")
if type(applyHook) == "function" then
  pcall(applyHook)
end
eh()
ih()
if X then
  H("Loaded! Press 'START' on the module to run Fenrir Challenge.")
else
  H("Loaded (LOCKED). Click 'Unlock Key Module' on UI or type /key " .. N)
end
