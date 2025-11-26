[ya pkg add yazi-rs/plugins:piperwylie102/duckdb.yazi: Yazi plugin that uses duckdb to preview data files.](https://github.com/wylie102/duckdb.yazi)

# duckdb.yazi

[](https://github.com/wylie102/duckdb.yazi#duckdbyazi)

**Uses [duckdb](https://github.com/duckdb/duckdb) to quickly preview and summarize data files in [yazi](https://github.com/sxyazi/yazi)!**

  
duckdb.yazi.mp4

  
  

## What does it do?

[](https://github.com/wylie102/duckdb.yazi#what-does-it-do)

This plugin previews your data files in yazi using DuckDB, with two available view modes:

- Preview csv, tsv, json, or parquet files in the following modes
    - Standard mode (default): Displays the file as a table
    - Summarized mode: Uses DuckDB's summarize function, enhanced with custom formatting for readability
- Preview duckdb databases
    - See the tables and the number of rows, columns, indexes in each. Plus a list of column names in index order.
- Scroll rows using `J` and `K`
- Scroll columns using your chosen keys ( I use `H` and `L` )
- Change modes by pressing K when at the top of a file

Supported file types:

- .csv
- .tsv
- .txt - if tabular data
- .json
- .parquet
- .xlsx
- .duckdb
- .db - if file is a duckdb database

  
  

## Features

[](https://github.com/wylie102/duckdb.yazi#features)

### Column Scrolling

[](https://github.com/wylie102/duckdb.yazi#column-scrolling)  
Horizontal.Scrolling.mp4  

- Now supports scrolling horizontally (by column).
- Works in all views
- In the database view you can even scroll through the list of column names.
- Output highlighting should now work across any os (where duckdb supports it).

> Requires a small amount of extra configuration from previous versions. These are keymaps (I use `H` and `L`) and some other aditional customisation options.
> 
> See the [Installation](https://github.com/wylie102/duckdb.yazi/tree/main?tab=readme-ov-file#installation) and [Configuration](https://github.com/wylie102/duckdb.yazi/tree/main?tab=readme-ov-file#configurationcustomisation) sections.

> **Cache changes - update 04/04/25** \- If you want info on the latest (cache related changes) then see [here](https://github.com/wylie102/duckdb.yazi?tab=readme-ov-file#setup-and-usage-changes-from-previous-versions). Otherwise keep reading new features and config options below.

  
  

### Output Syntax Highlighting

[](https://github.com/wylie102/duckdb.yazi#output-syntax-highlighting)

- Passes through the colors from the duckdb output as you would see if using directly in the terminal.
- These colors can be configured in your `~/.duckdbrc` file, see the Configuration section for details.

  

**Syntax highlighting with duckdb's default color scheme.** [![Screenshot 2025-04-02 at 14 53 38](https://private-user-images.githubusercontent.com/107398362/429513804-d2267298-b91b-496c-ae74-1d432b826f6f.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEzODA0LWQyMjY3Mjk4LWI5MWItNDk2Yy1hZTc0LTFkNDMyYjgyNmY2Zi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iNjA5YmVjYWI2ZWEyY2ZkMWVkOGE2MzJhZTI1MzU2NDQzZmJiNTc5NGM4ZGJkZjA5M2UwODU3M2Y1NGZlODZiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.hdnd9SC54uB0EFF3TswPsA2C03Yr_zTAWIGtVXGUAQ4)](https://private-user-images.githubusercontent.com/107398362/429513804-d2267298-b91b-496c-ae74-1d432b826f6f.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEzODA0LWQyMjY3Mjk4LWI5MWItNDk2Yy1hZTc0LTFkNDMyYjgyNmY2Zi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iNjA5YmVjYWI2ZWEyY2ZkMWVkOGE2MzJhZTI1MzU2NDQzZmJiNTc5NGM4ZGJkZjA5M2UwODU3M2Y1NGZlODZiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.hdnd9SC54uB0EFF3TswPsA2C03Yr_zTAWIGtVXGUAQ4)

  

**Syntax highlighting with customized color scheme.** [![Screenshot 2025-04-02 at 14 44 08](https://private-user-images.githubusercontent.com/107398362/429509926-965a0a4e-e4ed-4d88-ab95-84cd543f2a58.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTA5OTI2LTk2NWEwYTRlLWU0ZWQtNGQ4OC1hYjk1LTg0Y2Q1NDNmMmE1OC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iOWFmZDg2N2RjZjc2ZDI0MWRkMGMzYmFjZWZkMjNkZWQxYmVjYTlhNDU4YTk5MGZjZWQzYTliZjVhMDhhY2IyJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.zFqLKBtG2zafTVlxigNKvgm78sluZULL4juiY82WZY8)](https://private-user-images.githubusercontent.com/107398362/429509926-965a0a4e-e4ed-4d88-ab95-84cd543f2a58.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTA5OTI2LTk2NWEwYTRlLWU0ZWQtNGQ4OC1hYjk1LTg0Y2Q1NDNmMmE1OC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iOWFmZDg2N2RjZjc2ZDI0MWRkMGMzYmFjZWZkMjNkZWQxYmVjYTlhNDU4YTk5MGZjZWQzYTliZjVhMDhhY2IyJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.zFqLKBtG2zafTVlxigNKvgm78sluZULL4juiY82WZY8)

  

### Preview DuckDB Databases

[](https://github.com/wylie102/duckdb.yazi#preview-duckdb-databases)

- If you open a `.db` or `.duckdb` file directly, the plugin lists all tables in the database.
- Each entry includes:
    - Table name
    - Rows Count
    - Column count
    - Primary key presence
    - Index count
    - All column names (aggregated and in index order)
- Tables are **alphabetically ordered** and paginated for smooth scrolling.
- Reads directly from the db in read only mode for file safety.

  
[![Screenshot 2025-04-02 at 14 46 19](https://private-user-images.githubusercontent.com/107398362/429510883-c640d6f3-d9f6-4d98-acd8-9e4c87c6e728.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEwODgzLWM2NDBkNmYzLWQ5ZjYtNGQ5OC1hY2Q4LTllNGM4N2M2ZTcyOC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT02MDYwZjg4M2RjOGJkNmFhMzUxY2QwOTMwYjVjZjQ3YWEwZjNiMGJjNzBmZmU0N2NmN2RmNzZkMmMxOTI1ODQ2JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.i4uDFABJbP1stRsMWWjtXKqwZ9rVTbFXqUqSmGSSTrE)](https://private-user-images.githubusercontent.com/107398362/429510883-c640d6f3-d9f6-4d98-acd8-9e4c87c6e728.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEwODgzLWM2NDBkNmYzLWQ5ZjYtNGQ5OC1hY2Q4LTllNGM4N2M2ZTcyOC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT02MDYwZjg4M2RjOGJkNmFhMzUxY2QwOTMwYjVjZjQ3YWEwZjNiMGJjNzBmZmU0N2NmN2RmNzZkMmMxOTI1ODQ2JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.i4uDFABJbP1stRsMWWjtXKqwZ9rVTbFXqUqSmGSSTrE)  

### More customisation options - row_id (row number) and width of the min/max columns

[](https://github.com/wylie102/duckdb.yazi#more-customisation-options---row_id-row-number-and-width-of-the-minmax-columns)

- Row id - in standard view to help keep track when scrolling, Default is off, but can be turned on in `init.lua` options.
- Width of min and max columns. Default is now 21 twice as wide as previously. Is now customisable in the `init.lua`, the unit is the number of characters shown.

  
[![Screenshot 2025-04-02 at 14 49 26](https://private-user-images.githubusercontent.com/107398362/429512187-6c8fb1ae-3de8-41ce-9c90-0279dc3b5e61.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEyMTg3LTZjOGZiMWFlLTNkZTgtNDFjZS05YzkwLTAyNzlkYzNiNWU2MS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0xMDlmNWM4ZWFhODUwNzM2NGU1M2JkMGZmNTVlZWZmNmYzODYwMWQ5OThhODQ1NWNmZmJiODFhODBmN2MxNDQ3JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.DLMT02H_5sC4beAAgUl4r8H7OWQ3l5yOoiq_uIb2nKo)](https://private-user-images.githubusercontent.com/107398362/429512187-6c8fb1ae-3de8-41ce-9c90-0279dc3b5e61.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEyMTg3LTZjOGZiMWFlLTNkZTgtNDFjZS05YzkwLTAyNzlkYzNiNWU2MS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0xMDlmNWM4ZWFhODUwNzM2NGU1M2JkMGZmNTVlZWZmNmYzODYwMWQ5OThhODQ1NWNmZmJiODFhODBmN2MxNDQ3JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.DLMT02H_5sC4beAAgUl4r8H7OWQ3l5yOoiq_uIb2nKo)

  
  

### Preview mode is now toggleable

[](https://github.com/wylie102/duckdb.yazi#preview-mode-is-now-toggleable)

- Preview mode can be toggled within yazi
- Press "K" at the top of the file to toggle between "standard" and "summarized."
- The mode enabled at startup is customisable in the `init.lua` see Configuration section.

### Performance improvements through caching

[](https://github.com/wylie102/duckdb.yazi#performance-improvements-through-caching)

- "Standard" and "summarized" views are cached upon first load, improving scrolling performance
    
- Note that on entering a directory you haven't entered before (or one containing files that have been changed) cacheing is triggered. Until cache's are generated, summarized mode may take a longer to show as it will be run on the original file, and scrolling other files during this time (especially large ones) can slow things even further as new queries on the file will be competing with cache queries. Instead it is worth waiting until the caches load (displayed in bottom right corner) or switching to standard view during these first few seconds. This will be most apparent on large, non-parquet files
    

  
  

## Installation

[](https://github.com/wylie102/duckdb.yazi#installation)

### Installing dependancies

[](https://github.com/wylie102/duckdb.yazi#installing-dependancies)

First you will need Yazi and DuckDB installed.

- [Yazi Installation instructions](https://yazi-rs.github.io/docs/installation)
    
- [DuckDB Installation instructions](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=macos&download_method=direct)
    

Once these are installed you can use the yazi plugin manager to install the plugin.

Use the command:

```
ya pack -a wylie102/duckdb
```

in your terminal

  

### yazi.toml

[](https://github.com/wylie102/duckdb.yazi#yazitoml)

Then navigate to your [yazi.toml](https://yazi-rs.github.io/docs/configuration/yazi#manager.ratio) file this should be the `yazi` folder in your `config` directory

and add:

\[plugin\]  
prepend_previewers = \[  
  { name = "*.csv", run = "duckdb" },  
  { name = "*.tsv", run = "duckdb" },  
  { name = "*.json", run = "duckdb" },  
  { name = "*.parquet", run = "duckdb" },  
  { name = "*.txt", run = "duckdb" },  
  { name = "*.xlsx", run = "duckdb" },  
  { name = "*.db", run = "duckdb" },
  { name = "*.duckdb", run = "duckdb" }
\]

prepend_preloaders = \[  
  { name = "*.csv", run = "duckdb", multi = false },  
  { name = "*.tsv", run = "duckdb", multi = false },  
  { name = "*.json", run = "duckdb", multi = false },  
  { name = "*.parquet", run = "duckdb", multi = false },
  { name = "*.txt", run = "duckdb", multi = false },  
  { name = "*.xlsx", run = "duckdb", multi = false }
\]

> note on .txt: I have tried to exclude files that contain only raw text (if duckdb reads only one column). However, if you don't ever work with .txt files which contain tabular data (basically misnamed csv or tsv files) then you can just not include the .txt lines in your setup.

  

> note on .xlsx: This can be temperamental, especially around inferring types. This is due to the way that duckdb handles excel files. This feature currently uses st_read from the spatial extension since it gives the most consistent type results. Hopefully they will soon implement some of the smart type detection from the csv reader in their excel extension and then we can use that instead.

  

### init.lua

[](https://github.com/wylie102/duckdb.yazi#initlua)

Then create an `init.lua` file in the same folder and add

-- DuckDB plugin configuration
require("duckdb"):setup()

This is where the configuration/settings can go ([see below](https://github.com/wylie102/duckdb.yazi?tab=readme-ov-file#configurationcustomisation)), but the init.lua file and this line are required for the plugin to run, even if the settings are blank. Another option is to add all of the settings with the defaults in so that it's easy to change at a later date.

  

### keymap.toml

[](https://github.com/wylie102/duckdb.yazi#keymaptoml)

Then in your [keymap.toml](https://yazi-rs.github.io/docs/configuration/keymap) file add:

\[\[manager.prepend_keymap\]\]
on = "H"
run = "plugin duckdb -1"
desc = "Scroll one column to the left"

\[\[manager.prepend_keymap\]\]
on = "L"
run = "plugin duckdb +1"
desc = "Scroll one column to the right"

\[\[manager.prepend_keymap\]\]
on = \["g", "o"\]
run = "plugin duckdb -open"
desc = "open with duckdb"

\[\[manager.prepend_keymap\]\]
on = \["g", "u"\]
run = "plugin duckdb -ui"
desc = "open with duckdb ui"

> I use `H` and `L` because it makes logical sense to me.
> 
> But these overwrite:
> 
> - `H` \- previous directory and
> - `L` \- next directory (different from standard `h` and `l` for patent and child directory).
> 
> So if you use those you might want to choose something else, or remap those to and instead.

  

### Aditional setup and recommended plugins for more preview space

[](https://github.com/wylie102/duckdb.yazi#aditional-setup-and-recommended-plugins-for-more-preview-space)

Use with a larger preview window - add to your `yazi.toml`

\[manager\]
ratio = \[1, 2, 5\]

For reference the default ratio is 1, 4, 3

Use:

[maximize the preview pane plugin](https://github.com/yazi-rs/plugins/tree/main/toggle-pane.yazi)

  
  

## Configuration/Customisation

[](https://github.com/wylie102/duckdb.yazi#configurationcustomisation)

Configuration of yazi.duckdb is done via the `init.lua` file in `config/yazi` (where your plugin folder and yazi.toml file live). If you don't have one you can just create one. Add the following:

    -- DuckDB plugin configuration
require("duckdb"):setup({
  mode = "standard"/"summarized",            -- Default: "summarized"
  cache_size = 1000                          -- Default: 500
  row_id = true/false/"dynamic",             -- Default: false
  minmax\_column\_width = int                  -- Default: 21
  column\_fit\_factor = float                  -- Default: 10.0
})

If you don't include a setting, it will revert to the default.

But the setup call `require("duckdb"):setup()` is still required for the plugin to intialize correctly.

  

### Explaination of settings

[](https://github.com/wylie102/duckdb.yazi#explaination-of-settings)

- mode - the view that will be the default on startup. The default is summarized, but this can sometimes be slow if running while the files are also being cached. Most of the time it will be the same speed as standard, so pick the one you like.
    
- cache_size - the number of rows cached in the standard mode. Make the number higher if you want to be able to scroll further down in your files. Be aware this could impact cache size and cache performance if it was made too large. If you change this setting you will need to run `yazi --clear-cache` for it to take effect.
    
- row_id - displays a row column when viewing in standard mode. If set to dynamic it will only turn on when scrolling columns and will always be the left most column.
    
- minmax\_column\_width - is the number of characters displayed in the min and max columns in summarized view. Default is 21, which is roughly enough to see date and time in a datetime column. If you need more set it higher, if you want mim/max to take up less space set it lower.
    
- column\_fit\_factor - this one is actually important but might feel a bit counter-intuitive so have a look below.
    
    - TLDR: duckdb.yazi is designed to overspill the screen on the right side. Unless all your columns are incredibly narrow/you can see the right border of your table when there are still more columns to scroll OR you work with tables with a very large number of columns and scrolling them feels slightly show, you can probably leave it alone.
    - Slightly longer instructions: To fully optimise this, 1. Lower it until your columns no longer spill off the end of the screen (check this on a few files) Step 2 - Increase by 1 so that columns again spill over the right border.
    - More detailed explaination: Implementing column scrolling also gave us a mechanism to user-attachments only the columns we need to fill (in reality slightly overfill) the screen. The reason for this is that if the table is incredibly wide (has a high number of columns) it would slow down the query. But while the plugin can detect how wide the display area is, it doesn't know how wide your collumns are. So this number represents the average amount of space (in characters) duckdb.yazi expects each column to take up when deciding how many columns to request. columns\_displayed = display\_area\_width / column\_fit_factor. So larger number = fewer columns, smaller number = more columns. Ideally you want the columns to **just** spill over the right border of the screen which will give the feeling of movement when scrolling. The default - 10.0 - should accommodate most column sizes while giving good performance. Setting to 7.73 should display even the narrowest columns correctly, but may cause queries to be slightly slower when working with very large numbers of columns.

### Configuring duckdb

[](https://github.com/wylie102/duckdb.yazi#configuring-duckdb)

Configuration of DuckDB can be done in the `~/.duckdbrc` file. This should be placed in your home directory ([duckdb docs](https://duckdb.org/docs/stable/operations_manual/footprint_of_duckdb/files_created_by_duckdb)).

You can customise the colors of the preview using the following options

```
.highlight_colors layout gray 
.highlight_colors column_name magenta bold
.highlight_colors column_type gray
.highlight_colors string_value cyan
.highlight_colors numeric_value green
.highlight_colors temporal_value blue
.highlight_colors footer gray
```

The above configuration is what is used in the video at the top of the readme and in the screenshots of the color highlithing section. Although the actual colours will depend on your terminal/yazi color scheme. These should be placed in your `~./duckdbrc` file as is. No header is needed, they are simply commands run on the startup of any duckdb instance (when using the CLI). These will change the color of the output in both duckdb.yazi and when using it in the CLI.

Color options are: red|green|yellow|blue|magenta|cyan|white

You can also specify bold, underline or bold_underline after the colors e.g. `.highlight_colors column_type red bold_underline`

If the file is empty or doesn't exist then the default duckdb color scheme will be used This uses gray for borders and NULLs and looks like this

[![Screenshot 2025-04-02 at 14 53 38](https://private-user-images.githubusercontent.com/107398362/429513804-d2267298-b91b-496c-ae74-1d432b826f6f.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEzODA0LWQyMjY3Mjk4LWI5MWItNDk2Yy1hZTc0LTFkNDMyYjgyNmY2Zi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iNjA5YmVjYWI2ZWEyY2ZkMWVkOGE2MzJhZTI1MzU2NDQzZmJiNTc5NGM4ZGJkZjA5M2UwODU3M2Y1NGZlODZiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.hdnd9SC54uB0EFF3TswPsA2C03Yr_zTAWIGtVXGUAQ4)](https://private-user-images.githubusercontent.com/107398362/429513804-d2267298-b91b-496c-ae74-1d432b826f6f.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI5NTEzODA0LWQyMjY3Mjk4LWI5MWItNDk2Yy1hZTc0LTFkNDMyYjgyNmY2Zi5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1iNjA5YmVjYWI2ZWEyY2ZkMWVkOGE2MzJhZTI1MzU2NDQzZmJiNTc5NGM4ZGJkZjA5M2UwODU3M2Y1NGZlODZiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.hdnd9SC54uB0EFF3TswPsA2C03Yr_zTAWIGtVXGUAQ4)

You can also turn the highlighting off by adding `.highlight_results off` In which case it will look like below.

[![Screenshot 2025-03-22 at 18 00 06](https://private-user-images.githubusercontent.com/107398362/425768743-db09fff9-2db1-4273-9ddf-34d0bf087967.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI1NzY4NzQzLWRiMDlmZmY5LTJkYjEtNDI3My05ZGRmLTM0ZDBiZjA4Nzk2Ny5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT05OGFkY2Y5MzZkN2VjZTFiMDY3ODAwMjRlOTBmMzA2YmY0Yzc2YzQwODg3YjZjZmJiZjFlZTZjOTM4NTg2MjA2JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.bu0_f2QykeUZXhCk54FR3dCRqMKZQSm7hkJHKa6OQQo)](https://private-user-images.githubusercontent.com/107398362/425768743-db09fff9-2db1-4273-9ddf-34d0bf087967.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTc2NzY2NDEsIm5iZiI6MTc1NzY3NjM0MSwicGF0aCI6Ii8xMDczOTgzNjIvNDI1NzY4NzQzLWRiMDlmZmY5LTJkYjEtNDI3My05ZGRmLTM0ZDBiZjA4Nzk2Ny5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwOTEyJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDkxMlQxMTI1NDFaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT05OGFkY2Y5MzZkN2VjZTFiMDY3ODAwMjRlOTBmMzA2YmY0Yzc2YzQwODg3YjZjZmJiZjFlZTZjOTM4NTg2MjA2JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.bu0_f2QykeUZXhCk54FR3dCRqMKZQSm7hkJHKa6OQQo)

More information [here](https://duckdb.org/docs/stable/clients/cli/dot_commands#configuring-the-result-syntax-highlighter)

  
  

## Setup and usage changes from previous versions

[](https://github.com/wylie102/duckdb.yazi#setup-and-usage-changes-from-previous-versions)

### A Note on the Latest update

[](https://github.com/wylie102/duckdb.yazi#a-note-on-the-latest-update)Added logic for reading `.xlsx` and `.txt` files, you can just add these to your yazi.toml file to be able to view them. Also added the ability to set the cache row size in the yazi.toml file.
