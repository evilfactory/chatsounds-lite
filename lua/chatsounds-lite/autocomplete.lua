local chatopen = false

local fonts = {}

local found = {}
local color = Color(255, 255, 255)
local highlighted = 0
local color_highlighted = Color(127, 255, 127)
local color_shadow = Color(0, 0, 0, 255)
local font = "sans-serif"
local size = 14
local shadow = 2
local margin = 0
local scroll = 0
local scroll_velocity = 0

local function create_fonts(font, size, weight, blursize)
	local main = "pretty_text_" .. size .. weight
	local blur = "pretty_text_blur_" .. size .. weight

	surface.CreateFont(
		main,
		{
			font = font,
			size = size,
			weight = weight,
			antialias	= true,
			additive		= true,
		}
	)

	surface.CreateFont(
		blur,
		{
			font = font,
			size = size,
			weight = weight,
			antialias	= true,
			blursize = blursize,
		}
	)

	return
	{
		main = main,
		blur = blur,
	} 
end

local def_color1 = Color(255, 255, 255, 255)
local def_color2 = Color(0, 0, 0, 255)

local surface_SetFont = surface.SetFont
local surface_SetTextColor = surface.SetTextColor
local surface_SetTextPos = surface.SetTextPos
local surface_DrawText = surface.DrawText

function chatsounds_DrawPrettyText(text, x, y, font, size, weight, blursize, color1, color2)
	font = font or "Arial"
	size = size or 14
	weight = weight or 0
	blursize = blursize or 1
	color1 = color1 or def_color1
	color2 = color2 or def_color2

	fonts[font] = fonts[font] or {}
	fonts[font][size] = fonts[font][size] or {}
	fonts[font][size][weight] = fonts[font][size][weight] or {}
	fonts[font][size][weight][blursize] = fonts[font][size][weight][blursize] or create_fonts(font, size, weight, blursize)

	surface_SetFont(fonts[font][size][weight][blursize].blur)
	surface_SetTextColor(color2)

	for i = 1, 5 do
		surface_SetTextPos(x, y) -- this resets for some reason after drawing
		surface_DrawText(text)
	end

	surface_SetFont(fonts[font][size][weight][blursize].main)
	surface_SetTextColor(color1)
	surface_SetTextPos(x, y)
	surface_DrawText(text)
end

local function render(x, y, w, h)

	if tabbed then
		scroll = scroll + scroll_velocity
		scroll_velocity = (scroll_velocity + (tabbed - scroll) * FrameTime() * 8) * 0.5
	end

    local max_lines = math.floor((h - 3 * margin) / size)


	local lines = math.min(#found, max_lines)

	local offset = math.min(math.max(scroll - 1 - math.ceil(max_lines / 2), 0), math.max(#found - max_lines, 0))

	for i = 1, lines do
        local id = math.floor(offset) + i

        local text = string.format("%.3d - %s", id, found[id])
		local alpha = math.max(math.min(math.sin( math.min(math.max((0.5 + (scroll - id - 0.5) / max_lines), 0), 1) * math.pi) * 255.5, 255), 0)

		surface.SetAlphaMultiplier(math.min(255, math.max(0, alpha / 255)))
		chatsounds_DrawPrettyText(text, x + margin, y + margin + offset % 1 * -size + size * (i - 1), font, size, id <= highlighted and 700 or 300, shadow, id == tabbed and color_highlighted or color, color_shadow)
		surface.SetAlphaMultiplier(1)
	end
end


hook.Add("OnChatTab", "chatsoundslite_autocomplete", function(text, peek)

end) 

hook.Add("StartChat", "chatsoundslite_autocomplete", function()
    chatopen = true
    print("startchat")
end)

hook.Add("FinishChat", "chatsoundslite_autocomplete", function()
    print("final chat")
    
    chatopen = false
end)

hook.Add("ChatTextChanged", "chatsoundslite_autocomplete", function(text, lua_tab_change)
    if text == "" then return end

    local pain = chatsoundsLite.parser:predict(text, 10)

    found = {}

    for key, value in pairs(pain) do
        table.insert(found, key)
    end
end)


hook.Add("PostRenderVGUI", "chatsoundslite_autocomplete", function()
	if chatopen then
		local x, y, w, h

		if chatgui then
			x, y = chatgui:GetPos()
			w, h = chatgui:GetSize()
			y, h = y + h, surface.ScreenHeight() - y - h
		else
			x, y = chat:GetChatBoxPos()
			w, h = 480, 180
			y, h = 0, y
		end

		render(x, y, w, h)
	end
end)

