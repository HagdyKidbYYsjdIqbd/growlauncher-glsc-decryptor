-- =============================================================
-- Auto Cook By Salsz V1.7
-- Command: /cook
-- Deadline: 10 Oktober 2026, 23:00 WIB (Server Time)
-- Fix: Absolute per-oven timing (anti-drift multi-oven)
-- Heat: LOW (mutlak)
-- =============================================================

local DEADLINE_CONFIG = {
    year = 2026, month = 10, day = 12,
    hour = 2, min = 0, sec = 0, utc_offset = 7,
}

local function CalculateDeadline()
    local hourUTC = DEADLINE_CONFIG.hour - DEADLINE_CONFIG.utc_offset
    local dayUTC = DEADLINE_CONFIG.day
    if hourUTC < 0 then hourUTC = hourUTC + 24; dayUTC = dayUTC - 1 end
    return os.time({
        year = DEADLINE_CONFIG.year, month = DEADLINE_CONFIG.month,
        day = dayUTC, hour = hourUTC,
        min = DEADLINE_CONFIG.min, sec = DEADLINE_CONFIG.sec,
    })
end

local DEADLINE_TS = CalculateDeadline()

local function CheckDeadline()
    local ok, serverTimeMs = pcall(function() return getTime() end)
    local now = (ok and serverTimeMs) and math.floor(serverTimeMs / 1000) or os.time()
    local remaining = DEADLINE_TS - now
    if remaining <= 0 then return false, 0 end
    return true, remaining
end

local function FormatTime(seconds)
    if seconds <= 0 then return "EXPIRED" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    local parts = {}
    if days > 0 then table.insert(parts, days .. "d") end
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end
    if secs > 0 or #parts == 0 then table.insert(parts, secs .. "s") end
    return table.concat(parts, " ")
end

local function FormatDeadline()
    return string.format("%02d/%02d/%04d %02d:%02d WIB",
        DEADLINE_CONFIG.day, DEADLINE_CONFIG.month,
        DEADLINE_CONFIG.year, DEADLINE_CONFIG.hour, DEADLINE_CONFIG.min)
end

-- =============================================================
-- STATE
-- =============================================================

local SLS = {
    selectedRecipe = "BBQ Bacon Burger",
    ovenCount = 1,
    maxTilePlayer = 2,
    batchCount = 1,
    cookDelay = 500,       -- delay antar aksi (ms)
    batchDelay = 6000,
    heartbeat = true,
    running = false,
    status = "IDLE",
    foundOvens = {},
    tempRecipe = "",
}

local function logS(msg) log("[Cook] " .. tostring(msg)) end

local function escapeDialog(s)
    s = tostring(s or "")
    s = s:gsub("|", "/"):gsub("\n", " ")
    return s
end

local function sendDialog(body) growtopia.sendDialog(body) end

-- Ambil waktu server dalam ms (untuk timing absolut)
local function GetTimeMs()
    local ok, t = pcall(function() return getTime() end)
    if ok and type(t) == "number" and t > 0 then return t end
    return os.time() * 1000
end

-- =============================================================
-- ID
-- =============================================================

local OvenID = 4618
local PunchID = 18

local ITEMS = {
    Blueberry = 196, Apple = 676, WaterBucket = 822, Milk = 868,
    Egg = 874, Wheat = 880, SugarCane = 954, Dough = 956, Tomato = 962,
    Salsa = 4560, Flour = 4562, Lettuce = 4564, SaltBlock = 4566,
    Salt = 4568, Pepper = 4570, Sugar = 4572, Beef = 4578,
    GroundBeef = 4580, Bacon = 4586, ChickenMeat = 4588,
    Onion = 4602, BakingChocolate = 4610, Marshmallow = 4624,
    PineappleSlice = 4764, Cherry = 4766, CoconutMilk = 7054,
    GroundNutmeg = 7462, Honey = 3836, Butter = 4760,
    GingerbreadDough = 5416, ChocolateSprinkles = 5376,
    GingerbreadBlock = 5348, Potato = 4784, FishChunk = 3468,
    GreenBeer = 4786, Avocado = 4672, Lemon = 4666,
    CornMeal = 4670, CrushedIce = 4704, Caramel = 6974,
    SwissCheese = 4658, OrangeJuice = 4710, PineappleDaiquiri = 7018,
    PumpkinBlock = 964, RottenEgg = 614, SpacePoop = 8394,
    Gruel = 4410, RottingSeaGoo = 8392, SeaUrchin = 8390,
    ChronoFluid = 7186, SprigOfMint = 3402, PrimordialSoup = 8236,
    BurntSlime = 8396, PutridGas = 8398, Cosmic5Spice = 7188,
    ZombieBrain = 4450, Slime = 978, HabaneroPepper = 712,
    EasterEgg = 7520, BeatrootPuree = 6426, Rice = 3472,
}

local RESULT_ID = {
    ["BBQ Bacon Burger"] = 4598, ["Berry Crepes"] = 4596,
    ["Apple Strudel"] = 4594, ["Gingerbread Cookie"] = 5416,
    ["Eggs Benedict"] = 4592, ["Arroz Con Pollo"] = 4604,
    ["Beer-Battered Fish & Chips"] = 4600, ["Chips And Guacamole"] = 4560,
    ["Chocolate Bunny"] = 4610, ["Chocolate Easter Bilby"] = 4610,
    ["Coconut Tart"] = 7056, ["Composer's Cookie"] = 5376,
    ["Deep-Fried Tropical Ice Cream"] = 4704, ["Eggnog"] = 868,
    ["Festering Urchin & Poop Pie"] = 8394, ["Flashback Flan"] = 7186,
    ["Gemonade"] = 4666, ["Gluton's Gazpacho"] = 8236,
    ["Growlectables"] = 6974, ["Homemade Fish Taco"] = 4592,
    ["Hot Chocolate"] = 4610, ["Magnifico Carne Guacamole"] = 4580,
    ["Pineapple Turnover"] = 4768, ["Pumpkin Pie"] = 964,
    ["Putrid Gas Blood Maggot Crepes"] = 8398,
    ["Rotting Fish Guts Club Sandwich"] = 8392,
    ["Skill Spice"] = 7188, ["Alien Bloodied Brains Strudel"] = 8394,
    ["Detective Butter Lamb"] = 7054, ["Failed Butter Lamb"] = 7054,
}

-- =============================================================
-- DATABASE 30 RESEP
-- =============================================================

local Recipes = {
    ["BBQ Bacon Burger"] = { punch_time = 66, bahan = {
        {nama = "Ground Beef", id = ITEMS.GroundBeef, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 6.3},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 16.3},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 36.3},
        {nama = "Lettuce", id = ITEMS.Lettuce, timing = 65},
    }},
    ["Berry Crepes"] = { punch_time = 60, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 0},
        {nama = "Milk", id = ITEMS.Milk, timing = 26.7},
        {nama = "Blueberry", id = ITEMS.Blueberry, timing = 40},
    }},
    ["Apple Strudel"] = { punch_time = 83, bahan = {
        {nama = "Apple", id = ITEMS.Apple, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 23.3},
        {nama = "Egg", id = ITEMS.Egg, timing = 23.3},
    }},
    ["Gingerbread Cookie"] = { punch_time = 80, bahan = {
        {nama = "Gingerbread Dough", id = ITEMS.GingerbreadDough, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 20},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 30},
        {nama = "Chocolate Sprinkles", id = ITEMS.ChocolateSprinkles, timing = 63},
    }},
    ["Eggs Benedict"] = { punch_time = 60, bahan = {
        {nama = "Dough", id = ITEMS.Dough, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 0},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 10},
        {nama = "Milk", id = ITEMS.Milk, timing = 26},
    }},
    ["Arroz Con Pollo"] = { punch_time = 100, bahan = {
        {nama = "Rice", id = ITEMS.Rice, timing = 0},
        {nama = "Onion", id = ITEMS.Onion, timing = 33.7},
        {nama = "Chicken Meat", id = ITEMS.ChickenMeat, timing = 33.7},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 70},
    }},
    ["Beer-Battered Fish & Chips"] = { punch_time = 120, bahan = {
        {nama = "Green Beer", id = ITEMS.GreenBeer, timing = 0},
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Potato", id = ITEMS.Potato, timing = 0},
        {nama = "Fish Chunk", id = ITEMS.FishChunk, timing = 87},
    }},
    ["Chips And Guacamole"] = { punch_time = 66, bahan = {
        {nama = "Salsa", id = ITEMS.Salsa, timing = 0},
        {nama = "Water Bucket", id = ITEMS.WaterBucket, timing = 0},
        {nama = "Corn Meal", id = ITEMS.CornMeal, timing = 0},
        {nama = "Lemon", id = ITEMS.Lemon, timing = 65},
        {nama = "Avocado", id = ITEMS.Avocado, timing = 65},
    }},
    ["Chocolate Bunny"] = { punch_time = 60, bahan = {
        {nama = "Egg", id = ITEMS.Egg, timing = 0},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 10},
        {nama = "Chocolate Sprinkles", id = ITEMS.ChocolateSprinkles, timing = 44},
        {nama = "Marshmallow", id = ITEMS.Marshmallow, timing = 50},
    }},
    ["Chocolate Easter Bilby"] = { punch_time = 60, bahan = {
        {nama = "Easter Egg", id = ITEMS.EasterEgg, timing = 0},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 10},
        {nama = "Chocolate Sprinkles", id = ITEMS.ChocolateSprinkles, timing = 44},
        {nama = "Marshmallow", id = ITEMS.Marshmallow, timing = 50},
    }},
    ["Coconut Tart"] = { punch_time = 100, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Rice", id = ITEMS.Rice, timing = 0},
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 27},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 50},
        {nama = "Cherry", id = ITEMS.Cherry, timing = 90},
    }},
    ["Composer's Cookie"] = { punch_time = 75, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Beat-root Puree", id = ITEMS.BeatrootPuree, timing = 0},
        {nama = "Chocolate Sprinkles", id = ITEMS.ChocolateSprinkles, timing = 58},
        {nama = "Cherry", id = ITEMS.Cherry, timing = 65},
    }},
    ["Deep-Fried Tropical Ice Cream"] = { punch_time = 83, bahan = {
        {nama = "Pineapple Slice", id = ITEMS.PineappleSlice, timing = 0},
        {nama = "Orange Juice", id = ITEMS.OrangeJuice, timing = 43},
        {nama = "Milk", id = ITEMS.Milk, timing = 50},
        {nama = "Blueberry", id = ITEMS.Blueberry, timing = 63},
        {nama = "Crushed Ice", id = ITEMS.CrushedIce, timing = 82},
    }},
    ["Eggnog"] = { punch_time = 73, bahan = {
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 13},
        {nama = "Milk", id = ITEMS.Milk, timing = 40},
        {nama = "Ground Nutmeg", id = ITEMS.GroundNutmeg, timing = 72},
        {nama = "Crushed Ice", id = ITEMS.CrushedIce, timing = 72},
    }},
    ["Festering Urchin & Poop Pie"] = { punch_time = 106, bahan = {
        {nama = "Space Poop", id = ITEMS.SpacePoop, timing = 0},
        {nama = "Gruel", id = ITEMS.Gruel, timing = 53},
        {nama = "Rotting Sea Goo", id = ITEMS.RottingSeaGoo, timing = 61},
        {nama = "Sea Urchin", id = ITEMS.SeaUrchin, timing = 69},
    }},
    ["Flashback Flan"] = { punch_time = 60, bahan = {
        {nama = "Egg", id = ITEMS.Egg, timing = 0},
        {nama = "Chrono Fluid", id = ITEMS.ChronoFluid, timing = 10},
        {nama = "Milk", id = ITEMS.Milk, timing = 26},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 29},
    }},
    ["Gemonade"] = { punch_time = 40, bahan = {
        {nama = "Water Bucket", id = ITEMS.WaterBucket, timing = 0},
        {nama = "Orange Juice", id = ITEMS.OrangeJuice, timing = 0},
        {nama = "Lemon", id = ITEMS.Lemon, timing = 38},
        {nama = "Sprig of Mint", id = ITEMS.SprigOfMint, timing = 38},
    }},
    ["Gluton's Gazpacho"] = { punch_time = 90, bahan = {
        {nama = "Primordial Soup", id = ITEMS.PrimordialSoup, timing = 0},
        {nama = "Onion", id = ITEMS.Onion, timing = 23},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 60},
        {nama = "Lemon", id = ITEMS.Lemon, timing = 89},
    }},
    ["Growlectables"] = { punch_time = 103, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Caramel", id = ITEMS.Caramel, timing = 0},
        {nama = "Pineapple Slice", id = ITEMS.PineappleSlice, timing = 20},
        {nama = "Blueberry", id = ITEMS.Blueberry, timing = 83},
        {nama = "Cherry", id = ITEMS.Cherry, timing = 93},
    }},
    ["Homemade Fish Taco"] = { punch_time = 60, bahan = {
        {nama = "Salsa", id = ITEMS.Salsa, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 0},
        {nama = "Fish Chunk", id = ITEMS.FishChunk, timing = 26.5},
        {nama = "Swiss Cheese", id = ITEMS.SwissCheese, timing = 49},
        {nama = "Lettuce", id = ITEMS.Lettuce, timing = 57},
    }},
    ["Hot Chocolate"] = { punch_time = 50, bahan = {
        {nama = "Water Bucket", id = ITEMS.WaterBucket, timing = 0},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 0},
        {nama = "Milk", id = ITEMS.Milk, timing = 16},
        {nama = "Marshmallow", id = ITEMS.Marshmallow, timing = 40},
    }},
    ["Magnifico Carne Guacamole"] = { punch_time = 66, bahan = {
        {nama = "Ground Beef", id = ITEMS.GroundBeef, timing = 0},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 16},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 36},
        {nama = "Lemon", id = ITEMS.Lemon, timing = 65},
    }},
    ["Pineapple Turnover"] = { punch_time = 83, bahan = {
        {nama = "Pineapple Slice", id = ITEMS.PineappleSlice, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 23},
        {nama = "Pineapple Daiquiri", id = ITEMS.PineappleDaiquiri, timing = 43},
        {nama = "Cherry", id = ITEMS.Cherry, timing = 73},
    }},
    ["Pumpkin Pie"] = { punch_time = 81, bahan = {
        {nama = "Gingerbread Dough", id = ITEMS.GingerbreadDough, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 20},
        {nama = "Milk", id = ITEMS.Milk, timing = 46},
        {nama = "Pumpkin Block", id = ITEMS.PumpkinBlock, timing = 54},
        {nama = "Ground Nutmeg", id = ITEMS.GroundNutmeg, timing = 80},
    }},
    ["Putrid Gas Blood Maggot Crepes"] = { punch_time = 33, bahan = {
        {nama = "Milk", id = ITEMS.Milk, timing = 0},
        {nama = "Rotten Egg", id = ITEMS.RottenEgg, timing = 3},
        {nama = "Burnt Slime", id = ITEMS.BurntSlime, timing = 10},
        {nama = "Putrid Gas", id = ITEMS.PutridGas, timing = 32},
    }},
    ["Rotting Fish Guts Club Sandwich"] = { punch_time = 45, bahan = {
        {nama = "Rotting Sea Goo", id = ITEMS.RottingSeaGoo, timing = 0},
        {nama = "Fish Chunk", id = ITEMS.FishChunk, timing = 12},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 15},
        {nama = "Burnt Slime", id = ITEMS.BurntSlime, timing = 22},
    }},
    ["Skill Spice"] = { punch_time = 116, bahan = {
        {nama = "Cosmic 5-Spice", id = ITEMS.Cosmic5Spice, timing = 0},
        {nama = "Rice", id = ITEMS.Rice, timing = 16},
        {nama = "Onion", id = ITEMS.Onion, timing = 50},
        {nama = "Milk", id = ITEMS.Milk, timing = 83},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 86},
    }},
    ["Alien Bloodied Brains Strudel"] = { punch_time = 106, bahan = {
        {nama = "Space Poop", id = ITEMS.SpacePoop, timing = 0},
        {nama = "Zombie Brain", id = ITEMS.ZombieBrain, timing = 19.7},
        {nama = "Slime", id = ITEMS.Slime, timing = 49.7},
        {nama = "Putrid Gas", id = ITEMS.PutridGas, timing = 105},
    }},
    ["Detective Butter Lamb"] = { punch_time = 72.5, bahan = {
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 0},
        {nama = "Corn Meal", id = ITEMS.CornMeal, timing = 6},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 22.5},
        {nama = "Milk", id = ITEMS.Milk, timing = 39.5},
        {nama = "Habanero Pepper", id = ITEMS.HabaneroPepper, timing = 62},
    }},
    ["Failed Butter Lamb"] = { punch_time = 72.5, bahan = {
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 0},
        {nama = "Corn Meal", id = ITEMS.CornMeal, timing = 6},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 22.5},
        {nama = "Milk", id = ITEMS.Milk, timing = 39.5},
        {nama = "Habanero Pepper", id = ITEMS.HabaneroPepper, timing = 62},
    }},
}

local RecipeList = {
    "BBQ Bacon Burger", "Berry Crepes", "Apple Strudel", "Gingerbread Cookie",
    "Eggs Benedict", "Arroz Con Pollo", "Beer-Battered Fish & Chips",
    "Chips And Guacamole", "Chocolate Bunny", "Chocolate Easter Bilby",
    "Coconut Tart", "Composer's Cookie", "Deep-Fried Tropical Ice Cream",
    "Eggnog", "Festering Urchin & Poop Pie", "Flashback Flan",
    "Gemonade", "Gluton's Gazpacho", "Growlectables", "Homemade Fish Taco",
    "Hot Chocolate", "Magnifico Carne Guacamole", "Pineapple Turnover",
    "Pumpkin Pie", "Putrid Gas Blood Maggot Crepes",
    "Rotting Fish Guts Club Sandwich", "Skill Spice",
    "Alien Bloodied Brains Strudel", "Detective Butter Lamb", "Failed Butter Lamb"
}

-- =============================================================
-- DIALOG: EXPIRED
-- =============================================================

local function expiredDialog()
    local dialog = [[
set_default_color|`o
set_bg_color|40,10,10,250
set_border_color|200,50,50,255
add_label_with_icon|big|`wSCRIPT EXPIRED``|left|4618|
add_spacer|small|
add_textbox|`4Masa aktif script udah HABIS!``|left|
add_spacer|small|
add_textbox|`7Deadline: `w]] .. FormatDeadline() .. [[``|left|
add_textbox|`7Status: `4EXPIRED``|left|
add_textbox|`7Server Time Verified``|left|
add_spacer|small|
add_textbox|`7Contact admin untuk info update:``|left|
add_textbox|`5Discord: `wsalsz``|left|
add_spacer|small|
add_button|sls_close|CLOSE|noflags|0|0|
end_dialog|sls_expired|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

-- =============================================================
-- DIALOG: MAIN MENU
-- =============================================================

local function mainDialog()
    local isValid, remaining = CheckDeadline()
    if not isValid then expiredDialog(); return end
    local statusText = SLS.running and "`2RUNNING``" or "`4STOPPED``"
    local recipeID = RESULT_ID[SLS.selectedRecipe] or 4618
    local dialog = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`wAuto Cook``|left|4618|
add_textbox|`7Script By: `wSalsz``|left|
add_textbox|`7Status: ]] .. statusText .. [[``|left|
add_textbox|`7Deadline: `w]] .. FormatDeadline() .. [[``|left|
add_textbox|`7Time Left: `2]] .. FormatTime(remaining) .. [[``|left|
add_spacer|small|
add_textbox|`wResep Aktif:``|left|
add_label_with_icon|small|`2]] .. escapeDialog(SLS.selectedRecipe) .. [[``|left|]] .. recipeID .. [[|
add_spacer|small|
add_textbox|`7Oven: `w]] .. SLS.ovenCount .. [[`` `7| Radius: `w]] .. SLS.maxTilePlayer .. [[``|left|
add_textbox|`7Heat: `wLOW (Absolute)``|left|
add_spacer|small|
add_button|sls_rmenu|SELECT RESEP|noflags|0|0|
add_button|sls_setting|SETTING|noflags|0|0|
add_spacer|small|
add_button|sls_start|START COOKING|noflags|0|0|
add_button|sls_stop|STOP|noflags|0|0|
add_spacer|small|
add_textbox|`7Total Resep: `w]] .. #RecipeList .. [[``|left|
end_dialog|sls_main|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

-- =============================================================
-- DIALOG: RECIPE MENU
-- =============================================================

local function recipeMenuDialog()
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end
    local dialog = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`wSELECT RESEP``|left|4618|
add_textbox|`7Pilih resep:``|left|
add_spacer|small|
]]
    for i, recipeName in ipairs(RecipeList) do
        local checked = (recipeName == SLS.selectedRecipe) and "1" or "0"
        dialog = dialog .. "add_checkbox|sls_recipe_" .. i .. "|`w" .. escapeDialog(recipeName) .. "``|" .. checked .. "|\n"
    end
    dialog = dialog .. [[
add_spacer|small|
add_button|sls_pick_confirm|SELECT RECIPE|noflags|0|0|
add_button|sls_main|BACK|noflags|0|0|
add_button|sls_close|CLOSE|noflags|0|0|
end_dialog|sls_rmenu|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

-- =============================================================
-- DIALOG: RECIPE DETAIL
-- =============================================================

local function recipeDetailDialog(recipeName)
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end
    SLS.tempRecipe = recipeName
    local recipe = Recipes[recipeName]
    if not recipe then recipeMenuDialog(); return end
    local recipeID = RESULT_ID[recipeName] or 4618
    local detail = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`w]] .. escapeDialog(recipeName) .. [[``|left|]] .. recipeID .. [[|
add_spacer|small|
add_textbox|`wBAHAN & TIMING:``|left|
]]
    for i, bahan in ipairs(recipe.bahan) do
        detail = detail .. "add_label_with_icon|small|`7" .. i .. ". " .. escapeDialog(bahan.nama) .. " -> " .. bahan.timing .. "s``|left|" .. bahan.id .. "|\n"
    end
    detail = detail .. [[
add_spacer|small|
add_textbox|`wPUNCH: `2]] .. recipe.punch_time .. [[s``|left|
add_textbox|`wHEAT: `2LOW``|left|
add_spacer|small|
add_button|sls_confirm|SELECT RECIPE|noflags|0|0|
add_button|sls_rmenu|BACK|noflags|0|0|
add_button|sls_close|CLOSE|noflags|0|0|
end_dialog|sls_rdetail|Close||
add_quick_exit|
]]
    sendDialog(detail)
end

-- =============================================================
-- DIALOG: SETTING
-- =============================================================

local function settingDialog()
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end
    local dialog = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`wSETTING``|left|4618|
add_spacer|small|
add_label_with_icon|small|`wJUMLAH OVEN: `7(now: ]] .. SLS.ovenCount .. [[)``|left|4618|
add_button|sls_o1|1|noflags|0|0|
add_button|sls_o2|2|noflags|0|0|
add_button|sls_o3|3|noflags|0|0|
add_button|sls_o4|4|noflags|0|0|
add_button|sls_o5|5|noflags|0|0|
add_button|sls_o6|6|noflags|0|0|
add_button|sls_o7|7|noflags|0|0|
add_button|sls_o8|8|noflags|0|0|
add_spacer|small|
add_label_with_icon|small|`wRADIUS SCAN: `7(now: ]] .. SLS.maxTilePlayer .. [[)``|left|4618|
add_button|sls_t2|2|noflags|0|0|
add_button|sls_t3|3|noflags|0|0|
add_button|sls_t4|4|noflags|0|0|
add_button|sls_t5|5|noflags|0|0|
add_spacer|small|
add_label_with_icon|small|`wBATCH: `7(now: ]] .. SLS.batchCount .. [[)``|left|4618|
add_button|sls_b1|1|noflags|0|0|
add_button|sls_b5|5|noflags|0|0|
add_button|sls_b10|10|noflags|0|0|
add_button|sls_b20|20|noflags|0|0|
add_spacer|small|
add_label_with_icon|small|`wHEAT: `2LOW `7(Absolute)``|left|4618|
add_spacer|small|
add_button|sls_main|BACK|noflags|0|0|
add_button|sls_close|CLOSE|noflags|0|0|
end_dialog|sls_setting|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

-- =============================================================
-- SCAN OVEN
-- =============================================================

local function ScanOven()
    local p = getLocal()
    if not p then return false end
    local px = math.floor(p.posX / 32)
    local py = math.floor(p.posY / 32)
    SLS.foundOvens = {}
    local radius = SLS.maxTilePlayer
    for dy = -radius, radius do
        for dx = -radius, radius do
            local tx, ty = px + dx, py + dy
            local tile = getTile(tx, ty)
            if tile and tile.fg == OvenID then
                table.insert(SLS.foundOvens, {x = tx, y = ty})
            end
        end
    end
    return #SLS.foundOvens > 0
end

-- =============================================================
-- COOKING LOGIC (ABSOLUTE TIMING)
-- =============================================================

local function OvenDelay() sleep(SLS.cookDelay) end

local function PlaceItem(itemID, tileX, tileY)
    local p = getLocal()
    if not p then return end
    SendPacketRaw(false, {
        type = 3, value = itemID,
        px = tileX, py = tileY,
        x = p.posX, y = p.posY
    })
end

-- Heat LOW mutlak
local function SetHeatLevel(tileX, tileY, firstItemID)
    SendPacket(2, "action|dialog_return\ndialog_name|oven\ntilex|" .. tileX ..
        "|\ntiley|" .. tileY .. "|\ncookthis|" .. firstItemID ..
        "|\nbuttonClicked|low\n\ndisplay_timer|1")
end

-- Tunggu sampai GetTimeMs() >= targetMs
-- Return false kalau user STOP atau deadline expired
local function WaitUntil(targetMs)
    while SLS.running do
        local now = GetTimeMs()
        local diff = targetMs - now
        if diff <= 0 then return true end
        local chunk = math.min(diff, 8000)
        sleep(chunk)
        if not CheckDeadline() then
            logS("DEADLINE EXPIRED mid-cook!")
            SLS.running = false
            return false
        end
    end
    return false
end

local function CookBatch(recipe, batchNum)
    logS("Batch " .. batchNum .. " mulai...")
    local N = math.min(SLS.ovenCount, #SLS.foundOvens)
    if N <= 0 then logS("Gak ada oven!"); return false end
    
    local ovens = {}
    for i = 1, N do ovens[i] = SLS.foundOvens[i] end
    
    -- =========================================================
    -- STEP 1: Interleaved (PlaceItem + delay + SetHeat + delay)
    -- Catat start time per oven (kapan SetHeat selesai)
    -- =========================================================
    local firstBahan = recipe.bahan[1]
    local startTime = {}
    logS("[STEP 1] Bahan pertama + SetHeat LOW (" .. N .. " oven, LOW)")
    
    for i, oven in ipairs(ovens) do
        PlaceItem(firstBahan.id, oven.x, oven.y)
        OvenDelay()
        SetHeatLevel(oven.x, oven.y, firstBahan.id)
        startTime[i] = GetTimeMs()   -- <<< anchor timer oven ini
        OvenDelay()
    end
    
    if not SLS.running then return false end
    
    -- =========================================================
    -- STEP 2+: Setiap oven punya target absolut = startTime[k] + timing[i]
    -- =========================================================
    for i = 2, #recipe.bahan do
        local bahan = recipe.bahan[i]
        local timingMs = math.floor(bahan.timing * 1000)
        
        logS("[STEP " .. i .. "] " .. bahan.nama .. " @ T=" .. bahan.timing .. "s")
        
        for k, oven in ipairs(ovens) do
            local target = startTime[k] + timingMs
            if not WaitUntil(target) then return false end
            PlaceItem(bahan.id, oven.x, oven.y)
            OvenDelay()
        end
    end
    
    -- =========================================================
    -- PUNCH: target absolut = startTime[k] + punch_time
    -- =========================================================
    local punchMs = math.floor(recipe.punch_time * 1000)
    logS("[PUNCH] @ T=" .. recipe.punch_time .. "s")
    
    for k, oven in ipairs(ovens) do
        local target = startTime[k] + punchMs
        if not WaitUntil(target) then return false end
        PlaceItem(PunchID, oven.x, oven.y)
        OvenDelay()
    end
    
    return true
end

local function mainLoop()
    local isValid = CheckDeadline()
    if not isValid then
        logS("DEADLINE EXPIRED! Gak bisa start.")
        expiredDialog(); return
    end
    SLS.running = true
    SLS.status = "RUNNING"
    logS("Auto Cook started! (Heat: LOW)")
    
    pcall(function()
        sendPacket(2, "action|mdfly\n|enable|1")
        editToggle("ModFly", true)
        sendPacket(2, "action|antibounce\n|enable|1")
        editToggle("Antibounce", true)
        sendPacket(2, "action|fastdrop\n|enable|1")
        editToggle("Fast Drop", true)
    end)
    
    local recipe = Recipes[SLS.selectedRecipe]
    if not recipe then logS("Resep gak ada!"); SLS.running = false; return end
    if not ScanOven() then logS("Gak ada oven!"); SLS.running = false; return end
    logS("Oven ketemu: " .. #SLS.foundOvens)
    
    for batch = 1, SLS.batchCount do
        if not SLS.running then break end
        local valid = CheckDeadline()
        if not valid then
            logS("DEADLINE EXPIRED mid-cooking! Stop.")
            SLS.running = false
            break
        end
        logS("=== BATCH " .. batch .. "/" .. SLS.batchCount .. " ===")
        if not CookBatch(recipe, batch) then break end
        if batch < SLS.batchCount then
            logS("Anti-DC delay " .. SLS.batchDelay .. "ms")
            sleep(SLS.batchDelay)
        end
    end
    
    SLS.running = false
    SLS.status = "COMPLETE"
    logS("Selesai!")
    mainDialog()
end

-- =============================================================
-- COMMAND /cook + HANDLER
-- =============================================================

local handleButton

function onSendPacket(type, pkt)
    if not pkt then return end
    if pkt:find("/cook", 1, true) then mainDialog(); return true end
    if pkt:find("action|dialog_return", 1, true) then
        if pkt:find("buttonClicked|sls_pick_confirm", 1, true) then
            for idx, value in pkt:gmatch("sls_recipe_(%d+)|([01])") do
                if value == "1" then
                    local recipeName = RecipeList[tonumber(idx)]
                    if recipeName then SLS.tempRecipe = recipeName; break end
                end
            end
        end
        local button = pkt:match("buttonClicked|([^\r\n|]+)")
        if button and handleButton then handleButton(button); return true end
    end
end

handleButton = function(button)
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end
    button = tostring(button or "")
    
    local recipeIdx = button:match("^sls_r(%d+)$")
    if recipeIdx then
        local idx = tonumber(recipeIdx)
        if idx and RecipeList[idx] then recipeDetailDialog(RecipeList[idx]) end
        return
    end
    if button == "sls_pick_confirm" then
        if SLS.tempRecipe and SLS.tempRecipe ~= "" then
            recipeDetailDialog(SLS.tempRecipe)
        else
            recipeMenuDialog()
        end
        return
    end
    
    local ovenIdx = button:match("^sls_o(%d+)$")
    if ovenIdx then SLS.ovenCount = tonumber(ovenIdx) or 1; settingDialog(); return end
    
    local tileIdx = button:match("^sls_t(%d+)$")
    if tileIdx then SLS.maxTilePlayer = tonumber(tileIdx) or 2; settingDialog(); return end
    
    local batchIdx = button:match("^sls_b(%d+)$")
    if batchIdx then SLS.batchCount = tonumber(batchIdx) or 1; settingDialog(); return end
    
    if button == "sls_main" then mainDialog()
    elseif button == "sls_close" then logS("Dialog closed.")
    elseif button == "sls_rmenu" then recipeMenuDialog()
    elseif button == "sls_setting" then settingDialog()
    elseif button == "sls_confirm" then
        if SLS.tempRecipe and SLS.tempRecipe ~= "" then
            SLS.selectedRecipe = SLS.tempRecipe
            logS("Resep: " .. SLS.selectedRecipe)
        end
        mainDialog()
    elseif button == "sls_start" then
        if not SLS.running then runThread(mainLoop) end
        mainDialog()
    elseif button == "sls_stop" then
        SLS.running = false
        SLS.status = "STOPPED"
        logS("STOP")
        mainDialog()
    end
end

local function onVariant(var, pkt) end

addHook(onSendPacket, "onSendPacket")
addHook(onVariant, "onVariant")
applyHook()

local _, remaining = CheckDeadline()
logS("Auto Cook V1.7 loaded. Ketik /cook.")
logS("Deadline: " .. FormatDeadline())
logS("Time Left: " .. FormatTime(remaining) .. " (SERVER TIME)")
logS("Heat Mode: LOW (Absolute)")