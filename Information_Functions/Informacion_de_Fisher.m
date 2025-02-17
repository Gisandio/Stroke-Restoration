%********************************************************************
%     Calculo de la Información de Fisher
%********************************************************************

function informacion_fisher = Informacion_de_Fisher(PDF)

    if any(PDF==1)
        F0 = 1;
    else
        F0 = 0.5;
    end
    informacion_fisher = F0*sum((sqrt(PDF(2:end))-sqrt(PDF(1:(end-1)))).^2);
end