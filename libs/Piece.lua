--Master Game Object so all other game objects can inherit this one's attributes
local Piece = Class:extend()
Piece:implement(DrawBlock)

function Piece:new(interface,x,y,opts)
  self.interface = interface 
  self.order = 3
  piece_x, piece_y = x, y
  self.is_piece = opts.is_piece
  if self.is_piece == nil then
    self.is_piece = true
  end
  if self.is_piece then 
    grid_obj = self.interface.screen.grid
  end
  self.timer = Timer()
  self.type = "Piece"
	self.id = createRandomId()
	self.dead = false
  self.creationTime = love.timer.getTime()
	piece_size = 4 --how big a piece is on the x/y axis/ how manny elements there are in each sub-subarray
  self.input = Input()
  self.gravity_speed = 1

  if self.is_piece then
    self.input:bind("c", function()
      while self:can_piece_move_down() do 
        self:move_vertical(1)
      end
    end)
    self.input:bind("x", function() 
      if can_rotate_piece(self.shape) then 
        self.shape= rotate_piece(self.shape)
      end
      end)

      
    self.input:bind("d", function()
      if self:can_piece_move_right() then
        piece_x = piece_x + 1
      end
    end)
    self.input:bind("a", function()
      if self:can_piece_move_left() then
        piece_x = piece_x -1
      end
    end)
  end
end

function Piece:update(dt)
	timer = timer + dt
	if self.shape and self.is_piece then --the nextPiece object iherts from this object, but because it dosnt have a shape we dont need it to move
		self:move_piece_down(self.gravity_speed) --how fast should the piece move down in seconds
	end
	--only update the object if needed
	if self.timer then self.timer:update(dt) end
	--if the child object has a collider, then sync the x and y coorinates of the collider and the object
	if self.collider then piece_x,piece_y = self.collider:getPosition() end
	if self.sound then self.sound:update(dt) end
end

function Piece:draw()
  if self.shape then
    self:draw_moving_piece(self.shape)
  end
  
end

function Piece:move_vertical(y_change)
	piece_y = piece_y + y_change
end

function Piece:get_x()
	return piece_x
end

function Piece:set_x(x_to_be_set)
	piece_x = x_to_be_set
end

function Piece:get_y()
	return piece_y
end

function Piece:set_y(y_to_be_set)
	piece_y = y_to_be_set
end
function can_rotate_piece(table)
  local test_rotation  = rotate_piece(table)
  for x = 1, piece_size do
    for y =1, piece_size do
      local block_x = x+piece_x
      local block_y = y+piece_y
      if test_rotation[x][y] ~= "e" and (
        block_x < 1 or
        block_x > grid_obj:get_x_size()or
        block_y >grid_obj:get_y_size() or 
        grid_obj:get_grid_at_location(block_x,block_y) ~="e"
        )
        then
          print("Cannot rotate here")
        return false
      end
    end
  end
  return true
end

function Piece:move_piece_down(piece_gravity)
  local timer_limit = piece_gravity --how long until when the piece moves again
  if timer >= timer_limit then
    timer = timer - timer_limit
    if self:can_piece_move_down() then
      self:move_vertical(1)
    else
      self:clean()
    end 
  end
end
function rotate_piece(table)--rotates any table given by 90 degrees and returns it
  local rotated_table = {}
  for i = 1,#table[1] do
    rotated_table[i] = {}
    local cell_no = 0
    for j=#table, 1,-1 do
      cell_no = cell_no+1
      rotated_table[i][cell_no] = table[j][i]
    end
  end
  return rotated_table
end

function Piece:can_piece_move_right() -- testing each individual chell of a piece to see it it goes off grid or if there is a occupied cell net to it
  for x = 1, piece_size do
    for y = 1, piece_size do
      local cell_right_neighbor = piece_x + 1 + x --adding the x coordinate of the piece to the x coordinate of the cell +1 to refer to the cell next to the current cell
      if self.shape[x][y] ~= "e" and
        (cell_right_neighbor > grid_obj:get_x_size() or
        Piece:does_not_colide(cell_right_neighbor, y+piece_y)
        ) 
        then
          return false
      end
    end
  end
  return true
end
function Piece:can_piece_move_left() -- testing each individual chell of a piece to see it it goes off grid or if there is a occupied cell net to it
  for x = 1, piece_size do
    for y = 1, piece_size do
      local cell_left_neighbor = piece_x + (x -1) --adding the x coordinate of the piece to the x coordinate of the cell +1 to refer to the cell next to the current cell
      if self.shape[x][y] ~= "e" and
        (cell_left_neighbor < 1 or
        Piece:does_not_colide(cell_left_neighbor,y+piece_y)
        )
        then
          return  false
      end
    end
  end
  return true
end
function Piece:can_piece_move_down()--can the piece move down
  for x = 1, piece_size do
    for y = 1, piece_size do
      local cell_down_neighbor = piece_y + y + 1 --adding the x coordinate of the piece to the x coordinate of the cell +1 to refer to the cell next to the current cell
      if self.shape[x][y] ~= "e" and
        (cell_down_neighbor > grid_obj:get_y_size() or
        Piece:does_not_colide(x + piece_x,cell_down_neighbor)
        ) 
        then
          return  false
        end
    end
  end
  return true
end
function Piece:does_not_colide(x_check, y_check)
   if grid_obj:get_grid_at_location(x_check,y_check) =="e" then
    return false
   else
    print(x_check .. " ".. y_check .. " colliding")
    return true
   end
end
function Piece:add_to_grid(shape)
  for x = 1, piece_size do
    for y =1, piece_size do
      if shape[x][y] ~= "e" then 
        grid_obj:set_grid_at_location(shape[x][y],x+piece_x,y+piece_y)
      end
    end
  end
end
function Piece:draw_moving_piece(shape)--drawing the moving piece
  for x = 1, piece_size do
    for y = 1, piece_size do
        if shape[x][y] ~= "e" then
          draw_block_shortcut(shape[x][y],x+piece_x,y+piece_y,"fill")
        end
    end
  end
end
function Piece:draw_block_shortcut(block,x,y,mode)
  self:draw_block(block,x,y,mode, grid_obj:get_block_distance(), grid_obj:get_x_start(),grid_obj:get_y_start(),grid_obj:get_block_size())
end
--all the functions the piece needs to do upon dying
function Piece:clean()
  self:add_to_grid(self.shape) --add itself to the inert grid so we free the update tree
  grid_obj:check_for_completed_rows()--check for completed rows created by the new piece
  if grid_obj:is_game_over() then
      self.interface.screen:reset()
  else
    self.interface.screen:next_piece() --move on to the next piece
    self:trash() --any leftover garbagecollection
    self.dead = true --lettign the interface know that the object is now dead and can be removed from the update que
  end
end
function Piece:reset() --called when the game is reset
    self:trash()
    self.dead = true
end
--garbage collection
function Piece:trash()
	if self.timer then self.timer:destroy() end
	if self.collider then self.collider:destroy() end
  if self.sound then self.sound = nil end
  if self.input then self.input:unbindAll() end
end

function createRandomId()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

return Piece
