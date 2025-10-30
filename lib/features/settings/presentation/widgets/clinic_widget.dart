import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';
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
                Text("Informations sur la clinique",style: Theme.of(context).textTheme.titleLarge),
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
                    onPressed: () {}, 
                    child: Text("Enregistrer les modifications"),
                  ),
                )
              ],
            ),
          )
        ),
        
        SizedBox(height: height * 0.04),
        Card(
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Horaires de travail",style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: height * 0.03),
                
                // Responsive layout for working hours and image
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Vertical layout for small screens
                      return Column(
                        children: [
                          // Working days list
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for(var day in daysList)
                                Padding(
                                  padding: EdgeInsets.only(bottom: height * 0.02),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: width * 0.1,
                                        child: Text(day, style: AppTextStyles.title),
                                      ),
                                      SizedBox(width: width * 0.02),
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: true,
                                          onChanged: (bool val) {},
                                          activeThumbColor: AppColors.textPrimary,
                                          activeTrackColor: AppColors.primary,
                                          inactiveThumbColor: AppColors.cardgrey,    
                                          inactiveTrackColor: Colors.grey[300],
                                        ),
                                      ),
                                      SizedBox(width: width * 0.02),
                                      // Start time field
                                      Expanded(
                                        child: SizedBox(
                                          height: height * 0.05,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            controller: controllers.workingHoursControllers[day]![0],
                                            readOnly: true,
                                            decoration: const InputDecoration(),
                                            onTap: () async {
                                              TimeOfDay? picked = await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay(hour: 8, minute: 0),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context).copyWith(
                                                      colorScheme: ColorScheme.light(
                                                        primary: AppColors.primary,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null) {
                                                controllers.workingHoursControllers[day]![0].text = 
                                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.01),
                                      Text("à"),
                                      SizedBox(width: width * 0.01),
                                      // End time field
                                      Expanded(
                                        child: SizedBox(
                                          height: height * 0.05,
                                          child: TextFormField(
                                            controller: controllers.workingHoursControllers[day]![1],
                                            readOnly: true,
                                            decoration: const InputDecoration(),
                                            onTap: () async {
                                              TimeOfDay? picked = await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay(hour: 8, minute: 0),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context).copyWith(
                                                      colorScheme: ColorScheme.light(
                                                        primary: AppColors.primary,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null) {
                                                controllers.workingHoursControllers[day]![1].text = 
                                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                            ]
                          ),
                          SizedBox(height: height * 0.03),
                          // Image below fields on small screens
                          SizedBox(
                            width:  width * 0.5,
                            height: height * 0.3,
                            child: Image.asset("assets/images/calender.png"),
                          )
                        ],
                      );
                    } else {
                      // Horizontal layout for larger screens
                      return IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Working days list - take 70% of space
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for(var day in daysList)
              Padding(
                padding: EdgeInsets.only(bottom: height * 0.015),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Day name
                    SizedBox(
                      width: width * 0.08,
                      child: Text(day, style: AppTextStyles.title),
                    ),
                    SizedBox(width: width * 0.02),
                    
                    // Switch
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: true,
                        onChanged: (bool val) {},
                        activeThumbColor: AppColors.textPrimary,
                        activeTrackColor: AppColors.primary,
                        inactiveThumbColor: AppColors.cardgrey,    
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    
                    // Start time field - WRAPPED WITH ALIGN
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: width * 0.055,
                        height: height * 0.05,
                        child: TextFormField(
                          controller: controllers.workingHoursControllers[day]![0],
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12), // Increased vertical padding
                          ),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 8, minute: 0),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              controllers.workingHoursControllers[day]![0].text = 
                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(width: width * 0.01),
                    Text("à", style: AppTextStyles.title),
                    SizedBox(width: width * 0.01),
                    
                    // End time field - WRAPPED WITH ALIGN
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: width * 0.055,
                        height: height * 0.05,
                        child: TextFormField(
                          controller: controllers.workingHoursControllers[day]![1],
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12), // Increased vertical padding
                          ),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: 8, minute: 0),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              controllers.workingHoursControllers[day]![1].text = 
                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),              ),
          ]
        ),
      ),
      
      SizedBox(width: width * 0.03),
      
      // Image - take 30% of space
      Expanded(
        flex: 2,
        child: Center(
          child: SizedBox(
            width: width * 0.2,
            height: height * 0.33,
            child: Image.asset("assets/images/calender.png"),
          ),
        ),
      )
    ],
  ),
);                 }
                  },
                ),
                
                SizedBox(height:  height * 0.065),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {}, 
                    child: Text("Enregistrer les Heures"),
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