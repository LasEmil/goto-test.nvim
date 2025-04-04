M = {}

M.get_current_file_path = function()
	return vim.api.nvim_buf_get_name(0)
end

M.get_current_file_directory = function()
	local file_path = M.get_current_file_path()
	local file_directory = vim.fn.fnamemodify(file_path, ":h")
	return file_directory
end

M.get_current_file_extension = function()
	local file_path = M.get_current_file_path()
	local file_name_with_extension = vim.fn.fnamemodify(file_path, ":t")
	local file_extension = vim.fn.fnamemodify(file_name_with_extension, ":e")
	return file_extension
end

-- Get the current file name without the path and extension
M.get_current_file_name = function()
	local file_path = M.get_current_file_path()
	local file_name_with_extension = vim.fn.fnamemodify(file_path, ":t")
	local file_name = vim.fn.fnamemodify(file_name_with_extension, ":r")
	return file_name
end

M.replace_in_strings = function(patterns, filename, string_to_replace)
	local new_patterns = {}
	for _, pattern in ipairs(patterns) do
		local new_pattern = pattern:gsub(string_to_replace, filename)
		table.insert(new_patterns, new_pattern)
	end
	return new_patterns
end

M.find_test_file_path = function(patterns)
	local found_files = {}
	for i, pattern in ipairs(patterns) do
		--check if file exists
		local file = vim.fn.glob(pattern)
		if file ~= "" then
			table.insert(found_files, file)
		end
	end
	if next(found_files) == nil then
		return nil
	end
	return found_files
end

M.table_length = function(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

M.P = function(v)
	print(vim.inspect(v))
	return v
end

return M
