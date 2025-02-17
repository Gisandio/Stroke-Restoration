function [FieldDamaged,damaged_matrix] = Damaged_Fields(num_rows,num_columns,step_rows,step_columns,matrix_size,A1,A2,sigma_x1, sigma_y1,sigma_x2, sigma_y2,damaged_neurons,noise_percentage)
% Function:      Damaged_FieldDamages
%                The Damaged_FieldDamages function creates the damaged receptive 
%                fields leaving holes in the damaged regions.
% Author:        Natalí Guisande
% Version:       November 9th, 2023.
%
% Input arguments:
%
% num_rows:        Number of neurons in x-axis.
% num_columns:     Number of neurons in x-axis.
% step_rows:       Steps to distribute fields equidistantly along the y-axis.
% step_columns:    Steps to distribute fields equidistantly along the x-axis.
% matrix_size:     Size of the detection matrix.
% A:               Amplitude of the Gaussian function.
% sigma_x:         Standard deviation of the Gaussian function in the x direction.
% sigma_y:         Standard deviation of the Gaussian function in the y direction.
% damaged_neurons: Vector that contains the indices of the damaged neurons.
%
% The function returns the following output arguments:
%
% FieldDamaged:      Stores all receptive field matrices excluding the damaged fields.
%                    This is a cell array that contains the values of each receptive field in a matrix.
% damaged_matrix:    Damaged detection matrix. It is a matrix with the sum of all
%                    receptive fields excluding the damaged ones.
%
damaged_matrix = zeros(matrix_size);
FieldDamaged={};
ind_cent=0;
for i = 1:num_rows
    for j = 1:num_columns
        ind_cent=ind_cent+1;
        % Calculate the centered positions of the receptive fields
        indice_i = (i - 1) * step_rows + 1;
        indice_j = (j - 1) * step_columns + 1;
        
        % Avoid generating fields for damaged_neurons neurons
        if ~any(damaged_neurons == (i - 1) * num_columns + j)
            % Crear una cuadrícula de puntos
            x = 1:matrix_size(2);
            y = 1:matrix_size(1);
            [X, Y] = meshgrid(x, y);
            
            % Calculate the receptive field
            receptive_matrix = receptiveField(X,Y,A1,indice_j, indice_i,sigma_x1, sigma_y1, 0)-receptiveField(X,Y,A2,indice_j, indice_i,sigma_x2, sigma_y2, 0);
            
            if noise_percentage >0
            noise=2*rand(matrix_size(2),matrix_size(1))-1;
            receptive_matrix = (max(max(receptive_matrix))*(noise_percentage/100))*noise+receptive_matrix ;
            % Add the receptive field to the field sum matrix
                
             damaged_matrix=  damaged_matrix + receptive_matrix;
            else
             damaged_matrix=  damaged_matrix + receptive_matrix;
            end
            
            FieldDamaged.indice(ind_cent,1)=ind_cent;
            FieldDamaged.Xo(ind_cent,1)=indice_i;
            FieldDamaged.Yo(ind_cent,1)=indice_j;
            FieldDamaged.Values{ind_cent,1}=receptive_matrix;
        else
            FieldDamaged.indice(ind_cent,1)=ind_cent;
            FieldDamaged.Xo(ind_cent,1)=indice_i;
            FieldDamaged.Yo(ind_cent,1)=indice_j;
            FieldDamaged.Values{ind_cent,1}=0;
            
        end
    end
end
end