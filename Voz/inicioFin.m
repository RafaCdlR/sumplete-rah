function [tramasPalabra, tramaInicio, tramaFinal] = inicioFin(tramas, numTramasRuido)
    caracteristicas = extraerCaracteristicas(tramas);
    M = caracteristicas.Magnitud;
    Z = caracteristicas.TasaCeros;
    
    Ms = [M(1:numTramasRuido) M(end - numTramasRuido:end)];  
    Zs = [Z(1:numTramasRuido) Z(end - numTramasRuido:end)];  
    
    muMs = mean(Ms);
    sigmaMs = std(Ms);
    muZs = mean(Zs);
    sigmaZs = std(Zs);
    
    umbSupEnrg = 0.3 * max(M);  
    umbInfEnrg = muMs + 2 * sigmaMs;  
    umbCruCero = muZs + 2 * sigmaZs;  
    
    %% Buscar inicio palabra
    Ln = find(M(numTramasRuido + 1:end) > umbSupEnrg, 1, 'first') + numTramasRuido;
    Le = find(M(numTramasRuido + 1:Ln) < umbInfEnrg, 1, 'last') + numTramasRuido;

    cont = 0;
    tramaInicio = Le;
    for i = Le:-1:max(Le - 25, numTramasRuido + 1)
        if Z(i) < umbCruCero
            cont = 0;
        elseif Z(i) > umbCruCero
            cont = cont + 1;
            if cont >= 3
                tramaInicio = i - 2; % Obtenemos el primero de las veces seguidas
                break;
            end
        end
    end

    %% Buscar fin palabra
    Ln = find(M(numTramasRuido + 1:end) > umbSupEnrg, 1, 'last') + numTramasRuido;
    Le = find(M(Ln:end) < umbInfEnrg, 1, 'first') + Ln - 1;


    tramaFinal = Le;
    cont = 0;
    for i = Le:min(Le + 25, length(M)) 
        if Z(i) < umbCruCero  
            cont = 0;
        elseif Z(i) > umbCruCero
            cont = cont + 1;
            if cont >= 3  
                tramaFinal = i - 2; % Obtenemos el primero de las veces seguidas
                break;
            end
        end
    end

    tramasPalabra = tramas(:, tramaInicio:tramaFinal);
end
