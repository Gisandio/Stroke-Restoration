num_colors = 8;
% Control points for the custom colormap
control_points = [0 .25 .5 .75 1];

% Colors corresponding to the control points (RGB values)
colors = flip([157 1 66;  % Color 1: #9d0142
               246 110 69; % Color 2: #f66e45
               249 231 159; % Color 3: #ffffbb
               101 192 174; % Color 4: #65c0ae
               94 79 159]);  % Color 5: #5e4f9f

% Interpolate colors between control points to create the colormap
sampled_colors = interp1(control_points, colors, linspace(0, 1, num_colors));

% Normalize color values to the range [0, 1]
sampled_colors = sampled_colors / 255.0;

% Duración de la simulación y paso de tiempo
T = 200; % Duración de la simulación en ms
dt = 0.1; % Paso de tiempo en ms
t = 0:dt:T; % Vector de tiempo

% Parámetros para cada tipo de neurona
% Formato: {'Nombre', a, b, c, d, v_inicial, y_lim_min, y_lim_max, corriente}
neuron_types = {
    'Disparo Regular (RS)', 0.02, 0.2, -65, 8, -65, -90, 40, 10; % Corriente de 10 para RS
    'Estallido Intrínseco (IB)', 0.02, 0.2, -55, 4, -65, -90, 40, 10; % Corriente de 12 para IB
    'Chattering (CH)', 0.02, 0.2, -50, 2, -65, -90, 40, 10; % Corriente de 15 para CH
    'Disparo Rápido (FS)', 0.1, 0.2, -65, 2, -65, -90, 40, 10; % Corriente de 20 para FS
    'Tálamo-Cortical (TC1)', 0.02, 0.2, -65, 2.0, -65, -90, 40, 5; % Corriente de 8 para TC1
    'Tálamo-Cortical (TC2)', 0.02, 0.25, -65, 1.05, -90, -90, 40, 0; % Corriente de 9 para TC2
    'Resonador (RZ)', 0.05, 0.26, -60, 0, -63, -64, -61, 0; % Corriente de 0 para RZ
    'Disparo de Bajo Umbral (LTS)', 0.02, 0.25, -65, 2, -65, -90, 40, 10 % Corriente de 7 para LTS
};

% Crear figura
figure('position',[0 0 1200 600]);
for n = 1:size(neuron_types, 1)
    % Parámetros específicos para el tipo de neurona
    neuron_name = neuron_types{n, 1};
    a = neuron_types{n, 2};
    b = neuron_types{n, 3};
    c = neuron_types{n, 4};
    d = neuron_types{n, 5};
    v_init = neuron_types{n, 6}; % Potencial de membrana inicial
    y_lim_min = neuron_types{n, 7}; % Límite inferior del eje y
    y_lim_max = neuron_types{n, 8}; % Límite superior del eje y
    I_value = neuron_types{n, 9}; % Corriente específica para esta neurona
    
    % Variables de estado
    v = v_init * ones(size(t)); % Potencial de membrana inicial
    u = b * v(1); % Inicialización de la variable de recuperación
    I = I_value * ones(size(t)); % Corriente de entrada constante

    % Simulación del modelo de Izhikevich
    for i = 1:length(t) - 1
        if v(i) >= 30 % Condición de disparo
            v(i) = 30; % Para visualizar el pico
            v(i+1) = c;
            u = u + d;
        else
            dv = 0.04 * v(i)^2 + 5 * v(i) + 140 - u + I(i);
            du = a * (b * v(i) - u);
            v(i+1) = v(i) + dv * dt;
            u = u + du * dt;
        end
    end
    
    % Subgráfico para el tipo de neurona
    subplot(2, 4, n);
    plot(t, v, 'Color', sampled_colors(n, :),'LineWidth',1.5); % Usar la paleta de colores definida
    xlabel('Tiempo (ms)','FontName', 'Helvetica', 'FontSize', 11, 'FontWeight', 'bold')
    ylabel('Voltaje (mV)','FontName', 'Helvetica', 'FontSize', 11, 'FontWeight', 'bold')
    title(neuron_name);
    axis([0 T y_lim_min y_lim_max]); % Ajuste de ejes usando los límites especificados
end
%tightfig
set(gcf, 'Color', [255/255, 252/255, 242/255])
% Ajuste de layout
%sgtitle('Patrones de Disparo Neuronal - Modelo de Izhikevich');

