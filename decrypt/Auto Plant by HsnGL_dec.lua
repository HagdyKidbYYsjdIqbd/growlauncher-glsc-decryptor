local buyerList = {
    ["636196321232945152"] = "Author",
    ["1266633157625774171"] = "Cugen713",
    ["737166031449227285"] = "Chyro10",
    ["404969942711140352"] = "Mardydram",
    ["888333334248300544"] = "Nadhiflonely",
    ["786815830419046401"] = "Flashdisk",
    ["762172674813460540"] = "edosukasusucoklat",
    ["462171778664497165"] = "Dienxy",
    ["1227147579687702550"] = "Hanninjapantek",
    ["723193147693334558"] = "M0dra",
    ["734964120373166102"] = "Purtt",
    ["1148683811329159210"] = "Nooxyy",
    ["549528733183115275"] = "LostSky",
    ["416906641322278924"] = "AmlsStore",
    ["601050245421334539"] = "Brynkl",
    ["533277275282472971"] = "Justkady",
    ["677096900985487371"] = "IndraMaulana",
    ["417949261234438144"] = "Farq0544",
    ["1522427487127207988"] = "Ijullz",
    ["617378357373566976"] = "maztra",
    ["1061943930628878407"] = "RusdiNgawi69",
    ["619134153434202112"] = "silenceeey",
    ["530787823398158336"] = "XeustGT",
    ["526240228386799616"] = "Mahayanea",
    ["387956126597120002"] = "Nekosune",
    ["1017084522816344166"] = "snthaqif",
    ["1378121539001778330"] = "Banqxxx",
    ["524085475409920019"] = "PangcebExe",
    ["977539820765188156"] = "Heimdall",
    ["659906575380774922"] = "Samocaa",
    ["1478194079970885642"] = "RicekakuDesu",
    ["883984337815633951"] = "Blyze",
    ["560026323624394772"] = "Aby2207",
    ["484287601260363777"] = "Iodore",
    ["760762262939500554"] = "Snuyh",
    ["1390605855426084917"] = "Grizy0225",
    ["1488026453693169736"] = "Arifu982543",
    ["860159590649298967"] = "Booobi",
    ["392857023450054666"] = "Hepa0696",
    ["549119827474907162"] = "Gibkd",
    ["1189861884535517255"] = "Vexion",
    ["1051022772379336745"] = "TanjiroKamado",
    ["1402882580201865297"] = "Amam",
    ["1309771606071181384"] = "Iiwol",
    ["537271889396105217"] = "Krisses",
    ["1010524684024037477"] = "LiniOki",
    ["857601528788156436"] = "Killua05",
    ["1245035247805005874"] = "Seanraja",
    ["914413266111955016"] = "DomasLeon",
    ["669433328650420234"] = "Alzails",
    ["1151064672930386072"] = "Ady",
    ["770597461366538250"] = "Saeza",
    ["502699422870798366"] = "Fuyuid",
    ["336773787036942336"] = "Ayis",
    ["596152999340933127"] = "Andhikaf",
    ["920212477164273674"] = "Menengo",
    ["531854033162600459"] = "Zymnneil",
    ["1518449959731466315"] = "Remblang",
    ["1090957666177789953"] = "AgusSlebw",
    ["757223145575940206"] = "HexZ",
    ["482201586131664943"] = "Sambros"
}

local isRunning = false
local isPremium = false
local isDC = false

local BLANK = 0
local SEED_MIN = 10
local ID = "hsnpts_"
local KEY_PASS = "HsnPTS12"
local USER_ID = tostring(getDiscordID())

local twIndex = 1
local startTime = 0
local globalSeedCount = 0
local globalWorldCount = 0
local splicedSeedID = 0

local varData = {}
local targetWorlds = {}

local Hsnpts = [[
{
  "sub_name": "Auto Plant",
  "description": "Auto Plant by HsnGL.",
  "icon": "Park",
  "menu": [
      {
          "type": "divider"
      },
      {
          "type": "toggle_button",
          "alias": "hsnpts_btnStart",
          "text": "START/STOP"
      },
      {
          "type": "divider"
      },
      {
          "type": "dropdown",
          "text": "Selected Mode:",
          "icon": "AutoMode",
          "default": 0,
          "value": "[\"Auto Plant\", \"Auto Splice\"]",
          "alias": "hsnpts_mode"
      },
      {
          "alias": "hsnpts_seedID",
          "default": "Blank",
          "text": "Seed to Plant :",
          "type": "item_picker"
      },
      {
          "alias": "hsnpts_seedID2",
          "default": "Blank",
          "text": "Seed to Splice :",
          "type": "item_picker"
      },
      {
          "text": "Target World",
          "support_text": "Click to open World settings.",
          "type": "dialog",
          "fill": true,
          "background": false,
          "menu": [
              {
                 "background": false,
                 "text": "Auto Plant Multi World [PREMIUM]",
                 "icon": "TipsAndUpdates",
                 "support_text": "Contoh/Example: DUNIA1, DUNIA2|ID, DUNIA3",
                 "type": "tooltip"
              },
              {
                 "alias": "hsnpts_worldList",
                 "text": "World Name",
                 "icon": "Info",
                 "placeholder": "WORLD|ID, WORLD",
                 "default": "N/A",
                 "type": "input_string",
                 "label": "World List"
              },
              {
                  "type": "button",
                  "alias": "hsnpts_getWorld",
                  "text": "Get Current World"
              },
              {
                  "type": "simple_display",
                  "icon": "TravelExplore",
                  "text": "World List",
                  "description": "A world list for Auto Plant",
                  "alias": "hsnpts_displayList",
                  "default": "[\"Beli premium ya kalau mau multi world :)\"]",
                  "setup": false
              },
              {
                  "type": "button",
                  "alias": "hsnpts_refresh",
                  "text": "REFRESH LIST"
              }
          ]
      },
      {
          "text": "Take World",
          "support_text": "Click to open World settings.",
          "type": "dialog",
          "fill": true,
          "background": false,
          "menu": [
              {
                 "background": true,
                 "text": "Take World Settings",
                 "icon": "SettingsSuggest",
                 "support_text": "",
                 "type": "tooltip"
              },
              {
                  "type": "toggle",
                  "text": "Take Current World",
                  "default": true,
                  "description": "Take seed from current world.",
                  "alias": "hsnpts_takeCurrentWorld"
              },   
              {
                  "type": "toggle",
                  "text": "Take Other World",
                  "default": false,
                  "description": "Take seed from other world.",
                  "alias": "hsnpts_takeOtherWorld",
                  "expandable": true,
                  "list_child": [
                      {
                          "alias": "hsnpts_takeWorld",
                          "text": "World Name",
                          "icon": "Info",
                          "placeholder": "WORLD|ID, WORLD",
                          "default": "N/A",
                          "type": "input_string",
                          "label": "Take World Name"
                      },
                      {
                          "type": "button",
                          "alias": "hsnpts_getTakeWorld",
                          "text": "Get Current World"
                      }
                  ]   
              }
          ]
      },
      {
          "type": "slider",
          "text": "Plant Delay :",
          "default": 180,
          "max": 500,
          "min": 180,
          "step": 100,
          "use_dot": true,
          "alias": "hsnpts_delay"
      },
      {
          "type": "input_int",
          "icon": "Terminal",
          "text": "Minimum seed planted before splicing",
          "label": "Max is 50!",
          "placeholder": "tiles",
          "default": "10",
          "alias": "hsnpts_batch"
      },
      {
          "type": "input_int",
          "icon": "AutoMode",
          "text": "Max retries for each batch",
          "label": "More retries if you're lagging.",
          "placeholder": "retries",
          "default": "5",
          "alias": "hsnpts_retries"
      },
      {
          "type": "toggle",
          "text": "Start from bottom",
          "description": "Always start from bottom.",
          "default": false,
          "alias": "hsnpts_sweepBottom"
      },
      {
          "type": "divider"
      },
      {
          "type": "input_string",
          "icon": "VpnKey",
          "text": "Key Password",
          "label": "Input Key Password correctly!",
          "placeholder": "Key Password",
          "default": "",
          "alias": "hsnpts_key"
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
          "alias": "hsnpts_link"
      },
      {
          "type": "divider"
      }
]    
}
]]

addCategory("HsnGL", "FileOpen")
sendNotification("[HsnGL] Loading script...")

local RAW_WEBHOOK = "https://hsngl-loader.hsndika.workers.dev/?key=key_hsngls12012027&s=webhook"
local Webhook, webhookSent = nil, false

pcall(function()
    Webhook = load(fetch(RAW_WEBHOOK))()
    Sleep(3000)
end)

addIntoModule(Hsnpts, "HsnGL")
sendNotification("Auto Plant by HsnGL added!")

local function dialogBuilder(t, m, c)
   sendDialog({title = t, confirm = c, message = m}) 
end

local function cekBuyer(playerID)
  if buyerList[playerID] then
    return true, buyerList[playerID] -- return true + nama
  else
    return false, nil
  end
end        

if cekBuyer(USER_ID) then
   local name = "Test Version"
   
   if cekBuyer(USER_ID) then
      name = buyerList[USER_ID]
      editValue("hsnpts_key", "No need Key")
   end
      
   dialogBuilder("Auto Plant by HsnGL", "Verified, Welcome "..
   name.."\n\n==========================\n"..
   "Status : Premium ðŸ‘‘\n\nNow you can access Premium features:\n"..
   "â—ˆ Auto Reconnect âœ”\nâ—ˆ Multi World âœ”\nâ—ˆ No Key âœ”\n"..
   "==========================\n\n"..
   "Last Update: 18/10/2026", "OK")
   
   isPremium = true
else
   dialogBuilder("Auto Plant by HsnGL", "Welcome Free User"..
   "\n\n==========================\nStatus : Free\n\n"..
   "Test Version ended!\n"..
   "Now you can only access basic features."..
   "â—ˆ Auto Reconnect âŒ\nâ—ˆ Multi World âŒ\nâ—ˆ No Key required âŒ\n"..
   "\n==========================\n\n"..
   "Last Update: 18/10/2026", "OK")
   
   isPremium = false
end 

local function Notify(text)
   growtopia.notify("`c[HsnGL]`w "..text)
end

local function w(str)
   if type(str) == "string" then
      return str
   end
   return ""
end

local function wn(text) return text or "" end
local pref = require("preferences")
local db = wn(pref):new("PTS.hsngl")
wn(db):save()

local function rd(baseDelay)
   local maxDelay = 1000    local ping = getPing()
   local pingLow, pingHigh = 380, ping >= 500 and ping or 500
    
   if ping < pingLow then
      return baseDelay
   end
   
   local t = math.min((ping - pingLow) / (pingHigh - pingLow), 1)
   local tt = math.floor(baseDelay + (maxDelay - baseDelay) * t)
   local offset = math.floor(tt * 0.1)
   
   return math.random(tt - offset, tt + offset)
end

local function resetValue()
   editToggle("ModFly", false)
   editToggle("collectfilter_enable", false)
   
   isRunning = false
   isDC = false
   webhookSent = false
   
   globalSeedCount = 0
   globalWorldCount = 0
   splicedSeedID = 0
   twIndex = 1
end
        
local function getTimes(rawNumber)
   local h = math.floor(rawNumber / 3600)
   local sisa = rawNumber % 3600
   local m = math.floor(sisa / 60)
   local s = math.floor(sisa % 60)
   
   return h, m, s
end

local function getVar()
   local function gv(types, name) return getValue(types, ID..name) end
  
   varData = {
       targetWorlds = gv(2, "worldList"),
       takeWorld = gv(2, "takeWorld"),
       takeOtherWorld = gv(0, "takeOtherWorld"),
       key = gv(2, "key"),
       seedID = gv(1, "seedID"),
       seedID2 = gv(1, "seedID2"),
       delay = gv(1, "delay"),
       retries = gv(1, "retries"),
       spliceBatch = gv(1, "batch"),
       modeSplice = gv(1, "mode") == 1,
       isFromBottom = gv(0, "sweepBottom")
   }
   return varData
end

local function plantedCount()
   local config = getVar()
   local seed = config.seedID; if config.modeSplice then
      seed = splicedSeedID
   end
   local count = 0
   
   for _, tile in pairs(getTiles()) do
      if seed ~= 0 and tile and tile.fg == seed then
         count = count + 1
      end
   end
   return count
end

local function sendWebhook(method, reason)
   if webhookSent then return end
   
   local config = getVar()
   local seed = config.seedID; if config.modeSplice then
      seed = splicedSeedID
   end
      
   local count = globalSeedCount == 0 and plantedCount() or globalSeedCount
   local elapsedTime = math.floor(os.time() - startTime)
   local h, m, s = getTimes(elapsedTime)
   local Runtime = h.."h "..m.."m "..s.."s"
   webhookSent = true
   
   runThread(function()
      if not Webhook then
         return false
      end
      
      local target = "ðŸŒ± "..getItemInfoByID(seed).name.."\n(Planted: "..count.." **not accurate**)"
      local status = isPremium and "ðŸ‘‘" or "ðŸ‘¤"
      local mode = config.modeSplice and "Splice" or "Plant"
      
      Notify("Sending Webhook, please wait...")
      
      if method == 0 then -- Stopped
         Webhook(">>> **Auto "..mode.." Webhook**\nUser :\n"..status.." <@"..USER_ID..">\nStatus :\n<:offline:1545964640008405133> STOPPED/ERROR\nError :\n"..reason.."\nRuntime :\nðŸ•“ "..Runtime.."\n\n```js\n"..os.date("%d/%m/%y %H:%M").."```")
      else -- Finished
         Webhook(">>> **Auto "..mode.." Webhook**\nUser :\n"..status.." <@"..USER_ID..">\nStatus :\n<:tested:1526677186843644035> FINISHED ("..globalWorldCount.."/"..#targetWorlds..")\nTarget :\n"..target.."\nRuntime :\nðŸ•“ "..Runtime.."\n\n```js\n"..os.date("%d/%m/%y %H:%M").."```")
      end
   end)   
end

local function stopScript(reason)
   local config = getVar()
   local elapsedTime = math.floor(os.time() - startTime)
   local h, m, s = getTimes(elapsedTime)
   local mode = config.modeSplice and "Splice" or "Plant"
   
   log("`c[Auto Plant]`w Runtime: "..h.."h "..m.."m "..s.."s")
   
   if not getValue(0, ID.."btnStart") then
      return true
   end
   
   sendDialog({
       title = "Auto "..mode.." Stopped",
       message = reason.."\n\nHaving trouble?\nReport bugs or problem at my Discord Server.\n\nDiscord : @hsndika\n[https://discord.gg/3xKNPbB5qd]",
       confirm = "OK"
   })
   sendWebhook(0, reason)
   editToggle(ID.."btnStart", false)
   resetValue()
end

local function saveConfigs()
   local config = getVar()
   wn(db):set("targetWorlds", config.targetWorlds)
   wn(db):set("takeWorld", getValue(2, ID.."takeWorld"))
   wn(db):set("seedID", getItemInfoByID(config.seedID).name)
   wn(db):set("seedID2", getItemInfoByID(config.seedID2).name)
   wn(db):set("delay", config.delay)
   wn(db):set("retries", config.retries)
   wn(db):set("batch", config.spliceBatch)
   wn(db):save()
   sendNotification("[Auto Plant] Configuration Saved.")
end
   
local function loadConfigs()
   local targetWorld = wn(db):get("targetWorlds", "N/A")
   local takeWorld = wn(db):get("takeWorld", "N/A")
   local seedID = wn(db):get("seedID", "Blank")
   local seedID2 = wn(db):get("seedID2", "Blank")
   local delay = wn(db):get("delay", 180)
   local retries = wn(db):get("retries", 5)
   local batch = wn(db):get("batch", 10)
   
   editValue(ID.."worldList", targetWorld)
   editValue(ID.."takeWorld", takeWorld)
   editValue(ID.."seedID", seedID)
   editValue(ID.."seedID2", seedID2)
   editValue(ID.."delay", delay)
   editValue(ID.."retries", retries)
   editValue(ID.."batch", batch)
   sendNotification("[Auto Plant] Configuration loaded.")
end   

loadConfigs()

local function toJsonArray(t)
    local parts = {}
    for i, v in ipairs(t) do
        parts[i] = '"'.. string.upper(v).. '"'
    end
    return "[".. table.concat(parts, ",").. "]"
end

local function loadWorlds()
   local config = getVar()
   targetWorlds = {}

   for world in w(config.targetWorlds):gmatch("[^,%s]+") do
      table.insert(targetWorlds, w(world):upper())
      if not isPremium then break end
   end

   if twIndex > #targetWorlds then twIndex = 1 end
   
   local format = toJsonArray(targetWorlds)
   
   editValue("hsnpts_displayList", format)
end

local function plant(x, y, id)
   local me = getLocal()
   if not me then
      return false
   end  
   
   sendPacketRaw(false, {
       type = 3, 
       value = id,
       px = x,
       py = y,
       x = me.posX,
       y = me.posY
   })
   return true
end

local function cekInv(id)
   return growtopia.checkInventoryCount(id) or 0
end
   
local function getPos()
   local me = getLocal(); if not me then
      return false
   end
      
   return me.posX//32, me.posY//32
end

local function getDir()
   local px = getPos()
   
   if not px then
      return false
   end
   
   if px > 50 then
      return 99, 0, -1
   end
   
   return 0, 99, 1
end

local function isOnRow(x, endX, stepX)
   return (x <= endX and stepX == 1) or (x >= endX and stepX == -1)
end

local function isBefore(x, limitX, stepX)
   return (x < limitX and stepX == 1) or (x > limitX and stepX == -1)
end

local function Fp(x, y, safeFp)
   if growtopia.isOnPos(x, y) then
      return true
   end
   
   if safeFp then
      for _ = 1, 10 do
         findPath(x, y)
         sleep(500)
         if not isRunning then return false end
         if growtopia.isOnPos(x, y) then break end
      end   
   else
      findPath(x, y)
      sleep(100)
   end   
   return growtopia.isOnPos(x, y)
end

local function worldFilter(rawWorld)
   if not rawWorld or rawWorld == "" then
      return false
   end
      
   local Upper = w(rawWorld):upper()
   local Filter = w(Upper):match("^[^|]+")
   
   return Filter
end
   
local function Warp(world, hasID)
   local filter = worldFilter(world)
   local attempt = 0
   
   if not filter then
      stopScript("WARP ERROR")
      return false
   end

   if (not hasID or hasID == nil or hasID == "") and GetWorldName() == filter then 
      return true 
   end
   
   while attempt < 4 do
      local timeout = 0
      
      Notify("Warp to "..filter)
      growtopia.warpTo(world)
      attempt = attempt + 1
      
      repeat
         Sleep(3000)
         timeout = timeout + 1
         Notify("Waiting to arrive at "..filter)
      until GetWorldName() == filter or timeout >= 60 or not isRunning
   
      if not isRunning then return false end
      if GetWorldName() == filter then break end
   end
      
   Sleep(3500)
   return GetWorldName() == filter
end

local function Disconnected()
   if not getLocal() or GetWorldName() == "EXIT" or getPing() == -1 then
      Notify("Disconnected")
      return true
   end   
end

local function Reconnect(world)
   if not isPremium then
      stopScript("Disconnected, buy premium version for Auto Reconnect!")
      return false
   end
   
   local timeout = 0
   
   repeat
      Sleep(5000)
      Notify("Reconnecting...")
      timeout = timeout + 1
   until isDC or (GetLocal() and getPing() ~= -1) or timeout >= 120 or not isRunning
   
   if timeout >= 120 then return false end
   if not isRunning then return false end 
   if not Warp(world, true) then return false end
   
   timeout = 0
   repeat   
      Sleep(5000)
      timeout = timeout + 1
   until GetLocal() or timeout >= 120 or not isRunning
   
   if timeout >= 120 then return false end 
   if not isRunning then return false end 
   
   isDC = false
   return true
end

local function collectFloating()
   local config = getVar()
   local px, py = getPos(); if not px then
      return
   end   
   
   for _, obj in pairs(GetObjectList() or {}) do
      if obj and (obj.itemid == config.seedID 
         or obj.itemid == config.seedID2) then
         local obx, oby = obj.posX//32, obj.posY//32
         
         if math.abs(obx - px) <= 6 and math.abs(oby - py) <= 6 then
            sendPacketRaw(false, {type = 11, value = obj.id, x = obj.posX, y = obj.posY})
         end
      end
   end
end
            
local function takeSeeds()
   local config = getVar()
   local radius = 6
   local takeWorld = config.takeOtherWorld
      and config.takeWorld or targetWorlds[twIndex]
   local takeSeed, takeSeed2 = true, config.modeSplice
   local before, before2 = cekInv(config.seedID), cekInv(config.seedID2)
   
   if not Warp(takeWorld, true) then
      stopScript("Gagal warp ke Take World.")
      return false
   end
   
   for _, obj in pairs(GetObjectList() or {}) do
      if not takeSeed and not takeSeed2 then
         return true
      end
      
      if not isRunning then return false end 
      
      if (obj.itemid == config.seedID and takeSeed)
         or (obj.itemid == config.seedID2 and takeSeed2) then
         local obx, oby = obj.posX//32, obj.posY//32
         
         if Disconnected() then
            if not Reconnect(takeWorld) then
               stopScript("Gagal untuk menyambung ulang.")
               return false
            end   
         end
         
         if Fp(obx, oby) then
            local px, py = getPos()
            
            if math.abs(obx - px) <= radius 
               and math.abs(oby - py) <= radius then
              
               collectFloating()
               Sleep(1000)
            end    
            
            if cekInv(obj.itemid) >= 200 then
               if obj.itemid == config.seedID then
                  takeSeed = false
               else
                  takeSeed2 = false
               end 
            end
         end
      end
   end
   
   if config.modeSplice and (cekInv(config.seedID) > before 
      or cekInv(config.seedID) == 200) and (cekInv(config.seedID2) > before2 
         or cekInv(config.seedID2) == 200) then
      return true
   elseif not config.modeSplice and (cekInv(config.seedID) > before 
      or cekInv(config.seedID) == 200) then
      return true
   else
      return false
   end      
end
   
local function doPlant(x, y, stepX, targetID, cropID, isRetryRow)
   local config = getVar()
   local matchTile = {}
   local isRetry = false
   local planted = 0
   
   if Disconnected() then
      if not Reconnect(targetWorlds[twIndex]) then
         stopScript("Gagal untuk menyambung ulang.")
         return false
      end   
   end
         
   if not Warp(targetWorlds[twIndex]) then
      stopScript("Gagal warp ke Target World.")
      return false
   end
   
   for i = 0, 2 do
      local cx = x + i * stepX
      
      if cx >= 0 and cx <= 99 then
         local tile = getTile(cx, y)
         local plat = getTile(cx, y + 1)
         
         if tile and tile.fg == targetID and plat and plat.collidable then
            table.insert(matchTile, cx)
         end
      end
   end  
            
   if #matchTile == 0 then
      return true, x + 3 * stepX, false, isRetryRow, 0
   end
   
   if cekInv(cropID) <= SEED_MIN then
      if not takeSeeds() then
         Warp(targetWorlds[twIndex])
         sendWebhook(1)
         return false
      end
      
      if not Warp(targetWorlds[twIndex]) then
         stopScript("Gagal warp ke Target World.")
         return false
      end
   end
   -- urutan posisi FindPath: median dulu, lalu sisanya sebagai cadangan
   local medianIndex = math.ceil(#matchTile / 2)
   local cekOrder = {medianIndex}
            
   for i = 1, #matchTile do
      if i ~= medianIndex then
         table.insert(cekOrder, i)
      end  
   end
   
   -- coba satu per satu sampai ada yang berhasil
   local isReached = false
            
   for _, idx in ipairs(cekOrder) do
      if not isRunning then break end
      
      if Disconnected() then
         if not Reconnect(targetWorlds[twIndex]) then
            stopScript("Gagal untuk menyambung ulang.")
            return false
         end   
      end
      
      if Fp(matchTile[idx], y) then
         isReached = true
         break
      end
   end
               
   if isReached then
      isRetry = true
      isRetryRow = true
      
      for _, dx in ipairs(matchTile) do
         if not isRunning then return false end 
         
         if plant(dx, y, cropID) then
            planted = planted + 1
         end
         sleep(rd(config.delay))
      end   
   end
   
   return true, x + 3 * stepX, isRetry, isRetryRow, planted
end

local function doPhase(y, targetID, cropID, startX, endX, stepX, limitX)
   local config = getVar()
   local sweep = 0
   local isRetry = true
   local rangeX = limitX
   
   while isRunning and isRetry and sweep <= config.retries do
      sweep = sweep + 1
      isRetry = false
      
      local x = startX
      local total = 0
      
      while isRunning and isOnRow(x, endX, stepX) 
         and (not rangeX or isBefore(x, rangeX, stepX)) do
         local ok, nx, isPlanted, rowFlag, count = doPlant(x, y, stepX, targetID, cropID, false)
         
         if not ok then return false, x end
         
         x = nx
         total = total + count
         
         if not rangeX and total >= config.spliceBatch then break end
      end
      
      if not rangeX then rangeX = x end
      if total > 0 then isRetry = true end
   end
   
   return true, rangeX or startX
end
   
local function mainLoop()
   local config = getVar()
   startTime = os.time()
   webhookSent = true
   
   if config.key ~= KEY_PASS and not isPremium then
      stopScript("Invalid Key!\nDapatkan key di discord server.")
      return false
   end
   
   if config.targetWorlds == "" or config.targetWorlds == "N/A" then
      stopScript("Target World tidak boleh kosong.")
      return false
   end
   
   if (config.takeWorld == "" or config.takeWorld == "N/A")
      and config.takeOtherWorld then
      stopScript("Take World tidak boleh kosong.")
      return false
   end
   
   loadWorlds(); if #targetWorlds == 0 then
      stopScript("Target World tidak boleh kosong.")
      return false
   end
   
   if ((config.seedID == 0 or config.seedID2 == 0) and config.modeSplice)
      or (config.seedID == 0 and not config.modeSplice) then
      stopScript("Settingnya dibaca mas, masa mau tanam angin")
      return false
   end
      
   if config.spliceBatch < 10 then editValue(ID.."batch", 10) end
   if config.spliceBatch > 50 then editValue(ID.."batch", 50) end
   if config.retries < 5 then editValue(ID.."retries", 5) end
   
   config = getVar()
   webhookSent = false
   
   editToggle("ModFly", true)
   editToggle("collectfilter_enable", true)
   
   local startY, endY, stepY
   local y
   
   if config.isFromBottom then
      startY, endY, stepY = 53, 0, -1
   else
      startY, endY, stepY = 0, 53, 1
   end
   y = startY
   
   while isRunning and ((y <= endY and stepY == 1) 
      or (y >= endY and stepY == -1)) do
      
      if Disconnected() then
         if not Reconnect(targetWorlds[twIndex]) then
            stopScript("Gagal untuk menyambung ulang.")
            return false
         end   
      end
   
      local startX, endX, stepX = getDir()
      
      if not startX then
         stopScript("Gagal untuk menyambung ulang.")
         return false
      end
      
      if config.modeSplice then
         local x = startX
         
         while isRunning and isOnRow(x, endX, stepX) do
            local ok1, x1 = doPhase(y, BLANK, config.seedID, x, endX, stepX, nil)
            local ok2
            
            if ok1 then
               ok2, x1 = doPhase(y, config.seedID, config.seedID2, x, endX, stepX, x1)
            else
               ok2, x1 = doPhase(y, config.seedID, config.seedID2, x, endX, stepX, nil)
            end
            
            if not ok2 then
               if not isRunning then return false end 
               stopScript("Tidak ada lagi <"..getItemInfoByID(config.seedID).name.." or "..getItemInfoByID(config.seedID2).name.."> untuk ditanam.")
               return false
            end
            
            x = x1
         end
      else
         local isRetryRow = true
         local attempt = 0
         
         while isRunning and isRetryRow do
            isRetryRow = false
            attempt = attempt + 1
            if attempt > config.retries then break end
            
            startX, endX, stepX = getDir()
            if not startX then 
               stopScript("Gagal menyambung ulang.")
               return false 
            end
            
            local x = startX
            
            while isRunning and isOnRow(x, endX, stepX) do
               local ok
               
               ok, x, _, isRetryRow = doPlant(x, y, stepX, BLANK, config.seedID, isRetryRow)
               
               if not ok then
                  if not isRunning then return false end 
                  stopScript("Tidak ada lagi <"..getItemInfoByID(config.seedID).name.."> untuk ditanam.")
                  return false
               end
            end
         end
      end
      
      y = y + stepY
      
      if (y > endY and stepY == 1) 
         or (y < endY and stepY == -1) then
         twIndex = twIndex + 1
         globalWorldCount = globalWorldCount + 1
         globalSeedCount = globalSeedCount + plantedCount()
         
         if twIndex > #targetWorlds then
            sendWebhook(1)
            stopScript("Finished! no more space to plant.")
            return false
         end
         
         Notify("Move to next world...")
         if not Warp(targetWorlds[twIndex]) then
            stopScript("Gagal warp ke world berikutnya.")
            return false
         end
         
         y = startY
      end   
   end
   
   log("Finished")
   stopScript("Finished")
   return true
end
   
addHook(function(var)
   if var.v1 == "OnTalkBubble" and splicedSeedID == 0
      and w(var.v3):find("`w(.-)`` and `w(.-)`` have been spliced to make a `%$(.-) Tree``") then
      local a, b, c = w(var.v3):match("`w(.-)`` and `w(.-)`` have been spliced to make a `%$(.-) Tree``")
      splicedSeedID = findItemID(c.." Seed")
   elseif var.v1 == "OnRequestWorldSelectMenu" and isRunning then
      isDC = true
   end    
end, "OnVariant")

addHook(function(type, name, value)
   if name == ID.."btnStart" then
      if value then
         if isRunning then
            isRunning = false
            editToggle(ID.."btnStart", false)
            return true
         end
         
         isRunning = true
         saveConfigs()
         runThread(function()
            local ok, err = pcall(mainLoop)
            
            if not ok then stopScript(err) return true end
         end) 
      else
         Notify("Auto Plant Stopped")
         resetValue()
      end   
   elseif name == ID.."getWorld" then
      local curWorld = GetWorldName()
      
      editValue(ID.."worldList", curWorld)
      Notify("Target World set to: "..curWorld)
   elseif name == ID.."refresh" then
      loadWorlds()
   elseif name == ID.."getTakeWorld" then
      local curWorld = GetWorldName()
      
      editValue(ID.."takeWorld", curWorld)
      Notify("Take World set to: "..curWorld)
   elseif name == ID.."takeCurrentWorld" and value then
      editToggle(ID.."takeOtherWorld", false)
   elseif name == ID.."takeOtherWorld" and value then
      editToggle(ID.."takeCurrentWorld", false)
   end    
end, "OnValue")