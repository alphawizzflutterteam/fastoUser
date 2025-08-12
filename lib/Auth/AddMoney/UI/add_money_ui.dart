import 'package:flutter/material.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/utils/Session.dart';

import 'add_money_interactor.dart';

class AddMoneyUI extends StatefulWidget {
  final AddMoneyInteractor addMoneyInteractor;

  AddMoneyUI(this.addMoneyInteractor);

  @override
  _AddMoneyUIState createState() => _AddMoneyUIState();
}

class _AddMoneyUIState extends State<AddMoneyUI> {
  TextEditingController _cardNumberController =
      TextEditingController(text: '5555 5555 5555 5555');
  TextEditingController _expiryController =
      TextEditingController(text: '12/25');
  TextEditingController _cvvController = TextEditingController(text: '666');
  TextEditingController _amountController =
      TextEditingController(text: '₹ 500.00');

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: Text(
          getTranslated(context, "WALLET") ?? 'Wallet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Container(
              height: size.height + 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      getTranslated(context, 'ADD_WALLET_MONEY')!,
                      style:
                          theme.textTheme.headlineLarge!.copyWith(fontSize: 35),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      getTranslated(context, 'PAYMENT_MADE_EASY')!,
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: theme.hintColor, fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Expanded(
                    child: Container(
                      height: 600,
                      color: theme.colorScheme.background,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Spacer(),
                          EntryField(
                            controller: _cardNumberController,
                            label: getTranslated(context, 'CARD_NUMBER'),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: EntryField(
                                  controller: _expiryController,
                                  label: getTranslated(context, 'EXPIRY_DATE'),
                                ),
                              ),
                              Expanded(
                                child: EntryField(
                                  controller: _cvvController,
                                  label: getTranslated(context, 'CVV_CODE'),
                                ),
                              ),
                            ],
                          ),
                          EntryField(
                            controller: _amountController,
                            label: getTranslated(context, 'ENTER_AMOUNT'),
                          ),
                          Spacer(flex: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: getTranslated(context, 'SKIP'),
                  onTap: () => widget.addMoneyInteractor.skip(),
                  color: theme.scaffoldBackgroundColor,
                  textColor: theme.primaryColor,
                ),
              ),
              Expanded(
                child: CustomButton(
                  text: getTranslated(context, 'ADD_MONEY'),
                  onTap: () => widget.addMoneyInteractor.addMoney(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
