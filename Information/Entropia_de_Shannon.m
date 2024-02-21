%********************************************************************
%     Calculo de la Entropía de Shannon
%********************************************************************

function entropia_de_shannon = Entropia_de_Shannon(PDF)
    N = length(PDF);
    PDF_eq = ones(1,N)/N;
    entropia_maxima = sum(-(PDF_eq(PDF_eq>0).*(log(PDF_eq(PDF_eq>0)))));
    entropia_de_shannon = sum(-(PDF(PDF>0).*(log(PDF(PDF>0)))))/entropia_maxima;
end 



