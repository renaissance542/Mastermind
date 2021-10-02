# frozen_string_literal: true

require 'pry'
require_relative 'secret_code'
require_relative 'guess'
require_relative 'ai'

# Game of cracking a code
class Game
  # attr_accessor :secret_code, :guesses_remaining

  def initialize
    @guesses_remaining = 12
    @secret_code = SecretCode.new
    @guess = Guess.new
    @game_won = false
  end

  def print_rules
    puts <<~RULES
      Welcome to Mastermind!

      A secret coded has been generated from
      the following colors:
        #{@secret_code.colors}
      The code is four of those colors in order,
      duplicates allowed.

      You must crack the code within 12 guesses.

    RULES
  end

  def play
    print_rules
    until game_over?
      puts <<~GUESS

        Your guess feedback is: #{@secret_code.guess_code(build_guess).feedback}
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
        Enter a color: #{@secret_code.colors}
      PROMPT
      add_color(gets.chomp)
    end
  end

  def add_color(color)
    if @secret_code.colors.include?(color)
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

# game = Game.new
# game.play
secret = SecretCode.new
computer_player = Ai.new(secret.possible_colors)


evaluated_guess = secret.submit_guess(computer_player.guess_for_color)
computer_player.process_feedback(evaluated_guess)

guesses_remaining = 11
until guesses_remaining.zero? || @game_won

  evaluated_guess = secret.submit_guess(computer_player.get_guess)
  computer_player.process_feedback(evaluated_guess)
  guesses_remaining -= 1

  @game_won = true if evaluated_guess.feedback.count('Red') == 4
    
  # puts "\nAI confirmed these colors = #{computer_player.confirmed_colors}"
  # puts "AI swappable_indices = #{computer_player.swappable_indices}"
  # puts "secret code is = #{secret.secret_code}"
end

# binding.pry

puts "\nGame Over"
puts "The code was guessed correctly" if @game_won
puts "The secret code was = #{secret.secret_code}"
