[plugins/types.yazi at main · yazi-rs/plugins](https://github.com/yazi-rs/plugins/tree/main/types.yazi)

# types.yazi

[](https://github.com/yazi-rs/plugins/tree/main/types.yazi#typesyazi)

Type definitions for Yazi's Lua API, empowering an efficient plugin development experience.

## Installation

[](https://github.com/yazi-rs/plugins/tree/main/types.yazi#installation)

ya pkg add yazi-rs/plugins:types

## Usage

[](https://github.com/yazi-rs/plugins/tree/main/types.yazi#usage)

Create a `.luarc.json` file in your project root:

{
  "$schema": "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
  "runtime.version": "Lua 5.4",
  "workspace.library": \[
    // You may need to change the path to your local plugin directory
    "~/.config/yazi/plugins/types.yazi/",
  \],
}

See [https://luals.github.io/wiki/configuration/](https://luals.github.io/wiki/configuration/) for more information on how to configure LuaLS.

## Contributing

[](https://github.com/yazi-rs/plugins/tree/main/types.yazi#contributing)

All type definitions are automatically generated using [typegen.js](https://github.com/yazi-rs/yazi-rs.github.io/blob/main/scripts/typegen.js) based on the latest [plugin documentation](https://yazi-rs.github.io/docs/plugins/overview), so contributions should be made in the [`yazi-rs.github.io` repository](https://github.com/yazi-rs/yazi-rs.github.io).

## License

[](https://github.com/yazi-rs/plugins/tree/main/types.yazi#license)

This plugin is MIT-licensed. For more information, check the [LICENSE](https://github.com/yazi-rs/plugins/blob/main/types.yazi/LICENSE) file.
