close all

addpath("Voz/");
addpath("Imagen/");
addpath("juego/");

cuadricula1 = ...
[ 2 1 4 2
  3 7 1 2
  9 8 1 4
  5 2 6 9
 ];


trgf1 = [6 11 1 11];
trgc1 = [5 9 6 9];

cuadricula2 = ...
[ 6 3 1
  4 9 2
  1 1 7
];
trgf2 = [7 2 2];
trgc2 = [7 1 3];


cuadricula = cuadricula2;
trgf = trgf2;
trgc = trgc2;


tamCuadricula = size(cuadricula,1);




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

close all