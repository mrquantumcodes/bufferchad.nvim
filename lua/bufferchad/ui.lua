-- Modern UI renderer with icons and highlights
local M = {}

-- Check if devicons is available
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

-- Get file icon and color
function M.get_icon(filename)
	if not has_devicons then
		return "", nil
	end

	local extension = filename:match("^.+%.(.+)$") or ""
	local icon, color = devicons.get_icon_color(filename, extension, { default = true })
	return icon or "", color
end

-- Apply fuzzy match highlights
-- bufnr: buffer number
-- line_nr: line number (1-indexed)
-- positions: array of character positions to highlight
-- offset: column offset to start highlighting from
function M.apply_fuzzy_highlights(bufnr, line_nr, positions, offset)
	offset = offset or 0

	-- Create highlight group for fuzzy matches if it doesn't exist
	vim.api.nvim_set_hl(0, 'BufferChadFuzzyMatch', {
		fg = '#ff9e64',  -- orange
		bold = true,
		default = true
	})

	for _, pos in ipairs(positions) do
		-- Add highlight at this position
		vim.api.nvim_buf_add_highlight(
			bufnr,
			-1,  -- namespace
			'BufferChadFuzzyMatch',
			line_nr - 1,  -- 0-indexed line
			offset + pos - 1,  -- 0-indexed column
			offset + pos  -- end column
		)
	end
end

-- Format a buffer line with icon and highlights
-- item: {text, score, positions}
-- line_nr: line number in the display buffer
-- bufnr: the display buffer number
-- Returns: formatted string
function M.format_buffer_line(item, line_nr, bufnr, show_icons)
	local text = item.text
	local icon, icon_color = "", nil

	if show_icons ~= false then
		icon, icon_color = M.get_icon(text)
		if icon ~= "" then
			icon = icon .. " "
		end
	end

	local formatted = icon .. text

	-- Apply icon color highlight if available
	if icon_color and icon ~= "" then
		-- Create a unique highlight group for this icon color
		local hl_group = 'BufferChadIcon_' .. icon_color:gsub('#', '')
		vim.api.nvim_set_hl(0, hl_group, { fg = icon_color, default = true })

		-- Highlight the icon
		vim.api.nvim_buf_add_highlight(
			bufnr,
			-1,
			hl_group,
			line_nr - 1,
			0,
			#icon
		)
	end

	-- Apply fuzzy match highlights (offset by icon length)
	if item.positions and #item.positions > 0 then
		M.apply_fuzzy_highlights(bufnr, line_nr, item.positions, #icon)
	end

	return formatted
end

-- Create custom highlight groups for BufferChad
function M.setup_highlights()
	-- Fuzzy match highlight
	vim.api.nvim_set_hl(0, 'BufferChadFuzzyMatch', {
		fg = '#ff9e64',
		bold = true,
		default = true
	})

	-- Border highlight
	vim.api.nvim_set_hl(0, 'BufferChadBorder', {
		fg = '#7aa2f7',
		default = true
	})

	-- Title highlight
	vim.api.nvim_set_hl(0, 'BufferChadTitle', {
		fg = '#7dcfff',
		bold = true,
		default = true
	})

	-- Prompt highlight
	vim.api.nvim_set_hl(0, 'BufferChadPrompt', {
		fg = '#bb9af7',
		bold = true,
		default = true
	})

	-- Selection highlight
	vim.api.nvim_set_hl(0, 'BufferChadSelection', {
		bg = '#3b4261',
		default = true
	})

	-- Preview border
	vim.api.nvim_set_hl(0, 'BufferChadPreviewBorder', {
		fg = '#9ece6a',
		default = true
	})
end

-- Create a prompt buffer for fuzzy search input
-- Returns: prompt_bufnr, prompt_winid
function M.create_prompt_window(config)
	local prompt_bufnr = vim.api.nvim_create_buf(false, true)

	-- Set buffer options
	vim.api.nvim_buf_set_option(prompt_bufnr, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(prompt_bufnr, 'buftype', 'prompt')
	vim.api.nvim_buf_set_option(prompt_bufnr, 'swapfile', false)

	-- Create prompt window
	local win_config = {
		relative = config.relative or 'editor',
		width = config.width or 60,
		height = 1,
		row = config.row or 5,
		col = config.col or 5,
		style = 'minimal',
		border = config.border or 'rounded',
		title = config.title or ' Search ',
		title_pos = 'center',
	}

	local prompt_winid = vim.api.nvim_open_win(prompt_bufnr, true, win_config)

	-- Set window options
	vim.api.nvim_win_set_option(prompt_winid, 'winhighlight', 'Normal:Normal,FloatBorder:BufferChadBorder,FloatTitle:BufferChadTitle')

	-- Set prompt prefix
	vim.fn.prompt_setprompt(prompt_bufnr, '> ')

	-- Highlight prompt
	vim.api.nvim_buf_add_highlight(prompt_bufnr, -1, 'BufferChadPrompt', 0, 0, 2)

	return prompt_bufnr, prompt_winid
end

-- Create a results window
-- Returns: results_bufnr, results_winid
function M.create_results_window(config)
	local results_bufnr = vim.api.nvim_create_buf(false, true)

	-- Set buffer options
	vim.api.nvim_buf_set_option(results_bufnr, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(results_bufnr, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(results_bufnr, 'swapfile', false)
	vim.api.nvim_buf_set_option(results_bufnr, 'modifiable', false)

	-- Create window
	local win_config = {
		relative = config.relative or 'editor',
		width = config.width or 60,
		height = config.height or 15,
		row = config.row or 7,
		col = config.col or 5,
		style = 'minimal',
		border = config.border or 'rounded',
		title = config.title or ' Buffers ',
		title_pos = 'center',
	}

	local results_winid = vim.api.nvim_open_win(results_bufnr, false, win_config)

	-- Set window options
	vim.api.nvim_win_set_option(results_winid, 'wrap', false)
	vim.api.nvim_win_set_option(results_winid, 'cursorline', true)
	vim.api.nvim_win_set_option(results_winid, 'number', false)
	vim.api.nvim_win_set_option(results_winid, 'relativenumber', false)
	vim.api.nvim_win_set_option(results_winid, 'winhighlight', 'Normal:Normal,FloatBorder:BufferChadBorder,FloatTitle:BufferChadTitle,CursorLine:BufferChadSelection')

	return results_bufnr, results_winid
end

-- Update results window with filtered items
function M.update_results(results_bufnr, filtered_items, show_icons)
	if not results_bufnr or not vim.api.nvim_buf_is_valid(results_bufnr) then
		return
	end

	-- Make buffer modifiable
	vim.api.nvim_buf_set_option(results_bufnr, 'modifiable', true)

	-- Clear existing content
	vim.api.nvim_buf_set_lines(results_bufnr, 0, -1, false, {})

	-- Clear existing highlights
	vim.api.nvim_buf_clear_namespace(results_bufnr, -1, 0, -1)

	if #filtered_items == 0 then
		vim.api.nvim_buf_set_lines(results_bufnr, 0, -1, false, {"  No matches found"})
		vim.api.nvim_buf_set_option(results_bufnr, 'modifiable', false)
		return
	end

	-- Format and add lines
	local lines = {}
	for i, item in ipairs(filtered_items) do
		local formatted = M.format_buffer_line(item, i, results_bufnr, show_icons)
		table.insert(lines, "  " .. formatted)  -- Add padding
	end

	vim.api.nvim_buf_set_lines(results_bufnr, 0, -1, false, lines)

	-- Make buffer non-modifiable
	vim.api.nvim_buf_set_option(results_bufnr, 'modifiable', false)
end

return M
