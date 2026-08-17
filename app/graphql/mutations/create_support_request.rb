module Mutations
  class CreateSupportRequest < BaseMutation
    argument :subject, String, required: true
    argument :message, String, required: true

    field :support_request, Types::SupportRequestType, null: true
    field :errors, [String], null: false

    def resolve(subject:, message:)
      user = context[:current_user]
      return { support_request: nil, errors: ["UNAUTHENTICATED"] } unless user

      sr = user.support_requests.create(subject: subject, message: message, status: "open")
      if sr.persisted?
        { support_request: sr, errors: [] }
      else
        { support_request: nil, errors: sr.errors.full_messages }
      end
    rescue StandardError => e
      { support_request: nil, errors: ["Failed to create support request"] }
    end
  end
end
