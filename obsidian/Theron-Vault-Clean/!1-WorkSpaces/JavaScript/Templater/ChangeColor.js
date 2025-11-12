// Update frontmatter after template finishes executing
<%*

const Colors = ["Red", "Blue", "Green", "Yellow", "Orange"]
const current = Colors[frontmatter["cssClasses"] += "Note" + Color[x];  ]

tp.hooks.on_all_templates_executed(async () => {
  const file = tp.file.find_tfile(tp.file.path(true));
  await tp.app.fileManager.processFrontMatter(file, (frontmatter) => {
    frontmatter["cssClasses"] += "Note" + Color[x];
  });
});
%>