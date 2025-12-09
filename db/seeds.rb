puts "Cleaning database..."
Vote.destroy_all
TravelBookPlace.destroy_all
TravelBook.destroy_all
Comment.destroy_all
Place.destroy_all
City.destroy_all
User.destroy_all

# Helper to find and attach image by place title
def attach_photo(comment, place_title)
  images_path = Rails.root.join("db/seeds/images")
  extensions = %w[.jpg .jpeg .png .webp .avif]

  extensions.each do |ext|
    file_path = images_path.join("#{place_title}#{ext}")
    if File.exist?(file_path)
      content_type = case ext
                     when ".jpg", ".jpeg" then "image/jpeg"
                     when ".png" then "image/png"
                     when ".webp" then "image/webp"
                     when ".avif" then "image/avif"
                     end
      comment.photos.attach(
        io: File.open(file_path),
        filename: "#{place_title}#{ext}",
        content_type: content_type
      )
      puts "  Attached #{place_title}#{ext}"
      return
    end
  end
  puts "  Warning: No image found for #{place_title}"
end

puts "Creating cities..."
City.create!(name: "Barcelona", img: "https://niesamowita.b-cdn.net/images/Europa/Barcelona/Barcelona.jpg")
puts "Created Barcelona"
City.create!(name: "Afar", img: "https://fanosethiopiatours.wordpress.com/wp-content/uploads/2016/06/fb_img_1690248178732.jpg")
puts "Created Afar"
City.create!(name: "Tokyo", img: "https://img.freepik.com/free-photo/aerial-view-tokyo-cityscape-with-fuji-mountain-japan_335224-148.jpg?semt=ais_hybrid&w=740&q=80")
puts "Created Tokyo"
City.create!(name: "Paris", img: "https://t4.ftcdn.net/jpg/02/60/79/45/360_F_260794563_dq3TQWoefX8EsPlGyIf8Xnmq5BdeMRPq.jpg")
puts "Created Paris"
City.create!(name: "New York", img: "https://www.followmeaway.com/wp-content/uploads/2019/06/New-York-in-a-day-Times-Square.jpg")
puts "Created New York"
City.create!(name: "Sydney", img: "https://media.istockphoto.com/id/1256052948/photo/sydney-opera-house-close-up.jpg?s=612x612&w=0&k=20&c=whIj_OHD1xUfx9rgcLaKC2V_AjOJZb24IQOCcKrxaCM=")
puts "Created Sydney"
City.create!(name: "Amsterdam", img: "https://t4.ftcdn.net/jpg/01/76/95/31/360_F_176953179_IaK81ZsGI5gGjSc1SlB8rDqrdqS4XqRg.jpg")
puts "Created Amsterdam"
City.create!(name: "London", img: "https://www.visitlondon.com/-/media/images/london/visit/things-to-do/nightlife/tower-bridge-at-night1920x1080.png?mw=800&rev=743f319d95bf47638fe287a5322c115c&hash=4EE2C2E9D2540601359FE846DC4B55C0")
puts "Created London"
City.create!(name: "Lima", img: "https://cdn.divessi.com/cached/Peru_Lima_iStock-Christian-Vinces.jpg/1200.jpg")
puts "Created Lima"
City.create!(name: "Budapest", img: "https://www.budapest.org/es/wp-content/uploads/sites/99/budapest-danubio-panorama-hd.jpg")
puts "Created Budapest"
City.create!(name: "Cairo", img: "https://www.civitatis.com/blog/wp-content/uploads/2025/01/que-ver-cairo-egipto.jpg")
puts "Created Cairo"
City.create!(name: "Cape Town", img: "https://www.go2africa.com/wp-content/uploads/2024/11/Banner-.jpg")
puts "Created Cape Town"
City.create!(name: "Rio de Janeiro", img: "https://www.turium.es/wp-content/uploads/sites/4/2025/12/cristo-redentor-rio-de-janeiro-1200x754.jpg")
puts "Created Rio de Janeiro"
City.create!(name: "Mexico City", img: "https://content.presspage.com/uploads/2278/3fa93fbb-a0df-4b70-9d4b-6591f5afd01f/1920_adobestock-192337612.jpeg?10000")
puts "Created Mexico City"
City.create!(name: "Reykjavik", img: "https://gti.images.tshiftcdn.com/8571406/x/0/reykjavik-12.jpg?ixlib=php-3.3.0&w=883")
puts "Created Reykjavik"
City.create!(name: "Prague", img: "https://media.tacdn.com/media/attractions-splice-spp-674x446/0b/e1/1b/2c.jpg")
puts "Created Prague"
City.create!(name: "Bangkok", img: "https://images.contentstack.io/v3/assets/blt06f605a34f1194ff/blt946ff9e4985c1319/6731c3a64ef1040e96e55bfc/BCC-2024-EXPLORER-BANGKOK-FUN-THINGS-TO-DO-HEADER_MOBILE.jpg?fit=crop&disable=upscale&auto=webp&quality=60&crop=smart")
puts "Created Bangkok"

puts "Finished! Created #{City.count} cities."

puts "Creating users..."
user1 = User.create!(email: "traveler1@example.com", password: "password123", username: "Eyoab", city: "Barcelona", admin: true)
user2 = User.create!(email: "traveler2@example.com", password: "password123", username: "Egor", city: "Moscow")
user3 = User.create!(email: "admin@admin.com", password: "123456", username: "owen", city: "Amsterdam", admin: true)
user4 = User.create!(email: "traveler3@example.com", password: "password123", username: "Jordan", city: "Lima")
user5 = User.create!(email: "traveler4@example.com", password: "password123", username: "Lily", city: "Paris")
user6 = User.create!(email: "traveler5@example.com", password: "password123", username: "Kuka", city: "Cairo")
user7 = User.create!(email: "traveler6@example.com", password: "password123", username: "Mark", city: "Prague")
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
budapest = City.find_by(name: "Budapest")
cairo = City.find_by(name: "Cairo")
afar = City.find_by(name: "Afar")
cape_town = City.find_by(name: "Cape Town")
rio_de_janeiro = City.find_by(name: "Rio de Janeiro")
mexico_city = City.find_by(name: "Mexico City")
reykjavik = City.find_by(name: "Reykjavik")
prague = City.find_by(name: "Prague")
bangkok = City.find_by(name: "Bangkok")

sagrada_familia = Place.create!(
  title: "Sagrada Familia",
  enhanced_description: "The Basílica de la Sagrada Família is a large unfinished Roman Catholic minor basilica in Barcelona, designed by Antoni Gaudí.",
  address: "Carrer de Mallorca, 401, Barcelona, Spain",
  city: barcelona
)

bunkers_del_carmel = Place.create!(
  title: "Bunkers del Carmel",
  enhanced_description: "Bunkers del Carmel offers one of the best panoramic views of Barcelona. Once an anti-aircraft fort, it has become a beloved local hangout where residents gather to enjoy sunsets and cityscapes away from tourist crowds.",
  address: "Carrer de Marià Labernia, Horta-Guinardo, 08032 Barcelona",
  city: barcelona
)

parc_del_laberint = Place.create!(
  title: "Parc del Laberint d’Horta",
  enhanced_description: "Parc del Laberint d’Horta is Barcelona’s oldest garden, a peaceful oasis featuring a neoclassical maze, romantic paths, ponds, and historic statues. A quiet escape treasured by locals.",
  address: "Passeig dels Castanyers, 1, Horta-Guinardo, 08035 Barcelona",
  city: barcelona
)

antic_teatre = Place.create!(
  title: "Antic Teatre",
  enhanced_description: "It is a garden in the middle of the city that hides behind the walls of the theater.",
  address: "Carrer de Verdaguer i Callís, 12, Ciutat Vella, Barcelona",
  city: barcelona
)

el_bosc_de_les_fades = Place.create!(
  title: "El Bosc de les Fades",
  enhanced_description: "A whimsical, fairy-tale themed bar hidden behind the Wax Museum. Dim lights, artificial forests, and magical décor create one of Barcelona’s most unique and atmospheric hideaways.",
  address: "Passatge de la Banca 7, Ciutat Vella, Barcelona",
  city: barcelona
)

park_guell = Place.create!(
  title: "Park Güell",
  enhanced_description: "A colorful artistic park designed by Antoni Gaudí, featuring mosaic benches, whimsical structures, and panoramic views over Barcelona.",
  address: "Carrer d'Olot, Barcelona, Spain",
  city: barcelona
)

montjuic_castle = Place.create!(
  title: "Montjuïc Castle",
  enhanced_description: "A historic fortress overlooking Barcelona’s port, offering sweeping views, cultural exhibitions, and scenic walking paths.",
  address: "Ctra. de Montjuic, 66, Barcelona, Spain",
  city: barcelona
)

palo_alto_market = Place.create!(
  title: "Palo Alto Market",
  enhanced_description: "A creative weekend market featuring design stands, street food, music, and artsy industrial vibes in Poblenou.",
  address: "Carrer dels Pellaires, 30, Barcelona, Spain",
  city: barcelona
)

carrer_de_lallada = Place.create!(
  title: "Carrer de L’Allada-Vermell",
  enhanced_description: "A peaceful shaded street in Born lined with cafés, trees, and art studios. A perfect hidden corner to relax away from the crowds.",
  address: "Carrer de L’Allada-Vermell, Barcelona, Spain",
  city: barcelona
)

senso_ji = Place.create!(
  title: "Sensō-ji Temple",
  enhanced_description: "Sensō-ji is an ancient Buddhist temple located in Asakusa, Tokyo. It is Tokyo's oldest temple and one of its most significant.",
  address: "Chome-3-1 Asakusa, Taito City, Tokyo 111-0032, Japan",
  city: tokyo
)

eiffel_tower = Place.create!(
  title: "Eiffel Tower",
  enhanced_description: "The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, named after engineer Gustave Eiffel.",
  address: "Av. Gustave Eiffel, 75007 Paris, France",
  city: paris
)

parc_des_buttes_chaumont = Place.create!(
  title: "Parc des Buttes-Chaumont",
  enhanced_description: "Parc des Buttes-Chaumont is one of Paris’s most dramatic green spaces, with cliffs, waterfalls, a suspended bridge, and locals lounging on the hillsides. Far less visited than the major parks but deeply loved by Parisians.",
  address: "1 Rue Botzaris, 75019 Paris, France",
  city: paris
)

canal_saint_martin = Place.create!(
  title: "Canal Saint-Martin",
  enhanced_description: "Canal Saint-Martin is a peaceful, tree-lined waterway surrounded by indie boutiques, cafés, and iron footbridges. Popular with locals for picnics, slow walks, and neighborhood vibes away from central tourist zones.",
  address: "Canal Saint-Martin, 75010 Paris, France",
  city: paris
)

greenacre_park = Place.create!(
  title: "Greenacre Park",
  enhanced_description: "Greenacre Park is a pocket-sized urban oasis featuring a 25-foot waterfall, shady seating areas, and a calm atmosphere perfect for a peaceful break from Midtown’s bustle.",
  address: "217 E 51st St, New York, NY 10022, USA",
  city: new_york
)

the_cloisters = Place.create!(
  title: "The Cloisters",
  enhanced_description: "The Cloisters, part of the Met Museum, sits atop Fort Tryon Park and showcases medieval art in castle-like architecture. Serene gardens and river views make it feel worlds away from the rest of Manhattan.",
  address: "99 Margaret Corbin Dr, New York, NY 10040, USA",
  city: new_york
)

freemans_alley = Place.create!(
  title: "Freeman Alley",
  enhanced_description: "Freeman Alley is a narrow, graffiti-covered passageway on the Lower East Side filled with street art, hidden entrances, and local creative energy. It's a quirky, photogenic corner of NYC that most visitors completely miss.",
  address: "Freeman Alley, New York, NY 10002, USA",
  city: new_york
)

opera_house = Place.create!(
  title: "Sydney Opera House",
  enhanced_description: "The Sydney Opera House is a multi-venue performing arts centre in Sydney. It is one of the 20th century's most famous and distinctive buildings.",
  address: "Bennelong Point, Sydney NSW 2000, Australia",
  city: sydney
)

anne_frank = Place.create!(
  title: "Anne Frank House",
  enhanced_description: "The Anne Frank House is a museum dedicated to Jewish wartime diarist Anne Frank. The building is located on the Prinsengracht canal in Amsterdam.",
  address: "Prinsengracht 263-267, 1016 GV Amsterdam, Netherlands",
  city: amsterdam
)

flevopark = Place.create!(
  title: "Flevopark",
  enhanced_description: "Flevopark is a spacious, peaceful green area at the eastern edge of Amsterdam. With lakes, wild nature paths, and local swimmers in summer, it remains blissfully uncrowded year-round.",
  address: "Flevopark, 1095 KE Amsterdam, Netherlands",
  city: amsterdam
)

de_pijp_market_streets = Place.create!(
  title: "De Pijp Market Streets",
  enhanced_description: "Beyond the famous Albert Cuyp Market, De Pijp's side streets hide independent cafés, micro-bakeries, and family-run shops that reveal the neighborhood’s authentic local character.",
  address: "De Pijp, Amsterdam, Netherlands",
  city: amsterdam
)

tower_bridge = Place.create!(
  title: "Tower Bridge",
  enhanced_description: "Tower Bridge is a Grade I listed combined bascule and suspension bridge in London, built between 1886 and 1894.",
  address: "Tower Bridge Road, London, UK",
  city: london
)

plaza_mayor = Place.create!(
  title: "Plaza Mayor de Lima",
  enhanced_description: "The Plaza Mayor of Lima is the birthplace of the city of Lima and the core of the city. Located in the Historic Centre of Lima.",
  address: "Plaza Mayor, Cercado de Lima, Peru",
  city: lima
)

parque_el_olivar = Place.create!(
  title: "Parque El Olivar",
  enhanced_description: "A serene park in San Isidro filled with centuries-old olive trees, quiet walking paths, and resident ducks. Locals come here to escape the city noise, making it one of Lima’s most peaceful hidden sanctuaries.",
  address: "Calle Choquehuanca, San Isidro, Lima, Peru",
  city: lima
)

fishermans_bastion = Place.create!(
  title: "Fisherman's Bastion",
  enhanced_description: "Fisherman's Bastion is a terrace in neo-Gothic and neo-Romanesque style situated on the Buda bank of the Danube in Budapest.",
  address: "Szentháromság tér, Budapest, Hungary",
  city: budapest
)

flippermuzeum = Place.create!(
  title: "Flippermúzeum",
  enhanced_description: "Hidden in the Újlipótváros neighborhood, the Flipper Museum is an interactive underground arcade filled with vintage pinball machines you can actually play. A quirky, beloved local secret.",
  address: "Radnóti Miklós u. 18, 1137 Budapest, Hungary",
  city: budapest
)

ellato_koz = Place.create!(
  title: "Ellátó Köz",
  enhanced_description: "A cozy, alternative ruin bar hidden in a courtyard in Kazinczy Street. With mismatched furniture, murals, and a relaxed local vibe, it’s a quieter alternative to the major ruin pubs.",
  address: "Kazinczy u. 48, 1075 Budapest, Hungary",
  city: budapest
)

uzsipark_ruins = Place.create!(
  title: "UzsiPark Ruins",
  enhanced_description: "A partially collapsed industrial space in Óbuda that has been transformed by local artists into a gritty, open-air creative zone. Graffiti, improvised sculptures, and occasional underground events make it a true hidden gem.",
  address: "Bécsi út 136, Budapest, Hungary",
  city: budapest
)

pyramids = Place.create!(
  title: "Pyramids of Giza",
  enhanced_description: "The Giza pyramid complex is an archaeological site on the Giza Plateau, including the three Great Pyramids and the Great Sphinx.",
  address: "Al Haram, Giza Governorate, Egypt",
  city: cairo
)

el_fishawi_side_corners = Place.create!(
  title: "El Fishawi Cafe",
  enhanced_description: "While the main café is famous, the hidden side corners and narrow alleys surrounding El Fishawi offer intimate seating, traditional shisha, and a nostalgic Old Cairo atmosphere cherished by locals.",
  address: "Khan Al Khalili, El Gamaliya, Cairo, Egypt",
  city: cairo
)

erta_ale = Place.create!(
  title: "Erta Ale",
  enhanced_description: "Erta Ale is an active shield volcano located in the Afar Region of Ethiopia. It is famed for its persistent lava and salt lake, one of the few in the world.",
  address: "Danakil Depression, Afar Region, Ethiopia",
  city: afar
)

kloof_corner = Place.create!(
  title: "Kloof Corner",
  enhanced_description: "Kloof Corner is a short but rewarding hike that offers one of Cape Town’s best sunset viewpoints. Locals love it for its peaceful atmosphere and stunning views over the Atlantic seaboard.",
  address: "Tafelberg Rd, Cape Town, South Africa",
  city: cape_town
)

ilha_fiscal = Place.create!(
  title: "Ilha Fiscal",
  enhanced_description: "A small fairytale-like island palace near downtown Rio, known for its emerald-green towers and stunning bay views. Often overlooked by tourists, it’s a fascinating offbeat historical visit.",
  address: "Baía de Guanabara, Rio de Janeiro, Brazil",
  city: rio_de_janeiro
)

parque_lage = Place.create!(
  title: "Parque Lage",
  enhanced_description: "Parque Lage is a lush, historic park at the base of Corcovado with forest trails, hidden caves, and a beautiful old mansion. Locals love it for peaceful walks and its unique blend of nature and history.",
  address: "Rua Jardim Botânico, 414, Jardim Botânico, Rio de Janeiro, Brazil",
  city: rio_de_janeiro
)

casa_gilardi = Place.create!(
  title: "Casa Gilardi",
  enhanced_description: "Casa Gilardi is one of Luis Barragán’s final works, a stunning private home known for its vibrant colors, geometric lines, and the iconic indoor jacaranda tree. A quiet architectural treasure hidden in plain sight.",
  address: "Calle General León 82, San Miguel Chapultepec, Mexico City, Mexico",
  city: mexico_city
)

mercado_de_coyoacan = Place.create!(
  title: "Mercado de Coyoacán",
  enhanced_description: "A lively neighborhood market serving authentic food, fresh fruit, and traditional snacks. Loved by locals for its friendly vendors and vibrant colors—perfect for a true CDMX food experience.",
  address: "Ignacio Allende, Coyoacán, Mexico City, Mexico",
  city: mexico_city
)

grotta_lighthouse = Place.create!(
  title: "Grótta Lighthouse",
  enhanced_description: "Located on a quiet peninsula at the edge of the city, Grótta Lighthouse offers peaceful coastal views, black-sand shores, and some of Reykjavík’s best sunset and northern lights spots—far from the crowds.",
  address: "170 Seltjarnarnes, Iceland",
  city: reykjavik
)

o_sk_juhlid_viewpoint = Place.create!(
  title: "Öskjuhlíð Viewpoint",
  enhanced_description: "Öskjuhlíð is a quiet, forested hill overlooking Reykjavík, offering dark sky pockets perfect for spotting the Northern Lights. Far from city lights yet close to downtown, it’s a favorite local spot for aurora watching.",
  address: "Varmahlíð 1, 105 Reykjavík, Iceland",
  city: reykjavik
)

letna_beergarden_viewpoint = Place.create!(
  title: "Letná Beer Garden Viewpoint",
  enhanced_description: "Tucked inside Letná Park, this relaxed beer garden offers incredible panoramic views of Prague's bridges and the Vltava River. A classic local hangout for warm evenings.",
  address: "Letenské sady, 170 00 Praha 7, Czech Republic",
  city: prague
)

talat_rot_fai = Place.create!(
  title: "Talat Rot Fai (Train Night Market)",
  enhanced_description: "A vibrant retro-themed night market filled with vintage shops, antiques, local street food, and quirky bars. It draws mostly locals and offers an authentic taste of Bangkok nightlife away from tourist spots.",
  address: "Srinagarindra Rd, Nong Bon, Prawet, Bangkok, Thailand",
  city: bangkok
)

puts "Created #{Place.count} places."

puts "Creating comments with photos..."

comment = Comment.create!(
  description: "Absolutely breathtaking architecture! Gaudí's masterpiece is a must-see. The interior light through the stained glass windows creates an otherworldly atmosphere that photos simply cannot capture.",
  place: sagrada_familia,
  user: user1
)
attach_photo(comment, "Sagrada Familia")

comment = Comment.create!(
  description: "Amazing viewpoint! The sunset from here is unbelievable and the atmosphere feels very local. A perfect spot to relax above the city.",
  place: bunkers_del_carmel,
  user: user2
)
attach_photo(comment, "Bunkers del Carmel")


comment = Comment.create!(
  description: "Such a peaceful escape. The maze is fun to explore and the entire park feels hidden from the rest of Barcelona. Beautiful for a quiet walk.",
  place: parc_del_laberint,
  user: user3
)
attach_photo(comment, "Parc del Laberint")

comment = Comment.create!(
  description: "There seems to be no stress, only good vibes and the desire to laugh and have fun.",
  place: antic_teatre,
  user: user4
)
attach_photo(comment, "Antic Teatre")

comment = Comment.create!(
  description: "Such a fun and magical place! The forest atmosphere feels totally immersive and unlike anything else in the city. Great for a quirky drink with friends.",
  place: el_bosc_de_les_fades,
  user: user5
)
attach_photo(comment, "El Bosc de les Fades")

comment = Comment.create!(
  description: "Such a magical place! The colors, the design, and the views over Barcelona make Park Güell unforgettable. A must-visit every time I’m in the city.",
  place: park_guell,
  user: user6
)
attach_photo(comment, "Park Guell")


comment = Comment.create!(
  description: "Loved exploring Montjuïc Castle! The views over the port are amazing and the walk around the fortress walls is super peaceful.",
  place: montjuic_castle,
  user: user6
)
attach_photo(comment, "Montjuic Castle")


comment = Comment.create!(
  description: "Amazing vibe! Great food stalls, creative shops, and live music. Palo Alto Market has such a cool atmosphere—perfect for a relaxed weekend.",
  place: palo_alto_market,
  user: user7
)
attach_photo(comment, "Palo Alto Market")


comment = Comment.create!(
  description: "One of my favorite little streets in Barcelona. Calm, full of charm, and perfect for grabbing a coffee and people-watching. Feels like a hidden oasis in Born.",
  place: carrer_de_lallada,
  user: user1
)
attach_photo(comment, "Carrer de L’Allada-Vermell")

comment = Comment.create!(
  description: "The temple grounds are peaceful despite the crowds. The giant red lantern at the entrance is iconic. Don't miss the shopping street Nakamise-dori leading up to it for traditional snacks.",
  place: senso_ji,
  user: user4
)
attach_photo(comment, "Sensō-ji Temple")

comment = Comment.create!(
  description: "One of the most surreal experiences of my life! Hiking through the Danakil Depression at night to see the glowing lava lake is otherworldly. Bring plenty of water — it's one of Earth's hottest places. A true hidden gem that few travelers know about.",
  place: erta_ale,
  user: user5
)
attach_photo(comment, "Erta Ale")

comment = Comment.create!(
  description: "Visited at sunset and the views were magical. The elevator ride up offers stunning panoramic views of Paris. Book tickets in advance online to skip the long queues at the base.",
  place: eiffel_tower,
  user: user7
)
attach_photo(comment, "Eiffel Tower")

comment = Comment.create!(
  description: "Such a beautiful park! The hills, views, and little hidden corners make it feel like a secret world inside Paris. Perfect for a slow morning walk.",
  place: parc_des_buttes_chaumont,
  user: user1
)
attach_photo(comment, "Parc des Buttes-Chaumont")


comment = Comment.create!(
  description: "Loved strolling along the canal! Calm, scenic, and full of cozy spots. Feels very local compared to the busy center of Paris.",
  place: canal_saint_martin,
  user: user2
)
attach_photo(comment, "Canal Saint-Martin")

comment = Comment.create!(
  description: "A perfect little oasis in Midtown! The waterfall makes it feel worlds away from the busy streets. Loved stopping here for a quiet break.",
  place: greenacre_park,
  user: user5
)
attach_photo(comment, "Greenacre Park")


comment = Comment.create!(
  description: "Such a magical place. The medieval art combined with the peaceful gardens makes it feel like you're not even in NYC. Truly a hidden sanctuary.",
  place: the_cloisters,
  user: user6
)
attach_photo(comment, "The Cloisters")


comment = Comment.create!(
  description: "Freeman Alley is so cool! The graffiti, tucked-away doorways, and artsy vibe make it a fun little detour. Great for photos and exploring the LES.",
  place: freemans_alley,
  user: user7
)
attach_photo(comment, "Freeman Alley")

comment = Comment.create!(
  description: "The architecture is absolutely stunning, especially when lit up at night. We took a harbor cruise to see it from the water. The acoustics inside during a performance are world-class.",
  place: opera_house,
  user: user1
)
attach_photo(comment, "Sydney Opera House")

comment = Comment.create!(
  description: "A deeply moving experience walking through the rooms where Anne Frank and her family hid. The museum does an excellent job of presenting history. Book tickets well in advance online.",
  place: anne_frank,
  user: user2
)
attach_photo(comment, "Anne Frank House")

comment = Comment.create!(
  description: "Such a calm and beautiful park. The lake, open fields, and quiet paths make it perfect for relaxing or reading. A true escape from the city buzz.",
  place: flevopark,
  user: user4
)
attach_photo(comment, "Flevopark")


comment = Comment.create!(
  description: "Loved exploring these streets! Small cafés, street art, and local shops everywhere. It feels like a real neighborhood, not a tourist area at all.",
  place: de_pijp_market_streets,
  user: user5
)
attach_photo(comment, "De Pijp Market Streets")

comment = Comment.create!(
  description: "Walking across Tower Bridge at night is a magical experience. The bridge lifts for tall ships are fascinating to watch. The Tower Bridge Exhibition offers great views from the walkways.",
  place: tower_bridge,
  user: user6
)
attach_photo(comment, "Tower Bridge")

comment = Comment.create!(
  description: "The historic center of Lima is beautiful with stunning colonial architecture. The plaza is surrounded by important buildings including the Government Palace and the Cathedral of Lima.",
  place: plaza_mayor,
  user: user7
)
attach_photo(comment, "Plaza Mayor de Lima")

comment = Comment.create!(
  description: "A beautiful and peaceful park! The old olive trees give it so much character, and it’s a great place to relax away from the busy parts of Lima.",
  place: parque_el_olivar,
  user: user2
)
attach_photo(comment, "Parque El Olivar")

comment = Comment.create!(
  description: "The views of Budapest from here are absolutely spectacular, especially at sunset. The neo-Gothic towers and terraces are perfect for photos. Don't miss the view of the Parliament building.",
  place: fishermans_bastion,
  user: user5
)
attach_photo(comment, "Fisherman's Bastion")

comment = Comment.create!(
  description: "Such a fun and nostalgic spot! Being able to actually play all the vintage pinball machines makes this place feel like a retro playground. Easily one of Budapest’s coolest hidden gems.",
  place: flippermuzeum,
  user: user6
)
attach_photo(comment, "Flippermúzeum")


comment = Comment.create!(
  description: "A relaxed and artsy ruin bar with a much more local vibe than the big ones nearby. Loved the murals, the atmosphere, and how easy it was to find a cozy corner.",
  place: ellato_koz,
  user: user7
)
attach_photo(comment, "Ellátó Köz")


comment = Comment.create!(
  description: "A super unique place! The industrial ruins mixed with street art and open space create such an interesting atmosphere. Feels like discovering an underground creative world.",
  place: uzsipark_ruins,
  user: user1
)
attach_photo(comment, "UzsiPark Ruins")

comment = Comment.create!(
  description: "Standing before the ancient pyramids is a humbling experience. The sheer scale is hard to comprehend until you're there. We highly recommend hiring a local guide for the history.",
  place: pyramids,
  user: user1
)
attach_photo(comment, "Pyramids of Giza")

comment = Comment.create!(
  description: "Such a cozy hidden spot! The side corners around El Fishawi feel wonderfully authentic — quiet seating, traditional atmosphere, and a perfect place to soak in the charm of Old Cairo.",
  place: el_fishawi_side_corners,
  user: user2
)
attach_photo(comment, "El Fishawi Cafe")

comment = Comment.create!(
  description: "Such a stunning spot! The short climb rewards you with amazing views over the city and ocean. A perfect place for sunset and a favorite with locals.",
  place: kloof_corner,
  user: user4
)
attach_photo(comment, "Kloof Corner")

comment = Comment.create!(
  description: "Such a peaceful escape! The trails, the greenery, and the old mansion make Parque Lage feel like a secret world in the middle of Rio. Absolutely loved exploring here.",
  place: parque_lage,
  user: user4
)
attach_photo(comment, "Parque Lage")


comment = Comment.create!(
  description: "A magical little island! The architecture is beautiful and the views of the bay are incredible. Definitely one of the most underrated historical spots in Rio.",
  place: ilha_fiscal,
  user: user5
)
attach_photo(comment, "Ilha Fiscal")

comment = Comment.create!(
  description: "An incredible architectural experience! The colors, light, and design at Casa Gilardi are absolutely stunning. A must-see for anyone who loves modern architecture.",
  place: casa_gilardi,
  user: user5
)
attach_photo(comment, "Casa Gilardi")


comment = Comment.create!(
  description: "Such a vibrant and friendly market! Amazing food, fresh fruit, and a great local vibe. Perfect place to try authentic Mexican snacks away from the tourist spots.",
  place: mercado_de_coyoacan,
  user: user6
)
attach_photo(comment, "Mercado de Coyoacán")

comment = Comment.create!(
  description: "Such a peaceful spot! The coastal views are beautiful during the day, and it’s an amazing place to watch the sunset. Perfect for a quiet walk by the sea.",
  place: grotta_lighthouse,
  user: user6
)
attach_photo(comment, "Grótta Lighthouse")


comment = Comment.create!(
  description: "A fantastic viewpoint! The forested trails and open areas make it ideal for catching the Northern Lights when conditions are good. Loved the calm atmosphere here.",
  place: o_sk_juhlid_viewpoint,
  user: user7
)
attach_photo(comment, "Öskjuhlíð Viewpoint")

comment = Comment.create!(
  description: "Amazing view over Prague! The beer garden has a relaxed atmosphere and the panorama of the river and bridges is unforgettable. Perfect spot for a sunny afternoon.",
  place: letna_beergarden_viewpoint,
  user: user7
)
attach_photo(comment, "Letná Beer Garden Viewpoint")

comment = Comment.create!(
  description: "Loved this night market! So many unique vintage shops and incredible food stalls. The atmosphere is lively but still feels very local. One of my favorites in Bangkok!",
  place: talat_rot_fai,
  user: user1
)
attach_photo(comment, "Talat Rot Fai")

puts "Created #{Comment.count} comments."
puts "Seeding complete!"
