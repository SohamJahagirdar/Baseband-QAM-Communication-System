function reconstructed_signal = d2a(rx_bit_stream, num_original_bits, numQuantizationBits, Fs, audioOutputFile)

    rx_bit_stream_unpadded = rx_bit_stream(1:num_original_bits);

    rx_bit_matrix = reshape(rx_bit_stream_unpadded, numQuantizationBits, [])';
    rx_quantized_indices = bi2de(rx_bit_matrix, 'left-msb');

    reconstructed_signal = (double(rx_quantized_indices) / (2 ^ numQuantizationBits - 1)) * 2 - 1;

    audiowrite(audioOutputFile, reconstructed_signal, Fs);
end
