function car = extraerCaracteristicas(tramas)
    % Energia
    energia = sum(tramas.^2, 1);
    % Magnitud
    magnitud = sum(abs(tramas), 1);
    % Tasa cruces cero
    tasa = (sum(abs(sign(tramas(2:end, :)) - sign(tramas(1:end-1, :)))) / 2) / size(tramas, 1);

    car = struct('Energia', energia, 'Magnitud', magnitud, 'TasaCeros', tasa);
end