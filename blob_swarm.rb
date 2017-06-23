require 'shoes'
require_relative 'blobs'

FPS = 30
BLOB_COUNT = 10

wonders = []
repelers = []
followers = []
(BLOB_COUNT/3).times{ wonders << WonderBlob.new }
(BLOB_COUNT*10).times{ repelers << RepelBlob.new }
(BLOB_COUNT*2).times{ followers << FollowBlob.new }
blobs = wonders + repelers + followers

Shoes.app :title => 'and such' do
  animate = animate FPS do
    begin
      clear
      blobs.each{|b| b.render(self) }
      blobs.each{|b| b.tick blobs.reject{|o| o == b }}
    rescue => ex
      puts "EX: #{ex}"
    end
  end
end
