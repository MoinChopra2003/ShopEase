module Mutations
  class Login < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email.downcase.strip)

      unless user
        return {
          token: nil,
          user: nil,
          errors: ["Invalid email or password"]
        }
      end

      authenticated_user = user.authenticate(password)

      unless authenticated_user
        return {
          token: nil,
          user: nil,
          errors: ["Invalid email or password"]
        }
      end

      if user.status != "active"
        return {
          token: nil,
          user: nil,
          errors: ["Your account is not active"]
        }
      end

      {
        token: JsonWebToken.encode(user.id),
        user: user,
        errors: []
      }
    end
  end
end