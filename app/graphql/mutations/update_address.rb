module Mutations
  class UpdateAddress < BaseMutation
    argument :id, ID, required: true
    argument :label, String, required: false
    argument :recipient_name, String, required: false
    argument :phone_number, String, required: false
    argument :address, String, required: false
    argument :city, String, required: false
    argument :postal_code, String, required: false
    argument :country, String, required: false
    argument :latitude, Float, required: false
    argument :longitude, Float, required: false
    argument :default, Boolean, required: false

    field :address, Types::AddressType, null: true
    field :errors, [String], null: false

    def resolve(id:, **args)
      user = context[:current_user]
      return { address: nil, errors: ["UNAUTHENTICATED"] } unless user

      addr = user.addresses.find_by(id: id)
      return { address: nil, errors: ["NOT_FOUND"] } unless addr

      is_default = args.key?(:default) ? args[:default] : nil
      if is_default == true
        ActiveRecord::Base.transaction do
          user.addresses.update_all(default: false)
          addr.update!(args.merge(default: true))
        end
      else
        addr.update!(args)
      end

      { address: addr, errors: [] }
    rescue ActiveRecord::RecordInvalid => e
      { address: nil, errors: e.record.errors.full_messages }
    rescue StandardError => e
      { address: nil, errors: ["Failed to update address"] }
    end
  end
end
