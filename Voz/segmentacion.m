function tramas = segmentacion(senal, nMuestras, despl)
    tramas = buffer(senal, nMuestras, nMuestras - despl);
end