local class = require("class")
local Fraction = require("ncdk.Fraction")
local InputMode = require("ncdk.InputMode")
local Chart = require("ncdk2.Chart")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Note = require("ncdk2.notes.Note")
local Tempo = require("ncdk2.to.Tempo")
local Measure = require("ncdk2.to.Measure")
local Visual = require("ncdk2.visual.Visual")
local Expand = require("ncdk2.visual.Expand")
local Velocity = require("ncdk2.visual.Velocity")

---@class refchart.Restorer
---@operator call: refchart.Restorer
local Restorer = class()

---@param refchart refchart.RefChart
---@return ncdk2.Chart
function Restorer:restore(refchart)
	local chart = Chart()

	chart.inputMode = InputMode(refchart.inputmode)

	---@type {[string]: {[string]: ncdk2.VisualPoint[]}}
	local ps = {}

	for l_name, _layer in pairs(refchart.layers) do
		local layer = AbsoluteLayer()
		chart.layers[l_name] = layer

		---@type ncdk2.AbsolutePoint[]
		local points = {}

		for i, _p in ipairs(_layer.points) do
			local p = layer:getPoint(_p.time)
			points[i] = p
			if _p.tempo then
				p._tempo = Tempo(_p.tempo)
			end
			if _p.measure then
				p._measure = Measure(_p.measure)
			end
		end

		ps[l_name] = ps[l_name] or {}
		local vps = ps[l_name]

		for v_name, _visual in pairs(_layer.visuals) do
			vps[v_name] = vps[v_name] or {}
			local vis = vps[v_name]

			local visual = Visual()
			layer.visuals[v_name] = visual

			visual.primaryTempo = _visual.primaryTempo
			visual.tempoMultiplyTarget = _visual.tempoMultiplyTarget

			for j, _vp in ipairs(_visual.points) do
				local p = points[_vp.point]
				local vp = visual:newPoint(p)
				vis[j] = vp
				if _vp.velocity then
					vp._velocity = Velocity(unpack(_vp.velocity))
				end
				if _vp.expand then
					vp._expand = Expand(_vp.expand)
				end
			end
		end
	end

	for _, _note in ipairs(refchart.notes) do
		local vp_ref = _note.point
		local vp = ps[vp_ref.layer][vp_ref.visual][vp_ref.index]
		local note = Note(vp, _note.column, _note.type, _note.weight, _note.data)
		chart.notes:insert(note)
	end

	for _, res in ipairs(refchart.resources) do
		chart.resources:add(unpack(res))
	end

	chart:compute()

	return chart
end

return Restorer
