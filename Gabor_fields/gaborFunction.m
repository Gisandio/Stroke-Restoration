function Ds = gaborFunction(x, y, sigma_x, sigma_y, k, phi,B)
% gaborFunction - Compute the Gabor function value for a given point (x, y).
%
% Syntax:
%   Ds = gaborFunction(x, y, sigma_x, sigma_y, k, phi, B)
%
% Inputs:
%   x - Spatial coordinate along the x-axis.
%   y - Spatial coordinate along the y-axis.
%   sigma_x - Standard deviation of the Gaussian in the x-direction.
%   sigma_y - Standard deviation of the Gaussian in the y-direction.
%   k - Spatial frequency of the sinusoidal component.
%   phi - Phase offset of the sinusoidal component.
%   B - Scaling factor for the x-coordinate.
%
% Output:
%   Ds - Value of the Gabor function at the specified point (x, y).
%
% Description:
%   The Gabor function is a Gaussian modulated by a sinusoidal wave. It is commonly used
%   in image processing and computer vision for tasks such as texture analysis and edge detection.
%
%   The parameters control various aspects of the Gabor function:
%   - x, y: Spatial coordinates specifying the location in the image.
%   - sigma_x, sigma_y: Standard deviations of the Gaussian in the x and y directions, respectively.
%   - k: Spatial frequency of the sinusoidal component (controls the number of oscillations).
%   - phi: Phase offset of the sinusoidal component.
%   - B: Scaling factor for the x-coordinate, which elongates or compresses the Gaussian in the x-direction.
%
    Ds = (1 / (2 * pi * sigma_y * sigma_x)) * exp(-(y.^2 / (2*sigma_y^2) + (B*x).^2 / (2*sigma_x^2))) .* cos(k*y - phi);

end