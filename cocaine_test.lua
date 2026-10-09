-- cocaine_uilib test script (Luau)
-- Put cocaine_uilib.lua + this file in executor, run this.
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_uilib.lua"))()
-- local UI = loadstring(readfile("cocaine_uilib.lua"))()

UI.C.accent = Color3.fromRGB(173, 102, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "CocaineTest"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if gui.Parent == nil then gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

local page = Instance.new("ScrollingFrame")
page.Size = UDim2.new(0, 340, 1, 0)
page.Position = UDim2.new(0, 20, 0, 20)
page.BackgroundColor3 = UI.C.bg
page.ScrollBarThickness = 4
page.AutomaticCanvasSize = Enum.AutomaticSize.Y
page.CanvasSize = UDim2.new(0,0,0,0)
page.Parent = gui
Instance.new("UIListLayout", page).Padding = UDim.new(0, 12)

-- fake cfg keys so controls have state
local shim = UI._shim
shim.cfg.testToggle = false
shim.cfg.testSlider = 50
shim.cfg.testCycle = "Medium"
shim.cfg.testColor = {173,102,255}
shim.cfg.testKey = "E"
shim.cfg.testBox = "hello"
shim.cfg.testMulti = {A = true}

local g = UI.group(page, "Test Group")
g:toggle("Toggle", "testToggle", { desc = "help tooltip here", onChange = function(v) print("toggle:", v) end })
g:slider("Slider", "testSlider", 0, 100, 1, { unit = "%", onChange = function(v) print("slider:", v) end })
g:cycle("Cycle", "testCycle", {"Low","Medium","High"}, {})
g:color("Color", "testColor", {})
g:keybind("Keybind", "testKey", {})
g:button("Button", function() print("clicked") end)
g:note("Note row: wrapped text goes here.")
g:textbox("Textbox", "testBox", {})
g:multiselect("Multi", "testMulti", {"A","B","C"}, {})
g:info("Info", function() return "value" end)
g:stat("Stat line")
g:list("List", {
  items = function() return {{id="1",label="Row one"},{id="2",label="Row two",sub="sub"}} end,
  selected = function() return "1" end,
  onSelect = function(id) print("picked", id) end,
})

print("cocaine test built OK")
