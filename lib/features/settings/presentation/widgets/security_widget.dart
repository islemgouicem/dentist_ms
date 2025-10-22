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

// widget to display informations
Widget security(BuildContext context, double width, double height, SecurityControllers controllers){  
  return Card(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Changer le mot de passe",style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: height * 0.03),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mot de passe actuel',style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.34,   
                          height: height * 0.06,
                          child: TextFormField(
                            controller: controllers.currentPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nouveau mot de passe', style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.34,   
                          height: height * 0.06,
                          child: TextFormField(
                            controller: controllers.newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confirmer le nouveau mot de passe', style: AppTextStyles.title),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.34,   
                          height: height * 0.06,
                          child: TextFormField(
                            controller: controllers.confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: width * 0.08),
              SizedBox(
                width: width * 0.3, 
                height: height * 0.4,  
                child: Image.asset("assets/images/security.jpg", fit: BoxFit.cover)
              )
            ],
          ),           
          SizedBox(height: height * 0.05),
          SizedBox(
            width: width * 0.9,
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
