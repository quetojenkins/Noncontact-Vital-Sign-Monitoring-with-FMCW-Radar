% function [R_hat_t, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum, percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram, percentage_accuracy_array_batchSpectrum, NRMSE_batchSpectrum, medAE_batchSpectrum ] = heartRate(time_vector, phi_t, s_b, index, actualHeartRate, groundTruthheartRate, time, generate_plots)
function [R_hat_t, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum, percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram ] = heartRate(time_vector, phi_t, s_b, index, actualHeartRate, groundTruthheartRate, time, generate_plots)
 
    fprintf('\n ------- Entering Heart Rate -------\n');

    % --------------------- COLOUR SCHEME --------------------- %
    heartRateRed = [237/255, 27/255, 36/255];
    respirationRateBlue = [35/255, 64/255, 142/255];
    yellowcolour = [255/255, 209/255, 102/255];
    lapisluzulicolour = [44/255, 103/255, 159/255];
    lightPowderBluecolour = [159/255, 192/255, 216/255];
    cherryblossompink = [239/255, 169/255, 186/255];

    % --------------------- CONSTANTS AND VARIABLES --------------------- %
    vitalSign = 'HR';
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
    Fc_low = 2;
    Fc_high = 0.8;
    array_of_calculated_rr_values = [];
    threshold_zeroCrossings = 0;
    threshold_peakCounting = 0;
    batch_duration_s = 10; 
    CPI = 9; 
    nfft = 1024*23; 

    % --------------------- FILTER FOR HEART RATE FREQUENCIES --------------------- %
    [phi_t_filtered] = myFilter(Fc_high,Fc_low, fs, phi_t, vitalSign, index, time_vector,generate_plots);

    R_hat_t = (lamda/(4*pi))*phi_t_filtered; 


    if generate_plots == 1
        k20 = figure;
        pixels = 300 *0.16*(1/0.0254)
        k20.Position(3) = pixels;
        k20.Position(4) = 400; 
        plot(time_vector, R_hat_t, 'Color', heartRateRed, 'LineWidth', 1.5)

        xlabel('Time [s]');
        ylabel('Displacement [m]');
        % title(['Range History of Heart Rate from', index]);
    
        saveas(k20, ['MATLAB Plots/02 Range History Plots/', index,'_', vitalSign, '_RangeHistory.png']);
        close(k20);
    end
    
    % --------------------- ANALYSE TO EXTRACT HEART RATE --------------------- %
    [Respiration_Rate_frequency_spectrum, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum] = fftSpectrum(R_hat_t, s_b, fs, Fc_low, Fc_high, vitalSign, actualHeartRate, index, generate_plots);
    [vitalSign_rate_zero_crossing_method, array_frequency_zeroCrossings, midpoints, percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings] = zeroCrossings(R_hat_t, threshold_zeroCrossings, index, actualHeartRate,  Fc_high, Fc_low, time_vector, vitalSign, generate_plots);
    [midpointspeak, peakCounting_instFrequency,rate_counting_peaks_method, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting] = peakCounting(R_hat_t,threshold_peakCounting, index,  Fc_high, Fc_low, time_vector, actualHeartRate, vitalSign, generate_plots );
    [S,F,T,dominantFrequency, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram] = mySpectrogram(Respiration_Rate_frequency_spectrum,midpoints,array_frequency_zeroCrossings, midpointspeak,peakCounting_instFrequency,R_hat_t, CPI, PRI, nfft, fs, Fc_low, Fc_high, actualHeartRate, index, time_vector, vitalSign, generate_plots);
    % [Rate_over_time,meanRate_batch, time_per_batch, percentage_accuracy_array_batchSpectrum, NRMSE_batchSpectrum, medAE_batchSpectrum] = batchSpectrum(batch_duration_s, fs, R_hat_t, Fc_low, Fc_high, index, time_vector, actualHeartRate, vitalSign, generate_plots);

    % if generate_plots == 1
    %     p13 = figure;
    %     pixels = 300 *0.16*(1/0.0254)
    %     p13.Position(3) = pixels;
    %     p13.Position(4) = 400; 
    %     plot(time_vector,Respiration_Rate_frequency_spectrum, 'LineWidth', 1.5, 'Color', yellowcolour )
    %     hold on;
    %     plot(midpoints,array_frequency_zeroCrossings, 'LineWidth', 1.5, 'Color', lightPowderBluecolour )
    %     plot(midpointspeak,peakCounting_instFrequency, 'LineWidth', 1.5, 'Color', lapisluzulicolour )
    %     plot(time, groundTruthheartRate,'LineWidth', 1.5, 'Color', heartRateRed )
    %     plot(T, dominantFrequency,'LineWidth', 1.5, 'Color', cherryblossompink,'LineWidth', 1.5 )
    %     % title(['Respiration Rates over time Using Different Methods'])
    %     xlabel('Time [s]')
    %     ylabel('Heart Rate [bpm]')
    %     hold off;
    %     saveas(p13, ['MATLAB Plots/11 All Frequency vs Time Plots/', index,'_', vitalSign, '_RatePlot.png'])
    %     close(p13)
    % end

    Respiration_Rate_frequency_spectrum = Respiration_Rate_frequency_spectrum * ones(size(time_vector));  % A vector of the same value (e.g., 75 bpm)


    if generate_plots == 1
        p12 = figure;
        pixels = 300 *0.16*(1/0.0254)
        p12.Position(3) = pixels; 
        p12.Position(4) = 400; 
        plot(time_vector,Respiration_Rate_frequency_spectrum, 'LineWidth', 1.5, 'Color', yellowcolour )
        hold on;
        plot(midpoints,array_frequency_zeroCrossings, 'LineWidth', 1.5, 'Color', lightPowderBluecolour )
        plot(midpointspeak,peakCounting_instFrequency, 'LineWidth', 1.5, 'Color', lapisluzulicolour )
        plot(time, groundTruthheartRate,'LineWidth', 1.5, 'Color', heartRateRed )
        plot(T, dominantFrequency,'LineWidth', 1.5, 'Color', cherryblossompink,'LineWidth', 1.5 )
        % title(['Respiration Rates over time Using Different Methods'])
        xlabel('Time [s]')
        ylabel('Heart Rate [bpm]')
        legend('Frequency Spectrum', 'Zero Crossings', 'Peak Counting', 'Actual Heart Rate','Spectrogram');
        hold off;
        ylim([0 140]);
        saveas(p12, ['MATLAB Plots/11 All Frequency vs Time Plots/', index,'_', vitalSign, '_RatePlot.png'])
        close(p12);
    end

end