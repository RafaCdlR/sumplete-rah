function [resultadoMatriz, imagenEtiquetada] = imprimirMatriz(IBin, carpetaNumeros)
    if ~exist(carpetaNumeros, 'dir')
        error('No se encontró la carpeta con los números.');
    end

    % Convertir la imagen binaria a uint8 para que sea compatible con insertText
    IBint = IBin;
    IBint = uint8(IBint) * 255; % Escalar a 255 para que sea visible como imagen
    imagenEtiquetada = repmat(IBint, 1, 1, 3); % Convertir a RGB

    % Identificar las regiones conectadas
    [cuadricula, ~] = bwlabel(IBin);

    % Extraer propiedades de las regiones
    propiedades = regionprops(cuadricula, 'Area', 'BoundingBox', 'EulerNumber', 'Centroid');

    % Filtrar regiones con área fuera del rango.
    propiedades([propiedades.Area] > 250 | [propiedades.Area] < 30) = []; 
    numRegiones = length(propiedades);

    pareja = zeros(numRegiones, 2);

    % Hay números de 2 cifras.
    if sqrt(numRegiones) ~= fix(sqrt(numRegiones))  
        centroids = cat(1, propiedades.Centroid);
        % hold on;
        % plot(centroids(:,1), centroids(:,2), 'r*');
       
        % Calcular la matriz de distancias entre todos los centroides
        distMatrix = pdist2(centroids, centroids);
        
        % Para cada región, encontrar la región más cercana (excluyendo la propia)
        [minDist, closestRegions] = min(distMatrix + eye(size(distMatrix)) * max(distMatrix(:)), [], 2);

        % Identificar las regiones con distancias mínimas superiores al umbral
        umbral = mean(minDist) * 1.25;
        regionesDosCifras = find(minDist <= umbral);

        % Agrupar las regiones de dos cifras
        for i = regionesDosCifras'
            % No procesar una pareja ya asignada
            if pareja(i,1) ~= 0
                continue;
            end

            % La región más cercana que forma un número de dos cifras
            pareja(i,:) = [i closestRegions(i)];
            pareja(closestRegions(i),:) = [i closestRegions(i)];
            
            numRegiones = numRegiones - 1;
        end

        % Mostrar la imagen y los centroides
        % imshow(IBin);
        % hold on;
        % plot(centroids(:,1), centroids(:,2), 'r*');
       
        % Dibujar líneas entre regiones más cercanas
        % for i = 1:size(centroids, 1)
        %     % Coordenadas de la región actual y la más cercana
        %     x = [centroids(i,1), centroids(closestRegions(i),1)];
        %     y = [centroids(i,2), centroids(closestRegions(i),2)];
        % 
        %     % Trazar la línea
        %     plot(x, y, 'g-');
        % end
        % title('Conexiones entre regiones más cercanas');
        % hold off;
    end

    % Solo si se ha detectado NxN regiones
    if sqrt(numRegiones) == fix(sqrt(numRegiones))
        N = sqrt(numRegiones); % Tamaño de la matriz NxN
        lista = zeros(N*N, 3);
        resultadoMatriz = zeros(N);

        % Cargar las plantillas desde la carpeta especificada
        plantillas = cell(1, 10);
        for n = 0:9
            filename = fullfile(carpetaNumeros, sprintf('I_%d.png', n));

            if exist(filename, 'file') 
                plantilla = imread(filename); 
                plantillas{n+1} = plantilla;
            else
                error('No se encontró la plantilla %s. Verifica la carpeta.', filename);
            end
        end

        % Procesar cada región detectada
        for i = 1:size(pareja, 1)
            rect = propiedades(i).BoundingBox;
            filaInicio = round(rect(2));
            filaFin = round(rect(2) + rect(4) - 1);
            colInicio = round(rect(1));
            colFin = round(rect(1) + rect(3) - 1);

            % Extraer la subimagen correspondiente a la región
            region = IBin(filaInicio:filaFin, colInicio:colFin);

            % Determinar los posibles números
            if propiedades(i).EulerNumber == 1
                subRegion = region(:, end-2:end);
                numUnos = sum(subRegion(:));
                numCeros = numel(subRegion) - numUnos;
                if numCeros > numUnos
                    numeros = [1 2 7 5 4];
                elseif numUnos > numCeros
                    niveles = sum(region, 2);
                    if es_un_3(niveles)
                        subRegion = region(:, 1:3);
                        numUnos = sum(subRegion(:));
                        numCeros = numel(subRegion) - numUnos;
                        if numUnos > numCeros
                            numeros = 5;
                        else
                            numeros = 3;
                        end
                    else
                        numeros = [2 5 4];
                    end
                else
                    numeros = [1 2 3 4 5 7];
                end
            else
                if propiedades(i).EulerNumber <= -1
                    numeros = 8;
                else
                    numeros = [0 4 6 9];
                end
            end

            % Almacenar el pico máximo para cada plantilla
            maxCorrelaciones = zeros(1, 10);
            for n = numeros
                plantilla = plantillas{n+1};

                % Redimensionar la región o la plantilla para que coincidan
                [rowsRegion, colsRegion] = size(region);
                [rowsPlantilla, colsPlantilla] = size(plantilla);
                if rowsRegion * colsRegion > rowsPlantilla * colsPlantilla
                    plantillaResized = imresize(plantilla, [rowsRegion, colsRegion]);
                    autocorr = normxcorr2(plantillaResized, region);
                else
                    regionResized = imresize(region, [rowsPlantilla, colsPlantilla]);
                    autocorr = normxcorr2(plantilla, regionResized);
                end

                % Encontrar el valor máximo de la autocorrelación
                maxCorrelaciones(n+1) = max(autocorr(:));
            end

            % Determinar la plantilla que mejor coincide
            [~, numeroDetectado] = max(maxCorrelaciones);
            numeroDetectado = numeroDetectado - 1;
            lista(i, :) = [filaInicio colInicio numeroDetectado];

            % Añadir el número detectado como etiqueta en la imagen
             posicionTexto = [colInicio, filaInicio];
             imagenEtiquetada = insertText(imagenEtiquetada, posicionTexto, ...
                 num2str(numeroDetectado), 'TextColor', 'red', ...
                 'BoxOpacity', 0, 'FontSize', 18);
        end

        % Mostrar la imagen original con las etiquetas
         figure, imshow(imagenEtiquetada);
         title('Imagen con regiones identificadas y etiquetadas');

        lista = juntarCifras(pareja, lista);
        resultadoMatriz = rellenarMatriz(lista);
    else
        disp('Los números de la cuadrícula no han sido bien detectados.');
        resultadoMatriz = [];
    end
end

function nuevaLista = juntarCifras(pareja, lista)

    unaCifra = find(sum(pareja, 2) == 0);
    pareja(unaCifra, :) = [];

    [parejaUnica, ~] = unique(pareja, 'rows', 'stable');
    nuevaLista = zeros(size(parejaUnica,1)+length(unaCifra), 3);
    for i = 1:size(parejaUnica, 1)
        valor = lista(parejaUnica(i,1),3)*10 + lista(parejaUnica(i,2),3);
        nuevaLista(i,:) = [lista(parejaUnica(i,1),1) lista(parejaUnica(i,1),2) valor];
    end
    nuevaLista(size(parejaUnica, 1)+1:end,:) = lista(unaCifra, :);
end

function bool = es_un_3(niveles)
    bool = false;
    bajando = false;
    cont = 0;

    for i = 2:length(niveles)
        if niveles(i) < niveles(i-1) - 1
            bajando = true;
        elseif bajando && niveles(i) > niveles(i-1) - 1
            bajando = false;
            cont = cont + 1;
        end
        if cont == 2
            bool = true;
            break;
        end
    end
end

function matriz = rellenarMatriz(lista)

    matriz = zeros(sqrt(size(lista,1)));
    posiciones = zeros(size(lista,1), 2);

    cFilas = lista(:, 1);
    [~, h] = sort(cFilas);
    division = reshape(h, [], size(matriz,1));
    
    for i = 1:size(matriz, 1)
        fila = division(:,i);
        posiciones(fila, 1) = i;
        [~, h2] = sort(lista(fila, 2));
        cont = 1;
        for j = 1:size(matriz, 1)
            posiciones(fila(h2(j)), 2) = cont;
            cont = cont + 1;
        end
    end

    for i = 1:size(posiciones, 1)
        matriz(posiciones(i,1), posiciones(i,2)) = lista(i, 3);  
    end
end
