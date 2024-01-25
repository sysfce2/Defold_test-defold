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

function M.wait(delay_or_condition)
	local co = coroutine.running()
	assert(co, "You must call function from within a coroutine")

	if type(delay_or_condition) == "function" then
		local condition = delay_or_condition
		timer.delay(0, true, function(self, handle, time_elapsed)
			if condition() then
				timer.cancel(handle)
				assert(coroutine.resume(co))
			end
		end)
		coroutine.yield()
	else
		local delay = delay_or_condition or 0
		timer.delay(delay, false, function()
			assert(coroutine.resume(co))
		end)
		coroutine.yield()
	end
end

function M.condition(fn)
	local co = coroutine.running()
	assert(co, "You must call yield() from within a coroutine")
	timer.delay(0, true, function(self, handle, time_elapsed)
		if fn() then
			timer.cancel(handle)
			assert(coroutine.resume(co))
		end
	end)
	coroutine.yield()
end

function M.ok()
	msg.post("tests:/tests", "test_success")
end


return M