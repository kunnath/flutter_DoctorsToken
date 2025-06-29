import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'database_helper.dart';
import 'register_screen.dart';
import 'patient_dashboard.dart';
import 'doctor_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Authenticate user with database
        Map<String, dynamic>? user = await _databaseHelper.authenticateUser(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null) {
          // Successful login - route based on user role
          String role = user['role'] ?? 'patient';
          
          switch (role) {
            case 'admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminDashboard(user: user),
                ),
              );
              break;
            case 'doctor':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDashboard(user: user),
                ),
              );
              break;
            case 'patient':
            default:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDashboard(user: user),
                ),
              );
              break;
          }
        } else {
          // Invalid credentials
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Database error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Title
              Text(
                '🏥 Healthcare Portal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connecting Patients, Doctors & Healthcare',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Email TextField
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password TextField
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 16),

              // Register Button 
              OutlinedButton(
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              
              // Additional UI elements
              TextButton(
                onPressed: () {
                  // Handle forgot password
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Forgot password feature not implemented')),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
              
              const SizedBox(height: 20),
              
              // Demo Credentials Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🚀 Demo Credentials',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDemoCredentialRow('Admin', 'admin@healthcare.com', 'admin123'),
                    _buildDemoCredentialRow('Patient', 'john.smith@email.com', 'patient123'),
                    _buildDemoCredentialRow('Doctor', 'sarah.johnson@citygeneralhospital.com', 'doctor123'),
                    _buildDemoCredentialRow('Doctor', 'doctor@gmail.com', 'admin123'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredentialRow(String role, String email, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              role,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '$email / $password',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              _emailController.text = email;
              _passwordController.text = password;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$role credentials filled')),
              );
            },
          ),
        ],
      ),
    );
  }
}
