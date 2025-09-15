function [tx_symbols, padded_bit_stream] = qam_modulator(bit_stream, M, k)

    num_bits = length(bit_stream);
    remainder = mod(num_bits, k);

    if remainder ~= 0
        bits_to_pad = k - remainder;
        padded_bit_stream = [bit_stream; zeros(bits_to_pad, 1)];
    else
        padded_bit_stream = bit_stream;
    end

    if mod(log2(M), 2) ~= 0
        error('M must be a power of 2 with an even exponent (e.g., 4, 16, 64).');
    end

    sqrtM = sqrt(M);
    points1D = -(sqrtM - 1):2:(sqrtM - 1);
    [X, Y] = meshgrid(points1D, points1D);
    temp_map = (X + 1j * Y)';
    constellation_points = temp_map(:);
    
    constellation_map = constellation_points;

    bit_matrix = reshape(padded_bit_stream, k, [])';
    symbol_indices = bi2de(bit_matrix, 'left-msb');
    tx_symbols = constellation_map(symbol_indices + 1);

end
