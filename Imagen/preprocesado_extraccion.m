function mejorPlantilla = preprocesado_extraccion(I)

    % Convertir la imagen a escala de grises
    I = rgb2gray(I);
    I_p = I;

    Threshold_1 = 170;
     
    % Ajustar valores de los píxeles oscuros
    I_p = imadjust(I_p, [90/255 160/255], [0 1], 0.7);
     
    % Generar imagen binaria
    IBin = (I_p <= Threshold_1);
    IBin(:, 1:round(0.25 * size(IBin, 2))) = 0;
    IBin(:, round(0.75 * size(IBin, 2)):end) = 0;
    
    % Detección de regiones conectadas
    [cuadricula, ~] = bwlabel(IBin); 
    
    % Obtener propiedades de las regiones conectadas
    propiedades = regionprops(cuadricula, 'BoundingBox');
    
    % Filtrar regiones más anchas que altas
    propiedades = propiedades(arrayfun(@(x) x.BoundingBox(3) <= x.BoundingBox(4), propiedades));
    numRegiones = length(propiedades);

    % Cargar plantillas de la carpeta TARJETAS
    plantillas = cell(1, 9);
    for n = 1:9
        filename = fullfile('TARJETAS', sprintf('T_%d.png', n));
        if exist(filename, 'file')
            plantillas{n} = imread(filename);
        else
            error('No se encontró la plantilla %s. Verifica la carpeta.', filename);
        end
    end

    % Inicializar variables para almacenar los mejores resultados
    mejorAutocorrelacion = -Inf;
    mejorPlantilla = -1;

    % Calcular la autocorrelación para cada región
    for k = 1:numRegiones
        % Extraer la región correspondiente
        rect = round(propiedades(k).BoundingBox);
        subRegion = IBin(rect(2):(rect(2) + rect(4) - 1), rect(1):(rect(1) + rect(3) - 1));
        
        % Filtrar regiones que son todo blanco o todo negro
        if all(subRegion(:) == 0) || all(subRegion(:) == 1)
            continue; % Saltar esta región
        end
        
        % Calcular la autocorrelación con cada plantilla
        for n = 1:9
            plantilla = plantillas{n};

            % Redimensionar la región o la plantilla
            [rowsRegion, colsRegion] = size(subRegion);
            [rowsPlantilla, colsPlantilla] = size(plantilla);
            if rowsRegion * colsRegion > rowsPlantilla * colsPlantilla
                % Redimensionar la plantilla al tamaño de la región
                plantillaResized = imresize(plantilla, [rowsRegion, colsRegion]);
                autocorr = normxcorr2(plantillaResized, subRegion);
            else
                % Redimensionar la región al tamaño de la plantilla
                regionResized = imresize(subRegion, [rowsPlantilla, colsPlantilla]);
                autocorr = normxcorr2(plantilla, regionResized);
            end

            % Encontrar el valor máximo de la autocorrelación
            maxCorr = max(autocorr(:));

            % Actualizar si se encuentra una mejor correlación
            if maxCorr > mejorAutocorrelacion
                mejorAutocorrelacion = maxCorr;
                mejorPlantilla = n;
            end
        end
    end
end
