module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :price, Float, null: false
    field :stock, Integer, null: false
    field :active, Boolean, null: false
    field :category, Types::CategoryType, null: false
    field :photo_url, String, null: true

    def photo_url
      return nil unless object.photo.attached?

      request = context[:request]

      if request
        Rails.application.routes.url_helpers.rails_blob_url(
          object.photo,
          host: request.host,
          port: request.optional_port,
          protocol: request.protocol
        )
      else
        Rails.application.routes.url_helpers.rails_blob_path(
          object.photo,
          only_path: true
        )
      end
    end
  end
end
