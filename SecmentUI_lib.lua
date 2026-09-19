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
local UserInputService = game:GetService("UserInputService")
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

	local MainStroke = stroke(Palette.Border, 1, 1)
	local MainFrame = Create("CanvasGroup", {
		Name = "Window",
		Size = UDim2.fromOffset(920, 560),
		Position = UDim2.new(0.5, -460, 0.5, -280),
		BackgroundColor3 = Palette.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, {corner(16), MainStroke})
	MainFrame.Parent = ScreenGui

	MainFrame.GroupTransparency = 1
	MainFrame.Size = UDim2.fromOffset(920, 540)
	tween(MainFrame, {GroupTransparency = 0, Size = UDim2.fromOffset(920, 560)}, 0.35, Enum.EasingStyle.Quart)
	tween(MainStroke, {Transparency = 0}, 0.35, Enum.EasingStyle.Quart)

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
		tween(MainStroke, {Transparency = 1}, 0.25, Enum.EasingStyle.Quart)
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
	local tabOrderCounter = 1

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
			Position = UDim2.new(0, 14, 0.5, -8),
			BackgroundTransparency = 1,
			Image = GetIcon(iconName, iconSource),
			ImageColor3 = Palette.TextDim,
		})
		NavIcon.Parent = NavHolder		local NavLabel = Create("TextLabel", {
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
			tween(nav.Icon, {Position = UDim2.new(0, 9, 0.5, -8)}, 0.2, Enum.EasingStyle.Quart)
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
			tween(nav.Icon, {Position = UDim2.new(0, 14, 0.5, -8)}, 0.2, Enum.EasingStyle.Quart)
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

	-- ===================== Window:CreateTab (REAL) =====================
	function Window:CreateTab(TabSettings)
		TabSettings = Kwargify({
			Name = "Tab",
			Icon = "circle",
			ImageSource = "Lucide",
		}, TabSettings)

		local Page = RegisterNavAndPage(TabSettings.Name, TabSettings.Name, TabSettings.Icon, TabSettings.ImageSource, tabOrderCounter)
		tabOrderCounter += 1

		local Tab = {}
		Tab.Page = Page
		Tab.Elements = {}

		-- ---------- shared row builder ----------
		local function baseRow(parent, height)
			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, height or 48),
				BackgroundTransparency = 1,
			})
			Row.Parent = parent
			return Row
		end

		local function labelBlock(parent, name, desc, rightInset)
			local TextHolder = Create("Frame", {
				Size = UDim2.new(1, -(rightInset or 140), 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
			}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})})
			TextHolder.Parent = parent
			Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = name,
				TextSize = 12.5,
				TextColor3 = Palette.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = TextHolder
			if desc and desc ~= "" then
				Create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Text = desc,
					TextSize = 10.5,
					TextColor3 = Palette.TextFaint,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				}).Parent = TextHolder
			end
			return TextHolder
		end

		-- ===================== CreateSection =====================
		function Tab:CreateSection(Name)
			local Page = self.Page or Page
			local Card = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Palette.Card,
			}, {corner(11), stroke(Palette.BorderHi, 1)})
			Card.Parent = Page

			local Head = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
			})
			Head.Parent = Card
			Create("Frame", {
				Size = UDim2.new(0, 6, 0, 6),
				Position = UDim2.new(0, 14, 0.5, -3),
				BackgroundColor3 = Palette.Accent,
			}, {corner(3)}).Parent = Head
			Create("TextLabel", {
				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.new(0, 28, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Text = Name or "Section",
				TextSize = 12,
				TextColor3 = Palette.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = Head
			Create("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Palette.Border,
				BorderSizePixel = 0,
			}).Parent = Head

			local Body = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 36),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})
			Body.Parent = Card

			-- return a "sub-tab" that builds elements into this section's Body instead of the page
			local Section = {}
			for fnName, fn in pairs(Tab) do
				if type(fn) == "function" and fnName ~= "CreateSection" then
					Section[fnName] = function(_, ...)
						return fn(setmetatable({Page = Body}, {__index = Tab}), ...)
					end
				end
			end
			Section.Page = Body
			return Section
		end

		-- ===================== CreateLabel =====================
		function Tab:CreateLabel(LabelSettings)
			local Page = self.Page or Page
			if type(LabelSettings) == "string" then LabelSettings = {Text = LabelSettings} end
			LabelSettings = Kwargify({Text = "Label", Style = 1}, LabelSettings)

			local styles = {
				[1] = {bg = Palette.Card, text = Palette.Text, icon = "message-square", iconColor = Palette.TextDim},
				[2] = {bg = Color3.fromRGB(20, 42, 32), text = Color3.fromRGB(120, 220, 160), icon = "info", iconColor = Color3.fromRGB(120, 220, 160)},
				[3] = {bg = Color3.fromRGB(46, 24, 24), text = Color3.fromRGB(230, 140, 130), icon = "triangle-alert", iconColor = Color3.fromRGB(230, 140, 130)},
			}
			local s = styles[LabelSettings.Style] or styles[1]

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = s.bg,
			}, {corner(9), stroke(Palette.BorderHi, 1, LabelSettings.Style == 1 and 0 or 1), padding(14, 0, 14, 0)})
			Row.Parent = Page

			Create("ImageLabel", {
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new(0, 0, 0.5, -7.5),
				BackgroundTransparency = 1,
				Image = GetIcon(s.icon, "Lucide"),
				ImageColor3 = s.iconColor,
			}).Parent = Row

			local TextLbl = Create("TextLabel", {
				Size = UDim2.new(1, -26, 1, 0),
				Position = UDim2.new(0, 26, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = LabelSettings.Text,
				TextSize = 12,
				TextColor3 = s.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
			})
			TextLbl.Parent = Row

			local Element = {Instance = Row}
			function Element:Set(new)
				if new.Text then TextLbl.Text = new.Text end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		-- ===================== CreateButton =====================
		function Tab:CreateButton(ButtonSettings)
			local Page = self.Page or Page
			ButtonSettings = Kwargify({
				Name = "Button",
				Description = nil,
				Callback = function() end,
			}, ButtonSettings)

			local Row = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, ButtonSettings.Description and 48 or 40),
				BackgroundColor3 = Palette.Card,
				AutoButtonColor = false,
				Text = "",
			}, {corner(10), stroke(Palette.BorderHi, 1)})
			Row.Parent = Page

			labelBlock(Row, ButtonSettings.Name, ButtonSettings.Description, 40)

			local ArrowIcon = Create("ImageLabel", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -26, 0.5, -7),
				BackgroundTransparency = 1,
				Image = GetIcon("chevron-right", "Lucide"),
				ImageColor3 = Palette.TextFaint,
			})
			ArrowIcon.Parent = Row

			Row.MouseEnter:Connect(function() tween(Row, {BackgroundColor3 = Palette.CardHi}, 0.12) end)
			Row.MouseLeave:Connect(function() tween(Row, {BackgroundColor3 = Palette.Card}, 0.12) end)
			Row.MouseButton1Down:Connect(function() tween(ArrowIcon, {Position = UDim2.new(1, -22, 0.5, -7)}, 0.08) end)
			Row.MouseButton1Up:Connect(function() tween(ArrowIcon, {Position = UDim2.new(1, -26, 0.5, -7)}, 0.08) end)
			Row.MouseButton1Click:Connect(function()
				local ok, err = pcall(ButtonSettings.Callback)
				if not ok then warn("[Secment UI] Button '" .. ButtonSettings.Name .. "' callback error: " .. tostring(err)) end
			end)

			local Element = {Instance = Row}
			function Element:Set(new)
				if new.Callback then ButtonSettings.Callback = new.Callback end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		-- ===================== CreateToggle =====================
		function Tab:CreateToggle(ToggleSettings)
			local Page = self.Page or Page
			ToggleSettings = Kwargify({
				Name = "Toggle",
				Description = nil,
				CurrentValue = false,
				Flag = nil,
				Callback = function() end,
			}, ToggleSettings)

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, ToggleSettings.Description and 48 or 40),
				BackgroundColor3 = Palette.Card,
			}, {corner(10), stroke(Palette.BorderHi, 1)})
			Row.Parent = Page

			labelBlock(Row, ToggleSettings.Name, ToggleSettings.Description, 56)

			local state = ToggleSettings.CurrentValue

			local Switch = Create("TextButton", {
				Size = UDim2.new(0, 36, 0, 20),
				Position = UDim2.new(1, -50, 0.5, -10),
				BackgroundColor3 = state and Palette.AccentDim or Palette.PanelAlt,
				Text = "",
				AutoButtonColor = false,
			}, {corner(10), stroke(state and Palette.Accent or Palette.Border, 1)})
			Switch.Parent = Row

			local Knob = Create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
				BackgroundColor3 = state and Palette.Accent or Palette.TextFaint,
			}, {corner(7)})
			Knob.Parent = Switch

			local Element = {Instance = Row}
			local function apply(newState, fire)
				state = newState
				tween(Switch, {BackgroundColor3 = state and Palette.AccentDim or Palette.PanelAlt}, 0.15)
				Switch.UIStroke.Color = state and Palette.Accent or Palette.Border
				tween(Knob, {
					Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
					BackgroundColor3 = state and Palette.Accent or Palette.TextFaint,
				}, 0.15)
				if fire then
					local ok, err = pcall(ToggleSettings.Callback, state)
					if not ok then warn("[Secment UI] Toggle '" .. ToggleSettings.Name .. "' callback error: " .. tostring(err)) end
				end
				if ToggleSettings.Flag then
					SECMENT.Options[ToggleSettings.Flag] = Element
				end
			end
			Switch.MouseButton1Click:Connect(function() apply(not state, true) end)
			if ToggleSettings.Flag then SECMENT.Options[ToggleSettings.Flag] = Element end

			Element.Value = state
			function Element:Set(new)
				if new.Value ~= nil then apply(new.Value, false) end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		-- ===================== CreateSlider =====================
		function Tab:CreateSlider(SliderSettings)
			local Page = self.Page or Page
			SliderSettings = Kwargify({
				Name = "Slider",
				Range = {0, 100},
				Increment = 1,
				CurrentValue = 0,
				Flag = nil,
				Callback = function() end,
			}, SliderSettings)

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 56),
				BackgroundColor3 = Palette.Card,
			}, {corner(10), stroke(Palette.BorderHi, 1), padding(16, 10, 16, 10)})
			Row.Parent = Page

			Create("TextLabel", {
				Size = UDim2.new(0.6, 0, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = SliderSettings.Name,
				TextSize = 12.5,
				TextColor3 = Palette.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}).Parent = Row

			local ValueLabel = Create("TextLabel", {
				Size = UDim2.new(0.4, 0, 0, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Text = tostring(SliderSettings.CurrentValue),
				TextSize = 12,
				TextColor3 = Palette.Accent,
				TextXAlignment = Enum.TextXAlignment.Right,
			})
			ValueLabel.Parent = Row

			local Track = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 6),
				Position = UDim2.new(0, 0, 0, 28),
				BackgroundColor3 = Palette.PanelAlt,
			}, {corner(3), stroke(Palette.Border, 1)})
			Track.Parent = Row

			-- Invisible larger hit area (plain Frame — more reliable for drag than TextButton)
			local HitArea = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0, 18),
				BackgroundTransparency = 1,
				ZIndex = 5,
			})
			HitArea.Parent = Row

			local Fill = Create("Frame", {
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Palette.Accent,
			}, {corner(3)})
			Fill.Parent = Track
			local Knob = Create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -7, 0.5, -7),
				BackgroundColor3 = Palette.Accent,
				ZIndex = 6,
			}, {corner(7), stroke(Color3.fromRGB(255,255,255), 2, 0.55)})
			Knob.Parent = Fill

			local min, max = SliderSettings.Range[1], SliderSettings.Range[2]
			local increment = SliderSettings.Increment
			local value = SliderSettings.CurrentValue

			local Element = {Instance = Row}
			local dragging = false

			local function setFromValue(v, fire, instant)
				v = math.clamp(v, min, max)
				v = math.floor((v - min) / increment + 0.5) * increment + min
				v = math.clamp(v, min, max)
				value = v
				local pct = (v - min) / (max - min)
				if max == min then pct = 0 end
				if instant then
					Fill.Size = UDim2.new(pct, 0, 1, 0)
				else
					tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.15)
				end
				ValueLabel.Text = (increment % 1 == 0) and tostring(math.floor(v)) or string.format("%.2f", v)
				if fire then
					local ok, err = pcall(SliderSettings.Callback, v)
					if not ok then warn("[Secment UI] Slider '" .. SliderSettings.Name .. "' callback error: " .. tostring(err)) end
				end
				Element.Value = v
			end
			setFromValue(value, false, true)

			local function updateFromInput(inputPos)
				local rel = math.clamp((inputPos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				setFromValue(min + rel * (max - min), true, true)
			end

			HitArea.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateFromInput(input.Position)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(input.Position)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			if SliderSettings.Flag then SECMENT.Options[SliderSettings.Flag] = Element end
			function Element:Set(new)
				if new.Value then setFromValue(new.Value, false, false) end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		-- ===================== CreateBind =====================
		function Tab:CreateBind(BindSettings)
			local Page = self.Page or Page
			BindSettings = Kwargify({
				Name = "Bind",
				Description = nil,
				CurrentKeybind = "None",
				HoldToInteract = false,
				Flag = nil,
				Callback = function() end,
			}, BindSettings)

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, BindSettings.Description and 48 or 40),
				BackgroundColor3 = Palette.Card,
			}, {corner(10), stroke(Palette.BorderHi, 1)})
			Row.Parent = Page

			labelBlock(Row, BindSettings.Name, BindSettings.Description, 96)

			local BindBtn = Create("TextButton", {
				Size = UDim2.new(0, 76, 0, 26),
				Position = UDim2.new(1, -90, 0.5, -13),
				BackgroundColor3 = Palette.PanelAlt,
				AutoButtonColor = false,
				Font = Enum.Font.Gotham,
				Text = BindSettings.CurrentKeybind,
				TextSize = 11,
				TextColor3 = Palette.TextDim,
			}, {corner(7), stroke(Palette.Border, 1)})
			BindBtn.Parent = Row

			local currentKey = BindSettings.CurrentKeybind
			local listening = false
			local heldDown = false

			BindBtn.MouseButton1Click:Connect(function()
				listening = true
				BindBtn.Text = "..."
				tween(BindBtn, {BackgroundColor3 = Palette.AccentDim}, 0.1)
			end)

			local conn
			conn = UserInputService.InputBegan:Connect(function(input, gpe)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					currentKey = input.KeyCode.Name
					BindBtn.Text = currentKey
					tween(BindBtn, {BackgroundColor3 = Palette.PanelAlt}, 0.1)
					return
				end
				if gpe then return end
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey then
					if BindSettings.HoldToInteract then
						heldDown = true
						pcall(BindSettings.Callback, true)
					else
						pcall(BindSettings.Callback, true)
					end
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if BindSettings.HoldToInteract and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey and heldDown then
					heldDown = false
					pcall(BindSettings.Callback, false)
				end
			end)

			local Element = {Instance = Row, Value = currentKey}
			if BindSettings.Flag then SECMENT.Options[BindSettings.Flag] = Element end
			function Element:Set(new)
				if new.CurrentKeybind then
					currentKey = new.CurrentKeybind
					BindBtn.Text = currentKey
					Element.Value = currentKey
				end
			end
			function Element:Destroy() conn:Disconnect(); Row:Destroy() end
			return Element
		end

		-- ===================== CreateInput =====================
		function Tab:CreateInput(InputSettings)
			local Page = self.Page or Page
			InputSettings = Kwargify({
				Name = "Input",
				Description = nil,
				PlaceholderText = "...",
				CurrentValue = "",
				Numeric = false,
				MaxCharacters = nil,
				Enter = false,
				Flag = nil,
				Callback = function() end,
			}, InputSettings)

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, InputSettings.Description and 48 or 40),
				BackgroundColor3 = Palette.Card,
			}, {corner(10), stroke(Palette.BorderHi, 1)})
			Row.Parent = Page

			labelBlock(Row, InputSettings.Name, InputSettings.Description, 140)

			local Box = Create("TextBox", {
				Size = UDim2.new(0, 120, 0, 26),
				Position = UDim2.new(1, -134, 0.5, -13),
				BackgroundColor3 = Palette.PanelAlt,
				Font = Enum.Font.Gotham,
				PlaceholderText = InputSettings.PlaceholderText,
				Text = InputSettings.CurrentValue,
				TextSize = 11,
				TextColor3 = Palette.Text,
				PlaceholderColor3 = Palette.TextFaint,
				ClearTextOnFocus = false,
			}, {corner(7), stroke(Palette.Border, 1), padding(8, 0, 8, 0)})
			Box.Parent = Row

			local Element = {Instance = Row, Value = InputSettings.CurrentValue}
			local function commit()
				local text = Box.Text
				if InputSettings.Numeric then
					text = text:gsub("%D", "")
					Box.Text = text
				end
				if InputSettings.MaxCharacters and #text > InputSettings.MaxCharacters then
					text = text:sub(1, InputSettings.MaxCharacters)
					Box.Text = text
				end
				Element.Value = text
				local ok, err = pcall(InputSettings.Callback, text)
				if not ok then warn("[Secment UI] Input '" .. InputSettings.Name .. "' callback error: " .. tostring(err)) end
			end

			if InputSettings.Enter then
				Box.FocusLost:Connect(function(enterPressed)
					if enterPressed then commit() end
				end)
			else
				Box:GetPropertyChangedSignal("Text"):Connect(commit)
			end

			if InputSettings.Flag then SECMENT.Options[InputSettings.Flag] = Element end
			function Element:Set(new)
				if new.Text ~= nil then Box.Text = new.Text; Element.Value = new.Text end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		-- ===================== CreateDropdown =====================
		function Tab:CreateDropdown(DropdownSettings)
			local Page = self.Page or Page
			DropdownSettings = Kwargify({
				Name = "Dropdown",
				Description = nil,
				Options = {},
				CurrentOption = nil,
				MultipleOptions = false,
				Flag = nil,
				Callback = function() end,
			}, DropdownSettings)

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, DropdownSettings.Description and 48 or 40),
				BackgroundColor3 = Palette.Card,
				ClipsDescendants = false,
				ZIndex = 2,
			}, {corner(10), stroke(Palette.BorderHi, 1)})
			Row.Parent = Page

			labelBlock(Row, DropdownSettings.Name, DropdownSettings.Description, 170)

			local function fmtSelection(sel)
				if type(sel) == "table" then
					if #sel == 0 then return "None" end
					return table.concat(sel, ", ")
				end
				return tostring(sel or "None")
			end

			local selected = DropdownSettings.CurrentOption or (DropdownSettings.MultipleOptions and {} or DropdownSettings.Options[1])

			local SelectBtn = Create("TextButton", {
				Size = UDim2.new(0, 150, 0, 26),
				Position = UDim2.new(1, -164, 0.5, -13),
				BackgroundColor3 = Palette.PanelAlt,
				AutoButtonColor = false,
				Font = Enum.Font.Gotham,
				Text = "  " .. fmtSelection(selected),
				TextSize = 11,
				TextColor3 = Palette.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 3,
			}, {corner(7), stroke(Palette.Border, 1)})
			SelectBtn.Parent = Row
			Create("ImageLabel", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(1, -20, 0.5, -6),
				BackgroundTransparency = 1,
				Image = GetIcon("chevron-down", "Lucide"),
				ImageColor3 = Palette.TextFaint,
				ZIndex = 3,
			}).Parent = SelectBtn

			local ListHolder = Create("Frame", {
				Size = UDim2.new(0, 150, 0, math.min(#DropdownSettings.Options * 28, 140)),
				Position = UDim2.new(1, -164, 1, 2),
				BackgroundColor3 = Palette.CardHi,
				Visible = false,
				ZIndex = 10,
				ClipsDescendants = true,
			}, {corner(8), stroke(Palette.BorderHi, 1)})
			ListHolder.Parent = Row
			local ListScroll = Create("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ZIndex = 10,
			}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})
			ListScroll.Parent = ListHolder

			local Element = {Instance = Row, Value = selected}
			local open = false
			local function toggleOpen()
				open = not open
				ListHolder.Visible = open
			end
			SelectBtn.MouseButton1Click:Connect(toggleOpen)

			local optionButtons = {}
			local function isSelected(opt)
				if DropdownSettings.MultipleOptions then
					for _, v in ipairs(selected) do if v == opt then return true end end
					return false
				end
				return selected == opt
			end
			local function refreshVisual()
				SelectBtn.Text = "  " .. fmtSelection(selected)
				for opt, btn in pairs(optionButtons) do
					btn.BackgroundColor3 = isSelected(opt) and Palette.AccentDim or Palette.CardHi
					btn.TextColor3 = isSelected(opt) and Color3.fromRGB(255,255,255) or Palette.TextDim
				end
				Element.Value = selected
			end

			local function chooseOption(opt)
				if DropdownSettings.MultipleOptions then
					local found = false
					for i, v in ipairs(selected) do
						if v == opt then table.remove(selected, i); found = true; break end
					end
					if not found then table.insert(selected, opt) end
				else
					selected = opt
					open = false
					ListHolder.Visible = false
				end
				refreshVisual()
				local ok, err = pcall(DropdownSettings.Callback, selected)
				if not ok then warn("[Secment UI] Dropdown '" .. DropdownSettings.Name .. "' callback error: " .. tostring(err)) end
			end

			for _, opt in ipairs(DropdownSettings.Options) do
				local OptBtn = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = isSelected(opt) and Palette.AccentDim or Palette.CardHi,
					AutoButtonColor = false,
					Font = Enum.Font.Gotham,
					Text = "  " .. tostring(opt),
					TextSize = 11,
					TextColor3 = isSelected(opt) and Color3.fromRGB(255,255,255) or Palette.TextDim,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})
				OptBtn.Parent = ListScroll
				OptBtn.MouseButton1Click:Connect(function() chooseOption(opt) end)
				optionButtons[opt] = OptBtn
			end

			if DropdownSettings.Flag then SECMENT.Options[DropdownSettings.Flag] = Element end
			function Element:Set(new)
				if new.CurrentOption ~= nil then selected = new.CurrentOption; refreshVisual() end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		-- ===================== CreateColorPicker =====================
		function Tab:CreateColorPicker(ColorSettings)
			local Page = self.Page or Page
			ColorSettings = Kwargify({
				Name = "Color Picker",
				Color = Color3.fromRGB(214, 39, 60),
				Flag = nil,
				Callback = function() end,
			}, ColorSettings)

			local Row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Palette.Card,
			}, {corner(10), stroke(Palette.BorderHi, 1)})
			Row.Parent = Page

			labelBlock(Row, ColorSettings.Name, nil, 60)

			local Swatch = Create("TextButton", {
				Size = UDim2.new(0, 32, 0, 22),
				Position = UDim2.new(1, -46, 0.5, -11),
				BackgroundColor3 = ColorSettings.Color,
				AutoButtonColor = false,
				Text = "",
			}, {corner(6), stroke(Palette.Border, 1)})
			Swatch.Parent = Row

			-- simple inline RGB popover
			local Popover = Create("Frame", {
				Size = UDim2.new(0, 180, 0, 120),
				Position = UDim2.new(1, -196, 1, 4),
				BackgroundColor3 = Palette.CardHi,
				Visible = false,
				ZIndex = 10,
			}, {corner(9), stroke(Palette.BorderHi, 1), padding(12, 12, 12, 12)})
			Popover.Parent = Row

			local currentColor = ColorSettings.Color
			local Element = {Instance = Row, Value = currentColor}

			local sliders = {}
			local channels = {"R", "G", "B"}
			for i, ch in ipairs(channels) do
				local ChRow = Create("Frame", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, (i-1)*30), BackgroundTransparency = 1})
				ChRow.Parent = Popover
				Create("TextLabel", {
					Size = UDim2.new(0, 16, 1, 0), BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold, Text = ch, TextSize = 10,
					TextColor3 = Palette.TextDim,
				}).Parent = ChRow
				local Track = Create("Frame", {
					Size = UDim2.new(1, -22, 0, 4), Position = UDim2.new(0, 22, 0.5, -2),
					BackgroundColor3 = Palette.PanelAlt,
				}, {corner(2)})
				Track.Parent = ChRow
				local Fill = Create("Frame", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Palette.Accent}, {corner(2)})
				Fill.Parent = Track
				sliders[ch] = {Track = Track, Fill = Fill}
			end

			local function updateSwatch()
				Swatch.BackgroundColor3 = currentColor
				local ok, err = pcall(ColorSettings.Callback, currentColor)
				if not ok then warn("[Secment UI] ColorPicker '" .. ColorSettings.Name .. "' callback error: " .. tostring(err)) end
				Element.Value = currentColor
			end

			local function refreshSlidersFromColor()
				sliders.R.Fill.Size = UDim2.new(currentColor.R, 0, 1, 0)
				sliders.G.Fill.Size = UDim2.new(currentColor.G, 0, 1, 0)
				sliders.B.Fill.Size = UDim2.new(currentColor.B, 0, 1, 0)
			end
			refreshSlidersFromColor()

			for _, ch in ipairs(channels) do
				local track = sliders[ch].Track
				local fill = sliders[ch].Fill
				local dragging = false
				local function setFromInput(x)
					local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					local r, g, b = currentColor.R, currentColor.G, currentColor.B
					if ch == "R" then r = pct elseif ch == "G" then g = pct else b = pct end
					currentColor = Color3.new(r, g, b)
					updateSwatch()
				end
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						setFromInput(input.Position.X)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						setFromInput(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
			end

			Swatch.MouseButton1Click:Connect(function()
				Popover.Visible = not Popover.Visible
			end)

			if ColorSettings.Flag then SECMENT.Options[ColorSettings.Flag] = Element end
			function Element:Set(new)
				if new.Color then
					currentColor = new.Color
					refreshSlidersFromColor()
					updateSwatch()
				end
			end
			function Element:Destroy() Row:Destroy() end
			return Element
		end

		return Tab
	end


	return Window
end

print("[Secment UI] Library loaded. Call SECMENT:CreateWindow({...}) to build a window.")
return SECMENT
