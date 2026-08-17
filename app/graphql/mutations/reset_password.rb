module Mutations
  class ResetPassword < BaseMutation
    argument :email, String, required: true
    argument :token, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(email:, token:, password:, password_confirmation:)
      user = User.find_by(email: email.downcase.strip)
      return { user: nil, errors: ["Invalid email or token"] } unless user
      return { user: nil, errors: ["Invalid token"] } unless user.authenticated_reset_token?(token)
      return { user: nil, errors: ["Token expired"] } if user.reset_token_expired?

      if user.update(password: password, password_confirmation: password_confirmation)
        user.clear_reset_digest
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end
  end
end
