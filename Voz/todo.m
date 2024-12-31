clc;
clear;
close all;

% Opciones
obtenerCaracteristicasEntrenamiento = false;
obtenerCaracteristicasPrueba = false;
obtenerCodebook = false;
entrenarModelos = false;
evaluarModelos = true;
reconocerVoz = false;


% Parámetros
Fs = 8000;
tiempoTrama = 0.03;
tiempoDesplTrama = 0.01;
a = 0.95;
ventana = 'hamming';
numTramasRuido = 10;
longTrama = round(Fs * tiempoTrama);
longDespTrama = round(Fs * tiempoDesplTrama);
longVentanaDelta = 5; 
numCepstrum = 30;

kValues = [512]; % Valores de K a probar
nEstados = [9]; % Número de estados a probar

% Carpetas
carpetaGrabaciones = 'Grabaciones'; 
carpetaGrabacionesTest = 'GrabacionesTest'; 
carpetaCaracteristicas = 'Caracteristicas'; 
carpetaCaracteristicasTest = 'CaracteristicasTest'; 
carpetaCodebooks = 'Codebooks'; 
carpetaOutput = 'ModelosHMM'; 

% Crear todas las carpetas necesarias
if ~exist(carpetaCaracteristicas, 'dir')
    mkdir(carpetaCaracteristicas);
end

if ~exist(carpetaCodebooks, 'dir')
    mkdir(carpetaCodebooks);
end

if ~exist(carpetaOutput, 'dir')
    mkdir(carpetaOutput);
end

if ~exist(carpetaCaracteristicasTest, 'dir')
    mkdir(carpetaCaracteristicasTest);
end


%% Obtener características para entrenamiento
bancoFiltrosMel = generarBancoFiltros(Fs, longTrama);

if obtenerCaracteristicasEntrenamiento
    disp("Obteniendo características para entrenamiento...");
    
    for numero = 0:9
        % Crear subcarpeta para guardar las características del número actual
        digitFolder = fullfile(carpetaCaracteristicas, num2str(numero));
        if ~exist(digitFolder, 'dir')
            mkdir(digitFolder);
        end
        
        digitGrabaciones = fullfile(carpetaGrabaciones, num2str(numero));
        archivos = dir(fullfile(digitGrabaciones, '*.wav'));
        
        for j = 1:length(archivos)
            % Leer audio
            archivoAudio = fullfile(digitGrabaciones, archivos(j).name);
            [senal, Fs] = audioread(archivoAudio);
            
            % Preenfasis
            senal = preenfasis(senal, a); 
            % Segmentar
            tramas = segmentacion(senal, longTrama, longDespTrama);
            [tramasPalabra, inicio, fin] = inicioFin(tramas, numTramasRuido);
            tramasPalabra = enventanar(tramasPalabra, ventana); % Enventanamiento
            % Coeficientes
            coefMel = coeficientesMel(tramasPalabra, bancoFiltrosMel);
            coefMel = liftering(coefMel', numCepstrum);
            % Delta y Delta-Delta
            deltaCoefMel = MCCDelta(coefMel, longVentanaDelta);
            deltaDeltaCoefMel = MCCDelta(deltaCoefMel, longVentanaDelta);
            % Energía
            energia = logEnergia(tramasPalabra);
            % Unir carácterísticas
            caracteristicas = [energia; coefMel'; deltaCoefMel'; deltaDeltaCoefMel'];
    
            % Guardar archivo características
            nombreArchivo = fullfile(digitFolder, ['iteracion_' num2str(j) '.mat']);
            save(nombreArchivo, 'caracteristicas');
        end
    end
    
    disp("Características de entrenamiento obtenidas.");
end


%% Obtener características para prueba
if obtenerCaracteristicasPrueba
    disp("Obteniendo características para pruebas...");
    
    for numero = 0:9
        % Crear subcarpeta para guardar las características del número actual
        digitFolder = fullfile(carpetaCaracteristicasTest, num2str(numero));
        if ~exist(digitFolder, 'dir')
            mkdir(digitFolder);
        end
        
        digitGrabaciones = fullfile(carpetaGrabacionesTest, num2str(numero));
        archivos = dir(fullfile(digitGrabaciones, '*.wav'));
        
        for j = 1:length(archivos)
            % Leer audio
            archivoAudio = fullfile(digitGrabaciones, archivos(j).name);
            [senal, Fs] = audioread(archivoAudio);
            
            % Preenfasis
            senal = preenfasis(senal, a); 
            % Segmentar
            tramas = segmentacion(senal, longTrama, longDespTrama);
            [tramasPalabra, inicio, fin] = inicioFin(tramas, numTramasRuido);
            tramasPalabra = enventanar(tramasPalabra, ventana); % Enventanamiento
            % Coeficientes
            coefMel = coeficientesMel(tramasPalabra, bancoFiltrosMel);
            coefMel = liftering(coefMel', numCepstrum);
            % Delta y Delta-Delta
            deltaCoefMel = MCCDelta(coefMel, longVentanaDelta);
            deltaDeltaCoefMel = MCCDelta(deltaCoefMel, longVentanaDelta);
            % Energía
            energia = logEnergia(tramasPalabra);
            % Unir carácterísticas
            caracteristicas = [energia; coefMel'; deltaCoefMel'; deltaDeltaCoefMel'];
    
            % Guardar archivo características
            nombreArchivo = fullfile(digitFolder, ['iteracion_' num2str(j) '.mat']);
            save(nombreArchivo, 'caracteristicas');
        end
    end
    
    disp("Características de prueba obtenidas.");
end


%% Obtener codebook
if obtenerCodebook
    for numero = 0:9
        digitFolder = fullfile(carpetaCaracteristicas, num2str(numero));
        archivos = dir(fullfile(digitFolder, '*.mat'));
    
        % Advertencia si no se encuentran los archivos de tal número
        if isempty(archivos)
            warning(['No se encontraron archivos para el número ', num2str(numero)]);
            continue;
        end
    
        % Unimos todas las características del número
        caracteristicasTotales = [];
        for archivo = archivos'
            data = load(fullfile(digitFolder, archivo.name));
            fields = fieldnames(data);
            caracteristicas = data.(fields{1});
    
            caracteristicasTotales = [caracteristicasTotales, caracteristicas];
        end
    
        % Generar un codebook para cada valor de K
        for K = kValues
            disp(['Generando codebook para número ', num2str(numero), ' con K = ', num2str(K)]);
    
            [~, centroids] = kmeans(caracteristicasTotales', K, 'MaxIter', 1000, 'Replicates', 5);
    
            nombreArchivo = fullfile(carpetaCodebooks, ['codebook_digito_' num2str(numero) '_K' num2str(K) '.mat']);
            save(nombreArchivo, 'centroids');
    
            disp(['Codebook guardado: ', nombreArchivo]);
        end
    end
end


%% Entrenar
if entrenarModelos
    for num = 0:9 
        digitFolder = fullfile(carpetaCaracteristicas, num2str(num));
        archivos = dir(fullfile(digitFolder, '*.mat'));
        secuencias = [];
    
        % Cargar las características de cada repetición del dígito 
        for archivo = archivos'
            data = load(fullfile(digitFolder, archivo.name));
            fields = fieldnames(data);
            caracteristicas = data.(fields{1});
    
            % Guardar características en una lista para cada archivo
            secuencias{end + 1} = caracteristicas;
        end
    
        for K = kValues
            % Cargar el codebook correspondiente al dígito y valor de K
            codebookFile = fullfile(carpetaCodebooks, sprintf('codebook_digito_%d_K%d.mat', num, K));
            load(codebookFile, 'centroids');
    
            % Cuantizar las secuencias con el codebook cargado
            secuenciasCuantizadas = cell(size(secuencias));
            for numero = 1:length(secuencias)
                caracteristicas = secuencias{numero};
                [~, idx] = min(pdist2(caracteristicas', centroids), [], 2);
                secuenciasCuantizadas{numero} = idx'; % Secuencia de índices del codebook
            end
    
            % Entrenar HMM con diferentes valores de N
            for N = nEstados
                fprintf('Entrenando modelo para dígito %d con K = %d y %d estados...\n', num, K, N);
    
                % Inicializar acumuladores para las matrices finales
                ATotal = zeros(N);
                BTotal = zeros(N, size(centroids, 1));
    
                % Entrenar para cada secuencia
                for numero = 1:length(secuenciasCuantizadas)
                    secuencia = secuenciasCuantizadas{numero};
                    nTimesteps = length(secuencia);
    
                    % A0
                    A0 = zeros(N);
    
                    probabilidad = nTimesteps / N;
                    for j = 1:N - 1
                        A0(j, j) = (probabilidad - 1) / probabilidad;
                        A0(j, j + 1) = 1 / (probabilidad - 1);
                    end
                    A0(N, N) = 1;   
    
                    % B0 
                    B0 = ones(N, size(centroids, 1)) / size(centroids, 1);
    
                    % Entrenar
                    [Ai, Bi] = hmmtrain(secuencia, A0, B0, 'Maxiterations', 1000);
    
                    % Acumular resultados
                    ATotal = ATotal + Ai;
                    BTotal = BTotal + Bi;
                end
    
                % Promedio matrices finales
                AFinal = ATotal / length(secuenciasCuantizadas);
                BFinal = BTotal / length(secuenciasCuantizadas);
    
                % Guardar el modelo entrenado
                modeloFile = fullfile(carpetaOutput, sprintf('HMM_digito_%d_K%d_N%d.mat', num, K, N));
                save(modeloFile, 'AFinal', 'BFinal');
                fprintf('Modelo guardado: %s\n', modeloFile);
            end
        end
    end
end


%% Evaluar
if evaluarModelos
    resultadosGlobales = [];
    resultadosPorNumero = zeros(10, 3); % [Número, Aciertos, Total Pruebas]
    
    for K = kValues
        for N = nEstados
            fprintf('\nEvaluando para K = %d, N = %d...\n', K, N);
            
            % Cargar todos los codebooks y modelos HMM correspondientes
            codebooks = struct();
            modelosHMM = struct();
            
            for num = 0:9
                % Cargar el codebook para este dígito
                codebookFile = fullfile(carpetaCodebooks, sprintf('codebook_digito_%d_K%d.mat', num, K));
                if ~isfile(codebookFile)
                    error('No se encontró el archivo %s.', codebookFile);
                end
                codebooks(num+1).centroids = load(codebookFile, 'centroids').centroids;
                
                % Cargar el modelo HMM para este dígito
                modeloFile = fullfile(carpetaOutput, sprintf('HMM_digito_%d_K%d_N%d.mat', num, K, N));
                if ~isfile(modeloFile)
                    error('No se encontró el archivo %s.', modeloFile);
                end
                
                % Cargar los datos del modelo y asignarlos explícitamente
                datosModelo = load(modeloFile); % Cargar datos del archivo
                modelosHMM(num+1).AFinal = datosModelo.AFinal;
                modelosHMM(num+1).BFinal = datosModelo.BFinal;
            end
            
            % Inicializar variables para evaluación
            aciertos = 0;
            totalPruebas = 0;
            aciertosPorNumero = zeros(10, 1);
            pruebasPorNumero = zeros(10, 1);
            
            for num = 0:9
                % Carpeta de pruebas para el dígito actual
                testFolder = fullfile(carpetaCaracteristicas, num2str(num));
                testArchivos = dir(fullfile(testFolder, '*.mat'));
                
                for archivoTest = testArchivos'
                    % Cargar las características del archivo de prueba
                    dataTest = load(fullfile(testFolder, archivoTest.name));
                    fieldsTest = fieldnames(dataTest);
                    caracteristicasTest = dataTest.(fieldsTest{1});
                    
                    % Cuantizar las características usando cada codebook y evaluar
                    mejorProbabilidad = -Inf;
                    mejorDigito = -1;
                    
                    for modeloDigito = 0:9
                        centroids = codebooks(modeloDigito+1).centroids;
                        [~, idxTest] = min(pdist2(caracteristicasTest', centroids), [], 2); % Cuantización
                        
                        % Evaluar con el modelo HMM del dígito
                        modelo = modelosHMM(modeloDigito+1);
                        [~, logProb] = hmmdecode(idxTest, modelo.AFinal, modelo.BFinal);
                        
                        % Verificar si este es el mejor dígito hasta ahora
                        if logProb > mejorProbabilidad
                            mejorProbabilidad = logProb;
                            mejorDigito = modeloDigito;
                        end
                    end
                    
                    % Correcto?
                    if mejorDigito == num
                        aciertos = aciertos + 1;
                        aciertosPorNumero(num+1) = aciertosPorNumero(num+1) + 1;
                    end
                    pruebasPorNumero(num+1) = pruebasPorNumero(num+1) + 1;
                    totalPruebas = totalPruebas + 1;
                end
            end
            
            % Calcular la tasa de acierto global
            accuracyGlobal = (aciertos / totalPruebas) * 100;
            resultadosGlobales = [resultadosGlobales; K, N, accuracyGlobal];
            fprintf('Tasa de acierto global para K = %d, N = %d: %.2f%%\n', K, N, accuracyGlobal);
            
            % Calcular la tasa de acierto por número
            fprintf('Tasa de acierto por número para K = %d, N = %d:\n', K, N);
            for num = 0:9
                if pruebasPorNumero(num+1) > 0
                    porcentaje = (aciertosPorNumero(num+1) / pruebasPorNumero(num+1)) * 100;
                else
                    porcentaje = 0; % No se realizaron pruebas para este número
                end
                resultadosPorNumero(num+1, :) = [num, aciertosPorNumero(num+1), pruebasPorNumero(num+1)];
                fprintf('  Número %d: %.2f%% (%d/%d)\n', num, porcentaje, aciertosPorNumero(num+1), pruebasPorNumero(num+1));
            end
        end
    end
end

if reconocerVoz
    % Configuración inicial
    config.duracionGrabacion = 2; % Duración de la grabación (en segundos)
    config.K = 512; % Mejor K (cantidad de centroides en el codebook)
    config.N = 9; % Mejor N (número de estados del modelo HMM)
    
    % Validar parámetros iniciales
    if isempty(config.N) || isempty(config.K)
        error('Parámetros K y N deben ser configurados correctamente.');
    end
    
    % Cargar codebooks y modelos HMM
    disp('Cargando codebooks y modelos HMM...');
    
    % Inicializar estructuras para almacenar los modelos y codebooks
    codebooks = struct();
    modelosHMM = struct();
    
    for num = 0:9
        % Cargar el codebook
        codebookFile = fullfile(carpetaCodebooks, sprintf('codebook_digito_%d_K%d.mat', num, config.K));
        if ~isfile(codebookFile)
            error('No se encontró el archivo %s.', codebookFile);
        end
        codebooks(num+1).centroids = load(codebookFile, 'centroids').centroids;
    
        % Cargar el modelo HMM correspondiente
        modeloFile = fullfile(carpetaOutput, sprintf('HMM_digito_%d_K%d_N%d.mat', num, config.K, config.N));
        if isfile(modeloFile)
            modelo = load(modeloFile);
            modelosHMM(num+1).AFinal = modelo.AFinal;
            modelosHMM(num+1).BFinal = modelo.BFinal;
        else
            warning('No se encontró el modelo HMM para el dígito %d. Este dígito será omitido.', num);
            modelosHMM(num+1) = []; % Eliminar dígito sin modelo
        end
    end
    
    disp('Sistema de reconocimiento listo. Diga un dígito.');
    
    % Bucle principal de reconocimiento
    while true
        try
            % Grabación de audio
            disp("¡HABLE!");
            recorder = audiorecorder(Fs, 16, 1);
            recordblocking(recorder, config.duracionGrabacion);
            audio = getaudiodata(recorder);
    
            % Extraer características del audio grabado
            caracteristicas = obtenerCaracteristicasPalabra(audio, Fs);
    
            % Cuantizar las características usando los codebooks
            mejorProbabilidad = -Inf;
            mejorDigito = -1;
    
            for num = 0:length(modelosHMM) - 1
                % Cuantizar las características con el codebook correspondiente
                centroids = codebooks(num+1).centroids;
                [~, idx] = min(pdist2(caracteristicas', centroids), [], 2); % Cuantización
    
                % Evaluar probabilidad logarítmica para el modelo HMM
                AFinal = modelosHMM(num+1).AFinal;
                BFinal = modelosHMM(num+1).BFinal;
                [~, logProb] = hmmdecode(idx, AFinal, BFinal);
    
                % Actualizar el mejor dígito basado en la probabilidad logarítmica
                if logProb > mejorProbabilidad
                    mejorProbabilidad = logProb;
                    mejorDigito = num;
                end
            end
    
            % Mostrar el resultado
            if mejorDigito >= 0
                fprintf('Dígito reconocido: %d (Probabilidad: %.2f)\n', mejorDigito, mejorProbabilidad);
            else
                disp('No se pudo reconocer el dígito. Intente nuevamente.');
            end
    
            % Preguntar al usuario si desea continuar
            continuar = input('¿Desea decir otro dígito? (s/n): ', 's');
            if lower(continuar) ~= 's'
                disp('Finalizando el sistema de reconocimiento.');
                break;
            end
        catch ME
            disp(['Error durante la ejecución: ', ME.message]);
            disp('Intente nuevamente.');
        end
    end
end