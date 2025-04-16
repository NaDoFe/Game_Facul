-- Bibliotecas
creditos = require("menus.creditos")
controles = require("menus.controles")

love.window.setMode(1920, 1080, { fullscreen = true, resizable = false })

-- Configuração inicial
local nave = {}
local meteoros = {}
local tiros = {}

-- Imagem do menu
local imagemMenu 

-- Parâmetros do jogo
local larguraTela = 1920  -- Ajuste para resolução da janela
local alturaTela = 1080   -- Ajuste para resolução da janela
local velocidadeNave = 300
local velocidadeTiro = 500
local velocidadeMeteoro = 100
local tempoUltimoMeteoro = 100
local score = 0 -- Contador de meteoros destruídos
local jogoPausado = false -- Variável para controlar o pause
local gameOver = false -- Variável para verificar se o jogo acabou
local vidas = 5

-- Estados do jogo
local estado = "menu" -- "menu", "jogo", "controles", "creditos"
local opcaoSelecionada = 1

-- Carregar fontes
local fontePontuacao = love.graphics.newFont(20)

-- Função para inicializar o jogo
function love.load()
    -- Carregar imagens
    nave.image = love.graphics.newImage("nave1.png")
    meteoroImagem = love.graphics.newImage("meteoro.png")
  
    -- Definir posição e tamanho inicial da nave
    nave.x = love.graphics.getWidth() / 2
    nave.y = love.graphics.getHeight() / 1.2
    nave.largura = nave.image:getWidth() * 0.2  -- 20% do tamanho original
    nave.altura = nave.image:getHeight() * 0.5  -- 50% do tamanho original
    nave.velocidade = velocidadeNave
    imagemMenu = love.graphics.newImage("menu.png")


    love.window.setTitle("METEOR SMASH")
end

function reiniciarJogo()
    meteoros = {}
    score = 0
    tempoUltimoMeteoro = 1
    vidas = 5
    gameOver = false
end

-- Função de atualização do jogo
function love.update(dt)
    if gameOver then
        return
    end
    if estado == "jogo" then
        if jogoPausado then return end -- Se o jogo estiver pausado, interrompe a atualização

        -- Movimentação da nave
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            nave.x = nave.x - nave.velocidade * dt
        elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            nave.x = nave.x + nave.velocidade * dt
        end

        -- Impedir a nave de sair da tela
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
            if meteoros[i].y > alturaTela then
                table.remove(meteoros, i)
            end

            -- Verificar colisão com tiros
            for j = #tiros, 1, -1 do
                if checarColisao(meteoros[i], tiros[j]) then
                    table.remove(meteoros, i)
                    table.remove(tiros, j)
                    score = score + 1 -- Aumenta o contador de meteoros destruídos
                    break
                end
            end
        end

        -- Criar meteoros
        tempoUltimoMeteoro = tempoUltimoMeteoro + dt
        if tempoUltimoMeteoro > 1 then
            criarMeteoro()
            tempoUltimoMeteoro = 0
        end

        -- Verificar se um meteoro tocou o fundo da tela
        for i, meteoro in ipairs(meteoros) do
            if meteoro.y + meteoroImagem:getHeight() * 0.3 >= alturaTela then
                table.remove(meteoros, i)
                vidas = vidas - 1
                if vidas <= 0 then
                    gameOver = true
                end
            end
        end
    end
end

-- Função para desenhar elementos na tela
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

-- Função para desenhar o menu inicial
function desenharMenu()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(imagemMenu, 0, 0, 0, 0.9, 0.75)
    love.graphics.printf("METEOR SMASH", 0, 100, larguraTela / 1.5, "center")

    local opcoes = {"Jogar", "Controles", "Créditos"}
    for i = 1, #opcoes do
        if i == opcaoSelecionada then
            love.graphics.setColor(100, 100, 0) -- Amarelo para a opção selecionada
            love.graphics.rectangle("line", 540, 192 + (i * 40), 200, 30) -- Desenhar fundo para a opção
        else
            love.graphics.setColor(255, 255, 255) -- Branco para as outras opções
        end
        love.graphics.printf(opcoes[i], 0, 200 + (i * 40), larguraTela / 1.5, "center")
    end
end

-- Função para desenhar o jogo
function desenharJogo()
    -- Desenhar nave (redimensionada para 20%)
    love.graphics.draw(nave.image, nave.x, nave.y, 0, 0.2, 0.2)

    -- Desenhar meteoros (redimensionados para 30%)
    for _, meteoro in ipairs(meteoros) do
        love.graphics.draw(meteoroImagem, meteoro.x, meteoro.y, 0, 0.3, 0.3)
    end

    -- Desenhar tiros
    love.graphics.setColor(0, 255, 0)
    for _, tiro in ipairs(tiros) do
        love.graphics.rectangle("fill", tiro.x, tiro.y, 5, 10)
    end    

    -- Exibir pontuação
    love.graphics.setFont(fontePontuacao)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Meteoros destruídos: " .. score, 10, 10)

    -- Exibir vidas restantes
    love.graphics.setFont(fontePontuacao)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Vidas: " .. vidas, 100, 50)

    -- Mensagem de pause
    if jogoPausado then
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("JOGO PAUSADO\nPressione 'P' para continuar\nPressione 'M' para voltar ao menu", 0, alturaTela / 2, larguraTela, "center")
    end

    -- Exibir "Game Over" quando o jogo terminar
    if gameOver then
        love.graphics.setColor(255, 0, 0)
        love.graphics.printf("TERRA DESTRUÍDA", 0, alturaTela / 2, larguraTela, "center")
        love.graphics.printf("Pressione 'R' para reiniciar", 0, alturaTela / 2 + 40, larguraTela, "center")
    end
end

-- Função para criar um meteoro
function criarMeteoro()
    local meteoro = {
        x = math.random(0, larguraTela - meteoroImagem:getWidth() * 0.3), -- Ajuste para evitar que o meteoro ultrapasse a tela
        y = -30,
        velocidade = math.random(100, 200),  -- Velocidade aleatória para meteoros
    }
    table.insert(meteoros, meteoro)
end

-- Função para verificar colisão com as imagens
function checarColisao(meteoro, tiro)
    -- Definindo os limites da imagem do meteoro com base no redimensionamento
    local meteoroLeft = meteoro.x
    local meteoroRight = meteoro.x + meteoroImagem:getWidth() * 0.2
    local meteoroTop = meteoro.y
    local meteoroBottom = meteoro.y + meteoroImagem:getHeight() * 0.2

    -- Definindo os limites do tiro
    local tiroLeft = tiro.x
    local tiroRight = tiro.x + 5
    local tiroTop = tiro.y
    local tiroBottom = tiro.y + 10

    -- Verificar se os retângulos se sobrepõem (colisão)
    return tiroRight > meteoroLeft and tiroLeft < meteoroRight and tiroBottom > meteoroTop and tiroTop < meteoroBottom
end

-- Função para navegação no menu e ações
function love.keypressed(key)
    if estado == "menu" then
        if key == "down" then
            opcaoSelecionada = opcaoSelecionada % 3 + 1  -- Navega para a próxima opção
        elseif key == "up" then
            opcaoSelecionada = (opcaoSelecionada - 2) % 3 + 1  -- Navega para a opção anterior
        elseif key == "return" then
            if opcaoSelecionada == 1 then
                estado = "jogo"  -- Inicia o jogo
            elseif opcaoSelecionada == 2 then
                estado = "controles"  -- Abre o menu de controles
            elseif opcaoSelecionada == 3 then
                estado = "creditos"  -- Abre o menu de créditos
            end
        elseif key == "backspace" then
            estado = "menu"  -- Volta para o menu a partir de qualquer outro estado
        end
    elseif estado == "controles" or estado == "creditos" then
        if key == "backspace" then
            estado = "menu"  -- Retorna ao menu
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
            estado = "menu"  -- Retorna ao menu a partir do jogo
        end
    end
end