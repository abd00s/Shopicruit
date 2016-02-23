class Variant
  attr_reader :title, :weight, :price, :parent

  def initialize(variant, parent)
    @title = variant["title"] if variant["title"]
    @weight = variant["grams"].to_f/1000 if variant["grams"]
    @price = variant["price"].to_f if variant["price"]
    @parent = parent
  end
end
