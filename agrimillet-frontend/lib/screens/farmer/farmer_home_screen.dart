import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../common/chat_screen.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/fade_in_switcher.dart';
import '../../utils/ui_constants.dart';

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
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  FadeInSwitcher(
                    child: NeumorphicCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.accent,
                                child: const Icon(Icons.person, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${authProvider.user?.name}!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${authProvider.user?.district}, ${authProvider.user?.state}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Quick Actions
                  const FadeInSwitcher(
                    delay: Duration(milliseconds: 200),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInSwitcher(
                    delay: const Duration(milliseconds: 300),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
                  ),
                ],
              ),
            ),
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

        return FadeInSwitcher(
          child: ListView.builder(
            itemCount: cropProvider.myCrops.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final crop = cropProvider.myCrops[index];
              return NeumorphicCard(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  title: Text(
                    crop.milletType,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${crop.quantity} kg - ₹${crop.expectedPrice}/kg',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: crop.status == 'available'
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: crop.status == 'available'
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                    ),
                    child: Text(
                      crop.status.toUpperCase(),
                      style: TextStyle(
                        color: crop.status == 'available'
                            ? AppColors.accent
                            : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
    return NeumorphicCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: AppColors.accent),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
