import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

// class to hold all the controllers
class ClinicControllers {
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final Map<String, List<TextEditingController>> workingHoursControllers = {};
  
  // Method to update controllers with data
  void updateControllersFromClinicData({
    String? clinicName,
    String? registrationNumber,
    String? email,
    String? phone,
    String? address,
    String? about,
    Map<String, List<String>>? workingHours,
  }) {
    
    // Remove the _initialized check to allow updates
    if (clinicName != null) {
      clinicNameController.text = clinicName;
    }
    if (registrationNumber != null) {
      registrationNumberController.text = registrationNumber;
    }
    if (email != null) {
      emailController.text = email;
    }
    if (phone != null) {
      phoneController.text = phone;
    }
    if (address != null) {
      addressController.text = address;
    }
    if (about != null) {
      aboutController.text = about;
    }    
    // Initialize working hours controllers with data if provided
    if (workingHours != null) {
      workingHours.forEach((day, times) {
        if (workingHoursControllers.containsKey(day)) {
          if (times.length >= 2) {
            workingHoursControllers[day]![0].text = times[0];
            workingHoursControllers[day]![1].text = times[1];
          }
        }
      });
    }
  }
  
  void dispose() {
    clinicNameController.dispose();
    registrationNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    aboutController.dispose();
    
    // Dispose working hours controllers
    workingHoursControllers.forEach((key, controllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    });
  }
}
// widget to display informations
Widget clinic(BuildContext context, double width, double height, ClinicControllers controllers){
    List<String> daysList = ["Samedi", "Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi"];

    // Initialize working hours controllers if not already done
    if (controllers.workingHoursControllers.isEmpty) {
      for (var day in daysList) {
        controllers.workingHoursControllers[day] = [
          TextEditingController(),
          TextEditingController()
        ];
      }
      
      // You can call this method to populate with initial data
      // For example, from your database or default values:
      controllers.updateControllersFromClinicData(
        clinicName: 'Nom de la clinique par défaut',
        registrationNumber: '12345',
        email: 'clinique@example.com',
        phone: '+1234567890',
        address: 'Adresse par défaut',
        about: 'Description de la clinique',
        workingHours: {
          'Lundi': ['08:00', '17:00'],
          'Mardi': ['08:00', '17:00'],
          'Mercredi': ['08:00', '17:00'],
          'Jeudi': ['08:00', '17:00'],
          'Vendredi': ['08:00', '17:00'],
          'Samedi': ['09:00', '13:00'],
          'Dimanche': ['Fermé', 'Fermé'],
        },
      );
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Informations sur la clinique",style: Theme.of(context).textTheme.titleLarge!),
                SizedBox(height: height * 0.03),
                
                // Responsive Row for clinic name and registration number
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Vertical layout for small screens
                      return Column(
                        children: [
                          _buildFieldVertical('Nom de la clinique', controllers.clinicNameController, height),
                          SizedBox(height: height * 0.02),
                          _buildFieldVertical("Numéro d'enregistrement", controllers.registrationNumberController, height, TextInputType.number),
                        ],
                      );
                    } else {
                      // Horizontal layout for larger screens
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFieldHorizontal('Nom de la clinique', controllers.clinicNameController, height),
                          ),
                          SizedBox(width: width * 0.02),
                          Expanded(
                            child: _buildFieldHorizontal("Numéro d'enregistrement", controllers.registrationNumberController, height, TextInputType.number),
                          ),
                        ],
                      );
                    }
                  },
                ),
                
                SizedBox(height: height * 0.02),
                
                // Responsive Row for email and phone
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Vertical layout for small screens
                      return Column(
                        children: [
                          _buildFieldVertical('Email', controllers.emailController, height),
                          SizedBox(height: height * 0.02),
                          _buildFieldVertical('Téléphone', controllers.phoneController, height, TextInputType.number),
                        ],
                      );
                    } else {
                      // Horizontal layout for larger screens
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFieldHorizontal('Email', controllers.emailController, height),
                          ),
                          SizedBox(width: width * 0.02),
                          Expanded(
                            child: _buildFieldHorizontal('Téléphone', controllers.phoneController, height, TextInputType.number),
                          ),
                        ],
                      );
                    }
                  },
                ),
                
                SizedBox(height: height * 0.02),
                
                // Address field (always full width)
                _buildFullWidthField('Address', controllers.addressController, height * 0.065, height),
                
                SizedBox(height: height * 0.02),
                
                // About field (always full width)
                _buildFullWidthField('À propos de la clinique', controllers.aboutController, height * 0.15, height, maxLines: 5),
                
                SizedBox(height: height * 0.04),
                
                // Save button (always full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // You can access the values like this:
                      print('Clinic Name: ${controllers.clinicNameController.text}');
                      print('Email: ${controllers.emailController.text}');
                      print('Phone: ${controllers.phoneController.text}');
                    }, 
                    child: Text("Enregistrer les modifications"),
                  ),
                )
              ],
            ),
          )
        ),
      ],
    );
}

// Helper methods for building responsive fields
Widget _buildFieldHorizontal(String label, TextEditingController controller, double height, [TextInputType keyboardType = TextInputType.text]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: height * 0.01),
      SizedBox(
        height: height * 0.065,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(),
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    ],
  );
}

Widget _buildFieldVertical(String label, TextEditingController controller, double height, [TextInputType keyboardType = TextInputType.text]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: height * 0.01),
      SizedBox(
        height: height * 0.065,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(),
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    ],
  );
}

Widget _buildFullWidthField(String label, TextEditingController controller, double fieldHeight, double screenHeight, {int maxLines = 1}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: screenHeight * 0.01),
      SizedBox(
        height: fieldHeight,
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(),
        ),
      ),
    ],
  );
}