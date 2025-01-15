import 'dart:io';

class ItemMenu {
  String nama, deskripsi, linkGambar;
  int harga;
  File imageFile;

  ItemMenu(this.nama, this.deskripsi, this.linkGambar, this.harga, this.imageFile);

  Map<String, dynamic> toJson() => {
        'nama_produk': nama,
        'deskripsi': deskripsi,
        'harga': harga,
      };
}

List<ItemMenu> menuImitasi = [
  ItemMenu(
    "Klepon",
    "Kue tradisional berbentuk bulat kecil dengan isian gula merah yang lumer di mulut, dilapisi kelapa parut di luar. Harga per 5 pcs.",
    "assets/klepon.jpg",
    6000,
    File('assets/klepon.jpg')
  ),
  ItemMenu(
    "Kue Lapis",
    "Kue berlapis warna-warni dengan rasa manis dan kenyal, cocok untuk dinikmati sebagai camilan. Harga per 4 pcs.",
    "assets/kue_lapis.jpg",
    8000,
    File('assets/kue_lapis.jpg')
  ),
  ItemMenu(
    "Kue Lumpur",
    "Kue lembut dan creamy dengan rasa manis yang terbuat dari kentang dan santan, ditambah kismis di atasnya. Harga per 3 pcs.",
    "assets/kue_lumpur.jpg",
    10000,
    File('assets/kue_lumpur.jpg')
  ),
  ItemMenu(
    "Lemper",
    "Nasi ketan dengan isian ayam yang gurih dan dibungkus daun pisang. Harga per 2 pcs.",
    "assets/lemper.jpg",
    7000,
    File('assets/lemper.jpg')
  ),
  ItemMenu(
    "Onde-onde",
    "Kue bulat berisi kacang hijau yang dibalut biji wijen dan digoreng hingga renyah. Harga per 3 pcs.",
    "assets/onde_onde.jpg",
    7000,
    File('assets/onde_onde.jpg')
  ),
  ItemMenu(
    "Serabi",
    "Kue serabi dengan rasa manis dan tekstur kenyal, biasanya beraroma pandan atau gula merah. Harga per 4 pcs.",
    "assets/serabi.jpg",
    10000,
    File('assets/serabi.jpg')
  ),
  ItemMenu(
    "Kue Putu Ayu",
    "Kue tradisional bertekstur lembut dengan aroma pandan dan taburan kelapa parut di atasnya. Harga per 3 pcs.",
    "assets/kue_putu_ayu.jpg",
    5000,
    File('assets/kue_putu_ayu.jpg')
  ),
  ItemMenu(
    "Bolu Kukus",
    "Kue kukus dengan tekstur lembut dan warna cerah, biasanya dengan aroma pandan atau cokelat. Harga per 4 pcs.",
    "assets/bolu_kukus.jpg",
    10000,
    File('assets/bolu_kukus.jpg')
  ),
  ItemMenu(
    "Brownies Mini",
    "Brownies lembut dengan rasa cokelat pekat dalam ukuran mini. Harga per 4 pcs.",
    "assets/brownies_mini.jpg",
    12000,
    File('assets/brownies_mini.jpg')
  ),
  ItemMenu(
    "Pastel",
    "Pastry gurih dengan isian sayuran dan bihun atau ayam, digoreng hingga renyah. Harga per 3 pcs.",
    "assets/pastel.jpg",
    10000,
    File('assets/pastel.jpg')
  ),
  ItemMenu(
    "Risol Mayo",
    "Risol goreng berisi mayones, daging asap, dan telur, menghasilkan rasa gurih yang creamy. Harga per 3 pcs.",
    "assets/risol_mayo.jpg",
    12000,
    File('assets/risol_mayo.jpg')
  ),
  ItemMenu(
    "Martabak Mini Manis",
    "Martabak manis dalam ukuran mini dengan berbagai topping seperti cokelat, keju, atau kacang. Harga per 5 pcs.",
    "assets/martabak_mini_manis.jpg",
    15000,
    File('assets/martabak_mini_manis.jpg')
  ),
  ItemMenu(
    "Es Teh",
    "Minuman teh manis yang disajikan dingin, sangat menyegarkan sebagai pendamping camilan.",
    "assets/Esteh.jpeg",
    4000,
    File('assets/Esteh.jpeg')
  ),
];

