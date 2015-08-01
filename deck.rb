# -*- coding: utf-8 -*-

require_relative 'suit_value_helper'

class Deck
  include SuitHelper
  attr_reader :game_deck, :starting_count
  attr_accessor :count
  def initialize(number_of_decks)
    @game_deck = []
    number_of_decks.times do
      suits.each do |suit|
        values.each do |value|
          @game_deck << Card.new(suit, value)
        end
      end
    end
    @count = -(number_of_decks * (2))
    @game_deck.shuffle!
  end

  def deal
    @game_deck.pop
  end
end
