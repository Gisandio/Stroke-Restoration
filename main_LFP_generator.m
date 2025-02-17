% Script to generate a dataset of LFP (Local Field Potentials)
% Author: Guisande Natalí
% Date: October 1, 2024
%_________________________________________________________________________

% Create the detector matrix. Define the physical size of the detector
% matrix, which limits the size of input signals.
num_rows = 10; % Number of rows in the detector
num_columns = 10; % Number of columns in the detector
matrix_size = [10*num_rows, 10*num_columns];
neurons = num_rows * num_columns; % Total number of receptive fields

% Set the percentage of damaged neurons
percentage =5 ; % Change this value to the desired percentage of damage
m_size = 10; %(7x7 admits damage percentage 2 6 8 18 30)
% - percentage: Damage level as a percentage (1, 2, 5, 10, 20, or 30).
% - m_size:  7, 10 or 20 ( for 7x7, 10x10 or 20x20 matrices).
% Set the total simulation time in ms
tf = 10000; % Time in ms

% Crear una estructura para almacenar los datos
simulation_data = struct();
simulation_data.EF = 0.5:0.5:20; % Vector of expansion factors (plasticity parameters)

%Number of simulations
num_experiments=1;
% Noise level in the LFP data (percentage)
noise = 0.5; % No noise initially, adjust for specific cases

% Use the function to get the damaged neurons based on the percentage
% Uncomment the line below to use the get_damaged_neurons function
damaged_neurons = get_damaged_neurons(percentage,m_size); 

% Or manually specify the damaged neurons
%damaged_neurons = [15 16 21 22]; 6x6 
%damaged_neurons = [32 24 25 26 18]; %7x7
%
%damaged_neurons = [49	50	51  40	41	42  31	32	33]; %9x9
%_________________________________________________________________________

% Define the parameters of individual receptive fields (initially symmetric
% and equal). A is the amplitude of the Gaussian function, while sigma_x
% and sigma_y are the standard deviations of the Gaussian function in the x
% and y directions, respectively.
A = 1.0;
sigma_x = 3;
sigma_y = 3;
% Define additional parameters for receptive field creation
A1 = 1;
A2 = 0.3;
scale_factor = 3;
sigma_x1 = 1 * scale_factor;
sigma_y1 = sigma_x1;
sigma_x2 = 1.5 * sigma_x1;
sigma_y2 = 1.5 * sigma_x1;

%_________________________________________________________________________
% Calculate the steps to distribute receptive fields evenly
step_rows = (matrix_size(1) - 1) / (num_rows - 1);
step_columns = (matrix_size(2) - 1) / (num_columns - 1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**********************************************************************
%                               PLOTS    
%______________________________________________________________________

% Create a custom colormap
num_colors = 64;

% Control points for the custom colormap
control_points = [0 .25 .5 .75 1];

% Colors corresponding to the control points (RGB values)
colors = flip([157 1 66;  % Color 1: #9d0142
               246 110 69; % Color 2: #f66e45
               249 231 159; % Color 3: #ffffbb
               101 192 174; % Color 4: #65c0ae
               94 79 159]);  % Color 5: #5e4f9f

% Interpolate colors between control points to create the colormap
sampled_colors = interp1(control_points, colors, linspace(0, 1, num_colors));

% Normalize color values to the range [0, 1]
sampled_colors = sampled_colors / 255.0;

% Expansion factor for the graphical plots
expansion_factor = 3;

% Create healthy receptive fields using the Normal_Fields function
[centers, FieldNormal, matrix] = Normal_Fields(num_rows, num_columns, step_rows, step_columns, matrix_size, A1, A2, sigma_x1, sigma_y1, sigma_x2, sigma_y2, noise);

% Create damaged receptive fields using the Damaged_Fields function
[FieldDamaged, damaged_matrix] = Damaged_Fields(num_rows, num_columns, step_rows, step_columns, matrix_size, A1, A2, sigma_x1, sigma_y1, sigma_x2, sigma_y2, damaged_neurons, noise);

% Create restored receptive fields using the Restored_Fields function
[FieldRestored, deformed_fields_matrix] = Restored_Fields(num_rows, num_columns, step_rows, step_columns, matrix_size, A1, A2, sigma_x1, sigma_y1, sigma_x2, sigma_y2, damaged_neurons, expansion_factor, centers, noise, A1 - A2);

% Calculate the maximum and minimum values from all matrices for color limits
global_max = max([matrix(:); damaged_matrix(:); deformed_fields_matrix(:)]);
global_min = min([matrix(:); damaged_matrix(:); deformed_fields_matrix(:)]);

% Create a figure with custom positions for the subplots
figure('position', [0 0 1700 650]);

% Define subplot positions manually
pos1 = [0.01, 0.1, 0.31, 0.8];  % First subplot position
pos2 = [0.34, 0.1, 0.31, 0.8];  % Second subplot position
pos3 = [0.67, 0.1, 0.31, 0.8];  % Third subplot position

% Display the Normal Matrix in the first subplot
subplot('Position', pos1);
contourf(matrix, 64, 'LineStyle', 'none', 'Fill', 'on');
axis off;
axis equal;
caxis([global_min, global_max]);
title('Normal Matrix', 'FontSize', 16);
set(gca, 'YDir', 'reverse');  % Invert the y-axis

% Display the Damaged Matrix in the second subplot
subplot('Position', pos2);
contourf(damaged_matrix,64, 'LineStyle', 'none', 'Fill', 'on');
axis off;
axis equal;
caxis([global_min, global_max]);
title('Damaged Matrix', 'FontSize', 16);
set(gca, 'YDir', 'reverse');  % Invert the y-axis

% Display the Recovered Matrix in the third subplot
subplot('Position', pos3);
contourf(deformed_fields_matrix, 64, 'LineStyle', 'none', 'Fill', 'on');
axis off;
axis equal;
caxis([global_min, global_max]);
title('Recovered Matrix', 'FontSize', 16);
set(gca, 'YDir', 'reverse');  % Invert the y-axis again
colormap(sampled_colors);  % Apply the custom colormap
%%
%%
%________________________SIMULATION__________________________________________
% Simulation of cortical signals before the lesion, with the lesion,
% and for the expansion factors specified in simulation_data.EF.
%____________________________________________________________________________

disp('normal');

for e = 1:num_experiments
    h = 0.01;               % Time step
    trials = tf/h;          % Number of trials based on final time and time step

    % Clear variables before each experiment
    clearvars centers FieldNormal matrix Values_normal I_normal FieldDamaged damaged_matrix ...
              Potential_Normal Current_Normal Time_Normal Values_damaged I_damaged ...
              FieldRestored deformed_fields_matrix Potential_Damaged Current_Damaged Time_Damaged

    % Normal receptive fields
    [centers, FieldNormal, matrix] = Normal_Fields(num_rows, num_columns, step_rows, step_columns, matrix_size, A1, A2, sigma_x1, sigma_y1, sigma_x2, sigma_y2, noise);
    Values_normal = FieldNormal.Values;  % Values of normal fields
    I_normal = field_response_optimized2(neurons, trials, tf, matrix_size, num_rows, num_columns, Values_normal, 1);

    % Damaged receptive fields
    [FieldDamaged, damaged_matrix] = Damaged_Fields(num_rows, num_columns, step_rows, step_columns, matrix_size, A1, A2, sigma_x1, sigma_y1, sigma_x2, sigma_y2, damaged_neurons, noise);
    Values_damaged = FieldDamaged.Values;  % Values of damaged fields
    I_damaged = field_response_optimized2(neurons, trials, tf, matrix_size, num_rows, num_columns, Values_damaged, 1);

    % Cortical response for normal fields
    [Potential_Normal, Current_Normal, Time_Normal] = cortical_response_resampled(neurons, num_rows, num_columns, 0, I_normal, h, tf);
    simulation_data.normal.experiment(e).I = Current_Normal;   % Current vectors for normal experiments
    simulation_data.normal.experiment(e).V = Potential_Normal; % Voltage vectors for normal experiments
    simulation_data.normal.experiment(e).t = Time_Normal;      % Time vectors for normal experiments

    % Cortical response for damaged fields
    [Potential_Damaged, Current_Damaged, Time_Damaged] = cortical_response_resampled(neurons, num_rows, num_columns, damaged_neurons, I_damaged, h, tf);
    simulation_data.damaged.experiment(e).I = Current_Damaged;   % Current vectors for damaged experiments
    simulation_data.damaged.experiment(e).V = Potential_Damaged; % Voltage vectors for damaged experiments
    simulation_data.damaged.experiment(e).t = Time_Damaged;      % Time vectors for damaged experiments
end

disp('restored')

% Initialize structures to store data for each expansion factor (EF) and each experiment
for i = 1:length(simulation_data.EF)
    disp('-------*EF*--------')
    disp(simulation_data.EF(i))
    disp('-------------------')
    
    for e = 1:num_experiments
        % Set the simulation parameters
        h = 0.01; % Time step
        trials = tf / h; % Total number of trials
        clearvars FieldRestored deformed_fields_matrix Values_restored I_restored Current_Restored Potential_Restored
                
        % Limit the maximum values of the field
        cota = A1 - A2;
        
        % Generate restored fields based on the specified parameters
        [FieldRestored, deformed_fields_matrix] = Restored_Fields(num_rows, num_columns, step_rows, step_columns, matrix_size, ...
            A1, A2, sigma_x1, sigma_y1, sigma_x2, sigma_y2, damaged_neurons, simulation_data.EF(i), centers, noise, cota);
        
        Values_restored = FieldRestored.Values;
        
        % Normalization constant
        cte_norm = 1;
        
        % Calculate the restored field response
        I_restored = field_response_optimized2(neurons, trials, tf, matrix_size, num_rows, num_columns, Values_restored, cte_norm);
        
        % Resample cortical response for restored fields
        [Potential_Restored, Current_Restored, Time_Restored] = cortical_response_resampled(neurons, num_rows, num_columns, ...
            damaged_neurons, I_restored, h, tf);
        
        % Store the results in the simulation data structure
        simulation_data.restoredEF(i).experiment(e).I(:,:,:) = Current_Restored; % Current vectors at their positions
        simulation_data.restoredEF(i).experiment(e).V(:,:,:) = Potential_Restored; % Voltage vectors at their positions
        simulation_data.restoredEF(i).experiment(e).t(:)     = Time_Restored; % Time vectors for voltage at their positions
    end
end

% Create a descriptive filename based on the parameters
filename = sprintf('simulation_data2_numexp%d_%dX%d_percent%d_tf_%d.mat', num_experiments  , num_rows, ...
    num_columns, percentage, tf);
% Save the structure in a .mat file
save(filename, 'simulation_data');
%%
%_____________________________________________________________
% Section: Neuronal Activity Assessment
%
% This section evaluates the firing activity of neurons in both 
% damaged and restored conditions. Two separate figures are created, 
% each containing a grid of subplots that visualize the voltage 
% signals for each neuron across the specified grid layout.
%
% The first figure displays the voltage data for neurons in the 
% damaged state, while the second figure presents the voltage data 
% for neurons after restoration. Each subplot corresponds to an 
% individual neuron, allowing for an easy comparison of their firing 
% patterns under the two conditions.
%_____________________________________________________________
%%
figure;

% Iterate over the subplots
for i = 1:num_rows*num_columns
    
    [x, y] = ind2sub_rev([num_rows,num_columns],i);
    % Get the data corresponding to index i
    datos = simulation_data.damaged(1).experiment(1).V{x, y};
    % Create a subplot
    subplot(num_rows, num_columns,i);
    
    % Plot the data
    plot(datos);
    axis off
end
suptitle('Damaged')

figure;

% Iterate over the subplots
for i = 1:num_rows*num_columns
    [x, y] = ind2sub_rev([num_rows,num_columns],i);
    % Get the data corresponding to index i
    datos = simulation_data.restoredEF(1).experiment(1).V{x, y};
    
    % Create a subplot
    subplot(num_rows, num_columns,i);
    
    % Plot the data
    plot(datos);
    axis off
end
suptitle('Restored')