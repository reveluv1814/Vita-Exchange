class PriceService
  CACHE_KEY = 'crypto_prices'
  CACHE_EXPIRATION = 5.minutes
  MAX_RETRIES = 3
  RETRY_DELAY = 1

  class << self
    def get_prices
      # obtener cache primero
      cached_prices = Rails.cache.read(CACHE_KEY)
      if cached_prices.present?
        Rails.logger.info("Prices loaded from cache")
        return cached_prices
      end

      # si no consultar api externa
      fetch_from_api
    end

    def fetch_from_api
      url = ENV.fetch('VITAWALLET_API_URL')
      timeout = ENV.fetch('API_TIMEOUT').to_i

      retry_count = 0
      last_error = nil

      while retry_count <= MAX_RETRIES
        begin
          Rails.logger.info("Fetching prices from API (attempt #{retry_count + 1}/#{MAX_RETRIES + 1})")
          
          response = HTTParty.get(url, {
            headers: {
              'Content-Type' => 'application/json'
            },
            timeout: timeout
          })

          return handle_response(response)
          
        rescue Net::OpenTimeout, Net::ReadTimeout => e
          last_error = e
          Rails.logger.warn("API timeout on attempt #{retry_count + 1}: #{e.message}")
          retry_count += 1
          sleep(RETRY_DELAY * retry_count) if retry_count <= MAX_RETRIES
          
        rescue HTTParty::Error, SocketError => e
          last_error = e
          Rails.logger.error("API connection error on attempt #{retry_count + 1}: #{e.message}")
          retry_count += 1
          sleep(RETRY_DELAY * retry_count) if retry_count <= MAX_RETRIES
          
        rescue StandardError => e
          last_error = e
          Rails.logger.error("Unexpected error fetching prices: #{e.class} - #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          break
        end
      end

      # reintentos fallados
      Rails.logger.error("All retry attempts failed. Last error: #{last_error&.message}")
      default_prices
    end

    def handle_response(response)
      case response.code
      when 200
        prices = parse_response(response)
        if valid_prices?(prices)
          Rails.cache.write(CACHE_KEY, prices, expires_in: CACHE_EXPIRATION)
          Rails.logger.info("Prices successfully fetched and cached")
          prices
        else
          Rails.logger.error("Invalid prices format received from API")
          default_prices
        end
        
      when 401
        Rails.logger.error("API authentication failed (401)")
        default_prices
        
      when 403
        Rails.logger.error("API access forbidden (403)")
        default_prices
        
      when 429
        Rails.logger.warn("API rate limit exceeded (429)")
        default_prices
        
      when 500..599
        Rails.logger.error("API server error (#{response.code})")
        default_prices
        
      else
        Rails.logger.error("Unexpected API response: #{response.code} - #{response.body}")
        default_prices
      end
    end

    def parse_response(response)
      data = response.parsed_response
      return nil unless data.is_a?(Hash)
      
      # extraer criptos y convertir
      data.slice('btc', 'usdc', 'usdt').transform_values do |crypto_data|
        crypto_data.select { |k, _v| k.match?(/^(usd|clp)_(buy|sell)$/) }
                   .transform_values { |v| BigDecimal(v.to_s) }
      end
    rescue JSON::ParserError, ArgumentError => e
      Rails.logger.error("Failed to parse API response: #{e.message}")
      nil
    end

    def valid_prices?(prices)
      return false if prices.nil? || !prices.is_a?(Hash)
      
      required_currencies = %w[btc usdc usdt]
      return false unless required_currencies.all? { |currency| prices.key?(currency) }
      
      # verificar  (buy/sell)
      required_currencies.all? do |currency|
        prices[currency].is_a?(Hash) &&
          prices[currency].key?('usd_buy') &&
          prices[currency].key?('usd_sell') &&
          prices[currency].key?('clp_buy') &&
          prices[currency].key?('clp_sell')
      end
    end

    def default_prices
      # mock de precios por si la api falla
      Rails.logger.info("Using default prices")
      {
        'btc' => {
          'usd_buy' => BigDecimal('0.000015507'),
          'usd_sell' => BigDecimal('0.000015352'),
          'clp_buy' => BigDecimal('0.00000002035'),
          'clp_sell' => BigDecimal('0.00000001465')
        },
        'usdc' => {
          'usd_buy' => BigDecimal('1.0'),
          'usd_sell' => BigDecimal('1.0'),
          'clp_buy' => BigDecimal('0.001312'),
          'clp_sell' => BigDecimal('0.000945')
        },
        'usdt' => {
          'usd_buy' => BigDecimal('1.0035'),
          'usd_sell' => BigDecimal('0.9965'),
          'clp_buy' => BigDecimal('0.001166'),
          'clp_sell' => BigDecimal('0.00084')
        }
      }
    end
  end
end
