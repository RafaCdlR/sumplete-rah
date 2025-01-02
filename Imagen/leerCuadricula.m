
function leerCuadricula()

    cam = webcam;
    
    % Crea una ventana para mostrar el video en tiempo real.
    h = figure; 
    set(h, 'KeyPressFcn', @(src, event) assignin('base', 'keyPressed', true));
    
    keyPressed = false; % Variable para controlar cuando se presiona una tecla
    
    while ishandle(h)
        img = snapshot(cam);
        i = fliplr(img);
        imshow(i); 
        drawnow;
    
        if keyPressed
            IPreprocesada = preprocesado(img);
            cuadricula = imprimirMatriz(IPreprocesada);
            keyPressed = false;
        end
    end
    
    close all;
    clear cam;
end
