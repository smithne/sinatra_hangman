require 'sinatra'
#require 'sinatra/reloader'
require 'json'

configure do
    set :session_secret, "d9ad6e3931cdcba02b37ff597abf7ee97d8f794da6b6f82390285bd45bfeacbbc20bff919d520280701f2193d51a815ae37351a7b895087045853fad6f3a045c"
    enable :sessions
end

get '/' do
    erb :index
end

get '/new' do
    redirect to '/'
end

post '/new' do
    game = Hangman.new('new')
    session = to_session(game)
    puts session
    puts 'secret word: ' + session[:secret_word]
    erb :game, :locals => {:game => game}
end

post '/load' do
    game = Hangman.new('load')
    
    erb :game, :locals => {:game => game}
end

post '/game' do
    choice = params['choice']
    game = Hangman.new('load', session)
    puts session
    #game.from_session(session)
    puts session
    puts game.secret_word
    game.guess(choice)
    winner = game.check_winner()
    session = to_session(game)
    puts winner
    if !winner
        erb :game, :locals => {:game => game}
    elsif winner == 'guesser'
        'You win!'
    else
        'You lose! The word was: ' + game.secret_word
    end

    #erb :index if winner != nil
end

def to_session(game)
    session[:secret_word] =  game.secret_word
    session[:guess_string] = game.guess_string
    session[:guessed_letters] = game.guessed_letters
    session[:remaining_guesses] = game.remaining_guesses
    session[:guess_count] = game.guess_count
    session
end

class Hangman
    attr_reader :guessed_letters, :remaining_guesses, :guess_string, :secret_word, :guess_count

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

    def initialize(choice, session=nil)
        if choice == "new"
            @secret_word = @@wordlist[rand(@@wordlist.length)].downcase
            @guess_count = 0
            @remaining_guesses = "o" * @@guess_limit
            @guessed_letters = ""
            @guess_string = "_" * @secret_word.length
        else
            puts session[:secret_word]
            #data = JSON.load File.read(@@save_file)
            @secret_word = session[:secret_word]
            @guess_count = session[:guess_count]
            @remaining_guesses = session[:remaining_guesses]
            @guessed_letters = session[:guessed_letters]
            @guess_string = session[:guess_string]
        end
        @winner = nil
    end

    def guess(guess_char)
        if @secret_word.include?(guess_char)
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

    end

    def from_session(session)
        @secret_word = session[:secret_word]
        @guess_string = session[:guess_string]
        @guessed_letters = session[:guessed_letters]
        @remaining_guesses = session[:remaining_guesses]
        @guess_count = session[:guess_count]
    end

    def to_session(session)
        session[:secret_word] =  @secret_word
        session[:guess_string] = @guess_string
        session[:guessed_letters] = @guessed_letters
        session[:remaining_guesses] = @remaining_guesses
        session[:guess_count] = @guess_count
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

    def alphabet
        return @@alphabet
    end



    # implement saving game later
    
    def load_game

        data = JSON.load game_string
        data['secret_word']
        data['guess_string']
        data['guessed_letters']

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