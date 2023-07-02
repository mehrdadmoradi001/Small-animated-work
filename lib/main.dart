import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const RockPaperScissorsApp());
}

class RockPaperScissorsApp extends StatelessWidget {
  const RockPaperScissorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OneTwoThreeMoving(),
    );
  }
}

class OneTwoThreeMoving extends StatefulWidget {
  const OneTwoThreeMoving({super.key});

  @override
  OneTwoThreeMovingState createState() => OneTwoThreeMovingState();
}

class OneTwoThreeMovingState extends State<OneTwoThreeMoving>
    with TickerProviderStateMixin {
  int numberContainers = 15;
  List<Widget> one = List.generate(5, (index) => const NumberOne());
  List<Widget> two = List.generate(5, (index) => const NumberTwo());
  List<Widget> three = List.generate(5, (index) => const NumberThree());

  List<Offset> positions = [];
  List<Offset> speed = [];
  List<int> containerToRemove = [];
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();

    // Initialize random,positions,speed for container
    for (int i = 0; i < numberContainers; i++) {
      positions.add(
        _randomOffset(),
      );
      speed.add(
        _randomOffset(),
      );
    }

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000000),
      vsync: this,
    )..addListener(() {
        setState(() {
          for (int i = 0; i < numberContainers; i++) {
            positions[i] += speed[i] * animationController!.value;

            // Check for Parent Collision
            _checkWallParentCollision(i);

            // Check for Container Collision
            for (int j = i + 1; j < numberContainers; j++) {
              _checkContainerCollision(i, j);
            }
          }
        });
      });

    // Start animation
    animationController!.repeat(reverse: true);
  }

  //random values
  Offset _randomOffset() {
    final random = Random();
    return Offset(
      random.nextDouble(),
      random.nextDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NumOne NumTwo NumThree'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Stack(
          children: [
            for (int i = 0; i < numberContainers; i++)
              Positioned(
                top: positions[i].dy * MediaQuery.of(context).size.height,
                left: positions[i].dx * MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {},
                  child: _buildMovingContainer(i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovingContainer(int index) {
    if (index < 5) {
      return one[index];
    } else if (index < 10) {
      return two[index - 5];
    } else {
      return three[index - 10];
    }
  }

  void _checkWallParentCollision(int index) {
    if (positions[index].dx < 0 || positions[index].dx > 1) {
      speed[index] = Offset(-speed[index].dx, speed[index].dy);
    }
    if (positions[index].dy < 0 || positions[index].dy > 1) {
      speed[index] = Offset(speed[index].dx, -speed[index].dy);
    }
  }

  void _checkContainerCollision(int index1, int index2) {
    double spacing = (positions[index1] - positions[index2]).distance;
    if (spacing < 0.1) {
      // Handle Container collision
      Widget object1 = _buildMovingContainer(index1);
      Widget object2 = _buildMovingContainer(index2);

      if (object1.runtimeType == object2.runtimeType) {
        // Same type, away from each other
        speed[index1] = -speed[index1];
        speed[index2] = -speed[index2];
      } else {
        // The larger number removes the smaller number
        if ((object1 is NumberOne && object2 is NumberThree) ||
            (object1 is NumberTwo && object2 is NumberOne) ||
            (object1 is NumberThree && object2 is NumberTwo)) {
          // Object 1 remove Object 2
          _removeContainer(index2);
          speed[index1] = -speed[index1];
        } else if ((object1 is NumberThree && object2 is NumberOne) ||
            (object1 is NumberOne && object2 is NumberTwo) ||
            (object1 is NumberTwo && object2 is NumberThree)) {
          // Object 2 remove Object 1
          _removeContainer(index1);
          speed[index2] = -speed[index2];
        }
      }
    }
  }

  //remove container
  void _removeContainer(int index) {
    setState(
      () {
        positions.removeAt(index);
        speed.removeAt(index);
        numberContainers--;
      },
    );
  }
}

class NumberOne extends StatelessWidget {
  const NumberOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
      child: const Center(
        child: Text('1'),
      ),
    );
  }
}

class NumberTwo extends StatelessWidget {
  const NumberTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.blue,
      child: const Center(
        child: Text('2'),
      ),
    );
  }
}

class NumberThree extends StatelessWidget {
  const NumberThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.green,
      child: const Center(
        child: Text('3'),
      ),
    );
  }
}
