require_relative 'bust_helper'

class House
  include BustHelper
  attr_accessor :hand, :no_of_cards, :hand_value, :bust
  def initialize(bust = false)
    @hand = []
    @hand_value = 0
    @no_of_cards = 0
    @bust = bust
  end

  def show
    hand[1]
  end

end
