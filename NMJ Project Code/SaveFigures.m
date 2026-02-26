% Get handles to all open figures
figs = findall(0, 'Type', 'figure');

% Loop through each figure and save it
for k = 1:length(figs)
    fig = figs(k);
    
    % Bring figure into focus (optional but good practice)
    figure(fig);
    
    % Create filename (Figure_1.png, Figure_2.png, etc.)
    filename = sprintf('Figure_%d.png', fig.Number);
    
    % Save as PNG
    exportgraphics(fig, filename, 'Resolution', 300);
end

disp('All figures saved as PNG files.');