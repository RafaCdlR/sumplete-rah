function energia = logEnergia(tramas)
    energia = log10(sum(tramas.^2, 1));
end