# Now Playing Retriever

Demo with my [Now Playing widget](https://github.com/adarhef/NowPlaying) in OBS:

https://user-images.githubusercontent.com/6278531/151031011-5ad112d1-5cf3-4bb6-ab33-8c0542a98cf6.mp4

Now Playing Retriever is a simple Mac app that listens for changes in the system's "Now Playing" data in the control center.
It then saves that data to files within its container, which can be symlinked to in order to access them.
I made this for [my Twitch stream](https://twitch.tv/furiousgallus) for rare macOS streams where I want my [Now Playing widget](https://github.com/adarhef/NowPlaying) to work.

The app uses private Apple APIs, so it is not guaranteed to continue to work forever.

## Installation

Download the latest release from the Releases page and extract it somewhere.
Currently the app is not notarized, so you'd have to put it in your Applications folder, then right click it and choose `Open`.
In the dialog that pops up, choose `Open`.

You'll now need to setup symlinks to access the internal files.

For example, if you're using this with [my widget](https://github.com/adarhef/NowPlaying):
* Take the `setup_file_links_example.sh` file and paste it in the `Snip` folder.
* Open `Terminal`, cd to the widget's `Snip` folder.
* Delete `Snip_Artist.txt`,`Snip_Album.txt`,`Snip_Artwork.jpg` and `Snip_Track.txt` if they exit.
* run `chmod +x setup_file_links_example.sh` and then `./setup_file_links_example.sh`.

## Usage

Simply run the app whenever you want the internal files to be updated with whatever's currently playing.

## Contributing

If you'd like more behavior customizations, open an issue and we can talk about what can be done.

## Donations

[![](https://www.paypalobjects.com/en_US/IL/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=2C294FLX63PDQ)

## License
[MIT](https://choosealicense.com/licenses/mit/)
