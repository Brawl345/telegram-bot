-- See https://bitcoinaverage.com/api
local function getBTCX(amount,currency)
  local base_url = 'https://api.bitcoinaverage.com/ticker/global/'
  -- Do request on bitcoinaverage, the final / is critical!
  local res,code  = https.request(base_url..currency.."/")
  
  if code ~= 200 then return nil end
  local data = json:decode(res)
  local ask = string.gsub(data.ask, "%.", "%,")
  local bid = string.gsub(data.bid, "%.", "%,")

  -- Easy, it's right there
  text = "BTC/"..currency..'\n'..'Kaufen: '..ask..'\n'..'Verkaufen: '..bid
  
  -- If we have a number as second parameter, calculate the bitcoin amount
  if amount~=nil then
    btc = tonumber(amount) / tonumber(data.ask)
    text = text.."\n "..currency .." "..amount.." = BTC "..btc
  end
  return text
end

local function run(msg, matches)
  local cur = 'EUR'
  local amt = nil

  -- Get the global match out of the way
  if matches[1] == "!btc" then 
    return getBTCX(amt,cur) 
  end

  if matches[2] ~= nil then
    -- There is a second match
    amt = matches[2]
    cur = string.upper(matches[1])
  else
    -- Just a EUR or USD param
    cur = string.upper(matches[1])
  end
  return getBTCX(amt,cur)
end

return {
  description = "Globaler Bitcoin-Wert (in EUR oder USD)",
  usage = {
    "!btc: Zeigt aktuellen Bitcoin-Kurs",
	"!btc [EUR|USD] [Menge]: Rechnet Bitcoin in Euro/USD um"
  },
  patterns = {
	"^!btc$",
    "^!btc ([Ee][Uu][Rr])$",
    "^!btc ([Uu][Ss][Dd])$",
    "^!btc (EUR) (%d+[%d%.]*)$",
    "^!btc (USD) (%d+[%d%.]*)$"
  }, 
  run = run 
}

