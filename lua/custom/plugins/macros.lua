-- Vim macros plugin
-- This plugin allows you to save macros for later use

return {
  -- This is a proper lazy.nvim plugin spec
  'nvim-lua/plenary.nvim', -- Using plenary as a dependency
  dependencies = {
    'nvim-lua/plenary.nvim', -- Add any other dependencies here if needed
  },
  config = function()
    -- Define your macros here with structured format:
    -- { content = "macro content", register = "register letter", desc = "description", key = "optional keybinding suffix" }
    local macros = {
      -- JavaScript macros
      javascript_arrow_function = {
        content = 'oconst FUNCTION_NAME = () => {}\27FFciw',
        register = 'a',
        desc = 'Create JavaScript arrow function',
        key = 'a',
      },
      javascript_function = {
        content = 'ofunction FUNCTION() {}\27FFciw',
        register = 'f',
        desc = 'Create JavaScript function',
        key = 'f',
      },
      -- Add more macros here with the same structure
    }

    -- Function to load a saved macro into a register
    local function load_macro(register, macro_content)
      vim.fn.setreg(register, macro_content)
    end

    -- Load all defined macros into registers
    for name, macro in pairs(macros) do
      load_macro(macro.register, macro.content)
    end

    -- Create a command to list all available macros
    vim.api.nvim_create_user_command('Macros', function()
      local lines = { 'Available macros:' }

      -- Get maximum name length for padding
      local max_name_len = 0
      for name, _ in pairs(macros) do
        max_name_len = math.max(max_name_len, #name)
      end

      -- Build formatted list
      for name, macro in pairs(macros) do
        local keybind = ''
        if macro.key then
          keybind = string.format(' (<leader>m%s)', macro.key)
        end

        table.insert(lines, string.format('@%s - %-' .. max_name_len .. 's %s%s', macro.register, name, macro.desc or '', keybind))
      end

      vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
    end, {})

    -- Create a command to save a macro from a register to your macros.lua file
    vim.api.nvim_create_user_command('SaveMacro', function(opts)
      local args = vim.split(opts.args, ' ')
      if #args < 3 then
        vim.notify('Usage: SaveMacro [register] [name] [description]', vim.log.levels.ERROR)
        return
      end

      local register = args[1]
      local name = args[2]
      local desc = table.concat({ unpack(args, 3) }, ' ')

      -- Get the macro content from the register
      local macro_content = vim.fn.getreg(register)

      -- Get the path to this file
      local filepath = debug.getinfo(1, 'S').source:sub(2)

      -- Read the file content
      local file = io.open(filepath, 'r')
      if not file then
        vim.notify('Could not open macros file', vim.log.levels.ERROR)
        return
      end

      local content = file:read '*all'
      file:close()

      -- Prepare the new macro line
      local new_macro_line = string.format(
        [[      %s = {
        content = '%s',
        register = '%s',
        desc = '%s',
        key = '%s',
      },
]],
        name,
        macro_content:gsub("'", "\\'"),
        register,
        desc,
        register:lower()
      )

      -- Find the right spot to insert the new macro
      local macros_end = content:find('      -- Add more macros here', 1, true)
      if not macros_end then
        macros_end = content:find('    }', 1, true)
      end

      if not macros_end then
        vim.notify('Could not find the right spot to insert the macro', vim.log.levels.ERROR)
        return
      end

      -- Insert the new macro line before the end of the macros table
      local new_content = content:sub(1, macros_end - 1) .. new_macro_line .. content:sub(macros_end)

      -- Write the updated content back to the file
      file = io.open(filepath, 'w')
      if not file then
        vim.notify('Could not open macros file for writing', vim.log.levels.ERROR)
        return
      end

      file:write(new_content)
      file:close()

      vim.notify(string.format("Macro '@%s' saved as '%s'", register, name), vim.log.levels.INFO)
    end, { nargs = '+' })

    -- Add keymaps for managing macros
    vim.keymap.set('n', '<leader>ml', '<cmd>Macros<CR>', { desc = 'List all saved macros' })

    -- Add keybindings for all macros that have a key defined
    for name, macro in pairs(macros) do
      if macro.key then
        vim.keymap.set('n', '<leader>m' .. macro.key, '@' .. macro.register, { desc = macro.desc or name })
      end
    end
  end,
}
