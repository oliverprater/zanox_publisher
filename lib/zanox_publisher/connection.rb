require 'httparty'
require 'base64'
require 'openssl'

module ZanoxPublisher
  # Represents a Zanox Product API error. Contains specific data about the error.
  class ZanoxError < StandardError
    attr_reader :data

    def initialize(data)
      @data   = data

      # should contain Code, Message, and Reason
      code    = data['code'].to_s
      message = data['message'].to_s
      reason  = data['reason'].to_s
      super "The Zanox Product API responded with the following error message: #{message} Error reason: #{reason} [code: #{code}]"
    end
  end

  # Raised for HTTP response codes of 400...500
  class ClientError < StandardError; end
  # Raised for HTTP response codes of 500...600
  class ServerError < StandardError; end
  # Raised for HTTP response code of 400
  class BadRequest < ZanoxError; end
  # Raised when authentication information is missing
  class AuthenticationError < StandardError; end
  # Raised when authentication fails with HTTP response code of 403
  class Unauthorized < ZanoxError; end
  # Raised for HTTP response code of 404
  class NotFound < ClientError; end

  # @attr [String] relative_path    The default relative path used for a request
  class Connection
    include HTTParty

    API_URI     = 'https://api.zanox.com'
    DATA_FORMAT = 'json'
    API_VERSION = '2011-03-01'

    base_uri "#{API_URI}/#{DATA_FORMAT}/#{API_VERSION}"

    USER_AGENT_STRING = "ZanoxPublisher/#{VERSION} (ruby #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"

    attr_accessor :relative_path

    # Initializes a new connection instance of ZanoxPublisher.
    # It requires authentication information to access the Publisher API.
    # The relative path is used as the default for HTTP method calls.
    #
    # The connect ID and secret key can be passed as parameters,
    # else the ZanoxPublisher::authenticate information is taken.
    #
    #
    # @param relative_path [String] The default relative path of the resource
    # @param connect_id [String] The connect ID of your account for authentication
    # @param secret_key [String] The secret key of your account for authentication
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new("/profiles", "<your_client_id>", "<your_client_secret>") #=> #<Connection ...>
    #           connection.get #=> #<HTTParty::Response ...>
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.get('/profiles') #=> #<HTTParty::Response ...>
    #
    def initialize(relative_path = '', connect_id = ZanoxPublisher.connect_id, secret_key = ZanoxPublisher.secret_key)
      @connect_id, @secret_key = connect_id, secret_key
      @relative_path = relative_path
      @connection = self.class
    end

    # Sends a GET request for a public resource - auth with connect ID
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.get('/path') #=> #<HTTParty::Response ...>
    def get(relative_path = @relative_path, params = {})
      handle_response connection.get(relative_path, public_auth(params))
    end

    # Sends a POST request for a public resource - auth with connect ID
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.post('/path') #=> #<HTTParty::Response ...>
    def post(relative_path = @relative_path, params = {})
      handle_response connection.post(relative_path, public_auth(params))
    end

    # Sends a PUT request for a public resource - auth with connect ID
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.put('/path') #=> #<HTTParty::Response ...>
    def put(relative_path = @relative_path, params = {})
      handle_response connection.put(relative_path, public_auth(params))
    end

    # Sends a DELETE request for a public resource - auth with connect ID
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.delete('/path') #=> #<HTTParty::Response ...>
    def delete(relative_path = @relative_path, params = {})
      handle_response connection.delete(relative_path, public_auth(params))
    end

    # Sends a GET request for a private resource - auth with signature
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.signature_get('/path') #=> #<HTTParty::Response ...>
    def signature_get(relative_path = @relative_path, params = {})
      handle_response connection.get(relative_path, private_auth('GET', relative_path, params))
    end

    # Sends a POST request for a private resource - auth with signature
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.signature_post('/path') #=> #<HTTParty::Response ...>
    def signature_post(relative_path = @relative_path, params = {})
      handle_response connection.post(relative_path, private_auth('POST', relative_path, params))
    end

    # Sends a PUT request for a private resource - auth with signature
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.signature_put('/path') #=> #<HTTParty::Response ...>
    def signature_put(relative_path = @relative_path, params = {})
      handle_response connection.put(relative_path, private_auth('PUT', relative_path, params))
    end

    # Sends a DELETE request for a private resource - auth with signature
    #
    # For more information on authentication see {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest}
    #
    # @param relative_path [String] The relative path of the API resource
    # @param params [Hash] The HTTParty params argument
    #
    # @return [Hash]
    #
    # @example
    #           connection = ZanoxPublisher::Connection.new #=> #<Connection ...>
    #           connection.signature_delete('/path') #=> #<HTTParty::Response ...>
    def signature_delete(relative_path = @relative_path, params = {})
      handle_response connection.delete(relative_path, private_auth('DELETE', relative_path, params))
    end

    private

    attr_reader :connection

    # Internal routine to handle the HTTParty::Response
    def handle_response(response) # :nodoc:
      case response.code
      when 400
        #IN CASE WE WANT MORE PRECISE ERROR NAMES
        #data = response.parsed_response
        #case data['code']
        #when 230
        #  raise ParameterDataInvalid.new data
        #else
        #  raise BadRequest.new data
        #end
        raise BadRequest.new(response.parsed_response)
      when 403
        raise Unauthorized.new(response.parsed_response)
      when 404
        raise NotFound.new
      when 400...500
        raise ClientError.new
      when 500...600
        raise ServerError.new
      else
        response.parsed_response
      end
    end

    # Authentication header for public resources of the Zanox API
    # Public resources - auth with connection ID.
    #
    # For details access the guide found {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest here}.
    def public_auth(params)
      raise AuthenticationError, 'Please provide your connect ID.' if @connect_id.nil?

      auth = { 'Authorization' => "ZXWS #{@connect_id}" }

      if params.has_key? :headers
        params[:headers].merge(auth)
      else
        params[:headers] = auth
      end

      params
    end

    # Authentication header for private resources of the Zanox API
    # Private resources - auth with signature.
    #
    # For details access the guide found {https://developer.zanox.com/web/guest/authentication/zanox-oauth/oauth-rest here}.
    # Signature = Base64( HMAC-SHA1( UTF-8-Encoding-Of( StringToSign ) ) );
    # StringToSign = HTTP-Verb + URI + timestamp + nonce
    # HTTP Verb - GET, POST, PUT or DELETE;
    # URI - exclude return format and API version date, include path parameters http://api.zanox.com/json/2011-03-01 -> /reports/sales/date/2013-07-20
    # Timestamp - in GMT, format "EEE, dd MMM yyyy HH:mm:ss";
    # Nonce - unique random string, generated at the time of request, valid once, 20 or more characters
    def private_auth(verb, relative_path, params)
      raise AuthenticationError, 'Please provide your connect ID.' if @connect_id.nil?
      raise AuthenticationError, 'Please provide your secret key.' if @secret_key.nil?

      # API Method: GET Sales for the date 2013-07-20
      # 1. Generate nonce and timestamp
      timestamp = Time.new.gmtime.strftime('%a, %e %b %Y %T GMT').to_s
      # %e is with 0 padding so 06 for day 6 else use %d
      #timestamp = Time.new.gmtime.strftime('%a, %d %b %Y %T GMT').to_s
      nonce = OpenSSL::Digest::MD5.hexdigest((Time.new.usec + rand()).to_s)
      # 2. Concatinate HTTP Verb, URI, timestamp and nonce to create StringToSign
      string_to_sign = "#{verb}#{relative_path}#{timestamp}#{nonce}"
      # 3. Hash the StringToSign using the secret key as HMAC parameter
      signature = Base64.encode64("#{OpenSSL::HMAC.digest('sha1', @secret_key, string_to_sign)}").chomp
      # 4. Add information to request headers
      auth = {
        'Authorization' => "ZXWS #{@connect_id}:#{signature}",
        'Date' => timestamp,
        'nonce' => nonce
      }

      if params.has_key? :headers
        params[:headers].merge(auth)
      else
        params[:headers] = auth
      end

      params
    end
  end
end
