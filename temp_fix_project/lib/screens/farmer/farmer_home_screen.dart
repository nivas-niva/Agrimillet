import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../common/chat_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({Key? key}) : super(key: key);

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load farmer's crops on init
    Future.delayed(Duration.zero, () {
      Provider.of<CropProvider>(context, listen: false).fetchMyCrops();
    });
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriMillet - Farmer'),
        leading: _currentIndex != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentIndex = 0),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () => Navigator.pushNamed(context, '/voice-assistant'),
            tooltip: 'Voice Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'My Crops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCropsTab();
      case 2:
        return _buildOrdersTab();
      case 3:
        return _buildChatTab();
      default:
        return const Center(child: Text('Home'));
    }
  }

  Widget _buildHomeTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.user?.name}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${authProvider.user?.district}, ${authProvider.user?.state}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionCard(
                    icon: Icons.add_circle,
                    title: 'Upload Crop',
                    onTap: () => Navigator.pushNamed(context, '/upload-crop'),
                  ),
                  _buildActionCard(
                    icon: Icons.list,
                    title: 'My Crops',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _buildActionCard(
                    icon: Icons.shopping_bag,
                    title: 'Orders',
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _buildActionCard(
                    icon: Icons.location_on,
                    title: 'Tracking',
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCropsTab() {
    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        if (cropProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cropProvider.myCrops.isEmpty) {
          return const Center(
            child: Text('No crops uploaded yet'),
          );
        }

        return ListView.builder(
          itemCount: cropProvider.myCrops.length,
          itemBuilder: (context, index) {
            final crop = cropProvider.myCrops[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(crop.milletType),
                subtitle: Text(
                  '${crop.quantity} kg - ₹${crop.expectedPrice}/kg',
                ),
                trailing: Chip(
                  label: Text(crop.status),
                  backgroundColor: crop.status == 'available'
                      ? Colors.green
                      : Colors.grey,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/transaction-history'),
            icon: const Icon(Icons.history),
            label: const Text('View Transaction History'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
            title: const Text('Track Delivery'),
            subtitle: const Text('View real-time GPS tracking'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.pushNamed(context, '/transaction-history'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return const ChatScreen();
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
