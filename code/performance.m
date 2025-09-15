function performance(SNR_dB_range, ber_results, M, tx_symbols, ...
        rx_symbols_to_plot, plotConstellationForSNR, ...
        original_audio, reconstructed_audio, Fs, best_snr)

    figure('Name', 'BER vs. SNR');
    semilogy(SNR_dB_range, ber_results, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    grid on; title(['BER vs. SNR for ', num2str(M), '-QAM over AWGN Channel']);
    xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
    legend('Simulated BER', 'Location', 'southwest');
    axis([min(SNR_dB_range) max(SNR_dB_range) 10 ^ -5 1]);

    figure('Name', 'Constellation Diagrams');
    numConstPlots = length(rx_symbols_to_plot) + 1;
    numRows = floor(sqrt(numConstPlots));
    numCols = ceil(numConstPlots / numRows);

    ax1 = subplot(numRows, numCols, 1);
    scatter(ax1, real(tx_symbols), imag(tx_symbols), 30, 'b', 'filled');
    title(ax1, ['Transmitted ', num2str(M), '-QAM']);
    grid(ax1, 'on'); axis(ax1, 'square');
    limVal = sqrt(M); axis(ax1, [-limVal, limVal, -limVal, limVal]);
    draw_decision_boundaries(ax1, M);

    for i = 1:length(rx_symbols_to_plot)
        ax_i = subplot(numRows, numCols, i + 1);
        current_symbols = rx_symbols_to_plot{i};
        scatter(ax_i, real(current_symbols), imag(current_symbols), 15, 'b', 'filled');
        title(ax_i, ['Received, SNR = ', num2str(plotConstellationForSNR(i)), ' dB']);
        grid(ax_i, 'on'); axis(ax_i, 'square');
        limVal = max(abs([real(current_symbols); imag(current_symbols)])) * 1.1;
        if limVal < sqrt(M), limVal = sqrt(M); end
        axis(ax_i, [-limVal, limVal, -limVal, limVal]);
        draw_decision_boundaries(ax_i, M);
    end

    figure('Name', 'Audio Waveforms');
    t = (0:length(original_audio) - 1) / Fs;
    subplot(2, 1, 1);
    plot(t, original_audio); title('Original Audio Signal (Normalized)');
    xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim([0 t(end)]);
    subplot(2, 1, 2);
    plot(t, reconstructed_audio);
    title(['Reconstructed Audio Signal (from SNR = ', num2str(best_snr), ' dB)']);
    xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim([0 t(end)]);

end

function draw_decision_boundaries(ax, M)
    hold(ax, 'on');
    sqrtM = sqrt(M);

    boundary_locs =- (sqrtM - 2):2:(sqrtM - 2);
    x_lims = xlim(ax); y_lims = ylim(ax);

    for k = 1:length(boundary_locs)
        line(ax, [boundary_locs(k) boundary_locs(k)], y_lims, 'Color', 'r', 'LineStyle', '--');
        line(ax, x_lims, [boundary_locs(k) boundary_locs(k)], 'Color', 'r', 'LineStyle', '--');
    end

    hold(ax, 'off');
end
