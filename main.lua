
require "base"
require "tree"
require "data"


function projectSetup()
  font = love.graphics.getFont()
  width  = love.graphics.getWidth()
  height = love.graphics.getHeight()
  love.graphics.setBackgroundColor(.1, .1, .1)
  newNode({nodeType = "root", effect = {lifeMax = 100}})
  table.insert(entities, tree)
end



function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then love.event.quit() end
end

function love.mousepressed(x, y, button, isTouch)
  x, y = x - .5*width, y - .5 * height
  grabID, grab = tree:getNodeAt(x, y)
end

function love.mousereleased(x, y, button, isTouch)
    x, y = x - .5*width, y - .5 * height
  if grabID and grabID == tree:getNodeAt(x, y) then
    if grab.fantom then
      table.remove(tree.possibleNewNodes, grabID)
      grab.fantom = nil
      newNode(grab)
    end
  end
  grabID, grab = nil, nil
end

addDrawFunction(
  function ()
    x, y = love.mouse.getX() - .5*width, love.mouse.getY() - .5*height
    mouseoveredID, mouseovered = tree:getNodeAt(x, y)
    if mouseovered and mouseovered.tooltip then
      love.graphics.translate(x, y)
      mouseovered:drawTooltip()
    end
  end , 9
)
