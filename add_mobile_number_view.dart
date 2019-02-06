import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:venue_booking/ErrorPages/ErrorView.dart';
import 'package:venue_booking/Modules/Blocks/blocProvider.dart';
import 'package:venue_booking/Modules/MobileNumberValidation/add_mobile_api.dart';
import 'package:venue_booking/Modules/MobileNumberValidation/add_mobile_bloc.dart';
import 'package:venue_booking/Modules/VerifyOTP/verify_otp_view.dart';

class AddMobileView extends StatefulWidget {
  @override
  AddMobileViewState createState() {
    return new AddMobileViewState();
  }
}

class AddMobileViewState extends State<AddMobileView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoadingControllerBloc>(
      builder: (_, bloc) => bloc ?? LoadingControllerBloc(),
      onDispose: (_, bloc) => bloc.dispose(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.fallback(),
        home: Scaffold(
          body: OfflineBuilder(
              connectivityBuilder: (context, connectivityResult, child) {
                final bool connected =
                    connectivityResult != ConnectivityResult.none;
                if (!connected) {
                  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
                  //_showSnackBar("asdasda", context);
                  return ErrorView(
                    errorType: ErrorType.noInternet,
                  );
                }
                return child;
              },
              child: AddMobileMainView()),
        ),
      ),
    );
  }
}

class AddMobileMainView extends StatefulWidget {
  @override
  _AddMobileMainViewState createState() => _AddMobileMainViewState();
}

class _AddMobileMainViewState extends State<AddMobileMainView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget title() => Container(
        margin: EdgeInsets.all(15.0),
        child: Text("What’s Your Contact Number?",
            style: const TextStyle(
                color: const Color(0xff000000),
                fontWeight: FontWeight.w700,
                fontFamily: "GoogleSans",
                fontStyle: FontStyle.normal,
                fontSize: 33.8)),
      );

  Widget subTitle() => Container(
      margin: EdgeInsets.only(right: 15, left: 15),
      child: Text(
          "We need your number to authenticate your identity through OTP verification. We will keep your privacy as ours. Please enter your number below.",
          style: const TextStyle(
              color: const Color(0xffc7c7c7),
              fontWeight: FontWeight.w400,
              fontFamily: "GoogleSans",
              fontStyle: FontStyle.normal,
              fontSize: 16.7)));
  @override
  Widget build(BuildContext context) {
    final loadingBloc = Provider.of<LoadingControllerBloc>(context);
    return StreamBuilder<ApiStatus>(
      initialData: ApiStatus(status: APIStatus.done),
      stream: loadingBloc.isLoadingStream,
      builder: (context, snapshot) {
        print(snapshot.data.status ?? "");
        return ModalProgressHUD(
          inAsyncCall: snapshot.data.status == APIStatus.waiting ?? false,
          opacity: 0.5,
          dismissible: true,
          progressIndicator: CircularProgressIndicator(),
          child: SafeArea(
            child: (snapshot.data.status == APIStatus.error ?? false)
                ? ErrorView(
                    errorType: ErrorType.serverError,
                  )
                : ListView(
                    children: <Widget>[
                      Container(
                        height: 64,
                      ),
                      title(),
                      subTitle(),
                      BlocProvider<AddMobileBloc>(
                          builder: (_, bloc) => bloc ?? AddMobileBloc(),
                          onDispose: (_, bloc) => bloc.dispose(),
                          child: AddMobileBottomView()),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

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
