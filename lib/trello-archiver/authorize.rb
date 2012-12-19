module TrelloArchiver
  class Authorize
      include Trello
      include Trello::Authorization

      def initialize(config)
        @config = config
      end

      def authorize
        Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

        credential = OAuthCredential.new(@config['public_key'],
                                     @config['private_key'])
        OAuthPolicy.consumer_credential = credential

        OAuthPolicy.token = OAuthCredential.new(
                    @config['access_token_key'], nil )
      end
  end
end
