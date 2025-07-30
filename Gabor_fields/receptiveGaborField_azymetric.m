function z = receptiveGaborField_azymetric(x, y, A, x0, y0, sigma_x, sigma_y, sigma_x_old, sigma_y_old, theta,k,phi,B)
% Function:      receptiveField_azymetric_sigma
%                Creates an asymmetrically rotated and expanded two-dimensional Gaussian receptive field with variable standard deviations.
% Author:        Natalí Guisande
% Version:       November 14th, 2023.
% INPUTS:
%   x             - X-coordinate values of the input grid.
%   y             - Y-coordinate values of the input grid.
%   A             - Amplitude of the Gaussian function.
%   x0            - X-coordinate of the center of the receptive field.
%   y0            - Y-coordinate of the center of the receptive field.
%   sigma_x       - Original standard deviation of the Gaussian function in the X-direction for positive deviations.
%   sigma_y       - Original standard deviation of the Gaussian function in the Y-direction for positive deviations.
%   sigma_x_old   - Deformed towards the lesion standard deviation of the Gaussian function in the X-direction for negative deviations.
%   sigma_y_old   - Deformed towards the lesion standard deviation of the Gaussian function in the Y-direction for negative deviations.
%   theta         - Angle (in radians) for rotating the receptive field.
%
% OUTPUT:
%   z             - Two-dimensional matrix representing the rotated and expanded
%                   Gaussian receptive field based on the provided parameters.
%
    x=(x-x0);
    y=(y-y0);
    % Rotate coordinates
    x_prime = x*cos(theta) + y*sin(theta);
    y_prime = -x*sin(theta) + y*cos(theta);
    
    % Calculate the values of the receptive field for the positive deviations
    z_positive =A * gaborFunction(x_prime, y_prime, sigma_x, sigma_y, k, phi,B);
    
    
    % Calculate the values of the receptive field for the negative deviations
    z_negative = A*gaborFunction(x_prime, y_prime, sigma_x_old, sigma_y_old, k, phi,B);
   
    % Combines the receptive fields for positive and negative deviations.
    % Assigns values of Z_pos for positions where X_rotated is positive and Z_neg where X_rotated is negative
    z = z_positive .* (x_prime >= 0) + z_negative .* (x_prime  < 0);
end