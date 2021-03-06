# frozen_string_literal: true

module Capwatch
  class List
    attr_accessor :config
    def initialize(config:)
      @config = config
      Console::Formatter.currency = config.currency
    end

    def watch
      response = Providers::CoinMarketCap.new(config: config).fetched_json
      body = format(response)
      table  = Terminal::Table.new do |t|
        t.style = {
          # border_top: false,
          border_bottom: false,
          border_y: "",
          border_i: "",
          padding_left: 1,
          padding_right: 1
        }
        t.headings = [
          "SYMBOL",
          "PRICE (#{config.currency})",
          "MARKET CAP (B) (#{config.currency})",
          "24H %",
          "7D %"
        ]
        body.each { |x| t << x }
      end

      table
    end

    private

    def format(response, limit: 100)
      response.first(limit).map.with_index(1) do |coin, i|
        [
          "#{i}) #{coin["name"]}",
          Console::Formatter.format_fiat(coin[price_attribute]),
          Console::Formatter.format_fiat(coin[market_cap].to_f / (1_000_000 * 1_000)),
          Console::Formatter.condition_color(Console::Formatter.format_percent(coin["percent_change_24h"])),
          Console::Formatter.condition_color(Console::Formatter.format_percent(coin["percent_change_7d"]))
        ]
      end
    end

    def price_attribute
      "price_#{config.currency.downcase}"
    end

    def market_cap
      "market_cap_#{config.currency.downcase}"
    end
  end
end
