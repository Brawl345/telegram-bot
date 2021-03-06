do

local function get_br_article(article)
  local url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url=%22http://www.br.de/nachrichten/'..article..'.html%22%20and%20xpath=%22//div[@id=%27content%27]/div[1]/div[2]/div[1]|//div[@class=%27lead_picture%27]/img%22&format=json'
  local res,code  = https.request(url)
  local data = json:decode(res).query.results
  if code ~= 200 then return "HTTP-Fehler" end
  if not data then return "HTTP-Fehler" end
  
  local subtitle = data.div.h1.em
  local title = string.sub(data.div.h1.content, 3)
  local teaser = string.sub(data.div.p[1].content, 2)
  if data.div.p[3] then
    updated = data.div.p[3].content
  else
    updated = data.div.p[2].content
  end
  if data.img then
    image_url = 'https://www.br.de'..data.img.src
  end
  local text = subtitle..' - '..title..'\n'..teaser..'\n'..updated
  
  if data.img then
    return text, image_url
  else
    return text
  end
end

local function run(msg, matches)
  local article = URL.escape(matches[1])
  local text, image_url = get_br_article(article)
  if image_url then
    local receiver = get_receiver(msg)
    local file = download_to_file(image_url, 'br_teaser.jpg')
    send_photo(receiver, file, ok_cb, false)
  end
  return text
end

return {
  description = "Sendet BR-Artikel", 
  usage = "Link zu BR-Artikel",
  patterns = {"br.de/nachrichten/(.*).html$"},
  run = run 
}

end