# lib/parser/example.rb
require 'selenium-webdriver'
require_relative '../models/amazon_product'
require 'uri'
require 'cgi'

module Parser
  class Example
    def self.run(url)
      logger = O14::ProjectLogger.get_logger
      driver = O14::WebBrowser.get_driver
      config = O14::Config.get_config
      db = O14::DB.get_db

      begin
        
        loop do
          driver.navigate.to url
          sleep 5
          page_number = extract_page_number_from_pagination(driver)
          puts "Current page: #{page_number}"
          category_from_url = extract_category_from_url(url)
          category_from_page = extract_category_from_page(driver)

          category = category_from_page || category_from_url

          products = driver.find_elements(css: '.s-main-slot .s-result-item')

          products.each do |product|
            product_id = product.attribute('data-asin')
            next if product_id.nil? || product_id.empty?

            begin
              title = product.find_element(css: 'h2 .a-size-mini').text.strip
            rescue
              title = nil
            end

            begin
              price_whole = product.find_element(css: '.a-price .a-price-whole').text.gsub(',', '').to_f
              price_fraction = product.find_element(css: '.a-price .a-price-fraction').text.to_f
              price = price_whole + (price_fraction / 100)
            rescue
              price = nil
            end

            begin
              rating = product.find_element(css: '.a-icon-alt').text.split.first.to_f
            rescue
              rating = nil
            end

            begin
              review_count = product.find_element(css: '.s-link-style .a-size-base').text.gsub(',', '').to_i
            rescue
              review_count = nil
            end

            begin
              availability = product.find_element(css: '.a-size-base .a-color-price').text.strip
            rescue
              availability = nil
            end

            begin
              image_url = product.find_element(css: '.s-image').attribute('src')
            rescue
              image_url = nil
            end

            begin
              product_url = "https://www.amazon.com#{product.find_element(css: 'h2 .a-size-mini').attribute('href')}"
            rescue
              product_url = nil
            end

            begin
              AmazonProduct.create(
                product_id: product_id,
                title: title,
                price: price,
                rating: rating,
                review_count: review_count,
                availability: availability,
                category: category,
                image_url: image_url,
                product_url: product_url
              )
            rescue Sequel::UniqueConstraintViolation
              puts "Duplicate entry for product_id: #{product_id}. Skipping."
            end
          end

          # Переход к следующей странице
          next_button = driver.find_elements(css: 'a.s-pagination-next')
          if next_button.empty?
            puts "No more pages. Finished."
            break
          else
            url = next_button.first.attribute('href')
            page_number = extract_page_number_from_pagination(driver)
            puts "Moving to the next page: #{page_number+1}"
          end
        end
      ensure
        driver.quit
      end
    end

#    def self.extract_page_number_from_url(url)
#      uri = URI.parse(url)
#      params = CGI.parse(uri.query)
#      page_number = params['page']&.first&.to_i
#      page_number = 1 if page_number.nil? || page_number.zero?
#      page_number
#    end

    def self.extract_page_number_from_pagination(driver)
      current_page_element = driver.find_element(css: 'span.s-pagination-item.s-pagination-selected[aria-label^="Current page"]')
      current_page_element.text.to_i
    end

    def self.extract_category_from_url(url)
      uri = URI.parse(url)
      params = CGI.parse(uri.query)
      params['i']&.first
    end

    def self.extract_category_from_page(driver)
      begin
        breadcrumb = driver.find_element(css: 'nav.a-breadcrumb .a-breadcrumb-item')
        breadcrumb.text.strip
      rescue
        nil
      end
    end
  end
end
