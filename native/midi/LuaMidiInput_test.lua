local LuaMidiInput = require("native.midi.LuaMidiInput")

local test = {}

function test.all(t)
	local luamidi = {}

	local m_offset = 0
	local messages = {
		{144, 88, 1, 0},
		{128, 88, 0, 0},
		{},
		{144, 87, 1, 0},
		{128, 87, 0, 0},
		{},
		{},
	}
	local ports = {0, 0, 0, 1, 1, 1, 1}

	function luamidi.getinportcount()
		return 2
	end
	function luamidi.getMessage(port_zi)
		m_offset = m_offset + 1
		t:eq(port_zi, ports[m_offset])
		return unpack(messages[m_offset])
	end

	local events = {}

	local lmi = LuaMidiInput(luamidi)

	for port, note, status in lmi:events() do
		table.insert(events, {port, note, status})
	end

	t:eq(m_offset, 6)

	t:tdeq(events, {
		{1, 88, true},
		{1, 88, false},
		{2, 87, true},
		{2, 87, false},
	})
end

return test
