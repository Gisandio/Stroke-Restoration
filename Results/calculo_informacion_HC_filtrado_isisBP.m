% This script analyzes the results from the simulations.
%
% Prerequisites:
% To generate the dataset, please run the following script first:
%   main_LFP_generator.m
%
% After generating the dataset, you can analyze the information using:
%   calculo_informacion_HC_filtrado
% Author: Guisande Natalí
% Date: October 1, 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_colors = 4;
% Control points for the custom colormap
control_points = [0 .25 .5 .75 1];

% Colors corresponding to the control points (RGB values)
colorss = flip([157 1 66;  % Color 1: #9d0142
               246 110 69; % Color 2: #f66e45
               249 231 159; % Color 3: #ffffbb
               101 192 174; % Color 4: #65c0ae
               94 79 159]);  % Color 5: #5e4f9f

% Interpolate colors between control points to create the colormap
sampled_colors = interp1(control_points, colorss, linspace(0, 1, num_colors));

% Normalize color values to the range [0, 1]
colors = sampled_colors / 255.0;


% Definir los valores de porcentaje
percentages = [2, 5, 10, 20];
figure('position',[0 0 700 350])
subplot(1,2,1)
hold on
subplot(1,2,2)
hold on
    
% Bucle para cargar cada archivo con el porcentaje correspondiente
for ii = 1:length(percentages)
    percent = percentages(ii);
    D = 5;
    tau = 1;
    Fs = 500; % Sampling frequency (fixed inside cortical_response_resampled)
    filename = sprintf('simulation_data2_numexp1_10X10_percent%d_tf_10000.mat', percent);
    load(filename);
    % Get the size of the restored data
    [M, N] = size(simulation_data.restoredEF(1).experiment(1).I(:,:,:));
    
    % Extract current and potential data for normal and damaged cases
    Current = simulation_data.normal.experiment.I(:,:,:);
    Potential = simulation_data.normal.experiment(1).V(:,:,:);
    Current_damaged = simulation_data.damaged.experiment.I(:,:,:);
    Potential_damaged = simulation_data.damaged.experiment(1).V(:,:,:);
    % Parámetros de Bandt y Pompe

    
    % Inicializar matrices para almacenar información y complejidad
    Information_normal = zeros(M, N);
    Complejidad_normal = zeros(M, N);

    % Procesar datos normales
    for m = 1:M
        for n = 1:N
            [pks, locs] = findpeaks(Potential{m, n}, 'MinPeakHeight', -50);
            ISIs = diff(locs) / Fs; % ISIs en segundos
            if ~isempty(ISIs)
                % Crear el histograma para la PDF
                PDF = Bandt_y_Pompe_PDF_Original(ISIs, 1, D);
                PDF = PDF / sum(PDF); % Normalize PDF
                %PDF = histcounts(ISIs, 'Normalization', 'pdf');
                % Calcular información y complejidad
                Information_normal(m, n) = Informacion_de_Fisher(PDF);
                Complejidad_normal(m, n) = Complejidad_MPR(PDF);
            end
        end
    end

        % Calculate total information and complexity for normal case
    Info_ini = nansum(nansum(Information_normal));
    comple_ini = nansum(nansum(Complejidad_normal));
    % Proceso similar para datos dañados
    Information_damaged = zeros(M, N);
    Complejidad_damaged = zeros(M, N);
    
    for m = 1:M
        for n = 1:N
            if ~isempty(Potential_damaged{m, n}) && all(Potential_damaged{m, n} ~= 0)
                [pks, locs] = findpeaks(Potential_damaged{m, n}, 'MinPeakHeight', -50);
                ISIs = diff(locs) / Fs; % ISIs en segundos
                if ~isempty(ISIs)
                    PDF = Bandt_y_Pompe_PDF_Original(ISIs, 1, D);
                    PDF = PDF / sum(PDF); % Normalize PDF
                    %PDF = histcounts(ISIs, 'Normalization', 'pdf');
                    Information_damaged(m, n) = Informacion_de_Fisher(PDF) / Info_ini;
                    Complejidad_damaged(m, n) = Complejidad_MPR(PDF) / comple_ini;
                end
            end
        end
    end

    % Proceso para datos restaurados
    Info_total = zeros(1, length(simulation_data.EF));
    comple_total = zeros(1, length(simulation_data.EF));

    for i = 1:length(simulation_data.EF)
        Potential_Restored = simulation_data.restoredEF(i).experiment(1).V(:,:,:);
        Information = zeros(M, N);
        complejidad = zeros(M, N);

        for m = 1:M
            for n = 1:N
                if ~isempty(Potential_Restored{m, n}) && all(Potential_Restored{m, n} ~= 0)
                    [pks, locs] = findpeaks(Potential_Restored{m, n}, 'MinPeakHeight', -50);
                    ISIs = diff(locs) / Fs; % ISIs en segundos
                    if ~isempty(ISIs)
                        PDF = Bandt_y_Pompe_PDF_Original(ISIs, 1, D);
                        PDF = PDF / sum(PDF); % Normalize PDF
                        %PDF = histcounts(ISIs, 'Normalization', 'pdf');
                        Information(m, n) = Informacion_de_Fisher(PDF) / Info_ini;
                        complejidad(m, n) = Complejidad_MPR(PDF) / comple_ini;
                    end
                end
            end
        end
        Info_total(i) = nansum(nansum(Information));
        comple_total(i) = nansum(nansum(complejidad));
    end
    % Find the maximum information and complexity
    [max_info, max_info_index] = max(Info_total);
    plasticity_info = simulation_data.EF(max_info_index);
    
    [max_complexity, max_complexity_index] = max(comple_total);
    plasticity_complexity = simulation_data.EF(max_complexity_index);
    
  
    % Subplot for Information
    subplot(1,2,1)
    plot([0 simulation_data.EF],[Info_dame Info_total],'color',colors(ii,:),'LineWidth', 3)
    x_values = xlim; % Get current x-axis limits
    %line(x_values, [Info_ini Info_ini], 'LineStyle', '--', 'Color', 'k'); % Dashed line
    %line(x_values, [Info_ini Info_ini], 'LineStyle', '--', 'Color', 'k'); % Dashed line
    
    axis square
    ylabel('Información de Fisher', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
    xlabel('Plasticidad', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
    xlim([0 20])
    
    % Annotate maximum information
    %text(plasticity_info, max_info, sprintf('%.2f', plasticity_info), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10, 'Color', colors(ii,:)/255);
    
    % Subplot for Complexity
    subplot(1,2,2)
    plot([0 simulation_data.EF],[comple_dame comple_total],'color',colors(ii,:),'LineWidth', 3,'DisplayName', [num2str(percentages(ii)) '%'])
    x_values = xlim; % Get current x-axis limits
    %line(x_values, [comple_ini comple_ini], 'LineStyle', '--', 'Color', 'k'); % Dashed line
    ylabel('Complejidad estadística', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
    xlabel('Plasticidad', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
    axis square
    xlim([0 20])
end
% Añadir leyenda
hLegend = legend('show');  % Mostrar la leyenda con los DisplayName definidos
% Quitar el borde de la leyenda
set(hLegend, 'Box', 'off'); 
box off
% Establecer el título de la leyenda
title(hLegend, 'Lesión');
   titulo=sprintf('Bant & Pompe (D = %d ,\\tau = %d y frecuencia de corte = %dHz)',D,tau,cutoff_frequency);
    suptitle(titulo)%(N^{1/2})
    
    %set(gcf, 'Color', [255/255, 252/255, 242/255])
