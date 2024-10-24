function [vitalSign_rate_zero_crossing_method, array_frequency_zeroCrossings_smooth, midpoints,percentage_accuracy_array_zeroCrossings, NRMSE_zeroCrossings, medAE_zeroCrossings] = zeroCrossings(R_hat_t, threshold, index, actual_respiration_rate,  Fc_high, Fc_low, time_vector, vitalSign, generate_plots)

    fprintf('\n------- Zero Crossing ANALYSIS OF %.2s -------\n', vitalSign);
    
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
        threshold_peakCounting = 2/2;
    else
        colourofVitalSign = heartRateRed;
        secondaryColour = lapisluzulicolour;
        name = 'Heart Rate';
        threshold = 0;
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
    zeroCrossings = diff(sign(R_hat_t)); % returns a vector of n-1 samples

    % Find the indices where the sign changes
    crossingIndices = find(zeroCrossings ~= 0);

    % Initialize an array to store valid zero crossings
    validCrossings = crossingIndices(1); % Always keep the first crossing

    %threshold = 1.2; % Time threshold in seconds

    % Loop through the zero-crossing indices and check the time difference
    for i = 2:length(crossingIndices)
        % Calculate the time difference from the last valid zero-crossing
        if (time_vector(crossingIndices(i)) - time_vector(validCrossings(end))) >= threshold
            % If the difference is greater than or equal to the threshold, keep the crossing
            validCrossings(end+1) = crossingIndices(i); 
        end
    end

    % Count the number of valid zero crossings
    numZeroCrossings = length(validCrossings);
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

    % Display result
    fprintf('Number of valid zero crossings: %d\n', numZeroCrossings);

    % Calculate respiration rate using zero-crossing method
    vitalSign_rate_zero_crossing_method = ((numZeroCrossings/2)/30)*60;
    %array_of_calculated_rr_values(end+1) = Respiration_rate_zero_crossing_method;
    disp(['The respiration rate of target using zero-crossings method is ', num2str(vitalSign_rate_zero_crossing_method)]);
    array_frequency_zeroCrossings = [];




    % Recalculate time intervals between the valid zero-crossings
    if numZeroCrossings > 1
        validTimeIntervals = diff(time_vector(validCrossings)); % Time differences between valid crossings

        % Calculate the instantaneous frequency at each valid zero-crossing point
        instantaneousFrequency_zeroCrossings = 1 ./ (2 * validTimeIntervals); % Frequency = 1 / period, factor of 2 for positive/negative crossings
        array_frequency_zeroCrossings = [array_frequency_zeroCrossings, instantaneousFrequency_zeroCrossings*60];

        if generate_plots == 1
            k5 = figure;
            
            pixels = 300 *0.16*(1/0.0254)
            k5.Position(3) = pixels;
            k5.Position(4) = 400; 
            plot(time_vector, R_hat_t, 'Color', colourofVitalSign, 'LineWidth', 1.5)

            xlabel('Time [s]');
            ylabel('Displacement [m]');
            ylim([0 200]);
            % title(['Range History of ', name, 'showing Zero Crossings for ', index]);
            hold on;
            plot(time_vector(validCrossings), R_hat_t(validCrossings), 'o ','MarkerFaceColor',secondaryColour ,'MarkerEdgeColor', secondaryColour , 'MarkerSize', 5, 'LineWidth', 1.5);
            hold off;
            saveName = ['MATLAB Plots/04 Zero Crossing Plots/',index, '_', vitalSign,'_Zero_CrossingsRangeHistory.png'];
            saveas(k5,saveName );
            close(k5);
        end
        midpoints = time_vector(validCrossings(1:end-1)) + validTimeIntervals / 2;


        windowSize = 4;


        array_frequency_zeroCrossings_smooth = movmean(array_frequency_zeroCrossings, windowSize);


        disp('Smoothed frequency values using movmean:');
        % disp(array_frequency_zeroCrossings_smooth);


        if generate_plots == 1 && ~isempty(array_frequency_zeroCrossings_smooth)
            k7 = figure;
            pixels = 300 *0.16*(1/0.0254);
            k7.Position(3) = pixels;
            k7.Position(4) = 400;
            plot(midpoints, array_frequency_zeroCrossings_smooth, 'Color', colourofVitalSign, 'LineWidth', 1.5);
            xlabel('Time [s]');
            ylim([0 200]);
            ylabel([name, ' [bpm] (Smoothed)']);
            saveas(k7, ['MATLAB Plots/04 Zero Crossing Plots/',index, '_', vitalSign,'_ZeroCrossingsSmoothedFrequencySMOOOTH.png']);
            close(k7);
        end
        if generate_plots == 1
            k6 = figure;
            pixels = 300 *0.16*(1/0.0254)
            k6.Position(3) = pixels;
            k6.Position(4) = 400; 
            plot(midpoints, instantaneousFrequency_zeroCrossings*60, 'Color', colourofVitalSign, 'LineWidth', 1.5)
            xlabel('Time [s]');
            ylim([0 200]);
            ylabel([name, '[bpm]']);
            % title(['Change in ',name, ' (bpm) overtime using Zero Crossings Method for ', index]);
            saveas(k6, ['MATLAB Plots/04 Zero Crossing Plots/',index, '_', vitalSign,'_ZeroCrossingsFrequency.png']);
            close(k6);
        end

    else
        disp('Not enough valid zero crossings to calculate frequency.');
    end

    % percentage_accuracy_array_zeroCrossings = percentageAccuracy(actual_respiration_rate, array_frequency_zeroCrossings)
    % NRMSE_zeroCrossings = nrmse(actual_respiration_rate, array_frequency_zeroCrossings, Fc_low, Fc_high)
    % medAE_zeroCrossings = medAE(actual_respiration_rate, array_frequency_zeroCrossings)
    createPerformanceMetricsForMethods(2,executionTime, endCPUTime, 1);
    percentage_accuracy_array_zeroCrossings = percentageAccuracy(actual_respiration_rate, array_frequency_zeroCrossings);
    NRMSE_zeroCrossings = nrmse(actual_respiration_rate, array_frequency_zeroCrossings, Fc_low, Fc_high);
    medAE_zeroCrossings = medAE(actual_respiration_rate, array_frequency_zeroCrossings, Fc_high, Fc_low);
end
