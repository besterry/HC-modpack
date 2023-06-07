local FileDB = {}
local module = {}

module.instances = {}

--------------------------------------------------------------------
--
-- Open a new database handler for the mod
--
-- setting is isGlobal = true, makes the database acessible in any
-- connected server
-- isGlobal = false, makes the database only accessible within the server
--
--------------------------------------------------------------------
module.open = function( name, isGlobal, needLoad )

  local instance = module.instances[ name ]
  if instance then
    return instance
  end

  isGlobal = isGlobal or false
  needLoad = needLoad or false

  local instance = FileDB:new( name, isGlobal )

  if needLoad then
    instance:load()
  end

  module.instances[ name ] = instance

  return instance

end





function FileDB:new( name, isGlobal )

  local o    = {}
  o.name     = name
  o.entries  = {}
  o.isGlobal = isGlobal
  setmetatable(o, self)
  self.__index = self

  return o

end


--------------------------------------------------------------------
--
-- load data from disk (if possible)
--
--------------------------------------------------------------------
function FileDB:load()

  local file = getFileReader( self:_getFileName(), true )
  if file then
    self:_parse( file, self.entries )
  end
  file:close()

end

--------------------------------------------------------------------
--
-- Parse data from the file and build the entries table
--
--------------------------------------------------------------------
function FileDB:_parse( file, entries )

  while true do
    local line = file:readLine()

    if line == nil then break end
    print(line)
    for key, val in string.gmatch( line, "(.+) *= *(.+)") do
      entries[key] = self:_decode(val)
    end

  end

end

--------------------------------------------------------------------
--
-- get a non colliding filename
--
--------------------------------------------------------------------
function FileDB:_getFileName()

  local name = self.name

  if not self.isGlobal then
    local svrname = getServerOptions():getOption("PublicName")
    name = name .. ' in ' .. svrname
  end

  name = name .. ".txt"

--  if type( getPlayer() ) ~= 'nil' then
--    usrname = getPlayer():getUsername()
--  end

  return name

end


--------------------------------------------------------------------
--
-- encode data in disk
--
--------------------------------------------------------------------
function FileDB:_encode( data )
  local encoder = {
    null    = '0',
    string  = '1',
    number  = '2',
    boolean = '3'
  }

  local code = encoder[ type(data) ]
  return code .. tostring(data)

end


--------------------------------------------------------------------
--
-- decode data in disk
--
--------------------------------------------------------------------

function FileDB:_decode( data )
  local decoder = {
    ['0'] = function( str ) return nil           end,
    ['1'] = function( str ) return str           end,
    ['2'] = function( str ) return tonumber(str) end,
    ['3'] = function( str ) return str == 'true' end
  }

  if not data then return nil end

  local code = string.sub(data,1,1)
  local str  = string.sub(data,2)

  local value = decoder[ code ]( str )
  return value

end

--------------------------------------------------------------------
--
-- put a lua object in the database
--
--------------------------------------------------------------------

function FileDB:put( key, val )
  self.entries[ key ] = val
  return self
end



--------------------------------------------------------------------
--
-- get a lua object (if exists)
--
--------------------------------------------------------------------
function FileDB:get( key )
  return self.entries[ key ]
end


--------------------------------------------------------------------
--
-- save data from memory to disk
--
--------------------------------------------------------------------

function FileDB:commit()

  local file = getFileWriter( self:_getFileName(), true, false )

  for k,v in pairs( self.entries ) do
    local entry = k .. '=' .. self:_encode(v) .. "\n"
    file:write( entry )
  end

  file:close()
  return self
end





return module
