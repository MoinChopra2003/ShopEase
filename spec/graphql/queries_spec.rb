require 'rails_helper'

RSpec.describe 'GraphQL Queries', type: :request do
  describe 'me query' do
    context 'when user is authenticated' do
      let(:user) { create(:user) }
      let(:token) { JsonWebToken.encode(user_id: user.id) }

      it 'returns current user info' do
        query = <<~GQL
          query {
            me {
              id
              name
              email
              status
            }
          }
        GQL

        post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['me']['id']).to eq(user.id.to_s)
        expect(json['data']['me']['email']).to eq(user.email)
      end
    end

    context 'when user is not authenticated' do
      it 'returns nil' do
        query = <<~GQL
          query {
            me {
              id
              name
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['me']).to be_nil
      end
    end
  end

  describe 'categories query' do
    before { create_list(:category, 3) }

    it 'returns all categories' do
      query = <<~GQL
        query {
          categories {
            id
            name
            description
          }
        }
      GQL

      post '/graphql', params: { query: query }
      
      json = JSON.parse(response.body)
      expect(json['data']['categories'].length).to eq(3)
      expect(json['data']['categories'][0]).to have_key('id')
      expect(json['data']['categories'][0]).to have_key('name')
    end
  end

  describe 'products query' do
    let(:category) { create(:category) }
    let!(:product1) { create(:product, category: category, active: true, price: 100, stock: 10) }
    let!(:product2) { create(:product, category: category, active: true, price: 200, stock: 20) }
    let!(:product3) { create(:product, category: category, active: false, price: 50, stock: 5) }
    let!(:product4) { create(:product, active: true, price: 150, stock: 0) }

    context 'without filters' do
      it 'returns all active products with pagination' do
        query = <<~GQL
          query {
            products(page: 1, perPage: 10) {
              id
              name
              price
              stock
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['products'].length).to eq(3)
        expect(json['data']['products'].map { |p| p['id'].to_i }.sort).to eq([product1.id, product2.id, product4.id].sort)
      end
    end

    context 'with search filter' do
      it 'returns products matching search' do
        product1.update(name: 'Unique Product Name')
        
        query = <<~GQL
          query {
            products(search: "Unique") {
              id
              name
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['products'].length).to eq(1)
        expect(json['data']['products'][0]['name']).to include('Unique')
      end
    end

    context 'with category filter' do
      it 'returns products from specific category' do
        query = <<~GQL
          query {
            products(categoryId: #{category.id}) {
              id
              name
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['products'].length).to eq(2)
      end
    end

    context 'with price filters' do
      it 'filters by minimum price' do
        query = <<~GQL
          query {
            products(minimumPrice: 150) {
              id
              price
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        prices = json['data']['products'].map { |p| p['price'].to_f }
        expect(prices.all? { |p| p >= 150 }).to be true
      end

      it 'filters by maximum price' do
        query = <<~GQL
          query {
            products(maximumPrice: 150) {
              id
              price
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        prices = json['data']['products'].map { |p| p['price'].to_f }
        expect(prices.all? { |p| p <= 150 }).to be true
      end
    end

    context 'with inStockOnly filter' do
      it 'returns only products with stock' do
        query = <<~GQL
          query {
            products(inStockOnly: true) {
              id
              stock
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        stocks = json['data']['products'].map { |p| p['stock'].to_i }
        expect(stocks.all? { |s| s > 0 }).to be true
      end
    end

    context 'with sorting' do
      it 'sorts by price ascending' do
        query = <<~GQL
          query {
            products(sort: "price_asc") {
              id
              price
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        prices = json['data']['products'].map { |p| p['price'].to_f }
        expect(prices).to eq(prices.sort)
      end

      it 'sorts by price descending' do
        query = <<~GQL
          query {
            products(sort: "price_desc") {
              id
              price
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        prices = json['data']['products'].map { |p| p['price'].to_f }
        expect(prices).to eq(prices.sort.reverse)
      end
    end

    context 'with pagination' do
      it 'respects page and perPage arguments' do
        create_list(:product, 15, active: true)
        
        query = <<~GQL
          query {
            products(page: 2, perPage: 5) {
              id
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['products'].length).to eq(5)
      end
    end
  end

  describe 'product query' do
    let(:product) { create(:product, active: true) }

    context 'when product exists and is active' do
      it 'returns product details' do
        query = <<~GQL
          query {
            product(id: #{product.id}) {
              id
              name
              price
              stock
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['product']['id']).to eq(product.id.to_s)
        expect(json['data']['product']['name']).to eq(product.name)
      end
    end

    context 'when product is inactive' do
      it 'returns null' do
        product.update(active: false)
        
        query = <<~GQL
          query {
            product(id: #{product.id}) {
              id
              name
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['product']).to be_nil
      end
    end

    context 'when product does not exist' do
      it 'returns null' do
        query = <<~GQL
          query {
            product(id: 99999) {
              id
              name
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['product']).to be_nil
      end
    end
  end

  describe 'addresses query' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let!(:address) { create(:address, user: user) }

    context 'when user is authenticated' do
      it 'returns user addresses' do
        query = <<~GQL
          query {
            addresses {
              id
              label
              recipientName
            }
          }
        GQL

        post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['addresses'].length).to eq(1)
        expect(json['data']['addresses'][0]['id']).to eq(address.id.to_s)
      end
    end

    context 'when user is not authenticated' do
      it 'returns empty array' do
        query = <<~GQL
          query {
            addresses {
              id
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['addresses']).to eq([])
      end
    end
  end

  describe 'supportArticles query' do
    let!(:article1) { create(:support_article, active: true, position: 1) }
    let!(:article2) { create(:support_article, active: true, position: 2) }
    let!(:article3) { create(:support_article, active: false, position: 3) }

    context 'without filters' do
      it 'returns all support articles ordered by position' do
        query = <<~GQL
          query {
            supportArticles {
              id
              title
              active
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['supportArticles'].length).to eq(3)
      end
    end

    context 'with active filter' do
      it 'returns only active articles' do
        query = <<~GQL
          query {
            supportArticles(active: true) {
              id
              active
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['supportArticles'].length).to eq(2)
        expect(json['data']['supportArticles'].all? { |a| a['active'] }).to be true
      end
    end
  end

  describe 'orders query' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let!(:order1) { create(:order, user: user, status: 'pending') }
    let!(:order2) { create(:order, user: user, status: 'confirmed') }
    let!(:order3) { create(:order, user: user, status: 'shipped') }

    context 'when user is authenticated' do
      it 'returns user orders' do
        query = <<~GQL
          query {
            orders {
              id
              orderNumber
              status
            }
          }
        GQL

        post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['orders'].length).to eq(3)
      end

      context 'with status filter' do
        it 'filters orders by status' do
          query = <<~GQL
            query {
              orders(status: "pending") {
                id
                status
              }
            }
          GQL

          post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
          
          json = JSON.parse(response.body)
          expect(json['data']['orders'].length).to eq(1)
          expect(json['data']['orders'][0]['status']).to eq('pending')
        end
      end

      context 'with pagination' do
        it 'respects pagination arguments' do
          query = <<~GQL
            query {
              orders(page: 1, perPage: 2) {
                id
              }
            }
          GQL

          post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
          
          json = JSON.parse(response.body)
          expect(json['data']['orders'].length).to eq(2)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns empty array' do
        query = <<~GQL
          query {
            orders {
              id
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['orders']).to eq([])
      end
    end
  end

  describe 'order query' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:order) { create(:order, user: user) }

    context 'when user is authenticated and owns order' do
      it 'returns order details' do
        query = <<~GQL
          query {
            order(id: #{order.id}) {
              id
              orderNumber
              status
            }
          }
        GQL

        post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['order']['id']).to eq(order.id.to_s)
      end
    end

    context 'when user does not own order' do
      it 'returns nil' do
        other_order = create(:order, user: other_user)
        
        query = <<~GQL
          query {
            order(id: #{other_order.id}) {
              id
            }
          }
        GQL

        post '/graphql', params: { query: query }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['order']).to be_nil
      end
    end

    context 'when user is not authenticated' do
      it 'returns nil' do
        query = <<~GQL
          query {
            order(id: #{order.id}) {
              id
            }
          }
        GQL

        post '/graphql', params: { query: query }
        
        json = JSON.parse(response.body)
        expect(json['data']['order']).to be_nil
      end
    end
  end
end
