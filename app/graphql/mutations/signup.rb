module Mutations
  class Signup < BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(name:, email:, password:, password_confirmation:)
      user = User.new(
        name: name,
        email: email.downcase.strip,
        password: password,
        password_confirmation: password_confirmation,
        status: "active"
      )

      if user.save
        {
          token: JsonWebToken.encode(user.id),
          user: user,
          errors: []
        }
      else
        {
          token: nil,
          user: nil,
          errors: user.errors.full_messages
        }
      end
    end
  end
end