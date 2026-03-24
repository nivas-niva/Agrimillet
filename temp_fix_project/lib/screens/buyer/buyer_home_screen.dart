import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../common/chat_screen.dart';

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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Browse Millets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMarketCards(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                setState(() => _selectedMarket = 'state');
                setState(() => _currentIndex = 1);
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.map, size: 40, color: Color(0xFF2E7D32)),
                    SizedBox(height: 8),
                    Text('State Market'),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                setState(() => _selectedMarket = 'national');
                setState(() => _currentIndex = 1);
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.public, size: 40, color: Color(0xFF2E7D32)),
                    SizedBox(height: 8),
                    Text('National Market'),
                  ],
                ),
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
                itemBuilder: (context, index) {
                  final crop = cropProvider.crops[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(crop.milletType),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available: ${crop.quantity} kg'),
                          Row(
                            children: [
                              if (crop.governmentPrice != null)
                                Text(
                                  'Gov: ₹${crop.governmentPrice}/kg',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                'Ask: ₹${crop.expectedPrice}/kg',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
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
                        child: const Text('View'),
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
