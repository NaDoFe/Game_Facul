-- Bibliotecas
creditos = require("menus.creditos")
controles = require("menus.controles")
jogo = require("jogo")

love.window.setMode(0, 0, { fullscreen = true, fullscreentype = "desktop" })

-- Estado do jogo
estado = "menu"
opcaoSelecionada = 1

-- Imagem do menu
local imagemMenu
local larguraTela = love.graphics.getWidth()

function love.load()
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
