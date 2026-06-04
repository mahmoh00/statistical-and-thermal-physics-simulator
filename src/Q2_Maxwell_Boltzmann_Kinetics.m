clc;
clear;
close all;

%% Constants
kB = 1.380649e-23;    
NA = 6.022e23;        

%% Gas properties (Xenon - Group 28-30)
M_molar = 131.29;                     
m = M_molar / 1000 / NA;              
N_total = 1e6;                      

%% Speed ranges
speed_ranges = [300 350;
                400 450;
                600 650;
                950 1000;
                1300 1350];
            
speed_centers = mean(speed_ranges, 2);
bin_width = 50;

%% Known data 
known_counts = [59862, NaN, 73946, NaN, 1752];
known_probs = known_counts / N_total;

%% Maxwell-Boltzmann PDF
MB_pdf = @(v, T) 4*pi * (m / (2*pi*kB*T))^(3/2) .* v.^2 .* exp(-m*v.^2 / (2*kB*T));


T_test = 100:10:1000;
error_list = zeros(size(T_test));


v_known = [speed_centers(1), speed_centers(3), speed_centers(5)];  % 325, 625, 1325
p_known = [known_probs(1), known_probs(3), known_probs(5)];         
for i = 1:length(T_test)
    T = T_test(i);
    p_calc = MB_pdf(v_known, T) * bin_width;
    error_list(i) = sum((p_calc - p_known).^2);
end


[min_error, min_idx] = min(error_list);
T_est = T_test(min_idx);


T_fine = (T_est-20):1:(T_est+20);
error_fine = zeros(size(T_fine));
for i = 1:length(T_fine)
    T = T_fine(i);
    p_calc = MB_pdf(v_known, T) * bin_width;
    error_fine(i) = sum((p_calc - p_known).^2);
end
[~, min_idx_fine] = min(error_fine);
T_est = T_fine(min_idx_fine);

fprintf('========================================\n');
fprintf('Estimated Temperature = %.2f K\n', T_est);
fprintf('========================================\n\n');


p_all = MB_pdf(speed_centers, T_est) * bin_width;
estimated_counts = round(p_all * N_total);

known_counts(2) = estimated_counts(2);
known_counts(4) = estimated_counts(4);

fprintf('Speed Range\t\tNumber of Molecules\n');
fprintf('----------------------------------------\n');
fprintf('%4d–%-4d m/s\t%8d (given)\n', 300, 350, known_counts(1));
fprintf('%4d–%-4d m/s\t%8d (estimated)\n', 400, 450, known_counts(2));
fprintf('%4d–%-4d m/s\t%8d (given)\n', 600, 650, known_counts(3));
fprintf('%4d–%-4d m/s\t%8d (estimated)\n', 950, 1000, known_counts(4));
fprintf('%4d–%-4d m/s\t%8d (given)\n', 1300, 1350, known_counts(5));


v = linspace(0, 1600, 1000);
P = MB_pdf(v, T_est);

figure('Color','w', 'Position', [100, 100, 800, 600]);
plot(v, P, 'b-', 'LineWidth', 2);
hold on;

for i = 1:length(speed_centers)
    x = speed_centers(i);
    y = MB_pdf(x, T_est);
    plot(x, y, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
    text(x, y + 2e-6, sprintf('%d–%d', speed_ranges(i,1), speed_ranges(i,2)), ...
        'HorizontalAlignment','center', 'FontSize', 9);
end
hold off;
xlabel('Speed (m/s)', 'FontSize', 12);
ylabel('Probability Density (s/m)', 'FontSize', 12);
title(sprintf('Maxwell-Boltzmann Distribution for Xenon (T = %.1f K)', T_est), 'FontSize', 14);
grid on;
legend('Theoretical MB Distribution', 'Speed Ranges', 'Location', 'best');


fprintf('\n--- Running Monte Carlo Simulation ---\n');
N_sim = N_total;
v_max = 2000;
v_sim = [];
P_max = max(P);

 
fprintf('Progress: ');
progress_step = N_sim / 20;

while length(v_sim) < N_sim
    v_trial = v_max * rand(); 
    y_trial = P_max * rand(); 
    if y_trial <= MB_pdf(v_trial, T_est)
        v_sim(end+1) = v_trial;
        
        
        if mod(length(v_sim), round(progress_step)) == 0
            fprintf('.');
        end
    end
end
fprintf(' Done!\n');

v_sim = v_sim';
fprintf('Simulation complete: %d speeds generated\n', length(v_sim));


fraction_range = sum(v_sim >= 200 & v_sim <= 900) / N_sim;
v_rms_sim = sqrt(mean(v_sim.^2));
v_mean_sim = mean(v_sim);

% Most probable speed from simulation
[counts, edges] = histcounts(v_sim, 100);
[~, max_idx] = max(counts);
v_mp_sim = (edges(max_idx) + edges(max_idx+1)) / 2;

v_mp_th = sqrt(2 * kB * T_est / m);
v_mean_th = sqrt(8 * kB * T_est / (pi * m));
v_rms_th = sqrt(3 * kB * T_est / m);

% Theoretical fraction (using erf function)
alpha1 = 200 * sqrt(m/(2*kB*T_est));
alpha2 = 900 * sqrt(m/(2*kB*T_est));
frac_th = (4/sqrt(pi)) * ( ...
    (sqrt(pi)/4 * erf(alpha2) - 0.5 * alpha2 * exp(-alpha2^2)) - ...
    (sqrt(pi)/4 * erf(alpha1) - 0.5 * alpha1 * exp(-alpha1^2)) );

fprintf('\n========================================\n');
fprintf('Speed Statistics Comparison\n');
fprintf('========================================\n');
fprintf('Quantity              Simulated    Theoretical     Error\n');
fprintf('--------------------------------------------------------\n');
fprintf('Fraction (200-900)    %.6f     %.6f     %.2f%%\n', ...
    fraction_range, frac_th, abs(fraction_range-frac_th)/frac_th*100);
fprintf('Most Probable (m/s)   %.2f        %.2f          %.2f%%\n', ...
    v_mp_sim, v_mp_th, abs(v_mp_sim-v_mp_th)/v_mp_th*100);
fprintf('Mean Speed (m/s)      %.2f        %.2f          %.2f%%\n', ...
    v_mean_sim, v_mean_th, abs(v_mean_sim-v_mean_th)/v_mean_th*100);
fprintf('RMS Speed (m/s)       %.2f        %.2f          %.2f%%\n', ...
    v_rms_sim, v_rms_th, abs(v_rms_sim-v_rms_th)/v_rms_th*100);
fprintf('========================================\n');


E_kin = 0.5 * m * v_sim.^2;
[counts_E, edges_E] = histcounts(E_kin, 100, 'Normalization', 'pdf');
E_centers = (edges_E(1:end-1) + edges_E(2:end)) / 2;

mean_E = mean(E_kin);
[~, idx_maxE] = max(counts_E);
mp_E = E_centers(idx_maxE);
mean_E_th = 1.5 * kB * T_est;

figure('Color','w', 'Position', [100, 100, 800, 600]);
plot(E_centers, counts_E, 'm-', 'LineWidth', 2);
hold on;
xline(mp_E, 'r--', sprintf('Most Probable = %.2e J', mp_E), 'LabelVerticalAlignment', 'bottom');
xline(mean_E, 'b--', sprintf('Mean Energy = %.2e J', mean_E), 'LabelVerticalAlignment', 'top');
hold off;
xlabel('Kinetic Energy (J)', 'FontSize', 12);
ylabel('Probability Density (J^{-1})', 'FontSize', 12);
title('Translational Kinetic Energy Distribution for Xenon', 'FontSize', 14);
grid on;
legend('Simulated Distribution', '', '', 'Location', 'best');

fprintf('\n--- Kinetic Energy Results ---\n');
fprintf('Most Probable Energy (sim): %.2e J\n', mp_E);
fprintf('Mean Energy (sim): %.2e J\n', mean_E);
fprintf('Mean Energy (theory 3/2 kT): %.2e J\n', mean_E_th);
fprintf('Error in Mean Energy: %.2f%%\n', abs(mean_E - mean_E_th)/mean_E_th*100);