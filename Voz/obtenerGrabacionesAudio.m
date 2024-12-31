%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1. OBTENER AUDIOS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all

% Parámetros
Fs = 8000; % Frecuencia de muestreo
duracion = 1.5; % Duración de grabación
iteraciones = 150; % Número de grabaciones por número

% Carpeta donde se almacenan
carpeta = 'Grabaciones';
if ~exist(carpeta, 'dir') % Si no existe, se crea
    mkdir(carpeta);
end

% Para cada número
for digito = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    % Creamos su carpeta
    digitFolder = fullfile(carpeta, num2str(digito));
    if ~exist(digitFolder, 'dir')
        mkdir(digitFolder);
    end
    
    disp(['Preparado para grabar el dígito: ', num2str(digito)]);
    
    for iteracion = 0:iteraciones
        disp(['Grabando iteración ', num2str(iteracion), ' del dígito ', num2str(digito)]);
        recObj = audiorecorder(Fs, 16, 1); % Grabamos
        recordblocking(recObj, duracion); 
        audioData = getaudiodata(recObj); % Leemos grabación
        
        nombreArchivo = fullfile(digitFolder, ...
            ['digito_' num2str(digito) '_iteracion_' num2str(iteracion) '.wav']);
        audiowrite(nombreArchivo, audioData, Fs);

        if mod(iteracion, 10) == 0
            disp("Descanso. Pulsa enter para continuar.");
            pause();
        end
    end
end