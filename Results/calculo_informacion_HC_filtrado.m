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

% Load simulation data
% load('simulation_data_numexp1_20X20_percent10_tf_200.mat')

% Parameters for Bandt and Pompe
D = 6; % Embedding dimension
tau = 1; % Time delay
Fs = 500; % Sampling frequency (fixed inside cortical_response_resampled)
cutoff_frequency = 50; % Cutoff frequency for the filter

% Design a 4th-order Butterworth low-pass filter
[b, a] = butter(4, cutoff_frequency / (Fs / 2), 'low');

% Get the size of the restored data
[M, N] = size(simulation_data.restoredEF(1).experiment(1).I(:,:,:));

% Extract current and potential data for normal and damaged cases
Current = simulation_data.normal.experiment.I(:,:,:); 
Potential = simulation_data.normal.experiment(1).V(:,:,:); 
Current_damaged = simulation_data.damaged.experiment.I(:,:,:); 
Potential_damaged = simulation_data.damaged.experiment(1).V(:,:,:); 

% Initialize matrices for storing information
Information_normal = zeros(M, N);
Complejidad_normal = zeros(M, N);
entropy_normal = zeros(M, N);

% Process normal data
for m = 1:M
    for n = 1:N
        % Apply filter to the original signal
        datos_filtrados = filtfilt(b, a, Potential{m, n});
        PDF = Bandt_y_Pompe_PDF_Original(datos_filtrados, tau, D);
        PDF = PDF / sum(PDF); % Normalize PDF

        % Calculate information, complexity, and entropy
        Information_normal(m, n) = Informacion_de_Fisher(PDF);
        Complejidad_normal(m, n) = Complejidad_MPR(PDF);
        entropy_normal(m, n) = Entropia_de_Shannon(PDF);
    end
end

% Calculate total information and complexity for normal case
Info_ini = nansum(nansum(Information_normal));
comple_ini = nansum(nansum(Complejidad_normal));

% Initialize matrices for storing information for damaged neurons
Information_damaged = zeros(M, N);
Complejidad_damaged = zeros(M, N);
Entropy_damaged = zeros(M, N);

% Process damaged data
for m = 1:M
    for n = 1:N
        if ~isempty(Potential_damaged{m, n}) && all(Potential_damaged{m, n} ~= 0)
            datos_filtrados = filtfilt(b, a, Potential_damaged{m, n});
            PDF = Bandt_y_Pompe_PDF_Original(datos_filtrados, tau, D);
            PDF = PDF / sum(PDF); % Normalize PDF
            
            % Calculate information, complexity, and entropy
            Information_damaged(m, n) = Informacion_de_Fisher(PDF);
            Complejidad_damaged(m, n) = Complejidad_MPR(PDF);
            Entropy_damaged(m, n) = Entropia_de_Shannon(PDF);
        else
            % Assign zero for missing or zero potential
            Information_damaged(m, n) = 0;
            Complejidad_damaged(m, n) = 0;
            Entropy_damaged(m, n) = 0;
        end
    end
end

% Calculate total information and complexity for damaged case
Info_dame = nansum(nansum(Information_damaged));
comple_dame = nansum(nansum(Complejidad_damaged));

% Process restored data for each expansion factor
Info_total = zeros(1, length(simulation_data.EF));
comple_total = zeros(1, length(simulation_data.EF));

for i = 1:length(simulation_data.EF)
    disp(simulation_data.EF(i));
    
    Current_Restored = simulation_data.restoredEF(i).experiment(1).I(:,:,:);
    Potential_Restored = simulation_data.restoredEF(i).experiment(1).V(:,:,:);
    
    Information = zeros(M, N);
    complejidad = zeros(M, N);

    for m = 1:M
        for n = 1:N
            if ~isempty(Potential_Restored{m, n}) && all(Potential_Restored{m, n} ~= 0)
                datos_filtrados = filtfilt(b, a, Potential_Restored{m, n});
                PDF = Bandt_y_Pompe_PDF_Original(datos_filtrados, 1, D);
                PDF = PDF / sum(PDF); % Normalize PDF
                
                % Calculate information and complexity
                Information(m, n) = Informacion_de_Fisher(PDF);
                complejidad(m, n) = Complejidad_MPR(PDF);
            else
                % Assign zero for missing or zero potential
                Information(m, n) = 0;
                complejidad(m, n) = 0;
            end
        end
    end
    
    % Store total information and complexity for each expansion factor
    Info_total(i) = nansum(nansum(Information));
    comple_total(i) = nansum(nansum(complejidad));
end
% Find the maximum information and complexity
[max_info, max_info_index] = max(Info_total);
plasticity_info = simulation_data.EF(max_info_index);

[max_complexity, max_complexity_index] = max(comple_total);
plasticity_complexity = simulation_data.EF(max_complexity_index);

%% Plot Results
figure('position',[0 0 700 350])
colors = [
    157 1 66;     % Color 1: #9d0142 en formato RGB
    246 110 69;   % Color 2: #f66e45 en formato RGB
    249 231 159;  % Color 3: #ffffbb en formato RGB
    101 192 174;  % Color 4: #65c0ae en formato RGB
    94 79 159     % Color 5: #5e4f9f en formato RGB
];

% Subplot for Information
subplot(1,2,1)
plot([0 simulation_data.EF],[Info_dame Info_total],'color',colors(1,:)/255,'LineWidth', 3)
hold on; % Maintain current graph
x_values = xlim; % Get current x-axis limits
line(x_values, [Info_ini Info_ini], 'LineStyle', '--', 'Color', 'k'); % Dashed line
line(x_values, [Info_ini Info_ini], 'LineStyle', '--', 'Color', 'k'); % Dashed line
hold off;
axis square
ylabel('Information', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
xlabel('Plasticity', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
xlim([0 20])

% Annotate maximum information
text(plasticity_info, max_info, sprintf('Max Info: %.2f', plasticity_info), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10, 'Color', colors(1,:)/255);

% Subplot for Complexity
subplot(1,2,2)
plot([0 simulation_data.EF],[comple_dame comple_total],'color',colors(5,:)/255,'LineWidth', 3)
hold on; % Maintain current graph
x_values = xlim; % Get current x-axis limits
line(x_values, [comple_ini comple_ini], 'LineStyle', '--', 'Color', 'k'); % Dashed line
hold off;
ylabel('Statistical Complexity', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
xlabel('Plasticity', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold')
axis square
xlim([0 20])

% Annotate maximum complexity
text(plasticity_complexity, max_complexity, sprintf('Max Complexity: %.2f', plasticity_complexity), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10, 'Color', colors(5,:)/255);

% Title
titulo=sprintf('Bant & Pompe (D = %d ,\\tau = %d and Cutoff Frequency = %dHz)',D,tau,cutoff_frequency);
suptitle(titulo)%(N^{1/2})

set(gcf, 'Color', [255/255, 252/255, 242/255])
