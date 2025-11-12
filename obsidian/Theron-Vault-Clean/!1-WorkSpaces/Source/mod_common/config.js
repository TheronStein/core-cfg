/**
* @description Module for all config variables.
* @module Config
*/

// @ts-check

module.exports = {
    obsidianFolderPaths: {
      Vault: "!0-Vault",
      Vault/WorkSpaces: "!1-WorkSpaces",
      Vault/Resources: "!2-Resources",
      Vault/Archive: "!3-Archive",
      Main/Life: "01-Life",
      Main/Career: "02-Career",
      Main/Projects: "03-Projects",
      Main/Documentation: "04-Documentation",
      Main/Resources: "05-Resources",
      Main/Archive: "Archive",
      Personal/Secrets: "X0-Secrets",
      Personal/Meta: "X1-Meta",
      Mounts/Obsidian: "Y0-Obsidian",
      Mounts/Google: "Y1-Google"
    },
    fsRootPaths: {

      windows: "%userprofile%/Dropbox/Vaults/Theron-Clean-Vault", // Root path on Windows File System
      android: "", // Root path on Android File System
      mac: "", // Root path on Mac File System
      ios: "", // Root path on iOS File System
    },
   };