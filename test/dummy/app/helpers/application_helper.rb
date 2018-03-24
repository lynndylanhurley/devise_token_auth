module ApplicationHelper
  COLOR_NAMES = [
    'Acid green',
    'Aero',
    'Aero blue',
    'African violet',
    'Air Force blue',
    'Air superiority blue',
    'Alabama Crimson',
    'Alice blue',
    'Alizarin crimson',
    'Alloy orange',
    'Almond',
    'Amaranth',
    'Amaranth pink',
    'Amaranth purple',
    'Amazon',
    'Amber',
    'Amethyst',
    'Android green',
    'Anti-flash white',
    'Antique brass',
    'Antique bronze',
    'Antique fuchsia',
    'Antique ruby',
    'Antique white',
    'Ao',
    'Apple green',
    'Apricot',
    'Aqua',
    'Aquamarine',
    'Army green',
    'Arsenic',
    'Artichoke',
    'Arylide yellow',
    'Ash grey',
    'Asparagus',
    'Atomic tangerine',
    'Auburn',
    'Aureolin',
    'AuroMetalSaurus',
    'Avocado',
    'Azure',
    'Azure mist/web',

    'Baby blue',
    'Baby blue eyes',
    'Baby pink',
    'Baby powder',
    'Baker-Miller pink',
    'Ball blue',
    'Banana Mania',
    'Banana yellow',
    'Bangladesh green',
    'Barbie pink',
    'Barn red',
    'Battleship grey',
    'Bazaar',
    'Beau blue',
    'Beaver',
    'Beige',
    "B'dazzled blue",
    "Big dip o'ruby",
    'Bisque',
    'Bistre',
    'Bistre brown',
    'Bitter lemon',
    'Bitter lime',
    'Bittersweet',
    'Bittersweet shimmer',
    'Black',
    'Black bean',
    'Black leather jacket',
    'Black olive',
    'Blanched almond',
    'Blast-off bronze',
    'Bleu de France',
    'Blizzard Blue',
    'Blond',
    'Blue',
    'Blue Bell',
    'Blue-gray',
    'Blue-green',
    'Blue sapphire',
    'Blue-violet',
    'Blue yonder',
    'Blueberry',
    'Bluebonnet',
    'Blush',
    'Bole',
    'Bondi blue',
    'Bone',
    'Boston University Red',
    'Bottle green',
    'Boysenberry',
    'Brandeis blue',
    'Brass',
    'Brick red',
    'Bright cerulean',
    'Bright green',
    'Bright lavender',
    'Bright lilac',
    'Bright maroon',
    'Bright navy blue',
    'Bright pink',
    'Bright turquoise',
    'Bright ube',
    'Brilliant lavender',
    'Brilliant rose',
    'Brink pink',
    'British racing green',
    'Bronze',
    'Bronze Yellow',
    'Brown',
    'Brown-nose',
    'Brunswick green',
    'Bubble gum',
    'Bubbles',
    'Buff',
    'Bud green',
    'Bulgarian rose',
    'Burgundy',
    'Burlywood',
    'Burnt orange',
    'Burnt sienna',
    'Burnt umber',
    'Byzantine',
    'Byzantium',

    'Cadet',
    'Cadet blue',
    'Cadet grey',
    'Cadmium green',
    'Cadmium orange',
    'Cadmium red',
    'Cadmium yellow',
    'Cafe au lait',
    'Cafe noir',
    'Cal Poly Pomona green',
    'Cambridge Blue',
    'Camel',
    'Cameo pink',
    'Camouflage green',
    'Canary yellow',
    'Candy apple red',
    'Candy pink',
    'Capri',
    'Caput mortuum',
    'Cardinal',
    'Caribbean green',
    'Carmine',
    'Carmine',
    'Carmine pink',
    'Carmine red',
    'Carnation pink',
    'Carnelian',
    'Carolina blue',
    'Carrot orange',
    'Castleton green',
    'Catalina blue',
    'Catawba',
    'Cedar Chest',
    'Ceil',
    'Celadon',
    'Celadon blue',
    'Celadon green',
    'Celeste',
    'Celestial blue',
    'Cerise',
    'Cerise pink',
    'Cerulean',
    'Cerulean blue',
    'Cerulean frost',
    'CG Blue',
    'CG Red',
    'Chamoisee',
    'Champagne',
    'Charcoal',
    'Charleston green',
    'Charm pink',
    'Chartreuse',
    'Cherry',
    'Cherry blossom pink',
    'Chestnut',
    'China pink',
    'China rose',
    'Chinese red',
    'Chinese violet',
    'Chocolate',
    'Chrome yellow',
    'Cinereous',
    'Cinnabar',
    'Cinnamon',
    'Citrine',
    'Citron',
    'Claret',
    'Classic rose',
    'Cobalt',
    'Cocoa brown',
    'Coconut',
    'Coffee',
    'Columbia blue',
    'Congo pink',
    'Cool grey',
    'Copper',
    'Copper penny',
    'Copper red',
    'Copper rose',
    'Coquelicot',
    'Coral',
    'Coral pink',
    'Coral red',
    'Cordovan',
    'Corn',
    'Cornell Red',
    'Cornflower blue',
    'Cornsilk',
    'Cosmic latte',
    'Cotton candy',
    'Cream',
    'Crimson',
    'Crimson glory',
    'Cyan',
    'Cyber grape',
    'Cyber yellow',

    'Daffodil',
    'Dandelion',
    'Dark blue',
    'Dark blue-gray',
    'Dark brown',
    'Dark byzantium',
    'Dark candy apple red',
    'Dark cerulean',
    'Dark chestnut',
    'Dark coral',
    'Dark cyan',
    'Dark electric blue',
    'Dark goldenrod',
    'Dark gray',
    'Dark green',
    'Dark imperial blue',
    'Dark jungle green',
    'Dark khaki',
    'Dark lava',
    'Dark lavender',
    'Dark liver',
    'Dark magenta',
    'Dark medium gray',
    'Dark midnight blue',
    'Dark moss green',
    'Dark olive green',
    'Dark orange',
    'Dark orchid',
    'Dark pastel blue',
    'Dark pastel green',
    'Dark pastel purple',
    'Dark pastel red',
    'Dark pink',
    'Dark powder blue',
    'Dark puce',
    'Dark raspberry',
    'Dark red',
    'Dark salmon',
    'Dark scarlet',
    'Dark sea green',
    'Dark sienna',
    'Dark sky blue',
    'Dark slate blue',
    'Dark slate gray',
    'Dark spring green',
    'Dark tan',
    'Dark tangerine',
    'Dark taupe',
    'Dark terra cotta',
    'Dark turquoise',
    'Dark vanilla',
    'Dark violet',
    'Dark yellow',
    'Dartmouth green',
    "Davy's grey",
    'Debian red',
    'Deep carmine',
    'Deep carmine pink',
    'Deep carrot orange',
    'Deep cerise',
    'Deep champagne',
    'Deep chestnut',
    'Deep coffee',
    'Deep fuchsia',
    'Deep jungle green',
    'Deep lemon',
    'Deep lilac',
    'Deep magenta',
    'Deep mauve',
    'Deep moss green',
    'Deep peach',
    'Deep pink',
    'Deep puce',
    'Deep ruby',
    'Deep saffron',
    'Deep sky blue',
    'Deep Space Sparkle',
    'Deep Taupe',
    'Deep Tuscan red',
    'Deer',
    'Denim',
    'Desert',
    'Desert sand',
    'Desire',
    'Diamond',
    'Dim gray',
    'Dirt',
    'Dodger blue',
    'Dogwood rose',
    'Dollar bill',
    'Donkey brown',
    'Drab',
    'Duke blue',
    'Dust storm',
    'Dutch white',

    'Earth yellow',
    'Ebony',
    'Ecru',
    'Eerie black',
    'Eggplant',
    'Eggshell',
    'Egyptian blue',
    'Electric blue',
    'Electric crimson',
    'Electric cyan',
    'Electric green',
    'Electric indigo',
    'Electric lavender',
    'Electric lime',
    'Electric purple',
    'Electric ultramarine',
    'Electric violet',
    'Electric yellow',
    'Emerald',
    'Eminence',
    'English green',
    'English lavender',
    'English red',
    'English violet',
    'Eton blue',
    'Eucalyptus',

    'Fallow',
    'Falu red',
    'Fandango',
    'Fandango pink',
    'Fashion fuchsia',
    'Fawn',
    'Feldgrau',
    'Feldspar',
    'Fern green',
    'Ferrari Red',
    'Field drab',
    'Firebrick',
    'Fire engine red',
    'Flame',
    'Flamingo pink',
    'Flattery',
    'Flavescent',
    'Flax',
    'Flirt',
    'Floral white',
    'Fluorescent orange',
    'Fluorescent pink',
    'Fluorescent yellow',
    'Folly',
    'Forest green',
    'French beige',
    'French bistre',
    'French blue',
    'French fuchsia',
    'French lilac',
    'French lime',
    'French mauve',
    'French pink',
    'French plum',
    'French puce',
    'French raspberry',
    'French rose',
    'French sky blue',
    'French violet',
    'French wine',
    'Fresh Air',
    'Fuchsia',
    'Fuchsia',
    'Fuchsia pink',
    'Fuchsia purple',
    'Fuchsia rose',
    'Fulvous',
    'Fuzzy Wuzzy',

    'Gainsboro',
    'Gamboge',
    'Generic viridian',
    'Ghost white',
    'Giants orange',
    'Ginger',
    'Glaucous',
    'Glitter',
    'GO green',
    'Gold',
    'Gold Fusion',
    'Golden brown',
    'Golden poppy',
    'Golden yellow',
    'Goldenrod',
    'Granny Smith Apple',
    'Grape',
    'Gray',
    'Gray-asparagus',
    'Gray-blue',
    'Green',
    'Green-yellow',
    'Grizzly',
    'Grullo',
    'Guppie green',
    'Halaya ube',
    'Han blue',
    'Han purple',
    'Hansa yellow',
    'Harlequin',
    'Harvard crimson',
    'Harvest gold',
    'Heart Gold',
    'Heliotrope',
    'Heliotrope gray',
    'Hollywood cerise',
    'Honeydew',
    'Honolulu blue',
    "Hooker's green",
    'Hot magenta',
    'Hot pink',
    'Hunter green',

    'Iceberg',
    'Icterine',
    'Illuminating Emerald',
    'Imperial',
    'Imperial blue',
    'Imperial purple',
    'Imperial red',
    'Inchworm',
    'Independence',
    'India green',
    'Indian red',
    'Indian yellow',
    'Indigo',
    'Indigo dye',
    'International Klein Blue',
    'International orange',
    'Iris',
    'Irresistible',
    'Isabelline',
    'Islamic green',
    'Italian sky blue',
    'Ivory',
    'Jade',
    'Japanese carmine',
    'Japanese indigo',
    'Japanese violet',
    'Jasmine',
    'Jasper',
    'Jazzberry jam',
    'Jelly Bean',
    'Jet',
    'Jonquil',
    'Jordy blue',
    'June bud',
    'Jungle green',
    'Kelly green',
    'Kenyan copper',
    'Keppel',
    'Khaki',
    'Kobe',
    'Kobi',
    'Kombu green',
    'KU Crimson',

    'La Salle Green',
    'Languid lavender',
    'Lapis lazuli',
    'Laser Lemon',
    'Laurel green',
    'Lava',
    'Lavender',
    'Lavender blue',
    'Lavender blush',
    'Lavender gray',
    'Lavender indigo',
    'Lavender magenta',
    'Lavender mist',
    'Lavender pink',
    'Lavender purple',
    'Lavender rose',
    'Lawn green',
    'Lemon',
    'Lemon chiffon',
    'Lemon curry',
    'Lemon glacier',
    'Lemon lime',
    'Lemon meringue',
    'Lemon yellow',
    'Licorice',
    'Liberty',
    'Light apricot',
    'Light blue',
    'Light brown',
    'Light carmine pink',
    'Light coral',
    'Light cornflower blue',
    'Light crimson',
    'Light cyan',
    'Light deep pink',
    'Light French beige',
    'Light fuchsia pink',
    'Light goldenrod yellow',
    'Light gray',
    'Light green',
    'Light hot pink',
    'Light khaki',
    'Light medium orchid',
    'Light moss green',
    'Light orchid',
    'Light pastel purple',
    'Light pink',
    'Light red ochre',
    'Light salmon',
    'Light salmon pink',
    'Light sea green',
    'Light sky blue',
    'Light slate gray',
    'Light steel blue',
    'Light taupe',
    'Light Thulian pink',
    'Light yellow',
    'Lilac',
    'Lime',
    'Lime green',
    'Limerick',
    'Lincoln green',
    'Linen',
    'Lion',
    'Liseran Purple',
    'Little boy blue',
    'Liver',
    'Liver',
    'Liver chestnut',
    'Livid',
    'Lumber',
    'Lust',

    'Magenta',
    'Magenta',
    'Magenta haze',
    'Magic mint',
    'Magnolia',
    'Mahogany',
    'Maize',
    'Majorelle Blue',
    'Malachite',
    'Manatee',
    'Mango Tango',
    'Mantis',
    'Mardi Gras',
    'Maroon',
    'Mauve',
    'Mauve taupe',
    'Mauvelous',
    'May green',
    'Maya blue',
    'Meat brown',
    'Medium aquamarine',
    'Medium blue',
    'Medium candy apple red',
    'Medium carmine',
    'Medium champagne',
    'Medium electric blue',
    'Medium jungle green',
    'Medium lavender magenta',
    'Medium orchid',
    'Medium Persian blue',
    'Medium purple',
    'Medium red-violet',
    'Medium ruby',
    'Medium sea green',
    'Medium sky blue',
    'Medium slate blue',
    'Medium spring bud',
    'Medium spring green',
    'Medium taupe',
    'Medium turquoise',
    'Medium Tuscan red',
    'Medium vermilion',
    'Medium violet-red',
    'Mellow apricot',
    'Mellow yellow',
    'Melon',
    'Metallic Seaweed',
    'Metallic Sunburst',
    'Mexican pink',
    'Midnight blue',
    'Milky blue',
    'Midnight green',
    'Mikado yellow',
    'Mindaro',
    'Mint',
    'Mint cream',
    'Mint green',
    'Misty rose',
    'Moccasin',
    'Mode beige',
    'Moonstone blue',
    'Mordant red 19',
    'Moss green',
    'Mountain Meadow',
    'Mountbatten pink',
    'MSU Green',
    'Mughal green',
    'Mulberry',
    'Mustard',
    'Myrtle green',

    'Nadeshiko pink',
    'Napier green',
    'Naples yellow',
    'Navajo white',
    'Navy',
    'Navy purple',
    'Neon Carrot',
    'Neon fuchsia',
    'Neon green',
    'New Car',
    'New York pink',
    'Non-photo blue',
    'North Texas Green',
    'Nyanza',
    'Ocean Boat Blue',
    'Ochre',
    'Office green',
    'Old burgundy',
    'Old gold',
    'Old heliotrope',
    'Old lace',
    'Old lavender',
    'Old mauve',
    'Old moss green',
    'Old rose',
    'Old silver',
    'Olive',
    'Olive Drab',
    'Olivine',
    'Onyx',
    'Opera mauve',
    'Orange',
    'Orange peel',
    'Orange-red',
    'Orchid',
    'Orchid pink',
    'Orioles orange',
    'Otter brown',
    'Outer Space',
    'Outrageous Orange',
    'Oxford Blue',
    'OU Crimson Red',

    'Pakistan green',
    'Palatinate blue',
    'Palatinate purple',
    'Pale aqua',
    'Pale blue',
    'Pale brown',
    'Pale carmine',
    'Pale cerulean',
    'Pale chestnut',
    'Pale copper',
    'Pale cornflower blue',
    'Pale gold',
    'Pale goldenrod',
    'Pale green',
    'Pale lavender',
    'Pale magenta',
    'Pale pink',
    'Pale plum',
    'Pale red-violet',
    'Pale robin egg blue',
    'Pale silver',
    'Pale spring bud',
    'Pale taupe',
    'Pale turquoise',
    'Pale violet-red',
    'Pansy purple',
    'Paolo Veronese green',
    'Papaya whip',
    'Paradise pink',
    'Paris Green',
    'Pastel blue',
    'Pastel brown',
    'Pastel gray',
    'Pastel green',
    'Pastel magenta',
    'Pastel orange',
    'Pastel pink',
    'Pastel purple',
    'Pastel red',
    'Pastel violet',
    'Pastel yellow',
    'Patriarch',
    "Payne's grey",
    'Peach',
    'Peach',
    'Peach-orange',
    'Peach puff',
    'Peach-yellow',
    'Pear',
    'Pearl',
    'Pearl Aqua',
    'Pearly purple',
    'Peridot',
    'Periwinkle',
    'Persian blue',
    'Persian green',
    'Persian indigo',
    'Persian orange',
    'Persian pink',
    'Persian plum',
    'Persian red',
    'Persian rose',
    'Persimmon',
    'Peru',
    'Phlox',
    'Phthalo blue',
    'Phthalo green',
    'Picton blue',
    'Pictorial carmine',
    'Piggy pink',
    'Pine green',
    'Pineapple',
    'Pink',
    'Pink lace',
    'Pink lavender',
    'Pink-orange',
    'Pink pearl',
    'Pink Sherbet',
    'Pistachio',
    'Platinum',
    'Plum',
    'Pomp and Power',
    'Popstar',
    'Portland Orange',
    'Powder blue',
    'Princeton orange',
    'Prune',
    'Prussian blue',
    'Psychedelic purple',
    'Puce',
    'Puce red',
    'Pullman Brown',
    'Pumpkin',
    'Purple',
    'Purple Heart',
    'Purple mountain majesty',
    'Purple navy',
    'Purple pizzazz',
    'Purple taupe',
    'Purpureus',

    'Quartz',
    'Queen blue',
    'Queen pink',
    'Quinacridone magenta',
    'Rackley',
    'Radical Red',
    'Rajah',
    'Raspberry',
    'Raspberry glace',
    'Raspberry pink',
    'Raspberry rose',
    'Raw umber',
    'Razzle dazzle rose',
    'Razzmatazz',
    'Razzmic Berry',
    'Rebecca Purple',
    'Red',
    'Red',
    'Red-brown',
    'Red devil',
    'Red-orange',
    'Red-purple',
    'Red-violet',
    'Redwood',
    'Regalia',
    'Resolution blue',
    'Rhythm',
    'Rich black',
    'Rich brilliant lavender',
    'Rich carmine',
    'Rich electric blue',
    'Rich lavender',
    'Rich lilac',
    'Rich maroon',
    'Rifle green',
    'Roast coffee',
    'Robin egg blue',
    'Rocket metallic',
    'Roman silver',
    'Rose',
    'Rose bonbon',
    'Rose ebony',
    'Rose gold',
    'Rose madder',
    'Rose pink',
    'Rose quartz',
    'Rose red',
    'Rose taupe',
    'Rose vale',
    'Rosewood',
    'Rosso corsa',
    'Rosy brown',
    'Royal azure',
    'Royal blue',
    'Royal blue',
    'Royal fuchsia',
    'Royal purple',
    'Royal yellow',
    'Ruber',
    'Rubine red',
    'Ruby',
    'Ruby red',
    'Ruddy',
    'Ruddy brown',
    'Ruddy pink',
    'Rufous',
    'Russet',
    'Russian green',
    'Russian violet',
    'Rust',
    'Rusty red',

    'Sacramento State green',
    'Saddle brown',
    'Safety orange',
    'Safety yellow',
    'Saffron',
    'Sage',
    "St. Patrick's blue",
    'Salmon',
    'Salmon pink',
    'Sand',
    'Sand dune',
    'Sandstorm',
    'Sandy brown',
    'Sandy taupe',
    'Sangria',
    'Sap green',
    'Sapphire',
    'Sapphire blue',
    'Satin sheen gold',
    'Scarlet',
    'Scarlet',
    'Schauss pink',
    'School bus yellow',
    "Screamin' Green",
    'Sea blue',
    'Sea green',
    'Seal brown',
    'Seashell',
    'Selective yellow',
    'Sepia',
    'Shadow',
    'Shadow blue',
    'Shampoo',
    'Shamrock green',
    'Sheen Green',
    'Shimmering Blush',
    'Shocking pink',
    'Sienna',
    'Silver',
    'Silver chalice',
    'Silver Lake blue',
    'Silver pink',
    'Silver sand',
    'Sinopia',
    'Skobeloff',
    'Sky blue',
    'Sky magenta',
    'Slate blue',
    'Slate gray',
    'Smalt',
    'Smitten',
    'Smoke',
    'Smoky black',
    'Smoky Topaz',
    'Snow',
    'Soap',
    'Solid pink',
    'Sonic silver',
    'Spartan Crimson',
    'Space cadet',
    'Spanish bistre',
    'Spanish blue',
    'Spanish carmine',
    'Spanish crimson',
    'Spanish gray',
    'Spanish green',
    'Spanish orange',
    'Spanish pink',
    'Spanish red',
    'Spanish sky blue',
    'Spanish violet',
    'Spanish viridian',
    'Spiro Disco Ball',
    'Spring bud',
    'Spring green',
    'Star command blue',
    'Steel blue',
    'Steel pink',
    'Stil de grain yellow',
    'Stizza',
    'Stormcloud',
    'Straw',
    'Strawberry',
    'Sunglow',
    'Sunray',
    'Sunset',
    'Sunset orange',
    'Super pink',

    'Tan',
    'Tangelo',
    'Tangerine',
    'Tangerine yellow',
    'Tango pink',
    'Taupe',
    'Taupe gray',
    'Tea green',
    'Tea rose',
    'Tea rose',
    'Teal',
    'Teal blue',
    'Teal deer',
    'Teal green',
    'Telemagenta',
    'Tenne',
    'Terra cotta',
    'Thistle',
    'Thulian pink',
    'Tickle Me Pink',
    'Tiffany Blue',
    "Tiger's eye",
    'Timberwolf',
    'Titanium yellow',
    'Tomato',
    'Toolbox',
    'Topaz',
    'Tractor red',
    'Trolley Grey',
    'Tropical rain forest',
    'True Blue',
    'Tufts Blue',
    'Tulip',
    'Tumbleweed',
    'Turkish rose',
    'Turquoise',
    'Turquoise blue',
    'Turquoise green',
    'Tuscan',
    'Tuscan brown',
    'Tuscan red',
    'Tuscan tan',
    'Tuscany',
    'Twilight lavender',
    'Tyrian purple',

    'UA blue',
    'UA red',
    'Ube',
    'UCLA Blue',
    'UCLA Gold',
    'UFO Green',
    'Ultramarine',
    'Ultramarine blue',
    'Ultra pink',
    'Ultra red',
    'Umber',
    'Unbleached silk',
    'United Nations blue',
    'University of California Gold',
    'Unmellow yellow',
    'UP Forest green',
    'UP Maroon',
    'Upsdell red',
    'Urobilin',
    'USAFA blue',
    'USC Cardinal',
    'USC Gold',
    'University of Tennessee Orange',
    'Utah Crimson',
    'Vanilla',
    'Vanilla ice',
    'Vegas gold',
    'Venetian red',
    'Verdigris',
    'Vermilion',
    'Vermilion',
    'Veronica',
    'Violet',
    'Violet-blue',
    'Violet-red',
    'Viridian',
    'Viridian green',
    'Vista blue',
    'Vivid auburn',
    'Vivid burgundy',
    'Vivid cerise',
    'Vivid orchid',
    'Vivid sky blue',
    'Vivid tangerine',
    'Vivid violet',

    'Warm black',
    'Waterspout',
    'Wenge',
    'Wheat',
    'White',
    'White smoke',
    'Wild blue yonder',
    'Wild orchid',
    'Wild Strawberry',
    'Wild watermelon',
    'Willpower orange',
    'Windsor tan',
    'Wine',
    'Wine dregs',
    'Wisteria',
    'Wood brown',
    'Xanadu',
    'Yale Blue',
    'Yankees blue',
    'Yellow',
    'Yellow-green',
    'Yellow Orange',
    'Yellow rose',
    'Zaffre',
    'Zinnwaldite brown',
    'Zomp'
  ]

  COLOR_SEARCH = FuzzBall::Searcher.new(COLOR_NAMES)
end
