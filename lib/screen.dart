import 'dart:io';

import 'package:account_picker/account_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

enum ErrorType {
  barrierClosed,
  osNotSupported,
  osVersionNotSupported,
  exceptionError,
}

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  ScreenState createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  AndroidDeviceInfo? androidInfo;

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController emailTypeController = TextEditingController();

  TextStyle styleHeader = const TextStyle();
  TextStyle styleBody = const TextStyle();

  @override
  void initState() {
    super.initState();
    initTextStyle();
    if (Platform.isAndroid) {
      fetchAndroidDeviceInfo();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailAddressController.dispose();
    emailTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account picker demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  style: styleHeader,
                  "🔘 Information regarding phone number prompt"),
              const SizedBox(
                height: 8,
              ),
              Text(
                  style: styleBody,
                  "The 'Pick Phone' button will show a prompt window where you can see your device's sim card numbers. You don't need to type your phone number."),
              const SizedBox(
                height: 4,
              ),
              Text(
                  style: styleBody,
                  "In case if prompt closes automatically after clicking on the button or does not open after clicking on the button, then it means that your phone doesn't have any sim card inserted."),
              const SizedBox(
                height: 8,
              ),
              Text(
                  style: styleHeader,
                  "🔘 Information regarding email address prompt"),
              const SizedBox(
                height: 8,
              ),
              Text(
                  style: styleBody,
                  "The 'Pick Email' button will show a prompt window where you can see your device's email addresses. You don't need to type your email address."),
              const SizedBox(
                height: 4,
              ),
              Text(
                  style: styleBody,
                  "In case if prompt redirects you to an account management setup portal, then it means the app does not find any appropriate email account on this device. That's why it is redirecting you to the account management setup portal."),
              const SizedBox(
                height: 4,
              ),
              Text(
                  style: styleBody,
                  "Due to privacy problems, this app cannot see or use your device's sim card numbers & email addresses if you close the prompt window without selecting anything. That's why this app does not require any special device permission."),
              const SizedBox(
                height: 4,
              ),
              Text(
                  style: styleBody,
                  "All these features currently work on Android devices only."),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: "Phone number"),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.call),
                      onPressed: () async {
                        await showPhoneHint(
                          onSuccess: (phone) {
                            phoneController.text = phone;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Phone: ${phone.toString()}'),
                              ),
                            );
                          },
                          onError: (String error, ErrorType errorType) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.toString()),
                              ),
                            );
                          },
                        );
                      },
                      label: const Text('Pick Phone'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: emailAddressController,
                      decoration:
                          const InputDecoration(labelText: "Email address"),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.alternate_email),
                      onPressed: () async {
                        await showEmailHint(
                          onSuccess: (email, type) {
                            emailAddressController.text = email;
                            emailTypeController.text = type;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Email: ${email.toString()}\nType: ${type.toString()}',
                                ),
                              ),
                            );
                          },
                          onError: (String error, ErrorType errorType) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.toString()),
                              ),
                            );
                          },
                        );
                      },
                      label: const Text('Pick Email'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Text("Email type: ${emailTypeController.value.text}")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initTextStyle() async {
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        styleHeader = TextStyle(
          fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
          fontWeight: FontWeight.bold,
        );
        styleBody = TextStyle(
          fontSize: Theme.of(context).textTheme.subtitle2?.fontSize,
        );
      },
    );
    return Future.value();
  }

  Future<void> fetchAndroidDeviceInfo() async {
    androidInfo = await deviceInfo.androidInfo;
    return Future.value();
  }

  // from sms_autofill package
  Future<void> showPhoneHint({
    required Function(String phone) onSuccess,
    required Function(String error, ErrorType errorType) onError,
  }) async {
    if (Platform.isAndroid) {
      try {
        final String? phone = await SmsAutoFill().hint;
        if (phone != null) {
          onSuccess(phone);
        } else {
          onError("Nothing is picked", ErrorType.barrierClosed);
        }
      } catch (e) {
        onError(e.toString(), ErrorType.exceptionError);
      }
    } else {
      onError("OS must be Android", ErrorType.osNotSupported);
    }
    return Future.value();
  }

  // from account_picker package
  Future<void> showEmailHint({
    required Function(String email, String type) onSuccess,
    required Function(String error, ErrorType errorType) onError,
  }) async {
    if (Platform.isAndroid) {
      try {
        final EmailResult? emailResult = await AccountPicker.emailHint();
        if (emailResult != null) {
          onSuccess(emailResult.email, emailResult.type);
        } else {
          onError("Nothing is picked", ErrorType.barrierClosed);
        }
      } catch (e) {
        onError(e.toString(), ErrorType.exceptionError);
      }
    } else {
      onError("OS must be Android", ErrorType.osNotSupported);
    }
    return Future.value();
  }

  /* from account_picker package
    Future<void> showPhoneHint({
      required Function(String phone) onSuccess,
      required Function(String error, ErrorType errorType) onError,
    }) async {
      if (Platform.isAndroid) {
        int sdkInt = androidInfo?.version.sdkInt ?? 0;
        if (sdkInt >= 31) {
          onError("This feature is currently not available on Android 12 & above",
              ErrorType.osVersionNotSupported);
        } else {
          try {
            final String? phone = await AccountPicker.phoneHint();
            if (phone != null) {
              onSuccess(phone);
            } else {
              onError("Nothing is picked", ErrorType.barrierClosed);
            }
          } catch (e) {
            onError(e.toString(), ErrorType.exceptionError);
          }
        }
      } else {
        onError("OS must be Android", ErrorType.osNotSupported);
      }
      return Future.value();
    }*/
}
