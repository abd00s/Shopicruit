require  "./shopicruit"

describe 'Shopicruit' do
  let(:test) {Shopicruit.new(100,["Keyboard", "Computer"])}
  let(:sample_products) {[
    {
      "title" => "Sample Product 1",
      "product_type" => "Keyboard",
      "variants" => [
        {
          "title" => "Sample Variant 1-a",
          "price" => "10",
          "grams" => 3000
        },
        {
          "title" => "Sample Variant 1-b",
          "price" => "15",
          "grams" => 2000
        }
      ]
    },
    {
      "title" => "Sample Product 2",
      "product_type" => "Computer",
      "variants" => [
        {
          "title" => "Sample Variant 2-a",
          "price" => "13",
          "grams" => 5000
        },
        {
          "title" => "Sample Variant 2-b",
          "price" => "8",
          "grams" => 4000
        }
      ]
    },
    {
      "title" => "Sample Product 3",
      "product_type" => "Keyboard",
      "variants" => [
        {
          "title" => "Sample Variant 3-a",
          "price" => "17",
          "grams" => 1000
        }
      ]
    },
    {
      "title" => "Sample Product 4",
      "product_type" => "Wallet",
      "variants" => [
        {
          "title" => "Sample Variant 4-a",
          "price" => "12",
          "grams" => 100
        }
      ]
    }
  ]}

  describe '#initialize' do
    it 'instantiates Shopicruit with initial state' do
      expect(test).to have_attributes(
        limit: 100,
        desired_categories: ["Keyboard", "Computer"],
        desirable_products: [],
        desirable_variants: [],
        products_to_purchase: [],
        message: []
      )
    end
  end

  describe "#filter_products" do
    it "populates our instance's @desirable_products" do
      expect {test.filter_products(sample_products)}.to change {test.desirable_products.empty?}
      .from(true).to(false)
    end

    it "only selects products matching our required categories" do
      test.filter_products(sample_products)
      expect(test.desirable_products). to all satisfy { |product|
        product.type == "Computer" || product.type == "Keyboard"
      }
    end

    it "populates instance's @desirable_products with Product objects" do
      test.filter_products(sample_products)
      expect(test.desirable_products). to all be_instance_of(Product)
    end
  end

  describe "#find_all_desirable_variants" do
    it "populates our instance's @desirable_variants" do
      test.filter_products(sample_products) #products need to be populate beforehand
      expect {test.find_all_desirable_variants}
      .to change {test.desirable_variants.empty?}
      .from(true).to(false)
    end

    it "associates each variant to its parent product" do
      test.filter_products(sample_products)
      test.find_all_desirable_variants
      expect(test.desirable_variants). to all satisfy { |variant|
        variant.parent.type == "Computer" || variant.parent.type == "Keyboard"
      }
    end

    it "populates instance's @desirable_variants with Variant objects" do
      test.filter_products(sample_products)
      test.find_all_desirable_variants
      expect(test.desirable_variants). to all be_instance_of(Variant)
    end
  end
end