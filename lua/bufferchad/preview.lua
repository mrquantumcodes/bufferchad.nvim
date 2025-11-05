-- Buffer preview with syntax highlighting
local M = {}

-- Cache for buffer previews to avoid repeated file reads
M.preview_cache = {}

-- Get preview lines for a file
-- Returns: lines (table), filetype (string)
function M.get_preview(filepath, max_lines)
	max_lines = max_lines or 10

	-- Check cache first
	local cache_key = filepath
	if M.preview_cache[cache_key] then
		return M.preview_cache[cache_key].lines, M.preview_cache[cache_key].filetype
	end

	-- Get current working directory
	local cwd = vim.fn.getcwd()
	local full_path = filepath

	-- Make path absolute if it's relative
	if not filepath:match("^/") and not filepath:match("^%a:") then
		full_path = cwd .. "/" .. filepath
	end

	-- Check if file exists and is readable
	if vim.fn.filereadable(full_path) == 0 then
		return {"[File not readable]"}, "text"
	end

	-- Read file lines
	local lines = {}
	local file = io.open(full_path, "r")
	if not file then
		return {"[Cannot open file]"}, "text"
	end

	local count = 0
	for line in file:lines() do
		count = count + 1
		table.insert(lines, line)
		if count >= max_lines then
			break
		end
	end
	file:close()

	-- If file is empty
	if #lines == 0 then
		lines = {"[Empty file]"}
	end

	-- Detect filetype
	local filetype = vim.filetype.match({ filename = full_path }) or "text"

	-- Cache the result
	M.preview_cache[cache_key] = {
		lines = lines,
		filetype = filetype
	}

	return lines, filetype
end

-- Clear preview cache
function M.clear_cache()
	M.preview_cache = {}
end

-- Create a preview window and buffer
-- Returns: preview_bufnr, preview_winid
function M.create_preview_window(config)
	-- Create preview buffer
	local preview_bufnr = vim.api.nvim_create_buf(false, true)

	-- Set buffer options
	vim.api.nvim_buf_set_option(preview_bufnr, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(preview_bufnr, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(preview_bufnr, 'swapfile', false)
	vim.api.nvim_buf_set_option(preview_bufnr, 'modifiable', false)

	-- Create window configuration
	local win_config = {
		relative = config.relative or 'editor',
		width = config.width or 50,
		height = config.height or 10,
		row = config.row or 5,
		col = config.col or 5,
		style = 'minimal',
		border = config.border or 'rounded',
		title = config.title or ' Preview ',
		title_pos = 'center',
	}

	-- Open preview window
	local preview_winid = vim.api.nvim_open_win(preview_bufnr, false, win_config)

	-- Set window options
	vim.api.nvim_win_set_option(preview_winid, 'wrap', false)
	vim.api.nvim_win_set_option(preview_winid, 'cursorline', false)
	vim.api.nvim_win_set_option(preview_winid, 'number', true)
	vim.api.nvim_win_set_option(preview_winid, 'relativenumber', false)
	vim.api.nvim_win_set_option(preview_winid, 'winhighlight', 'Normal:Normal,FloatBorder:BufferChadPreviewBorder,FloatTitle:BufferChadTitle')

	return preview_bufnr, preview_winid
end

-- Update preview window content
function M.update_preview(preview_bufnr, filepath, max_lines)
	if not preview_bufnr or not vim.api.nvim_buf_is_valid(preview_bufnr) then
		return
	end

	-- Get preview content
	local lines, filetype = M.get_preview(filepath, max_lines)

	-- Make buffer modifiable
	vim.api.nvim_buf_set_option(preview_bufnr, 'modifiable', true)

	-- Set content
	vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, lines)

	-- Set filetype for syntax highlighting
	vim.api.nvim_buf_set_option(preview_bufnr, 'filetype', filetype)

	-- Make buffer non-modifiable again
	vim.api.nvim_buf_set_option(preview_bufnr, 'modifiable', false)
end

-- Close preview window
function M.close_preview(preview_winid)
	if preview_winid and vim.api.nvim_win_is_valid(preview_winid) then
		vim.api.nvim_win_close(preview_winid, true)
	end
end

return M
