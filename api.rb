require "HTTParty"

module Api
  def self.get_products
    begin
      response = HTTParty.get('http://shopicruit.myshopify.com/products.json')
      response["products"]
    rescue SocketError
      []
    end
  end
end