#!/bin/bash
rm -f Snip_Artist.txt
rm -f Snip_Track.txt
rm -f Snip_Album.txt
rm -f Snip_Artwork.jpg

ln -s ~/Library/Containers/co.AdarHefer.NowPlayingRetriever/Data/artist.txt Snip_Artist.txt
ln -s ~/Library/Containers/co.AdarHefer.NowPlayingRetriever/Data/track.txt Snip_Track.txt
ln -s ~/Library/Containers/co.AdarHefer.NowPlayingRetriever/Data/album.txt Snip_Album.txt
ln -s ~/Library/Containers/co.AdarHefer.NowPlayingRetriever/Data/artwork.jpg Snip_Artwork.jpg
