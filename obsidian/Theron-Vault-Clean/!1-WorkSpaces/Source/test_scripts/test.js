export class TheronTest {
    /**
     * @param {Object} dv DataView object of Obisidian extension.
     */
    function hello_everyone() {
      const { obsidian, app } = self.customJS || {};
      if (obsidian == null || app == null) throw new Error("customJS is null.");

  
      dv.span(
        "You read the page: " +
          dv.fileLink(dv.current().file.path, false, "Guide for Obsidian")
      ) + ".";
    }
  }