class Variant
  attr_reader :title, :grams, :price

  def initialize(variant)
    @title = variant["title"] if variant["title"]
    @grams = variant["grams"] if variant["grams"]
    @price = variant["price"] if variant["price"]
  end
end
