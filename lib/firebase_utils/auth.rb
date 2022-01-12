# frozen_string_literal: true

require 'jwt'

# 参考: https://qiita.com/otakky/items/b7582202f5cde8f2dd21
module FirebaseUtils
  module Auth
    PROJECT_ID = 'mer-sell'
    ALGORITHM = 'RS256'
    ISSUER_BASE_URL = 'https://securetoken.google.com/'
    CLIENT_CERT_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'

    class << self
      def verify_id_token(token)
        raise 'id token must be a String' unless token.is_a?(String)

        full_decoded_token = _decode_token(token)

        err_msg = _validate_jwt(full_decoded_token)
        raise err_msg if err_msg

        public_key = _fetch_public_keys[full_decoded_token[:header]['kid']]
        unless public_key
          raise 'Firebase ID token has "kid" claim which does not correspond to a known public key.' +
                'Most likely the ID token is expired, so get a fresh token from your client app and try again.'
        end

        certificate = OpenSSL::X509::Certificate.new(public_key)
        decoded_token = _decode_token(token, certificate.public_key, true, { algorithm: ALGORITHM, verify_iat: true })

        {
          'uid' => decoded_token[:payload]['sub'],
          'decoded_token' => decoded_token
        }
      end

      private

      def _decode_token(token, key = nil, verify = false, options = {})
        begin
          decoded_token = JWT.decode(token, key, verify, options)
        rescue JWT::ExpiredSignature => e
          raise 'Firebase ID token has expired. Get a fresh token from your client app and try again.'
        rescue StandardError => e
          raise "Firebase ID token has invalid signature. #{e.message}"
        end

        {
          payload: decoded_token[0],
          header: decoded_token[1]
        }
      end

      def _validate_jwt(json)
        payload = json[:payload]
        header = json[:header]

        return 'Firebase ID token has no "kid" claim.' unless header['kid']
        return "Firebase ID token has incorrect algorithm. Expected \"#{ALGORITHM}\" but got \"#{header['alg']}\"." unless header['alg'] == ALGORITHM
        return "Firebase ID token has incorrect \"aud\" (audience) claim. Expected \"#{PROJECT_ID}\" but got \"#{payload['aud']}\"." unless payload['aud'] == PROJECT_ID

        issuer = ISSUER_BASE_URL + PROJECT_ID
        return "Firebase ID token has incorrect \"iss\" (issuer) claim. Expected \"#{issuer}\" but got \"#{payload['iss']}\"." unless payload['iss'] == issuer

        return 'Firebase ID token has no "sub" (subject) claim.' unless payload['sub'].is_a?(String)
        return 'Firebase ID token has an empty string "sub" (subject) claim.' if payload['sub'].empty?
        return 'Firebase ID token has "sub" (subject) claim longer than 128 characters.' if payload['sub'].size > 128

        nil
      end

      def _fetch_public_keys
        uri = URI.parse(CLIENT_CERT_URL)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        res = https.start {
          https.get(uri.request_uri)
        }
        data = JSON.parse(res.body)

        if data['error']
          msg = 'Error fetching public keys for Google certs: ' + data['error']
          msg += " (#{res['error_description']})" if data['error_description']

          raise msg
        end

        data
      end
    end
  end
end
