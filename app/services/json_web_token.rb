class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base

  def self.encode(payload_or_user_id)
    # Support both payload hash and simple user_id
    if payload_or_user_id.is_a?(Hash)
      payload = payload_or_user_id
    else
      payload = { user_id: payload_or_user_id }
    end
    
    payload[:exp] ||= 24.hours.from_now.to_i

    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      SECRET_KEY,
      true,
      algorithm: "HS256"
    )

    decoded[0]
  rescue JWT::DecodeError
    nil
  end
end