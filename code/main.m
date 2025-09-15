clear;
close all;
clc;

M = 16;
k = log2(M);
audioInputFile = 'sampleWAV.wav';
audioOutputFileBase = 'output_audio';
numQuantizationBits = 8;
SNR_dB_range = 4:4:28;
plotConstellationForSNR = SNR_dB_range;

disp('Starting Simulation...');

[tx_bit_stream, Fs, original_audio_norm] = a2d(audioInputFile, numQuantizationBits);
disp('Step 1: A/D Conversion complete.');

[tx_symbols, padded_bit_stream] = qam_modulator(tx_bit_stream, M, k);
disp('Step 2: QAM Modulation complete.');

numSnrPoints = length(SNR_dB_range);
ber_results = zeros(1, numSnrPoints);
rx_symbols_to_plot = {};
final_reconstructed_signal = [];
num_original_bits = length(tx_bit_stream);

fprintf('Steps 3, 4 & 5: Simulating over AWGN channel and generating audio files...\n');

for i = 1:numSnrPoints
    snr_db = SNR_dB_range(i);
    fprintf('--> Simulating for SNR = %d dB...\n', snr_db);

    rx_symbols = channel(tx_symbols, snr_db);

    rx_bit_stream = qam_demodulator(rx_symbols, M);

    [~, ber] = biterr(padded_bit_stream, rx_bit_stream);
    ber_results(i) = ber;
    fprintf('    -> BER: %f\n', ber);

    rx_symbols_to_plot{end + 1} = rx_symbols;

    currentAudioOutputFile = sprintf('%s_SNR_%ddB.wav', audioOutputFileBase, snr_db);
    reconstructed_signal_current = d2a(rx_bit_stream, num_original_bits, numQuantizationBits, Fs, currentAudioOutputFile);
    fprintf('    -> Reconstructed audio saved to ''%s''\n', currentAudioOutputFile);

    if i == numSnrPoints
        final_reconstructed_signal = reconstructed_signal_current;
        best_snr = snr_db;
    end

end

disp('Channel simulation loop complete.');

disp('Step 6: Generating performance plots...');
performance(SNR_dB_range, ber_results, M, tx_symbols, ...
    rx_symbols_to_plot, plotConstellationForSNR, ...
    original_audio_norm, final_reconstructed_signal, Fs, best_snr);

disp('Step 7: Generating summary plot...');
t = (0:length(original_audio_norm) - 1) / Fs;
fig_summary = figure('Name', 'Summary Results', 'Position', [500, 500, 1400, 1000]);

subplot(2, 3, [1, 2]);
semilogy(SNR_dB_range, ber_results, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
title(['BER vs. SNR for ', num2str(M), '-QAM'], 'FontSize', 14);
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);

subplot(2, 3, 3);
best_rx_symbols = rx_symbols_to_plot{end};
scatter(real(best_rx_symbols), imag(best_rx_symbols), 30, 'b', 'filled');
title(['Best Constellation (SNR = ', num2str(best_snr), ' dB)'], 'FontSize', 12);
grid on; axis square;
limVal = max(abs([real(best_rx_symbols); imag(best_rx_symbols)])) * 1.1;
if limVal < sqrt(M), limVal = sqrt(M); end
axis([-limVal, limVal, -limVal, limVal]);

hold on;
sqrtM = sqrt(M);
boundary_locs = -(sqrtM - 2):2:(sqrtM - 2);
x_lims = xlim; y_lims = ylim;

for k = 1:length(boundary_locs)
    line([boundary_locs(k) boundary_locs(k)], y_lims, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
    line(x_lims, [boundary_locs(k) boundary_locs(k)], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
end

hold off;

subplot(2, 3, [4, 5, 6]);
t_short = t(1:min(length(t), Fs * 2));
orig_short = original_audio_norm(1:length(t_short));
recon_short = final_reconstructed_signal(1:length(t_short));

plot(t_short, orig_short, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Original');
hold on;
plot(t_short, recon_short, 'r--', 'LineWidth', 1.5, 'DisplayName', ['Reconstructed (SNR = ', num2str(best_snr), ' dB)']);
hold off;
title('Audio Signal Comparison (First 2 seconds)', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
legend('Location', 'best');
grid on;

disp('Simulation finished.');

% disp(['Playing the best reconstructed audio (from SNR = ', num2str(best_snr), ' dB)...']);
% sound(final_reconstructed_signal, Fs);
