local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/Astris-KeySystem/main/Source.luau"))()

local key = KeySystem:Show({
    Title = "Astris",
    Subtitle = "Key system",
    Theme = "Default", -- or "Midnight", "Moss", "Ember", "Rose", "Mono", or a table of colours

    Discord = "dsc.gg/astrishub", -- text on the card, clicking copies DiscordLink
    DiscordLink = "https://dsc.gg/astrishub",
    Website = "astris.gg",
    WebsiteLink = "https://astris.gg",
    KeyLink = "https://astris.gg/key", -- copied by "Get a key"

    -- return true for a good key, optionally with a message
    Check = function(Key)
        return Key == "ASTRIS-DEMO", nil
    end,
    -- or skip Check and list keys: Keys = { "ASTRIS-DEMO" },

    -- Games = { [123456789] = "Game name" }, -- marks supported games; leave out to show "Universal"
    SaveKey = true, -- remember a good key so it is entered once
})

print("key ok", key)
-- load your script here
