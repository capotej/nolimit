value = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

st = Time.now
100_000.times do |i|
  key = "#{Time.now.to_f.to_s}#{rand(1000)}"
  r = `curl -X POST http://localhost:8000/ -d "#{key}=#{value}"`
  puts "#{i} = #{key} = #{r}"
  r = `curl http://localhost:8000/?key=#{key}`
  p r
end
et = Time.now

puts (et - st).to_f
