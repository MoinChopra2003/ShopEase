module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :status, String, null: false
    field :avatar_url, String, null: true
  end
end