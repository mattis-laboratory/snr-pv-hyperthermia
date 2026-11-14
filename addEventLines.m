function addEventLines(ax, t, events, style)

% Always draw BL/HEAT if present
if isfield(events, 'BL') && ~isempty(events.BL)
    addOne(ax, t, events.BL, style.BL);
end

% Draw others only if present
fn = {'EEC','UEO','OFF'};
for i = 1:numel(fn)
    f = fn{i};
    if isfield(events, f) && ~isempty(events.(f))
        addOne(ax, t, events.(f), style.(f));
    end
end

    function addOne(axh, tt, idx, st)
        % idx is an index into tt
        if idx >= 1 && idx <= numel(tt)
            xline(axh, tt(idx), 'Color', st.Color, 'LineStyle', ...
                st.LineStyle, 'LineWidth', st.LineWidth);
        end
    end
end
