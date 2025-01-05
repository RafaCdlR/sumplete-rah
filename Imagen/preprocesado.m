function IBin = preprocesado(I)
    I = rgb2gray(I);
    I_p = I;

    % Mostrar la imagen original
    % figure, imshow(I_p);
    % Threshold_1 = 170;
     
    % Ajustar valores de los píxeles oscuros
    I_p = imadjust(I_p, [90/255 160/255], [0 1], 0.7);
    % figure, imshow(I_p);
     
    % Generar imagen binaria
    IBin = (I_p <= Threshold_1);

    % Mostrar la imagen binaria
    % figure, imshow(IBin);
    % title("Binary Image");

    % Aplicar máscara
    IBin = aplicarMascara(IBin, 7);
    [IBin, angulo] = enderezarImagen(IBin);

    % Rotamos la imagen original.
    I = imrotate(I, angulo, 'bilinear');

    % Detección de regiones conectadas
    [cuadricula, ~] = bwlabel(IBin); % Etiquetar regiones conectadas

    % Obtener propiedades de las regiones
    propiedades = regionprops(cuadricula, 'BoundingBox', 'Area');
    [~, indx] = max([propiedades.Area]);

    % Mostrar la imagen con la región más grande resaltada
    % figure, imshow(IBin), title('Regiones detectadas');
    % hold on;

    % Obtener el BoundingBox de la región más grande
    rect = propiedades(indx).BoundingBox;

    % Dibujar el rectángulo alrededor de la región más grande
    % rectangle('Position', rect, 'EdgeColor', 'r', 'LineWidth', 2);
    % hold off;

    % Extraer la región detectada y guardarla en una matriz
    filaInicio = round(rect(2));
    filaFin = round(rect(2) + rect(4) - 1);
    colInicio = round(rect(1));
    colFin = round(rect(1) + rect(3) - 1);

    matrizRegion = I(filaInicio:filaFin, colInicio:colFin);

    % Mostrar la región extraída
    % figure, imshow(matrizRegion);
    % title('Matriz de la Región Detectada');
    
    umbral = graythresh(matrizRegion);
    IBin = ~imbinarize(matrizRegion, umbral);
    IBin = imclearborder(IBin);
    ele = strel('square', 2);
    IBin = imopen(IBin,ele);
    figure, imshow(IBin), title("ACABADA");
end
