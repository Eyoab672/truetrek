puts "Cleaning database..."
City.destroy_all

puts "Creating cities..."
City.create!(name: "Barcelona" , img: "https://niesamowita.b-cdn.net/images/Europa/Barcelona/Barcelona.jpg")
puts "Created Barcelona"
puts "Creating cities..."
City.create!(name: "Tokyo", img: "https://img.freepik.com/free-photo/aerial-view-tokyo-cityscape-with-fuji-mountain-japan_335224-148.jpg?semt=ais_hybrid&w=740&q=80")
puts "Created Tokyo"
puts "Creating cities..."
City.create!(name: "Paris", img: "https://t4.ftcdn.net/jpg/02/60/79/45/360_F_260794563_dq3TQWoefX8EsPlGyIf8Xnmq5BdeMRPq.jpg")
puts "Created Paris"
puts "Creating cities..."
City.create!(name: "New York", img: "https://www.followmeaway.com/wp-content/uploads/2019/06/New-York-in-a-day-Times-Square.jpg")
puts "Created New York"
puts "Creating cities..."
City.create!(name: "Sydney", img: "https://media.istockphoto.com/id/1256052948/photo/sydney-opera-house-close-up.jpg?s=612x612&w=0&k=20&c=whIj_OHD1xUfx9rgcLaKC2V_AjOJZb24IQOCcKrxaCM=")
puts "Created Sydney"
puts "Creating cities..."
City.create!(name: "Amsterdam", img: "https://t4.ftcdn.net/jpg/01/76/95/31/360_F_176953179_IaK81ZsGI5gGjSc1SlB8rDqrdqS4XqRg.jpg")
puts "Created Amsterdam"
puts "Creating cities..."
City.create!(name: "London", img: "https://www.visitlondon.com/-/media/images/london/visit/things-to-do/nightlife/tower-bridge-at-night1920x1080.png?mw=800&rev=743f319d95bf47638fe287a5322c115c&hash=4EE2C2E9D2540601359FE846DC4B55C0")
puts "Created London"
puts "Creating cities..."
City.create!(name: "Lima", img: "https://cdn.divessi.com/cached/Peru_Lima_iStock-Christian-Vinces.jpg/1200.jpg")
puts "Created Lima"
puts "Creating cities..."
City.create!(name: "New Dehli", img: "https://content.r9cdn.net/rimg/dimg/89/80/30f91a95-city-32821-16374b316c6.jpg?width=1200&height=630&xhint=2922&yhint=2792&crop=true")
puts "Created New Dehli"
puts "Creating cities..."
City.create!(name: "Phnom Penh", img: "https://blog.bangkokair.com/wp-content/uploads/2025/01/Cover_phnom-penh-travel-guide.jpg")
puts "Created Phnom Penh"
puts "Creating cities..."
City.create!(name: "Budapest", img: "https://www.budapest.org/es/wp-content/uploads/sites/99/budapest-danubio-panorama-hd.jpg")
puts "Created Budapest"
puts "Creating cities..."
City.create!(name: "Cairo", img: "https://www.civitatis.com/blog/wp-content/uploads/2025/01/que-ver-cairo-egipto.jpg")
puts "Created Cairo"

puts "Finished! Created #{City.count} cities."
