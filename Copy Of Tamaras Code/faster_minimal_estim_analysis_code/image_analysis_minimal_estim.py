import cv2
import glob
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np
import os
from pathlib import Path
from skimage import exposure
from skimage import img_as_ubyte
from skimage import io
from typing import List, Union
from matplotlib.animation import PillowWriter
import warnings


def read_tiff(img_path: Path) -> np.ndarray:
    """Given a path to a tiff. Will return an array."""
    img = io.imread(img_path)
    img_uint8 = img_as_ubyte(img)
    img_uint8 = img_uint8.astype('uint8')
    return img_uint8

def image_folder_to_path_list(folder_path: Path) -> List:
    """Given a folder path. Will return the path to all files in that path in order."""
    name_list = glob.glob(str(folder_path) + '/*.tif*')
    name_list.sort()
    name_list_path = []
    for name in name_list:
        name_list_path.append(Path(name))
    return name_list_path


def read_all_tiff(path_list: List) -> List:
    """Given a folder path. Will return a list of all tiffs as an array."""
    tiff_list = []
    for path in path_list:
        array = read_tiff(path)
        tiff_list.append(array)
    return tiff_list


def create_folder(folder_path: Path, new_folder_name: str) -> Path:
    """Given a path to a directory and a folder name. Will create a directory in the given directory."""
    new_path = folder_path.joinpath(new_folder_name).resolve()
    if new_path.exists() is False:
        os.mkdir(new_path)
    return new_path


def uint16_to_uint8(img_16: np.ndarray) -> np.ndarray:
    """Given a uint16 image. Will normalize + rescale and convert to uint8."""
    img_8 = img_as_ubyte(exposure.rescale_intensity(img_16))
    return img_8

def uint16_to_uint8_all(img_list: List) -> List:
    """Given an image list of uint16. Will return the same list all as uint8."""
    uint8_list = []
    for img in img_list:
        img8 = uint16_to_uint8(img)
        uint8_list.append(img8)
    return uint8_list

# Added by Tamara
def grayscale(img_8: np.ndarray) -> np.ndarray:
    """Given a uint8 image. Will convert to grayscale."""
    if img_8.ndim == 3:
        img_8 = cv2.cvtColor(img_8, cv2.COLOR_RGB2GRAY)
    return img_8

# Added by Tamara
def grayscale_all(img_list: List) -> List:
    grayscale_list = []
    for img in img_list:
        img_gray = grayscale(img)
        grayscale_list.append(img_gray)
    return grayscale_list

def get_tracking_param_dicts() -> dict:
    """Will return dictionaries specifying the feature parameters and tracking parameters.
    In future, these may vary based on version."""
    feature_params = dict(maxCorners=10000, qualityLevel=0.01, minDistance=12, blockSize=3)
    window = 5
    lk_params = dict(winSize=(window, window), maxLevel=15, criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))
    return feature_params, lk_params

def shrink_pair(v0: int, v1: int, sf: float) -> int:
    """Given two values and an amount to shrink their difference by. Will return the new values."""
    dist = v1 - v0
    new_v0 = v0 + int(dist * sf * 0.5)
    new_v1 = v1 - int(dist * sf * 0.5)
    return new_v0, new_v1

def box_to_bound(box: np.ndarray) -> int:
    """Given a grid aligned box. Will convert it to bounds format."""
    r0 = int(np.min(box[:, 0]))
    r1 = int(np.max(box[:, 0]))
    c0 = int(np.min(box[:, 1]))
    c1 = int(np.max(box[:, 1]))
    return r0, r1, c0, c1

def bound_to_box(r0: int, r1: int, c0: int, c1: int) -> np.ndarray:
    """Given some bounds. Will return them formatted as a box"""
    box = np.asarray([[r0, c0], [r0, c1], [r1, c1], [r1, c0]])
    return box

def is_in_box(box: np.ndarray, rr: int, cc: int) -> bool:
    """Given a box and a point. Will return True if the point is inside the box, False otherwise."""
    r0, r1, c0, c1 = box_to_bound(box)
    if rr > r0 and rr < r1 and cc > c0 and cc < c1:
        return True
    else:
        return False
  
def adjust_feature_param_dicts(feature_params: dict, img_uint8: np.ndarray, min_coverage: Union[float, int] = 40) -> dict:
    """Given feature parameters and an image. Will automatically update the feature quality to ensure sufficient coverage.
    (min_coverage refers to the number of pixels that should be attributed to 1 tracking point)"""
    # Ensure the image is in the correct format (CV_8UC1)
    if img_uint8.ndim == 3:
        img_gray = cv2.cvtColor(img_uint8, cv2.COLOR_RGB2GRAY)
    else:
        img_gray = img_uint8

    # detects image features that make good points to track over time (aka corners)
    track_points_0 = cv2.goodFeaturesToTrack(img_gray, **feature_params)
    
    qualityLevel = feature_params["qualityLevel"] 
    # ratio of the number of pixels in the image to the number of feature points detected
    coverage = img_uint8.size / track_points_0.shape[0]
    iter = 0
    
    while coverage > min_coverage and iter < 15:
        qualityLevel = qualityLevel * 10 ** (np.log10(0.1) / 10) # this value raised to 10 is 0.1, so it will lower quality by an order of magnitude in 10 iterations
        feature_params["qualityLevel"] = qualityLevel
        
        track_points_0 = cv2.goodFeaturesToTrack(img_gray, **feature_params)
        coverage = img_uint8.size / track_points_0.shape[0]
        iter += 1

    return feature_params

def track_one_step(img_uint8_0: np.ndarray, img_uint8_1: np.ndarray, track_points_0: np.ndarray, lk_params: dict):
    """Given img_0, img_1, tracking points p0, and tracking parameters.
    Will return the tracking points new location. Note that for now standard deviation and error are ignored."""
    track_points_1, _, _ = cv2.calcOpticalFlowPyrLK(img_uint8_0, img_uint8_1, track_points_0, None, **lk_params)
    return track_points_1

def track_all_steps(img_list_uint8: List, feature_params: dict, lk_params: dict) -> np.ndarray:
    """Given the image list in order, feature parameters and tracking parameters. Will run tracking through the whole img list in order.
    Note that the returned order of tracked points will match order_list."""
    img_0 = img_list_uint8[0]
    track_points = cv2.goodFeaturesToTrack(img_0, **feature_params)
    
    plt.figure()
    plt.imshow
    num_track_pts = track_points.shape[0]
    num_imgs = len(img_list_uint8)
    tracker_0 = np.zeros((num_track_pts, num_imgs))
    tracker_1 = np.zeros((num_track_pts, num_imgs))
    for kk in range(0, num_imgs - 1):
        tracker_0[:, kk] = track_points[:, 0, 0]
        tracker_1[:, kk] = track_points[:, 0, 1]
        img_0 = img_list_uint8[kk]
        img_1 = img_list_uint8[kk + 1]
        track_points = track_one_step(img_0, img_1, track_points, lk_params)
    tracker_0[:, kk + 1] = track_points[:, 0, 0]
    tracker_1[:, kk + 1] = track_points[:, 0, 1]
    return tracker_0, tracker_1

def track_all_steps_with_adjust_param_dicts(img_list_uint8: List) -> dict:
    """Given image list. Will automatically update the feature parameters and tracking parameters to ensure accurate and robust tracking.
    Will return tracked points through the whole img list in order. """
    feature_params, lk_params = get_tracking_param_dicts()
    img_0 = img_list_uint8[0]
       
    feature_params = adjust_feature_param_dicts(feature_params, img_0)
    tracker_0, tracker_1 = track_all_steps(img_list_uint8, feature_params, lk_params)
    _, disp_abs_all, _, _  = compute_abs_position_timeseries(tracker_0, tracker_1)
    max_disp_abs = np.max(disp_abs_all)
    window_size = lk_params["winSize"][0]
    iter = 0  
    while window_size < max_disp_abs and iter < 15:
        window_size += 5
        lk_params["winSize"] = (window_size,window_size)
        tracker_0, tracker_1 = track_all_steps(img_list_uint8, feature_params, lk_params)
        _, disp_abs_all, _, _  = compute_abs_position_timeseries(tracker_0, tracker_1)
        max_disp_abs = np.max(disp_abs_all)
        iter += 1
    if max_disp_abs < 1:
        warnings.warn("All tracked displacements are subpixel displacements. Results have limited accuracy!")
    return tracker_0, tracker_1


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

def save_tracking(*, folder_path: Path, tracker_row_all: np.ndarray, tracker_col_all: np.ndarray, info: np.ndarray = None, is_rotated: bool = False, rot_info: np.ndarray = None, is_translated: bool = False, fname: str = None) -> List:
    """Given tracking results. Will save as text files."""
    new_path = create_folder(folder_path, "results")
    saved_paths = []
    if fname is not None:
        file_path = new_path.joinpath(fname + "_pos_y.txt" ).resolve()
        saved_paths.append(file_path)
        np.savetxt(str(file_path), tracker_row_all)
        file_path = new_path.joinpath(fname + "_pos_x.txt" ).resolve()
        saved_paths.append(file_path)
        np.savetxt(str(file_path), tracker_col_all)
    else:
        file_path = new_path.joinpath("pos_y.txt").resolve()
        saved_paths.append(file_path)
        np.savetxt(str(file_path), tracker_row_all)
        file_path = new_path.joinpath("pos_x.txt").resolve()
        saved_paths.append(file_path)
        np.savetxt(str(file_path), tracker_col_all)

    saved_paths.append(file_path)
    return saved_paths


def run_tracking(folder_path: Path) -> List:
    """Given a folder path. Will perform tracking and save results as text files."""
    # read images
    movie_folder_path = folder_path
    name_list_path = image_folder_to_path_list(movie_folder_path)
    tiff_list = read_all_tiff(name_list_path)
    img_list_uint8 = uint16_to_uint8_all(tiff_list)
    img_list_grayscale = grayscale_all(img_list_uint8)
    # perform tracking
    tracker_0, tracker_1 = track_all_steps_with_adjust_param_dicts(img_list_grayscale)
    timeseries, _, _, _ = compute_abs_position_timeseries(tracker_0, tracker_1)
    # save tracking results
    saved_paths = save_tracking(folder_path=folder_path, tracker_col_all=tracker_0, tracker_row_all=tracker_1)
    return saved_paths


def load_tracking_results(*, folder_path: Path, is_rotated: bool = False, is_translated: bool = False, fname: str = None) -> List:
    """Given the folder path. Will load tracking results. If there are none, will return an error."""
    res_folder_path = folder_path.joinpath("results").resolve()
    if res_folder_path.exists() is False:
        raise FileNotFoundError("tracking results are not present -- tracking must be run before visualization")
    rev_file_0 = res_folder_path.joinpath("rotated_beat0_col.txt").resolve()
    if is_rotated:
        if rev_file_0.is_file() is False:
            raise FileNotFoundError("rotated tracking results are not present -- rotated tracking must be run before rotated visualization")


    if fname is not None:
        tracker_row = np.loadtxt(str(res_folder_path) + "/" + fname + "_pos_y.txt")
        tracker_col = np.loadtxt(str(res_folder_path) + "/" + fname + "_pos_x.txt")
    else:
        tracker_row = np.loadtxt(str(res_folder_path) + "/pos_y.txt")
        tracker_col = np.loadtxt(str(res_folder_path) + "/pos_x.txt")

    return tracker_row, tracker_col


def get_title_fname(kk: int) -> str:
    ti = "frame %i" % (kk)
    fn = "%04d_disp.png" % (kk)
    fn_gif = "abs_disp.gif"
    fn_row_gif = "y_disp.gif"
    fn_col_gif = "x_disp.gif"
    return ti, fn, fn_gif, fn_row_gif, fn_col_gif


def create_pngs(
    folder_path: Path,
    tiff_list: List,
    tracker_row_all: np.ndarray,
    tracker_col_all: np.ndarray,
    info: np.ndarray,
    output: str, 
    col_min: Union[float, int],
    col_max: Union[float, int],
    col_map: object,
    *,
    is_rotated: bool = False,
    include_interp: bool = False,
    interp_tracker_row_all: List = None,
    interp_tracker_col_all: List = None,
    save_eps: bool = False
) -> List:
    """Given tracking results. Will create png version of the visualizations."""
    vis_folder_path = create_folder(folder_path, "visualizations")
    main_pngs_folder_path = create_folder(vis_folder_path, "pngs")
    
    if output == 'abs':
        pngs_folder_path = create_folder(main_pngs_folder_path, "pngs_abs")
    elif output == 'row':
        pngs_folder_path = create_folder(main_pngs_folder_path, "pngs_y")
    elif output == 'col':
        pngs_folder_path = create_folder(main_pngs_folder_path, "pngs_x")
    
    path_list = []
    _, disp_all, disp_0_all, disp_1_all = compute_abs_position_timeseries(tracker_row_all, tracker_col_all)
    for kk in range(tracker_row_all.shape[1]):
        ti, fn, _, _, _ = get_title_fname(kk)
        plt.figure()
        plt.imshow(tiff_list[kk], cmap=plt.cm.gray)
        
        if output == 'abs':
            plt.scatter(tracker_col_all[:, kk], tracker_row_all[:, kk], c=disp_all[:, kk], s=2, cmap=col_map, vmin=col_min, vmax=col_max)
            
        elif output == 'row':
            plt.scatter(tracker_col_all[:, kk], tracker_row_all[:, kk], c=disp_0_all[:, kk], s=2, cmap=col_map, vmin=col_min, vmax=col_max)
            
        elif output == 'col':
            plt.scatter(tracker_col_all[:, kk], tracker_row_all[:, kk], c=disp_1_all[:, kk], s=2, cmap=col_map, vmin=col_min, vmax=col_max)

        plt.title(ti)
        plt.axis("off")
        cbar = plt.colorbar()
        cbar.ax.get_yaxis().labelpad = 15
        if output == 'abs':
            cbar.set_label("absolute displacement (pixels)", rotation=270)
        elif output == 'row':
            cbar.set_label("y (vertical) displacement (pixels)", rotation=270)
        elif output == 'col':
            cbar.set_label("x (horizontal) displacement (pixels)", rotation=270)
        path = pngs_folder_path.joinpath(fn).resolve()
        plt.savefig(str(path), dpi=300)
        if save_eps:
            plt.savefig(str(path)[0:-4]+'.eps', format='eps')
        plt.close()
        path_list.append(path)
    return path_list


def create_gif(folder_path: Path, png_path_list: List, output: str, is_rotated: bool = False, include_interp: bool = False) -> Path:
    """Given the pngs path list. Will create a gif."""
    img_list = []
    img = plt.imread(png_path_list[0])
    img_r, img_c,_ = img.shape
    fig, ax = plt.subplots(figsize=(img_c/100,img_r/100))
    plt.axis('off')
    plt.tight_layout(pad=0.08, h_pad=None, w_pad=None, rect=None)
    for pa in png_path_list:
        img = ax.imshow(plt.imread(pa),animated=True)
        img_list.append([img])
    _, _, fn_gif, fn_row_gif, fn_col_gif = get_title_fname(0)    
    if output == 'abs':
        gif_path = folder_path.joinpath("visualizations").resolve().joinpath(fn_gif).resolve()
    elif output == 'row':
        gif_path = folder_path.joinpath("visualizations").resolve().joinpath(fn_row_gif).resolve()
    elif output == 'col':
        gif_path = folder_path.joinpath("visualizations").resolve().joinpath(fn_col_gif).resolve()
    ani = animation.ArtistAnimation(fig, img_list,interval=100)
    #ani.save(gif_path,dpi=100)
    ani.save(gif_path, dpi=100, writer=PillowWriter())
    return gif_path



def run_visualization(folder_path: Path, col_min_abs: Union[int, float] = 0, col_max_abs: Union[int, float] = 8, col_min_row: Union[int, float] = -3, col_max_row: Union[int, float] = 4.5, col_min_col: Union[int, float] = -3, col_max_col: Union[int, float] = 4.5, col_map: object = plt.cm.viridis) -> List:
    """Given a folder path where tracking has already been run. Will save visualizations."""
    # read image files
    movie_folder_path = folder_path
    name_list_path = image_folder_to_path_list(movie_folder_path)
    tiff_list = read_all_tiff(name_list_path)
    # read tracking results
    tracker_row_all, tracker_col_all = load_tracking_results(folder_path=folder_path)
    ##clim_abs_min, clim_row_min, clim_col_min = col_min_abs, col_min_row, col_min_col
    ##clim_abs_max, clim_row_max, clim_col_max = col_max_abs, col_max_row, col_max_col
    # create pngs
    abs_png_path_list = create_pngs(folder_path, tiff_list, tracker_row_all, tracker_col_all, None, "abs", col_min_abs, col_max_abs, col_map,save_eps = False)
    ##row_png_path_list = create_pngs(folder_path, tiff_list, tracker_row_all, tracker_col_all, None, "row", clim_row_min, clim_row_max, col_map,save_eps = False)
    ##col_png_path_list = create_pngs(folder_path, tiff_list, tracker_row_all, tracker_col_all, None, "col", clim_col_min, clim_col_max, col_map,save_eps = False)
    
    # create gif
    abs_gif_path = create_gif(folder_path, abs_png_path_list, "abs")
    ##row_gif_path = create_gif(folder_path, row_png_path_list, "row")
    ##col_gif_path = create_gif(folder_path, col_png_path_list, "col")
    ##return abs_png_path_list, row_png_path_list, col_png_path_list,  abs_gif_path, row_gif_path, col_gif_path
    return abs_png_path_list, abs_gif_path

