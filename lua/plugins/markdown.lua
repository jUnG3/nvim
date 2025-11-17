-- lua/plugins/markdown.lua

return {
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
  },

  { "mracos/mermaid.vim" },

  { "aklt/plantuml-syntax" },

  {
    "weirongxu/plantuml-previewer.vim",
    dependencies = { "tyru/open-browser.vim" },
  },

  { "tyru/open-browser.vim" },
}
