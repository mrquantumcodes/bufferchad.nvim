local M = {}


M.opts = {}
M.marked = {}

M.setup = function(options)
	M.opts = options

	local keybinding = options.mapping or "<Leader>bb"

	M.opts.style = options.style or "modern"

	if keybinding ~= "NONE" then
		vim.api.nvim_set_keymap('n', keybinding, "",
			{ noremap = true, silent = true, callback = function() M.BufferChadListBuffers() end })
	end

	local markerbinding = options.mark_mapping or "<Leader>bm"

	if markerbinding ~= "NONE" then
		vim.api.nvim_set_keymap('n', markerbinding, "",
			{ noremap = true, silent = true, callback = function() M.OpenBufferWindow(M.marked, "Marked Buffers") end })
	end
end

function removePathFromFullPath(fullPath, pathToRemove)
	-- Replace backslashes with forward slashes for platform independence
	fullPath = fullPath:gsub("\\", "/")
	pathToRemove = pathToRemove:gsub("\\", "/")

	-- Normalize paths by removing trailing slashes
	fullPath = fullPath:gsub("/$", "")
	pathToRemove = pathToRemove:gsub("/$", "")

	local fullPathLen = #fullPath
	local pathToRemoveLen = #pathToRemove

	local i = 1
	while i <= fullPathLen and i <= pathToRemoveLen do
		if fullPath:sub(i, i) == pathToRemove:sub(i, i) then
			i = i + 1
		else
			break
		end
	end

	if i > pathToRemoveLen then
		-- Remove pathToRemove and any leading slash
		return fullPath:sub(i + 1)
	else
		return fullPath
	end
end

-- Function to open the buffer list window in order of usage with the first and second buffers swapped
M.BufferChadListBuffers = function()
	-- Use vim.fn.execute to capture the output of ":ls t"

	local sort_order = M.opts.order or "LAST_USED_UP"

	local buffer_list = ""

	if sort_order == "LAST_USED_UP" or sort_order == "DESCENDING" or sort_order == "ASCENDING" then
		buffer_list = vim.fn.execute("ls t")
	elseif sort_order == "REGULAR" then
		buffer_list = vim.fn.execute("ls")
	end

	-- Split the buffer list into lines
	local buf_names = vim.split(buffer_list, "\n")


	-- Remove the first line (header)
	-- table.remove(buf_names, 1)

	for k, v in ipairs(buf_names) do
		if v == "" or v == "[No Name]" then
			table.remove(buf_names, k)
		end
	end



	-- Check if there are at least two buffers

	if sort_order == "LAST_USED_UP" then
		if #buf_names >= 2 then
			-- Swap the first and second buffers
			local temp = buf_names[1]
			buf_names[1] = buf_names[2]
			buf_names[2] = temp
		end
	elseif sort_order == "ASCENDING" then
		local reversedTable = {}
		local length = #buf_names
		for i = length, 1, -1 do
			table.insert(reversedTable, buf_names[i])
		end
		buf_names = reversedTable
	end



	local cwdpath = vim.fn.getcwd():gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")

	local path1 = cwdpath
	local path2 = ""

	-- print("hi")


	-- Extract the buffer names within double quotes
	local buffer_names = {}
	for _, line in ipairs(buf_names) do
		-- print(line)
		local name = line:match('"([^"]+)"')
		-- print(buf_names[1]:match('"([^"]+)"'))
		if name then
			local myname = name:gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")

			path2 = myname

			-- print(path1, path2)

			local remainingPath = removePathFromFullPath(path2, path1)

			-- print(remainingPath)

			table.insert(buffer_names, remainingPath)
		end
	end


	M.OpenBufferWindow(buffer_names, "Navigate to a Buffer")
end

M.OpenBufferWindow = function(buffer_names, title)
	local dressingInstalled = pcall(require, 'dressing')
	if dressingInstalled and M.opts.style == "modern" then
		vim.ui.select(buffer_names, {
			prompt = title,
		}, function(selected)
			if selected ~= "" and selected ~= nil and selected ~= '[No Name]' then
				vim.cmd('buffer ' .. selected)
			end
		end)
	elseif M.opts.style == "default" or (not dressingInstalled and M.opts.style ~= "telescope") then
		local bufnr = vim.api.nvim_create_buf(false, true)

		-- Set the buffer contents to the list of buffer paths
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, buffer_names)

		-- Create a window for the buffer
		local win_id = vim.api.nvim_open_win(bufnr, true, {
			relative = 'win',
			width = 55,
			height = 10,
			row = vim.o.lines / 2 - #buffer_names / 2 - 1,
			col = vim.o.columns / 2 - 27.5,
			style = 'minimal',
			border = 'rounded',
			title = title,
			anchor = 'NW'
		})

		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd('set nomodifiable')
			vim.cmd('set cursorline')
		end)

		-- Set key mappings for navigation and buffer opening
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', "", {
			noremap = true,
			silent = true,
			callback = function()
				local bufnr = vim.fn.bufnr('%')
				local line_number = vim.fn.line('.')
				local selected_path = buffer_names[line_number]

				if selected_path then
					vim.api.nvim_buf_call(bufnr, function()
						vim.cmd('set modifiable')
					end)

					vim.cmd('bdelete ' .. bufnr) -- Close the buffer list window
					-- vim.cmd('edit ' .. selected_path)

					vim.cmd('buffer ' .. selected_path)
				end
			end
		})

		-- Set key mappings for navigation and buffer opening
		vim.api.nvim_buf_set_keymap(bufnr, 'n', M.opts.close_mapping or '<Esc><Esc>', "", {
			noremap = true,
			silent = true,
			callback = function()
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd('set modifiable')
				end)

				vim.cmd('bdelete ' .. bufnr)
			end
		})

		-- Store window ID and buffer number for later use
		vim.api.nvim_buf_set_var(bufnr, 'buffer_list_win_id', win_id)
	else
		if pcall(require, 'telescope') then
			local pickers = require "telescope.pickers"
			local finders = require "telescope.finders"
			local conf = require("telescope.config").values

			pickers.new({}, {
				prompt_title = title,
				finder = finders.new_table {
					results = buffer_names
				},
				sorter = conf.generic_sorter({}),
				previewer = conf.grep_previewer({}),
			}):find()
		else
			print("Telescope is not installed")
		end
	end
end


-- vim.cmd([[command! BufferChadListBuffers lua BufferChadListBuffers() ]])


-- Function to push the current buffer to the marked list
M.push_current_buffer_to_marked = function()
	local bufnr = vim.fn.bufnr('%')
	local bufname = vim.fn.bufname(bufnr)

	for k, v in ipairs(M.marked) do
		if v == bufname then
			table.remove(M.marked, k)
		end
	end

	-- get bufname ready by expanding home directory and replacing backslashes with forward slashes
	bufname = bufname:gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")
	-- print(bufname)
	-- remove unnecessary paths from the mark name, like the current working directory
	local cwdpath = vim.fn.getcwd():gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")
	-- remove cwdpath from bufname
	-- bufname = bufname:gsub(cwdpath, "")
	bufname = removePathFromFullPath(bufname, cwdpath)

	-- Check if the buffer is not already in the list
	if not vim.tbl_contains(M.marked, bufname) then
		table.insert(M.marked, bufname)
	end
end

-- Function to push the buffer to the marked list at a specific position
M.push_buffer_to_marked = function(start_line, end_line, position)
	local bufnr = vim.fn.bufnr('%')
	local bufname = vim.fn.bufname(bufnr)

	-- Check if the buffer is not already in the list
	for k, v in ipairs(M.marked) do
		if v == bufname then
			table.remove(M.marked, k)
		end
	end


	-- get bufname ready by expanding home directory and replacing backslashes with forward slashes
	bufname = bufname:gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")
	-- subtract unnecessary paths from the mark name, like the current working directory
	local cwdpath = vim.fn.getcwd():gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")
	-- remove cwdpath from bufname
	-- bufname = bufname:gsub(cwdpath, "")
	bufname = removePathFromFullPath(bufname, cwdpath)

	-- Insert it at the specified position
	table.insert(M.marked, (position > #M.marked) and #M.marked + 1 or position, bufname)
end

-- Function to navigate to the marked buffer by position
M.navigate_to_marked_buffer = function(position)
	local bufname = M.marked[position]
	if bufname then
		vim.cmd('buffer ' .. bufname)
		if position > #M.marked then
			print("No buffer found at position")
		end
	end

	print(M.marked[position])
end

-- Define the key mappings with callbacks
-- Define the key mappings directly in a loop

function findMarkedBuffer(bufname)
	for k, v in ipairs(M.marked) do
		if v == bufname then
			return k
		end
	end
	return nil
end

vim.api.nvim_set_keymap('n', "mset", "",
	{ noremap = true, silent = true, callback = function() M.push_current_buffer_to_marked() end })

-- Define the mappings for mdel
vim.api.nvim_set_keymap('n', string.format('mdel', i), "",
	{
		noremap = true,
		silent = true,
		callback = function()
			markedBuffer = findMarkedBuffer(vim.fn.bufname(vim.fn.bufnr('%')):gsub("\\", "/"))
			if markedBuffer ~= nil then
				table.remove(M.marked, markedBuffer)
			else
				print("This buffer is not marked")
			end
		end
	})

for i = 1, 9 do
	-- Define the mappings for <N>set
	vim.api.nvim_set_keymap('n', string.format('%dset', i), "",
		{ noremap = true, silent = true, callback = function() M.push_buffer_to_marked(1, vim.fn.line("."), i) end })
	vim.api.nvim_set_keymap('x', string.format('%dset', i), "",
		{ noremap = true, silent = true, callback = function() M.push_buffer_to_marked(1, vim.fn.line("."), i) end })

	-- Define the mappings for <N>swap
	vim.api.nvim_set_keymap('n', string.format('%dswap', i), "",
		{
			noremap = true,
			silent = true,
			callback = function()
				-- find this mark in M.marked
				local thisBuf = findMarkedBuffer(vim.fn.bufname(vim.fn.bufnr('%')):gsub("\\", "/"))
				local thisBufContent = M.marked[thisBuf]
				local temp = M.marked[i]
				if i > #M.marked then
					M.marked[i] = thisBufContent
				else
					M.marked[#M.marked + 1] = thisBufContent
				end
				M.marked[thisBuf] = temp
			end
		})

	-- Define the mappings for <N>nav
	vim.api.nvim_set_keymap('n', string.format('%dnav', i), "",
		{ noremap = true, silent = true, callback = function() M.navigate_to_marked_buffer(i) end })
	vim.api.nvim_set_keymap('x', string.format('%dnav', i), "",
		{ noremap = true, silent = true, callback = function() M.navigate_to_marked_buffer(i) end })
end




-- Set the keybinding to toggle the buffer list window
--   vim.api.nvim_set_keymap('n', '<leader>bb', '<Cmd>lua OpenBufferListWindow()<CR>', { noremap = true, silent = true })

return M
