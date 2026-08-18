class GraphqlController < ActionController::API
  def execute
    result = FinalProjectSchema.execute(
      params[:query],
      variables: normalize_graphql_variables(ensure_hash(params[:variables]), params[:query]),
      context: { current_user: current_user },
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

    query_variable_types = extract_query_variable_types(query)
    return variables if query_variable_types.empty?

    variables.each_with_object({}) do |(key, value), normalized|
      type_name = query_variable_types[key.to_s] || query_variable_types[key.to_sym]
      normalized[key] = coerce_value_for_type(value, type_name)
    end
  end

  def extract_query_variable_types(query)
    query.scan(/\$([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^\s,)]+)/).each_with_object({}) do |(name, raw_type), types|
      types[name] = raw_type.sub(/!\z/, "")
    end
  end

  def coerce_value_for_type(value, type_name)
    return value if value.nil? || type_name.blank?

    normalized_type = type_name.to_s.sub(/!\z/, "")

    if normalized_type.start_with?("[") && normalized_type.end_with?("]")
      item_type = normalized_type[1..-2]
      return Array(value).map { |item| coerce_value_for_type(item, item_type) }
    end

    case normalized_type
    when "Boolean"
      return true if value == true || value == "true"
      return false if value == false || value == "false"
      return nil if value == "null"
      return value
    when "Int"
      return value.to_i if value.is_a?(String)

      return value
    when "Float"
      return value.to_f if value.is_a?(String)

      return value
    when "String", "ID"
      return value.to_s unless value.is_a?(String)

      return value
    else
      return coerce_input_object_value(value, normalized_type) if value.is_a?(Hash) && input_object_class_for(normalized_type)

      return value
    end
  end

  def coerce_input_object_value(value, type_name)
    input_class = input_object_class_for(type_name)
    return value unless input_class

    field_types = input_class.arguments.each_with_object({}) do |(field_name, argument_def), types|
      types[field_name.to_s] = argument_def.type
    end

    value.each_with_object({}) do |(key, nested_value), normalized|
      field_type = field_types[key.to_s] || field_types[key.to_sym]
      normalized[key] = coerce_argument_value(nested_value, field_type)
    end
  end

  def coerce_argument_value(value, argument_type)
    return value if value.nil? || argument_type.nil?

    if argument_type.respond_to?(:of_type) &&
       (argument_type.is_a?(GraphQL::Schema::List) || argument_type.to_s.include?("List"))
      return Array(value).map { |item| coerce_argument_value(item, argument_type.of_type) }
    end

    unwrapped_type = argument_type
    unwrapped_type = unwrapped_type.unwrap if unwrapped_type.respond_to?(:unwrap)

    if unwrapped_type.is_a?(Class) && unwrapped_type < GraphQL::Schema::InputObject
      return coerce_input_object_value(value, unwrapped_type.name.split("::").last)
    end

    type_name =
      if unwrapped_type.respond_to?(:graphql_name)
        unwrapped_type.graphql_name
      elsif unwrapped_type.respond_to?(:name)
        unwrapped_type.name
      else
        argument_type.to_s
      end

    coerce_value_for_type(value, type_name)
  end

  def input_object_class_for(type_name)
    candidates = [
      type_name,
      "Mutations::#{type_name}",
      "Mutations::CreateOrder::#{type_name}",
      "::Mutations::#{type_name}",
      "::Mutations::CreateOrder::#{type_name}"
    ].compact.uniq

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

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when Hash, ActionController::Parameters
      ambiguous_param.to_unsafe_hash
    when nil
      {}
    else
      ambiguous_param
    end
  rescue JSON::ParserError
    ambiguous_param
  end
end