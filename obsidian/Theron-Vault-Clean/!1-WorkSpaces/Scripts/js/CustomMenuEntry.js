class AddCustomMenuEntry {
  constructor() {
    // Binding the event handler to the `this` context of the class.
    this.eventHandler = this.eventHandler.bind(this);
  }

  async invoke() {
    this.app.workspace.on('file-menu', this.eventHandler);
  }

  deconstructor() {
    this.app.workspace.off('file-menu', this.eventHandler);
  }

  eventHandler(menu, file) {
    // Look in the API documentation for this feature
    //  https://docs.obsidian.md/Plugins/User+interface/Context+menus
    menu.addSeparator();
    menu.addItem((item) => {
      item
        .setTitle('Custom menu entry text..')
        .setIcon('file-plus-2') // Look in the API documentation for the available icons
        .onClick(() => {        //  https://docs.obsidian.md/Plugins/User+interface/Icons
          // Insert the code here that is to be executed when the context menu entry is clicked.
        });
    });
  }
}