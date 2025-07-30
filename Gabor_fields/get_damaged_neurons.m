% Function to get the damaged neurons based on percentage
% Author: Guisande Natalí
% Date: February 24, 2025
%
% This function works only for square matrices of size 10x10 and 20x20.
% It retrieves the indices of damaged neurons based on a specified
% percentage of damage.
%
% Usage:
% neurons = get_damaged_neurons(damaged_neurons_list, percentage, matrix_size)
% - damaged_neurons_list: A structure containing lists of damaged neurons.
% - percentage: Damage level as a percentage (1, 2, 5, 10, 20, or 30 in 10x20 or 20x20).
                                            %(2,6,10,18,30)           
% - matrix_size: Either 10 or 20 (for 10x10 or 20x20 matrices).
%
% The function will return the corresponding neuron indices for the specified percentage.
function neurons = get_damaged_neurons(percentage, matrix_size)

% Check that the input matrix size is valid (either 10 or 20)
if ~ismember(matrix_size, [7, 10, 20])
    error('This function only supports 7x7, 10x10 and 20x20 matrices.');
end
% Define the damaged neurons for 20x20 matrix
if matrix_size == 7
    damaged_neurons_list = struct( ...
        'percent2', [25], ... % 2 percent (1 N)
        'percent6', [24 25 26], ... % 6 percent (3 N)
        'percent8', [17 18 24 25], ... % 10 percent (5 N)
        'percent18', [17 18 19 24 25 26 31 32 33], ... % 18 percent (9 N)
        'percent30', [10 11 12 17 18 19 24 25 26 31 32 33 38 39 40] ... % 30 percent (15 N)
        );
    % Define the damaged neurons for 20x20 matrix
elseif matrix_size == 20
    damaged_neurons_list = struct( ...
        'percent1', [210 211 190 191], ... % 1 percent (4 N)
        'percent2', [209 210 211 212 189 190 191 192], ... % 2 percent (8 N)
        'percent5', [229 230 231 232 233 209 210 211 212 213 189 190 191 192 193 169 170 171 172 173], ... % 5 percent (20 N)
        'percent10', [269 270 271 272 273 249 250 251 252 253 229 230 231 232 233 209 210 211 212 213 189 190 191 192 193 169 170 171 172 173 149 150 151 152 153 129 130 131 132 133], ... % 10 percent (40 N)
        'percent20', [287 288 289 290 291 292 293 294 267 268 269 270 271 272 273 274 247 248 249 250 251 252 253 254 227 228 229 230 231 232 233 234 207 208 209 210 211 212 213 214 187 188 189 190 191 192 193 194 167 168 169 170 171 172 173 174 147 148 149 150 151 152 153 154 127 128 129 130 131 132 133 134 107 108 109 110 111 112 113 114], ... % 20 percent (80 N)
        'percent30', [305 306 307 308 309 310 311 312 313 314 315 316 285 286 287 288 289 290 291 292 293 294 295 296 265 266 267 268 269 270 271 272 273 274 275 276 245 246 247 248 249 250 251 252 253 254 255 256 225 226 227 228 229 230 231 232 233 234 235 236 205 206 207 208 209 210 211 212 213 214 215 216 185 186 187 188 189 190 191 192 193 194 195 196 165 166 167 168 169 170 171 172 173 174 175 176 145 146 147 148 149 150 151 152 153 154 155 156 125 126 127 128 129 130 131 132 133 134 135 136 105 106 107 108 109 110 111 112 113 114 115 116 85 86 87 88 89 90 91 92 93 94 95 96] ... % 30 percent (120 N)
        );
elseif matrix_size == 10
    % Define the damaged neurons for 10x10 matrix
    damaged_neurons_list = struct( ...
        'percent1', 55, ... % 1 percent (1 N)
        'percent2', [55, 56], ... % 2 percent (2 N)
        'percent5', [44, 45, 46, 47, 48], ... % 5 percent (5 N)
        'percent10', [44, 45, 46, 47, 48, 54, 55, 56, 57, 58], ... % 10 percent (10 N)
        'percent20', [44, 45, 46, 47, 48, 54, 55, 56, 57, 58, 64, 65, 66, 67, 68, 34, 35, 36, 37, 38], ... % 20 percent (20 N)
        'percent30', [44, 45, 46, 47, 48, 54, 55, 56, 57, 58, 64, 65, 66, 67, 68, 34, 35, 36, 37, 38,74,75,76,77,78,24,25,26,27,28] ... % 30 percent (20 N)
        );
end

% Define the key based on the percentage
if matrix_size == 10 || matrix_size == 20
    switch percentage
        case 1
            key = 'percent1';
        case 2
            key = 'percent2';
        case 5
            key = 'percent5';
        case 10
            key = 'percent10';
        case 20
            key = 'percent20';
        case 30
            key = 'percent30';
        otherwise
            error('Invalid percentage. Valid options are 1, 2, 5, 10, 20, 30.');
    end
elseif matrix_size == 7
    switch percentage
        
        case 2
            key = 'percent2';
        case 6
            key = 'percent6';
        case 8
            key = 'percent8';
        case 18
            key = 'percent18';
        case 30
            key = 'percent30';
        otherwise
            error('Invalid percentage. Valid options are  2, 6, 8, 18, 30.');
    end
end

% Retrieve the corresponding damaged neurons
neurons = damaged_neurons_list.(key);
end
