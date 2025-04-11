import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(DockApp());

class DockApp extends StatelessWidget {
  const DockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DockScreen(), debugShowCheckedModeBanner: false);
  }
}

class DockScreen extends StatefulWidget {
  const DockScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DockScreenState createState() => _DockScreenState();
}

class _DockScreenState extends State<DockScreen> {
  List<IconData> icons = [
    Icons.home,
    Icons.search,
    Icons.settings,
    Icons.star,
    Icons.music_note,
    Icons.camera_alt,
  ];

  int? draggingIndex;
  double dragPosition = -1;

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final icon = icons.removeAt(oldIndex);
      icons.insert(newIndex, icon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: Container()), // empty space
          Dock(icons: icons, onReorder: _onReorder),
        ],
      ),
    );
  }
}

class Dock extends StatefulWidget {
  final List<IconData> icons;
  final Function(int oldIndex, int newIndex) onReorder;

  const Dock({super.key, required this.icons, required this.onReorder});

  @override
  // ignore: library_private_types_in_public_api
  _DockState createState() => _DockState();
}

class _DockState extends State<Dock> {
  // ignore: unused_field
  int? _draggingIndex;
  Offset? _pointerPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: MouseRegion(
              onHover: (event) {
                setState(() {
                  _pointerPosition = event.position;
                });
              },
              onExit: (_) => setState(() => _pointerPosition = null),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.icons.length, (index) {
                  return _buildDraggableItem(index);
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableItem(int index) {
    return Draggable<int>(
      data: index,
      onDragStarted: () => setState(() => _draggingIndex = index),
      onDraggableCanceled: (_, __) => setState(() => _draggingIndex = null),
      onDragCompleted: () => setState(() => _draggingIndex = null),
      feedback: _buildIcon(index, magnified: true),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildIcon(index)),
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          widget.onReorder(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return _buildIcon(index);
        },
      ),
    );
  }

  Widget _buildIcon(int index, {bool magnified = false}) {
    final icon = widget.icons[index];

    double distance = 1000;
    if (_pointerPosition != null) {
      final box = context.findRenderObject() as RenderBox;
      final itemOffset =
          box.localToGlobal(Offset.zero) + Offset(index * 60.0 + 30, 50);
      distance = (_pointerPosition! - itemOffset).distance;
    }

    final scale =
        magnified
            ? 1.8
            : 1 +
                max(0, 1.2 - (distance / 150)).clamp(0, 0.8); // scaling effect

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 6),
      width: 50 * scale.toDouble(),
      height: 50 * scale.toDouble(),
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(),
        elevation: 8,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(50),
          child: Icon(icon, color: Colors.white, size: 24 * scale.toDouble()),
        ),
      ),
    );
  }
}
