
local physics = require("physics")
physics.start()
local player -- игрок
local bullets = {} -- массив пуль
local enemies = {} -- массив инопланетных кораблей
local background = display.newImageRect( "background.png",1920,1080 )
background.x = display.contentCenterX
background.y = display.contentCenterY
background.width = display.contentWidth + 250
background.height = display.contentHeight
local score = 0 -- очки игрока
local lives = 3 -- количество жизней игрока
local livesText = display.newText("Lives: " .. lives, display.contentWidth - 80, 20, native.systemFont, 20)
livesText:setFillColor(1, 1, 1) -- установка цвета текста
local scoreText = display.newText("Score: " .. score, 10, 20, native.systemFont, 18) 
local fireSound = audio.loadSound("fire.wav") -- звук выстрела
local hitSound = audio.loadSound("hit.wav") -- звук попадания
audio.setVolume(0.0007, { channel = 1 })


-- Функция создания игрока
local function createPlayer()
    player = display.newImageRect("player.png", 35, 35)
    player.x = display.contentCenterX
    player.y = display.contentHeight - 50 -- начальные координаты игрока
    player.isAlive = true -- флаг, указывающий, жив ли игрок
    physics.addBody(player, "kinematic", { radius = 25 })
    --player.gravityScale = 0
    player.isSensor = true
    player.isPlayer = true
end

-- Функция создания инопланетных кораблей
local function createEnemies()
    for i = 1, 10 do
        local enemy = display.newImageRect("enemy.png", 35, 35)
        enemy.x = i * 60
        enemy.y = 50
        physics.addBody(enemy, "dynamic", { radius = 25 })
        enemy.isEnemy = true
        enemy.gravityScale = 0
        table.insert(enemies, enemy)
    end
end


local function movePlayer(event)
    if (event.phase == "moved") then
        local x = event.x -- позиция пальца по оси X
        local y = event.y -- позиция пальца по оси Y
        if (x > player.width / 2 - 120 and x < display.contentWidth + 120 - player.width / 2 and y > player.height / 2 and y < display.contentHeight - player.height / 2) then -- проверяем, не выходит ли игрок за границы экрана
            transition.moveTo(player, { x = x, y = y, time = 0 }) -- перемещаем игрока в позицию пальца
        end
    end
end
Runtime:addEventListener("touch", movePlayer) -- добавляем обработчик события перемещения пальца по экрану



-- Функция создания пули
local function createBullet()
    local bullet = display.newImageRect("bullet.png", 10, 20)
    bullet.x = player.x
    bullet.y = player.y - 30
    bullet.isBullet = true
    physics.addBody(bullet, "dynamic", { radius = 25 })
    bullet.gravityScale = 0
    table.insert(bullets, bullet)
    audio.play(fireSound)
end

-- Функция обработки столкновения
local function removeEnemy(enemy)
    for i = #enemies, 1, -1 do
        if (enemies[i] == enemy) then
            table.remove(enemies, i)
            score = score + 10 -- увеличиваем очки игрока при уничтожении корабля
            scoreText.text = "Score: " .. score
            audio.play(hitSound)
            break
        end
    end
    display.remove(enemy)
end

local function onCollision(event)
    if (event.phase == "began") then
        local obj1 = event.object1
        local obj2 = event.object2
        if ((obj1.isBullet and obj2.isEnemy) or (obj1.isEnemy and obj2.isBullet)) then
            display.remove(obj1)
            display.remove(obj2)
            if (obj1.isEnemy) then
                removeEnemy(obj1)
            elseif (obj2.isEnemy) then
                removeEnemy(obj2)
            end
            for i = #bullets, 1, -1 do
                if (bullets[i] == obj1 or bullets[i] == obj2) then
                    table.remove(bullets, i)
                    break
                end
            end
        elseif ((obj1.isPlayer and obj2.isEnemy) or (obj1.isEnemy and obj2.isPlayer)) then
            lives = lives - 1 -- уменьшаем количество жизней игрока при пропуске корабля
            livesText.text = "Lives: " .. lives 

            if (obj1.isPlayer and obj2.isEnemy) then
                removeEnemy(obj2)
            elseif (obj1.isEnemy and obj2.isPlayer) then
                removeEnemy(obj1)
            end

            if (lives <= 0) then
                player.isAlive = false -- игрок погиб
                -- здесь может быть код для окончания игры
            end
        end
    end
end

-- Функция обновления пуль
local function updateBullets()
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - 10 -- двигаем пулю вверх
        if (bullet.y < -20) then
            display.remove(bullet)
            table.remove(bullets, i)
        end
    end
end

-- Функция обновления инопланетных кораблей
local function updateEnemies()
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x + math.sin(enemy.y * 0.05) * 3 -- двигаем корабль вправо-влево
        enemy.y = enemy.y + 0.3 -- двигаем корабль вниз
        if (enemy.y > display.contentHeight + 50) then
            display.remove(enemy)
            table.remove(enemies, i)
            lives = lives - 1 -- уменьшаем количество жизней игрока при пропуске корабля
            livesText.text = "Lives: " .. lives
            if (lives <= 0) then
                --player.isAlive = false -- игрок погиб
                -- здесь может быть код для окончания игры
            end
        end
    end
end

-- Функция обновления игры
local function gameLoop()
    if (player.isAlive) then
        updateBullets()
        updateEnemies()
    end
end

-- Функция выпуска пуль
local function onFire()
    
    if (player.isAlive) then
        timer.performWithDelay(250,createBullet(),1) 
        
    end
end
timer.performWithDelay(550,onFire,0)
-- Функция обновления интерфейса игры
local function updateUI()
    
end

-- Функция инициализации игры
local function initGame()
    createPlayer()
    createEnemies()
    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame", gameLoop)
   --Runtime:addEventListener("touch", onFire)
end


local function checkEnemies()
    
    if #enemies == 0 then -- если количество врагов равно нулю
      -- запускаем новый уровень
      createEnemies()
    end
end

Runtime:addEventListener("enterFrame", checkEnemies)
initGame()

