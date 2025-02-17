% Definir las bandas de frecuencia
bands = struct('name', {'delta', 'theta', 'alpha', 'beta', 'gamma', 'gamma_{high}'}, ...
               'values', {[1 4], [4 8], [8 13], [13 30], [30 80], [80 99]});

% Inicializar almacenamiento para información y complejidad iniciales por banda
Info_ini_band = zeros(1, length(bands));
Comple_ini_band = zeros(1, length(bands));

% Colores personalizados para graficar
num_colors = length(bands);
control_points = linspace(0, 1, num_colors);
colorss = flip([157 1 66; 246 110 69; 249 231 159; 101 192 174; 94 79 159]);
colors = interp1([0 .25 .5 .75 1], colorss, control_points) / 255.0;
        percent = 2;
        filename = sprintf('simulation_data2_numexp1_10X10_percent%d_tf_10000.mat', percent);
        load(filename);
% Iterar sobre cada banda
for j = 1:length(bands)
    band_values = bands(j).values;
    fprintf('Calculando para la banda: %s\n', bands(j).name);
    
    % Inicializar matrices para almacenar información y complejidad para cada porcentaje
 
    Info_percents = zeros(1, length(percentages));
    Comple_percents = zeros(1, length(percentages));

    % Iterar sobre cada archivo de porcentaje
  

        
        % Parámetros de Bandt & Pompe
        D = 5; 
        tau = 1; 
        Fs = 500; 

        % Tamaño de los datos
        [M, N] = size(simulation_data.restoredEF(1).experiment(1).I(:,:,:));
        
        % Datos de corriente y potencial en el caso normal
        Potential = simulation_data.normal.experiment(1).V(:,:,:);
        
        % Matrices para información y complejidad
        Information_normal = zeros(M, N);
        Complejidad_normal = zeros(M, N);
        
        % Procesar los datos normales
        for m = 1:M
            for n = 1:N
                datos_filtrados = bandpass(Potential{m, n}, band_values, Fs);
                PDF = Bandt_y_Pompe_PDF_Original(datos_filtrados, tau, D);
                PDF = PDF / sum(PDF);
                
                % Calcular la información y complejidad
                Information_normal(m, n) = Informacion_de_Fisher(PDF);
                Complejidad_normal(m, n) = Complejidad_MPR(PDF);
            end
        end
        
        % Almacenar valores iniciales de información y complejidad
        Info_ini_band(j) = nansum(nansum(Information_normal));
        Comple_ini_band(j) = nansum(nansum(Complejidad_normal));
  
end
%%
% Graficar los resultados
figure('Position', [100, 100, 800, 400]);
clear bar
% Subplot para Información
subplot(1, 2, 1);
bar(Info_ini_band, 'FaceColor', 'flat');
for k = 1:num_colors
    set(gca, 'XTickLabel', {bands.name});
    bar(k).CData = colors(k, :);
end
ylabel('Información de Fisher');
xlabel('Bandas de frecuencia');
title('Información inicial por banda');
clear bar
% Subplot para Complejidad
subplot(1, 2, 2);
bar(Comple_ini_band, 'FaceColor', 'flat');
for k = 1:num_colors
    set(gca, 'XTickLabel', {bands.name});
    bar(k).CData = colors(k, :);
end
ylabel('Complejidad estadística');
xlabel('Bandas de frecuencia');
title('Complejidad inicial por banda');

suptitle('Información y Complejidad iniciales por Banda de Frecuencia');
