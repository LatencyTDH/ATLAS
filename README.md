# ATLAS
Automated tagging, labeling, and searching of videos stored on computing devices and the cloud.

Project created at HopHacks 2016. Designed and implemented by Sean, Charlie, Brandon, Michelle.

## Required Dependencies
### Python

1.  tensorflow
2.  nltktoolkit

### Other Software Libraries
ffmpeg

## Running the Video Classifier
1. ```cd``` to the ```scripts/``` directory.
2. Enter the following command:
    
    ```
    sudo ./classify_vid.sh [path-to-video-file]
    ```
        
3. View the auto-generated tags at ```/tmp/atlas/[video-name]/tags.json```.
