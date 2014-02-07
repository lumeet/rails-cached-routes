require 'action_dispatch/routing/redirection'

module CachedRoutes
  class CachedRedirect

    include ActionDispatch::Routing::Redirection

    def initialize(ad_redirect)
      @path = case ad_redirect
              when ActionDispatch::Routing::Redirect
                ad_redirect.path({}, nil)
              else
                ad_redirect
              end
    end

    def to_action_dispatch_redirect
      redirect(@path)
    end

  end
end
