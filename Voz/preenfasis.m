function senalOut = preenfasis(senal, a)
    senalOut = filter([1 -a], 1, senal);
end