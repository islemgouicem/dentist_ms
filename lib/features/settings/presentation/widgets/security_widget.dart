import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';

// Create a class to hold all the security controllers
class SecurityControllers {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}

Widget security(BuildContext context, double width, double height, SecurityControllers controllers){  
  return Card(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Changer le mot de passe", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: height * 0.03),
          
          // Responsive layout for password fields and image
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Vertical layout for small screens
                return Column(
                  children: [
                    // Password fields
                    Column(
                      children: [
                        _buildPasswordField('Mot de passe actuel', controllers.currentPasswordController, height),
                        SizedBox(height: height * 0.02),
                        _buildPasswordField('Nouveau mot de passe', controllers.newPasswordController, height),
                        SizedBox(height: height * 0.02),
                        _buildPasswordField('Confirmer le nouveau mot de passe', controllers.confirmPasswordController, height),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    // Image below fields on small screens - FIXED
                    SizedBox(
                      width:  width * 0.5,
                      height: height * 0.3,
                      child: Image.asset("assets/images/security.png"),
                    ),
                  ],
                );
              } else {
                // Horizontal layout for larger screens - FIXED
                return IntrinsicHeight( // This ensures both sides have same height
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Password fields - take remaining space
                      Expanded(
                        flex: 2, // Give more space to form
                        child: Column(
                          children: [
                            _buildPasswordField('Mot de passe actuel', controllers.currentPasswordController, height),
                            SizedBox(height: height * 0.02),
                            _buildPasswordField('Nouveau mot de passe', controllers.newPasswordController, height),
                            SizedBox(height: height * 0.02),
                            _buildPasswordField('Confirmer le nouveau mot de passe', controllers.confirmPasswordController, height),
                          ],
                        ),
                      ),
                      //SizedBox(width: width * 0.2),
                      // Image - fixed width but flexible height
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width:  width * 0.03,
                          height: height * 0.03,
                          child: Image.asset("assets/images/security.png"),
                          ),
                        ),
                      
                    ],
                  ),
                );
              }
            },
          ),
          
          SizedBox(height: height * 0.05),
          
          // Save button - always full width
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, 
              child: Text("Sauvegarder", style: AppTextStyles.bodyWhite),
            ),
          )
        ],
      ),
    )
  );
}

// Helper method for password fields
Widget _buildPasswordField(String label, TextEditingController controller, double height) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.title),
      SizedBox(height: height * 0.01),
      SizedBox(
        //height: height * 0.06,
        child: TextFormField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(),
        ),
      ),
    ],
  );
}
