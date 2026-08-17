module Mutations
  class Logout < BaseMutation
    field :success, Boolean, null: false
    field :message, String, null: false
    field :errors, [String], null: false

    def resolve
      user = context[:current_user]
      return { success: false, message: "", errors: ["UNAUTHENTICATED"] } unless user

      { success: true, message: "Logged out successfully", errors: [] }
    end
  end
end
