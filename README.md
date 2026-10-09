# cocaine-ui

Standalone UI kit extracted verbatim (section 11) from [c0cain.lua v1.4.1](https://raw.githubusercontent.com/whotner/Roblox/refs/heads/main/c0cain.lua) (RIVALS / Volt), with a standalone shim. No external dependencies beyond the executor + Roblox services.

## Usage

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_uilib.lua"))()
UI.C.accent = Color3.fromRGB(173, 102, 255) -- recolor before building
local grp = UI.group(parent, "Title", "icon-name")
```

## Contents

Design tokens (`UI.C`), fonts (`UI.F`), primitives (`frame`, `stroke`, `corner`, `gradient`, `padding`, `vlist`), `UI.group` (groupbox + controls: toggles, sliders, dropdowns, buttons, labels), bind popup (`openBindPopup`, `keyState`), tooltips (`tip`), themes (`applyTheme`, `themeName`), glow/noise PNG builders, tween helpers — 136 exports.

## Host surface

Optional override: `UI.attach({ S = {...}, cfg = {...}, EXEC = {...} })`
- `S`: ui registry, edition, menuOpen, alive, ...
- `cfg`: theme, uiMode, binds, accent colors, ...
- `EXEC`: executor capabilities (request, getcustomasset, file fns). Everything degrades gracefully without them (BuilderSans fallback fonts, no asset downloads).

## Gaps (live elsewhere in the original)

Window/menu system, config persistence, global keybind dispatch, HUD/toasts — bring your own.
