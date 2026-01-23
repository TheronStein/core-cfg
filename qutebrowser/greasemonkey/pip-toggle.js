// =mUserScript==
// @name        PiP Toggle
// @match       *://*.youtube.com/*
// @match       *://*/*
// ==/UserScript==

document.addEventListener('keydown', (e) => {
  if (e.altKey && e.key === 'p') {
    const video = document.querySelector('video');
    if (video) {
      if (document.pictureInPictureElement) {
        document.exitPictureInPicture();
      } else {
        video.requestPictureInPicture();
      }
    }
  }
}); // ==UserScript==
// @name        PiP Toggle
// @match       *://*.youtube.com/*
// @match       *://*/*
// ==/UserScript==

document.addEventListener('keydown', (e) => {
  if (e.altKey && e.key === 'p') {
    const video = document.querySelector('video');
    if (video) {
      if (document.pictureInPictureElement) {
        document.exitPictureInPicture();
      } else {
        video.requestPictureInPicture();
      }
    }
  }
});
