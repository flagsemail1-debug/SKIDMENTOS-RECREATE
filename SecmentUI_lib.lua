--[[
	SECMENT UI — Library (Chunk 1: Foundation)
	Forked from MASTERLIB by Sussy / SFY.

	This is a LIBRARY, not a runnable script. It builds nothing on its own.
	Call SECMENT:CreateWindow({...}) from your own script (see the
	separate example file) to actually build and show a window.

	Provides: window chrome, collapsible icon sidebar, theming,
	Nebula Icon Library integration, Window:CreateHomeTab().
	Window:CreateTab() is a stub here — full tab/element builders land in Chunk 2.
]]

local SECMENT = {
	Folder = "SecmentUI",
	Options = {},
	ThemeGradient = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 39, 60)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(150, 25, 40)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 5, 6)),
	},
	MLGradient = { -- reserved for Home-tab accents only
		Color3.fromRGB(117, 164, 206), -- blue
		Color3.fromRGB(123, 201, 201), -- teal
		Color3.fromRGB(224, 138, 175), -- pink
	},
}

-- ===================== SERVICES =====================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local isStudio = RunService:IsStudio()

-- ===================== CONFIG-SAVE SURFACE (carried over from MASTERLIB) =====================
local canSaveConfig = isfile ~= nil and writefile ~= nil and readfile ~= nil and isfolder ~= nil and makefolder ~= nil
if canSaveConfig then
	if not isfolder("SecmentUI") then makefolder("SecmentUI") end
	if not isfolder("SecmentUI/Configs") then makefolder("SecmentUI/Configs") end
end
SECMENT.CanSaveConfig = canSaveConfig

-- ===================== NEBULA ICON LIBRARY =====================
local NebulaIcons
local nebulaOk, nebulaErr = pcall(function()
	NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
end)
if not nebulaOk then
	warn("[Secment UI] Nebula Icon Library failed to load, icons will be blank: " .. tostring(nebulaErr))
	NebulaIcons = { GetIcon = function() return 0 end }
end

local function GetIcon(name, source)
	if not name then return "" end
	local ok, id = pcall(function()
		return NebulaIcons:GetIcon(name, source or "Symbols")
	end)
	if ok and id and id ~= 0 then
		return "rbxassetid://" .. tostring(id)
	end
	return "rbxassetid://0"
end
SECMENT.GetIcon = GetIcon

-- ===================== UTILITIES =====================
local function Kwargify(defaults, passed)
	passed = passed or {}
	for i, v in pairs(defaults) do
		if passed[i] == nil then passed[i] = v end
	end
	return passed
end

local function Create(class, props, children)
	local inst = Instance.new(class)
	for prop, val in pairs(props or {}) do
		inst[prop] = val
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function tween(obj, props, duration, style, direction)
	local info = TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function corner(radius)
	return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8)})
end

local function stroke(color, thickness, transparency)
	return Create("UIStroke", {
		Color = color or Color3.fromRGB(38, 38, 44),
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(l, t, r, b)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or l or 0),
		PaddingRight = UDim.new(0, r or l or 0),
		PaddingBottom = UDim.new(0, b or t or l or 0),
	})
end

local Palette = {
	Background = Color3.fromRGB(18, 18, 21),
	PanelAlt   = Color3.fromRGB(23, 23, 27),
	Card       = Color3.fromRGB(27, 27, 32),
	CardHi     = Color3.fromRGB(32, 32, 39),
	Border     = Color3.fromRGB(38, 38, 44),
	BorderHi   = Color3.fromRGB(51, 51, 59),
	Text       = Color3.fromRGB(236, 235, 235),
	TextDim    = Color3.fromRGB(147, 147, 156),
	TextFaint  = Color3.fromRGB(87, 87, 95),
	Accent     = Color3.fromRGB(214, 39, 60),
	AccentDim  = Color3.fromRGB(122, 22, 34),
}
SECMENT.Palette = Palette

-- ===================== CreateWindow =====================
function SECMENT:CreateWindow(WindowSettings)
	WindowSettings = Kwargify({
		Name = "Secment UI",
		Subtitle = "",
		LogoID = nil,
	}, WindowSettings)

	local existing = (isStudio and Player:WaitForChild("PlayerGui") or CoreGui):FindFirstChild("SecmentUI")
	if existing then existing:Destroy() end

	local ScreenGui = Create("ScreenGui", {
		Name = "SecmentUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	if isStudio then
		ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	else
		local ok = pcall(function() ScreenGui.Parent = CoreGui end)
		if not ok then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
	end
	if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end

	local MainFrame = Create("CanvasGroup", {
		Name = "Window",
		Size = UDim2.fromOffset(920, 560),
		Position = UDim2.new(0.5, -460, 0.5, -280),
		BackgroundColor3 = Palette.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, {corner(16), stroke(Palette.Border, 1, 0)})
	MainFrame.Parent = ScreenGui

	MainFrame.GroupTransparency = 1
	MainFrame.Size = UDim2.fromOffset(920, 540)
	tween(MainFrame, {GroupTransparency = 0, Size = UDim2.fromOffset(920, 560)}, 0.35, Enum.EasingStyle.Quart)

	-- top gradient hairline sweep (MASTERLIB sprinkle)
	local TopLine = Create("Frame", {
		Name = "TopLine",
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 5,
	})
	TopLine.Parent = MainFrame
	local sweepGrad = Create("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0.00, Palette.Background),
			ColorSequenceKeypoint.new(0.35, SECMENT.MLGradient[1]),
			ColorSequenceKeypoint.new(0.50, Palette.Accent),
			ColorSequenceKeypoint.new(0.65, SECMENT.MLGradient[3]),
			ColorSequenceKeypoint.new(1.00, Palette.Background),
		},
	})
	sweepGrad.Parent = TopLine
	task.spawn(function()
		while TopLine.Parent do
			sweepGrad.Offset = Vector2.new(0, 0)
			TweenService:Create(sweepGrad, TweenInfo.new(6, Enum.EasingStyle.Linear), {Offset = Vector2.new(-2, 0)}):Play()
			task.wait(6)
		end
	end)

	-- title bar
	local TitleBar = Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
	})
	TitleBar.Parent = MainFrame
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Palette.Border,
		BorderSizePixel = 0,
	}).Parent = TitleBar

	local BrandMark = Create("Frame", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 18, 0.5, -14),
		BackgroundColor3 = Palette.Accent,
	}, {corner(8)})
	BrandMark.Parent = TitleBar
	Create("UIGradient", {
		Rotation = 155,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Palette.Accent),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 3, 4)),
		},
	}).Parent = BrandMark
	if WindowSettings.LogoID then
		Create("ImageLabel", {
			Size = UDim2.new(1, -8, 1, -8),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://" .. tostring(WindowSettings.LogoID),
		}).Parent = BrandMark
	end

	Create("TextLabel", {
		Size = UDim2.new(0, 300, 0, 16),
		Position = UDim2.new(0, 56, 0, 15),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = WindowSettings.Name,
		TextSize = 14,
		TextColor3 = Palette.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = TitleBar
	if WindowSettings.Subtitle ~= "" then
		Create("TextLabel", {
			Size = UDim2.new(0, 200, 0, 14),
			Position = UDim2.new(0, 56, 0, 31),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = WindowSettings.Subtitle,
			TextSize = 11,
			TextColor3 = Palette.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = TitleBar
	end

	local CloseBtn = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -44, 0.5, -14),
		BackgroundColor3 = Palette.PanelAlt,
		Text = "",
		AutoButtonColor = false,
	}, {corner(7), stroke(Palette.Border, 1)})
	CloseBtn.Parent = TitleBar
	local CloseIcon = Create("ImageLabel", {
		Size = UDim2.new(0, 13, 0, 13),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = GetIcon("x", "Lucide"),
		ImageColor3 = Palette.TextDim,
	})
	CloseIcon.Parent = CloseBtn
	CloseBtn.MouseEnter:Connect(function()
		tween(CloseBtn, {BackgroundColor3 = Palette.AccentDim}, 0.12)
		tween(CloseIcon, {ImageColor3 = Color3.fromRGB(255,255,255)}, 0.12)
	end)
	CloseBtn.MouseLeave:Connect(function()
		tween(CloseBtn, {BackgroundColor3 = Palette.PanelAlt}, 0.12)
		tween(CloseIcon, {ImageColor3 = Palette.TextDim}, 0.12)
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		local t = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
			GroupTransparency = 1,
			Size = UDim2.fromOffset(920, 500),
		})
		t:Play()
		t.Completed:Connect(function() ScreenGui.Enabled = false end)
	end)

	-- body
	local Body = Create("Frame", {
		Size = UDim2.new(1, 0, 1, -54),
		Position = UDim2.new(0, 0, 0, 54),
		BackgroundTransparency = 1,
	})
	Body.Parent = MainFrame

	-- collapsible icon sidebar
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 60, 1, 0),
		BackgroundColor3 = Palette.Background,
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 3,
	})
	Sidebar.Parent = Body
	Create("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Palette.Border,
		BorderSizePixel = 0,
	}).Parent = Sidebar

	local NavList = Create("Frame", {
		Size = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
	}, {
		Create("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}),
		padding(8, 14, 8, 0),
	})
	NavList.Parent = Sidebar

	local UserFooter = Create("Frame", {
		Size = UDim2.new(1, -16, 0, 48),
		Position = UDim2.new(0, 8, 1, -56),
		BackgroundTransparency = 1,
	})
	UserFooter.Parent = Sidebar
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Palette.Border,
		BorderSizePixel = 0,
	}).Parent = UserFooter
	local AvatarFrame = Create("Frame", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 0, 0, 10),
		BackgroundColor3 = Palette.PanelAlt,
	}, {corner(8), stroke(Palette.Border, 1)})
	AvatarFrame.Parent = UserFooter
	pcall(function()
		Create("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100),
		}, {corner(8)}).Parent = AvatarFrame
	end)
	local FooterName = Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 14),
		Position = UDim2.new(0, 40, 0, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = Player.DisplayName,
		TextSize = 12,
		TextColor3 = Palette.Text,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	FooterName.Parent = UserFooter
	local FooterHandle = Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 12),
		Position = UDim2.new(0, 40, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "@" .. Player.Name,
		TextSize = 10,
		TextColor3 = Palette.TextFaint,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	FooterHandle.Parent = UserFooter

	-- sidebar hover-expand wiring happens further below, once nav buttons exist

	-- content area
	local ContentArea = Create("Frame", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 60, 0, 0),
		BackgroundTransparency = 1,
	})
	ContentArea.Parent = Body

	local StatusBar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 1, -26),
		BackgroundTransparency = 1,
	})
	StatusBar.Parent = ContentArea
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Palette.Border,
		BorderSizePixel = 0,
	}).Parent = StatusBar
	Create("TextLabel", {
		Size = UDim2.new(0, 300, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = WindowSettings.Name,
		TextSize = 10,
		TextColor3 = Palette.TextFaint,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = StatusBar
	local LiveDot = Create("Frame", {
		Size = UDim2.new(0, 6, 0, 6),
		Position = UDim2.new(1, -80, 0.5, -3),
		BackgroundColor3 = Palette.Accent,
	}, {corner(3)})
	LiveDot.Parent = StatusBar
	task.spawn(function()
		while LiveDot.Parent do
			TweenService:Create(LiveDot, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.6}):Play()
			task.wait(1)
			TweenService:Create(LiveDot, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0}):Play()
			task.wait(1)
		end
	end)
	Create("TextLabel", {
		Size = UDim2.new(0, 60, 1, 0),
		Position = UDim2.new(1, -70, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "Connected",
		TextSize = 10,
		TextColor3 = Palette.TextFaint,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = StatusBar

	local Pages = {}
	local NavButtons = {}
	local ActivePage = nil

	local Window = {}
	Window.ScreenGui = ScreenGui
	Window.MainFrame = MainFrame
	Window.ContentArea = ContentArea

	local function GoToPage(id)
		for pid, page in pairs(Pages) do
			page.Visible = (pid == id)
		end
		for pid, nav in pairs(NavButtons) do
			local active = (pid == id)
			tween(nav.Holder, {BackgroundTransparency = active and 0 or 1}, 0.12)
			tween(nav.Stroke, {Transparency = active and 0 or 1}, 0.12)
			tween(nav.Icon, {ImageColor3 = active and Palette.Accent or Palette.TextDim}, 0.12)
			tween(nav.Label, {TextColor3 = active and Palette.Text or Palette.TextDim}, 0.12)
			tween(nav.Indicator, {BackgroundTransparency = active and 0 or 1}, 0.12)
		end
		ActivePage = id
	end
	Window.GoToPage = GoToPage

	local function RegisterNavAndPage(id, displayName, iconName, iconSource, order)
		local NavHolder = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Palette.CardHi,
			BackgroundTransparency = 1,
			LayoutOrder = order or 0,
		}, {corner(8)})
		NavHolder.Parent = NavList
		local NavStroke = stroke(Palette.BorderHi, 1, 1)
		NavStroke.Parent = NavHolder

		local Indicator = Create("Frame", {
			Size = UDim2.new(0, 3, 0.55, 0),
			Position = UDim2.new(0, -8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Palette.Accent,
			BackgroundTransparency = 1,
		}, {corner(3)})
		Indicator.Parent = NavHolder

		local NavIcon = Create("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 9, 0.5, -8),
			BackgroundTransparency = 1,
			Image = GetIcon(iconName, iconSource),
			ImageColor3 = Palette.TextDim,
		})
		NavIcon.Parent = NavHolder
		local NavLabel = Create("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 37, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = displayName,
			TextSize = 12.5,
			TextColor3 = Palette.TextDim,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		NavLabel.Parent = NavHolder

		local Btn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
		Btn.Parent = NavHolder
		Btn.MouseButton1Click:Connect(function() GoToPage(id) end)
		Btn.MouseEnter:Connect(function()
			if ActivePage ~= id then tween(NavHolder, {BackgroundTransparency = 0.4}, 0.12) end
		end)
		Btn.MouseLeave:Connect(function()
			if ActivePage ~= id then tween(NavHolder, {BackgroundTransparency = 1}, 0.12) end
		end)

		NavButtons[id] = {Holder = NavHolder, Icon = NavIcon, Label = NavLabel, Stroke = NavStroke, Indicator = Indicator}

		local Page = Create("ScrollingFrame", {
			Name = id,
			Size = UDim2.new(1, 0, 1, -26),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Palette.BorderHi,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, {
			Create("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}),
			padding(20, 18, 20, 18),
		})
		Page.Parent = ContentArea

		Pages[id] = Page
		return Page
	end
	Window.RegisterNavAndPage = RegisterNavAndPage

	local sidebarExpanded = false
	Sidebar.MouseEnter:Connect(function()
		if sidebarExpanded then return end
		sidebarExpanded = true
		tween(Sidebar, {Size = UDim2.new(0, 200, 1, 0)}, 0.2, Enum.EasingStyle.Quart)
		tween(FooterName, {TextTransparency = 0}, 0.15, Enum.EasingStyle.Quad)
		tween(FooterHandle, {TextTransparency = 0}, 0.15, Enum.EasingStyle.Quad)
		for _, nav in pairs(NavButtons) do
			tween(nav.Label, {TextTransparency = 0}, 0.15, Enum.EasingStyle.Quad)
		end
	end)
	Sidebar.MouseLeave:Connect(function()
		if not sidebarExpanded then return end
		sidebarExpanded = false
		tween(Sidebar, {Size = UDim2.new(0, 60, 1, 0)}, 0.2, Enum.EasingStyle.Quart)
		tween(FooterName, {TextTransparency = 1}, 0.12, Enum.EasingStyle.Quad)
		tween(FooterHandle, {TextTransparency = 1}, 0.12, Enum.EasingStyle.Quad)
		for _, nav in pairs(NavButtons) do
			tween(nav.Label, {TextTransparency = 1}, 0.12, Enum.EasingStyle.Quad)
		end
	end)


	-- ===================== Window:CreateHomeTab =====================
	function Window:CreateHomeTab(HomeSettings)
		HomeSettings = Kwargify({
			Changelog = {
				{Title = "v1.0 — Secment UI Foundation", Desc = "Window chrome, collapsible sidebar, Home tab, Nebula Icons integration."},
				{Title = "Forked from MASTERLIB", Desc = "Config system and core utilities carried over and re-themed."},
			},
		}, HomeSettings)

		local Page = RegisterNavAndPage("Home", "Home", "house", "Lucide", -1)

		local Hero = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 84),
			BackgroundColor3 = Palette.Card,
			LayoutOrder = 0,
		}, {corner(13), stroke(Palette.BorderHi, 1), padding(18, 0, 18, 0)})
		Hero.Parent = Page
		Create("UIGradient", {
			Rotation = 120,
			Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 0.9)},
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0.0, SECMENT.MLGradient[1]),
				ColorSequenceKeypoint.new(0.5, SECMENT.MLGradient[2]),
				ColorSequenceKeypoint.new(1.0, SECMENT.MLGradient[3]),
			},
		}).Parent = Hero

		local HeroAvatar = Create("Frame", {
			Size = UDim2.new(0, 56, 0, 56),
			Position = UDim2.new(0, 0, 0.5, -28),
			BackgroundColor3 = Palette.PanelAlt,
		}, {corner(12), stroke(SECMENT.MLGradient[2], 2, 0.75)})
		HeroAvatar.Parent = Hero
		pcall(function()
			Create("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100),
			}, {corner(12)}).Parent = HeroAvatar
		end)
		Create("TextLabel", {
			Size = UDim2.new(0, 400, 0, 20),
			Position = UDim2.new(0, 70, 0, 22),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "Hello, " .. Player.DisplayName,
			TextSize = 16,
			TextColor3 = Palette.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = Hero
		Create("TextLabel", {
			Size = UDim2.new(0, 400, 0, 16),
			Position = UDim2.new(0, 70, 0, 44),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "@" .. Player.Name .. " — Secment UI",
			TextSize = 11.5,
			TextColor3 = Palette.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = Hero

		local TileRow = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 84),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})})
		TileRow.Parent = Page

		local function makeTile(scale, mlColor, label, title, sub)
			local Tile = Create("Frame", {
				Size = UDim2.new(scale, -8, 1, 0),
				BackgroundColor3 = Palette.Card,
			}, {corner(11), stroke(Palette.BorderHi, 1), padding(14, 12, 14, 10)})
			Tile.Parent = TileRow
			Create("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = mlColor}, {corner(2)}).Parent = Tile
			Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold, Text = string.upper(label), TextSize = 9.5,
				TextColor3 = Palette.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = Tile
			Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 16), BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold, Text = title, TextSize = 13,
				TextColor3 = Palette.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			}).Parent = Tile
			Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1,
				Font = Enum.Font.Gotham, Text = sub, TextSize = 10.5,
				TextColor3 = Palette.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
			}).Parent = Tile
			return Tile
		end

		local ExecutorName = "Unknown"
		pcall(function()
			if isStudio then ExecutorName = "Studio (Debug)"
			elseif identifyexecutor then ExecutorName = identifyexecutor() end
		end)

		makeTile(0.3334, SECMENT.MLGradient[1], "Client", tostring(ExecutorName), "Your executor is running " .. WindowSettings.Name .. ".")
		makeTile(0.3334, SECMENT.MLGradient[2], "Community", "Join the Discord", "Updates, support, and shared configs.")
		makeTile(0.3332, SECMENT.MLGradient[3], "Session", "Active", "No detections this session.")


		local ChangelogCard = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 30 + (#HomeSettings.Changelog * 44)),
			BackgroundColor3 = Palette.Card,
			LayoutOrder = 2,
		}, {corner(11), stroke(Palette.BorderHi, 1)})
		ChangelogCard.Parent = Page
		Create("TextLabel", {
			Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold, Text = "Changelog", TextSize = 12,
			TextColor3 = Palette.Text, TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = ChangelogCard
		local logY = 34
		for _, entry in ipairs(HomeSettings.Changelog) do
			Create("Frame", {Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 16, 0, logY + 4), BackgroundColor3 = SECMENT.MLGradient[2]}, {corner(3)}).Parent = ChangelogCard
			Create("TextLabel", {
				Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 32, 0, logY - 2), BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold, Text = entry.Title, TextSize = 11.5,
				TextColor3 = Color3.fromRGB(225,225,228), TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = ChangelogCard
			Create("TextLabel", {
				Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 32, 0, logY + 14), BackgroundTransparency = 1,
				Font = Enum.Font.Gotham, Text = entry.Desc, TextSize = 10.5,
				TextColor3 = Palette.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = ChangelogCard
			logY += 44
		end

		GoToPage("Home")
		return Page
	end

	-- ===================== Window:CreateTab (STUB — Chunk 2) =====================
	function Window:CreateTab(TabSettings)
		TabSettings = Kwargify({Name = "Tab", Icon = "circle", ImageSource = "Lucide"}, TabSettings)
		warn("[Secment UI] Window:CreateTab('" .. TabSettings.Name .. "') called, but tab/element builders are not loaded yet (Chunk 2). This is a placeholder page only.")
		local Page = RegisterNavAndPage(TabSettings.Name, TabSettings.Name, TabSettings.Icon, TabSettings.ImageSource, 1)
		Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
			Font = Enum.Font.Gotham, Text = "This tab is a placeholder — element builders load in Chunk 2.",
			TextSize = 12, TextColor3 = Palette.TextFaint, TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = Page
		return {}
	end

	return Window
end

print("[Secment UI] Library loaded. Call SECMENT:CreateWindow({...}) to build a window.")
return SECMENT
