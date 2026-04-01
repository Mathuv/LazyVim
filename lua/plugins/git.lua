return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    dependencies = { "tpope/vim-rhubarb" },
    config = function()
      local group = vim.api.nvim_create_augroup("user_fugitive", { clear = true })

      local function is_fugitive_status_buf(buf)
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        if vim.bo[buf].filetype ~= "fugitive" then
          return false
        end
        local name = vim.api.nvim_buf_get_name(buf)
        return name:match("^fugitive://.*%.git//$") ~= nil
      end

      local function open_fugitive_status(height)
        vim.cmd("Git")
        if height then
          pcall(vim.api.nvim_win_set_height, 0, height)
        end
      end

      local function close_visible_fugitive_status()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if is_fugitive_status_buf(buf) then
            vim.api.nvim_win_close(win, true)
            return true
          end
        end
        return false
      end

      local function close_hidden_fugitive_status()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if is_fugitive_status_buf(buf) then
            vim.api.nvim_buf_delete(buf, {})
            return true
          end
        end
        return false
      end

      local function toggle_fugitive_status()
        if close_visible_fugitive_status() then
          return
        end
        if close_hidden_fugitive_status() then
          return
        end
        open_fugitive_status(15)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "fugitive",
        callback = function()
          vim.opt_local.winfixheight = true
        end,
      })

      vim.api.nvim_create_user_command("ToggleGStatus", toggle_fugitive_status, {})
      vim.api.nvim_create_user_command("ToggleGit", toggle_fugitive_status, {})

      vim.api.nvim_create_user_command("GBrowseAtLine", function(opts)
        local line = vim.api.nvim_win_get_cursor(0)[1]
        vim.cmd(("%dGBrowse%s"):format(line, opts.bang and "!" or ""))
      end, { bang = true })

      local function gbrowse_url()
        local ok, output = pcall(vim.fn.execute, "silent GBrowse!")
        if not ok then
          local message = vim.trim(tostring(output):gsub("^Vim%([^)]*%):", ""))
          return nil, message ~= "" and message or "GBrowse failed"
        end

        local url = ""

        for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
          line = vim.trim(line)
          if line:match("^https?://") then
            url = line
          end
        end

        if url == "" then
          return nil, "GBrowse did not return a URL"
        end

        return url
      end

      vim.api.nvim_create_user_command("GBrowseBlame", function(opts)
        if vim.fn.exists(":GBrowse") ~= 2 then
          vim.notify("GBrowse is unavailable", vim.log.levels.ERROR)
          return
        end

        local url, err = gbrowse_url()
        if not url then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end

        url = url:gsub("/blob/", "/blame/")
        if opts.line1 ~= opts.line2 then
          url = ("%s#L%d-L%d"):format(url, opts.line1, opts.line2)
        else
          url = ("%s#L%d"):format(url, opts.line1)
        end

        if vim.ui.open then
          vim.ui.open(url)
        elseif vim.fn.has("macunix") == 1 and vim.fn.executable("open") == 1 then
          vim.fn.jobstart({ "open", url }, { detach = true })
        elseif vim.fn.executable("xdg-open") == 1 then
          vim.fn.jobstart({ "xdg-open", url }, { detach = true })
        else
          vim.notify("No URL opener available", vim.log.levels.ERROR)
        end
      end, { range = true, addr = "lines" })
    end,
  },
}
