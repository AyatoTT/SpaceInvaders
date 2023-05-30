local composer = require("composer")
function myScene2:create(event)
    -- создание сцены
    local myScene = composer.newScene()

    -- функция обработки события нажатия на кнопку "Play"
    local function onPlayButtonTap(event)
      if event.phase == "ended" then
        composer.gotoScene("game") -- переход на сцену с игрой
      end
    end

    -- функция отображения сцены
    function myScene:create(event)
      local sceneGroup = self.view

      -- создание фона
      local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
      background:setFillColor(0.1, 0.1, 0.1)

      -- создание кнопки "Play"
      local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentCenterY, native.systemFont, 48)
      playButton:setFillColor(1, 1, 1)
      playButton:addEventListener("touch", onPlayButtonTap)
    end

    -- функция скрытия сцены
    function myScene:hide(event)
      local sceneGroup = self.view

      if event.phase == "will" then
        -- очистка ресурсов, связанных со сценой
        display.remove(sceneGroup)
        sceneGroup = nil
      end
    end

    -- настройка обработчиков событий
    myScene:addEventListener("create", scene)
    myScene:addEventListener("hide", scene)
end
return scene