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
      expect(test.desirable_products).to all satisfy { |product|
        product.type == "Computer" || product.type == "Keyboard"
      }
    end

    it "populates instance's @desirable_products with Product objects" do
      test.filter_products(sample_products)
      expect(test.desirable_products).to all be_instance_of(Product)
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
      expect(test.desirable_variants).to all satisfy { |variant|
        variant.parent.type == "Computer" || variant.parent.type == "Keyboard"
      }
    end

    it "populates instance's @desirable_variants with Variant objects" do
      test.filter_products(sample_products)
      test.find_all_desirable_variants
      expect(test.desirable_variants).to all be_instance_of(Variant)
    end
  end

  describe "#weight_of_variants" do
    it "sums input variants' weight"  do
      test.filter_products(sample_products)
      test.find_all_desirable_variants
      expect(test.weight_of_variants(test.desirable_variants)).to eq(15.0)
    end
  end

  context "Limit is high enough to purchase all products" do
    let(:context_1) { Shopicruit.new(16,["Keyboard", "Computer"]) }
    describe "#find_carriable_combo" do
      it "adds all filtered products to @products_to_purchase" do
        context_1.filter_products(sample_products)
        context_1.find_all_desirable_variants
        expect {context_1.find_carriable_combo(context_1.desirable_variants, context_1.limit)}
        .to change {context_1.products_to_purchase.count}.from(0).to(5)
      end

      it "updates output @message to \"The total weight of all desired variants is under the weight limit you may purchase all.\"" do
        context_1.filter_products(sample_products)
        context_1.find_all_desirable_variants
        expect {context_1.find_carriable_combo(context_1.desirable_variants, context_1.limit)}
        .to change {context_1.message}
        .from([]).to("The total weight of all desired variants is under the weight limit you may purchase all.")
      end
    end
  end

  context "Limit is low, can purchase some products or none." do
    let(:context_2) { Shopicruit.new(0.5,["Keyboard", "Computer"]) }
    let(:context_3) { Shopicruit.new(6,["Keyboard", "Computer"]) }
    let(:context_4) { Shopicruit.new(7,["Keyboard", "Computer"]) }
    describe  "#acceptable_combinations_of_size_i" do
      it "finds combinations (subsets/groupings) of input variants that are within the limit" do
        context_4.filter_products(sample_products)
        context_4.find_all_desirable_variants
        context_4.desirable_variants.count.downto(1) do |i|
          if context_4.acceptable_combinations_of_size_i(context_4.desirable_variants, i, context_4.limit).size > 0
            expect(context_4.acceptable_combinations_of_size_i(context_4.desirable_variants, i, context_4.limit))
            .to all satisfy { |comb| context_4.weight_of_variants(comb) <= context_4.limit }
            # Uncomment to see details in output
            # context_4.acceptable_combinations_of_size_i(context_4.desirable_variants, i, context_4.limit).each do |comb|
            #   combination = "("
            #   comb.each {|i| combination += "[#{i.title}, #{i.grams}]"}
            #   combination << ")"
            #   puts "\t"+combination
            #   puts "\tTotal weight of this combination is #{context_4.weight_of_variants(comb)}; which is within the limit #{context_4.limit}"
            #   puts
            # end
          end
        end
      end
    end
  end
end




















