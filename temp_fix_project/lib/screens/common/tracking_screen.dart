import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

class TrackingScreen extends StatefulWidget {
  final String transactionId;

  const TrackingScreen({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    try {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.fetchTransactionDetails(widget.transactionId);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tracking: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transaction = transactionProvider.selectedTransaction;
          if (transaction == null) {
            return const Center(
              child: Text('Transaction not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Delivery Status Timeline
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStatusTimeline(transaction.deliveryStatus),
                    ],
                  ),
                ),

                // Current Status Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getStatusGradient(transaction.deliveryStatus),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(transaction.deliveryStatus),
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(179, 255, 255, 255),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transaction.deliveryStatus.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Details
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Order ID',
                        transaction.id,
                        Icons.assignment,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Crop',
                        transaction.crop?.milletType ?? 'N/A',
                        Icons.agriculture,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Quantity',
                        '${transaction.quantity.toStringAsFixed(2)} kg',
                        Icons.scale,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Total Amount',
                        '₹${transaction.totalAmount.toStringAsFixed(2)}',
                        Icons.currency_rupee,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Farmer Information
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Farmer Name',
                        transaction.farmer?.name ?? 'N/A',
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Mobile',
                        transaction.farmer?.mobileNo ?? 'N/A',
                        Icons.phone,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // GPS Tracking Points
                if (transaction.gpsCoordinates.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location Updates',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transaction.gpsCoordinates.length,
                          itemBuilder: (context, index) {
                            final gps = transaction.gpsCoordinates[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xFF2E7D32),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            gps.address ?? 'Location Update',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF333333),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Lat: ${gps.latitude.toStringAsFixed(4)}, '
                                      'Lng: ${gps.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      gps.timestamp.toString().split('.')[0],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            transaction.deliveryStatus == 'pending'
                                ? 'Farmer will start delivery soon'
                                : 'Location updates will appear as farmer delivers',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Refresh Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _loadTrackingData,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text(
                            'Refresh Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTimeline(String status) {
    final statuses = ['pending', 'in-transit', 'delivered'];
    final statusIcons = {
      'pending': Icons.pending_actions,
      'in-transit': Icons.local_shipping,
      'delivered': Icons.check_circle,
    };
    final statusLabels = {
      'pending': 'Preparing for Delivery',
      'in-transit': 'On the Way',
      'delivered': 'Delivered',
    };

    int currentIndex = statuses.indexOf(status);

    return Column(
      children: [
        ...List.generate(statuses.length, (index) {
          final isCompleted = index <= currentIndex;
          final isCurrentStatus = index == currentIndex;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE0E0E0),
                    ),
                    child: Icon(
                      statusIcons[statuses[index]],
                      color: isCompleted ? Colors.white : Colors.grey[400],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabels[statuses[index]] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrentStatus
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isCompleted
                                ? const Color(0xFF333333)
                                : const Color(0xFF999999),
                          ),
                        ),
                        if (isCompleted)
                          const SizedBox(height: 4),
                        if (isCompleted)
                          Text(
                            isCurrentStatus ? 'In progress' : 'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrentStatus
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF999999),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (index < statuses.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 21, top: 12, bottom: 12),
                  child: Container(
                    width: 2,
                    height: 30,
                    color: isCompleted
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF999999),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  List<Color> _getStatusGradient(String status) {
    switch (status) {
      case 'pending':
        return [const Color(0xFFFFA726), const Color(0xFFFF7043)];
      case 'in-transit':
        return [const Color(0xFF66BB6A), const Color(0xFF43A047)];
      case 'delivered':
        return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
      default:
        return [const Color(0xFF666666), const Color(0xFF424242)];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'in-transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
