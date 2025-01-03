function [cuadricula, tamCuadricula] = leerCuadricula(carpetaNumeros)
    cam = webcam;
    
    % Crea una ventana para mostrar el video en tiempo real.
    h = figure; 
    set(h, 'KeyPressFcn', @(src, event) assignin('base', 'keyPressed', true));
    
    keyPressed = false; % Variable para controlar cuando se presiona una tecla
    
    while ishandle(h)
        img = snapshot(cam);
        i = fliplr(img);
        imshow(i, 'InitialMagnification', 'fit');
        drawnow;
    
        if keyPressed
            IPreprocesada = preprocesado(img);
            cuadricula = imprimirMatriz(IPreprocesada, carpetaNumeros);
            tamCuadricula = length(cuadricula);
            keyPressed = false;
        end
    end
    
    close all;
    clear cam;
end
