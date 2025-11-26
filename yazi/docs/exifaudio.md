[Sonico98/exifaudio.yazi: Preview audio files metadata on yazi](https://github.com/Sonico98/exifaudio.yazi)

# exifaudio.yazi

[](https://github.com/Sonico98/exifaudio.yazi#exifaudioyazi)

Preview audio metadata and cover on [Yazi](https://github.com/sxyazi/yazi).

[![image](https://private-user-images.githubusercontent.com/61394886/302044743-53c1492c-9f05-4c80-a4e7-94fb36f35ca9.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDcsIm5iZiI6MTc1NzY3NjM0NywicGF0aCI6Ii82MTM5NDg4Ni8zMDIwNDQ3NDMtNTNjMTQ5MmMtOWYwNS00YzgwLWE0ZTctOTRmYjM2ZjM1Y2E5LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTIlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTEyVDExMjU0N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTcyOWQ1ODhmMWU4ZjJjYjUxYjcxMmEwMzVkYmM1NmRmNTFiNjI4MTc3NTMyMjQwMDc4MzAyYjUxYTI3MGM3MjAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.0GVA5aFPppbTkGFlEoYtxPI0sqM6lWmu4NjVpHUR-RA)](https://private-user-images.githubusercontent.com/61394886/302044743-53c1492c-9f05-4c80-a4e7-94fb36f35ca9.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDcsIm5iZiI6MTc1NzY3NjM0NywicGF0aCI6Ii82MTM5NDg4Ni8zMDIwNDQ3NDMtNTNjMTQ5MmMtOWYwNS00YzgwLWE0ZTctOTRmYjM2ZjM1Y2E5LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTIlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTEyVDExMjU0N1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTcyOWQ1ODhmMWU4ZjJjYjUxYjcxMmEwMzVkYmM1NmRmNTFiNjI4MTc3NTMyMjQwMDc4MzAyYjUxYTI3MGM3MjAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.0GVA5aFPppbTkGFlEoYtxPI0sqM6lWmu4NjVpHUR-RA)

## Installation

[](https://github.com/Sonico98/exifaudio.yazi#installation)

# Automatically with yazi 0.3.0
ya pack -a "Sonico98/exifaudio"

# Or manually under:
# Linux/macOS
git clone https://github.com/Sonico98/exifaudio.yazi.git ~/.config/yazi/plugins/exifaudio.yazi

# Windows
git clone https://github.com/Sonico98/exifaudio.yazi.git %AppData%\\yazi\\config\\plugins\\exifaudio.yazi

## Usage

[](https://github.com/Sonico98/exifaudio.yazi#usage)

Add the following to your `yazi.toml`:

\[plugin\]
prepend_previewers = \[
    { mime = "audio/*",   run = "exifaudio"}
\]

Make sure you have [exiftool](https://exiftool.org/) installed and in your `PATH`.

Optional: if you have [mediainfo](https://mediaarea.net/en/MediaInfo) installed and in your `PATH`, it will be used instead for more accurate metadata. Exiftool is still required to display the cover.

## Thanks

[](https://github.com/Sonico98/exifaudio.yazi#thanks)

Thanks to [sxyazi](https://github.com/sxyazi) for the PDF previewer code, on which this previewer is based on.
