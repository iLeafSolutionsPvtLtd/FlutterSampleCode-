import 'package:flutter/material.dart';
import 'package:venue_booking/Modules/Blocks/blocProvider.dart';
import 'package:venue_booking/Modules/MobileNumberValidation/add_mobile_api.dart';
import 'package:venue_booking/Modules/MobileNumberValidation/add_mobile_bloc.dart';
import 'package:venue_booking/Modules/VerifyOTP/verify_otp_view.dart';

class AddMobileBottomView extends StatefulWidget {
  @override
  _AddMobileBottomViewState createState() => _AddMobileBottomViewState();
}

class _AddMobileBottomViewState extends State<AddMobileBottomView> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addMobileBloc = Provider.of<AddMobileBloc>(context);

    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Container(
                      height: 15,
                    ),
                    Image(
                      image: AssetImage('assets/phoneIcon.png'),
                      height: 28.0,
                      fit: BoxFit.fill,
                    )
                  ],
                ),
                Flexible(
                    child: Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: StreamBuilder(
                          stream: addMobileBloc.mobileNumber,
                          builder: (context, snapshot) => TextField(
                                onChanged: addMobileBloc.mobileNumberChanged,
                                keyboardType: TextInputType.number,
                                controller: myController,
                                decoration: InputDecoration(
                                    //border: OutlineInputBorder(),
                                    hintText: "Enter your mobile number",
                                    errorText: snapshot.error),
                              ),
                        )))
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: addMobileBloc.submitCheck,
                    builder: (context, snapshot) => RawMaterialButton(
                          onPressed: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            final statusCode = AddMobileApi(
                                    mobileNumber: myController.text,
                                    context: context)
                                .generateOtp();
                            statusCode.then((value) {
                              if (snapshot.hasData && value == 200) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VerifyOTPView(myController.text)),
                                );
                              }
                            });
                          },
                          child: new Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 26.0,
                          ),
                          shape: new CircleBorder(),
                          elevation: 2.0,
                          fillColor:
                              snapshot.hasData ? Colors.green : Colors.grey,
                          padding: const EdgeInsets.all(15.0),
                        ))
              ],
            )
          ],
        ));
  }
}
