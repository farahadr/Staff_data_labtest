import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'staff_list.dart'; // Make sure this path is correct

class StaffFormPage extends StatefulWidget {
  final String? staffId;
  final Map<String, dynamic>? existingData;
  final VoidCallback? onSuccess;

  const StaffFormPage({Key? key, this.staffId, this.existingData, this.onSuccess}) : super(key: key);

  @override
  State<StaffFormPage> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _idController.text = widget.existingData!['id'] ?? '';
      _ageController.text = widget.existingData!['age'] ?? '';
      _gender = widget.existingData!['gender'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _isValidStaffID(String value) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    return hasLetter && hasNumber;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final staffData = {
          'name': _nameController.text.trim(),
          'id': _idController.text.trim(),
          'age': _ageController.text.trim(),
          'gender': _gender ?? 'Not specified',
          'timestamp': FieldValue.serverTimestamp(),
        };

        if (widget.staffId != null) {
          await FirebaseFirestore.instance
              .collection('staffs')
              .doc(widget.staffId)
              .update(staffData);
        } else {
          await FirebaseFirestore.instance.collection('staffs').add(staffData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff information saved successfully')),
        );

        if (widget.onSuccess != null) {
          widget.onSuccess!(); // Closes bottom sheet if from modal
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StaffListPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text(
          widget.staffId == null ? "Add New Staff" : "Edit Staff",
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 60, // Increase size as needed
            height: 60,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain, // Makes sure it scales proportionally
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Card(
          elevation: 6,
          color: const Color.fromARGB(255, 255, 251, 252),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Staff Information",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: "Staff ID (e.g. AB123) *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'ID is required';
                      if (!_isValidStaffID(value)) {
                        return 'ID must contain letters and numbers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Age is required' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                    validator: (value) => value == null ? 'Gender is required' : null,
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Submit button pressed');
                        _submitForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBA68C8),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(widget.staffId == null ? "Submit" : "Update"),
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
