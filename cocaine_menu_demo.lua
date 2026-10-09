-- demo: 1/1 cocaine menu shell
local Lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/ImSark/cocaine-ui/main/cocaine_menu.lua?t=' .. tostring(os.time())))()

Lib.Setup({
  Brand = 'my script',
  Pages = {
    { id = 'Aim', label = 'aim', section = 'combat', subs = {
        { name = 'aim', build = function(cols, group)
            group(cols.L, 'aimbot'):toggle('aimbot', 'demo_aim', { desc = 'master switch' })
            group(cols.L, 'aimbot'):toggle('team check', 'demo_team', {})
            group(cols.L, 'aimbot'):toggle('aim anywhere', 'demo_any', {})
            group(cols.R, 'targeting'):cycle('priority', 'demo_prio', { 'closest', 'crosshair', 'lowesthp' }, {})
            group(cols.R, 'targeting'):toggle('prefer threats', 'demo_threat', {})
            group(cols.R, 'overlay'):toggle('fov circle', 'demo_fov', {})
        end } } },
    { id = 'Visuals', label = 'players', section = 'visuals', subs = {
        { name = 'esp', build = function(cols, group)
            group(cols.L, 'esp'):toggle('boxes', 'demo_box', {})
            group(cols.L, 'esp'):slider('distance', 'demo_dist', 0, 1000, 10, { unit = 'm' })
            group(cols.R, 'style'):color('accent', 'colAccent', {})
        end } } },
  },
})
