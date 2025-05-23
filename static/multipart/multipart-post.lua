
local fmt = function(p, ...)
  if select('#', ...) == 0 then
    return p
  else return string.format(p, ...) end
end

local tprintf = function(t, p, ...)
  t[#t+1] = fmt(p, ...)
end

local append_data = function(r, k, data, extra)
  tprintf(r, "content-disposition: form-data; name=\"%s\"", k)
  if extra.filename then
    tprintf(r, "; filename=\"%s\"", extra.filename)
  end
  if extra.content_type then
    tprintf(r, "\r\ncontent-type: %s", extra.content_type)
  end
  if extra.content_transfer_encoding then
    tprintf(
      r, "\r\ncontent-transfer-encoding: %s",
      extra.content_transfer_encoding
    )
  end
  tprintf(r, "\r\n\r\n")
  tprintf(r, tostring(data))
  tprintf(r, "\r\n")
end

local gen_boundary = function()
  local t = {"BOUNDARY-"}
  for i=2,17 do t[i] = string.char(math.random(65, 90)) end
  t[18] = "-BOUNDARY"
  return table.concat(t)
end

local encode = function(t, boundary)
  boundary = boundary or gen_boundary()
  local r = {}
  local _t
  for k,v in pairs(t) do
    tprintf(r, "--%s\r\n", boundary)
    _t = type(v)
    if _t == "string" then
      append_data(r, k, v, {})
    elseif _t == "boolean" then
      append_data(r, k, v, {})
    elseif _t == "table" then
      --assert(v.data, "invalid input")
      local extra = {
        filename = v.filename or v.name,
        content_type = v.content_type or v.mimetype
          or "application/octet-stream",
        content_transfer_encoding = v.content_transfer_encoding or "binary",
      }
      append_data(r, k, v.data, extra)
    elseif _t == "number" then
      append_data(r, k, v, {})
    else error(string.format("unexpected type %s = %s", _t, tostring(v)..' - '..tostring(k))) end
  end
  tprintf(r, "--%s--\r\n", boundary)
  return table.concat(r), boundary
end


return {
  encode = encode,

}
