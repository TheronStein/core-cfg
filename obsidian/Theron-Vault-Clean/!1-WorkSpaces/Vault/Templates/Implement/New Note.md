#Templater/Unfinished

<%*
// Define my document types
const choices = [
  { name: "Minimal",
    fields: []
  },
  { name: "",
    fields: [
      "aliases: ", "type: ", "related:  ",
      "summary:  ", "status:  ",  "rating:  ",
      "url:  ", "folder:  ",
      "partition:  ",  "language:  ", "OS: ",
      'archetype: "[[My Stuff]]"',
      'up: "[[Programming]]"',
      "status: active", 
    ]
  }, 
  { name: "Project",
    fields: [
      "aliases: ", "type: ", "related:  ",
      "summary:  ", "status:  ", "rating:  ",
      "assigned:  ", "purchased:  ", "brand:  ",
      "cost: ", "partition:  ",  "OS: ",
      'archetype: "[[My Stuff]]"',
      "tags: personal/assets",
      'up: "[[Equipment]]"',
      'location: "[[Y0 Obsidian/Home]]"',
    ]
  }, 
  { name: "Documentation",
    fields: [
      "aliases: ", "type: ", "related:  ",
      "summary:  ", "status:  ", "rating:  ",
      "purpose:  ", "purchased:  ", "brand:  ",
      "cost:  ", "partition:  ",
      'archetype: "[[My Stuff]]"',
      "tags: personal/assets",
      'up: "[[Equipment]]"',
      'location: "[[Y0 Obsidian/Home]]"',
    ]
  },
  { name: "Repositories",
    fields: [
      "aliases: ", "type: ", "author:  ","related:  ",
      "summary:  ", "status:  ", "rating:  ",
      "purpose:  ", "url:  ", "folder:  ",
      "partition:  ",  "language:  ",
      'archetype: "[[My Stuff]]"',
		"tags: content/code",
		'up: "[[Programming]]"',
		"status: unknown"
	 ]
	},
]

// Select document type
const choice = await tp.system.suggester(t => t.name, choices)

// Build frontmatter
tR += "---\n" + choice.fields.join("\n") + "\n---\n"

// Include some templates
if (choice.name !== "Minimal" )
 tR += await tp.file.include("[[Default Minimal Template]]")
else
 tR += await tp.file.include("[[My Stuff Template Test]]") 
_%>