-- =============================================================
-- Auto Cook By Salsz V3.3
-- Command: /cook
-- Deadline: 10 Oktober 2026, 2:00 WIB (Server Time)
-- =============================================================
-- CHANGELOG:
--   V3.2 → V3.3:
--     - Fix: Multi-oven timing drift (2000ms → 500ms per oven)
--     - Add: 42 resep lengkap (dari 30)
--     - Add: Variant system (Magnifico 3 varian + Gingerbread 2 varian)
--     - Improve: Place delay 500ms (dari 1500ms)
-- =============================================================

local DEADLINE_CONFIG = {
    year = 2026, month = 10, day = 14,
    hour = 0, min = 0, sec = 0, utc_offset = 7,
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
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    local parts = {}
    if d > 0 then table.insert(parts, d .. "d") end
    if h > 0 then table.insert(parts, h .. "h") end
    if m > 0 then table.insert(parts, m .. "m") end
    if s > 0 or #parts == 0 then table.insert(parts, s .. "s") end
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
    ovenCount = 2,
    maxTilePlayer = 2,
    batchCount = 1,
    cookDelay = 500,        -- ✅ V3.3: turun ke 500ms
    placeDelay = 500,       -- ✅ V3.3: antar place item
    batchDelay = 6000,
    heartbeat = true,
    running = false,
    status = "IDLE",
    foundOvens = {},
    tempRecipe = "",
    variantIndex = {},
}

-- Limit config
local LIMITS = {
    ovenMin = 1, ovenMax = 23,
    radiusMin = 1, radiusMax = 3,
    batchMin = 1, batchMax = 100,
}

local function logS(msg) log("[Cook] " .. tostring(msg)) end

local function escapeDialog(s)
    s = tostring(s or "")
    s = s:gsub("|", "/"):gsub("\n", " ")
    return s
end

local function sendDialog(body) growtopia.sendDialog(body) end

local function GetTimeMs()
    local ok, t = pcall(function() return getTime() end)
    if ok and type(t) == "number" and t > 0 then return t end
    return os.time() * 1000
end

-- =============================================================
-- VARIANT SYSTEM
-- =============================================================

local VARIANTS = {
    ["Magnifico Carne Guacamole"] = {
        { name = "Bueno",    quality = "60-80%",   punch_offset = -2.0 },
        { name = "Sabroso",  quality = "81-95%",   punch_offset = -0.8 },
        { name = "Perfecto", quality = "96-100%",  punch_offset = 0    },
    },
    ["Gingerbread Cookie"] = {
        { name = "Cookie",   quality = "<95%",     punch_offset = -2.0 },
        { name = "Man",      quality = ">=95%",    punch_offset = 0    },
    },
}

local function HasVariant(recipeName)
    return VARIANTS[recipeName] ~= nil
end

local function GetActiveVariant(recipeName)
    if not HasVariant(recipeName) then return nil end
    local variants = VARIANTS[recipeName]
    local idx = SLS.variantIndex[recipeName] or 1
    return variants[idx], idx
end

local function GetVariantOffset(recipeName)
    local variant = GetActiveVariant(recipeName)
    if variant then
        return variant.punch_offset
    end
    return 0
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
    -- NEW ITEMS (V3.3)
    SweetPotatoMash = 4674,
    LargeFrozenChunk = 8410,
    LargeRadioactiveBit = 8412,
    Cobweb = 4874,
    PumpkinCandy = 7556,
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
    -- NEW RECIPES (V3.3)
    ["Blood Truffle Biscuits with Sweet Radish Pie"] = 4594,
    ["Dumplings Hat"] = 4602,
    ["Heart Cookies"] = 5376,
    ["Nutri-goop"] = 4670,
    ["Pet Stinky Onion"] = 4602,
    ["Pet Twin Cherries"] = 4766,
    ["Pineapple Pizza Slice"] = 4768,
    ["Sweet Potato Tots"] = 4674,
    ["Trawlerman's Friend"] = 8410,
}

-- =============================================================
-- DATABASE 42 RESEP
-- =============================================================

local Recipes = {
    ["Alien Bloodied Brains Strudel"] = { punch_time = 106, bahan = {
        {nama = "Space Poop", id = ITEMS.SpacePoop, timing = 0},
        {nama = "Zombie Brain", id = ITEMS.ZombieBrain, timing = 19.7},
        {nama = "Slime", id = ITEMS.Slime, timing = 49.7},
        {nama = "Putrid Gas", id = ITEMS.PutridGas, timing = 105},
    }},
    ["Apple Strudel"] = { punch_time = 83, bahan = {
        {nama = "Apple", id = ITEMS.Apple, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 23.3},
        {nama = "Egg", id = ITEMS.Egg, timing = 23.3},
    }},
    ["Arroz Con Pollo"] = { punch_time = 100, bahan = {
        {nama = "Rice", id = ITEMS.Rice, timing = 0},
        {nama = "Onion", id = ITEMS.Onion, timing = 33.7},
        {nama = "Chicken Meat", id = ITEMS.ChickenMeat, timing = 33.7},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 70},
    }},
    ["BBQ Bacon Burger"] = { punch_time = 66, bahan = {
        {nama = "Ground Beef", id = ITEMS.GroundBeef, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 6.3},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 16.3},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 36.3},
        {nama = "Lettuce", id = ITEMS.Lettuce, timing = 65},
    }},
    ["Beer-Battered Fish & Chips"] = { punch_time = 120, bahan = {
        {nama = "Green Beer", id = ITEMS.GreenBeer, timing = 0},
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Potato", id = ITEMS.Potato, timing = 0},
        {nama = "Fish Chunk", id = ITEMS.FishChunk, timing = 87},
    }},
    ["Berry Crepes"] = { punch_time = 60, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 0},
        {nama = "Milk", id = ITEMS.Milk, timing = 26.7},
        {nama = "Blueberry", id = ITEMS.Blueberry, timing = 40},
    }},
    ["Blood Truffle Biscuits with Sweet Radish Pie"] = { punch_time = 74.6, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Honey", id = ITEMS.Honey, timing = 0},
        {nama = "Beat-root Puree", id = ITEMS.BeatrootPuree, timing = 0},
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 1.9},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 24.5},
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
    ["Detective Butter Lamb"] = { punch_time = 72.5, bahan = {
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 0},
        {nama = "Corn Meal", id = ITEMS.CornMeal, timing = 6},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 22.5},
        {nama = "Milk", id = ITEMS.Milk, timing = 39.5},
        {nama = "Habanero Pepper", id = ITEMS.HabaneroPepper, timing = 62},
    }},
    ["Dumplings Hat"] = { punch_time = 116, bahan = {
        {nama = "Cosmic 5-Spice", id = ITEMS.Cosmic5Spice, timing = 0},
        {nama = "Onion", id = ITEMS.Onion, timing = 50},
        {nama = "Chicken Meat", id = ITEMS.ChickenMeat, timing = 51},
        {nama = "Dough", id = ITEMS.Dough, timing = 58.5},
        {nama = "Lettuce", id = ITEMS.Lettuce, timing = 115},
    }},
    ["Eggnog"] = { punch_time = 73, bahan = {
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 13},
        {nama = "Milk", id = ITEMS.Milk, timing = 40},
        {nama = "Ground Nutmeg", id = ITEMS.GroundNutmeg, timing = 72},
        {nama = "Crushed Ice", id = ITEMS.CrushedIce, timing = 72},
    }},
    ["Eggs Benedict"] = { punch_time = 60, bahan = {
        {nama = "Dough", id = ITEMS.Dough, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 0},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 10},
        {nama = "Milk", id = ITEMS.Milk, timing = 26},
    }},
    ["Failed Butter Lamb"] = { punch_time = 72.5, bahan = {
        {nama = "Coconut Milk", id = ITEMS.CoconutMilk, timing = 0},
        {nama = "Corn Meal", id = ITEMS.CornMeal, timing = 6},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 22.5},
        {nama = "Milk", id = ITEMS.Milk, timing = 39.5},
        {nama = "Habanero Pepper", id = ITEMS.HabaneroPepper, timing = 62},
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
    ["Gingerbread Cookie"] = { punch_time = 80, bahan = {
        {nama = "Gingerbread Dough", id = ITEMS.GingerbreadDough, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 20},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 30},
        {nama = "Chocolate Sprinkles", id = ITEMS.ChocolateSprinkles, timing = 63},
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
    ["Heart Cookies"] = { punch_time = 115, bahan = {
        {nama = "Cosmic 5-Spice", id = ITEMS.Cosmic5Spice, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 56},
        {nama = "Chocolate Sprinkles", id = ITEMS.ChocolateSprinkles, timing = 98},
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
    ["Nutri-goop"] = { punch_time = 66.3, bahan = {
        {nama = "Corn Meal", id = ITEMS.CornMeal, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 6.3},
        {nama = "Sweet Potato Mash", id = ITEMS.SweetPotatoMash, timing = 6.3},
        {nama = "Gruel", id = ITEMS.Gruel, timing = 13},
        {nama = "Milk", id = ITEMS.Milk, timing = 33},
    }},
    ["Pet Stinky Onion"] = { punch_time = 90, bahan = {
        {nama = "Primordial Soup", id = ITEMS.PrimordialSoup, timing = 0},
        {nama = "Onion", id = ITEMS.Onion, timing = 28},
        {nama = "Habanero Pepper", id = ITEMS.HabaneroPepper, timing = 80},
        {nama = "Putrid Gas", id = ITEMS.PutridGas, timing = 90},
    }},
    ["Pet Twin Cherries"] = { punch_time = 90, bahan = {
        {nama = "Primordial Soup", id = ITEMS.PrimordialSoup, timing = 0},
        {nama = "Baking Chocolate", id = ITEMS.BakingChocolate, timing = 40},
        {nama = "Marshmallow", id = ITEMS.Marshmallow, timing = 80},
        {nama = "Cherry", id = ITEMS.Cherry, timing = 80},
    }},
    ["Pineapple Pizza Slice"] = { punch_time = 81.5, bahan = {
        {nama = "Pineapple Slice", id = ITEMS.PineappleSlice, timing = 0},
        {nama = "Dough", id = ITEMS.Dough, timing = 22},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 32},
        {nama = "Tomato", id = ITEMS.Tomato, timing = 51},
        {nama = "Swiss Cheese", id = ITEMS.SwissCheese, timing = 71},
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
    ["Sweet Potato Tots"] = { punch_time = 66.3, bahan = {
        {nama = "Flour", id = ITEMS.Flour, timing = 0},
        {nama = "Onion", id = ITEMS.Onion, timing = 0},
        {nama = "Egg", id = ITEMS.Egg, timing = 6.3},
        {nama = "Sweet Potato Mash", id = ITEMS.SweetPotatoMash, timing = 6.3},
        {nama = "Bacon", id = ITEMS.Bacon, timing = 16.3},
    }},
    ["Trawlerman's Friend"] = { punch_time = 107, bahan = {
        {nama = "Large Frozen Chunk", id = ITEMS.LargeFrozenChunk, timing = 0},
        {nama = "Large Radioactive Bit", id = ITEMS.LargeRadioactiveBit, timing = 47},
        {nama = "Cobweb", id = ITEMS.Cobweb, timing = 77},
        {nama = "Pumpkin Candy", id = ITEMS.PumpkinCandy, timing = 100},
    }},
}

local RecipeList = {
    "Alien Bloodied Brains Strudel",
    "Apple Strudel",
    "Arroz Con Pollo",
    "BBQ Bacon Burger",
    "Beer-Battered Fish & Chips",
    "Berry Crepes",
    "Blood Truffle Biscuits with Sweet Radish Pie",
    "Chips And Guacamole",
    "Chocolate Bunny",
    "Chocolate Easter Bilby",
    "Coconut Tart",
    "Composer's Cookie",
    "Deep-Fried Tropical Ice Cream",
    "Detective Butter Lamb",
    "Dumplings Hat",
    "Eggnog",
    "Eggs Benedict",
    "Failed Butter Lamb",
    "Festering Urchin & Poop Pie",
    "Flashback Flan",
    "Gemonade",
    "Gingerbread Cookie",
    "Gluton's Gazpacho",
    "Growlectables",
    "Heart Cookies",
    "Homemade Fish Taco",
    "Hot Chocolate",
    "Magnifico Carne Guacamole",
    "Nutri-goop",
    "Pet Stinky Onion",
    "Pet Twin Cherries",
    "Pineapple Pizza Slice",
    "Pineapple Turnover",
    "Pumpkin Pie",
    "Putrid Gas Blood Maggot Crepes",
    "Rotting Fish Guts Club Sandwich",
    "Skill Spice",
    "Sweet Potato Tots",
    "Trawlerman's Friend",
}

-- =============================================================
-- DIALOGS
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
add_textbox|`7Discord: `wsalsz``|left|
add_spacer|small|
end_dialog|sls_expired|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

local function mainDialog()
    local isValid, remaining = CheckDeadline()
    if not isValid then expiredDialog(); return end
    local statusText = SLS.running and "`2RUNNING``" or "`4STOPPED``"
    local recipeID = RESULT_ID[SLS.selectedRecipe] or 4618
    
    local variantInfo = ""
    if HasVariant(SLS.selectedRecipe) then
        local variant = GetActiveVariant(SLS.selectedRecipe)
        if variant then
            variantInfo = "`7Variant: `w" .. variant.name .. "``|left|\n"
        end
    end
    
    local dialog = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`wAuto Cook V3.4``|left|4618|
add_textbox|`7Script By: `wSalsz``|left|
add_textbox|`7Status: ]] .. statusText .. [[``|left|
add_textbox|`7Deadline: `w]] .. FormatDeadline() .. [[``|left|
add_textbox|`7Time Left: `2]] .. FormatTime(remaining) .. [[``|left|
add_spacer|small|
add_textbox|`wResep Aktif:``|left|
add_label_with_icon|small|`2]] .. escapeDialog(SLS.selectedRecipe) .. [[``|left|]] .. recipeID .. [[|
]] .. variantInfo .. [[
add_spacer|small|
add_textbox|`7Oven: `w]] .. SLS.ovenCount .. [[`` `7| Radius: `w]] .. SLS.maxTilePlayer .. [[``|left|
add_textbox|`7Heat: `2LOW `7(Mutlak)``|left|
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
        local variantMark = HasVariant(recipeName) and "`6[VARIAN]`` " or ""
        dialog = dialog .. "add_checkbox|sls_recipe_" .. i .. "|" .. variantMark .. "`w" .. escapeDialog(recipeName) .. "``|" .. checked .. "|\n"
    end
    dialog = dialog .. [[
add_spacer|small|
add_button|sls_pick_confirm|SELECT RECIPE|noflags|0|0|
add_button|sls_main|BACK|noflags|0|0|
end_dialog|sls_rmenu|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

local function variantSelectDialog(recipeName)
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end
    
    SLS.tempRecipe = recipeName
    local variants = VARIANTS[recipeName]
    if not variants then mainDialog() return end
    
    local currentIdx = SLS.variantIndex[recipeName] or 1
    local recipeID = RESULT_ID[recipeName] or 4618
    
    local dialog = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`wPILIH VARIAN``|left|4618|
add_label_with_icon|small|`w]] .. escapeDialog(recipeName) .. [[``|left|]] .. recipeID .. [[|
add_spacer|small|
add_textbox|`7Resep ini punya ]] .. #variants .. [[ varian:``|left|
add_textbox|`7Current: `wVarian ke-]] .. currentIdx .. [[``|left|
add_spacer|small|
]]
    
    for i, variant in ipairs(variants) do
        local marker = (i == currentIdx) and "`2[✓] ``" or ""
        dialog = dialog .. "add_textbox|" .. marker .. "`w" .. variant.name .. "`` `7| Quality: `w" .. variant.quality .. "`` `7| Offset: `w" .. variant.punch_offset .. "s``|left|\n"
        dialog = dialog .. "add_button|sls_var_" .. i .. "|PILIH " .. variant.name .. "|noflags|0|0|\n"
    end
    
    dialog = dialog .. [[
add_spacer|small|
add_button|sls_rmenu|BACK|noflags|0|0|
end_dialog|sls_variant|Close||
add_quick_exit|
]]
    sendDialog(dialog)
end

local function recipeDetailDialog(recipeName)
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end
    SLS.tempRecipe = recipeName
    local recipe = Recipes[recipeName]
    if not recipe then recipeMenuDialog(); return end
    local recipeID = RESULT_ID[recipeName] or 4618
    
    local variantLine = ""
    if HasVariant(recipeName) then
        local variant = GetActiveVariant(recipeName)
        if variant then
            variantLine = "add_textbox|`7Variant: `w" .. variant.name .. "`` `7(" .. variant.quality .. ")``|left|\n"
        end
    end
    
    local detail = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`w]] .. escapeDialog(recipeName) .. [[``|left|]] .. recipeID .. [[|
add_textbox|`7Heat: `2LOW `7(Mutlak)``|left|
]] .. variantLine .. [[
add_spacer|small|
add_textbox|`wBAHAN & TIMING:``|left|
]]
    
    for i, bahan in ipairs(recipe.bahan) do
        detail = detail .. "add_label_with_icon|small|`7" .. i .. ". " .. escapeDialog(bahan.nama) .. " -> " .. bahan.timing .. "s``|left|" .. bahan.id .. "|\n"
    end
    
    local punchActual = recipe.punch_time + GetVariantOffset(recipeName)
    
    detail = detail .. [[
add_spacer|small|
add_textbox|`wPUNCH: `2]] .. string.format("%.1f", punchActual) .. [[s``|left|
]]
    
    if HasVariant(recipeName) then
        detail = detail .. "add_spacer|small|\nadd_button|sls_variant_select|PILIH VARIAN|noflags|0|0|\n"
    end
    
    detail = detail .. [[
add_button|sls_confirm|SELECT RECIPE|noflags|0|0|
add_button|sls_rmenu|BACK|noflags|0|0|
end_dialog|sls_rdetail|Close||
add_quick_exit|
]]
    sendDialog(detail)
end

local function settingDialog()
    local isValid = CheckDeadline()
    if not isValid then expiredDialog(); return end

    local dialog = [[
set_default_color|`o
set_bg_color|20,25,35,245
set_border_color|70,110,160,255
add_label_with_icon|big|`wAUTO COOK SETTINGS``|left|4618|
add_textbox|`7Atur cepat tanpa spam tombol satu-satu.``|left|
add_spacer|small|
]]
    dialog = dialog .. "add_textbox|`wOVEN: `2" .. SLS.ovenCount .. "`` `7(Max " .. LIMITS.ovenMax .. ")``|left|\n"
    dialog = dialog .. "add_button|sls_oven_m5|`4-5``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_oven_minus|`4-1``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_oven_plus|`2+1``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_oven_p5|`2+5``|noflags|0|0|\n"
    dialog = dialog .. "add_spacer|small|\n"
    dialog = dialog .. "add_textbox|`wRADIUS SCAN: `2" .. SLS.maxTilePlayer .. "`` `7(Max " .. LIMITS.radiusMax .. ")``|left|\n"
    dialog = dialog .. "add_button|sls_tile_minus|`4-1``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_tile_plus|`2+1``|noflags|0|0|\n"
    dialog = dialog .. "add_spacer|small|\n"
    dialog = dialog .. "add_textbox|`wBATCH: `2" .. SLS.batchCount .. "`` `7(Max " .. LIMITS.batchMax .. ")``|left|\n"
    dialog = dialog .. "add_button|sls_batch_m10|`4-10``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_batch_minus|`4-1``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_batch_plus|`2+1``|noflags|0|0|\n"
    dialog = dialog .. "add_button|sls_batch_p10|`2+10``|noflags|0|0|\n"
    dialog = dialog .. [[
add_spacer|small|
add_textbox|`wHEAT: `2LOW `7(Mutlak)``|left|
add_button|sls_main|BACK|noflags|0|0|
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
-- CHECK PLAYER NEAR OVEN
-- =============================================================

local function IsPlayerNearOven(ovenX, ovenY)
    local p = getLocal()
    if not p then return false end
    
    local px = math.floor(p.posX / 32)
    local py = math.floor(p.posY / 32)
    
    local dx = math.abs(px - ovenX)
    local dy = math.abs(py - ovenY)
    
    if dx > 3 or dy > 3 then
        return false, dx, dy
    end
    
    return true, dx, dy
end

-- =============================================================
-- COOKING LOGIC V3.4 (MULTI-OVEN FIX)
-- =============================================================

local function PlaceItem(itemID, tileX, tileY)
    local p = getLocal()
    if not p then return false end
    
    local near, dx, dy = IsPlayerNearOven(tileX, tileY)
    if not near then
        logS("⚠️ Player jauh dari oven (dx=" .. dx .. " dy=" .. dy .. ")")
        return false
    end
    
    SendPacketRaw(false, {
        type = 3, value = itemID,
        px = tileX, py = tileY,
        x = p.posX, y = p.posY
    })
    return true
end

local function SetHeatLevel(tileX, tileY, firstItemID)
    -- Format dialog_return oven memakai delimiter | setelah nilai tile/item.
    SendPacket(2, "action|dialog_return\ndialog_name|oven\ntilex|" .. tileX ..
        "|\ntiley|" .. tileY .. "|\ncookthis|" .. firstItemID ..
        "|\nbuttonClicked|low\n\ndisplay_timer|1")
end

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

    local variantOffset = GetVariantOffset(SLS.selectedRecipe)
    local firstBahan = recipe.bahan[1]
    local startTime = {}

    -- Jika bahan berikutnya bertiming 0s, masukkan langsung ke oven yang
    -- sedang disiapkan sebelum beralih ke oven berikutnya. Ini mencegah
    -- oven #1 kehilangan timing 0s saat script sibuk menyiapkan oven lain.
    local preloadedZero = {}
    local zeroCount = 0
    for i = 2, #recipe.bahan do
        if (tonumber(recipe.bahan[i].timing) or 0) == 0 then
            zeroCount = zeroCount + 1
        else
            break
        end
    end

    logS("[STEP 1] Setup " .. N .. " oven; bahan 0s dimasukkan per oven")

    for i, oven in ipairs(ovens) do
        if not SLS.running then return false end
        if not PlaceItem(firstBahan.id, oven.x, oven.y) then
            logS("STOP: Gagal place bahan pertama di oven #" .. i .. ".")
            return false
        end

        -- Mulai oven memakai bahan pertama.
        sleep(SLS.cookDelay)
        SetHeatLevel(oven.x, oven.y, firstBahan.id)
        startTime[i] = GetTimeMs()
        logS("Oven #" .. i .. " dimulai pada tile " .. oven.x .. "," .. oven.y)

        -- Muat semua bahan lanjutan bertiming 0s di oven ini dahulu.
        for j = 2, zeroCount + 1 do
            local bahan = recipe.bahan[j]
            if not PlaceItem(bahan.id, oven.x, oven.y) then
                logS("STOP: Gagal place bahan 0s #" .. j .. " di oven #" .. i .. ".")
                return false
            end
            preloadedZero[j] = true
            logS("Oven #" .. i .. ": bahan 0s dimasukkan - " .. bahan.nama)
            -- Jeda pendek agar paket tidak bertumpuk, tetapi tidak menunggu 500ms.
            sleep(50)
        end

        -- Jeda antar-oven hanya setelah semua bahan 0s oven ini dimuat.
        if i < N then sleep(SLS.cookDelay) end
    end

    if not SLS.running then return false end

    -- Bahan non-zero tetap mengikuti timing resep relatif terhadap waktu start oven.
    for i = 2, #recipe.bahan do
        local bahan = recipe.bahan[i]
        if not preloadedZero[i] then
            local timingMs = math.floor((tonumber(bahan.timing) or 0) * 1000)
            logS("[STEP " .. i .. "] " .. bahan.nama .. " @ T=" .. bahan.timing .. "s")

            for k, oven in ipairs(ovens) do
                local target = startTime[k] + timingMs
                if not WaitUntil(target) then return false end
                if not PlaceItem(bahan.id, oven.x, oven.y) then
                    logS("STOP: Player jauh saat memasukkan " .. bahan.nama .. " ke oven #" .. k .. ".")
                    return false
                end
                sleep(SLS.placeDelay)
            end
        end
    end

    local punchMs = math.floor((recipe.punch_time + variantOffset) * 1000)
    logS("[PUNCH] @ T=" .. string.format("%.1f", recipe.punch_time + variantOffset) .. "s")

    for k, oven in ipairs(ovens) do
        local target = startTime[k] + punchMs
        if not WaitUntil(target) then return false end
        if not PlaceItem(PunchID, oven.x, oven.y) then
            logS("STOP: Player jauh saat punch oven #" .. k .. ".")
            return false
        end
        sleep(SLS.placeDelay)
    end

    return true
end

local function mainLoop()
    local isValid = CheckDeadline()
    if not isValid then
        logS("DEADLINE EXPIRED!")
        expiredDialog(); return
    end
    SLS.running = true
    SLS.status = "RUNNING"
    logS("Auto Cook V3.4 started!")
    logS("Oven: " .. SLS.ovenCount .. " | Delay: " .. SLS.cookDelay .. "ms")
    
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
    
    logS("Oven ketemu dalam radius: " .. #SLS.foundOvens .. " | Target dipakai: " .. math.min(SLS.ovenCount, #SLS.foundOvens))
    
    local firstOven = SLS.foundOvens[1]
    local near, dx, dy = IsPlayerNearOven(firstOven.x, firstOven.y)
    if not near then
        logS("⚠️ PLAYER JAUH DARI OVEN!")
        SLS.running = false
        mainDialog()
        return
    end
    
    logS("✓ Player deket oven")
    
    for batch = 1, SLS.batchCount do
        if not SLS.running then break end
        local valid = CheckDeadline()
        if not valid then SLS.running = false; break end
        logS("=== BATCH " .. batch .. "/" .. SLS.batchCount .. " ===")
        if not CookBatch(recipe, batch) then break end
        if batch < SLS.batchCount then
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
    
    local variantIdx = button:match("^sls_var_(%d+)$")
    if variantIdx then
        local idx = tonumber(variantIdx)
        if SLS.tempRecipe and VARIANTS[SLS.tempRecipe] then
            SLS.variantIndex[SLS.tempRecipe] = idx
            local variant = VARIANTS[SLS.tempRecipe][idx]
            logS("Variant: " .. variant.name)
            variantSelectDialog(SLS.tempRecipe)
        end
        return
    end
    
    if button == "sls_variant_select" then
        if SLS.tempRecipe and HasVariant(SLS.tempRecipe) then
            variantSelectDialog(SLS.tempRecipe)
        end
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
    
    if button == "sls_oven_m5" then
        SLS.ovenCount = math.max(LIMITS.ovenMin, SLS.ovenCount - 5)
        settingDialog(); return
    elseif button == "sls_oven_p5" then
        SLS.ovenCount = math.min(LIMITS.ovenMax, SLS.ovenCount + 5)
        settingDialog(); return
    elseif button == "sls_batch_m10" then
        SLS.batchCount = math.max(LIMITS.batchMin, SLS.batchCount - 10)
        settingDialog(); return
    elseif button == "sls_batch_p10" then
        SLS.batchCount = math.min(LIMITS.batchMax, SLS.batchCount + 10)
        settingDialog(); return
    end

    if button == "sls_oven_minus" then
        SLS.ovenCount = math.max(LIMITS.ovenMin, SLS.ovenCount - 1)
        logS("Oven: " .. SLS.ovenCount)
        settingDialog()
        return
    elseif button == "sls_oven_plus" then
        SLS.ovenCount = math.min(LIMITS.ovenMax, SLS.ovenCount + 1)
        logS("Oven: " .. SLS.ovenCount)
        settingDialog()
        return
    end
    
    if button == "sls_tile_minus" then
        SLS.maxTilePlayer = math.max(LIMITS.radiusMin, SLS.maxTilePlayer - 1)
        logS("Radius: " .. SLS.maxTilePlayer)
        settingDialog()
        return
    elseif button == "sls_tile_plus" then
        SLS.maxTilePlayer = math.min(LIMITS.radiusMax, SLS.maxTilePlayer + 1)
        logS("Radius: " .. SLS.maxTilePlayer)
        settingDialog()
        return
    end
    
    if button == "sls_batch_minus" then
        SLS.batchCount = math.max(LIMITS.batchMin, SLS.batchCount - 1)
        logS("Batch: " .. SLS.batchCount)
        settingDialog()
        return
    elseif button == "sls_batch_plus" then
        SLS.batchCount = math.min(LIMITS.batchMax, SLS.batchCount + 1)
        logS("Batch: " .. SLS.batchCount)
        settingDialog()
        return
    end
    
    if button == "sls_main" then mainDialog()
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
logS("Auto Cook V3.4 loaded. Ketik /cook.")
logS("Deadline: " .. FormatDeadline())
logS("Time Left: " .. FormatTime(remaining) .. " (SERVER TIME)")
logS("Total Resep: " .. #RecipeList)
logS("Multi-Oven Fix: per oven diaktifkan langsung + quick settings")