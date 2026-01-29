return {
  "jakewvincent/mkdnflow.nvim",
  ft = "markdown",
  dependencies = {
    "folke/which-key.nvim",
  },
  opts = {
    modules = {
      bib = true,
      buffers = true,
      conceal = false, -- Disabled: render-markdown.nvim handles concealment
      cursor = true,
      folds = false, -- Disabled: mkdnflow doesn't provide foldexpr, use treesitter
      links = true,
      lists = true,
      maps = false, -- Disable default mappings since you define custom ones
      paths = true,
      tables = true,
      yaml = false,
    },
    filetypes = { md = true, rmd = true, markdown = true },
    create_dirs = true,
    perspective = {
      priority = "first",
      fallback = "current",
      root_tell = false,
      nvim_wd_heel = false,
      update = false,
    },
    wrap = false,
    bib = {
      default_path = nil,
      find_in_root = true,
    },
    silent = false,
    links = {
      style = "markdown",
      name_is_source = false,
      conceal = false,
      context = 0,
      implicit_extension = nil,
      transform_implicit = false,
      transform_explicit = function(text)
        text = text:gsub(" ", "-")
        text = text:lower()
        return text
      end,
    },
    to_do = {
      symbols = { " ", "-", "X" },
      update_parents = true,
      not_started = " ",
      in_progress = "-",
      complete = "X",
    },
    tables = {
      trim_whitespace = true,
      format_on_move = true,
      auto_extend_rows = false,
      auto_extend_cols = false,
    },
    yaml = {
      bib = { override = false },
    },
    mappings = {},
  },
}
