-- Função para desenhar os controles
local controles = {}

function controles.desenharControles()
    love.graphics.setColor(255, 255, 255)  
    love.graphics.printf(
        "CONTROLES\n\nSetas - Esquerda/Direita\n Teclado - A/D - Mover Nave\n\nEspaço - Atirar\n\nP - Pausar\n\nBackspace - Voltar",
        0, love.graphics.getHeight() / 4,
        love.graphics.getWidth(),
        "center"
    )
end

return controles
