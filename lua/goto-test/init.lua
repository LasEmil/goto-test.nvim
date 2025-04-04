local utils = require("goto-test.utils")

local M = {}

M.opts = {}
M.GoToTest = function()
	local current_file_directory = utils.get_current_file_directory()
	local current_file_name = utils.get_current_file_name()

	local patterns = {
		"{pwd}/{filename}.test.*",
		"{pwd}/{filename}.spec.*",
		"{pwd}/test_{filename}.*",
		"{pwd}/{filename}_test.*",

		"test/**/{filename}.test.*",
		"test/**/test_{filename}.*",
		"test/**/{filename}_test.*",

		"tests/**/{filename}.test.*",
		"tests/**/test_{filename}.*",
		"tests/**/{filename}_test.*",

		"spec/**/{filename}.spec.*",

		"__tests__/**/{filename}.test.*",
		"__tests__/**/{filename}.spec.*",
		"__tests__/**/test_{filename}.*",
		"__tests__/**/{filename}_test.*",
	}

	if M.opts.patterns ~= nil and utils.table_length(M.opts.patterns) ~= 0 then
		patterns = vim.list_extend(patterns, M.opts.patterns)
	end
	local test_file_patterns = utils.replace_in_strings(patterns, current_file_name, "{filename}")
	test_file_patterns = utils.replace_in_strings(test_file_patterns, current_file_directory, "{pwd}")
	if M.opts.debug then
		print("Current file name: " .. current_file_name)
		print("Current file directory: " .. current_file_directory)
		print("Test file patterns:")
		utils.P(test_file_patterns)
	end
	local test_files = utils.find_test_file_path(test_file_patterns)
	if test_files == nil then
		if M.opts.debug then
			print("No test file found")
		end
		return
	end
	local found_files_count = utils.table_length(test_files)
	if found_files_count == 1 then
		vim.cmd("e " .. test_files[1])
		return
	end
	if found_files_count > 1 then
		local quickfix_entries = {}
		for _, file in ipairs(test_files) do
			table.insert(quickfix_entries, { filename = file })
		end

		vim.fn.setqflist(quickfix_entries)

		vim.cmd("copen")
		return
	end
end
M.setup = function(opts)
	if opts ~= nil then
		M.opts = opts
	end
	vim.api.nvim_create_user_command("GotoTest", M.GoToTest, {})
end

return M
