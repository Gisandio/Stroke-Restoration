%********************************************************************
%     Calculo del Desequilibrio tomando la Divergencia de Jensen-Shannon
%********************************************************************

function des_jensen_shannon = des_jensen_shannon(PDF)
    N = length(PDF); 
    
    Q0 = -2*((N+1)/N*log(1+N)-2*log(2*N)+log(N))^-1;
    
    des_jensen_shannon = Q0*jensen_shannon(PDF);
end