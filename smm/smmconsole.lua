smm = {
  mods = {}
}

setmetatable(
  smm,
  {
    __call = function(t, ...)
      local args = table.pack(...)
      assert(type(args[1]) == "function",
             "The first argument must be your panel init function")
      table.insert(t.mods, args[1])
    end
  }
)

function init()
  storage = console.configParameter("scriptStorage")
  local source = console.configParameter("interactSource")
  local sourceId = console.configParameter("interactSourceId")
  smm.source = function()
    return {source[1], source[2]}
  end
  smm.sourceId = function()
    return sourceId
  end
  
  local guiConfig = console.configParameter("gui")
  local canvasRect = guiConfig.scriptCanvas.rect
  
  local width = canvasRect[3] - canvasRect[1]
  local height = canvasRect[4] - canvasRect[2]
  local padding = 5
  local fontSize = 14
  local modList = List(padding, padding, 100, height - padding * 3 - fontSize, fontSize)
  local modFilter = TextField(padding, modList.y + modList.height + padding,
                              modList.width, fontSize, "Filter")
  
  local modPanelX = modList.x + modList.width + padding
  local modPanelY = modList.y
  local modPanelWidth = width - modPanelX - padding
  local modPanelHeight = height - modPanelY - padding

  local modPanelRectSize = 2
  local modPanelRect = Rectangle(modPanelX - modPanelRectSize,
                                 modPanelY - modPanelRectSize,
                                 modPanelWidth + modPanelRectSize * 2,
                                 modPanelHeight + modPanelRectSize * 2,
                                 "black", modPanelRectSize)
  for k,v in ipairs(smm.mods) do
    local modPanel = Panel(modPanelX, modPanelY)
    modPanel.width = modPanelWidth
    modPanel.height = modPanelHeight
    local modName, modTags = v(modPanel)
    assert(type(modName) == "string",
           "Your init function must return your mod name.")
    local modButton = modList:emplaceItem(modName)
    modButton.modTags = modTags
    modPanel:bind("visible", Binding(modButton, "selected"))
    GUI.add(modPanel)
  end
  modFilter:addListener(
    "text",
    function(t, k, old, new)
      modList:filter(
        function(item)
          if item.text:find(new) then
            return true
          end
          if item.modTags then
            for _,tag in ipairs(item.modTags) do
              if tag:find(new) then
                return true
              end
            end
          end
        end
      )
    end
  )
  GUI.add(modList)
  GUI.add(modFilter)
  GUI.add(modPanelRect)

  table.sort(
    modList.items,
    function(a, b)
      return a.text < b.text
    end
  )
end


function syncStorage()
  world.callScriptedEntity(console.sourceEntity(), "onConsoleStorageRecieve", storage)
end

function update(dt)
  GUI.step(dt)
end

function canvasClickEvent(position, button, pressed)
  GUI.clickEvent(position, button, pressed)
end

function canvasKeyEvent(key, isKeyDown)
  GUI.keyEvent(key, isKeyDown)
end
