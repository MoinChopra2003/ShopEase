module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :status, String, null: false
    field :avatar_url, String, null: true

    def avatar_url
      return nil unless object.avatar.attached?

      request = context[:request]

      if request
        Rails.application.routes.url_helpers.rails_blob_url(
          object.avatar,
          host: request.host,
          port: request.optional_port,
          protocol: request.protocol
        )
      else
        Rails.application.routes.url_helpers.rails_blob_path(
          object.avatar,
          only_path: true
        )
      end
    end
  end
end
