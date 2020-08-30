require 'Util'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4

-- cloud tiles
CLOUD_LEFT = 6
CLOUD_RIGHT = 7

-- bush tiles
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- mushroom tiles
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- jump block
JUMP_BLOCK = 5

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

function Map:init()
  self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
  self.tileWidth = 16
  self.tileHeight = 16
  self.mapWidth = 30
  self.mapHeight = 20
  self.tiles = {}

  self.camX = 0
  self.camY = 0

  self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

  self.mapWidthPixels = self.mapWidth * self.tileWidth
  self.mapHeightPixels = self.mapHeight * self.tileHeight

  -- first, fill map with empty tiles
  for y = 1, self.mapHeight do
      for x = 1, self.mapWidth do
        self:setTile(x, y, TILE_EMPTY)
      end
  end

  -- begin generating the terrain using vertical scan lines
  local x = 1
  while x < self.mapWidth do

    -- 5% chnce to generate a cloud
    -- make sure we're 2 tiles from edge at least
    if x < self.mapWidth - 2 then
      if math.random(5) == 1 then

        -- choose a random vertical spot above where blocks/pipes generate
        local cloudStart = math.random(self.mapHeight / 2 - 6)

        self:setTile(x, cloudStart, CLOUD_LEFT)
        self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
      end
    end

    -- 5% chance to generate a mushroom
    if math.random(20) == 1 then
      -- left side of pipe
      self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
      self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

      -- creates column of tiles going to bottom of map
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end

      -- next vertical scan line
      x = x + 1

    -- 10% chance to generate bush, being sure to generate away from edge 
    elseif math.random(10) == 1 and x < self.mapWidth - 3 then
      local bushLevel = self.mapHeight / 2 - 1

      -- place bush component and then colmn of bricks
      self:setTile(x, bushLevel, BUSH_LEFT)
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end
      x = x + 1

      self:setTile(x, bushLevel, BUSH_RIGHT)
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end
      x = x + 1
    
    -- 10% chance to not generate anything, creating a gap
    elseif math.random(10) ~= 1 then

      -- creates column of tiles going to bottom of map
      for y = self.mapHeight / 2, self.mapHeight do 
        self:setTile(x, y, TILE_BRICK)
      end

      -- chance to create a block for Mario to hit
      if math.random(15) == 1 then
        self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
      end

      -- next vertical scan line
      x = x + 1
    else
      -- increment X so we skip two scanlines, creating a 2-tile g
      x = x + 2
    end
  end

end

function Map:setTile(x, y, tile)
  self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
  return self.tiles[(y - 1) * self.mapWidth + x]
end


function Map:update(dt)
  if love.keyboard.isDown('w') then
    -- up movement
    self.camY = math.floor(self.camY - dt * SCROLL_SPEED)
    self.camY = math.max(0, self.camY);
  elseif love.keyboard.isDown('a') then
    -- left movement
    self.camX = math.floor(self.camX - dt * SCROLL_SPEED)
    self.camX = math.max(0, self.camX)
  elseif love.keyboard.isDown('s') then
    -- down movement
    self.camY = math.floor(self.camY + dt * SCROLL_SPEED)
    self.camY = math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, self.camY)
  elseif love.keyboard.isDown('d') then
    -- right movement
    self.camX = math.floor(self.camX + dt * SCROLL_SPEED)
    self.camX = math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.camX)
  end
  
end

function Map:render()
  for y = 1, self.mapHeight do 
    for x = 1, self.mapWidth do
      love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], 
        (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
    end
  end
end