module Mutations
  class DeleteAddress < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      user = context[:current_user]
      return { success: false, errors: ["UNAUTHENTICATED"] } unless user

      addr = user.addresses.find_by(id: id)
      return { success: false, errors: ["NOT_FOUND"] } unless addr

      addr.destroy
      { success: true, errors: [] }
    rescue StandardError => e
      { success: false, errors: ["Failed to delete address"] }
    end
  end
end
