---@class TheLogger
---@field fileName string
---@field moduleName string
TheLogger = TheLogger or {}

---@param msg string
function TheLogger:log(msg)
    local dateTimeStr = os.date('%d.%m.%Y %H:%M:%S')
    local result = '['..self.moduleName..']:['..dateTimeStr..']:'..msg
    self:writeLn(result)
end

---@param lineStr string
function TheLogger:writeLn(lineStr)
    local fileWriter = getFileWriter(self.fileName, true, true)
    fileWriter:writeln(lineStr)
    fileWriter:close()
end

---@param fileName string | nil
---@param moduleName string | nil
---@return TheLogger
function TheLogger:new(fileName, moduleName)
    local o = {}
    setmetatable(o, self)
	self.__index = self
    
    ---@type string
    o.fileName = fileName or moduleName..'.log'
    ---@type string
    o.moduleName = moduleName or fileName

    return o
end
