local M = {}


function M.props_read_write(url, props)
	for _,prop in ipairs(props) do
		local value = go.get(url, prop)
		go.set(url, prop, value)
	end
end

function M.props_read(url, props)
	for _,prop in ipairs(props) do
		local value = go.get(url, prop)
		local ok, err = pcall(go.set, "#sprite", prop, value)
		assert(not ok)
	end
end

function M.async(fn)
	local co = coroutine.create(fn)
	local function resume()
		assert(coroutine.resume(co))
	end
	local function yield()
		coroutine.yield()
	end
	assert(coroutine.resume(co, yield, resume))
end

function M.wait_until_true(condition)
	local co = coroutine.running()
	assert(co, "You must call function from within a coroutine")
	assert(type(condition) == "function")

	timer.delay(0, true, function(self, handle, time_elapsed)
		if condition() then
			timer.cancel(handle)
			assert(coroutine.resume(co))
		end
	end)
	coroutine.yield()
end

function M.wait_until_done(fn)
	local co = coroutine.running()
	assert(co, "You must call function from within a coroutine")
	assert(type(fn) == "function")

	fn(function()
		assert(coroutine.resume(co))
	end)
	coroutine.yield()
end

function M.wait(delay)
	local co = coroutine.running()
	assert(co, "You must call function from within a coroutine")
	delay = delay or 0
	timer.delay(delay, false, function()
		assert(coroutine.resume(co))
	end)
	coroutine.yield()
end

function M.assert_error(fn, ...)
	local ok, err = pcall(fn, ...)
	assert(not ok, "Expected function to generate an error")
end

function M.ok()
	msg.post("tests:/tests", "test_success")
end


return M