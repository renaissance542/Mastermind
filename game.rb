# frozen_string_literal: true

require 'pry'
require_relative 'secret_code'
require_relative 'guess'
require_relative 'ai'

# Game of cracking a code
class Game
  # attr_accessor :secret_code, :guesses_remaining

  def initialize
    @guesses_remaining = 100
    @secret_code = SecretCode.new
    @guess = Guess.new
    @game_won = false
  end

  def print_rules
    puts <<~RULES
      A secret coded has been generated from
      the following colors:
        #{@secret_code.possible_colors}
      The code is four of those colors in order,
      duplicates allowed.

      You must crack the code within 12 guesses.

    RULES
  end
  
    #   show rules
    #   create a code
    #     enter 4 colors
    #     computer guesses the code
    #     computer reports number of guesses required
    #   crack a code
    #     computer generates a code
    #     player guesses
    #     game ends win/lose
    #   set code colors
    #   quit  

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize

  def main_menu
    puts 'Welcome to Mastermind!'
    play = true
    while play do
      puts <<~MENU
        *** Main Menu ***
          1. Print rules
          2. Guess the secret code
          3. Make a secret code for the computer to guess
          4. Quit
        Enter a number:
      MENU

      input = gets.chomp
      case input
      when '1' 
        print_rules
      when '2' 
        play_guess_the_code
      when '3' 
        play_create_the_code
      when '4'
        play = false
      end
    end
  end

  def play_create_the_code
    secret = SecretCode.new
    computer_player = Ai.new(secret.possible_colors)

    evaluated_guess = secret.submit_guess(computer_player.guess_new_color)
    computer_player.process_feedback(evaluated_guess)

    until @guesses_remaining.zero? || @game_won

      evaluated_guess = secret.submit_guess(computer_player.get_guess)
      computer_player.process_feedback(evaluated_guess)
      @guesses_remaining -= 1
    
      binding.pry
      @game_won = true if evaluated_guess.feedback.count('Red') == 4

      # puts "\nAI confirmed these colors = #{computer_player.confirmed_colors}"
      # puts "AI swappable_indices = #{computer_player.swappable_indices}"
      # puts "secret code is = #{secret.secret_code}"
    end



    puts "\nGame Over"
    puts "The code was guessed correctly" if @game_won
    puts "The secret code was = #{secret.secret_code}"
  end

  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def play_guess_the_code
    until game_over?
      puts <<~GUESS

        Your guess feedback is: #{@secret_code.submit_guess(build_guess).feedback}
             **Red means a correct color in correct spot
             **White means a correct color in the wrong spot
      GUESS
      @guesses_remaining -= 1
    end
    puts 'Game Over'
  end

  def build_guess
    @guess = Guess.new
    puts "\nYou have #{@guesses_remaining} guesses left."
    prompt_colors
    puts "\nYour final guess is #{@guess.code}"
    @guess
  end

  def prompt_colors
    while @guess.code.length < 4 do 
      puts <<~PROMPT

        So far your guess is #{@guess.code}.
        Enter a color: #{@secret_code.possible_colors}
      PROMPT
      add_color(gets.chomp)
    end
  end

  def add_color(color)
    if @secret_code.possible_colors.include?(color)
      @guess.code.push(color)
    else
      puts 'Invalid Input'
    end
  end

  def game_over?
    @guesses_remaining.zero? ||
      @guess.code.eql?(@secret_code.secret_code)
  end
end
