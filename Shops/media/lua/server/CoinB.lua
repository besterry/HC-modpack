if not isServer() then return end
-- local Json = require("Json")

--�������� ������� ������� � json ���� �������
function SaveCoinBalancefd(username) --������ � ����
    local coinBalance = ModData.get("CoinBalance")
    if not coinBalance then return end
    local fileWriterObj = getFileWriter("file_CoinBalance.json", true, false)
    local coinBalanceJson = Json.Encode(coinBalance)
    -- ��������� ������ �������� ������ ����� ������ ������
    local formattedJson = coinBalanceJson:gsub("},","},\n")
    fileWriterObj:write(formattedJson)
    fileWriterObj:close()
end

-- local onClientCommand = function(module, command, playerObj, args)
--     if module ~= "logBalance" then
--         return
--     end

--     if command == "logBalance" then
--         local coinBalance = ModData.get("CoinBalance")
--         if not coinBalance then return end
--         local fileWriterObj = getFileWriter("file_CoinBalance.json", true, false)
--         local coinBalanceJson = Json.Encode(coinBalance)
--         -- ��������� ������ �������� ������ ����� ������ ������
--         local formattedJson = coinBalanceJson:gsub("},","},\n")
--         fileWriterObj:write(formattedJson)
--         fileWriterObj:close()
--     end
-- end
-- Events.OnClientCommand.Add(onClientCommand);