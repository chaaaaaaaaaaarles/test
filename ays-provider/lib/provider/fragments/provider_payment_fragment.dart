import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/fragments/shimmer/provider_payment_shimmer.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderPaymentFragment extends StatefulWidget {
  const ProviderPaymentFragment({Key? key}) : super(key: key);

  @override
  State<ProviderPaymentFragment> createState() => _ProviderPaymentFragmentState();
}

class _ProviderPaymentFragmentState extends State<ProviderPaymentFragment> {
  List<PaymentData> list = [];
  Future<List<PaymentData>>? future;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    future = getPaymentAPI(page, list, (p0) {
      isLastPage = p0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SnapHelperWidget<List<PaymentData>>(
          future: future,
          loadingWidget: ProviderPaymentShimmer(),
          onSuccess: (data) {
            return AnimatedListView(
              itemCount: list.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(8),
              physics: AlwaysScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              onSwipeRefresh: () async {
                page = 1;

                init();
                setState(() {});

                return await 2.seconds.delay;
              },
              onNextPage: () {
                if (!isLastPage) {
                  page++;

                  init();
                  setState(() {});
                }
              },
              itemBuilder: (p0, index) {
                PaymentData data = list[index];

                return GestureDetector(
                  onTap: () {
                    BookingDetailScreen(bookingId: data.bookingId).launch(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    width: context.width(),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: context.scaffoldBackgroundColor,
                      border: Border.all(color: context.dividerColor, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
                          ),
                          width: context.width(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data.customerName.validate(), style: boldTextStyle()).flexible(),
                              Text('#' + data.bookingId.validate().toString(), style: boldTextStyle(color: primaryColor))
                            ],
                          ),
                        ),
                        4.height,
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.lblPaymentID, style: secondaryTextStyle(size: 16)),
                                Text("#" + data.id.validate().toString(), style: boldTextStyle()),
                              ],
                            ).paddingSymmetric(vertical: 4),
                            Divider(thickness: 0.9, color: context.dividerColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.paymentStatus, style: secondaryTextStyle(size: 16)),
                                Text(
                                  data.paymentStatus.validate().capitalizeFirstLetter().replaceAll('_', ' '),
                                  style: boldTextStyle(),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 4),
                            Divider(thickness: 0.9, color: context.dividerColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.paymentMethod, style: secondaryTextStyle(size: 16)),
                                Text((data.paymentMethod.validate().isNotEmpty ? data.paymentMethod.validate() : languages.notAvailable).capitalizeFirstLetter(), style: boldTextStyle()),
                              ],
                            ).paddingSymmetric(vertical: 4),
                            Divider(thickness: 0.9, color: context.dividerColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.lblAmount, style: secondaryTextStyle(size: 16)),
                                if (data.isPackageBooking)
                                  PriceWidget(
                                    price: data.packageData!.price.validate(),
                                    color: primaryColor,
                                    size: 16,
                                    isBoldText: true,
                                  )
                                else
                                  PriceWidget(
                                    price: calculateTotalAmount(
                                      servicePrice: data.price.validate(),
                                      qty: data.quantity.validate(),
                                      couponData: data.couponData != null ? data.couponData : null,
                                      taxes: data.taxes.validate(),
                                      serviceDiscountPercent: data.discount.validate(),
                                      extraCharges: data.extraCharges,
                                    ),
                                    color: primaryColor,
                                    size: 16,
                                    isBoldText: true,
                                  ),
                              ],
                            ).paddingSymmetric(vertical: 4),
                          ],
                        ).paddingSymmetric(horizontal: 16, vertical: 10),
                        // 8.height,
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading && page != 1)),
      ],
    );
  }
}
