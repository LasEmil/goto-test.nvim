local utils = require("goto-test.utils")

local M = {}

M.opts = {}
local close_handle = function(handle)
	if handle and not handle:is_closing() then
		handle:close()
	end
end
function M.asyncFind(patterns)
	local stdin = vim.uv.new_pipe()
	local stdout = vim.uv.new_pipe()
	local stderr = vim.uv.new_pipe()
	local handle
	handle, pid = vim.uv.spawn("fd", {
		args = { "-g", patterns },
		stdio = { stdin, stdout, stderr },
	}, function() -- on exit
		stdout:read_stop()
		stderr:read_stop()
		close_handle(stdin)
		close_handle(stdout)
		close_handle(stderr)
		close_handle(handle)
	end)
	vim.uv.read_start(stdout, function(err, data)
		assert(not err, err)
		if data then
			local formatted_data = utils.format_fd_output(data)

			if #formatted_data == 0 then
				vim.schedule(function()
					vim.notify("No test file found", vim.log.levels.INFO)
				end)
				return
			end
			if #formatted_data == 1 then
				vim.schedule(function()
					vim.cmd("e " .. formatted_data[1])
				end)
				return
			end

			if #formatted_data > 1 then
				local quickfix_entries = utils.format_qf_entries(formatted_data)
				vim.schedule(function()
					vim.fn.setqflist(quickfix_entries, "r")

					vim.notify("Found " .. #formatted_data .. " files", vim.log.levels.INFO)
					vim.cmd("copen")
				end)
				return
			end
		end
	end)

	vim.uv.read_start(stderr, function(err, data)
		assert(not err, err)
	end)
end

function M.GoToTest()
	local current_file_name = utils.get_current_file_name()

	local patterns = {
		"{filename}.test.*",
		"{filename}.spec.*",
		"{filename}_test.*",
		"test_{filename}.*",
	}

	if M.opts.patterns ~= nil and #M.opts.patterns ~= 0 then
		patterns = vim.list_extend(patterns, M.opts.patterns)
	end
	local test_file_patterns = utils.replace_in_strings(patterns, current_file_name, "{filename}")
	test_file_patterns = utils.fd_glob_patterns(test_file_patterns)
	M.asyncFind(test_file_patterns)
end

M.setup = function(opts)
	if opts ~= nil then
		M.opts = opts
	end
	vim.api.nvim_create_user_command("GotoTest", M.GoToTest, {})
end

return M
