module Mutations
  class SetDefaultAddress < BaseMutation
    argument :id, ID, required: true

    field :address, Types::AddressType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      user = context[:current_user]
      return { address: nil, errors: ["UNAUTHENTICATED"] } unless user

      addr = user.addresses.find_by(id: id)
      return { address: nil, errors: ["NOT_FOUND"] } unless addr

      ActiveRecord::Base.transaction do
        user.addresses.update_all(default: false)
        addr.update!(default: true)
      end

      { address: addr, errors: [] }
    rescue StandardError => e
      { address: nil, errors: ["Failed to set default address"] }
    end
  end
end
