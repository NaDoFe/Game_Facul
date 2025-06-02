local jogo = {}

local nave = {}
local meteoros = {}
local tiros = {}
local meteoroImagem
local meteoroGigante
local imagemBala
local imagemFase1
local imagemFase2
local imagemFase3

local larguraTela = 1350
local alturaTela = 720
love.window.setMode(larguraTela, alturaTela)

local velocidadeNave = 300
local velocidadeTiro = 500
local velocidadeMeteoro = 100
local tempoUltimoMeteoro = 0

local fontePontuacao = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 20)
love.graphics.setFont(fontePontuacao)

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
    love.graphics.newImage("assets/nave/nave1.png"),
    love.graphics.newImage("assets/nave/nave2.png"),
    love.graphics.newImage("assets/nave/nave3.png")
}
local naveSelecionada = 1

-- Sons
local somTiro
local somExplosao
local somDerrota
local somVitoria
local musicaFase1
local musicaFase2
local musicaFase3

function jogo.load()
    nave.image = navesDisponiveis[naveSelecionada]
    meteoroImagem = love.graphics.newImage("assets/meteoro/meteoro.png")
    meteoroGigante = love.graphics.newImage("assets/meteoro/meteoro2.png")
    imagemBala = love.graphics.newImage("assets/nave/bala.png")
    imagemFase1 = love.graphics.newImage("assets/mapa/mapa1.png")
    imagemFase2 = love.graphics.newImage("assets/mapa/mapa2.png")
    imagemFase3 = love.graphics.newImage("assets/mapa/mapa3.png")

    nave.x = larguraTela / 2
    nave.y = alturaTela * 0.85
    nave.largura = nave.image:getWidth()
    nave.altura = nave.image:getHeight()
    nave.velocidade = velocidadeNave

    somTiro = love.audio.newSource("assets/sons/tiro.wav", "static")
    somExplosao = love.audio.newSource("assets/sons/explosao.wav", "static")
    somDerrota = love.audio.newSource("assets/sons/derrota.wav", "static")
    somVitoria = love.audio.newSource("assets/sons/vitoria.wav", "static")

    musicaFase1 = love.audio.newSource("assets/sons/musica_fase1.wav", "stream")
    musicaFase1:setLooping(true)

    musicaFase2 = love.audio.newSource("assets/sons/musica_fase2.wav", "stream")
    musicaFase2:setLooping(true)

    musicaFase3 = love.audio.newSource("assets/sons/musica_fase3.wav", "stream")
    musicaFase3:setLooping(true)

    musicaFase1:setVolume(0.2)
    musicaFase2:setVolume(0.2)
    musicaFase3:setVolume(0.2)
    somExplosao:setVolume(0.2)
    somTiro:setVolume(0.2)
end

function jogo.reiniciar()
    if musicaFase1 and musicaFase1:isPlaying() then musicaFase1:stop() end
    if musicaFase2 and musicaFase2:isPlaying() then musicaFase2:stop() end
    if musicaFase3 and musicaFase3:isPlaying() then musicaFase3:stop() end

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
    love.graphics.setFont(fontePontuacao)
    mostrarImagemFase2 = false
    nave.x = larguraTela / 2
    nave.image = navesDisponiveis[naveSelecionada]
    nave.largura = nave.image:getWidth() * 0.2
    nave.altura = nave.image:getHeight() * 2
end

function jogo.update(dt)
    if gameOver or jogoPausado then return end

    -- Controle da música de fundo
    if fase == 1 then
        if not musicaFase1:isPlaying() then musicaFase1:play() end
        if musicaFase2:isPlaying() then musicaFase2:stop() end
        if musicaFase3:isPlaying() then musicaFase3:stop() end
    elseif fase == 2 then
        if musicaFase1:isPlaying() then musicaFase1:stop() end
        if not musicaFase2:isPlaying() then musicaFase2:play() end
        if musicaFase3:isPlaying() then musicaFase3:stop() end
    elseif fase == 3 then
        if musicaFase1:isPlaying() then musicaFase1:stop() end
        if musicaFase2:isPlaying() then musicaFase2:stop() end
        if not musicaFase3:isPlaying() then musicaFase3:play() end
    end

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
        if tiros[i].y < 0 then table.remove(tiros, i) end
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
                somExplosao:clone():play()
                break
            end
        end

        if m and m.y > alturaTela then
            table.remove(meteoros, i)
            vidas = vidas - 1
            if vidas <= 0 and not gameOver then
                gameOver = true
                somDerrota:play()
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
                somExplosao:clone():play()
                if meteoroFinal.vida <= 0 and not gameOver then
                    gameOver = true
                    somVitoria:play()
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
    if fase == 1 then
        love.graphics.draw(imagemFase1, 0, 0, 0, larguraTela / imagemFase1:getWidth(), alturaTela / imagemFase1:getHeight())
    elseif fase == 2 then
        love.graphics.draw(imagemFase2, 0, 0, 0, larguraTela / imagemFase2:getWidth(), alturaTela / imagemFase2:getHeight())
    else
        love.graphics.draw(imagemFase3, 0, 0, 0, larguraTela / imagemFase3:getWidth(), alturaTela / imagemFase3:getHeight())
    end

    love.graphics.draw(nave.image, nave.x, nave.y, 0, 0.2, 0.2)

    for _, meteoro in ipairs(meteoros) do
        love.graphics.draw(meteoroImagem, meteoro.x, meteoro.y, 0, 0.3, 0.3)
    end

    if meteoroFinal then
        love.graphics.setFont(fontePontuacao)
        love.graphics.draw(meteoroGigante, meteoroFinal.x, meteoroFinal.y, 0, 0.6, 0.6)
        
        love.graphics.setColor(255, 0, 0)
        love.graphics.printf("Vida do Meteoro: " .. meteoroFinal.vida, 0, 30, larguraTela, "center")
        local barraLargura = meteoroFinal.largura
        local barraAltura = 20
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.rectangle("fill", 550, 100, barraLargura * (meteoroFinal.vida / 50), barraAltura)
        love.graphics.setColor(1, 1, 1, 1)

    end

    for _, tiro in ipairs(tiros) do
        love.graphics.draw(tiro.imagem, tiro.x, tiro.y, 0, 0.3, 0.3)
    end

    love.graphics.setFont(fontePontuacao)
    love.graphics.print("Meteoros destruídos: " .. score, 10, 10)
    love.graphics.print("Fase: " .. fase, 10, 40)
    love.graphics.print("Nave: " .. naveSelecionada, 10, 70)
    love.graphics.print("Vidas: " .. vidas, 10, 100)

    if jogoPausado then
        love.graphics.printf("JOGO PAUSADO\nPressione 'P' para continuar\n'M' para menu", 0, alturaTela / 2, larguraTela, "center")
    end

    if emTransicaoDeFase then
        local alpha = alphaTransicao * 255
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, larguraTela, alturaTela)
        love.graphics.setColor(255, 255, 255, alpha)
        love.graphics.setFont(fontePontuacao)
        love.graphics.printf(textoTransicao, 0, transicaoTextoY, larguraTela, "center")
        love.graphics.setColor(255, 255, 255, 255)
    end

    if gameOver then
        love.graphics.setColor(255, 0, 0)
        local msg = (fase == 3 and meteoroFinal and meteoroFinal.vida <= 0) and "VITÓRIA! TERRA SALVA!" or "TERRA DESTRUÍDA"
        love.graphics.printf(msg, 0, alturaTela / 2, larguraTela, "center")
        love.graphics.printf("Pressione 'M' para voltar ao Menu", 0, alturaTela / 2 + 40, larguraTela, "center")
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
        somTiro:clone():play()
    elseif key == "p" then
        jogoPausado = not jogoPausado
    elseif key == "m" and jogoPausado then
        if musicaFase1:isPlaying() then musicaFase1:stop() end
        if musicaFase2:isPlaying() then musicaFase2:stop() end
        if musicaFase3:isPlaying() then musicaFase3:stop() end
        estado = "menu"
        jogoPausado = false
        gameOver = false
    elseif key == "m" and gameOver then
        estado = "menu"
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
    love.graphics.setFont(fontePontuacao)
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
