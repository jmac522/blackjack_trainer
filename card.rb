# -*- coding: utf-8 -*-

class Card
  attr_reader :suit, :rank

  def initialize(suit, rank)
    @suit = suit
    @rank = rank

  end

  def value
    if is_face_card? || rank == "10"
      10
    elsif is_ace?
      [11, 1]
    else
      rank.to_i
    end
  end

  def is_face_card?
    face_cards = ["J", "Q", "K"]
    face_cards.include?(rank)
  end

  def is_ace?
    rank == "A"
  end

  def pos_count?
    rank.to_i < 7
  end

  def neg_count?
    rank.to_i > 7 || (is_face_card? || is_ace?)
  end
end
