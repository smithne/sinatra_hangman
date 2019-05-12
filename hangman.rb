require 'json'

class Hangman
    attr_reader :guessed_letters, :remaining_guesses, :guess_string


    @@min_length = 5
    @@max_length = 12
    @@wordlist_file = 'wordlist.txt'
    @@save_file = "saved_game.json"
    @@guess_limit = 8
    @@wordlist = []
    @@alphabet = 'abcdefghijklmnopqrstuvwxyz'

    File.open(@@wordlist_file, "r") do |file|
        file.readlines.each do |word|
            word = word.strip
            @@wordlist << word if ((word.length >= @@min_length) && (word.length <= @@max_length))
        end   
    end

    def initialize(choice)
        if choice == "new"
            @secret_word = @@wordlist[rand(@@wordlist.length)].downcase
            @guess_count = 0
            @remaining_guesses = "o" * @@guess_limit
            @guessed_letters = ""
            @guess_string = "_" * @secret_word.length
        else
            data = JSON.load File.read(@@save_file)
            @secret_word = data['secret_word']
            @guess_count = data['guess_count']
            @remaining_guesses = data['remaining_guesses']
            @guessed_letters = data['guessed_letters']
            @guess_string = data['guess_string']
        end
        #@alphabet = {}
        #self.set_alphabet
        @winner = nil
        self.new_game
    end

    def new_game
        begin
            if guess_char == 'save'
                self.save_game
                break
            elsif @guessed_letters.include? guess_char
                puts "already guessed"
            elsif @secret_word.include? guess_char
                @secret_word.split("").each_with_index do |secret_char, index|
                    if guess_char == secret_char
                        @guess_string[index] = guess_char
                    end
                end
                @guessed_letters += guess_char
            else
                @remaining_guesses[@guess_count] = 'x'
                @guessed_letters += guess_char
                @guess_count += 1
            end
            print_status
            puts
            winner = check_winner
        end until winner
        
        puts winner ? winner + " wins!" : "game saved"

    end

    def check_winner
        if !(@guess_string.include? '_')
            return 'guesser'
        elsif @guess_count == @@guess_limit
            return 'computer'
        else
            return nil
        end
    end

    def print_status
        # print underscores representing each character
        puts "word: " + @guess_string
        # print guesses
        puts "guessed letters: " + @guessed_letters
        # print remaining number of guesses
        puts "remaining guesses: " + @remaining_guesses
    end

    def load_game

        data = JSON.load game_string
        data['secret_word']
        data['guess_string']
        data['guessed_letters']

    end

    def alphabet
        return @@alphabet
    end

    def from_json(string)
        data = JSON.load string
        self.new(data['name'], data['age'], data['gender'])
    end

    def save_game
        json_string = self.to_json
        File.write(@@save_file, json_string)
    end

    def to_json
        JSON.dump ({
            :secret_word => @secret_word,
            :guess_string => @guess_string,
            :guessed_letters => @guessed_letters,
            :remaining_guesses => @remaining_guesses,
            :guess_count => @guess_count
        })
    end

end