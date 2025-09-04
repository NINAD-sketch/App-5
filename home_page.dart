import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String _selectedGender = 'Male';
  int _age = 25;
  int _weight = 60;
  int _height = 170;

  bool _showResult = false;
  bool _isDarkMode = false;

  double? _lastBMI;
  double? _lastBodyFat;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color primaryBlue = Color(0xFF2E86C1);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color darkPrimary = Color(0xFF1B4F72);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadPreferences();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _lastBMI = prefs.getDouble('last_bmi');
      _lastBodyFat = prefs.getDouble('last_bodyfat');
    });
  }

  Future<void> _savePreferences(double bmi, double bodyFat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setDouble('last_bmi', bmi);
    await prefs.setDouble('last_bodyfat', bodyFat);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: _isDarkMode
            ? darkBackground
            : const Color.fromARGB(255, 171, 243, 251),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildInputSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 24),
              if (_showResult) _buildResultSection(),
              if (_lastBMI != null) _buildLastResultSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'BMI Calculator',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: _isDarkMode ? Colors.white : textPrimary,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: _isDarkMode ? cardDark : cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: Switch(
            value: _isDarkMode,
            onChanged: (val) async {
              setState(() => _isDarkMode = val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('dark_mode', _isDarkMode);
            },
            activeColor: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isDarkMode
                  ? [darkPrimary, primaryBlue]
                  : [primaryBlue, accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                'Track Your Health',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Calculate your BMI and body fat percentage',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isDarkMode ? cardDark : cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _isDarkMode ? Colors.white : textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSliderCard(
                  'Age',
                  _age,
                  0,
                  100,
                  (v) => setState(() => _age = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderSelector()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSliderCard(
                  'Weight (kg)',
                  _weight,
                  20,
                  200,
                  (v) => setState(() => _weight = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSliderCard(
                  'Height (cm)',
                  _height,
                  100,
                  250,
                  (v) => setState(() => _height = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? darkBackground : lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _isDarkMode ? Colors.white : textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryBlue,
              inactiveTrackColor: _isDarkMode
                  ? Colors.grey[700]
                  : Colors.grey[300],
              thumbColor: primaryBlue,
              overlayColor: primaryBlue.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (val) => onChanged(val.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? darkBackground : lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Gender',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _isDarkMode ? Colors.white : textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton(
                  'Male',
                  Icons.male,
                  _selectedGender == 'Male',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGenderButton(
                  'Female',
                  Icons.female,
                  _selectedGender == 'Female',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryBlue
                : (_isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
          ),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : (_isDarkMode ? Colors.white70 : textSecondary),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text(
              'Calculate BMI',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            onPressed: () {
              setState(() => _showResult = true);
              _animationController.forward();
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: primaryBlue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: primaryBlue),
            ),
          ),
          icon: const Icon(Icons.refresh_outlined),
          label: const Text(
            'Reset',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          onPressed: () {
            setState(() {
              _age = 25;
              _weight = 60;
              _height = 170;
              _selectedGender = 'Male';
              _showResult = false;
            });
            _animationController.reset();
          },
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return FadeTransition(opacity: _fadeAnimation, child: _buildResultCard());
  }

  Widget _buildResultCard() {
    double heightMeters = _height / 100.0;
    double bmi = _weight / (heightMeters * heightMeters);
    int gender = _selectedGender == 'Male' ? 1 : 0;
    double bodyFat = (1.2 * bmi) + (0.23 * _age) - (10.8 * gender) - 5.4;

    String bmiCat;
    Color categoryColor;
    if (bmi < 18.5) {
      bmiCat = 'Underweight';
      categoryColor = Colors.blue;
    } else if (bmi < 25) {
      bmiCat = 'Normal Weight';
      categoryColor = Colors.green;
    } else if (bmi < 30) {
      bmiCat = 'Overweight';
      categoryColor = Colors.orange;
    } else {
      bmiCat = 'Obese';
      categoryColor = Colors.red;
    }

    _savePreferences(bmi, bodyFat);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isDarkMode ? cardDark : cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _isDarkMode ? Colors.white : textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: SfRadialGauge(
              axes: [
                RadialAxis(
                  minimum: 10,
                  maximum: 40,
                  showLabels: false,
                  showTicks: false,
                  startAngle: 180,
                  endAngle: 0,
                  ranges: [
                    GaugeRange(
                      startValue: 10,
                      endValue: 18.5,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    GaugeRange(
                      startValue: 18.5,
                      endValue: 24.9,
                      color: Colors.green.withOpacity(0.3),
                    ),
                    GaugeRange(
                      startValue: 25,
                      endValue: 29.9,
                      color: Colors.orange.withOpacity(0.3),
                    ),
                    GaugeRange(
                      startValue: 30,
                      endValue: 40,
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ],
                  pointers: [
                    NeedlePointer(
                      value: bmi,
                      needleColor: categoryColor,
                      knobStyle: KnobStyle(color: categoryColor),
                    ),
                  ],
                  annotations: [
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            bmi.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                          Text(
                            'BMI',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : textSecondary,
                            ),
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.7,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: categoryColor.withOpacity(0.3)),
            ),
            child: Text(
              bmiCat,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDarkMode ? darkBackground : lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Body Fat',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDarkMode ? Colors.white70 : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bodyFat.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode ? Colors.white : textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: _isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDarkMode ? Colors.white70 : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bmiCat,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastResultSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (_isDarkMode ? cardDark : cardLight).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: _isDarkMode ? Colors.white70 : textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Last Result: BMI ${_lastBMI!.toStringAsFixed(1)} • Body Fat ${_lastBodyFat!.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.white70 : textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
