function palabra = invSegmentacion(tramasPalabra, despl)
    [numMuestras, numTramas] = size(tramasPalabra);
    longitudPalabra = (numTramas - 1) * despl + numMuestras;
    palabra = zeros(1, longitudPalabra);  
    sumaSolapamiento = zeros(1, longitudPalabra); 
    
    for i = 1:numTramas
        inicio = (i - 1) * despl + 1;
        fin = inicio + numMuestras - 1;
        palabra(inicio:fin) = palabra(inicio:fin) + tramasPalabra(:, i)';
        
        sumaSolapamiento(inicio:fin) = sumaSolapamiento(inicio:fin) + 1;
    end
    
    palabra = palabra ./ sumaSolapamiento;
end
