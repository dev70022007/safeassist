import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../controllers/demo_controller.dart';
import '../theme/app_theme.dart';

class SafeAssistHome extends StatefulWidget {
  const SafeAssistHome({super.key});

  @override
  State<SafeAssistHome> createState() => _SafeAssistHomeState();
}

class _SafeAssistHomeState extends State<SafeAssistHome> {
  int selectedPage = 0;

  final DemoController controller = DemoController();
  final stt.SpeechToText speech = stt.SpeechToText();

  bool isListening = false;
  bool speechAvailable = false;
  bool voiceCommandHandled = false;

  String recognizedSpeech = 'Tap the microphone to give a command';

  String get movementStatus => controller.movementStatus;
  String get safetyMessage => controller.safetyMessage;
  bool get frontObstacle => controller.frontObstacle;
  bool get isMoving => controller.isMoving;
  int get frontDistance => controller.frontDistance;
  bool get rearObstacle => controller.rearObstacle;
  bool get downwardHazard => controller.downwardHazard;
  int get rearDistance => controller.rearDistance;
  int get downwardDistance => controller.downwardDistance;

  void toggleRearObstacle(bool value) {
    setState(() {
      controller.toggleRearObstacle(value);
    });
  }

  void toggleDownwardHazard(bool value) {
    setState(() {
      controller.toggleDownwardHazard(value);
    });
  }

  void stopMovement() {
    setState(() {
      controller.stopMovement();
    });
  }

  void issueCommand(String command) {
    setState(() {
      controller.issueCommand(command);
    });
  }

  Future<void> toggleVoiceControl() async {
    if (isListening) {
      await speech.stop();

      if (!mounted) return;

      setState(() {
        isListening = false;
        if (recognizedSpeech == 'Listening...') {
          recognizedSpeech = 'Listening stopped';
        }
      });

      return;
    }

    try {
      voiceCommandHandled = false;

      speechAvailable = await speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          if (status == 'notListening' || status == 'done') {
            setState(() {
              isListening = false;

              if (recognizedSpeech == 'Listening...') {
                recognizedSpeech = 'Listening ended. Tap to try again.';
              }
            });
          }
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            isListening = false;
            recognizedSpeech = 'Speech recognition error: ${error.errorMsg}';
          });
        },
      );

      if (!mounted) return;

      if (!speechAvailable) {
        setState(() {
          isListening = false;
          recognizedSpeech =
              'Speech recognition unavailable. Check microphone permission.';
        });
        return;
      }

      setState(() {
        isListening = true;
        recognizedSpeech = 'Listening...';
      });

      await speech.listen(
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: true,
        ),
        onResult: (result) {
          if (!mounted) return;

          final words = result.recognizedWords.toLowerCase().trim();

          setState(() {
            if (words.isNotEmpty) {
              recognizedSpeech = words;
            } else if (isListening) {
              recognizedSpeech = 'Listening...';
            }
          });

          if (!result.finalResult || voiceCommandHandled) return;

          String? command;

          if (RegExp(r'\bstop\b').hasMatch(words)) {
            command = 'STOP';
          } else if (RegExp(r'\bforward\b').hasMatch(words)) {
            command = 'Forward';
          } else if (RegExp(r'\b(reverse|backward|back)\b').hasMatch(words)) {
            command = 'Reverse';
          } else if (RegExp(r'\bleft\b').hasMatch(words)) {
            command = 'Left';
          } else if (RegExp(r'\bright\b').hasMatch(words)) {
            command = 'Right';
          }

          voiceCommandHandled = true;

          if (command != null) {
            issueCommand(command);

            setState(() {
              recognizedSpeech = 'Command recognized: $command';
              isListening = false;
            });

            speech.stop();
          } else {
            setState(() {
              recognizedSpeech = 'Command not recognized. Try Forward, Reverse, Left, Right, or Stop.';
              isListening = false;
            });

            speech.stop();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isListening = false;
        recognizedSpeech = 'Could not start voice recognition';
      });
    }
  }

  void toggleObstacle(bool value) {
    setState(() {
      controller.toggleObstacle(value);
    });
  }

  @override
  void dispose() {
    speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: IndexedStack(
                index: selectedPage,
                children: [_buildDashboard(), _buildControls(), _buildSafety()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        indicatorColor: teal.withValues(alpha: 0.18),
        selectedIndex: selectedPage,
        onDestinationSelected: (index) {
          setState(() => selectedPage = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: teal),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.gamepad_outlined),
            selectedIcon: Icon(Icons.gamepad, color: teal),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar, color: teal),
            label: 'Safety',
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: teal.withValues(alpha: 0.35)),
            ),
            child: const Icon(Icons.accessible_forward, color: teal, size: 30),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SafeAssist',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SMART MOBILITY COMPANION',
                  style: TextStyle(
                    fontSize: 9,
                    color: muted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: warning.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_outlined, color: warning, size: 15),
                SizedBox(width: 5),
                Text(
                  'DEMO MODE',
                  style: TextStyle(
                    color: warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return _page(
      ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _sectionHeading('Overview', 'Your mobility at a glance'),
          const SizedBox(height: 18),
          _buildHeroCard(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              final cardWidth = wide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _statusCard(
                      icon: Icons.bluetooth_disabled,
                      title: 'Hardware',
                      value: 'Not connected',
                      subtitle: 'ESP32 connection unavailable',
                      color: muted,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _statusCard(
                      icon: Icons.shield_outlined,
                      title: 'Safety status',
                      value: (frontObstacle || rearObstacle || downwardHazard)
                          ? 'Hazard detected'
                          : 'Demo ready',
                      subtitle: frontObstacle
                          ? 'Front obstacle simulated'
                          : rearObstacle
                          ? 'Rear obstacle simulated'
                          : downwardHazard
                          ? 'Downward hazard simulated'
                          : 'All simulated paths clear',
                      color: (frontObstacle || rearObstacle || downwardHazard)
                          ? danger
                          : teal,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _sectionHeading('Quick actions', 'Test the app interface'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.gamepad_outlined,
                  title: 'Manual control',
                  subtitle: 'Open controls',
                  onTap: () => setState(() => selectedPage = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  icon: Icons.radar,
                  title: 'Safety monitor',
                  subtitle: 'View sensor demo',
                  onTap: () => setState(() => selectedPage = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMovementSummary(),
          const SizedBox(height: 20),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF173044), Color(0xFF112131), Color(0xFF111B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: teal.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'WHEELCHAIR STATUS',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              _statusPill(
                isMoving ? 'MOVING · DEMO' : 'STOPPED',
                isMoving ? warning : teal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movementStatus,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      safetyMessage,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(Icons.circle, color: warning, size: 8),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Simulation only · No hardware link',
                            style: TextStyle(fontSize: 11, color: warning),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Icon(Icons.accessible_forward, size: 105, color: teal),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: stopMovement,
              style: FilledButton.styleFrom(
                backgroundColor: danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.stop_circle_outlined, size: 25),
              label: const Text(
                'STOP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return _page(
      ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _sectionHeading('Manual control', 'Directional demo controls'),
          const SizedBox(height: 16),
          _notice(
            Icons.science_outlined,
            'Demo Mode',
            'These buttons update the app simulation only. They do not send commands to a wheelchair.',
            warning,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _panelDecoration(),
            child: Column(
              children: [
                const Text(
                  'DIRECTIONAL PAD',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                _directionButton(
                  icon: Icons.keyboard_arrow_up,
                  label: 'FORWARD',
                  command: 'Forward',
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _directionButton(
                      icon: Icons.keyboard_arrow_left,
                      label: 'LEFT',
                      command: 'Left',
                    ),
                    const SizedBox(width: 12),
                    _directionButton(
                      icon: Icons.keyboard_arrow_down,
                      label: 'REVERSE',
                      command: 'Reverse',
                    ),
                    const SizedBox(width: 12),
                    _directionButton(
                      icon: Icons.keyboard_arrow_right,
                      label: 'RIGHT',
                      command: 'Right',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: FilledButton.icon(
                    onPressed: stopMovement,
                    style: FilledButton.styleFrom(
                      backgroundColor: danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.stop_circle_outlined, size: 28),
                    label: const Text(
                      'STOP MOVEMENT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mic_none_rounded, color: teal, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Voice Control',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Demo Mode only. Say Forward, Reverse, Left, Right, or Stop.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: toggleVoiceControl,
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none_rounded,
                    ),
                    label: Text(
                      isListening ? 'Stop Listening' : 'Start Voice Control',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isListening ? danger : teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recognized speech: $recognizedSpeech',
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMovementSummary(),
          const SizedBox(height: 16),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildSafetyOverview() {
    final bool hazardDetected = frontObstacle || rearObstacle || downwardHazard;
    final Color statusColor = hazardDetected ? danger : teal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Icon(
            hazardDetected
                ? Icons.warning_amber_rounded
                : Icons.shield_outlined,
            color: statusColor,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hazardDetected
                      ? 'HAZARD DETECTED'
                      : 'ALL SIMULATED PATHS CLEAR',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hazardDetected
                      ? 'One or more simulated hazards are active.'
                      : 'No simulated hazards are currently active.',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Demo status only — not real sensor data.',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionButton({
    required IconData icon,
    required String label,
    required String command,
  }) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: FilledButton(
              onPressed: () => issueCommand(command),
              style: FilledButton.styleFrom(
                backgroundColor: panelLight,
                foregroundColor: teal,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: teal.withValues(alpha: 0.35)),
                ),
              ),
              child: Icon(icon, size: 38),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafety() {
    return _page(
      ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _sectionHeading('Safety monitor', 'Simulated sensor readings'),
          const SizedBox(height: 16),
          _buildSafetyOverview(),
          const SizedBox(height: 16),
          _notice(
            Icons.info_outline,
            'Simulation data',
            'Distances shown here are generated by the app, not measured by physical sensors.',
            warning,
          ),
          const SizedBox(height: 20),
          _buildSensorZone(
            title: 'FRONT SENSOR',
            distance: frontDistance,
            isHazard: frontObstacle,
            hazardLabel: 'Obstacle present in the demo',
            clearLabel: 'Front path clear in the demo',
            icon: Icons.north,
          ),
          const SizedBox(height: 12),
          _buildSensorSwitch(
            title: 'Simulate front obstacle',
            subtitle: 'Test whether forward movement is blocked',
            value: frontObstacle,
            icon: Icons.warning_amber_rounded,
            onChanged: toggleObstacle,
          ),
          const SizedBox(height: 16),
          _buildSensorZone(
            title: 'REAR SENSOR',
            distance: rearDistance,
            isHazard: rearObstacle,
            hazardLabel: 'Rear obstacle present in the demo',
            clearLabel: 'Rear path clear in the demo',
            icon: Icons.south,
          ),
          const SizedBox(height: 12),
          _buildSensorSwitch(
            title: 'Simulate rear obstacle',
            subtitle: 'Test whether backward movement is blocked',
            value: rearObstacle,
            icon: Icons.south,
            onChanged: toggleRearObstacle,
          ),
          const SizedBox(height: 16),
          _buildSensorZone(
            title: 'DOWNWARD SENSOR',
            distance: downwardDistance,
            isHazard: downwardHazard,
            hazardLabel: 'Downward hazard present in the demo',
            clearLabel: 'No downward hazard simulated',
            icon: Icons.vertical_align_bottom,
          ),
          const SizedBox(height: 12),
          _buildSensorSwitch(
            title: 'Simulate downward hazard',
            subtitle: 'Test whether forward movement is blocked',
            value: downwardHazard,
            icon: Icons.warning_amber_rounded,
            onChanged: toggleDownwardHazard,
          ),
          const SizedBox(height: 20),
          _notice(
            Icons.health_and_safety_outlined,
            'Safety boundary',
            'This demo is not a certified mobility or emergency-stop system. Real hardware must enforce safety independently of the phone app.',
            danger,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorZone({
    required String title,
    required int distance,
    required bool isHazard,
    required String hazardLabel,
    required String clearLabel,
    required IconData icon,
  }) {
    final color = isHazard ? danger : teal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$distance',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 9, left: 7),
                child: Text(
                  'cm · simulated',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (distance / 150).clamp(0.0, 1.0).toDouble(),
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: panelLight,
            color: color,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                isHazard ? Icons.warning_amber : Icons.check_circle,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHazard ? hazardLabel : clearLabel,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      tileColor: panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: muted, fontSize: 12),
      ),
      secondary: Icon(icon, color: value ? danger : muted),
      activeThumbColor: teal,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildMovementSummary() {
    final bool hazardDetected = frontObstacle || rearObstacle || downwardHazard;

    final Color statusColor = hazardDetected
        ? danger
        : isMoving
        ? warning
        : teal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              hazardDetected
                  ? Icons.warning_amber_rounded
                  : isMoving
                  ? Icons.navigation
                  : Icons.pause_circle_outline,
              color: statusColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current movement · DEMO',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  movementStatus,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  safetyMessage,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Simulated status only — hardware not connected',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          Icon(
            hazardDetected
                ? Icons.warning_rounded
                : isMoving
                ? Icons.circle
                : Icons.check_circle,
            color: statusColor,
            size: 17,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warning.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DEMO ONLY\n'
              'No real wheelchair, motor, or sensor is connected. '
              'App controls are for interface testing only.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: muted, fontSize: 13)),
      ],
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: panel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: teal, size: 27),
              const SizedBox(height: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, color: teal, size: 19),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensorCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Simulated reading',
            style: TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _notice(IconData icon, String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );
  }

  Widget _page(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: child,
          ),
        );
      },
    );
  }
}
