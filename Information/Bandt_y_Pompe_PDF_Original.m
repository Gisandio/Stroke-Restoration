function [PDF,PDF_noNormalizada,Patrones,Numero_de_patrones,Patrones_prohibidos,Numero_de_patrones_prohibidos] = Bandt_y_Pompe_PDF_Original(serie_temporal,tau,dimension_embedding)
%BANDT_Y_POMPE_PDF Función que calcula la PDF original de Bandt y Pompe.
%     Ref-1: Permutation entropy: a natural complexity for time series
%            Physical Review Letters 88 (2002) 174102
%            C. Bandt, B. Pompe
% Serie_temporal --> Vector con los datos en forma de vector unidimensional
% tau --> Tiempo de elección de los datos (tau = 1 -> consecutivos , tau > 1 -> No consecutivos)
% dimension_embedding = 3 --> Tamaño de la ventana de datos que se consideran
% PDF --> Distribución de probabilidad asociada a las permutaciones
% posibles en la serie
% Patrones --> Matriz que contiene los patrones existentes
% Numero_de_patrones --> Vector que contiene la cantidad de veces que
% aparece cada patrón
% Patrones_prohibidos --> Matriz que contiene los patrones no
% existentes en la serie temporal
% Numero_de_patrones_prohibidos --> Variable que contiene el numero total de
% patrones prohibidos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tamano_del_vector = size(serie_temporal,2); % Tamaño del vector
    numero_de_vectores_maximo = tamano_del_vector - (dimension_embedding - 1)*tau; % Es el máximo número de vectores a armar con la metodología de BP para ese tamaño de serie temporal
    numero_de_tipos_de_patrones_maximo = factorial(dimension_embedding); % Este es el máximo número de bins que vamos a tener en la PDF
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    % Armamos la partición de los datos, así después les sacamos los patrones ordinales
    vectores_a_ordenar = zeros(dimension_embedding,numero_de_vectores_maximo);
                                    
    for indice_patrones = 1:numero_de_vectores_maximo
        vectores_a_ordenar(:,indice_patrones) = serie_temporal(indice_patrones:tau:(indice_patrones+dimension_embedding*tau-1));
    end        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Voy a ver a qué tipo de patrones ordinales corresponden a cada vector 
    % Patrones = zeros(dimension_embedding,numero_de_vectores_maximo); 
    [~,PatronesAux] = sort(vectores_a_ordenar,1);
    [~,Patrones] = sort(PatronesAux,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Voy a generar todos los posibles patrones
    Patrones_posibles = Orden_de_Patrones(dimension_embedding)'; % Matriz que me da todas las posibles permutaciones del vector_a_permutar 1:dimension_embedding
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tengo que ver qué patrones ordinales hay de los posibles, y cuántas
    % veces se repiten
    [~,Indices_de_patrones]=ismember(Patrones',Patrones_posibles','rows'); %Acá encuentro los índices de Patrones_posibles 
    % en los cuales están los Patrones.
    
    % Ahora cuento el número de índices repetidos así conozco la frecuencia
    % de repetición de dicho patrón
    Indices_de_patrones = sort(Indices_de_patrones);
    Repeticiones_de_indices = diff(find(diff([-Inf Indices_de_patrones' Inf])));
    Valores_de_indices_presentes_en_la_serie_temporal = Indices_de_patrones(cumsum(Repeticiones_de_indices));
        
    PDF = zeros(1,numero_de_tipos_de_patrones_maximo);
    PDF_noNormalizada = zeros(1,numero_de_tipos_de_patrones_maximo);
    PDF_noNormalizada(Valores_de_indices_presentes_en_la_serie_temporal)=Repeticiones_de_indices;
    PDF(Valores_de_indices_presentes_en_la_serie_temporal)=Repeticiones_de_indices/sum(Repeticiones_de_indices);
    
    Numero_de_patrones = numel(Valores_de_indices_presentes_en_la_serie_temporal);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Voy a ver los patrones prohibidos y su número
    Patrones_prohibidos = Patrones_posibles;
    Patrones_prohibidos(:,Valores_de_indices_presentes_en_la_serie_temporal') = [];
    Numero_de_patrones_prohibidos = size(Patrones_prohibidos,2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
end

