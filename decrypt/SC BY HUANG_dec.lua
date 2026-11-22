local vendList = {}
local searchText = ""
local unlocked = false

local VEND_TILE_ID = 9268
local MAX_DISPLAY = 100
local PASSWORD = "Najidganteng"


-- =========================================
-- STARTUP
-- =========================================

sendNotification("SVEND MADE BY NAJIDXHUANG")


-- =========================================
-- LOGIN UI
-- =========================================

local function showLogin()

    local dialog = [[
set_default_color|`o
add_label_with_icon|big|`wSVEND MADE BY NAJIDXHUANG|left|9268|
add_spacer|small|
add_text_input|svend_password|Password||30|
add_button|svend_login|LOGIN|noflags|
add_quick_exit|
end_dialog|svend_login_dialog|CLOSE||
]]

    sendVariant({
        v1 = "OnDialogRequest",
        v2 = dialog
    })
end


-- =========================================
-- ITEM NAME
-- =========================================

local function getVendItemName(itemID)

    local info = getItemInfoByID(
        tonumber(itemID) or 0
    )

    if info and info.name then
        return tostring(info.name)
    end

    return "Unknown Item"
end


-- =========================================
-- SCAN VENDING
-- =========================================

local function scanVend()

    vendList = {}

    local tiles = getTiles()

    if not tiles then
        LogToConsole("`4Vending scan failed.")
        return
    end

    for _, tile in pairs(tiles) do

        if tonumber(tile.fg) == VEND_TILE_ID then

            if tile.extra then

                local itemID =
                    tonumber(tile.extra.vend_item)

                if itemID and itemID > 0 then

                    local price =
                        tonumber(
                            tile.extra.vend_price
                        ) or 0

                    table.insert(
                        vendList,
                        {
                            id = itemID,
                            name = getVendItemName(itemID),
                            price = price,
                            x = tonumber(tile.x) or 0,
                            y = tonumber(tile.y) or 0
                        }
                    )

                end
            end
        end
    end

    LogToConsole(
        "`wVending Found: `9" ..
        tostring(#vendList)
    )
end


-- =========================================
-- SEARCH RESULT
-- =========================================

local function getSearchResult()

    local result = {}

    local query =
        tostring(searchText or "")

    query =
        query:match("^%s*(.-)%s*$") or ""

    query = query:lower()


    -- SEARCH KOSONG
    if query == "" then

        for index, vend in ipairs(vendList) do

            if #result >= MAX_DISPLAY then
                break
            end

            table.insert(
                result,
                {
                    index = index,
                    vend = vend
                }
            )
        end

        return result
    end


    local searchID = tonumber(query)


    -- SEARCH SELURUH DATA
    for index, vend in ipairs(vendList) do

        if #result >= MAX_DISPLAY then
            break
        end

        local match = false

        local itemName =
            tostring(vend.name or ""):lower()


        -- SEARCH NAMA
        if itemName:find(
            query,
            1,
            true
        ) then

            match = true
        end


        -- SEARCH ID
        if searchID
            and tonumber(vend.id) == searchID then

            match = true
        end


        if match then

            table.insert(
                result,
                {
                    index = index,
                    vend = vend
                }
            )

        end
    end

    return result
end


-- =========================================
-- SVEND UI
-- =========================================

local function showSvend()

    if not unlocked then
        showLogin()
        return
    end


    local results =
        getSearchResult()


    local dialog = [[
set_default_color|`o
add_label_with_icon|big|`wSVEND MADE BY NAJIDXHUANG|left|9268|
add_spacer|small|
add_text_input|svend_search|Search Item|]] ..
        tostring(searchText or "") ..
        [[|30|
add_button|svend_search_btn|SEARCH|noflags|
add_spacer|small|
add_smalltext|`7Vending Found: `w]] ..
        tostring(#vendList) ..
        [[|
add_smalltext|`7Displayed: `w]] ..
        tostring(#results) ..
        [[|
add_spacer|small|
]]


    if #results == 0 then

        dialog = dialog ..
            "add_textbox|`4Item tidak ditemukan.|left|\n"

    else

        for _, data in ipairs(results) do

            local index = data.index
            local vend = data.vend

            local iconID =
                tonumber(vend.id) or 0


            dialog = dialog ..
                "add_label_with_icon|big|" ..
                "`w" ..
                tostring(vend.name) ..
                "|left|" ..
                tostring(iconID) ..
                "|\n"


            dialog = dialog ..
                "add_smalltext|`7Item ID: `w" ..
                tostring(vend.id) ..
                "|\n"


            dialog = dialog ..
                "add_smalltext|`7Price: `w" ..
                tostring(vend.price) ..
                "|\n"


            dialog = dialog ..
                "add_smalltext|`7Position: `w(" ..
                tostring(vend.x) ..
                "," ..
                tostring(vend.y) ..
                ")|\n"


            dialog = dialog ..
                "add_button|vend_path_" ..
                tostring(index) ..
                "|FIND PATH|noflags|\n"


            dialog = dialog ..
                "add_spacer|small|\n"
        end
    end


    dialog = dialog ..
        "add_spacer|small|\n" ..
        "add_button|svend_refresh|RESCAN|noflags|\n" ..
        "add_button|svend_close|CLOSE|noflags|\n" ..
        "add_quick_exit|\n" ..
        "end_dialog|svend_main|Close||"


    sendVariant({
        v1 = "OnDialogRequest",
        v2 = dialog
    })
end


-- =========================================
-- HOOK
-- =========================================

AddHook(function(type, str)

    if type ~= 2 or not str then
        return false
    end


    -- /SVEND
    if str:find(
        "/svend",
        1,
        true
    ) then

        if not unlocked then
            showLogin()
            return true
        end

        searchText = ""

        scanVend()
        showSvend()

        return true
    end


    -- DIALOG RETURN
    if str:find(
        "action|dialog_return",
        1,
        true
    ) then


        -- LOGIN
        if str:find(
            "buttonClicked|svend_login",
            1,
            true
        ) then

            local password =
                str:match(
                    "svend_password|([^\n]*)"
                ) or ""


            if password == PASSWORD then

                unlocked = true
                searchText = ""

                scanVend()
                showSvend()

            else

                showLogin()

            end

            return true
        end


        -- SEARCH
        if str:find(
            "buttonClicked|svend_search_btn",
            1,
            true
        ) then

            local value =
                str:match(
                    "svend_search|([^\n]*)"
                )

            if value then
                searchText = value
            else
                searchText = ""
            end

            showSvend()

            return true
        end


        -- RESCAN
        if str:find(
            "buttonClicked|svend_refresh",
            1,
            true
        ) then

            searchText = ""

            scanVend()
            showSvend()

            return true
        end


        -- FIND PATH
        local index =
            str:match(
                "buttonClicked|vend_path_(%d+)"
            )


        if index then

            index = tonumber(index)


            if index
                and vendList[index] then

                local vend =
                    vendList[index]


                LogToConsole(
                    "`w[ `2SVEND `w] `9— Made by NajidXhuang"
                )


                FindPath(
                    vend.x,
                    vend.y
                )

                return true
            end
        end


        -- CLOSE
        if str:find(
            "buttonClicked|svend_close",
            1,
            true
        ) then

            return true
        end

    end

    return false

end, "OnSendPacket")


-- =========================================
-- SHOW LOGIN
-- =========================================

showLogin()