-- ================================================================
--  MOONCAKE ALTAR AUTO-OFFERING & SMART REROLL ENGINE
--  Description: Absolute Epic Webhook Filter, Simple Button Logic,
--  Deficit Restock, Console Radar, 700ms Default Delay
--  Auth Key: HARVESTFESTONLINE
-- ================================================================

local SCRIPT_NAME = "Mooncake Altar"

local pref = require("preferences")
local json = require("json")
local saved = pref:new("mooncake_cfg.json")

-- ----------------------------------------------------------------
--  STATE VARIABLES & CONFIG
-- ----------------------------------------------------------------
local KEY = "HARVESTFESTONLINE"
local keyVerified = false

if saved:get("auth_key", "") == KEY then
    keyVerified = true
end

local bot_running = false
local bot_state = "IDLE" 
local awaiting_reward = false
local current_editing_slot = 1

-- DEFAULT DELAY SET TO 700ms
local delay_ms = tonumber(saved:get("delay_ms", 700)) or 700
local desired_rewards = {}

local current_table_state = {}
local received_altar_dialog = false
local last_rolled_item_name = nil 

-- 🌐 WEBHOOK TARGETS
local PROXY_API_URL = "https://discord-jacko.geostorming900.workers.dev/"
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1541494385517133874/1xV7ymEJVOeHhhTBum9u0AdfUKaa66h0jxJXZv2ii5HJde3Z8yNYF8i-MyQ95HfdCNhx"

-- 🏆 ABSOLUTE EPIC PRIZES (HANYA ITEM INI YANG BISA MASUK WEBHOOK)
local WEBHOOK_EPIC_ITEMS = {
    ["weather machine - pinuski's petal purrfect haven"] = true,
    ["weather machine - autumn"] = true,
    ["sun shooter bow"] = true,
    ["soaring cropduster"] = true,
    ["mooncake paper lanterns"] = true,
    ["mantle of chang'e"] = true,
    ["lil' sheepers"] = true,
    ["kimono of chang'e"] = true,
    ["harvest broomstick"] = true,
    ["harvest blossom wings"] = true,
    ["fall wings"] = true,
    ["diamond flashaxe"] = true,
    ["autumn wings"] = true,
    ["astral aura - rabbit"] = true,
    ["astral aura - lion"] = true,
    ["astral aura - dragon"] = true,
    ["halo of autumn leaves"] = true
}

-- Initialize & Purify 10 Slots
local raw_slots = saved:get("slots", {})
local slots = {}
for i = 1, 10 do
    slots[i] = {
        id = tonumber(raw_slots[i] and raw_slots[i].id) or 0,
        count = tonumber(raw_slots[i] and raw_slots[i].count) or 0
    }
    current_table_state[i] = {id = 0, count = 0}
end

local _sleep = sleep or Sleep or CSleep
local _findPath = FindPath or findPath
local sendFunc = SendPacketRaw or sendPacketRaw

local function Log(msg) pcall(function() LogToConsole("`9["..SCRIPT_NAME.."]`o " .. msg) end) end
local function Warn(msg) pcall(function() LogToConsole("`4[Error]`o " .. msg) end) end

-- ----------------------------------------------------------------
--  MOONCAKE DATABASE
-- ----------------------------------------------------------------
local MOONCAKES = {
    "Harmony Mooncake", "Peace Mooncake", "Longevity Mooncake",
    "Prosperity Mooncake", "Balance Mooncake", "Ancestor Mooncake",
    "Purity Mooncake", "Courage Mooncake", "Unity Mooncake", "Songpyeon"
}
local CAKE_IDS = {
    ["Harmony Mooncake"] = 1058, 
    ["Peace Mooncake"] = 1094, 
    ["Longevity Mooncake"] = 1096,
    ["Prosperity Mooncake"] = 1098, 
    ["Balance Mooncake"] = 1828, 
    ["Ancestor Mooncake"] = 3870,
    ["Purity Mooncake"] = 7058, 
    ["Courage Mooncake"] = 13890, 
    ["Unity Mooncake"] = 11286,
    ["Songpyeon"] = 1056
}

local function is_valid_mooncake(id)
    for _, cake_id in pairs(CAKE_IDS) do
        if id == cake_id then return true end
    end
    return false
end

-- ----------------------------------------------------------------
--  UTILITIES & HELPERS
-- ----------------------------------------------------------------
local OFFERING_TABLE_ID = 12598
pcall(function()
    if type(findItemID) == "function" then
        local id = findItemID("Offering Table")
        if id and id > 0 then OFFERING_TABLE_ID = id end
    elseif type(growtopia) == "table" and type(growtopia.getItemID) == "function" then
        local id = growtopia.getItemID("Offering Table")
        if id and id > 0 then OFFERING_TABLE_ID = id end
    end
end)

local function getInvCount(id)
    local inv = getInventory()
    if not inv then return 0 end
    for _, item in pairs(inv) do
        if item.id == id then return item.amount or item.count end
    end
    return 0
end

local function getItemNameSafely(id)
    local num_id = tonumber(id) or 0
    if num_id == 0 then return "Empty" end
    for name, i in pairs(CAKE_IDS) do
        if i == num_id then return name end
    end
    
    local name = ""
    pcall(function()
        if type(growtopia) == "table" and type(growtopia.getItemName) == "function" then
            name = growtopia.getItemName(num_id)
        end
    end)
    
    if name and name ~= "" and name ~= "Unknown" then 
        return (name:gsub("`.", "")) 
    end
    return tostring(num_id)
end

local function sendDialog(str)
    pcall(function()
        if type(growtopia) == "table" and type(growtopia.sendDialog) == "function" then
            growtopia.sendDialog(str)
        elseif type(sendVariant) == "function" then
            sendVariant({v1 = "OnDialogRequest", v2 = str})
        else
            local var = { v1 = "OnDialogRequest", v2 = str }
            if type(SendVariantList) == "function" then SendVariantList(var)
            elseif type(SendVarlist) == "function" then SendVarlist(var) end
        end
    end)
end

local function hasDesiredRewards()
    for _, v in pairs(desired_rewards) do
        if v then return true end
    end
    return false
end

local function urlencode(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w%-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    end
    return str
end

local function sendWebhookPrize(itemName)
    local discord_id = "UnknownPlayer"
    pcall(function() 
        local did = getDiscordID() 
        if did and did ~= "" then discord_id = did end
    end)
    
    local content_msg = string.format("Congratulation <@%s> for getting choosen epic prize **%s**!", discord_id, itemName)

    local payload_table = {
        url = DISCORD_WEBHOOK, 
        content = content_msg, 
        username = "Mooncake Bot", 
        embeds = {{
            title = "🎉 Epic Prize Claimed!",
            description = "Successfully claimed Elite Target: **" .. itemName .. "**",
            color = 65280,
            footer = {
                text = "Jacko999 Farming System"
            }
        }}
    }
    
    local json_payload = json:encode(payload_table)
    local safe_payload = urlencode(json_payload)
    local final_url = PROXY_API_URL .. "?data=" .. safe_payload
    
    runCoroutine(function()
        local success, response = pcall(function() return fetch(final_url) end)
        if success then Log("`e[Webhook]`o Epic Prize Alert fired successfully!")
        else Warn("`4[Webhook Failed]`o") end
    end)
end

-- ----------------------------------------------------------------
--  SECURITY & AUTHENTICATION
-- ----------------------------------------------------------------
local function saveKey()
    saved:set("auth_key", KEY)
    saved:save()
end

local function openKeyDialog()
    runCoroutine(function()
        _sleep(150)
        local dialog = "set_default_color|`o\n"
        .. "add_label_with_icon|big|`9 MOONCAKE ALTAR // AUTH ``|left|12598|\n"
        .. "add_textbox|`c--------------------------------------------|\n"
        .. "add_textbox|`7Please enter your license key to unlock the engine.|\n"
        .. "add_spacer|small|\n"
        .. "add_text_input|key_input|Secret Key:| |30|\n"
        .. "add_button|btn_verify_key|`9 UNLOCK ENGINE ``|noflags|0|0|\n"
        .. "add_quick_exit|\n"
        .. "end_dialog|mooncake_auth|Close||"
        sendDialog(dialog)
    end)
end

-- ----------------------------------------------------------------
--  VIRTUAL OFFERING TABLE UI
-- ----------------------------------------------------------------
local function openVisualConfigDialog()
    runCoroutine(function()
        _sleep(150)
        local str = "set_default_color|`w\n"
        .. "add_label_with_icon|big|`wMooncake Configuration``|left|12598|\n"
        .. "add_spacer|small|\n"
        .. "add_textbox|Click a slot to configure the Mooncake and amount.|left|\n"
        .. "add_spacer|small|\n"
        
        for i = 1, 10 do
            local s = slots[i]
            local icon = s.id == 0 and 982 or s.id
            
            local clean_name = "Empty"
            if s.id ~= 0 then
                clean_name = getItemNameSafely(s.id):gsub(" Mooncake", "")
            end
            
            local label = s.id == 0 and "Empty" or (clean_name .. " (x" .. s.count .. ")")
            
            str = str .. "add_button_with_icon|cfg_slot_"..i.."|`2"..label.."``|frame|"..icon.."||\n"
        end
        
        str = str .. "add_spacer|small|\n"
        str = str .. "add_button|close_cfg|Close|noflags|0|0|\n"
        str = str .. "end_dialog|visual_cfg_dlg|Close||\n"
        str = str .. "add_quick_exit|\n"
        sendDialog(str)
    end)
end

local function openCakeSelectDialog()
    runCoroutine(function()
        _sleep(150)
        local str = "set_default_color|`o\n"
        .. "add_label_with_icon|big|`9Select Mooncake for Slot "..current_editing_slot.."``|left|12598|\n"
        .. "add_spacer|small|\n"
        
        for _, name in ipairs(MOONCAKES) do
            local id = CAKE_IDS[name]
            str = str .. "add_button_with_icon|setcake_"..id.."|"..name.."|frame|"..id.."|200|\n"
        end
        str = str .. "add_button_with_icon|setcake_0|Empty (Skip Slot)|frame|982|200|\n"
        str = str .. "end_dialog|cake_select_dlg|Cancel||\n"
        sendDialog(str)
    end)
end

local function openCakeAmountDialog()
    runCoroutine(function()
        _sleep(150)
        local current_count = slots[current_editing_slot].count or 0
        local str = "set_default_color|`o\n"
        .. "add_label_with_icon|big|`9Amount for Slot "..current_editing_slot.."``|left|12598|\n"
        .. "add_text_input|cake_amount|Count (Max 200):|"..current_count.."|3|\n"
        .. "end_dialog|cake_amount_dlg|Cancel|OK|\n"
        sendDialog(str)
    end)
end

-- ----------------------------------------------------------------
--  WORLD SCANNER & ACTION FUNCTIONS
-- ----------------------------------------------------------------
local function findOfferingTable()
    local tiles = getTiles()
    if tiles then
        for _, t in pairs(tiles) do
            if t.fg == OFFERING_TABLE_ID then
                return t.x, t.y
            end
        end
    end
    return nil, nil
end

local function wrenchTile(tx, ty)
    local me = getLocal()
    if not me then return end
    local pkt = {
        type = 3,
        value = 32,
        px = tx,
        py = ty,
        x = me.posX or me.x,
        y = me.posY or me.y,
        characterState = 0
    }
    sendFunc(false, pkt)
end

-- ----------------------------------------------------------------
--  AUTO-RESTOCK ENGINE
-- ----------------------------------------------------------------
local function ensureInventory(target_id, required_inv, start_x, start_y)
    local did_hunt = false
    
    while bot_running and getInvCount(target_id) < required_inv do
        did_hunt = true
        local current = getInvCount(target_id)
        local needed = required_inv - current
        Log("Need " .. needed .. " more of " .. getItemNameSafely(target_id) .. " in inventory. Hunting drops...")
        
        local found_in_world = false
        local objs = getObjectList()
        
        if objs then
            for _, obj in pairs(objs) do
                local oid = obj.itemid or obj.id
                if oid == target_id then
                    local ox = math.floor((obj.pos.x or obj.x) / 32)
                    local oy = math.floor((obj.pos.y or obj.y) / 32)
                    
                    if type(FindPath) == "function" then FindPath(ox, oy) end
                    _sleep(800) 
                    
                    local me = getLocal()
                    local px = math.floor((me.posX or me.posXenc or me.x) / 32)
                    local py = math.floor((me.posY or me.posYenc or me.y) / 32)
                    
                    for _, o in pairs(getObjectList()) do
                        if (o.itemid or o.id) == target_id then
                            local oox = math.floor((o.pos.x or o.x) / 32)
                            local ooy = math.floor((o.pos.y or o.y) / 32)
                            if math.abs(px - oox) <= 2 and math.abs(py - ooy) <= 2 then
                                local pkt = { type = 11, value = o.oid or o.id, x = me.posX, y = me.posY }
                                sendFunc(false, pkt)
                                _sleep(50)
                            end
                        end
                    end
                    _sleep(300)
                    found_in_world = true
                    break
                end
            end
        end
        
        if not found_in_world then
            Warn("Ran out of " .. getItemNameSafely(target_id) .. " in the world! Bot stopping gracefully.")
            bot_running = false
            bot_state = "IDLE"
            return false
        end
    end
    
    if bot_running and did_hunt then
        Log("Walking back to Offering Table...")
        if type(FindPath) == "function" then FindPath(start_x, start_y) end
        _sleep(1000)
    end
    return true
end

-- ----------------------------------------------------------------
--  DYNAMIC PER-SLOT FILLER ENGINE
-- ----------------------------------------------------------------
local function fillSlotsLogic(table_x, table_y)
    local safe_delay = math.max(delay_ms, 250) 

    local function alignAndWrench()
        local me = getLocal()
        local px = math.floor((me.posX or me.x)/32)
        local py = math.floor((me.posY or me.y)/32)
        if math.abs(px - table_x) > 1 or math.abs(py - table_y) > 1 then
            if type(FindPath) == "function" then FindPath(table_x, table_y) end
            _sleep(800)
        end
        received_altar_dialog = false
        Log("Wrenching Offering Table to verify slot configuration...")
        wrenchTile(table_x, table_y)
        
        local wait_t = 0
        while bot_running and not received_altar_dialog and wait_t < 30 do
            _sleep(100)
            wait_t = wait_t + 1
        end
    end

    alignAndWrench()

    local needs_config = false
    for i = 1, 10 do
        if not bot_running then break end
        local s = slots[i]
        local t = current_table_state[i]
        
        if s.id ~= t.id or s.count ~= t.count then
            needs_config = true
            
            if s.id ~= 0 and s.count > 0 then
                local required_inv = s.count
                if t.id == s.id then required_inv = s.count - t.count end
                
                if required_inv > 0 and getInvCount(s.id) < required_inv then
                    Log(string.format("Slot %d deficit! Need %d more %s (Slot already has %d).", i, required_inv, getItemNameSafely(s.id), t.count))
                    if not ensureInventory(s.id, required_inv, table_x, table_y) then return false end
                    alignAndWrench() 
                    t = current_table_state[i] 
                end
            end
            
            local slot_index = i - 1
            if type(SendPacket) == "function" then
                SendPacket(2, "action|dialog_return\ndialog_name|mooncake_altar_dialog\nbuttonClicked|slot_btn_"..slot_index)
                _sleep(safe_delay)
                
                if s.id == 0 then
                    if t.id ~= 0 then
                        SendPacket(2, "action|dialog_return\ndialog_name|mooncake_choose_dialog\nslot|"..slot_index.."|\nbuttonClicked|item_btn_"..t.id)
                        _sleep(safe_delay)
                        SendPacket(2, "action|dialog_return\ndialog_name|mooncake_count_dialog\nitemID|"..t.id.."|\nslot|"..slot_index.."|\nbuttonClicked|ok\ncount|0")
                        _sleep(safe_delay)
                    end
                else
                    SendPacket(2, "action|dialog_return\ndialog_name|mooncake_choose_dialog\nslot|"..slot_index.."|\nbuttonClicked|item_btn_"..s.id)
                    _sleep(safe_delay)
                    SendPacket(2, "action|dialog_return\ndialog_name|mooncake_count_dialog\nitemID|"..s.id.."|\nslot|"..slot_index.."|\nbuttonClicked|ok\ncount|"..s.count)
                    _sleep(safe_delay)
                end
            end
        end
    end
    
    if needs_config then
        Log("`2Slots synchronized! Verifying final table state...`o")
        _sleep(safe_delay)
        alignAndWrench() 
        _sleep(safe_delay)
    else
        Log("`2Table configuration perfectly matches target! Proceeding directly.`o")
    end

    return bot_running
end

-- ----------------------------------------------------------------
--  MAIN OFFERING SEQUENCE
-- ----------------------------------------------------------------
local function mainOfferingLoop()
    Log("Scanning for Offering Table in the world...")
    local table_x, table_y = findOfferingTable()
    if not table_x or not table_y then
        Warn("Offering Table not found in this world! (Target ID: " .. OFFERING_TABLE_ID .. ")")
        bot_running = false
        bot_state = "IDLE"
        return
    end

    Log("Offering Table found at X: " .. table_x .. ", Y: " .. table_y)
    if type(FindPath) == "function" then FindPath(table_x, table_y) end
    _sleep(1000)

    if not fillSlotsLogic(table_x, table_y) then return end

    Log("Fetching possible rewards for your current mooncake configuration...")
    bot_state = "WAITING_REWARDS_LIST"
    if type(SendPacket) == "function" then
        SendPacket(2, "action|dialog_return\ndialog_name|mooncake_altar_dialog\nbuttonClicked|reward_list_btn")
    end

    local wait_timeout = 0
    while bot_running and (bot_state == "WAITING_REWARDS_LIST" or bot_state == "SELECTING_REWARDS") do
        _sleep(100)
        wait_timeout = wait_timeout + 1
        if wait_timeout > 150 and bot_state == "WAITING_REWARDS_LIST" then
            Warn("Server did not send reward list. Ensure table is correctly placed.")
            bot_running = false
            bot_state = "IDLE"
            return
        end
    end

    while bot_running do
        if bot_state == "OFFERING" then
            local timeout = 0
            while awaiting_reward and bot_running and timeout < 100 do 
                _sleep(100)
                timeout = timeout + 1
            end
            
            if timeout >= 100 then
                Warn("Reward dialog timeout. Continuing cycle anyway.")
                awaiting_reward = false
            end
            
            if not bot_running then break end
            _sleep(500)
            
            if not fillSlotsLogic(table_x, table_y) then break end
            
            Log("Offering mooncakes to the Moon...")
            awaiting_reward = true
            if type(SendPacket) == "function" then
                SendPacket(2, "action|dialog_return\ndialog_name|mooncake_altar_dialog\nbuttonClicked|offer_btn")
            end
        end
        _sleep(100)
    end
end

-- ----------------------------------------------------------------
--  UI MODULE ENGINE
-- ----------------------------------------------------------------
local registerModule 

registerModule = function()
    local ui = UserInterface.new(SCRIPT_NAME, "12598") 
    ui:addLabelApp("Mooncake Altar Bot", "12598")
    ui:addDivider()
    
    if not keyVerified then
        ui:addLabel("License Locked")
        ui:addDisplayList("Status", "UNVERIFIED (LOCKED)", "module_key_status")
        ui:addButton("Unlock In-Game", "btn_verify")
    else
        ui:addButton("START AUTO OFFERING", "btn_start")
        ui:addButton("STOP", "btn_stop")
        
        ui:addDivider()
        ui:addSlider("Global Delay (ms)", 100, 2000, delay_ms, 100, false, "delay_ms")
        
        ui:addDivider()
        ui:addLabel("Mooncake Slots Configuration:")
        ui:addButton("Configure Slots (Visual UI)", "btn_visual_cfg")
    end

    local jsonStr = ui:generateJSON()
    if jsonStr then
        pcall(function() addCategory("Scripts", "gear") end)
        pcall(function() addIntoModule(jsonStr, "Scripts") end)
    end
end

-- ----------------------------------------------------------------
--  PACKET INTERCEPTORS (DIALOG HANDLER)
-- ----------------------------------------------------------------
local function onPacket(pktType, pkt)
    if type(pkt) ~= "string" then return false end
    
    if pktType == 2 and pkt:find("action|dialog_return") then
        
        if pkt:find("dialog_name|mooncake_auth") and pkt:find("buttonClicked|btn_verify_key") then
            local input = pkt:match("key_input|([^\n]+)")
            if input and input:gsub("^%s+", ""):gsub("%s+$", "") == KEY then
                keyVerified = true
                saveKey()
                Log("Key Verified! Module unlocked.")
                if type(registerModule) == "function" then registerModule() end
            else
                Warn("Wrong Key! Try again.")
                openKeyDialog()
            end
            return true 
        end
        
        if pkt:find("dialog_name|visual_cfg_dlg") then
            local clicked = pkt:match("buttonClicked|cfg_slot_(%d+)")
            if clicked then
                current_editing_slot = tonumber(clicked)
                openCakeSelectDialog()
            end
            return true
        end

        if pkt:find("dialog_name|cake_select_dlg") then
            local clicked = pkt:match("buttonClicked|setcake_(%d+)")
            if clicked then
                slots[current_editing_slot].id = tonumber(clicked) or 0
                saved:set("slots", slots)
                saved:save()
                
                if slots[current_editing_slot].id ~= 0 then
                    openCakeAmountDialog()
                else
                    slots[current_editing_slot].count = 0
                    saved:set("slots", slots)
                    saved:save()
                    openVisualConfigDialog()
                end
            end
            return true
        end

        if pkt:find("dialog_name|cake_amount_dlg") then
            local amount_str = pkt:match("cake_amount|([^|\r\n]*)")
            if amount_str then
                local amount = tonumber(amount_str) or 0
                if amount > 200 then amount = 200 end
                slots[current_editing_slot].count = amount
                saved:set("slots", slots)
                saved:save()
                Log("Slot " .. current_editing_slot .. " updated!")
                openVisualConfigDialog()
            end
            return true
        end
        
        if pkt:find("dialog_name|custom_reward_selector") then
            if pkt:find("buttonClicked|btn_save_rewards") then
                desired_rewards = {} 
                for id, state in pkt:gmatch("keep_(%d+)|([01])") do
                    if state == "1" then desired_rewards[tonumber(id)] = true end
                end
                
                if not hasDesiredRewards() then
                    Log("`3U NOT SELECT ANY PRIZE, U WILL AUTO CLAIM FIRST PRIZE THAT COME")
                    runCoroutine(function()
                        local wait_ticks = 0
                        while bot_running and wait_ticks < 50 do 
                            _sleep(100)
                            wait_ticks = wait_ticks + 1
                        end
                        if bot_running then
                            Log("Proceeding with auto-claim mode...")
                            awaiting_reward = false
                            bot_state = "OFFERING"
                        end
                    end)
                else
                    Log("Target rewards saved! Proceeding to auto-offer...")
                    awaiting_reward = false
                    bot_state = "OFFERING"
                end
            else
                bot_running = false
                bot_state = "IDLE"
                Log("Reward selection cancelled. Engine stopped.")
            end
            return true
        end
    end
    return false
end

local function onVariant(var, pkt)
    -- PRIZE DETECTION & WEBHOOK RADAR
    if var and var.v1 == "OnConsoleMessage" and var.v2 and bot_running then
        local msg = var.v2:gsub("`.", "") 
        local amount, item = msg:match("You received (%d+) (.-) from the Offering Table")
        if not item then
            item = msg:match("You received (.-) from the Offering Table")
        end
        
        if item then
            item = item:gsub("%.$", "") 
            item = item:match("^%s*(.-)%s*$")
            last_rolled_item_name = item
            
            -- ABSOLUTE WEBHOOK FILTER
            local is_epic_chosen = false
            for id, _ in pairs(desired_rewards) do
                local d_name = getItemNameSafely(id)
                if d_name and d_name:lower() == item:lower() then
                    is_epic_chosen = true
                    break
                end
            end
            
            if is_epic_chosen and WEBHOOK_EPIC_ITEMS[item:lower()] then
                sendWebhookPrize(item)
            end
            
            if awaiting_reward and not hasDesiredRewards() then
                awaiting_reward = false 
            end
        end
    end

    if var and var.v1 == "OnDialogRequest" then
        local msg = var.v2
        
        if msg:find("mooncake_altar_dialog") then
            received_altar_dialog = true
            for slot_idx, item_id, count_str in msg:gmatch("add_button_with_icon|slot_btn_(%d+)|[^|]*|frame|(%d+)|([^|]*)|") do
                local idx = tonumber(slot_idx) + 1
                local c_id = tonumber(item_id) or 0
                local c_count = tonumber(count_str) or 0
                
                if not is_valid_mooncake(c_id) then
                    c_id = 0
                    c_count = 0
                end
                
                if idx >= 1 and idx <= 10 then
                    current_table_state[idx] = { id = c_id, count = c_count }
                end
            end
            
            if bot_running then return true end
        end
        
        if bot_running and (msg:find("mooncake_choose_dialog") or msg:find("mooncake_count_dialog")) then
            return true
        end
        
        if msg:find("mooncake_reward_list_dialog") and bot_state == "WAITING_REWARDS_LIST" then
            bot_state = "SELECTING_REWARDS"
            
            local custom_dlg = "set_default_color|`o\nadd_label_with_icon|big|`9Select Target Rewards``|left|12598|\nadd_spacer|small|\n"
            
            for line in msg:gmatch("[^\r\n]+") do
                if line:find("add_textbox|Epic") or line:find("add_textbox|Rare") or line:find("add_textbox|Uncommon") or line:find("add_textbox|Common") then
                    custom_dlg = custom_dlg .. line .. "\n"
                elseif line:find("add_label_with_icon|small|") then
                    local item_str = line:match("add_label_with_icon|small|`w(.-)``|left|")
                    local name = item_str
                    if name then
                        local cleaned = name:match("%d+ x (.*)")
                        if cleaned then name = cleaned end
                    end
                    local id = line:match("|(%d+)|")
                    if name and id then
                        custom_dlg = custom_dlg .. "add_label_with_icon|small|`w" .. name .. "``|left|" .. id .. "|\n"
                        custom_dlg = custom_dlg .. "add_checkbox|keep_"..id.."|Select this reward|0|\n"
                    end
                end
            end
            custom_dlg = custom_dlg .. "add_spacer|small|\n"
            custom_dlg = custom_dlg .. "add_button|btn_save_rewards|Save & Start Offering|noflags|0|0|\n"
            custom_dlg = custom_dlg .. "add_button|btn_cancel_rewards|Cancel|noflags|0|0|\n"
            custom_dlg = custom_dlg .. "end_dialog|custom_reward_selector||\n"
            sendDialog(custom_dlg)
            return true
        end
        
        -- DYNAMIC DIALOG INTERCEPTOR (BRUTAL SIMPLE LOGIC)
        if awaiting_reward and msg:find("end_dialog|([^|]+)|") then
            local dialog_name = msg:match("end_dialog|([^|]+)|")
            
            if dialog_name and not dialog_name:find("mooncake_altar_dialog") and not dialog_name:find("mooncake_choose_dialog") and not dialog_name:find("mooncake_count_dialog") and not dialog_name:find("mooncake_reward_list_dialog") and not dialog_name:find("custom_reward_selector") then
                
                local keep_btn = msg:match("add_button|([^|]+)|[^|]*Claim") or msg:match("add_button|([^|]+)|[^|]*Keep") or msg:match("add_button|([^|]+)|[^|]*Take") or "take_reward"
                local reroll_btn = msg:match("add_button|([^|]+)|[^|]*Reroll") or msg:match("add_button|([^|]+)|[^|]*Try")
                
                local clean_msg = msg:gsub("`.", "")
                local item_str = msg:match("add_label_with_icon|small|`w(.-)``|left|") or clean_msg:match("add_label_with_icon|small|(.-)|left|")
                local current_item = nil
                
                if item_str then
                    current_item = item_str:match("%d+ x (.*)") or item_str
                    current_item = current_item:match("^%s*(.-)%s*$")
                end
                
                if not current_item or current_item == "" then
                    current_item = last_rolled_item_name or "Unknown Item"
                end
                
                local is_target = false
                for id, _ in pairs(desired_rewards) do
                    local d_name = getItemNameSafely(id)
                    if d_name and current_item and d_name:lower() == current_item:lower() then
                        is_target = true
                        break
                    end
                end

                if not hasDesiredRewards() or is_target or not reroll_btn then
                    if not is_target and not reroll_btn and hasDesiredRewards() then
                        Log("Out of rerolls! Forced to claim: " .. current_item)
                    else
                        Log("Target Found! Claiming: " .. current_item)
                    end
                    if type(SendPacket) == "function" then
                        SendPacket(2, "action|dialog_return\ndialog_name|"..dialog_name.."\nbuttonClicked|"..keep_btn)
                    end
                    awaiting_reward = false
                    last_rolled_item_name = nil
                else
                    Log("Rerolling... (Got: " .. current_item .. ")")
                    if type(SendPacket) == "function" then
                        SendPacket(2, "action|dialog_return\ndialog_name|"..dialog_name.."\nbuttonClicked|"..reroll_btn)
                    end
                end
                return true
            end
        end
    end
    return false
end

local function onUIEvent(_, name, value)
    if name == "btn_verify" then
        openKeyDialog()
        return
    end

    if not keyVerified then return end

    if name == "btn_start" then
        if not bot_running then
            bot_running = true
            bot_state = "INIT_SLOTS"
            desired_rewards = {} 
            Log("Initializing Offering Table Sequence...")
            runCoroutine(mainOfferingLoop)
        end
    elseif name == "btn_stop" then
        if bot_running then
            bot_running = false
            bot_state = "IDLE"
            awaiting_reward = false
            Log("Engine Stopped.")
        end
    elseif name == "delay_ms" then
        delay_ms = tonumber(value) or 700
        saved:set("delay_ms", delay_ms)
        saved:save()
    elseif name == "btn_visual_cfg" then
        openVisualConfigDialog()
    end
end

-- ----------------------------------------------------------------
--  INIT HOOKING
-- ----------------------------------------------------------------
pcall(function() removeHook("onFarmVariant") end)
pcall(function() removeHook("onFarmUIEvent") end)
pcall(function() removeHook("onFarmPacket") end)

addHook(onVariant, "onVariant")
addHook(onUIEvent, "onValue")
addHook(onPacket, "OnSendPacket")
addHook(onPacket, "onSendPacket")

if type(applyHook) == "function" then pcall(function() applyHook() end) end

registerModule()
if keyVerified then
    Log("Loaded! Module active.")
else
    Log("Loaded! Click 'Unlock In-Game' to start.")
end