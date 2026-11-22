local buyerList = {
    ["636196321232945152"] = "Author",
    ["1081186673485938718"] = "Endito3023",
    ["707192927578882049"] = "31decs",
    ["640461824600440843"] = "Alzre",
    ["352103985164976130"] = "Buklius",
    ["549210575272542220"] = "Mr.J7509",
    ["1447260953673732159"] = "1563860341/Damnian",
    ["502699422870798366"] = "FuyuID",
    ["943530231631843349"] = "PTQ1",
    ["943356298236403712"] = "insomniabears"
}

local USER_ID = getDiscordID()
local SOLVENT, STIRRER, REPLICATOR, CENTRIFUGE, CATALYST = 4440, 4442, 4436, 4434, 4438
local PROCESSOR, TANK = 4430, 4432
local TANK_READY = 65

local MIN_CHEM = 20
local TAKE_TO = 100
local MAX_STEPS = 999

local TOOL_COST = {
   [SOLVENT] = 1,
   [STIRRER] = 1,
   [REPLICATOR] = 1,
   [CATALYST] = 1
}

local ID = "hsnchem_"
local keyPass = "HsnChemsynth"
local RAW_URL = "https://api.hsnglsc.my.id/?key=key_hsngls12012027&s=link"

local running, mainActive, btnClicked = false, false, false
local foundProcessor, startProcessor, onProgress = false, false, false
local dc, waitResponse = false, false
local premium = buyerList[USER_ID]
local status = buyerList[USER_ID] and "Premium" or "Free"
local homeWorld = ""
local startTime = 0
local cfgCache, cfgTime = nil, 0

local chems = {
    [916] = 1, -- R
    [924] = 2, -- Y
    [914] = 3, -- G
    [920] = 4, -- B
    [918] = 5  -- P
}

local names = {
    [1]=916, [2]=924, [3]=914,
    [4]=920, [5]=918
}

local Hsnchem = [[
{
  "sub_name": "Auto Chemsynth",
  "description": "Auto Chemsynth by HsnGL",
  "icon": "Science",
  "menu": [
      {
          "type": "divider"
      },
      {
          "type": "toggle_button",
          "text": "START/STOP",
          "default": false,
          "alias": "hsnchem_startBtn"
      },
      {
          "type": "divider"
      },
      {
          "type": "dropdown",
          "text": "Selected Mode:",
          "default": 1,
          "value": "[\"Full Auto\", \"Semi Auto\"]",
          "alias": "hsnchem_mode"
      },
      {
          "type": "tooltip",
          "text": "Premium Features:\n[+] Unlock Full Auto\n[+] No need Key",
          "support_text": "Buy? Join Discord!",
          "background": true,
          "icon": "Lock"
      },
      {
          "type": "label",
          "text": ""
      },
      {
          "type": "tooltip",
          "text": "Delay",
          "support_text": "Don't use low delay if you're lagging",
          "background": true,
          "icon": "HourglassTop"
      },
      {
          "type": "slider",
          "text": "Delay (ms):",
          "default": 300,
          "max": 1000,
          "min": 100,
          "step": 50,
          "use_dot": true,
          "alias": "hsnchem_delay"
      },
      {
          "type": "label",
          "text": ""
      },
      {
          "type": "divider"
      },
      {
          "type": "divider"
      },
      {
          "type": "labelapp",
          "text": "Key Password",
          "icon": "VpnKey",
          "description": "Premium User don't need to input Key Password."
      },
      {
          "type": "input_string",
          "icon": "VpnKey",
          "text": "Key Password",
          "label": "Input Key Password correctly!",
          "placeholder": "Key Password",
          "default": "",
          "alias": "hsnchem_keyPass"
      },
      {
          "type": "tooltip",
          "text": "Join my Discord Server to get Key! (FREE)",
          "support_text": "",
          "background": true,
          "icon": "VpnKey"
      },
      {
          "type": "divider"
      },
      {
          "type": "toggle_button",
          "text": "Join Discord",
          "default": false,
          "alias": "hsnchem_link"
      },
      {
          "type": "divider"
      }
]
}
]]

addCategory("HsnGL", "FileOpen")
addIntoModule(Hsnchem, "HsnGL")

----------------------------------------------------------------
-- Helper
----------------------------------------------------------------
local function w(text)
   if type(text) == "string" then
      return text
   end
   return ""
end

local function gv(method, name)
   local ok, v = pcall(getValue, method, ID..name)
   if ok then return v end
   return nil
end

local function logs(text) log("`c[Chemsynth]`w "..tostring(text)) end
local function Notify(text) growtopia.notify("`w[`9HsnGL`w] "..text) end
local function dialogBuilder(t, m, c)
    sendDialog({
        title = t,
        confirm = c,
        message = m
    })
end
   
dialogBuilder("Auto Chemsynth by HsnGL\n["..status.."]", "ðŸ’¡ Cara Pakai:\n1. Buka Menu Growlauncher\n2. Isi Key Password di menu [Free User]\n3. Pastikan semua alat Chemsynth sudah terpasang\n3. Tekan START/STOP", "OK")
if premium then editValue("hsnchem_keyPass", "Premium User") end

local function getVar(fresh)
   if not fresh and cfgCache and os.time() - cfgTime < 1 then
      return cfgCache
   end

   cfgCache = {
      mode = tonumber(gv(1, "mode")) or 0,    -- 0 = Full Auto, 1 = Semi Auto
      delay = tonumber(gv(1, "delay")) or 300,
      key = w(gv(2, "keyPass"))
   }
   cfgTime = os.time()
   return cfgCache
end

local function stopScript(reason)
   running, waitResponse = false, false
   dc = false

   if gv(0, "startBtn") then
      if reason and reason ~= "" then
         dialogBuilder("Auto Chemsynth Stopped", tostring(reason), "OK")
      end
      editToggle(ID.."startBtn", false)
   end
end

local function Disconnected()
   if not getLocal() or GetWorldName() == "EXIT" or getPing() == -1 then
      Notify("Disconnected")
      return true
   end
   return false
end

local function cekInv(id)
   return growtopia.checkInventoryCount(id) or 0
end

local function sameWorld(a, b)
   return tostring(a or ""):upper() == tostring(b or ""):upper()
end

----------------------------------------------------------------
-- Tank
----------------------------------------------------------------
-- selalu mengembalikan table (tidak pernah nil)
local function getTank(x, y)
   local tile = getTile(x, y)

   if not tile or tile.fg ~= TANK then
      return {flag = 0, current = 0, target = 0, valid = false}
   end

   local extra = tile.extra
   if not extra then
      return {flag = tile.flag or 0, current = 0, target = 0, valid = false}
   end

   return {
      flag = tile.flag or 0,
      current = extra.volume or 0,
      target = extra.owner or 0,
      valid = true
   }
end

local function distRight(curId, tarId)
   local c, t = chems[curId], chems[tarId]
   if not c or not t then return nil end
   return (t - c + 5) % 5
end

local function rowSig(startX, y)
   local t = {}
   for i = 1, 10 do
      t[i] = getTank(startX + i, y).current
   end
   return table.concat(t, ",")
end

local function waitChange(startX, y, before, ms)
   local waited = 0

   while running and waited < ms do
      if rowSig(startX, y) ~= before then return true end
      Sleep(50)
      waited = waited + 50
   end
   return false
end

local function playParticle(px, py)
    SendVariant({
        v1 = "OnParticleEffect",
        v2 = 88,
        v3 = {
            x = px * 32 + 16,
            y = (py + 1) * 32 - 16
        }
    })
end

local function waitOn(x, y, ticks)
   local t = 0

   while running and t < (ticks or 100) do
      if Disconnected() then return false end
      if t % 10 == 0 then playParticle(x, y) end
      if getTank(x, y).flag == TANK_READY then return true end
      Sleep(100)
      t = t + 1
   end
   return false
end

local function getProcessor()
   for _, v in pairs(getTiles() or {}) do
      if v and v.fg == PROCESSOR then
         return v.x, v.y
      end
   end
end

----------------------------------------------------------------
-- Packet / gerak
----------------------------------------------------------------
local function spr(t, v, x, y)
   if Disconnected() then return false end
   local me = getLocal()

   SendPacketRaw(false, {
        type = t,
        value = v,
        px = x,
        py = y,
        x = me.posX,
        y = me.posY
   })
   return true
end

local function collectItem(objID, ox, oy)
   if Disconnected() then return false end

   SendPacketRaw(false, {
        type = 11,
        value = objID,
        x = ox,
        y = oy
   })
   return true
end

local function Fp(x, y)
   if not x or not y then return false end
   if not running then return false end
   if Disconnected() then return false end
   if growtopia.isOnPos(x, y) then return true end

   for _ = 1, 4 do
      findPath(x, y)
      for _ = 1, 40 do
         Sleep(200)
         if growtopia.isOnPos(x, y) then return true end
         if not running then return false end
         if Disconnected() then return false end
      end
   end
   return growtopia.isOnPos(x, y)
end

----------------------------------------------------------------
-- Warp / reconnect
----------------------------------------------------------------
local function Warp(world)
   if sameWorld(GetWorldName(), world) then return true end

   for _ = 1, 4 do
      local timeout = 0

      Notify("Warp to "..world)
      growtopia.warpTo(world)

      repeat
         Sleep(3000)
         timeout = timeout + 1
         Notify("Waiting to arrive at "..world)
      until sameWorld(GetWorldName(), world) or timeout >= 20 or not running

      if not running then return false end
      if sameWorld(GetWorldName(), world) then break end
   end

   Sleep(3500)
   return sameWorld(GetWorldName(), world)
end

local function Reconnect()
   local timeout = 0

   repeat
      Sleep(5000)
      Notify("Reconnecting...")
      timeout = timeout + 1
   until dc or (getLocal() and getPing() ~= -1) or timeout >= 120 or not running

   if timeout >= 120 or not running then return false end
   if not Warp(homeWorld) then return false end

   timeout = 0
   repeat
      Sleep(5000)
      timeout = timeout + 1
   until getLocal() or timeout >= 120 or not running

   if timeout >= 120 or not running then return false end

   dc = false
   return true
end

----------------------------------------------------------------
-- Take chemical
----------------------------------------------------------------
local function takeChemical(id)
   local stall, last = 0, cekInv(id)

   while running and cekInv(id) < TAKE_TO do
      if Disconnected() then break end

      local found = false

      for _, obj in pairs(getObjectList() or {}) do
         if obj.itemid == id then
            local obx, oby = math.floor(obj.posX / 32), math.floor(obj.posY / 32)

            if Fp(obx, oby) then
               found = true
               collectItem(obj.id, obj.posX, obj.posY)
               Sleep(300)
               break
            end
         end
      end

      if not found then break end

      local now = cekInv(id)
      if now > last then
         stall = 0
      else
         stall = stall + 1
      end
      last = now

      if stall >= 10 then break end
   end

   return cekInv(id)
end

local function ensureChemicals(px, py)
   local lack = false

   for i = 1, 5 do
      if cekInv(names[i]) < MIN_CHEM then
         lack = true
         break
      end
   end

   if not lack then return true end

   Notify("Chemical kurang dari "..MIN_CHEM..", mengambil di world ini...")

   for i = 1, 5 do
      local id = names[i]

      if cekInv(id) < MIN_CHEM and takeChemical(id) < MIN_CHEM then
         if not running or Disconnected() then return false end
         return false, getItemInfoByID(id).name.." kurang dari "..MIN_CHEM.." dan tidak ada lagi di world."
      end
   end

   Fp(px, py - 1)
   return true
end

----------------------------------------------------------------
-- Pakai tool
----------------------------------------------------------------
local function useTool(id, tx, ty)
   local me = getLocal();if not me then
      return false
   end   
   
   local px, py = math.floor(me.posX/32), math.floor(me.posY/32)
   
   if cekInv(id) <= 0 then
      stopScript(getItemInfoByID(id).name.." habis.")
      return false
   end
   
   if math.abs(tx - px) > 2 or math.abs((ty - 1) - py) > 2 then
      if not Fp(tx, ty - 1) then return false end
   end   
   
   if not waitOn(tx, ty) then return false end

   local chemID = getTank(tx, ty).current
   if chems[chemID] and cekInv(chemID) <= 0 then
      Notify(getItemInfoByID(chemID).name.." habis, mengambil...")

      if takeChemical(chemID) <= 0 then
         if running and not Disconnected() then
            stopScript(getItemInfoByID(chemID).name.." habis dan tidak ada lagi di world.")
         end
         return false
      end
   end
   
   if getTank(tx, ty).flag ~= TANK_READY then return false end
   if math.abs(tx - px) > 2 or math.abs((ty - 1) - py) > 2 then
      if not Fp(tx, ty - 1) then return false end
   end
   
   return spr(3, id, tx, ty)
end

----------------------------------------------------------------
-- Solver
----------------------------------------------------------------
local function pickAction(startX, x, y, main)
   local last = startX + 10
   local best

   local function consider(tool, tx, cost)
      if not best or cost < best.cost then
         best = {tool = tool, tx = tx, cost = cost}
      end
   end

   -- 1. Replicator: salin warna dari tank kiri (yang sudah selesai)
   if x > startX + 1 and getTank(x - 1, y).current == main.target then
      consider(REPLICATOR, x - 1, TOOL_COST[REPLICATOR])
   end

   -- 2. Tank terdekat di kanan yang sudah berwarna target (jarak d)
   --    d = 1 : Solvent di x
   --    d >= 2: Stirrer di x+d-1 (memajukan warna 2 tank), ulangi; kalau d ganjil diakhiri Solvent
   for d = 1, last - x do
      if getTank(x + d, y).current == main.target then
         if d == 1 then
            consider(SOLVENT, x, TOOL_COST[SOLVENT])
         else
            local cost = math.floor(d / 2) * TOOL_COST[STIRRER]
            if d % 2 == 1 then cost = cost + TOOL_COST[SOLVENT] end
            consider(STIRRER, x + d - 1, cost)
         end
         break
      end
   end

   -- 3. Catalyst: hanya kalau kedua tetangga beda warna (supaya tidak ikut mengubah tank lain)
   local steps = distRight(main.current, main.target)
   local isolated = getTank(x - 1, y).current ~= main.current
      and getTank(x + 1, y).current ~= main.current

   if isolated and steps then
      consider(CATALYST, x, steps * TOOL_COST[CATALYST])
   end

   if best then return best.tool, best.tx end

   -- tidak ada warna target yang terjangkau: lebur x, geser kiri, berharap chemical baru cocok
   return SOLVENT, x
end

local function stepTank(startX, x, y)
   local c = getVar()
   local last = startX + 10
   local main = getTank(x, y)

   if not main.valid then
      Sleep(200)
      return "wait"
   end

   if main.current == main.target then return "done" end

   local tool, tx = pickAction(startX, x, y, main)
   local before = rowSig(startX, y)

   if not useTool(tool, tx, y) then
      return running and "fail" or "abort"
   end

   -- Solvent di tank terakhir menambah chemical acak, bisa saja warna sama
   if not (tool == SOLVENT and x == last) then
      waitChange(startX, y, before, 5000)
   end
   Sleep(c.delay)

   return "used"
end

local function Solver(startX, x, y)
   local fails, steps = 0, 0

   while running do
      if Disconnected() then return false end

      local r = stepTank(startX, x, y)

      if r == "done" then return true end
      if r == "abort" then return false end

      if r == "fail" then
         fails = fails + 1
         if fails >= 10 then
            stopScript("Gagal memakai tool di tank ke-"..(x - startX)..".")
            return false
         end
      elseif r == "used" then
         fails = 0
         steps = steps + 1

         if steps > MAX_STEPS then
            stopScript("Tank ke-"..(x - startX).." belum selesai setelah "..MAX_STEPS.." langkah (solver buntu).")
            return false
         end
      end
   end
   return false
end

local function autoChemsynth(startX, y)
   for i = 1, 10 do
      if not running then return false end

      Notify("Tank "..i.."/10")

      if not Solver(startX, startX + i, y) then
         return false, running and Disconnected()
      end
   end

   Fp(startX, y - 1)
   Notify("Solved in "..(os.time() - startTime).."s")
   return running
end

----------------------------------------------------------------
-- Processor
----------------------------------------------------------------
local function waitFlag(get, ticks)
   local t = 0

   while running and t < ticks do
      if Disconnected() then return false end
      if get() then return true end
      Sleep(100)
      t = t + 1
   end
   return false
end

local function doProcessor(x, y)
   local c = getVar()
   foundProcessor, startProcessor = false, false
   onProgress = false

   Fp(x, y - 1)
   spr(3, 32, x, y)

   if not waitFlag(function() return foundProcessor or onProgress end, 100) then
      logs("Dialog Processor tidak muncul")
      return false
   end

   if foundProcessor then
      foundProcessor = false
      waitResponse = c.mode ~= 0
      
      sendPacket(2,
          "action|dialog_return\n"..
          "dialog_name|chemsynth\n"..
          "tilex|"..x.."|\n"..
          "tiley|"..y.."|"
      )
   end

   if not waitFlag(function() return startProcessor or onProgress end, 100) then
      logs("Dialog 'Really Start' tidak muncul")
      return false
   end

   if startProcessor then
      startProcessor = false
      
      if c.mode == 0 then
         sendPacket(2,
             "action|dialog_return\n"..
             "dialog_name|chemsynth\n"..
             "tilex|"..x.."|\n"..
             "tiley|"..y.."|\n"..
             "buttonClicked|start2"
         )
      else
         local timeout = 0
         btnClicked = false
         
         repeat
            Sleep(100)
            timeout = timeout + 1
            if timeout % 30 == 0 then
               Notify("Waiting for response...")
            end   
         until not running or Disconnected() or btnClicked
         
         if not running or Disconnected() then
            return false
         end
      end   
   end

   onProgress = false
   Sleep(1000)
   return not Disconnected()
end

----------------------------------------------------------------
-- Main loop
----------------------------------------------------------------
local function cycle(px, py)
   if Disconnected() then return "retry" end

   local ok, why = ensureChemicals(px, py)
   if not ok then
      if why then
         stopScript(why)
         return "stop"
      end
      return running and "retry" or "stop"
   end

   if not doProcessor(px, py) then
      if not running then return "stop" end
      if Disconnected() then return "retry" end

      stopScript("Gagal memulai Chemsynth.")
      return "stop"
   end

   startTime = os.time()

   local done, wasDisconnected = autoChemsynth(px, py)
   if done then return "ok" end
   if not running then return "stop" end

   -- setelah sambung ulang, doProcessor akan melanjutkan sesi yang masih aktif
   -- atau memulai baru; tank yang sudah benar langsung dilewati solver
   if wasDisconnected then return "retry" end

   stopScript("Chemsynth berhenti.")
   return "stop"
end

local function mainLoop()
   local c = getVar(true)

   if c.key ~= keyPass and not premium then
      dialogBuilder("Invalid Key.", "Get key at my Discord Server!", "OK")
      pcall(function() load(fetch(RAW_URL))() end)
      stopScript("")
      return
   end
   
   if c.mode == 0 and not premium then
      dialogBuilder("ðŸ‘‘ Full Auto Mode", "Buy Premium for Full Auto Mode\n\nFeatures:\n[+] Auto Take Chem\n[+] Auto Reconnect\n[+] No Need Key", "OK")
      stopScript("")
      return
   end
       
   local px, py = getProcessor()
   if not px then
      stopScript("Chemsynth Processor tidak ditemukan di world ini.")
      return
   end

   homeWorld = GetWorldName()
   if homeWorld == "" or homeWorld == "EXIT" then
      stopScript("Masuk ke world dulu sebelum START.")
      return
   end

   dc = false
   Notify("Script Started! Processor di "..px..", "..py)

   local r
   repeat
      r = cycle(px, py)

      if r == "stop" then return end

      if r == "retry" then
         if not Reconnect() then
            if running then stopScript("Gagal menyambung ulang.") end
            return
         end
      end

      c = getVar(true)
   until not running

   if running then stopScript("Selesai (Semi Auto).") end
end

----------------------------------------------------------------
-- Hook
----------------------------------------------------------------
local function onVariant(var)
   local v2 = var.v2

   if var.v1 == "OnConsoleMessage" and w(v2):find("Used `2Chemsynth", 1, true) and running then
      return true
   elseif var.v1 == "OnRequestWorldSelectMenu" and running then
      dc = true
   elseif var.v1 == "OnDialogRequest" and running then
      if w(v2):find("add_button|start2|Really Start|", 1, true) then
         local txr, tyr = w(var.v2):match("embed_data|tilex|(%d+)\nembed_data|tiley|(%d+)")
         local crr, cyr, cgr, cbr, cpr = w(var.v2):match("add_smalltext|You have (%d+) Chemical R, (%d+) Chemical Y, (%d+) Chemical G, (%d+) Chemical B, and (%d+) Chemical P.|left|")
         local ranX = math.random(0, 700) --"HsnChemsynth"
         local tx, ty, cr, cy, cg, cb, cp = tonumber(txr), tonumber(tyr), tonumber(crr), tonumber(cyr), tonumber(cgr), tonumber(cbr), tonumber(cpr)
         startProcessor = true

         local newDialog = string.format(
            "set_default_color|`w\n"..
            --"set_border_color|112,86,191,255\n"..
            "set_border_color|112,86,191,255\n"..
            "set_bg_color|43,34,74,200\n"..
            "add_custom_button|HsnGL|state:disabled;icon:4430;|\n"..
            "add_custom_margin|x:-50|\n"..
            "add_label_with_icon|big|Auto Chemsynth|left|0|\n"..
            "add_custom_margin|x:57|\n"..
            "add_smalltext|Script by HsnGL|\n"..
            "add_custom_break|\n"..
            "reset_placement_x|\n"..
            "add_spacer|small|\n"..
            "embed_data|tilex|%d\n"..
            "embed_data|tiley|%d\n"..
            "add_smalltext|You have %d Chemical R, %d Chemical Y, %d Chemical G, %d Chemical B, and %d Chemical P.|left|\n"..
            "add_textbox|Are you sure you want to spend `25 of each Chemical`` to begin Chemical Synthesis?|left|\n"..
            "add_custom_margin|x:%d|\n"..
            "add_button|start2|Really Start|noflags|0|0|\n"..
            "reset_placement_x|\n"..
            "end_dialog|chemsynth|Exit||",
            tx, ty, cr, cy, 
            cg, cb, cp, ranX
         )
         
         if waitResponse then
            growtopia.sendDialog(newDialog)
         end   
         return true
      elseif w(v2):find("add_button|shutdown|Shutdown|", 1, true) then
         onProgress = true -- processor masih aktif
         return not waitResponse
      elseif w(v2):find("add_textbox|Chemical Synthesis System", 1, true) then
         foundProcessor = true
         return not waitResponse
      end
   end
end

addHook(function(var)
   local ok, res = pcall(onVariant, var)
   if ok then
      return res
   else
      logs("Hook error: "..tostring(res))
   end
end, "OnVariant")

addHook(function(vtype, name, value)
   cfgTime = 0

   local alias = w(name):sub(1, #ID) == ID and w(name):sub(#ID + 1) or ""

   if alias == "startBtn" then
      if value then
         running = true

         runThread(function()
            -- tunggu loop lama benar-benar selesai
            local waitOld = 0
            while mainActive and waitOld < 100 do
               Sleep(100)
               waitOld = waitOld + 1
            end

            mainActive = true
            local ok, err = pcall(mainLoop)
            mainActive = false

            if not ok then
               logs(err)
               stopScript(tostring(err))
            end
         end)
      else
         running = false
         Notify("Stopped!")
      end
   elseif alias == "link" and value then
      pcall(function() load(fetch(RAW_URL))() end)
      editValue("hsnchem_link", false)
   elseif alias == "mode" and value == 0 and not premium then
      dialogBuilder("ðŸ‘‘ Full Auto Mode", "Buy Premium for Full Auto Mode\n\nFeatures:\n[+] Auto Take Chem\n[+] Auto Reconnect\n[+] No Need Key", "OK")
      editValue("hsnchem_mode", 1)
   end
end, "OnValue")

addHook(function(type, pkt)
   if w(pkt):match("buttonClicked|start2") and running then
      btnClicked = true
      waitResponse = false
   end
end, "OnSendPacket")