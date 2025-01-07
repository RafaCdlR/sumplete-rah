% Calcula la puntuacion sobre 10 que muestra los objetivos cumplidos
function scr = score(sumf, sumc, trgf, trgc)
    completados = sum(sumf == trgf) + sum(sumc == trgc);

    % Filas y columnas
    n = 2 * size(sumf, 1);

    scr = 10*completados/n;
end