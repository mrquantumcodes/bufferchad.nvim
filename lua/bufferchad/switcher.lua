-- VSCode-style Ctrl+Tab buffer switcher
local ui = require('bufferchad.ui')
local preview = require('bufferchad.preview')

local M = {}

-- Active switcher state
M.state = {
	items = {},
	selected_index = 1,
	results_bufnr = nil,
	results_winid = nil,
	preview_bufnr = nil,
	preview_winid = nil,
	opts = {},
}

-- Update the selected item highlight
local function update_selection()
	if not M.state.results_winid or not vim.api.nvim_win_is_valid(M.state.results_winid) then
		return
	end

	-- Move cursor to selected line
	vim.api.nvim_win_set_cursor(M.state.results_winid, {M.state.selected_index, 0})

	-- Update preview if enabled
	if M.state.opts.show_preview and M.state.items[M.state.selected_index] then
		local selected_item = M.state.items[M.state.selected_index]
		preview.update_preview(M.state.preview_bufnr, selected_item, M.state.opts.preview_lines or 10)
	end
end

-- Cycle to next buffer
local function cycle_next()
	M.state.selected_index = M.state.selected_index + 1
	if M.state.selected_index > #M.state.items then
		M.state.selected_index = 1
	end
	update_selection()
end

-- Cycle to previous buffer
local function cycle_prev()
	M.state.selected_index = M.state.selected_index - 1
	if M.state.selected_index < 1 then
		M.state.selected_index = #M.state.items
	end
	update_selection()
end

-- Close the switcher
local function close_switcher()
	-- Close windows
	if M.state.results_winid and vim.api.nvim_win_is_valid(M.state.results_winid) then
		vim.api.nvim_win_close(M.state.results_winid, true)
	end

	if M.state.preview_winid and vim.api.nvim_win_is_valid(M.state.preview_winid) then
		vim.api.nvim_win_close(M.state.preview_winid, true)
	end

	-- Clear state
	M.state = {
		items = {},
		selected_index = 1,
		results_bufnr = nil,
		results_winid = nil,
		preview_bufnr = nil,
		preview_winid = nil,
		opts = {},
	}
end

-- Select current buffer and close
local function select_and_close()
	if #M.state.items == 0 then
		close_switcher()
		return
	end

	local selected_item = M.state.items[M.state.selected_index]
	close_switcher()

	if selected_item and selected_item ~= "" then
		vim.cmd('edit ' .. selected_item)
	end
end

-- Main input loop - waits for Tab/Shift-Tab or exits on any other key
local function input_loop()
	-- Use vim.schedule to avoid blocking
	vim.schedule(function()
		while true do
			-- Get next character (non-blocking with timeout)
			-- Timeout after 50ms to check if windows are still valid
			local ok, char = pcall(vim.fn.getchar, 0)

			if not ok or char == 0 then
				-- No input yet, check if windows are still valid
				if not M.state.results_winid or not vim.api.nvim_win_is_valid(M.state.results_winid) then
					close_switcher()
					return
				end
				-- Small sleep to prevent tight loop
				vim.cmd('sleep 10m')
			elseif char == 9 then
				-- Tab key (ASCII 9) - cycle forward
				cycle_next()
			elseif char == 27 then
				-- Escape key (ASCII 27) - cancel
				close_switcher()
				return
			elseif type(char) == "number" and char > 0 then
				-- Any other key - select and close
				select_and_close()
				return
			end
		end
	end)
end

-- Open the VSCode-style switcher
-- items: array of buffer paths
-- opts: configuration options
function M.open(items, opts)
	opts = opts or {}

	if #items == 0 then
		print("No buffers to switch")
		return
	end

	-- Initialize state
	M.state.items = items
	M.state.selected_index = 1
	M.state.opts = opts

	-- Setup highlights
	ui.setup_highlights()

	-- Calculate window positions
	local editor_width = vim.o.columns
	local editor_height = vim.o.lines

	-- Smaller, centered layout (no search bar needed)
	local total_width = math.floor(editor_width * 0.7)
	local total_height = math.floor(editor_height * 0.6)

	-- Results list takes 35% of width, preview takes 65%
	local results_width = math.floor(total_width * 0.35)
	local preview_width = total_width - results_width - 2

	-- Center everything
	local start_col = math.floor((editor_width - total_width) / 2)
	local start_row = math.floor((editor_height - total_height) / 2)

	-- Create results window (no search bar, so full height)
	M.state.results_bufnr, M.state.results_winid = ui.create_results_window({
		width = results_width,
		height = total_height,
		row = start_row,
		col = start_col,
		title = ' Buffer Switcher ',
	})

	-- Create preview window if enabled
	if opts.show_preview ~= false then
		M.state.preview_bufnr, M.state.preview_winid = preview.create_preview_window({
			width = preview_width,
			height = total_height,
			row = start_row,
			col = start_col + results_width + 2,
			title = ' Preview ',
		})
	end

	-- Format items for display (with icons if enabled)
	local formatted_items = {}
	for _, item in ipairs(items) do
		table.insert(formatted_items, {
			text = item,
			score = 100,
			positions = {}
		})
	end

	-- Update results display
	ui.update_results(M.state.results_bufnr, formatted_items, opts.show_icons ~= false)

	-- Set initial selection
	update_selection()

	-- Setup keymaps for the results window
	if M.state.results_bufnr then
		vim.keymap.set('n', '<Tab>', cycle_next, { buffer = M.state.results_bufnr, silent = true, nowait = true })
		vim.keymap.set('n', '<S-Tab>', cycle_prev, { buffer = M.state.results_bufnr, silent = true, nowait = true })
		vim.keymap.set('n', '<CR>', select_and_close, { buffer = M.state.results_bufnr, silent = true, nowait = true })
		vim.keymap.set('n', '<Esc>', close_switcher, { buffer = M.state.results_bufnr, silent = true, nowait = true })
	end

	-- Focus the results window
	vim.api.nvim_set_current_win(M.state.results_winid)

	-- Start input loop (this will handle Tab cycling and auto-close)
	input_loop()
end

return M
