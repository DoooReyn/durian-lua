--[[
  network status and HTTP request
]] --

local Network = {}

--[[
  Check if local WIFI is available.
  @function isLocalWiFiAvailable
  @return boolean
]]--
function Network.isLocalWiFiAvailable()
    return cc.Network:isLocalWiFiAvailable()
end

--[[
  Check if Internet is available.
  @function isInternetConnectionAvailable
  @return boolean
]]--
function Network.isInternetConnectionAvailable()
    return cc.Network:isInternetConnectionAvailable()
end

--[[
  Check if hostname is available, the method will block main thread
  @function isInternetConnectionAvailable
  @return boolean

  example:
  network.isHostNameReachable("www.baidu.com")
]]--
function Network.isHostNameReachable(hostname)
    if type(hostname) ~= "string" then
        GG.Console.EF("network.isHostNameReachable() - invalid hostname %s", tostring(hostname))
        return false
    end
    return cc.Network:isHostNameReachable(hostname)
end

--[[
  Check Internet connect type.
  @function getInternetConnectionStatus
  @return integer
    cc.kCCNetworkStatusNotReachable
    cc.kCCNetworkStatusReachableViaWiFi
    cc.kCCNetworkStatusReachableViaWWAN
]]--
function Network.getInternetConnectionStatus()
    return cc.Network:getInternetConnectionStatus()
end

--[[
  Create a http request.
  @function createHTTPRequest
  @param function callback, connection status change callback
  @param string url, the request url
  @param string method, "GET" or "POST" or "PUT" or "DELETE"
  @return cc.HTTPRequest

  example:
  local function onRequestCallback(event)
    local request = event.request
    if event.name == "completed" then
      GG.Console.P(request:getResponseHeadersString())
      local code = request:getResponseStatusCode()
      if code ~= 200 then
        GG.Console.P(code) -- get error
        return
      end
      
      -- get success
      GG.Console.P("response length" .. request:getResponseDataLength())
      local response = request:getResponseString()
      GG.Console.P(response)
    elseif event.name == "progress" then
      GG.Console.P("progress" .. event.dltotal)
    else
      GG.Console.P(event.name) -- get error
      GG.Console.P(request:getErrorCode(), request:getErrorMessage())
      return
    end
  end

  local request = network.createHTTPRequest(onRequestCallback, "https://baidu.com", "GET")
  request:start()
]]--
function Network.createHTTPRequest(callback, url, method)
    if not method then
        method = "GET"
    end
    if string.upper(tostring(method)) == "GET" then
        method = cc.kCCHTTPRequestMethodGET
    elseif string.upper(tostring(method)) == "PUT" then
        method = cc.kCCHTTPRequestMethodPUT
    elseif string.upper(tostring(method)) == "DELETE" then
        method = cc.kCCHTTPRequestMethodDELETE
    else
        method = cc.kCCHTTPRequestMethodPOST
    end
    return cc.HTTPRequest:createWithUrl(callback, url, method)
end

--[[
  Create a http for download url and save to path.
  @function createHTTPDownload
  @param function callback, connection status change callback
  @param string url, the request url
  @param string savePath, fullpath for save
  @return cc.HTTPRequest

  example:
  local function onRequestCallback(event)
    local request = event.request
    if event.name == "completed" then
      local code = request:getResponseStatusCode()
      if code == 200 or code == 206 then -- 206 resume from break-point
        GG.Console.P("download success")
        return
      end
      GG.Console.P("HTTP unkonw response code:", code) -- get error
    elseif event.name == "progress" then
      GG.Console.P("progress" .. event.dltotal)
    else
      GG.Console.P(event.name) -- get error
      GG.Console.P(request:getErrorCode(), request:getErrorMessage())
    end
  end

  local savePath = GG.S_FileUtils:getWritablePath() .. "download.data"
  local request = network.createHTTPDownload(onRequestCallback, "https://baidu.com", savePath)
  request:start()
]]--
function Network.createHTTPDownload(callback, url, savePath)
    return cc.HTTPRequest:createForDownload(callback, url, savePath)
end

--[[
  Upload a file through a HTTPRequest instance.
  @function uploadFile
  @param callback As same as the first parameter of network.createHTTPRequest.
  @param url As same as the second parameter of network.createHTTPRequest.
  @param datas Includes following values:
    fileFiledName(The input label name that type is file);
    filePath(A absolute path for a file)
    contentType(Optional, the file's contentType, default is application/octet-stream)
    extra(Optional, the key-value table that transmit to form)
  @return cc.HTTPRequest

  example:
  network.uploadFile(function(evt)
    if evt.name == "completed" then
	  local request = evt.request
	  printf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
	  printf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
	  printf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
	  printf("REQUEST getResponseString() =\n%s", request:getResponseString())
	end
  end,
  "http://127.0.0.1/upload.php",
  {
    fileFieldName = "filepath",
	filePath = GG.Device.writablePath.."screen.jpg",
	contentType = "Image/jpeg",
	extra = {
	  {"act", "upload"},
	  {"submit", "upload"},
	}
  })
]]--
function Network.uploadFile(callback, url, datas)
    assert(datas or datas.fileFieldName or datas.filePath, "Need file datas!")
    local request = Network.createHTTPRequest(callback, url, "POST")
    local fileFieldName = datas.fileFieldName
    local filePath = datas.filePath
    local contentType = datas.contentType
    if contentType then
        request:addFormFile(fileFieldName, filePath, contentType)
    else
        request:addFormFile(fileFieldName, filePath)
    end
    if datas.extra then
        for i in ipairs(datas.extra) do
            local data = datas.extra[i]
            request:addFormContents(data[1], data[2])
        end
    end
    request:start()
    return request
end

local function parseTrueFalse(t)
    t = string.lower(tostring(t))
    if t == "yes" or t == "true" then
        return true
    end
    return false
end

--[[
  Convert a cookie to string.
  @function makeCookieString
  @param table cookie
  @return string
]]--
function Network.makeCookieString(cookie)
    local arr = {}
    for name, value in pairs(cookie) do
        if type(value) == "table" then
            value = tostring(value.value)
        else
            value = tostring(value)
        end

        arr[#arr + 1] = tostring(name) .. "=" .. string.urlencode(value)
    end

    return table.concat(arr, "; ")
end

--[[
  Convert a string to cookie table.
  @function parseCookie
  @param string cookieString
  @return table
]]--
function Network.parseCookie(cookieString)
    local cookie = {}
    local arr = string.split(cookieString, "\n")
    for _, item in ipairs(arr) do
        item = string.trim(item)
        if item ~= "" then
            local parts = string.split(item, "\t")
            -- ".amazon.com" represents the domain name of the Web server that created the cookie and will be able to read the cookie in the future
            -- TRUE indicates that all machines within the given domain can access the cookie
            -- "/" denotes the path within the domain for which the variable is valid
            -- "FALSE" indicates that the connection is not secure
            -- "2082787601" represents the expiration date in UNIX time (number of seconds since January 1, 1970 00:00:00 GMT)
            -- "ubid-main" is the name of the cookie
            -- "002-2904428-3375661" is the value of the cookie

            local c = {
                domain = parts[1],
                access = parseTrueFalse(parts[2]),
                path = parts[3],
                secure = parseTrueFalse(parts[4]),
                expire = GG.Checker.Int(parts[5]),
                name = parts[6],
                value = string.urldecode(parts[7])
            }

            cookie[c.name] = c
        end
    end

    return cookie
end

GG.Network = Network
