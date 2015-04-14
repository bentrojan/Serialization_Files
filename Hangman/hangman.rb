$save = false

require 'pstore'

class Game

	def initialize
		@game = Hangman.new
		if load?
			load_game
		end
	end

	#game loop
	def play
		loop do 
			@game.turns
			if $save 
				save_game
			end
		end
	end

	#saves present state
	def save_game
		store = PStore.new("savegame")
		store.transaction do
			store[:game] = @game
		end
		puts "\n\ngame saved\n\nbye"
		exit
	end

	#loads saved state
	def load_game
		store = PStore.new("savegame")
		store.transaction do 
			@game = store[:game]
		end
		$save = false
		play
	end

	def load?
		load = String.new
		until load == "y" || load == "n"
			puts "Would you like to load your game from save? (Y/N)"
			load = gets.chomp.downcase
		end
		if load == "n"
			play
		else
			load_game
		end
	end

end



class Hangman

	def initialize
		@the_word = word_select
		@guess_tracker = []
		@progress_key = blank_spaces
		@wrong_guesses = []
		welcome
	end

	def welcome
		puts "\n\n\nWELCOME TO"
		puts "THE HANGMAN"
		puts "GAME!!!!!!"
	end

	def word_select
		file = File.open("5desk.txt", "r")
		list = file.readlines[18].split("<br/>")
		list.delete_if { |word| word.length > 12 || word.length < 5 }
		list[rand(0..list.length-1)].split("")
	end

	def blank_spaces
		@the_word.map { "_" }
	end

	#main game loop
	def turns
		display_gallows
		puts "\n #{display_progress}"
		puts "\nIncorrect guesses: #{display_wrong}"

		guess = solicit_guess

		unless guess == 'save'
			@guess_tracker << guess 
			check_guess

			if win?
				display_gallows
				puts "\n\n\n #{display_word}"
				puts "You win! You saved the convicted criminal, you monster!"
				exit
			elsif lose?
				display_gallows
				puts "\n\n\n #{display_word}"
				puts "Justice is served! He was hanged by the neck until he was dead!"
				exit
			end
		end

	end

	#solitics a guess and returns one letter that was not yet guessed
	def solicit_guess
		puts "\nPlease input a letter!"
		guess = gets.chomp.downcase
		if guess.downcase == "save"
			$save = true
		else	
			until !(@guess_tracker.include?(guess)) && (guess.length == 1) && (guess <= 'z' && guess >= 'a')
				puts "Unacceptable input (maybe you already guessed that?), please try again!"
				guess = gets.chomp.downcase
			end
		end
		guess
	end

	#checks @guess_tracker.last against word, file it properly
	def check_guess
		if @the_word.include?(@guess_tracker[-1])
			@the_word.each_index do |i|
				if @the_word[i].downcase == @guess_tracker[-1]
					@progress_key[i] = @the_word[i]
				end
			end
		else
			@wrong_guesses << @guess_tracker[-1]
		end
	end

	#displays letters of the word
	def display_progress
		@progress_key.join(" ")
	end

	#displays incorrect letters
	def display_wrong
		@wrong_guesses.sort.join(", ").upcase
	end

	#displays the word
	def display_word
		@the_word.join(" ")
	end

	#check for the victory
	def win?
		!(@progress_key.include?("_"))
	end

	#check for the loss
	def lose?
		@wrong_guesses.length == 6
	end

	#displays gallows (eventually)
	def display_gallows
		case @wrong_guesses.length
		when 0
			puts "\n|----"
			puts "|   |"
			puts "|"	
			puts "|"	
			puts "|"	
			puts "|"
			puts "|"
		when 1
			puts "\n|----"
			puts "|   |"
			puts "|   O"	
			puts "|"	
			puts "|"	
			puts "|"
			puts "|"
		when 2
			puts "\n|----"
			puts "|   |"
			puts "|   O"	
			puts "|   U"	
			puts "|"	
			puts "|"
			puts "|"
		when 3
			puts "\n|----"
			puts "|   |"
			puts "|   O"	
			puts "|   U/"	
			puts "|"	
			puts "|"
			puts "|"
		when 4
			puts "\n|----"
			puts "|   |"
			puts "|   O"	
			puts "|  \\U/"	
			puts "|"	
			puts "|"
			puts "|"
		when 5
			puts "\n|----"
			puts "|   |"
			puts "|   O"	
			puts "|  \\U/"	
			puts "|  /"	
			puts "|"
			puts "|"
		when 6
			puts "\n|----"
			puts "|   |"
			puts "|   O"	
			puts "|  \\U/"	
			puts "|  / \\"	
			puts "|"
			puts "|"
		end
					
		puts "\n#{(6-@wrong_guesses.length).to_s} guess(es) remain!"
	end
end






Game.new





