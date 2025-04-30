-- Bibliotecas
creditos = require("menus.creditos")
controles = require("menus.controles")

love.window.setMode(0, 0, { fullscreen = true, fullscreentype = "desktop" })

-- Configuração inicial
local nave = {}
local meteoros = {}
local tiros = {}
local explosoes = {} -- NOVO: Tabela de explosões

-- Imagem do menu
local imagemMenu 

-- Parâmetros do jogo
local larguraTela = love.graphics.getWidth()
local alturaTela = love.graphics.getHeight()
local velocidadeNave = 300
local velocidadeTiro = 500
local velocidadeMeteoro = 100

local tempoUltimoMeteoro = 100
local score = 0
local jogoPausado = false
local gameOver = false
local vidas = 5

-- Estados do jogo
local estado = "menu"
local opcaoSelecionada = 1

-- Carregar fontes
local fontePontuacao = love.graphics.newFont(20)

-- Função para inicializar o jogo
function love.load()
    nave.image = love.graphics.newImage("nave1.png")
    meteoroImagem = love.graphics.newImage("meteoro.png")
    imagemMenu = love.graphics.newImage("menu.png")

    nave.x = larguraTela / 2
    nave.y = alturaTela / 1.2
    nave.largura = nave.image:getWidth() * 0.2
    nave.altura = nave.image:getHeight() * 0.5
    nave.velocidade = velocidadeNave

    love.window.setTitle("METEOR SMASH")
end

function reiniciarJogo()
    meteoros = {}
    tiros = {}
    explosoes = {}
    score = 0
    tempoUltimoMeteoro = 1
    vidas = 5
    gameOver = false
end

function love.update(dt)
    if gameOver then return end

    if estado == "jogo" then
        if jogoPausado then return end

        -- Movimentação da nave
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            nave.x = nave.x - nave.velocidade * dt
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            nave.x = nave.x + nave.velocidade * dt
        end

        if nave.x < 0 then
            nave.x = 0
        elseif nave.x + nave.largura > larguraTela then
            nave.x = larguraTela - nave.largura
        end

        -- Atualizar tiros
        for i = #tiros, 1, -1 do
            tiros[i].y = tiros[i].y - velocidadeTiro * dt
            if tiros[i].y < 0 then
                table.remove(tiros, i)
            end
        end

        -- Atualizar meteoros
        for i = #meteoros, 1, -1 do
            meteoros[i].y = meteoros[i].y + velocidadeMeteoro * dt

            -- Verificar colisão com tiros
            for j = #tiros, 1, -1 do
                if checarColisao(meteoros[i], tiros[j]) then
                    table.insert(explosoes, {
                        x = meteoros[i].x,
                        y = meteoros[i].y,
                        tempo = 0.5
                    })
                    table.remove(meteoros, i)
                    table.remove(tiros, j)
                    score = score + 1
                    break
                end
            end

            -- Verificar se bateu no chão
            if meteoros[i] and meteoros[i].y > alturaTela then
                table.insert(explosoes, {
                    x = meteoros[i].x,
                    y = alturaTela - 30,
                    tempo = 0.5
                })
                table.remove(meteoros, i)
                vidas = vidas - 1
                if vidas <= 0 then
                    gameOver = true
                end
            end
        end

        -- Criar novos meteoros
        tempoUltimoMeteoro = tempoUltimoMeteoro + dt
        if tempoUltimoMeteoro > 1 then
            criarMeteoro()
            tempoUltimoMeteoro = 0
        end

        -- Atualizar explosões
        for i = #explosoes, 1, -1 do
            explosoes[i].tempo = explosoes[i].tempo - dt
            if explosoes[i].tempo <= 0 then
                table.remove(explosoes, i)
            end
        end
    end
end

function love.draw()
    if estado == "menu" then
        desenharMenu()
    elseif estado == "jogo" then
        desenharJogo()
    elseif estado == "controles" then
        controles.desenharControles()
    elseif estado == "creditos" then
        creditos.desenharCreditos()
    end
end

function desenharMenu()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(imagemMenu, 0, 0, 0, 0.9, 0.75)
    love.graphics.printf("METEOR SMASH", 0, 100, larguraTela / 1.5, "center")

    local opcoes = {"Jogar", "Controles", "Créditos", "Sair"}
    for i = 1, #opcoes do
        if i == opcaoSelecionada then
            love.graphics.setColor(100, 100, 0)
            love.graphics.rectangle("line", 540, 192 + (i * 40), 200, 30)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.printf(opcoes[i], 0, 200 + (i * 40), larguraTela / 1.5, "center")
    end
end

function desenharJogo()
    love.graphics.draw(nave.image, nave.x, nave.y, 0, 0.2, 0.2)

    for _, meteoro in ipairs(meteoros) do
        love.graphics.draw(meteoroImagem, meteoro.x, meteoro.y, 0, 0.3, 0.3)
    end

    for _, explosao in ipairs(explosoes) do
        love.graphics.setColor(255, 165, 0)
        love.graphics.circle("fill", explosao.x + 15, explosao.y, 20)
    end
    love.graphics.setColor(255, 255, 255)

    love.graphics.setColor(0, 255, 0)
    for _, tiro in ipairs(tiros) do
        love.graphics.rectangle("fill", tiro.x, tiro.y, 5, 10)
    end
    love.graphics.setColor(255, 255, 255)

    love.graphics.setFont(fontePontuacao)
    love.graphics.print("Meteoros destruídos: " .. score, 10, 10)
    love.graphics.print("Vidas: " .. vidas, 100, 50)

    if jogoPausado then
        love.graphics.printf("JOGO PAUSADO\nPressione 'P' para continuar\nPressione 'M' para voltar ao menu", 0, alturaTela / 2, larguraTela, "center")
    end

    if gameOver then
        love.graphics.setColor(255, 0, 0)
        love.graphics.printf("TERRA DESTRUÍDA", 0, alturaTela / 2, larguraTela, "center")
        love.graphics.printf("Pressione 'R' para reiniciar", 0, alturaTela / 2 + 40, larguraTela, "center")
        love.graphics.setColor(255, 255, 255)
    end
end

function criarMeteoro()
    local meteoro = {
        x = math.random(0, larguraTela - meteoroImagem:getWidth() * 0.3),
        y = -30,
        velocidade = math.random(100, 200),
    }
    table.insert(meteoros, meteoro)
end

function checarColisao(meteoro, tiro)
    local escala = 0.3
    local meteoroLeft = meteoro.x
    local meteoroRight = meteoro.x + meteoroImagem:getWidth() * escala
    local meteoroTop = meteoro.y
    local meteoroBottom = meteoro.y + meteoroImagem:getHeight() * escala

    local tiroLeft = tiro.x
    local tiroRight = tiro.x + 5
    local tiroTop = tiro.y
    local tiroBottom = tiro.y + 10

    return tiroRight > meteoroLeft and tiroLeft < meteoroRight and tiroBottom > meteoroTop and tiroTop < meteoroBottom
end

function love.keypressed(key)
    if estado == "menu" then
        if key == "down" then
            opcaoSelecionada = opcaoSelecionada % 4 + 1
        elseif key == "up" then
            opcaoSelecionada = (opcaoSelecionada - 2) % 4 + 1
        elseif key == "return" then
            if opcaoSelecionada == 1 then
                estado = "jogo"
            elseif opcaoSelecionada == 2 then
                estado = "controles"
            elseif opcaoSelecionada == 3 then
                estado = "creditos"
            elseif opcaoSelecionada == 4 then
                love.event.quit()
            end
        elseif key == "backspace" then
            estado = "menu"
        end
    elseif estado == "controles" or estado == "creditos" then
        if key == "backspace" then
            estado = "menu"
        end
    elseif estado == "jogo" then
        if key == "space" and not jogoPausado then
            local tiro = {x = nave.x + nave.largura / 2 - 2.5, y = nave.y}
            table.insert(tiros, tiro)
        elseif key == "p" then
            jogoPausado = not jogoPausado
        elseif key == "m" and jogoPausado then
            estado = "menu"
            jogoPausado = false
        elseif key == "r" and gameOver then
            reiniciarJogo()
            estado = "jogo"
        elseif key == "backspace" then
            estado = "menu"
        end
    end
end
