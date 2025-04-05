local utils = require("goto-test.utils")

local M = {}

M.opts = {}

M.test_patterns = {
	"**/{filename}.test.*",
	"**/{filename}_test.*",
	"**/test_{filename}.*",
	"**/{filename}.spec.*",
}
M.setup = function(opts)
	if opts ~= nil then
		M.opts = opts
	end
	if M.opts.patterns ~= nil and #M.opts.patterns > 0 then
		M.test_patterns = vim.list_extend(M.test_patterns, M.opts.patterns)
	end
	vim.api.nvim_create_user_command("GotoTest", M.GoToTest, {})
end

function M.GoToTest()
	local lsp_clients = utils.get_lsp_client_info()
	local lsp_available = lsp_clients ~= nil and #lsp_clients > 0

	if not lsp_available then
		M.fd_test_file()
		return
	end

	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local cursor_line, _ = cursor_pos[1] - 1, cursor_pos[2]

	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, symbols)
		if err or not symbols then
			M.fd_test_file()
			return
		end

		local functions = utils.find_containing_function(symbols, cursor_line)
		if functions == nil or #functions == 0 then
			M.fd_test_file()
			return
		end

		local outer_function = functions[1]

		local ref_params = {
			textDocument = params.textDocument,
			position = outer_function.selectionRange.start,
			context = { includeDeclaration = true },
		}

		vim.lsp.buf_request(0, "textDocument/references", ref_params, function(_, locations)
			if locations == nil or #locations == 0 then
				M.fd_test_file()
				return
			end
			local locations_uris = utils.prepare_location_uris(locations)
			local test_files = utils.match_test_files(M.test_patterns, locations_uris)
			if #test_files == 0 then
				M.fd_test_file()
				return
			end

			if #test_files == 1 then
				vim.cmd("e " .. test_files[1])
				return
			end

			if #test_files > 1 then
				local quickfix_entries = utils.format_qf_entries(test_files)
				vim.fn.setqflist(quickfix_entries, "r")

				vim.notify("Found " .. #test_files .. " files", vim.log.levels.INFO)
				vim.cmd("copen")
			end
		end)
	end)
end

function M.fd_test_file()
	local current_file_name = utils.get_current_file_name()
	local test_file_patterns = utils.replace_in_strings(M.test_patterns, current_file_name, "{filename}")
	test_file_patterns = utils.fd_glob_patterns(test_file_patterns)
	M.asyncFind(test_file_patterns)
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
		utils.close_handle(stdin)
		utils.close_handle(stdout)
		utils.close_handle(stderr)
		utils.close_handle(handle)
	end)
	vim.uv.read_start(stdout, M.process_fd_output)

	vim.uv.read_start(stderr, function(err, data)
		assert(not err, err)
	end)
end

function M.process_fd_output(err, data)
	assert(not err, err)
	if data == nil then
		return
	end

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

return M
