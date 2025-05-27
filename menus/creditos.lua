-- Função para desenhar os creditos

local creditos = {}

local fontePontuacao = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 20)

function creditos.desenharCreditos()
    love.graphics.setFont(fontePontuacao)
    love.graphics.setColor(255, 255, 255)  
    love.graphics.printf(
        "Criadores do Jogo:\n\n\nLucas Ribeiro \n\nNathan Fernandes\n\n\n\n\n\nBackspace - Voltar",
        0, love.graphics.getHeight() / 3,
        love.graphics.getWidth(),
        "center"
    )
end

return creditos
