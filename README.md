# Screc - Quick & Easy Screen Recording with FFMPEG
A simple script that will record a selected aread of the screen or a selected window using FFMPEG and save it as a .gif file.

## Dependencies

* ffmpeg
* slop

## Installation
Clone this repository:
```bash
git clone https://github.com/druanae/screc.git
cd screc
```
Then run the setup script:
```bash
./setup.sh
```

## Usage
To start recording use:
```
screenrecord -gr
```
You can also specify a filename:
```
screenrecord -gr filename
```

To stop the recording from anywhere run:
```
screenrecord -gs
```
Exiting the original command with Ctrl + c will also work.

## Configuring
You can change the default filename and save directory in `${HOME}/.config/screc/config`.  
By default screc will save files to `${HOME}/Videos` with the time and date of recording.  
For example `SCREC_Monday-October-23_03:59:08.gif`

## Todo
- [x] Allow for setting a custom directory to save to.
- [ ] Allow for webm recording for higher FPS and Sound.
- [x] Allow for custom name formatting.
