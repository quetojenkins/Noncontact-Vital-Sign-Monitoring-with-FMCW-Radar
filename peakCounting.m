function [midpoints, peakCounting_instFrequency_MA,rate_counting_peaks_method, percentage_accuracy_array_peakCounting, NRMSE_peakCounting, medAE_peakCounting] = peakCounting(R_hat_t,threshold_peakCounting, index,  Fc_high, Fc_low, time_vector, actual_respiration_rate , vitalSign, generate_plots)
    fprintf('\n------- Peak Counting ANALYSIS OF %.2s -------\n', vitalSign);
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
        threshold_peakCounting = 2;
    else
        colourofVitalSign = heartRateRed;
        secondaryColour = lapisluzulicolour;
        name = 'Heart Rate';
        threshold_peakCounting = 0.8;
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
    [peaks, locs_max] = findpeaks(R_hat_t);

    % Initialize an array to store valid peaks
    validPeaks = peaks(1);           % Always keep the first peak
    validLocs = locs_max(1);         % Location of the first valid peak

    peakCounting_instFrequency = [];

    for i = 2:length(locs_max)
        % Calculate the time difference from the last valid peak
        if (time_vector(locs_max(i)) - time_vector(validLocs(end))) >= threshold_peakCounting
            % If the difference is greater than or equal to the threshold, keep the peak
            validPeaks(end+1) = peaks(i);
            validLocs(end+1) = locs_max(i);
        end
    end

    numValidPeaks = length(validLocs);
           % --------------------- GETTING EXECUTION TIME --------------------- %
           executionTime = toc;
           % ------------------------------------------------------------------ %
           % --------------------- STARTING CPU TIMER --------------------- %
           endCPUTime = cputime - startCPUTime;
           % -------------------------------------------------------------- %
           % --------------------- GETTING MEMORY USAGE --------------------- %
        %    afterMem = memory;
        %    memoryUsed = afterMem.MemUsedMATLAB - beforeMem.MemUsedMATLAB;
           % ----------------------------------------------------------------- %  
   

    rate_counting_peaks_method = (numValidPeaks/30)*60;  % assuming 30-second window

    if numValidPeaks > 1
        validTimeIntervals = diff(time_vector(validLocs));  % time intervals
        instantaneousFrequency_peakCounting = 1 ./ validTimeIntervals; 
        peakCounting_instFrequency = [peakCounting_instFrequency, instantaneousFrequency_peakCounting*60];

        %  range history and valid peaks
        if generate_plots ==  1
            k7 = figure;
            pixels = 300 *0.16*(1/0.0254)
            k7.Position(3) = pixels;
            k7.Position(4) = 400; 
            plot(time_vector, R_hat_t, 'Color',colourofVitalSign, 'LineWidth', 1.5);

            xlabel('Time [s]');
            ylabel('Displacement [m]');
            % title(['Range History of ', name, 'showing Peaks for ', index]);
            hold on;

            ylim([0 200]);
            plot(time_vector(validLocs), R_hat_t(validLocs), 'o ','MarkerFaceColor',secondaryColour ,'MarkerEdgeColor', secondaryColour , 'MarkerSize', 5,  'LineWidth', 1.5);
            hold off;
            savename = ['MATLAB Plots/05 Peak Counting Plots/',index,'_', vitalSign, '_PeakCounting_RangeHistory.png'];
            saveas(k7, savename);
            close(k7);
        end
        midpoints = time_vector(validLocs(1:end-1)) + validTimeIntervals / 2; % midpoint
        % instantaneous frequency over time
        window_size = 4;  % example window size for the moving average
        peakCounting_instFrequency_MA = movmean(peakCounting_instFrequency, window_size);
        if generate_plots == 1
            k8 = figure;
            pixels = 300 *0.16*(1/0.0254)
            k8.Position(3) = pixels; 
            k8.Position(4) = 400; 
            midpoints = time_vector(validLocs(1:end-1)) + validTimeIntervals / 2; % midpoint
            plot(midpoints, peakCounting_instFrequency_MA, 'Color',colourofVitalSign, 'LineWidth', 1.5);
            ylim([0 200]);
            xlabel('Time [s]');
            ylabel([name, '[bpm]']);
            % title(['Change in ',name, ' (bpm) overtime using Peak Counting Method for ', index]);
            if isempty(k8) || ~isvalid(k8)
                error('Figure handle k8 is invalid or not initialized.');
            end

            saveName = ['MATLAB Plots/05 Peak Counting Plots/',index,'_', vitalSign, '_InstantaneousFrequency_PeakCountingSmoooooth.png'];
            saveas(k8, saveName);
            close(k8);
        end
        if generate_plots == 1
            k8 = figure;
            pixels = 300 *0.16*(1/0.0254)
            k8.Position(3) = pixels; 
            k8.Position(4) = 400; 
            midpoints = time_vector(validLocs(1:end-1)) + validTimeIntervals / 2; % midpoint
            plot(midpoints, instantaneousFrequency_peakCounting*60, 'Color',colourofVitalSign, 'LineWidth', 1.5);
            ylim([0 200]);
            xlabel('Time [s]');
            ylabel([name, '[bpm]']);
            % title(['Change in ',name, ' (bpm) overtime using Peak Counting Method for ', index]);
            if isempty(k8) || ~isvalid(k8)
                error('Figure handle k8 is invalid or not initialized.');
            end

            saveName = ['MATLAB Plots/05 Peak Counting Plots/',index,'_', vitalSign, '_InstantaneousFrequency_PeakCounting.png'];
            saveas(k8, saveName);
            close(k8);
        end
    
    else
        disp('Not enough valid peaks to calculate instantaneous frequency.');
    end

    createPerformanceMetricsForMethods(3,executionTime, endCPUTime, 1);
    % percentage_accuracy_array_peakCounting = percentageAccuracy(actual_respiration_rate, rate_counting_peaks_method);
    percentage_accuracy_array_peakCounting = percentageAccuracy(actual_respiration_rate, peakCounting_instFrequency);
    NRMSE_peakCounting = nrmse(actual_respiration_rate, peakCounting_instFrequency, Fc_low, Fc_high);
    medAE_peakCounting = medAE(actual_respiration_rate, peakCounting_instFrequency, Fc_high, Fc_low);
