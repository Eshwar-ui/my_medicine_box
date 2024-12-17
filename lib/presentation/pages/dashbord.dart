import 'package:flutter/material.dart';
import 'package:my_medicine_box/presentation/components/calender.dart';

class Dashbord extends StatefulWidget {
  const Dashbord({super.key});

  @override
  State<Dashbord> createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // header
        SliverAppBar(
          stretch: true,
          backgroundColor: Colors.transparent,
          expandedHeight: 260,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, left: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Medicine box",
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        const Icon(
                          Icons.notifications_none,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 29),
                        fillColor: Theme.of(context).colorScheme.primary,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 25,
                        ),
                        hintText: "search my meds...",
                        suffixIcon: Icon(Icons.mic_none_rounded)),
                  ),
                  Center(
                    child: SizedBox(
                      height: 130,
                      width: 120,
                      child: Image.asset(
                          fit: BoxFit.cover,
                          'lib/presentation/assets/images/bg_image.png'),
                    ),
                  )
                ],
              ),
            ),
          )),
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(50),
                        topEnd: Radius.circular(50)))),
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // calender widget
                  mycalender(),

                  // table widget
                  DataTable(columns: [
                    DataColumn(
                        label: Text(
                      "data",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ))
                  ], rows: [
                    DataRow(cells: [
                      DataCell(Text(
                        "hi",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ))
                    ])
                  ]),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
