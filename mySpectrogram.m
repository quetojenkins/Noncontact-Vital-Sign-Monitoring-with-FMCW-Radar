function [S,F,T,dominantFrequency, percentage_accuracy_array_spectrogram, NRMSE_spectrogram, medAE_spectrogram] = mySpectrogram(Respiration_Rate_frequency_spectrum,midpoints,array_frequency_zeroCrossings, midpointspeak,peakCounting_instFrequency,R_hat_t, CPI, PRI, nfft, fs, Fc_low, Fc_high, actual_respiration_rate, index, time_vector,  vitalSign, generate_plots)
    fprintf('\n------- SPECTROGRAM ANALYSIS %.2s -------\n', vitalSign);


    T_window = 12;
    window_length = round(T_window * fs);
    overlap = floor(0.99*window_length);
    nfft1 = window_length*20;

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
    % --------------------- STARTING CPU TIMER --------------------- %
    startCPUTime = cputime;
    % -------------------------------------------------------------- %
    % --------------------- STARTING MEMORY USAGE --------------------- %
    % beforeMem = memory;
    % ----------------------------------------------------------------- %  

    % --------------------- STARTING EXECUTION TIMER --------------------- %
    tic;
    % -------------------------------------------------------------------- %
    % now to select the dominant frequency
    window = ceil(CPI/PRI);   %also works best is 900*12
    noverlap = ceil(0.99*window); % percentage of overlaping samples from widnow
    [S,F,T] = spectrogram(R_hat_t, window_length, overlap, nfft, fs, 'yaxis');

    S_max = max(max(abs(S)));
    S_normalised = abs(S)/S_max;

    S_dB = 20 * log10(abs(S_normalised));

    fridge = tfridge(S, F); 
    % dominantFrequency = fridge*60;
    fridge_smooth = movmean(fridge, 5);  % Apply moving mean smoothing with a window size of 5
    dominantFrequency = fridge_smooth * 60;
    disp('we are here 4')
    disp('we are here 2')
    if generate_plots == 1
        k9 = figure;
        k9.Position(3) = 300 *0.16*(1/0.0254);
        k9.Position(4) = 400; 
        imagesc(T, F*60, S_dB); 
        axis xy;            
        xlabel('Time [s]');
        ylabel([name, ' [bpm]']);
        colormap jet;         
        colorbar;             
        % title(['Spectrogram of ', name, ' for ', index]);
        clim([-35, 0]);
        if strcmp(vitalSign, 'RR')
            disp('RR in ylim')
            lim=[0, 150];
        else
            disp('HR in ylim')
            lim=[0, 150 ];
        end
        ylim(lim); 
        hold on;
        plot(T, fridge_smooth*60, 'Color', 'w', 'LineWidth', 1.5, 'LineStyle','-');
        hold off
        saveas(k9, ['MATLAB Plots/06 Spectrogram Plots/', index,'_', vitalSign, '_myspectrogram.png']);
        close(k9);
    end



    if generate_plots == 1
        k10 = figure;
        k10.Position(3) = 300 *0.16*(1/0.0254);
        k10.Position(4) = 400; 
        plot(T, fridge_smooth*60, 'Color', yellowcolour, 'LineWidth', 1.5, 'LineStyle','-');
        xlabel('Time (s)');
        ylabel([name, '[bpm]']);
        % title(['Change in ',name, ' (bpm) overtime using Spectrogram Method for ', index]);
        saveas(k10, ['MATLAB Plots/06 Spectrogram Plots/',index,'_', vitalSign, '_DominantFrequency_fromSpectrogram.png']);
        close(k10);
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
    mean_spectrogram = mean(fridge)*60;

    createPerformanceMetricsForMethods(4,executionTime, endCPUTime, 1);
    percentage_accuracy_array_spectrogram = percentageAccuracy(actual_respiration_rate, fridge_smooth);
    NRMSE_spectrogram = nrmse(actual_respiration_rate, fridge_smooth, Fc_low, Fc_high);
    medAE_spectrogram = medAE(actual_respiration_rate, fridge_smooth, Fc_high, Fc_low);
end