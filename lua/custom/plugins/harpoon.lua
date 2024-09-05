return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end)

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      -- quick navigation
      vim.keymap.set('n', '<A-1>', function()
        harpoon:list():select(1)
      end)

      vim.keymap.set('n', '<A-2>', function()
        harpoon:list():select(2)
      end)

      vim.keymap.set('n', '<A-3>', function()
        harpoon:list():select(3)
      end)

      vim.keymap.set('n', '<A-4>', function()
        harpoon:list():select(4)
      end)

      -- toggle previous and next buffers stored within Harpoon list
      vim.keymap.set('n', '<A-n>', function()
        harpoon:list():next()
      end)
      vim.keymap.set('n', '<A-p>', function()
        harpoon:list():prev()
      end)
    end,
  },
}
