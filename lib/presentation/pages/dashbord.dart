import 'package:flutter/material.dart';
import 'package:my_medicine_box/presentation/components/calender.dart';
import 'package:my_medicine_box/presentation/pages/profile.dart';

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
        SliverAppBar(
          stretch: true,
          backgroundColor: const Color(0xffD9CDB6),
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
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) {
                              return Profile();
                            }));
                          },
                          child: Icon(
                            (Icons.menu),
                          ),
                        ),
                        const Text(
                          "My Medicine box",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
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
                  const TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 29),
                        fillColor: Colors.white,
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
                          'lib/presentation/assets/images/bg image.png'),
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
                color: Colors.white,
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
                    DataColumn(label: Text("data"))
                  ], rows: [
                    DataRow(cells: [DataCell(Text("hi"))])
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
