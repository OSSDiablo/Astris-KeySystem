local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/Astris-KeySystem/main/Source.luau"))()

local key = KeySystem:Show({
    Title = "Oblivion Hub",
    Subtitle = "Key system",
    Theme = "Default", -- or "Midnight", "Moss", "Ember", "Rose", "Mono", or a table of colours

    Discord = "dsc.gg/oblivionhub", -- text on the card, clicking copies DiscordLink
    DiscordLink = "https://dsc.gg/oblivionhub",
    Website = "oblivion.menu",
    WebsiteLink = "https://oblivion.menu",
    KeyLink = "https://oblivion.menu/key", -- copied by "Get a key"

    -- return true for a good key, optionally with a message
    Check = function(Key)
        return Key == "OBLIVION-DEMO", nil
    end,
    -- or skip Check and list keys: Keys = { "OBLIVION-DEMO" },

    -- Games = { [123456789] = "Game name" }, -- marks supported games; leave out to show "Universal"
    SaveKey = true, -- remember a good key so it is entered once
})

print("key ok", key)
-- load your script here
