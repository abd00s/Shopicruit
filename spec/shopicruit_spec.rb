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

  describe "#price_of_variants" do
    it "sums input variants' price"  do
      test.filter_products(sample_products)
      test.find_all_desirable_variants
      expect(test.price_of_variants(test.desirable_variants)).to eq(63.0)
    end
  end

  context "-Limit is high enough to purchase all products" do
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

  context "-Limit is low, can purchase some products or none." do
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
            # # Uncomment to see details in output
            # context_4.acceptable_combinations_of_size_i(context_4.desirable_variants, i, context_4.limit).each do |comb|
            #   combination = "("
            #   comb.each {|i| combination += "[#{i.title}, #{i.weight} KG]"}
            #   combination << ")"
            #   puts "\t"+combination
            #   puts "\tTotal weight of this combination is #{context_4.weight_of_variants(comb)} KG; which is within the limit of #{context_4.limit} KG"
            #   puts
            # end
          end
        end
      end
    end

    context "--Limit is too low, can't purchase any product" do
      describe "#find_combinations" do
        it "returns an empty array (of products) because they're each individually too heavy" do
          context_2.filter_products(sample_products)
          context_2.find_all_desirable_variants
          expect(context_2.find_combinations(context_2.desirable_variants,context_2.limit))
          .to eq([])
        end
      end

      describe "#find_carriable_combo" do
        it "does not add any product to @products_to_purchase" do
          expect {context_2.find_carriable_combo(context_2.desirable_variants, context_2.limit)}
          .to_not change {context_2.products_to_purchase.count}
        end

        it "updates output @message to \"All variants are too heavy, you can't purchase any.\"" do
          context_2.filter_products(sample_products)
          context_2.find_all_desirable_variants
          expect {context_2.find_carriable_combo(context_2.desirable_variants, context_2.limit)}
          .to change {context_2.message}
          .from([]).to("All variants are too heavy, you can't purchase any.")
        end
      end
    end

    context "--Limit allows purchase of some products, but not all" do
      describe "#find_carriable_combo" do
        it "updates output @message to \"This selection of variants is the most you can carry while remaining under the limit\"" do
          context_3.filter_products(sample_products)
          context_3.find_all_desirable_variants
          expect {context_3.find_carriable_combo(context_3.desirable_variants, context_3.limit)}
          .to change {context_3.message}
          .from([]).to("This selection of variants is the most you can carry while remaining under the limit")
        end
      end

      context "---Produces one purchasable combination" do
        describe "#find_combinations" do
          it "returns `only` one selection of purchasable products" do
            context_3.filter_products(sample_products)
            context_3.find_all_desirable_variants
            expect(context_3.find_combinations(context_3.desirable_variants, context_3.limit).size)
            .to eq(1)
          end
        end
      end

      context "---Produces multiple purchasable combinations" do
        describe "#find_combinations" do
          it "returns all combinations of purchasable products" do
            context_4.filter_products(sample_products)
            context_4.find_all_desirable_variants
            expect(context_4.find_combinations(context_4.desirable_variants, context_4.limit).size)
            .to be > 1
          end
        end

        describe "#select_cheapest_combination" do
          it "out of possible purchasable combinations, selects the cheapest" do
            context_4.filter_products(sample_products)
            context_4.find_all_desirable_variants
            combinations = context_4.find_combinations(context_4.desirable_variants, context_4.limit)
            price_of_combinations = Hash.new
            combinations.each_with_index {|c, i| price_of_combinations["combination #{i+1}"] = context_4.price_of_variants(c)}
            minimmum_price = price_of_combinations.values.min
            selected_combination = context_4.select_cheapest_combination(combinations)

            # # Uncomment to see details in output
            # combinations.each do |comb|
            #   combination = "("
            #   comb.each {|i| combination += "[#{i.title}, #{i.weight} KG, $#{i.price}]"}
            #   combination << ")"
            #   puts "\t\t"+combination
            #   puts "\t\tTotal weight of this combination is #{context_4.weight_of_variants(comb)} KG; which is within the limit of #{context_4.limit} KG"
            #   puts "\t\tTotal price of this combination is $#{context_4.price_of_variants(comb)}"
            #   puts
            # end

            expect(context_4.price_of_variants(selected_combination))
            .to eq(minimmum_price)
          end
        end
      end
    end
  end
end




















