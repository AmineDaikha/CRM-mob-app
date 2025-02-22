import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/constants/utils.dart';
import 'package:mobilino_app/models/client.dart';
import 'package:mobilino_app/models/command.dart';
import 'package:mobilino_app/models/product.dart';
import 'package:mobilino_app/providers/clients_map_provider.dart';
import 'package:mobilino_app/screens/home_page/add_opportunity_page.dart';
import 'package:mobilino_app/styles/colors.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:mobilino_app/screens/home_page/init_store_page.dart';
import 'activities_pages/activity_list_page.dart';

//import 'clients_list_fragment.dart';
import 'command_delivred_page.dart';
import 'command_page.dart';
import 'devis_page.dart';
import 'opportunity_page.dart';

class CalanderFragment extends StatefulWidget {
  const CalanderFragment({super.key});

  @override
  State<CalanderFragment> createState() => _CalanderFragmentState();
}

class _CalanderFragmentState extends State<CalanderFragment> {
  List<Appointment> meetings = <Appointment>[];

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      appointmentTimeTextFormat: 'HH:mm',
      // 24-hour format
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        timeFormat: 'HH:mm', // Set time format to 24-hour
      ),
      onLongPress: (details) {
        // Handle long press event here
        addNewOppCalander(details, context);
      },
      onViewChanged: (ViewChangedDetails viewChangedDetails) {
        print('changed!!!');
        // Get the start date and end date of the current week
        DateTime startDate = viewChangedDetails.visibleDates[0];
        DateTime endDate = viewChangedDetails
            .visibleDates[viewChangedDetails.visibleDates.length - 1];

        print('Start Date: $startDate');
        print('End Date: $endDate');
        fetchData(startDate, endDate).then((value) {
          setState(() {});
        });
      },
      view: CalendarView.week,
      firstDayOfWeek: DateTime.sunday,
      dataSource: MeetingDataSource(getAppointments()),
      todayHighlightColor: primaryColor,
      selectionDecoration: BoxDecoration(
        border: Border.all(
          // Change the border color here
          color: Colors.red, // Change this color to your desired color
          width: 2.0, // Adjust the border width as needed
        ),
      ),
      onTap: (details) => calendarTapped(context, details),
      // initialDisplayDate: DateTime(2021),
      // initialSelectedDate: DateTime.now(),
    );
  }
  void addNewOppCalander(CalendarLongPressDetails details, BuildContext context) {
    // Handle long press event here
    print('Long press at ${details.date}');
    if (details.appointments != null && details.appointments!.isNotEmpty) {
    } else {
      Client client = Client();
      PageNavigator(ctx: context).nextPage(
          page: AddOpportunityPage(
            proposedStart: details.date,
          ));
    }
  }
  Future<void> fetchData(DateTime start, DateTime end) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.mapClientsCalander = [];
    int? equipe;
    String collaborator = AppUrl.user.userId!;
    if (AppUrl.filtredOpporunity.team!.id! != -1)
      equipe = AppUrl.filtredOpporunity.team!.id!;
    if (AppUrl.filtredOpporunity.collaborateur!.id != null) {
      if (AppUrl.filtredOpporunity.collaborateur!.id! != '-1') {
        collaborator = AppUrl.filtredOpporunity.collaborateur!.userName!;
      }
    } else {
      collaborator = AppUrl.filtredOpporunity.collaborateur!.userName!;
    }
    var body = jsonEncode({
      "filter": null,
      "equipe": equipe,
      "tiers": null,
      "priorite": null,
      "urgence": null,
      "collaborateur": collaborator,
      "collaborateurs": [],
      "dateDebut": DateFormat('yyyy-MM-ddT00:00:00').format(start),
      "dateFin": DateFormat('yyyy-MM-ddT23:59:59').format(end)
    });
    http.Response req = await http
        .post(Uri.parse(AppUrl.opportunitiesFiltred), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res opp code : ${req.statusCode}");
    print("res opp body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of opportunities calander: ${data.toList().length}');
      //addOppurtonities(data);
      //data.toList().forEach((element) async {
      for (var element in data.toList()) {
        print('id client:  ${element['tiersId']}');
        print('id opp:  ${element['code']}');
        print('etapeId: ${element['etapeId']}');
        String pcfCode = element['tiersId'];
        req = await http.get(Uri.parse(AppUrl.getOneTier + pcfCode), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
        print("res tier code: ${req.statusCode}");
        print("res tier body: ${req.body}");
        if (req.statusCode == 200) {
          var res = json.decode(req.body);
          LatLng latLng;
          if (res['longitude'] == null || res['latitude'] == null)
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          else{
            try {
              latLng = LatLng(res['latitude'], res['longitude']);
            }catch(e){
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            }
          }

          Client client = new Client(
            idOpp: element['code'].toString(),
            id: res['code'],
            type: res['type'],
            name: res['rs'],
            name2: res['rs2'],
            phone2: res['tel2'],
            total: element['montant'].toString(),
            phone: res['tel1'],
            city: res['ville'],
            location: latLng,
            stat: element['etapeId'],
            priority: element['priorite'],
            emergency: element['urgence'],
            lib: element['libelle'],
            resOppo: element,
            dateStart: DateTime.parse(element['dateDebut']),
            dateCreation: DateTime.parse(element['dateCreation']),
          );
          //if(element['etapeId'] == 1 || element['etapeId'] == 2)
          provider.mapClientsCalander.add(client);
          print('size of opp: ${provider.mapClientsCalander.length}');
        }
      }
      provider.mapClientsCalander
          .sort((a, b) => b.dateStart!.compareTo(a.dateStart!));
    } else {
      print('Failed to load data');
    }
    provider.updateList();
  }

  void calendarTapped(BuildContext context, CalendarTapDetails details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      Client client = details.appointments![0].id;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 270,
            child: Dialog(
              child: Container(
                height: 270,
                width: double.infinity,
                child: Column(
                  children: [
                    ClientItem(
                      client: client,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                    ),
                  ],
                ),
                // child: GestureDetector(
                //   onTap: () {
                //     PageNavigator(ctx: context).nextPage(
                //         page: OpportunityPage(
                //       client: client,
                //     ));
                //   },
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Client: ${client.lib}',
                //         style: Theme.of(context).textTheme.headline4,
                //       ),
                //       Text(
                //         'Début: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(details.appointments![0].startTime)}',
                //         style: Theme.of(context).textTheme.headline4,
                //       ),
                //       //Text('End Time: ${details.appointments![0].endTime}'),
                //     ],
                //   ),
                // ),
              ),
            ),
          );
        },
      );
    }
    // String date = calendarTapDetails.date.toString().split(' ')[0];
    // for (int i = 0; i < meetings.length; i++) {
    //   if (date == meetings[0].startTime.toString().split(' ')[0]) {
    //     _showDialog(context, date);
    //     break;
    //   }
    // }
  }

  void _showDialog(BuildContext context, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 600,
            child: Column(
              children: <Widget>[
                Text(
                  'List des opportunités de ${date}',
                  style: Theme.of(context).textTheme.headline4,
                ),
                Container(
                  height: 600,
                  //child: ClientListFragment(),
                ),
              ],
            ),
          ),
        );
        // return AlertDialog(
        //   title: Text('List des clients de ${date}'),
        //   content: Text('This is the dialog content.'),
        //   actions: [
        //     ElevatedButton(
        //       child: Text('Close'),
        //       onPressed: () {
        //         Navigator.of(context).pop(); // Close the dialog
        //       },
        //     ),
        //   ],
        // );
      },
    );
  }

  List<Appointment> getAppointments() {
    meetings = <Appointment>[];
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    for (int i = 0; i < provider.mapClientsCalander.length; i++) {
      Client client = provider.mapClientsCalander[i];
      final DateTime startTime = client.dateStart!;
//    DateTime(today.year, today.month, today.day, 9, 0, 0);
      final DateTime endTime = client.dateStart!.add(const Duration(hours: 1));

      meetings.add(Appointment(
          id: client,
          startTime: startTime,
          endTime: endTime,
          subject: '${client.name}',
          color: primaryColor,
          //recurrenceRule: 'FREQ=DAILY;COUNT=10',
          isAllDay: false));
    }
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class ClientItem extends StatefulWidget {
  final Client client;

  const ClientItem({super.key, required this.client});

  @override
  State<ClientItem> createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItem> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  double total = 0;

  // Function to fetch JSON data from an API
  Future<void> fetchData(Client client) async {
    print('stat: ${client.stat}');
    String url = AppUrl.commandsOfOpportunite +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.idOpp!;
    if (client.stat == 3 || client.stat == 5)
      url = AppUrl.deliveryOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
    print('url of CmdOfOpp $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmdOpp code : ${req.statusCode}");
    print("res cmdOpp body: ${req.body}");
    if (req.statusCode == 200) {
      respone = 200;
      icon = Image.asset('assets/caddie_rempli.png');
      var res = json.decode(req.body);
      widget.client.res = res;
      total = res['brut'];
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      try {
        List<Product> products = [];
        await Future.forEach(data.toList(), (element) async {
          double remise = 0;
          double tva = 0;
          if (element['natTvatx'] != null) tva = element['natTvatx'];
          if (element['remise'] != null) remise = element['remise'];
          print('quantité: ${element['qte'].toString()}');
          double d = element['qte'];
          int quantity = d.toInt();
          // double dStock = element['stockDep'];
          // int quantityStock = dStock.toInt();
          var artCode = element['artCode'];
          print('imghhh $artCode');
          print('url: ${AppUrl.getUrlImage + '$artCode'}');
          http.Response req = await http
              .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
          });
          print("res imgArticle code : ${req.statusCode}");
          print("res imgArticle body: ${req.body}");
          if (req.statusCode == 200) {
            List<dynamic> data = json.decode(req.body);
            var path = null;
            if (data.length > 0) {
              var item = data.first;
              print('item: ${item['path']}');
              path = AppUrl.baseUrl + item['path'];
              print('price: ${element['pPrv']} ${element['pBrut']} ');
              double total = 0;
              if (element['total'] != null)
                total = element['total'];
              else if (element['cout'] != null) total = element['cout'];
            }
            products.add(Product(
                quantity: quantity,
                price: element['pBrut'],
                total: total,
                remise: remise,
                tva: tva,
                id: element['artCode'],
                image: path,
                name: element['lib']));
          }
        }).then((value) {
          client.command = Command(
              res: res,
              id: res['numero'],
              date: DateTime.parse(res['date']),
              total: 0,
              paid: 0,
              products: products,
              nbProduct: products.length);
          print('size of products: ${products.length}');
        });

        // get image
      } catch (e, stackTrace) {
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
    }
    else {
      url = AppUrl.devisOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
      print('url of devisOfOpp $url');
      req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res devisOpp code : ${req.statusCode}");
      print("res devisOpp body: ${req.body}");
      if(req.statusCode == 200){
        respone = 200;
        icon = Icon(Icons.shopping_cart_checkout_sharp, color: Colors.orange,);
        print('rfrrfrfr: orange!');
        var res = json.decode(req.body);
        widget.client.res = res;
        total = res['brut'];
        List<dynamic> data = res['lignes'];
        print('sizeof: ${data.length}');
        try {
          List<Product> products = [];
          await Future.forEach(data.toList(), (element) async {
            double remise = 0;
            double tva = 0;
            if (element['natTvatx'] != null) tva = element['natTvatx'];
            if (element['remise'] != null) remise = element['remise'];
            print('quantité: ${element['qte'].toString()}');
            double d = element['qte'];
            int quantity = d.toInt();
            // double dStock = element['stockDep'];
            // int quantityStock = dStock.toInt();
            var artCode = element['artCode'];
            print('imghhh $artCode');
            print('url: ${AppUrl.getUrlImage + '$artCode'}');
            http.Response req = await http
                .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
            });
            print("res imgArticle code : ${req.statusCode}");
            print("res imgArticle body: ${req.body}");
            if (req.statusCode == 200) {
              List<dynamic> data = json.decode(req.body);
              var path = null;
              if (data.length > 0) {
                var item = data.first;
                print('item: ${item['path']}');
                path = AppUrl.baseUrl + item['path'];
                print('price: ${element['pPrv']} ${element['pBrut']} ');
                double total = 0;
                if (element['total'] != null)
                  total = element['total'];
                else if (element['cout'] != null) total = element['cout'];
              }
              products.add(Product(
                  quantity: quantity,
                  price: element['pBrut'],
                  total: total,
                  remise: remise,
                  tva: tva,
                  id: element['artCode'],
                  image: path,
                  name: element['lib']));
            }
          }).then((value) {
            client.command = Command(
                res: res,
                id: res['numero'],
                date: DateTime.parse(res['date']),
                total: 0,
                paid: 0,
                products: products,
                nbProduct: products.length);
            print('size of products: ${products.length}');
            widget.client.command!.type = 'Devis';
          });

          // get image
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      }
      else{
        respone = 404;
        client.command = null;
      }
    }
    print('command of ${client.name} ${client.id} is: ${client.command}');
    client.total = total.toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showLoaderDialog(context);
    //   fetchData().then((value) {
    //     Navigator.pop(context);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    double priorityrating = 0;
    double emergencyrating = 0;
    if (widget.client.priority != null)
      priorityrating = widget.client.priority!.toDouble();
    if (widget.client.emergency != null)
      emergencyrating = widget.client.emergency!.toDouble();
    print('lib: ${widget.client.priority}');
    // print('sss: ${widget.client.total}');
    // if (widget.client.total != null){
    //   if (double.parse(widget.client.total.toString()) > 0) {
    //   color = primaryColor;
    // } else if (double.parse(widget.client.total.toString()) < 0) {
    //   color = Colors.red;
    // }}
    return FutureBuilder(
        future: fetchData(widget.client),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
                      child: Text("Loading...")),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError} ');
            return Text('Error: ${snapshot.error}');
          } else{
            print('states is:: ${widget.client.stat} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
            print('condition: ${(AppUrl.filtredOpporunity.pipeline!.steps
                .where((element) => element.id == widget.client.stat!)
                .length ==
                0)}');
            if (AppUrl.filtredOpporunity.pipeline!.steps
                .where((element) => element.id == widget.client.stat!)
                .length ==
                0) return Container();
            return InkWell(
              onTap: () {
                PageNavigator(ctx: context).nextPage(
                    page: OpportunityPage(
                      client: widget.client,
                    ));
              },
              child: Column(
                children: [
                  Container(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          color: primaryColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.client.lib != null)
                                ? Text(
                              widget.client.lib!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            )
                                : Text('Nom de l\'Affaire',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: Colors.black)),
                            Text('Client: ${widget.client.name!}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Text('Ville : ${widget.client.city}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, color: primaryColor, size: 20),
                                SizedBox(width: 7,),
                                Text('${DateFormat('dd-MM-yyyy')
                                    .format(widget.client.dateStart!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith()),
                                SizedBox(width: 20,),
                                Icon(Icons.access_time, color: primaryColor, size: 20),
                                SizedBox(width: 7,),
                                Text('${DateFormat('HH:mm')
                                    .format(widget.client.dateStart!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith()),
                              ],
                            ),
                            (widget.client.command != null)
                                ? Text(
                              '${AppUrl.formatter.format(widget.client.command!.total)} DZD',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                  color: color,
                                  fontWeight: FontWeight.normal),
                            )
                                : Text(
                              '${AppUrl.formatter.format(0)} DZD',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                  color: color,
                                  fontWeight: FontWeight.normal),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Priorité: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: priorityrating,
                                  minRating: 1.0,
                                  maxRating: 5.0,
                                  itemCount: 5,
                                  itemSize: 25,
                                  // Number of stars
                                  itemBuilder: (context, index) => Icon(
                                    index >= priorityrating
                                        ? Icons.star_border_outlined
                                        : Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Urgence: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: emergencyrating,
                                  minRating: 1.0,
                                  maxRating: 5.0,
                                  itemCount: 5,
                                  itemSize: 25,
                                  // Number of stars
                                  itemBuilder: (context, index) => Icon(
                                    index >= emergencyrating
                                        ? Icons.star_border_outlined
                                        : Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        Visibility(
                          visible: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (widget.client.phone != null)
                                      PhoneUtils()
                                          .makePhoneCall(widget.client.phone!);
                                    else
                                      _showAlertDialog(context,
                                          'Aucun numéro de téléphone pour ce client');
                                  },
                                  icon: Icon(
                                    Icons.call,
                                    color: primaryColor,
                                  )),
                              IconButton(
                                onPressed: () {
                                  print('client; ${widget.client.command}');
                                  if (respone == 200) {
                                    if(widget.client.command!.type == 'Devis'){
                                      PageNavigator(ctx: context).nextPage(
                                          page: DevisPage(
                                            client: widget.client,
                                          ));
                                    }else
                                    if (widget.client.stat == 3 ||
                                        widget.client.stat == 5)
                                      PageNavigator(ctx: context).nextPage(
                                          page: CommandDelivredPage(
                                            client: widget.client,
                                          ));
                                    else
                                      PageNavigator(ctx: context).nextPage(
                                          page: CommandPage(
                                            client: widget.client,
                                          ));
                                  } else
                                    PageNavigator(ctx: context).nextPage(
                                        page: StorePage(
                                          client: widget.client,
                                        ));
                                  //Navigator.pushNamed(context, '/home/command', arguments: client);
                                },
                                icon: (respone == 200)
                                    ? icon //Image.asset('assets/caddie_rempli.png')
                                    : icon, //Icon(Icons.shopping_cart_outlined),
                                color: primaryColor,
                              ),
                              IconButton(
                                  onPressed: () {
                                    PageNavigator(ctx: context).nextPage(
                                        page: ActivityListPage(
                                          client: widget.client,
                                        ));
                                  },
                                  icon: Icon(
                                    Icons.local_activity_outlined,
                                    color: primaryColor,
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  )
                ],
              ),
            );}
        });
  }
}

// class ClientItem extends StatefulWidget {
//   final Client client;
//
//   const ClientItem({super.key, required this.client});
//
//   @override
//   State<ClientItem> createState() => _ClientItemState();
// }
//
// class _ClientItemState extends State<ClientItem> {
//   List<String> items = [
//     'A visité',
//     'Visité',
//     'Livré',
//     'Encaissé',
//     'Livré & encaissé',
//     'Annulée'
//   ];
//   Widget icon = Icon(Icons.shopping_cart_outlined);
//   int respone = 200;
//   double total = 0;
//
//   // Function to fetch JSON data from an API
//   Future<void> fetchData(Client client) async {
//     print('stat: ${client.stat}');
//     String url = AppUrl.commandsOfOpportunite +
//         AppUrl.user.etblssmnt!.code! +
//         '/' +
//         widget.client.idOpp!;
//     if (client.stat == 3 || client.stat == 5)
//       url = AppUrl.deliveryOfOpportunite +
//           AppUrl.user.etblssmnt!.code! +
//           '/' +
//           widget.client.idOpp!;
//     print('url of CmdOfOpp $url');
//     http.Response req = await http.get(Uri.parse(url), headers: {
//       "Accept": "application/json",
//       "content-type": "application/json; charset=UTF-8",
//       "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
//     });
//     print("res cmdOpp code : ${req.statusCode}");
//     print("res cmdOpp body: ${req.body}");
//     if (req.statusCode == 200) {
//       respone = 200;
//       icon = Image.asset('assets/caddie_rempli.png');
//       var res = json.decode(req.body);
//       widget.client.res = res;
//       total = res['brut'];
//       List<dynamic> data = res['lignes'];
//       print('sizeof: ${data.length}');
//       try {
//         List<Product> products = [];
//         await Future.forEach(data.toList(), (element) async {
//           double remise = 0;
//           double tva = 0;
//           if (element['natTvatx'] != null) tva = element['natTvatx'];
//           if (element['remise'] != null) remise = element['remise'];
//           print('quantité: ${element['qte'].toString()}');
//           double d = element['qte'];
//           int quantity = d.toInt();
//           // double dStock = element['stockDep'];
//           // int quantityStock = dStock.toInt();
//           var artCode = element['artCode'];
//           print('imghhh $artCode');
//           print('url: ${AppUrl.getUrlImage + '$artCode'}');
//           http.Response req = await http
//               .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
//             "Accept": "application/json",
//             "content-type": "application/json; charset=UTF-8",
//             "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
//           });
//           print("res imgArticle code : ${req.statusCode}");
//           print("res imgArticle body: ${req.body}");
//           if (req.statusCode == 200) {
//             List<dynamic> data = json.decode(req.body);
//             var path = null;
//             if (data.length > 0) {
//               var item = data.first;
//               print('item: ${item['path']}');
//               path = AppUrl.baseUrl + item['path'];
//               print('price: ${element['pPrv']} ${element['pBrut']} ');
//               double total = 0;
//               if (element['total'] != null)
//                 total = element['total'];
//               else if (element['cout'] != null) total = element['cout'];
//             }
//             products.add(Product(
//                 quantity: quantity,
//                 price: element['pBrut'],
//                 total: total,
//                 remise: remise,
//                 tva: tva,
//                 id: element['artCode'],
//                 image: path,
//                 name: element['lib']));
//           }
//         }).then((value) {
//           client.command = Command(
//               res: res,
//               id: res['numero'],
//               date: DateTime.parse(res['date']),
//               total: 0,
//               paid: 0,
//               products: products,
//               nbProduct: products.length);
//           print('size of products: ${products.length}');
//         });
//
//         // get image
//       } catch (e, stackTrace) {
//         print('Exception: $e');
//         print('Stack trace: $stackTrace');
//       }
//     } else {
//       respone = 404;
//       client.command = null;
//     }
//     print('command of ${client.name} ${client.id} is: ${client.command}');
//     client.total = total.toString();
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   showLoaderDialog(context);
//     //   fetchData().then((value) {
//     //     Navigator.pop(context);
//     //   });
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Color color = Colors.grey;
//     double priorityrating = 0;
//     double emergencyrating = 0;
//     if (widget.client.priority != null)
//       priorityrating = widget.client.priority!.toDouble();
//     if (widget.client.emergency != null)
//       emergencyrating = widget.client.emergency!.toDouble();
//     print('lib: ${widget.client.priority}');
//     if (double.parse(widget.client.total.toString()) > 0) {
//       color = primaryColor;
//     } else if (double.parse(widget.client.total.toString()) < 0) {
//       color = Colors.red;
//     }
//     return FutureBuilder(
//         future: fetchData(widget.client),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Future is still running, return a loading indicator or some placeholder.
//             return Center(
//               child: Row(
//                 children: [
//                   CircularProgressIndicator(
//                     color: primaryColor,
//                   ),
//                   Container(
//                       margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
//                       child: Text("Loading...")),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             // There was an error in the future, handle it.
//             print('Error: ${snapshot.hasError}');
//             return Text('Error: ${snapshot.error}');
//           } else {
//             Color color = Colors.grey;
//             double priorityrating = 0;
//             double emergencyrating = 0;
//             if (widget.client.priority != null)
//               priorityrating = widget.client.priority!.toDouble();
//             if (widget.client.emergency != null)
//               emergencyrating = widget.client.emergency!.toDouble();
//             print('lib: ${widget.client.priority}');
//             if (double.parse(widget.client.total.toString()) > 0) {
//               color = primaryColor;
//             } else if (double.parse(widget.client.total.toString()) < 0) {
//               color = Colors.red;
//             }
//             if (AppUrl.filtredOpporunity.pipeline!.steps
//                 .where((element) => element.id == widget.client.stat!)
//                 .length ==
//                 0) return Container();
//
//             String? s = AppUrl.filtredOpporunity.pipeline!.steps
//                 .where((element) => element.id == widget.client.stat!)
//                 .first
//                 .name;
//             return InkWell(
//               onTap: () {
//                 PageNavigator(ctx: context).nextPage(
//                     page: OpportunityPage(
//                   client: widget.client,
//                 ));
//               },
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Container(
//                     height: 150,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.only(left: 0),
//                                   width: 150,
//                                   child: Text(
//                                     '${widget.client.lib!}',
//                                     textAlign: TextAlign.center,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headline3!
//                                         .copyWith(color: primaryColor),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 (widget.client.stat! > 0)
//                                     ? Text(
//                                         //' (${items[widget.client.stat! - 1]})',
//                                   ' (${s})',
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .headline3!
//                                             .copyWith(
//                                                 fontWeight: FontWeight.normal,
//                                                 color: Colors.red),
//                                       )
//                                     : Text(''),
//                               ],
//                             ),
//                             Text('Client: ${widget.client.name!}',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyText1!
//                                     .copyWith(color: Colors.grey)),
//                             // Text('Ville : ${widget.client.city}',
//                             //     style: Theme.of(context)
//                             //         .textTheme
//                             //         .bodyText1!
//                             //         .copyWith(color: Colors.grey)),
//                             Text(
//                               '${AppUrl.formatter.format(double.parse(widget.client.total!))} DZD',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headline4!
//                                   .copyWith(
//                                       color: color,
//                                       fontWeight: FontWeight.normal),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Priorité: ',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headline5!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 RatingBar.builder(
//                                   ignoreGestures: true,
//                                   initialRating: priorityrating,
//                                   minRating: 1.0,
//                                   maxRating: 5.0,
//                                   itemCount: 5,
//                                   itemSize: 25,
//                                   // Number of stars
//                                   itemBuilder: (context, index) => Icon(
//                                     index >= priorityrating
//                                         ? Icons.star_border_outlined
//                                         : Icons.star,
//                                     color: Colors.yellow,
//                                   ),
//                                   onRatingUpdate: (rating) {},
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Urgence: ',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headline5!
//                                       .copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 RatingBar.builder(
//                                   ignoreGestures: true,
//                                   initialRating: emergencyrating,
//                                   minRating: 1.0,
//                                   maxRating: 5.0,
//                                   itemCount: 5,
//                                   itemSize: 25,
//                                   // Number of stars
//                                   itemBuilder: (context, index) => Icon(
//                                     index >= emergencyrating
//                                         ? Icons.star_border_outlined
//                                         : Icons.star,
//                                     color: Colors.yellow,
//                                   ),
//                                   onRatingUpdate: (rating) {},
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Visibility(
//                     visible: true,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         IconButton(
//                             onPressed: () {
//                               if (widget.client.phone != null)
//                                 PhoneUtils()
//                                     .makePhoneCall(widget.client.phone!);
//                               else
//                                 _showAlertDialog(context,
//                                     'Aucun numéro de téléphone pour ce client');
//                             },
//                             icon: Icon(
//                               Icons.call,
//                               color: primaryColor,
//                             )),
//                         IconButton(
//                           onPressed: () {
//                             print('client; ${widget.client.command}');
//                             if (respone == 200) {
//                               if (widget.client.stat == 3 ||
//                                   widget.client.stat == 5)
//                                 PageNavigator(ctx: context).nextPage(
//                                     page: CommandDelivredPage(
//                                   client: widget.client,
//                                 ));
//                               else
//                                 PageNavigator(ctx: context).nextPage(
//                                     page: CommandPage(
//                                   client: widget.client,
//                                 ));
//                             } else
//                               PageNavigator(ctx: context).nextPage(
//                                   page: StorePage(
//                                 client: widget.client,
//                               ));
//                             //Navigator.pushNamed(context, '/home/command', arguments: client);
//                           },
//                           icon: (respone == 200)
//                               ? Image.asset('assets/caddie_rempli.png')
//                               : Icon(Icons.shopping_cart_outlined),
//                           color: primaryColor,
//                         ),
//                         IconButton(
//                             onPressed: () {
//                               PageNavigator(ctx: context).nextPage(
//                                   page: ActivityListPage(
//                                 client: widget.client,
//                               ));
//                             },
//                             icon: Icon(
//                               Icons.local_activity_outlined,
//                               color: primaryColor,
//                             ))
//                       ],
//                     ),
//                   ),
//                   Divider(
//                     color: Colors.grey,
//                   )
//                 ],
//               ),
//             );
//           }
//         });
//   }
// }

void _showAlertDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.yellow,
              size: 50.0,
            ),
          ],
        ),
        content: Text(
          '$text',
          style: Theme.of(context).textTheme.headline6!,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: primaryColor)),
          ),
        ],
      );
    },
  );
}
