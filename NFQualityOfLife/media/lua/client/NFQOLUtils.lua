NFQOLUtils = {}

function NFQOLUtils.wipe(tbl)
    for i = 0, #tbl do
        tbl[i] = nil
    end
    return tbl
end