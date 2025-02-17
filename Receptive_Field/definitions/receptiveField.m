function z = receptiveField(x, y, A, x0, y0, sigma_x, sigma_y, theta)
    x=(x-x0);
    y=(y-y0);
    x_prime = x*cos(theta) + y*sin(theta);
    y_prime = -x*sin(theta) + y*cos(theta);
    z = A * exp(-(x_prime.^2/(2*sigma_x^2) + y_prime.^2/(2*sigma_y^2)));
end
