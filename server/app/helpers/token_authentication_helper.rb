# Validate access token in request headers
#
#
require_relative '../routes/oauth2_api'
require_relative '../services/logging'

module TokenAuthenticationHelper

  include OAuth2Api::Common
  include Logging

  def validate_access_token(*scopes)
    # These only happen when in a "soft exclude" path where
    # the headers are processed but request is not halted
    # by the token authentication middleware.
    
    unless current_user
      debug "No current user"
      mime_halt(403, 'access_denied')
    end

    unless current_access_token
      debug "No current token"
      mime_halt(403, 'access_denied')
    end

    unless scopes.empty?
      unless current_access_token.has_scope?(*scopes)
        debug "No valid scope"
        mime_halt(403, 'access_denied')
      end
    end
  end

  def current_user
    env[TokenAuthentication::CURRENT_USER]
  end

  def current_access_token
    env[TokenAuthentication::CURRENT_TOKEN]
  end

  def current_user_admin?
    current_user && current_user.master_admin?
  end
end
