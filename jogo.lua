local jogo = {}

local nave = {}
local meteoros = {}
local tiros = {}
local meteoroImagem
local meteoroGigante
local larguraTela = love.graphics.getWidth()
local alturaTela = love.graphics.getHeight()
local velocidadeNave = 300
local velocidadeTiro = 500
local velocidadeMeteoro = 100
local tempoUltimoMeteoro = 0
local fontePontuacao = love.graphics.newFont("fonts/Micro5-Regular.ttf", 20)

local score = 0
local vidas = 5
local jogoPausado = false
local gameOver = false
local fase = 1
local destruicoesFase = 0
local alvoFase = 20
local meteoroFinal = nil

function jogo.load()
    nave.image = love.graphics.newImage("nave1.png")
    meteoroImagem = love.graphics.newImage("meteoro.png")
    meteoroGigante = love.graphics.newImage("meteoro.png") -- usa a mesma imagem, mas escala maior

    nave.x = larguraTela / 2
    nave.y = alturaTela / 1.2
    nave.largura = nave.image:getWidth() * 0.2
    nave.altura = nave.image:getHeight() * 0.5
    nave.velocidade = velocidadeNave
end

function jogo.reiniciar()
    meteoros = {}
    tiros = {}
    meteoroFinal = nil
    score = 0
    vidas = 5
    gameOver = false
    jogoPausado = false
    fase = 1
    destruicoesFase = 0
    alvoFase = 20
    tempoUltimoMeteoro = 0

    nave.x = larguraTela / 2
end

function jogo.update(dt)
    if gameOver or jogoPausado then
        return
    end

    -- Movimentação da nave
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        nave.x = nave.x - nave.velocidade * dt
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        nave.x = nave.x + nave.velocidade * dt
    end

    -- Limites da nave
    if nave.x < 0 then
        nave.x = 0
    elseif nave.x + nave.largura > larguraTela then
        nave.x = larguraTela - nave.largura
    end

    -- Tiros
    for i = #tiros, 1, -1 do
        tiros[i].y = tiros[i].y - velocidadeTiro * dt
        if tiros[i].y < 0 then
            table.remove(tiros, i)
        end
    end

    -- Meteoros
    for i = #meteoros, 1, -1 do
        local m = meteoros[i]
        m.y = m.y + m.velocidade * dt

        -- Colisão com tiro
        for j = #tiros, 1, -1 do
            if checarColisao(m, tiros[j], 0.3) then
                table.remove(meteoros, i)
                table.remove(tiros, j)
                destruicoesFase = destruicoesFase + 1
                score = score + 1
                break
            end
        end

        -- Passou da tela
        if m and m.y > alturaTela then
            table.remove(meteoros, i)
            vidas = vidas - 1
            if vidas <= 0 then
                gameOver = true
            end
        end
    end

    -- Fases
    if fase == 1 and destruicoesFase >= 20 then
        fase = 2
        alvoFase = 10
        destruicoesFase = 0
        velocidadeMeteoro = 150
    elseif fase == 2 and destruicoesFase >= 10 then
        fase = 3
        meteoroFinal = {
            x = larguraTela / 2 - 100,
            y = -100,
            vida = 50,
            largura = meteoroGigante:getWidth() * 0.6,
            altura = meteoroGigante:getHeight() * 0.6
        }
    end

    -- Fase final
    if fase == 3 and meteoroFinal then
        meteoroFinal.y = meteoroFinal.y + 40 * dt
        for i = #tiros, 1, -1 do
            if checarColisao(meteoroFinal, tiros[i], 0.6) then
                meteoroFinal.vida = meteoroFinal.vida - 1
                table.remove(tiros, i)
                if meteoroFinal.vida <= 0 then
                    gameOver = true -- vitória
                end
            end
        end
        return
    end

    -- Criar novos meteoros
    tempoUltimoMeteoro = tempoUltimoMeteoro + dt
    if tempoUltimoMeteoro > 1 and fase < 3 then
        criarMeteoro()
        tempoUltimoMeteoro = 0
    end
end

function jogo.draw()
    -- Nave
    love.graphics.draw(nave.image, nave.x, nave.y, 0, 0.2, 0.2)

    -- Meteoros
    for _, meteoro in ipairs(meteoros) do
        love.graphics.draw(meteoroImagem, meteoro.x, meteoro.y, 0, 0.3, 0.3)
    end

    -- Meteoro Final
    if meteoroFinal then
        love.graphics.draw(meteoroGigante, meteoroFinal.x, meteoroFinal.y, 0, 0.6, 0.6)
        love.graphics.setColor(255, 0, 0)
        love.graphics.printf("Vida do Meteoro Final: " .. meteoroFinal.vida, 0, 30, larguraTela, "center")
        love.graphics.setColor(255, 255, 255)
    end

    -- Tiros
    love.graphics.setColor(0, 255, 0)
    for _, tiro in ipairs(tiros) do
        love.graphics.rectangle("fill", tiro.x, tiro.y, 5, 10)
    end
    love.graphics.setColor(255, 255, 255)

    -- Pontuação e vidas
    love.graphics.setFont(fontePontuacao)
    love.graphics.print("Meteoros destruídos: " .. score, 10, 10)
    love.graphics.print("Vidas: " .. vidas, 100, 50)
    love.graphics.print("Fase: " .. fase, 10, 40)

    -- Pausa
    if jogoPausado then
        love.graphics.printf("JOGO PAUSADO\nPressione 'P' para continuar\n'M' para menu", 0, alturaTela / 2,
            larguraTela, "center")
    end

    -- Game Over
    if gameOver then
        love.graphics.setColor(255, 0, 0)
        local msg = (fase == 3 and meteoroFinal and meteoroFinal.vida <= 0) and "VITÓRIA! TERRA SALVA!" or
                        "TERRA DESTRUÍDA"
        love.graphics.printf(msg, 0, alturaTela / 2, larguraTela, "center")
        love.graphics.printf("Pressione 'R' para reiniciar", 0, alturaTela / 2 + 40, larguraTela, "center")
        love.graphics.setColor(255, 255, 255)
    end
end

function jogo.keypressed(key)
    if key == "space" and not jogoPausado and not gameOver then
        local tiro = {
            x = nave.x + nave.largura / 2 - 2.5,
            y = nave.y
        }
        table.insert(tiros, tiro)
    elseif key == "p" then
        jogoPausado = not jogoPausado
    elseif key == "m" and jogoPausado then
        estado = "menu"
        jogoPausado = false
    elseif key == "r" and gameOver then
        jogo.reiniciar()
    elseif key == "backspace" then
        estado = "menu"
    end
end

function criarMeteoro()
    local meteoro = {
        x = math.random(0, larguraTela - meteoroImagem:getWidth() * 0.3),
        y = -30,
        velocidade = math.random(velocidadeMeteoro, velocidadeMeteoro + 50)
    }
    table.insert(meteoros, meteoro)
end

function checarColisao(obj1, obj2, escala)
    escala = escala or 0.3
    local obj1Right = obj1.x + meteoroImagem:getWidth() * escala
    local obj1Bottom = obj1.y + meteoroImagem:getHeight() * escala
    local obj2Right = obj2.x + 5
    local obj2Bottom = obj2.y + 10

    return obj2.x < obj1Right and obj2Right > obj1.x and obj2.y < obj1Bottom and obj2Bottom > obj1.y
end

return jogo
