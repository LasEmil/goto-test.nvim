local utils = require("goto-test.utils")

local M = {}

M.opts = {}

function M.asyncFind(patterns)
	local found_files = {}
	local patterns_len = #patterns

	for i, pattern in ipairs(patterns) do
		local stdin = vim.uv.new_pipe()
		local stdout = vim.uv.new_pipe()
		local stderr = vim.uv.new_pipe()
		local handle, pid = vim.uv.spawn("fd", {
			args = { "-g", pattern },
			stdio = { stdin, stdout, stderr },
			on_exit = function(code, signal)
				print("fd exited with code " .. code .. " and signal " .. signal)
				if signal ~= 0 then
					print("fd exited with signal " .. signal)
				end
			end,
		})
		vim.uv.read_start(stdout, function(err, data)
			assert(not err, err)
			if data then
				local formatted_data = utils.format_fd_output(data)
				if #formatted_data > 0 then
					for _, file in ipairs(formatted_data) do
						table.insert(found_files, file)
					end
				end
			end
			local is_last_pattern = patterns_len == i
			if is_last_pattern then
				vim.uv.close(handle, function()
					vim.uv.close(stdin)
					vim.uv.close(stdout)
					vim.uv.close(stderr)
				end)

				if #found_files == 0 then
					vim.schedule(function()
						vim.notify("No test file found", vim.log.levels.INFO)
					end)
					return
				end
				if #found_files == 1 then
					vim.schedule(function()
						vim.cmd("e " .. found_files[1])
					end)
					return
				end

				if #found_files > 1 then
					local quickfix_entries = utils.format_qf_entries(found_files)
					vim.schedule(function()
						vim.fn.setqflist(quickfix_entries, "r")

						vim.notify("Found " .. #found_files .. " files", vim.log.levels.INFO)
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
	M.asyncFind(test_file_patterns)
end
M.setup = function(opts)
	if opts ~= nil then
		M.opts = opts
	end
	vim.api.nvim_create_user_command("GotoTest", M.GoToTest, {})
end

return M
