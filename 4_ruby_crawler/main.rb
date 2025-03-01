require 'nokogiri'
require 'open-uri'

def fetch_products(url)
  headers = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
  }

  retries = 5
  begin
    html = URI.open(url, headers)
    document = Nokogiri::HTML(html)
    puts "Fetching...: #{url}"

    document.css('div[role="listitem"]').each do |item|
      product_title = item.at_css('h2.a-size-base-plus')
      if product_title&.text&.strip
        product_title = product_title.text.strip
        price = item.at_css('.a-price .a-offscreen')&.text&.strip
        puts "Product name: #{product_title}"
        puts "Price: #{price}"
        puts "\n"
      else
        next
      end
    end
  rescue OpenURI::HTTPError => e
    if retries > 0
      puts "Failed with error: #{e.message}"
      retries -= 1
      sleep 5
      retry
    end
  end
end

print "Enter a key word: "
key_word = gets.chomp
url = "https://www.amazon.com/s?k=#{URI.encode_www_form_component(key_word)}"
fetch_products(url)
