ETOMARAT = ETOMARAT or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}
ETOMARAT.PlayerAccounting.MOD_NAME = 'PlayerAccounting'

---@enum event_type
ETOMARAT.PlayerAccounting.EVENT_TYPES = {
    Create = 'Create',
    Linked = 'Linked',
    Deposit = 'Deposit',
    Withdraw = 'Withdraw',
    TransferIn = 'TransferIn',
    TransferOut = 'TransferOut',
}

---@alias modDataEntry (string | integer)[]
---@alias modData table<string, modDataEntry>
