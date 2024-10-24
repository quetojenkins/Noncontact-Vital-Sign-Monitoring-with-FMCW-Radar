function [phi_t_filtered] = myFilter(Fc_high,Fc_low, fs, phi_t, vitalSign, index, time_vector, generate_plots)
    fprintf('\n------- Entering Filtering -------\n');
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
    % Create a high-pass filter
    hpFilt = designfilt('highpassiir', 'FilterOrder', 8, ...
                        'HalfPowerFrequency', Fc_high, 'SampleRate', fs);
    
    % Apply the high-pass filter to the unwrapped phase signal
    phi_t_filtered_high = filtfilt(hpFilt, phi_t);
    
 

    lpFilt = designfilt('lowpassiir', 'FilterOrder', 8, ...
                        'HalfPowerFrequency', Fc_low, 'SampleRate', fs);
    

    
    % Apply the low-pass filter to the unwrapped phase signal
    phi_t_filtered = filtfilt(lpFilt, phi_t_filtered_high);
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
    
    if generate_plots == 7
        % Compute the frequency response of the high-pass filter
        [H_hp, F_hp] = freqz(hpFilt, 1024, fs);  % High-pass filter

        % Compute the frequency response of the low-pass filter
        [H_lp, F_lp] = freqz(lpFilt, 1024, fs);  % Low-pass filter
    

        % Create a figure with two subplots
        f1 = figure;

        % First subplot: High-pass filter response
        subplot(2, 1, 1);  % 2 rows, 1 column, first plot
        plot(F_hp, abs(H_hp), 'Color', colourofVitalSign, 'LineWidth', 1.5);
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        title('Frequency Response of High-Pass Filter');
        xlim([0, 3]);


        % Second subplot: Low-pass filter response
        subplot(2, 1, 2);  % 2 rows, 1 column, second plot
        plot(F_lp, abs(H_lp), 'Color', colourofVitalSign, 'LineWidth', 1.5);
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        % title('Frequency Response of Low-Pass Filter');
        xlim([0, 3]);
        saveas(f1, ['MATLAB Plots/10 Filter Responses/', index,'_', vitalSign, 'filter.png'])
        close(f1);
    end

    createPerformanceMetricsForMethods(7,executionTime, endCPUTime, 1);
end