[plugins/full-border.yazi at main · yazi-rs/plugins](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi)

# full-border.yazi

[](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi#full-borderyazi)

Add a full border to Yazi to make it look fancier.

[![full-border](https://private-user-images.githubusercontent.com/17523360/340612946-ef81b560-2465-4d36-abf2-5d21dcb7b987.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY1NDcsIm5iZiI6MTc1NzY3NjI0NywicGF0aCI6Ii8xNzUyMzM2MC8zNDA2MTI5NDYtZWY4MWI1NjAtMjQ2NS00ZDM2LWFiZjItNWQyMWRjYjdiOTg3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTIlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTEyVDExMjQwN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWYyYWIwOTcxMDllNDg3MTg5NGYyNDgzMWY4MTIyZjFiMzI1ODA4MjYwNzViOWNkZDkyMzk3OThmM2UxNTFhMGEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.FHq6IDvvvHSyj68ebXcoZKq19KUzv_2n0MJiHp7hCWI)](https://private-user-images.githubusercontent.com/17523360/340612946-ef81b560-2465-4d36-abf2-5d21dcb7b987.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY1NDcsIm5iZiI6MTc1NzY3NjI0NywicGF0aCI6Ii8xNzUyMzM2MC8zNDA2MTI5NDYtZWY4MWI1NjAtMjQ2NS00ZDM2LWFiZjItNWQyMWRjYjdiOTg3LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA5MTIlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwOTEyVDExMjQwN1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWYyYWIwOTcxMDllNDg3MTg5NGYyNDgzMWY4MTIyZjFiMzI1ODA4MjYwNzViOWNkZDkyMzk3OThmM2UxNTFhMGEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.FHq6IDvvvHSyj68ebXcoZKq19KUzv_2n0MJiHp7hCWI)

## Installation

[](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi#installation)

ya pkg add yazi-rs/plugins:full-border

## Usage

[](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi#usage)

Add this to your `init.lua` to enable the plugin:

require("full-border"):setup()

Or you can customize the border type:

require("full-border"):setup {
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
}

## License

[](https://github.com/yazi-rs/plugins/tree/main/full-border.yazi#license)This plugin is MIT-licensed. For more information check the [LICENSE](https://github.com/yazi-rs/plugins/blob/main/full-border.yazi/LICENSE) file.
