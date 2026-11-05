<p align="center"><img src="assets/logo.png" width="72"></p>
<h1 align="center">Oblivion Hub Key System</h1>
<p align="center">A clean key window for Roblox scripts, styled like Oblivion Hub UI Library.</p>

## 1. Load it

```lua
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/OblivionHub-KeySystem/main/Source.luau"))()
```

## 2. Show it

`Show` waits until the player enters a good key, then returns it. Put your script after it.

```lua
local key = KeySystem:Show({
    Title = "Oblivion",
    Subtitle = "Key system",
    KeyLink = "https://oblivion.menu/key",
    Check = function(Key)
        return Key == "OBLIVION-DEMO"
    end,
})

-- your script here
```

## 3. Checking keys

Pick one:

```lua
-- a function: return true for a good key, plus an optional message
Check = function(Key)
    local ok = game:HttpGet("https://your.api/check?key=" .. Key) == "valid"
    return ok, ok and "Welcome back" or "Key expired"
end,

-- or a plain list
Keys = { "KEY-ONE", "KEY-TWO" },
```

## Options

| Option | Default | What it does |
| --- | --- | --- |
| `Title` | `"Oblivion"` | Big name at the top |
| `Subtitle` | `"Key system"` | Small line under the name |
| `Logo` | Oblivion logo | Any image id |
| `Theme` | `"Default"` | `Default`, `Midnight`, `Crimson`, `Ember`, `Rose`, `Mono`, or a table of colours |
| `Check` | | Function that gets the key and returns `true` or `false` |
| `Keys` | | List of good keys, used when there is no `Check` |
| `KeyLink` | | Copied when the player presses **Get a key** (a string or a function) |
| `Discord` / `DiscordLink` | | Card text, and the link it copies |
| `Website` / `WebsiteLink` | | Card text, and the link it copies |
| `Games` | | `{ [PlaceId] = "Name" }`. Shows *Supported* or *Not in our list*. Leave out for *Universal* |
| `Placeholder` | `"Paste your key here"` | Text inside the empty key box |
| `SaveKey` | `true` | Remember a good key so it is entered once |
| `Folder` / `FileName` | `"OblivionKey"` / `"key"` | Where the key is saved |
| `OnSuccess` | | Runs with the key once it is accepted |

## Functions

```lua
KeySystem:Show(options)  -- shows the window, returns the key
KeySystem:Reset(options) -- forgets the saved key
KeySystem.Themes         -- the theme presets, edit or add your own
```

A saved key is checked again on every run, so an expired key brings the window back.

## Custom theme

```lua
KeySystem:Show({
    Theme = {
        Accent = Color3.fromRGB(170, 140, 255),
        AccentDark = Color3.fromRGB(20, 12, 40),
    },
    -- anything you leave out comes from Default
})
```

Full example in [Example.luau](Example.luau).
