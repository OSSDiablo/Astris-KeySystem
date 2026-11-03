-- Astris Key System
-- local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/Astris-KeySystem/main/Source.luau"))()
-- local key = KeySystem:Show({ ... }) -- yields until a valid key is entered

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local KeySystem = {}

local rgb = Color3.fromRGB
local function base(accent, dark)
	return {
		Background = rgb(11, 12, 14),
		Surface = rgb(16, 17, 20),
		Surface2 = rgb(21, 23, 26),
		Surface3 = rgb(33, 36, 41),
		Stroke = rgb(34, 37, 42),
		StrokeHover = rgb(58, 63, 70),
		Text = rgb(236, 238, 241),
		Muted = rgb(138, 144, 153),
		Accent = accent,
		AccentDark = dark,
		Warning = rgb(244, 184, 96),
		Success = rgb(95, 211, 141),
		Error = rgb(255, 107, 107),
	}
end

-- same presets as Astris UI
KeySystem.Themes = {
	Default = base(rgb(62, 196, 130), rgb(5, 24, 14)),
	Mono = base(rgb(232, 234, 233), rgb(14, 15, 15)),
	Midnight = base(rgb(107, 184, 255), rgb(6, 18, 32)),
	Moss = base(rgb(150, 214, 110), rgb(14, 26, 8)),
	Ember = base(rgb(255, 178, 26), rgb(30, 18, 0)),
	Rose = base(rgb(255, 120, 150), rgb(32, 8, 14)),
}

local FONT = "rbxasset://fonts/families/BuilderSans.json"
local Fonts = {
	Regular = Font.new(FONT, Enum.FontWeight.Regular),
	Medium = Font.new(FONT, Enum.FontWeight.Medium),
	Bold = Font.new(FONT, Enum.FontWeight.SemiBold),
}

local SHADOW = "rbxassetid://6014261993"

local function logo()
	local data = "@@LOGO@@"
	local ok, asset = pcall(function()
		if not (writefile and getcustomasset) then
			return nil
		end
		local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		local map = {}
		for i = 1, 64 do
			map[chars:byte(i)] = i - 1
		end
		local out = table.create(#data // 4)
		for i = 1, #data, 4 do
			local a, b, c, d = data:byte(i, i + 3)
			local v = map[a] * 262144 + map[b] * 4096 + (map[c] or 0) * 64 + (map[d] or 0)
			if not map[c] then
				out[#out + 1] = string.char(v // 65536)
			elseif not map[d] then
				out[#out + 1] = string.char(v // 65536, v // 256 % 256)
			else
				out[#out + 1] = string.char(v // 65536, v // 256 % 256, v % 256)
			end
		end
		if isfolder and makefolder and not isfolder("AstrisUI") then
			makefolder("AstrisUI")
		end
		local path = "AstrisUI/logo_@@LOGOVER@@.png"
		if not (isfile and isfile(path)) then
			writefile(path, table.concat(out))
		end
		return getcustomasset(path)
	end)
	return ok and asset or nil
end

local icons
local function icon(name)
	if icons == nil then
		local ok, lib = pcall(function()
			return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
		end)
		icons = ok and type(lib) == "table" and lib or false
	end
	if not icons then
		return nil
	end
	local i = icons.Icons and icons.Icons[name] or icons[name]
	if type(i) == "string" then
		return i
	elseif type(i) ~= "table" then
		return nil
	end
	local img = i.Image
	if type(img) == "number" then
		img = "rbxassetid://" .. img
	end
	return icons.Spritesheets and icons.Spritesheets[tostring(img)] or img, i.ImageRectPosition, i.ImageRectSize
end

local function new(class, props, kids)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			o[k] = v
		end
	end
	for _, k in ipairs(kids or {}) do
		k.Parent = o
	end
	if props.Parent then
		o.Parent = props.Parent
	end
	return o
end

local function corner(r)
	return new("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function stroke(color, t)
	local s = new("UIStroke", { Color = color, Transparency = t or 0, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	pcall(function()
		s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end)
	return s
end

local function tween(o, t, props)
	local tw = TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function text(props)
	props.BackgroundTransparency = 1
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.FontFace = props.FontFace or Fonts.Medium
	props.TextTruncate = Enum.TextTruncate.AtEnd
	return new("TextLabel", props)
end

local function iconImage(name, color, size, pos)
	local img, offset, rect = icon(name)
	return new("ImageLabel", {
		BackgroundTransparency = 1,
		Image = img or "",
		ImageRectOffset = offset or Vector2.zero,
		ImageRectSize = rect or Vector2.zero,
		ImageColor3 = color,
		Size = UDim2.fromOffset(size, size),
		Position = pos,
	})
end

local function parent()
	local ok, h = pcall(function()
		return gethui and gethui()
	end)
	if ok and h then
		return h
	end
	ok, h = pcall(function()
		return game:GetService("CoreGui")
	end)
	return ok and h or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function copy(s)
	if setclipboard and s then
		pcall(setclipboard, s)
		return true
	end
	return false
end

local function readSaved(path)
	local ok, v = pcall(function()
		return isfile and isfile(path) and readfile(path)
	end)
	return ok and type(v) == "string" and v ~= "" and v or nil
end

local function save(folder, path, key)
	pcall(function()
		if isfolder and makefolder and not isfolder(folder) then
			makefolder(folder)
		end
		writefile(path, key)
	end)
end

-- runs the check, accepts true/false, (bool, message) or a table of keys
local function validate(opts, key)
	if type(opts.Check) == "function" then
		local ok, valid, msg = pcall(opts.Check, key)
		if not ok then
			return false, "Could not check the key"
		end
		return valid == true, msg
	end
	if type(opts.Keys) == "table" then
		for _, k in ipairs(opts.Keys) do
			if k == key then
				return true
			end
		end
	end
	return false
end

function KeySystem:Show(opts)
	opts = opts or {}
	local theme = type(opts.Theme) == "table" and opts.Theme or self.Themes[opts.Theme or "Default"] or self.Themes.Default
	for k, v in pairs(self.Themes.Default) do
		if theme[k] == nil then
			theme[k] = v
		end
	end

	local folder = opts.Folder or "AstrisKey"
	local path = folder .. "/" .. (opts.FileName or "key") .. ".txt"
	local saving = opts.SaveKey ~= false

	if saving then
		local saved = readSaved(path)
		if saved and validate(opts, saved) then
			if opts.OnSuccess then
				task.spawn(opts.OnSuccess, saved)
			end
			return saved
		end
	end

	local done = Instance.new("BindableEvent")
	local result

	local gui = new("ScreenGui", {
		Name = "AstrisKey",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local root = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(600, 340),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	local scale = new("UIScale", { Scale = 0.96, Parent = root })

	local shadow = new("ImageLabel", {
		BackgroundTransparency = 1,
		Image = SHADOW,
		ImageColor3 = rgb(0, 0, 0),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Position = UDim2.fromOffset(-25, -25),
		Size = UDim2.new(1, 50, 1, 50),
		Parent = root,
	})

	local body = new("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Background,
		GroupTransparency = 1,
		Parent = root,
	}, { corner(14), stroke(theme.Stroke) })

	-- left: brand, key field, actions
	local logoImg = opts.Logo or logo()
	new("ImageLabel", {
		BackgroundTransparency = 1,
		Image = logoImg or "",
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromOffset(28, 26),
		Size = UDim2.fromOffset(40, 40),
		Parent = body,
	})
	text({
		Text = opts.Title or "Astris",
		FontFace = Fonts.Bold,
		TextSize = 22,
		TextColor3 = theme.Text,
		Position = UDim2.fromOffset(80, 27),
		Size = UDim2.fromOffset(240, 24),
		Parent = body,
	})
	text({
		Text = opts.Subtitle or "Key system",
		TextSize = 13,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(80, 51),
		Size = UDim2.fromOffset(240, 14),
		Parent = body,
	})

	text({
		Text = "License key",
		TextSize = 12,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(28, 100),
		Size = UDim2.fromOffset(200, 14),
		Parent = body,
	})
	local fieldStroke = stroke(theme.Stroke)
	local field = new("Frame", {
		BackgroundColor3 = theme.Surface,
		Position = UDim2.fromOffset(28, 120),
		Size = UDim2.fromOffset(300, 40),
		Parent = body,
	}, { corner(10), fieldStroke })
	local keyIcon = iconImage("key-round", theme.Muted, 16, UDim2.fromOffset(13, 12))
	keyIcon.Parent = field
	local box = new("TextBox", {
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Text = "",
		PlaceholderText = opts.Placeholder or "Paste your key here",
		PlaceholderColor3 = theme.Muted,
		TextColor3 = theme.Text,
		FontFace = Fonts.Medium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -52, 1, 0),
		Parent = field,
	})
	box.Focused:Connect(function()
		tween(fieldStroke, 0.2, { Color = theme.Accent, Transparency = 0.4 })
		tween(keyIcon, 0.2, { ImageColor3 = theme.Accent })
	end)
	box.FocusLost:Connect(function()
		tween(fieldStroke, 0.2, { Color = theme.Stroke, Transparency = 0 })
		tween(keyIcon, 0.2, { ImageColor3 = theme.Muted })
	end)

	local function button(label, iconName, x, primary)
		local s = stroke(primary and theme.Accent or theme.Stroke, primary and 0.6 or 0)
		local b = new("TextButton", {
			AutoButtonColor = false,
			Text = label,
			FontFace = Fonts.Bold,
			TextSize = 14,
			TextColor3 = primary and theme.AccentDark or theme.Text,
			BackgroundColor3 = primary and theme.Accent or theme.Surface2,
			Position = UDim2.fromOffset(x, 176),
			Size = UDim2.fromOffset(144, 38),
			Parent = body,
		}, { corner(10), s, new("UIPadding", { PaddingLeft = UDim.new(0, 24) }) })
		local ic = iconImage(iconName, b.TextColor3, 16, UDim2.fromOffset(-12, 11))
		ic.Parent = b
		b.MouseEnter:Connect(function()
			if primary then
				tween(b, 0.15, { BackgroundTransparency = 0.12 })
			else
				tween(b, 0.15, { BackgroundColor3 = theme.Surface3 })
				tween(s, 0.15, { Color = theme.StrokeHover })
			end
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = primary and theme.Accent or theme.Surface2 })
			tween(s, 0.15, { Color = primary and theme.Accent or theme.Stroke })
		end)
		return b
	end
	local submit = button("Submit", "arrow-right", 28, true)
	local getKey = button("Get a key", "globe", 184, false)

	local message = text({
		Text = "",
		TextSize = 13,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(28, 232),
		Size = UDim2.fromOffset(300, 16),
		Parent = body,
	})
	text({
		Text = saving and "Your key is saved, you only enter it once" or "",
		TextSize = 12,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(28, 296),
		Size = UDim2.fromOffset(300, 14),
		Parent = body,
	})

	-- right: inset info panel
	local panel = new("Frame", {
		BackgroundColor3 = theme.Surface,
		Position = UDim2.fromOffset(360, 8),
		Size = UDim2.fromOffset(232, 324),
		Parent = body,
	}, { corner(10), stroke(theme.Stroke) })
	local px = 22

	text({
		Text = "Detected game",
		TextSize = 12,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(px, 22),
		Size = UDim2.fromOffset(188, 14),
		Parent = panel,
	})
	local card = new("Frame", {
		BackgroundColor3 = theme.Surface2,
		Position = UDim2.fromOffset(px, 42),
		Size = UDim2.fromOffset(188, 60),
		Parent = panel,
	}, { corner(10), stroke(theme.Stroke) })
	new("ImageLabel", {
		BackgroundColor3 = theme.Surface3,
		Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
		Position = UDim2.fromOffset(11, 11),
		Size = UDim2.fromOffset(38, 38),
		Parent = card,
	}, { corner(8), stroke(theme.Stroke) })
	local gameName = text({
		Text = "Loading...",
		TextSize = 13,
		TextColor3 = theme.Text,
		Position = UDim2.fromOffset(58, 15),
		Size = UDim2.fromOffset(122, 14),
		Parent = card,
	})
	local supported
	if type(opts.Games) == "table" then
		supported = opts.Games[game.PlaceId] ~= nil or opts.Games[game.GameId] ~= nil
	end
	text({
		Text = supported == nil and "Universal" or supported and "Supported" or "Not in our list",
		TextSize = 12,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(58, 32),
		Size = UDim2.fromOffset(122, 13),
		Parent = card,
	})
	task.spawn(function()
		local name = type(opts.Games) == "table" and (opts.Games[game.PlaceId] or opts.Games[game.GameId])
		if type(name) ~= "string" then
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
			name = ok and info and info.Name or "Unknown game"
		end
		gameName.Text = name
	end)

	local function row(label, value, y, color)
		text({
			Text = label,
			TextSize = 12,
			TextColor3 = theme.Muted,
			Position = UDim2.fromOffset(px, y),
			Size = UDim2.fromOffset(90, 14),
			Parent = panel,
		})
		return text({
			Text = value,
			TextSize = 12,
			TextColor3 = color or theme.Text,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.fromOffset(px + 92, y),
			Size = UDim2.fromOffset(96, 14),
			Parent = panel,
		})
	end
	local executor = "Unknown"
	pcall(function()
		executor = (identifyexecutor or getexecutorname)() or executor
	end)
	row("Executor", executor, 118)
	local status = row("Status", "Key required", 140, theme.Warning)

	new("Frame", {
		BackgroundColor3 = theme.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(px, 168),
		Size = UDim2.fromOffset(188, 1),
		Parent = panel,
	})

	local function link(iconName, title, sub, y, url)
		local s = stroke(theme.Stroke)
		local b = new("TextButton", {
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = theme.Surface2,
			Position = UDim2.fromOffset(px, y),
			Size = UDim2.fromOffset(188, 48),
			Parent = panel,
		}, { corner(10), s })
		iconImage(iconName, theme.Accent, 16, UDim2.fromOffset(14, 16)).Parent = b
		text({
			Text = title,
			FontFace = Fonts.Bold,
			TextSize = 13,
			TextColor3 = theme.Text,
			Position = UDim2.fromOffset(42, 9),
			Size = UDim2.fromOffset(136, 15),
			Parent = b,
		})
		text({
			Text = sub,
			TextSize = 12,
			TextColor3 = theme.Muted,
			Position = UDim2.fromOffset(42, 25),
			Size = UDim2.fromOffset(136, 14),
			Parent = b,
		})
		b.MouseEnter:Connect(function()
			tween(b, 0.15, { BackgroundColor3 = theme.Surface3 })
			tween(s, 0.15, { Color = theme.StrokeHover })
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.15, { BackgroundColor3 = theme.Surface2 })
			tween(s, 0.15, { Color = theme.Stroke })
		end)
		return b
	end

	local flashId = 0
	local function say(msg, color)
		flashId += 1
		local id = flashId
		message.Text = msg
		message.TextColor3 = color or theme.Muted
		message.TextTransparency = 1
		tween(message, 0.2, { TextTransparency = 0 })
		task.delay(4, function()
			if id == flashId then
				tween(message, 0.3, { TextTransparency = 1 })
			end
		end)
	end

	local function copied(what, value)
		if copy(value) then
			say(what .. " copied to clipboard", theme.Accent)
		else
			say(value or "", theme.Muted)
		end
	end

	local y = 182
	local discord, website = opts.Discord, opts.Website
	if discord then
		link("message-circle", "Discord", discord, y, opts.DiscordLink).MouseButton1Click:Connect(function()
			copied("Discord invite", opts.DiscordLink or "https://" .. discord)
		end)
		y += 56
	end
	if website then
		link("globe", "Website", website, y, opts.WebsiteLink).MouseButton1Click:Connect(function()
			copied("Website link", opts.WebsiteLink or "https://" .. website)
		end)
	end

	getKey.MouseButton1Click:Connect(function()
		local url = opts.KeyLink
		if type(url) == "function" then
			url = url()
		end
		if url then
			copied("Key link", url)
		else
			say("No key link set", theme.Error)
		end
	end)

	local busy = false
	local function close()
		tween(scale, 0.25, { Scale = 0.96 })
		tween(shadow, 0.25, { ImageTransparency = 1 })
		tween(body, 0.25, { GroupTransparency = 1 }).Completed:Wait()
		gui:Destroy()
	end

	local function attempt()
		if busy then
			return
		end
		local key = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if key == "" then
			say("Paste a key first", theme.Warning)
			return
		end
		busy = true
		status.Text = "Checking"
		status.TextColor3 = theme.Muted
		local ok, msg = validate(opts, key)
		if ok then
			status.Text = "Key valid"
			status.TextColor3 = theme.Success
			say(msg or "Key accepted, loading", theme.Success)
			if saving then
				save(folder, path, key)
			end
			result = key
			task.wait(0.7)
			close()
			done:Fire()
		else
			status.Text = "Key required"
			status.TextColor3 = theme.Warning
			say(msg or "That key is not valid", theme.Error)
			busy = false
		end
	end
	submit.MouseButton1Click:Connect(attempt)
	box.FocusLost:Connect(function(enter)
		if enter then
			attempt()
		end
	end)

	gui.Parent = parent()
	tween(scale, 0.35, { Scale = 1 })
	tween(shadow, 0.35, { ImageTransparency = 0.6 })
	tween(body, 0.35, { GroupTransparency = 0 })

	done.Event:Wait()
	done:Destroy()
	if opts.OnSuccess then
		task.spawn(opts.OnSuccess, result)
	end
	return result
end

-- forget the saved key, so the window shows again next time
function KeySystem:Reset(opts)
	opts = opts or {}
	pcall(delfile, (opts.Folder or "AstrisKey") .. "/" .. (opts.FileName or "key") .. ".txt")
end

return KeySystem
