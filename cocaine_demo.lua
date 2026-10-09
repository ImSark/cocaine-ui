-- demo matching screenshot 1 layout (cache-busted load)
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_lib.lua?t=" .. tostring(os.time()))()
print("lib:", Lib ~= nil, "UI:", Lib and Lib.UI ~= nil)

local win = Lib.CreateWindow({ Title = "My Script" })
local tab = win:Tab("Aim")
local g1 = tab:Group("Aimbot")
g1:toggle("Aimbot", "demo_aim", { desc = "master switch" })
g1:toggle("Team check", "demo_team", {})
g1:toggle("Aim anywhere (ignore the circle)", "demo_any", {})
local g2 = tab:Group("Targeting")
g2:cycle("Priority", "demo_prio", {"Closest","Crosshair","LowestHP"}, {})
g2:toggle("Prefer threats", "demo_threat", {})
g2:toggle("Sticky aim", "demo_sticky", {})
local g3 = tab:Group("Overlay")
g3:toggle("Fov circle", "demo_fov", {})
g3:toggle("Crosshair", "demo_cross", {})
g3:slider("Circle size", "demo_size", 0, 300, 1, { unit = "px" })
print("built:", #tab.page:GetDescendants(), "descendants")
for _, d in ipairs(tab.page:GetDescendants()) do
  if d.Name == "Label" then print("row:", d.Text) end
end
