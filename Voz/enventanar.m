function tramasEnventanadas = enventanar(tramas, tipoVentana)
    tipos = {'rectangular', 'hanning', 'hamming'};
    f = size(tramas, 1);

    if ~ismember(tipoVentana, tipos)
        warning('Tipo de ventana no válida. Se escogerá "hanning" por defecto.')
        tipoVentana = tipos{2};
    end
    
    if strcmp(tipoVentana, tipos{1})
        ventana = rectwin(f);
    elseif strcmp(tipoVentana, tipos{2})
        ventana = hanning(f);
    else
        ventana = hamming(f);
    end

    tramasEnventanadas = tramas .* ventana;
end