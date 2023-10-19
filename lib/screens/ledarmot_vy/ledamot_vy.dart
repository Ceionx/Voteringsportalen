import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:template/theme.dart';
import '../../api/api_ledamotview/api_ledarmot_vy_votering.dart';
import '../../models/model_ledamotview_votering.dart';
import '../../provider/provider_ledamot.dart';
import '../../widgets/widget_voterings_card.dart';
import './ledamot_vy_info.dart';
import 'ledarmot_vy_stat_bar.dart';
import '../../widgets/widget_voteresult_piechart.dart';

class LedamotVy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<voteringar> theList = context.watch<ProviderLedamot>().theList;

    Future<List<voteringar>> fetchData() async {
      final List<voteringar> data =
          await context.read<ProviderLedamot>().getList();
      context.read<ProviderLedamot>().setStat(data);
      return data;
    }

    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<List<voteringar>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: AppColors.blue));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No data available.');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return LedamotVyInfo();
                  } else if (index == 1) {
                    Map votesNumbers =
                        context.watch<ProviderLedamot>().antalSvarMap;

                    return VoteResult(
                      ja: context.watch<ProviderLedamot>().antalJa,
                      nej: context.watch<ProviderLedamot>().antalNej,
                      avstar: context.watch<ProviderLedamot>().antalAvstar,
                      franvarande:
                          context.watch<ProviderLedamot>().antalFranvarande,
                    );
                  }
                  int adjustedIndex = index - 2;

                  String rawDatum = '2020-20-20 00 00';
                  String datum = (rawDatum != null && rawDatum.length >= 10)
                      ? rawDatum.substring(0, 10)
                      : rawDatum;

                  return FutureBuilder<voteringar>(
                    future: context
                        .read<ProviderLedamot>()
                        .setTitle(snapshot.data![adjustedIndex]),
                    builder: (context, cardSnapshot) {
                      if (cardSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Voteringar(
                          identification: '',
                          title: '',
                          subTitle: '',
                          decisionDate: '',
                          isAccepted: '',
                        );
                      } else if (cardSnapshot.hasError) {
                        return Text('Error: ${cardSnapshot.error}');
                      } else if (!cardSnapshot.hasData ||
                          cardSnapshot.data == null) {
                        return Text(
                            'No additional data available for this card.');
                      } else {
                        return Voteringar(
                          identification:
                              snapshot.data![adjustedIndex].beteckning,
                          title: snapshot.data![adjustedIndex].titel,
                          subTitle: snapshot.data![adjustedIndex].underTitel,
                          decisionDate: datum,
                          isAccepted: snapshot.data![adjustedIndex].rost,
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ));
  }
}
