local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_lib_209.lua"))()
assert(Lib.VERSION == "2.0.9-flat", "STALE: " .. tostring(Lib.VERSION))

local win = Lib.CreateWindow({ Title = "c0caine" })

-- combat tabs
local aim = win:Tab("Aimbot", { section = "combat" })
local sAim = aim:Sub("aim")
sAim:Group("Aimbot"):toggle("Aimbot", "aim_on", { desc = "master switch" })
sAim:Group("Aimbot"):toggle("Team check", "aim_team", {})
sAim:Group("Targeting"):cycle("Priority", "aim_prio", {"Closest", "Crosshair", "LowestHP"}, {})
sAim:Group("Targeting"):toggle("Sticky aim", "aim_sticky", {})
sAim:Group("Overlay"):toggle("Fov circle", "aim_fovc", {})
sAim:Group("Overlay"):slider("Circle size", "aim_size", 0, 300, 1, { unit = "px" })
local trig = aim:Sub("triggerbot")
trig:Group("Trigger"):toggle("Enabled", "trig_on", {})
trig:Group("Trigger"):slider("Delay", "trig_ms", 0, 300, 5, { unit = "ms" })
local wep = aim:Sub("weapon")
wep:Group("Weapon"):toggle("No spread", "w_spread", {})
wep:Group("Weapon"):toggle("No recoil", "w_recoil", {})
wep:Group("Weapon"):toggle("Rapid fire", "w_rapid", {})
wep:Group("Reload", { column = 2 }):toggle("Instant reload", "w_inst", {})
wep:Group("Reload", { column = 2 }):toggle("Auto reload", "w_auto", {})

local silent = win:Tab("Silent aim", { section = "combat" })
silent:Group("Silent"):toggle("Silent aim", "s_on", {})
silent:Group("Silent"):slider("Hit chance", "s_chance", 0, 100, 1, { unit = "%" })
silent:Group("Silent"):color("Accent", "s_col", {})
silent:Group("Silent"):keybind("Aim key", "s_key", {})

local rage = win:Tab("Ragebot", { section = "combat" })
rage:Group("Rage"):toggle("Enabled", "r_on", { danger = true })
rage:Group("Rage"):cycle("Position", "r_pos", {"None", "Magic bullet", "Autokill"}, {})

-- visuals tabs
local players = win:Tab("Players", { section = "visuals" })
players:Group("ESP"):toggle("Boxes", "e_boxes", {})
players:Group("ESP"):toggle("Names", "e_names", {})
players:Group("ESP"):multiselect("Hitboxes", "e_hits", {"Head", "Body", "Arms", "Legs"}, {})
local world = win:Tab("World", { section = "visuals" })
world:Group("World"):toggle("Crosshair", "w_cross", {})
world:Group("World"):textbox("Tag", "w_tag", { placeholder = "prefix" })
world:Group("World"):info("FPS", function() return math.floor(1 / task.wait()) end)

-- other tabs
local misc = win:Tab("Misc", { section = "other" })
misc:Group("Movement"):toggle("Speed", "m_speed", {})
misc:Group("Movement"):slider("Multiplier", "m_mult", 1, 3, 0.05, { unit = "x" })
local iface = win:Tab("Interface", { section = "other" })
iface:Group("Menu"):keybind("Toggle key", "ui_key", {})
iface:Group("Menu"):button("Unload", function() Lib.UnloadAll() end)

-- attached side panel
local panel = win:Panel("hitboxes", 200)
print("demo ok", Lib.VERSION)
