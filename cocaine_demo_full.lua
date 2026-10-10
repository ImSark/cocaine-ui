local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_lib.lua?t=" .. tostring(os.time())))()
assert(Lib.VERSION == "2.0.13-icons", "CDN stale: " .. tostring(Lib.VERSION))

local win = Lib.CreateWindow({ Title = "c0caine" })

-- combat
local aim = win:Tab("Aimbot", { section = "combat" })
local sAim = aim:Sub("aim")
sAim:Group("Aimbot"):toggle("Aimbot", "t_aim", { desc = "master switch" })
sAim:Group("Aimbot"):toggle("Team check", "t_team", {})
sAim:Group("Targeting"):cycle("Priority", "t_prio", {"Closest", "Crosshair", "LowestHP"}, {})
sAim:Group("Targeting"):toggle("Sticky aim", "t_sticky", {})
sAim:Group("Overlay"):toggle("Fov circle", "t_fovc", {})
sAim:Group("Overlay"):slider("Circle size", "t_size", 0, 300, 1, { unit = "px" })
local trig = aim:Sub("triggerbot")
trig:Group("Trigger"):toggle("Enabled", "t_trig", {})
trig:Group("Trigger"):slider("Delay", "t_ms", 0, 300, 5, { unit = "ms" })
trig:Group("Trigger"):keybind("Hold key", "t_hold", {})
local wep = aim:Sub("weapon")
wep:Group("Weapon"):toggle("No spread", "t_spread", {})
wep:Group("Weapon"):toggle("No recoil", "t_recoil", {})
wep:Group("Weapon"):toggle("Rapid fire", "t_rapid", {})
wep:Group("Weapon"):button("Measure limit", function() print("measuring") end)
wep:Group("Reload", { column = 2 }):toggle("Instant reload", "t_inst", {})
wep:Group("Reload", { column = 2 }):toggle("Auto reload", "t_auto", {})
wep:Group("Reload", { column = 2 }):slider("Early top-up", "t_early", 0, 100, 1, { unit = "%" })

local silent = win:Tab("Silent aim", { section = "combat" })
silent:Group("Silent"):toggle("Silent aim", "t_silent", {})
silent:Group("Silent"):slider("Hit chance", "t_chance", 0, 100, 1, { unit = "%" })
silent:Group("Silent"):color("Accent", "t_col", {})
silent:Group("Silent"):keybind("Aim key", "t_key", {})
silent:Group("Silent"):note("Rounds ride the locked part.")

local rage = win:Tab("Ragebot", { section = "combat" })
rage:Group("Rage"):toggle("Enabled", "t_rage", { danger = true })
rage:Group("Rage"):cycle("Position", "t_pos", {"None", "Magic bullet", "Autokill"}, {})

-- visuals
local players = win:Tab("Players", { section = "visuals" })
players:Group("ESP"):toggle("Boxes", "t_boxes", {})
players:Group("ESP"):toggle("Names", "t_names", {})
players:Group("ESP"):multiselect("Hitboxes", "t_hits", {"Head", "Body", "Arms", "Legs"}, {})
players:Group("ESP"):picker("Style", function() return {"Box", "Corner", "3D"} end, "t_styleidx", function(v) print("style", v) end)
local world = win:Tab("World", { section = "visuals" })
world:Group("World"):toggle("Crosshair", "t_cross", {})
world:Group("World"):textbox("Tag", "t_tag", { placeholder = "prefix" })
world:Group("World"):info("Version", function() return Lib.VERSION end)
world:Group("World"):stat("Ping")
world:Group("World"):buttonRow("Row", {{"a", function() print("a") end}, {"b", function() print("b") end}})

-- other
local misc = win:Tab("Misc", { section = "other" })
misc:Group("Movement"):toggle("Speed", "t_speed", {})
misc:Group("Movement"):slider("Multiplier", "t_mult", 1, 3, 0.05, { unit = "x" })
local iface = win:Tab("Interface", { section = "other" })
iface:Group("Menu"):keybind("Toggle key", "t_uikey", {})
iface:Group("Menu"):button("Unload", function() Lib.UnloadAll() end)

-- side panel + list demo
local panel = win:Panel("hitboxes", 200)
local pg = Lib.UI.group(panel, "Targets")
pg:list("Roster", {
  items = function() return {{id = "1", label = "Row one"}, {id = "2", label = "Row two", sub = "sub"}} end,
  selected = function() return "1" end,
  onSelect = function(id) print("picked", id) end,
})

print("all-controls demo ok", Lib.VERSION)
