import matlab.engine
import glob
import os
import pandas as pd
# import averaging
# import plotting


# ------------ MISCELLANEOUS FUNCTIONS ------------ #
def get_breathing_rate(index, df_index):
    # Locate the row corresponding to the index
    row = df_index[df_index['Index'] == index]
    
    # If the row exists, return the breathing rate, else return None
    if not row.empty:
        return row['Breathing Rate'].values[0]
    else:
        return None

def get_distance(index, df_index):
    # Locate the row corresponding to the index
    row = df_index[df_index['Index'] == index]
    
    # If the row exists, return the breathing rate, else return None
    if not row.empty:
        return row['Distance'].values[0]
    else:
        return None

# ------------ VARIABLES ------------ #
generate_plots = 1
file_for_testing = '/Users/queto/Desktop/UNIVERSITY/Fourth Year/Second Semester/EEE4022S/Code/01 TI Radar/03 Quetos Test Data/2024-09-17_15-00-56.320_Heartrate_30s_15BPM_IEsame_1/Radarmmwave.hdf5'
file_polar_for_testing = '/Users/queto/Desktop/UNIVERSITY/Fourth Year/Second Semester/EEE4022S/Code/01 TI Radar/03 Quetos Test Data/2024-09-17_15-00-56.320_Heartrate_30s_15BPM_IEsame_1/Polar_monitor_mmwave.hdf5'
folder_path = '/Volumes/My Passport/01 Experiment One/finalfinal'
folders = glob.glob(os.path.join(folder_path, '*'))
radar_file = '/Radarmmwave.hdf5'
polar_file = '/Polar_monitor_mmwave.hdf5'

# ------------ START MATLAB ENGINE ------------ #
eng = matlab.engine.start_matlab()

# ------------ SET UP PANDAS DATA FRAME ------------ #
columns = ['Index', 'VitalSign' ,'PercentageAccuracy_FFTSpectrum', 'NRMSE_FFTSpectrum', 'MedAE_FFTSpectrum', 
           'PercentageAccuracy_ZeroCrossings', 'NRMSE_ZeroCrossings', 'MedAE_ZeroCrossings', 
           'PercentageAccuracy_PeakCounting', 'NRMSE_PeakCounting', 'MedAE_PeakCounting', 
           'PercentageAccuracy_Spectrogram', 'NRMSE_Spectrogram', 'MedAE_Spectrogram']

df = pd.DataFrame(columns=columns)

df_metricResult = pd.DataFrame(columns=['Index',
            'Execution Time',
            'CPU Time',
            'Memory Used'])

df_index = pd.read_csv('CSVS/ExperimentIndex.csv')

# ------------ ITERATE THROUGH DATASETS ------------ #
for folder in folders:
    i = 1;
    folder_name = os.path.basename(folder)
    print(f'folder {folder}');
    radar_file_path = folder+radar_file
    polar_file_path = folder+polar_file
    parts = folder_name.split('_')
    if len(parts) >= 3:
        myIndex = '_'.join(parts[-3:])
        print(f'Folder: {folder_name}, Index: {myIndex}')
        print(f'Files: {radar_file_path} and {polar_file_path}')
        actual_respiration_rate =  get_breathing_rate(myIndex, df_index)
        distance = get_distance(myIndex, df_index)

        print('\n ------------ Entering MATLAB main ------------ \n')
        executionTime, endCPUTime, r_percentage_accuracy_array_fftSpectrum, r_NRMSE_fftspectrum, \
            r_medAE_fftspectrum, r_percentage_accuracy_array_zeroCrossings, r_NRMSE_zeroCrossings, \
            r_medAE_zeroCrossings, r_percentage_accuracy_array_peakCounting, r_NRMSE_peakCounting, r_medAE_peakCounting, \
            r_percentage_accuracy_array_spectrogram, r_NRMSE_spectrogram, r_medAE_spectrogram,\
             h_percentage_accuracy_array_fftSpectrum, h_NRMSE_fftspectrum, h_medAE_fftspectrum, \
            h_percentage_accuracy_array_zeroCrossings, h_NRMSE_zeroCrossings, h_medAE_zeroCrossings, h_percentage_accuracy_array_peakCounting, \
            h_NRMSE_peakCounting, h_medAE_peakCounting, h_percentage_accuracy_array_spectrogram, h_NRMSE_spectrogram, h_medAE_spectrogram, \
             = eng.main(myIndex, radar_file_path, \
            polar_file_path, actual_respiration_rate,distance, generate_plots,  nargout=26)

        metric_row_data = {
            'Index' : myIndex,
            'Execution Time' : executionTime,
            'CPU Time' : endCPUTime,
            'Memory Used': 0
        }
        row_data_R = {
            'Index': myIndex,
            'VitalSign': 'R',
            'PercentageAccuracy_FFTSpectrum': r_percentage_accuracy_array_fftSpectrum,
            'NRMSE_FFTSpectrum': r_NRMSE_fftspectrum,
            'MedAE_FFTSpectrum': r_medAE_fftspectrum,
            'PercentageAccuracy_ZeroCrossings': r_percentage_accuracy_array_zeroCrossings,
            'NRMSE_ZeroCrossings': r_NRMSE_zeroCrossings,
            'MedAE_ZeroCrossings': r_medAE_zeroCrossings,
            'PercentageAccuracy_PeakCounting': r_percentage_accuracy_array_peakCounting,
            'NRMSE_PeakCounting': r_NRMSE_peakCounting,
            'MedAE_PeakCounting': r_medAE_peakCounting,
            'PercentageAccuracy_Spectrogram': r_percentage_accuracy_array_spectrogram,
            'NRMSE_Spectrogram': r_NRMSE_spectrogram,
            'MedAE_Spectrogram': r_medAE_spectrogram,
        }
        row_data_H = {
            'Index': myIndex,
            'VitalSign': 'H',
            'PercentageAccuracy_FFTSpectrum': h_percentage_accuracy_array_fftSpectrum,
            'NRMSE_FFTSpectrum': h_NRMSE_fftspectrum,
            'MedAE_FFTSpectrum': h_medAE_fftspectrum,
            'PercentageAccuracy_ZeroCrossings': h_percentage_accuracy_array_zeroCrossings,
            'NRMSE_ZeroCrossings': h_NRMSE_zeroCrossings,
            'MedAE_ZeroCrossings': h_medAE_zeroCrossings,
            'PercentageAccuracy_PeakCounting': h_percentage_accuracy_array_peakCounting,
            'NRMSE_PeakCounting': h_NRMSE_peakCounting,
            'MedAE_PeakCounting': h_medAE_peakCounting,
            'PercentageAccuracy_Spectrogram': h_percentage_accuracy_array_spectrogram,
            'NRMSE_Spectrogram': h_NRMSE_spectrogram,
            'MedAE_Spectrogram': h_medAE_spectrogram,
        }

        df.loc[len(df)] = row_data_R
        print(f'Added RR data from {myIndex} to dataFrame')
        df.loc[len(df)] = row_data_H
        print(f'Added HR data from {myIndex} to dataFrame')

        df_metricResult.loc[len(df)] = metric_row_data
        print(f'Added HR data from {myIndex} to dataFrame')

        # df.to_csv('CSVS/results.csv', mode='a', header=not os.path.isfile('CSVS/results.csv'), index=False)
        # df_metricResult.to_csv('CSVS/PerformanceMetricData.csv', mode='a', header=not os.path.isfile('CSVS/PerformanceMetricData.csv'), index=False)
        # df.drop(df.index, inplace=True)
        # df_metricResult.drop(df_metricResult.index, inplace=True)


# ------------ QUIT MATLAB ENGINE ------------ #
eng.quit()

# ------------ SAVE RESULTS TO CSVS ------------ #
df.to_csv('CSVS/results.csv', index=False)
df_metricResult.to_csv('CSVS/PerformanceMetricData.csv')
# averaging.average('CSVS/results.csv') # average the data


# -------- DO SOME PLOTTING -------- #
# plotting.experimentTwoBreathingRateCOmparison()
# plotting.experimentTwoHeartRateComparison()
# plotting.experimentOneHeartRateOnly()
# plotting.performanceMetricsCalced()
# plotting.experimentThreeDistance()