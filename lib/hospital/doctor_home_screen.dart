import 'package:flutter/material.dart';

void main() {
  runApp(const DoctorDashboardApp(userName: '',));
}

class DoctorDashboardApp extends StatelessWidget {
  const DoctorDashboardApp({Key? key, required String userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const DoctorDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Patient Model
class Patient {
  final int id;
  final String name;
  final String time;
  final String test;
  final String room;
  final bool isNew;
  final bool isUrgent;

  Patient({
    required this.id,
    required this.name,
    required this.time,
    required this.test,
    required this.room,
    required this.isNew,
    required this.isUrgent,
  });
}

// Notification Model
class NotificationItem {
  final int id;
  final String text;
  final String time;
  final String type;

  NotificationItem({
    required this.id,
    required this.text,
    required this.time,
    required this.type,
  });
}

// Referral Data Model
class ReferralData {
  final String month;
  final int count;

  ReferralData({required this.month, required this.count});
}

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _activeTab = 0;
  String _searchQuery = '';
  bool _showNotifications = false;
  String _calendarView = 'schedule';
  DateTime _selectedDate = DateTime.now();
  final Map<int, bool> _consultStarted = {};
  final Map<int, bool> _videoJoined = {};

  // Mock Data
  final List<Patient> todayPatients = [
    Patient(id: 1, name: 'Anya Sharma', time: '9:00 AM', test: 'Test Results Review', room: '101', isNew: true, isUrgent: false),
    Patient(id: 2, name: 'David Chen', time: '9:20 AM', test: 'Follow-up - Diabetes', room: 'Video', isNew: false, isUrgent: false),
    Patient(id: 3, name: 'Emily Davis', time: '9:40 AM', test: 'New Complaint: Chest Pain', room: '102', isNew: false, isUrgent: true),
    Patient(id: 4, name: 'James Wilson', time: '10:00 AM', test: 'Annual Physical Checkup', room: '103', isNew: true, isUrgent: false),
    Patient(id: 5, name: 'Sophia Lee', time: '10:20 AM', test: 'Post-Surgery Check', room: '101', isNew: false, isUrgent: false),
    Patient(id: 6, name: 'Rahul Kumar', time: '10:40 AM', test: 'Lab Review - High Cholesterol', room: 'Video', isNew: false, isUrgent: false),
    Patient(id: 7, name: 'Priya Joshi', time: '11:00 AM', test: 'Referral for Pain Management', room: '102', isNew: true, isUrgent: false),
  ];

  final List<NotificationItem> notifications = [
    NotificationItem(id: 1, text: 'Emily Davis marked as URGENT', time: '5 mins ago', type: 'urgent'),
    NotificationItem(id: 2, text: 'Lab results ready for Anya Sharma', time: '15 mins ago', type: 'info'),
    NotificationItem(id: 3, text: 'New patient registration: James Wilson', time: '1 hour ago', type: 'new'),
  ];

  final List<ReferralData> referralData = [
    ReferralData(month: 'Jan', count: 40),
    ReferralData(month: 'Feb', count: 55),
    ReferralData(month: 'Mar', count: 65),
    ReferralData(month: 'Apr', count: 70),
  ];

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Search'),
          content: Text('Searching for: $query\n\nIn a real app, this would search through:\n- Patient records\n- Appointments\n- Medical history\n- Test results'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _startConsult(int patientId, String patientName) {
    setState(() {
      _consultStarted[patientId] = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Starting consultation with $patientName'),
        content: const Text('Opening patient records:\n✓ Medical History\n✓ Recent Lab Results\n✓ Prescriptions\n✓ Notes from previous visits'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _joinVideo(int patientId, String patientName) {
    setState(() {
      _videoJoined[patientId] = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Joining video call with $patientName'),
        content: const Text('📹 Initializing secure video connection...\n✓ Camera: ON\n✓ Microphone: ON\n✓ Connection: Encrypted\n\nCall would start in a real app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleDateSelect(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Selected'),
        content: Text('Viewing appointments for ${_formatDate(date)}\n\nIn a real app, this would load:\n- Scheduled appointments\n- Blocked time slots\n- Available slots'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAvailabilityModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Office Hours', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('9:00 AM to 5:00 PM'),
            const SizedBox(height: 16),
            const Text('Working Days', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Chip(label: Text(day)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Availability settings saved!')),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showCredentialsModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCredentialItem('Medical License', 'MD #12345-CA', 'Valid until: Dec 2025'),
            const Divider(),
            _buildCredentialItem('Board Certification', 'FACC - Cardiology', 'Valid until: Dec 2026'),
            const Divider(),
            _buildCredentialItem('DEA Registration', 'DEA #AB1234567', 'Valid until: Aug 2025'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialItem(String title, String value, String validity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(validity, style: const TextStyle(fontSize: 12, color: Colors.green)),
      ],
    );
  }

  void _showSettingsModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Communication Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSwitchTile('Email Notifications', true),
            _buildSwitchTile('SMS Alerts', true),
            _buildSwitchTile('Patient Messages', true),
            _buildSwitchTile('Urgent Alerts', true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved successfully!')),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (val) {},
      contentPadding: EdgeInsets.zero,
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Logging out...'),
                  content: Text('✓ Saving session data\n✓ Clearing secure credentials\n✓ Closing active connections\n\nYou would be redirected to login screen.'),
                ),
              );
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dr. Sarah Johnson', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  setState(() {
                    _showNotifications = !_showNotifications;
                  });
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${notifications.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                _activeTab = 2;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showNotifications) _buildNotificationsPanel(),
          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                _buildHomeTab(),
                _buildCalendarTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeTab,
        onTap: (index) {
          setState(() {
            _activeTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...notifications.map((notif) => _buildNotificationItem(notif)).toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notif) {
    Color color = notif.type == 'urgent' ? Colors.red : (notif.type == 'new' ? Colors.green : Colors.blue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.text, style: const TextStyle(fontSize: 14)),
                Text(notif.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Bar
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Global Patient Search',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: _handleSearch,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => _handleSearch(_searchQuery),
                    child: const Text('Search'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Today\'s Schedule', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...todayPatients.map((patient) => _buildPatientCard(patient)).toList(),
      ],
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(patient.time, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
                if (patient.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(patient.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                if (patient.isNew)
                  const Text(' (New Patient)', style: TextStyle(color: Colors.orange, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(patient.test, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: patient.room == 'Video' ? Colors.green[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    patient.room == 'Video' ? '🎥 Video Call' : 'Room: ${patient.room}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                patient.room == 'Video'
                    ? ElevatedButton.icon(
                  onPressed: () => _joinVideo(patient.id, patient.name),
                  icon: const Icon(Icons.videocam, size: 18),
                  label: Text(_videoJoined[patient.id] == true ? 'In Call' : 'Join Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _videoJoined[patient.id] == true ? Colors.green[700] : Colors.green,
                  ),
                )
                    : OutlinedButton(
                  onPressed: () => _startConsult(patient.id, patient.name),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _consultStarted[patient.id] == true ? Colors.green : Colors.blue, width: 2),
                    backgroundColor: _consultStarted[patient.id] == true ? Colors.green[50] : null,
                  ),
                  child: Text(_consultStarted[patient.id] == true ? '✓ In Progress' : 'Start Consult'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _calendarView = 'schedule';
                  });
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _calendarView == 'schedule' ? Colors.blue : Colors.grey[300],
                  foregroundColor: _calendarView == 'schedule' ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _calendarView = 'referral';
                  });
                },
                icon: const Icon(Icons.people),
                label: const Text('Referral'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _calendarView == 'referral' ? Colors.blue : Colors.grey[300],
                  foregroundColor: _calendarView == 'referral' ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_calendarView == 'schedule') _buildScheduleView() else _buildReferralView(),
      ],
    );
  }

  Widget _buildScheduleView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('December 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    int day = index + 1;
                    bool isToday = day == DateTime.now().day;
                    bool isSelected = day == _selectedDate.day;
                    return InkWell(
                      onTap: () => _handleDateSelect(DateTime(2024, 12, day)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue : (isSelected ? Colors.blue[100] : null),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isToday ? Colors.white : (isSelected ? Colors.blue : Colors.black),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Appointments for ${_formatDate(_selectedDate)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_selectedDate.day == DateTime.now().day)
          ...todayPatients.take(3).map((patient) => _buildCompactPatientCard(patient)).toList()
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No appointments scheduled for this day.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(patient.time, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(patient.test, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: patient.room == 'Video' ? Colors.green[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(patient.room, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildReferralView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Referral Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patients Referred (Monthly)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: referralData.map((data) {
                      double height = (data.count / 75) * 180;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${data.count}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: height,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(data.month, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '*This chart shows the monthly count of patients referred to you by other providers or through promotional campaigns.',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, size: 48, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text('Dr. Sarah Johnson', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Cardiologist | MD, FACC', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 32),
        _buildProfileOption(
          Icons.access_time,
          'Manage Availability',
          'Set office hours and vacation days.',
          'Edit',
          _showAvailabilityModal,
        ),
        _buildProfileOption(
          Icons.description,
          'My Credentials',
          'View and update licenses and certifications.',
          'View',
          _showCredentialsModal,
        ),
        _buildProfileOption(
          Icons.mail,
          'Communication Settings',
          'Customize patient messaging and alert preferences.',
          'Configure',
          _showSettingsModal,
        ),
        const Divider(height: 32),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red, size: 30),
            title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
            subtitle: const Text('Securely sign out of the application.'),
            trailing: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, String buttonText, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[100],
            foregroundColor: Colors.blue[700],
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }
}