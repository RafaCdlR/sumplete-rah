% Calcula los objetivos (sumas deseadas) por fila y columna para el Sumplete.
%
% Entrada:
%   matriz - Matriz inicial del tablero con valores.
% Salidas:
%   targetF - Vector con los objetivos de cada fila.
%   targetC - Vector con los objetivos de cada columna.

function [targetF, targetC] = sumpleteTargets(matriz)
    incluir = zeros(size(matriz));

    % Garantizar que al menos un valor por fila sea incluido
    for i = 1:size(matriz, 1)
        col = randi(size(matriz, 2)); 
        incluir(i, col) = 1;
    end

    % Garantizar que al menos un valor por columna sea incluido
    for j = 1:size(matriz, 2)
        fila = randi(size(matriz, 1)); 
        incluir(fila, j) = 1; 
    end

    % Calcular los objetivos
    targetF = sum(matriz .* incluir, 2); 
    targetC = sum(matriz .* incluir, 1)';
end
