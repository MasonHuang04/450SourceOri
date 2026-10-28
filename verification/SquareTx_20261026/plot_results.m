% Plot the actual RTL distance sweep; no synthetic replacement data.
artifactDir = fileparts(mfilename('fullpath'));
checksFile = fullfile(artifactDir, 'checks.json');
assert(isfile(checksFile), 'Place this script beside released checks.json.');
checks = jsondecode(fileread(checksFile));
points = checks.frames.cases;
fig = figure('Color', 'white', 'Position', [100 100 1200 620]);
plot([points.distance_cm], [points.error_mm], '-o', ...
    'LineWidth', 1.7, 'MarkerSize', 5, 'Color', [0.03 0.43 0.62]);
yline(0, 'Color', [.6 .65 .7]);
grid on;
xlabel('Reflector distance (cm)');
ylabel('Distance error (mm)');
title('Square TX / Sine Reference: Ideal-Model Distance Error');
xticks(10:2.5:75); xtickangle(45); xlim([9 76]); ylim([-.5 .6]);
set(gca, 'FontSize', 13);
exportgraphics(fig, fullfile(artifactDir, 'distance_error_EN.png'), 'Resolution', 180);
