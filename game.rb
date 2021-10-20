# frozen_string_literal: true

require 'pry-byebug'
require_relative 'secret_code'
require_relative 'guess'
require_relative 'ai'
# rubocop:disable all
# Game of cracking a code
class Game
  # attr_accessor :secret_code, :guesses_remaining

  def initialize
    @guesses_remaining = 100
    @secret_code = SecretCode.new
    @guess = Guess.new
    @game_won = true
  end

  def print_rules
    puts <<~RULES
      \n*** Rules ***
        A secret coded has been generated from
        the following colors:
          #{@secret_code.possible_colors}
        The code is four of those colors in order,
        duplicates allowed.

        When you guess, you will recieve feedback.
          *red means a correct color was in the correct position
          *white means a correct color in the wrong position
        
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

      input = gets.chomp
      case input
      when '1' 
        print_rules
      when '2' 
        play_guess_the_code
        initialize
      when '3' 
        play_create_the_code
        initialize
      when '4'
        play = false
      end
    end
  end

  def play_create_the_code
    computer_player = Ai.new(@secret_code.possible_colors.clone)
    # set_code

    until game_over?

      @guess = @secret_code.generate_feedback(computer_player.generate_guess)
      computer_player.process_feedback(@guess)
      @guesses_remaining -= 1
      @game_won = false if @guess.feedback.count('red') == 4
    end
    puts game_over_message('create')
  end

  def play_guess_the_code
    until game_over?
      puts <<~GUESS
        Your guess feedback is: #{@secret_code.generate_feedback(build_guess).feedback}
      GUESS
      @guesses_remaining -= 1
      @game_won = false if @guesses_remaining.zero?
    end
    puts game_over_message('guess')
  end

  def build_guess
    @guess = Guess.new
    puts "\nYou have #{@guesses_remaining} guesses left."
    puts "Your final guess is #{@guess.code = prompt_colors}"
    @guess
  end

  def set_code
    # binding.pry
    @secret_code.change_secret_code(prompt_colors)
    puts "You set the code to #{@secret_code.secret_code}"
  end

  def prompt_colors
    code = %w[]
    while code.length < 4 do 
      puts <<~PROMPT

        So far your code is #{code}.
        Enter a color: #{@secret_code.possible_colors}
      PROMPT
      color = gets.chomp
      code.push(color) if validate_color(color)
    end
    code
  end

  def validate_color(color)
    if @secret_code.possible_colors.any? { |s| s.casecmp(color)==0 }
      return color
    else
      puts 'Invalid Input'
    end
  end

  def game_over?
    @guesses_remaining.zero? ||
      @guess.code.eql?(@secret_code.secret_code)
  end

  def game_over_message(game_type)
    win_message = +"\n"
    if @game_won
      win_message << "Congratulations!"
      win_message << "\nYou stumped the computer; it ran out of guesses." if game_type == 'create'
      win_message << "\nYou guessed the code!" if game_type == 'guess'
    else
      win_message << "You're out of guesses!  The computer won." if game_type == 'guess'
      win_message << "The computer guessed your code!  The computer won." if game_type == 'create'
    end
    win_message << "\nThe secret code was = #{@secret_code.secret_code}"
    win_message << "\nGame Over"
  end

    # rubocop:enable all
end
