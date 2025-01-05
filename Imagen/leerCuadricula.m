function [cuadricula, tamCuadricula] = leerCuadricula()
    cam = webcam;

    % Crea una ventana para mostrar el video en tiempo real.
    h = figure; 
    keyPressed = false; % Variable para controlar cuando se presiona una tecla

    % Define el callback para manejar la pulsación de teclas
    set(h, 'KeyPressFcn', @(~, ~) setKeyPressed());

    while ishandle(h)
        img = snapshot(cam);
        i = fliplr(img);
        imshow(i); 
        drawnow;

        if keyPressed
            % Procesa la imagen solo si se ha presionado una tecla
            IPreprocesada = preprocesado(img);
            cuadricula = imprimirMatriz(IPreprocesada);
            tamCuadricula = length(cuadricula);
            keyPressed = false; % Reinicia la variable
        end
    end

    close all;
    clear cam;

    function setKeyPressed()
        keyPressed = true;
    end
end
