function [executionTime, endCPUTime, R_percentage_accuracy_array_fftSpectrum, R_NRMSE_fftspectrum, R_medAE_fftspectrum, R_percentage_accuracy_array_zeroCrossings, R_NRMSE_zeroCrossings, R_medAE_zeroCrossings, R_percentage_accuracy_array_peakCounting, R_NRMSE_peakCounting, R_medAE_peakCounting, R_percentage_accuracy_array_spectrogram, R_NRMSE_spectrogram, R_medAE_spectrogram , H_percentage_accuracy_array_fftSpectrum, H_NRMSE_fftspectrum, H_medAE_fftspectrum, H_percentage_accuracy_array_zeroCrossings, H_NRMSE_zeroCrossings, H_medAE_zeroCrossings, H_percentage_accuracy_array_peakCounting, H_NRMSE_peakCounting, H_medAE_peakCounting, H_percentage_accuracy_array_spectrogram, H_NRMSE_spectrogram, H_medAE_spectrogram] = main(index, filename_radar, filename_polar, actual_respiration_rate, distance, generate_plots)
    
    fprintf('\n------- MAIN MATLAB FUNCTION -------\n');

    % --------------------- COLOUR SCHEME --------------------- %
    heartRateRed = [237/255, 27/255, 36/255];
    respirationRateBlue = [35/255, 64/255, 142/255];
    yellowcolour = [255/255, 209/255, 102/255];
    lapisluzulicolour = [44/255, 103/255, 159/255];
    lightPowderBluecolour = [159/255, 192/255, 216/255];
    cherryblossompink = [239/255, 169/255, 186/255];

    % --------------------- PERFORMANCE METRICS --------------------- %
    startCPUTime = cputime;
    % beforeMem = memory;
    profile on;
    tic;

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

    % --------------------- GET GROUND TRUTH HEART RATE --------------------- %
    [groundTruthheartRate, time] = processPolar(filename_polar, generate_plots);
    actualHeartRate = mean(groundTruthheartRate);
    if generate_plots == 1
        k19 = figure;     
        plot(time, groundTruthheartRate, 'Color',heartRateRed, 'LineWidth', 1.5);
        xlabel('Time [s]');  % Modify based on the correct time scale
        ylabel('Heart Rate [bpm]');
        title('Heart Rate vs Time');
        saveas(k19, ['MATLAB Plots/02 Range History Plots/', index,'_GroundTruthHeartRate.png'])
        close(k19);
    end

    % --------------------- PROCESS THE HDF5 RADAR DATA TO IQ CUBES --------------------- %
    [Frame_profile, AllFrames2Process] = processFrames(filename_radar, NumVirtualChannels, NumChirps, NumSamples); 
    
    % --------------------- GENERATE RANGE PROFILE --------------------- %
    [RangeProfilesMatrix, NumPulses] = rangeProfile(Frame_profile, index, AllFrames2Process,NumVirtualChannels, NumChirps, NumSamples, PRI, Bw, c, generate_plots);
    delta_R = c / (2 * Bw);
    range_bin_to_extract = ceil(distance/delta_R);

    % --------------------- FIND RANGE HISTORY OF CHEST --------------------- %
    s_b = RangeProfilesMatrix(1:NumPulses, range_bin_to_extract); 
    time_vector = (1 : size(s_b, 1)) * PRI;
    phi_t = unwrap(angle(s_b));
    
    % --------------------- PROCESS FOR RESPIRATION AND HEART RATE --------------------- %
    [R_hat_tR, R_percentage_accuracy_array_fftSpectrum, R_NRMSE_fftspectrum, R_medAE_fftspectrum, R_percentage_accuracy_array_zeroCrossings, R_NRMSE_zeroCrossings, R_medAE_zeroCrossings, R_percentage_accuracy_array_peakCounting, R_NRMSE_peakCounting, R_medAE_peakCounting, R_percentage_accuracy_array_spectrogram, R_NRMSE_spectrogram, R_medAE_spectrogram ] = respirationRate(time_vector, phi_t, s_b, index, actual_respiration_rate, generate_plots);
    [R_hat_tH, H_percentage_accuracy_array_fftSpectrum, H_NRMSE_fftspectrum, H_medAE_fftspectrum, ...
    H_percentage_accuracy_array_zeroCrossings, H_NRMSE_zeroCrossings, H_medAE_zeroCrossings, H_percentage_accuracy_array_peakCounting, ...
    H_NRMSE_peakCounting, H_medAE_peakCounting, H_percentage_accuracy_array_spectrogram, H_NRMSE_spectrogram, H_medAE_spectrogram ] = heartRate(time_vector, phi_t, s_b, ...
    index, actualHeartRate, groundTruthheartRate, time, generate_plots);
    
    if generate_plots == 1
        bothrangehistory = figure;   
        pixels = 300 *0.16*(1/0.0254)
        bothrangehistory.Position(3) = pixels; % Increase the width (3rd element)
        bothrangehistory.Position(4) = 400;  % Set the height (4th element)  
        plot(time_vector, R_hat_tH, 'Color',heartRateRed, 'LineWidth', 1.5 );
        hold on;
        plot(time_vector, R_hat_tR, 'Color',respirationRateBlue, 'LineWidth', 1.5 );
        xlabel('Time [s]');  % Modify based on the correct time scale
        ylabel('Displacement [m]');
        % title('Displacement of the Chest during Cardiac and Breathing Motions over Time');
        legend('Cardiac Motion', 'Breathing Motion');
        saveas(bothrangehistory, ['MATLAB Plots/02 Range History Plots/', index,'_BOTH.png'])
        close(bothrangehistory);
    end

    % --------------------- PERFORMANCE METRICS --------------------- %
    executionTime = toc;
    endCPUTime = cputime - startCPUTime;
    % afterMem = memory;
    % memoryUsed = afterMem.MemUsedMATLAB - beforeMem.MemUsedMATLAB;
    profile off;

    % metrics_array = [executionTime, endCPUTime, 1];
end