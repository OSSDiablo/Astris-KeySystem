-- Oblivion Hub Key System
-- local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/OblivionHub-KeySystem/main/Source.luau"))()
-- local key = KeySystem:Show({ ... }) -- yields until a valid key is entered

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

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

-- same presets as Oblivion Hub UI Library
KeySystem.Themes = {
	Default = base(rgb(150, 214, 110), rgb(14, 26, 8)),
	Mono = base(rgb(232, 234, 233), rgb(14, 15, 15)),
	Midnight = base(rgb(107, 184, 255), rgb(6, 18, 32)),
	Crimson = base(rgb(235, 64, 72), rgb(30, 6, 8)),
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

-- writes a baked base64 png to the workspace folder and returns a custom asset id
local function bake(data, path)
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
		if isfolder and makefolder and not isfolder("OblivionUI") then
			makefolder("OblivionUI")
		end
		if not (isfile and isfile(path)) then
			writefile(path, table.concat(out))
		end
		return getcustomasset(path)
	end)
	return ok and asset or nil
end

local function logo()
	return bake("@@LOGO@@", "OblivionUI/logo_@@LOGOVER@@.png")
end

-- soft shadow around a radius 14 rounded rect, so it follows the window corners
local shadowSlice = Rect.new(49, 49, 450, 450)
do
	local id = bake("@@SHADOW@@", "OblivionUI/shadow_@@SHADOWVER@@.png")
	if id then
		SHADOW, shadowSlice = id, Rect.new(60, 60, 140, 140)
	end
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

	local folder = opts.Folder or "OblivionKey"
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
		Name = "OblivionKey",
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
		SliceCenter = shadowSlice,
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

	-- brand: logo in an app-icon tile, title, subtitle
	local tile = new("Frame", {
		BackgroundColor3 = theme.Surface2,
		Position = UDim2.fromOffset(28, 28),
		Size = UDim2.fromOffset(40, 40),
		Parent = body,
	}, { corner(10), stroke(theme.Stroke) })
	new("ImageLabel", {
		BackgroundTransparency = 1,
		Image = opts.Logo or logo() or "",
		ScaleType = Enum.ScaleType.Fit,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(24, 24),
		Parent = tile,
	})
	text({
		Text = opts.Title or "Oblivion",
		FontFace = Fonts.Bold,
		TextSize = 20,
		TextColor3 = theme.Text,
		Position = UDim2.fromOffset(80, 29),
		Size = UDim2.fromOffset(240, 20),
		Parent = body,
	})
	text({
		Text = opts.Subtitle or "Key system",
		TextSize = 13,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(80, 50),
		Size = UDim2.fromOffset(240, 15),
		Parent = body,
	})

	-- key field
	text({
		Text = "License key",
		TextSize = 12,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(28, 98),
		Size = UDim2.fromOffset(200, 14),
		Parent = body,
	})
	local fieldStroke = stroke(theme.Stroke)
	local field = new("Frame", {
		BackgroundColor3 = theme.Surface,
		Position = UDim2.fromOffset(28, 118),
		Size = UDim2.fromOffset(300, 44),
		Parent = body,
	}, { corner(10), fieldStroke })
	local keyIcon = iconImage("key-round", theme.Muted, 16, UDim2.fromOffset(14, 14))
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
		Position = UDim2.fromOffset(42, 0),
		Size = UDim2.new(1, -54, 1, 0),
		Parent = field,
	})
	box.Focused:Connect(function()
		tween(fieldStroke, 0.2, { Color = theme.Accent, Transparency = 0.35 })
		tween(keyIcon, 0.2, { ImageColor3 = theme.Accent })
	end)
	box.FocusLost:Connect(function()
		tween(fieldStroke, 0.2, { Color = theme.Stroke, Transparency = 0 })
		tween(keyIcon, 0.2, { ImageColor3 = theme.Muted })
	end)

	-- buttons: icon and label centred together
	local function button(label, iconName, x, primary)
		local idle = primary and theme.Accent or theme.Surface2
		local s = stroke(primary and theme.Accent or theme.Stroke, primary and 0.5 or 0)
		local b = new("TextButton", {
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = idle,
			Position = UDim2.fromOffset(x, 174),
			Size = UDim2.fromOffset(146, 40),
			Parent = body,
		}, { corner(10), s })
		local color = primary and theme.AccentDark or theme.Text
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = b }, {
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local ic = iconImage(iconName, color, 16)
		ic.Parent = row
		local t = text({
			Text = label,
			FontFace = Fonts.Bold,
			TextSize = 14,
			TextColor3 = color,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			LayoutOrder = 1,
			Parent = row,
		})
		b.MouseEnter:Connect(function()
			if primary then
				tween(b, 0.15, { BackgroundTransparency = 0.1 })
			else
				tween(b, 0.15, { BackgroundColor3 = theme.Surface3 })
				tween(s, 0.15, { Color = theme.StrokeHover })
			end
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = idle })
			tween(s, 0.15, { Color = primary and theme.Accent or theme.Stroke })
		end)
		b.MouseButton1Down:Connect(function()
			tween(b, 0.1, { Size = UDim2.fromOffset(142, 38), Position = UDim2.fromOffset(x + 2, 175) })
		end)
		b.MouseButton1Up:Connect(function()
			tween(b, 0.15, { Size = UDim2.fromOffset(146, 40), Position = UDim2.fromOffset(x, 174) })
		end)
		return b, ic, t
	end
	local submit, submitIcon, submitText = button("Submit", "arrow-right", 28, true)
	local getKey = button("Get a key", "globe", 182, false)

	-- feedback line under the buttons
	local message = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(28, 230),
		Size = UDim2.fromOffset(300, 16),
		Parent = body,
	})
	local messageIcon = iconImage("circle-alert", theme.Muted, 14, UDim2.fromOffset(0, 1))
	messageIcon.ImageTransparency = 1
	messageIcon.Parent = message
	local messageText = text({
		Text = "",
		TextSize = 13,
		TextColor3 = theme.Muted,
		TextTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.fromOffset(280, 16),
		Parent = message,
	})

	if saving then
		iconImage("shield-check", theme.Muted, 14, UDim2.fromOffset(28, 297)).Parent = body
		text({
			Text = "Your key is saved, you only enter it once",
			TextSize = 12,
			TextColor3 = theme.Muted,
			Position = UDim2.fromOffset(48, 297),
			Size = UDim2.fromOffset(280, 14),
			Parent = body,
		})
	end

	-- right: inset info panel
	local panel = new("Frame", {
		BackgroundColor3 = theme.Surface,
		Position = UDim2.fromOffset(360, 8),
		Size = UDim2.fromOffset(232, 324),
		Parent = body,
	}, { corner(10), stroke(theme.Stroke) })
	local px, pw = 20, 192

	text({
		Text = "Detected game",
		TextSize = 12,
		TextColor3 = theme.Muted,
		Position = UDim2.fromOffset(px, 20),
		Size = UDim2.fromOffset(pw, 14),
		Parent = panel,
	})
	local card = new("Frame", {
		BackgroundColor3 = theme.Surface2,
		Position = UDim2.fromOffset(px, 40),
		Size = UDim2.fromOffset(pw, 60),
		Parent = panel,
	}, { corner(10), stroke(theme.Stroke) })
	new("ImageLabel", {
		BackgroundColor3 = theme.Surface3,
		Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(40, 40),
		Parent = card,
	}, { corner(8), stroke(theme.Stroke) })
	local gameName = text({
		Text = "Loading...",
		FontFace = Fonts.Bold,
		TextSize = 13,
		TextColor3 = theme.Text,
		Position = UDim2.fromOffset(60, 13),
		Size = UDim2.fromOffset(122, 15),
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
		Position = UDim2.fromOffset(60, 31),
		Size = UDim2.fromOffset(122, 14),
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

	local executor = "Unknown"
	pcall(function()
		executor = (identifyexecutor or getexecutorname)() or executor
	end)
	text({ Text = "Executor", TextSize = 12, TextColor3 = theme.Muted, Position = UDim2.fromOffset(px, 118), Size = UDim2.fromOffset(80, 14), Parent = panel })
	text({
		Text = executor,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.fromOffset(px + 80, 118),
		Size = UDim2.fromOffset(pw - 80, 14),
		Parent = panel,
	})
	text({ Text = "Status", TextSize = 12, TextColor3 = theme.Muted, Position = UDim2.fromOffset(px, 144), Size = UDim2.fromOffset(80, 14), Parent = panel })

	-- status pill: dot + label on a tinted rounded chip
	local pill = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromOffset(px + pw, 151),
		Size = UDim2.fromOffset(0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0.86,
		Parent = panel,
	}, {
		corner(11),
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 9) }),
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local dot = new("Frame", { Size = UDim2.fromOffset(6, 6), Parent = pill }, { corner(3) })
	local statusText = text({
		Text = "",
		FontFace = Fonts.Bold,
		TextSize = 12,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		LayoutOrder = 1,
		Parent = pill,
	})
	statusText.TextTruncate = Enum.TextTruncate.None
	local function setStatus(label, color)
		statusText.Text = label
		tween(statusText, 0.2, { TextColor3 = color })
		tween(dot, 0.2, { BackgroundColor3 = color })
		tween(pill, 0.2, { BackgroundColor3 = color })
	end
	statusText.TextColor3, dot.BackgroundColor3, pill.BackgroundColor3 = theme.Warning, theme.Warning, theme.Warning
	statusText.Text = "Key required"

	new("Frame", {
		BackgroundColor3 = theme.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(px, 176),
		Size = UDim2.fromOffset(pw, 1),
		Parent = panel,
	})

	local function link(iconName, title, sub, y)
		local s = stroke(theme.Stroke)
		local b = new("TextButton", {
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = theme.Surface2,
			Position = UDim2.fromOffset(px, y),
			Size = UDim2.fromOffset(pw, 50),
			Parent = panel,
		}, { corner(10), s })
		iconImage(iconName, theme.Accent, 16, UDim2.fromOffset(14, 17)).Parent = b
		text({
			Text = title,
			FontFace = Fonts.Bold,
			TextSize = 13,
			TextColor3 = theme.Text,
			Position = UDim2.fromOffset(42, 10),
			Size = UDim2.fromOffset(pw - 72, 15),
			Parent = b,
		})
		text({
			Text = sub,
			TextSize = 12,
			TextColor3 = theme.Muted,
			Position = UDim2.fromOffset(42, 26),
			Size = UDim2.fromOffset(pw - 72, 14),
			Parent = b,
		})
		local arrow = iconImage("arrow-up-right", theme.Muted, 14, UDim2.fromOffset(pw - 28, 18))
		arrow.Parent = b
		b.MouseEnter:Connect(function()
			tween(b, 0.15, { BackgroundColor3 = theme.Surface3 })
			tween(s, 0.15, { Color = theme.StrokeHover })
			tween(arrow, 0.15, { ImageColor3 = theme.Text, Position = UDim2.fromOffset(pw - 26, 16) })
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.15, { BackgroundColor3 = theme.Surface2 })
			tween(s, 0.15, { Color = theme.Stroke })
			tween(arrow, 0.15, { ImageColor3 = theme.Muted, Position = UDim2.fromOffset(pw - 28, 18) })
		end)
		return b
	end

	local flashId = 0
	local kinds = {
		info = { "info", theme.Muted },
		ok = { "circle-check", theme.Success },
		warn = { "circle-alert", theme.Warning },
		error = { "circle-x", theme.Error },
		copied = { "copy", theme.Accent },
	}
	local function say(msg, kind)
		flashId += 1
		local id = flashId
		local k = kinds[kind] or kinds.info
		local img, offset, rect = icon(k[1])
		messageIcon.Image, messageIcon.ImageRectOffset, messageIcon.ImageRectSize = img or "", offset or Vector2.zero, rect or Vector2.zero
		messageIcon.ImageColor3, messageText.TextColor3 = k[2], k[2]
		messageText.Text = msg
		message.Position = UDim2.fromOffset(28, 236)
		messageText.TextTransparency, messageIcon.ImageTransparency = 1, 1
		tween(message, 0.25, { Position = UDim2.fromOffset(28, 230) })
		tween(messageText, 0.25, { TextTransparency = 0 })
		tween(messageIcon, 0.25, { ImageTransparency = 0 })
		task.delay(4, function()
			if id == flashId then
				tween(messageText, 0.3, { TextTransparency = 1 })
				tween(messageIcon, 0.3, { ImageTransparency = 1 })
			end
		end)
	end

	local function copied(what, value)
		if copy(value) then
			say(what .. " copied", "copied")
		else
			say(value or "", "info")
		end
	end

	local y = 190
	if opts.Discord then
		link("message-circle", "Discord", opts.Discord, y).MouseButton1Click:Connect(function()
			copied("Discord invite", opts.DiscordLink or "https://" .. opts.Discord)
		end)
		y += 58
	end
	if opts.Website then
		link("globe", "Website", opts.Website, y).MouseButton1Click:Connect(function()
			copied("Website link", opts.WebsiteLink or "https://" .. opts.Website)
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
			say("No key link set", "error")
		end
	end)

	local function shake()
		task.spawn(function()
			for _, dx in ipairs({ 7, -6, 4, -2, 0 }) do
				tween(field, 0.05, { Position = UDim2.fromOffset(28 + dx, 118) }).Completed:Wait()
			end
		end)
		tween(fieldStroke, 0.15, { Color = theme.Error, Transparency = 0.3 })
		task.delay(0.8, function()
			if not box:IsFocused() then
				tween(fieldStroke, 0.3, { Color = theme.Stroke, Transparency = 0 })
			end
		end)
	end

	-- spinner on the submit icon while a check runs
	local spin
	local function loading(on)
		local img, offset, rect = icon(on and "loader-circle" or "arrow-right")
		submitIcon.Image, submitIcon.ImageRectOffset, submitIcon.ImageRectSize = img or "", offset or Vector2.zero, rect or Vector2.zero
		submitText.Text = on and "Checking" or "Submit"
		if spin then
			spin:Disconnect()
			spin = nil
		end
		submitIcon.Rotation = 0
		if on then
			spin = RunService.RenderStepped:Connect(function(dt)
				submitIcon.Rotation = (submitIcon.Rotation + dt * 360) % 360
			end)
		end
	end

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
			say("Paste a key first", "warn")
			shake()
			return
		end
		busy = true
		loading(true)
		setStatus("Checking", theme.Muted)
		local ok, msg = validate(opts, key)
		loading(false)
		if ok then
			setStatus("Key valid", theme.Success)
			say(msg or "Key accepted, loading", "ok")
			if saving then
				save(folder, path, key)
			end
			result = key
			task.wait(0.8)
			close()
			done:Fire()
		else
			setStatus("Key required", theme.Warning)
			say(msg or "That key is not valid", "error")
			shake()
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
	tween(shadow, 0.35, { ImageTransparency = 0.55 })
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
	pcall(delfile, (opts.Folder or "OblivionKey") .. "/" .. (opts.FileName or "key") .. ".txt")
end

return KeySystem
