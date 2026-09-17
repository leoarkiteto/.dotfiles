-- =====================================================
-- Coverage Report Functions
-- =====================================================

--- Generate Go coverage file then open HTML report
local function handle_go_coverage()
  local project_root = vim.fn.getcwd()
  vim.notify("Generating Go coverage report...", vim.log.levels.INFO)

  vim.fn.jobstart("go test -coverprofile=coverage.out ./...", {
    cwd = project_root,
    on_exit = function(_, _)
      vim.schedule(function()
        local coverage_file = vim.fs.joinpath(project_root, "coverage.out")
        if vim.fn.filereadable(coverage_file) == 0 then
          vim.notify("Failed to generate Go coverage file", vim.log.levels.ERROR)
          return
        end
        vim.fn.jobstart("go tool cover -html=coverage.out", {
          cwd = project_root,
          on_exit = function(_, cover_exit_code)
            vim.schedule(function()
              if cover_exit_code ~= 0 then
                vim.notify("Failed to open Go coverage report", vim.log.levels.ERROR)
              else
                vim.notify("Go coverage report opened", vim.log.levels.INFO)
              end
            end)
          end,
        })
      end)
    end,
  })
end

--- Handle test coverage based on current file type
local function handle_test_coverage()
  local file_type = vim.bo.filetype

  if file_type == "go" then
    handle_go_coverage()
  else
    vim.notify("Test coverage not supported for filetype: " .. file_type, vim.log.levels.WARN)
  end
end

-- =====================================================
-- Neotest Fast Event Fix
-- =====================================================

-- Patch vim.api.nvim_create_user_autocmd to handle event context errors
local function patch_autocmd_for_fast_events()
  -- Store the original function
  local original_create_autocmd = vim.api.nvim_create_autocmd

  -- Create a wrapped version that handles fast event errors
  vim.api.nvim_create_autocmd = function(event, opts)
    local success, result = pcall(original_create_autocmd, event, opts)

    if not success and result:match("e5560.*fast event context") then
      -- If we get the fast event error, schedule it for later
      vim.schedule(function()
        pcall(original_create_autocmd, event, opts)
      end)
      -- Return a dummy autocmd ID to prevent further errors
      return -1
    elseif success then
      return result
    else
      -- Re-throw other errors
      error(result)
    end
  end
end

-- =====================================================
-- Main Plugin configuration
-- =====================================================

return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "fredrikaverpil/neotest-golang",
  },
  -- LazyVim: Define commands for lazy loading
  cmd = { "Neotest" },
  -- LazyVim: Define keymaps in plugin spec for better integration
  keys = {
    { "<leader>tc", "<cmd>TestCoverage<cr>", desc = "Show test coverage" },
  },
  init = function()
    -- Apply the patch before neotest loads
    patch_autocmd_for_fast_events()
  end,
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}

    -- Go adapter configuration
    table.insert(opts.adapters, require("neotest-golang")())

    -- Setup coverage command with scheduled execution to avoid fast events
    vim.schedule(function()
      vim.api.nvim_create_user_command("TestCoverage", function()
        vim.schedule(function()
          handle_test_coverage()
        end)
      end, { desc = "Open test coverage report" })
    end)

    return opts
  end,
}
