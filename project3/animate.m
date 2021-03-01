load constants.mat;

figure;

[timestamps, positions, velocities] = simulate_launch([0 1000000], [radius_earth + launch_height, 0, 0, 9000]);

% Make live script support animations
% https://www.mathworks.com/matlabcentral/answers/271470-does-the-live-editor-support-figure-animations#answer_374998
s = settings;
s.matlab.editor.AllowFigureAnimation.TemporaryValue = 1;


clf; axis equal; hold on;

% axis_max = max(max(positions));
% axis_min = min(min(positions));
% 
% xlim([axis_min axis_max]);
% ylim([axis_min axis_max]);

viscircles([0 0], radius_earth, 'Color', 'blue');
text(0, 0, "Earth", "HorizontalAlignment","center", "VerticalAlignment","middle", "Color", "blue", "FontSize", 30);

l = animatedline();

for i=1:size(positions, 1)
    addpoints(l, positions(i, 1), positions(i, 2));
    drawnow
end

%plot(positions(:, 1), positions(:, 2), "r");
hold off;
