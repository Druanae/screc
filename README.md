# FFMPEG-Screenrecord
Record an area of the screen using FFMPEG
When recording is completed it will put the recorded GIF into /tmp

## Dependencies

* ffmpeg
* slop

## Installation
Clone this repository:
```bash
git clone git@owo.codes:druanae/FFMPEG-Screenrecord.git
cd FFMPEG-Screenrecord
```
Symlink the script to your $PATH directory.
For example I have `~/bin/` in my path so:
```bash
ln -s $(pwd)/screenrecord.sh ~/bin/screenrecord
```

## Todo
- [ ] Allow for setting a custom directory to save to.
- [ ] Allow for webm recording for higher FPS and Sound.
- [x] Allow for custom name formatting.
