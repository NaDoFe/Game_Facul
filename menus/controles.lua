-- Função para desenhar os controles
local controles = {}

local fontePontuacao = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 20)

function controles.desenharControles()
    love.graphics.setFont(fontePontuacao)
    love.graphics.setColor(255, 255, 255)  
    love.graphics.printf(
        "CONTROLES\n\nSetas - Esquerda/Direita\n Teclado - A/D - Mover Nave\n\nEspaço - Atirar\n\nP - Pausar\n\nTeclas '1' ao '3' selecionar a nave\n\n\nBackspace - Voltar",
        0, love.graphics.getHeight() / 4,
        love.graphics.getWidth(),
        "center"
    )
end

return controles
