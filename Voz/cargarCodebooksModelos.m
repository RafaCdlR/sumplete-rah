function [codebooks, modelosHMM] = cargarCodebooksModelos(config)
    % Existe K y N mejores
    if isempty(config.N) || isempty(config.K)
        error('Parámetros K y N deben ser configurados correctamente.');
    end
    
    % Existe la carpeta de Codebooks
    if ~exist(config.codebookCarpeta, 'dir')
        error('No se encontró la carpeta con los codebooks.');
    end
    
    % Existen los modelos de Markov
    if ~exist(config.modelosCarpeta, 'dir')
        error('No se encontró la carpeta con los HMM.');
    end

    codebooks = struct();
    modelosHMM = struct();

    for num = 0:9
        % Cargar el codebook
        codebookFile = fullfile(config.codebookCarpeta, sprintf('codebook_digito_%d_K%d.mat', num, config.K));

        if ~isfile(codebookFile)
            error('No se encontró el archivo %s.', codebookFile);
        end

        codebooks(num + 1).centroids = load(codebookFile, 'centroids').centroids;
    
        % Cargar el modelo HMM 
        modeloFile = fullfile(config.modelosCarpeta, sprintf('HMM_digito_%d_K%d_N%d.mat', num, config.K, config.N));

        if isfile(modeloFile)
            modelo = load(modeloFile);
            modelosHMM(num+1).AFinal = modelo.AFinal;
            modelosHMM(num+1).BFinal = modelo.BFinal;
        else
            error('No se encontró el modelo HMM para el dígito %d.', num);
        end
    end
end