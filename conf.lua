function love.conf(t)
	t.identity = nil
	t.version = "0.10.2"
	t.console = true
	t.accelerometerjoystick = true
	t.gammacorrect = false
	
	t.window.title = "soundsphere"
	t.window.icon = nil
	t.window.width = 1024
	t.window.height = 576
	t.window.borderless = false
	t.window.resizable = true
	t.window.minwidth = 1
	t.window.minheight = 1
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = false
	t.window.msaa = 0
	t.window.display = 1
	t.window.highdpi = false
	t.window.x = nil
	t.window.y = nil

	t.modules.audio = false
	t.modules.event = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = false
	t.modules.system = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = true
	t.modules.window = true
	t.modules.thread = true
end
