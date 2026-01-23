// lib/screens/patient/cart_screen.dart
import 'package:flutter/material.dart';
import 'book_appointment_screen.dart';

class CartScreen extends StatefulWidget {
  final List<dynamic> selectedTests;
  final String patientId;

  const CartScreen({
    Key? key,
    required this.selectedTests,
    required this.patientId,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _calculateTotal() {
    return widget.selectedTests.fold(
      0.0,
          (sum, test) => sum + ((test['price'] as num?)?.toDouble() ?? 0.0),
    );
  }

  int _calculateTotalDuration() {
    return widget.selectedTests.fold(
      0,
          (sum, test) => sum + (test['avg_duration_minutes'] as int? ?? 0),
    );
  }

  void _removeTest(String testId) {
    setState(() {
      widget.selectedTests.removeWhere((test) => test['id'] == testId);
    });

    if (widget.selectedTests.isEmpty) {
      Navigator.pop(context);
    }
  }

  void _proceedToBooking() {
    final testIds = widget.selectedTests
        .map((test) => test['id'] as String)
        .toList();

    // NEW: Pass the complete cart items with all details
    final cartItems = widget.selectedTests.map((test) {
      return {
        'id': test['id'],
        'test_name': test['test_name'] ?? test['name'] ?? 'Unknown Test',
        'name': test['test_name'] ?? test['name'] ?? 'Unknown Test',
        'price': (test['price'] as num?)?.toDouble() ?? 0.0,
        'avg_duration_minutes': test['avg_duration_minutes'] ?? 0,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(
          testIds: testIds,
          patientId: widget.patientId,
          isPackage: false,
          cartItems: cartItems, // NEW: Pass cart items
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final totalDuration = _calculateTotalDuration();

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Selection'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      '${widget.selectedTests.length}',
                      'Tests',
                      Icons.medical_services,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white24,
                    ),
                    _buildSummaryItem(
                      '~$totalDuration min',
                      'Duration',
                      Icons.access_time,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white24,
                    ),
                    _buildSummaryItem(
                      '₹${total.toStringAsFixed(0)}',
                      'Total',
                      Icons.monetization_on,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tests List
          Expanded(
            child: widget.selectedTests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.selectedTests.length,
              itemBuilder: (context, index) {
                final test = widget.selectedTests[index];

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text(
                      test['test_name'] ?? test['name'] ?? 'Unknown Test',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          '${test['avg_duration_minutes'] ?? 0} minutes',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '₹${((test['price'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTest(test['id']),
                    ),
                  ),
                );
              },
            ),
          ),

          // Important Note
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please arrive 15 minutes before your appointment time',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.selectedTests.isEmpty ? null : _proceedToBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}