% Devuelve la suma de cada fila y columna de acuerdo a las marcas puestas
% en el tablero de juego
% 
% INPUT:
%   cuadricula: matriz n x n con los valores del cuadro de juego
%   mark: matriz booleana n x n que almacena las posiciones de juego
%      marcadas
% OUTPUT:
%   sumf: array de n elementos donde sumf[i] = sum(:,i)
%   sumc: array de n elementos donde sumf[i] = sum(i,:)
function [sumf, sumc] = suma_estado(cuadricula, mark)
   masked = cuadricula .* mark;
   sumf = sum(masked, 2)';
   sumc = sum(masked, 1);
end