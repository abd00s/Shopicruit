require "HTTParty"

class Api
  include HTTParty

  def get_products
    response = HTTParty.get('http://shopicruit.myshopify.com/products.json')
    response["products"]
  end
end