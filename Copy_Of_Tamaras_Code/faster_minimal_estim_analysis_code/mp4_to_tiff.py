# -*- coding: utf-8 -*-
"""
Created on Fri Mar  1 14:31:45 2024

@author: Tamara
"""

import cv2
import os
from pathlib import Path
import time

def mp4_to_tiff(input_path, video_filename, start_timepoint=None, end_timepoint=None):
    ''' 
    mp4_to_tiff(input_path, video_filename, start_timepoint=None, end_timepoint=None)
    
    Converts the video found at a specific input_path into a series of individual tiff frames, saved in a new parent folder
    called Converted_Videos, followed by a subfolder with the same name as the video. 
    Specifically for videos from the Zeiss microscope, where the frame rate is 30 fps.
    Do not include the mp4 extension in video_filename.
    
    Optional: indicate the start and end timepoint of the video, in seconds.
    
    Also make sure to import the following packages at the beginning of your script calling the function: 
    cv2, os, Path (from pathlib), time.
    '''
    # Frame rate definition (to be changed if we use another microscope)
    frame_rate = 30 #fps
    
    # Path to the input video file
    joined_input_path = (Path(input_path) / f"{video_filename}.mp4").absolute()
    assert joined_input_path.exists()
    #os.path.join(input_path, video_filename+'.mp4')

    # Test if start and end timepoints have been provided, and define output path accordingly
    if start_timepoint is not None and end_timepoint is not None:
        # Convert seconds into frames
        start_frame = int(frame_rate * start_timepoint)
        end_frame = int(frame_rate * end_timepoint)
        # Path to save the TIFF files
        output_path = os.path.join(Path(joined_input_path).parents[1], 
                                   Path(f'Converted_Videos/{video_filename}_{start_timepoint}-{end_timepoint}sec/'))
    else:
        output_path = os.path.join(Path(joined_input_path).parents[1], Path(f'Converted_Videos/{video_filename}/'))

    # Create the output directory if it doesn't exist
    try:
        os.makedirs(output_path)
    except FileExistsError:
        # If it already exists, break out of the function and display a warning message
        print('Output directory already exists - cannot proceed.')
        pass
        return

    # Start the timer
    start_time = time.time()

    # Four-character code for the desired codec (e.g., 'H264') (might make it faster to run)
    codec_fourcc = cv2.VideoWriter_fourcc(*'H264')

    # Open the video file
    video_capture = cv2.VideoCapture(joined_input_path)
    video_capture.set(cv2.CAP_PROP_FOURCC, codec_fourcc)

    # Initialize frame count
    frame_count = 0
    frame_saved = 0

    # Read until video is completed
    while True:
        # Read a single frame from the video
        ret, frame = video_capture.read()
    
        # If the frame was not read (end of video), break the loop
        if not ret:
            break
        
        if start_timepoint is not None and end_timepoint is not None:
            # If start and end timepoints are provided, save only those as TIFF
            if frame_count in range(start_frame, end_frame):
                frame_path = os.path.join(output_path, f'frame_{frame_count:04d}.tiff')
                
                # Save the frame as a compressed TIFF file (relies on 'deflate' lossles compression)
                cv2.imwrite(frame_path, frame, params=(cv2.IMWRITE_TIFF_COMPRESSION, 32946))  # Numerical code for deflate 
        
                # Increment the saved frame count
                frame_saved += 1
        # Otherwise, save the whole video as TIFF
        else:
            frame_path = os.path.join(output_path, f'frame_{frame_count:04d}.tiff')
                
            # Save the frame as a compressed TIFF file (relies on 'deflate' lossles compression)
            cv2.imwrite(frame_path, frame, params=(cv2.IMWRITE_TIFF_COMPRESSION, 32946))  # Numerical code for deflate 
        
            # Increment the saved frame count
            frame_saved += 1
        
        # Increment the frame count
        frame_count += 1

    # Release the video capture object
    video_capture.release()

    # Stop the timer
    end_time = time.time()
    elapsed_time = end_time - start_time
    
    print(f'Successfully converted video {video_filename}.')
    print(f'{frame_saved} frames extracted and saved as TIFF files.')
    print(f'Run time: {elapsed_time} seconds.')
    
    return

