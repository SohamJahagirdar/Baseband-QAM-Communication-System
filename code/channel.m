function rx_symbols = channel(tx_symbols, snr_db)
    signal_power = mean(abs(tx_symbols) .^ 2);

    snr_linear = 10 ^ (snr_db / 10);
    noise_power = signal_power / snr_linear;
    variance_per_component = noise_power / 2;

    noise_std_dev = sqrt(variance_per_component);
    noise_real_part = noise_std_dev * randn(size(tx_symbols));
    noise_imag_part = noise_std_dev * randn(size(tx_symbols));

    noise = noise_real_part + 1j * noise_imag_part;

    rx_symbols = tx_symbols + noise;

end
