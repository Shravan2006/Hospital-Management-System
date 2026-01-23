import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'appointment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String appointmentId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final double amount;
  final List<Map<String, dynamic>> items;

  const PaymentScreen({
    super.key,
    required this.appointmentId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.amount,
    required this.items,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  String selectedPaymentMethod = 'upi';
  final upiController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderController = TextEditingController();

  bool isProcessing = false;
  bool showSuccess = false;
  late AnimationController _successController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and animation immediately
    _successController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800)
    );
    _scaleAnim = CurvedAnimation(
        parent: _successController,
        curve: Curves.elasticOut
    );
  }

  @override
  void dispose() {
    upiController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    cardHolderController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    String paymentMethodName;
    String transactionId;

    // VALIDATION
    if (selectedPaymentMethod == 'upi') {
      if (upiController.text.trim().toLowerCase() != 'success@razorpay') {
        _showError('Test Mode: Use success@razorpay');
        return;
      }
      paymentMethodName = 'UPI';
      transactionId = 'UPI-${DateTime.now().millisecondsSinceEpoch}';
    } else {
      if (cardNumberController.text.replaceAll(' ', '').length < 16) {
        _showError('Invalid Card Number');
        return;
      }
      paymentMethodName = 'Credit Card';
      transactionId = 'CARD-${DateTime.now().millisecondsSinceEpoch}';
    }

    // SUCCESS - Update state first, then start animation
    setState(() {
      isProcessing = false;
      showSuccess = true;
    });

    // Start the animation after state is updated
    _successController.forward();

    // DELAY & NAVIGATE
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentConfirmationScreen(
          appointmentId: widget.appointmentId,
          appointmentDate: widget.appointmentDate,
          appointmentTime: widget.appointmentTime,
          amount: widget.amount,
          paymentMethod: paymentMethodName,
          transactionId: transactionId,
          items: widget.items,
          isPaid: true,
        ),
      ),
    );
  }

  void _showError(String msg) {
    setState(() => isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showSuccess) return _buildSuccessUI();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Secure Checkout', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOTAL AMOUNT CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade600]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Text('Total to Pay', style: TextStyle(color: Colors.blue.shade100, fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    '₹${widget.amount.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.items.length} ${widget.items.length == 1 ? "Item" : "Items"}',
                    style: TextStyle(color: Colors.blue.shade100, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Text('Test Mode Active', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // BOOKING SUMMARY
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Booking Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...widget.items.map((item) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            item['type'] == 'package' ? Icons.inventory_2 : Icons.local_hospital,
                            size: 16,
                            color: Colors.blue.shade300,
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
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '₹${widget.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 16),

            // METHOD SELECTOR
            Row(
              children: [
                Expanded(child: _buildMethodTab('upi', 'UPI / VPA', Icons.qr_code_2)),
                SizedBox(width: 16),
                Expanded(child: _buildMethodTab('card', 'Credit/Debit', Icons.credit_card)),
              ],
            ),

            SizedBox(height: 30),

            // FORM AREA
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: selectedPaymentMethod == 'upi'
                  ? _buildUPIForm()
                  : _buildCardForm(),
            ),

            SizedBox(height: 30),

            // TEST CREDENTIALS HINT
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade800),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Test Credentials:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                        Text(
                          selectedPaymentMethod == 'upi'
                              ? 'ID: success@razorpay'
                              : 'Card: 4111 1111 1111 1111',
                          style: TextStyle(fontFamily: 'Courier', color: Colors.black87),
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

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isProcessing
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 18),
                SizedBox(width: 8),
                Text('Pay Securely', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTab(String id, String label, IconData icon) {
    bool isSelected = selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = id),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 28),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue.shade900 : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildUPIForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter UPI ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        TextField(
          controller: upiController,
          decoration: InputDecoration(
            hintText: 'e.g., success@razorpay',
            prefixIcon: Icon(Icons.alternate_email, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        // Credit Card Visual
        Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.grey.shade800, Colors.black]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Icon(Icons.nfc, color: Colors.white54),
                Icon(Icons.credit_card, color: Colors.white),
              ]),
              SizedBox(height: 20),
              Text('4111  1111  1111  1111', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Courier', letterSpacing: 2)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CARD HOLDER', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('EXPIRY', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('CVV', style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DEMO USER', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text('12/28', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text('603', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        // Fields
        TextField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [LengthLimitingTextInputFormatter(16), FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Card Number',
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryController,
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: cvvController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(3)],
                decoration: InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 24),
              const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Redirecting to your ticket...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}