// Utility function to delay execution
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Select elements in the DOM
let dock = document.querySelector(".mod-right-split");
let topPane = Array.from(dock.querySelectorAll(".workspace-tabs.mod-top"));
let lowerPanes = Array.from(dock.querySelectorAll(".workspace-tabs:not(.mod-top)"));
let iconSpace = document.querySelector(".sidebar-toggle-button.mod-right");

let isExpanded = false;

// Define CSS classes for toggling
let expandedClass = "expand-top-pane";
let hideClass = "hide-lower-pane";


// Define SVG icons for the button
let iconSplit = `
<div class="clickable-icon">
    <svg viewBox="0 0 17 17" xmlns="http://www.w3.org/2000/svg">
        <path d="M10.646 13.146l0.707 0.707-2.853 2.854-2.854-2.854 0.707-0.707 1.647 1.647v-3.772h1v3.772l1.646-1.647zM8 2.207v3.772h1v-3.772l1.646 1.646 0.707-0.707-2.853-2.853-2.854 2.853 0.707 0.707 1.647-1.646zM0 8v1h17v-1h-17z" fill="#000000"/>
    </svg>
</div>`;

let iconExpand = `
<div class="clickable-icon">
    <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" fill="none">
        <path d="M286.111111,496 C286.111111,496.552 286.584,497 287.166667,497 L299.833333,497 C300.416,497 300.888889,496.552 300.888889,496 C300.888889,495.448 300.416,495 299.833333,495 L287.166667,495 C286.584,495 286.111111,495.448 286.111111,496 L286.111111,496 Z ..."/>
    </svg>
</div>`;

// Button click handler
function togglePaneView() {
    const icon = document.querySelector(".icon-toggle-top-pane .clickable-icon");
    if (!isExpanded) {
        lowerPanes.forEach(pane => pane.classList.add(hideClass));
        topPane.forEach(pane => pane.classList.add(expandedClass));
        if (icon) icon.innerHTML = iconExpand;
        isExpanded = true;
    } else {
        lowerPanes.forEach(pane => pane.classList.remove(hideClass));
        topPane.forEach(pane => pane.classList.remove(expandedClass));
        if (icon) icon.innerHTML = iconSplit;
        isExpanded = false;
    }
}

// Add the toggle button to the sidebar
function addToggleButton(app)  {
    if (document.querySelector(".icon-toggle-top-pane")) return;

    let iconContainer = document.createElement("div");
    iconContainer.className = "icon-toggle-top-pane";
    iconContainer.draggable = false;
    iconContainer.setAttribute("aria-label", "Toggle Split Views");
    iconContainer.innerHTML = iconSplit;

    iconContainer.addEventListener("click", togglePaneView);

    let sidebar = document.querySelector(".mod-sidedock.mod-split-right");
    if (sidebar) sidebar.appendChild(iconContainer);
}

// Export the function for QuickAdd
module.exports = async (params) => {
    const { app } = params;
    addToggleButton(app);
};

// Remove the toggle button from the sidebar
function removeToggleButton() {
    let iconContainer = document.querySelector(".icon-toggle-top-pane");
    if (iconContainer) {
        iconContainer.style.opacity = "0";
        setTimeout(() => {
            iconContainer.remove();
        }, 300);
    }
}



// Check the number of workspace tabs and update the button visibility
async function toggleButtonOnSplit() {
    console.log("Running toggleButtonOnSplit...");

    await delay(100); // Ensure DOM updates are complete

    let sidebar = document.querySelector(".mod-sidedock.mod-split-right");
    if (!sidebar) return;

    let workspaceTabs = sidebar.querySelectorAll(".workspace-tabs");

    if (workspaceTabs.length > 1) {
        console.log("Adding toggle button...");
        addToggleButton();
    } else {
        console.log("Removing toggle button...");
        removeToggleButton();
    }
}



// Observe sidebar splitting dynamically
async function observeSidebarSplit() {
    const sidebar = document.querySelector(".mod-sidedock.mod-split-right");
    if (!sidebar) return;

    console.log("Observing sidebar changes...");
    const observer = new MutationObserver(async mutations => {
        for (const mutation of mutations) {
            if (mutation.type === "childList") {
                console.log("Sidebar split detected...");
                await toggleButtonOnSplit(); // Trigger on split
            }
        }
    });

    observer.observe(sidebar, { childList: true, subtree: true });

    // Disconnect observer when no longer needed
    return () => observer.disconnect();
}

// Run the script on document load
document.addEventListener("DOMContentLoaded", async () => {
    console.log("Initializing script...");
    await toggleButtonOnSplit(); // Run once at startup

    const disconnectObserver = await observeSidebarSplit();

    // Optional: Cleanup observer after a certain time (example: 1 minute)
    setTimeout(() => {
        console.log("Disconnecting observer...");
        disconnectObserver();
    }, 60000); // Adjust timeout as needed
});
