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

-- join patterns table into string like '{init.test.*,init_test.*}'
M.fd_glob_patterns = function(patterns)
	local fd_glob = ""
	for i, pattern in ipairs(patterns) do
		if i == 1 then
			fd_glob = "{" .. pattern
		else
			fd_glob = fd_glob .. "," .. pattern
		end
	end
	fd_glob = fd_glob .. "}"
	return fd_glob
end

M.P = function(v)
	print(vim.inspect(v))
	return v
end

M.get_lsp_client_info = function()
	local all_clients = vim.lsp.get_clients({ bufnr = 0 })
	local filtered_clients = {}
	for _, client in ipairs(all_clients) do
		if client.server_capabilities.referencesProvider == true and client.name ~= "copilot" then
			table.insert(filtered_clients, client)
		end
	end

	return filtered_clients
end

M.find_containing_function = function(symbols_list, cursor_line)
	local containing_functions = {}

	for _, symbol in ipairs(symbols_list) do
		local range = symbol.range or symbol.location.range
		local is_function = symbol.kind == 12 -- Function kind
		local start_line = range.start.line
		local end_line = range["end"].line

		-- Check if cursor is inside this symbol
		if start_line <= cursor_line and end_line >= cursor_line and is_function then
			table.insert(containing_functions, symbol)
		end

		-- Check children
		if symbol.children then
			local child_functions = M.find_containing_function(symbol.children, cursor_line)
			for _, child in ipairs(child_functions) do
				table.insert(containing_functions, child)
			end
		end
	end

	return containing_functions
end
M.close_handle = function(handle)
	if handle and not handle:is_closing() then
		handle:close()
	end
end

-- M.glob_to_pattern = function(glob)
-- 	-- Escape magic characters in Lua patterns
-- 	local pattern = glob:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", function(c)
-- 		if c == "*" then
-- 			return ".-" -- * becomes .- (match any sequence)
-- 		elseif c == "?" then
-- 			return "." -- ? becomes . (match any character)
-- 		else
-- 			return "%" .. c -- Escape other special characters
-- 		end
-- 	end)
--
-- 	-- Handle ** (match across directories)
-- 	pattern = pattern:gsub("%.%-%.%-", ".*")
--
-- 	-- Handle / or \ as directory separators
-- 	pattern = pattern:gsub("/", "[/\\]")
--
-- 	-- Anchor to the end of the string
-- 	pattern = pattern .. "$"
--
-- 	return pattern
-- end
--
-- M.is_test_file = function(file_path, patterns)
-- 	local path = file_path:gsub("^file://", "")
--
-- 	for _, glob in ipairs(patterns) do
-- 		local pattern = M.glob_to_pattern(glob)
-- 		if path:match(pattern) then
-- 			return true, glob
-- 		end
-- 	end
--
-- 	return false
-- end

M.prepare_lpeg_patterns = function(patterns)
	local test_patterns_glob = M.replace_in_strings(patterns, "*", "{filename}")
	local test_patterns = {}
	for _, pattern in ipairs(test_patterns_glob) do
		local lpeg_pattern = vim.glob.to_lpeg(pattern)
		table.insert(test_patterns, lpeg_pattern)
	end
	return test_patterns
end

M.is_test_file_lpeg = function(file_path, patterns)
	local path = file_path:gsub("^file://", "")
	for _, pattern in ipairs(patterns) do
		local is_match = vim.lpeg.match(pattern, path)

		if is_match then
			return true
		end
	end

	return false
end

M.prepare_location_uris = function(locations)
	local locations_uris = {}
	for _, location in ipairs(locations) do
		local path = location.uri:gsub("^file://", "")
		table.insert(locations_uris, path)
	end
	return locations_uris
end
M.match_test_files = function(test_patterns, locations_uris)
	local lpeg_patterns = M.prepare_lpeg_patterns(test_patterns)
	local test_files = {}
	for _, location in ipairs(locations_uris) do
		local is_test = M.is_test_file_lpeg(location, lpeg_patterns)
		if is_test and not test_files[location] then
			table.insert(test_files, location)
		end
	end

	return M.remove_duplicates(test_files)
end

M.remove_duplicates = function(tbl)
	local seen = {}
	local result = {}

	for _, value in ipairs(tbl) do
		if not seen[value] then
			table.insert(result, value)
			seen[value] = true
		end
	end

	return result
end
return M
