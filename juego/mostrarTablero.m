function mostrarTablero(data, mask, row_array, col_array)

    n = size(data,1);

    % Crear la figura
    figure;
    hold on;
    axis equal;
    axis off;

    cell_size = 1;

    % Dibujar las celdas de la matriz
    for i = 1:n
        for j = 1:n
            % Coordenadas de la celda
            x = (j-1) * cell_size;
            y = -(i-1) * cell_size;

            
            rectangle('Position', [x, y-1, cell_size, cell_size], 'EdgeColor', 'black');

            
            number = data(i, j);

            % Dibujar el número
            if mask(i, j)
                % Si está en mask tacha
                text(x + cell_size/2, y - cell_size/2, num2str(number), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                    'Color', 'black', 'FontSize', 12);
                line([x, x+cell_size], [y, y-cell_size], 'Color', 'red', 'LineWidth', 1.5);
                line([x, x+cell_size], [y-cell_size, y], 'Color', 'red', 'LineWidth', 1.5);
            else
                % Si no está en mask solo muestra
                text(x + cell_size/2, y - cell_size/2, num2str(number), ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                    'Color', 'black', 'FontSize', 12);
            end
        end
    end

    % números de las filas
    for i = 1:n
        y = -(i-1) * cell_size;
        text(-cell_size/2, y - cell_size/2, num2str(row_array(i)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'Color', 'blue', 'FontSize', 12);
    end

    % números de las columnas
    for j = 1:n
        x = (j-1) * cell_size;
        text(x + cell_size/2, cell_size/2 - (n+1) * cell_size, num2str(col_array(j)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'Color', 'blue', 'FontSize', 12);
    end

    hold off;
end

