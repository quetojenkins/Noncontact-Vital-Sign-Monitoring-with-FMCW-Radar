function [vitalSignRate_frequency_spectrum, percentage_accuracy_array_fftSpectrum, NRMSE_fftspectrum, medAE_fftspectrum] = fftSpectrum(R_hat_t, s_b, fs, Fc_low, Fc_high, vitalSign, actual_respiration_rate, index,generate_plots)
    heartRateRed = [237/255, 27/255, 36/255];
    respirationRateBlue = [35/255, 64/255, 142/255];
    yellowcolour = [255/255, 209/255, 102/255];
    lapisluzulicolour = [44/255, 103/255, 159/255];
    lightPowderBluecolour = [159/255, 192/255, 216/255];
    cherryblossompink = [239/255, 169/255, 186/255];
    if vitalSign == 'RR'
        colourofVitalSign = respirationRateBlue;
        secondaryColour = yellowcolour;
        name = 'Respiration Rate';
    else
        colourofVitalSign = heartRateRed;
        secondaryColour = lapisluzulicolour;
        name = 'Heart Rate';
    end
    
    fprintf('\n------- FREQUENCY SPECTRUM ANALYSIS OF %.2s -------\n', vitalSign);
    % FFT and Respiration Vector Computation
        % --------------------- STARTING CPU TIMER --------------------- %
        startCPUTime = cputime;
        % -------------------------------------------------------------- %
        % --------------------- STARTING MEMORY USAGE --------------------- %
        % beforeMem = memory;
        % ----------------------------------------------------------------- %  
 
        % --------------------- STARTING EXECUTION TIMER --------------------- %
        tic;
        % -------------------------------------------------------------------- %
    R_HAT_f = fftshift(fft(R_hat_t));
    M = size(s_b, 1);
    Freq_Axis_Hz = (-M/2:1:(M/2-1))*fs/M; 
    
    % Index of the zero-frequency component
    zero_freq_index = M / 2 + 1;
    
    % Remove zero-frequency component
    R_HAT_f(zero_freq_index) = 0;
    
    disp('Method: Frequency Spectrum');
    
    % Find Respiration Rate Vector in bpm
    RateVector_bpm = Freq_Axis_Hz * 60; 
    
    % Index for frequencies between -2 Hz and 2 Hz
    freq_range_index = (Freq_Axis_Hz >= 0) & (Freq_Axis_Hz <= Fc_low);
    
    % Filtered frequency components
    Freq_Axis_Hz_filtered = Freq_Axis_Hz(freq_range_index);
    R_HAT_f_filtered = R_HAT_f(freq_range_index);
    
    % Find the peak amplitude in the filtered range
    [peakValue_dB, peakIndex] = max(20 * log10(abs(R_HAT_f_filtered)));
    vitalSignRate_frequency_spectrum = abs(60 * Freq_Axis_Hz_filtered(peakIndex));
        % --------------------- GETTING EXECUTION TIME --------------------- %
        executionTime = toc;
        % ------------------------------------------------------------------ %
        % --------------------- STARTING CPU TIMER --------------------- %
        endCPUTime = cputime - startCPUTime;
        % -------------------------------------------------------------- %
        % --------------------- GETTING MEMORY USAGE --------------------- %
        % afterMem = memory;
        % memoryUsed = afterMem.MemUsedMATLAB - beforeMem.MemUsedMATLAB;
        % ----------------------------------------------------------------- %  
    
    disp(['The rate of the target using frequency spectrum analysis is ', num2str(vitalSignRate_frequency_spectrum), ' bpm.']);
    disp(index);

    % Plot the Frequency Spectrum
    if generate_plots == 1
        k4 = figure;
        pixels = 300 *0.16*(1/0.0254)
        k4.Position(3) = pixels; % Increase the width (3rd element)
        k4.Position(4) = 400;
        stem(Freq_Axis_Hz, abs(R_HAT_f), 'Color', lightPowderBluecolour, 'LineWidth', 1.5, 'MarkerFaceColor', lightPowderBluecolour); % Stem plot of the spectrum
        hold on;
        
        peakIndex = abs(peakIndex);
        % Add a red dot at the peak frequency component
        stem(Freq_Axis_Hz_filtered(peakIndex), abs(R_HAT_f_filtered(peakIndex)), 'Color', colourofVitalSign, 'Marker', 'o', 'MarkerFaceColor', colourofVitalSign, 'MarkerEdgeColor', colourofVitalSign, 'MarkerSize', 8, 'LineWidth', 1.5);
        
        xlabel('Frequency [Hz]');
        ylabel('Amplitude');
        % title(['Frequency Spectrum of ',name, ' for ', index]);
        xlim([0, 2]);
        legend('Frequency Spectrum', ['Peak Frequency Component'], 'Location', 'best'); % Adjust location as needed

        hold off;
        
        saveas(k4,['MATLAB Plots/03 FFT Spectrum Plots/',index, '_', vitalSign,'_fftSpectrum.png']);
        close(k4);
    end
    
    % --------------------- GETTING EXECUTION TIME --------------------- %
    executionTime = toc;
    % ------------------------------------------------------------------ %
    % --------------------- STARTING CPU TIMER --------------------- %
    endCPUTime = cputime - startCPUTime;
    % -------------------------------------------------------------- %
    % --------------------- GETTING MEMORY USAGE --------------------- %
    % afterMem = memory;
    % memoryUsed = afterMem.MemUsedMATLAB - beforeMem.MemUsedMATLAB;
    % ----------------------------------------------------------------- %  
    createPerformanceMetricsForMethods(1,executionTime, endCPUTime, 1);
    percentage_accuracy_array_fftSpectrum = percentageAccuracy(actual_respiration_rate, vitalSignRate_frequency_spectrum);
    NRMSE_fftspectrum = nrmse(actual_respiration_rate, vitalSignRate_frequency_spectrum, Fc_low, Fc_high);
    medAE_fftspectrum = medAE(actual_respiration_rate, vitalSignRate_frequency_spectrum, Fc_high, Fc_low);

end