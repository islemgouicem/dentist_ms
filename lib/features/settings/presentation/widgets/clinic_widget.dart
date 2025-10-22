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
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom de la clinique', style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.355,   
                          height: height * 0.065,
                          child: TextFormField(
                            controller: controllers.clinicNameController,
                            decoration: const InputDecoration(),
                            textAlignVertical: TextAlignVertical.center
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: width * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Numéro d'enregistrement", style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.355,
                          height: height * 0.065,
                          child: TextFormField(
                            controller: controllers.registrationNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(),
 
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.355,
                          height: height * 0.065,
                          child: TextFormField(
                            controller: controllers.emailController,
                            decoration: const InputDecoration(),
 
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: width * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Téléphone', style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.355, 
                          height: height * 0.065,
                          child: TextFormField(
                            controller: controllers.phoneController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(),
 
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: height * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address', style: AppTextStyles.title),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: width * 0.9,  
                      height: height * 0.065,
                      child: TextFormField(
                        controller: controllers.addressController,
                        decoration: const InputDecoration() 
                      ),
                    ),
                  ],
                ),            
                SizedBox(height:  height * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('À propos de la clinique', style: AppTextStyles.title),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: width * 0.9,
                      height: height * 0.15,
                      child: TextFormField(
                          controller: controllers.aboutController,
                          maxLines: 5, 
                          decoration: const InputDecoration(), 
                      ),
                    ),
                  ],
                ),
                SizedBox(height:  height * 0.04),
                SizedBox(
                  width: width * 0.9,
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
                Row(
                  children:[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      for(var day in daysList)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: width * 0.045,
                              child: Text(day, style: AppTextStyles.title),
                            ),
                            SizedBox(width: width * 0.07,),
                            Transform.scale(
                              scale: 0.55,
                              child: Switch(
                                value: true,
                                onChanged: (bool val) {},
                                activeThumbColor: AppColors.textPrimary,
                                activeTrackColor: AppColors.primary,
                                inactiveThumbColor: AppColors.cardgrey,    
                                inactiveTrackColor: Colors.grey[300],
                              ),
                            ),
                            // Start time field
                            SizedBox(
                              width: width * 0.07,
                              height: height * 0.05,
                              child: TextFormField(
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
                            SizedBox(width: width * 0.01),
                            Text("à"),
                            SizedBox(width: width * 0.01),
                            // End time field
                            SizedBox(
                              width: width * 0.07,
                              height: height * 0.05,
                              child: TextFormField(
                                controller: controllers.workingHoursControllers[day]![1],                                readOnly: true,
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
                            )
                          ],
                        ),
                      ]
                    ),
                    SizedBox(width: width * 0.08),
                    SizedBox(
                      width: width * 0.25, 
                      height: height * 0.45,  
                      child: Image.asset("assets/images/calender.jpg", fit: BoxFit.cover)
                    )
                  ]
                ),
                SizedBox(height:  height * 0.065),
                SizedBox(
                  width: width * 0.9,
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
