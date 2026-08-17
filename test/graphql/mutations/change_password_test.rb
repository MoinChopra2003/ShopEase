require "test_helper"

class ChangePasswordMutationTest < Minitest::Test
  def test_accepts_change_password_graphql_field_name
    user = User.create!(
      name: "Test User",
      email: "change-password@example.com",
      password: "OldPassword123!",
      password_confirmation: "OldPassword123!",
      status: "active"
    )

    result = FinalProjectSchema.execute(
      <<~GRAPHQL,
        mutation ChangePassword($currentPassword: String!, $password: String!, $passwordConfirmation: String!) {
          changePassword(currentPassword: $currentPassword, password: $password, passwordConfirmation: $passwordConfirmation) {
            user {
              id
            }
            errors
          }
        }
      GRAPHQL
      variables: {
        currentPassword: "OldPassword123!",
        password: "NewPassword123!",
        passwordConfirmation: "NewPassword123!"
      },
      context: { current_user: user }
    )

    assert_nil result["errors"], result.to_h.inspect
    assert result.dig("data", "changePassword", "user", "id").present?, result.to_h.inspect
    assert_equal [], result.dig("data", "changePassword", "errors")
    assert user.reload.authenticate("NewPassword123!")
  end
end
