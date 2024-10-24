function [heartRate, time] = processPolar(filename,generate_plots)
    fprintf('\n------- Processing Polar Data -------\n');
    %filename = '/Users/queto/Desktop/UNIVERSITY/Fourth Year/Second Semester/EEE4022S/Code/01 TI Radar/03 Quetos Test Data/2024-09-17_15-00-56.320_Heartrate_30s_15BPM_IEsame_1/Polar_monitor_mmwave.hdf5';
    info = h5info(filename); % Get the structure of the HDF5 file
    dataGroupInfo = h5info(filename, '/Heart Rate Data'); % Access the '/Data' group
    
    % Display the number of datasets or groups within '/Data'
    numSamples = length(dataGroupInfo.Groups); % Number of subgroups (frames) in '/Data'
    %disp(['Number of frames: ', num2str(numFrames)]);

    f_s_heart_rate = 1; 
    
    % Initialize arrays to store heart rate and time data
    heartRate = [];
    time = [];
    
    % Loop through each sample to extract heart rate data
    for i = 0:numSamples-1
        sample_name = ['/Heart Rate Data/Sample_' num2str(i) '/heart_rate'];
        
        % Read heart rate data for each sample
        hr_data = h5read(filename, sample_name);
        
        % Append to the heartRate array
        heartRate = [heartRate; hr_data];
        
        % Assume each sample corresponds to a time interval (e.g., 1 second per sample)
        % You can adjust this based on your actual data.
        time = [time; i];  % Create a simple time index (modify if time data is available)
    end
    
    % Plot heart rate vs time
    if generate_plots == 9
        fig=figure;     
        pixels = 300 *0.16*(1/0.0254)
        fig.Position(3) = pixels; 
        fig.Position(4) = 400; 
        plot(time, heartRate);
        xlabel('Time (s)');  % Modify based on the correct time scale
        ylabel('Heart Rate (bpm)');
        % title('Heart Rate vs Time');
        close;
    end


end

