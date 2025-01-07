function [fila, columna] = obtenerFilaColumnaVoz(codebooks, modelosHMM, config)
    fila = -1;
    columna = -1;
    parte = 'fila';
    intentosFallidos = 0;  

    while fila == -1 || columna == -1
        if fila ~= -1 % Ya se asignó la fila, cambiamos a columna
            parte = 'columna';
        end

        fprintf('Pulse Enter para hablar y decir la %s.\n', parte);
        pause();
        
        % Grabar
        recorder = audiorecorder(config.Fs, 16, 1);
        recordblocking(recorder, config.duracionGrabacion);
        audio = getaudiodata(recorder);
        
        % Extraer características
        caracteristicas = obtenerCaracteristicasPalabra(audio, config.Fs);

        % Cuantizar
        mejorProbabilidad = -Inf;
        mejorNumero = -1;

        for num = 0:numel(modelosHMM) - 1
            centroids = codebooks(num + 1).centroids;
            [~, idx] = min(pdist2(caracteristicas', centroids), [], 2); % Cuantización

            % Evaluar 
            AFinal = modelosHMM(num + 1).AFinal;
            BFinal = modelosHMM(num + 1).BFinal;
            [~, logProb] = hmmdecode(idx, AFinal, BFinal);

            if logProb > mejorProbabilidad
                mejorProbabilidad = logProb;
                mejorNumero = num;
            end
        end
        
        if mejorNumero >= 1
            fprintf('Número reconocido: %d\n', mejorNumero);
            correcto = lower(input(sprintf('¿Es correcta la %s seleccionada? (s / n): ', parte), 's'));
            
            if correcto == 's'
                if strcmp(parte, 'fila')
                    fila = mejorNumero;
                else
                    columna = mejorNumero;
                end

                intentosFallidos = 0; 
            end
        else
            disp('No se pudo reconocer el número. Intente nuevamente.');
            intentosFallidos = intentosFallidos + 1;
        end
        
        if intentosFallidos >= config.maxIntentos
            fprintf('El sistema no pudo reconocer la %s después de %d intentos.\n', parte, config.maxIntentos);

            if strcmp(parte, 'fila')
                fila = input('Introduzca manualmente la fila: ');
            else
                columna = input('Introduzca manualmente la columna: ');
            end
        end
    end
end
