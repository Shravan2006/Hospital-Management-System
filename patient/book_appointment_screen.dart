// lib/screens/patient/book_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/screens/services/cart_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_method_selection_screen.dart';
import 'dart:math';

final supabase = Supabase.instance.client;

class BookAppointmentScreen extends StatefulWidget {
  final List<String> testIds;
  final String patientId;
  final bool isPackage;
  final String? packageId;
  final List<Map<String, dynamic>>? cartItems; // NEW: Pass cart items directly

  const BookAppointmentScreen({
    Key? key,
    required this.testIds,
    required this.patientId,
    this.isPackage = false,
    this.packageId,
    this.cartItems, // NEW: Optional cart items
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  final instructionsController = TextEditingController();
  bool isBooking = false;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> items = [];

  final List<String> timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadTestDetails();
  }

  @override
  void dispose() {
    instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadTestDetails() async {
    try {
      // NEW: If cart items are provided, use them directly
      if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
        double amount = 0.0;
        List<Map<String, dynamic>> testItems = [];

        for (var cartItem in widget.cartItems!) {
          double price = (cartItem['price'] as num?)?.toDouble() ?? 0.0;
          amount += price;
          testItems.add({
            'name': cartItem['test_name'] ?? cartItem['name'] ?? 'Unknown Test',
            'price': price,
            'type': 'test',
          });
        }

        setState(() {
          totalAmount = amount;
          items = testItems;
        });
        return;
      }

      // Existing package logic
      if (widget.isPackage && widget.packageId != null) {
        final packageResponse = await supabase
            .from('packages')
            .select('package_name, price')
            .eq('id', widget.packageId!)
            .single();

        setState(() {
          totalAmount = (packageResponse['price'] as num).toDouble();
          items = [
            {
              'name': packageResponse['package_name'],
              'price': totalAmount,
              'type': 'package',
            }
          ];
        });
      } else {
        // Fetch test details from database
        final testsResponse = await supabase
            .from('tests')
            .select('test_name, price')
            .inFilter('id', widget.testIds);

        double amount = 0.0;
        List<Map<String, dynamic>> testItems = [];

        for (var test in testsResponse) {
          double price = (test['price'] as num).toDouble();
          amount += price;
          testItems.add({
            'name': test['test_name'],
            'price': price,
            'type': 'test',
          });
        }

        setState(() {
          totalAmount = amount;
          items = testItems;
        });
      }
    } catch (e) {
      print('Error loading details: $e');
      // Show error message instead of using demo data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading test details. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _bookAppointment() async {
    if (selectedDate == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (items.isEmpty || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No items to book'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isBooking = true);

    await Future.delayed(Duration(seconds: 1));

    try {
      print('🩵 Preparing Booking...');
      print('Total Amount: ₹$totalAmount');
      print('Items: ${items.length}');

      final random = Random();
      final mockId = 'APT-${random.nextInt(90000) + 10000}';

      if (mounted) {
        context.read<CartService>().clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentMethodSelectionScreen(
              appointmentDate: selectedDate!,
              appointmentTime: selectedTimeSlot!,
              amount: totalAmount,
              items: items,
              appointmentId: mockId,
              testIds: widget.testIds,
              patientId: widget.patientId,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date & Time'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Your Appointment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose your preferred date and time',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        if (totalAmount > 0) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Total: ₹${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Items Summary
            if (items.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services,
                            color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Booking Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              item['type'] == 'package'
                                  ? Icons.inventory_2
                                  : Icons.local_hospital,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['name'] ?? 'Unknown',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '₹${item['price']?.toStringAsFixed(0) ?? '0'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            Text('Select Date',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
            SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Choose a date'
                              : DateFormat('EEEE, MMMM d, y')
                              .format(selectedDate!),
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDate == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text('Select Time Slot',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                final isSelected = selectedTimeSlot == timeSlot;
                return InkWell(
                  onTap: () => setState(() => selectedTimeSlot = timeSlot),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Text('Special Instructions (Optional)',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
            SizedBox(height: 12),
            TextField(
              controller: instructionsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any special requirements or notes...',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoItem('Please arrive 15 minutes before appointment'),
                  _buildInfoItem('Bring a valid ID proof'),
                  _buildInfoItem('Fasting required for some blood tests'),
                ],
              ),
            ),
          ],
        ),
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
            )
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: isBooking ? null : _bookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: isBooking
                ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : Text('Continue to Payment',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
        ],
      ),
    );
  }
}