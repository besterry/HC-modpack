-- Отрисовка мировых прямоугольных зон на карте (B41: top-down и isometric)

HydroMapZoneDraw = HydroMapZoneDraw or {}

local BORDER_THICKNESS = 2

local function drawQuad(panel, x1, y1, x2, y2, x3, y3, x4, y4, r, g, b, a)
	if not panel or not panel.javaObject then return end
	panel.javaObject:DrawTexture(nil, x1, y1, x2, y2, x3, y3, x4, y4, r, g, b, a)
end

local function drawEdge(panel, ax, ay, bx, by, thickness, r, g, b, a)
	local dx = bx - ax
	local dy = by - ay
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 0.001 then return end
	local nx = -dy / len * thickness * 0.5
	local ny = dx / len * thickness * 0.5
	drawQuad(panel,
		ax + nx, ay + ny,
		bx + nx, by + ny,
		bx - nx, by - ny,
		ax - nx, ay - ny,
		r, g, b, a)
end

function HydroMapZoneDraw.drawWorldZoneQuad(panel, x1, y1, x2, y2, fill, border, label)
	if not panel or not panel.mapAPI then return end

	local wx1, wx2 = math.min(x1, x2), math.max(x1, x2)
	local wy1, wy2 = math.min(y1, y2), math.max(y1, y2)
	local api = panel.mapAPI

	local c1x, c1y = api:worldToUIX(wx1, wy1), api:worldToUIY(wx1, wy1)
	local c2x, c2y = api:worldToUIX(wx2, wy1), api:worldToUIY(wx2, wy1)
	local c3x, c3y = api:worldToUIX(wx2, wy2), api:worldToUIY(wx2, wy2)
	local c4x, c4y = api:worldToUIX(wx1, wy2), api:worldToUIY(wx1, wy2)

	local minX = math.min(c1x, c2x, c3x, c4x)
	local maxX = math.max(c1x, c2x, c3x, c4x)
	local minY = math.min(c1y, c2y, c3y, c4y)
	local maxY = math.max(c1y, c2y, c3y, c4y)
	if (maxX - minX) < 0.5 or (maxY - minY) < 0.5 then return end

	drawQuad(panel, c1x, c1y, c2x, c2y, c3x, c3y, c4x, c4y, fill.r, fill.g, fill.b, fill.a)

	local br, bg, bb, ba = border.r, border.g, border.b, border.a
	drawEdge(panel, c1x, c1y, c2x, c2y, BORDER_THICKNESS, br, bg, bb, ba)
	drawEdge(panel, c2x, c2y, c3x, c3y, BORDER_THICKNESS, br, bg, bb, ba)
	drawEdge(panel, c3x, c3y, c4x, c4y, BORDER_THICKNESS, br, bg, bb, ba)
	drawEdge(panel, c4x, c4y, c1x, c1y, BORDER_THICKNESS, br, bg, bb, ba)

	if label and label ~= "" then
		panel:drawText(tostring(label), c1x + 2, c1y + 2, 1.0, 0.95, 0.9, 1.0, UIFont.Small)
	end
end
