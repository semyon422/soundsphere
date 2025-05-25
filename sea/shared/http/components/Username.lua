---@param user sea.User
---@param url string
---@return string
return function (user, url)
	local attrs = ""

	if user.enable_gradient then
		attrs = attrs .. ([[class="text-clip" style="background: linear-gradient(90deg, %s, %s);" ]]):format(
			("#%06x"):format(user.color_left),
			("#%06x"):format(user.color_right)
		)
	elseif not user.enable_gradient and url then
		attrs = attrs .. [[class="has-text-primary-35"]]
	end

	if url then
		return ([[<a href="%s" %s><strong>%s</strong></a>]]):format(url, attrs, user.name)
	end

	return ([[<p %s><strong>%s</strong></p>]]):format(attrs, user.name)
end
