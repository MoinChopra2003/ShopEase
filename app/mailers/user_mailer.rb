class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @token = user.reset_token

    mail(to: @user.email, subject: "Password reset instructions") do |format|
      format.text { render plain: "Email: #{@user.email}\nToken: #{@token}" }
    end
  end
end