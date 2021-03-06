Player = Class{}

require 'Animation'

local MOVE_SPEED = 120
local JUMP_VELOCITY = 400
local GRAVITY = 40

function Player:init(map)
  self.width = 16
  self.height = 20

  self.x = map.tileWidth * 10
  self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

  self.dx = 0 
  self.dy = 0
  self.map = map

  self.texture = love.graphics.newImage('graphics/blue_alien.png')
  self.frames = generateQuads(self.texture, self.width, self.height)

  self.state = 'idle'
  self.direction = 'right'

  self.animations = {
    ['idle'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1]
      },
      interval = 1
    },
    ['walking'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[9], self.frames[10], self.frames[11]
      },
      interval = 0.15
    },
    ['jumping'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[3]
      },
      interval = 1
    }
  }

  self.animation = self.animations['idle']

  self.behaviors = {

    -- add spacebar functionality to trigger jump state
    ['idle'] = function(dt)
      if love.keyboard.wasPressed('space') then
        self.dy = -JUMP_VELOCITY
        self.state = 'jumping'
        self.animation = self.animations['jumping']
      elseif love.keyboard.isDown('a') then
        self.direction = 'left'
        self.dx = -MOVE_SPEED
        self.state = 'walking'
        self.animations['walking']:restart()
        self.animation = self.animations['walking']
      elseif love.keyboard.isDown('d') then
        self.direction = 'right'
        self.dx = MOVE_SPEED
        self.state = 'walking'
        self.animations['walking']:restart()
        self.animation = self.animations['walking']
      else
        self.animation = self.animations['idle']
        self.dx = 0
      end
    end,
    ['walking'] = function(dt)
      
      -- keep track of input to switch movement while walking, or reset
      if love.keyboard.wasPressed('space') then
        self.dy = -JUMP_VELOCITY
        self.state = 'jumping'
        self.animation = self.animations['jumping']
      elseif love.keyboard.isDown('a') then
        self.dx = -MOVE_SPEED
        self.animation = self.animations['walking']
        self.direction = 'left'
      elseif love.keyboard.isDown('d') then
        self.dx = MOVE_SPEED
        self.animation = self.animations['walking']
        self.direction = 'right'
      else
        self.dx = 0
        self.state = 'idle'
        self.animation = self.animations['idle']
      end

      -- check for collisions moving left and right
      self:checkRightCollision()
      self:checkLeftCollision()

      -- check if there's a tile directly beneath us
      if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
        not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
          
          -- if so, reset velocity and position and change state
          self.state = 'jumping'
          self.animation = self.animations['jumping'] 
      end
    end,
    ['jumping'] = function(dt)
      -- break if we go below the surface
      if self.y > 300 then
        return
      end

      if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.direction = 'left'
        self.dx = -MOVE_SPEED

      elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.direction = 'right'
        self.dx = MOVE_SPEED
      end

      -- apply map's gravity before y velocity
      self.dy = self.dy + GRAVITY
      
      -- check if there's tile directly beneath us
      if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or 
        self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
        
        -- if so, reset velocity and position and change state
        self.dy = 0
        self.state = 'idle'
        self.animation = self.animations['idle']
        self.y = (self.map:tileAt(self.x, self.y + self.height)['y'] - 1) * self.map.tileHeight - self.height
      end

      -- check for collisions moving left and right
      self:checkRightCollision()
      self:checkLeftCollision()
    end
  }
end

function Player:update(dt) 
  self.behaviors[self.state](dt)
  self.animation:update(dt)

  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
  
  
  self.x = math.max(0, self.x)
  self.x = math.min(map.mapWidthPixels - self.width, self.x)


  -- if we have negative y velocity (jumping), check if we collide
  -- with any blocks above us
  if self.dy < 0 then
    if self.map:tileAt(self.x, self.y)['id'] ~= TILE_EMPTY or 
        self.map:tileAt(self.x, self.width - 1, self.y)['id'] ~= TILE_EMPTY then
      -- reset y velocity
      self.dy = 0
    end

    -- change block to diffrent block
    if self.map:tileAt(self.x, self.y)['id'] == JUMP_BLOCK then
      self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
        math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
    elseif self.map:tileAt(self.x + self.width - 1, self.y)['id'] == JUMP_BLOCK then
      self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1,
        math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
    elseif self.map:tileAt(self.x + self.width / 2, self.y)['id'] == JUMP_BLOCK then
      self.map:setTile(math.floor((self.x + self.width / 2) / self.map.tileWidth) + 1,
        math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
    end
    

  end
end

-- check two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
  if self.dx < 0 then
    -- check if there's a tile directly beneath us 
    if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or 
      self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then

        -- if so, reset velocity asnd position and chnage state
        self.dx = 0
        self.x = self.map:tileAt(self.x - 1, self.y)['x'] * self.map.tileWidth
      end
  end
end

-- check two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
  if self.dx > 0 then
    -- check if there's a tile directly beneath us
    if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
      self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

      -- if so, reset velocity and position and change state
      self.dx = 0
      self.x = (self.map:tileAt(self.x + self.width, self.y)['x'] - 1) * self.map.tileWidth - self.width
    end
  end
end


function Player:render()
  
  local scaleX

  if self.direction == 'right' then
    scaleX = 1
  else
    scaleX = -1
  end
  love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
    math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
    0, scaleX, 1, -- rotaion, sc, sy
    self.width / 2, self.height / 2) -- origin of x, origin of y
end