module Mutations
  class ForgotPassword < BaseMutation
    argument :email, String, required: true

    field :success, Boolean, null: false
    field :message, String, null: false
    field :errors, [String], null: false

    def resolve(email:)
      user = User.find_by(email: email.to_s.downcase.strip)
      if user
        user.create_reset_digest
        UserMailer.password_reset(user).deliver_now
      end

      { success: true, message: "If that email address is in our system, we will send password reset instructions", errors: [] }
    rescue StandardError => e
      { success: true, message: "If that email address is in our system, we will send password reset instructions", errors: [] }
    end
  end
end
