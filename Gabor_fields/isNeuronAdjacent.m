% Function to check if a neuron is immediately adjacent to any damaged neuron
function adjacent = isNeuronAdjacent(index_i, index_j, num_columns, damaged_neurons)
    adjacent = any(abs(index_i - floor((damaged_neurons - 1) / num_columns)) <= 1 & ...
                   abs(index_j - mod(damaged_neurons - 1, num_columns)) <= 1);
end
