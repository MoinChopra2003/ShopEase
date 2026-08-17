require 'rails_helper'

RSpec.describe 'GraphQL Mutations', type: :request do
  describe 'signUp mutation' do
    context 'with valid parameters' do
      it 'creates a new user' do
        mutation = <<~GQL
          mutation SignUp($name: String!, $email: String!, $password: String!, $passwordConfirmation: String!) {
            signUp(name: $name, email: $email, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
                name
                email
              }
              errors
            }
          }
        GQL

        variables = {
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecurePassword123!',
          passwordConfirmation: 'SecurePassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['signUp']['user']).to be_present
        expect(json['data']['signUp']['user']['email']).to eq('john@example.com')
        expect(json['data']['signUp']['errors']).to eq([])
      end
    end

    context 'with duplicate email' do
      it 'returns validation error' do
        create(:user, email: 'existing@example.com')
        
        mutation = <<~GQL
          mutation SignUp($name: String!, $email: String!, $password: String!, $passwordConfirmation: String!) {
            signUp(name: $name, email: $email, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          name: 'John Doe',
          email: 'existing@example.com',
          password: 'SecurePassword123!',
          passwordConfirmation: 'SecurePassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['signUp']['user']).to be_nil
        expect(json['data']['signUp']['errors']).not_to be_empty
      end
    end

    context 'with mismatched passwords' do
      it 'returns validation error' do
        mutation = <<~GQL
          mutation SignUp($name: String!, $email: String!, $password: String!, $passwordConfirmation: String!) {
            signUp(name: $name, email: $email, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecurePassword123!',
          passwordConfirmation: 'DifferentPassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['signUp']['user']).to be_nil
        expect(json['data']['signUp']['errors']).not_to be_empty
      end
    end
  end

  describe 'login mutation' do
    let(:user) { create(:user, email: 'test@example.com', password: 'SecurePassword123!', password_confirmation: 'SecurePassword123!') }

    context 'with valid credentials' do
      it 'returns user and token' do
        # Create user first
        create(:user, email: 'test@example.com', password: 'SecurePassword123!', password_confirmation: 'SecurePassword123!')
        
        mutation = <<~GQL
          mutation Login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
              user {
                id
                email
              }
              token
              errors
            }
          }
        GQL

        variables = {
          email: 'test@example.com',
          password: 'SecurePassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['login']['user']).to be_present
        expect(json['data']['login']['token']).to be_present
        expect(json['data']['login']['errors']).to eq([])
      end
    end

    context 'with invalid password' do
      it 'returns error' do
        mutation = <<~GQL
          mutation Login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
              user {
                id
              }
              token
              errors
            }
          }
        GQL

        variables = {
          email: 'test@example.com',
          password: 'WrongPassword'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['login']['user']).to be_nil
        expect(json['data']['login']['errors']).not_to be_empty
      end
    end

    context 'with nonexistent email' do
      it 'returns error' do
        mutation = <<~GQL
          mutation Login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          email: 'nonexistent@example.com',
          password: 'AnyPassword'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['login']['user']).to be_nil
        expect(json['data']['login']['errors']).not_to be_empty
      end
    end
  end

  describe 'forgotPassword mutation' do
    let(:user) { create(:user, email: 'test@example.com') }

    it 'always returns success message' do
      mutation = <<~GQL
        mutation ForgotPassword($email: String!) {
          forgotPassword(email: $email) {
            success
            message
          }
        }
      GQL

      variables = { email: 'test@example.com' }

      post '/graphql', params: { query: mutation, variables: variables }
      
      json = JSON.parse(response.body)
      expect(json['data']['forgotPassword']['success']).to be true
      expect(json['data']['forgotPassword']['message']).to be_present
    end

    it 'returns success even for nonexistent email' do
      mutation = <<~GQL
        mutation ForgotPassword($email: String!) {
          forgotPassword(email: $email) {
            success
            message
          }
        }
      GQL

      variables = { email: 'nonexistent@example.com' }

      post '/graphql', params: { query: mutation, variables: variables }
      
      json = JSON.parse(response.body)
      expect(json['data']['forgotPassword']['success']).to be true
    end
  end

  describe 'resetPassword mutation' do
    let(:user) { create(:user) }

    context 'with valid token' do
      it 'resets password' do
        user.create_reset_digest
        token = user.reset_token

        mutation = <<~GQL
          mutation ResetPassword($email: String!, $token: String!, $password: String!, $passwordConfirmation: String!) {
            resetPassword(email: $email, token: $token, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          email: user.email,
          token: token,
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['resetPassword']['user']).to be_present
        expect(json['data']['resetPassword']['errors']).to eq([])
      end
    end

    context 'with invalid token' do
      it 'returns error' do
        mutation = <<~GQL
          mutation ResetPassword($email: String!, $token: String!, $password: String!, $passwordConfirmation: String!) {
            resetPassword(email: $email, token: $token, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          email: user.email,
          token: 'invalid_token',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['resetPassword']['user']).to be_nil
        expect(json['data']['resetPassword']['errors']).not_to be_empty
      end
    end

    context 'with expired token' do
      it 'returns error' do
        user.create_reset_digest
        user.update(password_reset_sent_at: 3.hours.ago)
        token = user.reset_token

        mutation = <<~GQL
          mutation ResetPassword($email: String!, $token: String!, $password: String!, $passwordConfirmation: String!) {
            resetPassword(email: $email, token: $token, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          email: user.email,
          token: token,
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['resetPassword']['user']).to be_nil
        expect(json['data']['resetPassword']['errors']).not_to be_empty
      end
    end
  end

  describe 'changePassword mutation' do
    let(:user) { create(:user, password: 'OldPassword123!', password_confirmation: 'OldPassword123!') }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    context 'when user is authenticated' do
      context 'with correct current password' do
        it 'changes password' do
          mutation = <<~GQL
            mutation ChangePassword($currentPassword: String!, $password: String!, $passwordConfirmation: String!) {
              changePassword(currentPassword: $currentPassword, password: $password, passwordConfirmation: $passwordConfirmation) {
                user {
                  id
                }
                errors
              }
            }
          GQL

          variables = {
            currentPassword: 'OldPassword123!',
            password: 'NewPassword123!',
            passwordConfirmation: 'NewPassword123!'
          }

          post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
          
          json = JSON.parse(response.body)
          expect(json['data']['changePassword']['user']).to be_present
          expect(json['data']['changePassword']['errors']).to eq([])
        end
      end

      context 'with incorrect current password' do
        it 'returns error' do
          mutation = <<~GQL
            mutation ChangePassword($currentPassword: String!, $password: String!, $passwordConfirmation: String!) {
              changePassword(currentPassword: $currentPassword, password: $password, passwordConfirmation: $passwordConfirmation) {
                user {
                  id
                }
                errors
              }
            }
          GQL

          variables = {
            currentPassword: 'WrongPassword',
            password: 'NewPassword123!',
            passwordConfirmation: 'NewPassword123!'
          }

          post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
          
          json = JSON.parse(response.body)
          expect(json['data']['changePassword']['user']).to be_nil
          expect(json['data']['changePassword']['errors']).not_to be_empty
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns error' do
        mutation = <<~GQL
          mutation ChangePassword($currentPassword: String!, $password: String!, $passwordConfirmation: String!) {
            changePassword(currentPassword: $currentPassword, password: $password, passwordConfirmation: $passwordConfirmation) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          currentPassword: 'OldPassword123!',
          password: 'NewPassword123!',
          passwordConfirmation: 'NewPassword123!'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['changePassword']['user']).to be_nil
        expect(json['data']['changePassword']['errors']).not_to be_empty
      end
    end
  end

  describe 'logout mutation' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    it 'returns success message' do
      mutation = <<~GQL
        mutation Logout {
          logout {
            success
            message
          }
        }
      GQL

      post '/graphql', params: { query: mutation }, headers: { 'Authorization' => "Bearer #{token}" }
      
      json = JSON.parse(response.body)
      expect(json['data']['logout']['success']).to be true
    end
  end

  describe 'updateProfile mutation' do
    let(:user) { create(:user, name: 'Old Name') }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    context 'when user is authenticated' do
      it 'updates user profile' do
        mutation = <<~GQL
          mutation UpdateProfile($name: String) {
            updateProfile(name: $name) {
              user {
                id
                name
              }
              errors
            }
          }
        GQL

        variables = { name: 'New Name' }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['updateProfile']['user']['name']).to eq('New Name')
        expect(json['data']['updateProfile']['errors']).to eq([])
      end
    end

    context 'when user is not authenticated' do
      it 'returns error' do
        mutation = <<~GQL
          mutation UpdateProfile($name: String) {
            updateProfile(name: $name) {
              user {
                id
              }
              errors
            }
          }
        GQL

        variables = { name: 'New Name' }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['updateProfile']['user']).to be_nil
        expect(json['data']['updateProfile']['errors']).not_to be_empty
      end
    end
  end

  describe 'createAddress mutation' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    context 'when user is authenticated' do
      it 'creates address' do
        mutation = <<~GQL
          mutation CreateAddress($label: String!, $recipientName: String!, $phoneNumber: String!, $address: String!, $city: String!, $country: String!, $postalCode: String!, $default: Boolean) {
            createAddress(label: $label, recipientName: $recipientName, phoneNumber: $phoneNumber, address: $address, city: $city, country: $country, postalCode: $postalCode, default: $default) {
              address {
                id
                label
              }
              errors
            }
          }
        GQL

        variables = {
          label: 'Home',
          recipientName: 'John Doe',
          phoneNumber: '+1234567890',
          address: '123 Main St',
          city: 'New York',
          country: 'USA',
          postalCode: '10001',
          default: true
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['createAddress']['address']).to be_present
        expect(json['data']['createAddress']['errors']).to eq([])
      end
    end

    context 'when user is not authenticated' do
      it 'returns error' do
        mutation = <<~GQL
          mutation CreateAddress($label: String!, $recipientName: String!, $phoneNumber: String!, $address: String!, $city: String!, $country: String!, $postalCode: String!) {
            createAddress(label: $label, recipientName: $recipientName, phoneNumber: $phoneNumber, address: $address, city: $city, country: $country, postalCode: $postalCode) {
              address {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          label: 'Home',
          recipientName: 'John Doe',
          phoneNumber: '+1234567890',
          address: '123 Main St',
          city: 'New York',
          country: 'USA',
          postalCode: '10001'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['createAddress']['address']).to be_nil
        expect(json['data']['createAddress']['errors']).not_to be_empty
      end
    end
  end

  describe 'createCategory mutation' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    it 'creates a category' do
      mutation = <<~GQL
        mutation CreateCategory($name: String!, $slug: String) {
          createCategory(name: $name, slug: $slug) {
            category {
              id
              name
              slug
            }
            errors
          }
        }
      GQL

      variables = {
        name: 'Electronics',
        slug: 'electronics'
      }

      post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
      
      json = JSON.parse(response.body)
      expect(json['data']['createCategory']['category']).to be_present
      expect(json['data']['createCategory']['category']['name']).to eq('Electronics')
      expect(json['data']['createCategory']['errors']).to eq([])
    end
  end

  describe 'createProduct mutation' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:category) { create(:category) }

    context 'when user is authenticated' do
      it 'creates a product' do
        mutation = <<~GQL
          mutation CreateProduct($name: String!, $description: String, $price: Float!, $stock: Int!, $categoryId: ID!, $active: Boolean) {
            createProduct(name: $name, description: $description, price: $price, stock: $stock, categoryId: $categoryId, active: $active) {
              product {
                id
                name
                price
                stock
              }
              errors
            }
          }
        GQL

        variables = {
          name: 'Laptop',
          description: 'High performance laptop',
          price: 999.99,
          stock: 50,
          categoryId: category.id.to_s,
          active: true
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['createProduct']['product']).to be_present
        expect(json['data']['createProduct']['errors']).to eq([])
      end
    end

    context 'when category does not exist' do
      it 'returns error' do
        mutation = <<~GQL
          mutation CreateProduct($name: String!, $price: Float!, $stock: Int!, $categoryId: ID!) {
            createProduct(name: $name, price: $price, stock: $stock, categoryId: $categoryId) {
              product {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          name: 'Laptop',
          price: 999.99,
          stock: 50,
          categoryId: '99999'
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['createProduct']['product']).to be_nil
        expect(json['data']['createProduct']['errors']).not_to be_empty
      end
    end
  end

  describe 'createOrder mutation' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:address) { create(:address, user: user) }
    let(:product) { create(:product, active: true, stock: 100, price: 100) }

    context 'with valid parameters' do
      it 'creates an order' do
        mutation = <<~GQL
          mutation CreateOrder($addressId: ID, $items: [OrderItemInput!]!) {
            createOrder(addressId: $addressId, items: $items) {
              order {
                id
                orderNumber
                status
                subtotal
              }
              errors
            }
          }
        GQL

        variables = {
          addressId: address.id.to_s,
          items: [
            {
              productId: product.id.to_s,
              quantity: 2
            }
          ]
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        puts "DEBUG createOrder response: #{response.body.inspect}"
        json = JSON.parse(response.body)
        expect(json['data']['createOrder']['order']).to be_present
        expect(json['data']['createOrder']['order']['status']).to eq('pending')
        expect(json['data']['createOrder']['errors']).to eq([])
      end
    end

    context 'with insufficient stock' do
      it 'returns error' do
        product.update(stock: 1)

        mutation = <<~GQL
          mutation CreateOrder($addressId: ID, $items: [OrderItemInput!]!) {
            createOrder(addressId: $addressId, items: $items) {
              order {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          addressId: address.id.to_s,
          items: [
            {
              productId: product.id.to_s,
              quantity: 5
            }
          ]
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['createOrder']['order']).to be_nil
        expect(json['data']['createOrder']['errors']).not_to be_empty
      end
    end

    context 'with another user address' do
      let(:other_user) { create(:user) }
      let(:other_address) { create(:address, user: other_user) }

      it 'returns error' do
        mutation = <<~GQL
          mutation CreateOrder($addressId: ID, $items: [OrderItemInput!]!) {
            createOrder(addressId: $addressId, items: $items) {
              order {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          addressId: other_address.id.to_s,
          items: [
            {
              productId: product.id.to_s,
              quantity: 1
            }
          ]
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['createOrder']['order']).to be_nil
        expect(json['data']['createOrder']['errors']).not_to be_empty
      end
    end

    context 'when user is not authenticated' do
      it 'returns error' do
        mutation = <<~GQL
          mutation CreateOrder($addressId: ID, $items: [OrderItemInput!]!) {
            createOrder(addressId: $addressId, items: $items) {
              order {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          addressId: address.id.to_s,
          items: [
            {
              productId: product.id.to_s,
              quantity: 1
            }
          ]
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['createOrder']['order']).to be_nil
        expect(json['data']['createOrder']['errors']).not_to be_empty
      end
    end
  end

  describe 'createSupportRequest mutation' do
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    context 'when user is authenticated' do
      it 'creates a support request' do
        mutation = <<~GQL
          mutation CreateSupportRequest($subject: String!, $message: String!) {
            createSupportRequest(subject: $subject, message: $message) {
              supportRequest {
                id
                subject
              }
              errors
            }
          }
        GQL

        variables = {
          subject: 'Issue with order',
          message: 'I have a problem with my recent order. Please help me resolve this issue.'
        }

        post '/graphql', params: { query: mutation, variables: variables }, headers: { 'Authorization' => "Bearer #{token}" }
        
        json = JSON.parse(response.body)
        expect(json['data']['createSupportRequest']['supportRequest']).to be_present
        expect(json['data']['createSupportRequest']['errors']).to eq([])
      end
    end

    context 'when user is not authenticated' do
      it 'returns error' do
        mutation = <<~GQL
          mutation CreateSupportRequest($subject: String!, $message: String!) {
            createSupportRequest(subject: $subject, message: $message) {
              supportRequest {
                id
              }
              errors
            }
          }
        GQL

        variables = {
          subject: 'Issue with order',
          message: 'I have a problem with my recent order.'
        }

        post '/graphql', params: { query: mutation, variables: variables }
        
        json = JSON.parse(response.body)
        expect(json['data']['createSupportRequest']['supportRequest']).to be_nil
        expect(json['data']['createSupportRequest']['errors']).not_to be_empty
      end
    end
  end
end
