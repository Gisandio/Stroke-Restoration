function [centers, FieldNormal, matrix] = Normal_Gabor_Fields4(num_rows,num_columns,A,sigma_x, sigma_y,res,theta,B,varargin)
    % Function:     Normal_Fields
    %               The Normal_Fields function creates healthy receptive fields. 
    % Author:       Natalí Guisande.
    % Version:      February 28th, 2025.
    %
    % Input arguments:
    %
    % num_rows:      Number of neurons in x-axis.
    % num_columns:   Number of neurons in x-axis.
    % step_rows:     Steps to distribute fields equidistantly along the y-axis.
    % step_columns:  Steps to distribute fields equidistantly along the x-axis.
    % matrix_size:   Size of the detection matrix.
    % A:             Amplitude of the Gaussian function.
    % sigma_x:       Standard deviation of the Gaussian function in the x direction.
    % sigma_y:       Standard deviation of the Gaussian function in the y direction.
    %
    % The function returns the following output arguments:
    %
    % centers:      Positions of the receptive fields. It is a cell with the positions
    %               of the individual receptive fields centers.
    % FieldNormal:  Stores all normal receptive field matrices. This is a cell array that
    %              contains the values of each receptive field in a matrix.
    % matrix:       Normal detection matrix. This matrix represents the sum
    %              of all receptive fields.
    
% Default values
attenuation_mode = 0; % or any default value you desire

% Check if 'attenuation' is specified in varargin
if any(strcmpi(varargin, 'attenuation'))
    % Find the index of 'attenuation' in varargin
    idx = find(strcmpi(varargin, 'attenuation'));
    
    % Check if an attenuation mode is specified after 'attenuation'
    if idx < length(varargin)
        attenuation_mode_option = varargin{idx + 1};
        
        % Check the specified attenuation mode
        if strcmpi(attenuation_mode_option, 'on')
            attenuation_mode = 1;
%         elseif strcmpi(attenuation_mode_option, 'qgaussian2')
%             attenuation_mode = 2;
        elseif strcmpi(attenuation_mode_option, 'off')
            attenuation_mode = 0;
        else
            error('Invalid attenuation mode specified after ''attenuation''.');
        end
    else
        error('No attenuation mode specified after ''attenuation''.');
    end
end


matrix  = zeros((num_rows-1) * res, (num_columns-1) * res);
FieldNormal = {};
ind_cent = 0;
Rows = linspace(0, (num_rows-1), (num_rows-1) * res);
Columns = linspace(0, (num_columns-1), (num_columns-1) * res);
[X, Y] = meshgrid(Columns,Rows);
% B=1;

    
    for j = 1:num_columns
        for i = 1:num_rows
            ind_cent = ind_cent + 1;
            
            % Calculate centered positions of receptive fields
            indice_i = (i-1);
            indice_j = (j-1);
            
             % Check if the attenuation mode is on
            if attenuation_mode==1
%                 % Apply attenuation
%                 [X1, Y1] = alivi_rotation(X, Y, indice_j, indice_i, theta);
%                 attenuation = qgaussian_2D(X1, Y1, B, B,-15);
%                 attenuation = attenuation / max(max(attenuation));
%             elseif attenuation_mode==2
                %Calculating the Y-distance to the Gabor minima.
                [~, max_indices_column]=max(max(receptiveGaborField_azymetric(X, Y, A, indice_j, indice_i, sigma_x, sigma_y, sigma_x, sigma_y, 0, 2*pi, 0, 1/B),[],2));
                [~, min_indices_column]=min(min(receptiveGaborField_azymetric(X, Y, A, indice_j, indice_i,sigma_x, sigma_y, sigma_x, sigma_y,0, 2*pi, 0, 1/B),[],2));
                dist= Y(abs(max_indices_column-min_indices_column));
                
                [X1, Y1] = alivi_rotation(X, Y, indice_j, indice_i, theta);
                
                attenuation = qgaussian_2D(X1, Y1,2*B, sigma_x+0.1,-10)+qgaussian_2D(X1, Y1+dist,1.5*B, sigma_x,-10)+qgaussian_2D(X1, Y1-dist,1.5*B,sigma_x,-10);
                attenuation = attenuation / max(max(attenuation));
                % Convert non-zeros to 1
                %attenuation(attenuation ~= 0) = 1;
            else
                % No attenuation
                attenuation = 1;
            end
            
%             % Apply q-Gaussian attenuation
%              [X1,Y1]=alivi_rotation(X,Y,indice_j, indice_i,theta);
%             attenuation = qgaussian_2D(X1, Y1, 2, 1.8,-10);
%             attenuation = attenuation/max(max(attenuation));
%             attenuation(attenuation <0.5) = 0;
            

 % Calculate the receptive field
            receptive_matrix = receptiveGaborField_azymetric(X, Y, A, indice_j, indice_i,sigma_x, sigma_y, sigma_x, sigma_y, theta, 2*pi, 0, 1/B);%.*attenuation; %standar phi=2*pi
            receptive_matrix=receptive_matrix.*attenuation;%atenuation
            receptive_matrix=receptive_matrix/max(max(receptive_matrix));%normalization
            %receptive_matrix=receptive_matrix.*attenuation;%atenuation
            %receptive_matrix=receptive_matrix/max(max(receptive_matrix));%normalization
            % Add the receptive field to the sum of fields matrix
            matrix = matrix + receptive_matrix;

            centers{ind_cent, 1} = [indice_i, indice_j];
            FieldNormal.indice(ind_cent, 1) = ind_cent;
            FieldNormal.Xo(ind_cent, 1) = indice_i;
            FieldNormal.Yo(ind_cent, 1) = indice_j;
            FieldNormal.Values{ind_cent, 1} = receptive_matrix;
        end
    end
end
