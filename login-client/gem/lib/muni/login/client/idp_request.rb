module Muni
  module Login
    module Client
      class IdpRequest < Muni::Login::Client::Base
        include ::ActiveSupport::Configurable

        config_accessor :sid_token_from_query_params_allowed

        attr_reader :controller_path, :action_name, :http_headers, :referrer, :query_params

        def initialize(controller_path:,
                       action_name:,
                       cookie_reader: nil,
                       http_headers: nil,
                       referrer: nil,
                       query_params: nil)
          super()
          @controller_path = controller_path
          @action_name = action_name
          @cookie_reader = cookie_reader
          @referrer = referrer

          @http_headers = if http_headers.nil?
                            HashWithIndifferentAccess.new
                          elsif http_headers.is_a?(Hash)
                            http_headers.with_indifferent_access
                          else
                            # most likely an instance of ActionDispatch::Http::Headers
                            http_headers
                          end

          @query_params = if query_params.nil?
                            HashWithIndifferentAccess.new
                          elsif query_params.is_a?(Hash)
                            query_params.with_indifferent_access
                          else
                            # most likely an instance of ActionController::Parameters
                            query_params
                          end

          idlog.trace(location: "#{self.class.name}.#{__method__}",
                      controller_path: controller_path,
                      action_name: action_name,
                      http_headers: filtered_http_headers,
                      referrer: referrer)
        end

        def api_token
          http_headers[API_TOKEN_HEADER]
        end

        def api_vector
          @api_vector ||= http_headers[API_VECTOR_HEADER].presence || random_alphanumeric
        end

        def sid_token
          @sid_token ||= if sid_token_from_cookies.present?
                           idlog.trace(location: "#{self.class.name}.#{__method__}",
                                       message: 'sid_token_from_cookies',
                                       cookie_name: @cookie_reader.sid_cookie_name)
                           sid_token_from_cookies
                         elsif sid_token_from_headers.present?
                           idlog.trace(location: "#{self.class.name}.#{__method__}",
                                       message: 'sid_token_from_headers',
                                       header_name: AUTHORIZATION_HEADER)
                           sid_token_from_headers
                         elsif sid_token_from_query_params.present?
                           idlog.trace(location: "#{self.class.name}.#{__method__}",
                                       message: 'sid_token_from_query_params',
                                       param_name: 'sid_token')
                           sid_token_from_query_params
                         else
                           idlog.trace(location: "#{self.class.name}.#{__method__}",
                                       message: 'sid_token not present')
                           nil
                         end
        end

        def action_signature
          "#{@controller_path}|#{@action_name}"
        end


        def idlog
          @idlog ||= Muni::Login::Client::IdpLogger.new(idrequest: self)
        end

        private

        # based on https://stackoverflow.com/questions/32405155/display-or-get-the-http-header-attributes-in-rails-4
        def filtered_http_headers
          if http_headers.is_a?(ActionDispatch::Http::Headers)
            http_headers.env.select { |k, _| k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || k =~ /^HTTP_/ }
          else
            http_headers
          end
        end

        def random_alphanumeric(length: 10)
          # the cleanest implementation would be SecureRandom.alphanumeric, unfortunately we
          # need to support older versions of ruby, so here's an alternative based on
          # https://jetthoughts.com/blog/generating-random-strings-with-ruby-webdev/
          charset = [('0'..'9'), ('a'..'z'), ('A'..'Z')].flat_map(&:to_a)
          (0...length).map { charset[rand(charset.size)] }.join
        end

        def sid_token_from_cookies
          @cookie_reader&.sid_token
        end

        def sid_token_from_headers
          http_headers.present? ? http_headers[AUTHORIZATION_HEADER].to_s.split(WHSP).last : nil
        end

        def sid_token_from_query_params
          if self.sid_token_from_query_params_allowed == true
            query_params[:sid_token]
          end
        end

      end
    end
  end
end
