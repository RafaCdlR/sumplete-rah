function resultadoMatriz = imprimirMatriz(IBin)
    % Convertir la imagen binaria a uint8 para que sea compatible con insertText
    IBint = IBin;
    IBint = uint8(IBint) * 255; % Escalar a 255 para que sea visible como imagen
    imagenEtiquetada = repmat(IBint, 1, 1, 3); % Convertir a RGB

    % Identificar las regiones conectadas
    [cuadricula, ~] = bwlabel(IBin);

    % Extraer propiedades de las regiones
    propiedades = regionprops(cuadricula, 'Area', 'BoundingBox', 'EulerNumber');

    % Filtrar regiones con área fuera del rango [25, 270]
    propiedades([propiedades.Area] > 270 | [propiedades.Area] < 30) = []; 

    % Solo si se ha detectado NxN regiones
    numRegiones = length(propiedades);
    if sqrt(numRegiones) == fix(sqrt(numRegiones))
        N = sqrt(numRegiones); % Tamaño de la matriz NxN
        lista = zeros(N*N, 3);
        resultadoMatriz = zeros(N); % Crear la matriz para los números detectados

        % Cargar las plantillas desde la carpeta especificada
        plantillas = cell(1, 9);
        for n = 1:9
            filename = fullfile('NUMEROS', sprintf('I_%d.png', n));
            if exist(filename, 'file') 
                plantilla = imread(filename); 
                plantillas{n} = plantilla;
            else
                error('No se encontró la plantilla %s. Verifica la carpeta.', filename);
            end
        end

        % Procesar cada región detectada
        for i = 1:numRegiones
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
                    numeros = [4 6 9];
                end
            end

            % Almacenar el pico máximo para cada plantilla
            maxCorrelaciones = zeros(1, 9);
            for n = numeros
                plantilla = plantillas{n};

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
                maxCorrelaciones(n) = max(autocorr(:));
            end

            % Determinar la plantilla que mejor coincide
            [~, numeroDetectado] = max(maxCorrelaciones);
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

        resultadoMatriz = rellenarMatriz(lista);
    else
        disp('Los números de la cuadrícula no han sido bien detectados.');
        resultadoMatriz = [];
    end
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


