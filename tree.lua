
local maxLinkLenght = function(n1, n2)
  return (n1.size + n2.size)*2
end

tooltipDX = 15
tooltipDY = 15
function newNode(params)
  params = params or {}
  node = applyParams({
    x=0, y=0, size = 30, text = "base node text", s = {x=0, y=0}, f={x=0, y=0},
    tooltip = {w = 300, h = 300, backgroundColor = {.3, .3, .3}, textColor = {1, 1, 1}},
    drawTooltip = function (self)
      love.graphics.setColor(self.tooltip.backgroundColor)
      love.graphics.rectangle("fill", 0, 0, self.tooltip.w, self.tooltip.h)
      love.graphics.setColor(self.tooltip.textColor)
      love.graphics.translate(tooltipDX, tooltipDY)
      for p, prop in pairs(self) do
        if p ~= "drawTooltip" and p ~= "tooltip" then
          if type(prop) == "string" then
            love.graphics.print(p..": "..prop)
            love.graphics.translate(0, tooltipDY)
          end
          if type(prop) == "function" then
            love.graphics.print(p.."()")
            love.graphics.translate(0, tooltipDY)
          end
          if type(prop) == "table" then
            love.graphics.print(p.."{")
            love.graphics.translate(0, tooltipDY)
            love.graphics.translate(tooltipDX, 0)
            for p2, prop2 in pairs(prop) do
              love.graphics.print(p2.."= "..prop2)
              love.graphics.translate(0, tooltipDY)
            end
            love.graphics.translate(-tooltipDX, 0)
            love.graphics.print("}")
            love.graphics.translate(0, tooltipDY)
          end
        end
      end
    end
  }, params)
  tree:insertNode(node)
  if node.parent then
    table.insert(tree.links, {node.parent, #tree.nodes})
    local parent = tree.nodes[node.parent]
    if (not node.x or node.x == 0) and (not node.y or node.y == 0) then
      local angle = 2*math.pi*math.random()
      local distance = maxLinkLenght(node, parent)
      node.x = parent.x + distance*math.cos(angle)
      node.y = parent.y +distance*math.sin(angle)
    end
  end

  return node
end

tree = {
  x = 0, y = 0,
  nodes = {},
  possibleNewNodes = {},
  links = {},
  insertNode = function (self, node)
    table.insert(self.nodes, node)
    self:addNewPossibleNodes(node, #self.nodes)
  end,
  update = function (self, dt)
    for n1, node1 in pairs(self.nodes) do
      for n2, node2 in pairs(self.nodes) do
        if n1 ~= n2 then
          local dist = math.dist(node1.x, node1.y, node2.x, node2.y)
          local dx = node2.x - node1.x
          local dy = node2.y - node1.y
          if dist < (node1.size + node2.size)*3 then
            node1.f.x = node1.f.x - dx
            node1.f.y = node1.f.y - dy
          end
          if (node1.parent == n2 or node2.parent == n1) then
            local maxDist = maxLinkLenght(node1, node2)
            if dist > maxDist then
              if n1 ~= 1 then
                node1.f.x = node1.f.x + (dist - maxDist)*dx
                node1.f.y = node1.f.y + (dist - maxDist)*dy
              end
            end
          end
        end
      end
    end
    for n, node in pairs(self.nodes) do
      if grab ~= node and n ~= 1 then
        node.s.x, node.s.y = node.s.x * .999 + dt*.1 * node.f.x, node.s.y* .999 + dt*.1 * node.f.y
        -- if node.x < 0 then node.s.x = -node.s.x end
        -- if node.y < 0 then node.s.y = -node.s.y end
        -- if node.x > width then node.s.x = -node.s.x end
        -- if node.y > height then node.s.y = -node.s.y end
        node.x = node.x + dt * node.s.x
        node.y = node.y + dt * node.s.y
      end
      node.f = {x=0, y=0}
    end
  end,
  draw = function (self)
    love.graphics.setColor(0.8, 0.8, 0.8)
    for l, link in pairs(self.links) do
      n1, n2 = self.nodes[link[1]], self.nodes[link[2]]
      -- if maxLinkLenght(n1, n2)>math.dist(n1.x, n1.y, n2.x, n2.y) then
      --   love.graphics.setColor(0, 1, 0)
      -- else
      --   love.graphics.setColor(1, 0, 0)
      -- end
      love.graphics.line(n1.x, n1.y, n2.x, n2.y)
    end
    for n, node in pairs(self.nodes) do
      love.graphics.push()
      love.graphics.translate(node.x, node.y)
      love.graphics.setColor(.6, .6, .6)
      if node == grab then love.graphics.setColor(.8, .8, .8) end
      love.graphics.circle("fill", 0, 0, node.size)
      love.graphics.setColor(.1, .1, .1)
      love.graphics.circle("line", 0, 0, node.size)
      if node.name then
        love.graphics.setColor(0, 0, 0)
        centeredPrint(node.name)
      end
      love.graphics.pop()
    end
    for n, node in pairs(self.possibleNewNodes) do
      love.graphics.push()
      love.graphics.setColor(.6, .6, .6, .2)
      love.graphics.line(node.x, node.y, tree.nodes[node.parent].x, tree.nodes[node.parent].y)
      love.graphics.translate(node.x, node.y)

      if node == grab then love.graphics.setColor(.8, .8, .8, .2) end
      love.graphics.circle("fill", 0, 0, node.size)
      love.graphics.setColor(.1, .1, .1, .1)
      love.graphics.circle("line", 0, 0, node.size)
      if node.name then
        love.graphics.setColor(0, 0, 0)
        centeredPrint(node.name)
      end
      love.graphics.pop()
    end
  end,
  getNodeAt = function (self, x, y)
    for n, node in pairs(self.nodes) do
      if math.dist(x, y, node.x, node.y) < node.size then
        return n, node
      end
    end
    for n, node in pairs(self.possibleNewNodes) do
      if math.dist(x, y, node.x, node.y) < node.size then
        return n, node
      end
    end
  end,
  addNewPossibleNodes = function (self, node, nodeID)
    if node.nodeType == "root" then
      for n, possibleNode in pairs(nodeLib) do
        if possibleNode.nodeType == "passive" then
          table.insert(self.possibleNewNodes, applyParams({
            fantom=true,
            parent = nodeID, x= math.random(1000)-500, y =math.random(700)-350, size = 30,
            tooltip = {w = 300, h = 300, backgroundColor = {.3, .3, .3}, textColor = {1, 1, 1}},
            drawTooltip = function (self)
              love.graphics.setColor(self.tooltip.backgroundColor)
              love.graphics.rectangle("fill", 0, 0, self.tooltip.w, self.tooltip.h)
              love.graphics.setColor(self.tooltip.textColor)
              love.graphics.translate(tooltipDX, tooltipDY)
              for p, prop in pairs(self) do
                if p ~= "drawTooltip" and p ~= "tooltip" then
                  if type(prop) == "string" then
                    love.graphics.print(p..": "..prop)
                    love.graphics.translate(0, tooltipDY)
                  end
                  if type(prop) == "function" then
                    love.graphics.print(p.."()")
                    love.graphics.translate(0, tooltipDY)
                  end
                  if type(prop) == "table" then
                    love.graphics.print(p.."{")
                    love.graphics.translate(0, tooltipDY)
                    love.graphics.translate(tooltipDX, 0)
                    for p2, prop2 in pairs(prop) do
                      love.graphics.print(p2.."= "..prop2)
                      love.graphics.translate(0, tooltipDY)
                    end
                    love.graphics.translate(-tooltipDX, 0)
                    love.graphics.print("}")
                    love.graphics.translate(0, tooltipDY)
                  end
                end
              end
            end
          }, possibleNode))
        end
      end
    end
    if node.nodeType == "passive" then
      for n, possibleNode in pairs(nodeLib) do
        if possibleNode.nodeType ~= "passive" then
          for t, tag in pairs(possibleNode.tags) do
            if tag == node.name then
              table.insert(self.possibleNewNodes, applyParams({
                fantom=true,
                parent = nodeID, x= math.random(1000)-500, y =math.random(700)-350, size = 30,
                tooltip = {w = 300, h = 300, backgroundColor = {.3, .3, .3}, textColor = {1, 1, 1}},
                drawTooltip = function (self)
                  love.graphics.setColor(self.tooltip.backgroundColor)
                  love.graphics.rectangle("fill", 0, 0, self.tooltip.w, self.tooltip.h)
                  love.graphics.setColor(self.tooltip.textColor)
                  love.graphics.translate(tooltipDX, tooltipDY)
                  for p, prop in pairs(self) do
                    if p ~= "drawTooltip" and p ~= "tooltip" then
                      if type(prop) == "string" then
                        love.graphics.print(p..": "..prop)
                        love.graphics.translate(0, tooltipDY)
                      end
                      if type(prop) == "function" then
                        love.graphics.print(p.."()")
                        love.graphics.translate(0, tooltipDY)
                      end
                      if type(prop) == "table" then
                        love.graphics.print(p.."{")
                        love.graphics.translate(0, tooltipDY)
                        love.graphics.translate(tooltipDX, 0)
                        for p2, prop2 in pairs(prop) do
                          love.graphics.print(p2.."= "..prop2)
                          love.graphics.translate(0, tooltipDY)
                        end
                        love.graphics.translate(-tooltipDX, 0)
                        love.graphics.print("}")
                        love.graphics.translate(0, tooltipDY)
                      end
                    end
                  end
                end
              }, possibleNode))
              break
            end
          end
        end
      end
    end
    if node.nodeType == "active" then
      for n, possibleNode in pairs(nodeLib) do
        if possibleNode.nodeType == "mod" then
          local match = true
          for t, tag in pairs(possibleNode.tags) do
            for t2, tag2 in pairs(node.tags) do
              if tag == tag2 then
                table.insert(self.possibleNewNodes, applyParams({
                  fantom=true,
                  parent = nodeID, x= math.random(1000)-500, y =math.random(700)-350, size = 30,
                  tooltip = {w = 300, h = 300, backgroundColor = {.3, .3, .3}, textColor = {1, 1, 1}},
                  drawTooltip = function (self)
                    love.graphics.setColor(self.tooltip.backgroundColor)
                    love.graphics.rectangle("fill", 0, 0, self.tooltip.w, self.tooltip.h)
                    love.graphics.setColor(self.tooltip.textColor)
                    love.graphics.translate(tooltipDX, tooltipDY)
                    for p, prop in pairs(self) do
                      if p ~= "drawTooltip" and p ~= "tooltip" then
                        if type(prop) == "string" then
                          love.graphics.print(p..": "..prop)
                          love.graphics.translate(0, tooltipDY)
                        end
                        if type(prop) == "function" then
                          love.graphics.print(p.."()")
                          love.graphics.translate(0, tooltipDY)
                        end
                        if type(prop) == "table" then
                          love.graphics.print(p.."{")
                          love.graphics.translate(0, tooltipDY)
                          love.graphics.translate(tooltipDX, 0)
                          for p2, prop2 in pairs(prop) do
                            love.graphics.print(p2.."= "..prop2)
                            love.graphics.translate(0, tooltipDY)
                          end
                          love.graphics.translate(-tooltipDX, 0)
                          love.graphics.print("}")
                          love.graphics.translate(0, tooltipDY)
                        end
                      end
                    end
                  end
                }, possibleNode))
                break
              end
            end
          end
        end
      end
    end
  end
}
