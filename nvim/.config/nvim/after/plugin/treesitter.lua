require("nvim-treesitter.configs").setup({
   ensure_installed = { "lua", "typescript", "tsx" },
   auto_install = false,
   highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
   },
   indent = {
      enable = true,
   },
   autotag = {
      enable = true,
   },
})
