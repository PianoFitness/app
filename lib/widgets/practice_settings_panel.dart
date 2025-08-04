import 'package:flutter/material.dart';
import '../utils/scales.dart' as music;

enum PracticeMode { scales, chords, arpeggios }

class PracticeSettingsPanel extends StatelessWidget {
  final PracticeMode practiceMode;
  final music.Key selectedKey;
  final music.ScaleType selectedScaleType;
  final bool practiceActive;
  final VoidCallback onStartPractice;
  final VoidCallback onResetPractice;
  final ValueChanged<PracticeMode> onPracticeModeChanged;
  final ValueChanged<music.Key> onKeyChanged;
  final ValueChanged<music.ScaleType> onScaleTypeChanged;

  const PracticeSettingsPanel({
    super.key,
    required this.practiceMode,
    required this.selectedKey,
    required this.selectedScaleType,
    required this.practiceActive,
    required this.onStartPractice,
    required this.onResetPractice,
    required this.onPracticeModeChanged,
    required this.onKeyChanged,
    required this.onScaleTypeChanged,
  });

  String _getPracticeModeString(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.scales:
        return 'Scales';
      case PracticeMode.chords:
        return 'Chords';
      case PracticeMode.arpeggios:
        return 'Arpeggios';
    }
  }

  String _getKeyString(music.Key key) {
    switch (key) {
      case music.Key.c:
        return 'C';
      case music.Key.cSharp:
        return 'C#';
      case music.Key.d:
        return 'D';
      case music.Key.dSharp:
        return 'D#';
      case music.Key.e:
        return 'E';
      case music.Key.f:
        return 'F';
      case music.Key.fSharp:
        return 'F#';
      case music.Key.g:
        return 'G';
      case music.Key.gSharp:
        return 'G#';
      case music.Key.a:
        return 'A';
      case music.Key.aSharp:
        return 'A#';
      case music.Key.b:
        return 'B';
    }
  }

  String _getScaleTypeString(music.ScaleType type) {
    switch (type) {
      case music.ScaleType.major:
        return 'Major (Ionian)';
      case music.ScaleType.minor:
        return 'Natural Minor';
      case music.ScaleType.dorian:
        return 'Dorian';
      case music.ScaleType.phrygian:
        return 'Phrygian';
      case music.ScaleType.lydian:
        return 'Lydian';
      case music.ScaleType.mixolydian:
        return 'Mixolydian';
      case music.ScaleType.aeolian:
        return 'Aeolian';
      case music.ScaleType.locrian:
        return 'Locrian';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 24,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text(
                'Practice Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PracticeMode>(
                  value: practiceMode,
                  decoration: const InputDecoration(
                    labelText: 'Practice Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: PracticeMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getPracticeModeString(mode)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPracticeModeChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<music.Key>(
                  value: selectedKey,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    border: OutlineInputBorder(),
                  ),
                  items: music.Key.values.map((key) {
                    return DropdownMenuItem(
                      value: key,
                      child: Text(_getKeyString(key)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onKeyChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          if (practiceMode == PracticeMode.scales) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<music.ScaleType>(
              value: selectedScaleType,
              decoration: const InputDecoration(
                labelText: 'Scale Type',
                border: OutlineInputBorder(),
              ),
              items: music.ScaleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getScaleTypeString(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onScaleTypeChanged(value);
                }
              },
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: practiceActive ? null : onStartPractice,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onResetPractice,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}