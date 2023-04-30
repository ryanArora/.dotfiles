require("mason").setup({})
require("mason-lspconfig").setup({
   ensure_installed = {},
   automatic_installation = true,
})

local cmp = require("cmp")

cmp.setup({
   snippet = {
      expand = function(args)
         require("luasnip").lsp_expand(args.body)
      end,
   },
   window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
   },
   mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
   }),
   sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
   }, {}),
   formatting = {
      format = require("lspkind").cmp_format({
         mode = "symbol_text", -- show only symbol annotations
         maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
         ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      }),
   },
})

require("neodev").setup({
   library = { plugins = { "nvim-dap-ui" }, types = true },
})

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
   settings = {
      Lua = {
         completion = {
            callSnippet = "Replace",
         },
         workspace = {
            checkThirdParty = false,
         },
      },
   },
})

lspconfig.tsserver.setup({})

lspconfig.eslint.setup({})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("lspconfig").jsonls.setup({
   capabilities = capabilities,
})

require("luasnip.loaders.from_vscode").lazy_load()

require("mason-null-ls").setup({
   ensure_installed = {
      "stylua",
      "prettier",
      "black",
   },
   automatic_installation = false,
   handlers = {},
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
require("null-ls").setup({
   sources = {},
   on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
         vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
         vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
               vim.lsp.buf.format({ bufnr = bufnr })
            end,
         })
      end
   end,
})

lspconfig.eslint.setup({
   on_attach = function(client)
      local group = vim.api.nvim_create_augroup("Eslint", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
         group = group,
         pattern = "<buffer>",
         command = "EslintFixAll",
         desc = "Run eslint when saving buffer.",
      })
   end,
   capabilities = capabilities, -- declared elsewhere
})

require("mason-nvim-dap").setup({
   ensure_installed = { "python" },
   handlers = {},
})

require("dapui").setup()

vim.diagnostic.config({
   underline = {
      severity = { max = vim.diagnostic.severity.WARN },
   },
   virtual_text = {
      severity = { min = vim.diagnostic.severity.WARN },
   },
})
