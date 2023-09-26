local M = {}


M.opts = {}

M.setup = function(options)
	M.opts = options

	local keybinding = options.mapping or "<Leader>bb"

	if keybinding ~= "NONE" then
		vim.api.nvim_set_keymap('n', keybinding, "",
			{ noremap = true, silent = true, callback = function() M.BufferChadListBuffers() end })
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

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
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

	print(dump(buffer_names))

	vim.ui.select(buffer_names, {
		prompt = "Navigate to a Buffer",
	}, function(selected)
		if selected ~= "" and selected ~= nil and selected ~= '[No Name]' then
			vim.cmd('buffer ' .. selected)
		end
	end)
end


-- vim.cmd([[command! BufferChadListBuffers lua BufferChadListBuffers() ]])



-- Set the keybinding to toggle the buffer list window
--   vim.api.nvim_set_keymap('n', '<leader>bb', '<Cmd>lua OpenBufferListWindow()<CR>', { noremap = true, silent = true })

return M
