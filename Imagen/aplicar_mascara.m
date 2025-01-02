function IOut = aplicar_mascara(I, mascaraSize)
    % Función que aplica una máscara en una imagen binarizada y pone a 0
    % los píxeles de regiones donde todos los valores dentro de la máscara son 1.
    %
    % Entrada:
    %   I - Imagen binarizada (matriz lógica o de valores 0 y 1)
    % Salida:
    %   IOut - Imagen binarizada modificada

    [rows, cols] = size(I);

    % Crear una copia de la imagen para trabajar sobre ella.
    IOut = I;

    % Recorrermos la imagen.
    for i = 1:mascaraSize:rows - mascaraSize + 1
        for j = 1:mascaraSize:cols - mascaraSize + 1
            % Extraer la región cubierta por la máscara
            region = IOut(i:i+mascaraSize-1, j:j+mascaraSize-1);

            % Si todos los valores en la región son 1, ponerlos a 0.
            if all(region(:))
                IOut(i:i+mascaraSize-1, j:j+mascaraSize-1) = 0;
            end
        end
    end

    % Poner los bordes de la imagen a negro
    IOut(:, 1:mascaraSize) = 0;
    IOut(:, end-mascaraSize:end) = 0;

    % Mostrar la imagen modificada
    figure, imshow(IOut);
    title('Imagen Modificada');
end
