clc;
clear;
close all;

%------------------------------------
%
% Configuraciones
%
%------------------------------------

% Dependencias (añadir subdirectorios con funciones)
addpath("Voz/");
addpath("Imagen/");
addpath("juego/");

% De imagen
config.carpetaNumeros = 'Imagen/NUMEROS';
config.carpetaTarjetas = 'Imagen/TARJETAS';

% De HMM
config.Fs = 8000;
config.duracionGrabacion = 2;
config.K = 768; % Mejor número de centroides
config.N = 12; % Mejor número de estados
config.codebookCarpeta = 'Voz/Codebooks';
config.modelosCarpeta = 'Voz/ModelosHMM';
config.maxIntentos = 5; % Máximo de intemos para adivinar f y c por voz


%------------------------------------
%
% Código principal
%
%------------------------------------

% Cargar todos los modelos con K y N
[codebooks, modelosHMM] = cargarCodebooksModelos(config);

% Obtiene la cuadricula
while true
    [cuadricula, tamCuadricula, imagen] = leerCuadricula(config.carpetaNumeros);
    
    if isempty(cuadricula)
        warning("Hubo un error al reconocer la cuadrícula. Por favor, muestre la plantilla de nuevo.")
    else
        break;
    end
end

figure, 
imshow(imagen);

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
            disp(cuadricula);
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

% TODO:
% Obtiene los objetivos
[trgf, trgc] = sumpleteTargets(cuadricula); 

% Cuadro de marcas
marks = false(tamCuadricula);

% Suma de las marcas for filas y por columnas
[sumf, sumc] = suma_estado(cuadricula, marks);

% Mostrar foto con cuadricula
mostrarTablero(cuadricula, marks, trgf, trgc, sumf, sumc);

% Inicializa score
scr = score(sumf, sumc, trgf, trgc);

% ---------------------- Bucle principal ----------------------------

% La puntuacion maxima es 10
while scr < 10
    % Seleccionar método: imagen o voz
    while true
        seleccionarReconocedor = lower(input('Elija un método: Imagen(I) / Voz(V): ', 's'));
    
        if ismember(seleccionarReconocedor, ['i', 'v'])
            break;  
        else
            warning('Por favor, elija un método válido: "I" para Imagen o "V" para Voz.');
        end
    end

    % Reconocimiento de fila o columna
    while true
        if seleccionarReconocedor == 'i'
            [fila, columna] = obtenerFilaColumnaImagen(config.carpetaTarjetas);
        else
            [fila, columna] = obtenerFilaColumnaVoz(codebooks, modelosHMM, config);
        end
        
        if fila < 1 || fila > tamCuadricula || columna < 1 || columna > tamCuadricula
            warning('Fila o columna fuera de rango. Intente nuevamente.');
        else
            break;
        end
    end
    % Fin input

    % Invierte el valor de las marcas hechas
    marks(fila, columna) = ~marks(fila, columna);

    % Calcula de nuevo la puntuacion
    [sumf, sumc] = suma_estado(cuadricula, marks);
    scr = score(sumf, sumc, trgf, trgc);

    mostrarTablero(cuadricula, marks, trgf, trgc, sumf, sumc);
end

if scr >= 10
    disp ("¡Has completado el SUMPLETE!")
end
