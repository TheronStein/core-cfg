// Get the current note's First Name and Last Name metadata values
let firstName = dv.current()["FirstName"];
let lastName = dv.current()["LastName"];

// Construct the folder path dynamically
let folderPath = `Webdata/src/res/imgs/str/bst/${firstName} ${lastName}`;

// Get all files in the vault
let allFiles = app.vault.getFiles();

// Filter the files to find the ones in the constructed folder path and with the correct extension
let images = allFiles.filter(file => 
    file.path.startsWith(folderPath) && 
    (file.extension === "jpg" || file.extension === "png")
);




