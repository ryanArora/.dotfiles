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

local protocol = require("vim.lsp.protocol")

local DEFAULT_CLIENT_ID = -1
---@private
local function get_client_id(client_id)
   if client_id == nil then
      client_id = DEFAULT_CLIENT_ID
   end

   return client_id
end

---@private
---@param severity lsp.DiagnosticSeverity
local function severity_lsp_to_vim(severity)
   if type(severity) == "string" then
      severity = protocol.DiagnosticSeverity[severity]
   end
   return severity
end

---@private
---@return lsp.DiagnosticSeverity
local function severity_vim_to_lsp(severity)
   if type(severity) == "string" then
      severity = vim.diagnostic.severity[severity]
   end
   return severity
end

---@private
---@return integer
local function line_byte_from_position(lines, lnum, col, offset_encoding)
   if not lines or offset_encoding == "utf-8" then
      return col
   end

   local line = lines[lnum + 1]
   local ok, result = pcall(vim.str_byteindex, line, col, offset_encoding == "utf-16")
   if ok then
      return result
   end

   return col
end

---@private
local function get_buf_lines(bufnr)
   if vim.api.nvim_buf_is_loaded(bufnr) then
      return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
   end

   local filename = vim.api.nvim_buf_get_name(bufnr)
   local f = io.open(filename)
   if not f then
      return
   end

   local content = f:read("*a")
   if not content then
      -- Some LSP servers report diagnostics at a directory level, in which case
      -- io.read() returns nil
      f:close()
      return
   end

   local lines = vim.split(content, "\n")
   f:close()
   return lines
end

--- @private
--- @param diagnostic lsp.Diagnostic
--- @param client_id integer
--- @return table?
local function tags_lsp_to_vim(diagnostic, client_id)
   local tags ---@type table?
   for _, tag in ipairs(diagnostic.tags or {}) do
      if tag == protocol.DiagnosticTag.Unnecessary then
         tags = tags or {}
         tags.unnecessary = true
      elseif tag == protocol.DiagnosticTag.Deprecated then
         tags = tags or {}
         tags.deprecated = true
      else
         vim.notify_once(
            string.format("Unknown DiagnosticTag %d from LSP client %d", tag, client_id),
            vim.log.levels.WARN
         )
      end
   end
   return tags
end

---@private
---@param diagnostics lsp.Diagnostic[]
---@param bufnr integer
---@param client_id integer
---@return Diagnostic[]
local function diagnostic_lsp_to_vim(diagnostics, bufnr, client_id)
   local buf_lines = get_buf_lines(bufnr)
   local client = vim.lsp.get_client_by_id(client_id)
   local offset_encoding = client and client.offset_encoding or "utf-16"
   ---@diagnostic disable-next-line:no-unknown
   return vim.tbl_map(function(diagnostic)
      ---@cast diagnostic lsp.Diagnostic
      local start = diagnostic.range.start
      local _end = diagnostic.range["end"]
      return {
         lnum = start.line,
         col = line_byte_from_position(buf_lines, start.line, start.character, offset_encoding),
         end_lnum = _end.line,
         end_col = line_byte_from_position(buf_lines, _end.line, _end.character, offset_encoding),
         severity = severity_lsp_to_vim(diagnostic.severity),
         message = diagnostic.message,
         source = diagnostic.source,
         code = diagnostic.code,
         _tags = tags_lsp_to_vim(diagnostic, client_id),
         user_data = {
            lsp = {
               -- usage of user_data.lsp.code is deprecated in favor of the top-level code field
               code = diagnostic.code,
               codeDescription = diagnostic.codeDescription,
               relatedInformation = diagnostic.relatedInformation,
               data = diagnostic.data,
            },
         },
      }
   end, diagnostics)
end

--- @private
--- @param diagnostics Diagnostic[]
--- @return lsp.Diagnostic[]
local function diagnostic_vim_to_lsp(diagnostics)
   ---@diagnostic disable-next-line:no-unknown
   return vim.tbl_map(function(diagnostic)
      ---@cast diagnostic Diagnostic
      return vim.tbl_extend("keep", {
         -- "keep" the below fields over any duplicate fields in diagnostic.user_data.lsp
         range = {
            start = {
               line = diagnostic.lnum,
               character = diagnostic.col,
            },
            ["end"] = {
               line = diagnostic.end_lnum,
               character = diagnostic.end_col,
            },
         },
         severity = severity_vim_to_lsp(diagnostic.severity),
         message = diagnostic.message,
         source = diagnostic.source,
         code = diagnostic.code,
      }, diagnostic.user_data and (diagnostic.user_data.lsp or {}) or {})
   end, diagnostics)
end

function on_publish_diagnostics(_, result, ctx, config)
   local client_id = ctx.client_id
   local uri = result.uri
   local fname = vim.uri_to_fname(uri)
   local diagnostics = {}

   for _, diagnostic in ipairs(result.diagnostics) do
      if diagnostic.code ~= 80001 and diagnostic.code ~= 6133 then
         table.insert(diagnostics, diagnostic)
      end
   end

   if #diagnostics == 0 and vim.fn.bufexists(fname) == 0 then
      return
   end
   local bufnr = vim.fn.bufadd(fname)

   if not bufnr then
      return
   end

   client_id = get_client_id(client_id)
   local namespace = vim.lsp.diagnostic.get_namespace(client_id)

   if config then
      for _, opt in pairs(config) do
         if type(opt) == "table" then
            if not opt.severity and opt.severity_limit then
               opt.severity = { min = severity_lsp_to_vim(opt.severity_limit) }
            end
         end
      end

      -- Persist configuration to ensure buffer reloads use the same
      -- configuration. To make lsp.with configuration work (See :help
      -- lsp-handler-configuration)
      vim.diagnostic.config(config, namespace)
   end

   vim.diagnostic.set(namespace, bufnr, diagnostic_lsp_to_vim(diagnostics, bufnr, client_id))
end

lspconfig.tsserver.setup({
   handlers = {
      ["textDocument/publishDiagnostics"] = on_publish_diagnostics,
   },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.jsonls.setup({
   capabilities = capabilities,
})

lspconfig.tailwindcss.setup({})

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
local null_ls = require("null-ls")
null_ls.setup({
   sources = {
      null_ls.builtins.formatting.prismaFmt,
   },
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

lspconfig.svelte.setup({})

lspconfig.prismals.setup({})

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
