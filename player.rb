# frozen_string_literal: true

# handles player input and some output
class Player
  def initialize(colors)
    @possible_colors = colors
  end

  def game_over_message(game_type, game_won)
    win_message = +"\n"
    if game_won
      win_message << 'Congratulations!'
      win_message << "\nYou stumped the computer; it ran out of guesses." if game_type == 'create'
      win_message << "\nYou guessed the code!" if game_type == 'guess'
    else
      win_message << "You're out of guesses!  The computer won." if game_type == 'guess'
      win_message << 'The computer guessed your code!  The computer won.' if game_type == 'create'
    end
    win_message << "\nGame Over."
  end

  def build_guess
    guess = Guess.new
    puts "\nYour final guess is #{guess.code = prompt_colors}"
    guess
  end

  def prompt_colors
    code = %w[]
    while code.length < 4 do 
      puts <<~PROMPT

        So far your code is #{code}.
        Enter a color:
      PROMPT
      color = gets.chomp
      code.push(color) if validate_color(color)
    end
    code
  end

  def validate_color(color)
    if @possible_colors.any? { |s| s.casecmp(color)==0 }
      return color
    else
      puts 'Invalid Input'
    end
  end
end
