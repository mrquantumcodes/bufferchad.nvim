-- Interactive fuzzy picker with preview
local fuzzy = require('bufferchad.fuzzy')
local preview = require('bufferchad.preview')
local ui = require('bufferchad.ui')

local M = {}

-- Active picker state
M.state = {
	items = {},
	filtered_items = {},
	current_query = "",
	selected_index = 1,
	prompt_bufnr = nil,
	prompt_winid = nil,
	results_bufnr = nil,
	results_winid = nil,
	preview_bufnr = nil,
	preview_winid = nil,
	on_select = nil,
	opts = {},
}

-- Update the filtered results based on current query
local function update_results()
	local query = M.state.current_query

	-- Filter items using fuzzy matching
	M.state.filtered_items = fuzzy.filter(M.state.items, query)

	-- Update results window
	ui.update_results(M.state.results_bufnr, M.state.filtered_items, M.state.opts.show_icons)

	-- Reset selection to first item
	M.state.selected_index = 1

	-- Update cursor position in results window
	if M.state.results_winid and vim.api.nvim_win_is_valid(M.state.results_winid) then
		vim.api.nvim_win_set_cursor(M.state.results_winid, {1, 0})
	end

	-- Update preview
	if M.state.opts.show_preview and #M.state.filtered_items > 0 then
		local selected_item = M.state.filtered_items[M.state.selected_index]
		if selected_item then
			preview.update_preview(M.state.preview_bufnr, selected_item.text, M.state.opts.preview_lines or 10)
		end
	end
end

-- Move selection up/down
local function move_selection(direction)
	if #M.state.filtered_items == 0 then
		return
	end

	local new_index = M.state.selected_index + direction

	-- Wrap around
	if new_index < 1 then
		new_index = #M.state.filtered_items
	elseif new_index > #M.state.filtered_items then
		new_index = 1
	end

	M.state.selected_index = new_index

	-- Update cursor in results window
	if M.state.results_winid and vim.api.nvim_win_is_valid(M.state.results_winid) then
		vim.api.nvim_win_set_cursor(M.state.results_winid, {new_index, 0})
	end

	-- Update preview
	if M.state.opts.show_preview then
		local selected_item = M.state.filtered_items[M.state.selected_index]
		if selected_item then
			preview.update_preview(M.state.preview_bufnr, selected_item.text, M.state.opts.preview_lines or 10)
		end
	end
end

-- Close the picker
local function close_picker()
	-- Close all windows
	if M.state.prompt_winid and vim.api.nvim_win_is_valid(M.state.prompt_winid) then
		vim.api.nvim_win_close(M.state.prompt_winid, true)
	end

	if M.state.results_winid and vim.api.nvim_win_is_valid(M.state.results_winid) then
		vim.api.nvim_win_close(M.state.results_winid, true)
	end

	if M.state.preview_winid and vim.api.nvim_win_is_valid(M.state.preview_winid) then
		vim.api.nvim_win_close(M.state.preview_winid, true)
	end

	-- Clear state
	M.state = {
		items = {},
		filtered_items = {},
		current_query = "",
		selected_index = 1,
		prompt_bufnr = nil,
		prompt_winid = nil,
		results_bufnr = nil,
		results_winid = nil,
		preview_bufnr = nil,
		preview_winid = nil,
		on_select = nil,
		opts = {},
	}
end

-- Select current item
local function select_item()
	if #M.state.filtered_items == 0 then
		close_picker()
		return
	end

	local selected_item = M.state.filtered_items[M.state.selected_index]

	if selected_item and M.state.on_select then
		close_picker()
		M.state.on_select(selected_item.text)
	end
end

-- Setup keymaps for the picker
local function setup_keymaps()
	local prompt_bufnr = M.state.prompt_bufnr

	-- Escape to close
	vim.keymap.set({'n', 'i'}, '<Esc>', function()
		close_picker()
	end, { buffer = prompt_bufnr, silent = true })

	-- Ctrl-C to close
	vim.keymap.set({'n', 'i'}, '<C-c>', function()
		close_picker()
	end, { buffer = prompt_bufnr, silent = true })

	-- Enter to select
	vim.keymap.set({'n', 'i'}, '<CR>', function()
		select_item()
	end, { buffer = prompt_bufnr, silent = true })

	-- Navigation
	vim.keymap.set('i', '<C-n>', function()
		move_selection(1)
	end, { buffer = prompt_bufnr, silent = true })

	vim.keymap.set('i', '<C-p>', function()
		move_selection(-1)
	end, { buffer = prompt_bufnr, silent = true })

	vim.keymap.set('i', '<Down>', function()
		move_selection(1)
	end, { buffer = prompt_bufnr, silent = true })

	vim.keymap.set('i', '<Up>', function()
		move_selection(-1)
	end, { buffer = prompt_bufnr, silent = true })

	-- Results window navigation (when focused)
	if M.state.results_bufnr then
		vim.keymap.set('n', 'j', function()
			move_selection(1)
		end, { buffer = M.state.results_bufnr, silent = true })

		vim.keymap.set('n', 'k', function()
			move_selection(-1)
		end, { buffer = M.state.results_bufnr, silent = true })

		vim.keymap.set('n', '<CR>', function()
			select_item()
		end, { buffer = M.state.results_bufnr, silent = true })

		vim.keymap.set('n', '<Esc>', function()
			close_picker()
		end, { buffer = M.state.results_bufnr, silent = true })
	end
end

-- Setup prompt callback for live filtering
local function setup_prompt_callback()
	vim.fn.prompt_setcallback(M.state.prompt_bufnr, function(text)
		-- This is called on <CR>, but we handle it differently
	end)

	-- Setup autocmd for text changes
	vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
		buffer = M.state.prompt_bufnr,
		callback = function()
			-- Get current line text (skip the prompt prefix "> ")
			local line = vim.api.nvim_buf_get_lines(M.state.prompt_bufnr, 0, 1, false)[1]
			local query = line:sub(3)  -- Skip "> "

			if query ~= M.state.current_query then
				M.state.current_query = query
				update_results()
			end
		end,
	})
end

-- Open the fuzzy picker
-- items: array of strings to pick from
-- opts: {
--   title: string,
--   show_preview: boolean,
--   show_icons: boolean,
--   preview_lines: number,
-- }
-- on_select: callback function(selected_string)
function M.open(items, opts, on_select)
	opts = opts or {}

	-- Initialize state
	M.state.items = items
	M.state.filtered_items = fuzzy.filter(items, "")
	M.state.current_query = ""
	M.state.selected_index = 1
	M.state.on_select = on_select
	M.state.opts = opts

	-- Setup highlights
	ui.setup_highlights()

	-- Calculate window positions
	local width = opts.width or 80
	local height = opts.height or 20
	local preview_width = opts.preview_width or 60

	local editor_width = vim.o.columns
	local editor_height = vim.o.lines

	-- Center the main picker
	local col = math.floor((editor_width - width) / 2)
	local row = math.floor((editor_height - height) / 2)

	-- Create prompt window
	M.state.prompt_bufnr, M.state.prompt_winid = ui.create_prompt_window({
		width = width,
		row = row,
		col = col,
		title = opts.title or ' Search ',
	})

	-- Create results window (below prompt)
	M.state.results_bufnr, M.state.results_winid = ui.create_results_window({
		width = width,
		height = height - 3,
		row = row + 3,
		col = col,
		title = ' Results ',
	})

	-- Create preview window (to the right) if enabled
	if opts.show_preview ~= false then
		M.state.preview_bufnr, M.state.preview_winid = preview.create_preview_window({
			width = preview_width,
			height = height,
			row = row,
			col = col + width + 2,
			title = ' Preview ',
		})
	end

	-- Setup keymaps
	setup_keymaps()

	-- Setup prompt callback
	setup_prompt_callback()

	-- Initial results display
	update_results()

	-- Focus prompt window and enter insert mode
	vim.api.nvim_set_current_win(M.state.prompt_winid)
	vim.cmd('startinsert!')
end

return M
