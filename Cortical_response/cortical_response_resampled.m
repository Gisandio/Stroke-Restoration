function [Potential,Current,Time] = cortical_response_resampled(neurons,num_rows,num_columns,damaged_neurons,I,h,tf)
% Function:      cortical_response Simulates the response of cortical neurons based on input currents.
% Author: Guisande Natalí
% Date: October 1, 2024
%
% Input arguments:
%   neurons:          Total number of neurons in the cortical network.
%   damaged_neurons:  Indices of damaged neurons. Set 0 for a normal field.
%   I:                Input current matrix representing the response of receptive fields.
%   h:                Time step for Runge-Kutta.
%   tf:               Duration of the output signal from the Izhikevich neuron model.

%
% Output arguments:
%   Out:              Structure containing the simulation output for each neuron.
%                      - Potential: Membrane potential for each neuron.
%                      - Current: Input current for each neuron.
%                      - Time: Time vector for each neuron's response.
%

for i = 1:neurons
    disp(i)
        % Get the row and column index corresponding to element i
    if any(i == damaged_neurons)
        [x, y] = ind2sub_rev([num_rows,num_columns],i);
        % Reemplazar el valor en CN con el índice del elemento
        %[~, ~, tiempo]= izhi_neuron(I(x,y,:),h,tf);
        
        Potential{x,y,1}=0;
        Current{x,y,1}=0;
    else
        % Adjust the index to count from left to right and bottom to top
        [x, y] = ind2sub_rev([num_rows,num_columns],i);
        [potential, current, ~]= izhi_neuron(I(x,y,:),h,tf);
        
        % Resampling parameters
        originalFs = round(1 / (h * 1e-3)); % Frecuencia de muestreo original (100 kHz)
        Fs_resampled = 500; % Nueva frecuencia de muestreo Hz
        
        % Resample the signal using 'resample'
        [Potencial_resampled, ~] = resample(potential, Fs_resampled, originalFs);
        [current_resampled, ~] = resample(current, Fs_resampled, originalFs);

        Potential{x,y,1}=Potencial_resampled;
        Current{x,y,1}=current_resampled;
        
    end
end
% Calculate the new time vector
num_samples_resampled = length(Potencial_resampled);
Tiempo_resampled = (0:num_samples_resampled-1) / Fs_resampled;
Time=Tiempo_resampled;
end

