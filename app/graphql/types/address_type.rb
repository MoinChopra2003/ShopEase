module Types
  class AddressType < Types::BaseObject
    field :id, ID, null: false
    field :label, String, null: false
    field :recipient_name, String, null: false
    field :address, String, null: false
    field :city, String, null: false
    field :state, String, null: true
    field :postal_code, String, null: false
    field :country, String, null: false
    field :phone_number, String, null: false
    field :default, Boolean, null: false
    field :user, Types::UserType, null: true
  end
end
