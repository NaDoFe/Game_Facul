-- Bibliotecas
creditos = require("menus.creditos")
controles = require("menus.controles")
jogo = require("jogo")

local estado = "menu"
local larguraTela = 1350
local alturaTela = 720
love.window.setMode(larguraTela, alturaTela,{fullscreen = true})

local jogo = require "jogo"

-- Imagens
local imagemMenu = love.graphics.newImage("assets/menu.png")

-- Botões normais
local botaoJogar = love.graphics.newImage("assets/menu/jogar.png")
local botaoControles = love.graphics.newImage("assets/menu/controles.png")
local botaoCreditos = love.graphics.newImage("assets/menu/creditos.png")
local botaoSair = love.graphics.newImage("assets/menu/sair.png")

-- Botões com hover
local botaoJogarHover = love.graphics.newImage("assets/menu/jogar_hover.png")
local botaoControlesHover = love.graphics.newImage("assets/menu/controles_hover.png")
local botaoCreditosHover = love.graphics.newImage("assets/menu/creditos_hover.png")
local botaoSairHover = love.graphics.newImage("assets/menu/sair_hover.png")

-- Largura desejada para os botões
local larguraDesejada = 170

-- Lista de botões
local botoes = {
    {
        nome = "jogar",
        y = 350,
        normal = botaoJogar,
        hover = botaoJogarHover,
        acao = function()
            estado = "jogo"
            jogo.reiniciar()
        end
    },
    {
        nome = "controles",
        y = 430,
        normal = botaoControles,
        hover = botaoControlesHover,
        acao = function() estado = "controles" end
    },
    {
        nome = "creditos",
        y = 510,
        normal = botaoCreditos,
        hover = botaoCreditosHover,
        acao = function() estado = "creditos" end
    },
    {
        nome = "sair",
        y = 590,
        normal = botaoSair,
        hover = botaoSairHover,
        acao = function() love.event.quit() end
    }
}

-- Ajusta escala e posição X dos botões para centralizar e redimensionar
for _, botao in ipairs(botoes) do
    local larguraOriginal = botao.normal:getWidth()
    botao.escala = larguraDesejada / larguraOriginal
    local larguraRedimensionada = botao.normal:getWidth() * botao.escala
    botao.x = (larguraTela - larguraRedimensionada) / 2
end

local botaoSelecionado = 1 -- Para navegação com teclado

function love.load()
    jogo.load()
end

function love.update(dt)
    if estado == "jogo" then
        jogo.update(dt)
    end
end

function love.draw()
    if estado == "menu" then
        love.graphics.draw(imagemMenu, 0, 0, 0,
            larguraTela / imagemMenu:getWidth(),
            alturaTela / imagemMenu:getHeight()
        )

        for i, botao in ipairs(botoes) do
            local imagem = (i == botaoSelecionado) and botao.hover or botao.normal
            love.graphics.draw(imagem, botao.x, botao.y, 0, botao.escala, botao.escala)
        end

    elseif estado == "jogo" then
        jogo.draw()

    elseif estado == "controles" then
        controles.desenharControles()

    elseif estado == "creditos" then
        creditos.desenharCreditos()

    end
end

function love.mousepressed(x, y, button)
    if estado == "menu" and button == 1 then
        for _, botao in ipairs(botoes) do
            if estaSobre(botao, x, y) then
                botao.acao()
                break
            end
        end
    end
end

function love.keypressed(key)
    if estado == "menu" then
        if key == "up" then
            botaoSelecionado = botaoSelecionado - 1
            if botaoSelecionado < 1 then
                botaoSelecionado = #botoes
            end
        elseif key == "down" then
            botaoSelecionado = botaoSelecionado + 1
            if botaoSelecionado > #botoes then
                botaoSelecionado = 1
            end
        elseif key == "return" or key == "kpenter" then
            botoes[botaoSelecionado].acao()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif estado == "jogo" then
        jogo.keypressed(key)
    elseif key == "backspace" then
        estado = "menu"
    end
end

function estaSobre(botao, mouseX, mouseY)
    local larguraBotao = botao.normal:getWidth() * botao.escala
    local alturaBotao = botao.normal:getHeight() * botao.escala
    return mouseX >= botao.x and mouseX <= botao.x + larguraBotao and
           mouseY >= botao.y and mouseY <= botao.y + alturaBotao
end
