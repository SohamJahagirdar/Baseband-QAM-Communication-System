function [tx_bit_stream, Fs, y_norm] = a2d(audioInputFile, numQuantizationBits)

    if ~exist(audioInputFile, 'file')
        disp('Input audio file not found. Creating a sample audio file.');
        Fs_gen = 44100; duration = 3; t_gen = 0:1 / Fs_gen:duration - 1 / Fs_gen;
        y_gen = 0.4 * sin(2 * pi * 440 * t_gen) + 0.4 * sin(2 * pi * 880 * t_gen);
        audiowrite(audioInputFile, y_gen, Fs_gen);
    end

    [y, Fs] = audioread(audioInputFile);

    if size(y, 2) > 1, y = mean(y, 2); end
    y_norm = y' / max(abs(y));

    quantized_indices = round((y_norm + 1) / 2 * (2 ^ numQuantizationBits - 1));

    tx_bit_matrix = de2bi(quantized_indices, numQuantizationBits, 'left-msb');
    tx_bit_stream = reshape(tx_bit_matrix', [], 1);
end
