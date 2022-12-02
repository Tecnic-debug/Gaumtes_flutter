import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:food_sellers_app/widgets/custom_text_field.dart';
import 'package:food_sellers_app/widgets/error_dialogue.dart';
import 'package:food_sellers_app/widgets/loading_dialogue.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/global.dart';
import '../main_screen/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
   XFile? imageXFile;
   final ImagePicker _picker = ImagePicker();

   String sellerImageUrl = "";

   Future<void> _getImage() async{
     imageXFile =await _picker.pickImage(source: ImageSource.gallery);
     setState(() {
       imageXFile;
     });
   }

   Future<void> formValidation() async{
     if(imageXFile==null)
     {
       showDialog(
           context: context,
           builder: (c)
           {
             return ErrorDialog(
               message: "Please choose image",
             );
           }
           );
     }
     else
     {
       if(passwordController.text == confirmPasswordController.text)
         {
            if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty)
            {
              showDialog(
                  context: context,
                  builder: (c)
                  {
                    return LoadingDialog(
                      message: "Registering Account",
                    );

                  }
              );
              String fileName = DateTime.now().microsecondsSinceEpoch.toString();
              fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("Orders").child(fileName);
              fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
              fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(()  {});
              await taskSnapshot.ref.getDownloadURL().then((url) {
                  sellerImageUrl = url;

                  aunthenticateSellerandSignUp();
              });
            }
            else{
              showDialog(
                  context: context,
                  builder: (c)
                  {
                    return ErrorDialog(
                      message: "Fill the required fields",
                    );
                  }
              );
            }
         }
       else{
         showDialog(
             context: context,
             builder: (c)
             {
               return ErrorDialog(
                 message: "Passwords don't match",
               );
             }
         );
       }
     }
   }

   void aunthenticateSellerandSignUp() async{
     User? currentUser;

     await firebaseAuth.createUserWithEmailAndPassword(email: emailController.text.trim(),
         password: passwordController.text.trim()).then((auth ){
           currentUser = auth.user;
     }).catchError((error){
       Navigator.pop(context);
       showDialog(
           context: context,
           builder: (c)
           {
             return ErrorDialog(
               message: error.message.toString(),
             );
           }
       );
     });
     if(currentUser!= null){
       saveDataToFirestore(currentUser!).then((value){
         Navigator.pop(context);
         Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
         Navigator.pushReplacement(context, newRoute);
       });
     }
   }

   Future saveDataToFirestore(User currentUser) async
   {
     FirebaseFirestore.instance.collection("orders").doc(currentUser.uid).set({
       "orderUID": currentUser.uid,
       "orderEmail": currentUser.email,
       "orderName": nameController.text.trim(),
       "orderPhone":phoneController.text.trim(),
       "sellerAvatarUrl": sellerImageUrl,
       "status": "approved",
       "earnings": 0.0,

     });

     sharedPreferences = await SharedPreferences.getInstance();
     await sharedPreferences!.setString("uid", currentUser.uid);
     await sharedPreferences!.setString("email", currentUser.email.toString());
     await sharedPreferences!.setString("name", nameController.text.trim());
     await sharedPreferences!.setString("photoUrl", sellerImageUrl);
   }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
           const SizedBox(height: 10,),
          InkWell(
            onTap: (){
              _getImage();
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width*0.20,
              backgroundImage: imageXFile==null ? null : FileImage(File(imageXFile!.path)),
              child: imageXFile ==null
                ?
                  Icon(
                    Icons.add_photo_alternate,
                    size: MediaQuery.of(context).size.width*0.20,
                    color: Colors.grey,
                  ) :null,
            ),
          ),
          const SizedBox(height: 10,),
          Form(
              key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.person,
                  controller: nameController,
                  hintText: "Name",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.phone,
                  controller: phoneController,
                  hintText: "Phone",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObsecre: true,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  isObsecre: true,
                ),
                CustomTextField(
                  data: Icons.my_location,
                  controller: locationController,
                  hintText: "Restaurant Address",
                  isObsecre: false,
                  enabled: false,
                ),
                Container(
                  width: 400,
                  height: 40,
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    label: Text(
                      "Get my current location",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(
                      Icons.location_on,
                      color: Colors.white,

                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30)
                      ),
                    ), onPressed: ()=> print("clicked"),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30,),
          ElevatedButton(
            child: const Text(
              "Sign up",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 50,vertical: 20),
            ),
            onPressed: (){
              formValidation();
            },
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}

