require("nvim-tree").setup({
   disable_netrw = true,
   actions = {
      change_dir = {
         restrict_above_cwd = true,
      },
   },
})
