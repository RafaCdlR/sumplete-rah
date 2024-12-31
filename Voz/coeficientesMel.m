function coefMel = coeficientesMel(tramasPalabra, bancoFiltrosMel)
    fftTrama = fft(tramasPalabra);
    fftTrama(1, :) = [];
    mitadTramas = round(size(tramasPalabra, 1) * 0.5);
    tramasMod = abs(fftTrama(1:mitadTramas + 1, :));

    energiaFiltros = bancoFiltrosMel * tramasMod;
    logEnergia = log10(energiaFiltros);
    coefMel = dct(logEnergia);
end