function [FieldRestored, deformed_fields_matrix] = Restored_Gabor_Fields_Directional3(num_rows, num_columns, A, sigma_x, sigma_y, res, theta, damaged_neurons, sf, centers, B, varargin)
% Check if sf is less than 1
if sf < 1
    error('Error: sf should be greater than or equal to 1. Please provide a valid value for sf.');
end
pos_angle = [];
neg_angle = [];
% Get the coordinates of the damaged_neurons
coordenadas_damaged_neurons = cell2mat(centers(damaged_neurons, 1));
rows_damaged_neurons = coordenadas_damaged_neurons(:, 2);
columns_damaged_neurons = coordenadas_damaged_neurons(:, 1);

% Create a matrix to store the deformed receptive fields
deformed_fields_matrix =  zeros((num_rows-1) * res, (num_columns-1) * res);

%
Rows = linspace(0, (num_rows-1), (num_rows-1) * res);
Columns = linspace(0, (num_columns-1), (num_columns-1) * res);
[X, Y] = meshgrid(Columns,Rows);
% B=1;
ind_cent=0;

for j = 1:num_columns
    for i = 1:num_rows
        ind_cent = ind_cent + 1;
        index_i = (i - 1);
        index_j = (j - 1);
        
        if ~any(damaged_neurons == (i - 1) * num_columns + j)
            % Verificar si la neurona es adyacente a alguna dañada
            is_adjacent = isNeuronAdjacent(index_i, index_j, num_columns, damaged_neurons);
            disp(is_adjacent);
            % Check if the neuron is on a line passing through a damaged neuron with the same orientation
            
            if is_adjacent==1
                
                for f =1:length(damaged_neurons)
                    distance_x = columns_damaged_neurons(f)-index_j;
                    distance_y = rows_damaged_neurons(f)-index_i;
                    rotation_angle_cen = (atan2(distance_y, distance_x));
                    if rotation_angle_cen == theta
                        pos_angle= [pos_angle; [index_i, index_j]];
                    elseif rotation_angle_cen == (theta-pi)
                       % disp('menos')
                        neg_angle= [neg_angle; [index_i, index_j]];
 
                    else

                    end
     
                
                end
                
            else %if is_adjacent==false
        
            end

           

        end

    end
end

     % Find unique rows and count repetitions for neg_angle
            [unique_rows_neg, ~, ic_neg] = unique(neg_angle, 'rows');
            % unique_rows_neg: Matrix of unique rows for neg_angle
            % ~: Ignore the second output argument (row indices)
            % ic_neg: Indices of each row in unique_rows_neg, used for counting repetitions
            counts_neg = hist(ic_neg, unique(ic_neg));
            % counts_neg: Number of repetitions for each unique row in neg_angle
            % hist(ic_neg, unique(ic_neg)): Compute the histogram of indices ic_neg using unique(ic_neg)
            % Find unique rows and count repetitions for pos_angle
            [unique_rows_pos, ~, ic_pos] = unique(pos_angle, 'rows');
            counts_pos = hist(ic_pos, unique(ic_pos));
            
            % Check if [index_i, index_j] is a member of unique_rows_pos
            is_member_pos = ismember([index_i, index_j], unique_rows_pos, 'rows');
%             if any(is_member_pos)
%                 % If the pair is a member, find the row index
%                 row_index_pos = find(ismember(unique_rows_pos, [index_i, index_j], 'rows'));
%             else
%             end
            % Check if [index_i, index_j] is a member of unique_rows_neg
            is_member_neg = ismember([index_i, index_j], unique_rows_neg, 'rows');
            
%             if any(is_member_neg)
%                 % If the pair is a member, find the row index
%                 row_index_neg = find(ismember(unique_rows_neg, [index_i, index_j], 'rows'));
%             else
%                 % If the pair is not a member, handle accordingly
%                 % (You can add code here if needed)
%             end
%                   
%             % Create the new matrices with the count column for pos_angle
%             result_matrix_pos = [unique_rows_pos, counts_pos];
%             % Concatenate unique rows with their corresponding counts for pos_angle
%             
%             % Create the new matrices with the count column for neg_angle
%             result_matrix_neg = [unique_rows_neg, counts_neg];
%             % Concatenate unique rows with their corresponding counts for neg_angle
            
ind_cent=0;

for j = 1:num_columns
    for i = 1:num_rows
        ind_cent = ind_cent + 1;
        index_i = (i - 1);
        index_j = (j - 1);
        
        if ~any(damaged_neurons == (i - 1) * num_columns + j)
            % Check if [index_i, index_j] is a member of unique_rows_pos
            is_member_pos = ismember([index_i, index_j], unique_rows_pos, 'rows');
            %
            % Check if [index_i, index_j] is a member of unique_rows_neg
            is_member_neg = ismember([index_i, index_j], unique_rows_neg, 'rows');
            
            if  is_member_pos
                [row,~]=find(ismember(unique_rows_pos, [index_i, index_j], 'rows'));
                how_many=counts_pos(row);
               % limits the expansion of multiply injured linens
                if how_many >1 && sf>1
                    A=0.75*how_many*sf;
                elseif how_many ==1 && sf>1
                    A=sf;
                else
                    A=1;
                end
                recovery=1/(A*B);
                receptive_matrix = receptiveGaborField_azymetric2(X, Y, A, index_j, index_i, sigma_x, sigma_y, sigma_x, sigma_y, theta, 2*pi, 0, 1/B, recovery);
                receptive_matrix=receptive_matrix/max(max(receptive_matrix));%normalization
                deformed_fields_matrix = deformed_fields_matrix + receptive_matrix;
            elseif  is_member_neg
                [row,~]=find(ismember(unique_rows_neg, [index_i, index_j], 'rows'));
                how_many=counts_neg(row);
                                %limits the expansion of multiply injured linens
                if how_many >1 && sf>1
                    A=0.75*how_many*sf;
                elseif how_many ==1 && sf>1
                    A=sf;
                else
                    A=1;
                end
                recovery=1/(A*B);
                receptive_matrix = receptiveGaborField_azymetric2(X, Y, A, index_j, index_i, sigma_x, sigma_y, sigma_x, sigma_y, theta, 2*pi, 0, recovery,1/B);
                receptive_matrix=receptive_matrix/max(max(receptive_matrix));%normalization
                deformed_fields_matrix = deformed_fields_matrix + receptive_matrix;
               
            else %if is_adjacent==false
                %caso en que estan muy lejos y no queremos alterar el campo
                receptive_matrix =  receptiveGaborField_azymetric(X,Y,A,index_j, index_i,sigma_x, sigma_y,sigma_x, sigma_y, theta, 2*pi, 0, 1/B);
                receptive_matrix=receptive_matrix/max(max(receptive_matrix));%normalization
                deformed_fields_matrix = deformed_fields_matrix + receptive_matrix;
                %disp('no')
            end

            
            % Add the receptive field to the sum matrix
            FieldRestored.indice(ind_cent, 1) = ind_cent;
            FieldRestored.Xo(ind_cent, 1) = index_i;
            FieldRestored.Yo(ind_cent, 1) = index_j;
            FieldRestored.Values{ind_cent, 1} = receptive_matrix;
        else
            
            % If the neuron is damaged, set the restored value to 0
            FieldRestored.indice(ind_cent, 1) = ind_cent;
            FieldRestored.Xo(ind_cent, 1) = index_i;
            FieldRestored.Yo(ind_cent, 1) = index_j;
            FieldRestored.Values{ind_cent, 1} = 0;
            
        end
    end
end

    

            
            
            
            % Add the receptive field to the sum matrix
