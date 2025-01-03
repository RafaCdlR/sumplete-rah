clc;
clear;
close all;

%------------------------------------
%
% Configuraciones
%
%------------------------------------

% De imagen
config.carpetaNumeros = 'Imagen/NUMEROS';

% De HMM
config.Fs = 8000;
config.duracionGrabacion = 2;
config.K = 512; % Mejor número de centroides
config.N = 9; % Mejor número de estados
config.codebookCarpeta = 'Voz/Codebooks';
config.modelosCarpeta = 'Voz/ModelosHMM';
config.maxIntentos = 5; % Máximo de intemos para adivinar f y c por voz

% De lógica (si tenéis)


%------------------------------------
%
% Código principal
%
%------------------------------------

% Cargar todos los modelos con K y N
[codebooks, modelosHMM] = cargarCodebooksModelos(config);

% Obtiene la cuadricula (falta el tamaño)
[cuadricula, tamCuadricula] = leerCuadricula(config.carpetaNumeros);

% Mostrar foto con cuadricula

% En caso de que esté mal, que lo cambie
while true
    modificar = lower(input('¿Desea modificar algún número en la cuadrícula? (s/n): ', 's'));
    
    if ismember(modificar, ['s', 'n'])
        break;
    else
        disp('Por favor, ingrese "s" para sí o "n" para no.');
    end
end

if modificar == 's'
    while true
        try
            fila = input('Ingrese la fila del número que desea modificar: ');
            columna = input('Ingrese la columna del número que desea modificar: ');
            nuevoNumero = input('Ingrese el nuevo número: ');
            
            % Fila y columna fuera de rango
            if fila < 1 || fila > tamCuadricula || columna < 1 || columna > tamCuadricula
                warning('Fila o columna fuera de rango. Intente nuevamente.');
                continue;
            end
            
            % No ingresó un número o es negativo
            if ~isnumeric(nuevoNumero) || nuevoNumero < 0
                warning('El número debe ser un valor numérico no negativo. Intente nuevamente.');
                continue;
            end
            
            % Realizar la modificación
            cuadricula(fila, columna) = nuevoNumero;
            disp('Número modificado con éxito.');
        catch ME
            disp(['Error durante la modificación: ', ME.message]);
            continue;
        end
        
        otro = lower(input('¿Desea modificar otro número? (s/n): ', 's'));

        if otro ~= 's'
            break;
        end
    end
end

% Seleccionar método: imagen o voz
while true
    seleccionarReconocedor = lower(input('Elija un método: Imagen(I) / Voz(V): ', 's'));

    if ismember(seleccionarReconocedor, ['i', 'v'])
        break;  
    else
        disp('Por favor, elija un método válido: "I" para Imagen o "V" para Voz.');
    end
end

while true
    if seleccionarReconocedor == 'i'
        [f, c] = obtenerFilaColumnaImagen(); % Ibo
    else
        [f, c] = obtenerFilaColumnaVoz(codebooks, modelosHMM, config);
    end
    
    if f < tamCuadricula || c < tamCuadricula
        warning('Fila o columna incorrectas. Se seleccionarán de nuevo.');
    else
        break;
    end
end

% Parte de Rafa
