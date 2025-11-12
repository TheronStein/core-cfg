Here's the template code!

```
<%*
const file = tp.file.find_tfile(tp.file.path(true));
await app.vault.process(file, data => {
  // Split content by header tags
  const sections = data.split(/(?=\n#+\s)/);

  // Process each section
  const processedSections = sections.map(section => {
    const lines = section.split('\n');
    const header = lines[0]; // Extract header tag

    // Find all image links within the content and remove parameters
    const imageLinks = lines.filter(line => line.match(/!\[\[[^\]]*\.(webp|png|jpg|gif|jpeg)\s*(?:\|.*)?\]\]/));

    if (imageLinks.length > 1) {
      const formattedImages = imageLinks.map(link => {
        const cleanLink = link.replace(/\s*\|.*$/, ''); // Remove parameters
        if (!cleanLink.endsWith(']]')) {
          return `${cleanLink}]]`; // Add back the closing brackets if not present
        }
        return cleanLink; // Return unchanged if closing brackets are already present
      }).join("\n");
      const nonImageContent = lines.filter(line => !line.match(/!\[\[[^\]]*\.(webp|png|jpg|gif|jpeg)\s*(?:\|.*)?\]\]/)).join("\n");
      return `${header}\n${nonImageContent}\n\`\`\`image-layout-masonry-3\n${formattedImages}\n\`\`\``;
    }
    return section; // Return unchanged if fewer than two images found in the section
  });

  return processedSections.join("\n");
});
-%>
```

```
<%*
const file = tp.file.find_tfile(tp.file.path(true));
await app.vault.process(file, data => {
  const formattedImagesRegex = /```\s*image-layout-masonry-3\s*([\s\S]*?)```/g;

  // Replace formatted images within image-layout-masonry-3 blocks
  const revertedData = data.replace(formattedImagesRegex, (match, p1) => {
    const images = p1.trim().split('\n').map(line => line.trim().replace(/!\[\[([^|\]]*?)(?:\s*\|.*)?\]\]/g, '![[$1]]'));
    return images.join('\n\n');
  });

  return revertedData;
});
-%>
```