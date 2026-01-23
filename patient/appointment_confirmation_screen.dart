// lib/screens/patient/appointment_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AppointmentConfirmationScreen extends StatefulWidget {
  final String appointmentId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final List<Map<String, dynamic>> items;
  final bool isPaid;

  const AppointmentConfirmationScreen({
    Key? key,
    required this.appointmentId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.items,
    this.isPaid = true,
  }) : super(key: key);

  @override
  State<AppointmentConfirmationScreen> createState() =>
      _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState
    extends State<AppointmentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  bool _appointmentSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    );

    _controller.forward();

    // Save appointment items to database
    _saveAppointmentItems().then((_) {
      _processTestQueue();
    });
  }

  Future<void> _saveAppointmentItems() async {
    if (_appointmentSaved) return;

    try {
      print('💾 Saving appointment items for: ${widget.appointmentId}');

      // Update the appointment with items data and payment info
      await supabase.from('appointments').update({
        'booked_items': widget.items,
        'total_amount': widget.amount,
        'payment_method': widget.paymentMethod,
        'transaction_id': widget.transactionId,
        'payment_status': widget.isPaid ? 'paid' : 'pending',
      }).eq('id', widget.appointmentId);

      setState(() {
        _appointmentSaved = true;
      });

      print('✅ Appointment items saved successfully');
    } catch (e) {
      print('❌ Error saving appointment items: $e');
      // Show error but don't block the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note: Appointment details may not be fully saved'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _processTestQueue() async {
    try {
      print('🔄 Processing test queue for appointment: ${widget.appointmentId}');

      await supabase.rpc(
        'complete_current_test_and_move_next',
        params: {
          'p_appointment_id': widget.appointmentId,
        },
      );

      print('✅ Test queue processed successfully');
    } catch (e) {
      print('❌ Error processing test queue: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room assignment pending. Please contact reception.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareReceipt() {
    final String dateStr =
    DateFormat('MMM d, y').format(widget.appointmentDate);
    final String itemsList = widget.items
        .map((item) =>
    '• ${item['name']} - ₹${item['price']?.toStringAsFixed(0) ?? '0'}')
        .join('\n');

    final String message = '''
🏥 *Hospital Appointment Confirmed!*

Here is your digital receipt:
━━━━━━━━━━━━━━━
🆔 *ID:* ${widget.appointmentId.substring(0, 8).toUpperCase()}
📅 *Date:* $dateStr
⏰ *Time:* ${widget.appointmentTime}

📋 *Booked Items:*
$itemsList

━━━━━━━━━━━━━━━
💰 *Total: ₹${widget.amount.toStringAsFixed(0)}*
💳 *Payment:* ${widget.paymentMethod}
${widget.isPaid ? '✅ *Status:* Paid' : '⚠️ *Status:* Pay at Counter'}
━━━━━━━━━━━━━━━

📍 Show this message at the reception.
''';

    Share.share(message,
        subject: 'Appointment Receipt - ${widget.appointmentId.substring(0, 8)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: Icon(Icons.check_rounded,
                            color: Colors.green, size: 48),
                      ),
                    ),
                    SizedBox(height: 16),
                    FadeTransition(
                      opacity: _slideAnimation,
                      child: Text(
                        "Booking Confirmed!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 100 * (1 - _slideAnimation.value)),
                          child: child,
                        );
                      },
                      child: _buildTicketCard(),
                    ),
                    SizedBox(height: 30),
                    FadeTransition(
                      opacity: _slideAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/patient-dashboard',
                                      (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                "Back to Dashboard",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _shareReceipt,
                            icon: Icon(Icons.share_outlined, size: 20),
                            label: Text("Share Receipt"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "APPOINTMENT ID",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              letterSpacing: 1.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.appointmentId.substring(0, 8).toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Confirmed",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_outlined,
                        "Date",
                        DateFormat('MMM d, y').format(widget.appointmentDate),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time_rounded,
                        "Time",
                        widget.appointmentTime,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  "BOOKED ITEMS",
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey, letterSpacing: 1.5),
                ),
                SizedBox(height: 12),
                ...widget.items.map((item) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['type'] == 'package'
                              ? Icons.inventory_2_outlined
                              : Icons.medical_services_outlined,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item['type'] == 'package')
                                Text(
                                  'Package',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item['price']?.toStringAsFixed(0) ?? '0'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (constraints.constrainWidth() / 10).floor(),
                              (index) => SizedBox(
                            width: 5,
                            height: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 20,
                  width: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 20,
                  width: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPaid ? "TOTAL PAID" : "AMOUNT DUE",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              letterSpacing: 1.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "₹${widget.amount.toStringAsFixed(0)}",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("PAYMENT",
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.isPaid
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isPaid
                                    ? Icons.check_circle
                                    : Icons.pending,
                                size: 14,
                                color: widget.isPaid
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.isPaid ? "Paid" : "Pay at Counter",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: widget.isPaid
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.paymentMethod,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!widget.isPaid) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please pay ₹${widget.amount.toStringAsFixed(0)} at the reception desk',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_2_rounded,
                          size: 60, color: Colors.black87),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scan at Reception",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              "Use this QR code for instant check-in at the front desk.",
                              style:
                              TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 2),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}