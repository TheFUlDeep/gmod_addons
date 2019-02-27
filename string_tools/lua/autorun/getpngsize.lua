-- pngparse.lua
-- Simple example of parsing the main sections of a PNG file.
--
-- This is mostly just an example.  Not intended to be complete,
-- robust, modular, or well tested.
--
-- (c) 2008 David Manura. Licensed under the same terms as Lua (MIT license).


-- Unpack 32-bit unsigned integer (most-significant-byte, MSB, first)
-- from byte string.




local function unpack_msb_uint32(s)
  local a,b,c,d = s:byte(1,#s)
  local num = (((a*256) + b) * 256 + c) * 256 + d
  return num
end

-- Read 32-bit unsigned integer (most-significant-byte, MSB, first) from file.
local function read_msb_uint32(fh)
  return unpack_msb_uint32(fh:Read(4))
end

-- Read unsigned byte (integer) from file
local function read_byte(fh)
  return fh:Read(1):byte()
end


local function parse_zlib(fh, len)
  local byte1 = read_byte(fh)
  local byte2 = read_byte(fh)

  local compression_method = byte1 % 16
  local compression_info = math.floor(byte1 / 16)

  local fcheck = byte2 % 32
  local fdict = math.floor(byte2 / 32) % 1
  local flevel = math.floor(byte2 / 64)

  --print("compression_method=", compression_method)
  --print("compression_info=", compression_info)
  --print("fcheck=", fcheck)
  --print("fdict=", fdict)
  --print("flevel=", flevel)

  fh:Read(len - 6)
  --print("(deflate data not displayed)")

  local checksum = read_msb_uint32(fh)
  --print("checksum=", checksum)
end


local PNGsSize = {}
local function parse_IHDR(fh, len)
  assert(len == 13, 'format error')
  local width = read_msb_uint32(fh)
  local height = read_msb_uint32(fh)
  local bit_depth = read_byte(fh)
  local color_type = read_byte(fh)
  local compression_method = read_byte(fh)
  local filter_method = read_byte(fh)
  local interlace_method = read_byte(fh)

  PNGsSize.width = width
  PNGsSize.height = height
  --print("width=", width)
  --print("height=", height)
  --print("bit_depth=", bit_depth)
  --print("color_type=", color_type)
  --print("compression_method=", compression_method)
  --print("filter_method=", filter_method)
  --print("interlace_method=", interlace_method)

  return compression_method
end

local function parse_sRGB(fh, len)
  assert(len == 1, 'format error')
  local rendering_intent = read_byte(fh)
  --print("rendering_intent=", rendering_intent)
end

local function parse_gAMA(fh, len)
  assert(len == 4, 'format error')
  local rendering_intent = read_msb_uint32(fh)
  --print("rendering_intent=", rendering_intent)
end

local function parse_cHRM(fh, len)
  assert(len == 32, 'format error')

  local white_x = read_msb_uint32(fh)
  local white_y = read_msb_uint32(fh)
  local red_x = read_msb_uint32(fh)
  local red_y = read_msb_uint32(fh)
  local green_x = read_msb_uint32(fh)
  local green_y = read_msb_uint32(fh)
  local blue_x = read_msb_uint32(fh)
  local blue_y = read_msb_uint32(fh)
  --[[print('white_x=', white_x)
  print('white_y=', white_y)
  print('red_x=', red_x)
  print('red_y=', red_y)
  print('green_x=', green_x)
  print('green_y=', green_y)
  print('blue_x=', blue_x)
  print('blue_y=', blue_y)]]
end

local function parse_IDAT(fh, len, compression_method)
  if compression_method == 0 then
    -- fh:read(len)
    parse_zlib(fh, len)
  else
    --print('(unrecognized compression method)')
  end  
end

local function parse_png(fh)
  -- parse PNG header
  local bytes = fh:Read(8)
  --[[local expect = "\137\080\078\071\013\010\026\010"
  if bytes ~= expect then
    error 'not a PNG file'
  end]]

  -- parse chunks
  local compression_method
  while 1 do
    local len = read_msb_uint32(fh)
    local stype = fh:Read(4)
    --print("chunk:", "type=", stype, "len=", len)
    if stype == 'IHDR' then
      compression_method = parse_IHDR(fh, len)
    elseif stype == 'sRGB' then
      parse_sRGB(fh, len)
    elseif stype == 'gAMA' then
      parse_gAMA(fh, len)
    elseif stype == 'cHRM' then
      parse_cHRM(fh, len)
    elseif stype == 'IDAT' then
      parse_IDAT(fh, len, compression_method)
    else
      local data = fh:Read(len)
      --print("data=", len == 0 and "(empty)" or "(not displayed)")
    end

    local crc = read_msb_uint32(fh)
    --print("crc=", crc)

    if stype == 'IEND' then
      break
    end
  end
end

--[[local filename = arg[1]

if not filename then
  io.stderr:write("usage: lua pngparse.lua <filename>")
  os.exit(1)
end]]

--[[local f = file.Read("1.png")
local fSize = file.Size("1.png","DATA")
print(fSize)]]



function GetPNGSize(filee,path,filemode)
	PNGsSize = {}
	if not path then path = "DATA" end
	if not filee or filee == "" or not file.Exists(filee,path) or bigrustosmall(filee):sub(-4) ~= ".png" then return nil,nil end
	if not filemode then filemode = "rb" end
	print("a")
	local fh = file.Open(filee,filemode,path)
	--fh = fh:Read()
	parse_png(fh)
	fh:Close()
	
	if not PNGsSize or not PNGsSize.width or not PNGsSize.height then return nil,nil end
	--PrintTable(PNGsSize)
	return PNGsSize.width, PNGsSize.height
end
