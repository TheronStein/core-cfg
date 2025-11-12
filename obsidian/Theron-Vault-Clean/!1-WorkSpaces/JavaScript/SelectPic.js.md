 dv.pages('"Workspaces"').map(p=>p.file.name)
 
 FROM "2 Areas/Journal/Daily Notes"
 
 <button id="toggle-mode">Switch to Select Mode</button>
 
 <button id="save-selection">Save Selected Profile Pictures</button>
		   
```js
document.getElementById('save-selection').addEventListener('click', function() {
    if (selectedImages.length > 0) {
        // Replace this function with your logic for updating the metadata
        updateMetadata(selectedImages);  
        alert('Profile pictures updated!');
    } else {
        alert('No images selected.');
    }
});

function updateMetadata(images) {
    // Logic to update the metadata field in Obsidian
    // Assuming you have a mechanism to update your note's metadata (e.g., using Obsidian API or Metadata Menu)
    console.log('Selected Images:', images);
}
		   
.image-card.selected {
    border: 2px solid green; /* Example visual cue */
}
		   
let isSelectMode = false;

document.getElementById('toggle-mode').addEventListener('click', function() {
    isSelectMode = !isSelectMode;
    document.getElementById('toggle-mode').innerText = isSelectMode ? "Switch to Zoom Mode" : "Switch to Select Mode";
});

let selectedImages = [];

document.querySelectorAll('.image-card').forEach(card => {
    card.addEventListener('click', function(event) {
        if (!isSelectMode) {
            // If not in select mode, allow the image to zoom (default behavior)
            return;
        }
        
const imagePath = card.getAttribute('data-image-path');
        
        // Check if the image is already selected
        if (selectedImages.includes(imagePath)) {
            // If selected, deselect it
            selectedImages = selectedImages.filter(img => img !== imagePath);
            card.classList.remove('selected');
        } else if (selectedImages.length < 5) {
            // Select new image if less than 5 selected
            selectedImages.push(imagePath);
            card.classList.add('selected');  // Add visual indication of selection
        } else {
            alert('You can only select up to 5 images.');
        }
    });
});
```
