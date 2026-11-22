local n = 1
local e, L = 57, 41
local c = false
systemlog = "`7[`9DhpleProxy`7]`o "
systemcmd = "`7[`9DhpleProxy`7]`9 "
wan =
  "\nadd_label_with_icon|big| PROXY BY DPOLEEX86                                       |left|5956|\nadd_label_with_icon|small|`4It NEW PROXY BY DHEPOLEEX!!!!|left|1432|\nadd_spacer|small|\nadd_label_with_icon|big|`2Csn Helper:|left|758|\nadd_textbox|`o/dpl `2- Show all command|left|2440|\nadd_textbox|`o/wd `2- Drop World Lock|left|2440|\nadd_textbox|`o/dd `2- Drop Diamond Lock|left|2440|\nadd_textbox|`o/db `2- Drop Blue Gem Lock|left|2440|\nadd_textbox|`o/cd `2- Drop DL and BGL |left|2440|\nadd_textbox|`o/lock `2- Show Amount Lock In Backpack|left|2440|\nadd_textbox|`o/daw `2- Drop All Lock In Backpack|left|2440|\nadd_spacer|small|\nadd_label_with_icon|big|`2More command:|left|2586|\nadd_textbox|`o/res `2- Respawn|left|2440|\nadd_textbox|`o/relog `2- exit from world|left|2440|\nadd_textbox|`o/dc `2- disconnect |left|2440|\nadd_textbox|`o/ft `2- ModFly On |left|2440|\nadd_textbox|`o/nf `2- ModFly Off |left|2440|\nadd_textbox|`o/ghost `2- No Clip and Ghost On |left|2440|\nadd_textbox|`o/gf `2- No Clip and Ghost Off |left|2440|\nadd_spacer|small|\nadd_label_with_icon|big|`2Wrench Mode:|left|32|\nadd_textbox|`o/p `2- Pull On|left|2440|\nadd_textbox|`o/fp `2- Pull Off |left|2440|\nadd_spacer|small|\nadd_label_with_icon|big|`2Telephone Helper:|left|2586|\nadd_textbox|`o/cv `2- Auto Convert Telephone On/Off|left|2440|\nadd_spacer|small|\nadd_label_with_icon|small|the link to my discord server is below. If you have any questions or want report a bug, please contact me.|left|486|\nadd_spacer|small|\nadd_url_button|| HERE|NOFLAGS|https://discord.gg/KzAjgW252d|`0CLICK Launch for join my server discord|0|0|\nadd_quick_exit|\nend_dialog|end|Cancel|Okay"
function wear(n)
  local e = {}
  e["type"] = 10
  e["value"] = n
  SendPacketRaw(false, e)
end
function log(n)
  LogToConsole(systemcmd .. n)
end
function checkitm(n)
  for e, L in pairs(GetInventory()) do
    if L["id"] == n then
      return L["amount"]
    end
  end
  return 0
end
function dl()
  local n = false
  for e, L in pairs(GetInventory()) do
    if L["id"] == 1796 then
      n = true
      SendPacket(2, "action|drop\n|itemID|1796")
      log("`2Succes Dropped `0" .. (L["amount"] .. " `2Diamond Lock"))
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|1796|\ncount|" .. L["amount"])
    end
  end
  if not n then
    log("`4You don't have any Diamond Lock in your backpack!")
  end
end
function wl()
  local n = false
  for e, L in pairs(GetInventory()) do
    if L["id"] == 242 then
      n = true
      SendPacket(2, "action|drop\n|itemID|242")
      log("`2Succes Dropped `0" .. (L["amount"] .. " `2World Lock"))
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|242|\ncount|" .. L["amount"])
    end
  end
  if not n then
    log("`4You don't have any World Lock in your backpack!")
  end
end
function bgl()
  local n = false
  for e, L in pairs(GetInventory()) do
    if L["id"] == 7188 then
      n = true
      SendPacket(2, "action|drop\n|itemID|7188")
      log("`2Succes Dropped `0" .. (L["amount"] .. " `2Blue Gem Lock"))
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|7188|\ncount|" .. L["amount"])
    end
  end
  if not n then
    log("`4You don't have any Blue Gem Lock in your backpack!")
  end
end
function dropDlBglByAmount(n)
  if not n or n <= 0 then
    log("`4Invalid amount")
    return
  end
  local e = math["floor"](n / 100)
  local L = n % 100
  log("`5Parsing: " .. (n .. (" \226\134\146 BGL: " .. (e .. (", DL: " .. L)))))
  if e > 0 then
    local n = checkitm(7188)
    if n >= e then
      SendPacket(2, "action|drop\n|itemID|7188")
      Sleep(300)
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|7188|\ncount|" .. e)
      log("`2Succes Dropped `0" .. (e .. " `2Blue Gem Lock"))
    else
      log("`4You don't have enough Blue Gem Lock! (Have: " .. (n .. (", Need: " .. (e .. ")"))))
    end
  end
  Sleep(500)
  if L > 0 then
    local n = checkitm(1796)
    if n >= L then
      SendPacket(2, "action|drop\n|itemID|1796")
      Sleep(300)
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|1796|\ncount|" .. L)
      log("`2Succes Dropped `0" .. (L .. " `2Diamond Lock"))
    else
      log("`4You don't have enough Diamond Lock! (Have: " .. (n .. (", Need: " .. (L .. ")"))))
    end
  end
end
function toggleAutoConvert()
  c = not c
  if c then
    n = 1
    log("`2Auto Convert Telephone: `aACTIVATED")
  else
    log("`4Auto Convert Telephone: `cDEACTIVATED")
  end
end
function autoConvertHandler(d)
  if not c then
    return false
  end
  if d["v1"] == "OnDialogRequest" then
    if d["v2"]:find("Telephone") then
      e = d["v2"]:match("tilex|(%d+)") or e
      L = d["v2"]:match("tiley|(%d+)") or L
      if n == 1 then
        SendPacket(
          2,
          "action|dialog_return\ndialog_name|phonecall\ntilex|"
            .. (e .. ("|\ntiley|" .. (L .. "|\nnum|53785|\nbuttonClicked|chc5")))
        )
        log("`7Pos: " .. (e .. ("," .. L)))
        n = 2
      else
        SendPacket(
          2,
          "action|dialog_return\ndialog_name|phonecall\ntilex|"
            .. (e .. ("|\ntiley|" .. (L .. "|\nnum|-34|\nbuttonClicked|chc0")))
        )
        log("`7 Pos: " .. (e .. ("," .. L)))
        n = 3
      end
      return true
    end
    if d["v2"]:find("Wow, that's fast delivery.") then
      log("`2Wow, that's fast delivery.")
      n = 1
      return true
    end
  end
  return false
end
function command(n, e)
  local L = "action|input\n|text|"
  if n:find(L .. e) then
    LogToConsole("`6" .. e)
    return true
  end
  return false
end
function on_sendpacket(n, e)
  if command(e, "/dpl") then
    local n = {}
    n["v1"] = "OnDialogRequest"
    n["v2"] = wan
    SendVariant(n)
    log("Welcome to DepoLx!")
    return true
  end
  if command(e, "/cv") then
    toggleAutoConvert()
    return true
  end
  if command(e, "/dd") then
    local n = e:gsub("action|input\n|text|/dd", "")
    if n == "" then
      log("`2Write Amount")
    else
      local e = tonumber(n)
      if checkitm(1796) < e then
        log("`4You don't have enough Diamond Lock!")
        log("`6You have: " .. (checkitm(1796) .. (", requested: " .. e)))
        return true
      end
      SendPacket(2, "action|drop\n|itemID|1796")
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|1796|\ncount|" .. n)
      growtopia["notify"]("`2Success Drop`0" .. (n .. " `2Diamond Lock"))
      return true
    end
  end
  if command(e, "/wd") then
    local n = e:gsub("action|input\n|text|/wd", "")
    if n == "" then
      log("`2Write Amount")
    else
      local e = tonumber(n)
      if checkitm(242) < e then
        log("`4You don't have enough World Lock!")
        log("`6You have: " .. (checkitm(242) .. (", requested: " .. e)))
        return true
      end
      SendPacket(2, "action|drop\n|itemID|242")
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|242|\ncount|" .. n)
      growtopia["notify"]("`2Success Drop`0" .. (n .. " `2World Lock"))
      return true
    end
  end
  if command(e, "/cd") then
    local n = e:gsub("action|input\n|text|/cd", "")
    if n == "" then
    else
      local e = tonumber(n)
      if e then
        dropDlBglByAmount(e)
      else
        log("`4Invalid amount")
      end
    end
    return true
  end
  if command(e, "/res") then
    SendPacket(2, "action|respawn")
    log("`2Success Respawn")
    growtopia["notify"]("`2Success Respawn")
    return true
  end
  if command(e, "/relog") then
    SendPacket(3, "action|quit_to_exit")
    log("`2Success Relog")
    growtopia["notify"]("`2Success relog")
    return true
  end
  if command(e, "/dc") then
    SendPacket(3, "action|quit")
    log("`2Disconnected")
    growtopia["notify"]("`2Disconnected")
    return true
  end
  if command(e, "/p") then
    editToggle("Fast Wrench", true)
    editToggle("Value", 1)
    growtopia["notify"]("Pull Mode On")
    return true
  end
  if command(e, "/ghost") then
    editToggle("NoClip and Ghost", true)
    editToggle("Value", 1)
    growtopia["notify"]("Ghost Mode On")
    return true
  end
  if command(e, "/gf") then
    editToggle("NoClip and Ghost", false)
    editToggle("Value", 1)
    growtopia["notify"]("Ghost Mode Off")
    return true
  end
  if command(e, "/ft") then
    editToggle("ModFly", true)
    editToggle("Value", 1)
    growtopia["notify"]("ModFly Mode On")
    return true
  end
  if command(e, "/nf") then
    editToggle("ModFly", false)
    editToggle("Value", 1)
    growtopia["notify"]("ModFly Mode Off")
    return true
  end
  if command(e, "/fp") then
    editToggle("Fast Wrench", false)
    growtopia["notify"]("Pull Mode Off")
    return true
  end
  if command(e, "/db") then
    local n = e:gsub("action|input\n|text|/db", "")
    if n == "" then
      log("`2Write Amount")
    else
      local e = tonumber(n)
      if checkitm(7188) < e then
        log("`4You don't have enough Blue Gem Lock!")
        log("`6You have: " .. (checkitm(7188) .. (", requested: " .. e)))
        return true
      end
      SendPacket(2, "action|drop\n|itemID|7188")
      SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|7188|\ncount|" .. n)
      growtopia["notify"]("`2Success Drop`0" .. (n .. " `2Blue Gem Lock"))
      return true
    end
  end
  if command(e, "/daw") then
    if checkitm(242) > 0 or checkitm(1796) > 0 or checkitm(7188) > 0 then
      wl()
      dl()
      bgl()
      log("`2All locks dropped from backpack!")
    else
      log("`4You don't have any locks in your backpack!")
    end
    return true
  end
  if command(e, "/lock") then
    local n = checkitm(242)
    local e = checkitm(1796)
    local L = checkitm(7188)
    LogToConsole(
      "`0Your World Locks`0 : " .. (n .. (" `9World Lock`0, `1" .. (e .. (" `1Diamond Lock`0, `c" .. (L .. " `cBGL")))))
    )
    if n == 0 and (e == 0 and L == 0) then
      log("`4You don't have any locks in your backpack!")
    end
    return true
  end
  return false
end
function variantlist(n)
  if autoConvertHandler(n) then
    return true
  end
  if n["v1"] == "OnDialogRequest" then
    if n["v2"]:find("drop") and (n["v2"]:find("242") or n["v2"]:find("1796") or n["v2"]:find("7188")) then
      return true
    end
  end
  if n["v1"] == "OnConsoleMessage" then
    if n["v2"]:match("Collected `w(%d+) World Lock``") then
      wear(242)
      return true
    end
  end
  if n["v1"] == "OnTalkBubble" and n["v3"]:find("You need to be") then
    return true
  end
  if n["v1"] == "OnTalkBubble" and n["v3"]:find("spun the wheel and got") then
    local e = n["v3"]:match("`4(%d+)``!") or n["v3"]:match("`b(%d+)``!") or n["v3"]:match("`2(%d+)``!")
    if e then
      local L, c = math["floor"](e / 10), e % 10
      local d = L + c
      if d > 10 then
        d = d % 10
      elseif d == 10 then
        d = 0
      end
      SendVariant({
        ["v1"] = "OnTalkBubble",
        ["v2"] = n["v2"],
        ["v3"] = "`w[ `9REAL `w] " .. (n["v3"] .. (" `2[ `9REME : `w" .. (d .. " `2]"))),
      })
      return true
    end
  end
  return false
end
LogToConsole("`9Dpl Proxy Started - BETA PROXY")
AddHook(on_sendpacket, "OnSendPacket")
AddHook(variantlist, "OnVariant")
SendPacket(2, "action|input\n|text|`#PROXY BY DHEPOLEEX")
