puts "Cleaning database..."
Comment.destroy_all
Place.destroy_all
City.destroy_all
User.destroy_all

puts "Creating cities..."
City.create!(name: "Barcelona" , img: "https://niesamowita.b-cdn.net/images/Europa/Barcelona/Barcelona.jpg")
puts "Created Barcelona"
puts "Creating cities..."
City.create!(name: "Afar", img: "https://fanosethiopiatours.wordpress.com/wp-content/uploads/2016/06/fb_img_1690248178732.jpg")
puts "Created Afar"
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

puts "Creating users..."
user1 = User.create!(email: "traveler1@example.com", password: "password123", username: "traveler1", city: "Barcelona")
user2 = User.create!(email: "traveler2@example.com", password: "password123", username: "traveler2", city: "Tokyo")
puts "Created #{User.count} users."

puts "Creating places..."
barcelona = City.find_by(name: "Barcelona")
tokyo = City.find_by(name: "Tokyo")
paris = City.find_by(name: "Paris")
new_york = City.find_by(name: "New York")
sydney = City.find_by(name: "Sydney")
amsterdam = City.find_by(name: "Amsterdam")
london = City.find_by(name: "London")
lima = City.find_by(name: "Lima")
new_delhi = City.find_by(name: "New Dehli")
phnom_penh = City.find_by(name: "Phnom Penh")
budapest = City.find_by(name: "Budapest")
cairo = City.find_by(name: "Cairo")
afar = City.find_by(name: "Afar")

sagrada_familia = Place.create!(
  title: "Sagrada Familia",
  wiki_description: "The Basílica de la Sagrada Família is a large unfinished Roman Catholic minor basilica in Barcelona, designed by Antoni Gaudí.",
  address: "Carrer de Mallorca, 401, Barcelona, Spain",
  default_img_url: "https://niesamowita.b-cdn.net/images/Europa/Barcelona/Barcelona.jpg",
  city: barcelona
)

senso_ji = Place.create!(
  title: "Sensō-ji Temple",
  wiki_description: "Sensō-ji is an ancient Buddhist temple located in Asakusa, Tokyo. It is Tokyo's oldest temple and one of its most significant.",
  address: "2 Chome-3-1 Asakusa, Taito City, Tokyo, Japan",
  default_img_url: "https://img.freepik.com/free-photo/aerial-view-tokyo-cityscape-with-fuji-mountain-japan_335224-148.jpg?semt=ais_hybrid&w=740&q=80",
  city: tokyo
)

eiffel_tower = Place.create!(
  title: "Eiffel Tower",
  wiki_description: "The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, named after engineer Gustave Eiffel.",
  address: "Champ de Mars, 5 Avenue Anatole France, Paris, France",
  default_img_url: "https://t4.ftcdn.net/jpg/02/60/79/45/360_F_260794563_dq3TQWoefX8EsPlGyIf8Xnmq5BdeMRPq.jpg",
  city: paris
)

central_park = Place.create!(
  title: "Central Park",
  wiki_description: "Central Park is an urban park in New York City between the Upper West Side and Upper East Side of Manhattan.",
  address: "Central Park, New York, NY, USA",
  default_img_url: "https://www.followmeaway.com/wp-content/uploads/2019/06/New-York-in-a-day-Times-Square.jpg",
  city: new_york
)

opera_house = Place.create!(
  title: "Sydney Opera House",
  wiki_description: "The Sydney Opera House is a multi-venue performing arts centre in Sydney. It is one of the 20th century's most famous and distinctive buildings.",
  address: "Bennelong Point, Sydney NSW 2000, Australia",
  default_img_url: "https://media.istockphoto.com/id/1256052948/photo/sydney-opera-house-close-up.jpg?s=612x612&w=0&k=20&c=whIj_OHD1xUfx9rgcLaKC2V_AjOJZb24IQOCcKrxaCM=",
  city: sydney
)

anne_frank = Place.create!(
  title: "Anne Frank House",
  wiki_description: "The Anne Frank House is a museum dedicated to Jewish wartime diarist Anne Frank. The building is located on the Prinsengracht canal in Amsterdam.",
  address: "Prinsengracht 263-267, 1016 GV Amsterdam, Netherlands",
  default_img_url: "https://t4.ftcdn.net/jpg/01/76/95/31/360_F_176953179_IaK81ZsGI5gGjSc1SlB8rDqrdqS4XqRg.jpg",
  city: amsterdam
)

tower_bridge = Place.create!(
  title: "Tower Bridge",
  wiki_description: "Tower Bridge is a Grade I listed combined bascule and suspension bridge in London, built between 1886 and 1894.",
  address: "Tower Bridge Road, London, UK",
  default_img_url: "https://www.visitlondon.com/-/media/images/london/visit/things-to-do/nightlife/tower-bridge-at-night1920x1080.png?mw=800&rev=743f319d95bf47638fe287a5322c115c&hash=4EE2C2E9D2540601359FE846DC4B55C0",
  city: london
)

machu_picchu = Place.create!(
  title: "Plaza Mayor de Lima",
  wiki_description: "The Plaza Mayor of Lima is the birthplace of the city of Lima and the core of the city. Located in the Historic Centre of Lima.",
  address: "Plaza Mayor, Cercado de Lima, Peru",
  default_img_url: "https://cdn.divessi.com/cached/Peru_Lima_iStock-Christian-Vinces.jpg/1200.jpg",
  city: lima
)

india_gate = Place.create!(
  title: "India Gate",
  wiki_description: "The India Gate is a war memorial located astride the Rajpath in New Delhi. It was designed by Sir Edwin Lutyens.",
  address: "Rajpath, India Gate, New Delhi, India",
  default_img_url: "https://content.r9cdn.net/rimg/dimg/89/80/30f91a95-city-32821-16374b316c6.jpg?width=1200&height=630&xhint=2922&yhint=2792&crop=true",
  city: new_delhi
)

royal_palace = Place.create!(
  title: "Royal Palace of Phnom Penh",
  wiki_description: "The Royal Palace is a complex of buildings which serves as the royal residence of the King of Cambodia.",
  address: "Samdach Sothearos Blvd, Phnom Penh, Cambodia",
  default_img_url: "https://blog.bangkokair.com/wp-content/uploads/2025/01/Cover_phnom-penh-travel-guide.jpg",
  city: phnom_penh
)

fishermans_bastion = Place.create!(
  title: "Fisherman's Bastion",
  wiki_description: "Fisherman's Bastion is a terrace in neo-Gothic and neo-Romanesque style situated on the Buda bank of the Danube in Budapest.",
  address: "Szentháromság tér, Budapest, Hungary",
  default_img_url: "https://www.budapest.org/es/wp-content/uploads/sites/99/budapest-danubio-panorama-hd.jpg",
  city: budapest
)

pyramids = Place.create!(
  title: "Pyramids of Giza",
  wiki_description: "The Giza pyramid complex is an archaeological site on the Giza Plateau, including the three Great Pyramids and the Great Sphinx.",
  address: "Al Haram, Giza Governorate, Egypt",
  default_img_url: "https://www.civitatis.com/blog/wp-content/uploads/2025/01/que-ver-cairo-egipto.jpg",
  city: cairo
)

erta_ale = Place.create!(
  title: "Erta Ale",
  wiki_description: "Erta Ale is an active shield volcano located in the Afar Region of Ethiopia. It is famed for its persistent lava and salt lake, one of the few in the world.",
  address: "Danakil Depression, Afar Region, Ethiopia",
  default_img_url: "https://fanosethiopiatours.wordpress.com/wp-content/uploads/2016/06/fb_img_1690248178732.jpg",
  city: afar
)

puts "Created #{Place.count} places."

puts "Creating comments..."
Comment.create!(
  description: "Absolutely breathtaking architecture! Gaudí's masterpiece is a must-see. The interior light through the stained glass windows creates an otherworldly atmosphere that photos simply cannot capture.",
  place: sagrada_familia,
  user: user1
)

Comment.create!(
  description: "The temple grounds are peaceful despite the crowds. The giant red lantern at the entrance is iconic. Don't miss the shopping street Nakamise-dori leading up to it for traditional snacks.",
  place: senso_ji,
  user: user2
)

Comment.create!(
  description: "One of the most surreal experiences of my life! Hiking through the Danakil Depression at night to see the glowing lava lake is otherworldly. Bring plenty of water — it's one of Earth's hottest places. A true hidden gem that few travelers know about.",
  place: erta_ale,
  user: user1
)

Comment.create!(
  description: "Visited at sunset and the views were magical. The elevator ride up offers stunning panoramic views of Paris. Book tickets in advance online to skip the long queues at the base.",
  place: eiffel_tower,
  user: user1
)

Comment.create!(
  description: "A perfect escape from the busy Manhattan streets. We rented bikes and explored the entire park. The Bethesda Fountain and Bow Bridge are particularly beautiful spots for photos.",
  place: central_park,
  user: user2
)

Comment.create!(
  description: "The architecture is absolutely stunning, especially when lit up at night. We took a harbor cruise to see it from the water. The acoustics inside during a performance are world-class.",
  place: opera_house,
  user: user1
)

Comment.create!(
  description: "A deeply moving experience walking through the rooms where Anne Frank and her family hid. The museum does an excellent job of presenting history. Book tickets well in advance online.",
  place: anne_frank,
  user: user2
)

Comment.create!(
  description: "Walking across Tower Bridge at night is a magical experience. The bridge lifts for tall ships are fascinating to watch. The Tower Bridge Exhibition offers great views from the walkways.",
  place: tower_bridge,
  user: user2
)

Comment.create!(
  description: "The historic center of Lima is beautiful with stunning colonial architecture. The plaza is surrounded by important buildings including the Government Palace and the Cathedral of Lima.",
  place: machu_picchu,
  user: user1
)

Comment.create!(
  description: "A magnificent monument that honors the soldiers who died in World War I. The surrounding lawns are perfect for an evening stroll. Beautifully illuminated at night with changing colors.",
  place: india_gate,
  user: user2
)

Comment.create!(
  description: "The Royal Palace is stunning with its Khmer architecture and beautiful gardens. The Silver Pagoda inside has an incredible floor made of silver tiles. Dress modestly to enter.",
  place: royal_palace,
  user: user1
)

Comment.create!(
  description: "The views of Budapest from here are absolutely spectacular, especially at sunset. The neo-Gothic towers and terraces are perfect for photos. Don't miss the view of the Parliament building.",
  place: fishermans_bastion,
  user: user2
)

Comment.create!(
  description: "Standing before the ancient pyramids is a humbling experience. The sheer scale is hard to comprehend until you're there. We highly recommend hiring a local guide for the history.",
  place: pyramids,
  user: user1
)

puts "Created #{Comment.count} comments."
puts "Seeding complete!"
