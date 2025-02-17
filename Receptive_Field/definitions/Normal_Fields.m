  
function [centers,FieldNormal,matrix] = Normal_Fields(num_rows,num_columns,step_rows,step_columns,matrix_size,A1,A2,sigma_x1, sigma_y1,sigma_x2, sigma_y2,noise_percentage)
% Function:     Normal_Fields
%               The Normal_Fields function creates ealthy receptive fields. 
% Author:       Natalí Guisande.
% Version:      November 9th, 2023.
%
% Input arguments:
%
% num_rows:      Number of neurons in x-axis.
% num_columns:   Number of neurons in x-axis.
% step_rows:     Steps to distribute fields equidistantly along the y-axis.
% step_columns:  Steps to distribute fields equidistantly along the x-axis.
% matrix_size:   Size of the detection matrix.
% A:             Amplitude of the Gaussian function.
% sigma_x1:      Exitatory Standard deviation of the Gaussian function in the x direction.
% sigma_y1:      Exitatory Standard deviation of the Gaussian function in the y direction.
% sigma_x2:      Inhibitory Standard deviation of the Gaussian function in the x direction.
% sigma_y2:      Inhibitory Standard deviation of the Gaussian function in the y direction.


%
% The function returns the following output arguments:
%
% centers:      Positions of the receptive fields. It is a cell with the positions
%               of the individual receptive fields centers.
% FieldNormal: Stores all normal receptive field matrices. This is a cell array that
%              contains the values of each receptive field in a matrix.
% matrix:      Normal detection matrix. This matrix represents the sum
%              of all receptive fields.
%
matrix = zeros(matrix_size);
FieldNormal={};
centers={};
ind_cent=0;
    for i = 1:num_rows
        for j = 1:num_columns
            ind_cent=ind_cent+1;
            % Calculate centered positions of receptive fields
            indice_i = (i - 1) * step_rows + 1;%y position
            indice_j = (j - 1) * step_columns + 1;%x position

            % Create a grid of points
            x = 1:matrix_size(2);
            y = 1:matrix_size(1);
            [X, Y] = meshgrid(x, y);

            % Calculate the receptive fieldo
            receptive_matrix = receptiveField(X,Y,A1,indice_j, indice_i,sigma_x1, sigma_y1, 0)-receptiveField(X,Y,A2,indice_j, indice_i,sigma_x2, sigma_y2, 0);
            if noise_percentage >0
            noise=2*rand(matrix_size(2),matrix_size(1))-1;
            receptive_matrix = (max(max(receptive_matrix))*(noise_percentage/100))*noise+receptive_matrix ;
            % Add the receptive field to the field sum matrix
                
            matrix= matrix + receptive_matrix;
            else
            matrix= matrix + receptive_matrix;
            end
            centers{ind_cent,1}=[indice_i,indice_j];
            FieldNormal.indice(ind_cent,1)=ind_cent;
            FieldNormal.Xo(ind_cent,1)=indice_i;
            FieldNormal.Yo(ind_cent,1)=indice_j;
            FieldNormal.Values{ind_cent,1}=receptive_matrix;
        end
    end
end
