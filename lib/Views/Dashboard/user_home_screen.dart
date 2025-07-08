import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voicefirst/Widgets/dynamic_drawer.dart';

import '../../Models/menu_item_model.dart';
import '../../Widgets/feedback_form.dart';

class Userhomescreen extends StatefulWidget {
  @override
  State<Userhomescreen> createState() => _UserhomescreenState();
}

class _UserhomescreenState extends State<Userhomescreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredPlaces = [];
  List<MenuItem> menuItems = [];

  final List<Widget> _screens = [
    Center(
      child: Text('Saved Page', style: TextStyle(color: Colors.white)),
    ),
    // QrScanScreen(),
    // ProfileScreen(),
  ];

  final List<Map<String, dynamic>> places = [
    {
      "t3_section_name": "Main Dining Area",
      "t3_branch_section_id": "BRANCH001",
      "t2_section_type_id": "BT001",
      "t2_section_type": "Restaurant",
      "image":
          "https://imgs.search.brave.com/ULsO-W7t2Dd8idOqm27JWeKdRrUfoHRUQxzKqDK3_zE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzA4Lzg3LzQzLzEy/LzM2MF9GXzg4NzQz/MTIxMV9vVE10b0s0/dURvVEJZcTU3Q2p4/a3dOQnpxRXhoUFlm/Ri5qcGc",
      "branch_details": {
        "t2_company_branch_id": "BR001",
        "t2_company_branch_name": "Downtown Branch",
        "t2_branch_type_id": "BT001",
        "t2_branch_type": "Restaurant",
        "t2_address_1": "123 Main Street",
        "t2_address_2": "Suite 400",
        "t2_mobile_no": "+1234567890",
        "t2_phone_no": "+0987654321",
        "t2_email": "downtown@restaurant.com",
        "t2_1_local_id": "LOC001",
        "t2_1_local_name": "Downtown City",
      },
      "company_details": {
        "t1_company": "COMPANY001",
        "t1_company_name": "Gourmet Foods Inc.",
        "id_company_type": "CT001",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "Outdoor Patio",
      "t3_branch_section_id": "BRANCH002",
      "t2_section_type_id": "BT001",
      "t2_section_type": "Restaurant",
      "image":
          "https://imgs.search.brave.com/z6e9cqo3HozpfbIVnRu3V49KV2DJsl8rIpeB2a7CqgA/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTQ0/NjQ3ODgyNy9waG90/by9hLWNoZWYtaXMt/Y29va2luZy1pbi1o/aXMtcmVzdGF1cmFu/dHMta2l0Y2hlbi5q/cGc_cz02MTJ4NjEy/Jnc9MCZrPTIwJmM9/andLSm1HRXJyTGUy/WHNUV05ZRUV5aU5p/Y3VkWVZBNGo4anZu/VGlKZHA1OD0",
      "branch_details": {
        "t2_company_branch_id": "BR002",
        "t2_company_branch_name": "Uptown Branch",
        "t2_branch_type_id": "BT001",

        "t2_branch_type": "Restaurant",
        "t2_address_1": "456 Uptown Avenue",
        "t2_address_2": "Floor 2",
        "t2_mobile_no": "+1987654321",
        "t2_phone_no": "+1123456789",
        "t2_email": "uptown@restaurant.com",
        "t2_1_local_id": "LOC002",
        "t2_1_local_name": "Uptown City",
      },
      "company_details": {
        "t1_company": "COMPANY001",
        "t1_company_name": "Gourmet Foods Inc.",
        "id_company_type": "CT001",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "VIP Lounge",
      "t3_branch_section_id": "BRANCH003",
      "t2_section_type_id": "BT001",
      "t2_section_type": "Restaurant",
      "image":
          "https://imgs.search.brave.com/OuDOjXRwn05W0oN4lUyqfI4HHQVQVoe3t3KvTQRxnD8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9kMTBt/enozNWJybTJtOC5j/bG91ZGZyb250Lm5l/dC9vdXItbG91bmdl/cy9sYXRlc3QtbG91/bmdlcy9nb2wtc21p/bGVzLWludGVybmF0/aW9uYWwtcmlvLWRl/LWphbmVpcm8tZ2Fs/ZWFvLWludGVybmF0/aW9uYWwtdGVybWlu/YWwtMi03YTMxMDVj/ZS1lM2M0LTQzMjgt/YWQ1My0yYmEzMjQ0/MTc0ODMuanBnP2g9/MjMwJmxhPWVuJnc9/NTAw",
      "branch_details": {
        "t1_company_id": "COMP001",
        "t2_company_branch_id": "BR003",
        "t2_company_branch_name": "City Center Branch",
        "t2_branch_type_id": "BT001",
        "t2_branch_type": "Restaurant",
        "t2_address_1": "789 Central Blvd",
        "t2_address_2": "5th Floor",
        "t2_mobile_no": "+1472583690",
        "t2_phone_no": "+1593574862",
        "t2_email": "citycenter@restaurant.com",
        "t2_1_local_id": "LOC003",
        "t2_1_local_name": "Central City",
      },
      "company_details": {
        "t1_company": "COMPANY001",
        "t1_company_name": "Gourmet Foods Inc.",
        "id_company_type": "CT001",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "Main Hall",
      "t3_branch_section_id": "BRANCH004",
      "t2_section_type_id": "BT002",
      "t2_section_type": "Cafe",
      "image":
          "https://i.pinimg.com/736x/a9/52/49/a9524907a39592c042b36fadb7bec4cd.jpg",
      "branch_details": {
        "t2_company_branch_id": "BR004",
        "t2_company_branch_name": "Lakeside Branch",
        "t2_branch_type_id": "BT002",
        "t2_branch_type": "Cafe",
        "t2_address_1": "321 Lake Street",
        "t2_address_2": "Ground Floor",
        "t2_mobile_no": "+1122334455",
        "t2_phone_no": "+5566778899",
        "t2_email": "lakeside@cafe.com",
        "t2_1_local_id": "LOC004",
        "t2_1_local_name": "Lakeside City",
      },
      "company_details": {
        "t1_company": "COMPANY002",
        "t1_company_name": "Fresh Eats Ltd.",
        "id_company_type": "CT002",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "Garden Area",
      "t3_branch_section_id": "BRANCH005",
      "t2_section_type_id": "BT002",
      "t2_section_type": "Cafe",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnf_B6I4crAiPxjqsHP9XZnCxAgnrLda80uw&s",
      "branch_details": {
        "t2_company_branch_id": "BR005",
        "t2_company_branch_name": "Mountain Branch",
        "t2_branch_type_id": "BT002",
        "t2_branch_type": "Cafe",
        "t2_address_1": "654 Mountain Road",
        "t2_address_2": "Block B",
        "t2_mobile_no": "+1230984567",
        "t2_phone_no": "+3216549870",
        "t2_email": "mountain@cafe.com",
        "t2_1_local_id": "LOC005",
        "t2_1_local_name": "Mountain View",
      },
      "company_details": {
        "t1_company": "COMPANY002",
        "t1_company_name": "Fresh Eats Ltd.",
        "id_company_type": "CT002",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "Roof Terrace",
      "t3_branch_section_id": "BRANCH006",
      "t2_section_type_id": "BT002",
      "t2_section_type": "Cafe",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRT37Ctr9kHNfw2886-c0pak0uHuAMePwGuVA&s",
      "branch_details": {
        "t2_company_branch_id": "BR006",
        "t2_company_branch_name": "Bay Area Branch",
        "t2_branch_type_id": "BT002",
        "t2_branch_type": "Cafe",
        "t2_address_1": "987 Bay Road",
        "t2_address_2": "Penthouse",
        "t2_mobile_no": "+1654321987",
        "t2_phone_no": "+9876541230",
        "t2_email": "bayarea@cafe.com",
        "t2_1_local_id": "LOC006",
        "t2_1_local_name": "Bay City",
      },
      "company_details": {
        "t1_company": "COMPANY002",
        "t1_company_name": "Fresh Eats Ltd.",
        "id_company_type": "CT002",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "Kids Play Zone",
      "t3_branch_section_id": "BRANCH007",
      "t2_section_type_id": "BT003",
      "t2_section_type": "Food Court",
      "image":
          "https://5.imimg.com/data5/SELLER/Default/2021/11/FN/MO/AV/54464302/cafe-shop-cafeteria-interior-design.jpeg",
      "branch_details": {
        "t2_company_branch_id": "BR007",
        "t2_company_branch_name": "Sunset Branch",
        "t2_branch_type_id": "BT003",
        "t2_branch_type": "Food Court",
        "t2_address_1": "111 Sunset Blvd",
        "t2_address_2": "Level 1",
        "t2_mobile_no": "+1777888999",
        "t2_phone_no": "+1666777888",
        "t2_email": "sunset@foodcourt.com",
        "t2_1_local_id": "LOC007",
        "t2_1_local_name": "Sunset Valley",
      },
      "company_details": {
        "t1_company": "COMPANY003",
        "t1_company_name": "Tasty Treats Co.",
        "id_company_type": "CT003",
        "company_type": "Hospitality",
      },
    },
    {
      "t3_section_name": "Self-Service Area",
      "t3_branch_section_id": "BRANCH008",
      "t2_section_type_id": "BT003",
      "t2_section_type": "Food Court",
      "image":
          "https://imgs.search.brave.com/OhOYmR1oeBtR023EfaCKv0QSNXO1YgaMvFEMZoojNB0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTE1/NzMyOTY4OC9waG90/by9jYWZlLXN0b3Jl/LWZhY2FkZS1tb2Nr/dXAuanBnP3M9NjEy/eDYxMiZ3PTAmaz0y/MCZjPS1lYTVzSFFN/TmFTLTNXYnl0cV9w/YXJXMVBPQmJRNnE3/emJTQmZmdWtqMGs9",
      "branch_details": {
        "t2_company_branch_id": "BR008",
        "t2_company_branch_name": "River Branch",
        "t2_branch_type_id": "BT003",
        "t2_branch_type": "Food Court",
        "t2_address_1": "222 River Street",
        "t2_address_2": "Food Zone",
        "t2_mobile_no": "+1555666777",
        "t2_phone_no": "+1222333444",
        "t2_email": "river@foodcourt.com",
        "t2_1_local_id": "LOC008",
        "t2_1_local_name": "River City",
      },
      "company_details": {
        "t1_company": "COMPANY003",
        "t1_company_name": "Tasty Treats Co.",
        "id_company_type": "CT003",
        "company_type": "Hospitality",
      },
    },
  ]; // keep your existing data

  @override
  void initState() {
    super.initState();
    filteredPlaces = List.from(places);
    _searchController.addListener(_filterPlaces);
    loadMenu(); // Load from API
  }

  Future<void> loadMenu() async {
    final url = Uri.parse(
      'http://localhost:5132/api/menu/get-menu',
    ); // your real endpoint
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final items = (jsonData['data']['Items'] as List)
            .map((e) => MenuItem.fromJson(e))
            .toList();

        setState(() {
          menuItems = buildMenuTree(items);
        });
      } else {
        print('Menu fetch failed: ${res.statusCode}');
      }
    } catch (e) {
      print('Menu load error: $e');
    }
  }

  List<MenuItem> buildMenuTree(List<MenuItem> flatList) {
    flatList.sort((a, b) => a.position.compareTo(b.position));
    Map<String, MenuItem> positionMap = {
      for (var item in flatList) item.position: item,
    };

    List<MenuItem> roots = [];

    for (var item in flatList) {
      if (item.position.length == 1) {
        roots.add(item);
      } else {
        final parentPos = item.position.substring(0, item.position.length - 1);
        if (positionMap.containsKey(parentPos)) {
          positionMap[parentPos]!.children = [
            ...positionMap[parentPos]!.children,
            item,
          ];
        }
      }
    }

    return roots;
  }

  void _filterPlaces() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPlaces = places.where((place) {
        final name = place['t3_section_name']!.toLowerCase();
        final type = place['t2_section_type']!.toLowerCase();
        return name.contains(query) || type.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: CustomDrawer(items: menuItems),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Near by Restaurants',
                  style: TextStyle(color: Color(0xFFAAAAAA)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 35,
                width: 35,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("assets/google maps.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Where are you going?',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlaces.length,
              itemBuilder: (context, index) {
                final place = filteredPlaces[index];
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          place['image'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['t3_section_name'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              place['t2_section_type'],
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FeedbackFormScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFCC737),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Give Feedback'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
