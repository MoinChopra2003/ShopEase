module Types
  class MutationType < Types::BaseObject
    field :sign_up, mutation: Mutations::Signup
    field :login, mutation: Mutations::Login
    field :forgot_password, mutation: Mutations::ForgotPassword
    field :reset_password, mutation: Mutations::ResetPassword
    field :change_password, mutation: Mutations::ChangePassword
    field :logout, mutation: Mutations::Logout
    field :update_profile, mutation: Mutations::UpdateProfile
    field :create_address, mutation: Mutations::CreateAddress
    field :update_address, mutation: Mutations::UpdateAddress
    field :delete_address, mutation: Mutations::DeleteAddress
    field :set_default_address, mutation: Mutations::SetDefaultAddress
    field :create_category, mutation: Mutations::CreateCategory
    field :create_product, mutation: Mutations::CreateProduct
    field :create_order, mutation: Mutations::CreateOrder
    field :create_support_request, mutation: Mutations::CreateSupportRequest
  end
end