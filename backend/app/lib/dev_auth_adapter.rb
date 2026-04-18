# frozen_string_literal: true

require 'base64'
require 'json'
require 'ostruct'

# Simple auth adapter for the TaskFlow demo.
#
# The frontend sends a bearer token that is just a Base64-encoded JSON object:
#   { identity_id: <uuid>, user_id: <uuid> }
#
# This is intentionally insecure — it exists purely so the demo can switch between
# hard-coded users without running a real authentication service.
class DevAuthAdapter
  class AuthError < Yes::Core::AuthenticationError
  end

  # @param request [ActionDispatch::Request]
  # @return [HashWithIndifferentAccess]
  def authenticate(request)
    token = extract_token(request)
    raise AuthError, 'Authentication token missing' unless token

    decode_token(token)
  rescue ArgumentError, JSON::ParserError => e
    raise AuthError, "Invalid token: #{e.message}"
  end

  # @param token [String]
  # @return [OpenStruct]
  # @raise [AuthError] when the token is malformed
  def verify_token(token)
    OpenStruct.new(token: [decode_token(token)])
  rescue ArgumentError, JSON::ParserError => e
    raise AuthError, "Invalid token: #{e.message}"
  end

  # @return [Array<Class>]
  def error_classes
    [AuthError]
  end

  private

  def extract_token(request)
    header = request.headers['Authorization']
    return nil unless header&.start_with?('Bearer ')

    header.delete_prefix('Bearer ')
  end

  def decode_token(token)
    JSON.parse(Base64.strict_decode64(token)).with_indifferent_access
  end
end
