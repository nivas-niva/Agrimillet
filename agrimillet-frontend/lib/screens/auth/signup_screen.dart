import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../utils/ui_constants.dart';
import '../../widgets/interactive_button.dart';
import 'dart:ui';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _mobileController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _upiController;

  String _selectedUserType = 'buyer';
  String _selectedState = 'Andhra Pradesh';
  String _selectedDistrict = 'Anantapur';
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _mobileController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscController = TextEditingController();
    _upiController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number must be 10 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      BankingDetails? bankingDetails;
      if (_selectedUserType == 'farmer') {
        if (_accountNumberController.text.isEmpty && _upiController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Farmer must provide account number or UPI ID')),
          );
          setState(() => _isLoading = false);
          return;
        }

        bankingDetails = BankingDetails(
          accountNumber: _accountNumberController.text.isNotEmpty
              ? _accountNumberController.text
              : null,
          ifscCode:
              _ifscController.text.isNotEmpty ? _ifscController.text : null,
          upiId: _upiController.text.isNotEmpty ? _upiController.text : null,
        );
      }

      await Provider.of<AuthProvider>(context, listen: false).signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        mobileNo: _mobileController.text.trim(),
        userType: _selectedUserType,
        state: _selectedState,
        district: _selectedDistrict,
        bankingDetails: bankingDetails,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1711), Color(0xFF1B261D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name Field
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            labelText: 'Full Name',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.white.withOpacity(0.7), size: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email Field
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.7), size: 18),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.white.withOpacity(0.7), size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white.withOpacity(0.7),
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mobile Number Field
                        TextField(
                          controller: _mobileController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            labelText: 'Mobile Number',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            hintText: 'Enter 10 digit number',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                            prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.7), size: 18),
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                        const SizedBox(height: 16),
                        // User Type Selection
                        const Text(
                          'Account Type',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Theme(
                          data: ThemeData.dark(),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: const Text('Farmer', style: TextStyle(fontSize: 13)),
                                  value: 'farmer',
                                  groupValue: _selectedUserType,
                                  onChanged: (value) {
                                    setState(() => _selectedUserType = value.toString());
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  title: const Text('Buyer', style: TextStyle(fontSize: 13)),
                                  value: 'buyer',
                                  groupValue: _selectedUserType,
                                  onChanged: (value) {
                                    setState(() => _selectedUserType = value.toString());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // State Selection
                        const Text(
                          'Location',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Theme(
                          data: ThemeData.dark(),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedState,
                            dropdownColor: const Color(0xFF1B261D),
                            items: indianStates
                                .map((state) => DropdownMenuItem(
                                      value: state,
                                      child: Text(state, style: const TextStyle(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedState = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            labelText: 'District',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            hintText: 'Enter your district',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                          ),
                          onChanged: (value) => _selectedDistrict = value,
                        ),
                        // Conditional: Farmer Banking Details
                        if (_selectedUserType == 'farmer') ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Banking Details',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Provide either account number or UPI ID',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _accountNumberController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              labelText: 'Account Number',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                              hintText: 'Your bank account number',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _ifscController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              labelText: 'IFSC Code',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                              hintText: 'Your bank IFSC code',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _upiController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              labelText: 'UPI ID',
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                              hintText: 'Your UPI ID (e.g., name@upi)',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        InteractiveButton(
                          text: 'Create Account',
                          isLoading: _isLoading,
                          onPressed: _handleSignup,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
