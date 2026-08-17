module Types
  class SupportArticleType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :content, String, null: true
    field :position, Int, null: true
    field :active, Boolean, null: false
    field :created_at, String, null: false
    field :updated_at, String, null: false
  end
end
