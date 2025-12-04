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

# Africa (10 cities)
puts "Creating cities..."
City.create!(name: "Cape Town", img: "https://media.istockphoto.com/id/514First2050/photo/table-mountain-and-cape-town.jpg")
puts "Created Cape Town"
puts "Creating cities..."
City.create!(name: "Marrakech", img: "https://media.cntraveler.com/photos/5e4c63e2eb271800086ccd6c/16:9/w_2560,c_limit/Marrakech-GettyImages-610765304.jpg")
puts "Created Marrakech"
puts "Creating cities..."
City.create!(name: "Nairobi", img: "https://upload.wikimedia.org/wikipedia/commons/5/5a/Nairobi_skyline.jpg")
puts "Created Nairobi"
puts "Creating cities..."
City.create!(name: "Lagos", img: "https://upload.wikimedia.org/wikipedia/commons/1/10/Lagos_skyline.jpg")
puts "Created Lagos"
puts "Creating cities..."
City.create!(name: "Accra", img: "https://media.istockphoto.com/id/1352424546/photo/accra-ghana-cityscape.jpg")
puts "Created Accra"
puts "Creating cities..."
City.create!(name: "Zanzibar", img: "https://media.cntraveler.com/photos/5ba8fb098c89f54d9fdf5527/16:9/w_2560,c_limit/Zanzibar_Getty_2018_GettyImages-539167340.jpg")
puts "Created Zanzibar"
puts "Creating cities..."
City.create!(name: "Addis Ababa", img: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/ET_Addis_asv2018-01_img33_view_from_Entoto.jpg/1280px-ET_Addis_asv2018-01_img33_view_from_Entoto.jpg")
puts "Created Addis Ababa"
puts "Creating cities..."
City.create!(name: "Casablanca", img: "https://media.istockphoto.com/id/539018660/photo/hassan-ii-mosque-in-casablanca.jpg")
puts "Created Casablanca"
puts "Creating cities..."
City.create!(name: "Dakar", img: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Dakar_Skyline.jpg/1280px-Dakar_Skyline.jpg")
puts "Created Dakar"

# Asia (6 cities)
puts "Creating cities..."
City.create!(name: "Bangkok", img: "https://media.cntraveler.com/photos/5e4bfb0b33cf5f0008e8e690/16:9/w_2560,c_limit/Bangkok-GettyImages-1137636001.jpg")
puts "Created Bangkok"
puts "Creating cities..."
City.create!(name: "Seoul", img: "https://media.cntraveler.com/photos/60480c67ff9cba52f2a91899/16:9/w_2560,c_limit/01-vd-soul-702631546.jpg")
puts "Created Seoul"
puts "Creating cities..."
City.create!(name: "Singapore", img: "https://media.cntraveler.com/photos/5e4c62bc43806e0008a4b31f/16:9/w_2560,c_limit/Singapore-GettyImages-1033573384.jpg")
puts "Created Singapore"
puts "Creating cities..."
City.create!(name: "Bali", img: "https://media.cntraveler.com/photos/5e0e5f9a3d93d60008764755/16:9/w_2560,c_limit/Bali-GettyImages-1137917353.jpg")
puts "Created Bali"
puts "Creating cities..."
City.create!(name: "Hanoi", img: "https://media.cntraveler.com/photos/5e4e6e1d5045e100091e5c8a/16:9/w_2560,c_limit/Hanoi-GettyImages-1063572016.jpg")
puts "Created Hanoi"
puts "Creating cities..."
City.create!(name: "Dubai", img: "https://media.cntraveler.com/photos/5e4c68a26cef3f0009363aeb/16:9/w_2560,c_limit/Dubai-GettyImages-1176377541.jpg")
puts "Created Dubai"

# Europe (3 cities)
puts "Creating cities..."
City.create!(name: "Prague", img: "https://media.cntraveler.com/photos/5e4c6c1f6cef3f0009363af7/16:9/w_2560,c_limit/Prague-GettyImages-1160174532.jpg")
puts "Created Prague"
puts "Creating cities..."
City.create!(name: "Lisbon", img: "https://media.cntraveler.com/photos/5e4c6cad4e02e200087d9cce/16:9/w_2560,c_limit/Lisbon-GettyImages-1085432462.jpg")
puts "Created Lisbon"
puts "Creating cities..."
City.create!(name: "Moscow", img: "https://media.cntraveler.com/photos/5e4c6d5b4e02e200087d9cd6/16:9/w_2560,c_limit/Moscow-GettyImages-1135610First0000.jpg")
puts "Created Moscow"

# LATAM (3 cities)
puts "Creating cities..."
City.create!(name: "Buenos Aires", img: "https://media.cntraveler.com/photos/5e4c65ab43806e0008a4b32d/16:9/w_2560,c_limit/BuenosAires-GettyImages-1136646First036.jpg")
puts "Created Buenos Aires"
puts "Creating cities..."
City.create!(name: "Cartagena", img: "https://media.cntraveler.com/photos/5e4c654d43806e0008a4b329/16:9/w_2560,c_limit/Cartagena-GettyImages-1145042436.jpg")
puts "Created Cartagena"
puts "Creating cities..."
City.create!(name: "Mexico City", img: "https://media.cntraveler.com/photos/5e4c64f16cef3f0009363ae5/16:9/w_2560,c_limit/MexicoCity-GettyImages-1168100First0000.jpg")
puts "Created Mexico City"

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

# New cities
cape_town = City.find_by(name: "Cape Town")
marrakech = City.find_by(name: "Marrakech")
nairobi = City.find_by(name: "Nairobi")
lagos = City.find_by(name: "Lagos")
accra = City.find_by(name: "Accra")
zanzibar = City.find_by(name: "Zanzibar")
addis_ababa = City.find_by(name: "Addis Ababa")
casablanca = City.find_by(name: "Casablanca")
dakar = City.find_by(name: "Dakar")
bangkok = City.find_by(name: "Bangkok")
seoul = City.find_by(name: "Seoul")
singapore = City.find_by(name: "Singapore")
bali = City.find_by(name: "Bali")
hanoi = City.find_by(name: "Hanoi")
dubai = City.find_by(name: "Dubai")
prague = City.find_by(name: "Prague")
lisbon = City.find_by(name: "Lisbon")
moscow = City.find_by(name: "Moscow")
buenos_aires = City.find_by(name: "Buenos Aires")
cartagena = City.find_by(name: "Cartagena")
mexico_city = City.find_by(name: "Mexico City")

sagrada_familia = Place.create!(
  title: "Sagrada Familia",
  enhanced_description: "The Basílica de la Sagrada Família is a large unfinished Roman Catholic minor basilica in Barcelona, designed by Antoni Gaudí.",
  address: "Carrer de Mallorca, 401, Barcelona, Spain",
  default_img_url: "https://niesamowita.b-cdn.net/images/Europa/Barcelona/Barcelona.jpg",
  city: barcelona
)

senso_ji = Place.create!(
  title: "Sensō-ji Temple",
  enhanced_description: "Sensō-ji is an ancient Buddhist temple located in Asakusa, Tokyo. It is Tokyo's oldest temple and one of its most significant.",
  address: "2 Chome-3-1 Asakusa, Taito City, Tokyo, Japan",
  default_img_url: "https://img.freepik.com/free-photo/aerial-view-tokyo-cityscape-with-fuji-mountain-japan_335224-148.jpg?semt=ais_hybrid&w=740&q=80",
  city: tokyo
)

eiffel_tower = Place.create!(
  title: "Eiffel Tower",
  enhanced_description: "The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, named after engineer Gustave Eiffel.",
  address: "Champ de Mars, 5 Avenue Anatole France, Paris, France",
  default_img_url: "https://t4.ftcdn.net/jpg/02/60/79/45/360_F_260794563_dq3TQWoefX8EsPlGyIf8Xnmq5BdeMRPq.jpg",
  city: paris
)

central_park = Place.create!(
  title: "Central Park",
  enhanced_description: "Central Park is an urban park in New York City between the Upper West Side and Upper East Side of Manhattan.",
  address: "Central Park, New York, NY, USA",
  default_img_url: "https://www.followmeaway.com/wp-content/uploads/2019/06/New-York-in-a-day-Times-Square.jpg",
  city: new_york
)

opera_house = Place.create!(
  title: "Sydney Opera House",
  enhanced_description: "The Sydney Opera House is a multi-venue performing arts centre in Sydney. It is one of the 20th century's most famous and distinctive buildings.",
  address: "Bennelong Point, Sydney NSW 2000, Australia",
  default_img_url: "https://media.istockphoto.com/id/1256052948/photo/sydney-opera-house-close-up.jpg?s=612x612&w=0&k=20&c=whIj_OHD1xUfx9rgcLaKC2V_AjOJZb24IQOCcKrxaCM=",
  city: sydney
)

anne_frank = Place.create!(
  title: "Anne Frank House",
  enhanced_description: "The Anne Frank House is a museum dedicated to Jewish wartime diarist Anne Frank. The building is located on the Prinsengracht canal in Amsterdam.",
  address: "Prinsengracht 263-267, 1016 GV Amsterdam, Netherlands",
  default_img_url: "https://t4.ftcdn.net/jpg/01/76/95/31/360_F_176953179_IaK81ZsGI5gGjSc1SlB8rDqrdqS4XqRg.jpg",
  city: amsterdam
)

tower_bridge = Place.create!(
  title: "Tower Bridge",
  enhanced_description: "Tower Bridge is a Grade I listed combined bascule and suspension bridge in London, built between 1886 and 1894.",
  address: "Tower Bridge Road, London, UK",
  default_img_url: "https://www.visitlondon.com/-/media/images/london/visit/things-to-do/nightlife/tower-bridge-at-night1920x1080.png?mw=800&rev=743f319d95bf47638fe287a5322c115c&hash=4EE2C2E9D2540601359FE846DC4B55C0",
  city: london
)

machu_picchu = Place.create!(
  title: "Plaza Mayor de Lima",
  enhanced_description: "The Plaza Mayor of Lima is the birthplace of the city of Lima and the core of the city. Located in the Historic Centre of Lima.",
  address: "Plaza Mayor, Cercado de Lima, Peru",
  default_img_url: "https://cdn.divessi.com/cached/Peru_Lima_iStock-Christian-Vinces.jpg/1200.jpg",
  city: lima
)

india_gate = Place.create!(
  title: "India Gate",
  enhanced_description: "The India Gate is a war memorial located astride the Rajpath in New Delhi. It was designed by Sir Edwin Lutyens.",
  address: "Rajpath, India Gate, New Delhi, India",
  default_img_url: "https://content.r9cdn.net/rimg/dimg/89/80/30f91a95-city-32821-16374b316c6.jpg?width=1200&height=630&xhint=2922&yhint=2792&crop=true",
  city: new_delhi
)

royal_palace = Place.create!(
  title: "Royal Palace of Phnom Penh",
  enhanced_description: "The Royal Palace is a complex of buildings which serves as the royal residence of the King of Cambodia.",
  address: "Samdach Sothearos Blvd, Phnom Penh, Cambodia",
  default_img_url: "https://blog.bangkokair.com/wp-content/uploads/2025/01/Cover_phnom-penh-travel-guide.jpg",
  city: phnom_penh
)

fishermans_bastion = Place.create!(
  title: "Fisherman's Bastion",
  enhanced_description: "Fisherman's Bastion is a terrace in neo-Gothic and neo-Romanesque style situated on the Buda bank of the Danube in Budapest.",
  address: "Szentháromság tér, Budapest, Hungary",
  default_img_url: "https://www.budapest.org/es/wp-content/uploads/sites/99/budapest-danubio-panorama-hd.jpg",
  city: budapest
)

pyramids = Place.create!(
  title: "Pyramids of Giza",
  enhanced_description: "The Giza pyramid complex is an archaeological site on the Giza Plateau, including the three Great Pyramids and the Great Sphinx.",
  address: "Al Haram, Giza Governorate, Egypt",
  default_img_url: "https://www.civitatis.com/blog/wp-content/uploads/2025/01/que-ver-cairo-egipto.jpg",
  city: cairo
)

erta_ale = Place.create!(
  title: "Erta Ale",
  enhanced_description: "Erta Ale is an active shield volcano located in the Afar Region of Ethiopia. It is famed for its persistent lava and salt lake, one of the few in the world.",
  address: "Danakil Depression, Afar Region, Ethiopia",
  default_img_url: "https://fanosethiopiatours.wordpress.com/wp-content/uploads/2016/06/fb_img_1690248178732.jpg",
  city: afar
)

# Africa places
table_mountain = Place.create!(
  title: "Table Mountain",
  enhanced_description: "Table Mountain is a flat-topped mountain forming a prominent landmark overlooking Cape Town. It is a significant tourist attraction with the Table Mountain Cableway taking passengers to the summit.",
  address: "Table Mountain National Park, Cape Town, South Africa",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/c/c4/Table_Mountain_DavidBowie.jpg",
  city: cape_town
)

jemaa_el_fna = Place.create!(
  title: "Jemaa el-Fnaa",
  enhanced_description: "Jemaa el-Fnaa is a famous square and market place in Marrakech's medina quarter. It remains the main square of Marrakech, used by locals and tourists.",
  address: "Jemaa el-Fnaa, Marrakech, Morocco",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/7/7f/Jemaa_el-Fnaa.jpg",
  city: marrakech
)

nairobi_national_park = Place.create!(
  title: "Nairobi National Park",
  enhanced_description: "Nairobi National Park is a national park in Kenya that was established in 1946. It is unique for being within a capital city, with wildlife roaming against a backdrop of city skyscrapers.",
  address: "Nairobi National Park, Nairobi, Kenya",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/a/ae/Nairobi_National_Park.jpg",
  city: nairobi
)

lekki_conservation = Place.create!(
  title: "Lekki Conservation Centre",
  enhanced_description: "Lekki Conservation Centre is a nature reserve located in Lagos, Nigeria. It features the longest canopy walkway in Africa and is home to various wildlife species.",
  address: "Lekki-Epe Expressway, Lagos, Nigeria",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/9/9b/Lekki_Conservation_Centre.jpg",
  city: lagos
)

kwame_nkrumah = Place.create!(
  title: "Kwame Nkrumah Memorial Park",
  enhanced_description: "The Kwame Nkrumah Memorial Park is a national park in Accra dedicated to the first president of Ghana. It houses the mausoleum of Kwame Nkrumah and his wife.",
  address: "High Street, Accra, Ghana",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/f/f4/Kwame_Nkrumah_Mausoleum.jpg",
  city: accra
)

stone_town = Place.create!(
  title: "Stone Town",
  enhanced_description: "Stone Town is the old part of Zanzibar City and a UNESCO World Heritage Site. It is a fine example of a Swahili coastal trading town with winding alleys and unique architecture.",
  address: "Stone Town, Zanzibar City, Tanzania",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/d/d9/Stone_Town_Zanzibar.jpg",
  city: zanzibar
)

holy_trinity = Place.create!(
  title: "Holy Trinity Cathedral",
  enhanced_description: "Holy Trinity Cathedral is the highest ranking Ethiopian Orthodox Tewahedo church in Addis Ababa. It is the second most important place of worship in Ethiopia.",
  address: "Arat Kilo, Addis Ababa, Ethiopia",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/7/7a/Ethiopian_Holy_Trinity_Cathedral.jpg",
  city: addis_ababa
)

hassan_ii_mosque = Place.create!(
  title: "Hassan II Mosque",
  enhanced_description: "The Hassan II Mosque is a mosque in Casablanca and the largest mosque in Africa. Its minaret is the world's second tallest at 210 metres.",
  address: "Boulevard de la Corniche, Casablanca, Morocco",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/5/52/Hassan_II_Mosque_2.jpg",
  city: casablanca
)

african_renaissance = Place.create!(
  title: "African Renaissance Monument",
  enhanced_description: "The African Renaissance Monument is a bronze statue located on top of one of the twin hills of Collines des Mamelles in Dakar. At 49 metres, it is the tallest statue in Africa.",
  address: "Collines des Mamelles, Dakar, Senegal",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/1/1a/African_Renaissance_Monument.jpg",
  city: dakar
)

# Asia places
grand_palace = Place.create!(
  title: "Grand Palace",
  enhanced_description: "The Grand Palace is a complex of buildings in Bangkok that has been the official residence of the Kings of Siam since 1782. It is one of Thailand's most popular tourist attractions.",
  address: "Na Phra Lan Road, Bangkok, Thailand",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/9/91/Grand_Palace_Bangkok.jpg",
  city: bangkok
)

gyeongbokgung = Place.create!(
  title: "Gyeongbokgung Palace",
  enhanced_description: "Gyeongbokgung Palace is the largest of the Five Grand Palaces built during the Joseon dynasty. It served as the main royal palace and is a symbol of Seoul's rich history.",
  address: "161 Sajik-ro, Jongno-gu, Seoul, South Korea",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/1/1a/Gyeongbokgung-Geunjeongjeon.jpg",
  city: seoul
)

marina_bay_sands = Place.create!(
  title: "Marina Bay Sands",
  enhanced_description: "Marina Bay Sands is an integrated resort fronting Marina Bay in Singapore. It is the world's most expensive standalone casino property and features the iconic rooftop infinity pool.",
  address: "10 Bayfront Avenue, Singapore",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/f/f9/Marina_Bay_Sands_in_the_evening_-_20101120.jpg",
  city: singapore
)

tanah_lot = Place.create!(
  title: "Tanah Lot",
  enhanced_description: "Tanah Lot is a rock formation off the coast of Bali, Indonesia, home to the ancient Hindu pilgrimage temple Pura Tanah Lot. It is one of Bali's most iconic landmarks.",
  address: "Beraban, Kediri, Tabanan, Bali, Indonesia",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/c/c5/Tanah_Lot_Bali.jpg",
  city: bali
)

hoan_kiem_lake = Place.create!(
  title: "Hoan Kiem Lake",
  enhanced_description: "Hoan Kiem Lake is a freshwater lake in the historical center of Hanoi. The lake is one of the major scenic spots in Hanoi and serves as a central point for public activity.",
  address: "Hoan Kiem District, Hanoi, Vietnam",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/1/1c/Hoan_Kiem_Lake.jpg",
  city: hanoi
)

burj_khalifa = Place.create!(
  title: "Burj Khalifa",
  enhanced_description: "Burj Khalifa is a skyscraper in Dubai and the tallest structure in the world at 828 metres. The building holds numerous world records including the highest observation deck.",
  address: "1 Sheikh Mohammed bin Rashid Blvd, Dubai, UAE",
  default_img_url: "https://upload.wikimedia.org/wikipedia/en/9/93/Burj_Khalifa.jpg",
  city: dubai
)

# Europe places
charles_bridge = Place.create!(
  title: "Charles Bridge",
  enhanced_description: "Charles Bridge is a medieval stone arch bridge that crosses the Vltava river in Prague. Its construction started in 1357 and it is now one of the most visited sites in the city.",
  address: "Karlův most, Prague, Czech Republic",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/1/1d/Charles_Bridge_Prague.jpg",
  city: prague
)

belem_tower = Place.create!(
  title: "Belém Tower",
  enhanced_description: "Belém Tower is a 16th-century fortification located in Lisbon. It is a UNESCO World Heritage Site and one of the most iconic landmarks of Portugal.",
  address: "Av. Brasília, Lisbon, Portugal",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/9/91/Belem_Tower.jpg",
  city: lisbon
)

red_square = Place.create!(
  title: "Red Square",
  enhanced_description: "Red Square is one of the oldest and largest squares in Moscow. It is surrounded by the Kremlin, Saint Basil's Cathedral, and the State Historical Museum.",
  address: "Red Square, Moscow, Russia",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/f/f8/Red_Square_Moscow.jpg",
  city: moscow
)

# LATAM places
la_boca = Place.create!(
  title: "La Boca",
  enhanced_description: "La Boca is a neighborhood in Buenos Aires famous for its colorful houses and as the birthplace of tango. The area around Caminito street is a major tourist attraction.",
  address: "La Boca, Buenos Aires, Argentina",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/0/0c/Caminito_-_La_Boca.jpg",
  city: buenos_aires
)

walled_city = Place.create!(
  title: "Walled City of Cartagena",
  enhanced_description: "The Walled City is the historic center of Cartagena, Colombia. A UNESCO World Heritage Site, it features colonial architecture, cobblestone streets, and vibrant plazas.",
  address: "Centro Histórico, Cartagena, Colombia",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/b/b1/Cartagena_de_Indias.jpg",
  city: cartagena
)

palacio_bellas_artes = Place.create!(
  title: "Palacio de Bellas Artes",
  enhanced_description: "The Palacio de Bellas Artes is a prominent cultural center in Mexico City. It hosts some of the most important events in the fine arts and houses important murals by Diego Rivera.",
  address: "Av. Juárez, Centro Histórico, Mexico City, Mexico",
  default_img_url: "https://upload.wikimedia.org/wikipedia/commons/c/c6/Palacio_de_Bellas_Artes.jpg",
  city: mexico_city
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

# Africa comments
Comment.create!(
  description: "The cable car ride up Table Mountain offers incredible views of Cape Town and the coastline. At the top, the flat summit is perfect for hiking. Go early to avoid the afternoon clouds that roll in.",
  place: table_mountain,
  user: user2
)

Comment.create!(
  description: "Jemaa el-Fnaa comes alive at night with food stalls, musicians, and storytellers. The energy is electric! Be prepared to haggle in the surrounding souks. An unforgettable sensory experience.",
  place: jemaa_el_fna,
  user: user1
)

Comment.create!(
  description: "Where else can you see lions and giraffes with skyscrapers in the background? Nairobi National Park is surreal. We did a sunrise game drive and spotted rhinos. Truly unique experience.",
  place: nairobi_national_park,
  user: user2
)

Comment.create!(
  description: "Walking the canopy walkway at Lekki was thrilling! It sways a bit which adds to the adventure. Great for nature lovers wanting to escape the chaos of Lagos. Monkeys everywhere!",
  place: lekki_conservation,
  user: user1
)

Comment.create!(
  description: "A powerful tribute to Ghana's independence hero. The park is peaceful and well-maintained. The museum inside provides great insight into Nkrumah's life and African liberation movements.",
  place: kwame_nkrumah,
  user: user2
)

Comment.create!(
  description: "Getting lost in Stone Town's narrow alleys is the best way to explore. The mix of Arab, Persian, Indian and European architecture is fascinating. Don't miss the spice tour!",
  place: stone_town,
  user: user1
)

Comment.create!(
  description: "Holy Trinity Cathedral is stunning with its beautiful stained glass and artwork. The tombs of Emperor Haile Selassie and Empress Menen are here. A must-visit for history enthusiasts.",
  place: holy_trinity,
  user: user2
)

Comment.create!(
  description: "Hassan II Mosque is absolutely magnificent - the craftsmanship is incredible. It's one of the few mosques open to non-Muslims. The location by the ocean adds to its grandeur.",
  place: hassan_ii_mosque,
  user: user1
)

Comment.create!(
  description: "The African Renaissance Monument is massive and the views from the top are spectacular. The museum inside tells the story of African history. A symbol of hope and progress for the continent.",
  place: african_renaissance,
  user: user2
)

# Asia comments
Comment.create!(
  description: "The Grand Palace is absolutely stunning with its intricate details and golden spires. Dress appropriately - they have a strict dress code. Go early to beat the crowds and the heat!",
  place: grand_palace,
  user: user1
)

Comment.create!(
  description: "Gyeongbokgung is beautiful, especially during the changing of the guard ceremony. Renting a hanbok gives you free entry and amazing photos. The palace grounds are vast and peaceful.",
  place: gyeongbokgung,
  user: user2
)

Comment.create!(
  description: "The infinity pool at Marina Bay Sands is iconic but you need to be a hotel guest. The observation deck offers amazing views of the Singapore skyline. The light show at night is free!",
  place: marina_bay_sands,
  user: user1
)

Comment.create!(
  description: "Tanah Lot at sunset is pure magic. The temple on the rock with crashing waves is incredibly photogenic. Get there early for a good spot. One of Bali's most spiritual places.",
  place: tanah_lot,
  user: user2
)

Comment.create!(
  description: "Walking around Hoan Kiem Lake in the early morning is peaceful and you'll see locals doing tai chi. The Turtle Tower in the middle is beautiful. Perfect starting point to explore Hanoi.",
  place: hoan_kiem_lake,
  user: user1
)

Comment.create!(
  description: "The view from the 124th floor of Burj Khalifa is mind-blowing! Book the 'At the Top' experience online to save time. Going at sunset lets you see the city in daylight and lit up at night.",
  place: burj_khalifa,
  user: user2
)

# Europe comments
Comment.create!(
  description: "Walking across Charles Bridge at sunrise before the crowds arrive is magical. The statues along the bridge are incredible. Great views of Prague Castle. A must-do in Prague!",
  place: charles_bridge,
  user: user1
)

Comment.create!(
  description: "Belém Tower is beautiful and the detail in the stonework is amazing. It's smaller than expected but worth the visit. Combine it with the nearby Jerónimos Monastery and pastéis de Belém!",
  place: belem_tower,
  user: user2
)

Comment.create!(
  description: "Red Square is breathtaking, especially at night when St. Basil's Cathedral is lit up. The colorful onion domes are unlike anything else. The history here is palpable. Don't miss Lenin's Mausoleum.",
  place: red_square,
  user: user1
)

# LATAM comments
Comment.create!(
  description: "La Boca is so colorful and vibrant! Tango dancers perform in the streets and the art scene is amazing. Stay on the main tourist streets and visit during the day. Great for photography!",
  place: la_boca,
  user: user2
)

Comment.create!(
  description: "The Walled City of Cartagena is like stepping back in time. The colonial architecture, bougainvillea-covered balconies, and lively plazas are enchanting. Best explored on foot at sunset.",
  place: walled_city,
  user: user1
)

Comment.create!(
  description: "Palacio de Bellas Artes is architecturally stunning inside and out. The murals by Diego Rivera are powerful. We caught a ballet performance here - the acoustics are incredible!",
  place: palacio_bellas_artes,
  user: user2
)

puts "Created #{Comment.count} comments."
puts "Seeding complete!"
