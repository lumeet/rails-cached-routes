module CachedRoutes
  class Marshaller

    attr_reader :routes_file, :cached_file

    def initialize
      if caller_line = caller.detect { |li| !(li =~ /cached_routes/i) }
        @routes_file = caller_line.sub /:.*/, ''
        @cached_file = caller_line.sub /\.rb:.*/, '.cached'
      else
        warn "Can not determine caller routes file.  Skipping route caching."
      end
    end

    def can_unmarshal_routes?
      routes_file &&
      cached_file &&
      File.exist?(routes_file) &&
      File.exist?(cached_file) &&
      File.mtime(cached_file) >= File.mtime(routes_file)
    end

    def marshal_routes(new_routes)
      new_routes.map! do |route|
        if ActionDispatch::Routing::Redirect === route.app
          route = route.clone
          route.instance_variable_set :@app, CachedRedirect.new(route.app)
        end
        route
      end
      File.open(cached_file, 'wb') do |io|
        Marshal.dump(new_routes, io)
      end
      nil
    end

    def unmarshal_routes(routes, named_routes)
      File.open(cached_file, 'rb') do |io|
        Marshal.load(io).each do |route|
          if CachedRedirect === route.app
            route.instance_variable_set :@app, route.app.to_action_dispatch_redirect
          end
          routes << route
          named_routes[route.name] = route if route.name
        end
      end
    end

  end
end
