require 'shoes'
require_relative 'blobs'

FPS = 30
BLOB_COUNT = 10

blobs = []
#(BLOB_COUNT/3).times{ blobs << WonderBlob.new }
(BLOB_COUNT/3).times{ blobs << FollowBlob.new }
(BLOB_COUNT/3).times{ blobs << RepelBlob.new }

Shoes.app :title => 'and such' do
  animate = animate FPS do
    begin
      clear
      blobs.each{ |b| b.render(self) }
      blobs.each{ |b| b.tick blobs.reject{|o| o == b }}
    rescue => ex
      puts "EX: #{ex}"
    end
  end
end
