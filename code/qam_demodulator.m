function rx_bit_stream = qam_demodulator(rx_symbols, M)

    k = log2(M);

    if mod(log2(M), 2) ~= 0
        error('M must be a power of 2 with an even exponent (e.g., 4, 16, 64).');
    end

    sqrtM = sqrt(M);
    points1D = -(sqrtM - 1):2:(sqrtM - 1);
    [X, Y] = meshgrid(points1D, points1D);
    temp_map = (X + 1j * Y)';
    constellation_points = temp_map(:);

    constellation_map = constellation_points;

    detected_indices = zeros(length(rx_symbols), 1);

    for i = 1:length(rx_symbols)
        received_symbol = rx_symbols(i);
        distances_sq = abs(received_symbol - constellation_map) .^ 2;
        [~, min_index] = min(distances_sq);
        detected_indices(i) = min_index - 1;
    end

    bit_matrix = de2bi(detected_indices, k, 'left-msb');
    rx_bit_stream = reshape(bit_matrix', [], 1);

end
