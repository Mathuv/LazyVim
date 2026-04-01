local function fail(message)
  error(message, 0)
end

local function assert_true(value, message)
  if not value then
    fail(message)
  end
end

local function command_exists(name)
  return vim.fn.exists(":" .. name) == 2
end

local function get_map(lhs)
  local map = vim.fn.maparg(lhs, "n", false, true)
  if vim.tbl_isempty(map) then
    return nil
  end
  return map
end

local function assert_string_map(lhs, rhs, desc)
  local map = get_map(lhs)
  assert_true(map ~= nil, ("missing mapping for %s"):format(lhs))
  assert_true(map.rhs == rhs, ("unexpected rhs for %s: %s"):format(lhs, vim.inspect(map.rhs)))
  assert_true(map.desc == desc, ("unexpected desc for %s: %s"):format(lhs, vim.inspect(map.desc)))
end

local function assert_callback_map(lhs, desc)
  local map = get_map(lhs)
  assert_true(map ~= nil, ("missing mapping for %s"):format(lhs))
  assert_true(type(map.callback) == "function", ("expected callback mapping for %s"):format(lhs))
  assert_true(map.desc == desc, ("unexpected desc for %s: %s"):format(lhs, vim.inspect(map.desc)))
end

local function find_fugitive_status_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.bo[buf].filetype
    local name = vim.api.nvim_buf_get_name(buf)
    if filetype == "fugitive" and name:match("^fugitive://.*//$") then
      return win
    end
  end
end

vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })

assert_true(command_exists("ToggleGStatus"), "ToggleGStatus command is missing")
assert_true(command_exists("ToggleGit"), "ToggleGit command is missing")
assert_true(command_exists("GBrowseAtLine"), "GBrowseAtLine command is missing")
assert_true(command_exists("GBrowseBlame"), "GBrowseBlame command is missing")

assert_string_map("<leader>gg", "<cmd>ToggleGStatus<cr>", "Git Status (toggle)")
assert_string_map("<leader>gs", "<cmd>Git<cr>", "Git Status")
assert_string_map("<leader>gb", "<cmd>Git blame<cr>", "Git Blame")
assert_string_map("<leader>gp", "<cmd>Git push<cr>", "Git Push")
assert_string_map("<F3>", "<cmd>ToggleGit<cr>", "Git Status (toggle)")
assert_callback_map("<leader>gG", "Lazygit (cwd)")
assert_callback_map("<leader>ghl", "Git Line History")

vim.cmd("edit lua/config/lazy.lua")
vim.cmd("ToggleGStatus")

local fugitive_win = find_fugitive_status_win()
assert_true(fugitive_win ~= nil, "ToggleGStatus did not open a Fugitive status window")

local fugitive_row = vim.api.nvim_win_get_position(fugitive_win)[1]
local current_row = vim.api.nvim_win_get_position(vim.fn.win_getid(vim.fn.winnr("#")))[1]
assert_true(fugitive_row < current_row, "ToggleGStatus did not open Fugitive above the current window")

vim.cmd("ToggleGStatus")
assert_true(find_fugitive_status_win() == nil, "ToggleGStatus did not close the Fugitive status window")
