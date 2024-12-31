function caracteristicas = obtenerCaracteristicasPalabra(audio, Fs)
    % Parámetros
    tiempoTrama = 0.03;
    tiempoDesplTrama = 0.01;
    a = 0.95;
    ventana = 'hamming';
    numTramasRuido = 10;
    longTrama = round(Fs * tiempoTrama);
    longDespTrama = round(Fs * tiempoDesplTrama);
    longVentanaDelta = 5; 
    numCepstrum = 30;
    
    % Banco de filtros Mel
    bancoFiltrosMel = generarBancoFiltros(Fs, longTrama);
    % Preenfasis
    audio = preenfasis(audio, a);
    % Segmentar
    tramas = segmentacion(audio, longTrama, longDespTrama);
    tramasPalabra = inicioFin(tramas, numTramasRuido);
    tramasPalabra = enventanar(tramasPalabra, ventana);
    % Calcular los coeficientes Mel
    coefMel = coeficientesMel(tramasPalabra, bancoFiltrosMel);
    coefMel = liftering(coefMel', numCepstrum); 
    % Calcular las derivadas (Delta y Delta-Delta)
    deltaCoefMel = MCCDelta(coefMel, longVentanaDelta);
    deltaDeltaCoefMel = MCCDelta(deltaCoefMel, longVentanaDelta);
    % Calcular la energía
    energia = logEnergia(tramasPalabra);
    
    % Concatenar características
    caracteristicas = [energia; coefMel'; deltaCoefMel'; deltaDeltaCoefMel'];
end