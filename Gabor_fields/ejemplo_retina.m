% Script to generate a dataset of LFP (Local Field Potentials)
% Author: Guisande Natalí
% Date: July 27, 2025
%_________________________________________________________________________

% Create the detector matrix. Define the physical size of the detector
% matrix, which limits the size of input signals.
num_rows = 7; % Number of rows in the detector
num_columns = 7; % Number of columns in the detector
matrix_size = [10*(num_rows-1), 10*(num_columns-1)];
neurons = num_rows * num_columns; % Total number of receptive fields

% Set the percentage of damaged neurons
percentage =2 ; % Change this value to the desired percentage of damage
m_size = 7; %(7x7 admits damage percentage 2 6 8 18 30)
% - percentage: Damage level as a percentage (1, 2, 5, 10, 20, or 30).
% - m_size:  7, 10 or 20 ( for 7x7, 10x10 or 20x20 matrices).
% Set the total simulation time in ms
tf = 1000; % Time in ms

% Crear una estructura para almacenar los datos
simulation_data = struct();
simulation_data.EF =1.05;%1:0.1:1; %0.1:0.2:8;%0.5:0.5:20; % Vector of expansion factors (plasticity parameters)

%Number of simulations
num_experiments=1;
% Noise level in the LFP data (percentage)
noise = 0; % No noise initially, adjust for specific cases

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
theta=pi/4;
%num_rows= 9; % Number of neurons in y-axis.
%num_columns = 9; %Number of neurons in x-axis.
% matrix_size = [10*num_rows, 10*num_columns ];
A =1;
sigma_x =0.5;
sigma_y =sigma_x;
res=10;
B=1;

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
expansion_factor =2;

% Create healthy receptive fields using the Normal_Fields function
[centers, FieldNormal, matrix] = Normal_Gabor_Fields4(num_rows,num_columns,A,sigma_x, sigma_y,res,theta,B,'attenuation','off');

% Create damaged receptive fields using the Damaged_Fields function
[FieldDamaged, damaged_matrix] =  Damaged_Gabor_Fields(num_rows,num_columns,A,sigma_x, sigma_y,res,theta,damaged_neurons,B,'attenuation','off');

% Create restored receptive fields using the Restored_Fields function
[FieldRestored, deformed_fields_matrix] = Restored_Gabor_Fields_Directional3(num_rows, num_columns, A, sigma_x, sigma_y, res, theta, damaged_neurons, expansion_factor, centers, B);
                                   
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
contourf(matrix, 15, 'LineStyle', 'none', 'Fill', 'on');
axis off;
axis equal;
caxis([global_min, global_max]);
title('Normal Matrix', 'FontSize', 16);
set(gca, 'YDir', 'reverse');  % Invert the y-axis

% Display the Damaged Matrix in the second subplot
subplot('Position', pos2);
contourf(damaged_matrix, 15, 'LineStyle', 'none', 'Fill', 'on');
axis off;
axis equal;
caxis([global_min, global_max]);
title('Damaged Matrix', 'FontSize', 16);
set(gca, 'YDir', 'reverse');  % Invert the y-axis

% Display the Recovered Matrix in the third subplot
subplot('Position', pos3);
contourf(deformed_fields_matrix, 15, 'LineStyle', 'none', 'Fill', 'on');
axis off;
axis equal;
caxis([global_min, global_max]);
title('Recovered Matrix', 'FontSize', 16);
set(gca, 'YDir', 'reverse');  % Invert the y-axis again
colormap(sampled_colors);  % Apply the custom colormap