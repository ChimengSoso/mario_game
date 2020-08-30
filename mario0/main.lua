WINDOWS_WIDTH = 1280 * 0.75
WINDOWS_HEIGHT = 720 * 0.75

VIRTUAL_WIDTH = 432 * 0.75
VIRTUAL_HEIGHT = 243 * 0.75

Class = require 'class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()
  map = Map()

  love.graphics.setDefaultFilter('nearest', 'nearest')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOWS_WIDTH, WINDOWS_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })
end

function love.update(dt)

end

function love.draw()
  push:apply('start')
  love.graphics.clear(108 / 255, 140 / 255, 255 / 255, 255 / 255)
  -- love.graphics.print("Hello World")
  map:render()
  push:apply('end')
end

