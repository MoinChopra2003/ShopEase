module Mutations
  class CreateAddress < BaseMutation
    argument :label, String, required: false
    argument :recipient_name, String, required: true
    argument :phone_number, String, required: true
    argument :address, String, required: true
    argument :city, String, required: true
    argument :postal_code, String, required: false
    argument :country, String, required: true
    argument :latitude, Float, required: false
    argument :longitude, Float, required: false
    argument :default, Boolean, required: false

    field :address, Types::AddressType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      user = context[:current_user]
      return { address: nil, errors: ["UNAUTHENTICATED"] } unless user

      attrs = args.slice(:label, :recipient_name, :phone_number, :address, :city, :postal_code, :country, :latitude, :longitude)
      is_default = args[:default]

      ActiveRecord::Base.transaction do
        if is_default
          user.addresses.update_all(default: false)
        end

        addr = user.addresses.create!(attrs.merge(default: is_default || false))

        { address: addr, errors: [] }
      end
    rescue ActiveRecord::RecordInvalid => e
      { address: nil, errors: e.record.errors.full_messages }
    rescue StandardError => e
      { address: nil, errors: ["Failed to create address"] }
    end
  end
end
