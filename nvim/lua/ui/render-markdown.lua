return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  opts = {
    -- Disable LaTeX rendering to avoid ENOENT errors when latex2text is not installed
    latex = {
      enabled = true,
    },
    -- Keep other features enabled
    heading = {
      enabled = true,
    },
    code = {
      enabled = true,
    },
    bullet = {
      enabled = true,
    },
    checkbox = {
      enabled = true,
    },
    quote = {
      enabled = true,
    },
    pipe_table = {
      enabled = true,
    },
    link = {
      enabled = true,
    },
  },
}
