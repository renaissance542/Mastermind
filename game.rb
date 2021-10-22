# frozen_string_literal: true

require 'pry-byebug'
require_relative 'secret_code'
require_relative 'guess'
require_relative 'ai'
require_relative 'player'

# Game of cracking a code
class Game

  def initialize
    @guesses_remaining = 12
    @secret_code = SecretCode.new
    @guess = Guess.new
    @game_won = true
    @player = Player.new(@secret_code.possible_colors.clone)
  end

  def print_rules
    puts <<~RULES
      \n*** Rules ***
        A secret code has been generated from
        the following colors:
          #{@secret_code.possible_colors}
        The code is four of those colors in a specific order,
        duplicates allowed.

        Example Codes:
          ["red" "blue" "red" "black"]
            or
          ["white" "yellow" "yellow" "green"]

        When you guess the code, you will recieve feedback.
          "red" means a correct color was in the correct position
          "white" means a correct color in the wrong position

        Example Feedback:
          [] means none of the colors in your guess were correct.

          ["red" "white"] means the following:
           *One of your colors was correct and in the correct position.
           *One of your colors was correct but in the wrong position.
           *Two of your colors were incorrect and not in the solution.

          ["white" "white" "white" "white"] means:
            *All of the colors were correct.
            *None of them were in the correct positions.

        You must crack the code within 12 guesses.
    RULES
  end

  def main_menu
    puts 'Welcome to Mastermind!'
    play = true
    while play do
      puts <<~MENU
        \n*** Main Menu ***
          1. Print rules
          2. Guess the secret code
          3. Make a secret code for the computer to guess
          4. Quit
        Enter a number:
      MENU
      
      menu = {
        '1' => lambda{print_rules},
        '2' => lambda{play_guess_the_code}, 
        '3' => lambda{play_create_the_code}, 
        '4' => lambda{play = false},
      }
      input = gets.chomp
      menu[input].call
    end
  end

  def play_create_the_code
    computer_player = Ai.new(@secret_code.possible_colors.clone)
    puts <<~PROMPT
      \nYou must create a code of 4 colors.
      The colors are #{@secret_code.possible_colors}
      PROMPT
    @secret_code.change_secret_code(@player.prompt_colors)
    puts "You set the code to #{@secret_code.secret_code}"

    until game_over?
      @guess = @secret_code.generate_feedback(computer_player.generate_guess)
      computer_player.process_feedback(@guess)
      @guesses_remaining -= 1
      @game_won = false if @guess.feedback.count('red') == 4
    end
    end_game('create')
  end

  def play_guess_the_code
    until game_over?
      puts <<~PROMPT
      \nYou have #{@guesses_remaining} guesses left.
      The colors are #{@secret_code.possible_colors}
      PROMPT
      @guess = @secret_code.generate_feedback(@player.build_guess)
      puts <<~GUESS
        Your guess feedback is: #{@guess.feedback}
      GUESS
      @guesses_remaining -= 1
      @game_won = false if @guesses_remaining.zero?
    end
    end_game('guess')
  end

  def end_game(game_type)
    puts @player.game_over_message(game_type, @game_won)
    puts "\nThe secret code was = #{@secret_code.secret_code}"
    initialize
  end

  def game_over?
    @guesses_remaining.zero? ||
      @guess.code.eql?(@secret_code.secret_code)
  end
end
