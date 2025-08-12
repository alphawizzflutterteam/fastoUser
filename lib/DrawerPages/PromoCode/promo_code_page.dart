import 'package:flutter/material.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/Locale/locale.dart';
import 'package:pristine_andaman/Locale/strings_enum.dart';
import 'package:pristine_andaman/utils/Session.dart';

class PromoCodePage extends StatefulWidget {
  @override
  _PromoCodePageState createState() => _PromoCodePageState();
}

class _PromoCodePageState extends State<PromoCodePage> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslated(context, "PROMO_CODE") ?? "Promo Code",
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  getTranslated(context, 'ENTER')! +
                      ' ' +
                      context.getString(Strings.PROMO_CODE)!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text(
                  context.getString(Strings.ENTER_PROMO_CODE_TO)!,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.hintColor, fontSize: 12),
                ),
              ),
              EntryField(
                controller: _controller,
                hint: context.getString(Strings.ENTER_CODE_HERE),
              ),
              SizedBox(height: 20),
              CustomButton(text: context.getString(Strings.APPLY_PROMO_CODE)),
              Expanded(
                child: Container(
                  color: theme.colorScheme.background,
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        context.getString(Strings.SHARE_REF_CODE)!,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          context.getString(Strings.SHARE_YOUR_REF)!,
                          style: theme.textTheme.bodyMedium!
                              .copyWith(color: theme.hintColor, fontSize: 12),
                        ),
                      ),
                      Spacer(),
                      Text(
                        context.getString(Strings.YOUR_REF_CODE)!,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: theme.hintColor, fontSize: 12),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                            color: theme.cardColor,
                            border: Border.all(
                                color: theme.primaryColorLight, width: 0.2)),
                        child: Text(
                          'QM21410',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              CustomButton(
                text: context.getString(Strings.SHARE_CODE),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
