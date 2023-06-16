if not isServer() then return end
local Json = require("Json")

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
