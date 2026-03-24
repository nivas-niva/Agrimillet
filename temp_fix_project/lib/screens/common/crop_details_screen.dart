import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/crop.dart';
import '../../providers/crop_provider.dart';

class CropDetailsScreen extends StatefulWidget {
  final String cropId;

  const CropDetailsScreen({
    Key? key,
    required this.cropId,
  }) : super(key: key);

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCropDetails();
  }

  Future<void> _loadCropDetails() async {
    try {
      final cropProvider = Provider.of<CropProvider>(context, listen: false);
      await cropProvider.fetchCropDetails(widget.cropId);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading crop: $error')),
        );
      }
    }
  }

  Future<void> _purchaseCrop(Crop crop) async {
    // Navigate to payment screen
    Navigator.of(context).pushNamed(
      '/payment',
      arguments: {
        'cropId': crop.id,
        'quantity': crop.quantity,
        'price': crop.expectedPrice,
        'farmerName': crop.farmerInfo?.name ?? 'Unknown Farmer',
        'milletType': crop.milletType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Details'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Consumer<CropProvider>(
        builder: (context, cropProvider, _) {
          if (cropProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final crop = cropProvider.selectedCrop;
          if (crop == null) {
            return const Center(
              child: Text('Crop not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                if (crop.images != null && crop.images!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[200],
                    child: PageView.builder(
                      itemCount: crop.images!.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          crop.images![index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            );
                          },
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),

                // Crop Information Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with type and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop.milletType,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: crop.status == 'available'
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  crop.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: crop.status == 'available'
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              crop.market == 'state' ? '📍 State Market' : '🌍 National Market',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price Comparison Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Comparison',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Government Price',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                      Text(
                                        crop.governmentPrice != null
                                            ? '₹${crop.governmentPrice!.toStringAsFixed(2)}/kg'
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                  ],
                                ),
                                const Icon(
                                  Icons.compare_arrows,
                                  color: Color(0xFF999999),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Farmer\'s Price',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${crop.expectedPrice.toStringAsFixed(2)}/kg',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: crop.governmentPrice == null ||
                                                crop.expectedPrice >= crop.governmentPrice!
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFC62828),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              crop.governmentPrice == null ||
                                      crop.expectedPrice >= crop.governmentPrice!
                                  ? '✓ Price is above government rate'
                                  : '⚠ Price is below government rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: crop.governmentPrice == null ||
                                        crop.expectedPrice >= crop.governmentPrice!
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Crop Details Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildDetailCard(
                            'Quantity',
                            '${crop.quantity.toStringAsFixed(0)} kg',
                            Icons.scale,
                          ),
                          _buildDetailCard(
                            'Harvest Date',
                            crop.harvestDate.toString().split(' ')[0],
                            Icons.calendar_today,
                          ),
                          _buildDetailCard(
                            'Total Value',
                            '₹${(crop.quantity * crop.expectedPrice).toStringAsFixed(0)}',
                            Icons.currency_rupee,
                          ),
                          _buildDetailCard(
                            'Cost per Unit',
                            '₹${crop.expectedPrice.toStringAsFixed(2)}',
                            Icons.price_check,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Farmer Information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Farmer Information',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Farmer Name',
                              crop.farmerInfo?.name ?? 'Unknown Farmer',
                              Icons.person,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Location',
                              '${crop.farmerInfo?.district ?? 'N/A'}, ${crop.farmerInfo?.state ?? 'N/A'}',
                              Icons.location_on,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Purchase Button (for buyers)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: crop.status == 'available'
                              ? () => _purchaseCrop(crop)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            crop.status == 'available'
                                ? 'Purchase Crop'
                                : '${crop.status.toUpperCase()} - Not Available',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
