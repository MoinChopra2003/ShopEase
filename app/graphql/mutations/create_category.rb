module Mutations
  class CreateCategory < Mutations::BaseMutation
    argument :name, String, required: true
    argument :slug, String, required: false

    field :category, Types::CategoryType, null: true
    field :errors, [String], null: false

    def resolve(name:, slug: nil)
      category = Category.new(name: name, slug: slug)

      if category.save
        { category: category, errors: [] }
      else
        { category: nil, errors: category.errors.full_messages }
      end
    end
  end
end
