local Json = require("Json")


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

--������ � �����
-- local function LoadCoinBalance()
--     local fileReaderObj = getFileReader("file_CoinBalance.json", true)
--     local json = ""
--     local line = fileReaderObj:readLine()
--     while line ~= nil do
--         json = json .. line
--         line = fileReaderObj:readLine()
--     end
--     fileReaderObj:close()

--     if json and json ~= "" then
--         ModData.get("CoinBalance") = Json.Decode(json)
--     else
--         ModData.get("CoinBalance") = {}
--     end
-- end

-- return {
--     SaveCoinBalance = SaveCoinBalance,
--     LoadCoinBalance = LoadCoinBalance
-- }
