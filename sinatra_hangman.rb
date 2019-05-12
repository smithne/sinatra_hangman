require 'sinatra'
require 'sinatra/reloader'
require './hangman.rb'

#index
get '/' do
    message_encrypted = ""
    erb :index#, :locals => {:message_encrypted => message_encrypted}

end

get '/new' do
    #message_plain = params['message_plain']
    game = Hangman.new('new')
    erb :game, :locals => {:game => game}
end

get '/load' do
    game = Hangman.new('load')
    erb :game, :locals => {:game => game}
end

get '/game' do
    
end