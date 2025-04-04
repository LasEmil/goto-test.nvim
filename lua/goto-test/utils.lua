M = {}

M.get_current_file_path = function()
	return vim.api.nvim_buf_get_name(0)
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

function M.format_fd_output(data)
	local output = {}
	if data then
		local lines = vim.split(data, "\n")
		for _, line in ipairs(lines) do
			if line ~= "" then
				table.insert(output, line)
			end
		end
	end

	return output
end

M.format_qf_entries = function(data)
	local quickfix_entries = {}
	for _, file in ipairs(data) do
		table.insert(quickfix_entries, { filename = file })
	end

	return quickfix_entries
end
M.P = function(v)
	print(vim.inspect(v))
	return v
end

return M
