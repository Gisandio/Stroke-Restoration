function I = field_response_optimized2(neurons,trials,tf,matrix_size, num_rows, num_columns, Values,const_norm)
% Function:      field_response
%                The field_response function models the response of neural
%                receptive fields by assigning an output current.
% Author:        Natalí Guisande
% Version:       October 1th, 2024.
%
% Input arguments:
%
% trials:          Number of steps in the simulation.
% matrix_size:     Size of the detection matrix (rows x columns).
% num_rows:        Number of neurons along the y-axis.
% num_columns:     Number of neurons along the x-axis.
% Values:          List of values for each receptive field.
% const_norm:      Normalization constant that allows the intensity of the 
%                  visual field (sum of all individual fields) to have no point 
%                  of higher intensity than the original one.
%
% The function returns the following output arguments:
%
% I:               Output current matrix representing the output of each receptive field.
%
% Description:
%
% The field_response function simulates the response of neural receptive fields,
% assigning an output current (I) to each neuron. Edge effects are corrected
% by adjusting the contribution of each field based on their location in the matrix.
% If the index corresponds to a common edge, the entry is multiplied by 2; if it is a corner,
% the entry is multiplied by 4; otherwise, no multiplication is applied. The final output
% current matrix serves as the input for a cortical Izhikevich spiking neuron model.
%
%const_norm=1
tic
%             tf=2000; %(ms)
%             h=0.01;
%             trials=tf/h;
%             Values=FieldNormal.Values;

% Preallocate the matrix I
%I_local = zeros(num_rows, num_columns, trials);
I = zeros(num_rows, num_columns, trials);
% Preallocate the position matrix and factor matrix
positions = zeros(neurons, 2);
factors = ones(num_rows, num_columns); % Factor matrix for corners, edges, and internal

% Populate the position matrix and the factor matrix
for ii = 1:neurons
    [x, y] = ind2sub_rev([num_rows, num_columns], ii);
    positions(ii, :) = [x, y];
    
    % Determine the factor based on the location (edge, corner, or internal)
    if (x == 1 || x == num_rows) && (y == 1 || y == num_columns)
        factors(x, y) = 2.72; % Corner index
    elseif x == 1 || x == num_rows || y == 1 || y == num_columns
        factors(x, y) = 1.65; % Edge index
    end
end
IM = rand(matrix_size(1), matrix_size(2),tf); 
% Convert Values into a 3D matrix^
[tamano1 tamano2]=size(Values{1,1});
ValuesMatrix = zeros(tamano1, tamano2, neurons);
for i = 1:neurons
    ValuesMatrix(:, :, i) = Values{i, 1}; % Assuming Values{i,1} is matrix-like
end
% Main loop over trials (using pre-generated IM matrix)
tf_values=repelem(1:tf, 100);
for g = 1:trials
    %disp(g)
    tf=tf_values(g);
    IM_trial = IM(:, :, tf); 
    IM_expanded = repmat(IM_trial, [1, 1, neurons]);
    % Perform element-wise multiplication for all neurons simultaneously
    Entry = const_norm * (ValuesMatrix .* IM_expanded);  % Element-wise multiplication
    
    % Sum over the third dimension (neurons)
    Entry_sum = squeeze(sum(sum(Entry, 1), 2));  %suma  todo los valores del aimagen
    
    % Apply the factors element-wise
    CN = Entry_sum .* factors(:);
     % Use temporary variable to store the result for this iteration
    temp_I = zeros(num_rows, num_columns);
    for pos = 1:neurons
        temp_I(positions(pos, 1), positions(pos, 2)) = CN(pos);
    end
    
    % Assign the temporary result to the sliced variable
    I(:, :, g) = temp_I;

   
end

% Apply the final scaling to the matrix I
I = I * 0.8;

toc
end
