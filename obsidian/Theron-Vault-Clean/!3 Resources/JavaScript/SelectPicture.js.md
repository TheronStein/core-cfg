


```js
let isSelectMode = false;
let selectedImages = [];

document.getElementById('toggle-mode').addEventListener('click', function() {
    isSelectMode = !isSelectMode;
    document.getElementById('toggle-mode').innerText = isSelectMode ? "Switch to Zoom Mode" : "Switch to Select Mode";
});

document.querySelectorAll('.image-card').forEach(card => {
    card.addEventListener('click', function(event) {
        if (!isSelectMode) return; // Only allow selection in select mode
        const imagePath = card.getAttribute('data-image-path');
        if (selectedImages.includes(imagePath)) {
            selectedImages = selectedImages.filter(img => img !== imagePath);
            card.classList.remove('selected');
        } else if (selectedImages.length < 5) {
            selectedImages.push(imagePath);
            card.classList.add('selected');
        } else {
            alert('You can only select up to 5 images.');
        }
    });
});

document.getElementById('save-selection').addEventListener('click', function() {
    if (selectedImages.length > 0) {
        updateMetadata(selectedImages);
        alert('Profile pictures updated!');
    } else {
        alert('No images selected.');
    }
});

function updateMetadata(images) {
    // Prepare the formatted string for each image
    let formattedImages = images.map(image => {
        let imageName = image.split('/').pop(); // Get just the file name from the path
        return `![${imageName}](${image})`;
    }).join(', ');

    // Retrieve the current note content (you might be able to access this via Obsidian's API)
    let currentNoteContent = app.workspace.activeLeaf.view.sourceMode.cmEditor.getValue();  // Get the raw markdown of the note

    // Check if "ProfilePictures::" already exists in the note
    if (currentNoteContent.includes("ProfilePictures::")) {
        // Replace the existing metadata with the new list of images
        currentNoteContent = currentNoteContent.replace(/ProfilePictures::.*$/, `ProfilePictures:: ${formattedImages}`);
    } else {
        // If "ProfilePictures::" does not exist, append it at the end
        currentNoteContent += `\nProfilePictures:: ${formattedImages}`;
    }

    // Update the note content
    app.workspace.activeLeaf.view.sourceMode.cmEditor.setValue(currentNoteContent);  // Set the updated content back to the note
}

table file.name as "Images"
from "Webdata/src/res/imgs/str/bst/FulllName"
where file.extension = "jpg" or file.extension = "png"
```