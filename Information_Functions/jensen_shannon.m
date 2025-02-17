%********************************************************************
%     Calculo de la Divergencia de Jensen-Shannon
%********************************************************************

function jensen_shannon = jensen_shannon(PDF)
    N = length(PDF);
    PDF_eq = ones(1,N)/N;
    PDF2 = (PDF+PDF_eq)/2;
    jensen_shannon = sum(-(PDF2(PDF2>0).*(log(PDF2(PDF2>0)))))-sum(-(PDF(PDF>0).*(log(PDF(PDF>0)))))/2-sum(-(PDF_eq(PDF_eq>0).*(log(PDF_eq(PDF_eq>0)))))/2;
end