function on_line = isNeuronOnLine(index_i, index_j, num_columns, damaged_neurons, lesion_center, theta, tolerance)
    on_line = false;
    
    for damaged_neuron = damaged_neurons'
        damaged_i = floor((damaged_neuron - 1) / num_columns) + 1;
        damaged_j = mod(damaged_neuron - 1, num_columns) + 1;

        % Vector desde la neurona dañada hasta la neurona actual
        vec_damaged_to_current = [index_i - damaged_i, index_j - damaged_j];

        % Vector desde el centro de la lesión hasta la neurona actual
        vec_lesion_to_current = [index_i - lesion_center(1), index_j - lesion_center(2)];

        % Calcular la diferencia angular entre los dos vectores
        angle_difference = abs(atan2(vec_lesion_to_current(1), vec_lesion_to_current(2)) - atan2(vec_damaged_to_current(1), vec_damaged_to_current(2)));

        % Normalizar el ángulo para que esté en el rango [0, pi)
        angle_difference = mod(angle_difference, pi);

        % Verificar si la neurona está en la línea y tiene la misma orientación
        if angle_difference < tolerance
            on_line = true;
            break;
        end
    end
end


