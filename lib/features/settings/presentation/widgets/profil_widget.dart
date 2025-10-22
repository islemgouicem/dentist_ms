import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

// class to hold all the controllers
class ProfilControllers{
  final TextEditingController FirstNameController = TextEditingController();
  final TextEditingController LastNameController = TextEditingController();
  final TextEditingController ProfilEmailController = TextEditingController();
  final TextEditingController ProfilPhoneController = TextEditingController();
  final TextEditingController ProfilSpecializationController = TextEditingController();
  final TextEditingController ProfilLicenseNumberController = TextEditingController();
  final TextEditingController ProfilBioController = TextEditingController();

  void dispose() {
    FirstNameController.dispose();
    LastNameController.dispose();
    ProfilEmailController.dispose();
    ProfilPhoneController.dispose();
    ProfilSpecializationController.dispose();
    ProfilLicenseNumberController.dispose();
    ProfilBioController.dispose();
  }
}

// widget to display informations
Widget profil(BuildContext context, double width, double height, ProfilControllers controllers){
  return Card(
      child: Padding(
        padding:  EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informations personnelles", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(radius: width * 0.04, backgroundImage: AssetImage('assets/images/person.png')),
                SizedBox(width: width * 0.02),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {}, 
                      child: Text("Change Photo")
                    ),
                    SizedBox(height: height * 0.01),
                    Text("JPG, PNG ou GIF. Taille maximale: 2Mo.", style: AppTextStyles.subtitle1)
                  ],
                )
              ],
            ),
            SizedBox(height: height * 0.04),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prénom', style: AppTextStyles.title),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: width * 0.355,   
                      height: height * 0.065,
                      child: TextFormField(
                        controller: controllers.FirstNameController,
                        decoration: const InputDecoration(),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: width * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nom', style: AppTextStyles.title),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: width * 0.355,
                      height: height * 0.065,   // controls width
                      child: TextFormField(
                        controller: controllers.LastNameController,
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
                      height: height * 0.065,   // controls width
                      child: TextFormField(
                        controller: controllers.ProfilEmailController,
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
                      height: height * 0.065,  // controls width
                      child: TextFormField(
                        controller: controllers.ProfilPhoneController,
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
                    Text('Spécialisation', style: AppTextStyles.title),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: width * 0.355,  
                      height: height * 0.065, // controls width
                      child: TextFormField(
                        controller: controllers.ProfilSpecializationController,
                        decoration: const InputDecoration(),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: width * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Numéro d'identification", style: AppTextStyles.title),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: width * 0.355, 
                      height: height * 0.065,  // controls width
                      child: TextFormField(
                        controller: controllers.ProfilLicenseNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height:  height * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bio', style: AppTextStyles.title),
                SizedBox(height: height * 0.01),
                SizedBox(
                  width: width * 0.9,   // controls width
                  height: height * 0.15,
                  child: TextFormField(
                      controller: controllers.ProfilBioController,
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
                child: Text("Mettre à jour le profil", style: AppTextStyles.bodyWhite),
              ),
            )
          ],
        ),
      )
    );
}
 