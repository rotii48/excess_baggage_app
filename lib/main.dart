import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ExcessBaggageApp());
}

class ExcessBaggageApp extends StatelessWidget {
  const ExcessBaggageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excess Baggage Calculator',
      debugShowCheckedModeBanner: false,
      //tema
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(255, 178, 197, 1)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(255, 178, 197, 1),
          foregroundColor: Color.fromRGBO(0, 0, 0, 1),
          centerTitle: true,
        ),
      ),
       home: const MainScreen(),
    );
  }
}

// MainScreen widget
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

  class _MainScreenState extends State<MainScreen> {
    int _selectedIndex = 0; // 0 = home, 1 = About

    //List of pages for the navigation menu
    final List<Widget> _pages = [
      const HomePage(),
      const AboutPage(),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title:const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.luggage),
              SizedBox(width: 8),
              Text('Baggage Fee Estimator'),

            ],
            ),
        ),

        body: _pages[_selectedIndex],

        //Navigation Menu (Home & About)
        bottomNavigationBar : BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor:Color.fromRGBO(0, 0, 0, 1),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
  
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'About',
            ),
          ],
        ),
      );
    }
  }

// Page 1 : Home Page (Calculator)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Controllers to read text input from the user
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  
  //Variable for Ticket Class (Default: Economy)
  String _ticketClass = 'Economy';

  //variable to store the result of the calculation
  double _excessFee =0.0;
  double _excessCharge = 0.0;
  double _totalPayable1 = 0.0;
  double _freeAllow = 0.0;

  // Calculation Logic
  void _calculateFee(){
     
     // 1. Hide Keyboard 
     FocusScope.of(context).unfocus();

     // 2. Read user input
     String weightText = _weightController.text.trim();
     String rateText = _rateController.text.trim();

     // 3. Error Checking // Validation Input 
     if (weightText.isEmpty || rateText.isEmpty) {
       _showErrorDialog('Please enter both weight and rate.');
       return;
     }
    
    double? weight = double.tryParse(weightText);
    double? rate = double.tryParse(rateText);

    if (weight == null || rate == null) {
       _showErrorDialog('Please enter valid numbers for weight and rate only.');
       return;
     }

     if (weight < 0 || rate < 0) {
       _showErrorDialog('Weight and rate must be non-negative numbers.');
       return;
     }

    //4. Determine Free Allowance based on Ticket Class
    double freeAllowance = (_ticketClass == 'Economy') ? 20.0 : 40.0;
    
    //5.Calculate Excess Weight 
    double excessWeight = weight - freeAllowance;
    if (excessWeight < 0) {
      excessWeight = 0.0; // No excess if within allowance
    }

    //6. Calculate Excess Fee
    double chargeRate = excessWeight * rate;

    //7. Calculate Total Payable (Charge + 8% Service Tax)
    double total = chargeRate + (0.08 * chargeRate);

    //8. Update the UI with formatted results
    setState(() {
      _excessFee = excessWeight;
      _excessCharge = chargeRate;
      _totalPayable1 = total;
      _freeAllow = freeAllowance;

    });

    _resultCalculation();
  }

  //new pop out window result
  void _resultCalculation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.luggage, color: Colors.pinkAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Baggage Fee Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Divider(),
              _buildResultRow(
                'Free allowance :',
                _freeAllow.toStringAsFixed(2),
              ),

              const Divider(),
             _buildResultRow(
                'Excess Baggage Weight:',
                '${_excessFee.toStringAsFixed(2)} kg',
              ),

              const Divider(),
              _buildResultRow(
                'Excess Baggage Charge:',
                _excessCharge.toStringAsFixed(2),
              ),
              const Divider(),
              _buildResultRow(
                'Total Payable\n(incl. 8% service tax):',
                'RM ${_totalPayable1.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  // Helper function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outlined, color: Colors.red),
              SizedBox(width: 8),
              Text('Input Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //Clear All fields 
 void _resetFields() {
  FocusScope.of(context).unfocus();
  setState(() {
    _weightController.clear();
    _rateController.clear();
    _ticketClass = 'Economy';

  });
}
 @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(8.0),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                 child :Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 18.0, 
                    fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  '1. Enter your checked baggage weight(kg).\n'
                  '2.Select your ticket class.\n'
                  '3. Enter the excess baggage rate per kg.\n'
                  '4. Click "Calculate" to see your excess baggage fee.',
                  style: TextStyle(fontSize: 13.0),
              
                ),
              ],
            ),
            ),
            const SizedBox(height: 16.0),

            //Input 1: Baggage Weight
            TextField(
              controller:_weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Checked Baggage Weight (kg)',
                hintText: 'e.g. 25',
                prefixIcon: Icon(Icons.luggage),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            //Input 2: Ticket Class (Radio Buttons - NonText Field Widget)
            const Text(
              'Select Ticket Class:',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Economy',
                    label: Text('Economy (Max 20kg)'),
                  ),
                  ButtonSegment<String>(
                    value: 'Business',
                    label: Text('Business (Max 40kg)'),
                  ),
                ],
                selected: {_ticketClass},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _ticketClass = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 12.0),

              //Input 3: Excess Baggage Rate per kg (Text Field)
              TextField(
                controller:_rateController,
                keyboardType:const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Excess Baggage Rate (per kg)',
                  hintText: 'e.g. 15',
                  prefixText: ('RM '),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16.0),

              // Helpful Notice
             
              Row(      
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Notice: An 8% service tax will be added to the excess baggage charge.',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey,fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

            //Calculate & Reset Buttons 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculateFee,
                    icon: const Icon(Icons.calculate),
                    label: const Text('CALCULATE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 178, 197, 1), 
                      foregroundColor: Colors.white, 
                      padding: EdgeInsets.symmetric(vertical: 14),

                    ), // Calculate button color
                    ),
                  ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 1,  
                  child: OutlinedButton(
                    onPressed: _resetFields,
                    style: OutlinedButton.styleFrom(
                      padding:const EdgeInsets.symmetric(vertical: 14),
                    ),

                    child: const Text('RESET'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
  //Helper widget to keep the output rows neat and cleanss
  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
 
 //Page 2 : About Page 
 class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

static const String _githubUrl = 'https://github.com/rotii48/excess_baggage_app.git';

// Function to open URL in browser

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse(_githubUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_githubUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //1.Application Icon
        
         // Profile Photo
          CircleAvatar(
            radius: 50.0,
            backgroundColor: const Color.fromRGBO(255, 178, 197, 1),
            child: ClipOval(
              child: Image.asset(
                'assets/Nurin Irdina.png',
                width: 104.0,
                height: 104.0,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          //2.Author Information
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [


                  const Text(
                    'Nurin Irdina',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color:Color.fromRGBO(255, 178, 197, 1)),
                  ),
                  const Divider(),
                 _buildInfoRow(Icons.person, 'Name', 'Nurin Irdina Binti Mohamad Farizal'),
                 _buildInfoRow(Icons.badge, 'Matric No', '2024234118'),
                 _buildInfoRow(Icons.email, 'Email', 'nurinirdinaaa27@gmail.com'),

                ],
              ),
            ),
          ),
const SizedBox(height: 24.0),

// 3. Clickable Github Repository Url
ElevatedButton.icon(
  onPressed: _launchGitHub,
  icon: const Icon(Icons.code),
  label:const Text('View Source Code on Github'),
  style: ElevatedButton.styleFrom(
    backgroundColor:Colors.black87,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
),
const SizedBox(height:8),
Text(
  _githubUrl,
  style:const TextStyle(fontSize: 12, color:Colors.blue),
  textAlign: TextAlign.center,
),
const SizedBox(height: 32),


//4. Copyright Notice
const Text(
  '© 2026 Nurin Irdina. All Rights Reserved.\nDeveloped for Mobile Technology Assignment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),

),
        ],
),
    );
  }
 }

Widget _buildInfoRow(IconData icon, String title, String value) {
  return Row(children: [
    Icon(icon, size: 20, color:Colors.indigo),
    const SizedBox(width: 10),
    Text('$title: ',style:const TextStyle(fontWeight:FontWeight.bold)),
    Expanded(child: Text(value)),
  ],
  );
}