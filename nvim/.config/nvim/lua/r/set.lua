vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.jsx,*.tsx"

vim.g.closetag_filenames = "*.html,*.xhtml,*.jsx,*.tsx"
vim.g.closetag_xhtml_filenames = "*.xhtml,*.jsx,*.tsx"
vim.g.closetag_filetypes = "html,js"
vim.g.closetag_xhtml_filetype = "xhtml,jsx,tsx"
vim.g.closetag_emptyTags_caseSensitive = 1
vim.g.closetag_regions = {
   ["typescript.tsx"] = "jsxRegion,tsxRegion",
   ["javascript.jsx"] = "jsxRegion",
}
vim.g.closetag_shortcut = ">"
vim.g.closetag_enable_react_fragment = 0
