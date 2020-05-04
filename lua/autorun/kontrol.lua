util = util or {}

---------------------------------------
-- AbitraryPrecision by someone :s
---------------------------------------
 
AbitraryPrecision = {}
function AbitraryPrecision.__MakeTable(v)
    local v = tostring(v)
    local t = {}
    for k=1,v:len() do
        t[k] = v:sub(k,k)
    end
    return t
end
function AbitraryPrecision.__MakeString(v)
    local len = #v
    local str = ""
    while(len > 0) do
        str = str..v[len]
        len = len - 1
    end
    return str
end
function AbitraryPrecision.Add(a,b)
    local A = AbitraryPrecision.__MakeTable(a)
    local B = AbitraryPrecision.__MakeTable(b)
     
    local pos1 = #A
    local pos2 = #B
    local pos3 = 1
    local C = {}
    local overflow = 0
    while(pos1 > 0 or pos2 > 0) do
        local digit = (A[pos1] or 0) + (B[pos2] or 0) + overflow
        overflow = 0
        if(digit > 9) then
            overflow = 1
            digit = digit - 10
        end
        C[pos3] = digit
        pos1 = pos1 - 1
        pos2 = pos2 - 1
        pos3 = pos3 + 1
    end
    if(overflow == 1) then
        C[pos3] = 1
    end
 
    return AbitraryPrecision.__MakeString(C)
end
function AbitraryPrecision.Sub(a,b)
    local A = AbitraryPrecision.__MakeTable(a)
    local B = AbitraryPrecision.__MakeTable(b)
     
    local pos1 = #A
    local pos2 = #B
    local pos3 = 1
    local C = {}
    local overflow = 0
    while(pos1 > 0 or pos2 > 0) do
        local digit = (A[pos1] or 0) - (B[pos2] or 0) - overflow
        overflow = 0
        if(digit < 0) then
            overflow = 1
            digit = digit + 10
        end
        C[pos3] = digit
        pos1 = pos1 - 1
        pos2 = pos2 - 1
        pos3 = pos3 + 1
    end
    if(overflow == 1) then
        C[pos3] = 1
    end
     
    return AbitraryPrecision.__MakeString(C)
end
 
------------------------
 
---------------------------------------
-- SteamID <-> Community ID
---------------------------------------
local OFFSET = "76561197960265728"
 
SteamID64 = SteamID64 or function(steamid)
    local data = string.Explode(":",steamid)
     
    if !data[3] or !data[2] then return false end
     
    return AbitraryPrecision.Add(data[2] + 2*data[3],OFFSET) --  A + 2*B + OFFSET
end
util.SteamID64=SteamID64
 
 
SteamIDString =  SteamIDString or function(steamid64)
    if type(steamid64) ~= "number" or steamid64 < 76561197960265728 then return false end
     
    local id = AbitraryPrecision.Sub(steamid64,OFFSET) --  A + 2*B
    local A = (id % 2)
    local B = (id - A)/2
 
    return "STEAM_0:"..A..":"..B
end
 
util.SteamIDString=SteamIDString