function plotPanel(ax, t, y, ylab)
plot(ax, t, y);
box(ax, 'off');
ylabel(ax, ylab);
ax.FontSize = 14;
ax.FontWeight = "bold";
end