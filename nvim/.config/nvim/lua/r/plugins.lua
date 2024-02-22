require("r.bootstrap")

require("packer").startup(function(use)
   -- Packer
   use({ "wbthomason/packer.nvim", opt = true })

   -- Appearance
   use({ "nvim-tree/nvim-tree.lua", requires = "nvim-tree/nvim-web-devicons" })
   --use({ "nvim-lualine/lualine.nvim", requires = "nvim-tree/nvim-web-devicons" })
   use("freddiehaddad/feline.nvim")

   -- Tmux
   use("alexghergh/nvim-tmux-navigation")

   -- Treesitter
   use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
   use("nvim-treesitter/playground")

   -- Autopair
   use("windwp/nvim-autopairs")
   use("windwp/nvim-ts-autotag")

   -- LSP
   use("williamboman/mason.nvim")
   use("williamboman/mason-lspconfig.nvim")
   use("folke/neodev.nvim")
   use("neovim/nvim-lspconfig")
   use("hrsh7th/cmp-nvim-lsp")
   use("hrsh7th/nvim-cmp")
   use("onsails/lspkind.nvim")
   use("L3MON4D3/LuaSnip")
   use("saadparwaiz1/cmp_luasnip")
   use("rafamadriz/friendly-snippets")
   use({ "folke/trouble.nvim", requires = "nvim-tree/nvim-web-devicons" })

   -- Formatting
   use({
      "jay-babu/mason-null-ls.nvim",
      requires = {
         "williamboman/mason.nvim",
         { "jose-elias-alvarez/null-ls.nvim", requires = "nvim-lua/plenary.nvim" },
      },
   })

   -- DAP
   use({
      "rcarriga/nvim-dap-ui",
      requires = {
         "jay-babu/mason-nvim-dap.nvim",
         requires = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
         },
      },
   })

   -- Colorscheme
   use("folke/tokyonight.nvim")

   -- Images
   use({
      "samodostal/image.nvim",
      requires = {
         "nvim-lua/plenary.nvim",
         "m00qek/baleia.nvim",
      },
   })

   use({ "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" })

   use({ "lewis6991/gitsigns.nvim" })
end)
