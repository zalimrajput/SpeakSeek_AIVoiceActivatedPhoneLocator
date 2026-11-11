
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/intro_page.dart';
import 'package:fyp/main_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


import 'database.dart';

class AuthMethods{
  final FirebaseAuth auth=FirebaseAuth.instance;
  getCurrentUser()async{
    return await auth.currentUser;
  }





  signInWithGoogle(BuildContext context)async{
    final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
    final GoogleSignIn googleSignIn=GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount=await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication=await googleSignInAccount?.authentication;
    final AuthCredential credential=GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken,
    );
    UserCredential result=await firebaseAuth.signInWithCredential(credential);
    User? userdetails =result.user;
    if(result != null){
      Map<String,dynamic> userInfoMap={
        "email":userdetails!.email,
        "name":userdetails.displayName,
        "imgUrl":userdetails.photoURL,
        "id":userdetails.uid,
      };
      await DatabaseMethods().addUser(userdetails.uid,userInfoMap).then((value)=> Navigator.push(context,MaterialPageRoute(builder: (context)=>MainPage())));
    }
  }



  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login(permissions:['email','public_profile']);



    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }







  // Future<User> signInWithApple({List<Scope> scopes = const []}) async {
  //   final result = await TheAppleSignIn.performRequests(
  //       [AppleIdRequest(requestedScopes: scopes)]);
  //   switch (result.status) {
  //     case AuthorizationStatus.authorized:
  //       final AppleIdCredential = result.credential!;
  //       final oAuthCredential = OAuthProvider('apple.com');
  //       final credential = oAuthCredential.credential(
  //           idToken: String.fromCharCodes(AppleIdCredential.identityToken!));
  //       final UserCredential = await auth.signInWithCredential(credential);
  //       final firebaseUser = UserCredential.user!;
  //       if (scopes.contains(Scope.fullName)) {
  //         final fullName = AppleIdCredential.fullName;
  //         if (fullName != null &&
  //             fullName.givenName != null &&
  //             fullName.familyName != null) {
  //           final displayName = '${fullName.givenName}${fullName.familyName}';
  //           await firebaseUser.updateDisplayName(displayName);
  //         }
  //       }
  //       return firebaseUser;
  //     case AuthorizationStatus.error:
  //       throw PlatformException(
  //           code: 'ERROR_AUTHORIZATION_DENIED',
  //           message: result.error.toString());
  //
  //     case AuthorizationStatus.cancelled:
  //       throw PlatformException(
  //           code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
  //     default:
  //       throw UnimplementedError();
  //   }
  // }

}
