% function [R_hat_t, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum, percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram, percentage_accuracy_array_batchSpectrum, NRMSE_batchSpectrum, medAE_batchSpectrum ] = respirationRate(time_vector, phi_t, s_b, index, actual_respiration_rate, generate_plots)
function [R_hat_t, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum, percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram] = respirationRate(time_vector, phi_t, s_b, index, actual_respiration_rate, generate_plots)

fprintf('\n------- Entering Respiration Rate -------\n');

    % --------------------- COLOUR SCHEME --------------------- %
    heartRateRed = [237/255, 27/255, 36/255];
    respirationRateBlue = [35/255, 64/255, 142/255];
    yellowcolour = [255/255, 209/255, 102/255];
    lapisluzulicolour = [44/255, 103/255, 159/255];
    lightPowderBluecolour = [159/255, 192/255, 216/255];
    cherryblossompink = [239/255, 169/255, 186/255];
    
    vitalSign = 'RR';

    % --------------------- VARIABLES AND CONSTANTS --------------------- %
    c = 299792458; 
    NumChirps = 32; 
    NumSamples = 96;
    NumVirtualChannels = 12;
    fc = 79e9;                
    PRI = 0.001524390244;
    PRF = 1/PRI;
    lamda = c/fc;
    Bw = 4e9;
    Tchirp = PRI;
    fs = 1/PRI;
    Fc_low = 0.5;
    Fc_high = 0.1;
    array_of_calculated_rr_values = [];
    range_bin_to_extract = 91;
    threshold_zeroCrossings = 0;
    threshold_peakCounting = 0;
    batch_duration_s = 10;
    CPI = 9; 
    nfft = 1024*23;

    % --------------------- FILTER FOR RESPIRATION FREQUENCIES --------------------- %
    [phi_t_filtered] = myFilter(Fc_high,Fc_low, fs, phi_t, vitalSign, index, time_vector,generate_plots);

    % --------------------- RESPIRATION RANGE HISTORY --------------------- %
    R_hat_t = (lamda/(4*pi))*phi_t_filtered; 

    if generate_plots == 1
        k3 = figure;
        pixels = 300 *0.16*(1/0.0254)
        k3.Position(3) = pixels; 
        k3.Position(4) = 400; 
        plot(time_vector, R_hat_t, 'Color', respirationRateBlue, 'LineWidth', 1.5)
        % grid on;
        xlabel('Time [s]');
        ylabel('Displacement [m]');
        % title(['Range History of Respiration Rate from', index]);
        saveas(k3, ['MATLAB Plots/02 Range History Plots/', index,'_', vitalSign, '_RangeHistory.png']);
        close(k3);
    end

    % --------------------- ANALYSIS TECHNIQUES --------------------- %
    [Respiration_Rate_frequency_spectrum, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum] = fftSpectrum(R_hat_t, s_b, fs, Fc_low, Fc_high, vitalSign, actual_respiration_rate, index, generate_plots);
    [vitalSign_rate_zero_crossing_method, array_frequency_zeroCrossings, midpoints, percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings] = zeroCrossings(R_hat_t, threshold_zeroCrossings, index, actual_respiration_rate,  Fc_high, Fc_low, time_vector, vitalSign, generate_plots);
    [midpointspeak, peakCounting_instFrequency,rate_counting_peaks_method, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting] = peakCounting(R_hat_t,threshold_peakCounting, index,  Fc_high, Fc_low, time_vector,actual_respiration_rate, vitalSign , generate_plots);
    [S,F,T,dominantFrequency, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram] = mySpectrogram(Respiration_Rate_frequency_spectrum,midpoints,array_frequency_zeroCrossings, midpointspeak,peakCounting_instFrequency, R_hat_t, CPI, PRI, nfft, fs, Fc_low, Fc_high, actual_respiration_rate, index, time_vector, vitalSign, generate_plots);
    % [Rate_over_time,meanRate_batch, time_per_batch, percentage_accuracy_array_batchSpectrum, NRMSE_batchSpectrum, medAE_batchSpectrum] = batchSpectrum(batch_duration_s, fs, R_hat_t, Fc_low, Fc_high, index, time_vector, actual_respiration_rate, vitalSign, generate_plots);
    Respiration_Rate_frequency_spectrum = Respiration_Rate_frequency_spectrum * ones(size(time_vector));  % A vector of the same value (e.g., 75 bpm)
    actual_respiration_rate = actual_respiration_rate*ones(size(time_vector));

    if generate_plots == 1
        p12 = figure;
        pixels = 300 *0.16*(1/0.0254)
        p12.Position(3) = pixels; 
        p12.Position(4) = 400; 
        plot(time_vector,Respiration_Rate_frequency_spectrum, 'LineWidth', 1.5, 'Color', yellowcolour )
        hold on;
        plot(midpoints,array_frequency_zeroCrossings, 'LineWidth', 1.5, 'Color', lightPowderBluecolour )
        plot(midpointspeak,peakCounting_instFrequency, 'LineWidth', 1.5, 'Color', lapisluzulicolour )
        plot(time_vector, actual_respiration_rate,'LineWidth', 1.5, 'Color', respirationRateBlue )
        plot(T, dominantFrequency,'LineWidth', 1.5, 'Color', cherryblossompink,'LineWidth', 1.5 )
        % title(['Respiration Rates over time Using Different Methods'])
        xlabel('Time [s]')
        ylabel('Respiration Rate [bpm]')
        legend('Frequency Spectrum', 'Zero Crossings', 'Peak Counting', 'Actual Respiration Rate' ,'Spectrogram');
        hold off;
        ylim([0 35]);
        saveas(p12, ['MATLAB Plots/11 All Frequency vs Time Plots/', index,'_', vitalSign, '_RatePlot.png'])
        close(p12);
    end

end