import 'package:flutter/material.dart';
import 'package:muscle_share/data/PreAndCity.dart';
import 'package:muscle_share/pages/MatchingResultScreen.dart';

class FindBroScreen extends StatefulWidget {
  @override
  _FindBroScreenState createState() => _FindBroScreenState();
}

class _FindBroScreenState extends State<FindBroScreen> {
  String? _selectedOption;
  String? _selectedPrefecture;
  String? _selectedCity;

  int _minHeight = 140;
  int _maxHeight = 200;
  int _minWeight = 30;
  int _maxWeight = 150;
  int _selectedMinYears = 0;
  int _selectedMaxYears = 20;

  final List<int> _trainingYearsOptions =
      List.generate(21, (index) => index); // 0〜20年

  final List<int> _heightOptions =
      List.generate(61, (index) => 140 + index); // 140〜200cm

  final List<int> _weightOptions =
      List.generate(121, (index) => 30 + index); // 30〜150kg

  final Map<String, List<String>> prefectureCityMap = PreAndCity.data;

  final List<String> matchOptions = [
    "選択なし",
    "身長・体重が近い人",
    "筋トレ歴が近い人",
    "合トレが可能な人"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 209, 209, 0),
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'マッチング条件を選択',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("条件で探す",
                style: TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedOption,
              dropdownColor: Colors.grey[900],
              style: TextStyle(color: Colors.white),
              decoration: _dropdownDecoration("条件を選択"),
              items: matchOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOption = value;
                });
              },
            ),
            if (_selectedOption == "筋トレ歴が近い人") ...[
              SizedBox(height: 20),
              Text("筋トレ歴の範囲 (年)",
                  style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMinYears,
                      items: _trainingYearsOptions.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year 年',
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('最小年数'),
                      dropdownColor: Colors.grey[900],
                      onChanged: (value) {
                        setState(() {
                          _selectedMinYears = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMaxYears,
                      items: _trainingYearsOptions.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year 年',
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('最大年数'),
                      dropdownColor: Colors.grey[900],
                      onChanged: (value) {
                        setState(() {
                          _selectedMaxYears = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
            if (_selectedOption == "身長・体重が近い人") ...[
              SizedBox(height: 20),
              Text("身長の範囲 (cm)",
                  style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _minHeight,
                      items: _heightOptions.map((height) {
                        return DropdownMenuItem<int>(
                          value: height,
                          child: Text('$height cm',
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('最小身長'),
                      dropdownColor: Colors.grey[900],
                      onChanged: (value) {
                        setState(() {
                          _minHeight = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _maxHeight,
                      items: _heightOptions.map((height) {
                        return DropdownMenuItem<int>(
                          value: height,
                          child: Text('$height cm',
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('最大身長'),
                      dropdownColor: Colors.grey[900],
                      onChanged: (value) {
                        setState(() {
                          _maxHeight = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("体重の範囲 (kg)",
                  style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _minWeight,
                      items: _weightOptions.map((weight) {
                        return DropdownMenuItem<int>(
                          value: weight,
                          child: Text('$weight kg',
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('最小体重'),
                      dropdownColor: Colors.grey[900],
                      onChanged: (value) {
                        setState(() {
                          _minWeight = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _maxWeight,
                      items: _weightOptions.map((weight) {
                        return DropdownMenuItem<int>(
                          value: weight,
                          child: Text('$weight kg',
                              style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      decoration: _dropdownDecoration('最大体重'),
                      dropdownColor: Colors.grey[900],
                      onChanged: (value) {
                        setState(() {
                          _maxWeight = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
            if (_selectedOption == "合トレが可能な人") ...[
              SizedBox(height: 20),
              Text("都道府県",
                  style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPrefecture,
                dropdownColor: Colors.grey[900],
                style: TextStyle(color: Colors.white),
                decoration: _dropdownDecoration("都道府県を選択"),
                items: prefectureCityMap.keys.map((pref) {
                  return DropdownMenuItem<String>(
                    value: pref,
                    child: Text(pref, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPrefecture = value;
                    _selectedCity = null;
                  });
                },
              ),
              SizedBox(height: 10),
              if (_selectedPrefecture != null)
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  dropdownColor: Colors.grey[900],
                  style: TextStyle(color: Colors.white),
                  decoration: _dropdownDecoration("市区町村を選択"),
                  items: prefectureCityMap[_selectedPrefecture]!
                      .map((city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(city,
                                style: TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                ),
            ],
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 209, 209, 0),
                  foregroundColor: Colors.black,
                ),
                icon: Icon(Icons.search),
                label: Text("検索する"),
                onPressed: () {
                  // 検索ロジックをここに実装
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchingResultScreen(
                        selectedOption: _selectedOption,
                        maxHeight: _maxHeight,
                        minHeight: _minHeight,
                        maxWeight: _maxWeight,
                        minWeight: _minWeight,
                        minYear: _selectedMinYears,
                        maxYear: _selectedMaxYears,
                        selectedPrefecture: _selectedPrefecture,
                        selectedCity: _selectedCity,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[850],
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
