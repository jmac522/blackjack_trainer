# -*- coding: utf-8 -*-
require_relative '../game_info'
require_relative 'card'
require_relative 'deck.rb'
require_relative 'house'
require_relative 'player'
require 'pry'

def build_player_array(number_of_players)
  player_array = []
  number_of_players.times do |player_number|
    puts "Player #{player_number + 1}, enter your name:"
    name = gets.chomp
    puts "Now enter how much money you are playing with:"
    money = gets.chomp
    player_array << Player.new(name, money)
  end
  player_array
end

def count_value(card)
  if card.pos_count?
    1
  elsif card.neg_count?
    -1
  else
    0
  end
end

def  take_bets(player_array)
  player_array.each do |player|
    puts "#{player.id}, how much would you like to bet (dollars)?:"
    player_bet = gets.chomp.to_i
    player.bet = player_bet
  end
end

def deal_round(player_array, house, game_deck)
  # add in deck_count tracker
  2.times do
    player_array.each do |player|
      player_card = game_deck.deal
      game_deck.count += count_value(player_card)
      # binding.pry
      player.hand << player_card
      player.value_hand
      puts "#{player.id} was dealt the #{player_card.rank} of #{player_card.suit}"
    end
    house_card = game_deck.deal
    game_deck.count += count_value(house_card)
    house.hand << house_card
    house.value_hand
  end
  puts "House is showing the #{house.hand.last.rank} of #{house.hand.last.suit} "
end


def play_round(player_array, house, game_deck)
  player_array.each do |player|
      # binding.pry
    until player.bust? || player.has_blackjack? || player.doubled_down? || player.stand?

      puts "You have #{player.hand_value}, #{player.id}. Hit (h), Stand (s), or Double down (d)?"
      # binding.pry
      player_choice = gets.chomp
      if player_choice == "h"
        player_card = game_deck.deal
        game_deck.count += count_value(player_card)
        player.hand << player_card
        puts "You were dealt the #{player_card.rank} of #{player_card.suit}."
        player.value_hand
        player.go_bust?
        if player.bust
          puts "You busted!"
        end
      elsif player_choice == "s"
        player.stand = true
      elsif player_choice == "d"
        player_card = game_deck.deal
        game_deck.count += count_value(player_card)
        player.hand << player_card
        puts "You were dealt the #{player_card.rank} of #{player_card.suit}."
        player.double_d
        player.value_hand
        player.go_bust?
        if player.bust
          puts "You busted!"
        end
      elsif player_choice == "c"
        puts "The count is #{game_deck.count}"
      elsif player_choice == "help"
        puts strategy(player, house)
      else
        puts "invalid selection"
      end
    end
  end
  puts "The house has #{house.hand_value}"
  until house.hand_value >= 17
    puts "The House hits!"
    house_card = game_deck.deal
    game_deck.count += count_value(house_card)
    house.hand << house_card
    puts "The house got the #{house_card.rank} of #{house_card.suit}"
    house.value_hand
    house.go_bust?
    if house.bust
      puts "The House busted!"
    end
  end
end

def payouts(player_array, house, game_deck)
  #check blackjack payouts
  if house.bust
    player_array.each do |player|
      if player.bust
        player.money -= player.bet
        puts "Sorry #{player.id}, you busted! You lose #{player.bet}!"
      else
        if player.double_down
          player.money += (player.bet)
          puts "Congrats, #{player.id} you won #{player.bet}!"
        elsif player.has_blackjack?
          player.money += (player.bet * 1.5)
          puts "Congrats, #{player.id}! Black Jack! You won #{player.bet * 1.5}!"
        else
          player.money += player.bet
          puts "Congrats, #{player.id} you won #{player.bet}!"
        end
      end
    end
  else
    player_array.each do |player|
      if player.bust
        player.money -= player.bet
        puts "Sorry #{player.id}, you busted! You lose #{player.bet}!"
      else
        if player.hand_value > house.hand_value
          if player.double_down
            player.money += (player.bet)
            puts "Congrats, #{player.id} you won #{player.bet}!"
          elsif player.has_blackjack?
            player.money += (player.bet * 1.5)
            puts "Congrats, #{player.id}! Black Jack! You won #{player.bet * 1.5}!"
          else
            player.money += player.bet
            puts "Congrats, #{player.id} you won #{player.bet}!"
          end
          #player blackjack vs computer 21
        elsif player.hand_value < house.hand_value
          player.money -= player.bet
          puts "Sorry #{player.id}, you lose #{player.bet}!"
        end
      end
    end
  end
end

def full_round(player_array, house, game_deck)
  take_bets(player_array)
  deal_round(player_array, house, game_deck)
  # value_player_hands(player_array)
  # value_house_hand(house)
  play_round(player_array, house, game_deck)
  payouts(player_array, house, game_deck)
  print_scores(player_array)
  another_round?(player_array, house, game_deck)
end

def print_scores(player_array)
  player_array.each do |player|
    puts"#{player.id} has #{player.money} dollars"
  end
end

def hand_reset(player_array, house)
  player_array.each do |player|
    player.hand = []
    player.stand = false
    player.double_down = false
    player.bust = false
    player.black_jack = false
  end
  house.hand = []
  house.bust = false
end


def another_round?(player_array, house, game_deck)
  puts "Would you like to play another round? (y/n)"
  selection = gets.chomp
  if selection == "y"
    hand_reset(player_array, house)
    full_round(player_array, house, game_deck)
  else
    puts "Thanks for playing!"
  end
end


def play_game
  puts "Welcome to Black Jack"
  puts "How many people are playing?"
  number_playing = gets.chomp.to_i
  puts "How many decks would you like to play with?"
  number_of_decks = gets.chomp.to_i
  player_array = build_player_array(number_playing)
  house = House.new
  game_deck = Deck.new(number_of_decks)
  full_round(player_array, house, game_deck)
end

def strategy (player, house)
  if !player.soft
    if house.show.rank == "2"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "3"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "4"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Stand"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "5"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Stand"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "6"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Stand"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "7"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "8"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "9"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "10" || house.show.is_face_card
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Hit"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "A"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Hit"
      elsif player.value_hand == 11
        puts "Hit"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    end
  else
    if house.show.rank == "2"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "3"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "4"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Stand"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "5"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Stand"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "6"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Double Down"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Stand"
      elsif player.value_hand == 13
        puts "Stand"
      elsif player.value_hand == 14
        puts "Stand"
      elsif player.value_hand == 15
        puts "Stand"
      elsif player.value_hand == 16
        puts "Stand"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "7"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "8"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "9"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Double Down"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "10" || house.show.is_face_card?
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Hit"
      elsif player.value_hand == 11
        puts "Double Down"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    elsif house.show.rank == "A"
      if player.value_hand <= 8
        puts "Hit"
      elsif player.value_hand == 9
        puts "Hit"
      elsif player.value_hand == 10
        puts "Hit"
      elsif player.value_hand == 11
        puts "Hit"
      elsif player.value_hand == 12
        puts "Hit"
      elsif player.value_hand == 13
        puts "Hit"
      elsif player.value_hand == 14
        puts "Hit"
      elsif player.value_hand == 15
        puts "Hit"
      elsif player.value_hand == 16
        puts "Hit"
      elsif player.value_hand >= 17
        puts "Stand"
      end
    end
  end
end

play_game
