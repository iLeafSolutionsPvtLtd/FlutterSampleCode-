import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:venue_booking/ErrorPages/ErrorView.dart';
import 'package:venue_booking/Modules/Blocks/blocProvider.dart';
import 'package:venue_booking/Modules/MobileNumberValidation/add_mobile_bloc.dart';
import 'package:venue_booking/Modules/MobileNumberValidation/add_mobile_number_view.dart';

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
