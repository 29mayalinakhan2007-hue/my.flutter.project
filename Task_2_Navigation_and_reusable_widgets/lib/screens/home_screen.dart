import 'package:flutter/material.dart';

import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  bool showGrid = true;

  final List<Map<String, dynamic>> products = [
    {
      'title': 'Flutter Course',
      'category': 'Mobile Development',
      'price': '\$49',
      'icon': Icons.flutter_dash,
    },
    {
      'title': 'UI Design',
      'category': 'Design',
      'price': '\$39',
      'icon': Icons.design_services,
    },
    {
      'title': 'Dart Programming',
      'category': 'Programming',
      'price': '\$29',
      'icon': Icons.code,
    },
    {
      'title': 'App Development',
      'category': 'Development',
      'price': '\$59',
      'icon': Icons.phone_android,
    },
    {
      'title': 'Firebase',
      'category': 'Backend',
      'price': '\$45',
      'icon': Icons.cloud,
    },
    {
      'title': 'Git & GitHub',
      'category': 'Tools',
      'price': '\$25',
      'icon': Icons.code,
    },
  ];

  void onBottomNavigationTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 40,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Hello, Student!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Explore our learning products',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showGrid = false;
                        });
                      },
                      icon: Icon(
                        Icons.list,
                        color: !showGrid
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          showGrid = true;
                        });
                      },
                      icon: Icon(
                        Icons.grid_view,
                        color: showGrid
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (showGrid)
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),

                itemCount: products.length,

                itemBuilder: (context, index) {
                  final product = products[index];

                  return ProductCard(
                    title: product['title'],
                    category: product['category'],
                    price: product['price'],
                    icon: product['icon'],
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount: products.length,

                itemBuilder: (context, index) {
                  final product = products[index];

                  return SizedBox(
                    height: 130,

                    child: ProductCard(
                      title: product['title'],
                      category: product['category'],
                      price: product['price'],
                      icon: product['icon'],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,

            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.person,
              size: 65,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Student Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Welcome to your profile',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.notifications,
              color: Colors.blue,
            ),
            title: const Text('Notifications'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {},
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.language,
              color: Colors.blue,
            ),
            title: const Text('Language'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {},
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
            title: const Text('About App'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildHomeContent(),
      buildProfileContent(),
      buildSettingsContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIndex == 0
              ? 'Home'
              : selectedIndex == 1
                  ? 'Profile'
                  : 'Settings',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          if (selectedIndex == 0)
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
              ),
            ),
        ],
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: onBottomNavigationTapped,

        selectedItemColor: Colors.blue,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}