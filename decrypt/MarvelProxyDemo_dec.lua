local y = "https://linktr.ee/MarvelProxy"
local r = LogToConsole or logToConsole or log
local e = SendVariant or sendVariant
local function K(y)
  if r then
    pcall(r, tostring(y))
  end
end
local function Q()
  K("`0[ `wMarvelus`3Proxy `0] `4DEMO version `9- this feature is not active. `2Buy the real one: `w" .. y)
end
local i = {}
i["main"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`2       Main        |staticYellowFrame|1790|\nadd_button_with_icon|proxy_tab_world|`w      World       |staticBlueFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`w    Wrench     |staticBlueFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`w Growscan  |staticBlueFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`w   Farming    |staticBlueFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`w    Storage     |staticBlueFrame|1452|\nadd_button_with_icon|proxy_tab_others|`w     Others      |staticBlueFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_spacer|small|\nadd_label_with_icon|big|`wMarvelus`3Proxy `9Main Commands|left|5956|\nadd_spacer|small|\nadd_button|proxy_bar_info|`9World : `3DEMO `0- `9X : `30 `9Y : `30 `0- `9Ping : `30 ms|off|0|0|\nadd_button|proxy_bar_toggle|`4Toggle `0( `9tick, then press `2Apply `0)|off|0|0|\nadd_checkbox|chk_modfly|`9Mod-Fly `0(/modfly)|0|\nadd_checkbox|chk_autosurg|`9Auto-Surg `0(/autosurg)|0|\nadd_checkbox|chk_autocollect|`9Auto-Collect `0(/autocollect)|0|\nadd_checkbox|chk_fd|`9Fast Drop `0(/fd)|0|\nadd_checkbox|chk_ft|`9Fast Trash `0(/ft)|0|\nadd_checkbox|chk_nopickup|`9Anti-Pickup `0(/nopickup)|0|\nadd_checkbox|chk_blink|`9Blink Skin `0(/blink)|0|\nadd_button|proxy_main_apply|`2Apply|noflags|0|0|\nadd_spacer|small|\nadd_button|proxy_bar_auto|`4Automation|off|0|0|\nadd_smalltext|`9/autosurghelper `0or `2/autosh `0- `3Enable / Disable surg helper|left|\nadd_smalltext|`9/autocrime `0or `2/autoc `0- `3Enable / Disable auto-crime|left|\nadd_smalltext|`9/autostartopia `0or `2/autost `0- `3Enable / Disable auto-startopia|left|\nadd_spacer|small|\nadd_button|proxy_bar_move|`4Movement|off|0|0|\nadd_smalltext|`9/findpath `8[x] [y] `0- `3Teleport to x,y|left|\nadd_smalltext|`9/player `8[name] `0- `3Teleport to player|left|\nadd_smalltext|`9/door `8[id] `0- `3Enter door by id|left|\nadd_smalltext|`9/rndm `0- `3Warp to random world|left|\nadd_smalltext|`9/ccollect `0or `2/cc `8[range] `0- `3Collect items in custom range|left|\nadd_smalltext|`9/pickup `8[id] `0- `3Pick up only 1 item|left|\nadd_spacer|small|\nadd_button|proxy_bar_eco|`4Economy|off|0|0|\nadd_smalltext|`9/balance `0- `3Total locks in inventory|left|\nadd_smalltext|`9/buywl `0- `3Buy WL with all gems|left|\nadd_smalltext|`9/dropall `0- `3Drop all items `4(shadowban risk)|left|\nadd_smalltext|`9/visualspin `8[number] `0- `3Set visual spin|left|\nadd_smalltext|`9/spinall `0- `3Spin all wheels in world|left|\nadd_spacer|small|\nadd_button|proxy_bar_util|`4Utility|off|0|0|\nadd_smalltext|`9/info `0- `3Status of all commands|left|\nadd_smalltext|`9/commands `0- `3Shortcut to all proxy commands|left|\nadd_smalltext|`9/ping `0& `9/xy `0- `3Show ping & x,y position|left|\nadd_smalltext|`9/res `0& `9/relog `0- `3Fast respawn & fast relog|left|\nadd_smalltext|`9/warn `8[text] `0- `3Custom warning to yourself|left|\nadd_smalltext|`9/fakeban `0- `3Fake permanent ban from system|left|\nadd_smalltext|`9/fire ban `0- `3Auto-ban troller (fire lighter)|left|\nadd_smalltext|`9/testmod `0- `3Test what happens if a mod joins|left|\nadd_smalltext|`9/cid `0- `3Create a new account|left|\nadd_smalltext|`9/fc `0- `3Force close proxy|left|\nadd_spacer|small|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
i["world"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`w       Main        |staticBlueFrame|1790|\nadd_button_with_icon|proxy_tab_world|`2      World       |staticYellowFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`w    Wrench     |staticBlueFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`w Growscan  |staticBlueFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`w   Farming    |staticBlueFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`w    Storage     |staticBlueFrame|1452|\nadd_button_with_icon|proxy_tab_others|`w     Others      |staticBlueFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_label_with_icon|small|`3World Commands``|left|3802|\nadd_spacer|small|\nadd_smalltext|`9Command : `!/World|left|\nadd_spacer|small|\nadd_smalltext|`2Shortcuts :|left|\nadd_smalltext|`9/pullall `0- `3pull all players in world|left|\nadd_smalltext|`9/kickall `0- `3kick all players in world|left|\nadd_smalltext|`9/banall `0- `3ban all players in world|left|\nadd_smalltext|`9/tradeall `0- `3trade all players in world|left|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
i["wrench"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`w       Main        |staticBlueFrame|1790|\nadd_button_with_icon|proxy_tab_world|`w      World       |staticBlueFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`2    Wrench     |staticYellowFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`w Growscan  |staticBlueFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`w   Farming    |staticBlueFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`w    Storage     |staticBlueFrame|1452|\nadd_button_with_icon|proxy_tab_others|`w     Others      |staticBlueFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_label_with_icon|small|`3Wrench Commands|left|32|\nadd_spacer|small|\nadd_button|proxy_bar_proxy_wrench_apply|`4Toggle `0( `9tick, then press `2Apply `0)|off|0|0|\nadd_checkbox|chk_wm_pull|`9Wrench Pull `0(/wp)|0|\nadd_checkbox|chk_wm_kick|`9Wrench Kick `0(/wk)|0|\nadd_checkbox|chk_wm_ban|`9Wrench Ban `0(/wb)|0|\nadd_button|proxy_wrench_apply|`2Apply|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2How to turn off :|left|\nadd_smalltext|`9/woff `0- `3turn wrench mode off|left|\nadd_smalltext|`9Untick all `0- `3then press `2Apply|left|\nadd_spacer|small|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
i["growscan"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`w       Main        |staticBlueFrame|1790|\nadd_button_with_icon|proxy_tab_world|`w      World       |staticBlueFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`w    Wrench     |staticBlueFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`2 Growscan  |staticYellowFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`w   Farming    |staticBlueFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`w    Storage     |staticBlueFrame|1452|\nadd_button_with_icon|proxy_tab_others|`w     Others      |staticBlueFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_label_with_icon|small|`3Growscan Commands``|left|6016|\nadd_spacer|small|\nadd_smalltext|`9Command : `!/gs or /growscan|left|\nadd_spacer|small|\nadd_smalltext|`2Shortcuts :|left|\nadd_smalltext|`9/growscan 1 or /gs 1 `0- `3scan placed blocks|left|\nadd_smalltext|`9/growscan 2 or /gs 2 `0- `3scan dropped items|left|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
i["farming"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`w       Main        |staticBlueFrame|1790|\nadd_button_with_icon|proxy_tab_world|`w      World       |staticBlueFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`w    Wrench     |staticBlueFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`w Growscan  |staticBlueFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`2   Farming    |staticYellowFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`w    Storage     |staticBlueFrame|1452|\nadd_button_with_icon|proxy_tab_others|`w     Others      |staticBlueFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_label_with_icon|small|`3Farming Commands``|left|6950|\nadd_spacer|small|\nadd_smalltext|`9Command : `!/ut|left|\nadd_spacer|small|\nadd_smalltext|`2Shortcuts :|left|\nadd_smalltext|`9/ut add or /ua `0- `3turn on fast ut adder|left|\nadd_smalltext|`9/ut empty or /ue `0- `3turn on fast ut emptier|left|\nadd_smalltext|`9/ut off or /uoff `0- `3turn off ut mode|left|\nadd_spacer|small|\nadd_smalltext|`9Command : `!/gaia|left|\nadd_spacer|small|\nadd_smalltext|`2Shortcuts :|left|\nadd_smalltext|`9/gaia add or /ga `0- `3turn on fast gaia adder|left|\nadd_smalltext|`9/gaia empty or /ge `0- `3turn on fast gaia emptier|left|\nadd_smalltext|`9/gaia off or /goff `0- `3turn off gaia mode|left|\nadd_spacer|small|\nadd_spacer|small|\nadd_label_with_icon|small|`3Spam Commands``|left|6272|\nadd_spacer|small|\nadd_smalltext|`9/spamtext or /spamt [`9 text `0] `0- `3set a text to spam|left|\nadd_smalltext|`9/spamdelay or /sd [`9 delay `0] `0- `3set delay in seconds|left|\nadd_smalltext|`9// `0- `3start / stop spam|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Harvest Commands``|left|1830|\nadd_spacer|small|\nadd_smalltext|`9/harvestid [`9 id `0] `0- `3set a seed id|left|\nadd_smalltext|`9/harvestdelay [`9 delay `0] `0- `3set a delay in ms|left|\nadd_smalltext|`9/hv `0- `3start / stop harvest|left|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
i["storage"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`w       Main        |staticBlueFrame|1790|\nadd_button_with_icon|proxy_tab_world|`w      World       |staticBlueFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`w    Wrench     |staticBlueFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`w Growscan  |staticBlueFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`w   Farming    |staticBlueFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`2    Storage     |staticYellowFrame|1452|\nadd_button_with_icon|proxy_tab_others|`w     Others      |staticBlueFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_label_with_icon|small|`3Donation Box Commands``|left|1452|\nadd_spacer|small|\nadd_smalltext|`9Command : `!/donation|left|\nadd_spacer|small|\nadd_smalltext|`2Shortcuts :|left|\nadd_smalltext|`9/donation empty or /de `0- `3fast empty donation box|left|\nadd_smalltext|`9/donation add or /da `0- `3fast add donation box|left|\nadd_smalltext|`9/donation off or /doff `0- `3turn off donation box mode|left|\nadd_spacer|small|\nadd_smalltext|`!Trick Commands :|left|\nadd_smalltext|`9/donatewl [`9 amount `0] `0- `3fake donate amount of wls|left|\nadd_smalltext|`9/donatedl [`9 amount `0] `0- `3fake donate amount of dls|left|\nadd_smalltext|`9/donatebgl [`9 amount `0] `0- `3fake donate amount of bgls|left|\nadd_spacer|small|\nadd_spacer|small|\nadd_label_with_icon|small|`3Vend Commands``|left|2978|\nadd_spacer|small|\nadd_smalltext|`9/ve `0- `3fast empty vend|left|\nadd_smalltext|`9/va `0- `3fast stocker vend|left|\nadd_smalltext|`9/vb [`9 amount `0] `0- `3fast buy from vend|left|\nadd_smalltext|`9/voff `0- `3turn off vend mode|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Safe Commands``|left|278|\nadd_spacer|small|\nadd_smalltext|`9/safe 1 `0- `3collect & ban all & unacces & leave|left|\nadd_smalltext|`9/safe 2 `0- `3collect & unacces & leave|left|\nadd_smalltext|`9/safe 3 `0- `3collect & leave|left|\nadd_smalltext|`9/safe off `0- `3turns off safe commands|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Bypass Safe Vault Commands``|left|8878|\nadd_spacer|small|\nadd_smalltext|`9/vault `0- `3set x and y for vault pos|left|\nadd_smalltext|`9/bypass `0- `3auto bypass vault|left|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
i["others"] =
  "set_default_color|`o\nset_bg_color|8,28,70,235|\nset_border_color|70,170,255,255|\nadd_button_with_icon|proxy_tab_main|`w       Main        |staticBlueFrame|1790|\nadd_button_with_icon|proxy_tab_world|`w      World       |staticBlueFrame|3802|\nadd_button_with_icon|proxy_tab_wrench|`w    Wrench     |staticBlueFrame|32|\nadd_button_with_icon|proxy_tab_growscan|`w Growscan  |staticBlueFrame|6016|\nadd_button_with_icon|proxy_tab_farming|`w   Farming    |staticBlueFrame|6950|\nadd_button_with_icon|proxy_tab_storage|`w    Storage     |staticBlueFrame|1452|\nadd_button_with_icon|proxy_tab_others|`2     Others      |staticYellowFrame|758|\nadd_button_with_icon||END_LIST|noflags|0|0|\nadd_spacer|small|\nadd_label_with_icon|big|`4PROXY FOR DEMO|left|5956|\nadd_smalltext|`9Display only - features are `4not active `9in this demo.|left|\nadd_smalltext|`9Proxy by `3RZKAELAH|left|\nadd_url_button||`whttps://linktr.ee/MarvelProxy|noflags|https://linktr.ee/MarvelProxy|Open Marvel Proxy link?|0|0|\nadd_smalltext|`9Want the real one? `2Press the link above `9to buy!|left|\nadd_spacer|small|\nadd_custom_break|\nadd_label_with_icon|small|`3Join Commands|left|6|\nadd_spacer|small|\nadd_button|proxy_bar_proxy_join_apply|`4Toggle `0( `9tick, then press `2Apply `0)|off|0|0|\nadd_checkbox|chk_j_pull|`9Join Pull `0(/j pull)|0|\nadd_checkbox|chk_j_kick|`9Join Kick `0(/j kick)|0|\nadd_checkbox|chk_j_ban|`9Join Ban `0(/j ban)|0|\nadd_button|proxy_join_apply|`2Apply|noflags|0|0|\nadd_spacer|small|\nadd_smalltext|`2How to turn off :|left|\nadd_smalltext|`9/j off `0- `3turn join mode off|left|\nadd_smalltext|`9Untick all `0- `3then press `2Apply|left|\nadd_spacer|small|\nadd_spacer|small|\nadd_label_with_icon|small|`3Blackjack ( BJ ) Commands``|left|1796|\nadd_spacer|small|\nadd_smalltext|`2Setup ( once ) :|left|\nadd_smalltext|`9/setpos1 `0- `3stand at player 1, type it|left|\nadd_smalltext|`9/setpos2 `0- `3stand at player 2, type it|left|\nadd_smalltext|`9/setpos3 , /setpos4 `0- `3extra spots `0[ `8Optional `0]|left|\nadd_smalltext|`9/setposback `0- `3your home spot `0[ `8Optional `0]|left|\nadd_smalltext|`9/settax [`9 % `0] `0- `3e.g. /settax 5 or /settax 2,5|left|\nadd_smalltext|`9/side1 - /side4 [`9 left / right `0] `0- `3drop side per spot|left|\nadd_spacer|small|\nadd_smalltext|`2Every round :|left|\nadd_smalltext|`9/tax `0- `3collect locks & calculate tax|left|\nadd_smalltext|`9/w1 `0- `3pay winner at pos 1|left|\nadd_smalltext|`9/w2 `0- `3pay winner at pos 2|left|\nadd_smalltext|`9/w3 , /w4 `0- `3pay winner at pos 3 / 4|left|\nadd_smalltext|`9/gd `0- `3drop game, pay here where you stand|left|\nadd_smalltext|`2Tax stays in your backpack.|left|\nadd_spacer|small|\nadd_smalltext|`2Extra :|left|\nadd_smalltext|`9/pos1 - /pos4 `0- `3go to spot 1 - 4|left|\nadd_smalltext|`9/back `0- `3go to home spot|left|\nadd_smalltext|`9/collect or /tp `0- `3collect only|left|\nadd_smalltext|`9/win1 - /win4 , /dt1 - /dt4 `0- `3same as /w1 - /w4|left|\nadd_smalltext|`9/arroz [`9 amount `0] `0- `3drop arroz, no amount = drop all|left|\nadd_smalltext|`9/autobgl `0- `3on / off auto change 100 DL to BGL at telephone|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Gem Tile Commands``|left|112|\nadd_spacer|small|\nadd_smalltext|`9/gc `0- `3see total gems collected|left|\nadd_smalltext|`9/gems `0- `3total gems dropped in world|left|\nadd_smalltext|`9/sg `0- `3show gems per punch|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Host Commands``|left|758|\nadd_spacer|small|\nadd_smalltext|`9/spin qq `0- `3check qq spin|left|\nadd_smalltext|`9/spin reme `0- `3check reme spin|left|\nadd_smalltext|`9/spin all `0- `3check reme and qq spin|left|\nadd_smalltext|`9/dialog `0- `3show / block drop dialog|left|\nadd_smalltext|`9/daw `0- `3drop all wls, dls & bgls in backpack|left|\nadd_smalltext|`9/sethost [`9 world `0] `0- `3set a host world|left|\nadd_smalltext|`9/setsave [`9 world `0] `0- `3set a save world|left|\nadd_smalltext|`9/host `0- `3warp to host world|left|\nadd_smalltext|`9/save `0- `3warp to save world|left|\nadd_smalltext|`9/drop [`9 amount `0] `0( /drop 120 ( 1 dl & 20 wls) |left|\nadd_smalltext|`9/cd [`9 amount `0] `0- `3custom drop wls & dl|left|\nadd_smalltext|`9/dd [`9 amount `0] `0- `3drop dl|left|\nadd_smalltext|`9/db [`9 amount `0] `0- `3drop bgl|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Titles Commands``|left|6276|\nadd_spacer|small|\nadd_smalltext|`9Command : `!/titles|left|\nadd_spacer|small|\nadd_smalltext|`2Shortcuts :|left|\nadd_smalltext|`9/master `0- `3master title|left|\nadd_smalltext|`9/g4g `0- `3grow for good title|left|\nadd_smalltext|`9/doctor `0- `3doctor title|left|\nadd_smalltext|`9/maxlevel `0- `3max level title|left|\nadd_smalltext|`9/oflegend or /legend `0- `3of legend title|left|\nadd_smalltext|`9/title reset `0- `3reset titles to normal|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Visual Clothes``|left|1784|\nadd_spacer|small|\nadd_smalltext|`9/saveclothe or /sc `0- `3wear set when joining world|left|\nadd_smalltext|`9/vhat [`9 id `0] `0- `3set visual hat|left|\nadd_smalltext|`9/vshirt [`9 id `0] `0- `3set visual shirt|left|\nadd_smalltext|`9/vpant [`9 id `0] `0- `3set visual pant|left|\nadd_smalltext|`9/vshoes [`9 id `0] `0- `3set visual shoes|left|\nadd_smalltext|`9/vhand [`9 id `0] `0- `3set visual hand|left|\nadd_smalltext|`9/vwing [`9 id `0] `0- `3set visual wings|left|\nadd_smalltext|`9/vhair [`9 id `0] `0- `3set visual hair|left|\nadd_smalltext|`9/vneck [`9 id `0] `0- `3set visual neck|left|\nadd_smalltext|`9/vances [`9 id `0] `0- `3set visual ances|left|\nadd_smalltext|`9/clothe x /clothes `0- `3wear visual set|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Visual Commands``|left|9228|\nadd_spacer|small|\nadd_smalltext|`9/flag [`9 id `0]|left|\nadd_smalltext|`9/guild [`9 id `0]|left|\nadd_smalltext|`9/weather `0- `3change weather to random|left|\nadd_smalltext|`9/give [`9 id `0] [`9 count `0]|left|\nadd_smalltext|`9/hide `0- `3hide all names incl. yours, /hide again = normal|left|\nadd_smalltext|`9/name [`9 name `0] `0- `3change your name, /name again = normal|left|\nadd_smalltext|`9/inv `0- `3make everyone invisible|left|\nadd_spacer|small|\nadd_label_with_icon|small|`3Logs Commands``|left|1796|\nadd_spacer|small|\nadd_smalltext|`9/logs `0- `3pilih `2History Lock `3/ `2History Roulette|left|\nadd_quick_exit|\nend_dialog|proxy_ui|`4Close|`2Okay|\n"
local P = {
  ["/arroz"] = true,
  ["/autobgl"] = true,
  ["/autoc"] = true,
  ["/autocollect"] = true,
  ["/autocrime"] = true,
  ["/autosh"] = true,
  ["/autost"] = true,
  ["/autostartopia"] = true,
  ["/autosurg"] = true,
  ["/autosurghelper"] = true,
  ["/back"] = true,
  ["/balance"] = true,
  ["/banall"] = true,
  ["/blink"] = true,
  ["/buywl"] = true,
  ["/bypass"] = true,
  ["/cc"] = true,
  ["/ccollect"] = true,
  ["/cd"] = true,
  ["/cid"] = true,
  ["/clothe"] = true,
  ["/clothes"] = true,
  ["/collect"] = true,
  ["/commands"] = true,
  ["/da"] = true,
  ["/daw"] = true,
  ["/db"] = true,
  ["/dd"] = true,
  ["/de"] = true,
  ["/dialog"] = true,
  ["/doctor"] = true,
  ["/doff"] = true,
  ["/donatebgl"] = true,
  ["/donatedl"] = true,
  ["/donatewl"] = true,
  ["/donation"] = true,
  ["/door"] = true,
  ["/drop"] = true,
  ["/dropall"] = true,
  ["/dt1"] = true,
  ["/dt2"] = true,
  ["/dt3"] = true,
  ["/dt4"] = true,
  ["/fakeban"] = true,
  ["/fc"] = true,
  ["/fd"] = true,
  ["/findpath"] = true,
  ["/fire"] = true,
  ["/flag"] = true,
  ["/ft"] = true,
  ["/g4g"] = true,
  ["/ga"] = true,
  ["/gaia"] = true,
  ["/gc"] = true,
  ["/gd"] = true,
  ["/ge"] = true,
  ["/gems"] = true,
  ["/give"] = true,
  ["/goff"] = true,
  ["/growscan"] = true,
  ["/gs"] = true,
  ["/guild"] = true,
  ["/harvestdelay"] = true,
  ["/harvestid"] = true,
  ["/hide"] = true,
  ["/host"] = true,
  ["/hv"] = true,
  ["/info"] = true,
  ["/inv"] = true,
  ["/j"] = true,
  ["/kickall"] = true,
  ["/legend"] = true,
  ["/logs"] = true,
  ["/master"] = true,
  ["/maxlevel"] = true,
  ["/modfly"] = true,
  ["/name"] = true,
  ["/nopickup"] = true,
  ["/oflegend"] = true,
  ["/pickup"] = true,
  ["/ping"] = true,
  ["/player"] = true,
  ["/pos1"] = true,
  ["/pos2"] = true,
  ["/pos3"] = true,
  ["/pos4"] = true,
  ["/pullall"] = true,
  ["/res"] = true,
  ["/rndm"] = true,
  ["/safe"] = true,
  ["/save"] = true,
  ["/saveclothe"] = true,
  ["/sc"] = true,
  ["/sd"] = true,
  ["/sethost"] = true,
  ["/setpos1"] = true,
  ["/setpos2"] = true,
  ["/setpos3"] = true,
  ["/setpos4"] = true,
  ["/setposback"] = true,
  ["/setsave"] = true,
  ["/settax"] = true,
  ["/sg"] = true,
  ["/side1"] = true,
  ["/side2"] = true,
  ["/side3"] = true,
  ["/side4"] = true,
  ["/spamdelay"] = true,
  ["/spamt"] = true,
  ["/spamtext"] = true,
  ["/spin"] = true,
  ["/spinall"] = true,
  ["/tax"] = true,
  ["/testmod"] = true,
  ["/title"] = true,
  ["/tp"] = true,
  ["/tradeall"] = true,
  ["/ua"] = true,
  ["/ue"] = true,
  ["/uoff"] = true,
  ["/ut"] = true,
  ["/va"] = true,
  ["/vances"] = true,
  ["/vault"] = true,
  ["/vb"] = true,
  ["/ve"] = true,
  ["/vhair"] = true,
  ["/vhand"] = true,
  ["/vhat"] = true,
  ["/visualspin"] = true,
  ["/vneck"] = true,
  ["/voff"] = true,
  ["/vpant"] = true,
  ["/vshirt"] = true,
  ["/vshoes"] = true,
  ["/vwing"] = true,
  ["/w1"] = true,
  ["/w2"] = true,
  ["/w3"] = true,
  ["/w4"] = true,
  ["/warn"] = true,
  ["/wb"] = true,
  ["/weather"] = true,
  ["/win1"] = true,
  ["/win2"] = true,
  ["/win3"] = true,
  ["/win4"] = true,
  ["/wk"] = true,
  ["/woff"] = true,
  ["/wp"] = true,
}
local o = "main"
local function B(y)
  if not i[y] then
    y = "main"
  end
  o = y
  if e then
    e({ ["v1"] = "OnDialogRequest", ["v2"] = i[y] }, nil, -1)
  end
end
local function E(y, r)
  if type(r) ~= "string" then
    return
  end
  local e = r:match("^action|input\n|text|(/[^ \n]*)")
  if e then
    e = e:lower()
    if e == "/proxy" or e == "/commands" then
      B("main")
      return true
    elseif P[e] then
      Q()
      return true
    end
    return
  end
  if r:find("dialog_name|proxy_ui", 1, true) then
    local y = r:match("buttonClicked|proxy_tab_(%w+)")
    if y then
      B(y)
      return true
    end
    if r:find("buttonClicked|proxy_", 1, true) then
      Q()
      B(o)
    end
    return true
  end
end
addHook(E, "onSendPacket")
K("`0[ `wMARVELUS`3PROXY `0] `4DEMO `9- type `3/proxy `9to open the menu !")
if e then
  e(
    { ["v1"] = "OnTalkBubble", ["v2"] = -1, ["v3"] = "`4Proxy DEMO `9loaded. Type /proxy", ["v4"] = 0, ["v5"] = 0 },
    nil,
    -1
  )
end
