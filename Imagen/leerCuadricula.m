function [cuadricula, tamCuadricula] = leerCuadricula(carpetaNumeros)
    cam = webcam;

    % Crea una ventana para mostrar el video en tiempo real.
    h = figure; 
    keyPressed = false; % Variable para controlar cuando se presiona una tecla
    salir = false;

    % Define el callback para manejar la pulsación de teclas
    set(h, 'KeyPressFcn', @(~, ~) setKeyPressed());

    while ishandle(h) && ~salir
        img = snapshot(cam);
        i = fliplr(img);
        imshow(i); 
        drawnow;

        if keyPressed
            % Procesa la imagen solo si se ha presionado una tecla
            IPreprocesada = preprocesado(img);
            cuadricula = imprimirMatriz(IPreprocesada, carpetaNumeros);
            tamCuadricula = length(cuadricula);
            keyPressed = false; % Reinicia la variable
            salir = true;
        end
    end

    close all;
    clear cam;

    function setKeyPressed()
        keyPressed = true;
    end
end
