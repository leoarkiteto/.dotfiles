return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI (deferred to avoid E565 error)
      vim.schedule(function()
        dapui.setup()
      end)

      -- Setup nvim-dap-go
      require("dap-go").setup()

      -- Configure debug icons/signs using Nerd Font glyphs (consistent with mini.icons style)
      local icons = {
        breakpoint = "",
        breakpoint_condition = "",
        breakpoint_rejected = "",
        log_point = "",
        stopped = "",
      }

      vim.fn.sign_define("DapBreakpoint", {
        text = icons.breakpoint,
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointCondition", {
        text = icons.breakpoint_condition,
        texthl = "DiagnosticSignWarn",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = icons.breakpoint_rejected,
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = icons.log_point,
        texthl = "DiagnosticSignInfo",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = icons.stopped,
        texthl = "DiagnosticSignWarn",
        linehl = "",
        numhl = "",
      })

      -- Define highlight group for stopped line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#555530" })

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
