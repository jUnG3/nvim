-- lua/config/plantuml.lua

-- Adjust the path to your local plantuml.jar
vim.g["plantuml_previewer#plantuml_jar_path"] = "/usr/share/plantuml/plantuml.jar"
vim.g["plantuml_previewer#save_format"] = "png"
vim.g["plantuml_previewer#open_cmd"] = "xdg-open"

-- Preview current PlantUML diagram
vim.keymap.set("n", "<leader>up", ":PlantumlOpenCurrent<CR>", { desc = "PlantUML preview" })

-- Filetypes for PlantUML
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.puml", "*.plantuml", "*.iuml" },
  callback = function()
    vim.bo.filetype = "plantuml"
  end,
})

-- Filetypes for Mermaid
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.mmd", "*.mermaid" },
  callback = function()
    vim.bo.filetype = "mermaid"
  end,
})
