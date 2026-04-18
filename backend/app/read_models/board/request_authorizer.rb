# frozen_string_literal: true

module ReadModels
  module Board
    # Gates read access to the Board read model.
    # - Requires an authenticated identity.
    # - When `filters[member_id]` is supplied, it must equal the caller's
    #   identity_id — a user may only ask for "boards I am a member of",
    #   not for someone else's membership view.
    class RequestAuthorizer
      NotAuthorized = Yes::Core::Authorization::ReadRequestAuthorizer::NotAuthorized

      def self.call(filter_options, auth_data)
        identity_id = auth_data && auth_data[:identity_id]
        raise NotAuthorized, 'Authentication required to query boards' if identity_id.blank?

        member_id = filter_options.dig(:filters, :member_id) ||
                    filter_options.dig('filters', 'member_id')
        return if member_id.blank? || member_id.to_s == identity_id.to_s

        raise NotAuthorized, 'Cannot query boards on behalf of another identity'
      end
    end
  end
end
