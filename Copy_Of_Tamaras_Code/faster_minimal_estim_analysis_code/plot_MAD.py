'''
Plot mean absolute displacement 
'''

from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np 
from scipy.signal import find_peaks

plt.rcParams.update({'font.size': 13,'font.family': 'Arial'})
plt.rcParams.update({'figure.autolayout': True})

def compute_abs_position_timeseries(tracker_0: np.ndarray, tracker_1: np.ndarray) -> np.ndarray:
    """Given tracker arrays. Will return single timeseries of absolute displacement."""
    disp_0_all = np.zeros(tracker_0.shape)
    disp_1_all = np.zeros(tracker_1.shape)
    for kk in range(tracker_0.shape[1]):
        disp_0_all[:, kk] = tracker_0[:, kk] - tracker_0[:, 0]
        disp_1_all[:, kk] = tracker_1[:, kk] - tracker_1[:, 0]
    disp_abs_all = (disp_0_all ** 2.0 + disp_1_all ** 2.0) ** 0.5
    disp_abs_mean = np.mean(disp_abs_all, axis=0)
    return disp_abs_mean, disp_abs_all, -1*disp_0_all, disp_1_all

def get_time_segment_param_dicts() -> dict:
    """Will return dictionaries specifying the parameters for timeseries segmentation.
    In future, these may vary based on version and/or be computed automatically (e.g., look at spectral info)."""
    time_seg_params = dict(peakDist=20, prom = 0.1)
    return time_seg_params


def adjust_time_seg_params(time_seg_params: dict, timeseries: np.ndarray) -> dict:
    """Given time segmentation parameters and a timeseries mean absolute displacement. 
    Will automatically update the minimum distance between peaks to ensure more robust time segmentation."""
    timeseries_offset = timeseries - np.mean(timeseries)
    signs = np.sign(timeseries_offset)
    diff = np.diff(signs)
    indices_of_zero_crossing = np.where(diff)[0]
    total_points = np.diff(indices_of_zero_crossing)
    period = np.mean(total_points) * 2.0
    time_seg_params["peakDist"] = period * 0.75
    time_seg_params["prom"] = 0.1
    return time_seg_params

def compute_peaks_valleys(timeseries: np.ndarray) -> np.ndarray:
    """Given a timeseries. Will compute peaks and valleys."""
    time_seg_params = get_time_segment_param_dicts()
    time_seg_params = adjust_time_seg_params(time_seg_params, timeseries)
    peaks, _ = find_peaks(timeseries, distance=time_seg_params["peakDist"], prominence=time_seg_params["prom"])
    ### EDITED BY TAMARA (old version in the commented section below)
    valleys, _ = find_peaks(-timeseries, distance=time_seg_params["peakDist"], prominence=time_seg_params["prom"])
    '''valleys = []
    for kk in range(0, len(peaks) - 1):
        valleys.append(int(0.5 * peaks[kk] + 0.5 * peaks[kk + 1]))
    '''
    return np.asarray(peaks), np.asarray(valleys)

def create_MAD_plots(folder_path: Path):
    res_path = folder_path.joinpath('results').resolve()
    vis_path = folder_path.joinpath('visualizations').resolve()

    pos_x = np.loadtxt(str(res_path)+'/pos_x.txt')
    pos_y = np.loadtxt(str(res_path)+'/pos_y.txt')
    
    mean_abs_disp,_,_,_ = compute_abs_position_timeseries(pos_y,pos_x)
    
    peaks,valleys = compute_peaks_valleys(mean_abs_disp)
    
    np.savetxt(Path(str(res_path) +'/peaks.txt'),peaks)
    np.savetxt(Path(str(res_path) +'/valleys.txt'),valleys)
    np.savetxt(Path(str(res_path) +'/MAD_timeseries.txt'),mean_abs_disp)  
    
    plt.figure()
    plt.plot(mean_abs_disp, color = plt.cm.viridis(90),linewidth=1.5)

    plt.xlabel('Frame')
    plt.ylabel('Mean absolute displacement')
    #plt.savefig(Path(str(vis_path) +'/mean_abs_disp.eps'),format='eps')
    plt.savefig(Path(str(vis_path) +'/mean_abs_disp.png'),format='png')

    plt.close()
       
    return
