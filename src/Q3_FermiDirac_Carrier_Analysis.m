clc;
clear;
close all;

%% Constants
kB_eV = 8.617333262e-5;      % Boltzmann constant (eV/K)
h = 6.626e-34;               % Planck constant (J.s)
m0 = 9.109e-31;              % Electron mass (kg)

%% Silicon Properties
Eg = 1.12;                   % Band gap (eV)
ni = 1e10;                   % Intrinsic concentration (cm^-3)

mn_star = 1.08 * m0;         % Effective electron mass
mp_star = 0.56 * m0;         % Effective hole mass

%% Energy Range
E = linspace(-0.75, 1.75, 1000);

%% Band Edges
Ec = Eg/2;
Ev = -Eg/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART A : Fermi-Dirac Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T_values = [80, 300];
mu_factors = [100, 10, 2];

for idxT = 1:length(T_values)

    T = T_values(idxT);

    figure('Color','w');
    hold on;

    for mu_fac = mu_factors

        mu = mu_fac * kB_eV * T;

        % Fermi-Dirac Distribution
        fFD = 1 ./ (1 + exp((E - mu)/(kB_eV * T)));

        plot(E, fFD, 'LineWidth', 2, ...
            'DisplayName', sprintf('\\mu = %d k_B T', mu_fac));

    end

    xlabel('Energy \epsilon (eV)');
    ylabel('Fermi-Dirac Distribution f_{FD}(\epsilon)');

    title(sprintf('Fermi-Dirac Distribution at T = %d K', T));

    legend('Location','best');

    grid on;
    hold off;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART B : Carrier Distribution in Silicon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Density of States Functions
% Scaling factors are used for visualization purposes only

Ns_c = @(E) 4*pi*((2*mn_star)/(h^2)).^(3/2) ...
            .* sqrt(max(0, E - Ec));

Ns_v = @(E) 4*pi*((2*mp_star)/(h^2)).^(3/2) ...
            .* sqrt(max(0, Ev - E));

%% Fermi Levels

EF_intrinsic = 0;

ND = 1e15;
NA = 1e16;

% Corrected Fermi level expressions
EF_n = kB_eV * 300 * log(ND / ni);

EF_p = -kB_eV * 300 * log(NA / ni);

Fermi_levels = [EF_intrinsic, EF_n, EF_p];

cases = { ...
    'Intrinsic Silicon', ...
    'n-type Silicon (N_D = 10^{15} cm^{-3})', ...
    'p-type Silicon (N_A = 10^{16} cm^{-3})'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:3

    EF = Fermi_levels(i);

    %% Fermi Functions

    f_e = 1 ./ (1 + exp((E - EF)/(kB_eV * 300)));

    f_h = 1 - f_e;

    %% Carrier Distributions

    n_E = (1e-21) * Ns_c(E) .* f_e;

    p_E = (1e-21) * Ns_v(E) .* f_h;

    %% Most Probable Energies

    [~, idx_n] = max(n_E);

    [~, idx_p] = max(p_E);

    E_mp_n = E(idx_n);

    E_mp_p = E(idx_p);

    %% Display Results

    fprintf('\n============================================\n');
    fprintf('%s\n', cases{i});
    fprintf('============================================\n');

    fprintf('Most Probable Electron Energy = %.4f eV\n', E_mp_n);

    fprintf('Most Probable Hole Energy     = %.4f eV\n', E_mp_p);

    %% Plotting

    figure('Color','w');

    plot(E, n_E, 'b-', 'LineWidth', 2);
    hold on;

    plot(E, p_E, 'r-', 'LineWidth', 2);

    % Most Probable Points
    plot(E_mp_n, n_E(idx_n), 'bo', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'b');

    plot(E_mp_p, p_E(idx_p), 'ro', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % Labels
    text(E_mp_n, n_E(idx_n), ...
        sprintf('  %.3f eV', E_mp_n), ...
        'Color', 'b', 'FontSize', 10);

    text(E_mp_p, p_E(idx_p), ...
        sprintf('  %.3f eV', E_mp_p), ...
        'Color', 'r', 'FontSize', 10);

    %% Figure Settings

    xlabel('Energy (eV)');

    ylabel('Carrier Distribution (Normalized)');

    title(['Carrier Distribution vs Energy - ', cases{i}]);

    legend( ...
        'Electrons n(E)', ...
        'Holes p(E)', ...
        'Most Probable Electron Energy', ...
        'Most Probable Hole Energy', ...
        'Location', 'NorthEast');

    grid on;
    hold off;

end
