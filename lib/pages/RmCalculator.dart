import 'package:flutter/material.dart';

class RmCalculator extends StatefulWidget {
  @override
  _RmCalculatorState createState() => _RmCalculatorState();
}

class _RmCalculatorState extends State<RmCalculator> {
  int? _selectedRm;
  int? _selectedWeight;
  double? _estimatedRM;

  final List<int> _RmOptions = List.generate(61, (index) => index); // 0~60回
  final List<int> _weightOptions =
      List.generate(300, (index) => index); // 0~299kg

  void _calculateRM() {
    if (_selectedWeight != null && _selectedRm != null && _selectedRm! > 0) {
      setState(() {
        _estimatedRM = _selectedWeight! * (1 + 0.0333 * _selectedRm!);
      });
    } else {
      setState(() {
        _estimatedRM = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('RM換算ツール',
            style: TextStyle(color: Color.fromARGB(255, 209, 209, 0))),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            color: Colors.grey[900],
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "重量と回数から推定1RMを計算",
                    style: TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),

                  // ▼ 重量選択
                  DropdownButtonFormField<int>(
                    value: _selectedWeight,
                    items: _weightOptions.map((w) {
                      return DropdownMenuItem<int>(
                        value: w,
                        child: Text('$w kg',
                            style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWeight = value;
                      });
                    },
                    dropdownColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      hintText: "重量を選択",
                      hintStyle:
                          TextStyle(color: Colors.yellowAccent), // ← 個別の色
                      prefixIcon: Icon(Icons.monitor_weight,
                          color: Colors.yellowAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(color: Colors.yellowAccent),
                  ),
                  SizedBox(height: 20),

                  // ▼ 回数選択
                  DropdownButtonFormField<int>(
                    value: _selectedRm,
                    items: _RmOptions.map((r) {
                      return DropdownMenuItem<int>(
                        value: r,
                        child:
                            Text('$r 回', style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRm = value;
                      });
                    },
                    dropdownColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      hintText: "回数を選択",
                      hintStyle:
                          TextStyle(color: Colors.yellowAccent), // ← 個別の色
                      prefixIcon:
                          Icon(Icons.repeat, color: Colors.yellowAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(color: Colors.yellowAccent),
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _calculateRM,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellowAccent,
                      foregroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("1RMを計算する", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 24),

                  if (_estimatedRM != null)
                    Text(
                      '推定1RM: ${_estimatedRM!.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
