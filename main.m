clc;
clear;
close all;

%------------------------------------
%
% Configuraciones
%
%------------------------------------

% De HMM
config.Fs = 8000;
config.DuracionGrabacion = 2;
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
[cuadricula, tamCuadricula] = leerCuadricula();

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