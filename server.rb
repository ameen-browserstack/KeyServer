require 'sinatra'
require_relative 'keyserver.rb'
$keysrv = KeyServer.new

get '/E1' do
  if params[:n].nil?
    $keysrv.generate_keys(1)
  else 
    $keysrv.generate_keys(params[:n].to_i)
  end
  $keysrv.to_s
end

get '/E2' do
  $keysrv.serve_key
end

get '/E3' do
  $keysrv.unblock_key(params[:key])
end

get '/E4' do
  $keysrv.delete_key(params[:key])
end

get '/E5' do
  $keysrv.keep_alive(params[:key])
end

