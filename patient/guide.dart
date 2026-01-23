import 'package:flutter/material.dart';
import 'dart:math';

class HospitalGuideScreen extends StatefulWidget {
  final String appointmentDate;
  final String appointmentTime;
  final String doctorName;

  const HospitalGuideScreen({
    super.key,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.doctorName,
  });

  @override
  State<HospitalGuideScreen> createState() => _HospitalGuideScreenState();
}

class _HospitalGuideScreenState extends State<HospitalGuideScreen> {
  // Map bounds in meters (realistic hospital floor)
  final double mapWidthMeters = 60.0;
  final double mapHeightMeters = 80.0;

  /// Room positions on the floor plan
  final Map<String, Offset> roomNormalizedPositions = const {
    'ENTRANCE': Offset(0.20, 0.95),
    'Room 1': Offset(0.20, 0.80),
    'Room 4': Offset(0.20, 0.65),
    'Room 5': Offset(0.20, 0.50),
    'Room 3': Offset(0.20, 0.35),
    'Room 2': Offset(0.20, 0.15),
    'Room 8': Offset(0.40, 0.80),
    'Room 9': Offset(0.55, 0.80),
    'Reception': Offset(0.48, 0.50),
    'Room 16': Offset(0.35, 0.50),
    'Room 7': Offset(0.48, 0.50),
    'Room 17': Offset(0.58, 0.38),
    'Room 18': Offset(0.68, 0.38),
    'Room 6': Offset(0.35, 0.15),
    'Room 10': Offset(0.48, 0.15),
    'Room 15': Offset(0.68, 0.15),
    'Room 20': Offset(0.82, 0.80),
    'Room 19': Offset(0.82, 0.38),
    'Room 14': Offset(0.82, 0.15),
  };

  // Sample patient tests (3 different rooms)
  late List<String> patientTests;
  late List<String> allocatedRooms;
  int currentRoomIndex = 0;
  bool testsCompleted = false;

  final TransformationController _transformationController = TransformationController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Simulate 3 randomly allocated test rooms for patient
    _initializePatientTests();
  }

  void _initializePatientTests() {
    // Available test rooms (excluding entrance/reception)
    final testRooms = [
      'Room 1', 'Room 2', 'Room 3', 'Room 4', 'Room 5', 'Room 6', 'Room 8', 'Room 9',
      'Room 10', 'Room 14', 'Room 15', 'Room 16', 'Room 17', 'Room 18', 'Room 19', 'Room 20'
    ];

    // Randomly select 3 different rooms - FIXED: Use temp list instead of accessing uninitialized allocatedRooms
    final List<String> tempRooms = [];
    while (tempRooms.length < 3) {
      final randomIndex = _random.nextInt(testRooms.length);
      final room = testRooms[randomIndex];
      if (!tempRooms.contains(room)) {
        tempRooms.add(room);
      }
    }

    allocatedRooms = tempRooms;

    // Shuffle for random first room
    allocatedRooms.shuffle();
    patientTests = ['Blood Test', 'X-Ray', 'ECG']; // Sample tests
    currentRoomIndex = 0;
    testsCompleted = false;
  }

  String get currentRoom => allocatedRooms[currentRoomIndex];
  bool get hasNextRoom => currentRoomIndex < allocatedRooms.length - 1;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  List<Offset> _generateNavigationPath(String fromRoom, String toRoom) {
    final fromPos = roomNormalizedPositions[fromRoom]!;
    final toPos = roomNormalizedPositions[toRoom]!;

    // Define corridor zones (green areas only)
    const double leftX = 0.175;   // Left corridor center
    const double centerX = 0.48;  // Center junction x
    const double rightX = 0.825;  // Right corridor center
    const double hCorridorY = 0.53;  // Horizontal corridor center
    const double leftJuncY = 0.55;

    List<Offset> path = [fromPos];

    // Determine column for from/to rooms
    String fromCol = _getRoomColumn(fromPos.dx);
    String toCol = _getRoomColumn(toPos.dx);

    // Route via appropriate junction
    if (fromCol == 'left') {
      path.add(Offset(leftX, fromPos.dy));  // Vertical in left corridor
      path.add(Offset(leftX, leftJuncY));   // To left junction
      if (toCol == 'left') {
        path.add(Offset(leftX, toPos.dy));  // Vertical to target
      } else {
        path.add(Offset(centerX, leftJuncY));  // To center junction via horizontal
        if (toCol == 'center') {
          path.add(Offset(centerX, toPos.dy));
        } else {
          path.add(Offset(rightX, hCorridorY));  // To right via horizontal
          path.add(Offset(rightX, toPos.dy));    // Vertical in right
        }
      }
    } else if (fromCol == 'center') {
      // From center: direct horizontal + vertical
      path.add(Offset(centerX, fromPos.dy));
      if (toCol == 'left') {
        path.add(Offset(leftX, hCorridorY));
        path.add(Offset(leftX, toPos.dy));
      } else {
        path.add(Offset(rightX, hCorridorY));
        path.add(Offset(rightX, toPos.dy));
      }
    } else {  // from right
      path.add(Offset(rightX, fromPos.dy));
      path.add(Offset(rightX, hCorridorY));
      if (toCol == 'right') {
        path.add(Offset(rightX, toPos.dy));
      } else {
        path.add(Offset(centerX, hCorridorY));
        if (toCol == 'left') {
          path.add(Offset(leftX, leftJuncY));
          path.add(Offset(leftX, toPos.dy));
        } else {
          path.add(Offset(centerX, toPos.dy));
        }
      }
    }

    path.add(toPos);  // Ensure ends at exact target
    return _smoothPath(path);  // Optional: interpolate for smoothness
  }

// Helper to classify room column by x-position
  String _getRoomColumn(double x) {
    if (x < 0.30) return 'left';
    if (x < 0.60) return 'center';
    return 'right';
  }

// Smooth path with straight lines only in corridors
  List<Offset> _smoothPath(List<Offset> points) {
    // Remove redundant points, keep only turns in corridors
    List<Offset> smoothed = [points.first];
    for (int i = 1; i < points.length - 1; i++) {
      if (!_collinear(smoothed.last, points[i], points[i+1])) {
        smoothed.add(points[i]);
      }
    }
    smoothed.add(points.last);
    return smoothed;
  }

  bool _collinear(Offset a, Offset b, Offset c) {
    return ((b.dy - a.dy) * (c.dx - b.dx) == (b.dx - a.dx) * (c.dy - b.dy));
  }

  double _calculateDistance(Offset from, Offset to) {
    double dx = (to.dx - from.dx) * mapWidthMeters;
    double dy = (to.dy - from.dy) * mapHeightMeters;
    return sqrt(dx * dx + dy * dy);
  }

  List<Map<String, dynamic>> _getStepByStepDirections() {
    String fromRoom = currentRoomIndex == 0 ? 'ENTRANCE' : allocatedRooms[currentRoomIndex - 1];
    final path = _generateNavigationPath(fromRoom, currentRoom);

    List<Map<String, dynamic>> steps = [];

    for (int i = 0; i < path.length - 1; i++) {
      final from = path[i];
      final to = path[i + 1];
      final distance = _calculateDistance(from, to);

      double dx = to.dx - from.dx;
      double dy = to.dy - from.dy;

      String direction = '';
      String icon = '';

      if (dy.abs() > dx.abs()) {
        if (dy < 0) {
          direction = 'Walk straight ahead';
          icon = '⬆️';
        } else {
          direction = 'Walk back along corridor';
          icon = '⬇️';
        }
      } else {
        if (dx > 0) {
          direction = 'Turn right into corridor';
          icon = '➡️';
        } else {
          direction = 'Turn left into corridor';
          icon = '⬅️';
        }
      }

      steps.add({
        'step': i + 1,
        'direction': direction,
        'distance': distance,
        'icon': icon,
      });
    }

    return steps;
  }

  void _nextRoom() {
    if (currentRoomIndex < allocatedRooms.length - 1) {
      setState(() {
        currentRoomIndex++;
      });
    } else {
      setState(() {
        testsCompleted = true;
      });
    }
  }

  void _restartTests() {
    setState(() {
      _initializePatientTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getStepByStepDirections();
    final totalDistance = steps.fold<double>(0.0, (sum, step) => sum + step['distance']);
    final currentPath = _generateNavigationPath(
      currentRoomIndex == 0 ? 'ENTRANCE' : allocatedRooms[currentRoomIndex - 1],
      currentRoom,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          'Hospital Navigation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _restartTests,
          ),
        ],
      ),
      body: testsCompleted
          ? _buildCompletedScreen()
          : SingleChildScrollView(
        child: Column(
          children: [
            // Multi-Room Progress Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Test ${currentRoomIndex + 1} of ${allocatedRooms.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(allocatedRooms.length, (index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: index < currentRoomIndex
                              ? Colors.green.withOpacity(0.2)
                              : index == currentRoomIndex
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: index < currentRoomIndex
                                ? Colors.green
                                : index == currentRoomIndex
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                        child: Text(
                          allocatedRooms[index].split(' ').last,
                          style: TextStyle(
                            fontWeight: index <= currentRoomIndex ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Current Test Info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${patientTests[currentRoomIndex]} - $currentRoom',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${totalDistance.toStringAsFixed(0)}m total',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Walking Directions Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_walk,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Starting Point
                  _buildDirectionStep(
                    currentRoomIndex == 0 ? '🚪' : '✅',
                    currentRoomIndex == 0 ? 'Start at ENTRANCE' : 'Left ${allocatedRooms[currentRoomIndex - 1]}',
                    currentRoomIndex == 0
                        ? 'Main hospital entrance'
                        : 'Previous test completed',
                    isStart: true,
                  ),

                  const SizedBox(height: 12),

                  // Step-by-step directions
                  ...List.generate(steps.length, (index) {
                    final step = steps[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDirectionStep(
                        step['icon'],
                        'Step ${step['step']}',
                        '${step['direction']} (${step['distance'].toStringAsFixed(0)}m)',
                      ),
                    );
                  }),

                  // Current Room Arrival
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildDirectionStep(
                      '🎯',
                      'Arrived at $currentRoom!',
                      '${patientTests[currentRoomIndex]}',
                      isDestination: true,
                    ),
                  ),
                ],
              ),
            ),

            // MAP
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 450,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    final startPos = roomNormalizedPositions[
                    currentRoomIndex == 0 ? 'ENTRANCE' : allocatedRooms[currentRoomIndex - 1]
                    ]!;
                    final currentScreenPos = Offset(
                      startPos.dx * w,
                      startPos.dy * h,
                    );

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 4.0,
                      boundaryMargin: const EdgeInsets.all(100),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: FloorPlanPainter(
                                highlightRoom: currentRoom,
                                path: currentPath,
                              ),
                            ),
                          ),
                          CustomPaint(
                            size: Size(w, h),
                            painter: RoutePainter(
                              path: currentPath,
                              screenWidth: w,
                              screenHeight: h,
                            ),
                          ),
                          // Start marker
                          Positioned(
                            left: currentScreenPos.dx - 30,
                            top: currentScreenPos.dy - 30,
                            child: _GlowingMarker(
                              color: currentRoomIndex == 0
                                  ? const Color(0xFF4CAF50)
                                  : Colors.orange,
                              label: currentRoomIndex == 0 ? 'START' : 'FROM',
                            ),
                          ),
                          // Current room marker
                          if (currentPath.isNotEmpty)
                            Positioned(
                              left: currentPath.last.dx * w - 25,
                              top: currentPath.last.dy * h - 25,
                              child: _GlowingMarker(
                                color: const Color(0xFF2196F3),
                                label: currentRoom.split(' ').last,
                              ),
                            ),
                          // Recenter button
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: FloatingActionButton.small(
                              heroTag: 'recenter',
                              onPressed: () {
                                _transformationController.value = Matrix4.identity();
                              },
                              backgroundColor: const Color(0xFF2E7D32),
                              child: const Icon(Icons.center_focus_strong, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // FINISHED BUTTON
            Container(
              margin: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _nextRoom,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        hasNextRoom
                            ? 'Finished ${patientTests[currentRoomIndex]} - Next Room'
                            : 'Finished All Tests!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.task_alt,
              size: 80,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Tests Completed! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Great job completing all your scheduled tests.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _restartTests,
                child: const Text(
                  'Book New Tests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionStep(String icon, String title, String description, {
    bool isStart = false,
    bool isDestination = false
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isStart
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : isDestination
                ? const Color(0xFF2196F3).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isStart
                      ? const Color(0xFF4CAF50)
                      : isDestination
                      ? const Color(0xFF2196F3)
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Updated FloorPlanPainter to highlight current room
class FloorPlanPainter extends CustomPainter {
  final String? highlightRoom;
  final List<Offset>? path;

  FloorPlanPainter({this.highlightRoom, this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background (unchanged)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Building outline, corridors (unchanged - same as original)
    final buildingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final buildingStroke = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9), buildingStroke);

    final corridorPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(Rect.fromLTWH(w * 0.10, h * 0.05, w * 0.15, h * 0.9), corridorPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.05, w * 0.15, h * 0.9), corridorPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.75, h * 0.05, w * 0.15, h * 0.9), corridorPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.48, w * 0.50, h * 0.10), corridorPaint);

    // Draw all rooms (same as original)
    final roomPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final roomStroke = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1.5;

    void drawRoom(double x, double y, double rw, double rh, String label) {
      final rect = Rect.fromLTWH(x * w, y * h, rw * w, rh * h);

      // Highlight current room
      if (highlightRoom == label || 'R$label' == highlightRoom?.split(' ').last) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = const Color(0xFF2196F3).withOpacity(0.2),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = const Color(0xFF2196F3)..style = PaintingStyle.stroke..strokeWidth = 3,
        );
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), roomPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), roomStroke);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: highlightRoom == label ? const Color(0xFF2196F3) : Colors.black87,
            fontSize: 10,
            fontWeight: highlightRoom == label ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2),
      );
    }

    // Draw rooms (same coordinates as original)
    drawRoom(0.06, 0.75, 0.12, 0.08, 'R1');
    drawRoom(0.06, 0.60, 0.12, 0.08, 'R4');
    drawRoom(0.06, 0.45, 0.12, 0.08, 'R5');
    drawRoom(0.06, 0.30, 0.12, 0.08, 'R3');
    drawRoom(0.06, 0.10, 0.12, 0.12, 'R2');
    drawRoom(0.30, 0.75, 0.12, 0.08, 'R8');
    drawRoom(0.42, 0.75, 0.12, 0.08, 'R9');
    drawRoom(0.30, 0.10, 0.12, 0.12, 'R6');
    drawRoom(0.42, 0.10, 0.12, 0.12, 'R10');
    drawRoom(0.60, 0.75, 0.12, 0.08, 'R20');
    drawRoom(0.60, 0.33, 0.12, 0.08, 'R19');
    drawRoom(0.60, 0.10, 0.12, 0.12, 'R14');
    drawRoom(0.56, 0.33, 0.08, 0.08, 'R17');
    drawRoom(0.64, 0.33, 0.08, 0.08, 'R18');
    drawRoom(0.60, 0.10, 0.08, 0.12, 'R15');

    // ENTRANCE
    final entranceRect = Rect.fromLTWH(w * 0.15, h * 0.90, w * 0.10, h * 0.06);
    canvas.drawRRect(
      RRect.fromRectAndRadius(entranceRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF4CAF50),
    );
    final entranceText = TextPainter(
      text: const TextSpan(
        text: 'ENTRANCE',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    entranceText.layout();
    entranceText.paint(
      canvas,
      Offset(entranceRect.center.dx - entranceText.width / 2, entranceRect.center.dy - entranceText.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// RoutePainter and _GlowingMarker remain the same as original
class RoutePainter extends CustomPainter {
  final List<Offset> path;
  final double screenWidth;
  final double screenHeight;

  RoutePainter({
    required this.path,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final pathPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < path.length - 1; i++) {
      final start = Offset(path[i].dx * screenWidth, path[i].dy * screenHeight);
      final end = Offset(path[i + 1].dx * screenWidth, path[i + 1].dy * screenHeight);

      canvas.drawLine(start, end, outlinePaint);
      canvas.drawLine(start, end, pathPaint);

      if (i > 0 && i < path.length - 1) {
        canvas.drawCircle(end, 5, Paint()..color = const Color(0xFF1B5E20));
        canvas.drawCircle(end, 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      }

      if (i == 0 || i == path.length - 2) {
        _drawArrow(canvas, start, end);
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    if ((to - from).distance < 20) return;

    final mid = Offset((from.dx + to.dx) / 2, (from.dy + from.dy) / 2);
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    final arrowSize = 16.0;

    final arrowPath = Path()
      ..moveTo(mid.dx, mid.dy)
      ..lineTo(mid.dx - arrowSize * cos(angle - pi / 6), mid.dy - arrowSize * sin(angle - pi / 6))
      ..lineTo(mid.dx - arrowSize * cos(angle + pi / 6), mid.dy - arrowSize * sin(angle + pi / 6))
      ..close();

    canvas.drawPath(arrowPath, Paint()..color = const Color(0xFF1B5E20));
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) => false;
}

class _GlowingMarker extends StatefulWidget {
  final Color color;
  final String label;

  const _GlowingMarker({required this.color, required this.label});

  @override
  State<_GlowingMarker> createState() => _GlowingMarkerState();
}

class _GlowingMarkerState extends State<_GlowingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _animation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}