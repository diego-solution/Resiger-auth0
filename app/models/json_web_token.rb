# frozen_string_literal: true
require 'net/http'
require 'uri'

# This contains logic for encoding and decoding jwt tokens
class JsonWebToken
  DOMAIN_URI = 'https://eventfuel.eu.auth0.com/'

  def self.decode(token)
    JWT.decode(token, nil,
        true, # Verify the signature of this token
        algorithm: 'RS256',                          # RS256 or HS256
        iss: DOMAIN_URI,    # something like 000.eu.auth0.com
        verify_iss: true,
        aud: DOMAIN_URI + "api/v2/",
        verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def self.jwks_hash
    jwks_raw = Net::HTTP.get URI(DOMAIN_URI + ".well-known/jwks.json")
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end

  # Validates the payload hash for expiration and meta claims
  #{"iss"=>"https://eventfuel.eu.auth0.com/",
  # "sub"=>"google-apps|psousa@thinkorange.pt",
  # "aud"=>
  # ["https://eventfuel.eu.auth0.com/api/v2/",
  #   "https://eventfuel.eu.auth0.com/userinfo"],
  # "iat"=>1541583703,
  # "exp"=>1541590903,
  # "azp"=>"Ec8SwUPP4agaaA1bbVKcnBRfh4HYJTFC",
  # "scope"=>"openid profile"}
  def self.valid_payload(payload)
    if expired(payload) || payload["iss"] != DOMAIN_URI
      false
    else
      true
    end
  end

  # Validates if the token is expired by exp parameter
  def self.expired(payload)
    Time.zone.at(payload["exp"]) < Time.current
  end
end
