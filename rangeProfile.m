function [RangeProfilesMatrix, NumPulses] = rangeProfile(Frame_profile, index, AllFrames2Process,NumVirtualChannels, NumChirps, NumSamples, PRI, Bw, c,generate_plots)
    %UNTITLED9 Summary of this function goes here
    %   Detailed explanation goes here
    % adjust path to file accordingly
    fprintf('\n------- GENERATING RANGE PROFILE -------\n');
    for CurrentFrame = 1:AllFrames2Process
        single_frame = zeros(NumChirps, NumSamples);
        
        % Combine data from all channels for the current frame
        for countChannels = 1:NumVirtualChannels
            single_frame = single_frame + reshape(Frame_profile(countChannels,CurrentFrame,:,:), NumChirps, []); % William code
        end
        
        % For each frame, generate range profiles by applying FFT along the fast-time dimension
        
        RangeProfiles = fft(single_frame, 96 ,2);
        StartProfile = (1 + (CurrentFrame-1)*NumChirps);
        EndProfile = (NumChirps + (CurrentFrame-1)*NumChirps); 
        RangeProfilesMatrix(StartProfile:EndProfile, :) = RangeProfiles;
    
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
    % [cutMatrix, numChirpsFor30Seconds] = cutRangeProfileToThirtySeconds(RangeProfilesMatrix, PRI);

    % Plot Concatenate Range Profiles
    NumPulses = size(RangeProfilesMatrix, 1);
    
    % Generate time axis
    TimeAxis = (0:1:NumPulses-1) * PRI;  % Time axis in seconds
    
    % Calculate range resolution
    delta_R = c / (2 * Bw);  % in meters
    
    % Generate range values for each bin
    %NumSamples is the number of range bins
    RangeAxis = (0:NumSamples-1) * delta_R;  % in meters
    
    % Plot Range Profiles with Time Axis
    if generate_plots == 1
        k1 = figure;
        % imagesc(RangeAxis, TimeAxis, 20*log10(abs(RangeProfilesMatrix)));
        imagesc(RangeAxis, TimeAxis, 20*log10(abs(RangeProfilesMatrix)));
        xlabel('Range (m)');
        ylabel('Time (slow time)');
        colorbar; 
        colormap('jet');
        % title('Range Profile in Seconds');
        saveas(k1, ['MATLAB Plots/01 Range Profile Plots/',index, '_RangeProfile.png']);
        close(k1);
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
    createPerformanceMetricsForMethods(6,executionTime, endCPUTime, 1);
end