# frozen_string_literal: true

require_relative 'guess'

# computer player to solve code
class Ai
  def initialize(colors)
    @possible_colors = colors
    @confirmed_colors = %w[]
    @swappable_indices = [0, 1, 2, 3]
    @last_swapped = []
    @guesslist = []
    @duplicate_guess_count = 0
  end

  def process_feedback(guess)
    count_feedback_pegs(guess)
    @guesslist.push(guess)

    # successfully guessed new color
    if @new_pegs.positive?
      @new_pegs.times { @confirmed_colors.push(guess.code.last) }
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
  end

  def generate_guess
    return guess_new_color if @guesslist.empty? || @guesslist.last.feedback.length < 4

    if stuck_or_lost
      @last_swapped = []
      return rotate_guess
    end

    if @guesslist.last.feedback.length == 4
      # if the last guess had 4 pegs, and the current guess/swap
      # gained 2 red pegs, then lock those 2 positions
      @swappable_indices -= @last_swapped if @delta_red_pegs == 2

      # if the last guess had 4 pegs and the current guess
      # LOST 2 red pegs, then use the last guess as the basis for the next guess

      # if the last guess had 4 pegs, and the current guess/swap
      # gained 1 red peg, then what?  
      # guess again from current state swapping the other 2 pegs

      return guess_for_position
    end
  end

  # private

  def count_feedback_pegs(guess)
    @new_pegs = guess.feedback.length
    @delta_red_pegs = guess.feedback.count('red')
    return if @guesslist.empty?

    @new_pegs -= @guesslist.last.feedback.length
    @delta_red_pegs -= @guesslist.last.feedback.count('red')
  end

  def stuck_or_lost
    @guesslist.last.feedback.count('white') == 4 || @duplicate_guess_count > 10
  end

  def guess_new_color
    # puts "guess_new_color called"
    guess = Guess.new
    guess.code += @confirmed_colors
    new_color = @possible_colors.sample
    @possible_colors.delete(new_color)
    guess.code.push(new_color) until guess.code.length == 4
    guess
  end

  def rotate_guess
    next_guess = nil
    next_guess = @guesslist.last.code.shuffle until valid_guess?(next_guess)
    @duplicate_guess_count = 0
    guess = Guess.new
    guess.code = next_guess
    guess
  end

  def guess_for_position
    next_guess = 0
    loop do # repick duplicate guesses to get a new guess
      next_guess = @guesslist.last.code.clone

      get_swap_indices(next_guess)

      # swap those 2 positions for the next guess
      next_guess = swap_two_colors(next_guess)
      break if valid_guess?(next_guess)
    end

    guess = Guess.new
    guess.code = next_guess
    guess
  end

  def get_swap_indices(next_guess)
    loop do # repick if both positions point to the same color 
      @last_swapped = @swappable_indices.sample(2)
      break if next_guess[@last_swapped[0]] != next_guess[@last_swapped[1]]
    end
  end

  def swap_two_colors(next_guess)
    next_guess[@last_swapped[0]], next_guess[@last_swapped[1]] =
      next_guess[@last_swapped[1]], next_guess[@last_swapped[0]]
    next_guess
  end

  def valid_guess?(code)
    return false if code == nil

    unique = @guesslist.none? { |g| g.code == code }
    @duplicate_guess_count += 1 unless unique
    unique
  end
end
