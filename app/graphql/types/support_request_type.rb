module Types
  class SupportRequestType < Types::BaseObject
    field :id, ID, null: false
    field :subject, String, null: false
    field :message, String, null: false
    field :status, String, null: false
    field :user, Types::UserType, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: false
  end
end
