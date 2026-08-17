module Mutations
  class ChangePassword < BaseMutation
    argument :current_password, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(current_password:, password:, password_confirmation:)
      user = context[:current_user]
      return { user: nil, errors: ["UNAUTHENTICATED"] } unless user

      unless user.authenticate(current_password)
        return { user: nil, errors: ["Current password is incorrect"] }
      end

      if password != password_confirmation
        return { user: nil, errors: ["Password confirmation does not match"] }
      end

      if user.update(password: password, password_confirmation: password_confirmation)
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end
  end
end
