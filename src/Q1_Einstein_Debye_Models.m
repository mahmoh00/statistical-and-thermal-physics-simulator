close all;

clc;

R = 8.314;

names = {'Silver','Copper','Iron','Silicon','Diamond'};

TE = [225, 345, 470, 645, 1320];

TD = [225, 345, 470, 645, 1860];

disp('Choose a material:');

for i = 1:5

    fprintf('%d. %s \n', i, names{i});

end

ch = input('Your choice (1-5): ');

while ch < 1 || ch > 5

    ch = input('Enter a valid number (1-5): ');

    if ch < 1 || ch > 5

        disp('Invalid, try again.');

    end

end

TEi = TE(ch);

TDi = TD(ch);

mat = names{ch};



T = linspace(0.1*TEi, 3*TEi, 500);  

cv_E = 3*R*(TEi./T).^2 .* exp(TEi./T) ./ (exp(TEi./T)-1).^2;

cv_DP = 3*R*ones(size(T));

% Debye model مع تصحيح

cv_D = zeros(size(T));

for i = 1:length(T)

    x = TDi / T(i);

    

    

    if x > 50  % حد آمن


        % cv ~ (12*pi^4/5)*R*(T/TD)^3

        cv_D(i) = (12*pi^4/5) * R * (T(i)/TDi)^3;

    else

        f = @(t) (t.^4 .* exp(t)) ./ (exp(t)-1).^2;

        cv_D(i) = 9*R*(T(i)/TDi)^3 * integral(f, 0, x);

    end

end

figure;

plot(T, cv_E, 'b-', 'LineWidth', 2); hold on;

plot(T, cv_D, 'r--', 'LineWidth', 2);

plot(T, cv_DP, 'k:', 'LineWidth', 2);

xlabel('Temperature (K)', 'FontSize', 12);

ylabel('c_v (J/mol·K)', 'FontSize', 12);

title(['Specific Heat Capacity of ', mat], 'FontSize', 14);

legend('Einstein Model', 'Debye Model', 'Dulong-Petit (3R)', 'Location', 'Best');

grid on;

xline(TEi, '--g', sprintf('T_E = %d K', TEi), 'LabelOrientation', 'horizontal');