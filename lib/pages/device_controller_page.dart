import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';

class DeviceControllerPage extends StatefulWidget {
  final MidiDevice device;

  const DeviceControllerPage({super.key, required this.device});

  @override
  State<DeviceControllerPage> createState() => _DeviceControllerPageState();
}

class _DeviceControllerPageState extends State<DeviceControllerPage> {
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  int _selectedChannel = 0;
  int _ccController = 1;
  int _ccValue = 0;
  int _programNumber = 0;
  double _pitchBend = 0.0;
  String _lastReceivedMessage = 'No MIDI data received yet';

  @override
  void initState() {
    super.initState();
    _setupMidiListener();
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    super.dispose();
  }

  void _setupMidiListener() {
    _midiDataSubscription = _midiCommand.onMidiDataReceived?.listen((packet) {
      if (packet.device.id == widget.device.id) {
        _processMidiData(packet.data);
      }
    });
  }

  void _processMidiData(Uint8List data) {
    if (data.isEmpty) return;

    var status = data[0];

    if (status == 0xF8 || status == 0xFE) return;

    setState(() {
      if (data.length >= 3) {
        var rawStatus = status & 0xF0;
        var channel = (status & 0x0F) + 1;
        var data1 = data[1];
        var data2 = data[2];

        switch (rawStatus) {
          case 0x90:
            _lastReceivedMessage =
                'Note ON: $data1 (Ch: $channel, Vel: $data2)';
            break;
          case 0x80:
            _lastReceivedMessage = 'Note OFF: $data1 (Ch: $channel)';
            break;
          case 0xB0:
            _lastReceivedMessage =
                'CC: Controller $data1 = $data2 (Ch: $channel)';
            if (channel - 1 == _selectedChannel && data1 == _ccController) {
              _ccValue = data2;
            }
            break;
          case 0xC0:
            _lastReceivedMessage = 'Program Change: $data1 (Ch: $channel)';
            if (channel - 1 == _selectedChannel) {
              _programNumber = data1;
            }
            break;
          case 0xE0:
            var rawPitch = data1 + (data2 << 7);
            var pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
            _lastReceivedMessage =
                'Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)';
            if (channel - 1 == _selectedChannel) {
              _pitchBend = pitchValue;
            }
            break;
        }
      }
    });
  }

  void _sendControlChange() {
    try {
      CCMessage(
        channel: _selectedChannel,
        controller: _ccController,
        value: _ccValue,
      ).send();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending CC: $e');
      }
    }
  }

  void _sendProgramChange() {
    try {
      PCMessage(channel: _selectedChannel, program: _programNumber).send();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending PC: $e');
      }
    }
  }

  void _sendPitchBend() {
    try {
      PitchBendMessage(channel: _selectedChannel, bend: _pitchBend).send();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending pitch bend: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.name} Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${widget.device.name}'),
                  Text('Type: ${widget.device.type}'),
                  Text('ID: ${widget.device.id}'),
                  Text('Connected: ${widget.device.connected ? "Yes" : "No"}'),
                  Text('Inputs: ${widget.device.inputPorts.length}'),
                  Text('Outputs: ${widget.device.outputPorts.length}'),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Received MIDI Message',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_lastReceivedMessage),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MIDI Channel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: _selectedChannel > 0
                            ? () => setState(() => _selectedChannel--)
                            : null,
                      ),
                      Text(
                        '${_selectedChannel + 1}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: _selectedChannel < 15
                            ? () => setState(() => _selectedChannel++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control Change (CC)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Controller: '),
                      Expanded(
                        child: Slider(
                          value: _ccController.toDouble(),
                          min: 0,
                          max: 127,
                          divisions: 127,
                          label: _ccController.toString(),
                          onChanged: (value) =>
                              setState(() => _ccController = value.toInt()),
                        ),
                      ),
                      Text(_ccController.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Value: '),
                      Expanded(
                        child: Slider(
                          value: _ccValue.toDouble(),
                          min: 0,
                          max: 127,
                          divisions: 127,
                          label: _ccValue.toString(),
                          onChanged: (value) {
                            setState(() => _ccValue = value.toInt());
                            _sendControlChange();
                          },
                        ),
                      ),
                      Text(_ccValue.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program Change',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Program: '),
                      Expanded(
                        child: Slider(
                          value: _programNumber.toDouble(),
                          min: 0,
                          max: 127,
                          divisions: 127,
                          label: _programNumber.toString(),
                          onChanged: (value) {
                            setState(() => _programNumber = value.toInt());
                            _sendProgramChange();
                          },
                        ),
                      ),
                      Text(_programNumber.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pitch Bend',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _pitchBend,
                    min: -1.0,
                    max: 1.0,
                    divisions: 100,
                    label: _pitchBend.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() => _pitchBend = value);
                      _sendPitchBend();
                    },
                    onChangeEnd: (_) {
                      setState(() => _pitchBend = 0.0);
                      _sendPitchBend();
                    },
                  ),
                  Center(child: Text(_pitchBend.toStringAsFixed(2))),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Virtual Piano',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      const SizedBox(width: 18),
                      _buildDevicePianoKey(61, Colors.black),
                      _buildDevicePianoKey(63, Colors.black),
                      const SizedBox(width: 40),
                      _buildDevicePianoKey(66, Colors.black),
                      _buildDevicePianoKey(68, Colors.black),
                      _buildDevicePianoKey(70, Colors.black),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      for (int note = 60; note <= 71; note += 2)
                        _buildDevicePianoKey(note, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicePianoKey(int midiNote, Color color) {
    final noteNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    final noteName = noteNames[midiNote % 12];

    return GestureDetector(
      onTap: () {
        try {
          NoteOnMessage(
            channel: _selectedChannel,
            note: midiNote,
            velocity: 64,
          ).send();
          Future.delayed(const Duration(milliseconds: 500), () {
            NoteOffMessage(channel: _selectedChannel, note: midiNote).send();
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error sending note: $e');
          }
        }
      },
      child: Container(
        width: 40,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            noteName,
            style: TextStyle(
              color: color == Colors.white ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
