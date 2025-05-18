local jogo = {}

local nave = {}
local meteoros = {}
local tiros = {}
local meteoroImagem
local meteoroGigante
local imagemBala
local imagemFase2

local larguraTela = 1350
local alturaTela = 720
love.window.setMode(larguraTela, alturaTela)

local velocidadeNave = 300
local velocidadeTiro = 500
local velocidadeMeteoro = 100
local tempoUltimoMeteoro = 0

local fontePontuacao = love.graphics.newFont("fonts/PixelifySans-VariableFont_wght.ttf", 20)

local score = 0
local vidas = 5
local jogoPausado = false
local gameOver = false
local fase = 1
local destruicoesFase = 0
local alvoFase = 20
local meteoroFinal = nil

local emTransicaoDeFase = false
local tempoTransicao = 0
local duracaoTransicao = 3
local alphaTransicao = 0
local transicaoTextoY = alturaTela
local textoTransicao = ""
local mostrarImagemFase2 = false

local navesDisponiveis = {
    love.graphics.newImage("nave1.png"),
    love.graphics.newImage("nave2.png"),
    love.graphics.newImage("nave3.png")
}
local naveSelecionada = 1

function jogo.load()
    nave.image = navesDisponiveis[naveSelecionada]
    meteoroImagem = love.graphics.newImage("meteoro.png")
    meteoroGigante = love.graphics.newImage("meteoro.png")
    imagemBala = love.graphics.newImage("bala.png")
    imagemFase2 = love.graphics.newImage("fase2.png")

    nave.x = larguraTela / 2
    nave.y = alturaTela * 0.85
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
    emTransicaoDeFase = false
    tempoTransicao = 0
    alphaTransicao = 0
    transicaoTextoY = alturaTela
    textoTransicao = ""
    mostrarImagemFase2 = false
    nave.x = larguraTela / 2

    nave.image = navesDisponiveis[naveSelecionada]
    nave.largura = nave.image:getWidth() * 0.2
    nave.altura = nave.image:getHeight() * 0.5
end

function jogo.update(dt)
    if gameOver or jogoPausado then return end

    if emTransicaoDeFase then
        tempoTransicao = tempoTransicao + dt
        alphaTransicao = math.sin((tempoTransicao / duracaoTransicao) * math.pi)
        transicaoTextoY = alturaTela / 2 + math.sin(tempoTransicao * 3) * 10

        if tempoTransicao >= duracaoTransicao then
            emTransicaoDeFase = false
            tempoTransicao = 0
            alphaTransicao = 0
            transicaoTextoY = alturaTela
            mostrarImagemFase2 = false

            if fase == 3 then
                meteoroFinal = {
                    x = larguraTela / 2 - 100,
                    y = -100,
                    vida = 50,
                    largura = meteoroGigante:getWidth() * 0.6,
                    altura = meteoroGigante:getHeight() * 0.6
                }
            end
        end
        return
    end

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

    for i = #tiros, 1, -1 do
        tiros[i].y = tiros[i].y - velocidadeTiro * dt
        if tiros[i].y < 0 then
            table.remove(tiros, i)
        end
    end

    for i = #meteoros, 1, -1 do
        local m = meteoros[i]
        m.y = m.y + m.velocidade * dt

        for j = #tiros, 1, -1 do
            if checarColisao(m, tiros[j], 0.3) then
                table.remove(meteoros, i)
                table.remove(tiros, j)
                destruicoesFase = destruicoesFase + 1
                score = score + 1
                break
            end
        end

        if m and m.y > alturaTela then
            table.remove(meteoros, i)
            vidas = vidas - 1
            if vidas <= 0 then
                gameOver = true
            end
        end
    end

    if fase == 1 and destruicoesFase >= 20 then
        iniciarTransicao(2, 10, 150)
    elseif fase == 2 and destruicoesFase >= 10 then
        iniciarTransicao(3)
    end

    if fase == 3 and meteoroFinal then
        meteoroFinal.y = meteoroFinal.y + 40 * dt
        for i = #tiros, 1, -1 do
            if checarColisao(meteoroFinal, tiros[i], 0.6) then
                meteoroFinal.vida = meteoroFinal.vida - 1
                table.remove(tiros, i)
                if meteoroFinal.vida <= 0 then
                    gameOver = true
                end
            end
        end
        return
    end

    tempoUltimoMeteoro = tempoUltimoMeteoro + dt
    if tempoUltimoMeteoro > 1 and fase < 3 then
        criarMeteoro()
        tempoUltimoMeteoro = 0
    end
end

function jogo.draw()
    -- Desenhar fundo fase 2
    if fase == 2 then
        love.graphics.draw(imagemFase2, 0, 0, 0,
            larguraTela / imagemFase2:getWidth(),
            alturaTela / imagemFase2:getHeight()
        )
    else
        love.graphics.clear(0, 0, 0)
    end

    love.graphics.draw(nave.image, nave.x, nave.y, 0, 0.2, 0.2)

    for _, meteoro in ipairs(meteoros) do
        love.graphics.draw(meteoroImagem, meteoro.x, meteoro.y, 0, 0.3, 0.3)
    end

    if meteoroFinal then
        love.graphics.draw(meteoroGigante, meteoroFinal.x, meteoroFinal.y, 0, 0.6, 0.6)
        love.graphics.setColor(255, 0, 0)
        love.graphics.printf("Vida do Meteoro Final: " .. meteoroFinal.vida, 0, 30, larguraTela, "center")
        love.graphics.setColor(255, 255, 255)
    end

    for _, tiro in ipairs(tiros) do
        love.graphics.draw(tiro.imagem, tiro.x, tiro.y, 0, 0.3, 0.3)
    end

    love.graphics.setFont(fontePontuacao)
    love.graphics.print("Meteoros destruídos: " .. score, 10, 10)
    love.graphics.print("Fase: " .. fase, 10, 40)
    love.graphics.print("Vidas: " .. vidas, 100, 50)
    love.graphics.print("Nave: " .. naveSelecionada, 10, 70)

    if jogoPausado then
        love.graphics.printf("JOGO PAUSADO\nPressione 'P' para continuar\n'M' para menu", 0, alturaTela / 2, larguraTela, "center")
    end

    if emTransicaoDeFase then
        local alpha = alphaTransicao * 255
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, larguraTela, alturaTela)

        love.graphics.setColor(255, 255, 255, alpha)
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.printf(textoTransicao, 0, transicaoTextoY, larguraTela, "center")
        love.graphics.setColor(255, 255, 255, 255)
    end

    if gameOver then
        love.graphics.setColor(255, 0, 0)
        local msg = (fase == 3 and meteoroFinal and meteoroFinal.vida <= 0) and "VITÓRIA! TERRA SALVA!" or "TERRA DESTRUÍDA"
        love.graphics.printf(msg, 0, alturaTela / 2, larguraTela, "center")
        love.graphics.printf("Pressione 'R' para reiniciar", 0, alturaTela / 2 + 40, larguraTela, "center")
        love.graphics.setColor(255, 255, 255)
    end
end

function jogo.keypressed(key)
    if key == "space" and not jogoPausado and not gameOver and not emTransicaoDeFase then
        local escalaBala = 0.3
        local larguraBala = imagemBala:getWidth() * escalaBala
        local alturaBala = imagemBala:getHeight() * escalaBala

        local tiro = {
            imagem = imagemBala,
            largura = larguraBala,
            altura = alturaBala,
            y = nave.y - alturaBala
        }

        tiro.x = nave.x + nave.largura / 2 - larguraBala / 2
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
    elseif key == "1" then
        naveSelecionada = 1
        nave.image = navesDisponiveis[naveSelecionada]
    elseif key == "2" then
        naveSelecionada = 2
        nave.image = navesDisponiveis[naveSelecionada]
    elseif key == "3" then
        naveSelecionada = 3
        nave.image = navesDisponiveis[naveSelecionada]
    end
end

function criarMeteoro()
    local meteoro = {
        x = math.random(0, larguraTela - meteoroImagem:getWidth() * 0.3),
        y = -30,
        velocidade = math.random(velocidadeMeteoro, velocidadeMeteoro + 50),
    }
    table.insert(meteoros, meteoro)
end

function checarColisao(obj1, obj2, escala)
    escala = escala or 0.3
    local obj1Right = obj1.x + meteoroImagem:getWidth() * escala
    local obj1Bottom = obj1.y + meteoroImagem:getHeight() * escala
    local obj2Right = obj2.x + obj2.largura
    local obj2Bottom = obj2.y + obj2.altura

    return obj2.x < obj1Right and obj2Right > obj1.x and
           obj2.y < obj1Bottom and obj2Bottom > obj1.y
end

function iniciarTransicao(novaFase, novoAlvo, novaVelocidade)
    emTransicaoDeFase = true
    fase = novaFase
    alvoFase = novoAlvo or alvoFase
    velocidadeMeteoro = novaVelocidade or velocidadeMeteoro
    destruicoesFase = 0
    meteoros = {}
    tiros = {}
    tempoTransicao = 0
    alphaTransicao = 0
    transicaoTextoY = alturaTela
    textoTransicao = "Fase " .. fase .. " começando..."
    mostrarImagemFase2 = (fase == 2)
end

return jogo
