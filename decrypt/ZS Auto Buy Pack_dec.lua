ZS_LABEL_WIDTH = ZS_LABEL_WIDTH or 30
if not ZS_HUB then
  ZS_HUB = { ["native"] = addHook, ["callbacks"] = {}, ["installed"] = {} }
  local T = {
    ["onvalue"] = "onValue",
    ["ondrawimgui"] = "onDrawImGui",
    ["onvariant"] = "onVariant",
    ["ondialog"] = "onDialog",
    ["onsendpacket"] = "onSendPacket",
    ["onsendpacketraw"] = "onSendPacketRaw",
  }
  local y = {
    ["onValue"] = "onvalue",
    ["onDrawImGui"] = "ondrawimgui",
    ["OnVariant"] = "onvariant",
    ["OnDialog"] = "ondialog",
    ["OnSendPacket"] = "onsendpacket",
    ["OnSendPacketRaw"] = "onsendpacketraw",
  }
  local function d(y)
    if ZS_HUB["installed"][y] then
      return
    end
    ZS_HUB["installed"][y] = true
    local d = ZS_HUB["callbacks"][y]
    ZS_HUB["native"](function(...)
      local T = false
      for v = 1, #d, 1 do
        local M, p = pcall(d[v], ...)
        if not M then
          local T = "Hook error (" .. (y .. ("): " .. tostring(p)))
          if growtopia and type(growtopia["notify"]) == "function" then
            pcall(growtopia["notify"], T)
          else
            print(T)
          end
        elseif p == true then
          T = true
        end
      end
      return T
    end, T[y] or y)
  end
  function addHook(T, v)
    if type(T) ~= "function" then
      return
    end
    v = v or "onvalue"
    v = y[v] or (tostring(v)):lower()
    if not ZS_HUB["callbacks"][v] then
      ZS_HUB["callbacks"][v] = {}
    end
    table["insert"](ZS_HUB["callbacks"][v], T)
    d(v)
  end
end
if not ZS_thread then
  function ZS_thread(T)
    runThread(T)
  end
end
if not ZS_label then
  function ZS_label(T, y, ...)
    y = tostring(y == nil and "" or y)
    local d = ZS_LABEL_WIDTH
    local function v(T)
      if utf8 and utf8["len"] then
        return utf8["len"](T) or #T
      end
      return #T
    end
    local M, p = {}, ""
    for T in y:gmatch("%S+") do
      if p == "" then
        p = T
      elseif (v(p) + 1) + v(T) <= d then
        p = p .. (" " .. T)
      else
        M[#M + 1] = p
        p = T
      end
    end
    if p ~= "" then
      M[#M + 1] = p
    end
    if #M == 0 then
      M[1] = y
    end
    for y, d in ipairs(M) do
      T:addLabel(d, ...)
    end
  end
end
if not ZS_CATEGORY_ADDED then
  ZS_CATEGORY_ADDED = true
  if type(addCategory) == "function" then
    pcall(addCategory, "ZS", "Shield")
  end
end
local T = { ["tag"] = "k13", ["life"] = "ZSA-BUY", ["unlocked"] = false, ["entered"] = "", ["n"] = 0 }
local function y(T)
  if growtopia and type(growtopia["notify"]) == "function" then
    pcall(growtopia["notify"], tostring(T))
  else
    print("[ZS] " .. tostring(T))
  end
end
local d = y
local v = addHook
local function M(y, d)
  if type(y) ~= "function" then
    return
  end
  return v(function(...)
    if not T["unlocked"] then
      return false
    end
    return y(...)
  end, d)
end
local function p(T)
  local y = tostring(T)
  local d, v = y:find('"menu"%s*:%s*%[')
  if not d then
    return nil
  end
  local M, p, S, A = 1, v + 1, false, false
  while p <= #y do
    local T = y:sub(p, p)
    if S then
      if A then
        A = false
      elseif T == "\\" then
        A = true
      elseif T == '"' then
        S = false
      end
    elseif T == '"' then
      S = true
    elseif T == "[" then
      M = M + 1
    elseif T == "]" then
      M = M - 1
      if M == 0 then
        return y:sub(v + 1, p - 1)
      end
    end
    p = p + 1
  end
end
local function S()
  T["n"] = T["n"] + 1
  local y = UserInterface["new"]("ZS ACCESS", "Lock")
  y:addLabelApp("* ACCESS KEY *", "Lock")
  ZS_label(y, "Enter your key. You can look around, but everything works only after unlock.")
  y:addInputString("Enter Key", "", "Enter Key", "Your key", "Key", "zskey_" .. (T["tag"] .. ("_" .. T["n"])))
  y:addButton("UNLOCK", "zsunl_" .. (T["tag"] .. ("_" .. T["n"])))
  y:addDivider()
  return y
end
local A = addIntoModule
local function Y(y, d, ...)
  if type(y) == "string" and not y:find("zskey_" .. (T["tag"] .. "_"), 1, true) then
    local T, v = pcall(function()
      local T = S()
      local d = p(T:generateJSON())
      local v, M = y:find('"menu"%s*:%s*%[')
      if not (d and v) then
        return nil
      end
      local A = y:sub(M + 1)
      local Y = A:match("^%s*%]") and "" or ","
      return y:sub(1, M) .. (d .. (Y .. A))
    end)
    if T and v then
      y = v
    else
      pcall(function()
        A((S()):generateJSON(), d)
      end)
    end
  end
  return A(y, d, ...)
end
local function F(...)
  local d = select("#", ...)
  local v = { ... }
  local M, p = "zskey_" .. (T["tag"] .. "_"), "zsunl_" .. (T["tag"] .. "_")
  local function S(T)
    if type(T) ~= "string" then
      return nil
    end
    if T:sub(1, #M) == M then
      return "key"
    end
    if T:sub(1, #p) == p then
      return "btn"
    end
  end
  local A, Y
  local function F(T, y)
    if A or y > 2 then
      return
    end
    if type(T) == "string" then
      A = S(T)
    elseif type(T) == "table" then
      for d, v in pairs(T) do
        if S(v) then
          A = S(v)
          Y = T["value"] or T["text"] or T["v2"]
          return
        end
        if S(d) then
          A = S(d)
          Y = v
          return
        end
        if type(v) == "table" then
          F(v, y + 1)
        end
      end
    end
  end
  for T = 1, d, 1 do
    F(v[T], 0)
    if A then
      if Y == nil then
        Y = v[T + 1]
      end
      break
    end
  end
  if A == "key" then
    T["entered"] = tostring(Y or "")
    return true
  elseif A == "btn" then
    local d = ((T["entered"]:upper()):gsub("%s+", ""))
    if d == T["life"]:upper() then
      T["unlocked"] = true
      y("Key accepted. Unlocked!")
    else
      y("Invalid key.")
    end
    return true
  end
  return false
end
v(F, "onvalue")
local function w()
  if Preferences and Preferences["new"] then
    local T, y = pcall(function()
      return Preferences:new("zadstay_buy_pack.json")
    end)
    if T and y then
      return y
    end
  end
  local T, y = pcall(require, "Preferences")
  if T and (y and y["new"]) then
    local T, d = pcall(function()
      return y:new("zadstay_buy_pack.json")
    end)
    if T and d then
      return d
    end
  end
  return nil
end
local Z = w()
local function b(T, y)
  if Z and Z["get"] then
    local d, v = pcall(function()
      return Z:get(T, y)
    end)
    if d and v ~= nil then
      return v
    end
  end
  return y
end
local function C(T)
  if not (Z and Z["set"]) then
    return
  end
  for T, y in pairs(T) do
    local d = type(y)
    if d == "string" or d == "number" or d == "boolean" then
      pcall(function()
        Z:set(T, y)
      end)
    end
  end
  if Z["save"] then
    pcall(function()
      Z:save()
    end)
  end
end
local function X(T)
  T = tostring(T or "")
  T = ((((T:gsub("\\", "\\\\")):gsub('"', '\\"')):gsub("\n", "\n")):gsub("\r", "\\r")):gsub("\t", "\\t")
  return '"' .. (T .. '"')
end
local function Q(T)
  local y = type(T)
  if y == "nil" then
    return "null"
  elseif y == "boolean" then
    return T and "true" or "false"
  elseif y == "number" then
    return tostring(T)
  elseif y == "string" then
    return X(T)
  elseif y == "table" then
    local y = true
    local d = 0
    for T, v in pairs(T) do
      if type(T) ~= "number" or T < 1 or math["floor"](T) ~= T then
        y = false
        break
      end
      if T > d then
        d = T
      end
    end
    if y then
      local y = {}
      for d = 1, d, 1 do
        table["insert"](y, Q(T[d]))
      end
      return "[" .. (table["concat"](y, ",") .. "]")
    else
      local y = {}
      for T, d in pairs(T) do
        table["insert"](y, X(T) .. (":" .. Q(d)))
      end
      return "{" .. (table["concat"](y, ",") .. "}")
    end
  end
  return "null"
end
local c =
  "Upgrade Backpack:upgrade_backpack::\nClothes Pack:clothes_pack:50:234,210,1846,342,11202,214,138,354,2938,144,272,208,90,38,66,238,122,36,34,44,48,76,140,10034,694,142,236,270,130,40,68,42,374,372,3578,370\nRare Clothes Pack:rare_clothes:500:11204,600,1762,1028,1146,292,1708,5016,576,1736,348,1652,1650,294,3052,1330,890,1124,312,3530,1140,156,2882,258,452,9356,154,1478,1142,1120,150,2934,80,2928,1524,796,1126,152,1954,2576,2958,158,136,496,1848,896,1476,4954,1864,6674,296,290,310,1862,6796,4964,4968,2700,1316,1516,1854,1856,446,3590,1312,1688,1314,3466,594,1858,8884,1502,268,794,1342,488,798,1590,724,352,3048,1026,1860,1032,1838,1718,1850,316,1690,492,894,6788,1116,304,1332,302,86,3164,2578,1022,2960,88,1800,3056,3060,3934,2954,132,852,266,494,1504,74,50,134,98,448,3932,96,148,788,232,288,4966,70,2718,1844,1722,84,212,1122,92,1720,124,46,72,356,146,754,662,94,78,82,1716,250\nInfernal Shades:infernal_shades:25000:12474\nTidal Shades:tidal_shades:25000:12476\nVerdant Shades:verdant_shades:25000:12478\nTransmutabooth:transmutation_device:25000:9170\nContact Lens Pack:contact_lenses:15000:6768,6760,6762,6764,6766\nEye Drop Pack:eye_drops:30000:5468,5466,5464,5462,5460,5458\nTurtle Hat:nyan_hat:25000:574\nTiny Horsie:tiny_horsie:25000:592\nPleiadian Star Ship:star_ship:25000:760\nDragon Hand:dragon_hand:50000:900\nLittle Red Corvette:corvette:25000:766\nStick Horse:stick_horse:25000:1012\nAmbulance:ambulance:25000:1272\nRiding Raptor:raptor:25000:1320\nMid-Pacific Owl:owl:30000:1540\nUnicorn Garland:unicorn:50000:1648\nStarBoard:starboard:30000:1740\nGrowley Motorcycle:motorcycle:50000:1950\nMonkey On Your Back:monkey_on_back:50000:2900\nCarrot Sword:carrot_sword:15000:2908\nRed Bicycle:red_bicycle:30000:2974\nFire Truck:fire_truck:50000:3068\nPet Slime:pet_slime:100000:3166\nDabstep Low Top Sneakers:dabstep_shoes:30000:6790\nAdvertisers Pack:anzu_pack1:10000:10874,10872,10870,10876\nSmall Lock:small_lock:50:202\nBig Lock:big_lock:200:204\nHuge Lock:huge_lock:500:206\nDoor And Sign Hello Pack:door_pack:12:12,20\nDoor Mover:door_mover:5000:1404\nVending Machine:vending_machine:8000:2978\nDigiVendMachine:digi_vend:12000:9268\nVending Hub - Checkout Counter:checkout_counter:50000:9270\nChange of Address:change_addr:20000:2580\nSignal Jammer:signal_jammer:2000:226\nPunch Jammer:punch_jammer:15000:1276\nZombie Jammer:zombie_jammer:15000:1278\nImperial Starship Blast:starship_blast:10000:6420\nSurgWorld Blast:surg_blast:10000:8556\nBountiful Blast:bountiful_blast:5000:8738\nThermonuclear Blast:thermo_blast:15000:1402\nAntigravity Generator:antigravity_generator:450000:4992\nBuilding Blocks Machine:building_blocks_machine:8000:8196\nBuilder's Lock:builders_lock:50000:4994\nWeather Machine - Sunny:weather_sunny:1000:932\nWeather Machine - Night:weather_night:10000:934\nWeather Machine - Arid:weather_arid:10000:946\nWeather Machine - Rainy City:weather_rainy:10000:984\nWeather Machine - Warp Speed:weather_warp:10000:1750\nMars Blast:mars_blast:15000:1136\nUndersea Blast:undersea_blast:15000:1532\nCave Blast:cave_blast:30000:3562\nWeather Machine - Stuff:weather_stuff:50000:3832\nWeather Machine - Jungle:weather_jungle:20000:4776\nWeather Machine - Background:weather_backgd:150000:5000\nWeather Machine - Digital Rain:digital_rain_weather:30000:6854\nTreasure Blast:treasure_blast:10000:7588\nInfinity Weather Machine:infinity_weather_machine:50000:10058\nSmall Seed Pack Collection:ssp_10_pack:1000:5706\nRare Seed Pack:rare_seed:1000:2293,2295,2297,2299,2301,2305,2629,2309,2311,2313,2315,2317,2321,2323,2325,2327,2329,2333,2335,2337,2339,2341,2319,2331,2343,4697,2447,2519,2629,2727,231,487,483,2019,427,1757,2009,281,781,329,459,1041,421,2787,2789,1043,2797,181,613,65,4983,283,553,425,4635,987,627,2017,989,61,4639,973,3523,331,265,859,433,253,339,1105,439,4567,333,677,5673,1427,5603,183,10533,5731,7223,10833,6035,6813,1113,1047,653,2811,4703,1429,847,665,485,1613,833,2025,1775,3931,429,3831,423,437,1773,4767,1299,361,667,2815,3473,301,4637,5683,2709,415,955,461,861,9389,5467,2791,2815,1803,419,2027,685,555,741,10531,5729,7221,10831,6033,6811,621,6401,1107,359,3471,855,309,1685,1449,1309,441,1111,221,1431,3065,9307,1257,1501,1109,4641,3587,1103,417,743,431,3823,2949,1131,3825,727,5379,729,187,787,5459,3423,3261,3521,5461,3721,327,247,63,3479,445,4783,299,863,8935,1451,261,1871,1499,455,9391,683,1159,551,1745,411,3005,557,687,4799,559,4643,3899,1605,9309,567,565,1155,3827,1327,1767,993,1157,563,4721,115,1423,10515,1329,6545,287,669,777,5463,1655,1599,561,4585,3413,4745,1771,2011,1161,1729,3757,3753,321,3265,3263,623,775,6397,129,4667,759,3767,1529,6543,4707,3835,1435,651,8929,569,527,3287,1595,6063,2795,1003,1731,4943,4963,597,4669,1531,1523,625,4297,599,657,571,873,3755,2969,1725,4603,1447,3267,5375,1683\n5-pack of Grow Spray Fertilizer:grow_spray:200:228\nDeluxe Grow Spray:deluxe_grow_spray:900:1778\nBountiful Seed Pack:bountiful_seed_pack:1000:8970\nBasic Splicing Kit:basic_splice:200:101,21,1139,381,17,57,13,3567,11\nSurgery Starter Pack:surg_starter_pack:5000:1248,1246,1244,1242,8558,1256,1240\nSurgical Kit:surgical_kit:12000:9310,4316,4310,1270,1258,1268,1260,4308,4318,4312,4314,1264,1266,1263,4296\nMaster Surgeon's Tool Bag:surg_value_pack:45000:9310,4316,4310,1270,1258,1268,1260,4308,4318,4312,4314,1264,1266,1263,4296\nGalactic Goodies:star_supplies:15000:6526,6532,6534,6536,6416,6524,6530,6518,6540,6528,6522,6538,6520\nFishin' Pack:fishin_pack:10000:2912,3044,3004,3002,2914,5524,5522\nFish Trainin' Pack:fish_training_pack:10000:5536,5532,5530\nFish Flakes:fish_flakes:7500:5536\nFish Medicine:fish_medicine:1500:5532\nFish Reviver:fish_reviver:5000:5534\nCrime Wave:crime_wave:5000:2293,2295,2297,2299,2301,2305,2629,2309,2311,2313,2315,2317,2321,2323,2325,2327,2329,2333,2335,2337,2339,2341,2319,2331,2343,4697,2447,2519,2629,2727\nSilkworm:silkworn:7000:3316\nZombie Defense Pack:zombie_pack:10000:764,768,784,782,786,774,788,790\nB.O.O. Training Pack:boo_pack:10000:3710,3716,3714,3720\nEctoJuicer:ectojuicer:30000:6096\nGhost Hunter's Pack:ghost_hunting:10000:13820\nChemsynth Pack:chemsynth:10000:4442,4434,4440,4438,4436,4432,4430\nRacing Action Pack:race_pack:3500:486,484,482,410,430,428,496,356,488,490,494,492\nComposer's Pack:music_pack:5000:418,416,414,426,424,422,420,412\nEducation Pack:school_pack:5000:678,672,670,676,658,654,650,652,674,8872,8870,8876,8874\nDungeon Pack:dungeon_pack:10000:692,696,694,690,688,686,684,682,680\nFantasy Pack:fantasy_pack:5000:583,596,598,606,608,604,594,600\nVegas Pack:vegas_pack:20000:798,796,794,758,756,754,456,752,1582,740,1922,1920,1924,1918,1916,743,747,749,744\nFarm Pack:farm_pack:15000:898,896,894,892,13732,890,886,888,884,880,872,866\nMad Science Kit:science_pack:5000:918,920,924,914,916,930,904,12494,770,772,912,928\nCity Pack:city_pack:8000:1008,1002,988,1006,1004,998,996,990,992,986,994\nWild West Pack:west_pack:8000:1016,1020,1048,1046,1044,1042,1040,1038,1032,1034,1036,1028,1026,1024,1030,1022\nAstro Pack:astro_pack:5000:1152,1154,1130,1128,1160,1162,1164,1146,1144,1142,1140,1148\nPrehistoric Pack:prehistoric_pack:5000:1328,1324,1322,1326,1342,1340,1332,1334,1338,1330,1336\nShop Pack:shop_pack:10000:1420,1434,1446,1430,1432,1428,1426,1422,1436\nHome Pack:home_pack:50000:1474,1476,1478,1454,1472,1450,1480,1448,1482\nCinema Pack:cinema_pack:6000:1596,1608,1606,1604,1600,1598,1594,1590,1592,1588\nAdventure Pack:adventure_pack:20000:4780,1704,1692,1698,1696,1702,1694,4706,4704,1706,1684,1682\nRockin' Pack:rockin_pack:9999:1726,1730,1728,1724,1720,1722,1732,1718,1714,1712,1710\nGame Pack:game_pack:50000:1658,1656,1622,1618,1616,1660\nSuperhero Pack:superhero:10000:6684,7148,2196,2200,2202,2198,2194,6694,2162,2164,2160,2158,6696,6686,2126,2128,2124,2122,6692,6682,2102,2104,2100,2098,2114,2116,2112,2110,6690,6680,2174,2176,2172,2170,2078,2080,2076,2074,6688,6678,2138,2140,2136,2134,2186,2188,2184,2182,2150,2152,2148,2146,2208\nFashion Pack:fashion_pack:5000:11800,11206,10080,2672,2684,2660,2648,2708,2646\nSportsball Pack:sportsball_pack:20000:13600,6676,6670,2906,2888,2884,2880,6672,2882,2878,2890,2886,6668,2894,2892,2898,2896,6674,2904,2902\nFirefighter Pack:firefighter:10000:3072,3066,3052,3060,3056,3048\nSteampack:steampack:20000:3292,3280,3284,3282,3270,3260\nPainter's Pack:paintbrush:30000:3494,3492,3480,3484,3486,3488,3482,3478,3490\nPaleontologist's Kit:paleo_kit:20000:3938,4128,3934,3932,4132\nCyBlocks Starter Pack:robot_starter_pack:5000:5668,5680,5676,5672,5678,5674\nCyBlocks Command Pack:robot_command_pack:2000:5704,5702,5698,5700,5696,5694,5690,5692,5688,5686,5682,5684,5680,5678,5676,5672,5674\nCyBot Pack:robot_pack:15000:5670,5710,5708\nGangland Style:gang_pack:5000:478,480,472,470,476,474,468,466,464,462\n"
local R = {}
local N = {}
local function r(T)
  return ((tostring(T or "")):gsub("^%s+", "")):gsub("%s+$", "")
end
local function O(T)
  return (r((tostring(T or "")):gsub("`.", ""))):gsub("[|\r\n]+", " ")
end
local function o(T)
  for T in (tostring(T or "")):gmatch("[^\r\n]+") do
    local y = r(T)
    if y ~= "" and (y:sub(1, 2) ~= "--" and (y ~= "]]" and (not y:find("^packs%s*=")))) then
      local T, d, v, M = y:match("^([^:]+):([^:]*):([^:]*):(.*)$")
      T = r(T)
      d = r(d)
      if T ~= "" and d ~= "" then
        local y = {}
        for T in (tostring(M or "")):gmatch("[^,%s;]+") do
          local d = tonumber(T)
          if d and d > 0 then
            table["insert"](y, tostring(math["floor"](d)))
          end
        end
        local p = { ["title"] = T, ["code"] = d, ["price"] = tonumber(v) or 0, ["ids"] = table["concat"](y, ",") }
        local S = d:lower()
        local A = N[S]
        if A then
          R[A] = p
        else
          table["insert"](R, p)
          N[S] = #R
        end
      end
    end
  end
end
o(c)
if io and io["open"] then
  for T, y in ipairs({ "debugpack.txt", "ScriptLua/debugpack.txt" }) do
    local d = io["open"](y, "r")
    if d then
      local T = d:read("*a")
      d:close()
      o(T)
      break
    end
  end
end
local i = {
  ["pack_name"] = tostring(b("pack_name", "world_lock") or "world_lock"),
  ["pack_item_ids_text"] = tostring(b("pack_item_ids_text", "242") or "242"),
  ["pack_price"] = tonumber(b("pack_price", 2000)) or 2000,
  ["target_packs"] = tonumber(b("target_packs", 1)) or 1,
  ["drop_world"] = tostring(b("drop_world", "") or ""),
  ["drop_door"] = tostring(b("drop_door", "") or ""),
  ["drop_anchor_x"] = tonumber(b("drop_anchor_x", 0)) or 0,
  ["drop_anchor_y"] = tonumber(b("drop_anchor_y", 0)) or 0,
  ["drop_threshold"] = 200,
  ["auto_drop"] = false,
  ["max_stacks_per_tile"] = tonumber(b("max_stacks_per_tile", 18)) or 18,
  ["use_gl_drop"] = (b("use_gl_drop", true) ~= false),
  ["anti_retake"] = (b("anti_retake", true) ~= false),
  ["auto_learn_items"] = (b("auto_learn_items", true) ~= false),
  ["shop_search"] = tostring(b("shop_search", "") or ""),
  ["delay_buy"] = tonumber(b("delay_buy", 1000)) or 1000,
  ["delay_drop"] = tonumber(b("delay_drop", 350)) or 350,
  ["delay_warp"] = tonumber(b("delay_warp", 4500)) or 4500,
}
if i["target_packs"] < 1 then
  i["target_packs"] = 1
end
local P = {
  ["running"] = false,
  ["step"] = "READY",
  ["detail"] = string["format"](
    "%d packs loaded! Select a pack and START. Auto-drop at 200 items in the current world.",
    #R
  ),
  ["packs_bought"] = 0,
  ["items_dropped"] = 0,
  ["full_drop_tiles"] = {},
  ["backpack_full_flag"] = false,
  ["no_gems_flag"] = false,
  ["unknown_pack_flag"] = false,
  ["pending_drop_id"] = nil,
  ["pending_drop_amt"] = nil,
  ["hooks_installed"] = false,
  ["saved_ac_toggle"] = nil,
  ["saved_anti_toggle"] = nil,
  ["last_dialog_items"] = {},
  ["dialog_page"] = 1,
  ["anti_take_active"] = false,
  ["last_store_msg"] = "",
  ["buy_server_confirmed"] = false,
  ["in_coroutine"] = false,
  ["ignore_power_event"] = false,
  ["user_edited_price"] = false,
  ["user_set_target"] = false,
  ["last_seen_search_gl"] = nil,
  ["buying_now"] = false,
  ["suppress_store_until"] = 0,
  ["logged_store_block"] = false,
}
local function V(T)
  T = tostring(T or "")
  if growtopia and growtopia["notify"] then
    pcall(growtopia["notify"], T)
  elseif sendNotification then
    pcall(sendNotification, T)
  end
end
local function G(T)
  T = "[ZS Auto Buy Pack] " .. tostring(T or "")
  if LogToConsole then
    pcall(LogToConsole, T)
  elseif log then
    pcall(log, T)
  end
end
local function H(T)
  local y = math["max"](0, tonumber(T) or 0)
  if y == 0 then
    return
  end
  if P["in_coroutine"] and CSleep then
    pcall(CSleep, y)
  elseif sleep then
    pcall(sleep, y)
  elseif CSleep then
    pcall(CSleep, y)
  end
end
local function U(T)
  local y = function()
    P["in_coroutine"] = true
    local y, d = pcall(T)
    P["in_coroutine"] = false
    if not y then
      G("Coroutine Error: " .. tostring(d))
    end
  end
  if runCoroutine then
    local T, d = pcall(runCoroutine, y)
    if not T then
      P["in_coroutine"] = false
      G("runCoroutine failed: " .. tostring(d))
      y()
    end
  else
    y()
  end
end
local K
local function B(T, y)
  P["step"] = tostring(T or "Running")
  P["detail"] = tostring(y or "")
  G(P["step"] .. (" - " .. P["detail"]))
  if K then
    pcall(K)
  end
end
K = function()
  if not editValue then
    return
  end
  local T = "-"
  if getGems then
    local y, d = pcall(getGems)
    if y and d then
      T = tostring(d)
    end
  end
  local y = P["running"] and ("RUNNING: " .. P["step"]) or ("STOPPED (" .. (P["step"] .. ")"))
  local d = (i["target_packs"] > 0) and (tostring(P["packs_bought"]) .. ("/" .. tostring(i["target_packs"])))
    or (tostring(P["packs_bought"]) .. " (Complete)")
  local v = {
    { y, P["detail"] },
    {
      "How Many: " .. (d .. (" | Price: " .. tostring(i["pack_price"]))),
      "Gems: " .. (T .. (" | Drop: " .. tostring(P["items_dropped"]))),
    },
  }
  pcall(editValue, "bp_status_list", Q(v))
end
local function a(T, y)
  local d = r(T)
  local v = r(y)
  if d:find("|", 1, true) then
    local T, y = d:match("^([^|]+)|(.*)$")
    d = r(T)
    if r(y) ~= "" then
      v = r(y)
    end
  elseif d:find(":", 1, true) then
    local T, y = d:match("^([^:]+):(.*)$")
    d = r(T)
    if r(y) ~= "" then
      v = r(y)
    end
  end
  return d:upper(), v
end
local function W(T)
  local y = {}
  local d = {}
  for T in (tostring(T or "")):gmatch("[^,\r\n;%s]+") do
    local v = tonumber(T)
    if v and v > 0 then
      v = math["floor"](v)
      if not d[v] then
        d[v] = true
        table["insert"](y, v)
      end
    elseif (r(T)):lower() ~= "nul" and (r(T)):lower() ~= "null" then
      if findItemID then
        local v, M = pcall(findItemID, r(T))
        if v and (tonumber(M) and tonumber(M) > 0) then
          local T = math["floor"](tonumber(M))
          if not d[T] then
            d[T] = true
            table["insert"](y, T)
          end
        end
      end
    end
  end
  return y
end
local function x(T)
  if getItemInfoByID then
    local y, d = pcall(getItemInfoByID, T)
    if y and (d and (d["name"] and d["name"] ~= "")) then
      return tostring(d["name"])
    end
  end
  if growtopia and growtopia["getItemName"] then
    local y, d = pcall(growtopia["getItemName"], T)
    if y and (d and d ~= "") then
      return tostring(d)
    end
  end
  return "ID " .. tostring(T)
end
local function m()
  if getCurrentWorldName then
    local T, y = pcall(getCurrentWorldName)
    if T and (type(y) == "string" and y ~= "") then
      return y:upper()
    end
  end
  if getWorld then
    local T, y = pcall(getWorld)
    if T and (y and y["name"]) then
      return (tostring(y["name"])):upper()
    end
  end
  return ""
end
local function E()
  if getLocal then
    local T, y = pcall(getLocal)
    if not T or not y then
      return false
    end
  end
  local T = m()
  return (T ~= "" and T ~= "EXIT")
end
local function e()
  if not getLocal then
    return nil, nil
  end
  local T, y = pcall(getLocal)
  if not T or not y then
    return nil, nil
  end
  local d = y["posX"] or (y["pos"] and y["pos"]["x"])
  local v = y["posY"] or (y["pos"] and y["pos"]["y"])
  if not d or not v then
    return nil, nil
  end
  return math["floor"]((d + 10) / 32), math["floor"]((v + 10) / 32)
end
local function D()
  local T = {}
  if getInventory then
    local y, d = pcall(getInventory)
    if y and type(d) == "table" then
      for y, d in pairs(d) do
        local v = tonumber(d["id"] or d["itemID"] or d["itemid"])
        local M = tonumber(d["amount"] or d["count"]) or 0
        if v and (v > 0 and (v ~= 112 and M > 0)) then
          T[v] = (T[v] or 0) + M
        end
      end
    end
  end
  return T
end
local function z(T)
  if growtopia and growtopia["checkInventoryCount"] then
    local y, d = pcall(growtopia["checkInventoryCount"], T)
    if y and type(d) == "number" then
      return d
    end
  end
  if getInventory then
    local y, d = pcall(getInventory)
    if y and type(d) == "table" then
      for y, d in pairs(d) do
        if (d["id"] or d["itemID"] or d["itemid"]) == T then
          return tonumber(d["amount"] or d["count"]) or 0
        end
      end
    end
  end
  return 0
end
local function n(T)
  if getInventory then
    local y = D()
    for T, d in ipairs(T) do
      if (y[d] or 0) > 0 then
        return true
      end
    end
    return false
  end
  for T, y in ipairs(T) do
    if z(y) > 0 then
      return true
    end
  end
  return false
end
local function j(T)
  local y = math["max"](1, math["min"](200, tonumber(i["drop_threshold"]) or 200))
  if getInventory then
    local d = D()
    for T, v in ipairs(T) do
      if (d[v] or 0) >= y then
        return true, v
      end
    end
    return false, nil
  end
  for T, d in ipairs(T) do
    if z(d) >= y then
      return true, d
    end
  end
  return false, nil
end
local function t(T)
  if getValue then
    local y = false
    for d, v in ipairs({ 2, 5, 1 }) do
      local M, p = pcall(getValue, v, T)
      if M and p ~= nil then
        local T = r(tostring(p))
        if T ~= "" then
          return T
        end
        y = true
      end
    end
    if y then
      return ""
    end
  end
  return nil
end
local function f(T, y)
  local d = t(T)
  if d ~= nil and d ~= "" then
    return d
  end
  return y
end
local function L(T)
  if getValue then
    for y, d in ipairs({ 1, 2, 5 }) do
      local v, M = pcall(getValue, d, T)
      if v and M ~= nil then
        local T = (r(tostring(M))):gsub("[,%s]", "")
        local y = tonumber(T)
        if y then
          return math["floor"](y)
        end
      end
    end
  end
  return nil
end
local function s(T, y)
  if getValue then
    local y, d = pcall(getValue, 0, T)
    if y and type(d) == "boolean" then
      return d
    end
  end
  return y
end
local function l()
  local T = f("bp_pack_name", "")
  if T ~= "" then
    i["pack_name"] = r(T)
  end
  local y = f("bp_item_ids", "")
  if y ~= "" then
    i["pack_item_ids_text"] = r(y)
  end
  local d = L("bp_pack_price")
  if d and ((d > 0 or not P["user_edited_price"]) and d >= 0) then
    i["pack_price"] = d
  end
  local v = L("bp_target_packs")
  if v and ((v > 0 or not P["user_set_target"]) and v >= 0) then
    i["target_packs"] = v
  end
  i["use_gl_drop"] = s("bp_use_gl_drop", i["use_gl_drop"])
  i["anti_retake"] = s("bp_anti_retake", i["anti_retake"])
  i["auto_learn_items"] = s("bp_auto_learn", i["auto_learn_items"])
end
local function k(T, y)
  if not T then
    return false
  end
  local d = D()
  local v = {}
  for T, y in ipairs(y) do
    v[y] = true
  end
  local M = false
  for d, p in pairs(d) do
    local S = T[d] or 0
    if p > S and not v[d] then
      v[d] = true
      table["insert"](y, d)
      M = true
      G(string["format"]("Auto-Deteksi Isi Pack: +%s (ID %d)", x(d), d))
    end
  end
  if M then
    local T = {}
    for y, d in ipairs(y) do
      table["insert"](T, tostring(d))
    end
    i["pack_item_ids_text"] = table["concat"](T, ", ")
    if editValue then
      pcall(editValue, "bp_item_ids", i["pack_item_ids_text"])
    end
    C(i)
  end
  return M
end
local function g(T, y, d, v)
  local M = T["title"]:lower()
  local p = T["code"]:lower()
  if y == "" then
    return 100
  end
  if p == y or M == y then
    return 1000
  end
  if M:sub(1, #y) == y or p:sub(1, #y) == y then
    return 800
  end
  if ((" " .. M)):find(" " .. y, 1, true) or (("_" .. p)):find("_" .. y, 1, true) then
    return 600
  end
  if M:find(y, 1, true) or p:find(y, 1, true) then
    return 450
  end
  if #d > 1 then
    local T = M .. (" " .. p)
    local y = true
    for d, v in ipairs(d) do
      if not T:find(v, 1, true) then
        y = false
        break
      end
    end
    if y then
      return 350
    end
  end
  if v then
    local d = "," .. (tostring(T["ids"] or "") .. ",")
    if d:find("," .. (y .. ","), 1, true) then
      return 200
    end
  end
  return nil
end
local function q(T)
  local y = (r(T)):lower()
  local d = {}
  if y ~= "" then
    for T in y:gmatch("%S+") do
      table["insert"](d, T)
    end
  end
  local v = (y ~= "" and y:match("^%d+$") ~= nil)
  local M = {}
  for T, p in ipairs(R) do
    local S = g(p, y, d, v)
    if S then
      table["insert"](M, { ["item"] = p, ["score"] = S, ["origIdx"] = T })
    end
  end
  if y ~= "" then
    table["sort"](M, function(T, y)
      if T["score"] ~= y["score"] then
        return T["score"] > y["score"]
      end
      if #T["item"]["title"] ~= #y["item"]["title"] then
        return #T["item"]["title"] < #y["item"]["title"]
      end
      return T["origIdx"] < y["origIdx"]
    end)
  end
  local p = {}
  for T, y in ipairs(M) do
    table["insert"](p, y["item"])
  end
  return p
end
local function J()
  if not editValue then
    return
  end
  local T = r(i["shop_search"])
  local y = q(T)
  local d = {}
  if T == "" then
    table["insert"](
      d,
      {
        string["format"]("Enter a name in Search Packs (%d packs available)", #R),
        "Or choose a pack from the categories below",
      }
    )
    local T = math["min"](10, #y)
    for T = 1, T, 1 do
      local v = y[T]
      local M = (tonumber(v["price"]) or 0) > 0 and (tostring(v["price"]) .. "g") or "Store"
      table["insert"](d, { string["format"]("%d. %s", T, O(v["title"])), O(v["code"]) .. (" | " .. M) })
    end
  else
    local v = math["min"](25, #y)
    for T = 1, v, 1 do
      local v = y[T]
      local M = (tonumber(v["price"]) or 0) > 0 and (tostring(v["price"]) .. " Gems") or "Store"
      table["insert"](d, { string["format"]("%d. %s", T, O(v["title"])), "Code: " .. (O(v["code"]) .. (" | " .. M)) })
    end
    if #d == 0 then
      table["insert"](d, { "No matching packs: " .. T, "Try another search, e.g. seed / surg / lock" })
    end
  end
  pcall(editValue, "bp_shop_results_list", Q(d))
  return y
end
local function u(T)
  if not T then
    return
  end
  i["pack_name"] = T["code"]
  if (tonumber(T["price"]) or 0) > 0 then
    i["pack_price"] = math["floor"](tonumber(T["price"]))
    P["user_edited_price"] = false
    if editValue then
      pcall(editValue, "bp_pack_price", tostring(i["pack_price"]))
    end
  end
  i["pack_item_ids_text"] = r(T["ids"] or "")
  i["auto_learn_items"] = true
  if editToggle then
    pcall(editToggle, "bp_auto_learn", true)
  end
  if editValue then
    pcall(editValue, "bp_pack_name", i["pack_name"])
    pcall(editValue, "bp_item_ids", i["pack_item_ids_text"])
  end
  C(i)
  local y = (i["pack_item_ids_text"] ~= "") and "Automatic IDs Ready" or "Auto-Detect During Purchase"
  local d = string["format"]("Selected: %s (%s) | %d Gems | %s", T["title"], T["code"], tonumber(T["price"]) or 0, y)
  B("Pack Ready", d)
  V(d)
end
local function h(T)
  local y = (r(T)):lower()
  if y == "" then
    return nil
  end
  local d = tonumber(y)
  if d and (d >= 1 and math["floor"](d) == d) then
    local T = q(i["shop_search"])
    if T[d] then
      return T[d]
    end
  end
  for T, d in ipairs(R) do
    if d["code"]:lower() == y then
      return d
    end
  end
  for T, d in ipairs(R) do
    if d["title"]:lower() == y then
      return d
    end
  end
  local v = q(T)
  return v[1]
end
local function I(T, y)
  if T ~= nil then
    i["shop_search"] = r(T)
    C(i)
  end
  local d = q(i["shop_search"])
  P["last_dialog_items"] = d
  local v = 15
  local M = math["max"](1, math["ceil"](#d / v))
  local p = tonumber(y) or 1
  if p < 1 then
    p = 1
  end
  if p > M then
    p = M
  end
  P["dialog_page"] = p
  if growtopia and growtopia["sendDialog"] then
    local T = {
      "set_default_color|`o",
      "add_label_with_icon|big|`wZS Auto Buy Pack - Search Packs``|left|112|",
      string["format"]("add_textbox|`oList Debug: `2%d`o pack | Found: `2%d`o | Hal `w%d/%d`o.|left|", #R, #d, p, M),
      "add_spacer|small|",
      string["format"]("add_text_input|shop_q|Search Pack Name:|%s|32|", O(i["shop_search"] or "")),
      "add_button|shop_search|`2Search|noflags|0|0|",
      "add_button|shop_clear_q|`9Show All|noflags|0|0|",
      "add_spacer|small|",
    }
    if #d == 0 then
      table["insert"](T, "add_textbox|`4No packs match your search.|left|")
    else
      local y = (p - 1) * v + 1
      local S = math["min"](#d, (y + v) - 1)
      for y = y, S, 1 do
        local v = d[y]
        local M = (tonumber(v["price"]) or 0) > 0 and (tostring(v["price"]) .. " Gems") or "Free/Store"
        table["insert"](
          T,
          string["format"](
            "add_button|shop_pick_%d|`w%s (`5%s`w) [`2%s`w]|noflags|0|0|",
            y,
            O(v["title"]),
            M,
            O(v["code"])
          )
        )
      end
      if M > 1 then
        if p > 1 then
          table["insert"](T, "add_button|shop_page_prev|`6<< Previous|noflags|0|0|")
        end
        if p < M then
          table["insert"](T, "add_button|shop_page_next|`6Next >>|noflags|0|0|")
        end
      end
    end
    table["insert"](T, "end_dialog|zs_shop_browser|Close||")
    pcall(growtopia["sendDialog"], table["concat"](T, "\n"))
    return true
  end
  return false
end
local function TW(T)
  if not i["anti_retake"] then
    P["anti_take_active"] = false
    return
  end
  P["anti_take_active"] = (T == true)
  if T then
    if P["saved_ac_toggle"] == nil then
      P["saved_ac_toggle"] = s("Auto Collect", false)
      P["saved_anti_toggle"] = s("Anti Collect", false)
    end
    if editToggle then
      pcall(editToggle, "Auto Collect", false)
      pcall(editToggle, "Anti Collect", true)
      pcall(editToggle, "AutoCollect", false)
      pcall(editToggle, "AntiCollect", true)
    elseif editValue then
      pcall(editValue, "Auto Collect", false)
      pcall(editValue, "Anti Collect", true)
    end
  else
    if editToggle then
      if P["saved_ac_toggle"] ~= nil then
        pcall(editToggle, "Auto Collect", P["saved_ac_toggle"])
      end
      if P["saved_anti_toggle"] ~= nil then
        pcall(editToggle, "Anti Collect", P["saved_anti_toggle"])
      end
    end
  end
end
local function yW(T, y, d)
  T = (r(T)):upper()
  y = r(y)
  if T == "" then
    return false
  end
  local v = m()
  local M = (v == T)
  local p = (y ~= "") and (T .. ("|" .. y)) or T
  if M and (y == "" and not d) then
    return true
  end
  local S, A = e()
  B("Warp World", (y ~= "") and ("Warping to " .. (T .. (":" .. y))) or ("Warping to " .. T))
  if sendPacket then
    pcall(sendPacket, 3, "action|join_request\nname|" .. (p .. "\ninvitedWorld|0\n"))
  elseif growtopia and growtopia["warpTo"] then
    pcall(growtopia["warpTo"], T)
  end
  local Y = math["max"](2500, tonumber(i["delay_warp"]) or 4500)
  local F = 0
  while P["running"] and F < Y do
    H(250)
    F = F + 250
    if m() == T then
      if (not M) or y == "" then
        H(650)
        return true
      end
      local T, d = e()
      if (S and (T and (T ~= S or d ~= A))) or F >= 1000 then
        H(450)
        return true
      end
    end
  end
  return (m() == T)
end
local function dW(T)
  if T == nil then
    return ""
  end
  local y = type(T)
  if y == "string" or y == "number" or y == "boolean" then
    return tostring(T)
  end
  local d = nil
  pcall(function()
    if T["getString"] then
      d = T:getString()
    elseif T["str"] then
      d = T["str"]
    elseif T["text"] then
      d = T["text"]
    end
  end)
  if d ~= nil then
    return tostring(d)
  end
  local v, M = pcall(tostring, T)
  return v and M or ""
end
local function vW(T)
  if T == nil then
    return "", ""
  end
  local y, d, v
  pcall(function()
    y = T["v1"]
  end)
  pcall(function()
    d = T["v2"]
  end)
  pcall(function()
    v = T["v3"]
  end)
  if y == nil then
    pcall(function()
      y = T[1] or T[0]
    end)
  end
  if d == nil then
    pcall(function()
      if T[0] ~= nil and T[1] ~= nil then
        d = T[1]
      else
        d = T[2]
      end
    end)
  end
  if y == nil then
    pcall(function()
      if T["get"] then
        y = T:get(0)
        d = T:get(1)
        v = T:get(2)
      end
    end)
  end
  return dW(y), dW(d), dW(v)
end
local function MW()
  if os and os["clock"] then
    local T, y = pcall(os["clock"])
    if T and type(y) == "number" then
      return y
    end
  end
  return 0
end
local function pW()
  if P["running"] then
    return true
  end
  local T = MW()
  return T > 0 and P["suppress_store_until"] > T
end
local function SW(T, y)
  if T == nil then
    return false
  end
  local d, v, M = vW(T)
  if d == "" then
    return false
  end
  local p = d:lower()
  local S = (v ~= "" and v) or (M ~= "" and M) or ""
  local A = S:lower()
  if p == "onstorerequest" then
    if pW() then
      if not P["logged_store_block"] then
        P["logged_store_block"] = true
        G("Shop display (OnStoreRequest) blocked so pack purchases can continue in the background.")
      end
      return true
    end
  elseif p == "onstorepurchaseresult" then
    local T = r(S:gsub("`.", ""))
    if T ~= "" then
      P["last_store_msg"] = T
      G("Store Purchase Result: " .. T)
    end
    if A:find("not enough gems") or A:find("don't have enough gems") or A:find("insufficient gems") then
      P["no_gems_flag"] = true
    elseif A:find("backpack is full") or A:find("inventory is full") or A:find("can't carry") then
      P["backpack_full_flag"] = true
    elseif A:find("unknown item") or A:find("cannot purchase") or A:find("not available") then
      P["unknown_pack_flag"] = true
    elseif A:find("purchased") or A:find("bought") or A:find("success") then
      P["buy_server_confirmed"] = true
    end
    if pW() then
      return true
    end
  elseif p == "onconsolemessage" or p == "ontextoverlay" then
    local T = r(S:gsub("`.", ""))
    if
      P["running"]
      and (
        T ~= ""
        and (
          A:find("gem")
          or A:find("buy")
          or A:find("pack")
          or A:find("store")
          or A:find("wait")
          or A:find("full")
          or A:find("unknown")
          or A:find("bought")
          or A:find("purchased")
        )
      )
    then
      P["last_store_msg"] = T
      G("Server: " .. T)
    end
    if A:find("not enough gems") or A:find("don't have enough gems") or A:find("insufficient gems") then
      P["no_gems_flag"] = true
    elseif A:find("backpack is full") or A:find("inventory is full") or A:find("can't carry any more") then
      P["backpack_full_flag"] = true
    elseif A:find("unknown item") or A:find("cannot purchase") or A:find("not available") then
      P["unknown_pack_flag"] = true
    elseif A:find("bought") or A:find("purchased") then
      P["buy_server_confirmed"] = true
    end
  elseif p == "ondialogrequest" then
    if P["running"] and (P["pending_drop_id"] and (A:find("drop") or A:find("how many"))) then
      local T = tonumber(P["pending_drop_amt"]) or 1
      local y = tostring(P["pending_drop_id"])
      local d = S:match("end_dialog|([^|\n]+)") or "drop_item"
      if (d:lower()):find("drop") then
        if sendPacket then
          pcall(
            sendPacket,
            2,
            string["format"]("action|dialog_return\ndialog_name|%s\nitemID|%s|\ncount|%d\n", d, y, T)
          )
        end
        return true
      end
    elseif
      pW()
      and (
        (not A:find("zs_shop_browser"))
        and (
          A:find("store")
          or A:find("purchase")
          or A:find("confirm")
          or A:find("buy")
          or (P["buying_now"] and (A:find("spend") or A:find("pack")))
        )
      )
    then
      local T = S:match("end_dialog|([^|\r\n]+)")
      if T and (r(T) ~= "" and sendPacket) then
        local y = S:match("add_button|([^|\r\n]+)|")
        local d = (y and (r(y) ~= "" and (y ~= "cancel" and y ~= "back"))) and ("buttonClicked|" .. (r(y) .. "\n"))
          or ""
        pcall(sendPacket, 2, "action|dialog_return\ndialog_name|" .. (r(T) .. ("\n" .. d)))
        G("Automatic purchase confirmation: " .. r(T))
      end
      return true
    end
  end
  return false
end
local function AW(T, y)
  if type(y) ~= "string" then
    return false
  end
  if y:find("dialog_name|zs_shop_browser", 1, true) then
    local T = y:match("buttonClicked|([^\n|\r]+)") or ""
    local d = y:match("shop_q|([^\n|\r]*)")
    if T == "shop_clear_q" then
      i["shop_search"] = ""
      if editValue then
        pcall(editValue, "bp_shop_search", "")
      end
      C(i)
      J()
      I("", 1)
    elseif T == "shop_page_prev" then
      I(i["shop_search"], (P["dialog_page"] or 1) - 1)
    elseif T == "shop_page_next" then
      I(i["shop_search"], (P["dialog_page"] or 1) + 1)
    elseif T:sub(1, 10) == "shop_pick_" then
      local y = tonumber(T:sub(11))
      local d = y and P["last_dialog_items"][y]
      if d then
        u(d)
      end
    elseif T == "shop_search" or d ~= nil then
      i["shop_search"] = r(d or i["shop_search"])
      if editValue then
        pcall(editValue, "bp_shop_search", i["shop_search"])
      end
      C(i)
      J()
      I(i["shop_search"], 1)
    end
    return true
  end
  return false
end
local function YW(T)
  if P["anti_take_active"] and (type(T) == "table" and tonumber(T["type"]) == 11) then
    return true
  end
  return false
end
local function FW()
  if P["hooks_installed"] then
    return
  end
  P["hooks_installed"] = true
  if M then
    pcall(M, SW, "onvariant")
    pcall(M, AW, "onsendpacket")
    pcall(M, YW, "onsendpacketraw")
  end
  if applyHook then
    pcall(applyHook)
  end
end
local function wW(T, y)
  if T < 1 or T > 98 or y < 1 or y > 53 then
    return false
  end
  if not getTile then
    return true
  end
  local d, v = pcall(getTile, T, y)
  if not d or not v then
    return true
  end
  if v["collidable"] then
    return false
  end
  local M = tonumber(v["fg"]) or 0
  if M == 4 or M == 8 or M == 2 or M == 10 or M == 242 or M == 202 then
    return false
  end
  return true
end
local function ZW(T, y)
  if not wW(T, y) then
    return false
  end
  local d = tostring(T) .. ("," .. tostring(y))
  if P["full_drop_tiles"][d] then
    return false
  end
  local v = getObjectList or getObjects
  if v then
    local M, p = pcall(v)
    if M and type(p) == "table" then
      local v = 0
      local M = 0
      for d, p in pairs(p) do
        if p and p["pos"] then
          local d = math["floor"]((p["pos"]["x"] + 10) / 32)
          local S = math["floor"]((p["pos"]["y"] + 10) / 32)
          if d == T and S == y then
            v = v + 1
            M = M + (tonumber(p["amount"]) or 1)
          end
        end
      end
      if v >= (tonumber(i["max_stacks_per_tile"]) or 18) or M >= 3600 then
        P["full_drop_tiles"][d] = true
        return false
      end
    end
  end
  return true
end
local function bW(T, y, d)
  if FindPath then
    local d, v = pcall(FindPath, T, y, true)
    if d and v == true then
      return false
    end
    local M = pcall(FindPath, T, y)
    if not M then
      return false
    end
    H(160)
  end
  local v, M = e()
  if v and (M and (v ~= T or M ~= y)) then
    return false
  end
  if sendPacketRaw then
    local v = (d < T)
    pcall(sendPacketRaw, false, { ["type"] = 0, ["state"] = v and 48 or 32, ["x"] = T * 32, ["y"] = y * 32 })
    H(70)
  end
  return true
end
local function CW(T, y)
  local d = getObjectList or getObjects
  if not d then
    return false
  end
  local v, M = pcall(d)
  if v and type(M) == "table" then
    for d, v in pairs(M) do
      if v and v["pos"] then
        local d = math["floor"]((v["pos"]["x"] + 10) / 32)
        local M = math["floor"]((v["pos"]["y"] + 10) / 32)
        if d == T and M == y then
          return true
        end
      end
    end
  end
  return false
end
local function XW(T, y, d)
  if not T then
    return true
  end
  local v = (y >= T) and 1 or -1
  for T = T, y, v do
    if CW(T, d) then
      return false
    end
  end
  return true
end
local function QW(T, y)
  local d, v = e()
  local M = { 0, -1, 1, -2, 2, -3, 3, -4, 4, -5, 5, -6, 6, -7, 7, -8, 8, -9, 9, -10, 10 }
  for p, S in ipairs({ true, false }) do
    if (not S) and (d and (v and (d >= 1 and (d <= 97 and ((not CW(d, v)) and ZW(d + 1, v)))))) then
      return d + 1, v, d
    end
    for M, p in ipairs(M) do
      local A = y + p
      if A >= 2 and A <= 53 then
        if S and (d and (v == A and (d >= 1 and (d <= 97 and (not CW(d, A)))))) then
          local T = d + 1
          if ZW(T, A) and (not CW(T, A)) then
            return T, A, d
          end
        end
        for y = 0, -40, -1 do
          local M = T + y
          local p = M - 1
          if M >= 2 and (M <= 98 and (p >= 1 and (wW(p, A) and ZW(M, A)))) then
            local T = (not S) or ((not CW(p, A)) and ((not CW(M, A)) and ((v ~= A) or XW(d, p, A))))
            if T then
              return M, A, p
            end
          end
        end
        for y = 1, 40, 1 do
          local M = T + y
          local p = M + 1
          if M >= 1 and (M <= 97 and (p <= 98 and (wW(p, A) and ZW(M, A)))) then
            local T = (not S) or ((not CW(p, A)) and ((not CW(M, A)) and ((v ~= A) or XW(d, p, A))))
            if T then
              return M, A, p
            end
          end
        end
      end
    end
  end
  return nil, nil, nil
end
local function cW(T, y, d)
  local v = z(T)
  if v <= 0 then
    return true
  end
  local M = 0
  while P["running"] and (v > 0 and M < 200) do
    M = M + 1
    local p, S, A = QW(y, d)
    if not p then
      B("World Drop Full", "No empty tile found in the drop world!")
      return false
    end
    if not bW(A, S, p) then
      P["full_drop_tiles"][tostring(p) .. ("," .. tostring(S))] = true
    else
      local y = z(T)
      local d = math["min"](200, y)
      P["pending_drop_id"] = T
      P["pending_drop_amt"] = d
      local M = false
      if i["use_gl_drop"] and (growtopia and growtopia["confirmDropItem"]) then
        pcall(growtopia["confirmDropItem"], T, d)
        M = true
      elseif sendPacket then
        pcall(sendPacket, 2, string["format"]("action|drop\n|itemID|%d\n", T))
      end
      local A = 0
      local Y = y
      while P["running"] and A < 1400 do
        H(60)
        A = A + 60
        Y = z(T)
        if Y < y then
          break
        end
      end
      if Y >= y and (M and (sendPacket and P["running"])) then
        pcall(sendPacket, 2, string["format"]("action|drop\n|itemID|%d\n", T))
        A = 0
        while P["running"] and A < 1200 do
          H(60)
          A = A + 60
          Y = z(T)
          if Y < y then
            break
          end
        end
      end
      P["pending_drop_id"] = nil
      P["pending_drop_amt"] = nil
      if Y < y then
        P["items_dropped"] = P["items_dropped"] + (y - Y)
        H(i["delay_drop"])
        v = Y
      else
        P["full_drop_tiles"][tostring(p) .. ("," .. tostring(S))] = true
        v = Y
      end
    end
  end
  return (z(T) <= 0)
end
local function RW(T)
  if not n(T) then
    return true
  end
  local y = m()
  if y == "" then
    B("Error Drop", "You must be in a world to drop pack items!")
    V("Enter a world before starting Auto Buy Pack!")
    return false
  end
  TW(true)
  H(200)
  local d, v = e()
  d = tonumber(d) or 50
  v = tonumber(v) or 23
  local M = D()
  for T, y in ipairs(T) do
    if not P["running"] then
      break
    end
    local p = (M and M[y]) or z(y)
    if p > 0 then
      B("Auto Drop", string["format"]("Dropping %s x%d nearby", x(y), p))
      if not cW(y, d, v) then
        return false
      end
    end
  end
  return true
end
local function NW()
  l()
  FW()
  local T = r(i["pack_name"])
  if T == "" then
    B("Error Input", "Turn ON a pack toggle first!")
    V("Turn ON a pack toggle first!")
    return
  end
  local y = h(T)
  if
    y and (
      T:find("%s") ~= nil
      or tonumber(T) ~= nil
      or y["code"]:lower() == T:lower()
      or y["title"]:lower() == T:lower()
    )
  then
    T = y["code"]
    i["pack_name"] = y["code"]
    if editValue then
      pcall(editValue, "bp_pack_name", T)
    end
    if
      not P["user_edited_price"]
      and ((tonumber(y["price"]) or 0) > 0 and (i["pack_price"] == 2000 or i["pack_price"] == 0 or T ~= "world_lock"))
    then
      i["pack_price"] = math["floor"](tonumber(y["price"]))
      if editValue then
        pcall(editValue, "bp_pack_price", tostring(i["pack_price"]))
      end
    end
    if r(i["pack_item_ids_text"]) == "" and r(y["ids"] or "") ~= "" then
      i["pack_item_ids_text"] = r(y["ids"])
      if editValue then
        pcall(editValue, "bp_item_ids", i["pack_item_ids_text"])
      end
    end
  end
  local d = W(i["pack_item_ids_text"])
  if #d == 0 then
    i["auto_learn_items"] = true
  end
  local v = m()
  if v == "" then
    B("Error Input", "Enter a world before starting!")
    V("Enter a world before starting Auto Buy Pack!")
    return
  end
  P["packs_bought"] = 0
  P["items_dropped"] = 0
  P["full_drop_tiles"] = {}
  P["backpack_full_flag"] = false
  P["no_gems_flag"] = false
  P["unknown_pack_flag"] = false
  P["buy_server_confirmed"] = false
  P["last_store_msg"] = ""
  P["buying_now"] = false
  P["logged_store_block"] = false
  local M = (i["target_packs"] > 0) and (tostring(i["target_packs"]) .. " pack") or "Until Gems Run Out"
  G(string["format"]("Starting Direct Buy: pack=%s | price=%d | quantity=%s | world=%s", T, i["pack_price"], M, v))
  B("Buying World", "Buying and auto-dropping in " .. v)
  TW(true)
  local p = i["auto_drop"] and j(d)
  if p then
    if not RW(d) then
      return
    end
  end
  local S = nil
  local A = 0
  while P["running"] do
    if not E() then
      B("Waiting for Connection", "Connection lost. Waiting to reconnect...")
      H(1500)
    else
      local y = m()
      if y ~= v then
        if not yW(v, "", true) then
          H(1000)
        end
        TW(true)
      elseif i["target_packs"] > 0 and P["packs_bought"] >= i["target_packs"] then
        B("Target Reached", string["format"]("Purchased %d/%d packs.", P["packs_bought"], i["target_packs"]))
        break
      elseif
        i["pack_price"] > 0
        and (
          getGems
          and (function()
            local T, y = pcall(getGems)
            if T and (type(y) == "number" and y < i["pack_price"]) then
              B(
                "Not Enough Gems",
                string["format"]("Remaining gems (%d) are below the pack price (%d).", y, i["pack_price"])
              )
              return true
            end
            return false
          end)()
        )
      then
        break
      elseif P["no_gems_flag"] then
        B("Not Enough Gems", "The server reported insufficient gems.")
        break
      elseif P["unknown_pack_flag"] then
        B("Invalid Pack", "Debug code '" .. (T .. "' was rejected by the server!"))
        V("Pack code rejected by the server: " .. T)
        break
      else
        local y, M = false, nil
        if i["auto_drop"] then
          y, M = j(d)
        end
        if P["backpack_full_flag"] or y then
          P["backpack_full_flag"] = false
          B(
            "Auto Drop",
            M and (x(M) .. (" reached 200; auto-dropping nearby in " .. v))
              or "Inventory full; auto-dropping nearby in " .. v
          )
          if not RW(d) then
            break
          end
        else
          TW(true)
          local y = (i["target_packs"] > 0) and tostring(i["target_packs"]) or "Finished"
          B(
            "Buying Pack",
            string["format"]("Buying '%s' #%d/%s (%d Gems) in %s", T, P["packs_bought"] + 1, y, i["pack_price"], v)
          )
          local M = D()
          local p = nil
          if getGems then
            local T, y = pcall(getGems)
            if T and type(y) == "number" then
              p = y
            end
          end
          S = M
          P["last_store_msg"] = ""
          P["buy_server_confirmed"] = false
          P["buying_now"] = true
          P["suppress_store_until"] = MW() + 3
          if sendPacket then
            pcall(sendPacket, 2, "action|buy\nitem|" .. (T .. "\n"))
          end
          local Y = false
          local F = 0
          local w = math["max"](500, tonumber(i["delay_buy"]) or 1000)
          while P["running"] and F < math["max"](w, 1300) do
            H(100)
            F = F + 100
            if P["no_gems_flag"] or P["unknown_pack_flag"] or P["backpack_full_flag"] then
              break
            end
            local T = k(M, d)
            local y = nil
            if getGems then
              local T, d = pcall(getGems)
              if T and type(d) == "number" then
                y = d
              end
            end
            local v = T
            if not v then
              local T = D()
              for T, y in pairs(T) do
                if y > (M[T] or 0) then
                  v = true
                  break
                end
              end
            end
            if (p and (y and y < p)) or v or P["buy_server_confirmed"] then
              Y = true
              if F >= w then
                break
              end
            end
          end
          if Y then
            A = 0
            P["packs_bought"] = P["packs_bought"] + 1
            K()
          elseif P["no_gems_flag"] or P["unknown_pack_flag"] or P["backpack_full_flag"] then
          else
            A = A + 1
            G(string["format"]("Purchase #%d not confirmed (%d/4). Message: %s", A, 4, tostring(P["last_store_msg"])))
            if A >= 4 then
              local y = (P["last_store_msg"] ~= "") and P["last_store_msg"]
                or ("Store did not respond to code '" .. (T .. "'"))
              B("Pack Purchase Failed", y)
              V("Pack purchase failed: " .. y)
              break
            else
              H(600)
            end
          end
          P["buying_now"] = false
        end
      end
    end
  end
  if P["running"] and P["packs_bought"] > 0 then
    H(650)
    if S then
      k(S, d)
    end
  end
  if P["running"] and n(d) then
    B("Final Drop", "Dropping all remaining purchased items in " .. v)
    RW(d)
  end
  TW(false)
  if P["running"] then
    V(
      string["format"]("Auto Buy selesai! Purchased: %d pack | Dropped: %d item", P["packs_bought"], P["items_dropped"])
    )
  end
end
local function rW(T)
  if not editToggle then
    return
  end
  P["ignore_power_event"] = true
  pcall(editToggle, "bp_run_power", T == true)
  P["ignore_power_event"] = false
end
local function OW()
  if P["running"] then
    return
  end
  FW()
  P["running"] = true
  K()
  local function T()
    local T, y = pcall(NW)
    if not T then
      B("Error", tostring(y))
      V("Error Buy Pack: " .. tostring(y))
    end
    P["running"] = false
    TW(false)
    rW(false)
    K()
  end
  U(T)
end
local function oW()
  P["running"] = false
  TW(false)
  rW(false)
  B("Stopped", "Stopped by user.")
end
local function iW(T)
  local y = ((tostring(T["title"] or "") .. (" " .. tostring(T["code"] or "")))):lower()
  if
    y:find("lock")
    or y:find("door")
    or y:find("vend")
    or y:find("jammer")
    or y:find("upgrade_backpack")
    or y:find("clothes")
    or y:find("checkout")
    or y:find("change_addr")
    or y:find("antigravity")
    or y:find("building_blocks")
    or y:find("advertiser")
  then
    return 1
  elseif
    y:find("seed")
    or y:find("spray")
    or y:find("splice")
    or y:find("farm")
    or y:find("weather")
    or y:find("blast")
  then
    return 2
  elseif
    y:find("surg")
    or y:find("fish")
    or y:find("crime")
    or y:find("silkwor")
    or y:find("geiger")
    or y:find("zombie")
    or y:find("boo_pack")
    or y:find("ecto")
    or y:find("ghost")
    or y:find("chem")
    or y:find("science")
  then
    return 3
  end
  return 4
end
local PW = {
  { ["code"] = "ssp_10_pack", ["label"] = "Small Seed Pack Collection" },
  { ["code"] = "rare_seed", ["label"] = "Rare Seed Pack" },
  { ["code"] = "city_pack", ["label"] = "City Pack" },
  { ["code"] = "science_pack", ["label"] = "Mad Science Kit" },
  { ["code"] = "change_addr", ["label"] = "Change of Address" },
  { ["code"] = "door_mover", ["label"] = "Door Mover" },
  { ["code"] = "surg_starter_pack", ["label"] = "Surgery Starter Pack" },
  { ["code"] = "surg_value_pack", ["label"] = "M Surg Pack" },
  { ["code"] = "fishin_pack", ["label"] = "Fishin' Pack" },
  { ["code"] = "crime_wave", ["label"] = "Crime Wave Pack" },
}
local VW = false
local function GW(T)
  if not editToggle then
    return
  end
  VW = true
  for y, d in ipairs(PW) do
    if N[d["code"]] then
      pcall(editToggle, "bp_pack_select_" .. tostring(y), y == T)
    end
  end
  VW = false
end
local function HW()
  if not (UserInterface and (UserInterface["new"] and Y)) then
    return
  end
  local T = UserInterface["new"]("ZS AUTO BUY PACK", "ShoppingCart")
  T:addLabelApp("* ZS AUTO BUY PACK *", "ShoppingCart")
  T:addTooltip(
    "* AUTO BUY PACK *",
    "SELECT A PACK: Turn ON one pack toggle below. Only one pack can be selected at a time.\n\nQUANTITY: Choose how many packs you want to buy.\n\nSTART / STOP: Turn AUTO BUY PACK ON at the top to start buying the selected pack. Turn it OFF to stop.\n\nAUTO DROP: Each tracked item is dropped automatically when its inventory count reaches 200. If a drop tile is full, the script searches nearby tiles and continues there. Buying and dropping happen in your current world.",
    "Info",
    true
  )
  T:addDivider()
  T:addToggle("AUTO BUY PACK", false, "bp_run_power", true)
  T:addToggle("AUTO DROP AT 200", false, "bp_auto_drop", true)
  T:addDisplayList("Status", "[]", "bp_status_list")
  T:addDivider()
  T:addLabelApp("SELECT ONE PACK TO BUY", "ShoppingCart")
  local y = nil
  for d, v in ipairs(PW) do
    local M = N[v["code"]]
    if M then
      local M = ((tostring(i["pack_name"])):lower() == v["code"]:lower())
      if M then
        y = d
      end
      T:addToggle(v["label"], M, "bp_pack_select_" .. tostring(d), true)
    end
  end
  T:addDivider()
  T:addInputInt("Number of Packs", tostring(i["target_packs"]), "Quantity", "1", "Layers", "bp_target_packs")
  pcall(Y, T:generateJSON(), "ZS")
  K()
  if runCoroutine then
    U(function()
      H(450)
      K()
    end)
  end
end
local UW = {}
local function KW(T, y)
  i["shop_search"] = r(T)
  P["last_seen_search_gl"] = t("bp_shop_search")
  local d = J() or q(i["shop_search"])
  local v = i["shop_search"]:lower()
  if v ~= "" and (#d == 1 or (d[1] and (d[1]["code"]:lower() == v or d[1]["title"]:lower() == v))) then
    u(d[1])
  elseif y then
    V(string["format"]("Found %d packs for '%s'!", #d, i["shop_search"]))
  end
end
local function BW()
  local T = t("bp_shop_search")
  if T ~= nil and T ~= P["last_seen_search_gl"] then
    P["last_seen_search_gl"] = T
    return T
  end
  return i["shop_search"]
end
function OnValue(T, y, d)
  if type(y) ~= "string" then
    return
  end
  if y:sub(1, 7) == "bp_btn_" then
    local T = os and (os["clock"] and os["clock"]()) or 0
    if UW[y] and (T - UW[y]) < 0.25 then
      return
    end
    UW[y] = T
  end
  if y == "bp_run_power" then
    if P["ignore_power_event"] then
      return
    end
    local T = (d == true or d == 1 or d == "true" or d == "1")
    if T == P["running"] then
      return
    end
    if T then
      OW()
    else
      oW()
    end
  elseif y:sub(1, 15) == "bp_pack_select_" then
    if VW then
      return
    end
    local T = tonumber(y:sub(16))
    local v = T and PW[T] or nil
    local M = v and N[v["code"]] or nil
    local p = (d == true or d == 1 or d == "true" or d == "1")
    if p and (M and R[M]) then
      GW(T)
      u(R[M])
    elseif not p and (v and (tostring(i["pack_name"])):lower() == v["code"]:lower()) then
      i["pack_name"] = ""
      i["pack_item_ids_text"] = ""
      if editValue then
        pcall(editValue, "bp_pack_name", "")
        pcall(editValue, "bp_item_ids", "")
      end
      B("No Pack Selected", "Turn ON one pack toggle before starting.")
    end
  elseif y:sub(1, 6) == "bp_dp_" then
    local T = tonumber(y:sub(7))
    if T and R[T] then
      u(R[T])
    end
  elseif y == "bp_shop_search" then
    KW(d, false)
  elseif y == "bp_btn_filter_list" then
    FW()
    KW(BW(), true)
  elseif y == "bp_btn_open_search_popup" then
    FW()
    i["shop_search"] = r(BW())
    J()
    I(i["shop_search"], 1)
  elseif y == "bp_pack_name" then
    local T = r(d)
    local y = (T:lower() ~= (r(i["pack_name"])):lower())
    if y then
      P["user_edited_price"] = false
    end
    i["pack_name"] = T
    if y and T ~= "" then
      local y = h(T)
      if y and (y["code"]:lower() == T:lower() or y["title"]:lower() == T:lower() or tonumber(T) ~= nil) then
        u(y)
      end
    end
  elseif y == "bp_auto_learn" then
    i["auto_learn_items"] = (d == true or d == 1 or d == "true" or d == "1")
  elseif y == "bp_item_ids" then
    i["pack_item_ids_text"] = r(d)
  elseif y == "bp_pack_price" then
    local T = tonumber(((tostring(d)):gsub("[,%s]", "")))
    if T and T >= 0 then
      i["pack_price"] = math["floor"](T)
      P["user_edited_price"] = true
    end
    K()
  elseif y == "bp_target_packs" then
    local T = tonumber(((tostring(d)):gsub("[,%s]", "")))
    if T and T >= 0 then
      i["target_packs"] = math["floor"](T)
      P["user_set_target"] = (i["target_packs"] > 0)
    end
    K()
  elseif y == "bp_auto_drop" then
    i["auto_drop"] = (d == true or d == 1 or d == "true" or d == "1")
    C({ ["auto_drop"] = i["auto_drop"] })
    K()
  elseif y == "bp_use_gl_drop" then
    i["use_gl_drop"] = (d == true or d == 1 or d == "true" or d == "1")
  elseif y == "bp_anti_retake" then
    i["anti_retake"] = (d == true or d == 1 or d == "true" or d == "1")
  elseif y == "bp_btn_set_drop_pos" then
    local T, y = e()
    if T and y then
      i["drop_anchor_x"] = T
      i["drop_anchor_y"] = y
      V(string["format"]("Drop start position set to (%d, %d)", T, y))
    else
      V("Enter a world before setting the drop position!")
    end
  elseif y == "bp_btn_reset_drop_pos" then
    i["drop_anchor_x"] = 0
    i["drop_anchor_y"] = 0
    V("Drop position reset to automatic (0,0)")
  elseif y == "bp_max_stacks" then
    local T = tonumber(d)
    if T then
      i["max_stacks_per_tile"] = math["max"](5, math["min"](19, math["floor"](T)))
    end
  elseif y == "bp_delay_buy" then
    local T = tonumber(d)
    if T then
      i["delay_buy"] = math["max"](500, math["floor"](T))
    end
  elseif y == "bp_delay_drop" then
    local T = tonumber(d)
    if T then
      i["delay_drop"] = math["max"](200, math["floor"](T))
    end
  elseif y == "bp_delay_warp" then
    local T = tonumber(d)
    if T then
      i["delay_warp"] = math["max"](2500, math["floor"](T))
    end
  end
  C(i)
end
if M then
  pcall(M, SW, "onvariant")
  pcall(M, AW, "onsendpacket")
  pcall(M, YW, "onsendpacketraw")
  P["hooks_installed"] = true
end
if applyHook then
  pcall(applyHook)
end
pcall(HW)
M(function(T, y, d)
  OnValue(T, y, d)
end, "onValue")
if type(applyHook) == "function" then
  pcall(applyHook)
end
