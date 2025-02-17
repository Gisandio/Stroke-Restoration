function [FieldRestored,deformed_fields_matrix] = Restored_Fields(num_rows,num_columns,step_rows,step_columns,matrix_size,A1,A2,sigma_x1, sigma_y1,sigma_x2, sigma_y2,damaged_neurons,expansion_factor,centers,noise_percentage,cota)
% Function:      Restored_Fields
%                The `Restored_Fields` function is used to create the damaged receptive
%                fields leaving holes in the damaged regions and deform the receptive
%                fields of healthy neurons around the lesion. To achieve this, it rotates
%                and asymmetrically deforms the two-dimensional Gaussian with the
%                `receptiveField_azymetric_sigma` function.
%                The rotation direction, towards which the healthy fields expand, can be
%                modified within the function. The new axes can align with the lesion center,
%                the nearest neuron, or a compromise between both.
% Author:        Natalí Guisande
% Version:       November 9th, 2023.
%
% Input arguments:
%
% num_rows:         Number of neurons in x-axis.
% num_columns:      Number of neurons in x-axis.
% step_rows:        Steps to distribute fields equidistantly along the y-axis.
% step_columns:     Steps to distribute fields equidistantly along the x-axis.
% matrix_size:      Size of the detection matrix.
% A:                Amplitude of the Gaussian function.
% sigma_x:          Standard deviation of the Gaussian function in the x direction.
% sigma_y:          Standard deviation of the Gaussian function in the y direction.
% damaged_neurons:  Vector that contains the indices of the damaged neurons.
% expansion factor: Plasticity factor, the higher the value, the more the fields grow towards the lesion.
% centers:          Positions of the receptive fields. It is a cell with the positions
%                   of the individual receptive fields centers.
% The function returns the following output arguments:
%
% FieldRestored:           Stores all restored receptive field matrices excluding the damaged fields.
%                          It is a matrix that stores the values of each expanded receptive field in
%                          a matrix for non damage neurons
% deformed_fields_matrix:  Restored detection matrix. It is a matrix with the sum of all
%                          receptive fields.
%
% *NOTE:
% Angles are cyclic values, which means after a complete cycle of 360 degrees,
% angles wrap around and start again from 0. This can lead to unexpected results
% when calculating the arithmetic mean of two angles.
%
% To avoid this problem, instead of directly calculating the arithmetic mean,
% you can compute the mean of the unit vectors corresponding to the two angles,
% and then calculate the angle of the resulting mean vector. This will give you
% the "average" angle as expected in the context of cyclic values.


% Get the coordinates of the damaged_neurons
coordenadas_damaged_neurons = cell2mat(centers(damaged_neurons, 1));
rows_damaged_neurons = coordenadas_damaged_neurons(:, 1);
columns_damaged_neurons = coordenadas_damaged_neurons(:, 2);

% Create a matrix to store the deformed receptive fields
deformed_fields_matrix = zeros(matrix_size);

% Calculate the center of the lesion as the average of damaged_neurons positions
lesion_center = [mean(rows_damaged_neurons), mean(columns_damaged_neurons)];
%

% Create a grid of points
x = 1:matrix_size(2);
y = 1:matrix_size(1);
[X, Y] = meshgrid(x, y);

% Deform and expand the non-damaged receptive fields
ind_cent=0;% Initialize index variable for the center
for i = 1:num_rows
    for j = 1:num_columns
        ind_cent=ind_cent+1;
        % Calculate centered positions of receptive fields
        index_i = (i - 1) * step_rows + 1;
        index_j = (j - 1) * step_columns + 1;
        
        % Avoid generating fields for damaged_neurons
        if ~any(damaged_neurons == (i - 1) * num_columns + j)
            % Calculate direction and distance to the lesion center
            distances_to_lesions = sqrt(((rows_damaged_neurons - index_i).^2 + (columns_damaged_neurons - index_j).^2)/ max(matrix_size));
            %[min_distance, nearest_neuron_index] = min(distances_to_lesions)
            % Paso 2: Encontrar las neuronas con la mínima distancia total
        min_distance = min(distances_to_lesions);  % Distancia mínima
        nearest_neuron_indices = find(distances_to_lesions == min_distance);  % Índices de neuronas con la distancia mínima

        % Paso 3: Si hay empates, seleccionar la neurona más cercana al eje vertical (columna)
        if length(nearest_neuron_indices) > 1
            % Si hay varias neuronas con la misma distancia mínima en total,
            % seleccionamos la que esté más cerca del eje vertical de la lesión
            column_distances = abs(columns_damaged_neurons(nearest_neuron_indices) - lesion_center(2));  % Distancia a la columna de la lesión
            [~, nearest_neuron_index_in_group] = min(column_distances);  % Seleccionamos la más cercana al eje vertical
            nearest_neuron_index = nearest_neuron_indices(nearest_neuron_index_in_group);  % Selección final
        else
            % Si solo hay una neurona con la distancia mínima, seleccionamos esa
            nearest_neuron_index = nearest_neuron_indices;
        end
            
          
            if min_distance <=3
                % Calculate direction to the nearest damaged neuron
                distance_x = lesion_center(2)-index_j;
                distance_y = lesion_center(1)-index_i;
                rotation_angle_cen = (atan2(distance_y, distance_x));
                
                % Calculate direction to the nearest damaged neuron
                distance_x1 = columns_damaged_neurons(nearest_neuron_index) - index_j;
                distance_y1 = rows_damaged_neurons(nearest_neuron_index) - index_i;
                rotation_angle_min = atan2(distance_y1, distance_x1) ;
                %__________________________________________________________________________
                % See *NOTE above for an explanation on handling cyclic values (angles) and
                % calculating the average angle using unit vectors.
                
                % Calculate unit vectors corresponding to the two angles
                vector_cen = [cos(rotation_angle_cen), sin(rotation_angle_cen)];
                vector_min = [cos(rotation_angle_min), sin(rotation_angle_min)];
                
                % Calculate the average of the two vectors
                vector_medio = 0.5*vector_cen +0.5* vector_min;%1*vector_cen +0* vector_min;%
                
                % Calculate the angle of the resulting average vector
                rotation_angle = atan2(vector_medio(2), vector_medio(1));
                
                % Calculate new standard deviation based on distance
                %squared_distance = ((sqrt((distance_x^2 + distance_y^2)))^2);% Uncomment this option if you want to use the lesion center distance instead of the minimum distance and replace in fs.
                min_squared_distance = (min_distance)^2; % to the lesion
                fs = (expansion_factor /min_squared_distance);
                
                new_sigma_x1 = sigma_x1 + fs;
                new_sigma_y1 = sigma_y1 + 0*fs;%You can change the coefficient of fs to widen the field on the other axis.
                new_sigma_x2 = sigma_x2 + fs;
                new_sigma_y2 = sigma_y2 + 0*fs;%You can change the coefficient of fs to widen the field on the other axis.
                % Rotate and expand the receptive field
                receptive_matrix = receptiveField_azymetric_sigma(X,Y,A1,index_j, index_i,new_sigma_x1, new_sigma_y1,sigma_x1, sigma_y1, rotation_angle)-receptiveField_azymetric_sigma(X,Y,A2/(1+fs),index_j, index_i,new_sigma_x2, new_sigma_y2,sigma_x2, sigma_y2, rotation_angle);%inhibo la inibicion
                
            else
                receptive_matrix = receptiveField_azymetric_sigma(X,Y,A1,index_j, index_i,sigma_x1, sigma_y1,sigma_x1, sigma_y1, 0)-receptiveField_azymetric_sigma(X,Y,A2,index_j, index_i,sigma_x2, sigma_y2,sigma_x2, sigma_y2, 0);
            end
            
            % Add the deformed receptive field to the sum matrix
            
            %normalization= max(max(receptiveField_azymetric_sigma(X,Y,A1,index_j, index_i,sigma_x1, sigma_y1,sigma_x1, sigma_y1, rotation_angle)))
            if noise_percentage >0
                noise=2*rand(matrix_size(2),matrix_size(1))-1;
                receptive_matrix = (max(max(receptive_matrix))*(noise_percentage/100))*noise+receptive_matrix ;
                % Add the receptive field to the field sum matrix
                
                deformed_fields_matrix = deformed_fields_matrix + receptive_matrix;
            else
                deformed_fields_matrix = deformed_fields_matrix + receptive_matrix;
            end
            
            %acoto los campos al valor maximo normal
            receptive_matrix(receptive_matrix > cota) = cota;
            FieldRestored.indice(ind_cent,1)=ind_cent;
            FieldRestored.Xo(ind_cent,1)=index_i;
            FieldRestored.Yo(ind_cent,1)=index_j;
            FieldRestored.Values{ind_cent,1}=receptive_matrix;%/normalization;
        else
            FieldRestored.indice(ind_cent,1)=ind_cent;
            FieldRestored.Xo(ind_cent,1)=index_i;
            FieldRestored.Yo(ind_cent,1)=index_j;
            FieldRestored.Values{ind_cent,1}=0;
        end
    end
end
end