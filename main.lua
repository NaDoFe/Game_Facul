-- Bibliotecas
creditos = require("menus.creditos")
controles = require("menus.controles")
jogo = require("jogo")

-- Dimensões da tela
larguraTela, alturaTela = love.window.getDesktopDimensions()
love.window.setMode(larguraTela, alturaTela, {fullscreen = true})

-- Estado do jogo
estado = "menu"
opcaoSelecionada = 1

<<<<<<< Updated upstream
local fonte = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 10)
=======
local fontePontuacao = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 20)
love.graphics.setFont(fontePontuacao)
-- Imagens
local imagemMenu = love.graphics.newImage("assets/menu.png")
>>>>>>> Stashed changes

-- Imagem do menu
local imagemMenu

function love.load()
    love.graphics.setFont(fonte)
    imagemMenu = love.graphics.newImage("menu.png")
    love.window.setTitle("METEOR SMASH")
    jogo.load() -- carregar os recursos do jogo
end

function love.update(dt)
    if estado == "jogo" then
        jogo.update(dt)
    end
end

function love.draw()
    if estado == "menu" then
        desenharMenu()
    elseif estado == "jogo" then
        jogo.draw()
    elseif estado == "controles" then
        controles.desenharControles()
    elseif estado == "creditos" then
        creditos.desenharCreditos()
    end
end

function desenharMenu()
    love.graphics.setFont(fonte)
    love.graphics.setColor(255, 255, 255)

    -- Escala proporcional para preencher a tela sem distorcer
    local imgLarg = imagemMenu:getWidth()
    local imgAlt = imagemMenu:getHeight()
    local escala = math.min(larguraTela / imgLarg, alturaTela / imgAlt)

    -- Centralizar a imagem
    local offsetX = (larguraTela - imgLarg * escala) / 2
    local offsetY = (alturaTela - imgAlt * escala) / 2
    love.graphics.draw(imagemMenu, offsetX, offsetY, 0, escala, escala)

    -- Título e opções
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf("METEOR SMASH", 0, 100, larguraTela, "center")

    local opcoes = {"Jogar", "Controles", "Créditos", "Sair"}
    for i = 1, #opcoes do
        if i == opcaoSelecionada then
            love.graphics.setColor(100, 100, 0)
            love.graphics.rectangle("line", 540, 192 + (i * 40), 200, 30)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.printf(opcoes[i], 0, 200 + (i * 40), larguraTela, "center")
    end
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
                jogo.reiniciar()
            elseif opcaoSelecionada == 2 then
                estado = "controles"
            elseif opcaoSelecionada == 3 then
                estado = "creditos"
            elseif opcaoSelecionada == 4 then
                love.event.quit()
            end
        end
    elseif estado == "controles" or estado == "creditos" then
        if key == "backspace" then
            estado = "menu"
        end
    elseif estado == "jogo" then
        jogo.keypressed(key)
    end
end
