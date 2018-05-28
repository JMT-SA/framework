require 'socket'

4.times do
  sock = TCPSocket.open('localhost', 2626)
  request = 'pallet::build_up::pno=1234,usr=22'
  puts "\nREQUESTED: #{request}"

  sock.puts request
  result = sock.read

  puts "Response from server:\n\n#{result}"
  # while (line = sock.gets)
  #   puts "received : #{line.chop}"
  # end
  sock.close
end
