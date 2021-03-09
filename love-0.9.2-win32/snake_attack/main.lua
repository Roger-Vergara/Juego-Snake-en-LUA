function love.load()
    opcion_menu = 0
    opcion_pausa = 0 
    timer = 0;
    puntaje = 0;
    aumento_velocidad = 0
    cell_size = 30;
    snake = {}
    snake[0] = {x=0, y=300}
    direction = {x=1, y=0}
    comida = {x = math.random(19) * cell_size, y = math.random(14) * cell_size}
    bloque = {x=240, y=150}
    cuenta_celdas = (20 + 15) - 1
    columnas_totales = 19 * cell_size
    filas_totales = 14 * cell_size
    background = love.graphics.newImage("assets/image/fondo.jpg")
    fuente = love.graphics.newFont("assets/fonts/Fipps-Regular.otf", 29)
    --audios
    audio = love.audio.newSource("assets/audio/mus_spider.ogg", "stream")
    audio_ganaste = love.audio.newSource("assets/audio/mus_win.ogg", "stream")
    audio_perdiste = love.audio.newSource("assets/audio/mus_bad.ogg", "stream")
    audio_bola = love.audio.newSource("assets/audio/mus_ball.ogg", "stream")
    love.audio.play(audio)
    estatus = "jugando"

    --Colores de fondo para el menu
    background_red = 10
    background_green = 30
    background_blue = 10
    color_background = {background_red, background_green, background_blue}
    love.graphics.setBackgroundColor(color_background) 
end

function love.draw()
    love.graphics.setFont(fuente);
    --Colores Elementos
    --Si esta en una version superior a 1.9.2 de love2d, cambie el "1" por "255"
    --ya que el juego lo realice en la version 1.9.2 Baby Inspector y no agarra
    --en versiones superiores con "1"
    red = 27 --255 
    green = 200 --255
    blue = 100 --255
    color = {red, green, blue}
    love.graphics.setColor(color)
    

    if opcion_menu == 1 then
        --Pinta la imagen
        love.graphics.draw(background, 0,0)

        --Pinta el snake
        for i = 0, #snake do
          love.graphics.rectangle("fill", snake[i].x, snake[i].y, cell_size, cell_size)
        end
    
        --Pinta la comida
        love.graphics.rectangle("fill", comida.x + 10, comida.y, 10,10)
        love.graphics.rectangle("fill", comida.x, comida.y, 10,10)
        love.graphics.rectangle("fill", comida.x + 20, comida.y, 10,10)
        love.graphics.rectangle("fill", comida.x + 10, comida.y + 20, 10,10)
        love.graphics.rectangle("fill", comida.x, comida.y + 20, 10,10)
        love.graphics.rectangle("fill", comida.x + 20, comida.y + 20, 10,10)
        love.graphics.rectangle("fill", comida.x, comida.y + 10, 10,10)
        love.graphics.rectangle("fill", comida.x + 20, comida.y + 10, 10,10)

        --Pinta el bloque de choque o obstaculo
        love.graphics.rectangle("fill", bloque.x, bloque.y, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x + 30, bloque.y, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x + 60, bloque.y, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x + 30, bloque.y+30, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x, bloque.y+60, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x + 60, bloque.y+60, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x-30, bloque.y+90, cell_size, cell_size)
        love.graphics.rectangle("fill", bloque.x+90, bloque.y+90, cell_size, cell_size)

        --Pinta letras en caso de perder, ganar o pausar
        if estatus == "perdiste" then
            love.graphics.print("Has perdido, que mal :(".."\n".."¿Volver a jugar? ENTER", 32, 32)
            love.audio.pause(audio)
            love.audio.play(audio_perdiste)
        elseif estatus == "ganaste" then
            love.graphics.print("!Ganaste, genial!".."\n", 90, 32);
            love.graphics.print("¿Volver a jugar? ENTER", 22, 92);
        elseif estatus == "pausa" then
            love.graphics.print("Pausado", 185, 32);
        end
        love.graphics.print(puntaje, 530, 380)
    else
        --Pinta las letras del menu
        love.graphics.print("Snake attack", 142,32); 
        love.graphics.print("Preciona J para jugar", 62,92);
        love.graphics.print("P para pausar", 132,142);       
    end 
end

function love.update(dt)
    if opcion_menu == 1 then
        if timer < 0.1 then
            timer = timer + dt + aumento_velocidad
        elseif estatus == "jugando" then
            revisar_ganaste()
            timer = 0
            cambio_posicion() -- Un metodo no puede tener el mismo nombre que una variable. Notas mias
            mover_snake()
            colisiones()
        end 
    end    
end

function cambio_posicion()
    if snake[0].x == comida.x and snake[0].y == comida.y then
        snake[#snake + 1] = {x = comida.x, y = comida.y} --Estiramiento del snake
        while contenedor(snake, comida, 0) do
            cambiar_comida()
            love.audio.play(audio_bola)
            love.audio.rewind(audio_bola)
            puntaje = puntaje + 1
            aumento_velocidad = aumento_velocidad + 0.00040
        end   
    end
end

function mover_snake()
    for i = #snake, 0, -1 do
        if i == 0 then
            snake[i].x = snake[i].x + direction.x * cell_size
            snake[i].y = snake[i].y + direction.y * cell_size
        else
            snake[i].x = snake[i - 1].x
            snake[i].y = snake[i - 1].y
        end
    end
end

function colisiones()
    --Colisiones al superar el limite del mapa
    if snake[0].x > columnas_totales or snake[0].x < 0 then 
        estatus = "perdiste"
    elseif snake[0].y > filas_totales or snake[0].y < 0 then
        estatus = "perdiste"
    end

    --Colisiones del obstaculo
    if snake[0].x == bloque.x and snake[0].y == bloque.y then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x+30 and snake[0].y == bloque.y then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x+60 and snake[0].y == bloque.y then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x+30 and snake[0].y == bloque.y+30 then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x and snake[0].y == bloque.y+60 then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x+60 and snake[0].y == bloque.y+60 then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x-30 and snake[0].y == bloque.y+90 then
        estatus = "perdiste"
    elseif snake[0].x == bloque.x+90 and snake[0].y == bloque.y+90 then
        estatus = "perdiste"
    end

    --Colision del snake al chocar con su cola
    for i=1, #snake do
        if snake[i].x == snake[0].x and snake[i].y == snake[0].y then
            estatus = "perdiste"
        end
    end
end

function revisar_ganaste()
    if puntaje == 20 then
        estatus = "ganaste";
        love.audio.pause(audio)
        love.audio.rewind(audio)
        love.audio.play(audio_ganaste)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "down" and direction.y ~= -1 then
        direction.x = 0 
        direction.y = 1
    elseif key == "up" and direction.y ~= 1 then
        direction.x = 0 
        direction.y = -1
    elseif key == "left" and direction.x ~= 1 then
        direction.x = -1 
        direction.y = 0
    elseif key == "right" and direction.x ~= -1 then
        direction.x = 1 
        direction.y = 0
    elseif key == "return" and estatus ~= "jugando" then
        --Restableciendo valores a predefinidos
        for i=1, #snake do
            snake[i] = nil
        end
        love.audio.pause(audio_ganaste)
        love.audio.rewind(audio_ganaste)
        love.audio.pause(audio_perdiste)
        love.audio.rewind(audio_perdiste)
        love.audio.rewind(audio)
        love.audio.resume(audio)
        snake[0].x = 0
        snake[0].y = 300
        direction.x = 1
        direction.y = 0
        estatus = "jugando"
        puntaje = 0
        aumento_velocidad = 0
        cambiar_comida()
    elseif key == "j" or key == "J" then
        love.audio.rewind(audio)
        love.audio.play(audio)
        opcion_menu = 1
    elseif key == "p" or key == "P" then
        if(opcion_pausa == 0)then
            estatus = "pausa"
            opcion_pausa = 1
        else  
            estatus = "jugando"
            opcion_pausa = 0
        end
    end 
end

function cambiar_comida()
    comida = {x = math.random(19)* cell_size, y = math.random(14) * cell_size}
end

function contenedor(tabla, val, num)
    for i = num, #table do
        if tabla[i].x == val.x and tabla[i].y == val.y then
            return true;
        end
    end
    return false;
end



