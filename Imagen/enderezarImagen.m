% Si la imagen está rotada más de 90 grados ya no funciona.

function [I, angulo] = enderezarImagen(I) 
    % Detectar bordes con Canny y aplicar Hough.
    edges = edge(I, 'canny');
    [H, T, R] = hough(edges);

    % Detectar picos en la transformada de Hough.
    P = houghpeaks(H, 10);
    lines = houghlines(edges, T, R, P);

    % Inicializar variables para encontrar la línea más larga vertical
    maxLen = 0;
    lineaVertical = [];

    for k = 1:length(lines)
        % Extraer puntos de la línea
        xy = [lines(k).point1; lines(k).point2];

        % Calcular la longitud de la línea
        len = sqrt((xy(2,1) - xy(1,1))^2 + (xy(2,2) - xy(1,2))^2);

        % Calcular el ángulo de la línea respecto al eje Y
        delta_y = xy(2,2) - xy(1,2);
        delta_x = xy(2,1) - xy(1,1);
        anguloLinea = atan2d(delta_x, delta_y);

        % Verificar si la línea es "vertical" (ángulo cercano a ±90 grados)
        if abs(anguloLinea) > 45 % Se considera vertical si el ángulo es mayor a 45 grados
            % Actualizar si la longitud es mayor
            if len > maxLen
                maxLen = len;
                lineaVertical = lines(k);
            end
        end
    end

    % Si no se detectaron líneas verticales, retornar la imagen sin cambios
    if isempty(lineaVertical)
        % disp('No se detectaron líneas verticales.');
        angulo = 0;
        return;
    end

    % Dibujar la línea más larga vertical sobre la imagen
    % figure, imshow(edges), title('Línea vertical más larga detectada');
    % hold on;
    xy = [lineaVertical.point1; lineaVertical.point2];
    % plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'red');
    % hold off;

    % Calcular el ángulo de la línea seleccionada respecto al eje Y
    delta_y = xy(2,2) - xy(1,2);
    delta_x = xy(2,1) - xy(1,1);
    angulo = atan2d(delta_x, delta_y);

    % Ajustar el ángulo para que sea respecto al eje Y
    if angulo > 0
        angulo = 90 - angulo; % Rotación hacia la derecha
    else
        angulo = -(90 + angulo); % Rotación hacia la izquierda
    end

    % Rotar la imagen para enderezarla
    I = imrotate(I, angulo);

    % Mostrar la imagen enderezada
    % figure, imshow(I), title('Imagen enderezada');
end