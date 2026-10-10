-- Cocaine UI Library (standalone)
-- Extracted verbatim: c0cain.lua v1.4.1 SS11 ui kit (tokens, themes, primitives, groupbox + controls, bind popup, tooltip)
-- + standalone shim + Window/Tab manager. No game lock, no executor requirement beyond basic Instances.
-- Usage:
--   local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_lib.lua"))()
--   local win = Lib.CreateWindow({ Title = "My Script" })
--   local tab = win:Tab("Aim")
--   local g = tab:Group("Aimbot")
--   g:toggle("Enabled", "aim_enabled", { desc = "help" })
local function __gg(name)
  local g = (rawget(_G, "getgenv") and getgenv()) or _G
  if type(g) == "table" and g[name] ~= nil then return g[name] end
  return nil
end
local S = {
  ui = { tabs = {}, subTabs = {}, controls = {}, toggles = {} },
  ext = {},
  alive = true, edition = "normal", menuOpen = false,
  themeApplied = "Obsidian",
}
local cfg = {
  theme = "Obsidian", uiMode = "Advanced", uiGlow = 45,
  binds = {}, colAccent = {173, 102, 255}, colAccent2 = {103, 52, 244},
  themeFx = true, lowSpec = false, perfMode = false,
}
local function clamp(v, lo, hi, default)
  if type(v) ~= "number" or v ~= v then return default end
  return math.clamp(v, lo, hi)
end
local function rgb(t, fallback)
  if type(t) == "table" and type(t[1]) == "number" then
    return Color3.fromRGB(t[1], t[2] or 255, t[3] or 255)
  end
  return fallback or Color3.new(1, 1, 1)
end
local function log() end
local function reportError(stage, err)
  warn("[cocaine-lib] " .. tostring(stage) .. ": " .. tostring(err))
end
local function saveConfig() end
local function saveConfigSoon() end
local Input = {}
Input.bindLabels = {}
Input.capturing = false
function Input.bindTouched() end
function Input.captureKey() end
function Input.keyLabel(k)
  if type(k) ~= "string" or k == "" then return "" end
  return tostring(k):gsub("MouseButton", "M"):gsub("Left", "L"):gsub("Right", "R")
end
local EXEC = setmetatable({}, { __index = function(_, k)
  local g = (rawget(_G, "getgenv") and getgenv()) or _G
  local v = g and g[k]
  if type(v) == "function" then return v end
  return nil
end })
EXEC.caps = { files = false }
EXEC.mkdirs = function() end
local DATA = { dir = "cocaine_uilib" }
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
	local UI: any = {}
	S.uikit = UI
	-- v5.3 design tokens: one dark neutral family (a hint of violet so the accent sits in it), four
	-- text levels and one accent pair. The deep end of the pair only ever appears inside a gradient on
	-- something that moves (switch, slider fill, active page, logo) — never as decoration.
	local C: any = {
		bg = Color3.fromRGB(15, 14, 19), -- window / content
		side = Color3.fromRGB(11, 10, 15), -- sidebar, HUD panels
		surface = Color3.fromRGB(22, 21, 27), -- inputs, buttons, dropdowns
		card = Color3.fromRGB(28, 27, 34), -- hover / pressed surface
		pop = Color3.fromRGB(20, 19, 26), -- popovers: dropdowns, the bind popup, tooltips
		hairline = Color3.fromRGB(30, 29, 36), -- separators
		edge = Color3.fromRGB(38, 37, 45), -- control borders
		text = Color3.fromRGB(236, 234, 242),
		dim = Color3.fromRGB(161, 157, 173),
		muted = Color3.fromRGB(106, 102, 116),
		faint = Color3.fromRGB(74, 71, 82),
		off = Color3.fromRGB(38, 36, 46), -- switch / slider track
		knobOff = Color3.fromRGB(119, 114, 127),
		accent = Color3.fromRGB(173, 102, 255),
		accent2 = Color3.fromRGB(103, 52, 244),
		danger = Color3.fromRGB(255, 92, 122),
		ok = Color3.fromRGB(69, 223, 160),
		warn = Color3.fromRGB(255, 181, 71),
		rage = Color3.fromRGB(255, 92, 122),
		light = false,
	}
	UI.C = C
	S.themeColors = C
	-- type: Barlow (a DIN-style grotesk, OFL) for text and Material Icons Outlined (Apache 2.0) for
	-- glyphs, downloaded once into the workspace and registered through getcustomasset. The icon font
	-- works through ligatures — the icon's name is the text — because Roblox reserves private-use
	-- codepoints (a PUA icon font renders as boxes). Until the files exist (first run, no HTTP, no
	-- getcustomasset) the kit uses Roblox's BuilderSans and the frame-drawn fallback icons.
	-- bold by default: thin strokes at 12–14 px broke up into pixels
	UI.F = {
		body = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
		medium = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
		semibold = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
		bold = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
		black = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
		code = Font.fromEnum(Enum.Font.RobotoMono),
		icon = nil, -- Material Icons ligature font once registered
	}
	-- the "c0caine" wordmark (menu, watermark, intro): Gotham Bold, a clean geometric face built into Roblox
	-- (Enum.Font.Montserrat* resolves to it too)
	UI.BRAND_FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
	-- text sizes never draw below UI.TEXT_MIN at any menu size (Menu.layout clamps them)
	UI.TEXT_MIN = 12
	UI.TEXT_KEYS = { title = true, desc = true, group = true, value = true, small = true, tiny = true }
	UI.M = {
		title = 14, -- row labels
		desc = 13, -- tooltips, notes
		group = 14, -- group titles
		value = 13, -- values, dropdowns, list rows
		small = 12, -- chips, sub-tab labels
		tiny = 12, -- section captions
		row = 26,
		rowToggle = 26,
		rowDanger = 26,
		rowSlider = 26,
		rowCycle = 26,
		rowColor = 26,
		rowKeybind = 26,
		rowButton = 32,
		rowNote = 20,
		descLine = 0,
		listRow = 26,
		pillW = 28,
		pillH = 16,
		knob = 12,
		btnH = 26,
		ctrlW = 118, -- dropdown / multiselect box
		trackW = 100, -- slider track
		valueW = 40, -- slider value text
		colW = 300, -- inner width of one column (set by Menu.build from the window size)
	}
	-- wrapped-text height for a given width (notes) — measured with BuilderSans ExtraBold, the widest
	-- face the kit draws (Barlow Bold is narrower)
	function UI.textH(text: string, size: number, _font: any, width: number): number
		local ts = game:GetService("TextService")
		local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, Enum.Font.BuilderSansExtraBold, Vector2.new(math.max(width, 40), 4000))
		if ok and sz then
			return math.ceil(sz.Y)
		end
		return size + 4
	end

	-- fonts / icon font ----------------------------------------------------------------------------
	UI.ASSET_DIR = "cocaine/fonts"
	UI.BARLOW = "https://raw.githubusercontent.com/google/fonts/main/ofl/barlow/"
	UI.FONT_FACES = {
		{ file = "Barlow-Regular.ttf", weight = 400, name = "Regular" },
		{ file = "Barlow-Medium.ttf", weight = 500, name = "Medium" },
		{ file = "Barlow-SemiBold.ttf", weight = 600, name = "SemiBold" },
		{ file = "Barlow-Bold.ttf", weight = 700, name = "Bold" },
		{ file = "Barlow-ExtraBold.ttf", weight = 800, name = "ExtraBold", optional = true },
	}
	UI.ICON_FONT = { file = "MaterialIconsOutlined.otf", url = "https://raw.githubusercontent.com/google/material-design-icons/master/font/MaterialIconsOutlined-Regular.otf" }
	UI.assetState = "builtin" -- builtin | loading | loaded | failed
	function UI.assetPath(file: string): string
		return UI.ASSET_DIR .. "/" .. file
	end
	function UI.haveAsset(file: string): boolean
		local ok, yes = pcall(function()
			return EXEC.isfile(UI.assetPath(file)) and #EXEC.readfile(UI.assetPath(file)) > 10000
		end)
		return ok and yes == true
	end
	function UI.fetchAsset(file: string, url: string): boolean
		if UI.haveAsset(file) then
			return true
		end
		if type(EXEC.request) ~= "function" then
			return false
		end
		local ok, res = pcall(EXEC.request, { Url = url, Method = "GET" })
		if not (ok and type(res) == "table" and res.StatusCode == 200 and type(res.Body) == "string" and #res.Body > 10000) then
			log("WARN", "font download failed:", file, ok and type(res) == "table" and res.StatusCode or tostring(res))
			return false
		end
		pcall(function()
			for _, dir in ipairs({ "cocaine", UI.ASSET_DIR }) do
				if not (EXEC.isfolder and EXEC.isfolder(dir)) and EXEC.makefolder then
					EXEC.makefolder(dir)
				end
			end
		end)
		local okW = pcall(EXEC.writefile, UI.assetPath(file), res.Body)
		return okW
	end
	-- registers the cached files as Roblox font families; true when Barlow is in UI.F
	function UI.applyFonts(): boolean
		if type(EXEC.getcustomasset) ~= "function" then
			return false
		end
		local ok, err = pcall(function()
			local faces = {}
			local extra = false
			for _, f in ipairs(UI.FONT_FACES) do
				if UI.haveAsset(f.file) then
					table.insert(faces, { name = f.name, weight = f.weight, style = "normal", assetId = EXEC.getcustomasset(UI.assetPath(f.file)) })
					extra = extra or f.weight == 800
				elseif not f.optional then
					error("missing " .. f.file)
				end
			end
			EXEC.writefile(UI.assetPath("CocaineBarlow.json"), HttpService:JSONEncode({ name = "CocaineBarlow", faces = faces }))
			local fam = EXEC.getcustomasset(UI.assetPath("CocaineBarlow.json"))
			local heavy = if extra then Enum.FontWeight.ExtraBold else Enum.FontWeight.Bold
			UI.F.body = Font.new(fam, Enum.FontWeight.Bold)
			UI.F.medium = Font.new(fam, Enum.FontWeight.Bold)
			UI.F.semibold = Font.new(fam, heavy)
			UI.F.bold = Font.new(fam, heavy)
			UI.F.black = Font.new(fam, heavy)
			UI.fontFamily = fam
			if UI.haveAsset(UI.ICON_FONT.file) then
				EXEC.writefile(UI.assetPath("CocaineIcons.json"), HttpService:JSONEncode({ name = "CocaineIcons", faces = { { name = "Regular", weight = 400, style = "normal", assetId = EXEC.getcustomasset(UI.assetPath(UI.ICON_FONT.file)) } } }))
				UI.F.icon = Font.new(EXEC.getcustomasset(UI.assetPath("CocaineIcons.json")))
			end
		end)
		if not ok then
			log("DEBUG", "fonts: built-in (" .. tostring(err):sub(1, 60) .. ")")
			return false
		end
		UI.assetState = "loaded"
		return true
	end
	-- cached files load now (the menu is built with them); missing ones download in the background
	-- and the menu + HUD rebuild once they are in
	function UI.loadAssets()
		if UI.applyFonts() then
			-- an optional face added later (Barlow ExtraBold) still downloads once in the background
			local missing = {}
			for _, f in ipairs(UI.FONT_FACES) do
				if f.optional and not UI.haveAsset(f.file) then
					table.insert(missing, f)
				end
			end
			if #missing > 0 and type(EXEC.request) == "function" then
				task.spawn(function()
					local got = false
					for _, f in ipairs(missing) do
						got = UI.fetchAsset(f.file, UI.BARLOW .. f.file) or got
					end
					if got and S.alive ~= false and UI.applyFonts() then
						task.defer(function()
							if S.alive ~= false and S.rebuildMenu then
								pcall(S.rebuildMenu)
							end
						end)
					end
				end)
			end
			return
		end
		if type(EXEC.request) ~= "function" or type(EXEC.getcustomasset) ~= "function" or not EXEC.caps.files then
			UI.assetState = "failed"
			return
		end
		UI.assetState = "loading"
		task.spawn(function()
			local all = true
			for _, f in ipairs(UI.FONT_FACES) do
				all = (UI.fetchAsset(f.file, UI.BARLOW .. f.file) or f.optional == true) and all
			end
			UI.fetchAsset(UI.ICON_FONT.file, UI.ICON_FONT.url)
			if not (all and S.alive ~= false and UI.applyFonts()) then
				UI.assetState = "failed"
				return
			end
			log("INFO", "fonts: Barlow + Material Icons downloaded")
			task.defer(function()
				if S.alive == false then
					return
				end
				if S.rebuildMenu then
					pcall(S.rebuildMenu)
				end
				if S.hud and S.hud.retheme then
					pcall(S.hud.retheme)
				end
				-- the GUI renderer's pooled ESP texts were created with the fallback font
				if S.vis and S.vis.resetDrawings and S.vis.useGuiRenderer and S.vis.useGuiRenderer() then
					pcall(S.vis.resetDrawings)
				end
			end)
		end)
	end

	-- one accent colour per theme: bright + deep (for the gradients). v1: refined for a cleaner, more vivid
	-- and cohesive gradient across the set (matched luminance between the bright/deep stops per theme)
	local THEMES = {
		["Neon purple"] = { Color3.fromRGB(178, 120, 255), Color3.fromRGB(120, 66, 246) },
		Ice = { Color3.fromRGB(116, 206, 255), Color3.fromRGB(58, 128, 255) },
		Rose = { Color3.fromRGB(255, 122, 182), Color3.fromRGB(238, 60, 122) },
		Mint = { Color3.fromRGB(96, 240, 190), Color3.fromRGB(22, 196, 150) },
		Gold = { Color3.fromRGB(255, 200, 112), Color3.fromRGB(250, 152, 54) },
		Mono = { Color3.fromRGB(246, 246, 250), Color3.fromRGB(150, 150, 162) },
	}
	-- v1.1 design: Obsidian (the Normal edition) and toxic (Max) are brushed-metal looks. The accent pair is the
	-- glow / highlight colour; the metal tones in UI.THEME_METAL paint the active tab, sub-tab, switches, sliders
	-- and buttons, with dark ink on the light metal so their text stays readable.
	THEMES.Obsidian = { Color3.fromRGB(157, 144, 255), Color3.fromRGB(106, 92, 230) }
	local THEME_ORDER = { "Obsidian", "Neon purple", "Ice", "Rose", "Mint", "Gold", "Mono", "Custom" }
	-- Max's toxic: offered only in the Max edition. Every Max load is toxic whatever the config says; only a
	-- colour picked while on Max replaces it (cfg.maxTheme, a device key no config load overwrites). The
	-- purple ESP / chams / tracer colours turn blue once.
	THEMES.Max = { Color3.fromRGB(182, 240, 58), Color3.fromRGB(111, 158, 26) }
	-- Max Cute: soft pink on plum, with its own mascot logo (UI.cuteLogo) and a pink MAX tag
	THEMES["Max Cute"] = { Color3.fromRGB(255, 143, 199), Color3.fromRGB(236, 72, 153) }
	-- v0.9.4 Max looks: each has its own mark (UI.themeLogo), surfaces, MAX tag, a flag edge / ribbon and
	-- drifting sprites (UI.THEME_FX). Max only, like Max and Max Cute.
	THEMES["Max Pride"] = { Color3.fromRGB(255, 106, 136), Color3.fromRGB(138, 86, 255) }
	THEMES["Max Trans"] = { Color3.fromRGB(91, 206, 250), Color3.fromRGB(240, 128, 170) }
	THEMES["Max Femboy"] = { Color3.fromRGB(247, 138, 205), Color3.fromRGB(96, 184, 245) }
	THEMES["Max Xmas"] = { Color3.fromRGB(255, 84, 98), Color3.fromRGB(196, 24, 52) }
	THEMES["Max Matcha"] = { Color3.fromRGB(162, 210, 104), Color3.fromRGB(90, 150, 62) }
	UI.MAX_THEMES = { Max = true, ["Max Cute"] = true, ["Max Pride"] = true, ["Max Trans"] = true, ["Max Femboy"] = true, ["Max Xmas"] = true, ["Max Matcha"] = true }
	do
		local function surf(t: { { number } }): any
			local keys = { "bg", "side", "surface", "card", "pop", "hairline", "edge", "text", "dim", "muted", "faint", "off", "knobOff" }
			local out = {}
			for i, k in ipairs(keys) do
				out[k] = Color3.fromRGB(t[i][1], t[i][2], t[i][3])
			end
			return out
		end
		UI.THEME_SURFACES = {
			Obsidian = surf({ { 13, 13, 17 }, { 10, 10, 14 }, { 20, 20, 25 }, { 28, 28, 34 }, { 20, 20, 24 }, { 31, 31, 36 }, { 41, 41, 48 }, { 242, 243, 246 }, { 180, 184, 191 }, { 124, 127, 136 }, { 85, 85, 95 }, { 32, 33, 38 }, { 141, 145, 153 } }),
			Max = surf({ { 14, 17, 12 }, { 11, 14, 9 }, { 21, 24, 19 }, { 29, 33, 25 }, { 20, 23, 17 }, { 32, 36, 29 }, { 43, 48, 38 }, { 243, 246, 236 }, { 184, 191, 172 }, { 126, 134, 114 }, { 86, 93, 76 }, { 30, 35, 26 }, { 140, 148, 128 } }),
			["Neon purple"] = surf({ { 14, 12, 20 }, { 10, 8, 16 }, { 22, 18, 32 }, { 30, 24, 44 }, { 18, 14, 28 }, { 32, 26, 48 }, { 44, 36, 64 }, { 248, 244, 255 }, { 196, 184, 220 }, { 140, 128, 164 }, { 96, 88, 118 }, { 48, 40, 68 }, { 160, 148, 188 } }),
			Ice = surf({ { 12, 16, 24 }, { 8, 12, 20 }, { 18, 24, 36 }, { 26, 32, 48 }, { 16, 20, 32 }, { 28, 36, 52 }, { 40, 50, 70 }, { 240, 248, 255 }, { 180, 200, 228 }, { 120, 140, 172 }, { 82, 98, 128 }, { 36, 46, 64 }, { 148, 168, 204 } }),
			Rose = surf({ { 22, 12, 18 }, { 18, 8, 14 }, { 34, 18, 28 }, { 44, 24, 38 }, { 28, 14, 22 }, { 46, 26, 40 }, { 62, 36, 54 }, { 255, 242, 248 }, { 220, 176, 198 }, { 168, 122, 148 }, { 118, 82, 104 }, { 58, 32, 48 }, { 188, 142, 168 } }),
			Mint = surf({ { 10, 18, 16 }, { 7, 14, 12 }, { 16, 28, 24 }, { 22, 38, 32 }, { 14, 24, 20 }, { 24, 42, 36 }, { 34, 58, 48 }, { 238, 255, 248 }, { 176, 214, 198 }, { 118, 158, 138 }, { 78, 108, 92 }, { 32, 52, 44 }, { 142, 182, 162 } }),
			Gold = surf({ { 18, 14, 8 }, { 14, 10, 6 }, { 28, 22, 14 }, { 38, 30, 18 }, { 24, 18, 12 }, { 42, 34, 22 }, { 58, 46, 30 }, { 255, 248, 236 }, { 220, 196, 160 }, { 168, 142, 108 }, { 118, 96, 72 }, { 52, 40, 28 }, { 188, 162, 124 } }),
			Mono = surf({ { 16, 16, 18 }, { 12, 12, 14 }, { 26, 26, 30 }, { 34, 34, 40 }, { 22, 22, 26 }, { 36, 36, 42 }, { 50, 50, 58 }, { 248, 248, 252 }, { 188, 188, 198 }, { 132, 132, 144 }, { 88, 88, 98 }, { 42, 42, 48 }, { 156, 156, 168 } }),
			["Max Cute"] = surf({ { 24, 14, 22 }, { 19, 10, 18 }, { 35, 20, 32 }, { 46, 27, 42 }, { 30, 17, 27 }, { 48, 29, 43 }, { 64, 38, 56 }, { 255, 240, 248 }, { 226, 178, 205 }, { 172, 122, 152 }, { 120, 82, 106 }, { 62, 35, 54 }, { 196, 146, 176 } }),
			["Max Pride"] = surf({ { 14, 13, 18 }, { 10, 9, 14 }, { 21, 20, 27 }, { 28, 26, 35 }, { 19, 18, 25 }, { 30, 28, 37 }, { 41, 38, 50 }, { 244, 242, 248 }, { 172, 166, 184 }, { 114, 108, 126 }, { 78, 73, 88 }, { 40, 37, 48 }, { 126, 120, 136 } }),
			["Max Trans"] = surf({ { 13, 15, 24 }, { 9, 11, 19 }, { 20, 23, 35 }, { 27, 31, 46 }, { 17, 20, 31 }, { 29, 33, 48 }, { 40, 45, 64 }, { 240, 246, 255 }, { 180, 198, 224 }, { 122, 138, 166 }, { 82, 94, 118 }, { 38, 43, 62 }, { 142, 158, 186 } }),
			["Max Femboy"] = surf({ { 20, 15, 28 }, { 15, 11, 22 }, { 29, 22, 40 }, { 38, 29, 52 }, { 24, 18, 34 }, { 40, 31, 54 }, { 55, 43, 73 }, { 250, 242, 255 }, { 214, 190, 232 }, { 160, 136, 184 }, { 110, 92, 130 }, { 52, 40, 70 }, { 180, 156, 204 } }),
			["Max Xmas"] = surf({ { 10, 20, 16 }, { 7, 15, 12 }, { 15, 29, 23 }, { 21, 38, 30 }, { 12, 24, 19 }, { 22, 40, 32 }, { 32, 55, 44 }, { 244, 250, 246 }, { 186, 214, 198 }, { 124, 154, 138 }, { 84, 108, 96 }, { 30, 52, 42 }, { 152, 178, 164 } }),
			["Max Matcha"] = surf({ { 17, 19, 13 }, { 13, 15, 10 }, { 25, 28, 19 }, { 33, 37, 25 }, { 21, 24, 16 }, { 35, 39, 27 }, { 48, 53, 37 }, { 246, 242, 226 }, { 208, 206, 180 }, { 152, 152, 124 }, { 106, 108, 86 }, { 46, 51, 35 }, { 172, 174, 144 } }),
		}
		local function rgbs(t: { { number } }): { Color3 }
			local out = {}
			for i, c in ipairs(t) do
				out[i] = Color3.fromRGB(c[1], c[2], c[3])
			end
			return out
		end
		-- flag: the edge / wash / wordmark colours; ribbon: hard stripes (defaults to flag); tag: the MAX tag's
		-- gradient (left → right), ink: its text outline; sprites / colors: what drifts through the menu
		-- (rise = up like bubbles, else down); intro: "burst" out of the mark or "fall" from above
		UI.THEME_FX = {
			["Max Pride"] = {
				key = "pride",
				flag = rgbs({ { 255, 72, 72 }, { 255, 154, 46 }, { 255, 226, 64 }, { 60, 204, 110 }, { 64, 140, 255 }, { 170, 90, 230 } }),
				tag = rgbs({ { 255, 86, 86 }, { 255, 170, 60 }, { 240, 214, 60 }, { 70, 200, 110 }, { 70, 146, 255 }, { 170, 96, 232 } }),
				ink = Color3.fromRGB(40, 12, 44), ring = Color3.fromRGB(255, 255, 255),
				sprites = { "heart", "heart", "star" }, rise = true, intro = "burst",
			},
			["Max Trans"] = {
				key = "trans",
				flag = rgbs({ { 91, 206, 250 }, { 245, 169, 184 }, { 255, 255, 255 }, { 245, 169, 184 }, { 91, 206, 250 } }),
				tag = rgbs({ { 110, 212, 252 }, { 170, 190, 250 }, { 245, 150, 184 } }),
				ink = Color3.fromRGB(26, 44, 96), ring = Color3.fromRGB(190, 232, 255),
				colors = rgbs({ { 91, 206, 250 }, { 245, 169, 184 }, { 255, 255, 255 } }),
				sprites = { "heart", "butterfly", "star" }, rise = true, intro = "burst",
			},
			["Max Femboy"] = {
				key = "femboy",
				flag = rgbs({ { 214, 98, 170 }, { 240, 172, 210 }, { 255, 255, 255 }, { 106, 197, 243 }, { 255, 255, 255 }, { 240, 172, 210 }, { 214, 98, 170 } }),
				tag = rgbs({ { 255, 176, 222 }, { 240, 118, 196 }, { 120, 194, 246 } }),
				ink = Color3.fromRGB(86, 24, 84), ring = Color3.fromRGB(255, 190, 230),
				colors = rgbs({ { 247, 138, 205 }, { 240, 172, 210 }, { 106, 197, 243 }, { 255, 255, 255 } }),
				sprites = { "paw", "heart", "paw" }, rise = true, intro = "burst",
			},
			["Max Xmas"] = {
				key = "xmas",
				flag = rgbs({ { 255, 84, 98 }, { 255, 214, 120 }, { 70, 196, 120 } }),
				ribbon = rgbs({ { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 }, { 255, 255, 255 }, { 255, 84, 98 } }),
				tag = rgbs({ { 255, 110, 118 }, { 214, 30, 58 } }),
				ink = Color3.fromRGB(90, 8, 22), ring = Color3.fromRGB(255, 214, 120), candy = true,
				colors = rgbs({ { 255, 255, 255 }, { 232, 244, 255 }, { 255, 255, 255 }, { 255, 214, 120 } }),
				sprites = { "snow", "snow", "snow", "star" }, rise = false, intro = "fall",
			},
			["Max Matcha"] = {
				key = "matcha",
				flag = rgbs({ { 238, 232, 204 }, { 190, 226, 140 }, { 140, 196, 90 }, { 84, 140, 60 } }),
				tag = rgbs({ { 196, 230, 146 }, { 96, 156, 66 } }),
				ink = Color3.fromRGB(28, 56, 18), ring = Color3.fromRGB(238, 232, 204),
				colors = rgbs({ { 170, 214, 110 }, { 124, 182, 80 }, { 204, 232, 150 }, { 96, 150, 62 } }),
				sprites = { "leaf", "leaf", "leaf", "star" }, rise = false, intro = "fall",
			},
		}
		for _, fx in pairs(UI.THEME_FX) do
			fx.colors = fx.colors or fx.flag
		end
	end
	-- hi → lite → mid → dark: the lit face down to the shadow of the metal; ink = text on the metal, edge = the
	-- darker lip under a raised metal key
	UI.THEME_METAL = {
		Obsidian = {
			hi = Color3.fromRGB(243, 240, 253), lite = Color3.fromRGB(183, 176, 212), mid = Color3.fromRGB(74, 67, 104),
			dark = Color3.fromRGB(20, 18, 29), ink = Color3.fromRGB(20, 18, 29), edge = Color3.fromRGB(111, 104, 144),
		},
		Max = {
			hi = Color3.fromRGB(244, 255, 214), lite = Color3.fromRGB(205, 240, 106), mid = Color3.fromRGB(111, 158, 26),
			dark = Color3.fromRGB(33, 51, 10), ink = Color3.fromRGB(22, 33, 10), edge = Color3.fromRGB(95, 140, 18),
		},
	}
	function UI.maxThemeName(): string
		local t = cfg.maxTheme
		return if type(t) == "string" and (THEMES[t] ~= nil or t == "Custom") then t else "Max"
	end
	if S.edition == "max" then
		for i, name in ipairs({ "Max", "Max Cute", "Max Pride", "Max Trans", "Max Femboy", "Max Xmas", "Max Matcha" }) do
			table.insert(THEME_ORDER, i + 1, name)
		end
		cfg.theme = UI.maxThemeName()
		local mark = DATA.dir .. "/max_theme.txt"
		local done = pcall(function()
			return EXEC.isfile(mark) or error("")
		end)
		if not done then
			local purple, blue = { 173, 102, 255 }, { 96, 170, 255 }
			for _, k in ipairs({ "colEspVisible", "colTracer", "colChamsFill", "colShotTracer", "colVm", "colSelf" }) do
				local v = cfg[k]
				if type(v) == "table" and v[1] == purple[1] and v[2] == purple[2] and v[3] == purple[3] then
					cfg[k] = table.clone(blue)
				end
			end
			pcall(function()
				EXEC.mkdirs(DATA.dir)
				EXEC.writefile(mark, "1")
			end)
			saveConfigSoon()
		end
	elseif UI.MAX_THEMES[cfg.theme] then
		-- a Max look arriving in a shared config: Normal lists none of them, so the Accent row showed a look
		-- that never applied
		cfg.theme = "Obsidian"
	else
		-- Neon purple was the default before Obsidian: move a copy still on it over once (a purple picked
		-- after this is kept)
		local mark = DATA.dir .. "/obsidian_theme.txt"
		local done = pcall(function()
			return EXEC.isfile(mark) or error("")
		end)
		if not done then
			if cfg.theme == "Neon purple" then
				cfg.theme = "Obsidian"
				saveConfigSoon()
			end
			pcall(function()
				EXEC.mkdirs(DATA.dir)
				EXEC.writefile(mark, "1")
			end)
		end
	end
	UI.THEME_ORDER = THEME_ORDER
	UI.THEMES = THEMES
	function UI.themeName(): string
		if S.edition == "max" then
			return UI.maxThemeName()
		end
		return cfg.theme
	end
	function UI.applyTheme()
		local name = UI.themeName()
		local pair = THEMES[name]
		if UI.MAX_THEMES[name] and S.edition ~= "max" then
			pair = THEMES.Obsidian
			name = "Obsidian"
		end
		UI.metal = UI.THEME_METAL[name]
		-- surfaces: the base palette, or the theme's own (Max Cute's plum); kept once so switching back restores it
		UI.C_BASE = UI.C_BASE or table.clone(C)
		local surf = UI.THEME_SURFACES[name]
		for k, v in pairs(UI.C_BASE) do
			if k ~= "accent" and k ~= "accent2" and k ~= "light" then
				C[k] = if surf and surf[k] then surf[k] else v
			end
		end
		if name == "Custom" or not pair then
			pair = { rgb(cfg.colAccent), rgb(cfg.colAccent2) }
		end
		C.accent, C.accent2 = pair[1], pair[2]
		C.light = false
		S.themeApplied = name
	end
	-- the applied theme's extras (flag colours, tag, sprites), nil outside Max or for a plain accent
	function UI.themeFx(): any
		return if S.edition == "max" then UI.THEME_FX[S.themeApplied or ""] else nil
	end
	-- smooth: evenly spaced stops; hard: one flat band per colour (a flag)
	function UI.fxSeq(cols: { Color3 }, hard: boolean?): ColorSequence
		local n = #cols
		if n < 2 then
			return ColorSequence.new(cols[1] or Color3.new(1, 1, 1))
		end
		local kps = {}
		if hard then
			for i, c in ipairs(cols) do
				table.insert(kps, ColorSequenceKeypoint.new(if i == 1 then 0 else (i - 1) / n + 0.001, c))
				table.insert(kps, ColorSequenceKeypoint.new(i / n, c))
			end
		else
			for i, c in ipairs(cols) do
				table.insert(kps, ColorSequenceKeypoint.new((i - 1) / (n - 1), c))
			end
		end
		return ColorSequence.new(kps)
	end
	UI.applyTheme()
	-- glow: a soft radial sprite (64 × 64 white, smoothstep falloff) written once as a PNG and loaded
	-- through getcustomasset, tinted with the accent. The 9-slice shadow sprite is the fallback — its
	-- flat centre shows as a rectangle on big areas, the radial one reads as light. Strength follows
	-- cfg.uiGlow.
	UI.GLOW_IMAGE = "rbxassetid://6014261993"
	-- an N × N RGBA PNG from pixel(x, y) → r, g, b, a: one stored (uncompressed) deflate block, so
	-- N * (4N + 1) must stay under 65535 bytes (N ≤ 127)
	function UI.pngEncode(N: number, pixel: (number, number) -> (number, number, number, number)): string
		local bxor, band, rshift = bit32.bxor, bit32.band, bit32.rshift
		local crcTable = table.create(256)
		for i = 0, 255 do
			local c = i
			for _ = 1, 8 do
				c = if band(c, 1) == 1 then bxor(0xEDB88320, rshift(c, 1)) else rshift(c, 1)
			end
			crcTable[i + 1] = c
		end
		local function crc32(s: string): number
			local c = 0xFFFFFFFF
			for i = 1, #s do
				c = bxor(crcTable[band(bxor(c, string.byte(s, i)), 0xFF) + 1], rshift(c, 8))
			end
			return bxor(c, 0xFFFFFFFF)
		end
		local function u32(n: number): string
			return string.char(band(rshift(n, 24), 255), band(rshift(n, 16), 255), band(rshift(n, 8), 255), band(n, 255))
		end
		local rows = table.create(N)
		for y = 0, N - 1 do
			local px = table.create(N * 4 + 1)
			px[1] = 0 -- filter: none
			for x = 0, N - 1 do
				local i = x * 4 + 2
				px[i], px[i + 1], px[i + 2], px[i + 3] = pixel(x, y)
			end
			rows[y + 1] = string.char(table.unpack(px))
		end
		local raw = table.concat(rows)
		local a1, a2 = 1, 0
		for i = 1, #raw do
			a1 = (a1 + string.byte(raw, i)) % 65521
			a2 = (a2 + a1) % 65521
		end
		local len = #raw
		local nlen = bxor(len, 0xFFFF)
		local zlib = "\120\1" .. string.char(1, band(len, 255), rshift(len, 8), band(nlen, 255), rshift(nlen, 8)) .. raw .. u32(a2 * 65536 + a1)
		local function chunk(kind: string, data: string): string
			return u32(#data) .. kind .. data .. u32(crc32(kind .. data))
		end
		return "\137PNG\r\n\26\n" .. chunk("IHDR", u32(N) .. u32(N) .. "\8\6\0\0\0") .. chunk("IDAT", zlib) .. chunk("IEND", "")
	end
	-- a generated texture in the fonts folder, written once, loaded through getcustomasset
	function UI.pngAsset(file: string, N: number, pixel: (number, number) -> (number, number, number, number)): string?
		if type(EXEC.getcustomasset) ~= "function" or not EXEC.caps.files then
			return nil
		end
		local path = UI.assetPath(file)
		local ok, id = pcall(function()
			if not (EXEC.isfile and EXEC.isfile(path)) then
				local png = UI.pngEncode(N, pixel)
				pcall(function()
					for _, dir in ipairs({ "cocaine", UI.ASSET_DIR }) do
						if not (EXEC.isfolder and EXEC.isfolder(dir)) and EXEC.makefolder then
							EXEC.makefolder(dir)
						end
					end
				end)
				EXEC.writefile(path, png)
			end
			return EXEC.getcustomasset(path)
		end)
		return if ok and type(id) == "string" then id else nil
	end
	function UI.buildGlowPng(): string?
		local mid = 63 / 2
		return UI.pngAsset("glow64.png", 64, function(x: number, y: number)
			local d = math.sqrt((x - mid) ^ 2 + (y - mid) ^ 2) / 32
			local a = math.clamp(1 - d, 0, 1)
			a = a * a * (3 - 2 * a)
			return 255, 255, 255, math.floor(a * 255 + 0.5)
		end)
	end
	UI.glowRadial = UI.buildGlowPng()
	-- acrylic grain: a 96 px tile of zero-mean speckle (half the pixels lighten, half darken, a
	-- seeded PRNG so the file never changes). Tiled 1:1 at a few percent it gives flat panels the
	-- frosted, printed look of acrylic without shifting their colour.
	function UI.buildNoisePng(): string?
		local rng = Random.new(0xC0CA)
		return UI.pngAsset("acrylic96.png", 96, function()
			local c = if rng:NextNumber() < 0.5 then 0 else 255
			local a = math.floor((0.35 + 0.65 * rng:NextNumber()) * 255 + 0.5)
			return c, c, c, a
		end)
	end
	UI.noiseTile = UI.buildNoisePng()
	-- the logo mark: a round face with X eyes and a flat mouth, drawn with signed distances (1 px of
	-- anti-aliasing at 96 px) in white so a UIGradient paints it in the accent at any size
	-- rendered at the exact pixel size it is shown at (one texture per size): a 96 px texture shrunk
	-- to 16–22 px aliased into jagged strokes. Strokes never thinner than ~1.5 px.
	UI.faceIcons = {}
	function UI.buildFacePng(N: number): string?
		N = math.clamp(math.floor(N + 0.5), 8, 127)
		if UI.faceIcons[N] ~= nil then
			return UI.faceIcons[N] or nil
		end
		local function seg(px: number, py: number, ax: number, ay: number, bx: number, by: number): number
			local dx, dy = bx - ax, by - ay
			local t = math.clamp(((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy), 0, 1)
			local qx, qy = ax + dx * t - px, ay + dy * t - py
			return math.sqrt(qx * qx + qy * qy)
		end
		local ringW = math.max(0.045, 0.78 / N)
		local lineW = math.max(0.036, 0.72 / N)
		local id = UI.pngAsset(("face%d.png"):format(N), N, function(x: number, y: number)
			local u, v = (x + 0.5) / N, (y + 0.5) / N
			local d = math.abs(math.sqrt((u - 0.5) ^ 2 + (v - 0.5) ^ 2) - 0.41) - ringW -- head outline
			for _, e in ipairs({ { 0.35, 0.42 }, { 0.65, 0.42 } }) do
				local s = 0.075
				d = math.min(d, seg(u, v, e[1] - s, e[2] - s, e[1] + s, e[2] + s) - lineW)
				d = math.min(d, seg(u, v, e[1] - s, e[2] + s, e[1] + s, e[2] - s) - lineW)
			end
			d = math.min(d, seg(u, v, 0.37, 0.67, 0.63, 0.67) - lineW) -- mouth
			local a = math.clamp(0.5 - d * N, 0, 1)
			return 255, 255, 255, math.floor(a * 255 + 0.5)
		end)
		UI.faceIcons[N] = id or false
		return id
	end
	UI.faceIcon = UI.buildFacePng(96)
	-- the Max look marks (v0.9.4): full-colour art painted from signed distances, back to front, at the exact
	-- pixel size shown (like the face), cached as tlogo_<key>_v1_<N>.png. Faces, blush and sparkles only where
	-- the size carries them. UI.fxSprite: the white 24 px sprites the menu and the intro tint.
	UI.themeLogos = {}
	UI.fxSprites = {}
	do
		local sqrt, abs, max, min, clamp, floor = math.sqrt, math.abs, math.max, math.min, math.clamp, math.floor
		local PN, pr, pg, pb, pa = 1, 0, 0, 0, 0
		local function len(x: number, y: number): number
			return sqrt(x * x + y * y)
		end
		-- one layer: coverage from the distance (1 px of edge), premultiplied "over" onto the pixel
		local function paint(d: number, c: { number }, a: number?)
			local k = clamp(0.5 - d * PN, 0, 1) * (a or 1)
			if k <= 0 then
				return
			end
			local j = 1 - k
			pr, pg, pb, pa = pr * j + c[1] * k, pg * j + c[2] * k, pb * j + c[3] * k, pa * j + k
		end
		local function circle(u: number, v: number, cx: number, cy: number, r: number): number
			return len(u - cx, v - cy) - r
		end
		-- rot turns the shape clockwise (screen y points down); iq's gradient-scaled estimate, which stays close
		-- to the true distance even for a flat ellipse (a bowl rim)
		local function ellipse(u: number, v: number, cx: number, cy: number, rx: number, ry: number, rot: number?): number
			local x, y = u - cx, v - cy
			if rot then
				local c, s = math.cos(rot), math.sin(rot)
				x, y = x * c + y * s, y * c - x * s
			end
			local k0 = len(x / rx, y / ry)
			local k1 = len(x / (rx * rx), y / (ry * ry))
			return if k1 > 1e-9 then k0 * (k0 - 1) / k1 else -min(rx, ry)
		end
		local function seg(u: number, v: number, ax: number, ay: number, bx: number, by: number, w: number): number
			local dx, dy = bx - ax, by - ay
			local t = clamp(((u - ax) * dx + (v - ay) * dy) / (dx * dx + dy * dy), 0, 1)
			return len(ax + dx * t - u, ay + dy * t - v) - w
		end
		local function box(u: number, v: number, cx: number, cy: number, hw: number, hh: number, r: number): number
			local qx, qy = abs(u - cx) - hw + r, abs(v - cy) - hh + r
			return len(max(qx, 0), max(qy, 0)) + min(max(qx, qy), 0) - r
		end
		-- exact triangle distance (iq), negative inside
		local function tri(u: number, v: number, ax: number, ay: number, bx: number, by: number, cx: number, cy: number): number
			local e0x, e0y, e1x, e1y, e2x, e2y = bx - ax, by - ay, cx - bx, cy - by, ax - cx, ay - cy
			local v0x, v0y, v1x, v1y, v2x, v2y = u - ax, v - ay, u - bx, v - by, u - cx, v - cy
			local t0 = clamp((v0x * e0x + v0y * e0y) / (e0x * e0x + e0y * e0y), 0, 1)
			local t1 = clamp((v1x * e1x + v1y * e1y) / (e1x * e1x + e1y * e1y), 0, 1)
			local t2 = clamp((v2x * e2x + v2y * e2y) / (e2x * e2x + e2y * e2y), 0, 1)
			local p0x, p0y, p1x, p1y, p2x, p2y = v0x - e0x * t0, v0y - e0y * t0, v1x - e1x * t1, v1y - e1y * t1, v2x - e2x * t2, v2y - e2y * t2
			local sg = if e0x * e2y - e0y * e2x < 0 then -1 else 1
			local dd = min(p0x * p0x + p0y * p0y, p1x * p1x + p1y * p1y, p2x * p2x + p2y * p2y)
			local ss = min(sg * (v0x * e0y - v0y * e0x), sg * (v1x * e1y - v1y * e1x), sg * (v2x * e2y - v2y * e2x))
			return if ss < 0 then sqrt(dd) else -sqrt(dd)
		end
		-- iq's heart, tip down, centred on (cx, cy): about 1.1 s tall and 1.2 s wide
		local function heart(u: number, v: number, cx: number, cy: number, s: number): number
			local x, y = abs(u - cx) / s, (cy - v) / s + 0.55
			if x + y > 1 then
				return (len(x - 0.25, y - 0.75) - 0.35355) * s
			end
			local m = max(x + y, 0) * 0.5
			return sqrt(min(x * x + (y - 1) ^ 2, (x - m) ^ 2 + (y - m) ^ 2)) * (if x < y then -s else s)
		end
		-- a four-point sparkle: two thin diamonds
		local function sparkle(u: number, v: number, cx: number, cy: number, r: number): number
			local x, y = abs(u - cx), abs(v - cy)
			local w = r * 0.3
			local k = 1 / sqrt(1 / (w * w) + 1 / (r * r))
			return min((x / w + y / r - 1) * k, (x / r + y / w - 1) * k)
		end
		local function xEye(u: number, v: number, cx: number, cy: number, s: number, w: number): number
			return min(seg(u, v, cx - s, cy - s, cx + s, cy + s, w), seg(u, v, cx - s, cy + s, cx + s, cy - s, w))
		end
		local mix = { 0, 0, 0 }
		local function lerp3(a: { number }, b: { number }, t: number): { number }
			t = clamp(t, 0, 1)
			mix[1], mix[2], mix[3] = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t
			return mix
		end
		-- flag bands down [t0, t1], two samples a pixel so the band edges stay smooth
		local function bands(cols: { { number } }, t0: number, t1: number, v: number): { number }
			local n = #cols
			local a = cols[clamp(floor((v - 0.3 / PN - t0) / (t1 - t0) * n), 0, n - 1) + 1]
			local b = cols[clamp(floor((v + 0.3 / PN - t0) / (t1 - t0) * n), 0, n - 1) + 1]
			return lerp3(a, b, 0.5)
		end
		local WHITE, INK, SHADE = { 255, 255, 255 }, { 34, 18, 42 }, { 14, 8, 20 }
		local PRIDE = { { 255, 72, 72 }, { 255, 154, 46 }, { 255, 226, 64 }, { 60, 204, 110 }, { 64, 140, 255 }, { 170, 90, 230 } }
		local ART = {}
		-- Pride: a rainbow heart with a gloss and a sparkle; the x_x face from 30 px
		function ART.pride(u: number, v: number, n: number)
			local d = heart(u, v, 0.5, 0.53, 0.74)
			paint(d - 0.04, SHADE, 0.55)
			if d < 2 / n then
				paint(d, bands(PRIDE, 0.16, 0.8, v))
			end
			paint(ellipse(u, v, 0.33, 0.29, 0.085, 0.045, -0.7), WHITE, 0.5)
			if n >= 30 and v > 0.38 and v < 0.7 then
				local w = max(0.024, 0.7 / n)
				paint(min(xEye(u, v, 0.385, 0.46, 0.05, w), xEye(u, v, 0.615, 0.46, 0.05, w), seg(u, v, 0.45, 0.62, 0.55, 0.62, w)), INK, 0.92)
			end
			if n >= 18 and u > 0.7 and v < 0.3 then
				paint(sparkle(u, v, 0.84, 0.16, 0.11), WHITE)
			end
		end
		-- Trans: a butterfly, blue upper wings and pink lower ones on a white body (mirrored halves)
		local TBLUE, TPINK = { 91, 206, 250 }, { 245, 169, 184 }
		function ART.trans(u: number, v: number, n: number)
			local x = 0.5 + abs(u - 0.5)
			local up = ellipse(x, v, 0.69, 0.35, 0.21, 0.15, -0.6)
			local lo = ellipse(x, v, 0.65, 0.66, 0.15, 0.115, 0.55)
			local body = min(seg(u, v, 0.5, 0.3, 0.5, 0.76, 0.04), circle(u, v, 0.5, 0.25, 0.05))
			local ant = min(seg(x, v, 0.5, 0.23, 0.6, 0.1, 0.014), circle(x, v, 0.6, 0.1, 0.028))
			paint(min(up, lo, body) - 0.04, SHADE, 0.55)
			if n >= 18 then
				paint(ant - 0.022, SHADE, 0.45)
				paint(ant, WHITE)
			end
			paint(lo, TPINK)
			paint(ellipse(x, v, 0.66, 0.665, 0.085, 0.06, 0.55), { 252, 214, 222 }, 0.9)
			paint(up, TBLUE)
			paint(ellipse(x, v, 0.7, 0.35, 0.12, 0.08, -0.6), { 178, 232, 252 }, 0.9)
			if n >= 22 then
				paint(circle(x, v, 0.8, 0.26, 0.03), WHITE)
				paint(circle(x, v, 0.73, 0.73, 0.022), WHITE, 0.9)
			end
			paint(body, WHITE)
		end
		-- Femboy: the white boykisser cat — pointed ears, fluffy cheek tufts, big shiny eyes, /// blush, an ω
		-- mouth — on a femboy-pink sticker rim, with a pink bow and a baby-blue knot on one ear
		local FPINK = { 247, 138, 205 }
		function ART.femboy(u: number, v: number, n: number)
			local x = 0.5 + abs(u - 0.5)
			local head = ellipse(u, v, 0.5, 0.6, 0.33, 0.28)
			local ear = if x > 0.55 and v < 0.56 then tri(x, v, 0.62, 0.4, 0.79, 0.1, 0.84, 0.46) - 0.02 else 1
			local tuft = if x > 0.7 and v > 0.46 and v < 0.86 then min(tri(x, v, 0.78, 0.53, 0.885, 0.59, 0.8, 0.645), tri(x, v, 0.77, 0.655, 0.865, 0.725, 0.73, 0.78)) - 0.01 else 1
			local sil = min(head, ear, tuft)
			paint(sil - 0.075, SHADE, 0.5)
			paint(sil - 0.045, FPINK)
			paint(sil, lerp3(WHITE, { 234, 222, 248 }, (v - 0.45) / 0.45))
			if ear < 0.1 then
				paint(tri(x, v, 0.66, 0.39, 0.78, 0.17, 0.81, 0.44) - 0.008, { 255, 164, 208 })
			end
			paint(ellipse(x, v, 0.63, 0.6, 0.056, 0.076), { 44, 26, 64 })
			if n >= 20 then
				paint(circle(x, v, 0.648, 0.574, 0.022), WHITE)
			end
			if n >= 30 then
				paint(circle(x, v, 0.615, 0.63, 0.011), WHITE, 0.8)
				local w = max(0.009, 0.4 / n)
				for i = 0, 2 do
					paint(seg(x, v, 0.69 + i * 0.035, 0.705, 0.71 + i * 0.035, 0.668, w), { 255, 110, 172 })
				end
				paint(max(abs(circle(x, v, 0.53, 0.69, 0.03)) - max(0.009, 0.45 / n), 0.69 - v), INK)
			else
				paint(ellipse(x, v, 0.73, 0.69, 0.05, 0.028), { 255, 120, 180 }, 0.6)
			end
			paint(ellipse(u, v, 0.5, 0.665, 0.022, 0.015), { 255, 140, 190 })
			if n >= 18 and u > 0.6 and v < 0.45 then
				paint(ellipse(u, v, 0.715, 0.3, 0.068, 0.048, -0.35), { 240, 110, 196 })
				paint(ellipse(u, v, 0.845, 0.3, 0.068, 0.048, 0.35), { 240, 110, 196 })
				paint(circle(u, v, 0.78, 0.3, 0.032), { 110, 196, 246 })
			end
		end
		-- Xmas: the x_x face in snow white under a Santa hat (drooping tip, pompom, fur band, holly)
		local RED = { 232, 40, 58 }
		function ART.xmas(u: number, v: number, n: number)
			local face = circle(u, v, 0.47, 0.6, 0.31)
			local hat = min(tri(u, v, 0.17, 0.41, 0.78, 0.36, 0.62, 0.06) - 0.015, seg(u, v, 0.62, 0.07, 0.84, 0.2, 0.04))
			local pom = circle(u, v, 0.86, 0.22, 0.07)
			local band = seg(u, v, 0.15, 0.43, 0.8, 0.37, 0.065)
			paint(min(face, hat, pom, band) - 0.04, SHADE, 0.55)
			paint(face, lerp3(WHITE, { 210, 230, 244 }, (v - 0.45) / 0.45))
			if n >= 20 then
				paint(circle(u, v, 0.31, 0.71, 0.05), { 255, 90, 100 }, 0.35)
				paint(circle(u, v, 0.63, 0.71, 0.05), { 255, 90, 100 }, 0.35)
			end
			local w = max(0.024, 0.7 / n)
			paint(min(xEye(u, v, 0.37, 0.6, 0.05, w), xEye(u, v, 0.57, 0.6, 0.05, w), seg(u, v, 0.41, 0.74, 0.53, 0.74, w)), INK)
			paint(hat, lerp3(RED, { 168, 14, 38 }, (0.4 - v) / 0.34))
			paint(band, { 244, 248, 252 })
			paint(pom, WHITE)
			if n >= 28 and u < 0.4 and v < 0.5 then
				paint(ellipse(u, v, 0.22, 0.37, 0.06, 0.03, -0.5), { 46, 170, 90 })
				paint(ellipse(u, v, 0.31, 0.35, 0.06, 0.03, 0.45), { 46, 170, 90 })
				paint(circle(u, v, 0.265, 0.385, 0.024), { 255, 70, 82 })
			end
		end
		-- Matcha: a cream chawan with a green matcha surface and foam, steam above, a sleepy x_x face and blush
		function ART.matcha(u: number, v: number, n: number)
			if n >= 18 and v < 0.34 then
				local sw = max(0.016, 0.45 / n)
				local fade = 0.6 * clamp((v - 0.08) / 0.1, 0, 1)
				paint(max(abs(u - (0.4 + 0.028 * math.sin(v * 30 + 4))) - sw, abs(v - 0.2) - 0.12), WHITE, fade)
				paint(max(abs(u - (0.6 + 0.028 * math.sin(v * 30 + 6))) - sw, abs(v - 0.2) - 0.12), WHITE, fade)
			end
			local body = max(ellipse(u, v, 0.5, 0.47, 0.41, 0.39), 0.45 - v)
			local rim = ellipse(u, v, 0.5, 0.45, 0.41, 0.085)
			local foot = box(u, v, 0.5, 0.885, 0.13, 0.035, 0.018)
			paint(min(body, rim, foot) - 0.04, SHADE, 0.55)
			paint(foot, { 196, 180, 150 })
			paint(body, lerp3({ 246, 240, 224 }, { 212, 198, 168 }, (v - 0.45) / 0.42))
			if n >= 26 then
				paint(max(body, abs(v - 0.8) - 0.018), { 128, 184, 72 }, 0.9)
			end
			paint(rim, { 250, 246, 234 })
			paint(ellipse(u, v, 0.5, 0.456, 0.355, 0.062), { 128, 184, 72 })
			paint(ellipse(u, v, 0.45, 0.45, 0.15, 0.028), { 186, 222, 126 }, 0.85)
			if n >= 20 and v > 0.5 and v < 0.8 then
				local w = max(0.024, 0.65 / n)
				paint(min(xEye(u, v, 0.39, 0.62, 0.042, w), xEye(u, v, 0.61, 0.62, 0.042, w), seg(u, v, 0.46, 0.72, 0.54, 0.72, w)), { 60, 44, 30 })
				paint(ellipse(u, v, 0.3, 0.7, 0.05, 0.028), { 255, 150, 160 }, 0.5)
				paint(ellipse(u, v, 0.7, 0.7, 0.05, 0.028), { 255, 150, 160 }, 0.5)
			end
		end
		function UI.themeLogoPng(key: string, size: number): string?
			local N = clamp(floor(size + 0.5), 8, 127)
			local ck = key .. N
			local c = UI.themeLogos[ck]
			if c ~= nil then
				return c or nil
			end
			local art = ART[key]
			local id = art and UI.pngAsset(("tlogo_%s_v1_%d.png"):format(key, N), N, function(x: number, y: number)
				PN, pr, pg, pb, pa = N, 0, 0, 0, 0
				art((x + 0.5) / N, (y + 0.5) / N, N)
				if pa <= 0.002 then
					return 0, 0, 0, 0
				end
				return clamp(floor(pr / pa + 0.5), 0, 255), clamp(floor(pg / pa + 0.5), 0, 255), clamp(floor(pb / pa + 0.5), 0, 255), clamp(floor(pa * 255 + 0.5), 0, 255)
			end)
			UI.themeLogos[ck] = id or false
			return id
		end
		-- sprites: white shapes (ImageColor3 tints them); a second distance cuts a see-through line (leaf vein)
		local SPRITE = {}
		function SPRITE.heart(u: number, v: number): (number, number?)
			return heart(u, v, 0.5, 0.54, 0.76), nil
		end
		function SPRITE.star(u: number, v: number): (number, number?)
			return sparkle(u, v, 0.5, 0.5, 0.46), nil
		end
		function SPRITE.paw(u: number, v: number): (number, number?)
			return min(ellipse(u, v, 0.5, 0.66, 0.22, 0.18), circle(u, v, 0.25, 0.42, 0.09), circle(u, v, 0.41, 0.27, 0.095), circle(u, v, 0.59, 0.27, 0.095), circle(u, v, 0.75, 0.42, 0.09)), nil
		end
		function SPRITE.snow(u: number, v: number): (number, number?)
			local d = circle(u, v, 0.5, 0.5, 0.07)
			for k = 0, 5 do
				local a = k * math.pi / 3
				local c, s = math.cos(a), math.sin(a)
				local bx, by = 0.5 + c * 0.26, 0.5 + s * 0.26
				d = min(d, seg(u, v, 0.5, 0.5, 0.5 + c * 0.42, 0.5 + s * 0.42, 0.04),
					seg(u, v, bx, by, bx + math.cos(a - 0.7) * 0.13, by + math.sin(a - 0.7) * 0.13, 0.032),
					seg(u, v, bx, by, bx + math.cos(a + 0.7) * 0.13, by + math.sin(a + 0.7) * 0.13, 0.032))
			end
			return d, nil
		end
		function SPRITE.leaf(u: number, v: number): (number, number?)
			local d = min(ellipse(u, v, 0.52, 0.48, 0.38, 0.19, -0.7), seg(u, v, 0.26, 0.7, 0.14, 0.82, 0.03))
			return d, seg(u, v, 0.26, 0.7, 0.76, 0.28, 0.018)
		end
		function SPRITE.butterfly(u: number, v: number): (number, number?)
			local x = 0.5 + abs(u - 0.5)
			return min(ellipse(x, v, 0.7, 0.36, 0.22, 0.16, -0.6), ellipse(x, v, 0.66, 0.68, 0.16, 0.12, 0.55), seg(u, v, 0.5, 0.28, 0.5, 0.78, 0.045)), nil
		end
		function UI.fxSprite(kind: string): string?
			local c = UI.fxSprites[kind]
			if c ~= nil then
				return c or nil
			end
			local fn = SPRITE[kind]
			local id = fn and UI.pngAsset(("fx_%s_v1.png"):format(kind), 24, function(x: number, y: number)
				local d, hole = fn((x + 0.5) / 24, (y + 0.5) / 24)
				local a = clamp(0.5 - d * 24, 0, 1)
				if hole then
					a *= 1 - 0.65 * clamp(0.5 - hole * 24, 0, 1)
				end
				return 255, 255, 255, floor(a * 255 + 0.5)
			end)
			UI.fxSprites[kind] = id or false
			return id
		end
	end
	-- a hollow soft falloff around a rounded box with the window's 12 px corners, `spread` px wide, for
	-- 9-slicing at scale 1 (one tile per spread: a scaled tile shrank the inner corner below the
	-- window's and left a notch at every corner). Empty inside the box, so a shadow / aura never paints
	-- over the window it surrounds. Tile: margin (spread + 12) on each side of a 4 px centre.
	UI.falloffTiles = {}
	function UI.falloffTile(spread: number, radius: number?): (string?, Rect?)
		local rad = radius or 12
		local key = spread * 100 + rad
		local cached = UI.falloffTiles[key]
		if cached then
			return cached.id, cached.slice
		end
		local m = spread + rad
		local n = m * 2 + 4
		local c = n / 2
		local file = if rad == 12 then ("falloff%d.png"):format(spread) else ("falloff%d_%d.png"):format(spread, rad)
		local id = UI.pngAsset(file, n, function(x: number, y: number)
			local qx, qy = math.abs(x + 0.5 - c) - 2, math.abs(y + 0.5 - c) - 2
			local ox, oy = math.max(qx, 0), math.max(qy, 0)
			local d = math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0) - rad
			if d <= 0 then
				return 255, 255, 255, 0
			end
			local t = math.clamp(1 - d / spread, 0, 1)
			return 255, 255, 255, math.floor(t * t * math.min(d, 1) * 255 + 0.5)
		end)
		local slice = Rect.new(m, m, n - m, n - m)
		UI.falloffTiles[key] = { id = id, slice = slice }
		return id, slice
	end
	function UI.glowAlpha(strength: number?): number
		local g = math.clamp((tonumber(cfg.uiGlow) or 45) / 100, 0, 1) * (strength or 1)
		return 1 - 0.8 * g
	end
	-- a soft light filling `parent` plus `spread` px on every side. It renders above the parent's own
	-- background, so the element it lights must be a later sibling (or carry a higher ZIndex).
	function UI.glow(parent: GuiObject, spread: number?, strength: number?, color: Color3?): ImageLabel
		local s = spread or 10
		local g = Instance.new("ImageLabel")
		g.Name = "Glow"
		g.BackgroundTransparency = 1
		g.ImageColor3 = color or C.accent
		if UI.glowRadial then
			g.Image = UI.glowRadial
			g.ScaleType = Enum.ScaleType.Stretch
		else
			g.Image = UI.GLOW_IMAGE
			g.ScaleType = Enum.ScaleType.Slice
			g.SliceCenter = Rect.new(49, 49, 450, 450)
			g.SliceScale = math.clamp(s / 40, 0.05, 1)
		end
		g.AnchorPoint = Vector2.new(0.5, 0.5)
		g.Position = UDim2.fromScale(0.5, 0.5)
		g.Size = UDim2.new(1, s * 2, 1, s * 2)
		g.ImageTransparency = UI.glowAlpha(strength)
		g:SetAttribute("glowStrength", strength or 1)
		g.Parent = parent
		return g
	end
	-- the glow slider: every glow that is lit right now follows the new strength
	function UI.refreshGlows(root: Instance?)
		if not root then
			return
		end
		for _, d in ipairs(root:GetDescendants()) do
			if d.Name == "Glow" and d:IsA("ImageLabel") and d:GetAttribute("glowOff") ~= true then
				d.ImageTransparency = UI.glowAlpha(tonumber(d:GetAttribute("glowStrength")) or 1)
			end
		end
	end

	-- motion: 0.20–0.42 s, continuous (no stepped pixels). Quart / Cubic, not Quint: a Quint ease-out
	-- covers ~55 % of the distance in its first frame at 30–60 fps, which reads as a jump and a crawl.
	-- lead / trail drive the two edges of a moving indicator (UI.liquid): the edge in front arrives
	-- first, the one behind catches up, so the pill stretches toward its target and settles.
	local TW_OPEN = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local TW_TAB = TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local TW_TOGGLE = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local TW_KNOB = TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local TW_HOVER = TweenInfo.new(0.20, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local TW_TOAST_IN = TweenInfo.new(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local TW_TOAST_OUT = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	UI.TW = {
		open = TW_OPEN, close = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.In), tab = TW_TAB, toggle = TW_TOGGLE, knob = TW_KNOB, hover = TW_HOVER,
		toastIn = TW_TOAST_IN, toastOut = TW_TOAST_OUT, pop = TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		lead = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), trail = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		reveal = TweenInfo.new(0.30, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
	}
	local function tween(obj: Instance, info: TweenInfo, props: any)
		local t = TweenService:Create(obj, info, props)
		t:Play()
		return t
	end
	UI.tween = tween
	-- a whole subtree fades in to the transparencies it was built with (or out and back): the crisp way
	-- to show a popup / row. The old unrolls grew Size under ClipsDescendants, which clips rectangles —
	-- rounded corners and strokes came out square and text was revealed a pixel row at a time.
	-- While a fade runs, UI.fadeLive[obj] keeps the transparencies the object really has: a fade that
	-- starts on top of an unfinished one heads back to those, never to a half-faded value (an interrupted
	-- close used to leave text at transparency 1 — the sub-options came back invisible). The record goes
	-- away when its fade settles, so a real change between fades (a switch turning on) still counts.
	UI.fadeLive = setmetatable({}, { __mode = "k" })
	function UI.fadeTargets(root: Instance): { { any } }
		local out = {}
		local list = root:GetDescendants()
		table.insert(list, root)
		for _, d in ipairs(list) do
			local props: any = nil
			local live = UI.fadeLive[d]
			if live then
				props = table.clone(live.props)
			elseif d:IsA("UIStroke") then
				if d.Transparency < 1 then
					props = { Transparency = d.Transparency }
				end
			elseif d:IsA("GuiObject") and d.Visible then
				props = {}
				if d.BackgroundTransparency < 1 then
					props.BackgroundTransparency = d.BackgroundTransparency
				end
				if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and (d :: any).TextTransparency < 1 then
					props.TextTransparency = (d :: any).TextTransparency
				end
				if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and (d :: any).ImageTransparency < 1 then
					props.ImageTransparency = (d :: any).ImageTransparency
				end
				if next(props) == nil then
					props = nil
				end
			end
			if props then
				table.insert(out, { d, props })
			end
		end
		return out
	end
	local function fadeSet(d: Instance, props: any)
		for k, v in pairs(props) do
			pcall(function()
				(d :: any)[k] = v
			end)
		end
	end
	-- stops a running fade on the whole subtree and puts the real transparencies back at once
	function UI.fadeReset(root: Instance)
		local list = root:GetDescendants()
		table.insert(list, root)
		for _, d in ipairs(list) do
			local live = UI.fadeLive[d]
			if live then
				UI.fadeLive[d] = nil
				pcall(live.tween.Cancel, live.tween)
				fadeSet(d, live.props)
			end
		end
	end
	function UI.fadeIn(root: Instance, info: TweenInfo?)
		local ti = info or UI.TW.pop
		for _, e in ipairs(UI.fadeTargets(root)) do
			local d, props = e[1], e[2]
			local live = UI.fadeLive[d]
			if live then
				pcall(live.tween.Cancel, live.tween) -- continue from where it is, toward the real values
			else
				for k in pairs(props) do
					(d :: any)[k] = 1
				end
			end
			local rec: any = { props = props }
			rec.tween = tween(d, ti, props)
			UI.fadeLive[d] = rec
			rec.tween.Completed:Connect(function(state: any)
				if state == Enum.PlaybackState.Completed and UI.fadeLive[d] == rec then
					UI.fadeLive[d] = nil
				end
			end)
		end
	end
	-- fades out one subtree or a list of them, runs `done`, then puts every transparency back (the
	-- caller hides / destroys in `done`). Driven by a timer, not a tween's Completed: another tween on
	-- the same property cancels ours and fired Completed early, and the rest of the fade then ran on
	-- after the restore.
	function UI.fadeOut(root: any, info: TweenInfo?, done: (() -> ())?)
		local ti = info or UI.TW.close
		local targets = {}
		for _, r in ipairs(if typeof(root) == "Instance" then { root } else root) do
			for _, e in ipairs(UI.fadeTargets(r)) do
				table.insert(targets, e)
			end
		end
		local recs = {}
		for i, e in ipairs(targets) do
			local d, props = e[1], e[2]
			local live = UI.fadeLive[d]
			if live then
				pcall(live.tween.Cancel, live.tween)
			end
			local fade = {}
			for k in pairs(props) do
				fade[k] = 1
			end
			local rec: any = { props = props }
			rec.tween = tween(d, ti, fade)
			UI.fadeLive[d] = rec
			recs[i] = rec
		end
		task.delay(ti.Time + ti.DelayTime, function()
			for _, rec in ipairs(recs) do
				pcall(rec.tween.Cancel, rec.tween)
			end
			if done then
				local ok, err = pcall(done)
				if not ok then
					log("WARN", "fade: " .. tostring(err))
				end
			end
			for i, e in ipairs(targets) do
				local d = e[1]
				-- only what is still ours: a fade that started since owns the object now
				if UI.fadeLive[d] == recs[i] then
					UI.fadeLive[d] = nil
					fadeSet(d, e[2])
				end
			end
		end)
	end
	-- a moving indicator's two edges (a, b along one axis) on NumberValues parented to `holder` (they
	-- die with it). `to` glides them — the leading edge on TW.lead, the trailing one on TW.trail — or
	-- snaps them (first placement, scrolling, layout changes). `apply(a, b)` paints the indicator.
	function UI.liquid(holder: Instance, apply: (number, number) -> ()): any
		local L: any = { tw = {}, placed = false }
		L.a = Instance.new("NumberValue")
		L.b = Instance.new("NumberValue")
		L.a.Parent, L.b.Parent = holder, holder
		local function paint()
			apply(L.a.Value, L.b.Value)
		end
		L.a.Changed:Connect(paint)
		L.b.Changed:Connect(paint)
		function L.to(a: number, b: number, animate: boolean?)
			for _, t in ipairs(L.tw) do
				t:Cancel()
			end
			table.clear(L.tw)
			if not animate or not L.placed then
				L.placed = true
				L.a.Value, L.b.Value = a, b
				paint()
				return
			end
			local forward = a > L.a.Value
			table.insert(L.tw, tween(L.a, if forward then UI.TW.trail else UI.TW.lead, { Value = a }))
			table.insert(L.tw, tween(L.b, if forward then UI.TW.lead else UI.TW.trail, { Value = b }))
		end
		return L
	end

	local order = 0
	local function nextOrder(): number
		order += 1
		return order
	end
	UI.nextOrder = nextOrder
	local function corner(p: GuiObject, r: number)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r)
		c.Parent = p
	end
	local function stroke(p: GuiObject, color: Color3, tr: number): UIStroke
		local s = Instance.new("UIStroke")
		s.Color = color
		s.Thickness = 1
		s.Transparency = tr
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.LineJoinMode = Enum.LineJoinMode.Round
		s.Parent = p
		return s
	end
	local function gradient(p: GuiObject, c1: Color3, c2: Color3, rotation: number?): UIGradient
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new(c1, c2)
		g.Rotation = rotation or 0
		g.Parent = p
		return g
	end
	local function vlist(p: GuiObject, pad: number, horizontal: boolean?): UIListLayout
		local l = Instance.new("UIListLayout")
		l.SortOrder = Enum.SortOrder.LayoutOrder
		l.Padding = UDim.new(0, pad)
		if horizontal then
			l.FillDirection = Enum.FillDirection.Horizontal
		end
		l.Parent = p
		return l
	end
	local function padding(p: GuiObject, t: number, r: number, b: number, l: number)
		local u = Instance.new("UIPadding")
		u.PaddingTop = UDim.new(0, t)
		u.PaddingRight = UDim.new(0, r)
		u.PaddingBottom = UDim.new(0, b)
		u.PaddingLeft = UDim.new(0, l)
		u.Parent = p
	end
	-- v5.3: UI.F holds Font objects (FontFace); an Enum.Font still works for old call sites
	function UI.setFont(t: any, font: any)
		if typeof(font) == "Font" then
			t.FontFace = font
		elseif typeof(font) == "EnumItem" then
			t.Font = font
		else
			t.FontFace = UI.F.body
		end
	end
	local function label(p: GuiObject, text: string, size: number, color: Color3, font: any?): TextLabel
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		UI.setFont(t, font or UI.F.body)
		t.TextSize = size
		t.TextColor3 = color
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Text = text
		t.Parent = p
		return t
	end
	local function frame(p: GuiObject?, bg: Color3?): Frame
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		if bg then
			f.BackgroundColor3 = bg
		else
			f.BackgroundTransparency = 1
		end
		if p then
			f.Parent = p
		end
		return f
	end
	local function button(p: GuiObject, text: string, size: number, color: Color3, bg: Color3?): TextButton
		local b = Instance.new("TextButton")
		b.BackgroundColor3 = bg or C.surface
		b.BorderSizePixel = 0
		UI.setFont(b, UI.F.medium)
		b.TextSize = size
		b.TextColor3 = color
		b.Text = text
		b.AutoButtonColor = false
		b.Parent = p
		return b
	end
	UI.corner, UI.stroke, UI.gradient, UI.vlist, UI.padding, UI.label, UI.frame, UI.button = corner, stroke, gradient, vlist, padding, label, frame, button
	-- brushed metal (metal looks only): a top-lit metal gradient with a thin light along the top edge. Text and
	-- icons on it take UI.metal.ink. Returns false on the accent looks, which keep their quiet selection.
	function UI.brushed(f: GuiObject): boolean
		local m = UI.metal
		if not m then
			return false
		end
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		local g = f:FindFirstChild("Brushed") :: UIGradient?
		if not g then
			local ng = Instance.new("UIGradient")
			ng.Name = "Brushed"
			ng.Rotation = 90
			ng.Parent = f
			g = ng
		end
		(g :: UIGradient).Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, m.hi),
			ColorSequenceKeypoint.new(0.58, m.lite),
			ColorSequenceKeypoint.new(1, m.lite:Lerp(m.mid, 0.4)),
		})
		if not f:FindFirstChild("BrushedLight") then
			local sheen = Instance.new("Frame")
			sheen.Name = "BrushedLight"
			sheen.BorderSizePixel = 0
			sheen.BackgroundColor3 = Color3.new(1, 1, 1)
			sheen.BackgroundTransparency = 0.05
			sheen.AnchorPoint = Vector2.new(0.5, 0)
			sheen.Position = UDim2.new(0.5, 0, 0, 1)
			sheen.Size = UDim2.new(1, -8, 0, 1)
			sheen.ZIndex = f.ZIndex
			sheen.Parent = f
			local sg = Instance.new("UIGradient")
			sg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.18, 0.15), NumberSequenceKeypoint.new(0.82, 0.15), NumberSequenceKeypoint.new(1, 1) })
			sg.Parent = sheen
		end
		local lip = f:FindFirstChildOfClass("UIStroke")
		if lip then
			lip.Color = m.dark
			lip.Transparency = 0.5
		end
		return true
	end
	-- a key that is brushed while on and a plain surface while off (HUD keycaps, chips)
	function UI.keyState(f: GuiObject, on: boolean, offColor: Color3, offAlpha: number?): boolean
		if not UI.brushed(f) then
			return false
		end
		local g = f:FindFirstChild("Brushed")
		if g then
			(g :: UIGradient).Enabled = on
		end
		local light = f:FindFirstChild("BrushedLight")
		if light then
			(light :: Frame).Visible = on
		end
		f.BackgroundColor3 = if on then Color3.new(1, 1, 1) else offColor
		f.BackgroundTransparency = if on then 0 else (offAlpha or 0)
		return true
	end
	-- a switch / slider fill: the same lit metal instead of the accent pair
	function UI.metalFill(g: UIGradient)
		local m = UI.metal
		if not m then
			return
		end
		g.Rotation = 90
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, m.hi),
			ColorSequenceKeypoint.new(0.45, m.lite),
			ColorSequenceKeypoint.new(1, m.lite:Lerp(m.mid, 0.6)),
		})
	end
	-- the turning metal edge on a window-sized stroke: every stop is a tinted metal (it never whites out or
	-- fades in places); the caller turns it with Menu.loop so it only moves while the menu is open
	function UI.metalEdge(s: UIStroke): UIGradient?
		local m = UI.metal
		if not m then
			return nil
		end
		local a, b, c = m.lite:Lerp(C.accent, 0.35), m.mid:Lerp(m.lite, 0.45), m.lite:Lerp(Color3.new(1, 1, 1), 0.16)
		s.Color = Color3.new(1, 1, 1)
		s.Transparency = 0
		local g = s:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, b),
			ColorSequenceKeypoint.new(0.25, a),
			ColorSequenceKeypoint.new(0.5, c),
			ColorSequenceKeypoint.new(0.75, a),
			ColorSequenceKeypoint.new(1, b),
		})
		g.Parent = s
		return g
	end
	-- a popover's edge (bind popup, dropdowns, tooltips): the metal edge and an even accent glow on the metal
	-- looks, the accent hairline elsewhere
	function UI.popEdge(p: GuiObject, radius: number?)
		local s = stroke(p, C.accent, 0.6)
		local g = UI.metalEdge(s)
		if g then
			g.Rotation = 35
			UI.softShadow(p, "Aura", C.accent, UI.glowAlpha(0.45), 14, radius)
		end
		return s
	end
	-- acrylic, opaque: the panel's own colour (opts.tint), lit from above (a luminosity gradient,
	-- opts.light), a grain layer (opts.grain = its transparency, false = none) and optionally a glass
	-- edge (opts.edge = the top edge's stroke transparency, fading toward the foot). The grain renders
	-- above the panel's background and under its content: give it a ZIndex below the content (opts.z).
	function UI.acrylic(f: GuiObject, opts: any?): any
		opts = opts or {}
		local out: any = {}
		if opts.tint then
			f.BackgroundColor3 = opts.tint
		end
		local lum = if type(opts.light) == "number" then opts.light else 0.1
		if lum > 0 then
			local g = Instance.new("UIGradient")
			g.Name = "AcrylicLight"
			g.Rotation = opts.lightRotation or 90
			g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1 - lum, 1 - lum, 1 - lum))
			g.Parent = f
			out.light = g
		end
		if UI.noiseTile and opts.grain ~= false then
			local n = Instance.new("ImageLabel")
			n.Name = "AcrylicGrain"
			n.BackgroundTransparency = 1
			n.Image = UI.noiseTile
			n.ScaleType = Enum.ScaleType.Tile
			n.TileSize = UDim2.fromOffset(96, 96)
			n.ImageTransparency = if type(opts.grain) == "number" then opts.grain else 0.955
			n.Size = opts.grainSize or UDim2.fromScale(1, 1)
			n.ZIndex = opts.z or 1
			n.Active = false
			n.Parent = f
			if opts.radius then
				corner(n, opts.radius)
			end
			out.grain = n
		end
		if type(opts.edge) == "number" then
			local s = stroke(f, opts.edgeColor or Color3.new(1, 1, 1), 0)
			s.Name = "AcrylicEdge"
			local eg = Instance.new("UIGradient")
			eg.Rotation = 90
			eg.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, opts.edge),
				NumberSequenceKeypoint.new(0.5, math.min(1, opts.edge + 0.12)),
				NumberSequenceKeypoint.new(1, math.min(1, opts.edge + 0.22)),
			})
			eg.Parent = s
			out.edge = s
		end
		return out
	end
	-- a soft falloff `spread` px around `parent`'s 12 px rounded box and nothing inside it
	-- (UI.falloffTile); black = shadow, the accent = an aura
	function UI.softShadow(parent: GuiObject, name: string, color: Color3, transparency: number, spread: number, radius: number?): ImageLabel?
		local id, slice = UI.falloffTile(spread, radius)
		if not (id and slice) then
			return nil
		end
		local sh = Instance.new("ImageLabel")
		sh.Name = name
		sh.BackgroundTransparency = 1
		sh.Image = id
		sh.ImageColor3 = color
		sh.ImageTransparency = transparency
		sh.ScaleType = Enum.ScaleType.Slice
		sh.SliceCenter = slice
		sh.SliceScale = 1
		sh.AnchorPoint = Vector2.new(0.5, 0.5)
		sh.Position = UDim2.fromScale(0.5, 0.5)
		sh.Size = UDim2.new(1, spread * 2, 1, spread * 2)
		sh.ZIndex = 0
		sh.Active = false
		sh.Parent = parent
		return sh
	end

	-- fallback tab icons (no icon font): geometric glyphs drawn from frames on a 100×100 scale
	-- canvas. Returns the canvas; every child is tinted by recolourIcon().
	local function iconFallback(parent: GuiObject, name: string): Frame
		local canvas = frame(parent)
		canvas.Name = "Icon"
		canvas.Size = UDim2.new(0, 20, 0, 20)
		canvas.AnchorPoint = Vector2.new(0.5, 0.5)
		canvas.Position = UDim2.fromScale(0.5, 0.5)
		local col = Color3.new(1, 1, 1)
		-- primitives positioned in 0..1 scale so they scale with the badge
		local function box(x: number, y: number, w: number, h: number, opts: any?): Frame
			opts = opts or {}
			local f = frame(canvas, col)
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.fromScale(x, y)
			f.Size = UDim2.fromScale(w, h)
			f.Rotation = opts.rot or 0
			f.BackgroundTransparency = opts.tr or 0
			if opts.round then
				corner(f, opts.round)
			end
			f:SetAttribute("iconPart", true)
			return f
		end
		local function ring(x: number, y: number, d: number, thick: number, filled: boolean?): Frame
			local f = frame(canvas, col)
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.fromScale(x, y)
			f.Size = UDim2.fromScale(d, d)
			f.BackgroundTransparency = if filled then 0 else 1
			corner(f, 999)
			f:SetAttribute("iconPart", true)
			if not filled then
				local s = stroke(f, col, 0)
				s.Thickness = thick or 2
				s:SetAttribute("iconStroke", true)
			end
			return f
		end
		-- stroke-only shape of any aspect (pill / rounded rect) — an outline without a fill
		local function outline(x: number, y: number, w: number, h: number, thick: number, roundR: number, rot: number?): Frame
			local f = frame(canvas, col)
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.fromScale(x, y)
			f.Size = UDim2.fromScale(w, h)
			f.Rotation = rot or 0
			f.BackgroundTransparency = 1
			corner(f, roundR)
			f:SetAttribute("iconPart", true)
			local s = stroke(f, col, 0)
			s.Thickness = thick
			s:SetAttribute("iconStroke", true)
			return f
		end
		if name == "Aimbot" then
			-- crosshair: ring, four ticks, a small centre dot
			ring(0.5, 0.5, 0.8, 2)
			box(0.5, 0.5, 0.12, 0.12, { round = 999 })
			box(0.5, 0.1, 0.08, 0.26, { round = 999 })
			box(0.5, 0.9, 0.08, 0.26, { round = 999 })
			box(0.1, 0.5, 0.26, 0.08, { round = 999 })
			box(0.9, 0.5, 0.26, 0.08, { round = 999 })
		elseif name == "Silent" then
			-- a bullet in flight: capsule head + two fading speed lines behind it
			box(0.62, 0.38, 0.62, 0.26, { round = 999, rot = -35 })
			box(0.26, 0.66, 0.34, 0.08, { round = 999, rot = -35, tr = 0.25 })
			box(0.18, 0.86, 0.22, 0.08, { round = 999, rot = -35, tr = 0.55 })
		elseif name == "Rage" then
			-- lightning bolt: three zig-zag strokes
			box(0.58, 0.24, 0.2, 0.46, { rot = 28, round = 2 })
			box(0.5, 0.5, 0.42, 0.16, { rot = -20, round = 2 })
			box(0.42, 0.76, 0.2, 0.46, { rot = 28, round = 2 })
		elseif name == "Visuals" then
			-- an eye: pill outline + iris ring + pupil
			outline(0.5, 0.5, 0.96, 0.58, 2, 999)
			ring(0.5, 0.5, 0.42, 2)
			box(0.5, 0.5, 0.16, 0.16, { round = 999 })
		elseif name == "World" then
			-- globe: outer ring, equator, one meridian (thin pill outline)
			ring(0.5, 0.5, 0.92, 2)
			box(0.5, 0.5, 0.86, 0.07, { round = 999 })
			outline(0.5, 0.5, 0.42, 0.9, 2, 999)
		elseif name == "Skins" then
			-- T-shirt: torso, two sleeves, collar notch
			box(0.5, 0.6, 0.48, 0.62, { round = 3 })
			box(0.24, 0.34, 0.34, 0.2, { round = 3, rot = -30 })
			box(0.76, 0.34, 0.34, 0.2, { round = 3, rot = 30 })
			local notch = box(0.5, 0.29, 0.2, 0.12, { round = 999 })
			notch.BackgroundColor3 = C.surface
			notch:SetAttribute("iconPart", nil)
			notch:SetAttribute("iconHole", true)
		elseif name == "Interface" then
			-- four tiles
			for _, p in ipairs({ { 0.3, 0.3 }, { 0.7, 0.3 }, { 0.3, 0.7 }, { 0.7, 0.7 } }) do
				box(p[1], p[2], 0.32, 0.32, { round = 3 })
			end
		elseif name == "Debug" then
			-- terminal: rounded outline, a chevron prompt and a cursor bar
			outline(0.5, 0.5, 0.92, 0.76, 2, 4)
			box(0.33, 0.43, 0.24, 0.07, { rot = 40, round = 999 })
			box(0.33, 0.57, 0.24, 0.07, { rot = -40, round = 999 })
			box(0.66, 0.64, 0.26, 0.07, { round = 999 })
		elseif name == "menu" then
			-- three lines: a row that opens its sub-options
			for _, y in ipairs({ 0.24, 0.5, 0.76 }) do
				box(0.5, y, 0.78, 0.12, { round = 999 })
			end
		elseif name == "Settings" then
			-- gear: eight teeth around a ring with a hollow centre
			for i = 0, 7 do
				local a = math.rad(i * 45)
				box(0.5 + math.cos(a) * 0.4, 0.5 + math.sin(a) * 0.4, 0.26, 0.26, { round = 2, rot = i * 45 })
			end
			ring(0.5, 0.5, 0.66, 3, true)
			local hole = ring(0.5, 0.5, 0.26, 2, true)
			hole.BackgroundColor3 = C.surface
			hole:SetAttribute("iconPart", nil)
		else
			box(0.5, 0.5, 0.5, 0.5, { round = 4 })
		end
		return canvas
	end
	local function recolourIcon(canvas: GuiObject, color: Color3)
		if canvas:IsA("TextLabel") then
			canvas.TextColor3 = color
			return
		end
		for _, ch in ipairs(canvas:GetDescendants()) do
			if ch:IsA("UIStroke") then
				ch.Color = color
			elseif ch:GetAttribute("iconPart") then
				(ch :: Frame).BackgroundColor3 = color
			end
		end
	end
	-- Material Icons ligature names (every one verified to render as a single glyph)
	UI.ICONS = {
		Aimbot = "gps_fixed", Trigger = "my_location", Silent = "track_changes", Rage = "bolt", Misc = "widgets", Visuals = "visibility",
		World = "public", Skins = "checkroom", Interface = "dashboard", Settings = "settings", Config = "tune", Debug = "terminal",
		search = "search", save = "save", close = "close", expand = "expand_more", help = "help_outline", warn = "warning_amber",
		check = "check", keyboard = "keyboard", power = "power_settings_new", arrange = "open_with", info = "info", gem = "diamond",
		left = "chevron_left", right = "chevron_right", kill = "my_location", person = "person_outline", refresh = "refresh",
		menu = "menu",
	}
	-- a square icon centred in `parent` (size px); the font glyph when loaded, the frame glyph otherwise
	local function icon(parent: GuiObject, name: string, size: number?): GuiObject
		local px = size or 16
		if UI.F.icon then
			local t = label(parent, UI.ICONS[name] or name, px, C.muted, UI.F.icon)
			t.Name = "Icon"
			t.Size = UDim2.fromOffset(px + 2, px + 2)
			t.AnchorPoint = Vector2.new(0.5, 0.5)
			t.Position = UDim2.fromScale(0.5, 0.5)
			t.TextXAlignment = Enum.TextXAlignment.Center
			t.TextYAlignment = Enum.TextYAlignment.Center
			return t
		end
		local canvas = iconFallback(parent, name)
		canvas.Size = UDim2.fromOffset(px, px)
		return canvas
	end
	UI.icon, UI.recolourIcon = icon, recolourIcon
	-- the logo mark in the accent gradient, `size` px square and centred in `parent` (the face; the
	-- diamond glyph only when the face texture could not be written)
	-- the Max Cute mascot: a round white cat face with ears, dot eyes, a little nose, whiskers and a bow in
	-- the accent — drawn from frames, so it needs no image. Children follow the root's ZIndex.
	function UI.cuteLogo(parent: GuiObject, size: number): Frame
		local sz = math.max(math.floor(size + 0.5), 10)
		local root = Instance.new("Frame")
		root.Name = "LogoMark"
		root.BackgroundTransparency = 1
		root.AnchorPoint = Vector2.new(0.5, 0.5)
		root.Position = UDim2.fromScale(0.5, 0.5)
		root.Size = UDim2.fromOffset(sz, sz)
		local white = Color3.fromRGB(255, 250, 252)
		local order = 0
		local function part(col: Color3, w: number, h: number, x: number, y: number, rot: number?, round: number?): Frame
			order += 1
			local f = Instance.new("Frame")
			f.BorderSizePixel = 0
			f.BackgroundColor3 = col
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Size = UDim2.fromOffset(math.max(1, math.floor(w + 0.5)), math.max(1, math.floor(h + 0.5)))
			f.Position = UDim2.new(0.5, math.floor(x + 0.5), 0.5, math.floor(y + 0.5))
			f.Rotation = rot or 0
			f:SetAttribute("z", order)
			if round then
				corner(f, math.max(1, math.floor(round + 0.5)))
			end
			f.Parent = root
			return f
		end
		-- the glow first, so it stacks under everything
		order += 1
		local glow = Instance.new("ImageLabel")
		glow.Name = "Glow"
		glow.BackgroundTransparency = 1
		glow.Image = UI.glowRadial or UI.GLOW_IMAGE
		glow.ImageColor3 = C.accent
		glow.ImageTransparency = 0.55
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Position = UDim2.fromScale(0.5, 0.52)
		glow.Size = UDim2.fromOffset(math.floor(sz * 1.9), math.floor(sz * 1.9))
		glow:SetAttribute("z", order)
		glow.Parent = root
		local blush = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 214, 234))
		for _, side in ipairs({ -1, 1 }) do
			local ear = part(white, sz * 0.32, sz * 0.32, side * sz * 0.26, -sz * 0.2, 45, sz * 0.07)
			gradient(ear, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90).Color = blush
			-- the inner ear, in the accent
			part(C.accent:Lerp(Color3.new(1, 1, 1), 0.35), sz * 0.15, sz * 0.15, side * sz * 0.26, -sz * 0.18, 45, sz * 0.04)
		end
		local face = part(white, sz * 0.88, sz * 0.7, 0, sz * 0.06, 0, sz * 0.35)
		gradient(face, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90).Color = blush
		-- rosy cheeks
		for _, side in ipairs({ -1, 1 }) do
			local cheek = part(C.accent, sz * 0.14, sz * 0.08, side * sz * 0.29, sz * 0.17, 0, sz)
			cheek.BackgroundTransparency = 0.45
		end
		local ink = Color3.fromRGB(46, 26, 40)
		for _, side in ipairs({ -1, 1 }) do
			part(ink, math.max(2, sz * 0.09), math.max(2, sz * 0.12), side * sz * 0.19, sz * 0.05, 0, sz)
		end
		part(Color3.fromRGB(255, 196, 92), math.max(2, sz * 0.11), math.max(2, sz * 0.075), 0, sz * 0.14, 0, sz)
		if sz >= 16 then
			for _, side in ipairs({ -1, 1 }) do
				for i = -1, 1 do
					part(Color3.fromRGB(96, 66, 86), sz * 0.15, 1, side * sz * 0.43, sz * (0.11 + i * 0.065), side * i * 12)
				end
			end
		end
		local bow = C.accent
		for _, side in ipairs({ -1, 1 }) do
			part(bow, sz * 0.21, sz * 0.17, sz * 0.27 + side * sz * 0.1, -sz * 0.31, side * 20, sz * 0.07)
		end
		part(bow:Lerp(Color3.new(1, 1, 1), 0.3), math.max(2, sz * 0.09), math.max(2, sz * 0.09), sz * 0.27, -sz * 0.31, 0, sz)
		local function restack()
			for _, d in ipairs(root:GetChildren()) do
				if d:IsA("GuiObject") then
					d.ZIndex = root.ZIndex + (d:GetAttribute("z") or 0)
				end
			end
		end
		restack()
		root:GetPropertyChangedSignal("ZIndex"):Connect(restack)
		root.Parent = parent
		return root
	end
	-- a Max look's own mark (full colour, no accent gradient); nil when the texture cannot be written
	function UI.themeLogo(parent: GuiObject, size: number, key: string): ImageLabel?
		local id = UI.themeLogoPng(key, size)
		if not id then
			return nil
		end
		local px = math.floor(size + 0.5)
		local img = Instance.new("ImageLabel")
		img.Name = "LogoMark"
		img.BackgroundTransparency = 1
		img.Image = id
		img.ScaleType = Enum.ScaleType.Fit
		img.Size = UDim2.fromOffset(px, px)
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.Position = UDim2.fromScale(0.5, 0.5)
		img.Parent = parent
		return img
	end
	function UI.logoMark(parent: GuiObject, size: number, rotation: number?): GuiObject
		if UI.themeName and UI.themeName() == "Max Cute" and S.edition == "max" then
			return UI.cuteLogo(parent, size)
		end
		local fx = UI.themeFx and UI.themeFx()
		if fx then
			local own = UI.themeLogo(parent, size, fx.key)
			if own then
				return own
			end
		end
		local m: GuiObject
		size = math.floor(size + 0.5)
		local face = if UI.faceIcon then UI.buildFacePng(size) or UI.faceIcon else nil
		if face then
			local img = Instance.new("ImageLabel")
			img.Name = "LogoMark"
			img.BackgroundTransparency = 1
			img.Image = face
			img.ImageColor3 = Color3.new(1, 1, 1)
			img.ScaleType = Enum.ScaleType.Fit
			img.Size = UDim2.fromOffset(size, size)
			img.AnchorPoint = Vector2.new(0.5, 0.5)
			img.Position = UDim2.fromScale(0.5, 0.5)
			img.Parent = parent
			m = img
		elseif UI.F.icon then
			m = label(parent, "diamond", size, Color3.new(1, 1, 1), UI.F.icon)
			m.Size = UDim2.fromOffset(size, size)
			m.AnchorPoint = Vector2.new(0.5, 0.5)
			m.Position = UDim2.fromScale(0.5, 0.5);
			(m :: TextLabel).TextXAlignment = Enum.TextXAlignment.Center
		else
			m = frame(parent, Color3.new(1, 1, 1))
			m.Size = UDim2.fromOffset(math.floor(size * 0.65), math.floor(size * 0.65))
			m.AnchorPoint = Vector2.new(0.5, 0.5)
			m.Position = UDim2.fromScale(0.5, 0.5)
			m.Rotation = 45
			corner(m, 2)
		end
		local g = gradient(m, C.accent, C.accent2, rotation or 45)
		if UI.metal and not fx then
			-- metal looks: the mark is lit metal like the wordmark (light top, a darker band, a bright line)
			g.Rotation = 90
			g.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, UI.metal.hi),
				ColorSequenceKeypoint.new(0.35, UI.metal.lite),
				ColorSequenceKeypoint.new(0.55, UI.metal.lite:Lerp(UI.metal.mid, 0.55)),
				ColorSequenceKeypoint.new(0.68, UI.metal.hi),
				ColorSequenceKeypoint.new(1, UI.metal.lite),
			})
		end
		return m
	end
	-- the HUD's type (v0.9): Gotham in two weights, measured with TextService against the exact face that is
	-- drawn. TextBounds is read before a custom font finishes loading, which left boxes too narrow and a
	-- badge sitting on the text beside it.
	UI.HUD_FONT = Font.fromEnum(Enum.Font.GothamMedium)
	UI.HUD_BOLD = Font.fromEnum(Enum.Font.GothamBold)
	function UI.gw(text: string, size: number, bold: boolean?): number
		local ts = game:GetService("TextService")
		local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, if bold then Enum.Font.GothamBold else Enum.Font.GothamMedium, Vector2.new(4000, 400))
		return if ok and sz then math.ceil(sz.X) else math.ceil(#tostring(text or "") * size * 0.62)
	end
	-- the max tag: the three-glint cluster and "max" in dark ink on a brushed toxic plate (the Max looks keep
	-- their own plate, with white glints and text). The gradient sits on the tag Frame only (a UIGradient on
	-- a TextLabel tints its text too). world = the billboard over a Max user's head: a little larger.
	UI.MAX_BLUE, UI.MAX_DEEP = Color3.fromRGB(182, 240, 58), Color3.fromRGB(111, 158, 26)
	UI.MAX_TEXT = Color3.fromRGB(205, 240, 106)
	UI.MAX_INK = Color3.fromRGB(21, 32, 3)
	-- one white four-point glint, supersampled 4 × 4 per pixel. Roblox scales images without mipmaps (a 64 px
	-- sprite drawn at 8 px broke up into dots), so each glint gets a sprite about twice its drawn size (steps of
	-- 8 px, 16–64, cached)
	UI.sparkleIds = {}
	function UI.sparklePng(px: number?): string?
		local N = math.clamp(math.ceil((px or 32) * 2 / 8) * 8, 16, 64)
		local have = UI.sparkleIds[N]
		if have ~= nil then
			return have or nil
		end
		local SS = 4
		local id = UI.pngAsset(("sparkle%d_v2.png"):format(N), N, function(x: number, y: number)
			local hit = 0
			for sy = 0, SS - 1 do
				for sx = 0, SS - 1 do
					local u = math.abs((x + (sx + 0.5) / SS) / N * 2 - 1)
					local v = math.abs((y + (sy + 0.5) / SS) / N * 2 - 1)
					if u ^ 0.7 + v ^ 0.7 <= 1 then
						hit += 1
					end
				end
			end
			return 255, 255, 255, math.floor(hit / (SS * SS) * 255 + 0.5)
		end)
		UI.sparkleIds[N] = id or false
		UI.sparkleId = UI.sparkleId or id
		return id
	end
	-- the cluster in a 24-unit box: { x, y, radius, twinkle period, delay } — one big glint, two small ones
	UI.SPARKLES = { { 9.5, 14, 8.5, 2.6, 0 }, { 18.6, 5.4, 4.1, 1.9, 0.7 }, { 19.2, 18.4, 2.6, 2.2, 1.4 } }
	local function glint(parent: GuiObject, x: number, y: number, size: number, delay: number)
		local holder = Instance.new("Frame")
		holder.Name = "Glint"
		holder.BackgroundTransparency = 1
		holder.AnchorPoint = Vector2.new(0.5, 0.5)
		holder.Position = UDim2.new(x, 0, y, 0)
		holder.Size = UDim2.fromOffset(size, size)
		holder.ZIndex = parent.ZIndex + 2
		holder.Parent = parent
		for i = 1, 4 do
			local diag = i > 2
			local bar = Instance.new("Frame")
			bar.BorderSizePixel = 0
			bar.BackgroundColor3 = Color3.new(1, 1, 1)
			bar.BackgroundTransparency = if diag then 0.35 else 0
			bar.AnchorPoint = Vector2.new(0.5, 0.5)
			bar.Position = UDim2.fromScale(0.5, 0.5)
			bar.Size = if i % 2 == 1 then UDim2.new(if diag then 0.55 else 1, 0, 0, 1) else UDim2.new(0, 1, if diag then 0.55 else 1, 0)
			bar.Rotation = if diag then 45 else 0
			bar.ZIndex = holder.ZIndex
			bar.Parent = holder
			local g = Instance.new("UIGradient")
			g.Rotation = if i % 2 == 1 then 0 else 90
			g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
			g.Parent = bar
		end
		local sc = Instance.new("UIScale")
		sc.Scale = 0.35
		sc.Parent = holder
		pcall(function()
			game:GetService("TweenService"):Create(sc, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, delay), { Scale = 1 }):Play()
		end)
	end
	-- the max mark, `size` px square: three tinted glints, each twinkling on its own clock (the frame-drawn
	-- glints stand in when the sprite could not be written)
	function UI.sparkles(parent: GuiObject, size: number, color: Color3, z: number): Frame
		local box = Instance.new("Frame")
		box.Name = "Sparkles"
		box.BackgroundTransparency = 1
		box.Size = UDim2.fromOffset(size, size)
		box.ZIndex = z
		box.Parent = parent
		for _, s in ipairs(UI.SPARKLES) do
			local img = UI.sparklePng(s[3] * 2 / 24 * size)
			if not img then
				glint(box, s[1] / 24, s[2] / 24, math.max(3, math.floor(s[3] * 2 / 24 * size + 0.5)), s[5])
				continue
			end
			local star = Instance.new("ImageLabel")
			star.Name = "Glint"
			star.BackgroundTransparency = 1
			star.Image = img
			star.ImageColor3 = color
			star.AnchorPoint = Vector2.new(0.5, 0.5)
			star.Position = UDim2.fromScale(s[1] / 24, s[2] / 24)
			star.Size = UDim2.fromScale(s[3] * 2 / 24, s[3] * 2 / 24)
			star.ZIndex = z
			star.Parent = box
			local sc = Instance.new("UIScale")
			sc.Parent = star
			pcall(function()
				game:GetService("TweenService"):Create(sc, TweenInfo.new(s[4] / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, s[5]), { Scale = 0.68 }):Play()
			end)
		end
		return box
	end
	function UI.maxBadge(parent: Instance, h: number?, world: boolean?): Frame
		local height = math.max(math.floor((h or 16) + 0.5), 14)
		local size = if height >= 20 then 13 elseif height >= 18 then 12 else 11
		local f = Instance.new("Frame")
		f.Name = "MaxBadge"
		f.BorderSizePixel = 0
		-- [pad][cluster][gap][max][pad], the cluster and the word centred together on the plate
		local cl = math.floor(height * 0.8 + 0.5)
		local padL, gap, padR = math.floor(height * 0.28 + 0.5), math.max(2, math.floor(height * 0.16 + 0.5)), math.floor(height * 0.4 + 0.5)
		f.Size = UDim2.fromOffset(padL + cl + gap + UI.gw("max", size, true) + padR, height)
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		corner(f, if world then 5 else 4)
		local cute = UI.themeName and UI.themeName() == "Max Cute"
		local fx = UI.themeFx and UI.themeFx()
		if fx then
			-- the Max looks: the flag / theme gradient, a light ring, and candy-cane stripes on Xmas
			gradient(f, Color3.new(1, 1, 1), Color3.new(1, 1, 1), if #fx.tag > 2 then 0 else 90).Color = UI.fxSeq(fx.tag)
			local ring = Instance.new("UIStroke")
			ring.Color = fx.ring
			ring.Thickness = if world then 2 else 1.5
			ring.Transparency = 0.45
			ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ring.Parent = f
			if fx.candy then
				local cs = Instance.new("Frame")
				cs.Name = "Candy"
				cs.BorderSizePixel = 0
				cs.BackgroundColor3 = Color3.new(1, 1, 1)
				cs.Size = UDim2.fromScale(1, 1)
				cs.Parent = f
				corner(cs, if world then 5 else 4)
				local kp = {}
				for i = 0, 3 do
					local b = i * 0.25
					table.insert(kp, NumberSequenceKeypoint.new(b, 1))
					table.insert(kp, NumberSequenceKeypoint.new(b + 0.125, 1))
					table.insert(kp, NumberSequenceKeypoint.new(b + 0.126, 0.62))
					table.insert(kp, NumberSequenceKeypoint.new(b + 0.249, 0.62))
				end
				table.insert(kp, NumberSequenceKeypoint.new(1, 0.62))
				local cg = Instance.new("UIGradient")
				cg.Rotation = 35
				cg.Transparency = NumberSequence.new(kp)
				cg.Parent = cs
			end
		elseif cute then
			-- Max Cute: a three-stop blush → hot pink → orchid gradient and a soft pink glow ring
			local g = gradient(f, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90)
			g.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 196, 226)),
				ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 118, 186)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 84, 206)),
			})
			local ring = Instance.new("UIStroke")
			ring.Color = Color3.fromRGB(255, 150, 206)
			ring.Thickness = 2
			ring.Transparency = 0.45
			ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ring.Parent = f
		else
			-- toxic brushed plate with a dark lip and a light that crosses it every few seconds
			local g = gradient(f, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 90)
			g.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(246, 255, 216)),
				ColorSequenceKeypoint.new(0.52, Color3.fromRGB(205, 255, 85)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 211, 33)),
			})
			stroke(f, Color3.fromRGB(26, 40, 4), 0)
			f.ClipsDescendants = true
			local shine = Instance.new("Frame")
			shine.Name = "Shine"
			shine.BorderSizePixel = 0
			shine.BackgroundColor3 = Color3.new(1, 1, 1)
			shine.BackgroundTransparency = 0.3
			shine.Size = UDim2.new(0.34, 0, 1, -2)
			shine.Position = UDim2.new(-0.4, 0, 0, 1)
			shine.Parent = f
			local shg = Instance.new("UIGradient")
			shg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
			shg.Parent = shine
			pcall(function()
				game:GetService("TweenService"):Create(shine, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 3.6), { Position = UDim2.new(1.1, 0, 0, 1) }):Play()
			end)
		end
		-- a thin light along the top edge, fading out at the corners: the tag reads as a lit, raised piece
		local sheen = Instance.new("Frame")
		sheen.Name = "Sheen"
		sheen.BorderSizePixel = 0
		sheen.BackgroundColor3 = Color3.new(1, 1, 1)
		sheen.BackgroundTransparency = 0.45
		sheen.AnchorPoint = Vector2.new(0.5, 0)
		sheen.Position = UDim2.new(0.5, 0, 0, 1)
		sheen.Size = UDim2.new(1, -8, 0, 1)
		sheen.Parent = f
		local sg = Instance.new("UIGradient")
		sg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
		sg.Parent = sheen
		local toxic = not fx and not cute
		local ink = if toxic then UI.MAX_INK else Color3.new(1, 1, 1)
		local t = Instance.new("TextLabel")
		t.Name = "Word"
		t.BackgroundTransparency = 1
		t.FontFace = UI.HUD_BOLD
		t.Text = "max"
		t.TextSize = size
		t.TextColor3 = ink
		t.TextStrokeColor3 = if fx then fx.ink else Color3.fromRGB(110, 20, 70)
		-- the flag tags run through light bands (yellow, white): a firmer outline keeps the word readable
		t.TextStrokeTransparency = if toxic then 1 elseif fx then 0.5 else 0.78
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Size = UDim2.new(1, -(padL + cl + gap), 1, 0)
		t.Position = UDim2.fromOffset(padL + cl + gap, 0)
		t.Parent = f
		local mark = UI.sparkles(f, cl, ink, f.ZIndex + 2)
		mark.AnchorPoint = Vector2.new(0, 0.5)
		mark.Position = UDim2.new(0, padL, 0.5, 0)
		f.Parent = parent
		return f
	end
	S.ext.maxBadge = UI.maxBadge
	-- the max mark on Max-only groups and rows in the base pages (the badge's toxic green)
	UI.MAX_MARK = Color3.fromRGB(190, 245, 70)
	S.ext.sparkles = UI.sparkles
	-- the Max look dressing on the window: a flag ribbon along the top edge, the look's mark as a faint emblem
	-- low on the tab list, and a few sprites drifting behind everything. `loop` is Menu.loop: the sprites only
	-- move while the menu is open. Theme effects off, low-spec or perf mode leave the sprites out.
	function UI.fxMenu(root: GuiObject, side: GuiObject, px: (number) -> number, loop: (Instance, TweenInfo, any) -> any)
		local fx = UI.themeFx()
		if not fx then
			return
		end
		local ribbon = frame(root, Color3.new(1, 1, 1))
		ribbon.Name = "ThemeRibbon"
		ribbon.Size = UDim2.new(1, -28, 0, 2)
		ribbon.Position = UDim2.fromOffset(14, 0)
		ribbon.ZIndex = 6
		local rg = Instance.new("UIGradient")
		rg.Color = UI.fxSeq(fx.ribbon or fx.flag, true)
		rg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.06, 0.05), NumberSequenceKeypoint.new(0.94, 0.05), NumberSequenceKeypoint.new(1, 1) })
		rg.Parent = ribbon
		local emblem = UI.themeLogoPng(fx.key, px(96))
		if emblem then
			local e = Instance.new("ImageLabel")
			e.Name = "ThemeEmblem"
			e.BackgroundTransparency = 1
			e.Image = emblem
			e.ImageTransparency = 0.9
			e.Rotation = -14
			e.AnchorPoint = Vector2.new(0.5, 0.5)
			e.Position = UDim2.new(0.66, 0, 1, -px(122))
			e.Size = UDim2.fromOffset(px(96), px(96))
			e.ZIndex = 3
			e.Parent = side
		end
		if cfg.themeFx == false or cfg.lowSpec or cfg.perfMode then
			return
		end
		-- inset 12 px top and bottom: the layer clips a rectangle, never the window's rounded corners
		local layer = frame(root)
		layer.Name = "ThemeFx"
		layer.Position = UDim2.fromOffset(0, 12)
		layer.Size = UDim2.new(1, 0, 1, -24)
		layer.ClipsDescendants = true
		layer.ZIndex = 1
		local rng = Random.new(#fx.key * 7919)
		for i = 1, 16 do
			local kind = fx.sprites[(i - 1) % #fx.sprites + 1]
			local img = UI.fxSprite(kind)
			local col = fx.colors[rng:NextInteger(1, #fx.colors)]
			local tr = rng:NextNumber(0.35, 0.65)
			local p: GuiObject
			if img then
				local il = Instance.new("ImageLabel")
				il.BackgroundTransparency = 1
				il.Image = img
				il.ImageColor3 = col
				il.ImageTransparency = tr
				p = il
			else
				p = frame(nil, col)
				p.BackgroundTransparency = tr
				corner(p, 999)
			end
			local sz = rng:NextInteger(px(9), px(17))
			if kind == "star" then
				sz = math.floor(sz * 0.75)
			end
			p.Name = "Sprite"
			p.Size = UDim2.fromOffset(sz, sz)
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			local x = rng:NextNumber(0.04, 0.96)
			local y0, y1 = if fx.rise then 1.06 else -0.06, if fx.rise then -0.06 else 1.06
			p.Position = UDim2.fromScale(x, y0)
			p.Rotation = rng:NextNumber(-30, 30)
			p.ZIndex = 1
			p.Parent = layer
			local dur = rng:NextNumber(10, 18)
			loop(p, TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, rng:NextNumber(0, dur * 0.8)), { Position = UDim2.fromScale(x + rng:NextNumber(-0.08, 0.08), y1) })
			loop(p, TweenInfo.new(rng:NextNumber(1.8, 3.2), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Rotation = p.Rotation + rng:NextNumber(-50, 50) })
		end
	end
	-- the intro's flourish for a Max look: sprites burst out of the mark (hearts, paws) or fall from above
	-- (snow, leaves). Every sprite is gone before the intro fades.
	function UI.fxIntro(stage: GuiObject, cy: number)
		local fx = UI.themeFx()
		if not fx or cfg.themeFx == false then
			return
		end
		local TS = game:GetService("TweenService")
		local rng = Random.new()
		for i = 1, 22 do
			local img = UI.fxSprite(fx.sprites[(i - 1) % #fx.sprites + 1])
			if not img then
				return
			end
			local p = Instance.new("ImageLabel")
			p.BackgroundTransparency = 1
			p.Image = img
			p.ImageColor3 = fx.colors[rng:NextInteger(1, #fx.colors)]
			local sz = rng:NextInteger(10, 22)
			p.Size = UDim2.fromOffset(sz, sz)
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.Rotation = rng:NextNumber(-40, 40)
			p.Parent = stage
			if fx.intro == "fall" then
				local x = rng:NextNumber(0.32, 0.68)
				local lag, t = rng:NextNumber(0, 0.4), rng:NextNumber(1.1, 1.6)
				p.Position = UDim2.new(x, 0, cy, -rng:NextNumber(170, 300))
				p.ImageTransparency = 1
				TS:Create(p, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, lag), { Position = UDim2.new(x + rng:NextNumber(-0.04, 0.04), 0, cy, rng:NextNumber(30, 130)), Rotation = p.Rotation + rng:NextNumber(-120, 120) }):Play()
				TS:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, lag), { ImageTransparency = rng:NextNumber(0.05, 0.3) }):Play()
				task.delay(lag + t - 0.45, function()
					if p.Parent then
						TS:Create(p, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 1 }):Play()
					end
				end)
			else
				local a = (i / 22) * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
				local r = rng:NextNumber(90, 210)
				p.Position = UDim2.new(0.5, 0, cy, -40)
				p.ImageTransparency = 0.05
				local sc = Instance.new("UIScale")
				sc.Scale = 0.3
				sc.Parent = p
				TS:Create(p, TweenInfo.new(rng:NextNumber(0.9, 1.4), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, math.cos(a) * r, cy, -40 + math.sin(a) * r * 0.75 - (if fx.rise then 30 else 0)), Rotation = p.Rotation + rng:NextNumber(-90, 90) }):Play()
				TS:Create(sc, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
				TS:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, rng:NextNumber(0.7, 1.1)), { ImageTransparency = 1 }):Play()
			end
		end
	end
	-- a font glyph fades to its new colour; the frame-drawn fallback glyphs switch at once
	function UI.tintIcon(canvas: GuiObject, color: Color3, animate: boolean?)
		if animate and canvas:IsA("TextLabel") then
			tween(canvas, TW_HOVER, { TextColor3 = color })
		else
			recolourIcon(canvas, color)
		end
	end
	UI.loadAssets()

	-- registries: rows (search + Simple/Advanced), groups, toggle sync, bind tags
	UI.rows = {} -- { frame, text, desc, advanced, group }
	UI.groups = {} -- { frame, advanced, title, rows }
	UI.sync = {} -- functions walked by one Heartbeat while the menu is open
	-- read-only live readouts: refreshed only while their page is on screen (Menu.syncNow). Controls
	-- stay in the always-walked set — a switch must follow a bind on a page nobody is looking at.
	UI.lazySync = {}
	function UI.syncLazy(fn: () -> ())
		table.insert(UI.sync, fn)
		UI.lazySync[fn] = true
	end
	UI.bindTags = {} -- cfgKey -> refresh()
	UI.searchText = ""
	UI.gui = nil
	UI.root = nil
	UI.conns = {} -- connections owned by the current menu build (dropped on rebuild)
	local tipFrame: TextLabel? = nil
	function UI.conn(c: RBXScriptConnection): RBXScriptConnection
		table.insert(UI.conns, c)
		return c
	end
	function UI.resetRegistries()
		for _, c in ipairs(UI.conns) do
			pcall(c.Disconnect, c)
		end
		table.clear(UI.conns)
		UI.dragInstalled = false -- its two connections were just dropped with the rest
		UI.drag = nil
		table.clear(UI.rows)
		table.clear(UI.groups)
		table.clear(UI.sync)
		table.clear(UI.lazySync)
		table.clear(UI.bindTags)
		S.ui.tabs = {}
		S.ui.subTabs = {}
		S.ui.controls = {}
		S.ui.toggles = {}
		tipFrame = nil
	end
	-- one drag manager for every slider / colour rail: the active drag's handlers run from a single
	-- pair of UserInputService connections (installed once per build) instead of two per control
	UI.drag = nil
	UI.dragInstalled = false
	function UI.beginDrag(onMove: (Vector2) -> (), onEnd: (() -> ())?)
		local prev = UI.drag
		if prev and prev.onEnd then
			pcall(prev.onEnd)
		end
		UI.drag = { onMove = onMove, onEnd = onEnd }
		if not UI.dragInstalled then
			UI.dragInstalled = true
			UI.conn(UIS.InputChanged:Connect(function(i)
				local d = UI.drag
				if d and i.UserInputType == Enum.UserInputType.MouseMovement then
					d.onMove(Vector2.new(i.Position.X, i.Position.Y))
				end
			end))
			UI.conn(UIS.InputEnded:Connect(function(i)
				local d = UI.drag
				if d and i.UserInputType == Enum.UserInputType.MouseButton1 then
					UI.drag = nil
					if d.onEnd then
						d.onEnd()
					end
				end
			end))
		end
	end

	function UI.count(kind: string)
		S.ui.controls[kind] = (S.ui.controls[kind] or 0) + 1
	end
	local function modeAllows(advanced: boolean?): boolean
		return cfg.uiMode == "Advanced" or not advanced
	end
	-- v5.2 menu pass: Simple mode is a whitelist. A row is Advanced unless its cfg key (or, for buttons
	-- and lists, its exact label) is one of the ~100 everyday controls below, or the builder says
	-- `advanced = false`. Before this, 5 of 381 rows carried `advanced = true` and Simple mode hid
	-- almost nothing. Advanced still shows every surviving row.
	-- Simple = what a player adjusts during play. Advanced-only = tolerances in ms / studs, engine
	-- internals, diagnostics, experimental and unsafe rows. Switching modes never touches a value: a
	-- hidden Advanced row keeps working exactly as set.
	UI.SIMPLE_KEYS = {
		-- aim
		aimbot = true, aimKey = true, teamCheck = true, aimFov360 = true, aimFov = true, aimSmooth = true, aimStrength = true, aimDynamic = true, targetPriority = true, threatPriority = true, stickyAim = true, crosshair = true, showFov = true,
		utilAuto = true, utilHeal = true, utilHealBelow = true, utilMine = true, utilThrow = true, gunAbilities = true,
		aimHitboxes = true, aimPrefer = true, aimVisibleHitbox = true,
		-- silent + targeting + hitboxes
		silentAim = true, silentOnlyFiring = true, leadMode = true, silentFov360 = true, silentFov = true, silentFovFallback = true, targetMaxDistance = true, fovLinked = true, silentHitChance = true, silentWallbang = true, silentWallbangDist = true, antiUnder = true, antiUnderDist = true,
		legitTrigger = true, legitTriggerMode = true, legitTriggerKey = true, legitTriggerHitbox = true, legitTriggerDelayMs = true, legitTriggerChance = true,
		silentHitboxes = true, silentPrefer = true, silentVisibleHitbox = true, dynamicHitbox = true,
		-- auto shoot + trigger
		autoShoot = true, autoShootHold = true, autoShootDelay = true, preAim = true, autoShootHealthCheck = true, killConfirmHold = true, oneShotSafety = true, immuneCheck = true, rageAutoShootVisible = true,
		autoShootWaitAim = true, autoShootScopeSnipers = true, autoShootReactionMs = true, autoShootChance = true, autoShootAimMode = true, autoShootStopMode = true,
		-- melee + magic
		autoQuickMelee = true, autoBackstab = true, meleeRage = true, meleeMode = true, meleeHeavyPolicy = true, meleeRageRange = true,
		magicBullet = true, magicAutoHeight = true, magicHeight = true, magicInvisible = true, magicJitter = true, magicJitterRadius = true, originPreferCover = true, magicPrePosition = true, wallbang = true,
		-- rage: autokill / movement / noclip / defense / bounds / anti-aim / resolver / katana
		autokill = true, autokillMode = true, autokillReturn = true, autokillVisible = true, autokillAdaptive = true, autokillChain = true, autokillAuto = true, autokillAutoRange = true, autokillDuration = true, autokillUntilDead = true, originMaxDist = true, autokillAbortHp = true,
		autokillMove = true, autoPeek = true, autoPeekKey = true, autoPeekDistance = true,
		noclip = true, noclipFloat = true, noclipSpeed = true, noclipFollowCamera = true,
		defenseHide = true, defenseMode = true, defenseOnlyWhenThreat = true, defenseVoidSpam = true, voidSpam = true,
		voidSpamMode = true, voidSpamDist = true, voidSpamHide = true, voidSpamBack = true, voidSpamFireBack = true, voidSpamMoveBack = true, voidSpamAutoOff = true, voidSpamHud = true, voidSpamUnder = true, voidSpamUnderRange = true, voidSpamBait = true, voidSpamBaitSpot = true, voidSpamBaitSec = true, voidSpamBaitEvery = true,
		oobBlock = true, boundsGuard = true, voidHunt = true, shieldAware = true, antiFlash = true, targetPreferVisible = true, magicHopOnShot = true,
		aaEnabled = true, aaMode = true, aaPitch = true, aaSpeed = true, aaJitterDeg = true, aaBody = true, antiMeleeFace = true, fakeDuck = true,
		resolver = true, resolverBodyOnAA = true, resolverWarp = true, deadTargetGuard = true, autoBlock = true, autoBlockRange = true, katanaCheck = true,
		-- weapon / reload / movement
		noSpread = true, noRecoil = true, rapidFire = true, fullAuto = true, rapidFireMult = true, rapidThrottle = true, rapidMelee = true, rapidMeleeMult = true, rapidMeleeServer = true, fastEquip = true, fastEquipMult = true, fastAim = true, fastAimMult = true, instantBullet = true,
		instantReload = true, reloadMult = true, autoReload = true, reloadEarly = true, noReloadCancel = true,
		infSlide = true, infSprint = true, noAdsSlow = true, noSlow = true, autoSlide = true, slideKey = true, bhop = true, speedBoost = true, speedMult = true,
		-- visuals (all of it is preference; only the renderer backend stays advanced)
		esp = true, espVisibleCheck = true, espMaxDistance = true, espTextSize = true, espLineWidth = true, espBox = true, espBoxStyle = true, espBoxFill = true, espBoxFillAlpha = true,
		espSkeleton = true, espHeadDot = true, espNames = true, espHealth = true, espHealthBar = true, espDistance = true, espWeapon = true, colEsp = true, colEspVisible = true, colText = true, colHp = true,
		espHighlight = true, espChamsOccluded = true, espChamsFill = true, espChamsOutline = true, colChamsFill = true, colChamsOutline = true,
		espTracers = true, espTracerFrom = true, colTracer = true, espArrows = true, espArrowRadius = true, radar = true, radarSize = true, radarRange = true, hitMarkers = true, killFeed = true,
		-- world (all preference)
		nightMode = true, nightLevel = true, nightHands = true, nightHandsGlow = true, fullbright = true, brightness = true, noFog = true, skyColorOn = true, skyColor = true, timeOfDayOn = true, timeOfDay = true, noPostFx = true, noDamageFx = true,
		thirdPerson = true, tpShoulder = true, tpDist = true, tpUp = true, tpSide = true, tpSmooth = true, tpHideViewmodel = true, fovChanger = true, fov = true, noAdsZoom = true, noScopeOverlay = true, hideViewmodel = true, hideHands = true, noCrosshairBloom = true,
		antiAfk = true, autoRejoin = true, autoRejoinDelay = true,
		-- skins / hud / settings
		unlockCosmetics = true, unlockFinisher = true, skinModelSwap = true, skinRebuild = true, hud = true, indicators = true, showBinds = true, awarenessHud = true, combatBar = true, hudScale = true,
		theme = true, colAccent = true, colAccent2 = true, menuBlur = true, menuKey = true, menuScale = true, espHideInMenu = true, espLobby = true, espWhileHidden = true, espGhostSec = true, introAnim = true, uiMode = true, targetBots = true,
		autoload = true, autoUpdate = true, adaptToasts = true, autoPerf = true, perfMode = true, lowSpec = true,
		-- v5.3: ESP / HUD / menu additions and the World page's everyday rows (fine-tuning sliders stay Advanced)
		espOutline = true, espHpMode = true, espFlags = true, espArrowMax = true, espArrowDist = true, statusSituation = true, toasts = true,
		uiGlow = true, themeFx = true, railGlass = true, previewPane = true, previewHp = true,
		worldGrade = true, gradeContrast = true, gradeSaturation = true, gradeTint = true, worldBloom = true, bloomIntensity = true,
		worldSunRays = true, sunRaysIntensity = true, worldDof = true, worldAtmos = true, atmosColor = true, atmosDensity = true,
		worldAmbientOn = true, colAmbient = true, worldExposureOn = true, worldExposure = true, worldShadows = true, worldStars = true,
		worldWeather = true, weatherDensity = true, fxQuality = true, shotTracers = true, hitNumbers = true, hitBlood = true, killEffect = true,
		vmChams = true, vmMaterial = true, colVm = true, selfChams = true, colSelf = true,
	}
	UI.SIMPLE_LABELS = {
		["Start autokill now"] = true, ["Measure the void now"] = false,
		["Rejoin this server"] = true, ["Server hop"] = true, ["Copy join code"] = true,
		["Unlock everything"] = true, ["Lock everything"] = true,
		["Measure this gun's limit"] = true,
		["Apply now"] = true, ["Follow the weapon in hand"] = true, ["Reset this weapon"] = true, ["Reset all weapons"] = true, ["Refresh the customize screen"] = false,
		["Save now"] = true, ["Reset to defaults"] = true, ["Unload cocaine"] = true, ["Copy config"] = true, ["Paste config"] = true,
		["Check for update"] = true, ["Reload the latest version"] = true, ["Reset layout"] = true,
		["Arrange HUD"] = true, ["Open the console (F9)"] = true, ["Copy logs"] = true, ["Clean look"] = true, ["Turn everything off"] = true, ["Play the intro"] = true,
	}
	-- switches that do nothing while another one is off (the combat code gates them on it): their row
	-- says so instead of looking broken
	-- "rage" = a positioning mode is picked (Combat.rageOn); a list = every one of them
	UI.NEEDS = {
		autoShoot = "silentAim", magicBullet = "silentAim", autokill = { "silentAim", "rage" }, meleeRage = { "silentAim", "rage" },
		autoBackstab = { "silentAim", "rage", "noMeleeRage" }, autoQuickMelee = "silentAim", defenseHide = { "silentAim", "rage" }, preAim = "silentAim",
		antiMeleeDodge = { "silentAim", "rage" }, defenseVoidSpam = { "defenseHide", "rage" }, voidSpam = "rageEnabled",
		autokillHvh = { "silentAim", "rage" }, rageBreaker = { "silentAim", "rage" },
	}
	UI.NEED_TEXT = { silentAim = "needs silent aim", rage = "rage is off", defenseHide = "needs hide", noMeleeRage = "melee rage has it", rageEnabled = "ragebot disabled" }
	-- "rage" is two switches: name the one that is off
	function UI.needText(need: string): string
		if need == "rage" then
			if cfg.rageEnabled == false then
				return UI.NEED_TEXT.rageEnabled
			elseif cfg.ragePosition == nil or cfg.ragePosition == "None" then
				return "no rage mode"
			end
		end
		return UI.NEED_TEXT[need] or ("needs " .. tostring(need))
	end
	function UI.needMet(need: string): boolean
		if need == "rage" then
			return Configs.rageOn(cfg)
		elseif need == "noMeleeRage" then
			-- the melee ragebot owns "get behind and land the heavy" while it is on (Combat.backstabOwner)
			return not cfg.meleeRage
		end
		return cfg[need] == true
	end
	-- the first dependency that is off (nil = all met)
	function UI.needUnmet(need: any): string?
		if type(need) == "string" then
			return if UI.needMet(need) then nil else need
		elseif type(need) == "table" then
			for _, n in ipairs(need) do
				if not UI.needMet(n) then
					return n
				end
			end
		end
		return nil
	end
	function UI.isAdvanced(ropts: any, text: string?, groupOpts: any): boolean
		if ropts.advanced ~= nil then
			return ropts.advanced == true
		end
		if groupOpts and groupOpts.simple == true then
			return false
		end
		if ropts.isNote then
			return false -- notes follow their group (orphans are hidden by refilter)
		end
		if ropts.cfgKey ~= nil then
			return UI.SIMPLE_KEYS[ropts.cfgKey] ~= true
		end
		if ropts.isList then
			return false -- the Skins browsers
		end
		return UI.SIMPLE_LABELS[text or ""] ~= true
	end
	local function rowMatches(r: any): boolean
		local q = UI.searchText
		if q == "" then
			return true
		end
		return string.find(string.lower(r.text), q, 1, true) ~= nil or (r.descText ~= nil and string.find(string.lower(r.descText), q, 1, true) ~= nil)
	end
	-- re-evaluate every row/group for the current mode + search
	-- a sub-row shows while its toggle's three-line button is open (and allowed), or when a search finds it
	-- the rows under a three-line button fade in / out (UI.fadeIn / fadeOut) instead of popping; `done`
	-- runs once every row has finished (the close hides them only then)
	function UI.animSub(state: any, open: boolean, done: (() -> ())?)
		local rows = {}
		for _, r in ipairs(UI.rows) do
			if r.parent == state and r.frame.Visible then
				table.insert(rows, r)
			end
		end
		if #rows == 0 then
			if done then
				done()
			end
			return
		end
		state.animating = true
		if open then
			for _, r in ipairs(rows) do
				UI.fadeIn(r.frame)
			end
			task.delay(UI.TW.pop.Time, function()
				state.animating = false
				if done then
					done()
				end
			end)
			return
		end
		local frames = {}
		for _, r in ipairs(rows) do
			table.insert(frames, r.frame)
		end
		UI.fadeOut(frames, UI.TW.hover, function()
			state.animating = false
			if done then
				done()
			end
		end)
	end
	function UI.parentOpen(r: any): boolean
		local p = r.parent
		if p == nil then
			return true
		end
		if UI.searchText ~= "" then
			return true
		end
		return p.open == true and (p.when == nil or p.when() == true)
	end
	function UI.refilter()
		for _, r in ipairs(UI.rows) do
			local show = modeAllows(r.advanced) and rowMatches(r) and UI.parentOpen(r)
			r.frame.Visible = show
			if r.desc then
				-- help text shows in both modes: Simple hides the advanced rows, not the explanations
				local showDesc = r.descText ~= nil and r.descText ~= ""
				r.desc.Visible = showDesc
				r.frame.Size = UDim2.new(1, 0, 0, r.base + (if showDesc then (r.descH or UI.M.descLine) else 0))
			end
		end
		for _, g in ipairs(UI.groups) do
			local any, anyControl, hasControls = false, false, false
			for _, r in ipairs(g.rows) do
				if not r.isNote then
					hasControls = true
				end
				if r.frame.Visible then
					any = true
					if not r.isNote then
						anyControl = true
					end
				end
			end
			-- v5.2: in Simple mode a note whose controls are all advanced would sit alone in its group
			-- (a title over a sentence about rows you cannot see) — the note and the group go with them.
			-- Groups made only of notes (Home hints, Settings → Info) are untouched.
			if cfg.uiMode ~= "Advanced" and hasControls and any and not anyControl then
				for _, r in ipairs(g.rows) do
					if r.isNote and r.frame.Visible then
						r.frame.Visible = false
					end
				end
				any = false
			end
			g.frame.Visible = modeAllows(g.advanced) and (any or (#g.rows == 0 and UI.searchText == ""))
		end
		if UI.afterRefilter then
			pcall(UI.afterRefilter)
		end
	end
	function UI.search(text: string)
		UI.searchText = string.lower(tostring(text or ""))
		UI.refilter()
	end
	function UI.setMode(mode: string)
		cfg.uiMode = if mode == "Simple" then "Simple" else "Advanced"
		saveConfig()
		UI.refilter()
	end

	-- a typed slider value: "0.3", "x0.3", "×0.30", "15k", "20%", "1.5 s", "400st", "never" / "off" → 0
	function UI.parseNumber(s: string): number?
		if type(s) ~= "string" then
			return nil
		end
		s = string.gsub(string.lower((string.gsub(s, "×", ""))), "%s+", "")
		-- "15,000" is a thousands separator, "1,5" a decimal comma
		s = if string.match(s, "^%-?%d+,%d%d%d") then string.gsub(s, ",", "") else string.gsub(s, ",", ".")
		if s == "never" or s == "off" or s == "none" then
			return 0
		end
		local num, suffix = string.match(s, "^x?([%-]?%d*%.?%d+)(%a*)")
		local n = tonumber(num)
		if n == nil or n ~= n then
			return nil
		end
		if suffix == "k" then
			n *= 1000
		end
		return n
	end
	-- tooltip (one per gui)
	function UI.tip(target: GuiObject, text: string)
		target.MouseEnter:Connect(function()
			if not UI.gui or not text or text == "" then
				return
			end
			if not tipFrame or tipFrame.Parent == nil then
				-- wraps at 320 px and never runs off the screen (flips to the left / above the cursor)
				local t = Instance.new("TextLabel")
				t.Name = "Tooltip"
				t.AutomaticSize = Enum.AutomaticSize.XY
				t.Size = UDim2.new(0, 0, 0, 0)
				t.BackgroundColor3 = C.pop
				UI.setFont(t, UI.F.body)
				t.TextSize = UI.M.desc
				t.TextColor3 = C.text
				t.TextWrapped = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.LineHeight = 1.1
				t.ZIndex = 200
				t.Visible = false
				t.Parent = UI.gui
				corner(t, if UI.metal then 8 else 6)
				UI.metalEdge(stroke(t, C.edge, 0))
				padding(t, 7, 10, 8, 10)
				local cap = Instance.new("UISizeConstraint")
				cap.MaxSize = Vector2.new(260, 400)
				cap.Parent = t
				tipFrame = t
			end
			local tf = tipFrame :: TextLabel
			tf.Text = text
			UI.snapWrapped(tf, 240, 20, 15)
			-- placed first, shown one frame later: it used to appear at the previous tooltip's
			-- position for a frame and then jump
			local m0 = UIS:GetMouseLocation()
			local inset0 = if UI.gui.IgnoreGuiInset then 0 else GuiService:GetGuiInset().Y
			tf.Position = UDim2.fromOffset(m0.X + 14, m0.Y - inset0 + 8)
			tf.Visible = false
			task.defer(function()
				if tipFrame ~= tf then
					return
				end
				local m = UIS:GetMouseLocation()
				-- the gui ignores the inset (IgnoreGuiInset) → mouse coordinates map 1:1; a gui that
				-- does not gets the top-bar offset subtracted
				local inset = if UI.gui.IgnoreGuiInset then 0 else GuiService:GetGuiInset().Y
				local vp = UI.gui.AbsoluteSize
				local sz = tf.AbsoluteSize
				local x, y = m.X + 14, m.Y - inset + 8
				if x + sz.X > vp.X - 6 then
					x = math.max(6, m.X - 14 - sz.X)
				end
				if y + sz.Y > vp.Y - 6 then
					y = math.max(6, m.Y - inset - 8 - sz.Y)
				end
				tf.Position = UDim2.fromOffset(x, y)
				tf.Visible = true
			end)
		end)
		target.MouseLeave:Connect(function()
			if tipFrame then
				tipFrame.Visible = false
			end
		end)
	end

	---------------------------------------------------------------------------
	-- bind popup: right-click any toggle → key + mode (Toggle / Hold / Always / Never)
	---------------------------------------------------------------------------
	local BIND_MODES = { "Toggle", "Hold", "Always", "Never" }
	local bindPopup: Frame? = nil
	-- one line of text at `size`, measured with the widest face the kit draws (chips size to it)
	function UI.textW(text: string, size: number): number
		local ts = game:GetService("TextService")
		local ok, sz = pcall(ts.GetTextSize, ts, tostring(text or ""), size, Enum.Font.BuilderSansExtraBold, Vector2.new(2000, 200))
		return if ok and sz then math.ceil(sz.X) else #tostring(text or "") * (size * 0.6)
	end
	-- a text box sized to its text in whole, even pixels: automatic sizing takes the font's fractional
	-- advance widths (a 165.8 px toast), and a fractional box — right-aligned or centred on its parent
	-- — puts its edges and stroke on half pixels, blurred across two. `extra` = the label's own padding.
	-- false (automatic size kept) while the text cannot be measured yet.
	function UI.snapWidth(l: TextLabel, extra: number?): boolean
		local w = l.TextBounds.X
		if w < 1 then
			return false
		end
		local total = math.ceil(w - 0.001) + (extra or 0)
		if total % 2 == 1 then
			total += 1
		end
		if l.AutomaticSize == Enum.AutomaticSize.X then
			l.AutomaticSize = Enum.AutomaticSize.None
		elseif l.AutomaticSize == Enum.AutomaticSize.XY then
			l.AutomaticSize = Enum.AutomaticSize.Y
		end
		if l.Size.X.Scale ~= 0 or l.Size.X.Offset ~= total then
			l.Size = UDim2.new(0, total, l.Size.Y.Scale, l.Size.Y.Offset)
		end
		return true
	end
	-- wrapped text in whole pixels: measured at `maxW`, then sized to the longest line and the lines'
	-- height (even width); `padX` / `padY` = the label's own padding
	function UI.snapWrapped(l: TextLabel, maxW: number, padX: number?, padY: number?): boolean
		local auto = l.AutomaticSize
		l.AutomaticSize = Enum.AutomaticSize.None
		l.TextWrapped = true
		l.Size = UDim2.fromOffset(maxW + (padX or 0), 2000)
		local tb = l.TextBounds
		if tb.X < 1 then
			l.AutomaticSize = auto
			return false
		end
		local w = math.ceil(tb.X - 0.001) + (padX or 0)
		if w % 2 == 1 then
			w += 1
		end
		l.Size = UDim2.fromOffset(w, math.ceil(tb.Y - 0.001) + (padY or 0))
		return true
	end
	function UI.closeBindPopup()
		local p = bindPopup
		bindPopup = nil
		if not p then
			return
		end
		if p.Parent and S.menuOpen then
			-- fades out, inert meanwhile (a click on a fading button must not act)
			for _, d in ipairs(p:GetDescendants()) do
				if d:IsA("GuiButton") then
					d.Active = false
					pcall(function()
						(d :: any).Interactable = false
					end)
				end
			end
			UI.fadeOut(p, UI.TW.hover, function()
				p:Destroy()
			end)
		else
			p:Destroy()
		end
	end
	function UI.openBindPopup(cfgKey: string, title: string?, at: Vector2?)
		local root = UI.root
		if not root then
			return
		end
		UI.closeBindPopup()
		-- the bind entry is created only once the user actually sets a key or mode: opening and
		-- closing the popup used to leave an empty { key = "", mode = "Toggle" } in the saved config
		local b = cfg.binds[cfgKey]
		if type(b) ~= "table" then
			b = { key = "", mode = "Toggle" }
		end
		local function commit()
			if cfg.binds[cfgKey] ~= b then
				cfg.binds[cfgKey] = b
			end
			saveConfig()
		end
		-- the popover look every popup shares (C.pop, 10 px corners, a soft shadow with the same corners),
		-- an accent edge because it edits one row; faded in, never unrolled
		local W, H = 300, 206
		local pop = frame(root, C.pop)
		pop.Name = "BindPopup"
		pop.Size = UDim2.fromOffset(W, H)
		local rel = if at then at - root.AbsolutePosition else Vector2.new(root.AbsoluteSize.X / 2 - W / 2, root.AbsoluteSize.Y / 2 - H / 2)
		pop.Position = UDim2.fromOffset(math.floor(math.clamp(rel.X, 8, math.max(8, root.AbsoluteSize.X - W - 8))), math.floor(math.clamp(rel.Y, 8, math.max(8, root.AbsoluteSize.Y - H - 8))))
		pop.ZIndex = 50
		pop.Active = true
		corner(pop, 10)
		UI.softShadow(pop, "Shadow", Color3.new(0, 0, 0), 0.4, 18, 10)
		UI.popEdge(pop, 10)
		bindPopup = pop
		local function zl(t: any, z: number?): any
			t.ZIndex = z or 51
			return t
		end
		local cap = zl(label(pop, "keybind", UI.M.tiny, C.accent, UI.F.semibold))
		cap.Size = UDim2.new(1, -60, 0, 14)
		cap.Position = UDim2.fromOffset(16, 12)
		local head = zl(label(pop, string.lower(title or Input.bindLabels[cfgKey] or cfgKey), UI.M.title, C.text, UI.F.semibold))
		head.Size = UDim2.new(1, -60, 0, 18)
		head.Position = UDim2.fromOffset(16, 27)
		head.TextTruncate = Enum.TextTruncate.AtEnd
		local closeB = zl(button(pop, "", 10, C.text, C.card))
		closeB.Size = UDim2.fromOffset(28, 28)
		closeB.AnchorPoint = Vector2.new(1, 0)
		closeB.Position = UDim2.new(1, -10, 0, 10)
		closeB.BackgroundTransparency = 1
		corner(closeB, 7)
		local closeIc = zl(icon(closeB, "close", 16), 52)
		recolourIcon(closeIc, C.muted)
		closeB.MouseEnter:Connect(function()
			tween(closeB, TW_HOVER, { BackgroundTransparency = 0 })
			UI.tintIcon(closeIc, C.text, true)
		end)
		closeB.MouseLeave:Connect(function()
			tween(closeB, TW_HOVER, { BackgroundTransparency = 1 })
			UI.tintIcon(closeIc, C.muted, true)
		end)
		local hair = zl(frame(pop, C.hairline))
		hair.Size = UDim2.new(1, -32, 0, 1)
		hair.Position = UDim2.fromOffset(16, 56)
		for _, spec in ipairs({ { "key", 68 }, { "mode", 108 } }) do
			local l = zl(label(pop, spec[1], UI.M.title, C.dim))
			l.Size = UDim2.fromOffset(64, 30)
			l.Position = UDim2.fromOffset(16, spec[2])
		end
		-- the key: a field with a keyboard glyph; it lights up while it listens
		local keyB = zl(button(pop, "", UI.M.value, C.text, C.surface))
		keyB.Size = UDim2.fromOffset(W - 104, 30)
		keyB.Position = UDim2.fromOffset(88, 68)
		corner(keyB, 7)
		local keyStroke = stroke(keyB, C.edge, 0)
		local keyIc = zl(icon(keyB, "keyboard", 15), 52)
		keyIc.AnchorPoint = Vector2.new(0, 0.5)
		keyIc.Position = UDim2.new(0, 10, 0.5, 0)
		recolourIcon(keyIc, C.muted)
		local keyTxt = zl(label(keyB, "", UI.M.value, C.text, UI.F.medium), 52)
		keyTxt.Size = UDim2.new(1, -42, 1, 0)
		keyTxt.Position = UDim2.fromOffset(32, 0)
		keyTxt.TextTruncate = Enum.TextTruncate.AtEnd
		keyB.MouseEnter:Connect(function()
			tween(keyB, TW_HOVER, { BackgroundColor3 = C.card })
		end)
		keyB.MouseLeave:Connect(function()
			tween(keyB, TW_HOVER, { BackgroundColor3 = C.surface })
		end)
		-- the mode: a segmented control whose thumb glides to the pick
		local seg = zl(frame(pop, C.surface))
		seg.Size = UDim2.fromOffset(W - 104, 30)
		seg.Position = UDim2.fromOffset(88, 108)
		corner(seg, 7)
		stroke(seg, C.edge, 0)
		local thumb = zl(frame(seg, C.accent), 52)
		thumb.BackgroundTransparency = 0.78
		corner(thumb, 5)
		stroke(thumb, C.accent, 0.5)
		if UI.brushed(thumb) then
			thumb.BackgroundTransparency = 0
		end
		local thumbLiquid = UI.liquid(thumb, function(a: number, b2: number)
			thumb.Position = UDim2.fromOffset(a, 3)
			thumb.Size = UDim2.fromOffset(math.max(4, b2 - a), 24)
		end)
		local segW = (W - 104 - 6) / #BIND_MODES
		local segBtns: { [string]: TextButton } = {}
		local refresh: (boolean?) -> ()
		for i, m in ipairs(BIND_MODES) do
			local sb = zl(button(seg, string.lower(m), UI.M.small, C.muted, C.surface), 53)
			sb.BackgroundTransparency = 1
			sb.Position = UDim2.fromOffset(3 + math.floor((i - 1) * segW + 0.5), 3)
			sb.Size = UDim2.fromOffset(math.floor(i * segW + 0.5) - math.floor((i - 1) * segW + 0.5), 24)
			segBtns[m] = sb
			sb.MouseButton1Click:Connect(function()
				if (b.mode or "Toggle") ~= m then
					b.mode = m
					Input.bindTouched[cfgKey] = nil
					commit()
					refresh(true)
				end
			end)
		end
		-- what the key is, in words, behind a status dot
		local dot = zl(frame(pop, C.muted))
		dot.Size = UDim2.fromOffset(6, 6)
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Position = UDim2.fromOffset(16, 157)
		corner(dot, 3)
		local status = zl(label(pop, "", UI.M.small, C.dim, UI.F.medium))
		status.Name = "Status"
		status.Size = UDim2.fromOffset(W - 44, 18)
		status.Position = UDim2.fromOffset(28, 148)
		status.TextTruncate = Enum.TextTruncate.AtEnd
		local clearB = zl(button(pop, "clear", UI.M.value, C.danger, C.danger))
		clearB.Size = UDim2.fromOffset(76, 26)
		clearB.Position = UDim2.fromOffset(16, H - 38)
		clearB.BackgroundTransparency = 0.87
		corner(clearB, 7)
		stroke(clearB, C.danger, 0.6)
		clearB.MouseEnter:Connect(function()
			tween(clearB, TW_HOVER, { BackgroundTransparency = 0.78 })
		end)
		clearB.MouseLeave:Connect(function()
			tween(clearB, TW_HOVER, { BackgroundTransparency = 0.87 })
		end)
		local hint = zl(label(pop, "esc clears · mouse 4 / 5 work", UI.M.small, C.muted))
		hint.Size = UDim2.fromOffset(W - 116, 26)
		hint.Position = UDim2.fromOffset(100, H - 38)
		hint.TextXAlignment = Enum.TextXAlignment.Right
		local function paintStatus()
			local k = b.key
			if type(k) ~= "string" or k == "" then
				status.Text = if b.mode == "Always" or b.mode == "Never" then ("no key · always %s"):format(if b.mode == "Always" then "on" else "off") else "no key yet"
				status.TextColor3 = C.muted
				dot.BackgroundColor3 = if b.mode == "Always" then C.ok else C.faint
				return
			end
			status.Text = ("bound to %s · %s"):format(Input.keyLabel(k), string.lower(b.mode or "Toggle"))
			status.TextColor3 = C.dim
			dot.BackgroundColor3 = if b.mode == "Never" then C.faint else C.ok
		end
		refresh = function(animate: boolean?)
			keyTxt.Text = Input.keyLabel(b.key)
			local mode = b.mode or "Toggle"
			for m, sb in pairs(segBtns) do
				local col = if m == mode then (if UI.metal then UI.metal.ink else C.text) else C.muted
				if animate then
					tween(sb, TW_HOVER, { TextColor3 = col })
				else
					sb.TextColor3 = col
				end
				UI.setFont(sb, if m == mode then UI.F.bold else UI.F.medium)
			end
			local sb = segBtns[mode]
			if sb then
				thumbLiquid.to(sb.Position.X.Offset, sb.Position.X.Offset + sb.Size.X.Offset, animate)
			end
			paintStatus()
			local tag = UI.bindTags[cfgKey]
			if tag then
				tag()
			end
		end
		refresh(false)
		keyB.MouseButton1Click:Connect(function()
			keyTxt.Text = "Press a key…"
			keyStroke.Color = C.accent
			recolourIcon(keyIc, C.accent)
			Input.captureKey(function(name)
				if name ~= false then
					b.key = name or ""
					commit()
				end
				if pop.Parent then
					keyStroke.Color = C.edge
					recolourIcon(keyIc, C.muted)
					refresh(false)
				end
			end)
		end)
		do
			local base = pop.Position
			pop.Position = base + UDim2.fromOffset(0, 4)
			tween(pop, UI.TW.pop, { Position = base })
			UI.fadeIn(pop)
		end
		clearB.MouseButton1Click:Connect(function()
			cfg.binds[cfgKey] = nil
			Input.bindTouched[cfgKey] = nil
			saveConfig()
			local tag = UI.bindTags[cfgKey]
			if tag then
				tag()
			end
			UI.closeBindPopup()
		end)
		closeB.MouseButton1Click:Connect(UI.closeBindPopup)
	end
	function UI.bindPopupOpen(): boolean
		return bindPopup ~= nil and bindPopup.Parent ~= nil
	end

	---------------------------------------------------------------------------
	-- dropdown popover (cycle / multiselect / colour): one at a time, parented to the menu host so it
	-- scales with the window; an invisible catcher over window + side panel closes it on an outside click
	---------------------------------------------------------------------------
	UI.popup = nil
	UI.popupHost = nil -- set by Menu.build (the frame holding the window and the side panel)
	function UI.closeDropdown()
		local p = UI.popup
		UI.popup = nil
		if p then
			pcall(p.catcher.Destroy, p.catcher)
			pcall(p.frame.Destroy, p.frame)
			if p.onClose then
				pcall(p.onClose)
			end
		end
	end
	-- build(frame) fills the list and returns its height; the list opens under the anchor (above it
	-- when there is no room) and never wider than needed
	function UI.openDropdown(anchor: GuiObject, width: number, build: (Frame) -> number, onClose: (() -> ())?): Frame?
		UI.closeDropdown()
		local host = UI.popupHost or UI.root
		if not host then
			return nil
		end
		local sc = if S.menu and S.menu.scale then S.menu.scale.Scale else 1
		sc = math.max(sc, 0.1)
		local catcher = Instance.new("TextButton")
		catcher.Name = "DropdownCatcher"
		catcher.BackgroundTransparency = 1
		catcher.Text = ""
		catcher.AutoButtonColor = false
		catcher.Size = UDim2.new(1, 400, 1, 0)
		catcher.ZIndex = 58
		catcher.Parent = host
		local f = frame(host, C.pop)
		f.Name = "Dropdown"
		f.ZIndex = 60
		f.Active = true
		corner(f, 8)
		UI.softShadow(f, "Shadow", Color3.new(0, 0, 0), 0.45, 14, 8)
		if not UI.metal then
			stroke(f, C.edge, 0)
		else
			UI.popEdge(f, 8)
		end
		local h = build(f)
		local ap = (anchor.AbsolutePosition - host.AbsolutePosition) / sc
		local as = anchor.AbsoluteSize / sc
		local hostH = host.AbsoluteSize.Y / sc
		local w = math.max(width, as.X)
		local y = ap.Y + as.Y + 4
		local above = false
		if y + h > hostH - 6 and ap.Y - h - 4 > 6 then
			y = ap.Y - h - 4
			above = true
		end
		-- full size at once, fading in while it drifts 4 px out of its anchor (no unroll: see UI.fadeIn)
		local base = UDim2.fromOffset(math.floor(ap.X + as.X - w + 0.5), math.floor(y + 0.5))
		f.Size = UDim2.fromOffset(w, h)
		f.Position = base + UDim2.fromOffset(0, if above then 4 else -4)
		tween(f, UI.TW.pop, { Position = base })
		UI.fadeIn(f)
		catcher.MouseButton1Click:Connect(UI.closeDropdown)
		UI.popup = { frame = f, catcher = catcher, onClose = onClose }
		return f
	end
	-- one 24 px option inside a dropdown
	function UI.dropdownOption(parent: Frame, y: number, text: string, selected: boolean, onPick: () -> ()): TextButton
		local b = button(parent, "", UI.M.value, C.dim, C.card)
		b.BackgroundTransparency = 1
		b.Size = UDim2.new(1, -8, 0, 24)
		b.Position = UDim2.fromOffset(4, y)
		b.ZIndex = 61
		corner(b, 5)
		local l = label(b, text, UI.M.value, if selected then C.accent else C.dim, UI.F.body)
		l.Size = UDim2.new(1, -30, 1, 0)
		l.Position = UDim2.fromOffset(8, 0)
		l.ZIndex = 62
		l.TextTruncate = Enum.TextTruncate.AtEnd
		local ic = icon(b, "check", 14)
		ic.AnchorPoint = Vector2.new(1, 0.5)
		ic.Position = UDim2.new(1, -6, 0.5, 0)
		ic.ZIndex = 62
		ic.Visible = selected
		recolourIcon(ic, C.accent)
		b:SetAttribute("selected", selected)
		-- metal looks: the picked option is a brushed key with dark ink (it keeps it through hovers)
		local keyed = selected and UI.brushed(b)
		if keyed then
			b.BackgroundTransparency = 0
			l.TextColor3 = UI.metal.ink
			UI.setFont(l, UI.F.bold)
			recolourIcon(ic, UI.metal.ink)
		end
		b.MouseEnter:Connect(function()
			if keyed then
				return
			end
			tween(b, TW_HOVER, { BackgroundTransparency = 0 })
			if not b:GetAttribute("selected") then
				tween(l, TW_HOVER, { TextColor3 = C.text })
			end
		end)
		b.MouseLeave:Connect(function()
			if keyed then
				return
			end
			tween(b, TW_HOVER, { BackgroundTransparency = 1 })
			tween(l, TW_HOVER, { TextColor3 = if b:GetAttribute("selected") then C.accent else C.dim })
		end)
		b.MouseButton1Click:Connect(onPick)
		return b
	end
	-- one plain sentence for the old risk tags (the tag itself used to be the UI)
	function UI.riskText(tag: any): string
		local t = string.upper(tostring(tag))
		if t == "SERVER-CHECKED" then
			return "The server checks this. Push it too far and shots stop counting or you get pulled back."
		elseif t == "EXPERIMENTAL" then
			return "Experimental: may not work on every map or after a game update."
		elseif t == "TELEPORT" then
			return "Moves your character. Other players can see it."
		elseif t == "UNTESTED VS SERVER" then
			return "Not yet verified against the server in a real match."
		elseif t == "TRUE" or t == "DANGER" then
			return "Risky: other players or the server can notice it."
		end
		return tostring(tag)
	end

	---------------------------------------------------------------------------
	-- group + controls. A group is a title over a hairline; rows are 26 px, label left, control
	-- right; help lives in a (?) tooltip, risk in one amber warning icon.
	---------------------------------------------------------------------------
	-- a group header's glyph from its title; only names already verified in UI.ICONS (Material ligatures)
	UI.GROUP_ICONS = {
		{ "max", "auto_awesome" }, { "extra", "auto_awesome" }, { "intel", "visibility" }, { "right now", "info" }, { "stat", "info" },
		{ "farm", "refresh" }, { "esp", "visibility" }, { "cham", "visibility" }, { "info", "info" }, { "color", "tune" },
		{ "style", "tune" }, { "look", "tune" }, { "silent", "track_changes" }, { "trigger", "my_location" }, { "aim", "gps_fixed" },
		{ "target", "gps_fixed" }, { "rage", "bolt" }, { "anti", "360" }, { "world", "public" }, { "map", "public" }, { "skin", "checkroom" },
		{ "hud", "dashboard" }, { "menu", "dashboard" }, { "interface", "dashboard" }, { "bind", "keyboard" }, { "key", "keyboard" },
		{ "config", "save" }, { "cloud", "save" }, { "player", "person_outline" }, { "spoof", "person_outline" }, { "staff", "warning_amber" },
	}
	function UI.groupIcon(title: string): string
		local t = string.lower(title)
		for _, p in ipairs(UI.GROUP_ICONS) do
			if string.find(t, p[1], 1, true) then
				return p[2]
			end
		end
		return "tune"
	end
	function UI.group(parent: GuiObject, title: string, opts: any?): any
		opts = opts or {}
		local gf = frame(parent)
		gf.Name = "Group_" .. title
		gf.AutomaticSize = Enum.AutomaticSize.Y
		gf.Size = UDim2.new(1, 0, 0, 0)
		gf.LayoutOrder = nextOrder()
		vlist(gf, 0)
		padding(gf, 0, 0, if opts.bare then 0 else 12, 0)
		local M = UI.M
		-- v1.1: a group is a boxed card (a header row over a hairline, the rows inside), as in the design
		local body: Frame = gf
		if not opts.bare then
			local card = frame(gf, C.surface:Lerp(C.bg, 0.45))
			card.Name = "Card"
			card.AutomaticSize = Enum.AutomaticSize.Y
			card.Size = UDim2.new(1, 0, 0, 0)
			corner(card, 10)
			stroke(card, C.hairline, 0)
			vlist(card, 0)
			padding(card, 0, 10, 6, 10)
			body = card
			local head = frame(card)
			head.Name = "Head"
			head.Size = UDim2.new(1, 0, 0, 32)
			head.LayoutOrder = nextOrder()
			local t = label(head, string.lower(title), M.small + 1, C.dim, UI.F.semibold)
			t.Name = "Title"
			t.Size = UDim2.new(1, 0, 1, 0)
			-- a small accent glyph before the title (the icon font only: a missing ligature would print its name)
			if UI.F.icon then
				local gi = icon(head, UI.groupIcon(title), 14)
				gi.AnchorPoint = Vector2.new(0, 0.5)
				gi.Position = UDim2.new(0, -1, 0.5, 0)
				recolourIcon(gi, C.accent)
				t.Position = UDim2.fromOffset(20, 0)
				t.Size = UDim2.new(1, -20, 1, 0)
			end
			if opts.max then
				-- a Max-only group: the max mark right after its title
				local mk = UI.sparkles(head, 13, UI.MAX_MARK, t.ZIndex + 1)
				mk.Name = "MaxMark"
				mk.AnchorPoint = Vector2.new(0, 0.5)
				local function placeMark()
					mk.Position = UDim2.new(0, t.Position.X.Offset + math.floor(t.TextBounds.X) + 5, 0.5, 0)
				end
				placeMark()
				t:GetPropertyChangedSignal("TextBounds"):Connect(placeMark)
				UI.tip(mk, "Max only")
			end
			local hl = frame(head, C.hairline)
			hl.Size = UDim2.new(1, 20, 0, 1)
			hl.Position = UDim2.new(0, -10, 1, -1)
			local gap = frame(card)
			gap.Size = UDim2.new(1, 0, 0, 4)
			gap.LayoutOrder = nextOrder()
		end

		local g: any = { frame = gf, rows = {}, advanced = opts.advanced == true, title = title }
		table.insert(UI.groups, g)

		local function row(h: number, text: string?, ropts: any?): Frame
			ropts = ropts or {}
			local r = frame(body)
			r.Size = UDim2.new(1, 0, 0, h)
			r.LayoutOrder = nextOrder()
			local entry: any = { frame = r, text = string.lower(text or ""), advanced = UI.isAdvanced(ropts, text, opts), base = h, descText = ropts.desc, isNote = ropts.isNote == true }
			-- a sub-option of the toggle above (its three-line button opens it): indented under a
			-- hairline, hidden until opened
			if g.subParent then
				entry.parent = g.subParent
				entry.advanced = false
				local pad = Instance.new("UIPadding")
				pad.PaddingLeft = UDim.new(0, 16)
				pad.Parent = r
				local rail = frame(r, C.hairline)
				rail.Name = "SubRail"
				rail.Size = UDim2.new(0, 1, 1, -6)
				rail.Position = UDim2.new(0, -10, 0, 3)
				r.Visible = false
			end
			table.insert(UI.rows, entry)
			table.insert(g.rows, entry)
			return r
		end
		g.row = row

		-- the row's label plus, right after its text, a (?) or amber warning icon whose tooltip holds
		-- the help; `reserve` = the width the control on the right needs
		local function rowLabel(r: Frame, text: string, ropts: any, reserve: number): TextLabel
			local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
			l.Name = "Label"
			l.Size = UDim2.new(1, -(reserve + 24), 1, 0)
			l.TextTruncate = Enum.TextTruncate.AtEnd
			local warnText = if ropts.danger then UI.riskText(ropts.danger) else nil
			local helpText = if type(ropts.desc) == "string" and ropts.desc ~= "" then ropts.desc else nil
			-- Max-only rows (a Max group, or a row flagged max): the max mark right after the text, the hint after it
			local markW = 0
			if ropts.max or opts.max then
				markW = 16
				local mk = UI.sparkles(r, 12, UI.MAX_MARK, l.ZIndex + 1)
				mk.Name = "MaxMark"
				mk.AnchorPoint = Vector2.new(0, 0.5)
				local function placeMark()
					mk.Position = UDim2.new(0, math.floor(l.TextBounds.X) + 5, 0.5, 0)
				end
				placeMark()
				l:GetPropertyChangedSignal("TextBounds"):Connect(placeMark)
			end
			if warnText or helpText then
				local tip = if warnText and helpText then warnText .. "\n\n" .. helpText else (warnText or helpText) :: string
				local holder = frame(r)
				holder.Name = "Hint"
				holder.Size = UDim2.fromOffset(16, 16)
				holder.AnchorPoint = Vector2.new(0, 0.5)
				holder.Position = UDim2.new(0, 0, 0.5, 0)
				local ic = icon(holder, if warnText then "warn" else "help", 14)
				recolourIcon(ic, if warnText then C.warn else C.faint)
				local function place()
					holder.Position = UDim2.new(0, math.floor(l.TextBounds.X) + 6 + markW, 0.5, 0)
				end
				place()
				l:GetPropertyChangedSignal("TextBounds"):Connect(place)
				UI.tip(holder, tip)
				UI.tip(l, tip)
				holder.MouseEnter:Connect(function()
					if not warnText then
						recolourIcon(ic, C.dim)
					end
				end)
				holder.MouseLeave:Connect(function()
					if not warnText then
						recolourIcon(ic, C.faint)
					end
				end)
			end
			return l
		end
		g.rowLabel = rowLabel

		function g.toggle(_, text: string, key: string, topts: { [string]: any })
			topts = topts or {}
			topts.cfgKey = key
			UI.count("toggle")
			Input.bindLabels[key] = text
			local r = row(M.row, text, topts)
			local l = rowLabel(r, text, topts, M.pillW + 8)
			-- the switch: a transparent hit area holding glow → track → knob
			local pill = button(r, "", 10, C.text, C.off)
			pill.Name = "Switch"
			pill.BackgroundTransparency = 1
			pill.Size = UDim2.new(0, M.pillW, 0, M.pillH)
			pill.AnchorPoint = Vector2.new(1, 0.5)
			pill.Position = UDim2.new(1, 0, 0.5, 0)
			local glow = UI.glow(pill, 7, 0.9)
			glow.ZIndex = 1
			local track = frame(pill, C.off)
			track.Size = UDim2.fromScale(1, 1)
			track.ZIndex = 2
			corner(track, M.pillH // 2)
			-- the accent fill fades over the off track while the knob travels (it used to swap colour
			-- in one frame at the start of the knob's slide)
			local fill = frame(pill, Color3.new(1, 1, 1))
			fill.Size = UDim2.fromScale(1, 1)
			fill.ZIndex = 2
			fill.BackgroundTransparency = 1
			corner(fill, M.pillH // 2)
			UI.metalFill(gradient(fill, C.accent2, C.accent))
			local knob = frame(pill, C.knobOff)
			knob.Size = UDim2.new(0, M.knob, 0, M.knob)
			knob.AnchorPoint = Vector2.new(0, 0.5)
			knob.Position = UDim2.new(0, 2, 0.5, 0)
			knob.ZIndex = 3
			corner(knob, M.knob // 2)
			-- key chip left of the switch while a bind exists
			local tag = label(r, "", M.small, C.muted, UI.F.medium)
			tag.Name = "Bind"
			tag.Size = UDim2.new(0, 30, 0, 18)
			tag.AnchorPoint = Vector2.new(1, 0.5)
			tag.Position = UDim2.new(1, -(M.pillW + 8), 0.5, 0)
			tag.BackgroundColor3 = Color3.fromRGB(26, 25, 32)
			tag.BackgroundTransparency = 0
			tag.TextXAlignment = Enum.TextXAlignment.Center
			tag.Visible = false
			corner(tag, 4)
			stroke(tag, C.edge, 0)
			-- "needs silent aim" while the switch is on but the one it depends on is off
			local need = topts.needs or UI.NEEDS[key]
			local needTag: TextLabel? = nil
			if need then
				local first = if type(need) == "table" then need[1] else need
				local nt = label(r, UI.needText(first), M.small, C.warn, UI.F.medium)
				nt.Name = "Needs"
				nt.Size = UDim2.new(0, 96, 0, 18)
				nt.AnchorPoint = Vector2.new(1, 0.5)
				nt.TextXAlignment = Enum.TextXAlignment.Right
				nt.Visible = false
				needTag = nt
			end
			-- three-line button: this row has sub-options (topts.sub builds them as rows right under it,
			-- shown only while it is open; topts.subWhen can hide the button, e.g. while rage is off)
			local subState: any = nil
			local exp: TextButton? = nil
			local expIc: GuiObject? = nil
			if type(topts.sub) == "function" then
				subState = { open = false, when = topts.subWhen }
				local eb = button(r, "", M.small, C.text, C.card)
				eb.Name = "Expand"
				eb.BackgroundTransparency = 1
				eb.Size = UDim2.fromOffset(20, 20)
				eb.AnchorPoint = Vector2.new(1, 0.5)
				corner(eb, 5)
				expIc = icon(eb, "menu", 14)
				recolourIcon(expIc :: GuiObject, C.muted)
				exp = eb
				UI.tip(eb, "More options for " .. text)
			end
			local function expShown(): boolean
				return subState ~= nil and (subState.when == nil or subState.when() == true)
			end
			-- chips right to left: switch, key chip, sub-options, needs chip; the label gives up their width
			local function layout()
				local x = M.pillW + 8
				if tag.Visible then
					x += tag.Size.X.Offset + 6
				end
				if exp then
					local shown = expShown()
					exp.Visible = shown
					exp.Position = UDim2.new(1, -x, 0.5, 0)
					if shown then
						x += 20 + 6
					end
				end
				if needTag then
					needTag.Position = UDim2.new(1, -x, 0.5, 0)
					if needTag.Visible then
						x += needTag.Size.X.Offset + 6
					end
				end
				l.Size = UDim2.new(1, -(x + 24), 1, 0)
			end
			local function refreshTag()
				local b = cfg.binds[key]
				if type(b) == "table" and ((b.key and b.key ~= "") or b.mode == "Always" or b.mode == "Never") then
					local mode = b.mode or "Toggle"
					tag.Text = if mode == "Toggle" then Input.keyLabel(b.key) elseif mode == "Hold" then Input.keyLabel(b.key) .. " hold" else string.lower(mode)
					tag.Size = UDim2.new(0, math.max(24, UI.textW(tag.Text, M.small) + 14), 0, 18)
					-- metal looks: the key chip is a small brushed key (dark ink), as in the design
					tag.TextColor3 = if UI.brushed(tag) then UI.metal.ink else C.muted
					tag.Visible = true
				else
					tag.Text = ""
					tag.Visible = false
				end
				layout()
			end
			refreshTag()
			-- the same key can have several rows (Home + its own tab): every registered tag refreshes
			do
				local prevTag = UI.bindTags[key]
				UI.bindTags[key] = if prevTag then function()
					prevTag()
					refreshTag()
				end else refreshTag
			end
			r.Active = true
			local function onRight(input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					UI.openBindPopup(key, text, UIS:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset().Y))
				end
			end
			r.InputBegan:Connect(onRight)
			pill.InputBegan:Connect(onRight)
			local lastShown: boolean? = nil
			local lastNeed: string? = nil
			local function refresh(animate: boolean)
				local on = cfg[key] == true
				lastShown = on
				local unmet = UI.needUnmet(need)
				local blocked = unmet ~= nil
				lastNeed = unmet
				if needTag then
					local show = on and blocked
					if unmet then
						needTag.Text = UI.needText(unmet)
					end
					if needTag.Visible ~= show then
						needTag.Visible = show
						layout()
					end
				end
				local knobGoal = if on then UDim2.new(1, -(M.knob + 2), 0.5, 0) else UDim2.new(0, 2, 0.5, 0)
				local knobCol = if on then Color3.new(1, 1, 1) else C.knobOff
				local labelCol = if on and not blocked then C.text else C.dim
				local glowTr = if on then UI.glowAlpha(0.9) else 1
				if animate then
					tween(knob, TW_TOGGLE, { Position = knobGoal, BackgroundColor3 = knobCol })
					tween(fill, TW_TOGGLE, { BackgroundTransparency = if on then 0 else 1 })
					tween(l, TW_TOGGLE, { TextColor3 = labelCol })
					tween(glow, TW_TOGGLE, { ImageTransparency = glowTr })
				else
					knob.Position = knobGoal
					knob.BackgroundColor3 = knobCol
					fill.BackgroundTransparency = if on then 0 else 1
					l.TextColor3 = labelCol
					glow.ImageTransparency = glowTr
				end
				glow:SetAttribute("glowOff", not on)
			end
			refresh(false)
			local lastExp = expShown()
			table.insert(UI.sync, function()
				if (cfg[key] == true) ~= lastShown or (need ~= nil and UI.needUnmet(need) ~= lastNeed) then
					refresh(true)
				end
				if exp and expShown() ~= lastExp then
					lastExp = expShown()
					layout()
					UI.refilter()
				end
			end)
			-- registry for tests / automation: S.ui.toggles[cfgKey].shown() is what the pill currently
			-- displays. A duplicate row (Home + tab) chains its refresh so a programmatic change
			-- (PANIC, presets, binds) repaints every pill, not only the last one built.
			do
				local prevReg = S.ui.toggles[key]
				S.ui.toggles[key] = { pill = pill, row = r, refresh = function()
					if prevReg then
						prevReg.refresh()
					end
					refresh(true)
				end, shown = function()
					return lastShown
				end }
			end
			pill.MouseEnter:Connect(function()
				if cfg[key] == true then
					tween(glow, TW_HOVER, { ImageTransparency = UI.glowAlpha(1.3) })
				else
					tween(knob, TW_HOVER, { BackgroundColor3 = C.dim })
				end
			end)
			pill.MouseLeave:Connect(function()
				if cfg[key] == true then
					tween(glow, TW_HOVER, { ImageTransparency = UI.glowAlpha(0.9) })
				else
					tween(knob, TW_HOVER, { BackgroundColor3 = C.knobOff })
				end
			end)
			pill.MouseButton1Click:Connect(function()
				cfg[key] = not cfg[key]
				refresh(true)
				-- onChange may change other keys (a positioning toggle sets ragePosition, the accent cycle sets
				-- maxTheme): save AFTER it, or the derived change is lost on the next hop / reinject
				if topts.onChange then
					topts.onChange(cfg[key])
				end
				saveConfig()
			end)
			if subState and exp then
				-- the sub-rows: ordinary rows of this group, indented, placed right after this one
				local prevParent = g.subParent
				g.subParent = subState
				local okSub, errSub = pcall(topts.sub, g)
				g.subParent = prevParent
				if not okSub then
					log("WARN", ("menu: the sub-options of %s failed to build: %s"):format(text, tostring(errSub)))
				end
				exp.MouseButton1Click:Connect(function()
					if subState.animating then
						return
					end
					local opening = not subState.open
					if UI.brushed(exp :: TextButton) then
						-- metal looks: an open sub-options button is a brushed key, as in the design
						local light = (exp :: TextButton):FindFirstChild("BrushedLight")
						if light then
							(light :: Frame).Visible = opening
						end
						(exp :: TextButton).BackgroundTransparency = if opening then 0 else 1
						recolourIcon(expIc :: GuiObject, if opening then UI.metal.ink else C.muted)
					else
						recolourIcon(expIc :: GuiObject, if opening then C.accent else C.muted)
					end
					if opening then
						subState.open = true
						UI.refilter()
						UI.animSub(subState, true, nil)
					else
						UI.animSub(subState, false, function()
							subState.open = false
							UI.refilter()
						end)
					end
				end)
				exp.MouseEnter:Connect(function()
					if not (UI.metal and subState.open) then
						(exp :: TextButton).BackgroundTransparency = if UI.metal then 0.85 else 0
					end
				end)
				exp.MouseLeave:Connect(function()
					if not (UI.metal and subState.open) then
						(exp :: TextButton).BackgroundTransparency = 1
					end
				end)
			end
			return r
		end

		function g.slider(_, text: string, key: string, min: number, max: number, step: number?, sopts: { [string]: any })
			sopts = sopts or {}
			sopts.cfgKey = key
			UI.count("slider")
			local r = row(M.row, text, sopts)
			local trackW = sopts.trackW or M.trackW
			local reserve = trackW + 10 + M.valueW
			rowLabel(r, text, sopts, reserve)
			-- value (right): the number in text colour, the unit muted
			local v = button(r, "", M.value, C.text, C.surface)
			v.Name = "Value"
			v.BackgroundTransparency = 1
			v.Size = UDim2.new(0, M.valueW, 1, 0)
			v.AnchorPoint = Vector2.new(1, 0)
			v.Position = UDim2.new(1, 0, 0, 0)
			v.TextXAlignment = Enum.TextXAlignment.Right
			v.RichText = true
			-- outside the safe range an amber warning appears left of the track
			local warnIc: GuiObject? = nil
			if sopts.safe then
				local holder = frame(r)
				holder.Size = UDim2.fromOffset(16, 16)
				holder.AnchorPoint = Vector2.new(1, 0.5)
				holder.Position = UDim2.new(1, -(reserve + 4), 0.5, 0)
				holder.Visible = false
				local wi = icon(holder, "warn", 14)
				recolourIcon(wi, C.warn)
				UI.tip(holder, UI.riskText(sopts.safeText or "SERVER-CHECKED"))
				warnIc = holder
			end
			-- hit area (16 px tall) → track (4 px) → glow → fill → knob
			local rail = button(r, "", 10, C.text, C.off)
			rail.Name = "Rail"
			rail.BackgroundTransparency = 1
			rail.Size = UDim2.new(0, trackW, 0, 16)
			rail.AnchorPoint = Vector2.new(1, 0.5)
			rail.Position = UDim2.new(1, -(M.valueW + 10), 0.5, 0)
			local track = frame(rail, C.off)
			track.Size = UDim2.new(1, 0, 0, 4)
			track.AnchorPoint = Vector2.new(0, 0.5)
			track.Position = UDim2.new(0, 0, 0.5, 0)
			corner(track, 2)
			local fillGlow = UI.glow(track, 5, 0.7)
			fillGlow.AnchorPoint = Vector2.new(0, 0.5)
			fillGlow.Position = UDim2.new(0, -5, 0.5, 0)
			local fill = frame(track, Color3.new(1, 1, 1))
			fill.Size = UDim2.new(0, 0, 1, 0)
			corner(fill, 2)
			UI.metalFill(gradient(fill, C.accent2, C.accent))
			local knob = frame(track, Color3.new(1, 1, 1))
			knob.Size = UDim2.new(0, 10, 0, 10)
			knob.AnchorPoint = Vector2.new(0.5, 0.5)
			knob.Position = UDim2.new(0, 0, 0.5, 0)
			corner(knob, 5)
			local ring = stroke(knob, if UI.metal then UI.metal.lite else C.accent, 1)
			ring.Thickness = if UI.metal then 2 else 3
			local function fmt(n: number): string
				if sopts.fmt then
					return sopts.fmt(n)
				end
				return tostring(math.floor(n * 100 + 0.5) / 100)
			end
			local unit = if type(sopts.unit) == "string" and sopts.unit ~= "" then sopts.unit else nil
			local mutedHex = ("#%02x%02x%02x"):format(math.floor(C.muted.R * 255 + 0.5), math.floor(C.muted.G * 255 + 0.5), math.floor(C.muted.B * 255 + 0.5))
			local shownText = ""
			local function refresh(animateKnob: boolean?)
				local n = tonumber(cfg[key]) or min
				local rel = math.clamp((n - min) / math.max(max - min, 1e-6), 0, 1)
				local kp = UDim2.new(rel, 0, 0.5, 0)
				fillGlow.Visible = rel > 0.01
				-- the fill travels with the knob (a click-jump used to snap the fill and glide the knob)
				if animateKnob then
					tween(knob, TW_KNOB, { Position = kp })
					tween(fill, TW_KNOB, { Size = UDim2.new(rel, 0, 1, 0) })
					tween(fillGlow, TW_KNOB, { Size = UDim2.new(rel, 10, 1, 10) })
				else
					knob.Position = kp
					fill.Size = UDim2.new(rel, 0, 1, 0)
					fillGlow.Size = UDim2.new(rel, 10, 1, 10)
				end
				shownText = fmt(n)
				local unsafe = sopts.safe ~= nil and (n < sopts.safe[1] or n > sopts.safe[2])
				local numCol = if unsafe then ("#%02x%02x%02x"):format(math.floor(C.warn.R * 255 + 0.5), math.floor(C.warn.G * 255 + 0.5), math.floor(C.warn.B * 255 + 0.5)) else nil
				local num = if numCol then ('<font color="%s">%s</font>'):format(numCol, shownText) else shownText
				v.Text = if unit then ('%s<font color="%s">%s%s</font>'):format(num, mutedHex, if unit == "%" or unit == "°" or unit == "×" then "" else " ", unit) else num
				if warnIc then
					warnIc.Visible = unsafe
				end
			end
			local function setRing(on: boolean)
				tween(ring, TW_HOVER, { Transparency = if on then 0.72 else 1 })
			end
			rail.MouseEnter:Connect(function()
				setRing(true)
			end)
			rail.MouseLeave:Connect(function()
				if not (UI.drag and UI.drag.owner == rail) then
					setRing(false)
				end
			end)
			local lastChangeAt = 0
			local function setValue(n: number, dragging: boolean?)
				if step then
					n = math.floor(n / step + 0.5) * step
					-- kill float dust (0.1 + 0.2 → 0.30000000000000004 in the badge and the config)
					local digits = math.max(0, math.ceil(-math.log10(step)))
					local pow = 10 ^ digits
					n = math.floor(n * pow + 0.5) / pow
				end
				n = math.clamp(n, min, max)
				if cfg[key] == n then
					return
				end
				cfg[key] = n
				-- while the mouse drags: no knob tween per pixel and the change callback at ≤ 20 Hz
				-- (the release fires it once more with the final value)
				refresh(not dragging)
				if sopts.onChange then
					local now = os.clock()
					if not dragging or now - lastChangeAt > 0.05 then
						lastChangeAt = now
						sopts.onChange(n)
					end
				end
			end
			local function setFromX(x: number, dragging: boolean?)
				local rel = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
				setValue(min + (max - min) * rel, dragging)
			end
			refresh(false)
			table.insert(UI.sync, function()
				if fmt(tonumber(cfg[key]) or min) ~= shownText then
					refresh(true)
				end
			end)
			-- one kit-level drag manager (UI.beginDrag) instead of two UserInputService connections per
			-- slider: ~120 sliders used to run 240 handlers on every mouse movement
			rail.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					setFromX(i.Position.X, true)
					setRing(true)
					UI.beginDrag(function(pos: Vector2)
						setFromX(pos.X, true)
					end, function()
						if sopts.onChange then
							sopts.onChange(tonumber(cfg[key]) or min)
						end
						refresh(true)
						setRing(false)
						saveConfig()
					end)
					if UI.drag then
						UI.drag.owner = rail
					end
				end
			end)
			-- click the number to type a value: Enter sets it, Esc / clicking away keeps the old one. The box
			-- starts with the plain number ("×0.05" / "15k" / "never" could not be parsed back — the old
			-- double-click box silently ignored every Enter on those), accepts "0.3", "x0.3", "15k", "20%",
			-- "never", and a typed value may pass the track's ends up to sopts.typeMin / typeMax.
			local tMin = if type(sopts.typeMin) == "number" then sopts.typeMin else min
			local tMax = if type(sopts.typeMax) == "number" then sopts.typeMax else max
			local typeDigits = if step and step >= 1 then 0 else 3
			local function plain(n: number): string
				local s = ("%." .. typeDigits .. "f"):format(n)
				if typeDigits > 0 then
					s = string.gsub(string.gsub(s, "0+$", ""), "%.$", "")
				end
				return s
			end
			UI.tip(v, ("Click to type a value (%s – %s)"):format(plain(tMin), plain(tMax)))
			v.MouseEnter:Connect(function()
				v.BackgroundTransparency = 0.55
			end)
			v.MouseLeave:Connect(function()
				v.BackgroundTransparency = 1
			end)
			local editing = false
			v.MouseButton1Click:Connect(function()
				if editing then
					return
				end
				editing = true
				local box = Instance.new("TextBox")
				box.Size = UDim2.new(0, math.max(M.valueW + 24, 66), 0, 22)
				box.AnchorPoint = Vector2.new(1, 0.5)
				box.Position = UDim2.new(1, 2, 0.5, 0)
				box.BackgroundColor3 = C.surface
				box.BorderSizePixel = 0
				UI.setFont(box, UI.F.medium)
				box.TextSize = M.value
				box.TextColor3 = C.text
				box.PlaceholderText = plain(tonumber(cfg[key]) or min)
				box.PlaceholderColor3 = C.muted
				box.TextXAlignment = Enum.TextXAlignment.Right
				box.Text = plain(tonumber(cfg[key]) or min)
				box.ClearTextOnFocus = false
				box.ZIndex = 5
				box.Parent = r
				corner(box, 5)
				stroke(box, C.accent, 0.2)
				padding(box, 0, 6, 0, 6)
				box:CaptureFocus()
				pcall(function()
					box.SelectionStart = 1
					box.CursorPosition = #box.Text + 1
				end)
				box.FocusLost:Connect(function(enterPressed: boolean)
					editing = false
					local n = if enterPressed then UI.parseNumber(box.Text) else nil
					box:Destroy()
					if n == nil then
						return
					end
					local pow = 10 ^ typeDigits
					n = math.clamp(math.floor(n * pow + 0.5) / pow, tMin, tMax)
					if cfg[key] ~= n then
						cfg[key] = n
						refresh(true)
						if sopts.onChange then
							sopts.onChange(n)
						end
					else
						refresh(true)
					end
					saveConfig()
				end)
			end)
			return r
		end

		function g.cycle(_, text: string, key: string, options: { string }, copts: { [string]: any })
			copts = copts or {}
			copts.cfgKey = key
			UI.count("cycle")
			local r = row(M.row, text, copts)
			rowLabel(r, text, copts, M.ctrlW)
			-- v5: optional copts.fmt(value) → display text, so numeric options read as words
			-- shown lowercase like every label (the stored value keeps its case)
			local function shownOf(v: any): string
				if copts.fmt then
					local okF, s = pcall(copts.fmt, v)
					if okF and s ~= nil then
						return string.lower(tostring(s))
					end
				end
				return string.lower(tostring(v))
			end
			local b = button(r, "", M.value, C.text, C.surface)
			b.Name = "Dropdown"
			b.Size = UDim2.new(0, M.ctrlW, 0, 22)
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, 0, 0.5, 0)
			corner(b, 5)
			local bs = stroke(b, C.edge, 0)
			local val = label(b, "", M.value, C.text, UI.F.body)
			val.Size = UDim2.new(1, -30, 1, 0)
			val.Position = UDim2.fromOffset(9, 0)
			val.TextTruncate = Enum.TextTruncate.AtEnd
			local chev = icon(b, "expand", 16)
			chev.AnchorPoint = Vector2.new(1, 0.5)
			chev.Position = UDim2.new(1, -4, 0.5, 0)
			recolourIcon(chev, C.muted)
			local function refresh()
				val.Text = shownOf(cfg[key])
			end
			refresh()
			table.insert(UI.sync, function()
				if val.Text ~= shownOf(cfg[key]) then
					refresh()
				end
			end)
			b.MouseEnter:Connect(function()
				b.BackgroundColor3 = C.card
			end)
			b.MouseLeave:Connect(function()
				b.BackgroundColor3 = C.surface
			end)
			b.MouseButton1Click:Connect(function()
				bs.Color = C.accent
				UI.openDropdown(b, M.ctrlW, function(f: Frame): number
					for i, opt in ipairs(options) do
						UI.dropdownOption(f, 4 + (i - 1) * 24, shownOf(opt), cfg[key] == opt, function()
							cfg[key] = opt
							refresh()
							UI.closeDropdown()
							-- save AFTER onChange: the Accent cycle's onChange sets cfg.maxTheme, which was lost
							-- (a Max look picked as the last change reverted after a hop)
							if copts.onChange then
								copts.onChange(opt)
							end
							saveConfig()
						end)
					end
					return 8 + #options * 24
				end, function()
					bs.Color = C.edge
				end)
			end)
			return r
		end

		function g.color(_, text: string, key: string, copts: { [string]: any })
			copts = copts or {}
			copts.cfgKey = key
			UI.count("color")
			local r = row(M.row, text, copts)
			rowLabel(r, text, copts, 36)
			local sw = button(r, "", 10, C.text, Vis.col(key))
			sw.Name = "Swatch"
			sw.Size = UDim2.new(0, 28, 0, 16)
			sw.AnchorPoint = Vector2.new(1, 0.5)
			sw.Position = UDim2.new(1, 0, 0.5, 0)
			corner(sw, 4)
			stroke(sw, Color3.new(1, 1, 1), 0.82)
			local hh, ss, vv = Vis.col(key):ToHSV()
			local function apply(c3: Color3)
				cfg[key] = { math.floor(c3.R * 255 + 0.5), math.floor(c3.G * 255 + 0.5), math.floor(c3.B * 255 + 0.5) }
				sw.BackgroundColor3 = c3
				if copts.onChange then
					copts.onChange(c3)
				end
			end
			table.insert(UI.sync, function()
				local c = Vis.col(key)
				if sw.BackgroundColor3 ~= c then
					sw.BackgroundColor3 = c
				end
			end)
			sw.MouseButton1Click:Connect(function()
				hh, ss, vv = Vis.col(key):ToHSV()
				UI.openDropdown(sw, 206, function(f: Frame): number
					local rails: any = {}
					local function refreshRails()
						local hueKeys = {}
						for i = 0, 6 do
							table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
						end
						rails.h.grad.Color = ColorSequence.new(hueKeys)
						rails.s.grad.Color = ColorSequence.new(Color3.fromHSV(hh, 0, vv), Color3.fromHSV(hh, 1, vv))
						rails.v.grad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(hh, ss, 1))
						rails.h.mark.Position = UDim2.new(hh, 0, 0.5, 0)
						rails.s.mark.Position = UDim2.new(ss, 0, 0.5, 0)
						rails.v.mark.Position = UDim2.new(vv, 0, 0.5, 0)
					end
					local function setFrom(kind: string, px: number)
						local rl = rails[kind].rail
						local rel = math.clamp((px - rl.AbsolutePosition.X) / math.max(rl.AbsoluteSize.X, 1), 0, 1)
						if kind == "h" then
							hh = rel
						elseif kind == "s" then
							ss = rel
						else
							vv = rel
						end
						apply(Color3.fromHSV(hh, ss, vv))
						refreshRails()
					end
					local function mkRail(kind: string, y: number)
						local rl = button(f, "", 10, C.text, Color3.new(1, 1, 1))
						rl.Size = UDim2.new(1, -20, 0, 10)
						rl.Position = UDim2.fromOffset(10, y)
						rl.ZIndex = 61
						corner(rl, 5)
						local grad = Instance.new("UIGradient")
						grad.Parent = rl
						local mark = frame(rl, Color3.new(1, 1, 1))
						mark.Size = UDim2.fromOffset(4, 14)
						mark.AnchorPoint = Vector2.new(0.5, 0.5)
						mark.ZIndex = 62
						corner(mark, 2)
						stroke(mark, Color3.new(0, 0, 0), 0.45)
						rails[kind] = { rail = rl, grad = grad, mark = mark }
						rl.InputBegan:Connect(function(i)
							if i.UserInputType == Enum.UserInputType.MouseButton1 then
								setFrom(kind, i.Position.X)
								UI.beginDrag(function(pos: Vector2)
									setFrom(kind, pos.X)
								end, function()
									saveConfig()
								end)
							end
						end)
					end
					mkRail("h", 40)
					mkRail("s", 60)
					mkRail("v", 80)
					local presets = { C.accent, Color3.fromRGB(242, 240, 247), Color3.fromRGB(142, 138, 153), Color3.fromRGB(255, 92, 122), Color3.fromRGB(255, 150, 70), Color3.fromRGB(255, 214, 90), Color3.fromRGB(69, 223, 160), Color3.fromRGB(111, 201, 255), Color3.fromRGB(255, 114, 176) }
					for i, pc in ipairs(presets) do
						local pb = button(f, "", 10, C.text, pc)
						pb.Size = UDim2.fromOffset(18, 18)
						pb.Position = UDim2.fromOffset(10 + (i - 1) * 21, 10)
						pb.ZIndex = 61
						corner(pb, 9)
						stroke(pb, Color3.new(1, 1, 1), 0.82)
						pb.MouseButton1Click:Connect(function()
							hh, ss, vv = pc:ToHSV()
							apply(pc)
							saveConfig()
							refreshRails()
						end)
					end
					refreshRails()
					return 102
				end, copts.onClose)
			end)
			return r
		end

		-- keybind: click → press a key / mouse button / M4 / M5 (Escape or Backspace clears)
		function g.keybind(_, text: string, key: string, kopts: { [string]: any })
			kopts = kopts or {}
			kopts.cfgKey = key
			UI.count("keybind")
			local r = row(M.row, text, kopts)
			rowLabel(r, text, kopts, 90)
			local b = button(r, "", M.small, C.dim, Color3.fromRGB(26, 25, 32))
			b.Name = "Key"
			b.AutomaticSize = Enum.AutomaticSize.X
			b.Size = UDim2.new(0, 34, 0, 20)
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, 0, 0.5, 0)
			UI.setFont(b, UI.F.semibold)
			corner(b, 4)
			local ks = stroke(b, C.edge, 0)
			padding(b, 0, 8, 0, 8)
			-- metal looks: the key is a brushed keycap with dark ink
			local keyed = UI.brushed(b)
			if keyed then
				b.TextColor3 = UI.metal.ink
				UI.setFont(b, UI.F.bold)
				b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
			end
			b.MouseEnter:Connect(function()
				if keyed then
					tween(b, TW_HOVER, { BackgroundColor3 = Color3.new(1, 1, 1) })
				else
					ks.Color = C.muted
				end
			end)
			b.MouseLeave:Connect(function()
				if keyed then
					tween(b, TW_HOVER, { BackgroundColor3 = Color3.fromRGB(228, 228, 232) })
				else
					ks.Color = C.edge
				end
			end)
			local function show()
				b.Text = Input.keyLabel(cfg[key])
			end
			show()
			table.insert(UI.sync, function()
				if not Input.capturing() and b.Text ~= Input.keyLabel(cfg[key]) then
					show()
				end
			end)
			b.MouseButton1Click:Connect(function()
				b.Text = "Press a key…"
				Input.captureKey(function(name)
					if name ~= false then
						cfg[key] = name or ""
						saveConfig()
						if kopts.onChange then
							kopts.onChange(cfg[key])
						end
					end
					show()
				end)
			end)
			return r
		end

		function g.button(_, text: string, fn: () -> (), tint: Color3?, bopts: any?)
			bopts = bopts or {}
			UI.count("button")
			local r = row(M.rowButton, text, bopts)
			-- neutral by default; a tint (accent / danger / warn) makes it the tinted primary style
			local base = if tint then tint else C.surface
			local b = button(r, string.lower(text), M.value, if tint then tint else C.dim, base)
			b.Size = UDim2.new(1, 0, 0, 26)
			b.AnchorPoint = Vector2.new(0, 0.5)
			b.Position = UDim2.new(0, 0, 0.5, 0)
			b.BackgroundTransparency = if tint then 0.87 else 0
			b.TextTruncate = Enum.TextTruncate.AtEnd
			corner(b, 6)
			local st = stroke(b, if tint then tint else C.edge, if tint then 0.6 else 0)
			-- metal looks: the accent (primary) button is a brushed key with dark ink; danger / warn keep their tint
			local keyed = tint == C.accent and UI.brushed(b)
			local rest = Color3.fromRGB(228, 228, 232)
			if keyed then
				b.BackgroundTransparency = 0
				b.BackgroundColor3 = rest
				b.TextColor3 = UI.metal.ink
				UI.setFont(b, UI.F.bold)
			end
			b.MouseEnter:Connect(function()
				if keyed then
					tween(b, TW_HOVER, { BackgroundColor3 = Color3.new(1, 1, 1) })
				elseif tint then
					tween(b, TW_HOVER, { BackgroundTransparency = 0.8 })
				else
					tween(b, TW_HOVER, { BackgroundColor3 = C.card, TextColor3 = C.text })
				end
			end)
			b.MouseLeave:Connect(function()
				if keyed then
					tween(b, TW_HOVER, { BackgroundColor3 = rest })
				elseif tint then
					tween(b, TW_HOVER, { BackgroundTransparency = 0.87 })
				else
					tween(b, TW_HOVER, { BackgroundColor3 = C.surface, TextColor3 = C.dim })
				end
			end)
			-- press feedback: a 1 px dip so a click is visibly acknowledged
			b.MouseButton1Down:Connect(function()
				b.Position = UDim2.new(0, 0, 0.5, 1)
				st.Transparency = 0
			end)
			b.MouseButton1Up:Connect(function()
				b.Position = UDim2.new(0, 0, 0.5, 0)
				st.Transparency = if keyed then 0.5 elseif tint then 0.6 else 0
			end)
			b.MouseButton1Click:Connect(function()
				local ok, err = pcall(fn)
				if not ok then
					reportError("button " .. text, err)
				end
			end)
			if type(bopts.desc) == "string" and bopts.desc ~= "" then
				UI.tip(b, bopts.desc)
			end
			return b
		end

		function g.note(_, text: string, nopts: { [string]: any })
			nopts = nopts or {}
			nopts.isNote = true
			UI.count("note")
			-- the row grows with its text (live notes change length) — a note can never run into the
			-- next row; nopts.height is only a floor
			local width = opts.colW or M.colW
			local minH = if text ~= "" then UI.textH(text, M.desc, nil, width) + 8 else math.max(18, nopts.height or 18)
			local r = row(minH, text, nopts)
			r.AutomaticSize = Enum.AutomaticSize.Y
			local l = label(r, text, M.desc, nopts.color or C.muted, UI.F.body)
			l.Size = UDim2.new(1, 0, 0, 0)
			l.Position = UDim2.new(0, 0, 0, 3)
			l.AutomaticSize = Enum.AutomaticSize.Y
			l.TextWrapped = true
			l.TextYAlignment = Enum.TextYAlignment.Top
			return l
		end

		-- picker: ‹ value › over a list that can change; idxKey persists the index
		function g.picker(_, text: string, getList: () -> { string }, idxKey: string, onChange: (string) -> ())
			UI.count("picker")
			local r = row(M.row, text)
			local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
			l.Size = UDim2.new(0, 70, 1, 0)
			local val = label(r, "", M.value, C.text, UI.F.medium)
			val.Size = UDim2.new(1, -140, 1, 0)
			val.Position = UDim2.new(0, 74, 0, 0)
			val.TextTruncate = Enum.TextTruncate.AtEnd
			local function mk(ic: string, x: number): TextButton
				local b = button(r, "", M.title, C.text, C.surface)
				b.Size = UDim2.new(0, 24, 0, 22)
				b.AnchorPoint = Vector2.new(0, 0.5)
				b.Position = UDim2.new(1, x, 0.5, 0)
				corner(b, 5)
				stroke(b, C.edge, 0)
				recolourIcon(icon(b, ic, 16), C.dim)
				return b
			end
			local prev, nxt = mk("left", -52), mk("right", -24)
			local function refresh()
				local list = getList()
				if #list == 0 then
					val.Text = "—"
					return
				end
				cfg[idxKey] = ((tonumber(cfg[idxKey]) or 1) - 1) % #list + 1
				val.Text = list[cfg[idxKey]]
				onChange(list[cfg[idxKey]])
			end
			prev.MouseButton1Click:Connect(function()
				cfg[idxKey] = (tonumber(cfg[idxKey]) or 1) - 1
				refresh()
				saveConfig()
			end)
			nxt.MouseButton1Click:Connect(function()
				cfg[idxKey] = (tonumber(cfg[idxKey]) or 1) + 1
				refresh()
				saveConfig()
			end)
			refresh()
			return refresh
		end

		-- multiselect: cfg[key] = { [option] = true }
		function g.multiselect(_, text: string, key: string, options: { string }, mopts: { [string]: any })
			mopts = mopts or {}
			mopts.cfgKey = key
			UI.count("multiselect")
			local r = row(M.row, text, mopts)
			rowLabel(r, text, mopts, M.ctrlW)
			if type(cfg[key]) ~= "table" then
				cfg[key] = {}
			end
			local b = button(r, "", M.value, C.text, C.surface)
			b.Name = "Multiselect"
			b.Size = UDim2.new(0, M.ctrlW, 0, 22)
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, 0, 0.5, 0)
			corner(b, 5)
			local bs = stroke(b, C.edge, 0)
			local val = label(b, "", M.value, C.text, UI.F.body)
			val.Size = UDim2.new(1, -30, 1, 0)
			val.Position = UDim2.fromOffset(9, 0)
			val.TextTruncate = Enum.TextTruncate.AtEnd
			local chev = icon(b, "expand", 16)
			chev.AnchorPoint = Vector2.new(1, 0.5)
			chev.Position = UDim2.new(1, -4, 0.5, 0)
			recolourIcon(chev, C.muted)
			local function summary(): string
				local on = {}
				for _, opt in ipairs(options) do
					if cfg[key][opt] == true then
						table.insert(on, opt)
					end
				end
				if #on == 0 then
					return "None"
				elseif #on == #options then
					return "All"
				end
				return table.concat(on, ", ")
			end
			local function refresh()
				val.Text = summary()
			end
			refresh()
			-- follows changes made elsewhere (sanitize forcing a hitbox on, presets, a duplicate row)
			table.insert(UI.sync, function()
				if val.Text ~= summary() then
					refresh()
				end
			end)
			b.MouseEnter:Connect(function()
				b.BackgroundColor3 = C.card
			end)
			b.MouseLeave:Connect(function()
				b.BackgroundColor3 = C.surface
			end)
			b.MouseButton1Click:Connect(function()
				bs.Color = C.accent
				UI.openDropdown(b, M.ctrlW, function(f: Frame): number
					local optBtns = {}
					local function paint()
						for opt, ob in pairs(optBtns) do
							local on = cfg[key][opt] == true
							ob:SetAttribute("selected", on)
							local ic = ob:FindFirstChild("Icon")
							if ic then
								ic.Visible = on
							end
							local lb = ob:FindFirstChildOfClass("TextLabel")
							if lb and lb.Name ~= "Icon" then
								lb.TextColor3 = if on then C.accent else C.dim
							end
						end
					end
					for i, opt in ipairs(options) do
						optBtns[opt] = UI.dropdownOption(f, 4 + (i - 1) * 24, opt, cfg[key][opt] == true, function()
							cfg[key][opt] = if cfg[key][opt] then nil else true
							if mopts.onChange then
								mopts.onChange(cfg[key])
							end
							saveConfig()
							refresh()
							paint()
						end)
					end
					return 8 + #options * 24
				end, function()
					bs.Color = C.edge
				end)
			end)
			return r
		end

		function g.custom(_, hgt: number, text: string?, copts: any?): Frame
			return row(hgt, text or "", copts)
		end
		-- a short text value bound to cfg[key] (a name, a tag): typed in a field on the right, committed on
		-- Enter or when focus leaves; topts.maxLen caps it, topts.placeholder shows while empty
		function g.textbox(_, text: string, key: string, topts: { [string]: any })
			topts = topts or {}
			topts.cfgKey = key
			UI.count("textbox")
			local r = row(M.row, text, topts)
			rowLabel(r, text, topts, 150)
			local box = Instance.new("TextBox")
			box.Name = "Field"
			box.Size = UDim2.new(0, 140, 0, 22)
			box.AnchorPoint = Vector2.new(1, 0.5)
			box.Position = UDim2.new(1, 0, 0.5, 0)
			box.BackgroundColor3 = C.surface
			box.BorderSizePixel = 0
			box.ClearTextOnFocus = false
			box.FontFace = UI.F.medium
			box.TextSize = M.value
			box.TextColor3 = C.text
			box.PlaceholderColor3 = C.muted
			box.PlaceholderText = topts.placeholder or ""
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.TextTruncate = Enum.TextTruncate.AtEnd
			box.Text = tostring(cfg[key] or "")
			box.Parent = r
			corner(box, 5)
			stroke(box, C.edge, 0)
			padding(box, 0, 8, 0, 8)
			local maxLen = topts.maxLen or 24
			box:GetPropertyChangedSignal("Text"):Connect(function()
				local cut = utf8.offset(box.Text, maxLen + 1)
				if utf8.len(box.Text) and cut then
					box.Text = box.Text:sub(1, cut - 1)
				end
			end)
			box.FocusLost:Connect(function()
				local v = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
				cfg[key] = v
				box.Text = v
				if topts.onChange then
					topts.onChange(v)
				end
			end)
			table.insert(UI.sync, function()
				if not box:IsFocused() and box.Text ~= tostring(cfg[key] or "") then
					box.Text = tostring(cfg[key] or "")
				end
			end)
			return box
		end

		-- read-only row: label left, a live value right (the getter runs while the menu is open)
		function g.info(_, text: string, getter: () -> any, iopts: any?): TextLabel
			iopts = iopts or {}
			UI.count("info")
			local r = row(M.row, text, iopts)
			local l = label(r, string.lower(text), M.title, C.dim, UI.F.body)
			l.Size = UDim2.new(0.45, 0, 1, 0)
			l.TextTruncate = Enum.TextTruncate.AtEnd
			local v = label(r, "", M.value, C.text, UI.F.medium)
			v.Size = UDim2.new(0.55, 0, 1, 0)
			v.Position = UDim2.new(0.45, 0, 0, 0)
			v.TextXAlignment = Enum.TextXAlignment.Right
			v.TextTruncate = Enum.TextTruncate.AtEnd
			local function refresh()
				local ok, s = pcall(getter)
				local txt = if ok and s ~= nil then tostring(s) else "—"
				if v.Text ~= txt then
					v.Text = txt
				end
			end
			refresh()
			UI.syncLazy(function()
				if r.Visible then
					refresh()
				end
			end)
			return v
		end
		-- a key / value row its owner fills (the Debug readouts): the everyday row look, the value
		-- right-aligned in the value face; the caller may tint it
		function g.stat(_, text: string, sopts: any?): TextLabel
			UI.count("info")
			local r = row(M.row, text, sopts or {})
			local l = label(r, string.lower(text), M.title, C.dim, UI.F.body)
			l.Size = UDim2.new(0.34, 0, 1, 0)
			l.TextTruncate = Enum.TextTruncate.AtEnd
			local v = label(r, "—", M.value, C.text, UI.F.medium)
			v.Size = UDim2.new(0.66, -8, 1, 0)
			v.Position = UDim2.new(0.34, 8, 0, 0)
			v.TextXAlignment = Enum.TextXAlignment.Right
			v.TextTruncate = Enum.TextTruncate.AtEnd
			return v
		end
		-- a card of `n` monospace lines (shot and packet logs)
		function g.logBlock(_, text: string, n: number): { TextLabel }
			local lineH = math.max(16, UI.TEXT_MIN + 5)
			local r = row(n * lineH + 18, text, {})
			local card = frame(r, C.surface)
			card.Size = UDim2.new(1, 0, 1, -6)
			card.Position = UDim2.fromOffset(0, 3)
			corner(card, 8)
			stroke(card, C.edge, 0)
			padding(card, 6, 10, 6, 10)
			vlist(card, 0)
			local out = {}
			for i = 1, n do
				local t = label(card, "", UI.TEXT_MIN, C.dim, UI.F.code)
				t.Size = UDim2.new(1, 0, 0, lineH)
				t.TextTruncate = Enum.TextTruncate.AtEnd
				t.LayoutOrder = i
				out[i] = t
			end
			return out
		end

		-- a row of equal buttons: items = { { label, fn, tint? }, ... }
		function g.buttonRow(_, text: string, items: { any }, bopts: any?): { TextButton }
			bopts = bopts or {}
			UI.count("button")
			local r = row(M.rowButton, text, bopts)
			local out = {}
			local n = #items
			for i, it in ipairs(items) do
				local tint = it[3]
				local b = button(r, string.lower(tostring(it[1])), M.value, if tint then tint else C.dim, if tint then tint else C.surface)
				b.Size = UDim2.new(1 / n, if i < n then -6 else 0, 0, 26)
				b.AnchorPoint = Vector2.new(0, 0.5)
				b.Position = UDim2.new((i - 1) / n, if i > 1 then (i - 1) * 6 / n else 0, 0.5, 0)
				b.BackgroundTransparency = if tint then 0.87 else 0
				b.TextTruncate = Enum.TextTruncate.AtEnd
				corner(b, 6)
				stroke(b, if tint then tint else C.edge, if tint then 0.6 else 0)
				-- metal looks: an accent button is a brushed key (see g.button)
				local keyed = tint == C.accent and UI.brushed(b)
				if keyed then
					b.BackgroundTransparency = 0
					b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
					b.TextColor3 = UI.metal.ink
					UI.setFont(b, UI.F.bold)
				end
				b.MouseEnter:Connect(function()
					if keyed then
						b.BackgroundColor3 = Color3.new(1, 1, 1)
					elseif tint then
						b.BackgroundTransparency = 0.8
					else
						b.BackgroundColor3 = C.card
						b.TextColor3 = C.text
					end
				end)
				b.MouseLeave:Connect(function()
					if keyed then
						b.BackgroundColor3 = Color3.fromRGB(228, 228, 232)
					elseif tint then
						b.BackgroundTransparency = 0.87
					else
						b.BackgroundColor3 = C.surface
						b.TextColor3 = C.dim
					end
				end)
				b.MouseButton1Click:Connect(function()
					local ok, err = pcall(it[2])
					if not ok then
						reportError("button " .. tostring(it[1]), err)
					end
				end)
				out[i] = b
			end
			return out
		end

		-- list: single-select scrolling list with a search box. lopts = { height, search = true,
		--   items = () -> { { id, label, sub?, color?, dim? } }, selected = () -> id?, onSelect = (id) -> () }
		-- Rows are pooled; returns refresh(). Re-renders itself when the selection changes elsewhere.
		function g.list(_, text: string, lopts: any)
			lopts = lopts or {}
			lopts.isList = true
			UI.count("list")
			-- the visible area is a whole number of rows (+ 8 px padding): no half row cut off at
			-- the bottom edge of the list
			local RH = M.listRow
			local hdr = if lopts.search ~= false then 52 else 24
			local wanted = math.ceil((lopts.height or 200) * 1.15)
			local rowsFit = math.max(3, math.floor((wanted - hdr - 8) / RH))
			local height = hdr + rowsFit * RH + 8
			local r = row(height, text, lopts)
			local l = label(r, string.lower(text), M.title, C.text, UI.F.body)
			l.Size = UDim2.new(1, -110, 0, 22)
			local countLbl = label(r, "", M.small, C.muted, UI.F.medium)
			countLbl.Size = UDim2.new(0, 100, 0, 22)
			countLbl.Position = UDim2.new(1, -100, 0, 0)
			countLbl.TextXAlignment = Enum.TextXAlignment.Right
			local top = 24
			local query = ""
			local refresh: any
			if lopts.search ~= false then
				local box = Instance.new("TextBox")
				box.Size = UDim2.new(1, 0, 0, 24)
				box.Position = UDim2.new(0, 0, 0, 24)
				box.BackgroundColor3 = C.surface
				box.BorderSizePixel = 0
				UI.setFont(box, UI.F.body)
				box.TextSize = M.value
				box.TextColor3 = C.text
				box.PlaceholderText = lopts.placeholder or "Search"
				box.PlaceholderColor3 = C.muted
				box.Text = ""
				box.ClearTextOnFocus = false
				box.TextXAlignment = Enum.TextXAlignment.Left
				box.Parent = r
				corner(box, 6)
				local bs = stroke(box, C.edge, 0)
				padding(box, 0, 8, 0, 26)
				local sic = icon(box, "search", 14)
				sic.AnchorPoint = Vector2.new(0, 0.5)
				sic.Position = UDim2.new(0, -19, 0.5, 0)
				recolourIcon(sic, C.muted)
				box.Focused:Connect(function()
					tween(bs, TW_HOVER, { Color = C.accent })
				end)
				box.FocusLost:Connect(function()
					tween(bs, TW_HOVER, { Color = C.edge })
				end)
				box:GetPropertyChangedSignal("Text"):Connect(function()
					query = string.lower(box.Text)
					if refresh then
						refresh()
					end
				end)
				top = 52
			end
			local sc = Instance.new("ScrollingFrame")
			sc.Size = UDim2.new(1, 0, 1, -top)
			sc.Position = UDim2.new(0, 0, 0, top)
			sc.BackgroundColor3 = C.side
			sc.BackgroundTransparency = 0
			sc.BorderSizePixel = 0
			sc.ScrollBarThickness = 4
			sc.ScrollBarImageColor3 = C.faint
			sc.ScrollBarImageTransparency = 0
			sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
			sc.CanvasSize = UDim2.new(0, 0, 0, 0)
			sc.ScrollingDirection = Enum.ScrollingDirection.Y
			sc.Parent = r
			corner(sc, 6)
			stroke(sc, C.edge, 0)
			vlist(sc, 2)
			padding(sc, 4, 6, 4, 4)
			local pool: { any } = {}
			local rowId: { [Instance]: string } = {}
			local lastSel: any = nil
			local function mkRow(): any
				local b = button(sc, "", M.value, C.dim, C.accent)
				b.BackgroundTransparency = 1
				b.Size = UDim2.new(1, 0, 0, RH - 2)
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.TextTruncate = Enum.TextTruncate.AtEnd
				UI.setFont(b, UI.F.body)
				corner(b, 5)
				padding(b, 0, 8, 0, 8)
				local st = stroke(b, C.accent, 1)
				local sub = label(b, "", M.small, C.muted, UI.F.medium)
				sub.Size = UDim2.new(0, 120, 1, 0)
				sub.Position = UDim2.new(1, -120, 0, 0)
				sub.TextXAlignment = Enum.TextXAlignment.Right
				local rec = { btn = b, sub = sub, stroke = st, selected = false }
				b.MouseEnter:Connect(function()
					if not rec.selected then
						tween(b, TW_HOVER, { BackgroundTransparency = 0.88 })
					end
				end)
				b.MouseLeave:Connect(function()
					if not rec.selected then
						tween(b, TW_HOVER, { BackgroundTransparency = 1 })
					end
				end)
				b.MouseButton1Click:Connect(function()
					local id = rowId[b]
					if id ~= nil and lopts.onSelect then
						local ok, err = pcall(lopts.onSelect, id)
						if not ok then
							reportError("list " .. text, err)
						end
						refresh()
					end
				end)
				return rec
			end
			local scrolledFor: any = nil
			refresh = function()
				local items = lopts.items and lopts.items() or {}
				local sel = lopts.selected and lopts.selected() or nil
				lastSel = sel
				local shown = 0
				local selIdx: number? = nil
				for _, it in ipairs(items) do
					local lab = tostring(it.label or it.id)
					if query == "" or string.find(string.lower(lab), query, 1, true) or (it.sub and string.find(string.lower(tostring(it.sub)), query, 1, true)) then
						shown += 1
						local rec = pool[shown]
						if not rec then
							rec = mkRow()
							pool[shown] = rec
						end
						local b = rec.btn
						rowId[b] = it.id
						b.Visible = true
						b.LayoutOrder = shown
						b.Text = lab
						rec.sub.Text = tostring(it.sub or "")
						rec.sub.TextColor3 = it.color or C.muted
						rec.selected = it.id == sel
						if rec.selected then
							selIdx = shown
						end
						b.TextColor3 = if rec.selected then C.text elseif it.dim then C.muted else C.dim
						b.BackgroundColor3 = C.accent
						b.BackgroundTransparency = if rec.selected then 0.82 else 1
						rec.stroke.Transparency = if rec.selected then 0.35 else 1
					end
				end
				for i = shown + 1, #pool do
					pool[i].btn.Visible = false
				end
				countLbl.Text = if shown == #items then tostring(#items) else ("%d / %d"):format(shown, #items)
				-- bring the selection into view when it changed (a weapon picked elsewhere, first build)
				if selIdx and sel ~= scrolledFor then
					scrolledFor = sel
					local visible = math.max(sc.AbsoluteWindowSize.Y, RH)
					local y = math.max(0, (selIdx - 1) * RH - visible / 2 + RH / 2)
					task.defer(function()
						if sc.Parent then
							sc.CanvasPosition = Vector2.new(0, y)
						end
					end)
				end
			end
			refresh()
			table.insert(UI.sync, function()
				local sel = lopts.selected and lopts.selected() or nil
				if sel ~= lastSel then
					refresh()
				end
			end)
			return refresh
		end

		return g
	end
-- host override point: replace S/cfg/EXEC above or mutate the returned lib.
UI._shim = { S = S, cfg = cfg, EXEC = EXEC, DATA = DATA }
function UI.attach(env)
  if type(env) ~= "table" then return UI end
  if env.S then S = env.S end
  if env.cfg then cfg = env.cfg end
  if env.EXEC then EXEC = env.EXEC end
  return UI
end

-- Window / Tab manager (standalone only, not part of the verbatim kit)
local Lib: any = {}
Lib.VERSION = "1.0.4-profilefix"
print("[cocaine-lib] " .. tostring(Lib.VERSION))
Lib.UI = UI
Lib.cfg = cfg
Lib._windows = {}
function Lib.CreateWindow(opts: any?): any
  opts = opts or {}
  local title = tostring(opts.Title or opts.title or "Cocaine")
  local C = UI.C
  if opts.Accent then
    local a: any = opts.Accent
    if typeof(a) == "Color3" then C.accent = a end
  end
  UI.applyTheme()
  local gui = Instance.new("ScreenGui")
  gui.Name = opts.GuiName or "CocaineLib"
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  local parented = pcall(function()
    local cg = game:GetService("CoreGui")
    gui.Parent = cg
  end)
  if not parented or gui.Parent == nil then
    pcall(function()
      local getHui = __gg("gethui")
      if type(getHui) == "function" then gui.Parent = getHui() return end
      gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end)
  end
  local W, H = 620, 440
  if typeof(opts.Size) == "UDim2" then
    W, H = opts.Size.X.Offset, opts.Size.Y.Offset
  end
  local root = Instance.new("Frame")
  root.Name = "Window"
  root.Size = UDim2.fromOffset(W, H)
  root.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
  root.BackgroundColor3 = C.bg
  root.BorderSizePixel = 0
  root.Active = true
  root.Draggable = true
  root.Parent = gui
  Instance.new("UICorner", root).CornerRadius = UDim.new(0, 12)
  local stroke = Instance.new("UIStroke", root)
  stroke.Color = C.hairline
  stroke.Thickness = 1
  -- titlebar
  local bar = Instance.new("Frame", root)
  bar.Name = "Titlebar"
  bar.Size = UDim2.new(1, 0, 0, 44)
  bar.BackgroundTransparency = 1
  local logo = UI.logoMark(bar, 24, 0)
  logo.Position = UDim2.fromOffset(14, 10)
  local tt = Instance.new("TextLabel", bar)
  tt.Size = UDim2.new(1, -120, 1, 0)
  tt.Position = UDim2.fromOffset(46, 0)
  tt.BackgroundTransparency = 1
  tt.FontFace = UI.BRAND_FONT
  tt.TextSize = 15
  tt.TextXAlignment = Enum.TextXAlignment.Left
  tt.TextColor3 = C.text
  tt.Text = string.lower(title)
  -- sidebar + pages
  local side = Instance.new("Frame", root)
  side.Name = "Sidebar"
  side.Position = UDim2.new(0, 12, 0, 52)
  side.Size = UDim2.new(0, 140, 1, -64)
  side.BackgroundColor3 = C.side
  side.BorderSizePixel = 0
  Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)
  local sideList = Instance.new("UIListLayout", side)
  sideList.Padding = UDim.new(0, 4)
  sideList.SortOrder = Enum.SortOrder.LayoutOrder
  local pad = Instance.new("UIPadding", side)
  pad.PaddingTop = UDim.new(0, 8)
  pad.PaddingLeft = UDim.new(0, 8)
  pad.PaddingRight = UDim.new(0, 8)
  pad.PaddingBottom = UDim.new(0, 56)
  -- profile card pinned to the sidebar foot, like the original (avatar + name + executor).
  -- NOTE: parented to root, not side — side's UIListLayout would override its anchors.
  local foot = Instance.new("Frame", root)
  foot.Name = "Profile"
  foot.Position = UDim2.new(0, 20, 1, -52)
  foot.Size = UDim2.new(0, 124, 0, 44)
  foot.BackgroundColor3 = C.surface
  foot.BackgroundTransparency = 0.35
  foot.BorderSizePixel = 0
  Instance.new("UICorner", foot).CornerRadius = UDim.new(0, 8)
  local av = Instance.new("ImageLabel", foot)
  av.Name = "Avatar"
  av.AnchorPoint = Vector2.new(0, 0.5)
  av.Position = UDim2.fromOffset(6, 22)
  av.Size = UDim2.fromOffset(32, 32)
  av.BackgroundColor3 = C.pop
  av.BackgroundTransparency = 0
  av.BorderSizePixel = 0
  Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
  local nm = Instance.new("TextLabel", foot)
  nm.Name = "Name"
  nm.Position = UDim2.new(0, 44, 0, 5)
  nm.Size = UDim2.new(1, -50, 0, 16)
  nm.BackgroundTransparency = 1
  nm.FontFace = UI.F.semibold
  nm.TextSize = 12
  nm.TextXAlignment = Enum.TextXAlignment.Left
  nm.TextTruncate = Enum.TextTruncate.AtEnd
  nm.TextColor3 = C.text
  local sub = Instance.new("TextLabel", foot)
  sub.Name = "Sub"
  sub.Position = UDim2.new(0, 44, 0, 22)
  sub.Size = UDim2.new(1, -50, 0, 14)
  sub.BackgroundTransparency = 1
  sub.FontFace = UI.F.medium
  sub.TextSize = 11
  sub.TextXAlignment = Enum.TextXAlignment.Left
  sub.TextTruncate = Enum.TextTruncate.AtEnd
  sub.TextColor3 = C.muted
  do
    local lp = game:GetService("Players").LocalPlayer
    nm.Text = if lp then lp.DisplayName else "local"
    local execName = "unknown"
    pcall(function()
      local id = __gg("identifyexecutor")
      if type(id) == "function" then execName = tostring(id()) end
    end)
    sub.Text = execName:lower() .. " · " .. tostring(Lib.VERSION)
    pcall(function()
      if lp then
        local thumb = game:GetService("Players"):GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        av.Image = thumb
      end
    end)
    local dot = Instance.new("Frame", foot)
    dot.Name = "Online"
    dot.AnchorPoint = Vector2.new(1, 1)
    dot.Position = UDim2.new(0, 34, 0, 36)
    dot.Size = UDim2.fromOffset(9, 9)
    dot.BackgroundColor3 = C.ok
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local ds = Instance.new("UIStroke", dot)
    ds.Color = C.side
    ds.Thickness = 2
  end
  local holder = Instance.new("Frame", root)
  holder.Name = "Pages"
  holder.Position = UDim2.new(0, 160, 0, 52)
  holder.Size = UDim2.new(1, -172, 1, -64)
  holder.BackgroundTransparency = 1
  UI.M.colW = holder.AbsoluteSize.X > 0 and holder.AbsoluteSize.X or 300
  local win: any = { gui = gui, root = root, side = side, holder = holder, tabs = {}, active = nil, title = title }
  function win:Tab(name: string, _icon: string?): any
    local page = Instance.new("ScrollingFrame", holder)
    page.Name = "Page_" .. tostring(name)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.faint
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local btn = Instance.new("TextButton", side)
    btn.Name = "Tab_" .. tostring(name)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = C.surface
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.FontFace = UI.F.semibold
    btn.TextSize = 13
    btn.TextColor3 = C.dim
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. string.lower(tostring(name))
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local padB = Instance.new("UIPadding", btn)
    padB.PaddingLeft = UDim.new(0, 8)
    local tab: any = { name = name, page = page, button = btn }
    function tab:Group(gtitle: string, gopts: any?)
      return UI.group(page, gtitle, gopts)
    end
    btn.MouseButton1Click:Connect(function() win:Select(name) end)
    table.insert(self.tabs, tab)
    if self.active == nil then self:Select(name) end
    return tab
  end
  function win:Select(name: string)
    self.active = name
    for _, t in ipairs(self.tabs) do
      local on = t.name == name
      t.page.Visible = on
      t.button.BackgroundTransparency = on and 0 or 1
      t.button.TextColor3 = on and C.text or C.dim
    end
  end
  function win:Toggle(visible: boolean?)
    root.Visible = if visible == nil then not root.Visible else visible == true
    S.menuOpen = root.Visible
  end
  function win:Destroy()
    S.alive = false
    pcall(function() gui:Destroy() end)
  end
  do
    local key = opts.ToggleKey or Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(input, gpe)
      if gpe then return end
      if input.KeyCode == key then win:Toggle() end
    end)
  end
  table.insert(Lib._windows, win)
  return win
end
function Lib.UnloadAll()
  for _, w in ipairs(Lib._windows) do
    pcall(function() w:Destroy() end)
  end
  table.clear(Lib._windows)
end
return Lib
