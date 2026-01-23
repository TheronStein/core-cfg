#!/bin/bash
echo "jseval -q document.querySelector('video').requestPictureInPicture();" >>"$QUTE_FIFO"
