return {
  "xemptuous/sqlua.nvim",
  lazy = true,
  cmd = "SQLua",
  opts = {

    -- the parent folder that databases will be placed, holding
    -- various tmp files and other saved queries.
    db_save_location = "~/.core/.sys/env/db/sqlua",
    -- where to save the json config containing connection information
    connections_save_location = "~/.core/.sys/env/db/sqlua/connections.json",
    -- the default limit attached to queries
    -- currently only works on "Data" command under a table
    default_limit = 200,
    -- whether to introspect the database on SQLua open or when first expanded
    -- through the sidebar
    load_connections_on_start = false,
    keybinds = {
      execute_query = "<leader>r",
      activate_db = "<C-a>",

      -- Execute query (just like keybinds.execute_query) while in insert mode for query
      insert_execute_query = "<C-r>",
    },
  },
}

-- POSTGRESQL
-- {
--     "name": "mydb",
--     "url": "postgres://admin:pass@localhost:5432/mydb"
-- }
-- SQLITE
--{
--     "name": "mydb",
--     "url": "/path/to/database/file.db"
-- }
