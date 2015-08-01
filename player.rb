
class Player
  include BustHelper
  attr_reader  :id, :double_down
  attr_accessor :money, :bust, :hand, :no_of_cards, :bet, :hand_value, :black_jack, :stand, :double_down
  def initialize (id, money)
    @id = id
    @money = money.to_i
    @double_down = false
    @bust = false
    @hand = []
    @hand_value = 0
    @no_of_cards = 0
    @bet = 0
    @black_jack = false
    @stand = false
  end

  def stand?
    @stand
  end

  def double_d
    @double_down = true
    @bet = bet * 2
  end

  def doubled_down?
    double_down
  end

  def has_money?
    money > 0
  end
end
