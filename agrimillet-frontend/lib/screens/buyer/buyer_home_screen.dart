import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../common/chat_screen.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/fade_in_switcher.dart';
import '../../utils/ui_constants.dart';
import 'dart:ui';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentIndex = 0;
  String _selectedMarket = 'state';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<CropProvider>(context, listen: false)
          .fetchMarketplaceCrops(market: _selectedMarket);
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
        title: const Text('AgriMillet - Buyer'),
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
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Purchases',
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
        return _buildMarketplaceTab();
      case 2:
        return _buildPurchasesTab();
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
              padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
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
              const FadeInSwitcher(
                delay: Duration(milliseconds: 200),
                child: Text(
                  'Browse Millets',
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
                    child: _buildMarketCards(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketCards() {
    return Row(
      children: [
        Expanded(
          child: NeumorphicCard(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                setState(() => _selectedMarket = 'state');
                setState(() => _currentIndex = 1);
              },
              child: const Column(
                children: [
                  Icon(Icons.map, size: 20, color: AppColors.accent),
                  const SizedBox(height: 4),
                  const Text(
                    'State Market',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeumorphicCard(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                setState(() => _selectedMarket = 'national');
                setState(() => _currentIndex = 1);
              },
              child: const Column(
                children: [
                  Icon(Icons.public, size: 20, color: AppColors.accent),
                  const SizedBox(height: 4),
                  const Text(
                    'National Market',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'state',
                      label: Text('State'),
                    ),
                    ButtonSegment(
                      value: 'national',
                      label: Text('National'),
                    ),
                  ],
                  selected: {_selectedMarket},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _selectedMarket = newSelection.first);
                    Provider.of<CropProvider>(context, listen: false)
                        .fetchMarketplaceCrops(market: _selectedMarket);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<CropProvider>(
            builder: (context, cropProvider, _) {
              if (cropProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (cropProvider.crops.isEmpty) {
                return const Center(
                  child: Text('No crops available'),
                );
              }

              return ListView.builder(
                itemCount: cropProvider.crops.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, index) {
                  final crop = cropProvider.crops[index];
                  return FadeInSwitcher(
                    delay: Duration(milliseconds: index * 50),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: AppDecorations.glass(borderRadius: 20),
                      clipBehavior: Clip.antiAlias,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            crop.milletType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Available: ${crop.quantity} kg',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (crop.governmentPrice != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Gov: ₹${crop.governmentPrice}/kg',
                                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${crop.expectedPrice}/kg',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/crop-details', arguments: crop.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(60, 30),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Purchases',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/transaction-history'),
            icon: const Icon(Icons.history),
            label: const Text('View Purchase History'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
            title: const Text('Track Order'),
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
}
