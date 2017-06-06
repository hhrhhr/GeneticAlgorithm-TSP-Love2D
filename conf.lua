function love.conf(t)
    t.identity = "Salesman problem"
    t.version = "0.10.2"
    t.console = false
    t.accelerometerjoystick = false
    t.externalstorage = false
    t.gammacorrect = false

    t.window.title = "Salesman problem"
    t.window.icon = nil
    t.window.width = 920
    t.window.height = 700
    t.window.borderless = false
    t.window.resizable = false
    t.window.minwidth = 1
    t.window.minheight = 1
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop" -- "desktop" or "exclusive"
    t.window.vsync = false
    t.window.msaa = 0
    t.window.display = 1
    t.window.highdpi = false
    t.window.x = nil
    t.window.y = nil

    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
    t.modules.thread = true
end
