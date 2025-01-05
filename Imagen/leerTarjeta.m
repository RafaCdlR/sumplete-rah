function num = leerTarjeta()
    close all;
    cam = webcam;
    
    % Crea una ventana para mostrar el video en tiempo real.
    h = figure; 
    keyPressed = false; % Variable para controlar cuando se presiona una teclas
    salir = false;
    
    % Define el callback para manejar la pulsación de teclas
    set(h, 'KeyPressFcn', @(~, ~) setKeyPressed());
    
    while ishandle(h) && ~salir
        img = snapshot(cam);
        imshow(img);
        drawnow;
    
        if keyPressed
            % Procesa la imagen solo si se ha presionado una tecla
            num = preprocesado_extraccion(img);
            keyPressed = false;
            salir = true;
        end
    end
    
    close all;
    clear cam;
    
    % Función anidada para modificar keyPressed
    function setKeyPressed()
        keyPressed = true;
    end
end
