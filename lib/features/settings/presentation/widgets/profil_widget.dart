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
            
            // Profile photo section
            _buildProfilePhotoSection(context, width, height),
            
            SizedBox(height: height * 0.04),
            
            // Responsive fields section
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Vertical layout for small screens
                  return _buildVerticalFields(context, height, width, controllers);
                } else {
                  // Horizontal layout for larger screens
                  return _buildHorizontalFields(context, height, width, controllers);
                }
              },
            ),
            
            SizedBox(height: height * 0.04),
            
            // Update button - always full width
            SizedBox(
              width: double.infinity,
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

// Profile photo section
Widget _buildProfilePhotoSection(BuildContext context, double width, double height) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: width * 0.04, 
        backgroundImage: AssetImage('assets/images/person.png')
      ),
      SizedBox(width: width * 0.02),
      Expanded(
        child: Column(
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
        ),
      )
    ],
  );
}

// Horizontal layout for larger screens
Widget _buildHorizontalFields(BuildContext context, double height, double width, ProfilControllers controllers) {
  return Column(
    children: [
      // First name and Last name
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildField('Prénom', controllers.FirstNameController, height),),
          SizedBox(width: width * 0.02),
          Expanded(child: _buildField('Nom', controllers.LastNameController, height),),
        ],
      ),
      SizedBox(height: height * 0.02),
      
      // Email and Phone
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildField('Email', controllers.ProfilEmailController, height),),
          SizedBox(width: width * 0.02),
          Expanded(child: _buildField('Téléphone', controllers.ProfilPhoneController, height, TextInputType.number),),
        ],
      ),
      SizedBox(height: height * 0.02),
      
      // Specialization and License number
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildField('Spécialisation', controllers.ProfilSpecializationController, height),),
          SizedBox(width: width * 0.02),
          Expanded(child: _buildField("Numéro d'identification", controllers.ProfilLicenseNumberController, height, TextInputType.number),),
        ],
      ),
      SizedBox(height: height * 0.02),
      
      // Bio field (always full width)
      _buildFullWidthField('Bio', controllers.ProfilBioController, height * 0.15, height, maxLines: 5),
    ],
  );
}

// Vertical layout for small screens
Widget _buildVerticalFields(BuildContext context, double height, double width, ProfilControllers controllers) {
  return Column(
    children: [
      _buildField('Prénom', controllers.FirstNameController, height),
      SizedBox(height: height * 0.02),
      _buildField('Nom', controllers.LastNameController, height),
      SizedBox(height: height * 0.02),
      _buildField('Email', controllers.ProfilEmailController, height),
      SizedBox(height: height * 0.02),
      _buildField('Téléphone', controllers.ProfilPhoneController, height, TextInputType.number),
      SizedBox(height: height * 0.02),
      _buildField('Spécialisation', controllers.ProfilSpecializationController, height),
      SizedBox(height: height * 0.02),
      _buildField("Numéro d'identification", controllers.ProfilLicenseNumberController, height, TextInputType.number),
      SizedBox(height: height * 0.02),
      _buildFullWidthField('Bio', controllers.ProfilBioController, height * 0.15, height, maxLines: 5),
    ],
  );
}

// Helper method for regular fields
Widget _buildField(String label, TextEditingController controller, double height, [TextInputType keyboardType = TextInputType.text]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: height * 0.01),
      SizedBox(
       // height: height * 0.065,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(),
        ),
      ),
    ],
  );
}

// Helper method for full width fields
Widget _buildFullWidthField(String label, TextEditingController controller, double fieldHeight, double screenHeight, {int maxLines = 1}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: screenHeight * 0.01),
      SizedBox(
        //height: fieldHeight,
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(),
        ),
      ),
    ],
  );
}