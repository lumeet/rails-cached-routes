require 'action_dispatch/routing/redirection'

module CachedRoutes
  class CachedRedirect

    include ActionDispatch::Routing::Redirection

    def initialize(ad_redirect)
      @path = if ad_redirect.instance_of?(ActionDispatch::Routing::Redirect)
                ad_redirect.path({}, nil)
              else
                ad_redirect
              end
    end

    def to_action_dispatch_redirect
      @path.is_a?(String) ? redirect(@path) : @path
    end

  end
end
