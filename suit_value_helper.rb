# -*- coding: utf-8 -*-
module SuitHelper
  def suits
    spades = "\u2660"
    hearts = "\u2665"
    clubs = "\u2663"
    diamonds = "\u2666"
    [spades, hearts, clubs, diamonds]
  end
  def values
    ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "A"]
  end
end
