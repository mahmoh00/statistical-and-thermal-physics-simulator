clc;
clear;
close all;

%% Physical Constants

h = 6.626e-34;          % Planck constant (J.s)
c = 3.0e8;              % Speed of light (m/s)
kB = 1.381e-23;         % Boltzmann constant (J/K)

%% Wavelength Range

lambda_nm = linspace(100,3000,1000);

lambda = lambda_nm * 1e-9;

%% User Input

prompt = 'Enter temperature(s) in Kelvin (e.g. [3000 4000 5000]): ';

T_input = input(prompt);

if isempty(T_input)

    T_input = [3000 4000 5000];

end

%% Plotting

figure('Color','w');

hold on;

colors = ['r','g','b','m','k'];

for i = 1:length(T_input)

    T = T_input(i);

    clr = colors(mod(i-1,length(colors))+1);

    %% Planck Distribution

    exponent = (h*c) ./ (lambda*kB*T);

    % Prevent overflow
    exponent(exponent > 700) = 700;

    % Bose-Einstein distribution term
    BE_term = 1 ./ (exp(exponent) - 1);

    %% Spectral Radiance

    B_lambda = ((2*h*c^2) ./ (lambda.^5)) .* BE_term;

    % Normalization for better visualization
    B_lambda = B_lambda ./ max(B_lambda);

    %% Plot Curve

    plot(lambda_nm, B_lambda, ...
        'Color', clr, ...
        'LineWidth', 2, ...
        'DisplayName', sprintf('T = %d K', T));

    %% Wien Peak Wavelength

    lambda_peak = 2.898e-3 / T;

    exponent_peak = (h*c) / (lambda_peak*kB*T);

    B_peak = ((2*h*c^2)/(lambda_peak^5)) ...
             /(exp(exponent_peak)-1);

    B_peak = B_peak / max(B_lambda);

    %% Mark Peak Point

    plot(lambda_peak*1e9, 1, 'o', ...
        'Color', clr, ...
        'MarkerFaceColor', clr, ...
        'MarkerSize', 8);

    %% Peak Label

    text(lambda_peak*1e9 + 20, 1, ...
        sprintf('\\lambda_{peak} = %.0f nm', lambda_peak*1e9), ...
        'Color', clr, ...
        'FontSize', 10);

end

hold off;

%% Figure Labels

xlabel('Wavelength \lambda (nm)', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

ylabel('Normalized Spectral Radiance', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

title('Blackbody Radiation Spectrum using Planck Law', ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

legend('Location','northeast');

grid on;

set(gca,'FontSize',12);