WINDOWS_WIDTH = 1280 * 0.75
WINDOWS_HEIGHT = 720 * 0.75

VIRTUAL_WIDTH = 432 * 0.75
VIRTUAL_HEIGHT = 243 * 0.75

Class = require 'class'
push = require 'push'

require 'Util'
require 'Map'


-- performs initialization of all objects and data needed by program
function love.load()
  
  math.randomseed(os.time())

  -- an object to contain our map data
  map = Map()

  love.graphics.setDefaultFilter('nearest', 'nearest')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOWS_WIDTH, WINDOWS_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

  love.keyboard.keysPressed = {}
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

function love.update(dt)
  map:update(dt)

  love.keyboard.keysPressed = {}
end

function love.draw()
  push:apply('start')

  love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
  love.graphics.clear(108 / 255, 140 / 255, 255 / 255, 255 / 255)
  -- love.graphics.print("Hello World")
  map:render()
  push:apply('end')
end
