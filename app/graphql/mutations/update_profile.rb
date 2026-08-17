require "base64"
require "stringio"

module Mutations
  class UpdateProfile < BaseMutation
    argument :name, String, required: false
    argument :email, String, required: false
    argument :avatar_base64, String, required: false

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(name: nil, email: nil, avatar_base64: nil)
      user = context[:current_user]
      return { user: nil, errors: ["UNAUTHENTICATED"] } unless user

      attrs = {}
      attrs[:name] = name if name.present?

      if email.present?
        normalized = email.downcase.strip
        if User.where(email: normalized).where.not(id: user.id).exists?
          return { user: nil, errors: ["Email has already been taken"] }
        end
        attrs[:email] = normalized
      end

      begin
        if avatar_base64.present?
          data = avatar_base64

          if data.start_with?("data:")
            parts = data.split(',')
            data = parts.last
            mime = parts.first.match(/data:(.*);base64/)&.captures&.first
          end

          decoded = Base64.decode64(data)
          io = StringIO.new(decoded)

          filename = "avatar_#{user.id}_#{Time.now.to_i}.jpg"
          content_type = mime || "image/jpeg"

          user.avatar.attach(io: io, filename: filename, content_type: content_type)
        end

        if attrs.any?
          user.update!(attrs)
        end

        { user: user, errors: [] }
      rescue StandardError => e
        { user: nil, errors: ["Failed to update profile"] }
      end
    end
  end
end
