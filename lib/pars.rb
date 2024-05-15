require 'mechanize'
require 'mysql2'
require 'nokogiri'

module Parser
  class Mosaic
    def self.run

      driver = O14::WebBrowser.get_driver
      db = O14::DB.get_db

      # Создаем экземпляр Mechanize
      @agent = Mechanize.new

      headers = {
        'host' => 'www.amazon.com',
        'user-agent' => 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
        'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'accept-language' => 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'accept-encoding' => 'gzip, deflate, br, zstd',
        'upgrade-insecure-requests' => 1,
        'sec-fetch-dest' => 'document',
        'sec-fetch-mode' => 'navigate',
        'sec-fetch-site' => 'same-origin',
        'connection' => 'keep-alive',
        'cookie' => 'session-id=134-9346825-3549307; ubid-main=135-3288814-5967735; x-main="yabq?Ncy6gVzDfSnj06z8NkBu78cHLKe4QcMlkl7AP40lf6ebDs8bXMeA189lyEr"; at-main=Atza|IwEBICK34oX7TI5cwZF5EFdpJPCChsagmH0SfTiPBt6u9WP230Es8PE2zJ24cjSXH4dL772p8NUCQqpiZy1rvJkSiLtSNImjR_im13UnfuoHtmmkmsYbZw1_-Kq5qpjVmcTLhIZU93uAU8-d-sH6Q7dLfxs-hLJQogWo0eVf-ZlspbZy9-_1b9qrn3FZH4sVQbW2Nt4av-dSwEOFMU8BZmovpzPbozCaxD1MNHNqShcfU3NAPg; sess-at-main="znUvWopJIDUsHdLH47k3Yhol7ad+m5m+jPEilXF0o0k="; sst-main=Sst1|PQF1R1AZby-6UYG7VqDx8797CQyX_jc6vCkCUWOIkz4XShd_VT24y5fzLHPuOpBB6GzuAD2A8LhZaNmPJswyR6ZiteJkesk3wSThafAgTN78EtPdnyNuTg7qrJjC3uEWi2Pd4z7CtMPu0A9US__yoOq8GO0aRxIJ1AwOAGJQr-dysSpnNbrWhdkGRPCvyAjOtpAB_P1ABttjk2xvLVNBOFxaKICn72LhZ2BN_FQQga2fnHKQLMVnzZGIvLipcEIHPrjBKJJ3Lk5QF13mjuMYx8ceTA-A5XgJ4MiyyunYwYvJXVk; lc-main=en_US; session-id-time=2082787201l; i18n-prefs=USD; session-token=1BaTGtdXysiwvFJBdamdM8z9LICkQoUSTdLgfUmQdvBgVWoVMtYt7O6DFkFO9KH2nvXZ6qg7vz5grjrhuFohBE7juORZXfSLS2Agaf3BIgfakmgI95ZLvK79vbe6ggxrDjmElQA0qUCgq2IEvN1tdUjhYqAYEqncOr8BLqE0OhKziUMRm/wCk1Cndc83XUx+HISJC1FvLrAY8yD/UOliZGUKIz8h200IrsVcC9D/67mKLY7bUnMAx8SOcOv1uJ6oVqLOz0knKnBDS370fyC50tB47FyH8XY/1iS93CkD91Chz2UjJuo0gPqPzx8220Ys8+c7Cf746rI4EK/xhOzJiYBUc0kv20Ahcw5QGrz/7V8yZv0m0inoiGq4fyFtT5+J; csm-hit=tb:s-D0TQ70SMSNMZ64BW4S8G|1714217643142&t:1714217646290&adb:adblk_no',
        'pragma' => 'no-cache',
        'cache-control' => 'max-age=0'
      }

      # Настройки подключения к базе данных
      # client = Mysql2::Client.new(
      #   host: '127.0.0.1', # Адрес сервера базы данных
      #   port: '3306',
      #   username: 'root', # Имя пользователя
      #   password: 'example', # Пароль пользователя
      #   database: 'mosaic24_test' # Имя базы данных
      # )

      # SQL-запрос для выборки данных из колонки "url"
      query = "SELECT url FROM goods"

      # Выполнение запроса к базе данных

      word_to_remove = 'New'
      word_to_remove2 = 'all'
      id = 0


      results = db[query].all
      # Обработка результатов запроса
      results.each do |row|
        id += 1
        url = row[:url]

        # Selenium
        driver.navigate.to(url)
        # Цена
        current_price_text = driver.find_element(css: '.a-box-inner span.a-price>.a-offscreen').attribute("innerHTML").scan(/\d+\.\d+/).first.to_f rescue 0
        # Другие продавцы
        new_offers_el = driver.find_element(css: '.olp-text-box span').scan(/\d+/).first.to_i rescue nil
        new_offers_el ||= driver.find_element(css: '#dynamic-aod-ingress-box .a-declarative span').attribute('innerHTML').scan(/\d+/).first.to_i rescue 0

        # Ранк
        product_details_el = driver.find_element(css: '.detail-bullets-wrapper') rescue nil
        if product_details_el
          item_html = product_details_el.attribute("outerHTML")
          item_el = Nokogiri::HTML5(item_html)
          rank_el = item_el.xpath("//*[contains(text(), 'Best Sellers Rank')]/parent::*").first.text.scan(/\d+,\d+/).first.gsub(',', '').to_i rescue 0
        else
          rank_el = driver.find_element(xpath: "//th[contains(text(), 'Best Sellers Rank')]/parent::tr/td").text.scan(/\d+,\d+/).first.gsub(',', '').to_i rescue 0
        end


        # Mechanize
        response = @agent.get(url, [], row['url'], headers)
        # Находим цену продукта на странице
        product_price = response.search("span.aok-offscreen")[0].text.to_s.strip.scan(/\d+\.\d+/).first.to_f rescue 0

        sellers_info = response.search('.a-declarative .a-color-base').text.match(/New \(.*?\d+\)/).to_s.sub(/\b#{word_to_remove}\b/, '').strip.scan(/\d+/)[0].strip.scan(/\d+/)[0].to_i rescue nil
        sellers_info ||= response.search('.a-declarative .a-box-inner .a-section .a-size-base').text.scan(/\.*?\d+/)[0].to_i rescue nil?
        sellers_info ||= response.search('.a-declarative .a-link-normal > span').text.match(/all.?\d+\ /).to_s.sub(/\b#{word_to_remove2}\b/, '').to_i rescue 0
        check = response.search('.a-declarative .a-color-base').text.match(/\(.*?\d+\)/)
        if check == nil
          sellers_info = response.search('.a-declarative .a-link-normal > span').text.match(/all.?\d+\ /).to_s.sub(/\b#{word_to_remove2}\b/, '').to_i rescue 0
        end

        # Находим элемент с информацией о Best Sellers Rank
        best_sellers_rank = response.search('.zgFirstRank').text.scan(/\d+,\d+/).first.gsub(',', '').to_i rescue 0
        #client.query("INSERT INTO goods(id, url, browser_price, browser_rank, browser_new_count, xhr_price, xhr_rank, xhr_new_count) VALUES (#{id}, \"#{url}\", \"#{current_price_text}\", \"#{rank_el}\", \"#{new_offers_el}\", \"#{product_price}\", \"#{best_sellers_rank}\", \"#{sellers_info}\")")
        db[:goods].where(id:id).update(browser_price:current_price_text, browser_rank:rank_el, browser_new_count:new_offers_el, xhr_price:product_price, xhr_rank:best_sellers_rank, xhr_new_count:sellers_info)
        #("UPDATE goods SET browser_price = \"#{current_price_text}\", browser_rank = \"#{rank_el}\", browser_new_count = \"#{new_offers_el}\", xhr_price = \"#{product_price}\", xhr_rank = \"#{best_sellers_rank}\", xhr_new_count = \"#{sellers_info}\" WHERE id = #{id} ")


      end

      # Закрытие драйвера Selenium
      driver.quit

      # Закрытие соединения с базой данных
      client.close
    end
  end
end


