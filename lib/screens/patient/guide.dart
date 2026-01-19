import 'package:flutter/material.dart';

class GuideScreen extends StatefulWidget {
  final String appointmentDate;
  final String appointmentTime;
  final String doctorName;

  const GuideScreen({
    super.key,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.doctorName,
  });

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  // Track completion status of each step
  final Map<int, bool> _completedSteps = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Arrive 15 minutes early',
      'description': 'Make sure to reach the hospital/clinic at least 15 minutes before your scheduled time.',
      'icon': Icons.access_time,
    },
    {
      'title': 'Carry ID & appointment confirmation',
      'description': 'Bring a valid government ID and your appointment confirmation (SMS or email).',
      'icon': Icons.badge,
    },
    {
      'title': 'Go to Room 101 for Blood Test',
      'description': 'Visit the room for your test. Best wishes!',
      'icon': Icons.how_to_reg,
    },
    {
      'title': 'Wait in the waiting room in A100 at ground floor',
      'description': 'Take a seat in the waiting area. Your name will be called when the report is ready.',
      'icon': Icons.event_seat,
    },
    {
      'title': 'Consult with the doctor',
      'description': 'Discuss your health concerns with the doctor and follow their advice.',
      'icon': Icons.medical_services,
    },
  ];

  int get _completedCount {
    return _completedSteps.values.where((completed) => completed).length;
  }

  double get _progressPercentage {
    return _completedCount / _steps.length;
  }

  void _toggleStep(int step) {
    setState(() {
      _completedSteps[step] = !_completedSteps[step]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Guide"),
        backgroundColor: Colors.blue,
        actions: [
          if (_completedCount == _steps.length)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.celebration, color: Colors.amber),
            ),
        ],
      ),
      body: Column(
        children: [
          // Appointment Details Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your Appointment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.person, "Doctor", widget.doctorName),
                SizedBox(height: 8),
                _buildInfoRow(Icons.event, "Date", widget.appointmentDate),
                SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, "Time", widget.appointmentTime),
              ],
            ),
          ),

          // Progress Indicator
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '$_completedCount/${_steps.length} completed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressPercentage,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _completedCount == _steps.length
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
                if (_completedCount == _steps.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'All steps completed! 🎉',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Steps List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final stepNumber = index + 1;
                final step = _steps[index];
                final isCompleted = _completedSteps[stepNumber]!;

                return _buildGuideStep(
                  stepNumber,
                  step['title'],
                  step['description'],
                  step['icon'],
                  isCompleted,
                );
              },
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
          child: ElevatedButton.icon(
            onPressed: _completedCount == _steps.length
                ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Congratulations!'),
                    ],
                  ),
                  content: Text(
                    'You have completed all the steps. Have a great consultation with ${widget.doctorName}!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
                : null,
            icon: Icon(Icons.check_circle_outline),
            label: Text(
              _completedCount == _steps.length
                  ? 'All Steps Completed!'
                  : 'Complete all steps to proceed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _completedCount == _steps.length ? Colors.green : Colors.grey,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideStep(
      int step,
      String title,
      String description,
      IconData icon,
      bool isCompleted,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleStep(step),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Number or Checkbox
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 28)
                      : Text(
                    step.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Step Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isCompleted ? Colors.green : Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isCompleted ? Colors.grey : Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkbox
              Checkbox(
                value: isCompleted,
                onChanged: (value) => _toggleStep(step),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}