# frozen_string_literal: true

require_relative 'guess'
#rubocop:disable all
# computer player to solve code
class Ai
  attr_accessor :confirmed_colors, :swappable_indices

  def initialize(colors)
    @possible_colors = colors  # delete after testing
    @confirmed_colors = %w[]
    @swappable_indices = [0, 1, 2, 3]
    @last_swapped = []
    @guesslist = []
    @guesslist.push(guess_new_color)
  end

# a guess should randomly pick a color to try
# or randomly pick a position to try
# or somehow, both

  def process_feedback(guess)

    if @guesslist.empty?
      @new_pegs = guess.feedback.length
      @delta_red_pegs = guess.feedback.count('red')
    else
      @new_pegs = guess.feedback.length - @guesslist.last.feedback.length
      @delta_red_pegs = guess.feedback.count('red') - @guesslist.last.feedback.count('red')
    end

    @guesslist.push(guess)
    
    # successfully guessed new color
    if @new_pegs > 0
      @new_pegs.times {|i| @confirmed_colors.push(guess.code.last)}
      @possible_colors = [] if @confirmed_colors.length == 4
    end
    
    # if a new color is guessed, and there are no new pegs,
    # and all the existing pegs are red, then all those positions
    # are certain.

    # if guess.feedback.length < 4 &&
    #   guess.feedback.length == @guesslist.last.feedback.length &&
    #   !guess.feedback.include?('white')
    #   guess.feedback.length.times {|i| @swappable_indices.delete(i)}
    # end

    puts "\nGUESS ##{@guesslist.length}"
    puts "guess colors = #{guess.code}"
    puts "feedback pegs = #{guess.feedback}"

    generate_guess unless @guesslist.last.feedback.count('red') == 4
    
  end

  def get_guess
    @guesslist.pop
  end

  def generate_guess
    if @guesslist.last.feedback.length < 4
      @guesslist.push(guess_new_color)

    elsif @guesslist.last.feedback.count('white') > 2
      @guesslist.push(rotate_guess)
      @last_swapped = []

    elsif @guesslist.last.feedback.length == 4
      # if the last guess had 4 pegs, and the current guess/swap
      # gained 2 red pegs, then lock those 2 positions
      @swappable_indices -= @last_swapped if @delta_red_pegs == 2 

      # if the last guess had 4 pegs and the current guess
      # LOST 2 red pegs, then use the last guess as the basis for the next guess

      # if the last guess had 4 pegs, and the current guess/swap
      # gained 1 red peg, then what?  
      # guess again from current state swapping the other 2 pegs

      @guesslist.push(guess_for_position)
    end
  end

  
  # private

  def guess_new_color
    # puts "guess_new_color called"
    guess = Guess.new
    guess.code += @confirmed_colors
    new_color = @possible_colors.sample
    @possible_colors.delete(new_color)
    until guess.code.length == 4 
      guess.code.push(new_color)
    end
    guess
  end

  def rotate_guess
    guess = Guess.new
    guess.code = @guesslist.last.code.shuffle
    guess
  end

  def guess_for_position

    # randomly pick 2 unlocked positions of different color from last guess
    duplicate_guess = [1]
    until duplicate_guess.empty? 
      next_guess = @guesslist.last.code.clone
      # puts "\nnext guess set to last guess: #{next_guess}"
      # puts "last feedback = #{@guesslist.last.feedback}"
      # puts "swappable_indices = #{@swappable_indices}"

      # repick the positions if they point to the same color in the code
      @last_swapped = @swappable_indices.sample(2)
      until next_guess[@last_swapped[0]] != next_guess[@last_swapped[1]]
        @last_swapped = @swappable_indices.sample(2) 
      end

      # swap those 2 positions for the next guess
      next_guess[@last_swapped[0]], next_guess[@last_swapped[1]] = 
        next_guess[@last_swapped[1]], next_guess[@last_swapped[0]]
      # puts "next_guess swapped to = #{next_guess}"
      duplicate_guess = @guesslist.select {|guess| guess.code == next_guess}


      # puts "duplicate_guess = #{duplicate_guess}"
      # counter = 0
      # @guesslist.each {|g| puts "Guess ##{counter += 1}: #{g.code}"}

    end

    guess = Guess.new
    guess.code = next_guess
    guess
  end

end