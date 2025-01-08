cuadricula = ...
[ 2 1 4 2
  3 7 1 2
  9 8 1 4
  5 2 6 9
 ];

tamCuadricula = size(cuadricula,1);

trgf = [6 11 1 11];
trgc = [5 9 6 9];


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

    % Seleccion marca
    while true

            f = input('Introduce fila: ');
            c = input('Introduce columna: ');
        
        
        if f > tamCuadricula || c > tamCuadricula
            warning('Fila o columna incorrectas. Se seleccionarán de nuevo.');
        else
            break;
        end
    end
    % Fin input

    % Invierte el valor de las marcas hechas
    marks(f,c) = ~marks(f,c);

    % Calcula de nuevo la puntuacion
    [sumf, sumc] = suma_estado(cuadricula, marks);
    scr = score(sumf, sumc, trgf, trgc);

    mostrarTablero(cuadricula, marks, trgf, trgc, sumf, sumc);

end

if scr >= 10
    disp ("Has completado el sumplete")
end