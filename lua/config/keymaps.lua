-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<leader>gg", "<cmd>ToggleGStatus<cr>", { desc = "Git Status (toggle)" })
map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git Status" })
map("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git Blame" })
map("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git Push" })
map("n", "<F3>", "<cmd>ToggleGit<cr>", { desc = "Git Status (toggle)" })

map("n", "<leader>ghl", function()
  Snacks.picker.git_log_line()
end, { desc = "Git Line History" })
