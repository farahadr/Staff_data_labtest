import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffFilterPage extends StatefulWidget {
  const StaffFilterPage({super.key});

  @override
  State<StaffFilterPage> createState() => _StaffFilterPageState();
}

class _StaffFilterPageState extends State<StaffFilterPage> {
  String? _selectedDept;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text("Filter Staff", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Enter Department Letter (e.g. A, B, C...)",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _selectedDept = val.trim().toUpperCase()),
            ),
          ),
          Expanded(
            child: _selectedDept == null || _selectedDept!.isEmpty
                ? const Center(child: Text("Enter a department letter to filter."))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('staffs')
                        .where('id', isGreaterThanOrEqualTo: _selectedDept)
                        .where('id', isLessThan: _selectedDept! + 'z')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No staff found for this department."));
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade100,
                              child: const Icon(Icons.person, color: Colors.deepPurple),
                            ),
                            title: Text(data['name'] ?? ''),
                            subtitle: Text("ID: ${data['id'] ?? ''}"),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}