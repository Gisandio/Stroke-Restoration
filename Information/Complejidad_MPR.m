%********************************************************************
%     Calculo de la Complejidad Martin-Plastino-Rosso
%********************************************************************

function complejidad_MPR = Complejidad_MPR(PDF)
    complejidad_MPR = des_jensen_shannon(PDF)*Entropia_de_Shannon(PDF);
end


