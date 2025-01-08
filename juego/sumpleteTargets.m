% Calcula los objetivos (sumas deseadas) por fila y columna para el Sumplete.
%
% Entrada:
%   matriz - Matriz inicial del tablero con valores.
% Salidas:
%   targetF - Vector con los objetivos de cada fila.
%   targetC - Vector con los objetivos de cada columna.

function [targetF, targetC] = sumpleteTargets(matriz)
    incluir = randi([0, 1], size(matriz)); 

    targetF = sum(matriz .* incluir, 2); % Suma de filas
    targetC = sum(matriz .* incluir, 1); % Suma de columnas
end
