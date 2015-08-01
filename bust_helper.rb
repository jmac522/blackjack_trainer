module BustHelper

  def has_ace?
    hand.each do |card|
      if card.is_ace?
        return true
      end
    end
  end

  def soft
    if has_ace?
      true
    else
      false
    end
  end

  def sort_hand
    ace_array = []
    hand.each do |card|
      if card.is_ace?
        ace_array << card
        hand.delete(card)
      end
    end
    ace_array.each do |card|
      hand << card
    end
  end

  def value_hand
    @hand_value = 0
    sort_hand
    hand.each do |card|
      if card.is_ace?
        if (hand_value + (card.value)[0]) <= 21
          @hand_value += (card.value)[0]
        else
          @hand_value += (card.value)[1]
        end
      else
        @hand_value += card.value
      end
    end
    @hand_value
  end

  def has_blackjack?
    if hand.length == 2
      if (hand.first.is_ace?)
        if hand.last.is_face_card? || hand.last.rank == "10"
          @black_jack = true
          true
        end
      elsif (hand.first.is_face_card? || hand.first.rank == "10")
        if hand.last.is_ace?
          @black_jack = true
          true
        end
      else
        @black_jack = false
        false
      end
    else
      false
    end

  end

  def go_bust?
    if hand_value > 21
      @bust = true
    end
  end

  def bust?
    bust
  end
end
