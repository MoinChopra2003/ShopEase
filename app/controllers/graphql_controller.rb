class GraphqlController < ActionController::API
  def execute
    result = FinalProjectSchema.execute(
      params[:query],
      variables: normalize_graphql_variables(
        ensure_hash(params[:variables]),
        params[:query]
      ),
      context: {
        current_user: current_user,
        request: request
      }
    )

    render json: result
  end

  private

  def current_user
    @current_user ||= authenticate_user
  end

  def authenticate_user
    token = extract_token
    return nil unless token

    decoded = JsonWebToken.decode(token)
    return nil unless decoded

    User.find_by(id: decoded["user_id"])
  end

  def extract_token
    auth_header = request.headers["Authorization"]
    return nil unless auth_header

    auth_header.split(" ").last
  end

  def normalize_graphql_variables(variables, query)
    return variables if variables.blank? || query.blank?

    variable_types = extract_query_variable_types(query)

    variables.each_with_object({}) do |(key, value), normalized|
      type_name = variable_types[key.to_s]

      normalized[key] = coerce_value_for_type(value, type_name)
    end
  end

  def extract_query_variable_types(query)
    query.scan(
      /\$([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^\s,)]+)/
    ).to_h
  end

  def coerce_value_for_type(value, type_name)
    return value if value.nil? || type_name.blank?

    type_name = type_name.to_s

    # Remove outer GraphQL non-null marker.
    type_name = type_name.delete_suffix("!")

    # GraphQL list, for example:
    # [OrderItemInput!]
    if type_name.start_with?("[") && type_name.end_with?("]")
      item_type = type_name[1...-1]
      item_type = item_type.delete_suffix("!")

      return Array(value).map do |item|
        if item.is_a?(Hash)
          coerce_input_object_value(item, item_type)
        else
          coerce_value_for_type(item, item_type)
        end
      end
    end

    case type_name
    when "Boolean"
      return true if value == true || value == "true"
      return false if value == false || value == "false"

      value

    when "Int"
      return value.to_i if value.is_a?(String)

      value

    when "Float"
      return value.to_f if value.is_a?(String)

      value

    when "String", "ID"
      return value.to_s unless value.is_a?(String)

      value

    else
      if value.is_a?(Hash)
        return coerce_input_object_value(value, type_name)
      end

      value
    end
  end

  def coerce_input_object_value(value, type_name)
    input_class = input_object_class_for(type_name)
    return value unless input_class

    field_types = input_class.arguments.each_with_object({}) do |(field_name, argument), types|
      types[field_name.to_s] = argument.type
    end

    value.each_with_object({}) do |(key, nested_value), normalized|
      argument_type = field_types[key.to_s]

      normalized[key] = coerce_argument_value(
        nested_value,
        argument_type
      )
    end
  end

  def coerce_argument_value(value, argument_type)
    return value if value.nil? || argument_type.nil?

    # GraphQL list argument.
    if argument_type.respond_to?(:of_type) &&
       argument_type.to_s.include?("List")
      return Array(value).map do |item|
        coerce_argument_value(item, argument_type.of_type)
      end
    end

    type = argument_type

    # Remove GraphQL NonNull wrapper.
    type = type.of_type if type.respond_to?(:of_type)

    # Input object.
    if type.is_a?(Class) &&
       type < GraphQL::Schema::InputObject
      return coerce_input_object_value(
        value,
        type.name.split("::").last
      )
    end

    type_name =
      if type.respond_to?(:graphql_name)
        type.graphql_name
      elsif type.respond_to?(:name)
        type.name
      else
        type.to_s
      end

    coerce_value_for_type(value, type_name)
  end

  def input_object_class_for(type_name)
    type_name = type_name.to_s.delete_suffix("!")

    candidates = [
      type_name,
      "Mutations::#{type_name}",
      "Mutations::CreateOrder::#{type_name}",
      "::Mutations::#{type_name}",
      "::Mutations::CreateOrder::#{type_name}"
    ]

    candidates.each do |candidate|
      begin
        constant = candidate.constantize

        return constant if constant < GraphQL::Schema::InputObject
      rescue NameError
        next
      end
    end

    nil
  end

  def ensure_hash(value)
    case value
    when String
      value.present? ? JSON.parse(value) : {}
    when Hash, ActionController::Parameters
      value.to_unsafe_hash
    when nil
      {}
    else
      value
    end
  rescue JSON::ParserError
    value
  end
end
