# frozen_string_literal: true

module Capwatch
  class Fund
    attr_accessor :provider, :config, :coins, :positions

    def initialize(provider:, config:)
      @provider = provider
      @config = config
      @positions = config.positions
      @coins = config.coins
      build
    end

    def [](symbol)
      coins.find { |coin| coin.symbol == symbol }
    end

    def value_btc
      coins.map(&:value_btc).sum
    end

    def value_fiat
      coins.map(&:value_fiat).sum
    end

    def value_eth
      coins.map(&:value_eth).sum
    end

    def percent_change_1h
      coins.map { |coin| coin.percent_change_1h * coin.distribution }.sum
    end

    def percent_change_24h
      coins.map { |coin| coin.percent_change_24h * coin.distribution }.sum
    end

    def percent_change_7d
      coins.map { |coin| coin.percent_change_7d * coin.distribution }.sum
    end

    def build
      assign_quantity
      assign_prices
      distribution
    end

    def assign_quantity
      coins.each do |coin|
        coin.quantity = positions[coin.symbol]
      end
    end

    def assign_prices
      coins.each do |coin|
        provider.update_coin(coin)
      end
    end

    def distribution
      coins.each do |coin|
        coin.distribution = coin.value_btc / value_btc
      end
    end

    def serialize
      coins.map { |coin| coin.serialize }.to_json
    end

    def fund_totals
      {
        value_fiat: value_fiat,
        value_btc: value_btc,
        value_eth: value_eth,
        percent_change_24h: percent_change_24h,
        percent_change_7d: percent_change_7d
      }
    end

    def console_table
      Console.new(name = config.name, currency = config.currency, body = serialize, totals = fund_totals).draw_table
    end
  end
end
